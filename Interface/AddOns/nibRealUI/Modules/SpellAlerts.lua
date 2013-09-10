local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local _
local MODNAME = "SpellAlerts"
local SpellAlerts = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Spell Alerts",
		desc = "Modify the position and size of the Spell Alert system.",
		arg = MODNAME,
		-- order = 1916,
		args = {
			header = {
				type = "header",
				name = "Spell Alerts",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Modify the position and size of the Spell Alert system.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Spell Alerts module.",
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

function SpellAlerts:UpdatePosition()
	-- Spell Alert frame
	SpellActivationOverlayFrame:SetScale(0.65)
	
	SpellActivationOverlayFrame:SetFrameStrata("MEDIUM")
	SpellActivationOverlayFrame:SetFrameLevel(1)
	
	if _G["RealUIPositionersSpellAlerts"] then
		SpellActivationOverlayFrame:ClearAllPoints()
		SpellActivationOverlayFrame:SetAllPoints(_G["RealUIPositionersSpellAlerts"])
	end
end

function SpellAlerts:UpdateAppearance()
	SpellActivationOverlayFrame:SetAlpha(GetCVar("spellActivationOverlayOpacity"))
end

function SpellAlerts:PLAYER_LOGIN()
	SpellAlerts:UpdatePosition()
	SpellAlerts:UpdateAppearance()
end

----------
function SpellAlerts:OnInitialize()
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function SpellAlerts:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
end