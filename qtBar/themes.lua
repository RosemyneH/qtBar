-- ʕ •ᴥ•ʔ✿ qtBar UI themes (qtRunner-compatible palette) ✿ ʕ •ᴥ•ʔ
local _G = _G

if not _G.qtBar then
	_G.qtBar = {}
end

local qtBar = _G.qtBar

qtBar.Themes = {
	dark = {
		text = { r = 0.92, g = 0.94, b = 0.98 },
		textMuted = { r = 0.55, g = 0.62, b = 0.72 },
		accent = { r = 0.55, g = 0.78, b = 1.0 },
		sel = { r = 0.22, g = 0.42, b = 0.62, a = 0.45 },
		hi = { r = 0.4, g = 0.65, b = 0.95, a = 0.22 },
		panel = { r = 0.02, g = 0.02, b = 0.04, a = 0.92 },
		panelInset = { r = 0.0, g = 0.0, b = 0.0, a = 0.55 },
		border = { r = 0.2, g = 0.28, b = 0.38, a = 0.45 },
		borderSoft = { r = 0.35, g = 0.4, b = 0.5, a = 0.2 },
		listBorder = { r = 0.3, g = 0.35, b = 0.45, a = 0.18 },
		good = { r = 0.46, g = 0.9, b = 0.58 },
		bad = { r = 1.0, g = 0.45, b = 0.45 },
	},
	light = {
		text = { r = 0.14, g = 0.18, b = 0.24 },
		textMuted = { r = 0.38, g = 0.44, b = 0.52 },
		accent = { r = 0.12, g = 0.44, b = 0.76 },
		sel = { r = 0.42, g = 0.67, b = 0.95, a = 0.34 },
		hi = { r = 0.28, g = 0.52, b = 0.82, a = 0.12 },
		panel = { r = 0.96, g = 0.97, b = 1.0, a = 0.96 },
		panelInset = { r = 0.88, g = 0.91, b = 0.96, a = 0.96 },
		border = { r = 0.58, g = 0.67, b = 0.8, a = 0.9 },
		borderSoft = { r = 0.52, g = 0.63, b = 0.78, a = 0.55 },
		listBorder = { r = 0.52, g = 0.63, b = 0.78, a = 0.45 },
		good = { r = 0.12, g = 0.55, b = 0.22 },
		bad = { r = 0.75, g = 0.22, b = 0.22 },
	},
	red = {
		text = { r = 0.98, g = 0.92, b = 0.93 },
		textMuted = { r = 0.72, g = 0.56, b = 0.58 },
		accent = { r = 1.0, g = 0.34, b = 0.36 },
		sel = { r = 0.72, g = 0.18, b = 0.22, a = 0.5 },
		hi = { r = 1.0, g = 0.42, b = 0.4, a = 0.24 },
		panel = { r = 0.09, g = 0.02, b = 0.04, a = 0.94 },
		panelInset = { r = 0.16, g = 0.04, b = 0.06, a = 0.64 },
		border = { r = 0.58, g = 0.18, b = 0.2, a = 0.65 },
		borderSoft = { r = 0.74, g = 0.28, b = 0.3, a = 0.32 },
		listBorder = { r = 0.62, g = 0.2, b = 0.24, a = 0.28 },
		good = { r = 0.45, g = 0.88, b = 0.56 },
		bad = { r = 1.0, g = 0.48, b = 0.48 },
	},
	blue = {
		text = { r = 0.91, g = 0.96, b = 1.0 },
		textMuted = { r = 0.56, g = 0.68, b = 0.82 },
		accent = { r = 0.34, g = 0.7, b = 1.0 },
		sel = { r = 0.14, g = 0.34, b = 0.64, a = 0.48 },
		hi = { r = 0.34, g = 0.7, b = 1.0, a = 0.22 },
		panel = { r = 0.02, g = 0.05, b = 0.11, a = 0.94 },
		panelInset = { r = 0.03, g = 0.1, b = 0.18, a = 0.62 },
		border = { r = 0.2, g = 0.42, b = 0.74, a = 0.6 },
		borderSoft = { r = 0.28, g = 0.52, b = 0.86, a = 0.28 },
		listBorder = { r = 0.22, g = 0.46, b = 0.78, a = 0.24 },
		good = { r = 0.48, g = 0.9, b = 0.64 },
		bad = { r = 1.0, g = 0.5, b = 0.5 },
	},
	green = {
		text = { r = 0.92, g = 0.98, b = 0.94 },
		textMuted = { r = 0.56, g = 0.74, b = 0.62 },
		accent = { r = 0.34, g = 0.9, b = 0.5 },
		sel = { r = 0.08, g = 0.42, b = 0.2, a = 0.48 },
		hi = { r = 0.36, g = 1.0, b = 0.58, a = 0.2 },
		panel = { r = 0.03, g = 0.08, b = 0.04, a = 0.94 },
		panelInset = { r = 0.04, g = 0.14, b = 0.08, a = 0.62 },
		border = { r = 0.16, g = 0.52, b = 0.28, a = 0.6 },
		borderSoft = { r = 0.24, g = 0.66, b = 0.38, a = 0.3 },
		listBorder = { r = 0.2, g = 0.58, b = 0.34, a = 0.24 },
		good = { r = 0.44, g = 0.94, b = 0.56 },
		bad = { r = 1.0, g = 0.48, b = 0.46 },
	},
	yellow = {
		text = { r = 0.2, g = 0.16, b = 0.04 },
		textMuted = { r = 0.44, g = 0.36, b = 0.14 },
		accent = { r = 0.92, g = 0.72, b = 0.16 },
		sel = { r = 0.94, g = 0.78, b = 0.22, a = 0.34 },
		hi = { r = 0.98, g = 0.84, b = 0.3, a = 0.16 },
		panel = { r = 0.97, g = 0.91, b = 0.62, a = 0.96 },
		panelInset = { r = 0.9, g = 0.82, b = 0.42, a = 0.94 },
		border = { r = 0.7, g = 0.56, b = 0.16, a = 0.85 },
		borderSoft = { r = 0.76, g = 0.62, b = 0.22, a = 0.5 },
		listBorder = { r = 0.72, g = 0.58, b = 0.18, a = 0.44 },
		good = { r = 0.12, g = 0.5, b = 0.2 },
		bad = { r = 0.72, g = 0.2, b = 0.18 },
	},
	purple = {
		text = { r = 0.96, g = 0.92, b = 1.0 },
		textMuted = { r = 0.66, g = 0.58, b = 0.8 },
		accent = { r = 0.72, g = 0.46, b = 1.0 },
		sel = { r = 0.38, g = 0.18, b = 0.62, a = 0.48 },
		hi = { r = 0.78, g = 0.5, b = 1.0, a = 0.2 },
		panel = { r = 0.06, g = 0.03, b = 0.1, a = 0.94 },
		panelInset = { r = 0.12, g = 0.05, b = 0.18, a = 0.62 },
		border = { r = 0.42, g = 0.24, b = 0.72, a = 0.6 },
		borderSoft = { r = 0.58, g = 0.34, b = 0.9, a = 0.3 },
		listBorder = { r = 0.5, g = 0.28, b = 0.8, a = 0.24 },
		good = { r = 0.44, g = 0.9, b = 0.58 },
		bad = { r = 1.0, g = 0.46, b = 0.56 },
	},
	orange = {
		text = { r = 1.0, g = 0.94, b = 0.88 },
		textMuted = { r = 0.78, g = 0.6, b = 0.46 },
		accent = { r = 1.0, g = 0.56, b = 0.18 },
		sel = { r = 0.72, g = 0.32, b = 0.08, a = 0.48 },
		hi = { r = 1.0, g = 0.62, b = 0.22, a = 0.22 },
		panel = { r = 0.1, g = 0.05, b = 0.02, a = 0.94 },
		panelInset = { r = 0.18, g = 0.09, b = 0.03, a = 0.62 },
		border = { r = 0.74, g = 0.36, b = 0.08, a = 0.62 },
		borderSoft = { r = 0.88, g = 0.48, b = 0.14, a = 0.3 },
		listBorder = { r = 0.78, g = 0.4, b = 0.1, a = 0.24 },
		good = { r = 0.52, g = 0.9, b = 0.56 },
		bad = { r = 1.0, g = 0.46, b = 0.4 },
	},
	teal = {
		text = { r = 0.9, g = 0.98, b = 0.98 },
		textMuted = { r = 0.54, g = 0.76, b = 0.76 },
		accent = { r = 0.22, g = 0.84, b = 0.82 },
		sel = { r = 0.06, g = 0.42, b = 0.42, a = 0.46 },
		hi = { r = 0.28, g = 0.92, b = 0.88, a = 0.2 },
		panel = { r = 0.02, g = 0.08, b = 0.08, a = 0.94 },
		panelInset = { r = 0.03, g = 0.15, b = 0.14, a = 0.62 },
		border = { r = 0.14, g = 0.52, b = 0.5, a = 0.62 },
		borderSoft = { r = 0.2, g = 0.68, b = 0.64, a = 0.3 },
		listBorder = { r = 0.18, g = 0.6, b = 0.58, a = 0.24 },
		good = { r = 0.48, g = 0.94, b = 0.62 },
		bad = { r = 1.0, g = 0.48, b = 0.48 },
	},
	rose = {
		text = { r = 1.0, g = 0.93, b = 0.96 },
		textMuted = { r = 0.78, g = 0.58, b = 0.68 },
		accent = { r = 1.0, g = 0.42, b = 0.66 },
		sel = { r = 0.68, g = 0.18, b = 0.4, a = 0.46 },
		hi = { r = 1.0, g = 0.48, b = 0.72, a = 0.2 },
		panel = { r = 0.1, g = 0.03, b = 0.07, a = 0.94 },
		panelInset = { r = 0.16, g = 0.05, b = 0.11, a = 0.62 },
		border = { r = 0.72, g = 0.22, b = 0.44, a = 0.62 },
		borderSoft = { r = 0.86, g = 0.34, b = 0.58, a = 0.3 },
		listBorder = { r = 0.78, g = 0.28, b = 0.5, a = 0.24 },
		good = { r = 0.48, g = 0.92, b = 0.62 },
		bad = { r = 1.0, g = 0.46, b = 0.54 },
	},
}

