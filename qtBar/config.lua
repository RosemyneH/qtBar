-- ʕ •ᴥ•ʔ✿ saved settings + /qtbar frame ✿ʕ •ᴥ•ʔ
local _G = _G
local qtBar = _G.qtBar
if not qtBar then
	return
end

local UIParent = _G.UIParent
local format = string.format
local max = math.max
local ipairs = ipairs
local tinsert = table.insert

qtBar.DEFAULTS = {
	hideWhileLeveling = false,
	maxLevel = 80,
	fillColor = { r = 0.25, g = 0.55, b = 0.95, a = 1 },
	showAttuneSlotCount = true,
	point = "BOTTOM",
	relativePoint = "BOTTOM",
	x = 0,
	y = 64,
	width = 480,
	height = 14,
	sizeMinW = 64,
	sizeMaxW = 2560,
	sizeMinH = 4,
	sizeMaxH = 100,
	bubbleScale = 1,
	colorCycleSpeed = 0,
	theme = "dark"
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

-- ʕ •ᴥ•ʔ✿ BackdropTemplate required on modern clients for SetBackdrop to work ✿ʕ •ᴥ•ʔ
local CONFIG_FRAME_TEMPLATE = _G.BackdropTemplateMixin and "BackdropTemplate" or nil

local VALID_ANCHOR = {
	CENTER = true,
	TOP = true,
	BOTTOM = true,
	LEFT = true,
	RIGHT = true,
	TOPLEFT = true,
	TOPRIGHT = true,
	BOTTOMLEFT = true,
	BOTTOMRIGHT = true
}

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
	if db.sizeMinW == nil then
		db.sizeMinW = d.sizeMinW
	end
	if db.sizeMaxW == nil then
		db.sizeMaxW = d.sizeMaxW
	end
	if db.sizeMinH == nil then
		db.sizeMinH = d.sizeMinH
	end
	if db.sizeMaxH == nil then
		db.sizeMaxH = d.sizeMaxH
	end
	if db.bubbleScale == nil then
		db.bubbleScale = d.bubbleScale
	end
	if db.colorCycleSpeed == nil then
		db.colorCycleSpeed = d.colorCycleSpeed
	end
	if db.theme == nil then
		db.theme = d.theme
	end
	if type(db.theme) ~= "string" or not qtBar.Themes or not qtBar.Themes[db.theme] then
		db.theme = "dark"
	end
	if not db._layoutMigrated2 then
		db._layoutMigrated2 = true
		local xn = tonumber(db.x)
		local yn = tonumber(db.y)
		if
			xn
			and yn
			and (math.abs(xn) > 5000 or yn > 3000 or yn < -500)
		then
			db.x, db.y, db.point, db.relativePoint = d.x, d.y, d.point, d.relativePoint
		end
	end
	if type(db.point) ~= "string" or not VALID_ANCHOR[db.point] then
		db.point = d.point
	end
	if type(db.relativePoint) ~= "string" or not VALID_ANCHOR[db.relativePoint] then
		db.relativePoint = d.relativePoint
	end
	db.sizeMinW = tonumber(db.sizeMinW) or d.sizeMinW
	db.sizeMaxW = tonumber(db.sizeMaxW) or d.sizeMaxW
	db.sizeMinH = tonumber(db.sizeMinH) or d.sizeMinH
	db.sizeMaxH = tonumber(db.sizeMaxH) or d.sizeMaxH
	db.bubbleScale = tonumber(db.bubbleScale) or d.bubbleScale
	db.colorCycleSpeed = tonumber(db.colorCycleSpeed) or 0
	qtBar.db = db
end

local function makeCheck(parent, cfgFrame, name, y, text, get, set)
	local c = _G.CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
	c:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, y)
	local tf = _G[name .. "Text"]
	tf:SetText(text)
	c:SetScript("OnClick", function()
		set(c:GetChecked() == 1)
		qtBar.ConfigMerge()
		qtBar.Refresh()
	end)
	c:SetScript("OnShow", function()
		c:SetChecked(get() and 1 or 0)
	end)
	cfgFrame._checks = cfgFrame._checks or {}
	tinsert(cfgFrame._checks, { check = c, textFrame = tf })
	return c
end

