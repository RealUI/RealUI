--[[
-- Kui_Nameplates
-- By Kesava at curse.com
--
-- changes colour of health bars based on health percentage
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('LowHealthColours', addon.Prototype, 'AceEvent-3.0')

mod.uiName = 'Low health colour'

local LOW_HEALTH_COLOR, PRIORITY, OVER_CLASSCOLOUR

local function OnHealthValueChanged(oldHealth,current)
    local frame = oldHealth:GetParent():GetParent().kui

    if  (frame.tapped) or
        -- don't show on tapped units
        (not OVER_CLASSCOLOUR and frame.player and not frame.friend)
        -- don't show on enemy players
    then
        return
    end

    local percent = frame.health.percent

    if percent <= addon.db.profile.general.lowhealthval then
        frame:SetHealthColour(PRIORITY, unpack(LOW_HEALTH_COLOR))
        frame.stuckLowHealth = true
    elseif frame.stuckLowHealth then
        frame:SetHealthColour(false)
        frame.stuckLowHealth = nil
    end
end

function mod:PostCreate(msg,frame)
    frame.oldHealth:HookScript('OnValueChanged',OnHealthValueChanged)
end

function mod:PostShow(msg,frame)
    -- call our hook onshow, too
    OnHealthValueChanged(frame.oldHealth,frame.oldHealth:GetValue())
end

-- config changed hooks ########################################################
mod:AddConfigChanged('enabled', function(v)
    mod:Toggle(v)
end)
mod:AddConfigChanged('colour', function(v)
    LOW_HEALTH_COLOR = v
end)
mod:AddConfigChanged('over_tankmode', function(v)
    PRIORITY = v and 15 or 5
end)
mod:AddConfigChanged('over_classcolour', function(v)
    OVER_CLASSCOLOUR = v
end)
-- config hooks ################################################################
function mod:GetOptions()
    return {
        enabled = {
            name = 'Change colour of health bars at low health',
            desc = 'Change the colour of low health units\' health bars. "Low health" is determined by the "Low health value" option under "General display".',
            type = 'toggle',
            width = 'full',
            order = 10
        },
        over_tankmode = {
            name = 'Override tank mode',
            desc = 'When using tank mode, allow the low health colour to override tank mode colouring',
            type = 'toggle',
            order = 20
        },
        over_classcolour = {
            name = 'Show on enemy players',
            desc = 'Show on enemy players - i.e. override class colours',
            type = 'toggle',
            order = 30
        },
        colour = {
            name = 'Low health colour',
            desc = 'The colour to use',
            type = 'color',
            order = 40
        }
    }
end
function mod:OnInitialize()
    self.db = addon.db:RegisterNamespace(self.moduleName, {
        profile = {
            enabled = true,
            over_tankmode = false,
            over_classcolour = true,
            colour = { 1, 1, .85 }
        }
    })

    addon:InitModuleOptions(self)

    LOW_HEALTH_COLOR = self.db.profile.colour
    PRIORITY = self.db.profile.over_tankmode and 15 or 5
    OVER_CLASSCOLOUR = self.db.profile.over_classcolour

    self:SetEnabledState(self.db.profile.enabled)
end
function mod:OnEnable()
    self:RegisterMessage('KuiNameplates_PostCreate', 'PostCreate')
    self:RegisterMessage('KuiNameplates_PostShow', 'PostShow')
end
function mod:OnDisable()
    self:UnregisterMessage('KuiNameplates_PostCreate', 'PostCreate')
    self:UnregisterMessage('KuiNameplates_PostShow', 'PostShow')
end
