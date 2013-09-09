-- Original code from aTooltip by Alza, modified code from FreeUI by Haleth

local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndbc

local MODNAME = "Tooltip"
local Tooltip = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = MODNAME,
		desc = "Modifies the appearance of the Tooltip window.",
		childGroups = "tab",
		arg = MODNAME,
		-- order = 2015,
		args = {
			header = {
				type = "header",
				name = "Tooltip",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Modifies the appearance of the Tooltip window.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Tooltip module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
				end,
				order = 30,
			},
			gap1 = {
				name = " ",
				type = "description",
				order = 31,
			},
			features = {
				name = "Features",
				type = "group",
				inline = true,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				order = 40,
				args = {
					talents = {
						type = "toggle",
						name = "Show Talent Spec",
						width = "full",
						desc = "Display the Talent Spec of the moused-over unit in the Tooltip. This feature sends Inspect requests, so may delay the opening of the Inspect window.",
						get = function() return db.features.talents end,
						set = function(info, value) 
							db.features.talents = value
						end,
						order = 10,
					},
				},
			},
			position = {
				name = "Position",
				type = "group",
				inline = true,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				order = 50,
				args = {
					cursor = {
						type = "toggle",
						name = "Cursor",
						width = "full",
						desc = "Position the Tooltip at the Cursor.",
						get = function() return db.position.cursor end,
						set = function(info, value) 
							db.position.cursor = value
						end,
						order = 10,
					},
					manual = {
						name = "Custom Location",
						type = "group",
						inline = true,
						disabled = function() return db.position.cursor or (not nibRealUI:GetModuleEnabled(MODNAME)) end,
						order = 20,
						args = {
							x = {
								type = "input",
								name = "X Offset",
								width = "half",
								order = 10,
								get = function(info) return tostring(db.position.manual[4]) end,
								set = function(info, value)
									db.position.manual[4] = value
								end,
							},
							y = {
								type = "input",
								name = "Y Offset",
								width = "half",
								order = 20,
								get = function(info) return tostring(db.position.manual[5]) end,
								set = function(info, value)
									db.position.manual[5] = value
								end,
							},
							anchor = {
								type = "select",
								name = "Anchor",
								get = function(info) 
									for k,v in pairs(nibRealUI.globals.anchorPoints) do
										if v == db.position.manual[1] then return k end
									end
								end,
								set = function(info, value)
									db.position.manual[1] = nibRealUI.globals.anchorPoints[value]
									db.position.manual[3] = nibRealUI.globals.anchorPoints[value]
								end,
								style = "dropdown",
								width = nil,
								values = nibRealUI.globals.anchorPoints,
								order = 30,
							},
						},
					},
				},
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 51,
			},
			font = {
				name = "Font",
				type = "group",
				inline = true,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				order = 60,
				args = {
					size = {
						type = "range",
						name = "Size",
						min = 6, max = 32, step = 1,
						get = function(info) return db.font.size end,
						set = function(info, value) 
							db.font.size = value
							Tooltip:SetupFonts()
						end,
						order = 10,
					},
				},
			},
		},
	}
	end
	
	return options
end

local UnitReactionColor = {
    { 1.0, 0.0, 0.0 },
    { 1.0, 0.0, 0.0 },
    { 1.0, 0.5, 0.0 },
    { 1.0, 1.0, 0.0 },
    { 0.0, 1.0, 0.0 },
    { 0.0, 1.0, 0.0 },
    { 0.0, 1.0, 0.0 },
    { 0.0, 1.0, 0.0 },
}

--PVP_ENABLED = ""

local pName = UnitName("player")

