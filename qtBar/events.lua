-- ʕ •ᴥ•ʔ✿ slim events → scoped attune refresh ✿ʕ •ᴥ•ʔ
local qtBar = qtBar
if not qtBar then
	return
end

local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitGUID = UnitGUID

local PewLayoutDelaySec = 0.25
local CLEU_THROTTLE_SEC = 0.2
local lastCLEUAttune = 0
local playerGUID

local function scheduleDelayedLayoutApply()
	local prev = qtBar._pewLayoutDeferFrame
	if prev then
		prev:SetScript("OnUpdate", nil)
	end
	local d = CreateFrame("Frame")
	qtBar._pewLayoutDeferFrame = d
	local acc = 0
	d:SetScript("OnUpdate", function(self, el)
		acc = acc + el
		if acc < PewLayoutDelaySec then
			return
		end
		self:SetScript("OnUpdate", nil)
		if qtBar._pewLayoutDeferFrame == self then
			qtBar._pewLayoutDeferFrame = nil
		end
		if qtBar.ConfigMerge then
			qtBar.ConfigMerge()
		end
		if qtBar.ApplyBarLayout then
			qtBar.ApplyBarLayout()
		end
		if qtBar.LayoutBarArt then
			qtBar.LayoutBarArt()
		end
		qtBar.BumpAttuneRefresh()
	end)
end

local function refreshEquipped()
	qtBar.BumpAttuneRefresh("equipped")
end

-- PARTY_KILL as a top-level event is not reliable; CLEU carries PARTY_KILL and UNIT_DIED
local function maybeRefreshFromCombatLog()
	local t = (type(GetTime) == "function" and GetTime()) or 0
	if t - lastCLEUAttune < CLEU_THROTTLE_SEC then
		return
	end
	lastCLEUAttune = t
	if qtBar.RefreshEquippedAttunementSnapshot then
		local snap = qtBar.RefreshEquippedAttunementSnapshot()
		local n = snap and tonumber(snap.count) or 0
		if n > 0 then
			if qtBar.BarSyncFromData then
				qtBar.BarSyncFromData("equipped")
			end
			return
		end
	end
	qtBar.BumpAttuneRefresh()
end

local function refreshAll()
	qtBar.BumpAttuneRefresh()
end

function qtBar.RegisterEvents()
	if qtBar._evFrame then
		return
	end
	local f = CreateFrame("Frame")
	qtBar._evFrame = f

	local eventList = {
		"COMBAT_LOG_EVENT_UNFILTERED",
		"QUEST_TURNED_IN",
		"PLAYER_EQUIPMENT_CHANGED",
		"UNIT_INVENTORY_CHANGED",
		"CHAT_MSG_SYSTEM",
		"PLAYER_ENTERING_WORLD",
		"PLAYER_LOGOUT"
	}

	for _, ev in ipairs(eventList) do
		f:RegisterEvent(ev)
	end

	f:SetScript("OnEvent", function(_, event, ...)
		if event == "UNIT_INVENTORY_CHANGED" then
			local unit = ...
			if unit and unit ~= "player" then
				return
			end
			refreshEquipped()
			return
		end
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			if not playerGUID and type(UnitGUID) == "function" then
				playerGUID = UnitGUID("player")
			end
			-- ʕ •ᴥ•ʔ WotLK CLEU: see API_COMBAT_LOG_EVENT (subEvent + base params include hideCaster) ✿ʕ •ᴥ•ʔ
			local subEvent = select(2, ...)
			local sourceGUID = select(4, ...)
			local petGUID = type(UnitGUID) == "function" and UnitGUID("pet") or nil
			local isKillCredit = (subEvent == "PARTY_KILL" or subEvent == "UNIT_DIED")
			local isOurSource = sourceGUID
				and playerGUID
				and (sourceGUID == playerGUID or (petGUID and sourceGUID == petGUID))
			if isKillCredit and isOurSource then
				maybeRefreshFromCombatLog()
			end
			return
		end
		if event == "QUEST_TURNED_IN" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "CHAT_MSG_SYSTEM" then
			refreshEquipped()
			return
		end
		if event == "PLAYER_ENTERING_WORLD" then
			playerGUID = UnitGUID("player")
			refreshAll()
			scheduleDelayedLayoutApply()
			return
		end
		if event == "PLAYER_LOGOUT" then
			if qtBar.PersistLayout then
				qtBar.PersistLayout()
			end
			return
		end
	end)
end
