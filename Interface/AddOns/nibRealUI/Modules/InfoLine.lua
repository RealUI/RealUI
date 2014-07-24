local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")
local Tablet20 = LibStub("Tablet-2.0")

local MODNAME = "InfoLine"
local InfoLine = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
local StatDisplay

local _
local min = math.min
local max = math.max
local floor = math.floor
local abs = math.abs
local tonumber = tonumber
local tostring = tostring
local strform = string.format
local gsub = gsub
local strsub = strsub

local db, dbc, dbg, ndb, ndbc, ndbg

local LoggedIn
local NeedSpecUpdate = false

local ILFrames
local HighlightBar
local FontStringsLarge = {}
local TextureFrames = {}
local FramesCreated = false

local layoutSize = 1

local Icons = {
	[1] = {
		start1 = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Start1]], 			15},
		start2 = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Start2]], 			15},
		mail = 			{[[Interface\AddOns\nibRealUI\Media\InfoLine\Mail]], 			14},
		guild = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Guild]], 			9},
		friends = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Friends]],			8},
		durability = 	{[[Interface\AddOns\nibRealUI\Media\InfoLine\Durability]], 		8},
		bag = 			{[[Interface\AddOns\nibRealUI\Media\InfoLine\Bags]],			10},
		xp = 			{[[Interface\AddOns\nibRealUI\Media\InfoLine\XP]], 				11},
		rep = 			{[[Interface\AddOns\nibRealUI\Media\InfoLine\Rep]], 			11},
		meters = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Meters]], 			10},
		layout_dt =		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Layout_DT]], 		21},
		layout_h =		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Layout_H]], 		11},
		system = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\System]], 			9},
		currency = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Currency]], 		5},
	},
	[2] = {
		start1 = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Start1]], 			15},
		start2 = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Start2]], 			15},
		mail = 			{[[Interface\AddOns\nibRealUI\Media\InfoLine\Mail_HR]], 		15},
		guild = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Guild_HR]], 		9},
		friends = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Friends_HR]], 		9},
		durability = 	{[[Interface\AddOns\nibRealUI\Media\InfoLine\Durability_HR]], 	8},
		bag = 			{[[Interface\AddOns\nibRealUI\Media\InfoLine\Bags_HR]],			11},
		xp = 			{[[Interface\AddOns\nibRealUI\Media\InfoLine\XP_HR]], 			12},
		rep = 			{[[Interface\AddOns\nibRealUI\Media\InfoLine\Rep_HR]], 			12},
		meters = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Meters_HR]], 		11},
		layout_dt =		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Layout_DT_HR]], 	22},
		layout_h =		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Layout_H_HR]], 	12},
		system = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\System_HR]], 		10},
		currency = 		{[[Interface\AddOns\nibRealUI\Media\InfoLine\Currency]], 		5},
	},
}

local ElementHeight = {
	[1] = 9,
	[2] = 10,
}

local TextPadding = 1

local HighlightColor
local HighlightColorVals

local TextColorNormal
local TextColorNormalVals
local TextColorDisabledVals
local TextColorWhite
local TextColorTTHeader
local TextColorOrange1
local TextColorblue1
local TextColorBlue1

local CurrencyColors = {
	GOLD = {1, 0.95, 0.15},
	SILVER = {0.75, 0.75, 0.75},
	COPPER = {0.75, 0.45, 0.31}
}

local ClassLookup

local PlayerStatusValToStr = {
	[1] = CHAT_FLAG_AFK,
	[2] = CHAT_FLAG_DND,
}

local Elements = {
	start = 		{L["Start"]},
	mail =			{MAIL_LABEL},
	guild = 		{ACHIEVEMENTS_GUILD_TAB},
	friends = 		{QUICKBUTTON_NAME_FRIENDS},
	durability = 	{DURABILITY},
	bag = 			{INVTYPE_BAG},
	currency = 		{BONUS_ROLL_REWARD_CURRENCY},
	xprep = 		{L["XP/Rep"]},
	clock = 		{TIMEMANAGER_TITLE},
	pc = 			{L["SysInfo"]},
	specchanger = 	{L["Spec Changer"]},
	layoutchanger =	{L["Layout Changer"]},
	metertoggle = 	{L["Meter Toggle"]},
}

local Tablets = {
	guild = Tablet20,
	friends = Tablet20,
	currency = Tablet20,
	pc = Tablet20,
	spec = Tablet20,
	durability = Tablet20,
}

local HPName, CPName, JPName, VPName, BPCurr1Name, BPCurr2Name, BPCurr3Name, GoldName 
local CurrencyStartSet

local LootSpecIDs = {}
local LootSpecClass


----------------
-- Micro Menu --
----------------
local ddMenuFrame = CreateFrame("Frame", "RealUIStartDropDown", UIParent, "UIDropDownMenuTemplate")
local MicroMenu = {
	{text = "|cffffffffRealUI|r",
		isTitle = true,
		notCheckable = true
	},
	{text = L["RealUI Config"],
		func = function() nibRealUI:ShowConfigBar() end,
		notCheckable = true
	},
	{text = "Power Mode",
		notCheckable = true,
		hasArrow = true,
		menuList = {
			{
				text = "Economy",
				func = function() 
					print(L["PowerModeEconomy"])
					nibRealUI:SetPowerMode(2)
					nibRealUI:ReloadUIDialog()
				end,
				checked = function() return nibRealUI.db.profile.settings.powerMode == 2 end,
			},
			{
				text = "Normal",
				func = function()
					print(L["PowerModeNormal"])
					nibRealUI:SetPowerMode(1)
					nibRealUI:ReloadUIDialog()
				end,
				checked = function() return nibRealUI.db.profile.settings.powerMode == 1 end,
			},
			{
				text = "Turbo",
				func = function()
					print(L["PowerModeTurbo"])
					nibRealUI:SetPowerMode(3)
					nibRealUI:ReloadUIDialog()
				end,
				checked = function() return nibRealUI.db.profile.settings.powerMode == 3 end,
			},
		},
	},
	{text = "",
		notCheckable = true,
		disabled = true
	},
	{text = CHARACTER_BUTTON,
		func = function() ToggleCharacter("PaperDollFrame") end,
		notCheckable = true
	},
	{text = SPELLBOOK_ABILITIES_BUTTON,
		func = function() ToggleFrame(SpellBookFrame) end,
		notCheckable = true
	},
	{text = TALENTS_BUTTON,
		func = function() 
			if not PlayerTalentFrame then 
				TalentFrame_LoadUI()
			end 

			ShowUIPanel(PlayerTalentFrame)
		end,
		notCheckable = true
	},
	{text = ACHIEVEMENT_BUTTON,
		func = function() ToggleAchievementFrame() end,
		notCheckable = true
	},
	{text = QUESTLOG_BUTTON,
		func = function() ToggleFrame(QuestLogFrame) end,
		notCheckable = true
	},
	{text = MOUNTS_AND_PETS,
		func = function() TogglePetJournal() end,
		notCheckable = true
	},
	{text = SOCIAL_BUTTON,
		func = function() ToggleFriendsFrame(1) end,
		notCheckable = true
	},
	{text = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE,
		func = function() PVEFrame_ToggleFrame() end,
		notCheckable = true
	},
	{text = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP,
		func = function() TogglePVPUI() end,
		notCheckable = true
	},
	{text = ACHIEVEMENTS_GUILD_TAB,
		func = function() 
			if IsInGuild() then 
				if not GuildFrame then GuildFrame_LoadUI() end 
				GuildFrame_Toggle() 
			else 
				if not LookingForGuildFrame then LookingForGuildFrame_LoadUI() end 
				LookingForGuildFrame_Toggle() 
			end
		end,
		notCheckable = true
	},
	{text = RAID,
		func = function() ToggleFriendsFrame(4) end,
		notCheckable = true
	},
	{text = HELP_BUTTON,
		func = function() ToggleHelpFrame() end,
		notCheckable = true
	},	
	{text = ENCOUNTER_JOURNAL,
		func = function() ToggleEncounterJournal() end,
		notCheckable = true
	},	
	{text = LOOKING_FOR_RAID,
		func = function() ToggleRaidBrowser() end,
		notCheckable = true
	},
	{text = BLIZZARD_STORE,
		func = function() ToggleStoreUI() end,
		notCheckable = true,
		-- disabled = IsTrialAccount() or C_StorePublic.IsDisabledByParentalControls()
	}
}

-------------
-- Options --
-------------
local table_Sides = {
	"LEFT",
	"RIGHT"
}

local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Info Line",
		desc = "Information / Button display.",
		arg = MODNAME,
		childGroups = "tab",
		args = {
			header = {
				type = "header",
				name = "Info Line",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Information / Button display.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Info Line module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
					nibRealUI:ReloadUIDialog()
				end,
				order = 30,
			},
			position = {
				name = "Position/Size",
				type = "group",
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 50,
				args = {
					parent = {
						type = "group",
						name = "Parent",
						inline = true,
						order = 10,
						args = {
							xleft = {
								type = "input",
								name = "X Left",
								width = "half",
								order = 10,
								get = function(info) return tostring(db.position.xleft) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.position.xleft = value
									InfoLine:UpdatePositions()
								end,
							},
							xright = {
								type = "input",
								name = "X Right",
								width = "half",
								order = 20,
								get = function(info) return tostring(db.position.xright) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.position.xright = value
									InfoLine:UpdatePositions()
								end,
							},
							y = {
								type = "input",
								name = "Y",
								width = "half",
								order = 30,
								get = function(info) return tostring(db.position.y) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.position.y = value
									InfoLine:UpdatePositions()
									InfoLine:SetBackground()
								end,
							},
							xgap = {
								type = "input",
								name = "Padding",
								width = "half",
								order = 40,
								get = function(info) return tostring(db.position.xgap) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.position.xgap = value
									InfoLine:UpdatePositions()
								end,
							},
						},
					},
					text = {
						type = "group",
						name = "Text",
						inline = true,
						order = 20,
						args = {
							yoffset = {
								type = "input",
								name = "Y Offset",
								width = "half",
								get = function(info) return tostring(db.text.yoffset) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.text.yoffset = value
									InfoLine:UpdatePositions()
								end,
								order = 10,
							},
							tablets = {
								type = "group",
								inline = true,
								name = "Tablet Font Sizes",
								order = 20,
								args = {
									headersize = {
										type = "input",
										name = "Header",
										width = "half",
										get = function(info) return tostring(db.text.tablets.headersize) end,
										set = function(info, value)
											value = nibRealUI:ValidateOffset(value)
											db.text.tablets.headersize = value
											InfoLine:Refresh()
										end,
										order = 10,
									},
									columnsize = {
										type = "input",
										name = "Column Titles",
										width = "half",
										get = function(info) return tostring(db.text.tablets.columnsize) end,
										set = function(info, value)
											value = nibRealUI:ValidateOffset(value)
											db.text.tablets.columnsize = value
											InfoLine:Refresh()
										end,
										order = 20,
									},
									normalsize = {
										type = "input",
										name = "Normal",
										width = "half",
										get = function(info) return tostring(db.text.tablets.normalsize) end,
										set = function(info, value)
											value = nibRealUI:ValidateOffset(value)
											db.text.tablets.normalsize = value
											InfoLine:Refresh()
										end,
										order = 30,
									},
									hintsize = {
										type = "input",
										name = "Hint",
										width = "half",
										get = function(info) return tostring(db.text.tablets.hintsize) end,
										set = function(info, value)
											value = nibRealUI:ValidateOffset(value)
											db.text.tablets.hintsize = value
											InfoLine:Refresh()
										end,
										order = 40,
									},
								},
							},
						},
					},
				},
			},
			colors = {
				name = "Colors",
				type = "group",
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 60,
				args = {
					normal = {
						type = "color",
						name = "Normal",
						hasAlpha = false,
						get = function(info,r,g,b)
							return db.colors.normal[1], db.colors.normal[2], db.colors.normal[3]
						end,
						set = function(info,r,g,b)
							db.colors.normal[1] = r
							db.colors.normal[2] = g
							db.colors.normal[3] = b
							InfoLine:Refresh()
						end,
						order = 10,
					},
					sep1 = {
						type = "description",
						name = " ",
						order = 20,
					},
					highlight = {
						type = "color",
						name = "Highlight",
						hasAlpha = false,
						get = function(info,r,g,b)
							return db.colors.highlight[1], db.colors.highlight[2], db.colors.highlight[3]
						end,
						set = function(info,r,g,b)
							db.colors.highlight[1] = r
							db.colors.highlight[2] = g
							db.colors.highlight[3] = b
							InfoLine:Refresh()
						end,
						disabled = function()
							if db.colors.classcolorhighlight then return true else return false; end 
						end,
						order = 30,
					},
					classcolorhighlight = {
						type = "toggle",
						name = "Class Color Highlight",
						desc = "Use your Class Color for the highlight.",
						get = function() return db.colors.classcolorhighlight end,
						set = function(info, value) 
							db.colors.classcolorhighlight = value
							InfoLine:Refresh()
						end,
						order = 40,
					},
					sep2 = {
						type = "description",
						name = " ",
						order = 50,
					},
					disabled = {
						type = "color",
						name = "Disabled",
						hasAlpha = false,
						get = function(info,r,g,b)
							return db.colors.disabled[1], db.colors.disabled[2], db.colors.disabled[3]
						end,
						set = function(info,r,g,b)
							db.colors.disabled[1] = r
							db.colors.disabled[2] = g
							db.colors.disabled[3] = b
							InfoLine:Refresh()
						end,
						order = 60,
					},
					ttheader = {
						type = "color",
						name = "Tooltip Header 1",
						hasAlpha = false,
						get = function(info,r,g,b)
							return db.colors.ttheader[1], db.colors.ttheader[2], db.colors.ttheader[3]
						end,
						set = function(info,r,g,b)
							db.colors.ttheader[1] = r
							db.colors.ttheader[2] = g
							db.colors.ttheader[3] = b
							InfoLine:Refresh()
						end,
						order = 70,
					},
					orange1 = {
						type = "color",
						name = "Header 1",
						hasAlpha = false,
						get = function(info,r,g,b)
							return nibRealUI.media.colors.orange[1], nibRealUI.media.colors.orange[2], nibRealUI.media.colors.orange[3]
						end,
						set = function(info,r,g,b)
							nibRealUI.media.colors.orange[1] = r
							nibRealUI.media.colors.orange[2] = g
							nibRealUI.media.colors.orange[3] = b
							InfoLine:Refresh()
						end,
						order = 80,
					},
					blue1 = {
						type = "color",
						name = "Header 2",
						hasAlpha = false,
						get = function(info,r,g,b)
							return nibRealUI.media.colors.blue[1], nibRealUI.media.colors.blue[2], nibRealUI.media.colors.blue[3]
						end,
						set = function(info,r,g,b)
							nibRealUI.media.colors.blue[1] = r
							nibRealUI.media.colors.blue[2] = g
							nibRealUI.media.colors.blue[3] = b
							InfoLine:Refresh()
						end,
						order = 90,
					},
					blue1 = {
						type = "color",
						name = "Header 3",
						hasAlpha = false,
						get = function(info,r,g,b)
							return nibRealUI.media.colors.blue[1], nibRealUI.media.colors.blue[2], nibRealUI.media.colors.blue[3]
						end,
						set = function(info,r,g,b)
							nibRealUI.media.colors.blue[1] = r
							nibRealUI.media.colors.blue[2] = g
							nibRealUI.media.colors.blue[3] = b
							InfoLine:Refresh()
						end,
						order = 100,
					},
				},
			},
			other = {
				name = "Other",
				type = "group",
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 70,
				args = {
					icTips = {
						type = "toggle",
						name = "In Combat Tooltips",
						desc = "Show the tooltips in combat.",
						get = function() return db.other.icTips end,
						set = function(info, value) 
							db.other.icTips = value
							nibRealUI.InfoLineICTips = value 		-- Tablet-2.0 use
							InfoLine:Refresh()
						end,
						order = 10,
					},
					clock = {
						type = "group",
						name = "Clock",
						inline = true,
						order = 20,
						args = {
							clock24 = {
								type = "toggle",
								name = "24 hour clock",
								desc = "Show the time in 24 hour format.",
								get = function() return db.other.clock.hr24 end,
								set = function(info, value) 
									db.other.clock.hr24 = value
									InfoLine:Refresh()
								end,
								order = 10,
							},
							clocklocal = {
								type = "toggle",
								name = "Use local time",
								desc = "Show the time at your home.",
								get = function() return db.other.clock.uselocal end,
								set = function(info, value) 
									db.other.clock.uselocal = value
									InfoLine:Refresh()
								end,
								order = 20,
							},
						},
					},
					tablets = {
						type = "group",
						name = "Info Displays",
						inline = true,
						order = 30,
						args = {
							maxheight = {
								type = "input",
								name = "Max Height",
								desc = "Maximum height of the Info Displays. May require a UI reload (/rl) to take effect.",
								width = "half",
								get = function(info) return tostring(db.other.tablets.maxheight) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.other.tablets.maxheight = value
								end,
								order = 10,
							},
						},
					},
				},
			},
		},
	}
	end
	
	-- Create Elements options table
	local elementopts = {
		name = "Elements",
		type = "group",
		disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
		order = 40,
		args = {},
	}
	local elementordercnt = 10;	
	for k_e, v_e in pairs(Elements) do
		-- Create base options for Elements
		elementopts.args[k_e] = {
			type = "toggle",
			name = Elements[k_e][1],
			desc = "Enable the "..Elements[k_e][1].." element.",
			get = function() return db.elements[k_e] end,
			set = function(info, value) 
				db.elements[k_e] = value
				InfoLine:Refresh()
			end,
			order = elementordercnt,
		}
		elementordercnt = elementordercnt + 10
	end
	options.args.elements = elementopts
	
	return options
end
----

--------------------
-- Misc Functions --
--------------------
-- Create Copy Frame
local CopyFrame

