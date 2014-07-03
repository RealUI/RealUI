local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "ClassResource_Stagger"
local Stagger = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")

local layoutSize

local Textures = {
	[1] = {
		bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Bar_Long]],
		endBox = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_End]],
		middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Middle]],
	},
	[2] = {
		bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Bar_Long]],
		endBox = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_End]],
		middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Middle]],
	},
}

local BarWidth = {
	[1] = 118,
	[2] = 128,
}

local FontStringsRegular = {}

local VengeanceID = 132365
local MinLevel = 10
local maxHealth

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Stagger",
		desc = "Monk Stagger tracker (+ Vengeance).",
		arg = MODNAME,
		childGroups = "tab",
		args = {
			header = {
				type = "header",
				name = "Stagger",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Monk Stagger tracker (+ Vengeance).",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Stagger module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
				end,
				order = 30,
			},
		},
	}
	end
	return options
end

------------------------
---- Vengeance Scan ----
------------------------
-- Scan the tooltip and extract the vengeance value
do
	local regions = {}
	local spellName = GetSpellInfo(VengeanceID)
	local tooltipBufferStagger = CreateFrame("GameTooltip","RealUIBufferTooltip_Stagger",nil,"GameTooltipTemplate")
	tooltipBufferStagger:SetOwner(WorldFrame, "ANCHOR_NONE")

	local function makeTable(t, ...)
		wipe(t)
		for i = 1, select("#", ...) do
			t[i] = select(i, ...)
		end
	end

	function Stagger:UpdateCurrentVengeance()
		local name = UnitAura("player", spellName)
		if name then
			-- Buff found, copy it into the buffer for scanning
			tooltipBufferStagger:ClearLines()
			tooltipBufferStagger:SetUnitBuff("player", name)

			-- Grab all regions, stuff em into our table
			makeTable(regions, tooltipBufferStagger:GetRegions())

			-- Convert FontStrings to strings, replace anything else with ""
			for i=1, #regions do
				local region = regions[i]
				regions[i] = region:GetObjectType() == "FontString" and region:GetText() or ""
			end

			-- Find the number, save it
			self.curVeng = tonumber(string.match(table.concat(regions),"%d+")) or 0
		else
			self.curVeng = 0
		end
	end
end

-----------------
---- Updates ----
-----------------
function Stagger:UpdateAuras(event, units)
	if units and not(units.player) then return end

	-- Stagger
	self.curStagger = UnitStagger("player")
	self.percent = self.curStagger / maxHealth
	self.staggerLevel = 1

	local staggerPer = nibRealUI:Clamp(self.percent, 0, 1/5) * 5
	AngleStatusBar:SetValue(self.sBar.stagger.bar, staggerPer)
	self.sBar.stagger.value:SetText(nibRealUI:ReadableNumber(self.curStagger, 0))

    if (self.percent > STAGGER_YELLOW_TRANSITION and self.percent < STAGGER_RED_TRANSITION) then
    	--Moderate
		self.sBar.stagger.endBox:SetVertexColor(unpack(nibRealUI.media.colors.yellow))
		AngleStatusBar:SetBarColor(self.sBar.stagger.bar, nibRealUI.media.colors.yellow)
    elseif (self.percent > STAGGER_RED_TRANSITION) then
    	--Heavy
		self.sBar.stagger.endBox:SetVertexColor(unpack(nibRealUI.media.colors.red))
		AngleStatusBar:SetBarColor(self.sBar.stagger.bar, nibRealUI.media.colors.red)
    else
    	--Light
		self.sBar.stagger.endBox:SetVertexColor(unpack(nibRealUI.media.colors.green))
		AngleStatusBar:SetBarColor(self.sBar.stagger.bar, nibRealUI.media.colors.green)
    end

	-- Vengeance
	self:UpdateCurrentVengeance()
	
	local vengPer = nibRealUI:Clamp(self.curVeng / self.maxVeng, 0, 1)
	AngleStatusBar:SetValue(self.sBar.veng.bar, vengPer)
	self.sBar.veng.value:SetText(nibRealUI:ReadableNumber(self.curVeng, 0))

	if vengPer > 0 then
		self.sBar.veng.endBox:SetVertexColor(unpack(nibRealUI.media.colors.orange))
	else
		self.sBar.veng.endBox:SetVertexColor(unpack(nibRealUI.media.background))
	end

	-- Update visibility
	if (((self.curStagger > 0) or (self.curVeng > 0)) and not(self.sBar:IsShown())) or
		(((self.curStagger <= 0) or (self.curVeng <= 0)) and self.sBar:IsShown()) then
			self:UpdateShown()
	end
