-- ʕ •ᴥ•ʔ✿ standalone attune bar ✿ ʕ •ᴥ•ʔ
local _G = _G
local qtBar = _G.qtBar
if not qtBar then
	return
end

local min = math.min
local max = math.max
local floor = math.floor
local format = string.format
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetCursorPosition = _G.GetCursorPosition
local IsShiftKeyDown = _G.IsShiftKeyDown
local UIParent = _G.UIParent
local UnitLevel = _G.UnitLevel
local GetTime = _G.GetTime
local BARS_PATH = "Interface\\TargetingFrame\\UI-StatusBar"
local XP_ART_PATH = "Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf"
local DEFAULT_MINW, DEFAULT_MAXW = 64, 2560
local DEFAULT_MINH, DEFAULT_MAXH = 4, 100
local function getSizeLimits()
	local db, d = qtBar.db, qtBar.DEFAULTS
	if not d then
		return DEFAULT_MINW, DEFAULT_MAXW, DEFAULT_MINH, DEFAULT_MAXH
	end
	local w0 = (db and tonumber(db.sizeMinW)) or d.sizeMinW or DEFAULT_MINW
	local w1 = (db and tonumber(db.sizeMaxW)) or d.sizeMaxW or DEFAULT_MAXW
	local h0 = (db and tonumber(db.sizeMinH)) or d.sizeMinH or DEFAULT_MINH
	local h1 = (db and tonumber(db.sizeMaxH)) or d.sizeMaxH or DEFAULT_MAXH
	w0, w1 = max(32, w0), min(4096, w1)
	h0, h1 = max(2, h0), min(300, h1)
	if w0 > w1 then
		w0, w1 = w1, w0
	end
	if h0 > h1 then
		h0, h1 = h1, h0
	end
	return w0, w1, h0, h1
end
local ART_COORDS = {
	{ top = 0.79296875, bottom = 0.83203125 },
	{ top = 0.54296875, bottom = 0.58203125 },
	{ top = 0.29296875, bottom = 0.33203125 },
	{ top = 0.04296875, bottom = 0.08203125 }
}

qtBar._dirty = true

local function clamp(v, low, high)
	return max(low, min(high, v))
end

local function round(v)
	if v < 0 then
		return -floor(-v + 0.5)
	end
	return floor(v + 0.5)
end

local function cursorPos()
	local scale = UIParent:GetEffectiveScale()
	local x, y = GetCursorPosition()
	return x / scale, y / scale
end

local function numOr(v, d)
	if type(v) == "number" and v == v then
		return v
	end
	if type(v) == "string" then
		return tonumber(v)
	end
	return d
end

local function saveLayout()
	local b = qtBar.bar
	local db = qtBar.db
	if not b or not db or not b.overlay then
		return
	end
	local ow = b.overlay:GetWidth()
	local oh = b.overlay:GetHeight()
	if type(ow) == "number" and type(oh) == "number" and ow > 0 and oh > 0 and ow == ow and oh == oh then
		db.width = round(ow)
		db.height = round(oh)
	end
	local point, _relativeTo, relativePoint, xOfs, yOfs = b.overlay:GetPoint(1)
	local x = numOr(xOfs, nil)
	local y = numOr(yOfs, nil)
	if type(point) ~= "string" or type(relativePoint) ~= "string" or type(x) ~= "number" or type(y) ~= "number" then
		return
	end
	if math.abs(x) > 20000 or math.abs(y) > 20000 then
		return
	end
	db.point = point
	db.relativePoint = relativePoint
	db.x = round(x)
	db.y = round(y)
end

function qtBar.PersistLayout()
	return saveLayout()
end

local function showTooltip(frame)
	local snap = qtBar._lastAttuneSnap
	GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
	GameTooltip:SetText("qtBar", 0.6, 0.8, 1)
	GameTooltip:AddLine(qtBar.FormatAttuneLabel(snap), 1, 1, 1)
	if snap and snap.count then
		GameTooltip:AddLine(format("Average %.1f%% across %d slots", snap.average or 0, snap.count), 0.85, 0.85, 0.85)
	end
	GameTooltip:AddLine("Shift + Left-Drag: move", 0.6, 0.8, 1)
	GameTooltip:AddLine("Shift + Right-Drag: resize", 0.6, 0.8, 1)
	GameTooltip:Show()
