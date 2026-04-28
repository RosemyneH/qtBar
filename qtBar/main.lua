-- ʕ •ᴥ•ʔ✿ qtBar: core, host, init ✿ʕ •ᴥ•ʔ
local _G = _G

if not _G.qtBar then
	_G.qtBar = {}
end

local qtBar = _G.qtBar
local unpack = unpack or table.unpack

qtBar.queuedUpdate = false
qtBar.old_cu_uib = nil
qtBar.pendingCustomUIBRefresh = false

local CreateFrame = _G.CreateFrame

local function _delayRun(seconds, fn)
	if type(_G.Wait) == "function" then
		_G.Wait(seconds, fn)
		return
	end
	local acc = 0
	local f = CreateFrame("Frame")
	f:SetScript("OnUpdate", function(self, el)
		acc = acc + el
		if acc >= seconds then
			self:SetScript("OnUpdate", nil)
			fn()
		end
	end)
end

function qtBar.BumpAttuneRefresh()
	qtBar._dirty = true
	qtBar.queuedUpdate = true
end

qtBar.RequestAttuneRefresh = qtBar.BumpAttuneRefresh

function qtBar.ScheduleCustomUIBRefresh()
	if qtBar.pendingCustomUIBRefresh then
		return
	end
	qtBar.pendingCustomUIBRefresh = true
	_delayRun(0.1, function()
		qtBar.pendingCustomUIBRefresh = false
		if _G.RequestUpdateList then
			local updateMask = _G.UPDATE_MASK or {
				FULL_LIST = 1,
				OBTAINED = 2,
				ATTUNED_PERCENT = 4
			}
			local o, a = updateMask.OBTAINED, updateMask.ATTUNED_PERCENT
			local bitlib = _G.bit or bit
			if bitlib and bitlib.bor then
				_G.RequestUpdateList(bitlib.bor(o, a))
			else
				_G.RequestUpdateList(o + a)
			end
		end
		qtBar.BumpAttuneRefresh()
	end)
end

function qtBar.HookCustomItemUpdateButton()
	if qtBar.hookedCustomItemUpdateButton then
		return
	end
	if type(_G._cu_uib) ~= "function" then
		return
	end
	qtBar.hookedCustomItemUpdateButton = true
	qtBar._uibHooked = true
	qtBar.old_cu_uib = _G._cu_uib
	_G._cu_uib = function(...)
		local results = { qtBar.old_cu_uib(...) }
		qtBar.ScheduleCustomUIBRefresh()
		return unpack(results)
	end
end

function qtBar._tryHookUib()
	qtBar.HookCustomItemUpdateButton()
end

function qtBar.Refresh()
	qtBar.BumpAttuneRefresh()
	qtBar.ConfigMerge()
	if not qtBar.bar or not qtBar.bar.overlay then
		qtBar.BarCreate()
	end
	if qtBar.ApplyBarLayout then
		qtBar.ApplyBarLayout()
	end
	if qtBar.LayoutBarArt then
		qtBar.LayoutBarArt()
	end
	qtBar.BarSyncFromData()
	qtBar._dirty = false
	qtBar.queuedUpdate = false
end

function qtBar.InitCore()
	qtBar.ConfigMerge()
	qtBar.BarCreate()
	qtBar.RegisterEvents()
	qtBar._tryHookUib()
	qtBar.BumpAttuneRefresh()
	qtBar.Refresh()
	qtBar._dirty = true
	qtBar.queuedUpdate = true
end

-- ʕ •ᴥ•ʔ global: Synastria runs this after custom APIs are ready (server) ✿ʕ •ᴥ•ʔ
function qtBarInit()
	if qtBar._evFrame then
		return
	end
	qtBar.InitCore()
end

if type(_G.SynastriaSafeInvoke) == "function" then
	_G.SynastriaSafeInvoke(qtBarInit)
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

