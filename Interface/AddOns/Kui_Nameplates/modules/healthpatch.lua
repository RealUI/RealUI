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

function mod:GUIDStored(msg,f,unit)
    f.health.health_max_snapshot = UnitHealthMax(unit)
    f:OnHealthValueChanged()

    if UnitIsPlayer(unit) then
        -- store health with GUID
        health_cache[f.guid] = f.health.health_max_snapshot
        tinsert(cache_index, f.guid)
    else
        -- store health with name
        -- since most NPCs with the same name have equal-ish health
        health_cache[f.name.text] = f.health.health_max_snapshot
        tinsert(cache_index, f.name.text)
    end

    if #cache_index > 100 then
        health_cache[tremove(cache_index, 1)] = nil
    end
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
    self:RegisterMessage('KuiNameplates_PostHide','PostHide')
    self:RegisterMessage('KuiNameplates_PostShow','PostShow')
end