end

local function hsvToRgb(h, s, v)
	h = h % 1
	if h < 0 then
		h = h + 1
	end
	h = h * 6
	local i = floor(h)
	local f = h - i
	local p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
	i = i % 6
	if i == 0 then
		return v, t, p
	end
	if i == 1 then
		return q, v, p
	end
	if i == 2 then
		return p, v, t
	end
	if i == 3 then
		return p, q, v
	end
	if i == 4 then
		return t, p, v
	end
	return v, t, p
end

function qtBar.ApplyBarLayout()
	local b = qtBar.bar
	local db = qtBar.db
	if not b or not db or not b.overlay then
		return
	end
	local mw, Mw, mh, Mh = getSizeLimits()
	local bw = clamp(tonumber(db.width) or 420, mw, Mw)
	local bh = clamp(tonumber(db.height) or 14, mh, Mh)
	-- ʕ •ᴥ•ʔ ApplyBarLayout reads db only; never writes SavedVariables here. ✿ʕ •ᴥ•ʔ
	local x = round(tonumber(db.x) or 0)
	local y = round(tonumber(db.y) or 64)
	b.overlay:ClearAllPoints()
	b.overlay:SetSize(bw, bh)
	b.overlay:SetPoint(db.point or "BOTTOM", UIParent, db.relativePoint or "BOTTOM", x, y)
end

function qtBar.LayoutBarArt()
	local b = qtBar.bar
	if not b or not b.art then
		return
	end
	local db = qtBar.db
	local scale = (db and tonumber(db.bubbleScale)) or 1
	if scale < 0.1 then
		scale = 0.1
	end
	if scale > 3 then
		scale = 3
	end
	local w = b.overlay:GetWidth()
	local h = b.overlay:GetHeight()
	local pieceW = w * 0.25
	local artH = min(10 * scale, h * 0.9)
	local y = max(0, h - artH)
	for i = 1, 4 do
		local t = b.art[i]
		t:ClearAllPoints()
		t:SetSize(pieceW, artH)
		t:SetPoint("BOTTOM", b.overlay, "BOTTOM", (i - 2.5) * pieceW, y)
	end
end

function qtBar.BarCreate()
	if qtBar.bar and qtBar.bar.overlay then
		return
	end
	qtBar.bar = qtBar.bar or {}
	local b = qtBar.bar

	b.overlay = CreateFrame("Frame", "qtBarStandalone", UIParent)
	b.overlay:Hide()
	b.overlay:SetFrameStrata("MEDIUM")
	b.overlay:SetFrameLevel(25)
	b.overlay:SetMovable(true)
	b.overlay:EnableMouse(true)
	if b.overlay.SetClampedToScreen then
		b.overlay:SetClampedToScreen(true)
	end

	b.bg = b.overlay:CreateTexture(nil, "BACKGROUND")
	b.bg:SetAllPoints()
	b.bg:SetTexture(0, 0, 0, 0.5)

	b.fill = CreateFrame("StatusBar", "qtBarFill", b.overlay)
	b.fill:SetAllPoints(b.overlay)
	b.fill:SetMinMaxValues(0, 100)
	b.fill:SetValue(0)
	b.fill:SetFrameLevel(5)
	b.fill:SetStatusBarTexture(BARS_PATH)
	local tx = b.fill:GetStatusBarTexture()
	if tx then
		tx:SetDrawLayer("BORDER", 0)
	end

	b.art = {}
	for i = 1, 4 do
		local t = b.overlay:CreateTexture(nil, "OVERLAY")
		t:SetTexture(XP_ART_PATH)
		t:SetTexCoord(0, 1, ART_COORDS[i].top, ART_COORDS[i].bottom)
		b.art[i] = t
	end

	b.label = b.overlay:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	b.label:SetPoint("CENTER", b.overlay, "CENTER", 0, 1)
	b.label:SetText("")

	b.overlay:SetScript("OnSizeChanged", function()
		qtBar.LayoutBarArt()
	end)
	b.overlay:SetScript("OnEnter", showTooltip)
	b.overlay:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	b.overlay:SetScript("OnMouseDown", function(self, button)
		if not IsShiftKeyDown() then
			return
		end
		if button == "LeftButton" then
			self:StartMoving()
			b.moving = true
			return
		end
		if button == "RightButton" then
			local x, y = cursorPos()
			b.resizeX, b.resizeY = x, y
			b.resizeW, b.resizeH = self:GetWidth(), self:GetHeight()
			b.resizing = true
			self:SetScript("OnUpdate", function()
				local cx, cy = cursorPos()
				local mw, Mw, mh, Mh = getSizeLimits()
				self:SetSize(
					clamp(b.resizeW + cx - b.resizeX, mw, Mw),
					clamp(b.resizeH + cy - b.resizeY, mh, Mh)
				)
			end)
		end
	end)
	b.overlay:SetScript("OnMouseUp", function(self)
		if b.moving then
			self:StopMovingOrSizing()
			b.moving = nil
			saveLayout()
		end
		if b.resizing then
			self:SetScript("OnUpdate", nil)
			b.resizing = nil
			saveLayout()
		end
	end)
	b.ticker = CreateFrame("Frame", "qtBarTicker", _G.UIParent)
	b.ticker:Show()
	b.ticker:SetScript("OnUpdate", function(self, el)
		qtBar.BarOnUpdate(self, el)
	end)

	qtBar.ApplyBarLayout()
	qtBar.LayoutBarArt()
	qtBar.bar = b
