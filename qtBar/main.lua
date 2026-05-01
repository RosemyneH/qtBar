-- ʕ •ᴥ•ʔ✿ qtBar: core, host, init ✿ʕ •ᴥ•ʔ
if not qtBar then
	qtBar = {}
end

local qtBar = qtBar

local CreateFrame = CreateFrame

-- ʕ •ᴥ•ʔ one delayed attune pass after first paint (enough for APIs to be ready) ✿ʕ •ᴥ•ʔ
local function scheduleDelayedAttuneDisplay(seconds)
	local f = qtBar._qtBarAttuneDelayFrame
	if f then
		f:SetScript("OnUpdate", nil)
	end
	f = CreateFrame("Frame")
	qtBar._qtBarAttuneDelayFrame = f
	f:Hide()
	local acc = 0
	f:SetScript("OnUpdate", function(self, el)
		acc = acc + (el or 0)
		if acc < seconds then
			return
		end
		self:SetScript("OnUpdate", nil)
		if qtBar.RefreshAttuneDisplay then
			qtBar.RefreshAttuneDisplay()
		end
		if qtBar._tryHookUib then
			qtBar._tryHookUib()
		end
	end)
	f:Show()
end

function qtBar.RefreshAttuneDisplay(which, bagID)
	local scope = which or "all"
	if scope == "bag" then
		if qtBar.RefreshBagAttunementSnapshot then
			qtBar.RefreshBagAttunementSnapshot(bagID)
		end
		if qtBar.BarSyncFromData then
			qtBar.BarSyncFromData("bag")
		end
		return
	end
	if scope == "equipped" then
		if qtBar.RefreshEquippedAttunementSnapshot then
			qtBar.RefreshEquippedAttunementSnapshot()
		end
		if qtBar.BarSyncFromData then
			qtBar.BarSyncFromData("equipped")
		end
		return
	end
	if qtBar.RefreshEquippedAttunementSnapshot then
		qtBar.RefreshEquippedAttunementSnapshot()
	end
	if qtBar.RefreshBagAttunementSnapshot then
		qtBar.RefreshBagAttunementSnapshot()
	end
	if qtBar.BarSyncFromData then
		qtBar.BarSyncFromData()
	end
end

function qtBar.BumpAttuneRefresh(which, bagID)
	qtBar.RefreshAttuneDisplay(which, bagID)
end

qtBar.RequestAttuneRefresh = qtBar.BumpAttuneRefresh

-- ʕ •ᴥ•ʔ✿ Synastria _cu_uib: attune / custom item UI updates ✿ʕ •ᴥ•ʔ
function qtBar.ScheduleCustomUIBRefresh()
	local f = qtBar._qtBarCustomUIBDefer
	if f then
		return
	end
	f = CreateFrame("Frame")
	qtBar._qtBarCustomUIBDefer = f
	f:SetScript("OnUpdate", function(self)
		self:SetScript("OnUpdate", nil)
		qtBar._qtBarCustomUIBDefer = nil
		qtBar.BumpAttuneRefresh()
	end)
end

function qtBar.HookCustomItemUpdateButton()
	if qtBar.hookedCustomItemUpdateButton then
		return
	end
	if type(_cu_uib) ~= "function" then
		return
	end
	qtBar.hookedCustomItemUpdateButton = true
	qtBar._uibHooked = true
	qtBar.old_cu_uib = _cu_uib
	_cu_uib = function(...)
		qtBar.ScheduleCustomUIBRefresh()
		return qtBar.old_cu_uib(...)
	end
end

function qtBar._tryHookUib()
	qtBar.HookCustomItemUpdateButton()
end

function qtBar.Refresh()
	qtBar.ConfigMerge()
	if not qtBar.bar or not qtBar.bar.overlay then
		qtBar.BarCreate()
	end
	if qtBar.ApplyBarLayout then
		qtBar.ApplyBarLayout()
	end
	if qtBar.ApplyBarTextureStyle then
		qtBar.ApplyBarTextureStyle()
	end
	if qtBar.LayoutBarArt then
		qtBar.LayoutBarArt()
	end
	if qtBar.ApplyBarInsetFills then
		qtBar.ApplyBarInsetFills()
	end
	qtBar.RefreshAttuneDisplay()
end

function qtBar.InitCore()
	qtBar.ConfigMerge()
	qtBar.BarCreate()
	qtBar.RegisterEvents()
	if qtBar._tryHookUib then
		qtBar._tryHookUib()
	end
	qtBar.Refresh()
	scheduleDelayedAttuneDisplay(0.5)
end

-- ʕ •ᴥ•ʔ global: Synastria runs this after custom APIs are ready (server) ✿ʕ •ᴥ•ʔ
function qtBarInit()
	if qtBar._evFrame then
		return
	end
	qtBar.InitCore()
end
if type(SynastriaSafeInvoke) == "function" then
	SynastriaSafeInvoke(qtBarInit)
else
	qtBarInit()
end

local qtBarBoot = CreateFrame("Frame")
qtBarBoot:RegisterEvent("PLAYER_ENTERING_WORLD")
qtBarBoot:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if not qtBar._evFrame then
		qtBarInit()
	end
	if qtBar.ConfigMerge then
		qtBar.ConfigMerge()
	end
	if qtBar.ApplyBarLayout then
		qtBar.ApplyBarLayout()
	end
	if qtBar.Refresh then
		qtBar.Refresh()
	end
end)

