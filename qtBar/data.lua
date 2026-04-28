-- ʕ •ᴥ•ʔ✿ data / attune scan ✿ ʕ •ᴥ•ʔ
if not qtBar then
	qtBar = {}
end

local qtBar = qtBar
local floor = math.floor
local min = math.min
local max = math.max

local GEAR_SLOT_MIN, GEAR_SLOT_MAX = 1, 19
local BAG_SLOT_MIN, BAG_SLOT_MAX = 0, 4

local API = qtBar.API or {}
qtBar.API = API

API.hasCustomLinkSlot = type(Custom_GetItemLinkBySlot) == "function"

local INVENTORY_SLOT_BAG_0 = 0xFF
local INVENTORY_SLOT_ITEM_START = 23
local SERVER_BAG_MAP = {
	[0] = INVENTORY_SLOT_BAG_0,
	[1] = 0x13,
	[2] = 0x14,
	[3] = 0x15,
	[4] = 0x16
}

function API:GetNativeBagSlot(bagID, slotID)
	local nativeBag = SERVER_BAG_MAP[bagID]
	if not nativeBag or not slotID then
		return nil, nil
	end
	if bagID == 0 then
		return nativeBag, INVENTORY_SLOT_ITEM_START + slotID - 1
	end
	return nativeBag, slotID - 1
end

function API:GetItemLinkBySlot(bagID, slotID)
	if API.hasCustomLinkSlot then
		local nb, ns = API:GetNativeBagSlot(bagID, slotID)
		if nb and ns then
			local link = Custom_GetItemLinkBySlot(nb, ns)
			if link then
				return link
			end
		end
	end
	return GetContainerItemLink(bagID, slotID)
end

local function isAttuneApiReady()
	return GetCustomGameData(41, 0) ~= 0
end

local function clearSnapshot(out, notReady)
	local rows = out.slots
	for i = 1, #(rows or {}) do
		rows[i] = nil
	end
	out.average = 0
	out.count = 0
	out.allComplete = false
	out.notReady = notReady and true or false
	out.hash = 0
end

local function getProgressByLink(link, isEligibleFn)
	if not link then
		return nil, nil
	end
	if not isAttuneApiReady() then
		return nil, nil
	end
	local extractItemId = CustomExtractItemId
	local isEligible = isEligibleFn
	local getLinkProgress = GetItemLinkAttuneProgress
	if type(extractItemId) ~= "function" or type(isEligible) ~= "function" or type(getLinkProgress) ~= "function" then
		return nil, nil
	end
	local itemId = extractItemId(link)
	if not itemId or itemId <= 0 then
		return nil, nil
	end
	if (isEligible(itemId) or 0) <= 0 then
		return nil, itemId
	end
	local progress = getLinkProgress(link)
	if type(progress) ~= "number" then
		return nil, itemId
	end
	progress = max(0, min(100, progress))
	return progress, itemId
end

function qtBar.FormatAttuneLabel(snap, prefix)
	if not snap then
		return (prefix or "Attune") .. ": --"
	end
	if snap.notReady then
		return (prefix or "Attune") .. ": --"
	end
	if snap.allComplete then
		return string.format("%s: 100%%", prefix or "Attune")
	end
	local p = floor(snap.average + 0.5)
	local db = qtBar.db
	if db and db.showAttuneSlotCount and snap.count and snap.count > 0 then
		return string.format("%s: %d%%  (%d slots)", prefix or "Attune", p, snap.count)
	end
	return string.format("%s: %d%%", prefix or "Attune", p)
end

-- Integer mix; no string allocs (poll-friendly).
function qtBar.AttuneFingerprintHash(snap)
	if not snap then
		return 0
	end
	if type(snap.hash) == "number" then
		return snap.hash
	end
	if snap.allComplete then
		return -1
	end
	local MOD = 4294967291
	local h = floor((snap.average or 0) * 10000 + 0.5) % MOD
	h = (h * 31 + (snap.count or 0)) % MOD
	local bitlib = bit
	local slots = snap.slots
	for i = 1, #(slots or {}) do
		local row = slots[i]
		if row then
			local bagPart = (row.bag or 0) + 10
			local part = (bagPart * 1000000) + ((row.slot or 0) * 1000) + floor((row.progress or 0) * 10 + 0.5)
			if bitlib and bitlib.bxor then
				h = bitlib.bxor(h * 33, part % MOD)
			else
				h = (h * 33 + part) % MOD
			end
		end
	end
	return h
end

qtBar.FingerprintAttuneSnapshot = qtBar.AttuneFingerprintHash

function qtBar.CacheAttuneSnapshot(snap)
	if not snap then
		return
	end
	qtBar._lastAttuneSnap = snap
	qtBar._lastAttuneFp = qtBar.AttuneFingerprintHash(snap)
