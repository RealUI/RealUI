--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
--
-- Provides health snapshot upon GUID storage for 6.2.2 workaround
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('HealthPatch', 'AceEvent-3.0')

local cache_index = {}
local health_cache = {}

function mod:UnitStored(msg,unit,name,guid)
    if UnitIsPlayer(unit) then
        -- store health with GUID
        health_cache[guid] = UnitHealthMax(unit)
        tinsert(cache_index, guid)
    else
        -- store health with name
        -- since most NPCs with the same name have equal-ish health
        health_cache[name] = UnitHealthMax(unit)
        tinsert(cache_index, name)
    end

    if #cache_index > 100 then
        health_cache[tremove(cache_index, 1)] = nil
    end
end
function mod:GUIDStored(msg,f,unit)
    f.health.health_max_snapshot = UnitHealthMax(unit)
    f:OnHealthValueChanged()

    self:UnitStored(nil, unit, f.name.text, f.guid)
end
function mod:GUIDAssumed(msg,f)
    self:PostShow(nil,f)
end
function mod:PostHide(msg,f)
    f.health.health_max_snapshot = nil
end
function mod:PostShow(msg,f)
    if f.guid and health_cache[f.guid] then
        f.health.health_max_snapshot = health_cache[f.guid]
    elseif f.name.text and health_cache[f.name.text] then
        f.health.health_max_snapshot = health_cache[f.name.text]
    else
        return
    end

    f:OnHealthValueChanged()
end
function mod:OnInitialize()
    self:SetEnabledState(true)
end
function mod:OnEnable()
    self:RegisterMessage('KuiNameplates_GUIDStored','GUIDStored')
    self:RegisterMessage('KuiNameplates_GUIDAssumed','GUIDAssumed')
    self:RegisterMessage('KuiNameplates_UnitStored','UnitStored')
    self:RegisterMessage('KuiNameplates_PostHide','PostHide')
    self:RegisterMessage('KuiNameplates_PostShow','PostShow')
end
