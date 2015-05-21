local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local _
local MODNAME = "SpellAlerts"
local SpellAlerts = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0")

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
end

function SpellAlerts:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
end
