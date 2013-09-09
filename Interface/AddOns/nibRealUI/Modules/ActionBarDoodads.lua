local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local ndb, db

local MODNAME = "ActionBarDoodads"
local ActionBarDoodads = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local EnteredWorld = false
local Bar4, Bar4Stance, Bar4Profile

local Textures = {
	petBar = {
		center = [[Interface\Addons\nibRealUI\Media\Doodads\PetBar_Center]],
		sides = [[Interface\Addons\nibRealUI\Media\Doodads\PetBar_Sides]],
	},
	stanceBar = {
		center = [[Interface\Addons\nibRealUI\Media\Doodads\StanceBar_Center]],
		sides = [[Interface\Addons\nibRealUI\Media\Doodads\StanceBar_Sides]],
	},
}

local Doodads

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Action Bar Indicators",
		desc = "Adds some extra features to the Action Bars.",
		arg = MODNAME,
		childGroups = "tab",
		disabled = function() return not(IsAddOnLoaded("Bartender4")) end,
		-- order = 103,
		args = {
			header = {
				type = "header",
				name = "Action Bar Indicators",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Adds indicators to highlight location of Stance and Pet Bars.",
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
				name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
				order = 22,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Action Bar Extras module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
					nibRealUI:ReloadUIDialog()
				end,
				order = 30,
			},
		},
	}
	end
	return options
end

----
-- StanceBar functions
----
function ActionBarDoodads:ToggleStanceBar()
	if not(Doodads and Doodads.stance) then return end
	
	if ( Bar4Stance and Bar4Stance:IsEnabled() and nibRealUI:DoesAddonMove("Bartender4") and ndb.actionBarSettings[nibRealUI.cLayout].moveBars.stance and nibRealUI:GetModuleEnabled(MODNAME) and not UnitInVehicle("player")) then
		Doodads.stance:Show()
	else
		Doodads.stance:Hide()
	end
end

function ActionBarDoodads:UpdateStanceBar()
	if not(Doodads and Doodads.stance and Bar4Stance and nibRealUI:DoesAddonMove("Bartender4") and ndb.actionBarSettings[nibRealUI.cLayout].moveBars.stance) then return end
	
	-- Color
	-- Doodads.stance.sides:SetVertexColor(unpack(nibRealUI.classColor))
	Doodads.stance.sides:SetVertexColor(0.5, 0.5, 0.5)
	
	-- Size/Position
	local Bar4Profile = Bartender4DB["profileKeys"][nibRealUI.key]
	local NumStances = GetNumShapeshiftForms()
	local sbP = 1--ndb.actionBarSettings[nibRealUI.cLayout].stanceBar.padding
	local sbW = (NumStances * 22) + ((NumStances - 1) * sbP)
	local sbX = Bartender4DB["namespaces"]["StanceBar"]["profiles"][Bar4Profile]["position"]["x"] - floor((sbW / 2)) + 11.5

	Doodads.stance:ClearAllPoints()
	Doodads.stance:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", floor(sbX) - 2, -6)
end

function ActionBarDoodads:UPDATE_SHAPESHIFT_FORMS()
	self:UpdateStanceBar()
	self:ToggleStanceBar()
end

----
-- PetBar functions
----
function ActionBarDoodads:TogglePetBar()
	if not(Doodads and Doodads.pet) then return end
	
	if ( nibRealUI:DoesAddonMove("Bartender4") and ndb.actionBarSettings[nibRealUI.cLayout].moveBars.pet and nibRealUI:GetModuleEnabled(MODNAME) and (UnitExists("pet") and not UnitInVehicle("player")) and nibRealUI.cLayout == 1 ) then
		Doodads.pet:Show()
	else
		Doodads.pet:Hide()
	end
end

function ActionBarDoodads:UpdatePetBar()
	if not(Doodads and Doodads.pet and nibRealUI:DoesAddonMove("Bartender4") and ndb.actionBarSettings[nibRealUI.cLayout].moveBars.pet) then return end
	
	-- Color
	Doodads.pet.sides:SetVertexColor(unpack(nibRealUI.classColor))
	
	-- Size/Position
	local Bar4Profile = Bartender4DB["profileKeys"][nibRealUI.key]
	local pbX = Bartender4DB["namespaces"]["PetBar"]["profiles"][Bar4Profile]["position"]["x"]
	local pbA = Bartender4DB["namespaces"]["PetBar"]["profiles"][Bar4Profile]["position"]["point"]
	Doodads.pet:ClearAllPoints()
	Doodads.pet:SetPoint(pbA, "UIParent", pbA, floor(pbX) + 3, 3)

	Doodads.pet:Show()
end

function ActionBarDoodads:UNIT_PET()
	self:UpdatePetBar()
	self:TogglePetBar()
end

----
-- Frame Creation
----
function ActionBarDoodads:CreateDoodads()
	Doodads = {}

	-- PetBar
	Doodads.pet = CreateFrame("Frame", "RealUIActionBarDoodadsPet", UIParent)
	local dP = Doodads.pet
	
	dP:SetFrameStrata("BACKGROUND")
	dP:SetFrameLevel(1)
	dP:SetHeight(32)
	dP:SetWidth(32)
	
	dP.sides = dP:CreateTexture(nil, "ARTWORK")
	dP.sides:SetAllPoints(dP)
	dP.sides:SetTexture(Textures.petBar.sides)
	
	dP.center = dP:CreateTexture(nil, "ARTWORK")
	dP.center:SetAllPoints(dP)
	dP.center:SetTexture(Textures.petBar.center)

	dP:Hide()

	-- Stance Bar
	Doodads.stance = CreateFrame("Frame", "RealUIActionBarDoodadsStance", UIParent)
	local dS = Doodads.stance
	
	dS:SetFrameStrata("LOW")
	dS:SetFrameLevel(2)
	dS:SetHeight(32)
	dS:SetWidth(32)
	
	dS.sides = dS:CreateTexture(nil, "ARTWORK")
	dS.sides:SetAllPoints(dS)
	dS.sides:SetTexture(Textures.stanceBar.sides)
	
	dS.center = dS:CreateTexture(nil, "ARTWORK")
	dS.center:SetAllPoints(dS)
	dS.center:SetTexture(Textures.stanceBar.center)
end

----
function ActionBarDoodads:RefreshMod()
	if not(nibRealUI:GetModuleEnabled(MODNAME) and Bar4) then return end
	db = self.db.profile
	
	if not Doodads then self:CreateDoodads() end

	self:UpdatePetBar()
	self:TogglePetBar()

	self:UpdateStanceBar()
	self:ToggleStanceBar()
end

function ActionBarDoodads:PLAYER_ENTERING_WORLD()
	if not Bar4 then return end
	
	self:TogglePetBar()
	self:ToggleStanceBar()
	
	if EnteredWorld then return end
	
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
	self:RefreshMod()
	
	EnteredWorld = true
end

function ActionBarDoodads:PLAYER_LOGIN()
	if IsAddOnLoaded("Bartender4") and Bartender4 then
		Bar4 = LibStub("AceAddon-3.0"):GetAddon("Bartender4", true)
		Bar4Stance = Bar4:GetModule("StanceBar", true)
	end
end

function ActionBarDoodads:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
		},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile

	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function ActionBarDoodads:OnEnable()	
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	if EnteredWorld then 
		self:RefreshMod()
	end
end

function ActionBarDoodads:OnDisable()
	self:TogglePetBar()
end