local function CreateCopyFrame()
	local frame = CreateFrame("Frame", "RealUICopyFrame", UIParent)
	tinsert(UISpecialFrames, "RealUICopyFrame")
	
	frame:SetBackdrop({
		bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
		edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 3, right = 3, top = 5, bottom = 3 }
	})
	frame:SetBackdropColor(0,0,0,1)
	frame:SetWidth(400)
	frame:SetHeight(200)
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:Hide()
	frame:SetFrameStrata("DIALOG")
	CopyFrame = frame
	
	local scrollArea = CreateFrame("ScrollFrame", "RealUICopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	
	local editBox = CreateFrame("EditBox", nil, frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(350)
	editBox:SetHeight(170)
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
	CopyFrame.editBox = editBox
	
	scrollArea:SetScrollChild(editBox)
	
	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
end

-- Sort by Realm
local function RealmSort(a, b)
	if a.name == nibRealUI.realm then 
		return true
	elseif b.name == nibRealUI.realm then
		return false
	else
		return a.name < b.name
	end
end

-- Sort by Character
local function CharSort(a, b)
	if a[2] == b[2] then
		return a[12] < b[12]
	end
	return a[2] < b[2]
end

-- Gold string
local function convertMoney(money)
	money = money or 0
	local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
	if floor(gold) > 0 then
		return format("|cff%s%d|r", TextColorNormal, gold), "GOLD", gold, format("|cff%s%d|r", TextColorNormal, gold)
	elseif floor(silver) > 0 then
		return format("|cff%s%d|r", TextColorNormal, silver), "SILVER", silver, format("|cff%s%d|r|cffc7c7cfs|r", TextColorNormal, silver)
	else
		return format("|cff%s%d|r", TextColorNormal, copper), "COPPER", copper, format("|cff%s%d|r|cffeda55fc|r", TextColorNormal, copper)
	end
end

-- Get Realm time
local function RetrieveGameTime(...)
	local serTime, serAMPM
	local hour, min = GetGameTime()
	
	if ( min < 10 ) then min = strform("%s%s", "0", min) end
	
	if ... then
		-- 12 hour clock
		if hour >= 12 then 
			serAMPM = "PM"
			if hour > 12 then
				hour = hour - 12
			end
		else
			serAMPM = "AM"
			if hour == 0 then hour = 12 end
		end
		serTime = strform("%d:%s %s", hour, min, serAMPM)
	else
		serAMPM = ""
		serTime = strform("%d:%s", hour, min)
	end
	
	return serTime, serAMPM
end

-- Seconds to Time
local function ConvertSecondstoTime(value)
	local hours, minues, seconds
	hours = floor(value / 3600)
	minutes = floor((value - (hours * 3600)) / 60)
	seconds = floor(value - ((hours * 3600) + (minutes * 60)))

	if ( hours > 0 ) then
		return strform("%dh %dm", hours, minutes)
	elseif ( minutes > 0 ) then
		if minutes >= 10 then
			return strform("%dm", minutes)
		else
			return strform("%dm %ds", minutes, seconds)
		end
	else
		return strform("%ds", seconds)
	end
end

-- Text width
local TestStr = CreateFrame("Frame", nil, UIParent)
TestStr.text = TestStr:CreateFontString()
local function GetTextWidth(str, size)
	TestStr.text:SetFont(nibRealUI.font.standard, size)
	TestStr.text:SetText(str)
	return TestStr.text:GetWidth() + 4
end

-- Add blank line to Tablet
local function AddBlankTabLine(cat, ...)
	local blank = {"blank", true, "fakeChild", true, "noInherit", true}
	local cnt = ... or 1
	for i = 1, cnt do
		cat:AddLine(blank)
	end
end

-- Construct standard Header for tablets
local function MakeTabletHeader(col, size, indentation, justifyTable)
	local header = {}
	local colors = {}
	colors = nibRealUI.media.colors.orange
	
	for i = 1, #col do
		if ( i == 1 ) then
			header["text"] = col[i]
			header["justify"] = justifyTable[i]
			header["size"] = size
			header["textR"] = colors[1]
			header["textG"] = colors[2]
			header["textB"] = colors[3]
			header["indentation"] = indentation
		else
			header["text"..i] = col[i]
			header["justify"..i] = justifyTable[i]
			header["size"..i] = size
			header["text"..i.."R"] = colors[1]
			header["text"..i.."G"] = colors[2]
			header["text"..i.."B"] = colors[3]
			header["indentation"] = indentation
		end
	end
	return header
end

-- Element Width
local function UpdateElementWidth(e, ...)
	local extraWidth = 0
	if ... or e.hidden then
		e.curwidth = 0
		e:SetWidth(e.curwidth)
		InfoLine:UpdatePositions()
	else
		local OldWidth = e.curwidth
		if e.type == 1 then
			e.curwidth = db.position.xgap + e.iconwidth + db.position.xgap
		elseif e.type == 2 then
			e.curwidth = db.position.xgap + (ceil(e.text:GetWidth() / TextPadding) * TextPadding) + db.position.xgap
		elseif e.type == 3 then
			e.curwidth = db.position.xgap + e.iconwidth + extraWidth + (ceil(e.text:GetWidth() / TextPadding) * TextPadding) + db.position.xgap
		elseif e.type == 4 then
			extraWidth = 4
			e.curwidth = db.position.xgap + e.text1:GetWidth()+ extraWidth  + e.iconwidth + extraWidth + e.text2:GetWidth() + db.position.xgap
			e.text1:ClearAllPoints()
			e.text1:SetPoint("BOTTOMLEFT", e, "BOTTOMLEFT", db.position.xgap, db.position.yoff + db.text.yoffset + 0.5)
			e.icon:ClearAllPoints()
			e.icon:SetPoint("BOTTOMLEFT", e, "BOTTOMLEFT", db.position.xgap + e.text1:GetWidth() + 2, db.position.yoff)
			e.text2:ClearAllPoints()
			e.text2:SetPoint("BOTTOMLEFT", e, "BOTTOMLEFT", db.position.xgap + e.text1:GetWidth() + 2 + e.iconwidth + 6, db.position.yoff + db.text.yoffset + 0.5)
		end
		-- if e.side == "LEFT" then e.curwidth = e.curwidth - 5 else e.curwidth = e.curwidth - 2 end
		if e.type == 3 then e.curwidth = e.curwidth - 5 else e.curwidth = e.curwidth - 2 end
		if e.type == 2 then e.curwidth = e.curwidth - 1 end
		if e.tag == "currency" then e.curwidth = e.curwidth + 5 end
		if e.curwidth ~= OldWidth then
			e:SetWidth(e.curwidth)
			InfoLine:UpdatePositions()
		end
	end
end

-- Highlight Bar
local function SetHighlightPosition(e)
	HighlightBar:ClearAllPoints()
	HighlightBar:SetPoint("BOTTOMLEFT", e, "BOTTOMLEFT", 0, -1)
	HighlightBar:SetWidth(e.curwidth)
end

------------
-- GRAPHS --
------------

local Graphs = {}
local GraphHeight = 20	-- multipe of 2
local GraphLineWidth = 3
local GraphColor2 = {0.3, 0.3, 0.3, 0.2}
local GraphColor3 = {0.5, 0.5, 0.5, 0.75}

-- Create Graph
local function CreateGraph(id, maxVal, numVals, parentFrame)
	if Graphs[id] then return end
	
	-- Create Graph frame
	Graphs[id] = CreateFrame("Frame", nil, UIParent)
	Graphs[id].parentFrame = parentFrame
	Graphs[id]:SetHeight(GraphHeight + 1)
	
	Graphs[id].gridBot = CreateFrame("Frame", nil, Graphs[id])
	Graphs[id].gridBot:SetHeight(1)
	Graphs[id].gridBot:SetPoint("BOTTOMLEFT", Graphs[id], 0, 0)
	Graphs[id].gridBot:SetPoint("BOTTOMRIGHT", Graphs[id], 0, 0)
	Graphs[id].gridBot.bg = Graphs[id].gridBot:CreateTexture()
	Graphs[id].gridBot.bg:SetAllPoints()
	Graphs[id].gridBot.bg:SetTexture(GraphColor2[1], GraphColor2[2], GraphColor2[3], GraphColor2[4])
	
	Graphs[id].topLines = {}
	Graphs[id].gapLines = {}
	for c = 1, numVals do
		Graphs[id].topLines[c] = CreateFrame("Frame", nil, Graphs[id])
		Graphs[id].topLines[c]:SetPoint("BOTTOMLEFT", Graphs[id], "BOTTOMLEFT", (c - 1) * GraphLineWidth, 0)
		Graphs[id].topLines[c]:SetHeight(GraphHeight - 1)
		Graphs[id].topLines[c]:SetWidth(GraphLineWidth - 1)
		
		Graphs[id].topLines[c].point = Graphs[id].topLines[c]:CreateTexture()
		Graphs[id].topLines[c].point:SetPoint("BOTTOM", Graphs[id].topLines[c], "BOTTOM", 0, 0)
		Graphs[id].topLines[c].point:SetHeight(1)
		Graphs[id].topLines[c].point:SetWidth(GraphLineWidth - 1)
		Graphs[id].topLines[c].point:SetTexture(1, 0.15, 0.15)
		
		Graphs[id].gapLines[c] = {}
		for r = 1, (GraphHeight / 2) + 1 do
			Graphs[id].gapLines[c][r] = Graphs[id].topLines[c]:CreateTexture()
			Graphs[id].gapLines[c][r]:SetPoint("BOTTOM", Graphs[id].topLines[c], "BOTTOM", 0, (r - 1) * 2)
			Graphs[id].gapLines[c][r]:SetHeight(1)
			Graphs[id].gapLines[c][r]:SetWidth(GraphLineWidth - 1)
			Graphs[id].gapLines[c][r]:SetTexture(0, 0, 0, 0)
		end
	end
	
	-- Fill out Graph info
	Graphs[id].max = maxVal
	Graphs[id].numVals = numVals
	Graphs[id].vals = {}
	for i = 1, numVals do
		Graphs[id].vals[i] = 0
	end
end

-- Update Graph
local function UpdateGraph(id, vals, ...)
	if not Graphs[id] then return end
	if not Graphs[id].enabled then return end
	
	numVals = Graphs[id].numVals
	
	-- Set new Min/Max
	newMax = ...
	if newMax then
		Graphs[id].max = newMax
	end
	
	-- Update Vals
	if Graphs[id].shown then
		for c = 1, numVals do
			Graphs[id].vals[c] = min(vals[c] or 0, Graphs[id].max)
			Graphs[id].vals[c] = max(Graphs[id].vals[c], 0)
			
			local topPoint = max(floor(Graphs[id].vals[c] * ((GraphHeight - 1) / Graphs[id].max) - 1), 0) + 2
			Graphs[id].topLines[c].point:SetPoint("BOTTOM", Graphs[id].topLines[c], "BOTTOM", 0, topPoint)
			
			for g = 1, (GraphHeight / 2) do
				Graphs[id].gapLines[c][g]:SetTexture(0, 0, 0, 0)
			end
			if topPoint > 1 then
				for r = 1, floor((topPoint / 2)) do
					if Graphs[id].gapLines[c][r] then
						Graphs[id].gapLines[c][r]:SetTexture(GraphColor3[1], GraphColor3[2], GraphColor3[3], GraphColor3[4])
					end
				end
			end
		end
	end
end

-- Show Graph
local function ShowGraph(id, parent, relPoint, point, x, y, parentFrame)
	Graphs[id]:SetParent(parent)
	Graphs[id]:SetFrameStrata("TOOLTIP")
	Graphs[id]:SetFrameLevel(20)
	Graphs[id]:SetPoint(relPoint, parent, point, x, y)
	Graphs[id]:SetWidth(Graphs[id].numVals * 3)
	
	Graphs[id]:Show()
	Graphs[id].shown = true
end

-- Hide Graph
local function HideGraph(id)
	Graphs[id]:Hide()
	Graphs[id].shown = false
end

-- Hide non-parented Graphs
local function HideOtherGraphs(parentFrame)
	for k, v in pairs(Graphs) do
		if (Graphs[k].parentFrame ~= parentFrame) and Graphs[k].shown then
			HideGraph(k)
		end
	end
end

----------
-- Text --
----------
---- XP/Rep
local xp, lvl, xpmax, restxp
local rep, replvlmax, repStandingID, repstatus, watchedFaction
function InfoLine_XR_OnLeave(self)
	if ( (repstatus == "---") and (UnitLevel("player") == MAX_PLAYER_LEVEL) ) then
		-- Max Level and no Rep tracked, hide display
		self:SetAlpha(0)
	end
	if GameTooltip:IsShown() then GameTooltip:Hide() end
end

function InfoLine_XR_OnEnter(self)
	self:SetAlpha(1)

	GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
	
	if UnitLevel("player") < MAX_PLAYER_LEVEL then
		GameTooltip:AddLine(strform("|cff%s%s|r", TextColorTTHeader, XP.." / "..REPUTATION))
		GameTooltip:AddLine(" ")
		
		if IsXPUserDisabled() then
			GameTooltip:AddLine(strform("|cff%s%s|r", TextColorOrange1, COMBAT_XP_GAIN.." ("..VIDEO_OPTIONS_DISABLED..")"))
		else
			GameTooltip:AddLine(strform("|cff%s%s|r", TextColorOrange1, COMBAT_XP_GAIN))
		end
		GameTooltip:AddDoubleLine(L["Current"], nibRealUI:ReadableNumber(xp), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
		GameTooltip:AddDoubleLine(L["Remaining"], nibRealUI:ReadableNumber(xpmax - xp), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
		if not restxp then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26, "0", 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
		else
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26, nibRealUI:ReadableNumber(restxp), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(strform("|cff%s%s|r", TextColorOrange1, REPUTATION))
	else
		GameTooltip:AddLine(strform("|cff%s%s|r", TextColorOrange1, REPUTATION))
		GameTooltip:AddLine(" ")
	end
	local repStandingColor = {0.9, 0.9, 0.9}
	if (repstatus ~= "---") then
		repStandingColor = {FACTION_BAR_COLORS[repStandingID].r, FACTION_BAR_COLORS[repStandingID].g, FACTION_BAR_COLORS[repStandingID].b}
	end
	GameTooltip:AddDoubleLine(FACTION, watchedFaction, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
	GameTooltip:AddDoubleLine(STATUS, repstatus, 0.9, 0.9, 0.9, repStandingColor[1], repStandingColor[2], repStandingColor[3])
	GameTooltip:AddDoubleLine(L["Current"], nibRealUI:ReadableNumber(rep), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
	GameTooltip:AddDoubleLine(L["Remaining"], nibRealUI:ReadableNumber(replvlmax - rep), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
	
	-- Hint
	if (UnitLevel("player") < MAX_PLAYER_LEVEL) and not(IsXPUserDisabled()) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(strform("|cff00ff00%s|r", L["<Click> to switch between"]))
		GameTooltip:AddLine(strform("|cff00ff00%s|r", "    "..L["XP and Rep display."]))
	end
	
	GameTooltip:Show()
end

function InfoLine_XR_Update(self)
	-- XP Data
	xp = UnitXP("player")
	lvl = UnitLevel("player")
	xpmax = UnitXPMax("player")
	if xpmax == 0 then return end
	restxp = GetXPExhaustion() or 0
	local percentXP = (xp/xpmax)*100
	if (xp <= 0) or (xpmax <= 0) then
		percentXP = 0
	else
		percentXP = (xp/xpmax)*100
	end
	local percentXPStr = tostring(percentXP)
	local percentRestXPStr = tostring(floor((restxp / xpmax) * 100))
	
	-- Currency
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].level = lvl
	
	-- Rep Data
	local CurWatchedFaction, replvl, repmin, repmax, repvalue = GetWatchedFactionInfo()
	watchedFaction = CurWatchedFaction
	rep = repvalue - repmin
	replvlmax = repmax - repmin
	repstatus = getglobal("FACTION_STANDING_LABEL"..replvl)
	repStandingID = replvl
	
 	local percentRep
	if (replvlmax <= 0) then
		percentRep = 0
	else
		percentRep = (rep/(replvlmax))*100
	end
	local percentRepStr = tostring(percentRep)
	
	if not watchedFaction then
		watchedFaction = L["Faction not set"]
		repstatus = "---"
		rep = 0
		replvlmax = 0
		percentRepStr = "---"
	end
	
	-- Set Info Text
	local XRSuffix, XRStr, XRPer, XRLen, XRRested
	local HideMe = false
	if ( (dbc.xrstate == "x") and not(UnitLevel("player") == MAX_PLAYER_LEVEL) and not(IsXPUserDisabled()) ) then
		XRSuffix, XRStr, XRPer = "XP:", percentXPStr, percentXP
		if restxp > 0 then
			XRRested = percentRestXPStr
		else
			XRRested = ""
		end
	else
		if ( (repstatus == "---") and (UnitLevel("player") == MAX_PLAYER_LEVEL) ) then
			-- Max Level and no Rep tracked, hide display
			HideMe = true
		end
		XRSuffix, XRStr, XRPer, XRRested = "Rep:", percentRepStr, percentRep, ""
	end
	if XRPer < 10 then XRLen = 3 else XRLen = 4 end
	if XRSuffix == "XP:" then
		if XRRested ~= "" then
			self.text:SetFormattedText("|cff%s %s÷ [%s÷]|r", TextColorNormal, strsub(XRStr, 1, XRLen), XRRested)
		else
			self.text:SetFormattedText("|cff%s %s÷|r", TextColorNormal, strsub(XRStr, 1, XRLen))
		end
		self.icon:SetTexture(Icons[layoutSize].xp[1])
	else
		self.text:SetFormattedText("|cff%s %s÷|r", TextColorNormal, strsub(XRStr, 1, XRLen))
		self.icon:SetTexture(Icons[layoutSize].rep[1])
	end
	
	self.hidden = HideMe
	if HideMe then
		self.text:SetText("")
		UpdateElementWidth(self)
	else
		UpdateElementWidth(self)
	end
end

function InfoLine_XR_OnMouseDown(self)
	dbc.xrstate = (dbc.xrstate == "x") and "r" or "x"
	if UnitLevel("player") == MAX_PLAYER_LEVEL and not InCombatLockdown() then
		ToggleCharacter("ReputationFrame")
	end
	InfoLine_XR_Update(self)
end

---- Currency
local CurrencyTabletData = {}
local CurrencyTabletDataRK = {}
local CurrencyTabletDataStart = {}
local CurrencyTabletDataCurrent = {}

local NumCurrencies = 8

local function ShortenDynamicCurrencyName(name)
	local IgnoreLocales = {
		koKR = true,
		zhCN = true,
		zhTW = true,
	}
	if IgnoreLocales[nibRealUI.locale] then
		return name
	else
		return name ~= nil and string.gsub(name, "%l*%s*%p*", "") or "-"
	end
end

local function Currency_GetDifference(startVal, endVal, isGold)
	startVal = startVal or 0
	endVal = endVal or 0
	local newVal = endVal - startVal
	local newPrefix, newSuffix = "", ""
	
	if newVal > 0 then
		newPrefix = "|cff00c000+"
	elseif newVal < 0 then
		newPrefix = "|cffe00000-"
	else
		newPrefix = "|cff4D4D4D"
	end
	
	if isGold and newVal ~= 0 then
		local gold, silver, copper = abs(newVal / 10000), abs(mod(newVal / 100, 100)), abs(mod(newVal, 100))
		if floor(gold) > 0 then
			newVal = floor(gold)
			newSuffix = "|cffffd700g|r"
		elseif floor(silver) > 0 then
			newVal = floor(silver)
			newSuffix = "|cffc7c7cfs|r"
		else
			newVal = floor(copper)
			newSuffix = "|cffeda55fc|r"
		end
	else
		newSuffix = "|r"
	end
	
	return string.format(newPrefix.."%s"..newSuffix, newVal ~= 0 and abs(newVal) or "~")
end

local function Currency_TabletClickFunc(realm, faction, name)
	if not name then return end
	if realm == nibRealUI.realm and faction == nibRealUI.faction and name == nibRealUI.name then return end
	if IsAltKeyDown() then
		dbg.currency[realm][faction][name] = nil
		ILFrames.currency.needrefreshed = true
		ILFrames.currency.elapsed = 1
	end
end

local RealmSection, MaxWidth = {}, {}
local FactionList = {nibRealUI.faction, nibRealUI:OtherFaction(nibRealUI.faction)}
local function Currency_UpdateTablet()
	if not CurrencyTabletData then return end
	
	local FactionList = {nibRealUI.faction, nibRealUI:OtherFaction(nibRealUI.faction)}
	local HasMaxLvl, OnlyMe = false, true
	
	-- Get max col widths
	MaxWidth = {[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0, [7] = 0, [8] = 0, [9] = 0, [10] = 0, [11] = 0, [12] = 0}
	for kr, vr in pairs(CurrencyTabletData) do
		local realm = kr
		if (CurrencyTabletData[realm]["Alliance"] and (#CurrencyTabletData[realm]["Alliance"] > 0)) or
			(CurrencyTabletData[realm]["Horde"] and (#CurrencyTabletData[realm]["Horde"] > 0)) then
			
			local TotalGold = 0
			for kf, vf in ipairs(FactionList) do
				if CurrencyTabletData[realm][vf] and #CurrencyTabletData[realm][vf] > 0 then
					for kn, vn in pairs(CurrencyTabletData[realm][vf]) do
						if vn[2] == MAX_PLAYER_LEVEL then HasMaxLvl = true end
						TotalGold = TotalGold + vn[3]
						MaxWidth[3] = max(MaxWidth[3], GetTextWidth(convertMoney(vn[3]), db.text.tablets.normalsize))
						for i = 4, (NumCurrencies + 4) do
							MaxWidth[i] = max(MaxWidth[i], GetTextWidth(vn[i], db.text.tablets.normalsize))
						end
					end
				end
			end
			MaxWidth[3] = max(MaxWidth[3], GetTextWidth(convertMoney(TotalGold), db.text.tablets.normalsize))
		end
	end
	MaxWidth[2] = 20 	-- Level
	
	wipe(RealmSection)
	local line = {}
	for kr, vr in ipairs(CurrencyTabletDataRK) do
		local realm = CurrencyTabletDataRK[kr].name
		if 	(CurrencyTabletData[realm]["Alliance"] and (#CurrencyTabletData[realm]["Alliance"] > 0)) or
			(CurrencyTabletData[realm]["Horde"] and (#CurrencyTabletData[realm]["Horde"] > 0)) then
			
			-- Realm Category
			RealmSection[realm] = {}
			RealmSection[realm].cat = Tablets.currency:AddCategory()
			if kr > 1 then
				AddBlankTabLine(RealmSection[realm].cat, 4)
			end
			RealmSection[realm].cat:AddLine("text", realm, "size", db.text.tablets.headersize + nibRealUI.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)
			AddBlankTabLine(RealmSection[realm].cat, 2)

			-- Characters
			local charCols = {
				NAME,
				LEVEL_ABBR,
				GoldName,
				L["Justice Points"],
				L["Valor Points"],
				L["Honor Points"],
				L["Conquest Points"],
				"BP1",
				"BP2",
				"BP3",
				L["Updated"]
			}
			RealmSection[realm].charCat = Tablets.currency:AddCategory("columns", #charCols)
			local charHeader = MakeTabletHeader(charCols, db.text.tablets.columnsize + nibRealUI.font.sizeAdjust, 12, {"LEFT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT"})
			RealmSection[realm].charCat:AddLine(charHeader)
			AddBlankTabLine(RealmSection[realm].charCat, 1)
			
			local TotalGold, TotalRealmChars = 0, 0
			for kf, vf in ipairs(FactionList) do
				if CurrencyTabletData[realm][vf] and #CurrencyTabletData[realm][vf] > 0 then
					sort(CurrencyTabletData[realm][vf], CharSort)
					for kn, vn in pairs(CurrencyTabletData[realm][vf]) do
						TotalRealmChars = TotalRealmChars + 1
						local currentName = vn[NumCurrencies + 4]
						local isPlayer = ((realm == nibRealUI.realm) and (vf == nibRealUI.faction) and (currentName == nibRealUI.name))
						if not isPlayer then OnlyMe = false end
						local NormColor = isPlayer and 1 or 0.7
						local ZeroShade = isPlayer and 0.1 or 0.4
						
						wipe(line)
						for i = 1, #charCols do
							if (i == 1) then
								line["indentation"] = 12.5
								if isPlayer then
									line["hasCheck"] = true
									line["checked"] = true
									line["isRadio"] = true
									line["indentation"] = 0
								end
								line["text"] = vn[i]
								line["justify"] = "LEFT"
								line["func"] = function() Currency_TabletClickFunc(realm, vf, currentName) end
								line["size"] = db.text.tablets.normalsize
								line["customwidth"] = MaxWidth[NumCurrencies + 4]
							elseif (i == 2) or (i == (NumCurrencies + 3)) then
								line["text"..i] = vn[i]
								line["justify"..i] = "RIGHT"
								line["text"..i.."R"] = NormColor
								line["text"..i.."G"] = NormColor
								line["text"..i.."B"] = NormColor
								line["customwidth"..i] = MaxWidth[i]
								line["indentation"..i] = 12.5
							elseif (i == 3) then
								TotalGold = TotalGold + vn[i]
								line["text"..i] = select(4, convertMoney(vn[i]))
								line["justify"..i] = "RIGHT"
								line["customwidth"..i] = MaxWidth[i]
								line["indentation"..i] = 12.5
								
							else
								local curSuffix = ""
								-- Backpack Currency suffix
								if (i >= 8) and (i <= 10) then
									if dbg.currency[realm][vf][currentName].bpCurrencies[i - 7].name then
										curSuffix = " "..ShortenDynamicCurrencyName(dbg.currency[realm][vf][currentName].bpCurrencies[i - 7].name)
									end
								end
								line["text"..i] = (vn[i] or "0")..curSuffix
								line["justify"..i] = "RIGHT"
								line["customwidth"..i] = MaxWidth[i]
								line["indentation"..i] = 12.5
								if vn[i + (NumCurrencies + 1)] == 0 then
									line["text"..i.."R"] = NormColor - ZeroShade
									line["text"..i.."G"] = NormColor - ZeroShade
									line["text"..i.."B"] = NormColor - ZeroShade
								else
									line["text"..i.."R"] = NormColor
									line["text"..i.."G"] = NormColor
									line["text"..i.."B"] = NormColor
								end
								
							end
						end
						RealmSection[realm].charCat:AddLine(line)
						
						-- Start values
						if isPlayer then
							NormColor = 0.5
							wipe(line)
							for i = 1, #charCols do
								if i == 1 then
									line["indentation"] = 12
									line["text"] = ""
									line["justify"] = "LEFT"
									line["size"] = db.text.tablets.columnsize + nibRealUI.font.sizeAdjust
									line["customwidth"] = MaxWidth[(NumCurrencies + 4)]
								elseif i == 2 or i == (NumCurrencies + 3) then
									line["text"..i] = ""
									line["justify"..i] = "RIGHT"
									line["size"..i] = db.text.tablets.columnsize + nibRealUI.font.sizeAdjust
									line["customwidth"..i] = MaxWidth[i]
									line["indentation"..i] = 12
								elseif i == 3 then
									line["text"..i] = Currency_GetDifference(CurrencyTabletDataStart[3], CurrencyTabletDataCurrent[3], true)
									line["justify"..i] = "RIGHT"
									line["size"..i] = db.text.tablets.columnsize + nibRealUI.font.sizeAdjust
									line["customwidth"..i] = MaxWidth[3]
									line["indentation"..i] = 12
								else
									line["text"..i] = Currency_GetDifference(CurrencyTabletDataStart[i + (NumCurrencies + 1)], CurrencyTabletDataCurrent[i + (NumCurrencies + 1)], false)
									line["justify"..i] = "RIGHT"
									line["size"..i] = db.text.tablets.columnsize + nibRealUI.font.sizeAdjust
									line["customwidth"..i] = MaxWidth[i]
									line["indentation"..i] = 12
								end
							end
							RealmSection[realm].charCat:AddLine(line)
							AddBlankTabLine(RealmSection[realm].charCat, 4)
						end
					end
					AddBlankTabLine(RealmSection[realm].charCat, 4)
				end
			end
			
			-- Realm Total
			if TotalRealmChars > 1 then
				RealmSection[realm].charCat:AddLine(
					"text3", convertMoney(TotalGold),
					"justify3", "RIGHT",
					"customwidth3", MaxWidth[3],
					"size3", db.text.tablets.columnsize + nibRealUI.font.sizeAdjust,
					"indentation3", 12
				)
				AddBlankTabLine(RealmSection[realm].charCat, 4)
			end
		end
	end
	
	-- Hint
	local hint
	if OnlyMe then
		hint = L["<Click> to switch currency displayed."]
	else
		if HasMaxLvl then
			hint = L["<Click> to switch currency displayed."].."\n"..L["<Alt+Click> to erase highlighted character data."].."\n"..L["<Shift+Click> to reset weekly caps."]
		else
			hint = L["<Click> to switch currency displayed."].."\n"..L["<Alt+Click> to erase highlighted character data."]
		end
	end
	local hintCat = Tablets.currency:AddCategory()
	AddBlankTabLine(hintCat, 10)
	hintCat:AddLine(
		"text", hint,
		"textR", 0,
		"textG", 1,
		"textB", 0,
		"wrap", true
	)
	if not OnlyMe and HasMaxLvl then
		AddBlankTabLine(hintCat, 2)
		hintCat:AddLine(
			"text", L["Note: Weekly caps will reset upon loading currency data"].."\n  "..L["on a character whose weekly caps have reset."],
			"size", db.text.tablets.hintsize + nibRealUI.font.sizeAdjust,
			"textR", 0.7,
			"textG", 0.7,
			"textB", 0.7,
			"wrap", true
		)
	end
	AddBlankTabLine(hintCat, 1)
	hintCat:AddLine(
		"text", L["To track additional currencies, use the Currency tab in the Player Frame and set desired Currency to 'Show On Backpack'"],
		"textR", 0,
		"textG", 1,
		"textB", 0,
		"wrap", true
	)
end

local function Currency_ResetWeeklyValues()
	for kr, vr in pairs(dbg.currency) do
		if vr then
			for kf, vf in pairs(dbg.currency[kr]) do
				if vf then
					for kn, vn in pairs(dbg.currency[kr][kf]) do
						if vn then
							dbg.currency[kr][kf][kn].vpw = 0
							dbg.currency[kr][kf][kn].cpw = 0
						end
					end
				end
			end
		end
	end
end

local function Currency_GetWeeklyValues()
	local Name, earnedTotal, earnedThisWeek, weeklyMax, IsDiscovered
	local valorTotal, valorThisWeek, valorWeeklyMax, conquestTotal, conquestThisWeek, conquestWeeklyMax = 0,0,0,0,0,0
	
	-- Valor
	Name, earnedTotal, _, earnedThisWeek, weeklyMax, _, IsDiscovered = GetCurrencyInfo(396)
	if Name and IsDiscovered then
		valorTotal = earnedTotal or 0
		valorThisWeek = earnedThisWeek or 0
		valorWeeklyMax = weeklyMax/100 or 0
	end
	
	-- Conquest
	Name, earnedTotal, _, earnedThisWeek, weeklyMax, _, IsDiscovered = GetCurrencyInfo(390)
	if Name and IsDiscovered then
		conquestTotal = earnedTotal or 0
		conquestThisWeek = earnedThisWeek or 0
		conquestWeeklyMax = weeklyMax or 0
	end
	
	return valorTotal, valorThisWeek, valorWeeklyMax, conquestTotal, conquestThisWeek, conquestWeeklyMax
end

local function Currency_GetVals()
	local curr = {}
	curr[HPName] = 0	
	curr[CPName] = 0
	curr[JPName] = 0
	curr[VPName] = 0
	-- Try Dynamics Currency Start
	if(BPCurr1Name ~= nil) then
		curr[BPCurr1Name] = 0
	end
	if(BPCurr2Name ~= nil) then
		curr[BPCurr2Name] = 0
	end
	if(BPCurr3Name ~= nil) then
		curr[BPCurr3Name] = 0
	end
	-- Try Dynamics Currency End
	
	local currencySize = GetCurrencyListSize()
	for i = 1, currencySize do
		local name, isHeader, _, _, _, count = GetCurrencyListInfo(i)
		if curr[name] and (not isHeader) then
			curr[name] = count or 0
		end
	end
	
	return curr
end

local function Currency_Update(self)
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].class = nibRealUI.class
	
	local money = GetMoney()
	local currVals = Currency_GetVals()
	local valorTotal, valorThisWeek, valorWeeklyMax, conquestTotal, conquestThisWeek, conquestWeeklyMax = Currency_GetWeeklyValues()
	
	local curDate = date("%d/%m")
	if strsub(curDate, 1, 1) == "0" then
		curDate = strsub(curDate, 2)
	end
	
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].gold = money or 0
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].updated = curDate
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].jp = currVals[JPName] or 0
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].vp = currVals[VPName] or 0
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].hp = currVals[HPName] or 0
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].cp = currVals[CPName] or 0
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[1].amnt = currVals[BPCurr1Name] or 0
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[2].amnt = currVals[BPCurr2Name] or 0
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[3].amnt = currVals[BPCurr3Name] or 0
	
	if self.hasshown or self.initialized then
		local oldVPW = dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].vpw
		local oldCPW = dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].cpw
		dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].vpw = valorThisWeek
		dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].cpw = conquestThisWeek
	
		if (valorThisWeek < oldVPW) or (conquestThisWeek < oldCPW) then
			-- Weekly reset
			Currency_ResetWeeklyValues()
		end
	
		-- Quick Current reference list
		CurrencyTabletDataCurrent = {
			"",
			"",
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].gold,
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].jp,
			"",
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].hp,
			"",
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[1].amnt,
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[2].amnt,
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[3].amnt,
			"",
			-- Start session values
			nil,
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].jp,
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].vp,
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].hp,
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].cp,
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[1].amnt,
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[2].amnt,
			dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[3].amnt,
		}
		
		-- Start Session
		if not CurrencyStartSet then
			CurrencyTabletDataStart = CurrencyTabletDataCurrent
			CurrencyStartSet = true
		end
	end
	
	-- Fill out columns
	wipe(CurrencyTabletData)
	wipe(CurrencyTabletDataRK)
	local rCnt = 0
	for kr, vr in pairs(dbg.currency) do
		rCnt = rCnt + 1
		CurrencyTabletData[kr] = {}
		CurrencyTabletDataRK[rCnt] = {name = kr}
		
		if vr then
			for kf, vf in pairs(dbg.currency[kr]) do
				CurrencyTabletData[kr][kf] = {}
				
				if vf then
					for kn, vn in pairs(dbg.currency[kr][kf]) do
						if vn then
							local vpStr = tostring(dbg.currency[kr][kf][kn].vp)
							local cpStr = tostring(dbg.currency[kr][kf][kn].cp)
							if dbg.currency[kr][kf][kn].level == MAX_PLAYER_LEVEL then
								vpStr = vpStr.." ("..tostring(dbg.currency[kr][kf][kn].vpw or 0).."/"..valorWeeklyMax..")"
								cpStr = cpStr.." ("..tostring(dbg.currency[kr][kf][kn].cpw or 0).."/"..conquestWeeklyMax..")"
							end
							
							local classColor = nibRealUI:GetClassColor(dbg.currency[kr][kf][kn].class)
							local nameStr = strform("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, kn)
							
							if not dbg.currency[kr][kf][kn].bpCurrencies then
								dbg.currency[kr][kf][kn].bpCurrencies = {
									[1] = {amnt = 0, name = nil},
									[2] = {amnt = 0, name = nil},
									[3] = {amnt = 0, name = nil},
								}
							end

							tinsert(CurrencyTabletData[kr][kf], {
								nameStr,
								dbg.currency[kr][kf][kn].level,
								dbg.currency[kr][kf][kn].gold,
								dbg.currency[kr][kf][kn].jp,
								vpStr,
								dbg.currency[kr][kf][kn].hp,
								cpStr,
								dbg.currency[kr][kf][kn].bpCurrencies[1].amnt,
								dbg.currency[kr][kf][kn].bpCurrencies[2].amnt,
								dbg.currency[kr][kf][kn].bpCurrencies[3].amnt,
								dbg.currency[kr][kf][kn].updated,
								kn,
								dbg.currency[kr][kf][kn].jp,
								dbg.currency[kr][kf][kn].vp,
								dbg.currency[kr][kf][kn].hp,
								dbg.currency[kr][kf][kn].cp
							})
						end
						
					end
				end
			end
		end
	end
	
	-- Refresh tablet
	if Tablets.currency:IsRegistered(self) then
		if Tablet20Frame:IsShown() then
			Tablets.currency:Refresh(self)
		end
	end
	
	-- Info Text
	local function CurrencyDisplayText(val, abrv)
		return tostring(val or 0) .. " " .. abrv
	end

	local CurText, curCurrency, rawValue
	if dbc.currencystate == 1 then
		CurText, curCurrency, rawValue = convertMoney(money)
		if not(rawValue < 100000) then
			CurText = nibRealUI:ReadableNumber(rawValue, 1)
		end
	elseif dbc.currencystate == 2 then
		CurText = CurrencyDisplayText(dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].jp, "JP")
	elseif dbc.currencystate == 3 then
		CurText = CurrencyDisplayText(dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].vp, "VP")
	elseif dbc.currencystate == 4 then
		CurText = CurrencyDisplayText(dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].vpw, "VPw")
	elseif dbc.currencystate == 5 then
		CurText = CurrencyDisplayText(dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].hp, "HP")
	elseif dbc.currencystate == 6 then
		CurText = CurrencyDisplayText(dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].cp, "CP")
	elseif dbc.currencystate == 7 then
		CurText = CurrencyDisplayText(dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].cpw, "CPw")
	elseif dbc.currencystate == 8 then
		CurText = CurrencyDisplayText(dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[1].amnt, ShortenDynamicCurrencyName(BPCurr1Name))
	elseif dbc.currencystate == 9 then
		CurText = CurrencyDisplayText(dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpcurr2, ShortenDynamicCurrencyName(BPCurr2Name))
	elseif dbc.currencystate == 10 then
		CurText = CurrencyDisplayText(dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpcurr3, ShortenDynamicCurrencyName(BPCurr3Name))
	end
	self.text:SetFormattedText("%s", CurText)

	-- If Gold, then show C/S/G colored square
	if dbc.currencystate == 1 then
		self.icon:Show()
		self.icon:ClearAllPoints()
		self.icon:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.text:GetWidth() + 6, 6)
		self.icon:SetVertexColor(unpack(CurrencyColors[curCurrency]))
	else
		self.icon:Hide()
	end
	
	UpdateElementWidth(self)
