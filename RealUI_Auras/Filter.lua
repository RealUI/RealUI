-- Filter.lua: Filter engine (duration, time-left, spell lists, detectOtherDebuffs)
-- All filter logic is isolated here. Returns true if an aura should be displayed.

local AurasAddon = LibStub("AceAddon-3.0"):GetAddon("RealUI_Auras")
local Filter = {}
AurasAddon.Filter = Filter

local function SafeNumber(value, fallback)
    if type(value) ~= "number" then
        return fallback
    end

    local ok, coerced = pcall(function()
        return value + 0
    end)

    if ok then
        return coerced
    end

    return fallback
end

local function SafeString(value)
    if type(value) ~= "string" then
        return nil
    end

    local ok = pcall(function()
        return strsub(value, 1, 0)
    end)

    if ok then
        return value
    end

    return nil
end

local function SafeListContains(list, key)
    if key == nil then
        return false
    end

    local ok, value = pcall(rawget, list, key)
    return ok and value ~= nil
end

--- Determine whether an aura passes all group filters.
--- @param group table  Group config from AceDB profile
--- @param auraType string  "buff" or "debuff"
--- @param auraData table  Aura data from AuraUtil.ForEachAura callback
--- @return boolean  true if the aura should be displayed
function Filter.ShouldShow(group, auraType, auraData)
    local duration = SafeNumber(auraData.duration, 0)
    local expirationTime = SafeNumber(auraData.expirationTime, 0)

    -- 1. Duration filter: exclude auras whose total duration exceeds the cap
    if group.checkDuration and group.filterDuration and group.filterDuration > 0 then
        if duration > 0 and duration > group.filterDuration then
            return false
        end
    end

    -- 2. No-duration filter: exclude permanent auras when showNoDuration is false
    if not group.showNoDuration and duration == 0 then
        return false
    end

    -- 3. Time-left filter: exclude auras with too much time remaining
    if group.checkTimeLeft and group.filterTimeLeft and group.filterTimeLeft > 0
       and expirationTime > 0 then
        local timeLeft = expirationTime - GetTime()
        if timeLeft > group.filterTimeLeft then
            return false
        end
    end

    -- 4. Spell list exclusion: check the appropriate list for this aura type
    local listKey = (auraType == "buff") and group.filterBuffTable or group.filterDebuffTable
    if listKey then
        local spellLists = RealUI_Auras.db and RealUI_Auras.db.global
                           and RealUI_Auras.db.global.SpellLists
        if spellLists and spellLists[listKey] then
            local list = spellLists[listKey]
            local spellId = SafeNumber(auraData.spellId, nil)
            local spellName = SafeString(auraData.name)

            if SafeListContains(list, spellId) or SafeListContains(list, spellName) then
                return false
            end
        end
    end

    -- 5. detectOtherDebuffs: when false, only show debuffs cast by the player
    if auraType == "debuff" and group.detectOtherDebuffs == false then
        if not auraData.isFromPlayerOrPlayerPet then
            return false
        end
    end

    return true
end
