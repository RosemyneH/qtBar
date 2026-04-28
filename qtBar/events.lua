-- ʕ •ᴥ•ʔ✿ slim events → refresh (no CLEU) ✿ʕ •ᴥ•ʔ
local _G = _G
local qtBar = _G.qtBar
if not qtBar then
	return
end

local GetTime = _G.GetTime

local THROTTLE_REGEN_OFF = 0.45
local lastAt = {}

local function markNow()
	qtBar.BumpAttuneRefresh()
end

local function markThrottled(key, interval)
	interval = interval or 0.35
	local t = GetTime()
	local nextOk = (lastAt[key] or 0) + interval
	if t < nextOk then
		return
	end
	lastAt[key] = t
	markNow()
end

function qtBar.RegisterEvents()
	if qtBar._evFrame then
		return
	end
	local f = _G.CreateFrame("Frame")
	qtBar._evFrame = f

	local eventList = {
		"UNIT_INVENTORY_CHANGED",
		"PLAYER_ENTERING_WORLD",
		"PLAYER_LEVEL_UP",
		"QUEST_LOG_UPDATE",
		"LOOT_CLOSED",
		"PLAYER_REGEN_ENABLED",
		"PLAYER_REGEN_DISABLED"
	}

	for _, ev in ipairs(eventList) do
		f:RegisterEvent(ev)
	end

	f:SetScript("OnEvent", function(_, event, ...)
		if event == "PLAYER_REGEN_DISABLED" then
			markThrottled("regen_off", THROTTLE_REGEN_OFF)
			return
		end
		if event == "UNIT_INVENTORY_CHANGED" then
			local unit = ...
			if unit and unit ~= "player" then
				return
			end
			markNow()
			return
		end
		if event == "QUEST_LOG_UPDATE" then
			markThrottled("quest", 0.35)
			return
		end
		if event == "LOOT_CLOSED" then
			markThrottled("loot", 0.35)
			return
		end
		if event == "PLAYER_REGEN_ENABLED" then
			markNow()
			return
		end
		if event == "PLAYER_LEVEL_UP" then
			markNow()
			return
		end
		if event == "PLAYER_ENTERING_WORLD" then
			qtBar._tryHookUib()
			if qtBar.RefreshAttuneCacheFromWorld then
				qtBar.RefreshAttuneCacheFromWorld()
			end
			markNow()
			return
		end
	end)
end
