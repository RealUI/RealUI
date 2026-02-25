local ADDON_NAME, ns = ...

-- Property Test: Purchase button visibility
-- Feature: inventory-bank-rewrite, Property 8: Purchase button visibility
-- Validates: Requirements 3.5
--
-- For any bank type where C_Bank.HasMaxBankTabs() returns false, the
-- Tab_Sidebar should display a purchase button. When HasMaxBankTabs()
-- returns true, no purchase button should be shown.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

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

-- Simple RNG (xorshift32)
local rngState = 808
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

--- Generate a random set of purchased tab data for a given bank type.
local function generatePurchasedTabs(bankType)
    local range = tabRanges[bankType]
    local count = nextRandom(#range + 1) - 1  -- 0 to maxTabs
    local tabs = {}
    for i = 1, count do
        tabs[i] = {
            ID = range[i],
            name = ("Tab %d"):format(i),
            icon = _G.QUESTION_MARK_ICON or 134400,
        }
    end
    return tabs
end

local function RunPurchaseButtonTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    local bank = Inventory.bank
    if not bank.tabSidebar then
        _G.print("|cffff0000[ERROR]|r TabSidebar not found on bank frame.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Purchase button visibility — running", NUM_ITERATIONS, "iterations")

    local sidebar = bank.tabSidebar

    -- Save originals
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    local originalHasMaxTabs = _G.C_Bank.HasMaxBankTabs
    local originalSetActiveTab = bank.SetActiveTab

    local mockPurchasedTabs = {}
    local mockHasMax = false

    _G.C_Bank.FetchPurchasedBankTabData = function()
        return mockPurchasedTabs
    end

    _G.C_Bank.HasMaxBankTabs = function()
        return mockHasMax
    end

    -- Stub SetActiveTab to prevent full item refresh pipeline
    bank.SetActiveTab = function() end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local bankType = bankTypes[nextRandom(#bankTypes)]
        mockPurchasedTabs = generatePurchasedTabs(bankType)
        local tabCount = #mockPurchasedTabs
        local maxTabs = #tabRanges[bankType]

        -- Randomly decide whether max tabs has been reached
        -- Force true when all tabs are purchased, force false when none are,
        -- otherwise randomize
        if tabCount >= maxTabs then
            mockHasMax = true
        elseif tabCount == 0 then
            mockHasMax = nextRandom(2) == 1  -- could still be at max with 0 (edge case)
        else
            mockHasMax = nextRandom(2) == 1
        end

        sidebar.selectedTabID = nil
        sidebar:Refresh(bankType)

        local purchaseBtnVisible = sidebar.purchaseButton:IsShown()

        -- Check: purchase button visible iff HasMaxBankTabs is false
        if mockHasMax then
            -- Max tabs reached: purchase button must be hidden
            if purchaseBtnVisible then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: bankType=%d HasMaxBankTabs=true but purchase button is visible"):format(
                        i, bankType
                    )
                )
            end
        else
            -- Not at max: purchase button must be shown
            if not purchaseBtnVisible then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: bankType=%d HasMaxBankTabs=false but purchase button is hidden"):format(
                        i, bankType
                    )
                )
            end
        end
    end

    -- Restore original functions
    _G.C_Bank.FetchPurchasedBankTabData = originalFetchPurchased
    _G.C_Bank.HasMaxBankTabs = originalHasMaxTabs
    bank.SetActiveTab = originalSetActiveTab

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 8: Purchase button visibility — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 8: Purchase button visibility — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:bankpurchasebutton()
    return RunPurchaseButtonTest()
end
