local ADDON_NAME, ns = ...

-- Property Test: Money buttons disabled when bank is locked
-- Feature: inventory-bank-rewrite, Property 19: Money buttons disabled when bank is locked
-- Validates: Requirements 7.6
--
-- For any bank type where C_Bank.FetchBankLockedReason() returns non-nil,
-- the Withdraw and Deposit buttons should be disabled.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

-- Simple RNG (xorshift32)
local rngState = 743
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunMoneyLockTest()
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

    _G.print("|cff00ccff[PBT]|r Money buttons disabled when bank is locked — running", NUM_ITERATIONS, "iterations")

    -- Save originals
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    local originalFetchBankLockedReason = _G.C_Bank.FetchBankLockedReason
    local originalDoesBankTypeSupportMoneyTransfer = _G.C_Bank.DoesBankTypeSupportMoneyTransfer
    local originalMoneyFrameSetType = _G.MoneyFrame_SetType
    local originalMoneyFrameUpdateMoney = _G.MoneyFrame_UpdateMoney

    -- Stub to prevent side effects
    _G.C_Bank.FetchPurchasedBankTabData = function() return {} end
    _G.C_Bank.DoesBankTypeSupportMoneyTransfer = function() return true end
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
        local isLocked = (nextRandom(2) == 1)

        -- Mock FetchBankLockedReason
        _G.C_Bank.FetchBankLockedReason = function()
            if isLocked then
                return 1 -- Any non-nil value represents a lock reason
            end
            return nil
        end

        bank:SetBankType(bankType)

        local withdrawEnabled = bank.withdrawButton:IsEnabled()
        local depositEnabled = bank.depositButton:IsEnabled()
        local expectedEnabled = not isLocked

        if withdrawEnabled ~= expectedEnabled then
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: bankType=%d locked=%s expected withdraw enabled=%s got=%s"):format(
                    i, bankType, tostring(isLocked), tostring(expectedEnabled), tostring(withdrawEnabled)
                )
            )
            failures = failures + 1
        elseif depositEnabled ~= expectedEnabled then
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: bankType=%d locked=%s expected deposit enabled=%s got=%s"):format(
                    i, bankType, tostring(isLocked), tostring(expectedEnabled), tostring(depositEnabled)
                )
            )
            failures = failures + 1
        end
    end

    -- Restore
    _G.C_Bank.FetchPurchasedBankTabData = originalFetchPurchased
    _G.C_Bank.FetchBankLockedReason = originalFetchBankLockedReason
    _G.C_Bank.DoesBankTypeSupportMoneyTransfer = originalDoesBankTypeSupportMoneyTransfer
    _G.MoneyFrame_SetType = originalMoneyFrameSetType
    _G.MoneyFrame_UpdateMoney = originalMoneyFrameUpdateMoney
    bank.SetActiveTab = originalSetActiveTab
    if bank.tabSidebar and originalTabSidebarRefresh then
        bank.tabSidebar.Refresh = originalTabSidebarRefresh
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 19: Money buttons disabled when bank is locked — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 19: Money buttons disabled when bank is locked — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

function ns.commands:bankmoneylock()
    return RunMoneyLockTest()
end