end

local function Currency_OnEnter(self)
	-- Register Tablets.currency
	if not Tablets.currency:IsRegistered(self) then
		Tablets.currency:Register(self,
			"children", function()
				Currency_UpdateTablet()
			end,
			"point", function()
				return "BOTTOMLEFT"
			end,
			"relativePoint", function()
				return "TOPLEFT"
			end,
			"maxHeight", db.other.tablets.maxheight,
			"clickable", true,
			"hideWhenEmpty", true
		)
	end
	
	if Tablets.currency:IsRegistered(self) then
		-- Tablets.currency appearance
		Tablets.currency:SetColor(self, nibRealUI.media.window[1], nibRealUI.media.window[2], nibRealUI.media.window[3])
		Tablets.currency:SetTransparency(self, nibRealUI.media.window[4])
		Tablets.currency:SetFontSizePercent(self, 1)
		
		-- Open
		Tablets.currency:Open(self)
		
		HideOtherGraphs(self)
	end
	
	self.hasshown = true
	Currency_Update(self)
	
end

function Currency_OnMouseDown(self)
	if IsShiftKeyDown() then
		Currency_ResetWeeklyValues()
		Currency_Update(self)
		print("|cff0099ffRealUI: |r|cffffffffWeekly caps have been reset.")
	elseif IsAltKeyDown() then
		print("|cff0099ffRealUI: |r|cffffffffTo erase character data, mouse-over their entry in the Currency display and then Alt+Click.")
	else
		dbc.currencystate = (dbc.currencystate < (NumCurrencies + 2)) and (dbc.currencystate + 1) or 1
		if UnitLevel("player") < MAX_PLAYER_LEVEL then
			if dbc.currencystate == 3 or dbc.currencystate == 4 then 	-- Skip VP if not Max Level
				dbc.currencystate = 5
			elseif dbc.currencystate > (NumCurrencies + 2) then
				dbc.currencystate = 1
			end
		end
		if not InCombatLockdown() then
			ToggleCharacter("CurrencyFrame")
		end
		Currency_Update(self)
	end
end

---- Bag
function InfoLine_Bag_Update(self)
	local freeSlots, totalSlots = 0, 0
	
	-- Cycle through bags
	for i = 0, 4 do
		local slots, slotsTotal = GetContainerNumFreeSlots(i), GetContainerNumSlots(i)
		if ( i >= 1 ) then	-- Extra bag
			local bagLink = GetInventoryItemLink("player", ContainerIDToInventoryID(i))
			if bagLink then
				freeSlots =  freeSlots + slots
				totalSlots = totalSlots + slotsTotal
			end
		else -- Backpack, we count slots
			freeSlots =  freeSlots + slots
			totalSlots = totalSlots + slotsTotal
		end
	end

	-- Info Text
	self.text:SetFormattedText("|cff%s %d|r", TextColorNormal, freeSlots)
	UpdateElementWidth(self)
