-- ʕ •ᴥ•ʔ✿ data / attune scan ✿ ʕ •ᴥ•ʔ
if not qtBar then
	qtBar = {}
end

local qtBar = qtBar
local floor = math.floor
local min = math.min
local max = math.max
local pairs = pairs

local BAG_SLOT_MIN, BAG_SLOT_MAX = 0, 4
local EQUIPPED_SLOT_IDS = { 1, 2, 3, 15, 5, 9, 10, 6, 7, 8, 11, 12, 13, 14, 16, 17, 18 }

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

local function wipeTable(t)
	for k in pairs(t) do
		t[k] = nil
	end
end

local function createMemoryArena()
	return {
		rows = {},
		used = 0
	}
end

local function resetMemoryArena(arena)
	if not arena then
		return
	end
	for i = 1, arena.used do
		local row = arena.rows[i]
		if row then
			wipeTable(row)
		end
	end
	arena.used = 0
end

local function allocArenaRow(arena)
	arena.used = arena.used + 1
	local row = arena.rows[arena.used]
	if not row then
		row = {}
		arena.rows[arena.used] = row
	end
	return row
end

function qtBar.CreateMemoryArena()
	return createMemoryArena()
end

function qtBar.ResetMemoryArena(arena)
	resetMemoryArena(arena)
end

function qtBar.AllocMemoryArenaRow(arena)
	if not arena then
		return nil
	end
	return allocArenaRow(arena)
end

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

local function clearRows(rows)
	for i = 1, #(rows or {}) do
		rows[i] = nil
	end
end

local function ensureSnapshot(out)
	out.slots = out.slots or {}
	out._arena = out._arena or createMemoryArena()
	return out
end

local function clearSnapshot(out, notReady)
	ensureSnapshot(out)
	resetMemoryArena(out._arena)
	clearRows(out.slots)
	out.average = 0
	out.count = 0
	out.allComplete = false
	out.notReady = notReady and true or false
	out.hash = 0
end

local function newSnapshot()
	return ensureSnapshot({ average = 0, count = 0, allComplete = false, hash = 0 })
end

