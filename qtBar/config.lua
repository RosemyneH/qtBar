-- ʕ •ᴥ•ʔ✿ saved settings + /qtbar frame ✿ʕ •ᴥ•ʔ
local _G = _G
local qtBar = _G.qtBar
if not qtBar then
	return
end

local UIParent = _G.UIParent
local format = string.format

qtBar.DEFAULTS = {
	hideWhileLeveling = false,
	maxLevel = 80,
	fillColor = { r = 0.25, g = 0.55, b = 0.95, a = 1 },
	showAttuneSlotCount = true,
	point = "BOTTOM",
	relativePoint = "BOTTOM",
	x = 0,
	y = 53,
	width = 1024,
	height = 13
}

function qtBar.ConfigCopyDefaults()
	local t = {}
	for k, v in pairs(qtBar.DEFAULTS) do
		if type(v) == "table" then
			t[k] = { r = v.r, g = v.g, b = v.b, a = v.a }
		else
			t[k] = v
		end
	end
	return t
end

function qtBar.ConfigMerge()
	_G.qtBarDB = _G.qtBarDB or {}
	local db = _G.qtBarDB
	local d = qtBar.DEFAULTS
	for k, v in pairs(d) do
		if db[k] == nil then
			if type(v) == "table" and v.r then
				db[k] = { r = v.r, g = v.g, b = v.b, a = v.a }
			else
				db[k] = v
			end
		end
	end
	if type(db.fillColor) ~= "table" then
		local c = d.fillColor
		db.fillColor = { r = c.r, g = c.g, b = c.b, a = c.a }
	else
		local c = d.fillColor
		db.fillColor.r = db.fillColor.r or c.r
		db.fillColor.g = db.fillColor.g or c.g
		db.fillColor.b = db.fillColor.b or c.b
		db.fillColor.a = db.fillColor.a or c.a
	end
	db.width = tonumber(db.width) or d.width
	db.height = tonumber(db.height) or d.height
	db.x = tonumber(db.x) or d.x
	db.y = tonumber(db.y) or d.y
	db.point = db.point or d.point
	db.relativePoint = db.relativePoint or d.relativePoint
	qtBar.db = db
end

local function makeCheck(name, parent, y, text, get, set)
	local c = _G.CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
	c:SetPoint("TOPLEFT", 20, y)
	_G[name .. "Text"]:SetText(text)
	c:SetScript("OnClick", function()
		set(c:GetChecked() == 1)
		qtBar.ConfigMerge()
		qtBar.Refresh()
	end)
	c:SetScript("OnShow", function()
		c:SetChecked(get() and 1 or 0)
	end)
	return c
end

function qtBar.ConfigCreatePanel()
	qtBar.ConfigMerge()
	if qtBar.configFrame then
		return
	end
	local f = _G.CreateFrame("Frame", "qtBarConfigFrame", UIParent)
	f:SetWidth(400)
	f:SetHeight(492)
	f:SetPoint("CENTER", 0, 0)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 8, right = 8, top = 8, bottom = 8 }
	})
	f:SetBackdropColor(0, 0, 0, 0.85)
	f:Hide()

	local close = _G.CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -6, -6)
	close:SetScript("OnClick", function()
		f:Hide()
	end)

	local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -16)
	title:SetText("qtBar")

	local y = -44
	f.checkHide = makeCheck("qtBarCfg_Hide", f, y, "Hide standalone bar while leveling (under max level)", function()
		return qtBar.db.hideWhileLeveling
	end, function(v)
		qtBar.db.hideWhileLeveling = v
	end)
	y = y - 28
	f.checkSlotCount = makeCheck("qtBarCfg_SlotN", f, y, "Show how many attunable slots in the label (e.g. 12 slots)", function()
		return qtBar.db.showAttuneSlotCount
	end, function(v)
		qtBar.db.showAttuneSlotCount = v
		qtBar._dirty = true
	end)
	f:HookScript("OnShow", function()
		if qtBar.BumpAttuneRefresh then
			qtBar.BumpAttuneRefresh()
		end
	end)
	qtBar.configFrame = f
	f:Hide()
end

function qtBar.ConfigToggle()
	qtBar.ConfigMerge()
	qtBar.ConfigCreatePanel()
	if qtBar.configFrame:IsVisible() then
		qtBar.configFrame:Hide()
	else
		qtBar.configFrame:Show()
	end
end

local function clampColor(v)
	if not v then
		return nil
	end
	if v < 0 then
		return 0
	end
	if v > 1 then
		return 1
	end
	return v
end

local function applyFillColor(r, g, b, a)
	qtBar.ConfigMerge()
	qtBar.db.fillColor = { r = r, g = g, b = b, a = a or 1 }
	qtBar.Refresh()
end

local function resetPosition()
	qtBar.ConfigMerge()
	local d = qtBar.DEFAULTS
	qtBar.db.point = d.point
	qtBar.db.relativePoint = d.relativePoint
	qtBar.db.x = d.x
	qtBar.db.y = d.y
	qtBar.db.width = d.width
	qtBar.db.height = d.height
	if qtBar.ApplyBarLayout then
		qtBar.ApplyBarLayout()
	end
	qtBar.Refresh()
end

local function printUsage()
	_G.DEFAULT_CHAT_FRAME:AddMessage(
		"|cff99ccffqtBar|r: /qtbar | /qtbar config | /qtbar refresh | /qtbar color r g b [a] | /qtbar color reset | /qtbar resetpos"
	)
end

_G.SLASH_QTBAR1 = "/qtbar"
_G.SlashCmdList["QTBAR"] = function(msg)
	local m, rest = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
	m = (m or ""):lower()
	if m == "config" or m == "options" or m == "" then
		qtBar.ConfigToggle()
	elseif m == "refresh" or m == "reload" then
		if qtBar.Refresh then
			qtBar.Refresh()
		end
		_G.DEFAULT_CHAT_FRAME:AddMessage("|cff99ccffqtBar|r: refreshed attune display.")
	elseif m == "color" then
		local arg = (rest or ""):lower()
		if arg == "reset" then
			local c = qtBar.DEFAULTS.fillColor
			applyFillColor(c.r, c.g, c.b, c.a)
			_G.DEFAULT_CHAT_FRAME:AddMessage("|cff99ccffqtBar|r: fill color reset.")
			return
		end
		local r, g, b, a = rest:match("^%s*(%S+)%s+(%S+)%s+(%S+)%s*(%S*)%s*$")
		r, g, b, a = clampColor(tonumber(r)), clampColor(tonumber(g)), clampColor(tonumber(b)), clampColor(tonumber(a) or 1)
		if not r or not g or not b then
			printUsage()
			return
		end
		applyFillColor(r, g, b, a)
		_G.DEFAULT_CHAT_FRAME:AddMessage(format("|cff99ccffqtBar|r: fill color set to %.2f %.2f %.2f %.2f.", r, g, b, a))
	elseif m == "resetpos" or m == "resetposition" then
		resetPosition()
		_G.DEFAULT_CHAT_FRAME:AddMessage("|cff99ccffqtBar|r: bar position reset.")
	else
		printUsage()
	end
end
