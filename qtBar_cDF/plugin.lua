-- ʕ •ᴥ•ʔ✿ cDF: wake standalone qtBar after cDF setup ✿ʕ •ᴥ•ʔ
local _G = _G
local CreateFrame = _G.CreateFrame

local function kickQtBar()
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

local function later(seconds, fn)
	local acc = 0
	local x = CreateFrame("Frame")
	x:SetScript("OnUpdate", function(self, el)
		acc = acc + el
		if acc < seconds then
			return
		end
		self:SetScript("OnUpdate", nil)
		fn()
	end)
end

local function staggerKicks()
	kickQtBar()
	later(0.2, kickQtBar)
	later(0.85, kickQtBar)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(_, e, name)
	if e == "ADDON_LOADED" and (name == "qtBar_cDF" or name == "cDF") then
		local t = 0
		f:SetScript("OnUpdate", function(self, el)
			t = t + el
			if t < 0.02 then
				return
			end
			self:SetScript("OnUpdate", nil)
			staggerKicks()
		end)
		return
	end
	if e == "PLAYER_ENTERING_WORLD" then
		staggerKicks()
	end
end)
