-- ʕ •ᴥ•ʔ✿ ElvUI: wake standalone qtBar after UI setup ✿ʕ •ᴥ•ʔ
local _G = _G

local function refreshQtBar()
	local q = _G.qtBar
	if not q then
		return
	end
	if q.RefreshAttuneCacheFromWorld then
		q.RefreshAttuneCacheFromWorld()
	end
	if q.BumpAttuneRefresh then
		q.BumpAttuneRefresh()
	end
end

local f = _G.CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(_, e, name)
	if e == "ADDON_LOADED" and name ~= "ElvUI" and name ~= "qtBar_ElvUI" then
		return
	end
	if e == "ADDON_LOADED" and (name == "ElvUI" or name == "qtBar_ElvUI") then
		local t = 0
		f:SetScript("OnUpdate", function(self, el)
			t = t + el
			if t < 0.8 then
				return
			end
			self:SetScript("OnUpdate", nil)
			refreshQtBar()
		end)
		return
	end
	if e == "PLAYER_ENTERING_WORLD" then
		refreshQtBar()
	end
end)
