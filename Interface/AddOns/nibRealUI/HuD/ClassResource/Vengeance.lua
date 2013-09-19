local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "ClassResource_Vengeance"
local Vengeance = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")

local layoutSize

local Textures = {
	[1] = {
		bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Bar]],
		middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Middle]],
	},
	[2] = {
		bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Bar]],
		middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Middle]],
	},
}

local BarWidth = {
	[1] = 84,
	[2] = 114,
}

local FontStringsRegular = {}

local VengeanceID = 132365
local VengeanceName
local MinLevel = 10

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Vengeance",
		desc = "Vengeance tracker for Druids, Paladins and Warriors.",
		arg = MODNAME,
		childGroups = "tab",
		args = {
			header = {
				type = "header",
				name = "Vengeance",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Vengeance tracker for Druids, Paladins and Warriors.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Vengeance module.",
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
local tooltipBufferVeng = CreateFrame("GameTooltip","RealUIBufferTooltip_Vegneance",nil,"GameTooltipTemplate")
tooltipBufferVeng:SetOwner(WorldFrame, "ANCHOR_NONE")
local regions = {}
local function makeTable(t, ...)
	wipe(t)
	for i = 1, select("#", ...) do
		t[i] = select(i, ...)
	end
end
function Vengeance:UpdateCurrent()
	local name = UnitAura("player", VengeanceName)
	if name then
		-- Buff found, copy it into the buffer for scanning
		tooltipBufferVeng:ClearLines()
		tooltipBufferVeng:SetUnitBuff("player", name)

		-- Grab all regions, stuff em into our table
		makeTable(regions, tooltipBufferVeng:GetRegions())

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

---------------------------
---- Vengeance Updates ----
---------------------------
function Vengeance:UpdateAuras(event, units)
	if units and not(units.player) then return end

	self:UpdateCurrent()

	self.vBar.value.text:SetText(nibRealUI:ReadableNumber(self.curVeng, 0))

	local vengPer = nibRealUI:Clamp(self.curVeng / self.maxVeng, 0, 1)
	
	if vengPer < 0.5 then
		AngleStatusBar:SetValue(self.vBar.left.bar, vengPer * 2)
		AngleStatusBar:SetValue(self.vBar.right.bar, 0)
	else
		AngleStatusBar:SetValue(self.vBar.right.bar, (vengPer - 0.5) * 2)
		AngleStatusBar:SetValue(self.vBar.left.bar, 1)
	end

	if ((self.curVeng > 0) and not(self.vBar:IsShown())) or
		((self.curVeng <= 0) and self.vBar:IsShown()) then
			self:UpdateShown()
	end
end

function Vengeance:UpdateMax(event, unit)
	if (unit and (unit ~= "player")) then
		return
	end
	
	local Stam, MaxHealth, BaseHealth = UnitStat("player", 3), UnitHealthMax("player")
	if Stam < 20 then
		BaseHealth = MaxHealth - Stam
	else
		BaseHealth = MaxHealth - ((Stam - 19) * 10) - 6
	end
	local MaxVeng = MaxHealth --floor(Stam + (BaseHealth / 10))
	
	self.maxVeng = MaxVeng
	self:UpdateAuras()
end

function Vengeance:UpdateShown(event, unit)
	if unit and unit ~= "player" then return end

	if self.configMode then
		self.vBar:Show()
		return
	end

	if ( (self.curVeng and (self.curVeng > 0)) and not(UnitIsDeadOrGhost("player")) and (UnitLevel("player") >= MinLevel) ) then
		self.vBar:Show()
	else
		self.vBar:Hide()
	end
end

function Vengeance:PLAYER_ENTERING_WORLD()
	self.guid = UnitGUID("player")
	self:UpdateAuras()
	self:UpdateShown()
end

-----------------------
---- Frame Updates ----
-----------------------
function Vengeance:UpdateFonts()
	local font = nibRealUI:Font()
	for k, fontString in pairs(FontStringsRegular) do
		fontString:SetFont(unpack(font))
	end
end

function Vengeance:UpdateGlobalColors()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if not (nibRealUI.class == "DRUID" or
			nibRealUI.class == "PALADIN" or
			nibRealUI.class == "WARRIOR") then
		return
	end
	AngleStatusBar:SetBarColor(self.vBar.left.bar, nibRealUI.media.colors.orange)
	AngleStatusBar:SetBarColor(self.vBar.right.bar, nibRealUI.media.colors.orange)
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

function Vengeance:CreateFrames()
	self.vBar = CreateFrame("Frame", "RealUI_Vengeance", RealUIPositionersClassResource)
	local vBar = self.vBar
		vBar:SetSize((BarWidth[layoutSize] * 2) + 1, 6)
		vBar:SetPoint("BOTTOM")
		-- vBar:Hide()
	
	-- Lunar
	vBar.left = CreateFrame("Frame", nil, vBar)
		vBar.left:SetPoint("BOTTOMRIGHT", vBar, "BOTTOM", -1, 0)
		vBar.left:SetSize(BarWidth[layoutSize], 6)

		vBar.left.bg = vBar.left:CreateTexture(nil, "ARTWORK")
			vBar.left.bg:SetPoint("BOTTOMRIGHT")
			vBar.left.bg:SetSize(128, 16)
			vBar.left.bg:SetTexture(Textures[layoutSize].bar)
			vBar.left.bg:SetVertexColor(unpack(nibRealUI.media.background))

		vBar.left.bar = AngleStatusBar:NewBar(vBar.left, 2, -1, BarWidth[layoutSize] - 7, 4, "RIGHT", "RIGHT", "RIGHT")
			vBar.left.bar.reverse = true
	
	-- Solar
	vBar.right = CreateFrame("Frame", nil, vBar)
		vBar.right:SetPoint("BOTTOMLEFT", vBar, "BOTTOM", 0, 0)
		vBar.right:SetSize(BarWidth[layoutSize], 6)

		vBar.right.bg = vBar.right:CreateTexture(nil, "ARTWORK")
			vBar.right.bg:SetPoint("BOTTOMLEFT")
			vBar.right.bg:SetSize(128, 16)
			vBar.right.bg:SetTexture(Textures[layoutSize].bar)
			vBar.right.bg:SetTexCoord(1, 0, 0, 1)
			vBar.right.bg:SetVertexColor(unpack(nibRealUI.media.background))

		vBar.right.bar = AngleStatusBar:NewBar(vBar.right, 5, -1, BarWidth[layoutSize] - 7, 4, "LEFT", "LEFT", "RIGHT")
			vBar.right.bar.reverse = true

	-- Middle
	vBar.middle = vBar:CreateTexture(nil, "ARTWORK")
		vBar.middle:SetPoint("BOTTOM")
		vBar.middle:SetSize(16, 16)
		vBar.middle:SetTexture(Textures[layoutSize].middle)
		vBar.middle:SetVertexColor(unpack(nibRealUI.classColor))

	-- Vengeance text
	vBar.value = CreateTextFrame(vBar)
		vBar.value:SetPoint("BOTTOM", vBar, "TOP", 0, 3)
end

------------
function Vengeance:ToggleConfigMode(val)
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if not (nibRealUI.class == "DRUID" or
			nibRealUI.class == "PALADIN" or
			nibRealUI.class == "WARRIOR") then
		return
	end
	if self.configMode == val then return end

	self.configMode = val
	self:UpdateShown()
end

function Vengeance:OnInitialize()
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

function Vengeance:OnEnable()
	if not (nibRealUI.class == "DRUID" or
			nibRealUI.class == "PALADIN" or
			nibRealUI.class == "WARRIOR") then
		return
	end

	self.configMode = false

	VengeanceName = GetSpellInfo(VengeanceID)

	if not self.vBar then self:CreateFrames() end
	self:UpdateMax()
	self:UpdateFonts()
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
	self:RegisterBucketEvent("UNIT_AURA", updateSpeed, "UpdateAuras")
end

function Vengeance:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()
end