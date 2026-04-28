-- ʕ •ᴥ•ʔ✿ data / attune scan ✿ ʕ •ᴥ•ʔ
local _G = _G

if not _G.qtBar then
	_G.qtBar = {}
end

local qtBar = _G.qtBar
local floor = math.floor
local min = math.min
local max = math.max

local GEAR_SLOT_MIN, GEAR_SLOT_MAX = 1, 19

function qtBar.FormatAttuneLabel(snap)
	if not snap then
		return "Attune: --"
	end
	if snap.allComplete then
		return "Attune: 100%"
	end
	local p = floor(snap.average + 0.5)
	local db = qtBar.db
	if db and db.showAttuneSlotCount and snap.count and snap.count > 0 then
		return string.format("Attune: %d%%  (%d slots)", p, snap.count)
	end
	return string.format("Attune: %d%%", p)
end

-- Integer mix; no string allocs (poll-friendly).
function qtBar.AttuneFingerprintHash(snap)
	if not snap then
		return 0
	end
	if snap.allComplete then
		return -1
	end
	local MOD = 4294967291
	local h = floor((snap.average or 0) * 10000 + 0.5) % MOD
	h = (h * 31 + (snap.count or 0)) % MOD
	local bitlib = _G.bit or bit
	local slots = snap.slots
	for i = 1, #(slots or {}) do
		local row = slots[i]
		if row then
			local part = row.slot * 100000 + floor((row.progress or 0) * 1000 + 0.5)
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
	if not qtBar.GetEquippedAttunementSnapshot then
		return nil
	end
	local snap = qtBar.GetEquippedAttunementSnapshot()
	qtBar.CacheAttuneSnapshot(snap)
	return snap
end

function qtBar.GetEquippedAttunementSnapshot()
	local CanAttuneItemHelper = _G.CanAttuneItemHelper
	local GetLinkProgress = _G.GetItemLinkAttuneProgress

	local out = qtBar._attuneSnap
	if not out then
		out = { slots = {}, average = 0, count = 0, allComplete = false }
		qtBar._attuneSnap = out
	end
	local rows = out.slots
	local prevLen = #rows

	local sum = 0
	local n = 0
	local hasNumericAttune = false
	local hasIncomplete = false

	for slot = GEAR_SLOT_MIN, GEAR_SLOT_MAX do
		local link = _G.GetInventoryItemLink("player", slot)
		if link then
			local itemId = _G.GetInventoryItemID("player", slot) or 0
			if itemId > 0
				and CanAttuneItemHelper
				and CanAttuneItemHelper(itemId) > 0
			then
				if GetLinkProgress then
					local p = GetLinkProgress(link)
					if type(p) == "number" then
						hasNumericAttune = true
						p = max(0, min(100, p))
						if p < 100 then
							hasIncomplete = true
							n = n + 1
							local row = rows[n]
							if not row then
								row = {}
								rows[n] = row
							end
							row.slot = slot
							row.progress = p
							sum = sum + p
						end
					end
				end
			end
		end
	end

	for i = n + 1, prevLen do
		rows[i] = nil
	end

	local average = n > 0 and (sum / n) or 0

	local allComplete = hasNumericAttune and not hasIncomplete
	if allComplete then
		average = 100
	end

	out.slots = rows
	out.average = average
	out.count = n
	out.allComplete = allComplete

	return out
end
