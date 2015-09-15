--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('TargetArrows', 'AceEvent-3.0')

local arrowSize

-- messages ####################################################################
function mod:PostCreate(msg,f)
    local ta = CreateFrame('Frame',nil,f)
    ta:SetFrameLevel(1) -- same as castbar/healthbar

    ta.left = ta:CreateTexture(nil,'ARTWORK',nil,-1)
    ta.left:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\target-arrow')
    ta.left:SetPoint('RIGHT',f.overlay,'LEFT',14,-1)
    ta.left:SetSize(arrowSize,arrowSize)

    ta.right = ta:CreateTexture(nil,'ARTWORK',nil,-1)
    ta.right:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\target-arrow')
    ta.right:SetPoint('LEFT',f.overlay,'RIGHT',-14,-1)
    ta.right:SetTexCoord(1,0,0,1)
    ta.right:SetSize(arrowSize,arrowSize)

    ta.left:SetVertexColor(unpack(addon.db.profile.general.targetglowcolour))
    ta.right:SetVertexColor(unpack(addon.db.profile.general.targetglowcolour))

    ta:Hide()
    f.targetArrows = ta
end
function mod:PostHide(msg,f)
    f.targetArrows:Hide()
end
function mod:PostTarget(msg,f,is_target)
    if not f.targetArrows then return end
    if is_target then
        f.targetArrows:Show()
    else
        f.targetArrows:Hide()
    end
end
-- register ####################################################################
function mod:OnInitialize()
    self:SetEnabledState(addon.db.profile.general.targetarrows)
end
function mod:OnEnable()
    arrowSize = floor(addon.sizes.tex.targetArrow)

    self:RegisterMessage('KuiNameplates_PostCreate', 'PostCreate')
    self:RegisterMessage('KuiNameplates_PostTarget', 'PostTarget')
    self:RegisterMessage('KuiNameplates_PostHide', 'PostHide')
end
