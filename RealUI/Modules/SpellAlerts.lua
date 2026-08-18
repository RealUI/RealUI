local _, private = ...

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "SpellAlerts"
local SpellAlerts = RealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Spell alerts are designed to appear around the player character, so the
-- frame is anchored statically to screen center (via the static SpellAlerts
-- positioner) and never follows the HuD sliders (B13).
--
-- Sizing model: Blizzard's SpellActivationOverlayFrame positions each alert
-- texture off the frame's edges and sizes the textures from internal
-- constants in the frame's local coordinate space. Keeping the frame's local
-- size constant and applying SetScale therefore scales both the alert
-- artwork AND its spread around the character uniformly — exactly what the
-- user-facing "Scale" setting should do.
local BASE_SCALE = 0.65
-- Local-unit footprint chosen so that at scale 100% the physical rect
-- matches the old positioner-driven default (~250x140 px).
local BASE_WIDTH, BASE_HEIGHT = 385, 215

function SpellAlerts:GetUserScale()
    local scale = self.db and self.db.profile.scale
    if _G.type(scale) ~= "number" or scale <= 0 then
        return 1
    end
    return scale
end

function SpellAlerts:UpdatePosition()
    local frame = _G.SpellActivationOverlayFrame
    if not frame then return end

    frame:SetScale(BASE_SCALE * self:GetUserScale())
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(1)

    -- Constant local size; SetScale drives the visual size (see note above).
    frame:SetSize(BASE_WIDTH, BASE_HEIGHT)
    frame:ClearAllPoints()
    local anchor = _G.RealUIPositionersSpellAlerts or _G.UIParent
    frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)
end

function SpellAlerts:UpdateAppearance()
    --_G.SpellActivationOverlayFrame:SetAlpha(_G.GetCVar("spellActivationOverlayOpacity"))
end

function SpellAlerts:PLAYER_LOGIN()
    SpellAlerts:UpdatePosition()
    SpellAlerts:UpdateAppearance()
end

function SpellAlerts:OnProfileUpdate()
    -- Core's profile cascade calls OnProfileUpdate on every module; leave
    -- Blizzard's frame alone when the module is disabled.
    if not self:IsEnabled() then return end
    self:UpdatePosition()
end

----------
function SpellAlerts:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            scale = 1,
        }
    })

    -- Register with ModuleFramework
    if RealUI.ModuleFramework then
        RealUI:RegisterRealUIModule(MODNAME, "enhancement", {}, {
            description = "Spell alert system with positioning integration",
            version = "1.1.0"
        })
    end

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function SpellAlerts:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
end