end

function qtBar.RefreshAttuneCacheFromWorld()
	if not qtBar.GetEquippedAttunementSnapshot or not qtBar.GetBagAttunementSnapshot then
		return nil
	end
	if not isAttuneApiReady() then
		return nil
	end
	local equippedSnap = qtBar.GetEquippedAttunementSnapshot()
	local bagSnap = qtBar.GetBagAttunementSnapshot()
	qtBar._lastEquippedSnap = equippedSnap
	qtBar._lastBagSnap = bagSnap
	qtBar._lastEquippedFp = qtBar.AttuneFingerprintHash(equippedSnap)
	qtBar._lastBagFp = qtBar.AttuneFingerprintHash(bagSnap)
	return equippedSnap, bagSnap
end

function qtBar.GetEquippedAttunementSnapshot()
	local out = qtBar._equippedAttuneSnap
	if not out then
		out = { slots = {}, average = 0, count = 0, allComplete = false, hash = 0 }
		qtBar._equippedAttuneSnap = out
	end
	if not isAttuneApiReady() then
		clearSnapshot(out, true)
		return out
	end
	local sum = 0
	local n = 0
	local hasNumericAttune = false
	local hasIncomplete = false
	local MOD = 4294967291
	local hash = 2166136261
	local bitlib = bit
	local canAttuneItem = CanAttuneItemHelper
	if type(canAttuneItem) ~= "function" then
		clearSnapshot(out, true)
		return out
	end

	for slot = GEAR_SLOT_MIN, GEAR_SLOT_MAX do
		local link = GetInventoryItemLink("player", slot)
		if link then
			local p = getProgressByLink(link, canAttuneItem)
			if type(p) == "number" then
				hasNumericAttune = true
				if p < 100 then
					hasIncomplete = true
					n = n + 1
					sum = sum + p
					local part = (10 * 1000000) + (slot * 1000) + floor(p * 10 + 0.5)
					if bitlib and bitlib.bxor then
						hash = bitlib.bxor(hash * 16777619, part % MOD)
					else
						hash = (hash * 16777619 + part) % MOD
					end
				end
			end
		end
	end

	local average = n > 0 and (sum / n) or 0

	local allComplete = hasNumericAttune and not hasIncomplete
	if allComplete then
		average = 100
	end

	out.slots = out.slots or {}
	out.average = average
	out.count = n
	out.allComplete = allComplete
	out.notReady = false
	if allComplete then
		out.hash = -1
	else
		hash = (hash * 31 + n) % MOD
		hash = (hash * 31 + floor(average * 10000 + 0.5)) % MOD
		out.hash = hash
	end

	return out
end

function qtBar.GetBagAttunementSnapshot()
	local out = qtBar._bagAttuneSnap
	if not out then
		out = { slots = {}, average = 0, count = 0, allComplete = false, hash = 0 }
		qtBar._bagAttuneSnap = out
	end
	if not isAttuneApiReady() then
		clearSnapshot(out, true)
		return out
	end
	local sum = 0
	local n = 0
	local hasNumericAttune = false
	local hasIncomplete = false
	local MOD = 4294967291
	local hash = 2166136261
	local bitlib = bit
	local isAttunableBySomeone = IsAttunableBySomeone
	if type(isAttunableBySomeone) ~= "function" then
		clearSnapshot(out, true)
		return out
	end

	for bag = BAG_SLOT_MIN, BAG_SLOT_MAX do
		local slotCount = GetContainerNumSlots and GetContainerNumSlots(bag) or 0
		for slot = 1, slotCount do
			local link = API:GetItemLinkBySlot(bag, slot)
			if link then
				local p = getProgressByLink(link, isAttunableBySomeone)
				if type(p) == "number" then
					hasNumericAttune = true
					if p < 100 then
						hasIncomplete = true
						n = n + 1
						sum = sum + p
						local part = ((bag + 10) * 1000000) + (slot * 1000) + floor(p * 10 + 0.5)
						if bitlib and bitlib.bxor then
							hash = bitlib.bxor(hash * 16777619, part % MOD)
						else
							hash = (hash * 16777619 + part) % MOD
						end
					end
				end
			end
		end
	end

	local average = n > 0 and (sum / n) or 0
	local allComplete = hasNumericAttune and not hasIncomplete
	if allComplete then
		average = 100
	end

	out.slots = out.slots or {}
	out.average = average
	out.count = n
	out.allComplete = allComplete
	out.notReady = false
	if allComplete then
		out.hash = -1
	else
		hash = (hash * 31 + n) % MOD
		hash = (hash * 31 + floor(average * 10000 + 0.5)) % MOD
		out.hash = hash
	end

	return out
end
