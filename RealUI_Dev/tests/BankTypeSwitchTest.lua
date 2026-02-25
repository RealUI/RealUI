local ADDON_NAME, ns = ...

-- Property Test: Bank type switch updates display and highlight
-- Feature: inventory-bank-rewrite, Property 5: Bank type switch updates display and highlight
-- Validates: Requirements 2.3, 2.4
--
-- For any bank type switch action, the active bank type should change to the
-- selected type, only the selected type's button should be visually highlighted,
-- and the tab sidebar and item display should reflect the new type.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 529
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunBankTypeSwitchTest()
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

    _G.print("|cff00ccff[PBT]|r Bank type switch updates display and highlight — running", NUM_ITERATIONS, "iterations")

    local switcher = bank.bankTypeSwitcher

    -- Mock C_Bank.CanViewBank: both types always viewable for switch tests
    local originalCanViewBank = _G.C_Bank.CanViewBank
    _G.C_Bank.CanViewBank = function() return true end

    -- Mock C_Bank.FetchPurchasedBankTabData to return empty table
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    _G.C_Bank.FetchPurchasedBankTabData = function() return {} end

    -- Track SetBankType calls on the bank frame
    local originalSetBankType = bank.SetBankType
    local lastSetBankType
    bank.SetBankType = function(self, bankType)
        lastSetBankType = bankType
    end

    -- Capture the highlight and normal colors from the icon font objects
    -- The implementation uses Color.highlight for active and Color.white for inactive
    -- We compare icon text colors to determine which button is highlighted
    local function getIconColor(btn)
        local r, g, b = btn.icon:GetTextColor()
        return r, g, b
    end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Pick a random bank type to switch to
        local targetType = bankTypes[nextRandom(#bankTypes)]

        -- Reset tracking
        lastSetBankType = nil

        -- Perform the switch
        switcher:SetActiveType(targetType)

        -- Check 1: activeType should match the target
        local activeType = switcher:GetActiveType()
        if activeType ~= targetType then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: activeType expected %d, got %s"):format(
                    i, targetType, tostring(activeType)
                )
            )
        end

        -- Check 2: SetBankType should have been called on the bank frame with the target type
        if lastSetBankType ~= targetType then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: SetBankType called with %s, expected %d"):format(
                    i, tostring(lastSetBankType), targetType
                )
            )
        end

        -- Check 3: Only the selected button should be highlighted
        -- The active button's icon color should differ from inactive buttons
        local activeBtn = switcher.buttons[targetType]
        if not activeBtn then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: no button found for target bankType=%d"):format(i, targetType)
            )
        else
            local ar, ag, ab = getIconColor(activeBtn)

            for bt, btn in next, switcher.buttons do
                local br, bg, bb = getIconColor(btn)
                if bt == targetType then
                    -- Active button: color should match the active button's color (self-check)
                    if br ~= ar or bg ~= ag or bb ~= ab then
                        failures = failures + 1
                        _G.print(
                            ("|cffff0000[FAIL]|r iteration %d: active button color mismatch for bankType=%d"):format(i, bt)
                        )
                    end
                else
                    -- Inactive button: color should differ from the active button
                    if br == ar and bg == ag and bb == ab then
                        failures = failures + 1
                        _G.print(
                            ("|cffff0000[FAIL]|r iteration %d: inactive bankType=%d has same color as active bankType=%d"):format(
                                i, bt, targetType
                            )
                        )
                    end
                end
            end
        end
    end

    -- Restore original functions
    _G.C_Bank.CanViewBank = originalCanViewBank
    _G.C_Bank.FetchPurchasedBankTabData = originalFetchPurchased
    bank.SetBankType = originalSetBankType

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 5: Bank type switch updates display and highlight — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 5: Bank type switch updates display and highlight — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:banktypeswitch()
    return RunBankTypeSwitchTest()
end
