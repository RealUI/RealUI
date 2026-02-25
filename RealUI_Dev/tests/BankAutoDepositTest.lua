local ADDON_NAME, ns = ...

-- Property Test: Auto-deposit button visibility matches bank type
-- Feature: inventory-bank-rewrite, Property 16: Auto-deposit button visibility matches bank type
-- Validates: Requirements 6.1, 6.4
--
-- For any active bank type, the Auto_Deposit button should be visible
-- if and only if the active type is Enum.BankType.Account.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

-- Simple RNG (xorshift32)
local rngState = 421
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunAutoDepositVisibilityTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    local bank = Inventory.bank
    if not bank.deposit then
        _G.print("|cffff0000[ERROR]|r Auto-deposit button not found on bank frame.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Auto-deposit button visibility matches bank type — running", NUM_ITERATIONS, "iterations")

    -- Mock C_Bank.FetchPurchasedBankTabData to prevent side effects during SetBankType
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    _G.C_Bank.FetchPurchasedBankTabData = function() return {} end

    -- Stub SetActiveTab to prevent full Update cascade
    local originalSetActiveTab = bank.SetActiveTab
    bank.SetActiveTab = function(self, tabID)
        self.activeTabID = tabID
        _G.wipe(self.bagIDs)
        if tabID then
            _G.tinsert(self.bagIDs, tabID)
        end
    end

    -- Stub tabSidebar:Refresh to prevent UI side effects
    local originalTabSidebarRefresh
    if bank.tabSidebar then
        originalTabSidebarRefresh = bank.tabSidebar.Refresh
        bank.tabSidebar.Refresh = function(self, bankType)
            self.selectedTabID = nil
            bank:SetActiveTab(nil)
        end
    end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Pick a random bank type
        local bankType = bankTypes[nextRandom(#bankTypes)]

        -- Call SetBankType which should toggle deposit button visibility
        bank:SetBankType(bankType)

        local isShown = bank.deposit:IsShown()
        local expectedVisible = (bankType == _G.Enum.BankType.Account)

        if isShown ~= expectedVisible then
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: bankType=%d expected deposit visible=%s got visible=%s"):format(
                    i, bankType, tostring(expectedVisible), tostring(isShown)
                )
            )
            failures = failures + 1
        end
    end

    -- Restore original functions
    _G.C_Bank.FetchPurchasedBankTabData = originalFetchPurchased
    bank.SetActiveTab = originalSetActiveTab
    if bank.tabSidebar and originalTabSidebarRefresh then
        bank.tabSidebar.Refresh = originalTabSidebarRefresh
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 16: Auto-deposit button visibility matches bank type — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 16: Auto-deposit button visibility matches bank type — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:bankautodeposit()
    return RunAutoDepositVisibilityTest()
end
