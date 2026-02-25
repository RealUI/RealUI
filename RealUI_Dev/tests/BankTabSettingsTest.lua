local ADDON_NAME, ns = ...

-- Property Test: Tab settings refresh on BANK_TAB_SETTINGS_UPDATED
-- Feature: inventory-bank-rewrite, Property 22: Tab settings refresh on BANK_TAB_SETTINGS_UPDATED
-- Validates: Requirements 9.4
--
-- For any BANK_TAB_SETTINGS_UPDATED event matching the active bank type,
-- the Tab_Sidebar should re-fetch tab data and update tab names and icons
-- to reflect the new settings.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

-- Tab ID ranges per bank type
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
local rngState = 922
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

--- Generate random purchased tab data with random names/icons.
local function generatePurchasedTabs(bankType, suffix)
    local range = tabRanges[bankType]
    local count = nextRandom(#range) -- 1 to maxTabs (at least one tab)
    local tabs = {}
    for i = 1, count do
        tabs[i] = {
            ID = range[i],
            name = ("Tab%d_%s"):format(i, suffix or "orig"),
            icon = 100000 + nextRandom(9999),
        }
    end
    return tabs
end

local function RunBankTabSettingsTest()
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

    _G.print("|cff00ccff[PBT]|r Tab settings refresh on BANK_TAB_SETTINGS_UPDATED — running", NUM_ITERATIONS, "iterations")

    local sidebar = bank.tabSidebar

    -- Save originals
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    local originalHasMaxTabs = _G.C_Bank.HasMaxBankTabs
    local originalSetActiveTab = bank.SetActiveTab

    -- Mock HasMaxBankTabs to always return true (hide purchase button)
    _G.C_Bank.HasMaxBankTabs = function()
        return true
    end

    -- Stub SetActiveTab to prevent full item refresh
    bank.SetActiveTab = function(self, tabID)
        self.activeTabID = tabID
        _G.wipe(self.bagIDs)
        if tabID then
            _G.tinsert(self.bagIDs, tabID)
        end
    end

    local mockPurchasedTabs = {}
    _G.C_Bank.FetchPurchasedBankTabData = function()
        return mockPurchasedTabs
    end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Pick a random active bank type
        local activeBankType = bankTypes[nextRandom(#bankTypes)]
        -- Pick a random event bank type (may or may not match)
        local eventBankType = bankTypes[nextRandom(#bankTypes)]

        -- Generate initial tab data and set up sidebar
        mockPurchasedTabs = generatePurchasedTabs(activeBankType, "before")
        sidebar.selectedTabID = nil
        bank.activeBankType = activeBankType
        sidebar:Refresh(activeBankType)

        -- Capture tab names before the event
        local namesBefore = {}
        for j, btn in ipairs(sidebar.tabButtons) do
            if btn:IsShown() and btn.tabData then
                namesBefore[btn.tabData.ID] = btn.tabData.name
            end
        end

        -- Generate updated tab data (same tabs, new names/icons)
        local updatedTabs = generatePurchasedTabs(activeBankType, "after")
        -- Ensure same tab count as before for a clean comparison
        while #updatedTabs < #mockPurchasedTabs do
            local range = tabRanges[activeBankType]
            local idx = #updatedTabs + 1
            updatedTabs[idx] = {
                ID = range[idx],
                name = ("Tab%d_after"):format(idx),
                icon = 200000 + nextRandom(9999),
            }
        end
        while #updatedTabs > #mockPurchasedTabs do
            updatedTabs[#updatedTabs] = nil
        end

        -- Switch mock to return updated data
        mockPurchasedTabs = updatedTabs

        -- Fire BANK_TAB_SETTINGS_UPDATED event
        bank:OnEvent("BANK_TAB_SETTINGS_UPDATED", eventBankType)

        local shouldRefresh = (eventBankType == activeBankType)

        if shouldRefresh then
            -- Verify tab names/icons were updated
            for j, btn in ipairs(sidebar.tabButtons) do
                if btn:IsShown() and btn.tabData then
                    local expectedTab = updatedTabs[j]
                    if expectedTab then
                        if btn.tabData.name ~= expectedTab.name then
                            failures = failures + 1
                            _G.print(
                                ("|cffff0000[FAIL]|r iteration %d: tab %d name expected '%s', got '%s'"):format(
                                    i, j, expectedTab.name, btn.tabData.name
                                )
                            )
                        end
                        if btn.tabData.icon ~= expectedTab.icon then
                            failures = failures + 1
                            _G.print(
                                ("|cffff0000[FAIL]|r iteration %d: tab %d icon expected %s, got %s"):format(
                                    i, j, tostring(expectedTab.icon), tostring(btn.tabData.icon)
                                )
                            )
                        end
                    end
                end
            end
        else
            -- Event bank type doesn't match active — names should NOT have changed
            for j, btn in ipairs(sidebar.tabButtons) do
                if btn:IsShown() and btn.tabData then
                    local oldName = namesBefore[btn.tabData.ID]
                    if oldName and btn.tabData.name ~= oldName then
                        failures = failures + 1
                        _G.print(
                            ("|cffff0000[FAIL]|r iteration %d: non-matching bankType event changed tab %d name from '%s' to '%s'"):format(
                                i, j, oldName, btn.tabData.name
                            )
                        )
                    end
                end
            end
        end
    end

    -- Restore originals
    _G.C_Bank.FetchPurchasedBankTabData = originalFetchPurchased
    _G.C_Bank.HasMaxBankTabs = originalHasMaxTabs
    bank.SetActiveTab = originalSetActiveTab

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 22: Tab settings refresh on BANK_TAB_SETTINGS_UPDATED — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 22: Tab settings refresh on BANK_TAB_SETTINGS_UPDATED — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:banktabsettings()
    return RunBankTabSettingsTest()
end
