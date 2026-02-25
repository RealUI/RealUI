local ADDON_NAME, ns = ...

-- Property Test: Free slot count accuracy
-- Feature: inventory-bank-rewrite, Property 12: Free slot count accuracy
-- Validates: Requirements 4.6
--
-- For any active bank tab, the drop target's displayed count should equal
-- the number of free (empty) slots in that tab's container as reported by
-- C_Container.GetContainerNumFreeSlots().

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

-- All possible bank tab container IDs (Character + Account)
local allBankTabIDs = {
    _G.Enum.BagIndex.CharacterBankTab_1,
    _G.Enum.BagIndex.CharacterBankTab_2,
    _G.Enum.BagIndex.CharacterBankTab_3,
    _G.Enum.BagIndex.CharacterBankTab_4,
    _G.Enum.BagIndex.CharacterBankTab_5,
    _G.Enum.BagIndex.CharacterBankTab_6,
    _G.Enum.BagIndex.AccountBankTab_1,
    _G.Enum.BagIndex.AccountBankTab_2,
    _G.Enum.BagIndex.AccountBankTab_3,
    _G.Enum.BagIndex.AccountBankTab_4,
    _G.Enum.BagIndex.AccountBankTab_5,
}

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 317
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunBankFreeSlotCountTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Free slot count accuracy — running", NUM_ITERATIONS, "iterations")

    local bank = Inventory.bank

    -- Save original C_Container.GetContainerNumFreeSlots so we can mock it
    local originalGetContainerNumFreeSlots = _G.C_Container.GetContainerNumFreeSlots

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate random inputs
        local tabID = allBankTabIDs[nextRandom(#allBankTabIDs)]
        -- Random free slot count: 0 to 98 (bank tabs have up to 98 slots)
        local expectedFreeSlots = nextRandom(99) - 1  -- 0..98

        -- Also test nil activeTabID ~20% of the time
        local useNilTab = (nextRandom(5) == 1)

        -- Mock C_Container.GetContainerNumFreeSlots to return our controlled value
        _G.C_Container.GetContainerNumFreeSlots = function(containerID)
            if containerID == tabID then
                return expectedFreeSlots, 0  -- freeSlots, bagFamily
            end
            return 0, 0
        end

        -- Set up bank state
        if useNilTab then
            bank.activeTabID = nil
        else
            bank.activeTabID = tabID
        end

        -- Call GetNumFreeSlots and verify
        local result = bank:GetNumFreeSlots()

        if useNilTab then
            -- With nil activeTabID, should return 0
            if result ~= 0 then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: activeTabID=nil — expected 0, got %s"):format(
                        i, tostring(result)
                    )
                )
            end
        else
            -- With a valid activeTabID, should return the mocked free slot count
            if result ~= expectedFreeSlots then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: activeTab=%d expectedFree=%d got=%d"):format(
                        i, tabID, expectedFreeSlots, result
                    )
                )
            end
        end
    end

    -- Restore original function
    _G.C_Container.GetContainerNumFreeSlots = originalGetContainerNumFreeSlots

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 12: Free slot count accuracy — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 12: Free slot count accuracy — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:bankfreeslots()
    return RunBankFreeSlotCountTest()
end
