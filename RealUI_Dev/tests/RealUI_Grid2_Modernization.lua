local ADDON_NAME, ns = ... -- luacheck: ignore

-- Verification Test: Grid2 Modernization
-- Feature: grid2-modernization
-- Validates: Requirements 1–11
--
-- Verifies that the shipped Grid2 profiles in Grid2DB match the
-- modernized DB_VERSION 106 expectations after private.AddOns.Grid2() runs.

local PROFILE_NAMES = { "RealUI", "RealUI-Healing" }

local OBSOLETE_STATUSES = {
    "buff-Grace-mine",
    "buff-DivineAegis",
    "buff-InnerFire",
    "buff-SpiritShell-mine",
    "buff-EternalFlame-mine",
    "debuff-WeakenedSoul",
}

local function RunGrid2ModernizationTest()
    _G.print("|cff00ccff[TEST]|r Grid2 Modernization — verification")

    local Grid2DB = _G.Grid2DB
    if not Grid2DB then
        -- Grid2 is an optional user install since de-bundling (2026-08-15);
        -- its absence is expected, not a failure.
        _G.print("|cffffcc00[SKIP]|r Grid2 not loaded — test skipped (Grid2 is optional).")
        return true
    end

    local profiles = Grid2DB.profiles
    if not profiles then
        _G.print("|cffff0000[FAIL]|r Grid2DB.profiles not found")
        return false
    end

    local failures = 0
    local checks = 0

    local function check(condition, msg)
        checks = checks + 1
        if not condition then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r " .. msg)
        end
    end

    -- Test both profiles
    for _, profileName in _G.ipairs(PROFILE_NAMES) do
        local profile = profiles[profileName]
        if not profile then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r Profile %q not found in Grid2DB.profiles"):format(profileName))
        else
            -- Req 1.1: versions.Grid2 == 106
            check(profile.versions and profile.versions.Grid2 == 106,
                profileName .. ": versions.Grid2 should be 106, got " ..
                _G.tostring(profile.versions and profile.versions.Grid2))

            -- Req 1.2: versions.Grid2RaidDebuffs == 4
            check(profile.versions and profile.versions.Grid2RaidDebuffs == 4,
                profileName .. ": versions.Grid2RaidDebuffs should be 4, got " ..
                _G.tostring(profile.versions and profile.versions.Grid2RaidDebuffs))

            -- Req 2.1, 2.2: heals indicator has no anchorTo
            local heals = profile.indicators and profile.indicators["heals"]
            check(heals and heals.anchorTo == nil,
                profileName .. ": heals indicator should not have anchorTo")

            -- Req 3.1, 3.2: background indicator exists with type "background"
            local bg = profile.indicators and profile.indicators["background"]
            check(bg and bg.type == "background",
                profileName .. ": background indicator should exist with type 'background'")

            -- Req 4 (inverted for Grid2 4.0): private-auras-dispel must be
            -- ABSENT — the type never registers on 12.1 and Grid2's own DB
            -- migration deletes the indicator
            local pad = profile.indicators and profile.indicators["private-auras-dispel"]
            check(pad == nil,
                profileName .. ": private-auras-dispel indicator should be absent (Grid2 4.0)")
            check(not (profile.statusMap and profile.statusMap["private-auras-dispel"]),
                profileName .. ": private-auras-dispel statusMap should be absent (Grid2 4.0)")

            -- Grid2 4.0: mine filters must be numeric (boolean true is
            -- dropped by Grid2's <200 migration)
            for _, mineStatus in _G.ipairs({"buff-Renew-mine", "buff-PrayerOfMending-mine"}) do
                local status = profile.statuses and profile.statuses[mineStatus]
                if status then
                    check(status.mine == 1,
                        profileName .. ": " .. mineStatus .. " should have mine = 1")
                end
            end

            -- Req 5.1, 5.2: threat status has blinkThreshold, no disableBlink
            local threat = profile.statuses and profile.statuses["threat"]
            check(threat and threat.blinkThreshold == true,
                profileName .. ": threat status should have blinkThreshold = true")
            check(threat and threat.disableBlink == nil,
                profileName .. ": threat status should not have disableBlink")

            -- Property 1 / Req 6.1–6.7: No obsolete statuses in statuses or statusMap
            for _, obsolete in _G.ipairs(OBSOLETE_STATUSES) do
                -- Check statuses table
                check(not (profile.statuses and profile.statuses[obsolete]),
                    profileName .. ": obsolete status '" .. obsolete .. "' should not be in statuses")

                -- Check statusMap (all indicator entries)
                if profile.statusMap then
                    for indicator, mappings in _G.pairs(profile.statusMap) do
                        check(mappings[obsolete] == nil,
                            profileName .. ": statusMap[" .. indicator .. "] should not reference '" .. obsolete .. "'")
                    end
                end
            end

            -- Req 9.1, 9.2: hideBlizzard table
            local hb = profile.hideBlizzard
            check(hb and hb.raid == true,
                profileName .. ": hideBlizzard.raid should be true")
            check(hb and hb.party == true,
                profileName .. ": hideBlizzard.party should be true")

            -- Req 11.1, 11.2: tooltip indicator has displayUnitOOC = true
            local tooltip = profile.indicators and profile.indicators["tooltip"]
            check(tooltip and tooltip.displayUnitOOC == true,
                profileName .. ": tooltip indicator should have displayUnitOOC = true")
        end
    end

    -- Req 7.1, 7.2: raid-debuffs status has empty debuffs in RealUI-Healing
    local healingProfile = profiles["RealUI-Healing"]
    if healingProfile then
        local rd = healingProfile.statuses and healingProfile.statuses["raid-debuffs"]
        check(rd ~= nil,
            "RealUI-Healing: raid-debuffs status should exist")
        check(rd and rd.debuffs and _G.next(rd.debuffs) == nil,
            "RealUI-Healing: raid-debuffs.debuffs should be empty table")

        -- Grid2 4.0: consolidated HoT status drives icon-left (one aura
        -- slot per icon indicator)
        local myHoTs = healingProfile.statuses and healingProfile.statuses["buffs-MyHoTs"]
        check(myHoTs ~= nil,
            "RealUI-Healing: buffs-MyHoTs status should exist (Grid2 4.0 icon-left consolidation)")
        local iconLeft = healingProfile.statusMap and healingProfile.statusMap["icon-left"]
        check(iconLeft and iconLeft["buffs-MyHoTs"] ~= nil,
            "RealUI-Healing: icon-left should map buffs-MyHoTs")
        check(not (iconLeft and iconLeft["raid-icon-player"]),
            "RealUI-Healing: icon-left should not map raid-icon-player (mixed-indicator overlap)")
    end

    -- Req 8.1, 8.2, 8.3: Grid2RaidDebuffs enabledModules
    local namespaces = Grid2DB.namespaces
    local rdNamespace = namespaces and namespaces.Grid2RaidDebuffs
    local rdProfiles = rdNamespace and rdNamespace.profiles
    local rdHealing = rdProfiles and rdProfiles["RealUI-Healing"]
    if rdHealing then
        local em = rdHealing.enabledModules
        check(em and em["Midnight"] == true,
            "Grid2RaidDebuffs: enabledModules should include 'Midnight'")
        check(em and em["Mythic+ Dungeons"] == true,
            "Grid2RaidDebuffs: enabledModules should include 'Mythic+ Dungeons'")
        check(em and em["The War Within"] == nil,
            "Grid2RaidDebuffs: enabledModules should not include 'The War Within'")
    else
        failures = failures + 1
        _G.print("|cffff0000[FAIL]|r Grid2RaidDebuffs namespace profile 'RealUI-Healing' not found")
    end

    -- Summary
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Grid2 Modernization — all %d checks passed"):format(checks))
    else
        _G.print(("|cffff0000[FAIL]|r Grid2 Modernization — %d failures out of %d checks"):format(failures, checks))
    end

    return failures == 0
end

function ns.commands:grid2mod()
    return RunGrid2ModernizationTest()
end