end

function Stagger:UpdateMax(event, unit)
	if (unit and (unit ~= "player")) then
		return
	end
	
	maxHealth = UnitHealthMax("player")
	self.maxVeng = maxHealth
	self:UpdateAuras()
end

function Stagger:UpdateShown(event, unit)
	if unit and unit ~= "player" then return end

	if self.configMode then
		self.sBar:Show()
		return
	end

	if ( (GetSpecialization() == 1) and ((self.curVeng and (self.curVeng > 0)) or (self.curStagger and (self.curStagger > 0))) and not(UnitIsDeadOrGhost("player")) and (UnitLevel("player") >= MinLevel) ) then
		self.sBar:Show()
	else
		self.sBar:Hide()
	end
end

function Stagger:PLAYER_ENTERING_WORLD()
	self.guid = UnitGUID("player")
	self:UpdateAuras()
	self:UpdateShown()
end

-----------------------
---- Frame Updates ----
-----------------------
function Stagger:UpdateFonts()
	local font = nibRealUI:Font()
	for k, fontString in pairs(FontStringsRegular) do
		fontString:SetFont(unpack(font))
	end
end

function Stagger:UpdateGlobalColors()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if nibRealUI.class ~= "MONK" then return end
	AngleStatusBar:SetBarColor(self.sBar.veng.bar, nibRealUI.media.colors.orange)
	self:UpdateAuras()
end

local function CreateTextFrame(parent, size)
	local NewTextFrame = CreateFrame("Frame", nil, parent)
	NewTextFrame:SetSize(12, 12)

	NewTextFrame.text = NewTextFrame:CreateFontString(nil, "ARTWORK")
	NewTextFrame.text:SetFont(unpack(nibRealUI:Font()))
	NewTextFrame.text:SetPoint("BOTTOM", NewTextFrame, "BOTTOM", 0.5, 0.5)
	tinsert(FontStringsRegular, NewTextFrame.text)
	
	return NewTextFrame
end

