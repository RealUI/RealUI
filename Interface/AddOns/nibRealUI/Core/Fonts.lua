local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb, ndbc

local MODNAME = "Fonts"
local Fonts = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

nibRealUI.font = {
	standard = nil,
	pixel1 = nil,
	pixel2 = nil,
	pixelNumbers = nil,
	pixelCooldown = nil,
}

RealUIFontSmall = CreateFont("RealUIFontObjectSmall")
RealUIFontLarge = CreateFont("RealUIFontObjectLarge")
RealUIFontPixel = CreateFont("RealUIFontObjectPixel")
RealUIStandardFont10 = CreateFont("RealUIFontObjectStandard10")

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Fonts",
		desc = "Adjust the fonts used in RealUI.",
		arg = MODNAME,
		order = 9106,
		args = {
			header = {
				type = "header",
				name = "Fonts",
				order = 10,
			},
			desc1 = {
				type = "description",
				name = "Adjust the fonts used in RealUI.",
				fontSize = "medium",
				order = 20,
			},
			desc2 = {
				type = "description",
				name = " ",
				order = 21,
			},
			desc3 = {
				type = "description",
				name = "Note: Some 3rd party addons (such as MSBT) will need fonts adjusted through their own configuration window.",
				order = 22,
			},
			desc4 = {
				type = "description",
				name = "Note2: You will need to reload the UI (/rl) for changes to take effect.",
				order = 23,
			},
			gap1 = {
				name = " ",
				type = "description",
				order = 24,
			},
			standard = {
				name = "Standard",
				type = "group",
				inline = true,
				order = 30,
				args = {
					font = {
						type = "select",
						name = "Font",
						values = AceGUIWidgetLSMlists.font,
						get = function()
							return nibRealUI.media.font.standard[1]
						end,
						set = function(info, value)
							nibRealUI.media.font.standard[1] = value
						end,
						dialogControl = "LSM30_Font",
						order = 10,
					},
					sizeadjust = {
						type = "range",
						name = "Adjust Size",
						desc = "Increase/Decrease all UI Standard font sizes by this value.",
						min = -6, max = 6, step = 1,
						get = function(info) return db.standard.sizeadjust end,
						set = function(info, value) 
							db.standard.sizeadjust = value
							nibRealUI.font.sizeAdjust = db.standard.sizeadjust
						end,
						order = 20,
					},
					changeYellow = {
						type = "toggle",
						name = "Adjust Yellow Fonts",
						desc = "Change the color of WoW's 'yellow' fonts.",
						get = function() return db.standard.changeYellow end,
						set = function(info, value) 
							db.standard.changeYellow = value
							InfoLine:Refresh()
						end,
						order = 30,
					},
					yellowColor = {
						type = "color",
						name = "Yellow Font Color",
						hasAlpha = false,
						get = function(info,r,g,b)
							return db.standard.yellowColor[1], db.standard.yellowColor[2], db.standard.yellowColor[3]
						end,
						set = function(info,r,g,b)
							db.standard.yellowColor[1] = r
							db.standard.yellowColor[2] = g
							db.standard.yellowColor[3] = b
						end,
						order = 40,
					},
				},
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 31,
			},
			chatFont = {
				name = "Custom Chat Font",
				type = "group",
				inline = true,
				order = 35,
				args = {
					enabled = {
						type = "toggle",
						name = "Use custom chat font",
						desc = "Use a font other than Standard for the Chat window.",
						get = function() return ndb.settings.chatFontCustom.enabled end,
						set = function(info, value) 
							ndb.settings.chatFontCustom.enabled = value
							nibRealUI:StyleSetChatFont()
						end,
						order = 10,
					},
					font = {
						type = "select",
						name = "Font",
						values = AceGUIWidgetLSMlists.font,
						get = function()
							return ndb.settings.chatFontCustom.font
						end,
						set = function(info, value)
							ndb.settings.chatFontCustom.font = value
							nibRealUI:StyleSetChatFont()
						end,
						dialogControl = "LSM30_Font",
						order = 20,
					},
				},
			},
			gap3 = {
				name = " ",
				type = "description",
				order = 36,
			},
			pixel_small = {
				name = "Pixel (Small)",
				type = "group",
				inline = true,
				order = 40,
				args = {
					font = {
						type = "select",
						name = "Font",
						values = AceGUIWidgetLSMlists.font,
						get = function()
							return nibRealUI.media.font.pixel.small[1]
						end,
						set = function(info, value)
							nibRealUI.media.font.pixel.small[1] = value
						end,
						dialogControl = "LSM30_Font",
						order = 10,
					},
					size = {
						type = "range",
						name = "Size",
						min = 6, max = 28, step = 1,
						get = function(info) return nibRealUI.media.font.pixel.small[2] end,
						set = function(info, value)
							nibRealUI.media.font.pixel.small[2] = value
						end,
						order = 20,
					},
					outline = {
						type = "select",
						name = "Outline",
						values = nibRealUI.globals.outlines,
						get = function()
							for k,v in pairs(nibRealUI.globals.outlines) do
								if v == nibRealUI.media.font.pixel.small[3] then return k end
							end
						end,
						set = function(info, value)
							nibRealUI.media.font.pixel.small[3] = nibRealUI.globals.outlines[value]
						end,
						order = 30,
					},
				},
			},
			gap4 = {
				name = " ",
				type = "description",
				order = 41,
			},
			pixel_large = {
				name = "Pixel (Large)",
				type = "group",
				inline = true,
				order = 50,
				args = {
					font = {
						type = "select",
						name = "Font",
						values = AceGUIWidgetLSMlists.font,
						get = function()
							return nibRealUI.media.font.pixel.large[1]
						end,
						set = function(info, value)
							nibRealUI.media.font.pixel.large[1] = value
						end,
						dialogControl = "LSM30_Font",
						order = 10,
					},
					size = {
						type = "range",
						name = "Size",
						min = 6, max = 28, step = 1,
						get = function(info) return nibRealUI.media.font.pixel.large[2] end,
						set = function(info, value)
							nibRealUI.media.font.pixel.large[2] = value
						end,
						order = 20,
					},
					outline = {
						type = "select",
						name = "Outline",
						values = nibRealUI.globals.outlines,
						get = function()
							for k,v in pairs(nibRealUI.globals.outlines) do
								if v == nibRealUI.media.font.pixel.large[3] then return k end
							end
						end,
						set = function(info, value)
							nibRealUI.media.font.pixel.large[3] = nibRealUI.globals.outlines[value]
						end,
						order = 30,
					},
				},
			},
			gap5 = {
				name = " ",
				type = "description",
				order = 51,
			},
			pixel_numbers = {
				name = "Pixel (Numbers)",
				type = "group",
				inline = true,
				order = 60,
				args = {
					font = {
						type = "select",
						name = "Font",
						values = AceGUIWidgetLSMlists.font,
						get = function()
							return nibRealUI.media.font.pixel.numbers[1]
						end,
						set = function(info, value)
							nibRealUI.media.font.pixel.numbers[1] = value
						end,
						dialogControl = "LSM30_Font",
						order = 10,
					},
					size = {
						type = "range",
						name = "Size",
						min = 6, max = 28, step = 1,
						get = function(info) return nibRealUI.media.font.pixel.numbers[2] end,
						set = function(info, value)
							nibRealUI.media.font.pixel.numbers[2] = value
						end,
						order = 20,
					},
					outline = {
						type = "select",
						name = "Outline",
						values = nibRealUI.globals.outlines,
						get = function()
							for k,v in pairs(nibRealUI.globals.outlines) do
								if v == nibRealUI.media.font.pixel.numbers[3] then return k end
							end
						end,
						set = function(info, value)
							nibRealUI.media.font.pixel.numbers[3] = nibRealUI.globals.outlines[value]
						end,
						order = 30,
					},
				},
			},
			gap6 = {
				name = " ",
				type = "description",
				order = 61,
			},
			pixel_cooldown = {
				name = "Pixel (Cooldown)",
				type = "group",
				inline = true,
				order = 80,
				args = {
					font = {
						type = "select",
						name = "Font",
						values = AceGUIWidgetLSMlists.font,
						get = function()
							return nibRealUI.media.font.pixel.cooldown[1]
						end,
						set = function(info, value)
							nibRealUI.media.font.pixel.cooldown[1] = value
						end,
						dialogControl = "LSM30_Font",
						order = 10,
					},
					size = {
						type = "range",
						name = "Size",
						min = 6, max = 28, step = 1,
						get = function(info) return nibRealUI.media.font.pixel.cooldown[2] end,
						set = function(info, value)
							nibRealUI.media.font.pixel.cooldown[2] = value
						end,
						order = 20,
					},
					outline = {
						type = "select",
						name = "Outline",
						values = nibRealUI.globals.outlines,
						get = function()
							for k,v in pairs(nibRealUI.globals.outlines) do
								if v == nibRealUI.media.font.pixel.cooldown[3] then return k end
							end
						end,
						set = function(info, value)
							nibRealUI.media.font.pixel.cooldown[3] = nibRealUI.globals.outlines[value]
						end,
						order = 30,
					},
				},
			},
			gap7 = {
				name = " ",
				type = "description",
				order = 81,
			},
			changeFCT = {
				type = "toggle",
				name = "Change Floating Combat Text",
				desc = "Change the font of the default Floating Combat Text.",
				get = function() return db.changeFCT end,
				set = function(info, value) 
					db.changeFCT = value
				end,
				order = 90,
			},
		},
	};
	end
	return options
