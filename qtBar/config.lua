-- ʕ •ᴥ•ʔ✿ saved settings + /qtbar frame ✿ʕ •ᴥ•ʔ
local qtBar = qtBar
if not qtBar then
	return
end

local UIParent = UIParent
local format = string.format
local max = math.max
local ipairs = ipairs
local tinsert = table.insert

qtBar.ADDON_TITLE = "|cff99ccffqt|r|cffff9933AttuneBar|r"

qtBar.DEFAULTS = {
	hideWhileLeveling = false,
	maxLevel = 80,
	fillColor = { r = 1, g = 0, b = 0, a = 1 },
	equippedFillColor = { r = 1, g = 0, b = 0, a = 1 },
	bagFillColor = { r = 0.2, g = 0.75, b = 1, a = 1 },
	ghostColor = { r = 0.65, g = 0.65, b = 0.65, a = 0.55 },
	showAttuneSlotCount = true,
	showLabelOnHover = false,
	hideBagAttuneBar = false,
	useCDFBarTextures = false,
	point = "BOTTOM",
	relativePoint = "BOTTOM",
	x = 0,
	y = 64,
	bagPoint = "BOTTOM",
	bagRelativePoint = "BOTTOM",
	bagX = 0,
	bagY = 46,
	width = 480,
	height = 14,
	sizeMinW = 64,
	sizeMaxW = 2560,
	sizeMinH = 4,
	sizeMaxH = 100,
	bubbleScale = 1,
	bubbleStretchX = 1,
	lerpSpeed = 3,
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
local CONFIG_FRAME_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

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
	qtBarDB = qtBarDB or {}
	local db = qtBarDB
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
	if type(db.equippedFillColor) ~= "table" then
		local c = db.fillColor or d.equippedFillColor
		db.equippedFillColor = { r = c.r, g = c.g, b = c.b, a = c.a }
	else
		local c = d.equippedFillColor
		db.equippedFillColor.r = db.equippedFillColor.r or c.r
		db.equippedFillColor.g = db.equippedFillColor.g or c.g
		db.equippedFillColor.b = db.equippedFillColor.b or c.b
		db.equippedFillColor.a = db.equippedFillColor.a or c.a
	end
	if type(db.bagFillColor) ~= "table" then
		local c = d.bagFillColor
		db.bagFillColor = { r = c.r, g = c.g, b = c.b, a = c.a }
	else
		local c = d.bagFillColor
		db.bagFillColor.r = db.bagFillColor.r or c.r
		db.bagFillColor.g = db.bagFillColor.g or c.g
		db.bagFillColor.b = db.bagFillColor.b or c.b
		db.bagFillColor.a = db.bagFillColor.a or c.a
	end
	if type(db.ghostColor) ~= "table" then
		local c = d.ghostColor
		db.ghostColor = { r = c.r, g = c.g, b = c.b, a = c.a }
	else
		local c = d.ghostColor
		db.ghostColor.r = db.ghostColor.r or c.r
		db.ghostColor.g = db.ghostColor.g or c.g
		db.ghostColor.b = db.ghostColor.b or c.b
		db.ghostColor.a = db.ghostColor.a or c.a
	end
	db.width = tonumber(db.width) or d.width
	db.height = tonumber(db.height) or d.height
	db.x = tonumber(db.x) or d.x
	db.y = tonumber(db.y) or d.y
	db.point = db.point or d.point
	db.relativePoint = db.relativePoint or d.relativePoint
	db.bagPoint = db.bagPoint or d.bagPoint
	db.bagRelativePoint = db.bagRelativePoint or d.bagRelativePoint
	db.bagX = tonumber(db.bagX) or d.bagX
	db.bagY = tonumber(db.bagY) or d.bagY
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
	if db.bubbleStretchX == nil then
		db.bubbleStretchX = d.bubbleStretchX
	end
	if db.colorCycleSpeed == nil then
		db.colorCycleSpeed = d.colorCycleSpeed
	end
	if db.lerpSpeed == nil then
		db.lerpSpeed = d.lerpSpeed
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
	if type(db.bagPoint) ~= "string" or not VALID_ANCHOR[db.bagPoint] then
		db.bagPoint = d.bagPoint
	end
	if type(db.bagRelativePoint) ~= "string" or not VALID_ANCHOR[db.bagRelativePoint] then
		db.bagRelativePoint = d.bagRelativePoint
	end
	db.sizeMinW = tonumber(db.sizeMinW) or d.sizeMinW
	db.sizeMaxW = tonumber(db.sizeMaxW) or d.sizeMaxW
	db.sizeMinH = tonumber(db.sizeMinH) or d.sizeMinH
	db.sizeMaxH = tonumber(db.sizeMaxH) or d.sizeMaxH
	db.bubbleScale = d.bubbleScale
	db.bubbleStretchX = d.bubbleStretchX
	db.lerpSpeed = tonumber(db.lerpSpeed) or d.lerpSpeed
	if db.lerpSpeed < 0.1 then
		db.lerpSpeed = 0.1
	end
	if db.lerpSpeed > 20 then
		db.lerpSpeed = 20
	end
	db.colorCycleSpeed = tonumber(db.colorCycleSpeed) or 0

	qtBar.db = db
end

local function makeCheck(parent, cfgFrame, name, y, text, get, set)
	local c = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
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
	local f = CreateFrame("Frame", "qtBarConfigFrame", UIParent, CONFIG_FRAME_TEMPLATE)
	f:SetWidth(560)
	f:SetHeight(720)
	f:SetPoint("CENTER", 0, 0)
	if f.SetFrameStrata then
		f:SetFrameStrata("DIALOG")
	end
	if f.SetFrameLevel then
		f:SetFrameLevel(200)
	end
	if f.SetToplevel then
		f:SetToplevel(true)
	end
	f:SetMovable(true)
	f:EnableMouse(true)
	if f.SetClampedToScreen then
		f:SetClampedToScreen(true)
	end
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
	if UISpecialFrames then
		local found = false
		for _, n in ipairs(UISpecialFrames) do
			if n == "qtBarConfigFrame" then
				found = true
				break
			end
		end
		if not found then
			tinsert(UISpecialFrames, "qtBarConfigFrame")
		end
	end

	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -6, -6)
	close:SetScript("OnClick", function()
		f:Hide()
	end)

	local dragHandle = CreateFrame("Frame", nil, f)
	dragHandle:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -8)
	dragHandle:SetPoint("TOPRIGHT", f, "TOPRIGHT", -32, -8)
	dragHandle:SetHeight(24)
	dragHandle:EnableMouse(true)
	dragHandle:RegisterForDrag("LeftButton")
	dragHandle:SetScript("OnDragStart", function()
		f:StartMoving()
	end)
	dragHandle:SetScript("OnDragStop", function()
		f:StopMovingOrSizing()
	end)

	f.title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	f.title:SetPoint("TOP", 0, -14)
	f.title:SetText(qtBar.ADDON_TITLE)

	f.themeLabel = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	f.themeLabel:SetPoint("TOPLEFT", 22, -42)
	f.themeLabel:SetText("Theme")

	local themeDrop = CreateFrame("Frame", "qtBarConfigThemeDrop", f, "UIDropDownMenuTemplate")
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

	local inset = CreateFrame("Frame", nil, f, CONFIG_FRAME_TEMPLATE)
	if inset.SetFrameStrata then
		inset:SetFrameStrata("DIALOG")
	end
	if inset.SetFrameLevel then
		inset:SetFrameLevel(f:GetFrameLevel() + 5)
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
	end)
	y = y - rowPad
	f.checkLabelHover = makeCheck(inset, f, "qtBarCfg_LabelHover", y, "Show label only on hover", function()
		return qtBar.db.showLabelOnHover
	end, function(v)
		qtBar.db.showLabelOnHover = v
		if qtBar.UpdateLabelVisibility then
			qtBar.UpdateLabelVisibility(false)
		end
	end)
	y = y - rowPad
	f.checkHideBag = makeCheck(inset, f, "qtBarCfg_HideBag", y, "Hide bag attune bar (second bar)", function()
		return qtBar.db.hideBagAttuneBar
	end, function(v)
		qtBar.db.hideBagAttuneBar = v
	end)
	y = y - rowPad
	f.checkCDFTex = makeCheck(inset, f, "qtBarCfg_CDFTex", y, "Use cDF-style bubble chrome (bundled under qtBar/textures; cDF addon not required)", function()
		return qtBar.db.useCDFBarTextures
	end, function(v)
		qtBar.db.useCDFBarTextures = v
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
		if dbk == "lerpSpeed" then
			if n < 0.1 then
				n = 0.1
			end
			if n > 20 then
				n = 20
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
		if dbk == "bubbleStretchX" then
			if n < 0.2 then
				n = 0.2
			end
			if n > 4 then
				n = 4
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
			"lerp",
			"ccycle"
		}) do
			local edit = f["edit_" .. k]
			if edit and edit.setFromDb then
				edit.setFromDb()
			end
		end
		if f.updateColorPreview then
			f.updateColorPreview()
		end
	end
	f:HookScript("OnShow", function()
		if f.Raise then
			f:Raise()
		end
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
		{ "lerp", "Animation speed (lerp, default 3)", "lerpSpeed", "float" },
		{ "ccycle", "Rainbow cycle speed (0 = off; try 0.2-0.8)", "colorCycleSpeed", "float" }
	}) do
		local pkey, lbl, dbk, numKind = p[1], p[2], p[3], p[4]
		local lab = inset:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		lab:SetPoint("TOPLEFT", 16, y2)
		lab:SetWidth(labelW)
		lab:SetJustifyH("LEFT")
		lab:SetJustifyV("TOP")
		lab:SetText(lbl)
		tinsert(f._themeTexts, lab)
		local edit = CreateFrame("EditBox", "qtBarCfg_" .. pkey, inset, "InputBoxTemplate")
		if edit.SetFrameStrata then
			edit:SetFrameStrata("DIALOG")
		end
		edit:SetWidth(112)
		edit:SetHeight(20)
		edit:ClearAllPoints()
		edit:SetPoint("TOPLEFT", inset, "TOPLEFT", editX, y2 - 2)
		edit:SetMaxLetters(12)
		edit:SetAutoFocus(false)
		edit:EnableMouse(true)
		if edit.EnableKeyboard then
			edit:EnableKeyboard(true)
		end
		if edit.SetFrameLevel and inset.GetFrameLevel then
			edit:SetFrameLevel(inset:GetFrameLevel() + 30)
		end
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
		edit:SetScript("OnEscapePressed", function(s)
			s:ClearFocus()
			s.setFromDb()
		end)
		edit:SetScript("OnMouseDown", function(s)
			if s.Raise then
				s:Raise()
			end
			s:SetFocus()
			s:HighlightText()
		end)
		edit:SetScript("OnMouseUp", function(s)
			if s.Raise then
				s:Raise()
			end
			s:SetFocus()
		end)
		edit:SetScript("OnEditFocusLost", edit.onApply)
		edit.setFromDb()
		local labH = (lab.GetStringHeight and lab:GetStringHeight()) or 16
		if labH < 14 then
			labH = 16
		end
		y2 = y2 - max(labH + 18, rowPad + 4)
	end

	local function createColorPickerRow(rowKey, rowLabel, dbKey, disableCycleOnPick)
		local colorLabel = inset:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		colorLabel:SetPoint("TOPLEFT", 16, y2)
		colorLabel:SetWidth(labelW)
		colorLabel:SetJustifyH("LEFT")
		colorLabel:SetText(rowLabel)
		tinsert(f._themeTexts, colorLabel)

		local colorBtn = CreateFrame("Button", "qtBarCfg_" .. rowKey .. "ColorBtn", inset)
		if colorBtn.SetFrameStrata then
			colorBtn:SetFrameStrata("DIALOG")
		end
		colorBtn:SetWidth(112)
		colorBtn:SetHeight(20)
		colorBtn:SetPoint("TOPLEFT", inset, "TOPLEFT", editX, y2 - 2)
		colorBtn:SetNormalFontObject("GameFontHighlightSmall")
		colorBtn:SetText("Pick...")
		local sw = colorBtn:CreateTexture(nil, "ARTWORK")
		sw:SetPoint("TOPLEFT", colorBtn, "TOPLEFT", 4, -4)
		sw:SetPoint("BOTTOMRIGHT", colorBtn, "BOTTOMRIGHT", -4, 4)
		sw:SetTexture("Interface\\Buttons\\WHITE8X8")
		colorBtn.swatch = sw

		f.updateColorPreview = f.updateColorPreview or function() end
		local prevUpdate = f.updateColorPreview
		f.updateColorPreview = function()
			prevUpdate()
			qtBar.ConfigMerge()
			local c = qtBar.db[dbKey] or qtBar.DEFAULTS[dbKey]
			sw:SetVertexColor(c.r or 1, c.g or 1, c.b or 1, c.a or 1)
		end

		local function applyPickedColor(r, g, b, a)
			qtBar.ConfigMerge()
			qtBar.db[dbKey] = {
				r = r or 1,
				g = g or 1,
				b = b or 1,
				a = a or 1
			}
			if disableCycleOnPick then
				qtBar.db.colorCycleSpeed = 0
			end
			qtBar.Refresh()
			f.updateColorPreview()
		end

		colorBtn:SetScript("OnClick", function()
			qtBar.ConfigMerge()
			local c = qtBar.db[dbKey] or qtBar.DEFAULTS[dbKey]
			if not ColorPickerFrame then
				return
			end
			local picker = ColorPickerFrame
			local r0, g0, b0, a0 = c.r or 1, c.g or 1, c.b or 1, c.a or 1
			picker.hasOpacity = true
			picker.opacity = 1 - a0
			picker.previousValues = { r0, g0, b0, a0 }
			picker.func = function()
				local r, g, b = picker:GetColorRGB()
				local a = 1 - (OpacitySliderFrame and OpacitySliderFrame:GetValue() or picker.opacity or 0)
				applyPickedColor(r, g, b, a)
			end
			picker.opacityFunc = picker.func
			picker.cancelFunc = function(prev)
				if type(prev) == "table" then
					applyPickedColor(prev[1], prev[2], prev[3], prev[4] or 1)
				end
			end
			picker:SetColorRGB(r0, g0, b0)
			picker:Hide()
			picker:Show()
		end)
		y2 = y2 - rowPad
	end

	createColorPickerRow("EquippedFill", "Equipped fill color", "equippedFillColor", true)
	createColorPickerRow("BagFill", "Bag fill color", "bagFillColor", true)
	createColorPickerRow("Ghost", "Ghost bar color", "ghostColor", false)
	f.updateColorPreview()
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
	qtBar.db.equippedFillColor = { r = r, g = g, b = b, a = a or 1 }
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
	qtBar.db.bagPoint = d.bagPoint
	qtBar.db.bagRelativePoint = d.bagRelativePoint
	qtBar.db.bagX = d.bagX
	qtBar.db.bagY = d.bagY
	qtBar.db.width = d.width
	qtBar.db.height = d.height
	if qtBar.ApplyBarLayout then
		qtBar.ApplyBarLayout()
	end
	qtBar.Refresh()
