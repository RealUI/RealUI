local _, private = ...

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "SpellAlerts"
local SpellAlerts = RealUI:NewModule(MODNAME, "AceEvent-3.0")

function SpellAlerts:UpdatePosition()
    -- Spell Alert frame
    _G.SpellActivationOverlayFrame:SetScale(0.65)

    _G.SpellActivationOverlayFrame:SetFrameStrata("MEDIUM")
    _G.SpellActivationOverlayFrame:SetFrameLevel(1)

    if _G["RealUIPositionersSpellAlerts"] then
        _G.SpellActivationOverlayFrame:ClearAllPoints()
        _G.SpellActivationOverlayFrame:SetAllPoints(_G["RealUIPositionersSpellAlerts"])
    end
end

function SpellAlerts:UpdateAppearance()
    _G.SpellActivationOverlayFrame:SetAlpha(_G.GetCVar("spellActivationOverlayOpacity"))
end

function SpellAlerts:PLAYER_LOGIN()
    SpellAlerts:UpdatePosition()
    SpellAlerts:UpdateAppearance()
end

----------
function SpellAlerts:OnInitialize()
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function SpellAlerts:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
end
