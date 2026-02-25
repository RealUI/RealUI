local ADDON_NAME, ns = ...

-- Property Test: Tab selection displays correct items
-- Feature: inventory-bank-rewrite, Property 7: Tab selection displays correct items
-- Validates: Requirements 3.2
--
-- For any tab selection, the bank frame should iterate only the selected tab's
-- container ID and display items from that container. Specifically:
-- 1. After SetActiveTab(tabID), bagIDs contains exactly {tabID}
-- 2. Update() is called, which iterates only that container ID
-- 3. Setting tabID to nil results in an empty bagIDs and no iteration

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

-- Tab ID ranges per bank type (mirrors bankTypeConfig)
local tabRanges = {
    [_G.Enum.BankType.Character] = {
        _G.Enum.BagIndex.CharacterBankTab_1,
        _G.Enum.BagIndex.CharacterBankTab_2,
        _G.Enum.BagIndex.CharacterBankTab_3,
        _G.Enum.BagIndex.CharacterBankTab_4,
        _G.Enum.BagIndex.CharacterBankTab_5,
        _G.Enum.BagIndex.CharacterBankTab_6,
    },
    [_G.Enum.BankType.Account] = {
        _G.Enum.BagIndex.AccountBankTab_1,
        _G.Enum.BagIndex.AccountBankTab_2,
        _G.Enum.BagIndex.AccountBankTab_3,
        _G.Enum.BagIndex.AccountBankTab_4,
        _G.Enum.BagIndex.AccountBankTab_5,
    },
}

-- All bank tab IDs in a flat list
local allBankTabIDs = {}
for _, range in next, tabRanges do
    for _, id in ipairs(range) do
        allBankTabIDs[#allBankTabIDs + 1] = id
    end
end

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 709
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunTabSelectionTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Tab selection displays correct items — running", NUM_ITERATIONS, "iterations")

    local bank = Inventory.bank

    -- Save originals
    local originalUpdate = bank.Update

    -- Track which bagIDs were iterated during Update
    local iteratedBagIDs = {}
    local updateCalled = false

    bank.Update = function(self)
        updateCalled = true
        -- Capture the bagIDs that would be iterated (same as MainBagMixin:Update does)
        for _, bagID in self:IterateBagIDs() do
            iteratedBagIDs[#iteratedBagIDs + 1] = bagID
        end
        -- Don't call original — avoid side effects from actual item iteration
    end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Decide test scenario: ~80% select a real tab, ~20% select nil (no tabs purchased)
        local selectNil = (nextRandom(5) == 1)
        local tabID

        if selectNil then
            tabID = nil
        else
            tabID = allBankTabIDs[nextRandom(#allBankTabIDs)]
        end

        -- Reset tracking
        updateCalled = false
        _G.wipe(iteratedBagIDs)

        -- Call SetActiveTab
        bank:SetActiveTab(tabID)

        -- Check 1: activeTabID should match what we set
        if bank.activeTabID ~= tabID then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: activeTabID expected %s, got %s"):format(
                    i, tostring(tabID), tostring(bank.activeTabID)
                )
            )
        end

        -- Check 2: bagIDs should contain exactly {tabID} or be empty if nil
        local expectedCount = tabID and 1 or 0
        if #bank.bagIDs ~= expectedCount then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: bagIDs length expected %d, got %d"):format(
                    i, expectedCount, #bank.bagIDs
                )
            )
        elseif tabID and bank.bagIDs[1] ~= tabID then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: bagIDs[1] expected %s, got %s"):format(
                    i, tostring(tabID), tostring(bank.bagIDs[1])
                )
            )
        end

        -- Check 3: Update should have been called
        if not updateCalled then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: Update was not called after SetActiveTab(%s)"):format(
                    i, tostring(tabID)
                )
            )
        end

        -- Check 4: IterateBagIDs should yield exactly the selected tab (or nothing)
        if #iteratedBagIDs ~= expectedCount then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: IterateBagIDs yielded %d IDs, expected %d"):format(
                    i, #iteratedBagIDs, expectedCount
                )
            )
        elseif tabID and iteratedBagIDs[1] ~= tabID then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: IterateBagIDs yielded %s, expected %s"):format(
                    i, tostring(iteratedBagIDs[1]), tostring(tabID)
                )
            )
        end

        -- Check 5: Switching tabs should replace, not accumulate bagIDs.
        -- Pick a second different tab and verify bagIDs is replaced.
        if tabID and #allBankTabIDs > 1 then
            local secondTabID
            repeat
                secondTabID = allBankTabIDs[nextRandom(#allBankTabIDs)]
            until secondTabID ~= tabID

            _G.wipe(iteratedBagIDs)
            updateCalled = false

            bank:SetActiveTab(secondTabID)

            if #bank.bagIDs ~= 1 then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: after tab switch, bagIDs length expected 1, got %d"):format(
                        i, #bank.bagIDs
                    )
                )
            elseif bank.bagIDs[1] ~= secondTabID then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: after tab switch, bagIDs[1] expected %s, got %s"):format(
                        i, tostring(secondTabID), tostring(bank.bagIDs[1])
                    )
                )
            end
        end
    end

    -- Restore original Update
    bank.Update = originalUpdate

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 7: Tab selection displays correct items — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 7: Tab selection displays correct items — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:banktabselection()
    return RunTabSelectionTest()
end
