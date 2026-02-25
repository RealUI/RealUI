local ADDON_NAME, ns = ...

-- Property Test: Default bank type is first available
-- Feature: inventory-bank-rewrite, Property 4: Default bank type is first available
-- Validates: Requirements 2.2
--
-- For any set of viewable bank types, when the bank frame opens, the active
-- bank type should be the first viewable type in enumeration order.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

-- Canonical enumeration order: Character first, then Account
local bankTypesOrdered = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 421
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function nextBool()
    return nextRandom(2) == 1
end

local function RunBankDefaultTypeTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    local bank = Inventory.bank
    if not bank.bankTypeSwitcher then
        _G.print("|cffff0000[ERROR]|r BankTypeSwitcher not found on bank frame.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Default bank type is first available — running", NUM_ITERATIONS, "iterations")

    local switcher = bank.bankTypeSwitcher

    -- Mock C_Bank.CanViewBank to return controlled values
    local originalCanViewBank = _G.C_Bank.CanViewBank
    local canViewOverrides = {}
    _G.C_Bank.CanViewBank = function(bankType)
        if canViewOverrides[bankType] ~= nil then
            return canViewOverrides[bankType]
        end
        return false
    end

    -- Mock C_Bank.FetchPurchasedBankTabData to return empty table (called during SetBankType)
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    _G.C_Bank.FetchPurchasedBankTabData = function() return {} end

    -- Track which bank type SetBankType was called with
    local originalSetBankType = bank.SetBankType
    local lastSetBankType
    bank.SetBankType = function(self, bankType)
        lastSetBankType = bankType
    end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate random CanViewBank results, ensuring at least one is true
        local canViewCharacter = nextBool()
        local canViewAccount = nextBool()

        -- Ensure at least one type is viewable (skip all-false cases)
        if not canViewCharacter and not canViewAccount then
            -- Force one randomly
            if nextBool() then
                canViewCharacter = true
            else
                canViewAccount = true
            end
        end

        canViewOverrides[_G.Enum.BankType.Character] = canViewCharacter
        canViewOverrides[_G.Enum.BankType.Account] = canViewAccount

        -- Determine expected default: first viewable in enumeration order
        local expectedDefault
        for _, bankType in ipairs(bankTypesOrdered) do
            if canViewOverrides[bankType] then
                expectedDefault = bankType
                break
            end
        end

        -- Reset and call Refresh
        lastSetBankType = nil
        switcher.activeType = nil
        switcher:Refresh()

        -- Verify the active type matches expected default
        local activeType = switcher:GetActiveType()

        if activeType ~= expectedDefault then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: expected default=%d got=%s (canView: char=%s acct=%s)"):format(
                    i,
                    expectedDefault,
                    tostring(activeType),
                    tostring(canViewCharacter),
                    tostring(canViewAccount)
                )
            )
        end

        -- Also verify SetBankType was called with the correct default
        if lastSetBankType ~= expectedDefault then
            -- Only report if not already counted as failure above
            if activeType == expectedDefault then
                failures = failures + 1
            end
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: SetBankType called with %s, expected %d"):format(
                    i,
                    tostring(lastSetBankType),
                    expectedDefault
                )
            )
        end
    end

    -- Restore original functions
    _G.C_Bank.CanViewBank = originalCanViewBank
    _G.C_Bank.FetchPurchasedBankTabData = originalFetchPurchased
    bank.SetBankType = originalSetBankType

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 4: Default bank type is first available — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 4: Default bank type is first available — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:bankdefaulttype()
    return RunBankDefaultTypeTest()
end
