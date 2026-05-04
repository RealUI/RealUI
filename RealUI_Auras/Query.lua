-- Query.lua: Aura query engine (AuraUtil wrappers, sort, group combiner)
-- NOTE: Filter.lua loads AFTER Query.lua in the TOC, so AurasAddon.Filter
-- does not exist at file scope. Reference it lazily inside functions.

local AurasAddon = LibStub("AceAddon-3.0"):GetAddon("RealUI_Auras")
local Query = {}
AurasAddon.Query = Query

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

local function SafeTexture(value)
    if type(value) == "number" then
        local textureID = SafeNumber(value, nil)
        if textureID and textureID > 0 then
            return textureID
        end
        return nil
    end

    if type(value) == "string" then
        local texturePath = SafeString(value)
        if texturePath and texturePath ~= "" then
            return texturePath
        end
    end

    return nil
end

---------------------------------------------------------------------------
-- 4.4  Sort comparators
---------------------------------------------------------------------------

local function SortByTimeAsc(a, b)
    -- Permanent auras (duration == 0) sort last
    if a.duration == 0 and b.duration ~= 0 then return false end
    if b.duration == 0 and a.duration ~= 0 then return true end
    if a.expirationTime ~= b.expirationTime then
        return a.expirationTime < b.expirationTime
    end
    return (a.auraInstanceID or 0) < (b.auraInstanceID or 0)
end

local function SortByTimeDesc(a, b)
    return SortByTimeAsc(b, a)
end

local Sort = {}

function Sort.Apply(results, group)
    if not group.timeSort then return end
    if group.reverseSort then
        table.sort(results, SortByTimeDesc)
    else
        table.sort(results, SortByTimeAsc)
    end
end

---------------------------------------------------------------------------
-- 4.2  Query.BuildFilter(group, auraType)
-- Returns a WoW filter string: "HELPFUL" or "HARMFUL", optionally with
-- "|PLAYER" appended when the group restricts to player-cast auras.
---------------------------------------------------------------------------

function Query.BuildFilter(group, auraType)
    local filter
    if auraType == "buff" then
        filter = "HELPFUL"
        if group.detectBuffsCastBy == "player" then
            filter = filter .. "|PLAYER"
        end
    else
        filter = "HARMFUL"
        if group.detectDebuffsCastBy == "player" then
            filter = filter .. "|PLAYER"
        end
    end
    return filter
end

---------------------------------------------------------------------------
-- 4.3  Query.GetAuras(group, auraType)
-- Queries all matching auras for a group via AuraUtil.ForEachAura,
-- filters through Filter.ShouldShow, copies relevant fields, sorts,
-- and caps at group.maxBars.
---------------------------------------------------------------------------

function Query.GetAuras(group, auraType)
    local Filter = AurasAddon.Filter

    -- Determine which unit to query
    local unit
    if auraType == "buff" then
        unit = group.detectBuffsMonitor or group.unit
    else
        unit = group.detectDebuffsMonitor or group.unit
    end

    if not UnitExists(unit) then return {} end

    local filter = Query.BuildFilter(group, auraType)
    local results = {}

    AuraUtil.ForEachAura(unit, filter, nil, function(auraData)
        local ok, shouldShow = pcall(Filter.ShouldShow, group, auraType, auraData)
        if ok and shouldShow then
            local name = SafeString(auraData.name)
            local spellId = SafeNumber(auraData.spellId, nil)
            local icon = SafeTexture(auraData.icon)

            if icon == nil and spellId then
                local okSpellTexture, spellTexture = pcall(GetSpellTexture, spellId)
                if okSpellTexture then
                    icon = SafeTexture(spellTexture)
                end
            end

            -- Secret/forbidden aura payloads can pass filter checks but still
            -- have no displayable data. Skip them to avoid empty aura boxes.
            if icon == nil then
                return
            end

            local duration = SafeNumber(auraData.duration, 0)
            local expirationTime = SafeNumber(auraData.expirationTime, 0)

            -- Copy fields into a new table — WoW may reuse the auraData object
            results[#results + 1] = {
                name           = name,
                icon           = icon,
                applications   = SafeNumber(auraData.applications, 0),
                dispelName     = SafeString(auraData.dispelName),
                duration       = duration,
                expirationTime = expirationTime,
                sourceUnit     = SafeString(auraData.sourceUnit),
                spellId        = spellId,
                isFromPlayer   = auraData.isFromPlayerOrPlayerPet,
                auraInstanceID = SafeNumber(auraData.auraInstanceID, 0),
                timeMod        = SafeNumber(auraData.timeMod, 1),
                isDebuff       = (auraType == "debuff"),
            }
        end
        -- Return nil to continue iterating (no early exit)
    end, true)  -- usePackedAura = true: receive auraData as a table, not unpacked args

    -- Sort results
    Sort.Apply(results, group)

    -- Cap at maxBars
    if group.maxBars and #results > group.maxBars then
        for i = group.maxBars + 1, #results do
            results[i] = nil
        end
    end

    return results
end

---------------------------------------------------------------------------
-- 4.5  Query.GetAllForGroup(group)
-- Combines buff and debuff queries according to group.detectBuffs /
-- group.detectDebuffs, merges result lists, re-sorts, and caps at maxBars.
---------------------------------------------------------------------------

function Query.GetAllForGroup(group)
    local results = {}

    if group.detectBuffs then
        local buffs = Query.GetAuras(group, "buff")
        for _, a in ipairs(buffs) do
            results[#results + 1] = a
        end
    end

    if group.detectDebuffs then
        local debuffs = Query.GetAuras(group, "debuff")
        for _, a in ipairs(debuffs) do
            results[#results + 1] = a
        end
    end

    -- Re-sort the merged list
    Sort.Apply(results, group)

    -- Cap at maxBars
    if group.maxBars and #results > group.maxBars then
        for i = group.maxBars + 1, #results do
            results[i] = nil
        end
    end

    return results
end
