-- ʕ •ᴥ•ʔ✿ standalone attune bar ✿ ʕ •ᴥ•ʔ
local qtBar = qtBar
if not qtBar then
	return
end

local min = math.min
local max = math.max
local floor = math.floor
local format = string.format
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GetCursorPosition = GetCursorPosition
local IsShiftKeyDown = IsShiftKeyDown
local UIParent = UIParent
local UnitLevel = UnitLevel
local GetTime = GetTime
local BARS_PATH = "Interface\\TargetingFrame\\UI-StatusBar"
local SOLID_BAR_TEX = "Interface\\Buttons\\WHITE8X8"
-- ʕ •ᴥ•ʔ cDF chrome: uiexperiencebar.blp only (ui-hud-experiencebar-round); bundled under qtBar/textures ✿ʕ •ᴥ•ʔ
local CDF_ASSETS = "Interface\\AddOns\\qtBar\\textures\\"
local CDF_TEX_UIEXP = CDF_ASSETS .. "uiexperiencebar"
-- ui-hud-experiencebar-round — same as cDF new XP (mainbars.lua); no second mainmenubar layer ✿ʕ •ᴥ•ʔ
local CDF_COORD_ROUND_U1, CDF_COORD_ROUND_U2 = 1 / 2048, 572 / 2048
local CDF_COORD_ROUND_V1, CDF_COORD_ROUND_V2 = 1 / 64, 18 / 64
local XP_ART_PATH = "Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf"
-- ʕ •ᴥ•ʔ Match LayoutBarArt cdfRound CENTER dx (-3); vertical uses insetY only (center dy is not symmetric margin) ✿ʕ •ᴥ•ʔ
local CDF_FILL_ROUNDFRAME_X = -3
local CDF_FILL_INSET_X = 3
local CDF_FILL_INSET_Y = 3
local CDF_MIN_INNER_W = 16
local CDF_MIN_INNER_H = 4
local BAG_BAR_GAP = 4

local function cdfComputeInsets(W, H)
	if type(W) ~= "number" or type(H) ~= "number" or W ~= W or H ~= H then
		return 0, 0, 0
	end
	local ix = min(CDF_FILL_INSET_X, max(0, (W - CDF_MIN_INNER_W) / 2))
	local iy = min(CDF_FILL_INSET_Y, max(0, (H - CDF_MIN_INNER_H) / 2))
	local ox = CDF_FILL_ROUNDFRAME_X
	if ix + ox < 0 then
		ox = -ix
	end
	return ix, iy, ox
end
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

local function clamp(v, low, high)
	return max(low, min(high, v))
end

local function round(v)
	if v < 0 then
		return -floor(-v + 0.5)
	end
	return floor(v + 0.5)
end

local function pixelSnap(v)
	return floor((v or 0) + 0.5)
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

local function saveLayout(which)
	local bars = qtBar.bars
	local key = (which == "bag") and "bag" or "equipped"
	local b = bars and bars[key]
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
	if key == "bag" then
		db.bagPoint = point
		db.bagRelativePoint = relativePoint
		db.bagX = round(x)
		db.bagY = round(y)
	else
		db.point = point
		db.relativePoint = relativePoint
		db.x = round(x)
		db.y = round(y)
	end
end

function qtBar.PersistLayout()
	saveLayout("equipped")
	return saveLayout("bag")
end

local function showTooltip(frame)
	local key = frame and frame._qtKey or "equipped"
	local snap = (key == "bag") and qtBar._lastBagSnap or qtBar._lastEquippedSnap
	local prefix = (key == "bag") and "Bag Attune" or "Equipped Attune"
	GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
	GameTooltip:SetText(qtBar.ADDON_TITLE or "qtAttuneBar")
	GameTooltip:AddLine(qtBar.FormatAttuneLabel(snap, prefix), 1, 1, 1)
	if snap and snap.count then
		GameTooltip:AddLine(format("Average %.1f%% across %d slots", snap.average or 0, snap.count), 0.85, 0.85, 0.85)
	end
	GameTooltip:AddLine("Shift + Left-Drag: move", 0.6, 0.8, 1)
	GameTooltip:AddLine("Shift + Right-Drag: resize", 0.6, 0.8, 1)
	GameTooltip:AddLine("Shift + Middle-Click: open config", 0.6, 0.8, 1)
	GameTooltip:Show()
