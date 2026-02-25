local ADDON_NAME, ns = ...

-- Property Test: Money frame visibility matches transfer support
-- Feature: inventory-bank-rewrite, Property 17: Money frame visibility matches transfer support
-- Validates: Requirements 7.1
--
-- For any active bank type, the Money_Frame's Withdraw and Deposit buttons
-- should be visible if and only if C_Bank.DoesBankTypeSupportMoneyTransfer()
-- returns true for that type.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

-- Simple RNG (xorshift32)
local rngState = 517
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunMoneyVisibilityTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    local bank = Inventory.bank
    if not bank.withdrawButton or not bank.depositButton then
        _G.print("|cffff0000[ERROR]|r Withdraw/Deposit buttons not found on bank frame.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Money frame visibility matches transfer support — running", NUM_ITERATIONS, "iterations")

    -- Save originals
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    local originalDoesBankTypeSupportMoneyTransfer = _G.C_Bank.DoesBankTypeSupportMoneyTransfer
    local originalFetchBankLockedReason = _G.C_Bank.FetchBankLockedReason
    local originalMoneyFrameSetType = _G.MoneyFrame_SetType
    local originalMoneyFrameUpdateMoney = _G.MoneyFrame_UpdateMoney

    -- Stub to prevent side effects
    _G.C_Bank.FetchPurchasedBankTabData = function() return {} end
    _G.C_Bank.FetchBankLockedReason = function() return nil end
    _G.MoneyFrame_SetType = function() end
    _G.MoneyFrame_UpdateMoney = function() end

    local originalSetActiveTab = bank.SetActiveTab
    bank.SetActiveTab = function(self, tabID)
        self.activeTabID = tabID
        _G.wipe(self.bagIDs)
        if tabID then
            _G.tinsert(self.bagIDs, tabID)
        end
    end

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
        local bankType = bankTypes[nextRandom(#bankTypes)]

        -- Randomize whether money transfer is supported
        local supportsTransfer = (nextRandom(2) == 1)
        _G.C_Bank.DoesBankTypeSupportMoneyTransfer = function(bt)
            if bt == bankType then
                return supportsTransfer
            end
            return originalDoesBankTypeSupportMoneyTransfer(bt)
        end

        bank:SetBankType(bankType)

        local withdrawShown = bank.withdrawButton:IsShown()
        local depositShown = bank.depositButton:IsShown()

        if withdrawShown ~= supportsTransfer then
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: bankType=%d supportsTransfer=%s withdrawShown=%s"):format(
                    i, bankType, tostring(supportsTransfer), tostring(withdrawShown)
                )
            )
            failures = failures + 1
        elseif depositShown ~= supportsTransfer then
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: bankType=%d supportsTransfer=%s depositShown=%s"):format(
                    i, bankType, tostring(supportsTransfer), tostring(depositShown)
                )
            )
            failures = failures + 1
        end
    end

    -- Restore
    _G.C_Bank.FetchPurchasedBankTabData = originalFetchPurchased
    _G.C_Bank.DoesBankTypeSupportMoneyTransfer = originalDoesBankTypeSupportMoneyTransfer
    _G.C_Bank.FetchBankLockedReason = originalFetchBankLockedReason
    _G.MoneyFrame_SetType = originalMoneyFrameSetType
    _G.MoneyFrame_UpdateMoney = originalMoneyFrameUpdateMoney
    bank.SetActiveTab = originalSetActiveTab
    if bank.tabSidebar and originalTabSidebarRefresh then
        bank.tabSidebar.Refresh = originalTabSidebarRefresh
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 17: Money frame visibility matches transfer support — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 17: Money frame visibility matches transfer support — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

function ns.commands:bankmoneyvisibility()
    return RunMoneyVisibilityTest()
end