-- Talents (code from TipTop by Seerah)
local talentsGUID
local talents = {}
function Tooltip:TalentQuery()
	if not db.features.talents then return end
	if CanInspect("mouseover") then
		if UnitName("mouseover") ~= pName and UnitLevel("mouseover") > 9 then
			local talentline = nil
			for i = 1, GameTooltip:NumLines() do
				local left, leftText
				left = _G["GameTooltipTextLeft"..i]
				leftText = left:GetText()
				if leftText then
					if strsub(leftText, 1, 3) == "S: " then
						talentline = 1
					end
				end
			end
			if not talentline then
				if InspectFrame and InspectFrame:IsShown() then
					GameTooltip:AddLine("S: Inspect Frame is open")
				elseif Examiner and Examiner:IsShown() then
					GameTooltip:AddLine("S: Examiner frame is open")
				else
					talentsGUID = UnitGUID("mouseover")
					NotifyInspect("mouseover")
					GameTooltip:AddLine("S: ...")
					Tooltip:RegisterEvent("INSPECT_READY")
				end
				GameTooltip:Show()
			end
		end
	end
end

function Tooltip:TalentText()
	if not db.features.talents then return end
	local specID, spec, left, leftText
	if UnitExists("mouseover") then
		specID = GetInspectSpecialization("mouseover")
		_, spec = GetSpecializationInfoByID(specID)
		for i = 1, GameTooltip:NumLines() do
			left = _G[GameTooltip:GetName().."TextLeft"..i]
			leftText = left:GetText()
			if leftText ~= nil and strsub(leftText, 1, 3) == "S: " then
				if spec then
					left:SetFormattedText("S: |cffffffff%s|r", spec)
				else
					left:SetText("S: |cffffffff"..NONE.."|r")
				end
			end
			GameTooltip:Show()
		end
	end
	Tooltip:UnregisterEvent("INSPECT_READY")
	specID, spec = nil
end

function Tooltip:INSPECT_READY(event, arg)
	if not db.features.talents then return end
	if talentsGUID == arg then
		self:TalentText()
	end
end

-- Position
function Tooltip:SetupPosition()
	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
		if db.position.cursor then
			self:SetOwner(parent, "ANCHOR_CURSOR")
		else
			self:SetOwner(parent, "ANCHOR_NONE")
			self:SetPoint(unpack(db.position.manual))
		end
	end)
end

-- Fonts
function Tooltip:SetupFonts()
	-- Code from TipTop by Seerah
	local font = nibRealUI.font.standard
	local fontSize = db.font.size
	
	GameTooltipHeaderText:SetFont(font, fontSize + 1)
	GameTooltipText:SetFont(font, fontSize)
	GameTooltipTextSmall:SetFont(font, fontSize - 2)
	ShoppingTooltip1TextLeft1:SetFont(font, fontSize -2)
	ShoppingTooltip1TextLeft2:SetFont(font, fontSize)
	ShoppingTooltip1TextLeft3:SetFont(font, fontSize -2)
	ShoppingTooltip2TextLeft1:SetFont(font, fontSize -2)
	ShoppingTooltip2TextLeft2:SetFont(font, fontSize)
	ShoppingTooltip2TextLeft3:SetFont(font, fontSize -2)
	ShoppingTooltip3TextLeft1:SetFont(font, fontSize -2)
	ShoppingTooltip3TextLeft2:SetFont(font, fontSize)
	ShoppingTooltip3TextLeft3:SetFont(font, fontSize -2)
	
	for i = 1, ShoppingTooltip1:NumLines() do
		_G["ShoppingTooltip1TextRight"..i]:SetFont(font, fontSize -2)
	end
	for i = 1, ShoppingTooltip2:NumLines() do
		_G["ShoppingTooltip2TextRight"..i]:SetFont(font, fontSize -2)
	end
	for i = 1, ShoppingTooltip3:NumLines() do
		_G["ShoppingTooltip3TextRight"..i]:SetFont(font, fontSize -2)
	end
	if GameTooltipMoneyFrame1 then
		GameTooltipMoneyFrame1PrefixText:SetFont(font, fontSize)
		GameTooltipMoneyFrame1SuffixText:SetFont(font, fontSize)
		GameTooltipMoneyFrame1CopperButtonText:SetFont(font, fontSize)
		GameTooltipMoneyFrame1SilverButtonText:SetFont(font, fontSize)
		GameTooltipMoneyFrame1GoldButtonText:SetFont(font, fontSize)
	end