end

local function rainbowRgb(t)
	local tau = 6.28318530718
	local phase = (t % 1) * tau
	local r = 0.5 + 0.5 * math.sin(phase)
	local g = 0.5 + 0.5 * math.sin(phase + 2.09439510239)
	local b = 0.5 + 0.5 * math.sin(phase + 4.18879020479)
	return r, g, b
end

function qtBar.ApplyBarInsetFills()
	local bars = qtBar.bars
	local db = qtBar.db
	if not bars or not db or not bars.equipped or not bars.equipped.overlay then
		return
	end
	local cdf = db.useCDFBarTextures
	local function insetFull(fill, ghost, overlay)
		if not fill or not ghost or not overlay then
			return
		end
		local ix, iy, ox = 0, 0, 0
		if cdf then
			local W, H = overlay:GetWidth(), overlay:GetHeight()
			ix, iy, ox = cdfComputeInsets(W, H)
		end
		fill:ClearAllPoints()
		ghost:ClearAllPoints()
		fill:SetPoint("TOPLEFT", overlay, "TOPLEFT", ix + ox, -iy)
		fill:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", -ix + ox, iy)
		ghost:SetPoint("TOPLEFT", overlay, "TOPLEFT", ix + ox, -iy)
		ghost:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", -ix + ox, iy)
	end
	insetFull(bars.equipped.fill, bars.equipped.fillGhost, bars.equipped.overlay)
	insetFull(bars.bag.fill, bars.bag.fillGhost, bars.bag.overlay)
	if bars.equipped.label then
		bars.equipped.label:ClearAllPoints()
		bars.equipped.label:SetPoint("CENTER", bars.equipped.overlay, "CENTER", 0, 1)
	end
	if bars.bag.label then
		bars.bag.label:ClearAllPoints()
		bars.bag.label:SetPoint("CENTER", bars.bag.overlay, "CENTER", 0, 1)
	end
end

local function getFillColorForBar(db, key)
	if key == "bag" then
		return (db and db.bagFillColor) or (qtBar.DEFAULTS and qtBar.DEFAULTS.bagFillColor) or (db and db.fillColor)
	end
	return (db and db.equippedFillColor) or (qtBar.DEFAULTS and qtBar.DEFAULTS.equippedFillColor) or (db and db.fillColor)
end

function qtBar.ApplyBarTextureStyle()
	local bars = qtBar.bars
	local db = qtBar.db
	if not bars or not db then
		return
	end
	local cdf = db.useCDFBarTextures
	for _, b in pairs(bars) do
		if b and b.fill and b.fillGhost then
			if cdf then
				-- ʕ •ᴥ•ʔ Solid tint — UI-StatusBar has vertical grain under strong vertex color ✿ʕ •ᴥ•ʔ
				b.fill:SetStatusBarTexture(SOLID_BAR_TEX)
				local tx = b.fill:GetStatusBarTexture()
				if tx then
					tx:SetTexCoord(0, 1, 0, 1)
					tx:SetDrawLayer("BORDER", 0)
				end
				b.fillGhost:SetStatusBarTexture(SOLID_BAR_TEX)
				local gtx = b.fillGhost:GetStatusBarTexture()
				if gtx then
					gtx:SetTexCoord(0, 1, 0, 1)
					gtx:SetDrawLayer("ARTWORK", 0)
				end
			else
				b.fill:SetStatusBarTexture(BARS_PATH)
				local tx = b.fill:GetStatusBarTexture()
				if tx then
					tx:SetTexCoord(0, 1, 0, 1)
					tx:SetDrawLayer("BORDER", 0)
				end
				b.fillGhost:SetStatusBarTexture(BARS_PATH)
				local gtx = b.fillGhost:GetStatusBarTexture()
				if gtx then
					gtx:SetTexCoord(0, 1, 0, 1)
					gtx:SetDrawLayer("ARTWORK", 0)
				end
			end
		end
		if b and b.art then
			for i = 1, 4 do
				local t = b.art[i]
				if t then
					if cdf then
						t:Hide()
					else
						t:SetTexture(XP_ART_PATH)
						t:Show()
					end
				end
			end
		end
		if b and b.cdfRound then
			if cdf then
				b.cdfRound:SetTexture(CDF_TEX_UIEXP)
				b.cdfRound:SetTexCoord(CDF_COORD_ROUND_U1, CDF_COORD_ROUND_U2, CDF_COORD_ROUND_V1, CDF_COORD_ROUND_V2)
				b.cdfRound:SetVertexColor(1, 1, 1)
				b.cdfRound:Show()
			else
				b.cdfRound:Hide()
			end
		end
		-- ʕ •ᴥ•ʔ Rect bg fills overlay corners past pointed/chrome atlas ✿ʕ •ᴥ•ʔ
		if b and b.bg then
			if cdf then
				b.bg:Hide()
			else
				b.bg:Show()
			end
		end
	end
