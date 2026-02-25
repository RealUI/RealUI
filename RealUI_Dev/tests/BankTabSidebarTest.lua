local ADDON_NAME, ns = ...

-- Property Test: Tab sidebar reflects purchased tabs with selection highlight
-- Feature: inventory-bank-rewrite, Property 6: Tab sidebar reflects purchased tabs with selection highlight
-- Validates: Requirements 3.1, 3.4
--
-- For any bank type and any set of purchased tab data returned by
-- C_Bank.FetchPurchasedBankTabData(), the Tab_Sidebar should display exactly
-- one button per purchased tab, and only the currently selected tab button
-- should be visually highlighted.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

local bankTypes = {
    _G.Enum.BankType.Character,
    _G.Enum.BankType.Account,
}

-- Tab ID ranges per bank type (mirrors bankTypeConfig)
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

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 613
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

--- Generate a random set of purchased tab data for a given bank type.
--- Returns 0 to maxTabs purchased tabs with sequential IDs from the tab range.
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

local function RunTabSidebarTest()
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

    _G.print("|cff00ccff[PBT]|r Tab sidebar reflects purchased tabs — running", NUM_ITERATIONS, "iterations")

    local sidebar = bank.tabSidebar

    -- Save originals
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    local originalHasMaxTabs = _G.C_Bank.HasMaxBankTabs
    local originalSetActiveTab = bank.SetActiveTab

    -- Mock FetchPurchasedBankTabData to return our generated data
    local mockPurchasedTabs = {}
    _G.C_Bank.FetchPurchasedBankTabData = function()
        return mockPurchasedTabs
    end

    -- Mock HasMaxBankTabs to always return true (hide purchase button, simplify test)
    _G.C_Bank.HasMaxBankTabs = function()
        return true
    end

    -- Stub SetActiveTab to prevent full item refresh pipeline
    bank.SetActiveTab = function() end

    -- Capture highlight border color for comparison
    -- The implementation uses Color.highlight for active and Color.frame for inactive
    local function getBorderColor(btn)
        return btn:GetBackdropBorderColor()
    end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Pick a random bank type
        local bankType = bankTypes[nextRandom(#bankTypes)]

        -- Generate random purchased tab data
        mockPurchasedTabs = generatePurchasedTabs(bankType)
        local tabCount = #mockPurchasedTabs

        -- Reset selected tab so Refresh auto-selects
        sidebar.selectedTabID = nil

        -- Call Refresh which populates tab buttons
        sidebar:Refresh(bankType)

        -- Check 1: Exactly one visible button per purchased tab
        local visibleCount = 0
        for _, btn in ipairs(sidebar.tabButtons) do
            if btn:IsShown() then
                visibleCount = visibleCount + 1
            end
        end

        if visibleCount ~= tabCount then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: bankType=%d expected %d visible tab buttons, got %d"):format(
                    i, bankType, tabCount, visibleCount
                )
            )
        end

        -- Check 2: Each visible button has correct tabData
        for j = 1, tabCount do
            local btn = sidebar.tabButtons[j]
            if btn and btn:IsShown() then
                if not btn.tabData or btn.tabData.ID ~= mockPurchasedTabs[j].ID then
                    failures = failures + 1
                    _G.print(
                        ("|cffff0000[FAIL]|r iteration %d: button %d tabData.ID expected %s, got %s"):format(
                            i, j,
                            tostring(mockPurchasedTabs[j].ID),
                            tostring(btn.tabData and btn.tabData.ID)
                        )
                    )
                end
            end
        end

        -- Check 3: Selection highlight — only the selected tab should be highlighted
        if tabCount > 0 then
            local selectedID = sidebar:GetSelectedTabID()

            -- Verify a tab is selected
            if not selectedID then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: no tab selected despite %d purchased tabs"):format(i, tabCount)
                )
            else
                -- Now pick a random tab to select and verify highlight
                local targetIdx = nextRandom(tabCount)
                local targetID = mockPurchasedTabs[targetIdx].ID
                sidebar:SelectTab(targetID)

                -- Verify only the selected tab has the highlight border color
                local highlightR, highlightG, highlightB
                local frameR, frameG, frameB

                -- Get the colors from the selected and a non-selected button
                local selectedBtn = nil
                for j = 1, tabCount do
                    local btn = sidebar.tabButtons[j]
                    if btn and btn:IsShown() and btn.tabData then
                        local r, g, b = getBorderColor(btn)
                        if btn.tabData.ID == targetID then
                            selectedBtn = btn
                            highlightR, highlightG, highlightB = r, g, b
                        else
                            frameR, frameG, frameB = r, g, b
                        end
                    end
                end

                if not selectedBtn then
                    failures = failures + 1
                    _G.print(
                        ("|cffff0000[FAIL]|r iteration %d: selected button not found for tabID=%s"):format(
                            i, tostring(targetID)
                        )
                    )
                elseif tabCount > 1 and highlightR and frameR then
                    -- The highlight color should differ from the frame (inactive) color
                    if highlightR == frameR and highlightG == frameG and highlightB == frameB then
                        failures = failures + 1
                        _G.print(
                            ("|cffff0000[FAIL]|r iteration %d: selected tab border color matches inactive tab (no highlight distinction)"):format(i)
                        )
                    end
                end

                -- Verify no non-selected button has the highlight color
                if highlightR then
                    for j = 1, tabCount do
                        local btn = sidebar.tabButtons[j]
                        if btn and btn:IsShown() and btn.tabData and btn.tabData.ID ~= targetID then
                            local r, g, b = getBorderColor(btn)
                            if r == highlightR and g == highlightG and b == highlightB then
                                failures = failures + 1
                                _G.print(
                                    ("|cffff0000[FAIL]|r iteration %d: non-selected tab %d has highlight color"):format(i, j)
                                )
                            end
                        end
                    end
                end
            end
        else
            -- No purchased tabs: selectedTabID should be nil
            if sidebar:GetSelectedTabID() ~= nil then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: selectedTabID should be nil with 0 purchased tabs, got %s"):format(
                        i, tostring(sidebar:GetSelectedTabID())
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
        _G.print(("|cff00ff00[PASS]|r Property 6: Tab sidebar reflects purchased tabs with selection highlight — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 6: Tab sidebar reflects purchased tabs with selection highlight — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:banktabsidebar()
    return RunTabSidebarTest()
end
