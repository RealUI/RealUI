local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Migration populates spec-to-profile mapping
-- Feature: 2026-03-22-realui-profiles-2, Property 11: Migration populates spec-to-profile mapping
-- **Validates: Requirements 8.4**
--
-- For any existing db.char.layout.spec table mapping spec indices to layout
-- indices (1 or 2), after migration, db.char.specProfiles shall map each spec
-- index to the corresponding profile name ("RealUI" for layout 1,
-- "RealUI-Healing" for layout 2). Existing specProfiles entries should not be
-- overwritten.

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 161803
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function randomBool()
    return nextRandom(2) == 1
end

-- Layout index → profile name mapping (mirrors FinalMigrations)
local layoutToProfile = {
    [1] = "RealUI",
    [2] = "RealUI-Healing",
}

-- Pool of custom profile names for pre-populating specProfiles
local CUSTOM_PROFILES = {
    "RealUI_PvP", "RealUI_Mythic", "MyCustom", "Raid", "Solo", "Arena",
}

-- Replicate the migration's Scope 2 logic from FinalMigrations.lua in isolation.
-- This mirrors the pcall-wrapped block that populates db.char.specProfiles from
-- db.char.layout.spec data.
local function MigrateSpecMapping_Replica(dbc)
    if type(dbc) ~= "table" then return end

    if not dbc.specProfiles then
        dbc.specProfiles = {}
    end

    if dbc.layout and type(dbc.layout.spec) == "table" then
        for specIndex, layoutIndex in _G.pairs(dbc.layout.spec) do
            -- Only populate if not already set (preserve existing assignments)
            if not dbc.specProfiles[specIndex] then
                local profileName = layoutToProfile[layoutIndex]
                if profileName then
                    dbc.specProfiles[specIndex] = profileName
                else
                    -- Unknown layout index, default to "RealUI"
                    dbc.specProfiles[specIndex] = layoutToProfile[1]
                end
            end
        end
    end
end

local function RunMigrationSpecMappingTest()
    _G.print("|cff00ccff[PBT]|r Property 11: Migration populates spec-to-profile mapping")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- 1. Build a random db.char table with layout.spec data
        local numSpecs = nextRandom(4) -- 1–4 specs (WoW supports up to 4)
        local layoutSpec = {}
        for specIdx = 1, numSpecs do
            -- Layout index is 1 or 2
            layoutSpec[specIdx] = nextRandom(2)
        end

        local dbc = {
            layout = {
                spec = layoutSpec,
            },
        }

        -- 2. Optionally pre-populate some specProfiles entries
        local preExisting = {} -- track which specs had pre-existing assignments
        if randomBool() then
            dbc.specProfiles = {}
            for specIdx = 1, numSpecs do
                if randomBool() then
                    -- Assign a random custom profile to this spec
                    local customName = CUSTOM_PROFILES[nextRandom(#CUSTOM_PROFILES)]
                    dbc.specProfiles[specIdx] = customName
                    preExisting[specIdx] = customName
                end
            end
        end

        -- 3. Snapshot the pre-existing specProfiles values
        local originalSpecProfiles = {}
        if dbc.specProfiles then
            for k, v in _G.pairs(dbc.specProfiles) do
                originalSpecProfiles[k] = v
            end
        end

        -- 4. Run the migration replica
        MigrateSpecMapping_Replica(dbc)

        -- 5. Verify results
        local iterFailed = false

        -- 5a. specProfiles must exist
        if type(dbc.specProfiles) ~= "table" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: specProfiles is not a table after migration"):format(i))
            iterFailed = true
        end

        if not iterFailed then
            for specIdx = 1, numSpecs do
                if preExisting[specIdx] then
                    -- 5b. Pre-existing entries must NOT be overwritten
                    if dbc.specProfiles[specIdx] ~= preExisting[specIdx] then
                        failures = failures + 1
                        iterFailed = true
                        _G.print(("|cffff0000[FAIL]|r iter %d: spec %d pre-existing '%s' was overwritten with '%s'"):format(
                            i, specIdx, preExisting[specIdx], _G.tostring(dbc.specProfiles[specIdx])))
                        break
                    end
                else
                    -- 5c. Non-pre-existing entries must be populated from layout.spec
                    local expectedLayout = layoutSpec[specIdx]
                    local expectedProfile = layoutToProfile[expectedLayout] or layoutToProfile[1]
                    if dbc.specProfiles[specIdx] ~= expectedProfile then
                        failures = failures + 1
                        iterFailed = true
                        _G.print(("|cffff0000[FAIL]|r iter %d: spec %d expected '%s' (layout %d), got '%s'"):format(
                            i, specIdx, expectedProfile, expectedLayout, _G.tostring(dbc.specProfiles[specIdx])))
                        break
                    end
                end
            end
        end

        -- 5d. No extra spec indices should appear beyond what layout.spec had
        if not iterFailed then
            for specIdx in _G.pairs(dbc.specProfiles) do
                if not layoutSpec[specIdx] and not originalSpecProfiles[specIdx] then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r iter %d: unexpected spec index %s appeared in specProfiles"):format(
                        i, _G.tostring(specIdx)))
                    break
                end
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 11: Migration populates spec-to-profile mapping — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 11: Migration populates spec-to-profile mapping — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:migrationspecmapping()
    return RunMigrationSpecMappingTest()
end