function Stagger:CreateFrames()
	self.sBar = CreateFrame("Frame", "RealUI_Stagger", RealUIPositionersClassResource)
	local sBar = self.sBar
		sBar:SetSize((BarWidth[layoutSize] * 2) + 1, 6)
		sBar:SetPoint("BOTTOM")
		-- sBar:Hide()
	
	-- Stagger
	sBar.stagger = CreateFrame("Frame", nil, sBar)
		sBar.stagger:SetPoint("BOTTOMRIGHT", sBar, "BOTTOM", -1, 0)
		sBar.stagger:SetSize(BarWidth[layoutSize], 6)

		sBar.stagger.bg = sBar.stagger:CreateTexture(nil, "ARTWORK")
			sBar.stagger.bg:SetPoint("BOTTOMRIGHT")
			sBar.stagger.bg:SetSize(128, 16)
			sBar.stagger.bg:SetTexture(Textures[layoutSize].bar)
			sBar.stagger.bg:SetVertexColor(unpack(nibRealUI.media.background))

		sBar.stagger.endBox = sBar.stagger:CreateTexture(nil, "ARTWORK")
			sBar.stagger.endBox:SetPoint("BOTTOMRIGHT", sBar.stagger, "BOTTOMLEFT", 4, 0)
			sBar.stagger.endBox:SetSize(16, 16)
			sBar.stagger.endBox:SetTexture(Textures[layoutSize].endBox)
			sBar.stagger.endBox:SetVertexColor(unpack(nibRealUI.media.background))

		sBar.stagger.bar = AngleStatusBar:NewBar(sBar.stagger, -5, -1, BarWidth[layoutSize] - 7, 4, "RIGHT", "RIGHT", "LEFT")
			sBar.stagger.bar.reverse = true

		sBar.stagger.value = sBar.stagger:CreateFontString()
			sBar.stagger.value:SetPoint("BOTTOMLEFT", sBar.stagger, "TOPLEFT", -6.5, 1.5)
			sBar.stagger.value:SetJustifyH("LEFT")
			tinsert(FontStringsRegular, sBar.stagger.value)
	
	-- Vengeance
	sBar.veng = CreateFrame("Frame", nil, sBar)
		sBar.veng:SetPoint("BOTTOMLEFT", sBar, "BOTTOM", 0, 0)
		sBar.veng:SetSize(BarWidth[layoutSize], 6)

		sBar.veng.bg = sBar.veng:CreateTexture(nil, "ARTWORK")
			sBar.veng.bg:SetPoint("BOTTOMLEFT")
			sBar.veng.bg:SetSize(128, 16)
			sBar.veng.bg:SetTexture(Textures[layoutSize].bar)
			sBar.veng.bg:SetTexCoord(1, 0, 0, 1)
			sBar.veng.bg:SetVertexColor(unpack(nibRealUI.media.background))

		sBar.veng.endBox = sBar.veng:CreateTexture(nil, "ARTWORK")
			sBar.veng.endBox:SetPoint("BOTTOMLEFT", sBar.veng, "BOTTOMRIGHT", -4, 0)
			sBar.veng.endBox:SetSize(16, 16)
			sBar.veng.endBox:SetTexture(Textures[layoutSize].endBox)
			sBar.veng.endBox:SetTexCoord(1, 0, 0, 1)
			sBar.veng.endBox:SetVertexColor(unpack(nibRealUI.media.background))

		sBar.veng.bar = AngleStatusBar:NewBar(sBar.veng, 5, -1, BarWidth[layoutSize] - 7, 4, "LEFT", "LEFT", "RIGHT")
			sBar.veng.bar.reverse = true

		sBar.veng.value = sBar.veng:CreateFontString()
			sBar.veng.value:SetPoint("BOTTOMRIGHT", sBar.veng, "TOPRIGHT", 9.5, 1.5)
			sBar.veng.value:SetJustifyH("RIGHT")
			tinsert(FontStringsRegular, sBar.veng.value)

	-- Middle
	sBar.middle = sBar:CreateTexture(nil, "ARTWORK")
		sBar.middle:SetPoint("BOTTOM")
		sBar.middle:SetSize(16, 16)
		sBar.middle:SetTexture(Textures[layoutSize].middle)
		sBar.middle:SetVertexColor(unpack(nibRealUI.classColor))
end

------------
function Stagger:ToggleConfigMode(val)
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if nibRealUI.class ~= "MONK" then return end
	if self.configMode == val then return end

	self.configMode = val
	self:UpdateShown()
end

function Stagger:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile

	layoutSize = ndb.settings.hudSize
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterHuDOptions(MODNAME, GetOptions, "ClassResource")
	nibRealUI:RegisterConfigModeModule(self)
end

function Stagger:OnEnable()
	if nibRealUI.class ~= "MONK" then return end

	self.configMode = false

	if not self.sBar then self:CreateFrames() end
	self:UpdateFonts()
	self:UpdateMax()
	self:UpdateGlobalColors()

	local updateSpeed
	if nibRealUI.db.profile.settings.powerMode == 1 then
		updateSpeed = 1/6
	elseif nibRealUI.db.profile.settings.powerMode == 2 then
		updateSpeed = 1/4
	else
		updateSpeed = 1/8
	end

	-- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateShown")
	self:RegisterEvent("PLAYER_UNGHOST", "UpdateShown")
	self:RegisterEvent("PLAYER_ALIVE", "UpdateShown")
	self:RegisterEvent("PLAYER_DEAD", "UpdateShown")
	self:RegisterEvent("PLAYER_LEVEL_UP", "UpdateShown")
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateMax")
	self:RegisterBucketEvent({"UNIT_DISPLAYPOWER", "UNIT_AURA", "UNIT_ABSORB_AMOUNT_CHANGED"}, updateSpeed, "UpdateAuras")
end

function Stagger:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()
end