local function addSnapshotSlot(out, bag, slot, progress, itemId)
	local row = allocArenaRow(out._arena)
	row.bag = bag
	row.slot = slot
	row.progress = progress
	row.itemId = itemId
	out.slots[#out.slots + 1] = row
	return row
end

local function mixHash(hash, part, mod, bitlib)
	if bitlib and bitlib.bxor then
		return bitlib.bxor(hash * 16777619, part % mod)
	end
	return (hash * 16777619 + part) % mod
end

local function finishSnapshot(out, sum, count, hasNumericAttune, hasIncomplete, hash, mod)
	local average = count > 0 and (sum / count) or 0
	local allComplete = hasNumericAttune and not hasIncomplete
	if allComplete then
		average = 100
	end

	out.average = average
	out.count = count
	out.allComplete = allComplete
	out.notReady = false
	if allComplete then
		out.hash = -1
	else
		hash = (hash * 31 + count) % mod
		hash = (hash * 31 + floor(average * 10000 + 0.5)) % mod
		out.hash = hash
	end

	return out
end

local function getProgressByLink(link, isEligibleFn, allowProgressWithoutEligibility)
	if not link then
		return nil, nil
	end
	if not isAttuneApiReady() then
		return nil, nil
	end
	local extractItemId = CustomExtractItemId
	local isEligible = isEligibleFn
	local getLinkProgress = GetItemLinkAttuneProgress
	if type(extractItemId) ~= "function" or type(getLinkProgress) ~= "function" then
		return nil, nil
	end
	if type(isEligible) ~= "function" and not allowProgressWithoutEligibility then
		return nil, nil
	end
	local itemId = extractItemId(link)
	if not itemId or itemId <= 0 then
		return nil, nil
	end
	local progress = getLinkProgress(link)
	if type(progress) ~= "number" then
		return nil, itemId
	end
	progress = max(0, min(100, progress))
	if type(isEligible) == "function" and (isEligible(itemId) or 0) <= 0 and not allowProgressWithoutEligibility then
		return nil, itemId
	end
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
	if not qtBar.RefreshEquippedAttunementSnapshot or not qtBar.RefreshBagAttunementSnapshot then
		return nil
	end
	if not isAttuneApiReady() then
		return nil
	end
	local equippedSnap = qtBar.RefreshEquippedAttunementSnapshot()
	local bagSnap = qtBar.RefreshBagAttunementSnapshot()
	qtBar._lastEquippedSnap = equippedSnap
	qtBar._lastBagSnap = bagSnap
	qtBar._lastEquippedFp = qtBar.AttuneFingerprintHash(equippedSnap)
	qtBar._lastBagFp = qtBar.AttuneFingerprintHash(bagSnap)
	return equippedSnap, bagSnap
end

local function getEquippedSnapshot()
	local out = qtBar._equippedAttuneSnap
	if not out then
		out = newSnapshot()
		qtBar._equippedAttuneSnap = out
	end
	return out
end

function qtBar.RefreshEquippedAttunementSnapshot()
	local out = getEquippedSnapshot()
	clearSnapshot(out, false)
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
	local getLinkProgress = GetItemLinkAttuneProgress
	if type(canAttuneItem) ~= "function" or type(getLinkProgress) ~= "function" then
		clearSnapshot(out, true)
		return out
	end

	for _, slot in ipairs(EQUIPPED_SLOT_IDS) do
		local itemId = GetInventoryItemID("player", slot)
		if itemId and canAttuneItem(itemId) >= 1 then
			local link = GetInventoryItemLink("player", slot)
			local p = link and getLinkProgress(link) or nil
			if type(p) == "number" then
				p = max(0, min(100, p))
				hasNumericAttune = true
				if p < 100 then
					hasIncomplete = true
					n = n + 1
					sum = sum + p
					addSnapshotSlot(out, nil, slot, p, itemId)
				end
				local part = (10 * 1000000) + (slot * 1000) + floor(p * 10 + 0.5)
				hash = mixHash(hash, part, MOD, bitlib)
			end
		end
	end

	return finishSnapshot(out, sum, n, hasNumericAttune, hasIncomplete, hash, MOD)
end

function qtBar.GetEquippedAttunementSnapshot()
	local out = qtBar._equippedAttuneSnap
	if not out or out.notReady then
		return qtBar.RefreshEquippedAttunementSnapshot()
	end
	return out
end

local function getBagSnapshot()
	local out = qtBar._bagAttuneSnap
	if not out then
		out = newSnapshot()
		qtBar._bagAttuneSnap = out
	end
	return out
end

local function ensureBagCache()
	local cache = qtBar._bagAttuneCache
	if not cache then
		cache = { bags = {}, hydrated = false }
		qtBar._bagAttuneCache = cache
	end
	return cache
end

local function ensureBagState(cache, bag)
	local state = cache.bags[bag]
	if not state then
		state = newSnapshot()
		cache.bags[bag] = state
	end
	return state
end

local function scanBagState(cache, bag)
	local state = ensureBagState(cache, bag)
	clearSnapshot(state, false)
	if not isAttuneApiReady() then
		clearSnapshot(state, true)
		return state
	end
	local sum = 0
	local n = 0
	local hasNumericAttune = false
	local hasIncomplete = false
	local MOD = 4294967291
	local hash = 2166136261
	local bitlib = bit
	local canAttuneItem = CanAttuneItemHelper
	local isAttunableBySomeone = IsAttunableBySomeone
	local extractItemId = CustomExtractItemId
	local getLinkProgress = GetItemLinkAttuneProgress
	if type(extractItemId) ~= "function" or type(getLinkProgress) ~= "function" then
		clearSnapshot(state, true)
		return state
	end

	local slotCount = GetContainerNumSlots and GetContainerNumSlots(bag) or 0
	for slot = 1, slotCount do
		local link = GetContainerItemInfo and select(7, GetContainerItemInfo(bag, slot)) or nil
		if not link then
			link = API:GetItemLinkBySlot(bag, slot)
		end
		if link then
			local itemId = extractItemId(link)
			local canAttuneNormally = itemId and type(canAttuneItem) == "function" and canAttuneItem(itemId) >= 1
			local canAttuneForSomeone = itemId and type(isAttunableBySomeone) == "function" and (isAttunableBySomeone(itemId) or 0) ~= 0
			if canAttuneNormally or canAttuneForSomeone then
				local p = getLinkProgress(link)
				if type(p) == "number" then
					p = max(0, min(100, p))
					hasNumericAttune = true
					if p < 100 then
						hasIncomplete = true
						n = n + 1
						sum = sum + p
						addSnapshotSlot(state, bag, slot, p, itemId)
						local part = ((bag + 10) * 1000000) + (slot * 1000) + floor(p * 10 + 0.5)
						hash = mixHash(hash, part, MOD, bitlib)
					end
				end
			end
		end
	end

	return finishSnapshot(state, sum, n, hasNumericAttune, hasIncomplete, hash, MOD)
end

local function rebuildBagSnapshot(cache, out)
	clearSnapshot(out, false)

	local sum = 0
	local n = 0
	local hasNumericAttune = false
	local hasIncomplete = false
	local MOD = 4294967291
	local hash = 2166136261
	local bitlib = bit
	local anyReady = false

	for bag = BAG_SLOT_MIN, BAG_SLOT_MAX do
		local state = cache.bags[bag]
		if state and not state.notReady then
			anyReady = true
			if state.count and state.count > 0 then
				hasIncomplete = true
				n = n + state.count
				sum = sum + ((state.average or 0) * state.count)
			end
			if state.allComplete or (state.count and state.count > 0) then
				hasNumericAttune = true
			end
			local rows = state.slots
			for i = 1, #(rows or {}) do
				local src = rows[i]
				if src then
					addSnapshotSlot(out, src.bag, src.slot, src.progress, src.itemId)
					local part = (((src.bag or 0) + 10) * 1000000) + ((src.slot or 0) * 1000) + floor((src.progress or 0) * 10 + 0.5)
					hash = mixHash(hash, part, MOD, bitlib)
				end
			end
		end
	end

	if not anyReady then
		clearSnapshot(out, true)
		return out
	end

	return finishSnapshot(out, sum, n, hasNumericAttune, hasIncomplete, hash, MOD)
end

function qtBar.RefreshBagAttunementSnapshot(bagID)
	local out = getBagSnapshot()
	local cache = ensureBagCache()
	local bag = tonumber(bagID)
	local scanSingle = cache.hydrated and bag and bag >= BAG_SLOT_MIN and bag <= BAG_SLOT_MAX

	if scanSingle then
		scanBagState(cache, bag)
	else
		for i = BAG_SLOT_MIN, BAG_SLOT_MAX do
			scanBagState(cache, i)
		end
		cache.hydrated = isAttuneApiReady()
	end

	return rebuildBagSnapshot(cache, out)
end

function qtBar.GetBagAttunementSnapshot()
	local out = qtBar._bagAttuneSnap
	if not out or out.notReady then
		return qtBar.RefreshBagAttunementSnapshot()
	end
	return out
end