function qtBar.ConfigCreatePanel()
	qtBar.ConfigMerge()
	if qtBar.configFrame then
		return
	end
	local f = _G.CreateFrame("Frame", "qtBarConfigFrame", UIParent, CONFIG_FRAME_TEMPLATE)
	f:SetWidth(560)
	f:SetHeight(720)
	f:SetPoint("CENTER", 0, 0)
	if f.SetFrameStrata then
		f:SetFrameStrata("DIALOG")
	end
	if f.SetFrameLevel then
		f:SetFrameLevel(200)
	end
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
	f._checks = {}
	f._themeTexts = {}
	f._editRefs = {}
	f:Hide()

	local close = _G.CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -6, -6)
	close:SetScript("OnClick", function()
		f:Hide()
	end)

	f.title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	f.title:SetPoint("TOP", 0, -14)
	f.title:SetText("qtBar")

	f.themeLabel = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	f.themeLabel:SetPoint("TOPLEFT", 22, -42)
	f.themeLabel:SetText("Theme")

	local themeDrop = _G.CreateFrame("Frame", "qtBarConfigThemeDrop", f, "UIDropDownMenuTemplate")
	themeDrop:SetPoint("TOPLEFT", f, "TOPLEFT", 110, -44)
	UIDropDownMenu_SetWidth(themeDrop, 200)
	local function themeDDInit(_self, level)
		if level and level > 1 then
			return
		end
		qtBar.ConfigMerge()
		for _, key in ipairs(qtBar.ThemeOrder or {}) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = qtBar:GetThemeLabel(key)
			info.value = key
			info.func = function()
				qtBar.db.theme = key
				qtBar.ConfigMerge()
				qtBar:ApplyConfigTheme()
			end
			info.checked = qtBar.db.theme == key
			UIDropDownMenu_AddButton(info)
		end
	end
	UIDropDownMenu_Initialize(themeDrop, themeDDInit)
	f.themeDrop = themeDrop
	qtBar:RegisterThemeDropdown(themeDrop)

	local inset = _G.CreateFrame("Frame", nil, f, CONFIG_FRAME_TEMPLATE)
	if inset.SetFrameLevel then
		inset:SetFrameLevel(1)
	end
	inset:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 16,
		insets = { left = 6, right = 6, top = 6, bottom = 6 }
	})
	inset:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -78)
	inset:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 38)
	f.inset = inset

	local rowPad = 36
	local y = -14
	f.checkHide = makeCheck(inset, f, "qtBarCfg_Hide", y, "Hide standalone bar while leveling (under max level)", function()
		return qtBar.db.hideWhileLeveling
	end, function(v)
		qtBar.db.hideWhileLeveling = v
	end)
	y = y - rowPad
	f.checkSlotCount = makeCheck(inset, f, "qtBarCfg_SlotN", y, "Show attunable slot count in the label (e.g. 12 slots)", function()
		return qtBar.db.showAttuneSlotCount
	end, function(v)
		qtBar.db.showAttuneSlotCount = v
		qtBar._dirty = true
	end)
	y = y - rowPad
	local labelW = 340
	local editX = 16 + labelW + 24
	local y2 = y
	local function validateValue(dbk, n)
		if n == nil then
			return nil
		end
		if dbk == "colorCycleSpeed" then
			if n < 0 then
				n = 0
			end
			if n > 5 then
				n = 5
			end
			return n
		end
		if dbk == "bubbleScale" then
			if n < 0.1 then
				n = 0.1
			end
			if n > 3 then
				n = 3
			end
			return n
		end
		if dbk == "height" and n < 2 then
			return nil
		end
		if dbk == "width" and n < 32 then
			return nil
		end
		if dbk:sub(1, 4) == "size" and n < 1 then
			return nil
		end
		return n
	end
	f.syncSizeFields = function()
		for _, k in ipairs({
			"barW",
			"barH",
			"minW",
			"maxW",
			"minH",
			"maxH",
			"bubble",
			"ccycle"
		}) do
			local edit = f["edit_" .. k]
			if edit and edit.setFromDb then
				edit.setFromDb()
			end
		end
	end
	f:HookScript("OnShow", function()
		if qtBar.BumpAttuneRefresh then
			qtBar.BumpAttuneRefresh()
		end
		if f.syncSizeFields then
			f.syncSizeFields()
		end
		qtBar.ConfigMerge()
		qtBar:RefreshThemeDropdown()
		qtBar:ApplyConfigTheme()
	end)
	for _, p in ipairs({
		{ "barW", "Bar width (px)", "width", "int" },
		{ "barH", "Bar height (px)", "height", "int" },
		{ "minW", "Min width (shift-right-drag)", "sizeMinW", "int" },
		{ "maxW", "Max width (resize cap)", "sizeMaxW", "int" },
		{ "minH", "Min height", "sizeMinH", "int" },
		{ "maxH", "Max height", "sizeMaxH", "int" },
		{ "bubble", "Bubble / art scale (0.1-3)", "bubbleScale", "float" },
		{ "ccycle", "Color cycle speed (0 = solid; try 0.2-0.8)", "colorCycleSpeed", "float" }
	}) do
		local pkey, lbl, dbk, numKind = p[1], p[2], p[3], p[4]
		local lab = inset:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		lab:SetPoint("TOPLEFT", 16, y2)
		lab:SetWidth(labelW)
		lab:SetJustifyH("LEFT")
		lab:SetJustifyV("TOP")
		lab:SetText(lbl)
		tinsert(f._themeTexts, lab)
		local edit = _G.CreateFrame("EditBox", "qtBarCfg_" .. pkey, inset, "InputBoxTemplate")
		edit:SetWidth(112)
		edit:ClearAllPoints()
		edit:SetPoint("TOPLEFT", inset, "TOPLEFT", editX, y2 - 2)
		edit:SetMaxLetters(12)
		tinsert(f._editRefs, edit)
		f["edit_" .. pkey] = edit
		function edit.setFromDb()
			qtBar.ConfigMerge()
			local n = qtBar.db[dbk]
			if n == nil then
				edit:SetText("")
				return
			end
			if numKind == "float" and type(n) == "number" then
				edit:SetText(string.format("%g", n))
			else
				edit:SetText(tostring(math.floor(n + 0.5)))
			end
		end
		function edit.onApply()
			local t = (edit:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
			if t == "" then
				if dbk == "colorCycleSpeed" then
					qtBar.db.colorCycleSpeed = 0
					qtBar.ConfigMerge()
					qtBar.Refresh()
					return
				end
				qtBar.ConfigMerge()
				edit.setFromDb()
				return
			end
			local n = tonumber(t)
			if numKind == "int" and n then
				n = math.floor(n + 0.5)
			end
			local v = validateValue(dbk, n)
			if v == nil then
				qtBar.ConfigMerge()
				edit.setFromDb()
				return
			end
			qtBar.db[dbk] = v
			qtBar.ConfigMerge()
			qtBar.Refresh()
		end
		edit:SetScript("OnEnterPressed", function(s)
			s:ClearFocus()
		end)
		edit:SetScript("OnEditFocusLost", edit.onApply)
		edit.setFromDb()
		local labH = (lab.GetStringHeight and lab:GetStringHeight()) or 16
		if labH < 14 then
			labH = 16
		end
		y2 = y2 - max(labH + 18, rowPad + 4)
	end
	qtBar.configFrame = f
	qtBar:ApplyConfigTheme()
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
	qtBar.db.colorCycleSpeed = 0
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
		"|cff99ccffqtBar|r: /qtbar [config] | /qtbar refresh | /qtbar color r g b [a] | /qtbar color reset | /qtbar colorspeed 0-5 | /qtbar resetpos"
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
	elseif m == "colorspeed" or m == "colorcycle" then
		qtBar.ConfigMerge()
		local t = (rest or ""):match("%S+")
		if not t then
			_G.DEFAULT_CHAT_FRAME:AddMessage(
				format("|cff99ccffqtBar|r: color cycle speed = %g (0=static, same as options).", tonumber(qtBar.db.colorCycleSpeed) or 0)
			)
			return
		end
		local s = tonumber(t)
		if not s or s < 0 or s > 5 then
			_G.DEFAULT_CHAT_FRAME:AddMessage("|cff99ccffqtBar|r: /qtbar colorspeed <0-5> (config panel has the same).")
			return
		end
		qtBar.db.colorCycleSpeed = s
		qtBar.Refresh()
		_G.DEFAULT_CHAT_FRAME:AddMessage(format("|cff99ccffqtBar|r: color cycle speed = %g.", s))
	elseif m == "resetpos" or m == "resetposition" then
		resetPosition()
		_G.DEFAULT_CHAT_FRAME:AddMessage("|cff99ccffqtBar|r: bar position reset.")
	else
		printUsage()
	end
end