end

local function normalizeBagBarParents(bars)
	local bg = bars and bars.bag
	if not bg or not bg.overlay then
		return
	end
	if bg.fill and bg.fill:GetParent() ~= bg.overlay then
		bg.fill:SetParent(bg.overlay)
	end
	if bg.fillGhost and bg.fillGhost:GetParent() ~= bg.overlay then
		bg.fillGhost:SetParent(bg.overlay)
	end
	if bg.label and bg.label:GetParent() ~= bg.overlay then
		bg.label:SetParent(bg.overlay)
	end
end

function qtBar.ApplyBarLayout()
	local bars = qtBar.bars
	local db = qtBar.db
	if not bars or not db or not bars.equipped or not bars.equipped.overlay then
		return
	end
	normalizeBagBarParents(bars)
	local mw, Mw, mh, Mh = getSizeLimits()
	local bw = clamp(tonumber(db.width) or 420, mw, Mw)
	local bh = clamp(tonumber(db.height) or 14, mh, Mh)
	-- ʕ •ᴥ•ʔ ApplyBarLayout reads db only; never writes SavedVariables here. ✿ʕ •ᴥ•ʔ
	local x = round(tonumber(db.x) or 0)
	local y = round(tonumber(db.y) or 64)
	local equipped = bars.equipped
	equipped.overlay:ClearAllPoints()
	equipped.overlay:SetSize(bw, bh)
	equipped.overlay:SetPoint(db.point or "BOTTOM", UIParent, db.relativePoint or "BOTTOM", x, y)
	local bag = bars.bag
	if bag and bag.overlay then
		bag.overlay:Show()
		local bx = round(tonumber(db.bagX) or x)
		local by = round(tonumber(db.bagY) or (y - bh - BAG_BAR_GAP))
		bag.overlay:ClearAllPoints()
		bag.overlay:SetSize(bw, bh)
		bag.overlay:SetPoint(db.bagPoint or "BOTTOM", UIParent, db.bagRelativePoint or "BOTTOM", bx, by)
	end
end

