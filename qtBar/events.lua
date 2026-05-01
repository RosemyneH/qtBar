-- ʕ •ᴥ•ʔ✿ slim events → scoped attune refresh ✿ʕ •ᴥ•ʔ
local qtBar = qtBar
if not qtBar then
	return
end

local CreateFrame = CreateFrame

local PewLayoutDelaySec = 0.25

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
		if event == "QUEST_TURNED_IN" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "CHAT_MSG_SYSTEM" then
			refreshEquipped()
			return
		end
		if event == "PLAYER_ENTERING_WORLD" then
			if qtBar._tryHookUib then
				qtBar._tryHookUib()
			end
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
