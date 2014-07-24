local style = {}

AURORA_CUSTOM_STYLE = style

style.apiVersion = "5.0.7"

local F, C

style.functions = {
	["CreateBD"] = function(f, a)
		f:SetBackdrop({
			bgFile = C.media.backdrop,
			edgeFile = C.media.backdrop,
			edgeSize = 1,
		})
		f:SetBackdropColor(0, 0, 0, a or AuroraConfig.alpha)
		f:SetBackdropBorderColor(0, 0, 1)
		if not a then tinsert(C.frames, f) end
	end,
	["Reskin"] = function(f, noHighlight)
		f:SetNormalTexture("")
		f:SetHighlightTexture("")
		f:SetPushedTexture("")
		f:SetDisabledTexture("")

		if f.Left then f.Left:SetAlpha(0) end
		if f.Middle then f.Middle:SetAlpha(0) end
		if f.Right then f.Right:SetAlpha(0) end
		if f.LeftSeparator then f.LeftSeparator:Hide() end
		if f.RightSeparator then f.RightSeparator:Hide() end

		F.CreateBD(f, .0)
	end,
}

style.classcolors = {
	["HUNTER"] = { r = 0.58, g = 0.86, b = 0.49 },
	["WARLOCK"] = { r = 0.6, g = 0.47, b = 0.85 },
	["PALADIN"] = { r = 0, g = 1, b = 1 },
	["PRIEST"] = { r = 0.8, g = 0.87, b = .9 },
	["MAGE"] = { r = 0, g = 0.76, b = 1 },
	["MONK"] = {r = 0.0, g = 1.00 , b = 0.59},
	["ROGUE"] = { r = 1, g = 0.91, b = 0.2 },
	["DRUID"] = { r = 1, g = 0.49, b = 0.04 },
	["SHAMAN"] = { r = 0, g = 0.6, b = 0.6 };
	["WARRIOR"] = { r = 0.9, g = 0.65, b = 0.45 },
	["DEATHKNIGHT"] = { r = 0.77, g = 0.12 , b = 0.23 },
}

style.highlightColor = {r = 0, g = 1, b = 0}

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
	if addon == "Aurora" then
		F, C = unpack(Aurora)

		self:UnregisterEvent("ADDON_LOADED")
	end
end)