function qtBar.LayoutBarArt()
	local bars = qtBar.bars
	if not bars then
		return
	end
	local db = qtBar.db
	if db and db.useCDFBarTextures then
		for _, b in pairs(bars) do
			if b and b.overlay and b.cdfRound then
				local w = max(1, b.overlay:GetWidth())
				local h = max(1, b.overlay:GetHeight())
				b.cdfRound:ClearAllPoints()
				b.cdfRound:SetSize(w, max(h + 4, 18))
				b.cdfRound:SetPoint("CENTER", b.overlay, "CENTER", -3, -2)
			end
		end
		return
	end
	local scale = (db and tonumber(db.bubbleScale)) or 1
	local stretchX = (db and tonumber(db.bubbleStretchX)) or 1
	if scale < 0.1 then
		scale = 0.1
	end
	if scale > 3 then
		scale = 3
	end
	if stretchX < 0.2 then
		stretchX = 0.2
	end
	if stretchX > 4 then
		stretchX = 4
	end
	for _, b in pairs(bars) do
		if b and b.art and b.overlay then
			local w = b.overlay:GetWidth()
			local h = b.overlay:GetHeight()
			local baseW = pixelSnap(w * 0.25)
			if baseW < 1 then
				baseW = 1
			end
			local pieceW = baseW
			local baseArtH = max(10, h)
			local artH = pixelSnap(min(baseArtH * scale, h * 3))
			if artH < 1 then
				artH = 1
			end
			local y = pixelSnap((h * 0.5) - (artH * 0.5))
			local xZoom = max(0.2, min(4, stretchX))
			local uSpan = 0.5 / xZoom
			if uSpan > 0.5 then
				uSpan = 0.5
			end
			local inset = 0.0015
			local u1 = (0.5 - uSpan) + inset
			local u2 = (0.5 + uSpan) - inset
			if u2 <= u1 then
				u1 = 0.25
				u2 = 0.75
			end
			for i = 1, 4 do
				local t = b.art[i]
				t:ClearAllPoints()
				t:SetSize(pieceW, artH)
				local top = ART_COORDS[i].top + inset
				local bottom = ART_COORDS[i].bottom - inset
				if bottom <= top then
					top = ART_COORDS[i].top
					bottom = ART_COORDS[i].bottom
				end
				t:SetTexCoord(u1, u2, top, bottom)
				local xOfs = pixelSnap((i - 2.5) * baseW)
				t:SetPoint("BOTTOM", b.overlay, "BOTTOM", xOfs, y)
			end
		end
	end
end

function qtBar.UpdateLabelVisibility(isHovering)
	local bars = qtBar.bars
	local db = qtBar.db
	if not bars then
		return
	end
	local hoverOnly = db and db.showLabelOnHover
	local show = not hoverOnly
	if hoverOnly then
		show = isHovering and true or false
	end
	for _, b in pairs(bars) do
		if b and b.label then
			if b.label.SetShown then
				b.label:SetShown(show)
			elseif show then
				b.label:Show()
			else
				b.label:Hide()
			end
		end
	end
end

