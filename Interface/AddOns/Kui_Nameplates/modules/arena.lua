--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
--
-- Modifications for plates while in an arena
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('Arena', addon.Prototype, 'AceEvent-3.0')

mod.uiName = "Arena modifications"

local in_arena

function mod:IsArenaPlate(frame)
    if frame.friend then
        frame.level:SetText()
        return
    end

    for i = 1, GetNumArenaOpponents() do
        if frame.name.text == GetUnitName('arena'..i) then
            frame.level:SetText(i)
            return
        elseif frame.name.text == GetUnitName('arenapet'..i) then
            frame.level:SetText(i..'*')
            return
        end
    end

    -- unhandled name
    frame.level:SetText('?')
end

function mod:PostShow(msg, frame)
    if in_arena and not frame.friend then
        self:IsArenaPlate(frame)
        frame.level:SetWidth(0)
        frame.level:Show()
    end
end

function mod:UNIT_NAME_UPDATE(event, unit)
    if not strfind(unit, "^arena") then return end

    local frame = addon:GetUnitPlate(unit)
    if not frame then return end
    if frame.friend then return end

    self:IsArenaPlate(frame)
    frame.level:SetWidth(0)
    frame.level:Show()
end

function mod:PLAYER_ENTERING_WORLD()
    local in_instance, instance_type = IsInInstance()
    if in_instance and instance_type == 'arena' then
        in_arena = true
        self:RegisterMessage('KuiNameplates_PostShow', 'PostShow')
        self:RegisterEvent('UNIT_NAME_UPDATE')
    else
        in_arena = nil
        self:UnregisterMessage('KuiNameplates_PostShow', 'PostShow')
        self:UnregisterEvent('UNIT_NAME_UPDATE')
    end
end

function mod:OnInitialize()
    self:SetEnabledState(true)
end

function mod:OnEnable()
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
end