end

local function printUsage()
	DEFAULT_CHAT_FRAME:AddMessage(
		qtBar.ADDON_TITLE .. ": /qtbar [config] | /qtbar refresh | /qtbar color r g b [a] | /qtbar color reset | /qtbar colorspeed 0-5 | /qtbar resetpos"
	)
end

SLASH_QTBAR1 = "/qtbar"
SlashCmdList["QTBAR"] = function(msg)
	local m, rest = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
	m = (m or ""):lower()
	if m == "config" or m == "options" or m == "" then
		qtBar.ConfigToggle()
	elseif m == "refresh" or m == "reload" then
		if qtBar.Refresh then
			qtBar.Refresh()
		end
		DEFAULT_CHAT_FRAME:AddMessage(qtBar.ADDON_TITLE .. ": refreshed attune display.")
	elseif m == "color" then
		local arg = (rest or ""):lower()
		if arg == "reset" then
			local c = qtBar.DEFAULTS.fillColor
			applyFillColor(c.r, c.g, c.b, c.a)
			DEFAULT_CHAT_FRAME:AddMessage(qtBar.ADDON_TITLE .. ": fill color reset.")
			return
		end
		local r, g, b, a = rest:match("^%s*(%S+)%s+(%S+)%s+(%S+)%s*(%S*)%s*$")
		r, g, b, a = clampColor(tonumber(r)), clampColor(tonumber(g)), clampColor(tonumber(b)), clampColor(tonumber(a) or 1)
		if not r or not g or not b then
			printUsage()
			return
		end
		applyFillColor(r, g, b, a)
		DEFAULT_CHAT_FRAME:AddMessage(format("%s: fill color set to %.2f %.2f %.2f %.2f.", qtBar.ADDON_TITLE, r, g, b, a))
	elseif m == "colorspeed" or m == "colorcycle" then
		qtBar.ConfigMerge()
		local t = (rest or ""):match("%S+")
		if not t then
			DEFAULT_CHAT_FRAME:AddMessage(
				format("%s: color cycle speed = %g (0=static, same as options).", qtBar.ADDON_TITLE, tonumber(qtBar.db.colorCycleSpeed) or 0)
			)
			return
		end
		local s = tonumber(t)
		if not s or s < 0 or s > 5 then
			DEFAULT_CHAT_FRAME:AddMessage(qtBar.ADDON_TITLE .. ": /qtbar colorspeed <0-5> (config panel has the same).")
			return
		end
		qtBar.db.colorCycleSpeed = s
		qtBar.Refresh()
		DEFAULT_CHAT_FRAME:AddMessage(format("%s: color cycle speed = %g.", qtBar.ADDON_TITLE, s))
	elseif m == "resetpos" or m == "resetposition" then
		resetPosition()
		DEFAULT_CHAT_FRAME:AddMessage(qtBar.ADDON_TITLE .. ": bar position reset.")
	else
		printUsage()
	end
end