qtBar.ThemeOrder = {
	"dark",
	"light",
	"red",
	"blue",
	"green",
	"yellow",
	"purple",
	"orange",
	"teal",
	"rose",
}

qtBar.ThemeLabels = {
	dark = "Dark",
	light = "Light",
	red = "Red",
	blue = "Blue",
	green = "Green",
	yellow = "Yellow",
	purple = "Purple",
	orange = "Orange",
	teal = "Teal",
	rose = "Rose",
}

function qtBar:GetColors()
	local themeName = _G.qtBarDB and _G.qtBarDB.theme or "dark"
	return self.Themes[themeName] or self.Themes.dark
end

function qtBar:GetThemeLabel(themeName)
	return (self.ThemeLabels and self.ThemeLabels[themeName]) or themeName or "Dark"
end

function qtBar:GetThemeList()
	return self.ThemeOrder or { "dark", "light" }
end

local function refreshThemeDropdownText(dd)
	if not dd then
		return
	end
	qtBar.ConfigMerge()
	local name = qtBar.db and qtBar.db.theme or "dark"
	local text = qtBar:GetThemeLabel(name)
	local uid = _G.UIDropDownMenu
	if uid and uid.SetText then
		uid.SetText(dd, text)
	else
		local tn = dd:GetName() and _G[dd:GetName() .. "Text"]
		if tn and tn.SetText then
			tn:SetText(text)
		end
	end
