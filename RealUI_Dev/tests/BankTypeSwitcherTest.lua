local ADDON_NAME, ns = ...

-- Property Test: Bank type switcher shows viewable types
-- Feature: inventory-bank-rewrite, Property 3: Bank type switcher shows viewable types
-- Validates: Requirements 2.1
--
-- For any combination of C_Bank.CanViewBank() return values across bank types,
-- the Bank_Type_Switcher should display exactly one button per viewable bank type
-- and no buttons for non-viewable types.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

-- The two bank types the switcher manages
local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
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

local function nextBool()
    return nextRandom(2) == 1
end

local function RunBankTypeSwitcherTest()
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

    _G.print("|cff00ccff[PBT]|r Bank type switcher shows viewable types — running", NUM_ITERATIONS, "iterations")

    local switcher = bank.bankTypeSwitcher

    -- Mock C_Bank.CanViewBank to return controlled values per type
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

    -- Stub out bank:Update and bank:SetBankType to prevent side effects
    local originalSetBankType = bank.SetBankType
    bank.SetBankType = function() end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate random CanViewBank results for each bank type
        local canViewCharacter = nextBool()
        local canViewAccount = nextBool()

        canViewOverrides[_G.Enum.BankType.Character] = canViewCharacter
        canViewOverrides[_G.Enum.BankType.Account] = canViewAccount

        -- Call Refresh which queries CanViewBank and shows/hides buttons
        switcher:Refresh()

        -- Verify each button's visibility matches the CanViewBank result
        local ok = true
        for _, bankType in ipairs(bankTypes) do
            local btn = switcher.buttons[bankType]
            if not btn then
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: no button found for bankType=%d"):format(i, bankType)
                )
                ok = false
            else
                local isShown = btn:IsShown()
                local expected = canViewOverrides[bankType]

                if isShown ~= expected then
                    _G.print(
                        ("|cffff0000[FAIL]|r iteration %d: bankType=%d expected visible=%s got visible=%s (canView: char=%s acct=%s)"):format(
                            i,
                            bankType,
                            tostring(expected),
                            tostring(isShown),
                            tostring(canViewCharacter),
                            tostring(canViewAccount)
                        )
                    )
                    ok = false
                end
            end
        end

        -- Count visible buttons — should equal number of viewable types
        local visibleCount = 0
        for _, btn in next, switcher.buttons do
            if btn:IsShown() then
                visibleCount = visibleCount + 1
            end
        end

        local expectedCount = 0
        if canViewCharacter then expectedCount = expectedCount + 1 end
        if canViewAccount then expectedCount = expectedCount + 1 end

        if visibleCount ~= expectedCount then
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: expected %d visible buttons, got %d"):format(
                    i, expectedCount, visibleCount
                )
            )
            ok = false
        end

        if not ok then
            failures = failures + 1
        end
    end

    -- Restore original functions
    _G.C_Bank.CanViewBank = originalCanViewBank
    _G.C_Bank.FetchPurchasedBankTabData = originalFetchPurchased
    bank.SetBankType = originalSetBankType

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 3: Bank type switcher shows viewable types — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 3: Bank type switcher shows viewable types — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:banktypeswitcher()
    return RunBankTypeSwitcherTest()
end
