local ADDON_NAME, ns = ...

-- Property Test: Money event refreshes correct bank type
-- Feature: inventory-bank-rewrite, Property 18: Money event refreshes correct bank type
-- Validates: Requirements 7.4, 7.5
--
-- For any ACCOUNT_MONEY event while Warband Bank is active, or PLAYER_MONEY event
-- while Character Bank is active, the Money_Frame balance should be refreshed.
-- Events for the non-active type should not trigger a refresh.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

local moneyEvents = {
    "ACCOUNT_MONEY",
    "PLAYER_MONEY",
}

-- Simple RNG (xorshift32)
local rngState = 631
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunMoneyEventTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    local bank = Inventory.bank
    if not bank.moneyFrame then
        _G.print("|cffff0000[ERROR]|r Money frame not found on bank frame.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Money event refreshes correct bank type — running", NUM_ITERATIONS, "iterations")

    -- Save originals
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    local originalFetchBankLockedReason = _G.C_Bank.FetchBankLockedReason
    local originalDoesBankTypeSupportMoneyTransfer = _G.C_Bank.DoesBankTypeSupportMoneyTransfer
    local originalMoneyFrameSetType = _G.MoneyFrame_SetType
    local originalMoneyFrameUpdateMoney = _G.MoneyFrame_UpdateMoney

    -- Stub to prevent side effects during SetBankType
    _G.C_Bank.FetchPurchasedBankTabData = function() return {} end
    _G.C_Bank.FetchBankLockedReason = function() return nil end
    _G.C_Bank.DoesBankTypeSupportMoneyTransfer = function() return true end
    _G.MoneyFrame_SetType = function() end

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
        local event = moneyEvents[nextRandom(#moneyEvents)]

        -- Set the active bank type
        bank:SetBankType(bankType)

        -- Track whether MoneyFrame_UpdateMoney is called during OnEvent
        local moneyUpdated = false
        _G.MoneyFrame_UpdateMoney = function()
            moneyUpdated = true
        end

        -- Fire the event through OnEvent
        bank:OnEvent(event)

        -- Determine expected behavior
        local shouldRefresh = false
        if event == "ACCOUNT_MONEY" and bankType == _G.Enum.BankType.Account then
            shouldRefresh = true
        elseif event == "PLAYER_MONEY" and bankType == _G.Enum.BankType.Character then
            shouldRefresh = true
        end

        if moneyUpdated ~= shouldRefresh then
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: bankType=%d event=%s expected refresh=%s got refresh=%s"):format(
                    i, bankType, event, tostring(shouldRefresh), tostring(moneyUpdated)
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
        _G.print(("|cff00ff00[PASS]|r Property 18: Money event refreshes correct bank type — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 18: Money event refreshes correct bank type — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

function ns.commands:bankmoneyevent()
    return RunMoneyEventTest()
end
