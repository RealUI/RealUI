local ADDON_NAME, ns = ...

-- Property Test: Sort dispatches correct function per bank type
-- Feature: inventory-bank-rewrite, Property 21: Sort dispatches correct function per bank type
-- Validates: Requirements 8.3
--
-- For any active bank type, clicking the sort button should call
-- C_Container.SortBankBags() for Character Bank or
-- C_Container.SortAccountBankBags() for Warband Bank.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 2101
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunBankSortDispatchTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Sort dispatches correct function per bank type — running", NUM_ITERATIONS, "iterations")

    local bank = Inventory.bank
    local restackButton = bank.restackButton
    if not restackButton then
        _G.print("|cffff0000[ERROR]|r bank.restackButton not found.")
        return false
    end

    local clickHandler = restackButton:GetScript("OnClick")
    if not clickHandler then
        _G.print("|cffff0000[ERROR]|r restackButton has no OnClick handler.")
        return false
    end

    local failures = 0

    -- Save originals
    local originalSortBankBags = _G.C_Container.SortBankBags
    local originalSortAccountBankBags = _G.C_Container.SortAccountBankBags
    local originalPlaySound = _G.PlaySound
    local originalGetCVarBool = _G.GetCVarBool
    local originalStaticPopup = _G.StaticPopup_Show

    -- Track which sort function was called
    local sortCalled = nil
    _G.C_Container.SortBankBags = function()
        sortCalled = "SortBankBags"
    end
    _G.C_Container.SortAccountBankBags = function()
        sortCalled = "SortAccountBankBags"
    end

    -- Suppress sound and popups during test
    _G.PlaySound = function() end
    _G.GetCVarBool = function(cvar)
        if cvar == "bankConfirmTabCleanUp" then return false end
        return originalGetCVarBool(cvar)
    end
    _G.StaticPopup_Show = function() end

    local originalBankType = bank:GetActiveBankType()

    for i = 1, NUM_ITERATIONS do
        local bankType = bankTypes[nextRandom(#bankTypes)]
        bank.activeBankType = bankType

        sortCalled = nil
        clickHandler(restackButton)

        local expectedSort
        if bankType == _G.Enum.BankType.Character then
            expectedSort = "SortBankBags"
        else
            expectedSort = "SortAccountBankBags"
        end

        if sortCalled ~= expectedSort then
            failures = failures + 1
            if failures <= 5 then
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: bankType=%s, expected %s, got %s"):format(
                        i, tostring(bankType), tostring(expectedSort), tostring(sortCalled)
                    )
                )
            end
        end
    end

    -- Restore originals
    bank.activeBankType = originalBankType
    _G.C_Container.SortBankBags = originalSortBankBags
    _G.C_Container.SortAccountBankBags = originalSortAccountBankBags
    _G.PlaySound = originalPlaySound
    _G.GetCVarBool = originalGetCVarBool
    _G.StaticPopup_Show = originalStaticPopup

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 21: Sort dispatches correct function per bank type — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 21: Sort dispatches correct function per bank type — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

function ns.commands:banksortdispatch()
    return RunBankSortDispatchTest()
end