end

function Fonts:UpdateUIFonts2()
	local font = nibRealUI.font.standard
	local adjSize = db.standard.sizeadjust
	
	RaidWarningFrame.slot1:SetFont(font, 20, "OUTLINE")
	RaidWarningFrame.slot2:SetFont(font, 20, "OUTLINE")
	RaidBossEmoteFrame.slot1:SetFont(font, 20, "OUTLINE")
	RaidBossEmoteFrame.slot2:SetFont(font, 20, "OUTLINE")
	
	STANDARD_TEXT_FONT = font
	UNIT_NAME_FONT     = font
	NAMEPLATE_FONT     = font
	if db.changeFCT then
		DAMAGE_TEXT_FONT = font
	end

	-- Base fonts
	AchievementFont_Small:SetFont(font, 10 + adjSize)
	AchievementFont_Small:SetShadowColor(0, 0, 0)
	AchievementFont_Small:SetShadowOffset(1, -1)
	CoreAbilityFont:SetFont(font, 32)
	CoreAbilityFont:SetShadowColor(0, 0, 0)
	CoreAbilityFont:SetShadowOffset(1, -1)
	DestinyFontHuge:SetFont(font, 32)
	DestinyFontHuge:SetShadowColor(0, 0, 0)
	DestinyFontHuge:SetShadowOffset(1, -1)
	DestinyFontLarge:SetFont(font, 18)
	DestinyFontLarge:SetShadowColor(0, 0, 0)
	DestinyFontLarge:SetShadowOffset(1, -1)
	FriendsFont_Normal:SetFont(font, 11 + adjSize)
	FriendsFont_Small:SetFont(font, 10 + adjSize)
	FriendsFont_Large:SetFont(font, 13)
	FriendsFont_UserText:SetFont(font, 10 + adjSize)
	GameFont_Gigantic:SetFont(font, 32)
	GameTooltipHeader:SetFont(font, 13)
	GameTooltipHeader:SetShadowColor(0, 0, 0)
	GameTooltipHeader:SetShadowOffset(1, -1)
	InvoiceFont_Small:SetFont(font, 10 + adjSize)
	InvoiceFont_Small:SetShadowColor(0, 0, 0)
	InvoiceFont_Small:SetShadowOffset(1, -1)
	InvoiceFont_Med:SetFont(font, 11 + adjSize)
	InvoiceFont_Med:SetShadowColor(0, 0, 0)
	InvoiceFont_Med:SetShadowOffset(1, -1)
	MailFont_Large:SetFont(font, 15)
	NumberFont_OutlineThick_Mono_Small:SetFont(font, 10 + adjSize, "OUTLINE")
	NumberFont_Outline_Huge:SetFont(font, 30, "OUTLINE")
	NumberFont_Outline_Large:SetFont(font, 15, "OUTLINE")
	NumberFont_Outline_Med:SetFont(font, 12, "OUTLINE")
	NumberFont_Shadow_Med:SetFont(font, 12)
	NumberFont_Shadow_Small:SetFont(font, 10 + adjSize)
	QuestFont_Shadow_Small:SetFont(font, 10)
	QuestFont_Large:SetFont(font, 12)
	QuestFont_Large:SetShadowColor(0, 0, 0)
	QuestFont_Large:SetShadowOffset(1, -1)
	QuestFont_Shadow_Huge:SetFont(font, 18)
	QuestFont_Super_Huge:SetFont(font, 24)
	QuestFont_Super_Huge:SetShadowColor(0, 0, 0)
	QuestFont_Super_Huge:SetShadowOffset(1, -1)
	ReputationDetailFont:SetFont(font, 10 + adjSize)
	SpellFont_Small:SetFont(font, 10 + adjSize)
	SpellFont_Small:SetShadowColor(0, 0, 0)
	SpellFont_Small:SetShadowOffset(1, -1)
	SystemFont_InverseShadow_Small:SetFont(font, 10 + adjSize)
	GameFontNormal:SetFont(font, 11 + adjSize)
	SystemFont_Large:SetFont(font, 15)
	SystemFont_Large:SetShadowColor(0, 0, 0)
	SystemFont_Large:SetShadowOffset(1, -1)
	SystemFont_Huge1:SetFont(font, 20)
	SystemFont_Huge1:SetShadowColor(0, 0, 0)
	SystemFont_Huge1:SetShadowOffset(1, -1)
	SystemFont_Med1:SetFont(font, 11 + adjSize)
	SystemFont_Med1:SetShadowColor(0, 0, 0)
	SystemFont_Med1:SetShadowOffset(1, -1)
	SystemFont_Med2:SetFont(font, 12 + adjSize)
	SystemFont_Med2:SetShadowColor(0, 0, 0)
	SystemFont_Med2:SetShadowOffset(1, -1)
	SystemFont_Med3:SetFont(font, 13 + adjSize)
	SystemFont_Med3:SetShadowColor(0, 0, 0)
	SystemFont_Med3:SetShadowOffset(1, -1)
	SystemFont_OutlineThick_WTF:SetFont(font, 32, "THICKOUTLINE")
	SystemFont_OutlineThick_Huge2:SetFont(font, 22, "THICKOUTLINE")
	SystemFont_OutlineThick_Huge4:SetFont(font, 26, "THICKOUTLINE")
	SystemFont_Outline_Small:SetFont(font, 10 + adjSize, "OUTLINE")
	SystemFont_Outline:SetFont(font, 11 + adjSize, "OUTLINE")
	SystemFont_Shadow_Large:SetFont(font, 15)
	SystemFont_Shadow_Large_Outline:SetFont(font, 15)
	SystemFont_Shadow_Med1:SetFont(font, 11 + adjSize)
	SystemFont_Shadow_Med1_Outline:SetFont(font, 11 + adjSize, "OUTLINE")
	SystemFont_Shadow_Med2:SetFont(font, 12 + adjSize)
	SystemFont_Shadow_Med3:SetFont(font, 13 + adjSize)
	SystemFont_Shadow_Outline_Huge2:SetFont(font, 22, "OUTLINE")
	SystemFont_Shadow_Huge1:SetFont(font, 20)
	SystemFont_Shadow_Huge3:SetFont(font, 25)
	SystemFont_Shadow_Small:SetFont(font, 10 + adjSize)
	SystemFont_Small:SetFont(font, 10 + adjSize)
	SystemFont_Small:SetShadowColor(0, 0, 0)
	SystemFont_Small:SetShadowOffset(1, -1)
	SystemFont_Tiny:SetFont(font, 9 + adjSize)
	SystemFont_Tiny:SetShadowColor(0, 0, 0)
	SystemFont_Tiny:SetShadowOffset(1, -1)
	Tooltip_Med:SetFont(font, 11 + adjSize)
	Tooltip_Med:SetShadowColor(0, 0, 0)
	Tooltip_Med:SetShadowOffset(1, -1)
	Tooltip_Small:SetFont(font, 9 + adjSize)
	Tooltip_Small:SetShadowColor(0, 0, 0)
	Tooltip_Small:SetShadowOffset(1, -1)
	
	if db.standard.changeYellow then
		local yellowFonts = {
			GameFontNormal,
			GameFontNormalSmall,
			GameFontNormalMed3,
			GameFontNormalLarge,
			GameFontNormalHuge,
			BossEmoteNormalHuge,
			NumberFontNormalRightYellow,
			NumberFontNormalYellow,
			NumberFontNormalLargeRightYellow,
			NumberFontNormalLargeYellow,
			QuestTitleFontBlackShadow,
			DialogButtonNormalText,
			AchievementPointsFont,
			AchievementPointsFontSmall,
			AchievementDateFont,
			FocusFontSmall
		}
		for k, font in pairs(yellowFonts) do
			font:SetTextColor(db.standard.yellowColor[1], db.standard.yellowColor[2], db.standard.yellowColor[3])
		end
	end