end

function InfoLine_Bag_OnMouseDown(self)
	if ContainerFrame1:IsShown() then
		ToggleBackpack()
	else
		ToggleBackpack()
		for i = 1, NUM_BAG_SLOTS do
			ToggleBag(i)
		end
	end
end

---- Durability
local SlotNameTable = {
	[1] = { slot = "HeadSlot", name = "Head" },
	[2] = { slot = "ShoulderSlot", name = "Shoulder" },
	[3] = { slot = "ChestSlot", name = "Chest" },
	[4] = { slot = "WaistSlot", name = "Waist" },
	[5] = { slot = "WristSlot", name = "Wrist" },
	[6] = { slot = "HandsSlot", name = "Hands" },
	[7] = { slot = "LegsSlot", name = "Legs" },
	[8] = { slot = "FeetSlot", name = "Feet" },
	[9] = { slot = "MainHandSlot", name = "Main Hand" },
	[10] = { slot = "SecondaryHandSlot", name = "Off Hand" },
}
local DuraSlotInfo = { }

function InfoLine_Durability_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
	GameTooltip:AddLine(strform("|cff%s%s|r", TextColorTTHeader, DURABILITY))
	GameTooltip:AddLine(" ")
	for i = 1, 10 do
		local durastring
		if ( DuraSlotInfo[i].equip and DuraSlotInfo[i].max ~= nil ) then
			local dColor = nibRealUI:ColorTableToStr({nibRealUI:GetDurabilityColor(DuraSlotInfo[i].perc / 100)})
			durastring = strform("|cff%s%d%%|r", dColor, DuraSlotInfo[i].perc)
			GameTooltip:AddDoubleLine(SlotNameTable[i].name, durastring, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
		end
	end
	GameTooltip:Show()
end

function InfoLine_Durability_Update(self)
	local durability
	local minVal = 100
	
	for i = 1, 10 do
		if not DuraSlotInfo[i] then tinsert(DuraSlotInfo, i, {equip, value, max, perc}) end
		local slotID = GetInventorySlotInfo(SlotNameTable[i].slot)
		local itemLink = GetInventoryItemLink("player", slotID)
		local value, maximum = 0, 0
		if itemLink ~= nil then
			DuraSlotInfo[i].equip = true
			value, maximum = GetInventoryItemDurability(slotID)
		else
			DuraSlotInfo[i].equip = false
		end
		if ( DuraSlotInfo[i].equip and maximum ~= nil ) then
			DuraSlotInfo[i].value = value
			DuraSlotInfo[i].max = maximum
			DuraSlotInfo[i].perc = floor((DuraSlotInfo[i].value/DuraSlotInfo[i].max)*100)
		end
	end
	for i = 1, 10 do
		if ( DuraSlotInfo[i].equip and DuraSlotInfo[i].max ~= nil ) then
			if DuraSlotInfo[i].perc < minVal then minVal = DuraSlotInfo[i].perc end
		end
	end
	
	-- Info Text
	if minVal <= 95 then
		self.hidden = false
		self.text:SetFormattedText("|cff%s %d÷|r", TextColorNormal, minVal)
	else
		self.hidden = true
		self.text:SetText("")
	end
	UpdateElementWidth(self)
end

function InfoLine_Durability_OnMouseDown(self)
	if not InCombatLockdown() then
		ToggleCharacter("PaperDollFrame")
	end
end

---- Friends
local FriendsTabletData
local FriendsTabletDataNames
local FriendsOnline = 0

local function Friends_TabletClickFunc(name, iname, BNid)
	--print("Name: "..name.." iName: "..iname.." BNid: "..BNid)
	if not name then return end
	if IsAltKeyDown() then
		if iname == "" then
			InviteUnit(name)
		else
			InviteUnit(iname)
		end
	elseif BNid then
		SetItemRef("BNplayer:"..name..":"..BNid, "|HBNplayer:"..name.."|h["..name.."|h", "LeftButton")
	else
		SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."]|h", "LeftButton")
	end
end