end

function qtBar.BarSyncFromData()
	local b = qtBar.bar
	if not b or not b.overlay then
		return
	end

	local db = qtBar.db
	if not db then
		return
	end

	local snap
	if qtBar._snapshotReuseFromPoll then
		qtBar._snapshotReuseFromPoll = false
		snap = qtBar._attuneSnap
	else
		snap = qtBar.GetEquippedAttunementSnapshot()
	end
	if not snap then
		return
	end
	if qtBar.CacheAttuneSnapshot then
		qtBar.CacheAttuneSnapshot(snap)
	else
		qtBar._lastAttuneSnap = snap
	end

	if db.hideWhileLeveling and UnitLevel("player") < (db.maxLevel or 80) then
		b.overlay:Hide()
		return
	end

	b.overlay:Show()
	b.fill:SetValue(snap.average or 0)
	if not (tonumber(db.colorCycleSpeed) and tonumber(db.colorCycleSpeed) > 0) then
		local c = db.fillColor
		b.fill:SetStatusBarColor(c.r, c.g, c.b, c.a or 1)
	end
	b.label:SetText(qtBar.FormatAttuneLabel and qtBar.FormatAttuneLabel(snap) or format("Attune: %d%%", floor((snap.average or 0) + 0.5)))
	b._lastAverage = snap.average
end

local POLL_ATTUNE_SEC = 1

function qtBar.BarOnUpdate(_, elapsed)
	local b = qtBar.bar
	if not b or not b.ticker then
		return
	end
	if qtBar.queuedUpdate then
		qtBar.queuedUpdate = false
		qtBar._dirty = true
	end
	local el = elapsed or 0
	qtBar._attunePollAcc = (qtBar._attunePollAcc or 0) + el
	if qtBar._attunePollAcc >= POLL_ATTUNE_SEC then
		qtBar._attunePollAcc = 0
		local snap = qtBar.GetEquippedAttunementSnapshot()
		local fp = qtBar.AttuneFingerprintHash(snap)
		if fp ~= qtBar._lastAttuneFp then
			qtBar._snapshotReuseFromPoll = true
			qtBar._dirty = true
		end
	end
	if qtBar._dirty then
		qtBar._dirty = false
		qtBar.BarSyncFromData()
	end
	if b.fill and b.overlay:IsShown() then
		local db = qtBar.db
		local sp = (db and tonumber(db.colorCycleSpeed)) or 0
		if sp > 0 then
			local t = (GetTime() * sp) % 1
			local cr, cg, cb = hsvToRgb(t, 0.7, 0.95)
			local a = 1
			if db and db.fillColor and type(db.fillColor) == "table" then
				a = db.fillColor.a or 1
			end
			b.fill:SetStatusBarColor(cr, cg, cb, a)
		end
	end
end