end

function Fonts:UpdateUIFonts()
	-- Font code from Fontifier/FreeUI
	local font = nibRealUI.font.standard
	local adjSize = db.standard.sizeadjust
	
	RaidWarningFrame.slot1:SetFont(font, 20 + adjSize, "OUTLINE")
	RaidWarningFrame.slot2:SetFont(font, 20 + adjSize, "OUTLINE")
	RaidBossEmoteFrame.slot1:SetFont(font, 20 + adjSize, "OUTLINE")
	RaidBossEmoteFrame.slot2:SetFont(font, 20 + adjSize, "OUTLINE")

	STANDARD_TEXT_FONT = font
	UNIT_NAME_FONT     = font
	if db.changeFCT then
		DAMAGE_TEXT_FONT = font
	end
	NAMEPLATE_FONT     = font
	
	UIErrorsFrame:SetFont(font, 12 + adjSize, "OUTLINE")
	UIErrorsFrame:SetShadowOffset(0, 0)

	HelpFrameKnowledgebaseNavBarHomeButtonText:SetFont(font, 12 + adjSize)

	GameTooltipHeaderText:SetFont(font, 11 + adjSize + 2, "OUTLINE")
	GameTooltipText:SetFont(font, 11 + adjSize, "OUTLINE")
	GameTooltipTextSmall:SetFont(font, 11 + adjSize - 2, "OUTLINE")