function qtBar.BarCreate()
	if qtBar.bars and qtBar.bars.equipped and qtBar.bars.equipped.overlay then
		return
	end
	qtBar.bars = qtBar.bars or {}
	local bars = qtBar.bars

	local function createVisualBar(frameName, fillName, ghostName, tickerName, key, interactive)
		local b = {}
		b.overlay = CreateFrame("Frame", frameName, UIParent)
		b.overlay._qtKey = key
		b.overlay:Hide()
		b.overlay:SetFrameStrata("MEDIUM")
		b.overlay:SetFrameLevel(25)
		b.overlay:SetMovable(true)
		b.overlay:EnableMouse(interactive and true or false)
		if b.overlay.SetClipsChildren then
			b.overlay:SetClipsChildren(true)
		end
		if b.overlay.SetClampedToScreen then
			b.overlay:SetClampedToScreen(true)
		end

		b.bg = b.overlay:CreateTexture(nil, "BACKGROUND")
		b.bg:SetAllPoints()
		b.bg:SetTexture(0, 0, 0, 0.5)

		b.fill = CreateFrame("StatusBar", fillName, b.overlay)
		b.fill:SetAllPoints(b.overlay)
		b.fill:SetMinMaxValues(0, 100)
		b.fill:SetValue(0)
		b.fill:SetFrameLevel(6)
		b.fill:SetStatusBarTexture(BARS_PATH)
		local tx = b.fill:GetStatusBarTexture()
		if tx then
			tx:SetDrawLayer("BORDER", 0)
		end

		b.fillGhost = CreateFrame("StatusBar", ghostName, b.overlay)
		b.fillGhost:SetAllPoints(b.overlay)
		b.fillGhost:SetMinMaxValues(0, 100)
		b.fillGhost:SetValue(0)
		b.fillGhost:SetFrameLevel(5)
		b.fillGhost:SetStatusBarTexture(BARS_PATH)
		b.fillGhost:SetStatusBarColor(0.65, 0.65, 0.65, 0.55)
		local gtx = b.fillGhost:GetStatusBarTexture()
		if gtx then
			gtx:SetDrawLayer("ARTWORK", 0)
		end

		b.art = {}
		for i = 1, 4 do
			local t = b.overlay:CreateTexture(nil, "OVERLAY")
			t:SetTexture(XP_ART_PATH)
			t:SetTexCoord(0, 1, ART_COORDS[i].top, ART_COORDS[i].bottom)
			b.art[i] = t
		end

		b.cdfRound = b.overlay:CreateTexture(nil, "OVERLAY")
		b.cdfRound:SetDrawLayer("OVERLAY", -6)
		b.cdfRound:Hide()

		b.label = b.overlay:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
		b.label:SetPoint("CENTER", b.overlay, "CENTER", 0, 1)
		b.label:SetText("")

		b.overlay:SetScript("OnSizeChanged", function()
			qtBar.LayoutBarArt()
		end)
		b.overlay:SetScript("OnEnter", function(self)
			showTooltip(self)
			qtBar.UpdateLabelVisibility(true)
		end)
		b.overlay:SetScript("OnLeave", function()
			GameTooltip:Hide()
			qtBar.UpdateLabelVisibility(false)
		end)
		if interactive then
			b.overlay:SetScript("OnMouseDown", function(self, button)
				if button == "MiddleButton" then
					if qtBar.ConfigToggle then
						qtBar.ConfigToggle()
					end
					return
				end
				local shiftDown = (type(IsShiftKeyDown) == "function" and IsShiftKeyDown()) and true or false
				if not shiftDown then
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
						local nw = clamp(b.resizeW + cx - b.resizeX, mw, Mw)
						local nh = clamp(b.resizeH + cy - b.resizeY, mh, Mh)
						self:SetSize(nw, nh)
						local bars = qtBar.bars
						if bars then
							if bars.equipped and bars.equipped.overlay then
								bars.equipped.overlay:SetSize(nw, nh)
							end
							if bars.bag and bars.bag.overlay then
								bars.bag.overlay:SetSize(nw, nh)
							end
						end
						if qtBar.LayoutBarArt then
							qtBar.LayoutBarArt()
						end
						if qtBar.ApplyBarInsetFills then
							qtBar.ApplyBarInsetFills()
						end
					end)
				end
			end)
			b.overlay:SetScript("OnMouseUp", function(self)
				if b.moving then
					self:StopMovingOrSizing()
					b.moving = nil
					saveLayout(b.overlay._qtKey)
					qtBar.ApplyBarLayout()
				end
				if b.resizing then
					self:SetScript("OnUpdate", nil)
					b.resizing = nil
					saveLayout(b.overlay._qtKey)
					qtBar.ApplyBarLayout()
				end
			end)
		end

		b.ticker = CreateFrame("Frame", tickerName, UIParent)
		return b
	end

	bars.equipped = createVisualBar("qtBarStandalone", "qtBarFill", "qtBarFillGhost", "qtBarTicker", "equipped", true)
	bars.bag = createVisualBar("qtBarStandaloneBag", "qtBarFillBag", "qtBarFillGhostBag", "qtBarTickerBag", "bag", true)

	bars.equipped.ticker._qtRunning = false
	bars.bag.ticker:Hide()

	if qtBar.ConfigMerge then
		qtBar.ConfigMerge()
	end
	qtBar.ApplyBarLayout()
	qtBar.ApplyBarTextureStyle()
	qtBar.LayoutBarArt()
	if qtBar.ApplyBarInsetFills then
		qtBar.ApplyBarInsetFills()
	end
	qtBar.bar = bars.equipped
end