end

-- Unit Styling
function Tooltip:UPDATE_MOUSEOVER_UNIT()
	if not db.features.talents then return end
	Tooltip:UnregisterEvent("INSPECT_READY")
	Tooltip:TalentQuery()
end

function Tooltip:SetupUnitStyling()
	local classification = {
		worldboss = "",
		rareelite = "R+",
		elite = "+",
		rare = "R",
	}

	local function GetColor(unit)
		local r, g, b = 1, 1, 1

		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			r, g, b = unpack(nibRealUI:GetClassColor(class or "WARRIOR"))
		elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or UnitIsDead(unit) then
			r, g, b = .6, .6, .6
		else
			r, g, b = unpack(UnitReactionColor[UnitReaction("player", unit) or 5])
		end

		return "|cff"..nibRealUI:ColorTableToStr({r, g, b})
	end

	local function OnTooltipSetUnit(self)
		local lines = self:NumLines()
		local name, unit = self:GetUnit()
		if not unit or not name then return end

		local race = UnitRace(unit) or ""
		local level = UnitLevel(unit) or ""
		local c = UnitClassification(unit)
		local crtype = UnitCreatureType(unit)
		local unitName, unitRealm = UnitName(unit)

		if(level and level==-1) then
			if(c=="worldboss") then
				level = "Boss"
			else
				level = "??"
			end
		end
		local levelColor = GetQuestDifficultyColor(tonumber(level) or 99)
		levelColor = nibRealUI:ColorTableToStr({levelColor.r, levelColor.g, levelColor.b})
		local color = GetColor(unit)
		
		if unitRealm and unitRealm ~= "" then
			_G["GameTooltipTextLeft1"]:SetFormattedText(color.."%s - %s", name, unitRealm)
		else
			_G["GameTooltipTextLeft1"]:SetText(color..name)
		end

		if(UnitIsPlayer(unit)) then
			local InGuild = GetGuildInfo(unit)
			if(InGuild) then
				_G["GameTooltipTextLeft2"]:SetFormattedText("<|cff0099ff%s|r>", InGuild)
			end

			local n = InGuild and 3 or 2
			_G["GameTooltipTextLeft"..n]:SetFormattedText("|cff%s%s|r %s", levelColor, level, race)
		else
			for i = 2, lines do
				local line = _G["GameTooltipTextLeft"..i]
				local text = line:GetText() or ""
				if((level and text:find("^"..LEVEL)) or (crtype and text:find("^"..crtype))) then
					line:SetFormattedText("|cff%s%s|r%s %s", levelColor, level, classification[c] or "", crtype or "")
					break
				end
			end
		end

		-- Target Line
		local tunit = unit.."target"
		if(UnitExists(tunit) and unit~="player") then
			local color = GetColor(tunit)
			local target = ""

			if(UnitName(tunit)==UnitName("player")) then
				target = color.."> YOU <".."|r"
			else
				target = color..UnitName(tunit).."|r"
			end
			self:AddLine("T: "..target)
		end
	end
	GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
end

----
function Tooltip:RefreshMod()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	
	db = self.db.profile
	
	-- Refresh Mod
	self:SetupPosition()
	self:SetupFonts()
	self:SetupUnitStyling()
end

function Tooltip:PLAYER_LOGIN()
	LoggedIn = true

	self:RefreshMod()
end

function Tooltip:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			features = {
				talents = true,
			},
			position = {
				cursor = false,
				manual = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -31, 192},
			},
			font = {
				size = 11,
			},
		},
	})
	db = self.db.profile
	ndbc = nibRealUI.db.char
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
	
	self:RegisterEvent("PLAYER_LOGIN")
end

function Tooltip:OnEnable()	
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	if LoggedIn then self:RefreshMod() end
end

function Tooltip:OnDisable()
	self:UnregisterEvent("PLAYER_LOGIN")
	self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
end