end

function Fonts:PLAYER_LOGIN()
	self:UpdateUIFonts2()
end

function nibRealUI:Font(isLSM, size)
	local db = nibRealUI.db.profile
	local size = size or "default"
	if size == "default" then
		if db.settings.fontStyle == 1 then
			if isLSM then
				return "pixel_small"
			else
				return nibRealUI.font.pixel1
			end
		else
			if isLSM then
				return "pixel_large"
			else
				return nibRealUI.font.pixel2
			end
		end

	elseif size == "small" then
		if db.settings.fontStyle == 1 then
			if isLSM then
				return "pixel_small"
			else
				return nibRealUI.font.pixel1
			end
		elseif db.settings.fontStyle == 2 then
			if isLSM then
				return "pixel_small"
			else
				return nibRealUI.font.pixel1
			end
		elseif db.settings.fontStyle == 3 then
			if isLSM then
				return "pixel_large"
			else
				return nibRealUI.font.pixel2
			end
		end

	elseif size == "large" then
		if isLSM then
			return "pixel_large"
		else
			return nibRealUI.font.pixel2
		end

	elseif size == "tiny" then
		if isLSM then
			return "pixel_tiny"
		else
			return nibRealUI.font.pixel1
		end
	end
end

function Fonts:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			changeFCT = true,
			standard = {
				sizeadjust = 1,
				changeYellow = true,
				yellowColor = {1, 0.55, 0}
			},
		}
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char
	
	self:SetEnabledState(true)
	nibRealUI:RegisterPlainOptions(MODNAME, GetOptions)
	
	nibRealUI.font.standard = nibRealUI:GetFont("standard")
	nibRealUI.font.pixel1 = nibRealUI:GetFont("small")
	nibRealUI.font.pixel2 = nibRealUI:GetFont("large")
	nibRealUI.font.pixelNumbers = nibRealUI:GetFont("numbers")
	nibRealUI.font.pixelCooldown = nibRealUI:GetFont("cooldown")

	nibRealUI.font.sizeAdjust = db.standard.sizeadjust

	RealUIFontSmall:SetFont(unpack(nibRealUI.font.pixel1))
	RealUIFontLarge:SetFont(unpack(nibRealUI.font.pixel2))
	RealUIFontPixel:SetFont(unpack(nibRealUI.font.pixel1))
	RealUIStandardFont10:SetFont(nibRealUI.font.standard, 10)
	
	self:UpdateUIFonts()
	
	self:RegisterEvent("PLAYER_LOGIN")
end