end

function qtBar:RegisterThemeDropdown(dd)
	self._themeDD = dd
	if dd then
		dd._qtBarThemeBinding = true
	end
end

function qtBar:RefreshThemeDropdown()
	refreshThemeDropdownText(self._themeDD)
end

function qtBar:ApplyConfigTheme()
	local f = self.configFrame
	if not f then
		return
	end
	local c = self:GetColors()
	f:SetBackdropColor(c.panel.r, c.panel.g, c.panel.b, c.panel.a)
	f:SetBackdropBorderColor(c.border.r, c.border.g, c.border.b, c.border.a)
	if f.inset and f.inset.SetBackdropColor then
		f.inset:SetBackdropColor(c.panelInset.r, c.panelInset.g, c.panelInset.b, c.panelInset.a)
		f.inset:SetBackdropBorderColor(c.borderSoft.r, c.borderSoft.g, c.borderSoft.b, c.borderSoft.a)
	end
	if f.title then
		f.title:SetTextColor(c.accent.r, c.accent.g, c.accent.b)
	end
	if f.themeLabel then
		f.themeLabel:SetTextColor(c.textMuted.r, c.textMuted.g, c.textMuted.b)
	end
	for _, fs in ipairs(f._themeTexts or {}) do
		if fs and fs.SetTextColor then
			fs:SetTextColor(c.textMuted.r, c.textMuted.g, c.textMuted.b)
		end
	end
	for _, ed in ipairs(f._editRefs or {}) do
		if ed and ed.SetTextColor then
			ed:SetTextColor(c.accent.r, c.accent.g, c.accent.b)
		end
	end
	for _, row in ipairs(f._checks or {}) do
		local tf = row.textFrame
		if tf and tf.SetTextColor then
			tf:SetTextColor(c.text.r, c.text.g, c.text.b)
		end
	end
	refreshThemeDropdownText(self._themeDD)
	local ddup = self._themeDD
	if ddup then
		local left = _G[ddup:GetName() .. "Left"]
		local right = _G[ddup:GetName() .. "Right"]
		local mid = _G[ddup:GetName() .. "Middle"]
		if mid and mid.SetVertexColor then
			mid:SetVertexColor(c.panelInset.r, c.panelInset.g, c.panelInset.b)
		end
		if left and left.SetVertexColor then
			left:SetVertexColor(c.borderSoft.r, c.borderSoft.g, c.borderSoft.b)
		end
		if right and right.SetVertexColor then
			right:SetVertexColor(c.borderSoft.r, c.borderSoft.g, c.borderSoft.b)
		end
		local t = _G[ddup:GetName() .. "Text"]
		if t and t.SetTextColor then
			t:SetTextColor(c.text.r, c.text.g, c.text.b)
		end
	end
end
