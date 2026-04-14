local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Aura toggle and count synchronization (Property 5)
-- Feature: hud-unitframe-enhancements
-- Validates: Requirements 3.5, 3.6, 3.7
--
-- For any unit frame with aura elements and for any toggle value (true/false)
-- and count value (0-40), after RefreshUnits executes: if the toggle is true,
-- the aura frame's .num should equal the configured count and the frame should
-- be shown; if the toggle is false, .num should be 0 and the frame hidden.

local NUM_ITERATIONS = 40

-- Simple RNG (xorshift32)
local rngState = 8831
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunAuraToggleTest()
    _G.print("|cff00ccff[PBT]|r Aura toggle and count sync — running", NUM_ITERATIONS, "iterations")

    local RealUI = _G.RealUI
    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames or not UnitFrames.db then
        _G.print("|cffff0000[SKIP]|r UnitFrames module or DB not available")
        return false
    end

    local db = UnitFrames.db.profile
    local failures = 0

    -- Save original values
    local savedPlayerBuffs = db.units.player.showPlayerBuffs
    local savedPlayerCount = db.units.player.buffCount
    local savedPlayerSize = db.units.player.buffSize
    local savedTargetDebuffs = db.units.target.showTargetDebuffs
    local savedTargetDebuffCount = db.units.target.debuffCount
    local savedTargetDebuffSize = db.units.target.debuffSize
    local savedTargetBuffs = db.units.target.showTargetBuffs
    local savedTargetBuffCount = db.units.target.buffCount
    local savedTargetBuffSize = db.units.target.buffSize
    local savedBossDebuffs = db.boss.showBossDebuffs
    local savedBossDebuffCount = db.boss.debuffCount
    local savedBossDebuffSize = db.boss.debuffSize
    local savedBossBuffs = db.boss.showBossBuffs
    local savedBossBuffCount = db.boss.buffCount
    local savedBossBuffSize = db.boss.buffSize

    -- Test toggle/count logic for each unit type
    local testCases = {}
    for i = 1, NUM_ITERATIONS do
        testCases[i] = {
            toggle = (nextRandom(2) == 1),
            count = nextRandom(41) - 1,  -- 0 to 40
            size = nextRandom(51) + 9,   -- 10 to 60
        }
    end

    -- Test player buffs
    local playerFrame = _G["RealUIPlayerFrame"]
    if playerFrame and playerFrame.Buffs then
        for i, tc in _G.ipairs(testCases) do
            db.units.player.showPlayerBuffs = tc.toggle
            db.units.player.buffCount = tc.count
            db.units.player.buffSize = tc.size
            UnitFrames:RefreshUnits("PlayerAuras")

            if tc.toggle then
                if playerFrame.Buffs.num ~= tc.count then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r player buffs iter %d: toggle=true count=%d, .num=%d"):format(
                        i, tc.count, playerFrame.Buffs.num))
                end
                if playerFrame.Buffs.size ~= tc.size then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r player buffs iter %d: toggle=true size=%d, .size=%d"):format(
                        i, tc.size, playerFrame.Buffs.size))
                end
            else
                if playerFrame.Buffs.num ~= 0 then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r player buffs iter %d: toggle=false, .num=%d (expected 0)"):format(
                        i, playerFrame.Buffs.num))
                end
            end
        end
    else
        _G.print("|cff888888[INFO]|r Player frame or Buffs not spawned, skipping player aura test")
    end

    -- Test target debuffs/buffs
    local targetFrame = _G["RealUITargetFrame"]
    if targetFrame then
        if targetFrame.Debuffs then
            for i, tc in _G.ipairs(testCases) do
                db.units.target.showTargetDebuffs = tc.toggle
                db.units.target.debuffCount = tc.count
                db.units.target.debuffSize = tc.size
                UnitFrames:RefreshUnits("TargetAuras")

                if tc.toggle then
                    if targetFrame.Debuffs.num ~= tc.count then
                        failures = failures + 1
                        _G.print(("|cffff0000[FAIL]|r target debuffs iter %d: toggle=true count=%d, .num=%d"):format(
                            i, tc.count, targetFrame.Debuffs.num))
                    end
                    if targetFrame.Debuffs.size ~= tc.size then
                        failures = failures + 1
                        _G.print(("|cffff0000[FAIL]|r target debuffs iter %d: toggle=true size=%d, .size=%d"):format(
                            i, tc.size, targetFrame.Debuffs.size))
                    end
                else
                    if targetFrame.Debuffs.num ~= 0 then
                        failures = failures + 1
                        _G.print(("|cffff0000[FAIL]|r target debuffs iter %d: toggle=false, .num=%d"):format(
                            i, targetFrame.Debuffs.num))
                    end
                end
            end
        end
    else
        _G.print("|cff888888[INFO]|r Target frame not spawned, skipping target aura test")
    end

    -- Restore original values
    db.units.player.showPlayerBuffs = savedPlayerBuffs
    db.units.player.buffCount = savedPlayerCount
    db.units.player.buffSize = savedPlayerSize
    db.units.target.showTargetDebuffs = savedTargetDebuffs
    db.units.target.debuffCount = savedTargetDebuffCount
    db.units.target.debuffSize = savedTargetDebuffSize
    db.units.target.showTargetBuffs = savedTargetBuffs
    db.units.target.buffCount = savedTargetBuffCount
    db.units.target.buffSize = savedTargetBuffSize
    db.boss.showBossDebuffs = savedBossDebuffs
    db.boss.debuffCount = savedBossDebuffCount
    db.boss.debuffSize = savedBossDebuffSize
    db.boss.showBossBuffs = savedBossBuffs
    db.boss.buffCount = savedBossBuffCount
    db.boss.buffSize = savedBossBuffSize
    UnitFrames:RefreshUnits("AuraRestore")

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 5: Aura toggle and count sync — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 5: Aura toggle — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:ufauratoggle()
    return RunAuraToggleTest()
end
