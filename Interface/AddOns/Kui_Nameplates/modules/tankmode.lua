--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('TankMode', addon.Prototype, 'AceEvent-3.0')
local class, tankmode

local profile_tankmode

mod.uiName = 'Threat'

-------------------------------------------------------- threat bracket stuff --
local function ShowThreatBrackets(frame,...)
    if not frame.threatBrackets then return end
    if ... == false then
        frame.threatBrackets:Hide()
    else
        frame.threatBrackets:SetVertexColor(...)
        frame.threatBrackets:Show()
    end
end
do
    local brackets = {
        { 'BOTTOMLEFT',  nil, 'TOPLEFT' },
        { 'BOTTOMRIGHT', nil, 'TOPRIGHT' },
        { 'TOPLEFT',     nil, 'BOTTOMLEFT' },
        { 'TOPRIGHT',    nil, 'BOTTOMRIGHT' }
    }

    -- pixel positions
    local leftmost = 0.28125
    local bottommost = 0
    local default_size = 18
    local ratio = 2

    local size, x_offset, y_offset

    function mod:UpdateThreatBracketScaling()
        size = default_size * self.db.profile.brackets.scale
        x_offset = (size*ratio) * leftmost
        y_offset = floor((size * bottommost) - 2)
    end

    function mod:CreateThreatBrackets(frame)
        local tb = CreateFrame('Frame',nil,frame.health)
        tb:SetFrameLevel(1) -- same as castbar/healthbar
        tb:Hide()

        for k,v in ipairs(brackets) do
            local b = tb:CreateTexture(nil,'ARTWORK',nil,-1)
            b:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\threat-bracket')
            tb[k] = b
        end

        tb.SetVertexColor = function(self,...)
            for k,b in ipairs(self) do
                b:SetVertexColor(...)
            end
        end

        frame.threatBrackets = tb

        self:UpdateThreatBrackets(frame)
    end
    function mod:UpdateThreatBrackets(frame)
        -- apply scaling + positions to threat brackets on given frame
        if not frame.threatBrackets then return end
        for k,v in ipairs(brackets) do
            local b = frame.threatBrackets[k]
            b:SetSize(size*ratio,size)

            if k % 2 == 0 then
                v[4] = x_offset - 1
            else
                v[4] = -x_offset
            end

            if k <= 2 then
                v[5] = -y_offset
            else
                v[5] = y_offset - .5
            end

            if k == 2 then
                b:SetTexCoord(1,0,0,1)
            elseif k == 3 then
                b:SetTexCoord(0,1,1,0)
            elseif k == 4 then
                b:SetTexCoord(1,0,1,0)
            end

            v[2] = frame.health
            b:SetPoint(unpack(v))
        end
    end
end
--------------------------------------------------------- tank mode functions --
function mod:Update()
    if profile_tankmode.enabled == 1 then
        -- smart - judge by spec
        local spec = GetSpecialization()
        local role

        if class == 'WARRIOR' and GetShapeshiftForm() == 4 then
            -- no tank for gladiator stance
            role = nil
        else
            role = spec and GetSpecializationRole(spec) or nil
        end

        if role == 'TANK' then
            tankmode = true
        else
            tankmode = false
        end
    else
        tankmode = (profile_tankmode.enabled == 3)
    end
end

function mod:Toggle()
    if profile_tankmode.enabled == 1 then
        -- smart tank mode, listen for spec changes
        self:RegisterEvent('PLAYER_TALENT_UPDATE', 'Update')
        self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'Update')

        -- on a warrior, watch for gladiator stance
        if class == 'WARRIOR' then
            self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', 'Update')
        end
    else
        self:UnregisterEvent('PLAYER_TALENT_UPDATE')
        self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED')
        self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM')
    end

    self:Update()
end