function qtBar.BarSyncFromData(which)
	local bars = qtBar.bars
	if not bars or not bars.equipped or not bars.bag then
		return
	end

	local db = qtBar.db
	if not db then
		return
	end

	if db.hideWhileLeveling and UnitLevel("player") < (db.maxLevel or 80) then
		bars.equipped.overlay:Hide()
		bars.bag.overlay:Hide()
		return
	end

	if db.hideBagAttuneBar and bars.bag and bars.bag.overlay then
		bars.bag.overlay:Hide()
	end

	local function syncBarVisual(b, snap, prefix)
		b.overlay:Show()
		local target = snap.average or 0
		if snap.allComplete then
			target = 100
		end
		if type(b._displayAverage) ~= "number" then
			b._displayAverage = target
		end
		if snap.allComplete then
			b._displayAverage = target
		end
		b._targetAverage = target
		if b.fillGhost then
			local gc = db.ghostColor or qtBar.DEFAULTS.ghostColor
			b.fillGhost:SetStatusBarColor(gc.r or 1, gc.g or 1, gc.b or 1, gc.a or 1)
			b.fillGhost:SetValue(target)
		end
		b.fill:SetValue(b._displayAverage)
		if not (tonumber(db.colorCycleSpeed) and tonumber(db.colorCycleSpeed) > 0) then
			local c = getFillColorForBar(db, b.overlay._qtKey)
			b.fill:SetStatusBarColor(c.r, c.g, c.b, c.a or 1)
		end
		local nextLabel = qtBar.FormatAttuneLabel and qtBar.FormatAttuneLabel(snap, prefix) or format("%s: %d%%", prefix, floor((snap.average or 0) + 0.5))
		if b._lastLabel ~= nextLabel then
			b.label:SetText(nextLabel)
			b._lastLabel = nextLabel
		end
		b._lastAverage = snap.average
	end

	if which ~= "bag" then
		local equippedSnap = qtBar.GetEquippedAttunementSnapshot and qtBar.GetEquippedAttunementSnapshot() or nil
		if equippedSnap then
			qtBar._lastEquippedSnap = equippedSnap
			qtBar._lastEquippedFp = qtBar.AttuneFingerprintHash(equippedSnap)
			syncBarVisual(bars.equipped, equippedSnap, "Equipped Attune")
		end
	end
	if which ~= "equipped" and not db.hideBagAttuneBar then
		local bagSnap = qtBar.GetBagAttunementSnapshot and qtBar.GetBagAttunementSnapshot() or nil
		if bagSnap then
			qtBar._lastBagSnap = bagSnap
			qtBar._lastBagFp = qtBar.AttuneFingerprintHash(bagSnap)
			syncBarVisual(bars.bag, bagSnap, "Bag Attune")
		end
	end
	qtBar.UpdateLabelVisibility(false)
	qtBar.SetTickerActive(true)
end

function qtBar.SetTickerActive(active)
	local bars = qtBar.bars
	local mainBar = bars and bars.equipped
	local ticker = mainBar and mainBar.ticker
	if not ticker then
		return
	end
	if active then
		if not ticker._qtRunning then
			ticker._qtRunning = true
			ticker:Show()
			ticker:SetScript("OnUpdate", function(self, el)
				qtBar.BarOnUpdate(self, el)
			end)
		end
		return
	end
	if ticker._qtRunning then
		ticker._qtRunning = false
		ticker:SetScript("OnUpdate", nil)
		ticker:Hide()
	end
end

function qtBar.BarOnUpdate(_, elapsed)
	local bars = qtBar.bars
	local mainBar = bars and bars.equipped
	if not mainBar or not mainBar.ticker then
		return
	end
	local el = elapsed or 0
	local db = qtBar.db
	local colorSpeed = (db and tonumber(db.colorCycleSpeed)) or 0
	local animating = false
	for _, b in pairs(bars) do
		local run = b.overlay:IsShown()
		if b.fill and run then
			local target = b._targetAverage
			local display = b._displayAverage
			if type(target) == "number" and type(display) == "number" then
				local lerpPerSec = (db and tonumber(db.lerpSpeed)) or 3
				if lerpPerSec < 0.1 then
					lerpPerSec = 0.1
				end
				local t = min(1, el * lerpPerSec)
				local nextV = display + (target - display) * t
				if math.abs(target - nextV) < 0.02 then
					nextV = target
				end
				b._displayAverage = nextV
				b.fill:SetValue(nextV)
				if nextV ~= target then
					animating = true
				end
			end
			if colorSpeed > 0 then
				local rt = (GetTime() * colorSpeed) % 1
				local cr, cg, cb = rainbowRgb(rt)
				local a = 1
				local c = getFillColorForBar(db, b.overlay._qtKey)
				if c and type(c) == "table" then
					a = c.a or 1
				end
				b.fill:SetStatusBarColor(cr, cg, cb, a)
			end
		end
	end
	if not animating and colorSpeed <= 0 then
		qtBar.SetTickerActive(false)
	end
end