local FriendsCat
local function Friends_UpdateTablet()
	if ( FriendsOnline > 0 and FriendsTabletData ) then
		local Cols, lineHeader
		
		-- Title
		local Cols = {
			NAME,
			LEVEL_ABBR,
			ZONE,
			FACTION,
			GAME
		}
		FriendsCat = Tablets.friends:AddCategory("columns", #Cols)
		lineHeader = MakeTabletHeader(Cols, db.text.tablets.columnsize + nibRealUI.font.sizeAdjust, 0, {"LEFT", "RIGHT", "LEFT", "LEFT", "LEFT"})
		FriendsCat:AddLine(lineHeader)
		AddBlankTabLine(FriendsCat)
		
		-- Friends
		for _, val in ipairs(FriendsTabletData) do
			local line = {}
			for i = 1, #Cols do
				if i == 1 then	-- Name
					line["text"] = val[i]
					line["justify"] = "LEFT"
					line["func"] = function() Friends_TabletClickFunc(val[6],val[8],val[9]) end
					line["size"] = db.text.tablets.normalsize
				elseif i == 2 then	-- Level
					line["text"..i] = val[2]
					line["justify"..i] = "RIGHT"
					local uLevelColor = GetQuestDifficultyColor(tonumber(val[2]) or 1)
					line["text"..i.."R"] = uLevelColor.r
					line["text"..i.."G"] = uLevelColor.g
					line["text"..i.."B"] = uLevelColor.b
					line["size"..i] = db.text.tablets.normalsize
				else	-- The rest
					line["text"..i] = val[i]
					line["justify"..i] = "LEFT"
					line["text"..i.."R"] = 0.8
					line["text"..i.."G"] = 0.8
					line["text"..i.."B"] = 0.8
					line["size"..i] = db.text.tablets.normalsize
				end
			end
			FriendsCat:AddLine(line)
		end
		
		-- Hint
		Tablets.friends:SetHint(L["<Click> to whisper, <Alt+Click> to invite."], db.text.tablets.hintsize + nibRealUI.font.sizeAdjust)
	end
end

local function Friends_OnEnter(self)
	-- Register Tablets.friends
	if not Tablets.friends:IsRegistered(self) then
		Tablets.friends:Register(self,
			"children", function()
				Friends_UpdateTablet()
			end,
			"point", function()
				return "BOTTOMLEFT"
			end,
			"relativePoint", function()
				return "TOPLEFT"
			end,
			"maxHeight", db.other.tablets.maxheight,
			"clickable", true,
			"hideWhenEmpty", true
		)
	end
	
	if Tablets.friends:IsRegistered(self) then
		-- Tablets.friends appearance
		Tablets.friends:SetColor(self, nibRealUI.media.window[1], nibRealUI.media.window[2], nibRealUI.media.window[3])
		Tablets.friends:SetTransparency(self, nibRealUI.media.window[4])
		Tablets.friends:SetFontSizePercent(self, 1)
		
		-- Open
		if ( FriendsOnline > 0 ) then
			ShowFriends()
		end
		Tablets.friends:Open(self)
		
		HideOtherGraphs(self)
	end
end

local BNetRequestAlert = CreateFrame("Frame", nil, self, "MicroButtonAlertTemplate")
local function Friends_BNetRequest(self, event, ...)
	print("Friends_BNetRequest: event", event)
	if (event == "BN_FRIEND_INVITE_REMOVED") then
		print("Friends_BNetRequest", "Hide")
		BNetRequestAlert:Hide();
	elseif (event == "BN_FRIEND_INVITE_ADDED") or (not BNetRequestAlert.isHidden) then
		print("Friends_BNetRequest", "Show")
		BNetRequestAlert:SetSize(177, BNetRequestAlert.Text:GetHeight()+42);
		BNetRequestAlert.Arrow:SetPoint("TOP", BNetRequestAlert, "BOTTOM", -30, 4)
		BNetRequestAlert:SetPoint("BOTTOM", self, "TOP", 30, 18)
		BNetRequestAlert.CloseButton:SetScript("OnClick", function(self)
			BNetRequestAlert:Hide()
			BNetRequestAlert.isHidden = true
		end);
		BNetRequestAlert.Text:SetText(BN_TOAST_NEW_INVITE);
		BNetRequestAlert.Text:SetWidth(145);
		BNetRequestAlert:Show();
		BNetRequestAlert.isHidden = false
	end
	print("Friends_BNetRequest: isHidden", BNetRequestAlert.isHidden)
end

local function Friends_Update(self)
	FriendsTabletData = nil
	FriendsTabletDataNames = nil
	local curFriendsOnline = 0
	
	-- Standard Friends
	for i = 1, GetNumFriends() do
		local name, lvl, class, area, online, status, note = GetFriendInfo(i)
		if online then
			if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end
			if ( not FriendsTabletDataNames or FriendsTabletDataNames == nil ) then FriendsTabletDataNames = {} end
			
			curFriendsOnline = curFriendsOnline + 1
			
			-- Class
			local classColor = nibRealUI:GetClassColor(ClassLookup[class])
			class = strform("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, class)
			
			-- Name
			local cname
			if ( status == "" and name ) then
				cname = strform("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
			elseif ( name ) then
				cname = strform("%s |cff%02x%02x%02x%s|r", status, classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
			end
			
			-- Add Friend to list
			tinsert(FriendsTabletData, { cname, lvl, area, nibRealUI.faction, "WoW", name, note, "" })
			if name then
				FriendsTabletDataNames[name] = true
			end
		end
	end
	
	-- Battle.net Friends
	for t = 1, BNGetNumFriends() do
		local BNid, BNname, battletag, isBattleTagPresence, toonname, toonid, client, online, lastonline, isafk, isdnd, broadcast, note = BNGetFriendInfo(t)
		-- WoW friends
		if ( online and client=="WoW" ) then
			if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end
			if ( not FriendsTabletDataNames or FriendsTabletDataNames == nil ) then FriendsTabletDataNames = {} end
			
			local _,name, _, realmName, _, faction, race, class, guild, area, lvl = BNGetToonInfo(toonid)
			curFriendsOnline = curFriendsOnline + 1
			
			if (realmName == nibRealUI.realm) then
				FriendsTabletDataNames[toonname] = true
			end

			-- Class
			local classColor = nibRealUI:GetClassColor(ClassLookup[class])
			class = strform("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, class)
			
			-- Name
			local cname
			if ( realmName == GetRealmName() ) then
				-- On My Realm
				cname = strform(
					"|cff%02x%02x%02x%s|r |cffcccccc(|r|cff%02x%02x%02x%s|r|cffcccccc)|r",
					FRIENDS_BNET_NAME_COLOR.r * 255, FRIENDS_BNET_NAME_COLOR.g * 255, FRIENDS_BNET_NAME_COLOR.b * 255,
					BNname,
					classColor[1] * 255, classColor[2] * 255, classColor[3] * 255,
					name
				)
			else
				-- On Another Realm
				cname = strform(
					"|cff%02x%02x%02x%s|r |cffcccccc(|r|cff%02x%02x%02x%s|r|cffcccccc-%s)|r",
					FRIENDS_BNET_NAME_COLOR.r * 255, FRIENDS_BNET_NAME_COLOR.g * 255, FRIENDS_BNET_NAME_COLOR.b * 255,
					BNname,
					classColor[1] * 255, classColor[2] * 255, classColor[3] * 255,
					name,
					realmName
				)
			end
			if (isafk and name ) then
				cname = strform("%s %s", CHAT_FLAG_AFK, cname)
			elseif(isdnd and name) then
				cname = strform("%s %s", CHAT_FLAG_DND, cname)
			end
			
			-- Add Friend to list
			tinsert(FriendsTabletData, { cname, lvl, area, faction, client, BNname, note, name, BNid })
		-- SC2 friends
		elseif ( online and client=="S2" ) then
			if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end
			
			local _,name, _, realmName, faction, _, race, class, guild, area, lvl, gametext = BNGetToonInfo(toonid)
			client = "SC2"
			curFriendsOnline = curFriendsOnline + 1
			
			-- Name
			local cname
			cname = strform(
				"|cff%02x%02x%02x%s|r |cffcccccc(%s)|r",
				FRIENDS_BNET_NAME_COLOR.r * 255, FRIENDS_BNET_NAME_COLOR.g * 255, FRIENDS_BNET_NAME_COLOR.b * 255,
				BNname,
				toonname
			)
			if ( isafk and toonname ) then
				cname = strform("%s %s", CHAT_FLAG_AFK, cname)
			elseif ( isdnd and toonname ) then
				cname = strform("%s %s", CHAT_FLAG_DND, cname)
			end
			
			-- Add Friend to list
			tinsert(FriendsTabletData, { cname, "", gametext, "", client, BNname, note, "", BNid })
		-- D3 friends
		elseif ( online and client=="D3" ) then
			if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end
			
			local _,name, _, realmName, faction, _, race, class, guild, area, lvl, gametext = BNGetToonInfo(toonid)
			client = "D3"
			curFriendsOnline = curFriendsOnline + 1
			
			-- Name
			local cname
			cname = strform(
				"|cff%02x%02x%02x%s|r |cffcccccc(%s)|r",
				FRIENDS_BNET_NAME_COLOR.r * 255, FRIENDS_BNET_NAME_COLOR.g * 255, FRIENDS_BNET_NAME_COLOR.b * 255,
				BNname,
				toonname
			)
			if ( isafk and toonname ) then
				cname = strform("%s %s", CHAT_FLAG_AFK, cname)
			elseif ( isdnd and toonname ) then
				cname = strform("%s %s", CHAT_FLAG_DND, cname)
			end
			
			-- Add Friend to list
			tinsert(FriendsTabletData, { cname, lvl, gametext, class, client, BNname, note, "", BNid })
		-- Hearthstone friends
		elseif ( online and client=="WTCG" ) then
			if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end

			local _,name, _, realmName, faction, _, race, class, guild, area, lvl, gametext = BNGetToonInfo(toonid)
			client = "HS"
			curFriendsOnline = curFriendsOnline + 1
			
			-- Name
			local cname
			cname = strform(
				"|cff%02x%02x%02x%s|r |cffcccccc(%s)|r",
				FRIENDS_BNET_NAME_COLOR.r * 255, FRIENDS_BNET_NAME_COLOR.g * 255, FRIENDS_BNET_NAME_COLOR.b * 255,
				BNname,
				toonname
			)
			if ( isafk and toonname ) then
				cname = strform("%s %s", CHAT_FLAG_AFK, cname)
			elseif ( isdnd and toonname ) then
				cname = strform("%s %s", CHAT_FLAG_DND, cname)
			end
			
			-- Add Friend to list
			tinsert(FriendsTabletData, { cname, lvl, gametext, class, client, BNname, note, "", BNid })
		-- BNet App friends
		elseif ( online and client=="App" ) then
			if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end
			
			local _,name, _, realmName, faction, _, race, class, guild, area, lvl, gametext = BNGetToonInfo(toonid)
			client = "App"
			curFriendsOnline = curFriendsOnline + 1
			
			-- Name
			local cname
			cname = strform(
				"|cff%02x%02x%02x%s|r |cffcccccc(%s)|r",
				FRIENDS_BNET_NAME_COLOR.r * 255, FRIENDS_BNET_NAME_COLOR.g * 255, FRIENDS_BNET_NAME_COLOR.b * 255,
				BNname,
				toonname
			)
			if ( isafk and toonname ) then
				cname = strform("%s %s", CHAT_FLAG_AFK, cname)
			elseif ( isdnd and toonname ) then
				cname = strform("%s %s", CHAT_FLAG_DND, cname)
			end
			
			-- Add Friend to list
			tinsert(FriendsTabletData, { cname, lvl, gametext, class, client, BNname, note, "", BNid })
		end
	end
	
	-- OnEnter
	FriendsOnline = curFriendsOnline
	if FriendsOnline > 0 then
		self.hasfriends = true
	else
		self.hasfriends = false
	end
	
	-- Refresh tablet
	if Tablets.friends:IsRegistered(self) then
		if Tablet20Frame:IsShown() then
			Tablets.friends:Refresh(self)
		end
	end
	
	-- Info Text
	self.text:SetFormattedText("|cff%s %d|r", TextColorNormal, FriendsOnline)
	UpdateElementWidth(self)
end

function Friends_OnMouseDown(self)
	if not InCombatLockdown() then
		ToggleFriendsFrame()
	end
end

---- Guild
local GuildTabletData
local GuildOnline = 0

local function Guild_GMOTDClickFunc(gmotd)
	CopyFrame:Show()
	CopyFrame.editBox:SetText(gmotd)
	CopyFrame.editBox:HighlightText(0)
end

local function Guild_TabletClickFunc(name)
	if not name then return end
	if IsAltKeyDown() then
		InviteUnit(name)
	else
		SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
	end
end

local GuildSection = {}
local function Guild_UpdateTablet()
	if ( IsInGuild() and GuildOnline > 0 ) then
		local Cols, lineHeader
		wipe(GuildSection)
		
		-- Guild Name
		local gname, _, _ = GetGuildInfo("player")
		GuildSection.headerCat = Tablets.guild:AddCategory()
		GuildSection.headerCat:AddLine("text", gname, "size", db.text.tablets.headersize + nibRealUI.font.sizeAdjust, "textR", db.colors.ttheader[1], "textG", db.colors.ttheader[2], "textB", db.colors.ttheader[3])
		GuildSection.headerCat:AddLine("isLine", true, "text", "")
		
		-- Guild Level
		GuildSection.headerCat:AddLine("text", (GetGuildFactionGroup() == 0) and strform(GUILD_LEVEL_AND_FACTION, GetGuildLevel(), FACTION_HORDE) or strform(GUILD_LEVEL_AND_FACTION, GetGuildLevel(), FACTION_ALLIANCE), "size", db.text.tablets.columnsize + nibRealUI.font.sizeAdjust, "textR", nibRealUI.media.colors.blue[1], "textG", nibRealUI.media.colors.blue[2], "textB", nibRealUI.media.colors.blue[3])
		
		-- Reputation
		GuildSection.headerCat:AddLine("text", GetText("FACTION_STANDING_LABEL"..GetGuildFactionInfo(), UnitSex("player")), "size", db.text.tablets.normalsize, "textR", 0.7, "textG", 0.7, "textB", 0.7)
		AddBlankTabLine(GuildSection.headerCat, 5)
		
		-- GMOTD
		local gmotd = GetGuildRosterMOTD()
		if gmotd ~= "" then
			GuildSection.headerCat:AddLine("text", gmotd, "wrap", true, "size", db.text.tablets.normalsize, "textR", 1, "textG", 1, "textB", 1, "func", function() Guild_GMOTDClickFunc(gmotd) end)
			AddBlankTabLine(GuildSection.headerCat, 5)
		end
		AddBlankTabLine(GuildSection.headerCat)
		
		-- Titles
		local Cols = {
			NAME,
			LEVEL_ABBR,
			ZONE,
			RANK,
			LABEL_NOTE
		}
		if CanViewOfficerNote() then
			tinsert(Cols, "Officer Note")
		end
		
		GuildSection.guildCat = Tablets.guild:AddCategory("columns", #Cols)
		lineHeader = MakeTabletHeader(Cols, db.text.tablets.columnsize + nibRealUI.font.sizeAdjust, 0, {"LEFT", "RIGHT", "LEFT", "LEFT", "LEFT", "LEFT"})
		GuildSection.guildCat:AddLine(lineHeader)
		AddBlankTabLine(GuildSection.guildCat)
		
		-- Guild Members
		local nameslot = #Cols + 1
		local isPlayer, isFriend, isGM, normColor
		local line = {}
		for _, val in ipairs(GuildTabletData) do
			isPlayer = val[7] == nibRealUI.name
			if FriendsTabletDataNames then
				isFriend = (not isPlayer) and FriendsTabletDataNames[val[7]] or false
			end
			isGM = val[4] == GUILD_RANK0_DESC
			normColor = 	isPlayer and {0.3, 1, 0.3} or 
							isFriend and {0, 0.8, 0.8} or 
							isGM and {1, 0.65, 0.2} or
							{0.8, 0.8, 0.8}
			wipe(line)
			for i = 1, #Cols do
				if i == 1 then	-- Name
					line["text"] = val[i]
					line["justify"] = "LEFT"
					line["func"] = function() Guild_TabletClickFunc(val[7]) end
					line["size"] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
				elseif i == 2 then	-- Level
					line["text"..i] = val[i]
					line["justify"..i] = "RIGHT"
					local uLevelColor = GetQuestDifficultyColor(val[2])
					line["text"..i.."R"] = uLevelColor.r
					line["text"..i.."G"] = uLevelColor.g
					line["text"..i.."B"] = uLevelColor.b
					line["size"..i] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
				else	-- The rest
					line["text"..i] = val[i]
					line["justify"..i] = "LEFT"
					line["text"..i.."R"] = normColor[1]
					line["text"..i.."G"] = normColor[2]
					line["text"..i.."B"] = normColor[3]
					line["size"..i] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
				end
			end
			GuildSection.guildCat:AddLine(line)
		end
		
		-- Hint
		Tablets.guild:SetHint(L["<Click> to whisper, <Alt+Click> to invite."], db.text.tablets.hintsize + nibRealUI.font.sizeAdjust)
	end
end

local function Guild_OnEnter(self)
	-- Register Tablets.guild
	if not Tablets.guild:IsRegistered(self) then
		Tablets.guild:Register(self,
			"children", function()
				Guild_UpdateTablet()
			end,
			"point", function()
				return "BOTTOMLEFT"
			end,
			"relativePoint", function()
				return "TOPLEFT"
			end,
			"maxHeight", db.other.tablets.maxheight,
			"clickable", true,
			"hideWhenEmpty", true
		)
	end
	
	if Tablets.guild:IsRegistered(self) then
		-- Tablets.guild appearance
		Tablets.guild:SetColor(self, nibRealUI.media.window[1], nibRealUI.media.window[2], nibRealUI.media.window[3])
		Tablets.guild:SetTransparency(self, nibRealUI.media.window[4])
		Tablets.guild:SetFontSizePercent(self, 1)
		
		-- Open
		if ( IsInGuild() and GuildOnline > 0 ) then
			GuildRoster()
		end
		Tablets.guild:Open(self)
		
		HideOtherGraphs(self)
	end
end

local function Guild_Update(self)
	-- If not in guild, set members to 0
	local guildonline = 0
	if not IsInGuild() then
		self.hidden = true
		self.text:SetText("")
		UpdateElementWidth(self)
		return
	end
	
	GuildTabletData = nil
	-- Total Online Guildies
	for i = 1, GetNumGuildMembers() do
		if ( not GuildTabletData or GuildTabletData == nil ) then GuildTabletData = {} end		
		local gPrelist
		local name, rank, _, lvl, _class, zone, note, offnote, online, status, class, _, _, mobile = GetGuildRosterInfo(i)
		
		if (online or mobile) then
			-- Class Color
			local classColor = nibRealUI:GetClassColor(class)
			class = strform("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, class)
			
			-- Player Name
			local cname
			if status == 0 then
				cname = strform("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
			else
				local curStatus = PlayerStatusValToStr[status] or ""
				cname = strform("%s |cff%02x%02x%02x%s|r", curStatus, classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
			end
			
			-- Mobile
			if mobile and (not online) then
				cname = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)..cname
				zone = REMOTE_CHAT
			end
			
			-- Note
			if CanViewOfficerNote() then
				gPrelist = { cname, lvl, zone, rank, note, offnote, name }
			else
				gPrelist = { cname, lvl, zone, rank, note, " ", name }
			end
			
			-- Add to list
			tinsert(GuildTabletData, gPrelist)
			guildonline = guildonline + 1
		end
	end
	
	-- OnEnter
	GuildOnline = guildonline
	if GuildOnline > 0 then
		self.hasguild = true
	else
		self.hasguild = false
	end
	
	-- Refresh tablet
	if Tablets.guild:IsRegistered(self) then
		Tablets.guild:Refresh(self)
	end
	
	-- Info Text
	self.hidden = false
	self.text:SetFormattedText("|cff%s %d|r", TextColorNormal, guildonline)
	UpdateElementWidth(self)
end

function Guild_OnMouseDown(self)
	if not InCombatLockdown() then
		ToggleGuildFrame()
	end
end

-- Meters
local function Meter_Toggle(self)
	if not self.initialized then return end
	
	if not self.windowopen then
		if self.arecount then
			self.frecount.MainWindow:Show()
			self.frecount:RefreshMainWindow()
		end
		if self.askada then
			if not self.fskada:IsVisible() then
				Skada:ToggleWindow()
			end
		end
		if self.aal then
			self.fal:Show()
		end
		PlaySound("igMiniMapOpen")
		self.windowopen = true
	else
		if self.arecount then
			self.frecount.MainWindow:Hide()
		end
		if self.askada then
			if self.fskada:IsVisible() then
				Skada:ToggleWindow()
			end
		end
		if self.aal then
			self.fal:Hide()
		end
		PlaySound("igMiniMapClose")
		self.windowopen = false
	end
end

local function Meter_Update(self)
	if not self.initialized then
		self.askada = IsAddOnLoaded("Skada")
		self.arecount = IsAddOnLoaded("Recount")
		self.aal = IsAddOnLoaded("alDamageMeter")
		self.fskada = _G.SkadaBarWindowSkada
		self.frecount = _G.Recount
		self.fal = _G.alDamageMeterFrame
		self.hidden = not((self.askada and self.fskada) or (self.arecount and self.frecount) or (self.aal and self.fal))
		self.initialized = true
	end
	
	if not self.hidden then
		local SkadaOpen, RecountOpen, alDMOpen
		if self.fskada then
			SkadaOpen = self.fskada:IsVisible()
		end
		if self.frecount then
			RecountOpen = self.frecount.MainWindow:IsVisible()
		end
		if self.fal then
			alDMOpen = self.fal:IsVisible()
		end
		
		self.windowopen = SkadaOpen or RecountOpen or alDMOpen
	end

	if self.windowopen then
		self.icon:SetVertexColor(1, 1, 1)
	else
		self.icon:SetVertexColor(0.25, 0.25, 0.25)
	end
	
	InfoLine:UpdatePositions()
end

---- Layout Button
local function Layout_Update(self)
	local CurLayoutIcon

	if ndbc.layout.current == 1 then
		-- DPS/Tank
		CurLayoutIcon = Icons[layoutSize].layout_dt
	else
		-- Healing
		CurLayoutIcon = Icons[layoutSize].layout_h
	end
	self.icon:SetTexture(CurLayoutIcon[1])
	self.iconwidth = CurLayoutIcon[2]
	UpdateElementWidth(self)
end

---- Spec Button
local SpecEquipList = {}

local function SpecChangeClickFunc(self, ...)
	if ... then
		if GetActiveSpecGroup() == ... then return end
	end
	
	if GetNumSpecGroups() > 1 then
		local NewTG = GetActiveSpecGroup() == 1 and 2 or 1
		
		-- Set Spec
		SetActiveSpecGroup(NewTG)
		
		-- Flag for changing Equip and Layout once Spec change completes
		NeedSpecUpdate = true
	end
end

local function SpecGearClickFunc(self, index, equipName)
	if not index then return end
	
	if IsShiftKeyDown() then
		if dbc.specgear.primary == index then
			dbc.specgear.primary = -1
		end
		if dbc.specgear.secondary == index then
			dbc.specgear.secondary = -1
		end
	elseif IsAltKeyDown() then
		dbc.specgear.secondary = index
	elseif IsControlKeyDown() then
		dbc.specgear.primary = index
	else
		EquipmentManager_EquipSet(equipName)
	end
	
	Tablets.spec:Refresh(self)
end

local function SpecLootClickFunc(self, spec)
	SetLootSpecialization(LootSpecIDs[spec])
end

local function SpecStatClickFunc(self, spec)
	nibRealUI:GetModule("StatDisplay"):ShowOptionsWindow()
end

local function SpecAddLootSpecToCat(self, cat)
	local numSpecs = GetNumSpecializations()
	local specNames = {}
	for i = 1, numSpecs do
		local _, name = GetSpecializationInfo(i)
		specNames[i] = name
	end

	local curLootSpecName = nibRealUI:GetCurrentLootSpecName()
	
	-- Specs
	local line = {}
	for i = 1, numSpecs do
		wipe(line)

		line["text"] = specNames[i]
		line["size"] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
		line["justify"] = "LEFT"
		line["textR"] = (curLootSpecName == specNames[i]) and nibRealUI.media.colors.blue[1] or db.colors.disabled[1]
		line["textG"] = (curLootSpecName == specNames[i]) and nibRealUI.media.colors.blue[2] or db.colors.disabled[2]
		line["textB"] = (curLootSpecName == specNames[i]) and nibRealUI.media.colors.blue[3] or db.colors.disabled[3]
		line["hasCheck"] = true
		line["isRadio"] = true
		line["checked"] = (curLootSpecName == specNames[i])
		line["func"] = function() SpecLootClickFunc(self, i) end

		cat:AddLine(line)
	end

end

local function SpecAddEquipListToCat(self, cat)
	local numSpecGroups = GetNumSpecGroups()
	
	-- Sets
	local line = {}
	if #SpecEquipList > 0 then
		for k, v in ipairs(SpecEquipList) do
			local _, _, _, isEquipped = GetEquipmentSetInfo(k)
			
			wipe(line)
			for i = 1, 4 do
				if i == 1 then
					line["text"] = strform("|T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d|t %s", SpecEquipList[k].icon, db.text.tablets.normalsize + nibRealUI.font.sizeAdjust, db.text.tablets.normalsize + nibRealUI.font.sizeAdjust, 0, 0, 64, 64, 0.1, 0.9, 0.1, 0.9, SpecEquipList[k].name)
					line["size"] = db.text.tablets.normalsize
					line["justify"] = "LEFT"
					line["textR"] = 0.9
					line["textG"] = 0.9
					line["textB"] = 0.9
					line["hasCheck"] = true
					line["isRadio"] = true
					line["checked"] = isEquipped
					line["func"] = function() SpecGearClickFunc(self, k, SpecEquipList[k].name) end
					line["customwidth"] = 110
				elseif i == 2 then
					line["text"..i] = PRIMARY
					line["size"..i] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
					line["justify"..i] = "LEFT"
					line["text"..i.."R"] = (dbc.specgear.primary == k) and nibRealUI.media.colors.blue[1] or 0.3
					line["text"..i.."G"] = (dbc.specgear.primary == k) and nibRealUI.media.colors.blue[2] or 0.3
					line["text"..i.."B"] = (dbc.specgear.primary == k) and nibRealUI.media.colors.blue[3] or 0.3
				elseif (i == 3) and (numSpecGroups > 1) then
					line["text"..i] = SECONDARY
					line["size"..i] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
					line["justify"..i] = "LEFT"
					line["text"..i.."R"] = (dbc.specgear.secondary == k) and nibRealUI.media.colors.blue[1] or 0.3
					line["text"..i.."G"] = (dbc.specgear.secondary == k) and nibRealUI.media.colors.blue[2] or 0.3
					line["text"..i.."B"] = (dbc.specgear.secondary == k) and nibRealUI.media.colors.blue[3] or 0.3
				end
			end
			
			cat:AddLine(line)
		end
	end
end

local TalentInfo = {}
local function SpecAddTalentGroupLineToCat(self, cat, talentGroup)
	local InactiveColor = db.colors.disabled
	local ActiveGroupColor = nibRealUI.media.colors.blue
	local ActiveSpecColor =  nibRealUI.media.colors.orange
	local ActiveLayoutColor = db.colors.normal
	
	local activeSpecGroup = GetActiveSpecGroup()
	local activeSpec = GetSpecialization()
	local id, name, description, icon, spec
	local defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship"
	local line = {}
	
	for i = 1, 3 do
		local GroupColor = (activeSpecGroup == talentGroup) and ActiveGroupColor or InactiveColor
		local SpecColor = (activeSpecGroup == talentGroup) and ActiveSpecColor or InactiveColor
		local LayoutColor = (activeSpecGroup == talentGroup) and ActiveLayoutColor or InactiveColor
		if i == 1 then
			line["text"] = talentGroup == 1 and PRIMARY or SECONDARY
			line["justify"] = "LEFT"
			line["size"] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
			line["textR"] = GroupColor[1]
			line["textG"] = GroupColor[2]
			line["textB"] = GroupColor[3]
			line["hasCheck"] = true
			line["checked"] = activeSpecGroup == talentGroup
			line["isRadio"] = true
			line["func"] = function() SpecChangeClickFunc(self, talentGroup) end
			line["customwidth"] = 110
		elseif i == 2 then
			line["text"..i] = ndbc.layout.spec[talentGroup] == 1 and L["DPS/Tank"] or L["Healing"]
			line["justify"..i] = "LEFT"
			line["size"..i] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
			line["text"..i.."R"] = LayoutColor[1]
			line["text"..i.."G"] = LayoutColor[2]
			line["text"..i.."B"] = LayoutColor[3]
		elseif i == 3 then
			spec = GetSpecialization(false, false, talentGroup)
			if spec then
				id, name, description, icon = GetSpecializationInfo(spec)
			else
				id, name, description, icon = nil, NONE, nil, defaultSpecTexture
			end
			-- line["text"..i] = strform("%s |T%s:%d:%d:%d:%d|t", name, icon, db.text.tablets.normalsize, db.text.tablets.normalsize, 0, 0)
			line["text"..i] = name
			line["justify"..i] = "RIGHT"
			line["text"..i.."R"] = SpecColor[1]
			line["text"..i.."G"] = SpecColor[2]
			line["text"..i.."B"] = SpecColor[3]
		end
	end
	cat:AddLine(line)
end

local SpecSection = {}
local function Spec_UpdateTablet(self)
	local Cols, lineHeader
	
	local numSpecGroups = GetNumSpecGroups()
	
	wipe(SpecSection)
	
	---- Spec Category
	SpecSection["specs"] = {}
	SpecSection["specs"].cat = Tablets.spec:AddCategory()
	SpecSection["specs"].cat:AddLine("text", SPECIALIZATION, "size", db.text.tablets.headersize + nibRealUI.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)

	SpecSection["specs"].talentCat = Tablets.spec:AddCategory("columns", 3)
	AddBlankTabLine(SpecSection["specs"].talentCat, 2)
	SpecAddTalentGroupLineToCat(self, SpecSection["specs"].talentCat, 1)
	if numSpecGroups > 1 then
		SpecAddTalentGroupLineToCat(self, SpecSection["specs"].talentCat, 2)
	end
	
	---- Equipment
	local numEquipSets = GetNumEquipmentSets()
	if numEquipSets > 0 then
		AddBlankTabLine(SpecSection["specs"].talentCat, 8)
		
		-- Equipment Category
		SpecSection["equipment"] = {}
		SpecSection["equipment"].cat = Tablets.spec:AddCategory()
		SpecSection["equipment"].cat:AddLine("text", EQUIPMENT_MANAGER, "size", db.text.tablets.headersize + nibRealUI.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)
		AddBlankTabLine(SpecSection["equipment"].cat, 2)
		
		-- Equipment Cat
		SpecSection["equipment"].equipCat = Tablets.spec:AddCategory("columns", 3)
		AddBlankTabLine(SpecSection["equipment"].equipCat, 1)
		
		SpecAddEquipListToCat(self, SpecSection["equipment"].equipCat)
	end

	---- Loot Specialization
	if GetSpecialization() then
		if numEquipSets > 0 then
			AddBlankTabLine(SpecSection["equipment"].equipCat, 8)
		else
			AddBlankTabLine(SpecSection["specs"].talentCat, 8)
		end
		SpecSection["loot"] = {}
		SpecSection["loot"].cat = Tablets.spec:AddCategory()
		SpecSection["loot"].cat:AddLine("text", LOOT.." "..SPECIALIZATION, "size", db.text.tablets.headersize + nibRealUI.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)
		AddBlankTabLine(SpecSection["loot"].cat, 2)
		SpecAddLootSpecToCat(self, SpecSection["loot"].cat)
	end
	
	---- Stat Display
	if not StatDisplay then
		StatDisplay = nibRealUI:GetModule("StatDisplay", true)
	end
	if nibRealUI:GetModuleEnabled("StatDisplay") and StatDisplay then
		if GetSpecialization() then 
			AddBlankTabLine(SpecSection["loot"].cat, 8)
		elseif numEquipSets > 0 then
			AddBlankTabLine(SpecSection["equipment"].equipCat, 8)
		else
			AddBlankTabLine(SpecSection["specs"].talentCat, 8)
		end
		SpecSection["stats"] = {}
		SpecSection["stats"].cat = Tablets.spec:AddCategory()
		SpecSection["stats"].cat:AddLine("text", L["Stat Display"], "size", db.text.tablets.headersize + nibRealUI.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)
		AddBlankTabLine(SpecSection["stats"].cat, 2)
		
		if numSpecGroups == 2 then Cols = {PRIMARY, SECONDARY, " "} else Cols = {PRIMARY, " "} end
		SpecSection["stats"].statCat = Tablets.spec:AddCategory("columns", #Cols)
		lineHeader = MakeTabletHeader(Cols, db.text.tablets.columnsize + nibRealUI.font.sizeAdjust, 12, {"LEFT", "LEFT"})
		SpecSection["stats"].statCat:AddLine(lineHeader)
		AddBlankTabLine(SpecSection["stats"].statCat, 1)
		
		local watchedStatTexts = StatDisplay:GetCharStatTexts()
		local line = {}
		for r = 1, 2 do
			wipe(line)
			for s = 1, numSpecGroups do
				if s == 1 then
					line["text"] = watchedStatTexts[s][r]
					line["size"] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
					line["justify"] = "LEFT"
					line["textR"] = 0.9
					line["textG"] = 0.9
					line["textB"] = 0.9
					line["indentation"] = 12.5
					line["func"] = function() SpecStatClickFunc(self, s) end
				elseif s == 2 then
					line["text2"] = watchedStatTexts[s][r]
					line["size2"] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
					line["justify2"] = "LEFT"
					line["text2R"] = 0.9
					line["text2G"] = 0.9
					line["text2B"] = 0.9
				end
			end
			line["text"..(numSpecGroups + 1)] = " "
			SpecSection["stats"].statCat:AddLine(line)
		end
	end
	
	-- Hint
	local hintStr = ""
	if numSpecGroups > 1 then
		hintStr = hintStr .. L["<Spec Click> to change talent specs."]
	end
	if numEquipSets > 0 then
		if hintStr ~= "" then hintStr = hintStr .. "\n" end
		if numSpecGroups > 1 then
			hintStr = hintStr .. L["<Equip Click> to equip."].."\n"..L["<Equip Ctl+Click> to assign to "]..PRIMARY..".\n"..L["<Equip Alt+Click> to assign to "]..SECONDARY..".\n"..L["<Equip Shift+Click> to unassign."]
		else
			hintStr = hintStr .. L["<Equip Click> to equip."].."\n"..L["<Equip Ctl+Click> to assign to "]..PRIMARY..".\n"..L["<Equip Shift+Click> to unassign."]
		end
	end
	if nibRealUI:GetModuleEnabled("StatDisplay") and StatDisplay then
		if hintStr ~= "" then hintStr = hintStr .. "\n" end
		hintStr = hintStr .. L["<Stat Click> to configure."]
	end
	Tablets.spec:SetHint(hintStr, db.text.tablets.hintsize + nibRealUI.font.sizeAdjust)
end

local function Spec_OnEnter(self)
	-- Register Tablets.spec
	if not Tablets.spec:IsRegistered(self) then
		Tablets.spec:Register(self,
			"children", function()
				Spec_UpdateTablet(self)
			end,
			"point", function()
				return "BOTTOMRIGHT"
			end,
			"relativePoint", function()
				return "TOPRIGHT"
			end,
			"maxHeight", db.other.tablets.maxheight,
			"clickable", true,
			"hideWhenEmpty", true
		)
	end
	
	if Tablets.spec:IsRegistered(self) then
		-- Tablets.spec appearance
		Tablets.spec:SetColor(self, nibRealUI.media.window[1], nibRealUI.media.window[2], nibRealUI.media.window[3])
		Tablets.spec:SetTransparency(self, nibRealUI.media.window[4])
		Tablets.spec:SetFontSizePercent(self, 1)
		
		-- Open
		Tablets.spec:Open(self)
		
		HideOtherGraphs(self)
	end
	
	self.mouseover = true
	self.text:SetTextColor(unpack(TextColorNormalVals))
end

function InfoLine:SpecUpdateEquip()
	-- Update Equipment Set
	local NewTG = GetActiveSpecGroup()
	if ( (NewTG == 1) and (dbc.specgear.primary > 0) ) then
		EquipmentManager_EquipSet(GetEquipmentSetInfo(dbc.specgear.primary))
	elseif ( (NewTG == 2) and (dbc.specgear.secondary > 0) ) then
		EquipmentManager_EquipSet(GetEquipmentSetInfo(dbc.specgear.secondary))
	end
	self:CancelTimer(self.timerSpecEquip)
end

local function Spec_Update(self)
	-- Talent Info
	wipe(TalentInfo)
	local numSpecGroups = GetNumSpecGroups()
	for i = 1, numSpecGroups do
		TalentInfo[i] = {}
		for t = 1, 3 do
			local _, _, _, specIcon, pointsSpent = GetSpecializationInfo(t, false, false, i)
			TalentInfo[i][t] = {
				points = pointsSpent,
				icon = specIcon,
			}
		end
	end
	
	-- Gear sets
	wipe(SpecEquipList)
	local numEquipSets = GetNumEquipmentSets()
	if numEquipSets > 0 then
		for index = 1, numEquipSets do
			local equipName, equipIcon = GetEquipmentSetInfo(index)
			SpecEquipList[index] = {
				name = equipName,
				icon = equipIcon,
			}
		end
	end
	if dbc.specgear.primary > numEquipSets then
		dbc.specgear.primary = -1
	end
	if dbc.specgear.secondary > numEquipSets then
		dbc.specgear.secondary = -1
	end
	
	-- Info text
	-- Active talent tree
	if GetActiveSpecGroup() == 1 then
		self.text:SetText(PRIMARY)
		UpdateElementWidth(self)
	else
		self.text:SetText(SECONDARY)
		UpdateElementWidth(self)
	end
	
	-- Refresh Tablet
	if Tablets.spec:IsRegistered(self) then
		if Tablet20Frame:IsShown() then
			Tablets.spec:Refresh(self)
		end
	end
	
	if NeedSpecUpdate then
		-- Register timer to update equipment set (can't be updated as soon as cast ends)
		InfoLine.timerSpecEquip = InfoLine:ScheduleRepeatingTimer("SpecUpdateEquip", 0.25)
		
		-- Update Layout
		local NewTG = GetActiveSpecGroup()
		ndbc.layout.current = ndbc.layout.spec[NewTG]
		Layout_Update(ILFrames.layout)
		nibRealUI:UpdateLayout()

		-- ActionBar Doodads
		if nibRealUI:GetModuleEnabled("ActionBarDoodads") then
			local ABD = nibRealUI:GetModule("ActionBarDoodads", true)
			if ABD then ABD:RefreshMod() end
		end
		
		-- No longer need Equip/Layout update on Spec change
		NeedSpecUpdate = false
	end
end

---- PC
local SysStats = {
	netTally = 0,
	bwIn = 		{cur = 0, tally = {}, avg = 0, min = 0, max = 0},
	bwOut = 	{cur = 0, tally = {}, avg = 0, min = 0, max = 0},
	lagHome = 	{cur = 0, tally = {}, avg = 0, min = 0, max = 0},
	lagWorld = 	{cur = 0, tally = {}, avg = 0, min = 0, max = 0},
	fpsTally = -5,
	fps = 		{cur = 0, tally = {}, avg = 0, min = 0, max = 0},
}

local SysSection = {}
local function PC_UpdateTablet()
	local Cols, lineHeader
	wipe(SysSection)
	
	-- Network Category
	SysSection["network"] = {}
	SysSection["network"].cat = Tablets.pc:AddCategory()
	SysSection["network"].cat:AddLine("text", NETWORK_LABEL, "size", db.text.tablets.headersize + nibRealUI.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)
	AddBlankTabLine(SysSection["network"].cat, 2)
	
	-- Lines
	Cols = {
		L["Stat"],
		L["Cur"],
		L["Max"],
		L["Min"],
		L["Avg"],
	}
	SysSection["network"].lineCat = Tablets.pc:AddCategory("columns", #Cols)
	lineHeader = MakeTabletHeader(Cols, db.text.tablets.columnsize + nibRealUI.font.sizeAdjust, 12, {"LEFT", "RIGHT", "RIGHT", "RIGHT", "RIGHT"})
	SysSection["network"].lineCat:AddLine(lineHeader)
	AddBlankTabLine(SysSection["network"].lineCat, 1)
	
	local NetworkLines = {
		[1] = {L["In"], L["kbps"], "%.2f", SysStats.bwIn},
		[2] = {L["Out"], L["kbps"], "%.2f", SysStats.bwOut},
		[3] = {HOME , L["ms"], "%d", SysStats.lagHome},
		[4] = {CHANNEL_CATEGORY_WORLD, L["ms"], "%d", SysStats.lagWorld},
	}
	local line = {}
	for l = 1, #NetworkLines do
		wipe(line)
		for i = 1, #Cols do
			if i == 1 then
				line["text"] = strform("|cffe5e5e5%s|r |cff808080(%s)|r", NetworkLines[l][1], NetworkLines[l][2])
				line["justify"] = "LEFT"
				line["size"] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
				line["indentation"] = 12.5
				line["customwidth"] = 90
			elseif i == 2 then
				line["text"..i] = strform(NetworkLines[l][3], NetworkLines[l][4].cur)
				line["justify"..i] = "RIGHT"
				line["text"..i.."R"] = 0.9
				line["text"..i.."G"] = 0.9
				line["text"..i.."B"] = 0.9
				line["indentation"..i] = 12.5
				line["customwidth"..i] = 30
			elseif i == 3 then
				line["text"..i] = strform(NetworkLines[l][3], NetworkLines[l][4].max)
				line["justify"..i] = "RIGHT"
				line["text"..i.."R"] = 0.7
				line["text"..i.."G"] = 0.7
				line["text"..i.."B"] = 0.7
				line["indentation"..i] = 12.5
				line["customwidth"..i] = 30
			elseif i == 4 then
				line["text"..i] = strform(NetworkLines[l][3], NetworkLines[l][4].min)
				line["justify"..i] = "RIGHT"
				line["text"..i.."R"] = 0.7
				line["text"..i.."G"] = 0.7
				line["text"..i.."B"] = 0.7
				line["indentation"..i] = 12.5
				line["customwidth"..i] = 30
			elseif i == 5 then
				line["text"..i] = strform(NetworkLines[l][3], NetworkLines[l][4].avg)
				line["justify"..i] = "RIGHT"
				line["text"..i.."R"] = 0.7
				line["text"..i.."G"] = 0.7
				line["text"..i.."B"] = 0.7
				line["indentation"..i] = 12.5
				line["customwidth"..i] = 30
			end
		end
		SysSection["network"].lineCat:AddLine(line)
	end
	AddBlankTabLine(SysSection["network"].lineCat, 4)
	
	-- Computer Category
	SysSection["computer"] = {}
	SysSection["computer"].cat = Tablets.pc:AddCategory()
	SysSection["computer"].cat:AddLine("text", SYSTEMOPTIONS_MENU, "size", db.text.tablets.headersize + nibRealUI.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)
	AddBlankTabLine(SysSection["computer"].cat, 2)
	
	-- Lines
	Cols = {
		L["Stat"],
		L["Cur"],
		L["Max"],
		L["Min"],
		L["Avg"],
	}
	SysSection["computer"].lineCat = Tablets.pc:AddCategory("columns", #Cols)
	lineHeader = MakeTabletHeader(Cols, db.text.tablets.columnsize + nibRealUI.font.sizeAdjust, 12, {"LEFT", "RIGHT", "RIGHT", "RIGHT", "RIGHT"})
	SysSection["computer"].lineCat:AddLine(lineHeader)
	AddBlankTabLine(SysSection["computer"].lineCat, 1)
	
	local ComputerLines = {
		[1] = {L["FPS"], SysStats.fps},
	}
	for l = 1, #ComputerLines do
		wipe(line)
		for i = 1, #Cols do
			if i == 1 then
				line["text"] = strform("|cffe5e5e5%s|r", ComputerLines[l][1])
				line["justify"] = "LEFT"
				line["size"] = db.text.tablets.normalsize + nibRealUI.font.sizeAdjust
				line["indentation"] = 12.5
				line["customwidth"] = 90
			elseif i == 2 then
				line["text"..i] = ComputerLines[l][2].cur
				line["justify"..i] = "RIGHT"
				line["text"..i.."R"] = 0.9
				line["text"..i.."G"] = 0.9
				line["text"..i.."B"] = 0.9
				line["indentation"..i] = 12.5
				line["customwidth"..i] = 30
			elseif i == 3 then
				line["text"..i] = ComputerLines[l][2].max
				line["justify"..i] = "RIGHT"
				line["text"..i.."R"] = 0.7
				line["text"..i.."G"] = 0.7
				line["text"..i.."B"] = 0.7
				line["indentation"..i] = 12.5
				line["customwidth"..i] = 30
			elseif i == 4 then
				line["text"..i] = ComputerLines[l][2].min
				line["justify"..i] = "RIGHT"
				line["text"..i.."R"] = 0.7
				line["text"..i.."G"] = 0.7
				line["text"..i.."B"] = 0.7
				line["indentation"..i] = 12.5
				line["customwidth"..i] = 30
			elseif i == 5 then
				line["text"..i] = ComputerLines[l][2].avg
				line["justify"..i] = "RIGHT"
				line["text"..i.."R"] = 0.7
				line["text"..i.."G"] = 0.7
				line["text"..i.."B"] = 0.7
				line["indentation"..i] = 12.5
				line["customwidth"..i] = 30
			end
		end
		SysSection["computer"].lineCat:AddLine(line)
	end
	AddBlankTabLine(SysSection["computer"].lineCat, 8)	-- Space for graph
end

local function PC_OnLeave(self)
	if Tablets.pc:IsRegistered(self) then
		Tablets.pc:Close(self)
		HideGraph("fps")
	end
end

local function PC_OnEnter(self)
	-- Register Tablets.pc
	if not Tablets.pc:IsRegistered(self) then
		Tablets.pc:Register(self,
			"children", function()
				PC_UpdateTablet()
			end,
			"point", function()
				return "BOTTOMRIGHT"
			end,
			"relativePoint", function()
				return "TOPRIGHT"
			end,
			"maxHeight", db.other.tablets.maxheight,
			"clickable", true,
			"hideWhenEmpty", true
		)
	end
	
	if Tablets.pc:IsRegistered(self) then
		-- Tablets.pc appearance
		Tablets.pc:SetColor(self, nibRealUI.media.window[1], nibRealUI.media.window[2], nibRealUI.media.window[3])
		Tablets.pc:SetTransparency(self, nibRealUI.media.window[4])
		Tablets.pc:SetFontSizePercent(self, 1)
		
		Tablets.pc:Open(self)
		
		ShowGraph("fps", Tablet20Frame, "BOTTOMRIGHT", "BOTTOMRIGHT", -10, 10, self)
		HideOtherGraphs(self)
	end
end

local function PC_Update(self, short)
	if short then	
		-- FPS
		SysStats.fps.cur = floor((GetFramerate() or 0) + 0.5)
		
		-- Get last 60 second data
		if ( (SysStats.fps.cur > 0) and (SysStats.fps.cur < 120) ) then
			if SysStats.fpsTally < 0 then
				-- Skip first 5 seconds upon login
				SysStats.fpsTally = SysStats.fpsTally + 1
			else
				local fpsCount = 60
				if SysStats.fpsTally < fpsCount then
					-- fpsCount up to our 60-sec of total tallying
					SysStats.fpsTally = SysStats.fpsTally + 1
					SysStats.fps.tally[SysStats.fpsTally] = SysStats.fps.cur
					fpsCount = SysStats.fpsTally
				else
					-- Shift our tally table down by 1
					for i = 1, fpsCount - 1 do
						SysStats.fps.tally[i] = SysStats.fps.tally[i + 1]
					end
					SysStats.fps.tally[fpsCount] = SysStats.fps.cur
				end
				
				-- Get Average/Min/Max fps
				local minfps, maxfps, totalfps = nil, 0, 0
				for i = 1, fpsCount do
					totalfps = totalfps + SysStats.fps.tally[i]
					if not minfps then minfps = SysStats.fps.tally[i] else minfps = min(minfps, SysStats.fps.tally[i]) end
					maxfps = max(maxfps, SysStats.fps.tally[i])
				end
				SysStats.fps.avg = floor((totalfps / fpsCount) + 0.5)
				SysStats.fps.min = minfps
				SysStats.fps.max = maxfps
			end
		end
		
		-- Graph
		UpdateGraph("fps", SysStats.fps.tally)
	else
		-- Net
		SysStats.bwIn.cur, SysStats.bwOut.cur, SysStats.lagHome.cur, SysStats.lagWorld.cur = GetNetStats()
		SysStats.bwIn.cur = floor(SysStats.bwIn.cur * 100 + 0.5 ) / 100
		SysStats.bwOut.cur = floor(SysStats.bwOut.cur * 100 + 0.5 ) / 100
		
		-- Get last 60 net updates
		local netCount = 60
		if SysStats.netTally < netCount then
			-- Tally up to 60
			SysStats.netTally = SysStats.netTally + 1
			
			SysStats.bwIn.tally[SysStats.netTally] = SysStats.bwIn.cur
			SysStats.bwOut.tally[SysStats.netTally] = SysStats.bwOut.cur
			SysStats.lagHome.tally[SysStats.netTally] = SysStats.lagHome.cur
			SysStats.lagWorld.tally[SysStats.netTally] = SysStats.lagWorld.cur
			
			netCount = SysStats.netTally
		else
			-- Shift our tally table down by 1
			for i = 1, netCount - 1 do
				SysStats.bwIn.tally[i] = SysStats.bwIn.tally[i + 1]
				SysStats.bwOut.tally[i] = SysStats.bwOut.tally[i + 1]
				SysStats.lagHome.tally[i] = SysStats.lagHome.tally[i + 1]
				SysStats.lagWorld.tally[i] = SysStats.lagWorld.tally[i + 1]
			end
			-- Store new values
			SysStats.bwIn.tally[netCount] = SysStats.bwIn.cur
			SysStats.bwOut.tally[netCount] = SysStats.bwOut.cur
			SysStats.lagHome.tally[netCount] = SysStats.lagHome.cur
			SysStats.lagWorld.tally[netCount] = SysStats.lagWorld.cur
		end
		
		-- Get Average/Min/Max
		local minBwIn, maxBwIn, totalBwIn = nil, 0, 0
		local minBwOut, maxBwOut, totalBwOut = nil, 0, 0
		local minLagHome, maxLagHome, totalLagHome = nil, 0, 0
		local minLagWorld, maxLagWorld, totalLagWorld = nil, 0, 0
		
		for i = 1, netCount do
			totalBwIn = totalBwIn + SysStats.bwIn.tally[i]
			if not minBwIn then minBwIn = SysStats.bwIn.tally[i] else minBwIn = min(minBwIn, SysStats.bwIn.tally[i]) end
			maxBwIn = max(maxBwIn, SysStats.bwIn.tally[i])
			
			totalBwOut = totalBwOut + SysStats.bwOut.tally[i]
			if not minBwOut then minBwOut = SysStats.bwOut.tally[i] else minBwOut = min(minBwOut, SysStats.bwOut.tally[i]) end
			maxBwOut = max(maxBwOut, SysStats.bwOut.tally[i])
			
			totalLagHome = totalLagHome + SysStats.lagHome.tally[i]
			if not minLagHome then minLagHome = SysStats.lagHome.tally[i] else minLagHome = min(minLagHome, SysStats.lagHome.tally[i]) end
			maxLagHome = max(maxLagHome, SysStats.lagHome.tally[i])
			
			totalLagWorld = totalLagWorld + SysStats.lagWorld.tally[i]
			if not minLagWorld then minLagWorld = SysStats.lagWorld.tally[i] else minLagWorld = min(minLagWorld, SysStats.lagWorld.tally[i]) end
			maxLagWorld = max(maxLagWorld, SysStats.lagWorld.tally[i])
		end
		
		SysStats.bwIn.avg = floor((totalBwIn / netCount) * 100 + 0.5) / 100
		SysStats.bwIn.min = minBwIn
		SysStats.bwIn.max = maxBwIn
		
		SysStats.bwOut.avg = floor((totalBwOut / netCount) * 100 + 0.5) / 100
		SysStats.bwOut.min = minBwOut
		SysStats.bwOut.max = maxBwOut
		
		SysStats.lagHome.avg = floor((totalLagHome / netCount) + 0.5)
		SysStats.lagHome.min = minLagHome
		SysStats.lagHome.max = maxLagHome
		
		SysStats.lagWorld.avg = floor((totalLagWorld / netCount) + 0.5)
		SysStats.lagWorld.min = minLagWorld
		SysStats.lagWorld.max = maxLagWorld
	end
	
	-- Info Text
	self.text1:SetFormattedText("|cff%s%d|r", TextColorNormal, floor(SysStats.fps.cur + 0.5))
	self.text2:SetFormattedText("|cff%s%d|r", TextColorNormal, SysStats.lagWorld.cur)
	UpdateElementWidth(self)
	
	-- Tablet
	if Tablets.pc:IsRegistered(self) then
		if Tablet20Frame:IsShown() then
			Tablets.pc:Refresh(self)
		end
	end
end

---- Mail
local function Mail_Update(self)
	if HasNewMail() then
		self.hasMail = true
		self.hidden = false
		UpdateElementWidth(self)
	else
		self.hasMail = false
		self.hidden = true
		UpdateElementWidth(self, true)
	end
end

---- Clock
local function Clock_Update(self, ...)
	-- Time
	local newTime
	if db.other.clock.uselocal then
		newTime = db.other.clock.hr24 and date("%H:%M") or date("%I:%M %p")
		if strsub(newTime, 1, 1) == "0" then
			newTime = strsub(newTime, 2)
		end
	else
		newTime = db.other.clock.hr24 and RetrieveGameTime() or RetrieveGameTime(true)
	end
	
	
	if ( WGTime ~= nil ) then
		if (WGTime == 300) and db.other.clock.wgalert then
			print(format("|cffff0000%s|r", L["5 minutes until Wintergrasp"]))
			
		end
	end
	if ( TBTime ~= nil ) and db.other.clock.tbalert then
		if TBTime == 300 then
			print(format("|cffff0000%s|r", L["5 minutes until Tol Barad"]))
		end
	end
	
	-- Info Text
	self.text:SetFormattedText("|cff%s%s|r", TextColorNormal, newTime)
	UpdateElementWidth(self)
end

local function Clock_OnEnter(self)
	local locTime = db.other.clock.hr24 and date("%H:%M") or strform("%d%s", strsub(date("%I:%M %p"), 1, 2), strsub(date("%I:%M %p"), 3))
	
	local serTime = RetrieveGameTime(not db.other.clock.hr24)
	local caltext = date("%b %d (%a)")

	GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
	GameTooltip:AddLine(strform("|cff%s%s|r", TextColorTTHeader, TIMEMANAGER_TOOLTIP_TITLE))
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(strform("|cff%s%s|r", TextColorblue1, TIMEMANAGER_TOOLTIP_REALMTIME), strform("%s", serTime), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
	GameTooltip:AddDoubleLine(strform("|cff%s%s|r", TextColorblue1, TIMEMANAGER_TOOLTIP_LOCALTIME), strform("%s", locTime), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
	GameTooltip:AddDoubleLine(strform("|cff%s%s:|r", TextColorblue1, L["Date"]), caltext, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
	
	-- TB/WG
	GameTooltip:AddLine(" ")
	local _, _, _, _, WGTime = GetWorldPVPAreaInfo(1)
	local _, _, _, _, TBTime = GetWorldPVPAreaInfo(2)
	if ( WGTime ~= nil ) then
		GameTooltip:AddDoubleLine(strform("|cff%s%s|r", TextColorblue1, L["Wintergrasp Time Left"]), strform("%s", ConvertSecondstoTime(WGTime)), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
	else
		GameTooltip:AddLine(strform("|cff%s%s|r", TextColorblue1, L["No Wintergrasp Time Available"]))
	end
	if ( TBTime ~= nil ) then
		GameTooltip:AddDoubleLine(strform("|cff%s%s|r", TextColorblue1, L["Tol Barad Time Left"]), strform("%s", ConvertSecondstoTime(TBTime)), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
	else
		GameTooltip:AddLine(strform("|cff%s%s|r", TextColorblue1, L["No Tol Barad Time Available"]))
	end
	
	-- Invites
	GameTooltip:AddLine(" ")
	if self.pendingCalendarInvites and self.pendingCalendarInvites > 0 then
		GameTooltip:AddDoubleLine(strform("|cff%s%s|r", TextColorblue1, L["Pending Invites:"]), strform("%s", self.pendingCalendarInvites), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
		GameTooltip:AddLine(" ")
	end

	-- World Bosses infos
	if UnitLevel("player") >= 90 then
		local WorldBosses = {
			["Galleon"] = 32098,
			["Sha Of Anger"] = 32099,
			["Nalak"] = 32518,
			["Oondasta"] = 32519,
			["Celestials"] = 33117,
			["Ordos"] = 33118
		}
		for k,v in pairs(WorldBosses) do 
			GameTooltip:AddDoubleLine(strform("|cff%s%s|r", TextColorblue1, L[k]), strform(IsQuestFlaggedCompleted(v) and L["World Boss Done"] or L["World Boss Not Done"]),  0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
		end
		GameTooltip:AddLine(" ")
	end

	-- Hint
	GameTooltip:AddLine(strform("|cff00ff00%s|r", L["<Click> to show calendar."]))
	GameTooltip:AddLine(strform("|cff00ff00%s|r", L["<Shift+Click> to show timer."]))
	GameTooltip:Show()
end

local function Clock_OnMouseDown(self)
	if IsShiftKeyDown() then
		ToggleTimeManager()
	else
		if IsAddOnLoaded("GroupCalendar5") and SlashCmdList.CAL then
			SlashCmdList.CAL("show")
		else
			ToggleCalendar()
		end
	end
end

---------------------
-- Mouse functions --
---------------------
function InfoLine:OnMouseDown(self)
	if self.tag == "start" then
		EasyMenu(MicroMenu, RealUIStartDropDown, self, 0, 0, "MENU", 2)
		
	elseif self.tag == "guild" then
		Guild_OnMouseDown(self)
		
	elseif self.tag == "friends" then
		Friends_OnMouseDown(self)
		
	elseif self.tag == "durability" then
		InfoLine_Durability_OnMouseDown(self)
		
	elseif self.tag == "bag" then
		InfoLine_Bag_OnMouseDown(self)
		
	elseif self.tag == "currency" then
		Currency_OnMouseDown(self)
		
	elseif self.tag == "xprep" then
		InfoLine_XR_OnMouseDown(self)
		
	elseif self.tag == "clock" then
		Clock_OnMouseDown(self)
		
	elseif self.tag == "meters" then
		Meter_Toggle(self)
		
	elseif self.tag == "spec" then
		SpecChangeClickFunc(self)
		
	elseif self.tag == "layout" then
		local NewLayout = ndbc.layout.current == 1 and 2 or 1
		ndbc.layout.current = NewLayout
		ndbc.layout.spec[GetActiveSpecGroup()] = NewLayout
		Layout_Update(self)
		nibRealUI:UpdateLayout()
		GameTooltip:Hide()
		InfoLine:OnEnter(self)
	end
end

function InfoLine:OnLeave(self)
	self.mouseover = false
	HighlightBar:Hide()
	if GameTooltip:IsShown() then GameTooltip:Hide() end
	if self.tag == "start" then
		local color = nibRealUI.media.colors.blue
		self.icon1:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])
		color = nibRealUI.media.colors.orange
		self.icon2:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])
	end
end

function InfoLine:OnEnter(self)
	-- Highlight
	self.mouseover = true
	if self.tag ~= "start" then
		HighlightBar:Show()
		SetHighlightPosition(self)
	end

	if not((not InCombatLockdown()) or db.other.icTips) then return end

	if self.tag == "start" then
		GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
		GameTooltip:AddLine(strform("|cff%s%s|r", TextColorTTHeader, MAINMENU_BUTTON))
		GameTooltip:Show()
		
		local color = nibRealUI.media.colors.blue
		self.icon1:SetVertexColor(color[1], color[2], color[3])
		color = nibRealUI.media.colors.orange
		self.icon2:SetVertexColor(color[1], color[2], color[3])
	elseif self.tag == "mail" and self.hasMail then
		MinimapMailFrameUpdate()
		
		local send1, send2, send3 = GetLatestThreeSenders()
		local toolText

		GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
		if (send1 or send2 or send3) then
			GameTooltip:AddLine(strform("|cff%s%s|r", TextColorTTHeader, HAVE_MAIL_FROM))
		else
			GameTooltip:AddLine(strform("|cff%s%s|r", TextColorTTHeader, HAVE_MAIL))
		end

		if send1 then GameTooltip:AddLine(strform("|cff%s%s|r", TextColorWhite, send1)) end
		if send2 then GameTooltip:AddLine(strform("|cff%s%s|r", TextColorWhite, send2)) end
		if send3 then GameTooltip:AddLine(strform("|cff%s%s|r", TextColorWhite, send3)) end

		GameTooltip:Show()
		
	elseif self.tag == "guild" then
		if self.hasguild then
			Guild_OnEnter(self)
		end
		
	elseif self.tag == "friends" then
		if self.hasfriends then
			Friends_OnEnter(self)
		end
		
	elseif self.tag == "durability" then
		InfoLine_Durability_OnEnter(self)
		
	elseif self.tag == "bag" then
		GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
		GameTooltip:AddLine(strform("|cff%s%s|r", TextColorTTHeader, EMPTY .. " " .. BAGSLOTTEXT))
		GameTooltip:Show()
		
	elseif self.tag == "currency" then
		Currency_OnEnter(self)
		
	elseif self.tag == "xprep" then
		InfoLine_XR_OnEnter(self)
		
	elseif self.tag == "clock" then
		Clock_OnEnter(self)
		
	elseif self.tag == "meters" then
		GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
		GameTooltip:AddLine(strform("|cff%s%s|r", TextColorTTHeader, L["Meter Toggle"]))
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(strform("|cff%s%s|r", TextColorblue1, L["Active Meters:"]))
		if IsAddOnLoaded("Recount") then
			GameTooltip:AddLine(strform("|cff%s%s|r", TextColorWhite, "Recount"))
		end
		if IsAddOnLoaded("Skada") then
			GameTooltip:AddLine(strform("|cff%s%s|r", TextColorWhite, "Skada"))
		end
		if IsAddOnLoaded("alDamageMeter") then
			GameTooltip:AddLine(strform("|cff%s%s|r", TextColorWhite, "alDamageMeter"))
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(strform("|cff00ff00%s|r", L["<Click> to toggle meters."]))
		GameTooltip:Show()
		
	elseif self.tag == "pc" then
		PC_OnEnter(self)
		
	elseif self.tag == "spec" then
		Spec_OnEnter(self)
		
	elseif self.tag == "layout" then
		local CurLayoutText = ndbc.layout.current == 1 and "DPS/Tank" or "Healing"
		local CurResText = layoutSize == 1 and "Low" or "High"
		GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
		GameTooltip:AddLine(strform("|cff%s%s|r", TextColorTTHeader, L["Layout Changer"]))
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(strform("|cff%s%s |r|cff%s%s|r", TextColorblue1, L["Current Layout:"], TextColorWhite, CurLayoutText))
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(strform("|cff00ff00%s|r", L["<Click> to change layouts."]))
		GameTooltip:Show()
	end
end

-------------------
-- Frame Updates --
-------------------
-- Background
function InfoLine:SetBackground()
	if ndb.settings.infoLineBackground then
		ILFrames.parent:SetBackdropColor(unpack(nibRealUI.media.window))
		tinsert(REALUI_WINDOW_FRAMES, ILFrames.parent)
		ILFrames.parent.backgroundTop:SetTexture(0, 0, 0, 1)
		if db.position.y > 0 then
			ILFrames.parent.backgroundBottom:SetTexture(0, 0, 0, 1)
		else
			ILFrames.parent.backgroundBottom:SetTexture(0, 0, 0, 0)
		end	
		ILFrames.parent.stripeTex:Show()
	else
		ILFrames.parent:SetBackdropColor(0, 0, 0, 0)
		ILFrames.parent.backgroundTop:SetTexture(0, 0, 0, 0)
		ILFrames.parent.backgroundBottom:SetTexture(0, 0, 0, 0)
		ILFrames.parent.stripeTex:Hide()
	end
end

-- Font
function InfoLine:UpdateFonts()
	layoutSize = (ndb.settings.fontStyle == 3) and 2 or 1

	-- Set Fonts
	local font = nibRealUI:Font(false, "small")
	for k, fontString in pairs(FontStringsLarge) do
		fontString:SetFont(unpack(font))
	end

	-- Set Icons
	for i,v in pairs(TextureFrames) do
		local element, texture, icon = v[1], v[2], v[3]
		if element.type and (element.type ~= 2) then
			texture:SetTexture(Icons[layoutSize][icon][1])
			element.iconwidth = Icons[layoutSize][icon][2]
		end
	end

	-- Update Element widths
	for i,v in pairs(ILFrames) do
		if ILFrames[i].type and (ILFrames[i].type ~= 1) then
			UpdateElementWidth(ILFrames[i])
		end
	end

	Layout_Update(ILFrames.layout)
	Currency_Update(ILFrames.currency)
end

-- Positions
local function SetPosition(info, parent, anchor, x, width, height)
	info:ClearAllPoints()
	info:SetPoint(anchor, parent, anchor, x, 0)
	info:SetWidth(width)
	info:SetHeight(height)
end

local AlreadyUpdating
function InfoLine:UpdatePositions()
	if AlreadyUpdating then return end
	AlreadyUpdating = true
	
	local Frames = {
		left = {
			{ILFrames.start,		db.elements.start},
			{ILFrames.mail,			db.elements.mail},
			{ILFrames.guild,		db.elements.guild},
			{ILFrames.friends,		db.elements.friends},
			{ILFrames.durability,	db.elements.durability},
			{ILFrames.bag,			db.elements.bag},
			{ILFrames.currency,		db.elements.currency},
			{ILFrames.xprep,		db.elements.xprep},
		},
		right = {
			{ILFrames.clock,		db.elements.clock},
			{ILFrames.meters,		db.elements.metertoggle},
			{ILFrames.layout,		db.elements.layoutchanger},
			{ILFrames.spec,			db.elements.specchanger},
			{ILFrames.pc,			db.elements.pc},
		},
	}
	
	local EHeight = db.position.yoff + ElementHeight[layoutSize] + db.position.yoff
	
	-- Parent
	ILFrames.parent:ClearAllPoints()
	ILFrames.parent:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",  db.position.xleft, db.position.y)
	ILFrames.parent:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT",  db.position.xright, db.position.y)
	ILFrames.parent:SetHeight(EHeight)
	
	---- Left
	local XPos = 0
	for k,v in ipairs(Frames.left) do
		if v[2] and not v[1].hidden then
			v[1]:Show()
			SetPosition(v[1], ILFrames.parent, "BOTTOMLEFT", XPos, v[1].curwidth, EHeight)
			XPos = XPos + v[1].curwidth
			if v[1].mouseover then
				HighlightBar:SetWidth(v[1].curwidth)
			end
		else
			v[1]:Hide()
		end
	end
	
	-- Right
	XPos = 0
	for k,v in ipairs(Frames.right) do
		if v[2] and not v[1].hidden then
			v[1]:Show()
			SetPosition(v[1], ILFrames.parent, "BOTTOMRIGHT", XPos, v[1].curwidth, EHeight)
			XPos = XPos - v[1].curwidth
			if v[1].mouseover then
				HighlightBar:SetWidth(v[1].curwidth)
			end
		else
			v[1]:Hide()
		end
	end
	
	AlreadyUpdating = false
end

--------------------
-- Frame Creation --
--------------------
local function CreateNewElement(name, side, type, iconInfo, ...)
	local extra = ...
	-- Types - 1 = Icon, 2 = Text, 3 = Icon + Text
	local NewElement = CreateFrame("Frame", name, UIParent)
	NewElement.side = side
	NewElement.type = type
	
	NewElement:SetFrameStrata(ILFrames.parent:GetFrameStrata())
	NewElement:SetFrameLevel(ILFrames.parent:GetFrameLevel() + 1)
	
	if type ~= 4 then
		if (type == 1) or (type == 3) then
			if extra == "start" then
				NewElement.icon1 = NewElement:CreateTexture(nil, "ARTWORK")
				NewElement.icon1:SetPoint("BOTTOMLEFT", NewElement, "BOTTOMLEFT", db.position.xgap, db.position.yoff / 2)
				NewElement.icon1:SetHeight(16)
				NewElement.icon1:SetWidth(16)
				NewElement.icon1:SetTexture(Icons[layoutSize].start1[1])
				local color = nibRealUI.media.colors.blue
				NewElement.icon1:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])

				NewElement.icon2 = NewElement:CreateTexture(nil, "ARTWORK")
				NewElement.icon2:SetPoint("BOTTOMLEFT", NewElement, "BOTTOMLEFT", db.position.xgap, db.position.yoff / 2)
				NewElement.icon2:SetHeight(16)
				NewElement.icon2:SetWidth(16)
				NewElement.icon2:SetTexture(Icons[layoutSize].start2[1])
				color = nibRealUI.media.colors.orange
				NewElement.icon2:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])
			else
				NewElement.icon = NewElement:CreateTexture(nil, "ARTWORK")
				NewElement.icon:SetPoint("BOTTOMLEFT", NewElement, "BOTTOMLEFT", db.position.xgap, db.position.yoff)
				NewElement.icon:SetHeight(16)
				NewElement.icon:SetWidth(extra or 16)
				NewElement.icon:SetTexture(iconInfo[1])
			end
			if type == 1 then
				NewElement.curwidth = (db.position.xgap * 2) + iconInfo[2]
			end
			NewElement.iconwidth = iconInfo[2]
		end
		
		if (type == 2) or (type == 3) then
			NewElement.text = NewElement:CreateFontString(nil, "ARTWORK")
			tinsert(FontStringsLarge, NewElement.text)
			NewElement.text:SetFont(unpack(nibRealUI.font.pixel1))
			NewElement.text:SetJustifyH("LEFT")
			if type == 2 then
				NewElement.text:SetPoint("BOTTOMLEFT", NewElement, "BOTTOMLEFT", db.position.xgap, db.position.yoff + db.text.yoffset + 0.5)
			else
				NewElement.text:SetPoint("BOTTOMLEFT", NewElement, "BOTTOMLEFT", db.position.xgap + iconInfo[2] - 1, db.position.yoff + db.text.yoffset + 0.5)
			end
			NewElement.curwidth = 50
		end
	else
		NewElement.text1 = NewElement:CreateFontString(nil, "ARTWORK")
		tinsert(FontStringsLarge, NewElement.text1)
		NewElement.text1:SetFont(unpack(nibRealUI.font.pixel1))
		NewElement.text1:SetJustifyH("LEFT")
		
		NewElement.icon = NewElement:CreateTexture(nil, "ARTWORK")
		NewElement.icon:SetHeight(16)
		NewElement.icon:SetWidth(16)
		NewElement.icon:SetTexture(iconInfo[1])
		NewElement.iconwidth = iconInfo[2]
		
		NewElement.text2 = NewElement:CreateFontString(nil, "ARTWORK")
		tinsert(FontStringsLarge, NewElement.text2)
		NewElement.text2:SetFont(unpack(nibRealUI.font.pixel1))
		NewElement.text2:SetTextColor(unpack(TextColorNormalVals))
		NewElement.text2:SetJustifyH("LEFT")
		
		NewElement.curwidth = 100
	end
	
	NewElement:EnableMouse(true)
	NewElement.mouseover = false
	NewElement:SetScript("OnEnter", function(self) InfoLine:OnEnter(self) end)
	NewElement:SetScript("OnLeave", function(self) InfoLine:OnLeave(self) end)
	NewElement:SetScript("OnMouseDown", function(self) InfoLine:OnMouseDown(self) end)
	
	return NewElement
end

function InfoLine:CreateFrames()
	if FramesCreated then return end
	
	ILFrames = {}
	
	-- Parent
	ILFrames.parent = CreateFrame("Frame", "RealUI_InfoLine", UIParent)
	ILFrames.parent:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	ILFrames.parent:SetFrameStrata("LOW")
	ILFrames.parent:SetFrameLevel(0)

	-- Background
	ILFrames.parent:SetBackdrop({
		bgFile = nibRealUI.media.textures.plain, 
		edgeFile = nil,
	})
	ILFrames.parent.stripeTex = nibRealUI:AddStripeTex(ILFrames.parent)
	ILFrames.parent.backgroundTop = ILFrames.parent:CreateTexture(nil, "ARTWORK")
		ILFrames.parent.backgroundTop:SetPoint("TOPLEFT", ILFrames.parent, "TOPLEFT")
		ILFrames.parent.backgroundTop:SetPoint("BOTTOMRIGHT", ILFrames.parent, "TOPRIGHT", 0, -1)
	ILFrames.parent.backgroundBottom = ILFrames.parent:CreateTexture(nil, "ARTWORK")
		ILFrames.parent.backgroundBottom:SetPoint("BOTTOMLEFT", ILFrames.parent, "BOTTOMLEFT")
		ILFrames.parent.backgroundBottom:SetPoint("TOPRIGHT", ILFrames.parent, "BOTTOMRIGHT", 0, 1)
	self:SetBackground()
	
	-- Highlight Bar
	HighlightBar = CreateFrame("Frame", nil, UIParent)
	HighlightBar:Hide()
	HighlightBar:SetHeight(3)
	HighlightBar:SetFrameStrata("LOW")
	HighlightBar:SetFrameLevel(0)
	HighlightBar.bg = HighlightBar:CreateTexture(nil, "BORDER")
	HighlightBar.bg:SetAllPoints(HighlightBar)
	HighlightBar.bg:SetTexture(0, 0, 0, 1)
	HighlightBar.line = HighlightBar:CreateTexture(nil, "ARTWORK")
	HighlightBar.line:SetPoint("BOTTOMLEFT", HighlightBar, "BOTTOMLEFT", 1, 1)
	HighlightBar.line:SetPoint("TOPRIGHT", HighlightBar, "TOPRIGHT", -1, -1)
	HighlightBar.line:SetTexture(unpack(HighlightColorVals))
	
	-------- LEFT
	-- -- Start Button
	ILFrames.start = CreateNewElement("RealUIInfoLineStart", "LEFT", 1, Icons[layoutSize].start1, "start")
	tinsert(TextureFrames, {ILFrames.start, ILFrames.start.icon1, "start1"})
	tinsert(TextureFrames, {ILFrames.start, ILFrames.start.icon2, "start2"})
	ILFrames.start.tag = "start"
	
	-- -- Mail
	ILFrames.mail = CreateNewElement(nil, "LEFT", 1, Icons[layoutSize].mail)
	tinsert(TextureFrames, {ILFrames.mail, ILFrames.mail.icon, "mail"})
	ILFrames.mail.tag = "mail"
	ILFrames.mail.hasMail = false
	ILFrames.mail:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.mail:RegisterEvent("UPDATE_PENDING_MAIL")
	ILFrames.mail:RegisterEvent("MAIL_CLOSED")
	ILFrames.mail:RegisterEvent("MAIL_SHOW")
	ILFrames.mail:RegisterEvent("MAIL_INBOX_UPDATE")
	ILFrames.mail:SetScript("OnEvent", function(self, event)
		if not db.elements.mail then return end
		if event == "PLAYER_ENTERING_WORLD" then
			self.needrefreshed = true
		end
		Mail_Update(self)
	end)
	ILFrames.mail.elapsed = 0
	ILFrames.mail:SetScript("OnUpdate", function(self, elapsed)
		if self.needrefreshed then
			self.elapsed = self.elapsed + elapsed
			if self.elapsed >= 5 then
				self.needrefreshed = false
				self.elapsed = 0
				Mail_Update(self)
			end
		end
	end)
	
	-- -- Guild
	ILFrames.guild = CreateNewElement(nil, "LEFT", 3, Icons[layoutSize].guild)
	tinsert(TextureFrames, {ILFrames.guild, ILFrames.guild.icon, "guild"})
	ILFrames.guild.tag = "guild"
	ILFrames.guild:RegisterEvent("GUILD_ROSTER_UPDATE")
	ILFrames.guild:RegisterEvent("GUILD_PERK_UPDATE")
	ILFrames.guild:RegisterEvent("GUILD_MOTD")
	ILFrames.guild:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.guild:SetScript("OnEvent", function(self, event)
		if not db.elements.guild then return end
		if event == "GUILD_MOTD" then
			if not self.hidden then return end
			self.needrefreshed = true
			self.elapsed = -2
		else
			self.needrefreshed = true
			self.elapsed = 0
		end
	end)
	ILFrames.guild.elapsed = 2
	ILFrames.guild:SetScript("OnUpdate", function(self, elapsed) 
		self.elapsed = self.elapsed + elapsed
		if self.elapsed >= 2 then
			if self.needrefreshed then
				Guild_Update(self)
				self.needrefreshed = false
			end
			self.elapsed = 0
		end
	end)
	
	-- -- Friends
	ILFrames.friends = CreateNewElement(nil, "LEFT", 3, Icons[layoutSize].friends)
	tinsert(TextureFrames, {ILFrames.friends, ILFrames.friends.icon, "friends"})
	ILFrames.friends.tag = "friends"
	ILFrames.friends:RegisterEvent("FRIENDLIST_UPDATE")
	ILFrames.friends:RegisterEvent("BN_FRIEND_INVITE_ADDED")
	ILFrames.friends:RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED")
	ILFrames.friends:RegisterEvent("BN_FRIEND_INVITE_REMOVED")
	ILFrames.friends:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	ILFrames.friends:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	ILFrames.friends:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.friends:SetScript("OnEvent", function(self, event, ...)
		if (BNGetNumFriendInvites() > 0) or event == "BN_FRIEND_INVITE_REMOVED" then
			Friends_BNetRequest(self, event, ...)
		end
		if not db.elements.friends then return end
		self.needrefreshed = true
		self.elapsed = 0
	end)
	ILFrames.friends.elapsed = 2
	ILFrames.friends:SetScript("OnUpdate", function(self, elapsed) 
		self.elapsed = self.elapsed + elapsed
		if self.elapsed >= 2 then
			if self.needrefreshed then
				Friends_Update(self)
				self.needrefreshed = false
			end
			self.elapsed = 0
		end
	end)
	
	-- -- Durability
	ILFrames.durability = CreateNewElement(nil, "LEFT", 3, Icons[layoutSize].durability)
	tinsert(TextureFrames, {ILFrames.durability, ILFrames.durability.icon, "durability"})
	ILFrames.durability.tag = "durability"
	ILFrames.durability:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	ILFrames.durability:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.durability:SetScript("OnEvent", function(self) 
		if not db.elements.durability then return end
		InfoLine_Durability_Update(self)
	end)
	
	-- -- Bag Space
	ILFrames.bag = CreateNewElement(nil, "LEFT", 3, Icons[layoutSize].bag)
	tinsert(TextureFrames, {ILFrames.bag, ILFrames.bag.icon, "bag"})
	ILFrames.bag.tag = "bag"
	ILFrames.bag:RegisterEvent("InfoLine_Bag_Update")
	ILFrames.bag:RegisterEvent("UNIT_INVENTORY_CHANGED")
	ILFrames.bag:RegisterEvent("BAG_UPDATE")
	ILFrames.bag:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.bag:SetScript("OnEvent", function(self) 
		if not db.elements.bag then return end
		InfoLine_Bag_Update(self)
	end)
	
	-- -- Currency
	ILFrames.currency = CreateNewElement(nil, "LEFT", 2, nil)
	ILFrames.currency.icon = ILFrames.currency:CreateTexture(nil, "ARTWORK")
		ILFrames.currency.icon:SetSize(16, 16)
		ILFrames.currency.icon:SetTexture(Icons[layoutSize].currency[1])
	ILFrames.currency.tag = "currency"
	-- Currency events
	ILFrames.currency:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.currency:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
	ILFrames.currency:RegisterEvent("SEND_MAIL_COD_CHANGED")
	ILFrames.currency:RegisterEvent("PLAYER_TRADE_MONEY")
	ILFrames.currency:RegisterEvent("TRADE_MONEY_CHANGED")
	ILFrames.currency:RegisterEvent("PLAYER_MONEY")
	ILFrames.currency:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	ILFrames.currency:RegisterEvent("UPDATE_PENDING_MAIL")
	-- To know when to start tracking Currency changes
	local MoneyPossibilityEvents = {
		["AUCTION_HOUSE_SHOW"] = true,
		["MAIL_SHOW"] = true,
		["TRADE_SHOW"] = true,
		["TRAINER_SHOW"] = true,
		["MERCHANT_SHOW"] = true,
		["GUILDBANKFRAME_OPENED"] = true,
		["FORGE_MASTER_OPENED"] = true,
		["VOID_STORAGE_OPEN"] = true,
		["TRANSMOGRIFY_OPEN"] = true,
		["TAXIMAP_OPENED"] = true,
		["GOSSIP_SHOW"] = true,
		["QUEST_COMPLETE"] = true,
	}
	for k, v in pairs(MoneyPossibilityEvents) do
		if v then
			ILFrames.currency:RegisterEvent(k)
		end
	end
	-- Events to know when to update Currencies
	ILFrames.currency:SetScript("OnEvent", function(self, event)
		if not db.elements.currency then return end
		if event == "UPDATE_PENDING_MAIL" then
			self.ingame = true
			self:UnregisterEvent("UPDATE_PENDING_MAIL")
		elseif MoneyPossibilityEvents[event] then
			if self.ingame then
				self.initialized = true
			end
			if MoneyPossibilityEvents[event] then 
				for k, v in pairs(MoneyPossibilityEvents) do
					if v then
						ILFrames.currency:UnregisterEvent(k)
					end
				end
			end
		end
		self.needrefreshed = true
		self.elapsed = 0
	end)
	-- Update on interval, avoids too many updates due to lots of events
	ILFrames.currency.elapsed = 1
	ILFrames.currency:SetScript("OnUpdate", function(self, elapsed) 
		self.elapsed = self.elapsed + elapsed
		if self.elapsed >= 1 then
			if self.needrefreshed then
				Currency_Update(self)
				self.needrefreshed = false
			end
			self.elapsed = 0
		end
	end)
	-- Hook into TokenFrame "Show On Backpack" checkbox
	TokenFramePopupBackpackCheckBox:HookScript("OnClick", function(self)
		nibRealUI:Notification(TOKEN_OPTIONS, true, L["Info Line currency tracking will update after UI Reload (/rl)"], nil, [[Interface\AddOns\nibRealUI\Media\Icons\Notification_Alert]])
	end)
	
	-- -- XP/Rep
	ILFrames.xprep = CreateNewElement(nil, "LEFT", 3, Icons[layoutSize].xp)
	tinsert(TextureFrames, {ILFrames.xprep, ILFrames.xprep.icon, "xp"})
	ILFrames.xprep.tag = "xprep"
	ILFrames.xprep:RegisterEvent("PLAYER_XP_UPDATE")
	ILFrames.xprep:RegisterEvent("UPDATE_FACTION")
	ILFrames.xprep:RegisterEvent("DISABLE_XP_GAIN")
	ILFrames.xprep:RegisterEvent("ENABLE_XP_GAIN")
	ILFrames.xprep:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.xprep:SetScript("OnEvent", function(self) 
		if not db.elements.xprep then return end
		InfoLine_XR_Update(self)
	end)
	
	
	------- RIGHT
	-- -- Clock
	ILFrames.clock = CreateNewElement(nil, "RIGHT", 2, nil)
	ILFrames.clock.tag = "clock"
	ILFrames.clock.text:SetJustifyH("RIGHT")
	ILFrames.clock:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.clock:SetScript("OnEvent", function(self) 
		if not db.elements.clock then return end
		Clock_Update(self, true)
	end)
	ILFrames.clock.elapsed = 1
	ILFrames.clock:SetScript("OnUpdate", function(self, elapsed) 
		if not db.elements.clock then return end
		self.elapsed = self.elapsed + elapsed
		if self.elapsed >= 1 then
			Clock_Update(self)
			self.elapsed = 0
		end
	end)
	
	-- -- Meters Button
	ILFrames.meters = CreateNewElement(nil, "RIGHT", 1, Icons[layoutSize].meters)
	tinsert(TextureFrames, {ILFrames.meters, ILFrames.meters.icon, "meters"})
	ILFrames.meters.tag = "meters"
	ILFrames.meters:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.meters:SetScript("OnEvent", function(self) 
		if not db.elements.metertoggle then return end
		Meter_Update(self)
	end)
	ILFrames.meters.elapsed = 2
	ILFrames.meters:SetScript("OnUpdate", function(self, elapsed) 
		if not db.elements.metertoggle then return end
		self.elapsed = self.elapsed + elapsed
		if self.elapsed >= 2 then
			Meter_Update(self)
			self.elapsed = 0
		end
	end)
	
	-- -- Spec Button
	ILFrames.spec = CreateNewElement("RealUIInfoLineSpecChanger", "RIGHT", 2, nil)
	ILFrames.spec.tag = "spec"
	ILFrames.spec:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.spec:RegisterEvent("UPDATE_PENDING_MAIL")
	ILFrames.spec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	ILFrames.spec:RegisterEvent("EQUIPMENT_SETS_CHANGED")
	ILFrames.spec:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	ILFrames.spec:SetScript("OnEvent", function(self) 
		if not db.elements.specchanger then return end
		if event == "UPDATE_PENDING_MAIL" then
			ILFrames.spec:UnregisterEvent("UPDATE_PENDING_MAIL")
		end
		Spec_Update(self)
	end)
	
	-- -- Layout Button
	ILFrames.layout = CreateNewElement(nil, "RIGHT", 1, Icons[layoutSize].layout_dt, 32)
	ILFrames.layout.tag = "layout"
	ILFrames.layout:RegisterEvent("PLAYER_ENTERING_WORLD")
	ILFrames.layout:SetScript("OnEvent", function(self) 
		if not db.elements.layoutchanger then return end
		Layout_Update(self)
	end)

	-- -- PC
	ILFrames.pc = CreateNewElement(nil, "RIGHT", 4, Icons[layoutSize].system)
	tinsert(TextureFrames, {ILFrames.pc, ILFrames.pc.icon, "system"})
	ILFrames.pc.tag = "pc"
	CreateGraph("fps", 60, 60, ILFrames.pc)
	ILFrames.pc:RegisterEvent("UPDATE_PENDING_MAIL")
	ILFrames.pc:SetScript("OnEvent", function(self)
		if not db.elements.pc then return end
		ILFrames.pc.ready = true
		Graphs["fps"].enabled = true
		ILFrames.pc:UnregisterEvent("UPDATE_PENDING_MAIL")
	end)
	ILFrames.pc.elapsed1 = 1
	ILFrames.pc.elapsed2 = 5
	ILFrames.pc:SetScript("OnUpdate", function(self, elapsed) 
		if not db.elements.pc then return end
		if ILFrames.pc.ready then
			self.elapsed1 = self.elapsed1 + elapsed
			self.elapsed2 = self.elapsed2 + elapsed
			if self.elapsed1 >= 1 then
				-- FPS update
				PC_Update(self, true)
				self.elapsed1 = 0
			end
			if self.elapsed2 >= 5 then
				PC_Update(self, false)
				self.elapsed2 = 0
			end
		end
	end)

	FramesCreated = true
end

------------------
-- Core Updates --
------------------
function InfoLine:UpdateAllInfo()
	Guild_Update(ILFrames.guild)
	Friends_Update(ILFrames.friends)
	InfoLine_Durability_Update(ILFrames.durability)
	InfoLine_Bag_Update(ILFrames.bag)
	Currency_Update(ILFrames.currency)
	InfoLine_XR_Update(ILFrames.xprep)
	Clock_Update(ILFrames.clock, true)
	PC_Update(ILFrames.pc, true)
	Spec_Update(ILFrames.spec)
	Layout_Update(ILFrames.layout)
	Meter_Update(ILFrames.meters)
end

function InfoLine:Refresh()
	-- Get Colors
	TextColorNormal = nibRealUI:ColorTableToStr(db.colors.normal)
	TextColorNormalVals = db.colors.normal
	if db.colors.classcolorhighlight then
		HighlightColor = nibRealUI:ColorTableToStr(nibRealUI.classColor)
		HighlightColorVals = {nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3]}
	else
		HighlightColor = nibRealUI:ColorTableToStr(db.colors.highlight)
		HighlightColorVals = db.colors.highlight
	end
	TextColorDisabledVals = db.colors.disabled
	TextColorWhite = nibRealUI:ColorTableToStr({1, 1, 1})
	TextColorTTHeader = nibRealUI:ColorTableToStr(db.colors.ttheader)
	TextColorOrange1 = nibRealUI:ColorTableToStr(nibRealUI.media.colors.orange)
	TextColorblue1 = nibRealUI:ColorTableToStr(nibRealUI.media.colors.blue)
	TextColorBlue1 = nibRealUI:ColorTableToStr(nibRealUI.media.colors.blue)
	
	-- Create Frames if it has been delayed
	if not FramesCreated then
		InfoLine:CreateFrames()
	end
	
	-- Update
	InfoLine:UpdateFonts()
	InfoLine:UpdatePositions()

	local color = nibRealUI.media.colors.blue
	ILFrames.start.icon1:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])
	color = nibRealUI.media.colors.orange
	ILFrames.start.icon2:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])
	
	-- InfoLine:UpdateAllInfo()
end

function InfoLine:UpdateGlobalColors()
	self:Refresh()
end

local function ClassColorsUpdate()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	InfoLine:Refresh()
end

function InfoLine:PLAYER_LOGIN()
	LoggedIn = true
	
	-- Class Name lookup table
	ClassLookup = {}
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		ClassLookup[v] = k
	end
	for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		ClassLookup[v] = k
	end
	
	-- Class Colors
	if CUSTOM_CLASS_COLORS then
		CUSTOM_CLASS_COLORS:RegisterCallback(ClassColorsUpdate)
	end
	
	-- Currency Names
	HPName = GetCurrencyInfo(392)
	CPName = GetCurrencyInfo(390)
	JPName = GetCurrencyInfo(395)
	VPName = GetCurrencyInfo(396)
	-- Try Dynamics Currency Start
	BPCurr1Name = GetBackpackCurrencyInfo(1)
	BPCurr2Name = GetBackpackCurrencyInfo(2)
	BPCurr3Name = GetBackpackCurrencyInfo(3)
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[1].name = BPCurr1Name
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[2].name = BPCurr2Name
	dbg.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name].bpCurrencies[3].name = BPCurr3Name
	-- Try Dynamics Currency End
	GoldName = strtrim(strsub(strform(nibRealUI.goldstr or GOLD_AMOUNT, 0), 2))

	-- Loot Spec
	LootSpecIDs, LootSpecClass = nibRealUI:GetLootSpecData()
	
	-- Start title
	MicroMenu[1].text = nibRealUI:GetVerString(true)
	
	InfoLine:Refresh()
end

function InfoLine:RefreshMod()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	
	db = self.db.profile
	ndbc = nibRealUI.db.char
	ndbg = nibRealUI.db.global
	
	InfoLine:Refresh()
end

--------------------
-- Initialization --
--------------------
function InfoLine:OnInitialize()
	local otherFaction = nibRealUI:OtherFaction(nibRealUI.faction)
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		char = {
			xrstate = "x",
			currencystate = 1,
			specgear = {
				primary = -1,
				secondary = -1,
			},
		},
		global = {
			currency = {
				[nibRealUI.realm] = {
					[nibRealUI.faction] = {
						[nibRealUI.name] = {
							class = "",
							level = 0,
							gold = -1,
							jp = -1,
							vp = -1,
							vpw = -1,
							hp = -1,
							cp = -1,
							cpw = -1,
							-- Try Dynamics Currency start
							bpCurrencies = {
								[1] = {amnt = -1, name = nil},
								[2] = {amnt = -1, name = nil},
								[3] = {amnt = -1, name = nil},
							},
							-- Try Dynamics Currency end
							updated = "",
						},
					},
					[otherFaction] = {},
				},
			},
		},
		profile = {
			position = {
				xleft = 0,
				xright = 0,
				y = 0,
				xgap = 8,
				yoff = 6,
			},
			text = {
				yoffset = 0,
				tablets = {
					headersize = 13,
					columnsize = 10,
					normalsize = 11,
					hintsize = 11,
				},
			},
			colors = {
				normal = {1, 1, 1},
				highlight = {1, 1, 1},
				classcolorhighlight = true,
				disabled = {0.5, 0.5, 0.5},
				ttheader = {1, 1, 1},
				hint = {0, 0.6, 1},
			},
			other = {
				icTips = false,
				clock = {
					hr24 = false,
					uselocal = true,
					wgalert = false,
					tbalert = true,
				},
				tablets = {
					maxheight = 500,
				},
			},
			elements = {
				start = true,
				mail = true,
				guild = true,
				friends = true,
				durability = true,
				bag = false,
				currency = true,
				xprep = true,
				clock = true,
				pc = true,
				specchanger = true,
				layoutchanger = true,
				metertoggle = true,
			},
		},
	})
	db = self.db.profile
	dbc = self.db.char
	dbg = self.db.global
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char
	ndbg = nibRealUI.db.global

	self.InfoLineICTips = db.other.icTips 		-- Tablet-2.0 use
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function InfoLine:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
	
	CreateCopyFrame()
	
	if LoggedIn then
		InfoLine:Refresh()
	end
end