function mod:ThreatUpdate(frame)
    frame.hasThreat = true
    -- we are holding threat if the default glow is red
    frame.holdingThreat = frame.glow.r > .9 and (frame.glow.g + frame.glow.b) < .1

    if not frame.targetGlow or not frame.target then
        if tankmode then
            -- set glow to tank colour unless this is the current target
            frame:SetGlowColour(unpack(profile_tankmode.glowcolour))
        else
            -- not in tank mode; set glow to default ui's colour
            frame:SetGlowColour(frame.glow.r, frame.glow.g, frame.glow.b)
        end
    end

    if tankmode then
        -- also change health bar colour in tank mode
        if frame.holdingThreat then
            frame:SetHealthColour(10, unpack(profile_tankmode.barcolour))
            ShowThreatBrackets(frame, unpack(profile_tankmode.barcolour))
        else
            -- losing/gaining threat
            frame:SetHealthColour(10, unpack(profile_tankmode.midcolour))
            ShowThreatBrackets(frame, unpack(profile_tankmode.midcolour))
        end
    else
        -- not in tank mode; use default glow colour for brackets, too
        ShowThreatBrackets(frame, frame.glow.r, frame.glow.g, frame.glow.b)
    end
end
function mod:ThreatClear(frame)
    frame:SetHealthColour(false)
    ShowThreatBrackets(frame,false)
end
-------------------------------------------------------------------- messages --
function mod:PostCreate(msg,f)
    self:CreateThreatBrackets(f)
end
function mod:PostHide(msg,f)
    ShowThreatBrackets(f,false)
end
---------------------------------------------------- Post db change functions --
mod:AddConfigChanged('enabled', function()
    mod:Toggle()
end)
mod:AddConfigChanged({'brackets','scale'},
    function()
        mod:UpdateThreatBracketScaling()
    end,
    function(f)
        mod:UpdateThreatBrackets(f)
    end
)
-------------------------------------------------------------------- Register --
function mod:GetOptions()
    return {
        tankmode = {
            name = 'Tank mode',
            type = 'group',
            inline = true,
            order = 10,
            disabled = function(info)
                return mod.db.profile.tankmode.enabled == 2
            end,
            args = {
                enabled = {
                    name = 'Enable tank mode',
                    desc = 'Change the colour of a plate\'s health bar and border when you have threat on its unit.\n\nSelecting "Smart" (default) will automatically enable or disable tank mode based on your current specialisation\'s role.',
                    type = 'select',
                    values = { 'Smart', 'Disabled', 'Enabled' },
                    order = 0,
                    disabled = false
                },
                barcolour = {
                    name = 'Bar colour',
                    desc = 'The bar colour to use when you have threat',
                    type = 'color',
                    order = 10
                },
                midcolour = {
                    name = 'Transitional colour',
                    desc = 'The bar colour to use when you are losing or gaining threat.',
                    type = 'color',
                    order = 20
                },
                glowcolour = {
                    name = 'Glow colour',
                    desc = 'The glow (border) colour to use when you have threat',
                    type = 'color',
                    hasAlpha = true,
                    order = 30
                }
            }
        },
        brackets = {
            name = 'Threat brackets',
            type = 'group',
            inline = true,
            order = 20,
            disabled = function(info)
                return not mod.db.profile.brackets.enable_brackets
            end,
            args = {
                enable_brackets = {
                    name = 'Show threat brackets',
                    desc = 'Show threat brackets when you have threat on a nameplate. Kind of like target arrows, but for threat. In tank mode they will inherit the bar colour set above. Otherwise they will use the default glow colour.',
                    type = 'toggle',
                    order = 10,
                    disabled = false
                },
                scale = {
                    name = 'Threat bracket scale',
                    desc = 'The scale of the threat bracket textures',
                    type = 'range',
                    order = 20,
                    min = 0.1,
                    softMin = 0.5,
                    softMax = 2
                }
            }
        },
    }
end

function mod:configChangedListener()
    profile_tankmode = self.db.profile.tankmode
end

function mod:OnInitialize()
    self.db = addon.db:RegisterNamespace(self.moduleName, {
        profile = {
            tankmode = {
                enabled = 1,
                barcolour = { .2, .9, .1 },
                midcolour = { 1, .5, 0 },
                glowcolour = { 1, 0, 0, 1 },
            },
            brackets = {
                enable_brackets = true,
                scale = 1,
            },
        }
    })

    addon:InitModuleOptions(self)
    self:UpdateThreatBracketScaling()
    self:SetEnabledState(true)
end

function mod:OnEnable()
    class = select(2,UnitClass('player'))

    if self.db.profile.brackets.enable_brackets then
        self:RegisterMessage('KuiNameplates_PostCreate', 'PostCreate')
        self:RegisterMessage('KuiNameplates_PostHide', 'PostHide')
    end

    self:Toggle()
end
