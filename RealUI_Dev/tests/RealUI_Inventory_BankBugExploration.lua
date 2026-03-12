-- =============================================================================
-- RealUI Bank Bugfix Package 1 — Bug Condition Exploration Test
-- =============================================================================
-- This file is loaded in-game to verify the existence of 9 bank UI bugs.
-- Each test prints PASS or FAIL. On UNFIXED code, tests should FAIL,
-- confirming the bugs exist.
--
-- Usage: /run RealUI_BankBugExploration()
--   (Bank must be open for most tests to produce meaningful results)
--
-- Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9
-- =============================================================================

local _, private = ...

local passCount, failCount = 0, 0

local function Assert(condition, bugID, description, detail)
    if condition then
        passCount = passCount + 1
        print("|cFF00FF00PASS|r " .. bugID .. ": " .. description)
    else
        failCount = failCount + 1
        local msg = "|cFFFF0000FAIL|r " .. bugID .. ": " .. description
        if detail then
            msg = msg .. " — " .. detail
        end
        print(msg)
    end
end

-- =============================================================================
-- Bug 1.7: C_Bank.HasRefundableItemsInBags removed API
-- This test can run without the bank being open.
-- =============================================================================
local function TestBug1_7()
    -- The API was removed in a recent WoW patch. If it's nil, calling it
    -- would produce a Lua error. The fix should nil-guard the call.
    local apiExists = (_G.C_Bank and _G.C_Bank.HasRefundableItemsInBags ~= nil)
    Assert(apiExists,
        "Bug 1.7",
        "C_Bank.HasRefundableItemsInBags exists (not nil)",
        "C_Bank.HasRefundableItemsInBags is nil — calling it will error"
    )
end

-- =============================================================================
-- Bug 1.1: Empty item list on first bank open / no auto-select
-- =============================================================================
local function TestBug1_1(bankFrame)
    if not bankFrame then
        Assert(false, "Bug 1.1", "Bank frame exists", "bankFrame is nil")
        return
    end

    local tabSidebar = bankFrame.tabSidebar
    if not tabSidebar then
        Assert(false, "Bug 1.1", "tabSidebar exists", "tabSidebar is nil")
        return
    end

    -- After bank opens, a tab should be auto-selected
    local selectedTabID = tabSidebar:GetSelectedTabID()
    Assert(selectedTabID ~= nil,
        "Bug 1.1",
        "tabSidebar has auto-selected a tab on bank open",
        "selectedTabID is nil — no tab was auto-selected"
    )

    -- Items should be displayed (slots array should not be empty)
    local slotCount = bankFrame.slots and #bankFrame.slots or 0
    Assert(slotCount > 0,
        "Bug 1.1",
        "Bank frame has items displayed (slots > 0)",
        "slots count = " .. slotCount .. " — items are not displayed"
    )
end

-- =============================================================================
-- Bug 1.2: Blue overlay (ItemContextOverlay) visible on bank slots
-- =============================================================================
local function TestBug1_2(bankFrame)
    if not bankFrame then return end

    -- Find active bank slot buttons and check ItemContextOverlay
    local bankSlotPool = private.GetSlotTypeForBag and private.GetSlotTypeForBag(_G.Enum.BagIndex.AccountBankTab_1)
    if not bankSlotPool then
        -- Try character bank tab
        bankSlotPool = private.GetSlotTypeForBag and private.GetSlotTypeForBag(_G.Enum.BagIndex.CharacterBankTab_1)
    end
    if not bankSlotPool then
        Assert(false, "Bug 1.2", "Bank slot pool accessible", "Cannot access bank slot pool")
        return
    end

    local checkedCount = 0
    local overlayVisibleCount = 0
    for slot in bankSlotPool:EnumerateActive() do
        if slot:IsShown() and slot.item then
            checkedCount = checkedCount + 1
            if slot.ItemContextOverlay and slot.ItemContextOverlay:IsShown() then
                overlayVisibleCount = overlayVisibleCount + 1
            end
        end
    end

    if checkedCount == 0 then
        Assert(false, "Bug 1.2", "Found visible bank slots to check", "No active bank slots found")
        return
    end

    Assert(overlayVisibleCount == 0,
        "Bug 1.2",
        "ItemContextOverlay is NOT visible on bank slots (" .. checkedCount .. " checked)",
        overlayVisibleCount .. " of " .. checkedCount .. " slots have blue overlay visible"
    )
end

-- =============================================================================
-- Bugs 1.3/1.4/1.9: GetBagID() mismatch with slot.location bag component
-- This is the shared root cause for shift-click, right-click, and tooltip bugs.
-- =============================================================================
local function TestBug1_3_1_4_1_9(bankFrame)
    if not bankFrame then return end

    local activeTabID = bankFrame:GetActiveTabID()
    if not activeTabID then
        Assert(false, "Bug 1.3/1.4/1.9", "Active tab selected", "No active tab — cannot check slots")
        return
    end

    local bankSlotPool = private.GetSlotTypeForBag and private.GetSlotTypeForBag(activeTabID)
    if not bankSlotPool then
        Assert(false, "Bug 1.3/1.4/1.9", "Bank slot pool accessible", "Cannot access bank slot pool")
        return
    end

    local checkedCount = 0
    local mismatchCount = 0
    local mismatchExample = ""
    for slot in bankSlotPool:EnumerateActive() do
        if slot:IsShown() and slot.location and not slot.location:IsEmpty() then
            local locationBagID, locationSlotIndex = slot.location:GetBagAndSlot()
            if locationBagID == activeTabID then
                checkedCount = checkedCount + 1
                local getBagIDResult = slot:GetBagID()
                if getBagIDResult ~= locationBagID then
                    mismatchCount = mismatchCount + 1
                    if mismatchExample == "" then
                        mismatchExample = string.format(
                            "slot[%d]: GetBagID()=%s but location bagID=%s",
                            locationSlotIndex,
                            tostring(getBagIDResult),
                            tostring(locationBagID)
                        )
                    end
                end
            end
        end
    end

    if checkedCount == 0 then
        Assert(false, "Bug 1.3/1.4/1.9", "Found bank slots to check", "No active bank slots in current tab")
        return
    end

    Assert(mismatchCount == 0,
        "Bug 1.3/1.4/1.9",
        "GetBagID() matches location bagID for all " .. checkedCount .. " bank slots",
        mismatchCount .. " mismatches found. Example: " .. mismatchExample
    )
end

-- =============================================================================
-- Bug 1.5: Bank type switcher anchored to searchButton (overlaps bag slots)
-- =============================================================================
local function TestBug1_5(bankFrame)
    if not bankFrame then return end

    local switcher = bankFrame.bankTypeSwitcher
    if not switcher then
        Assert(false, "Bug 1.5", "bankTypeSwitcher exists", "bankTypeSwitcher is nil")
        return
    end

    -- Check the first switcher button's anchor point
    local anchoredToSearch = false
    for _, btn in next, switcher.buttons do
        local numPoints = btn:GetNumPoints()
        for i = 1, numPoints do
            local point, relativeTo, relativePoint, xOfs, yOfs = btn:GetPoint(i)
            if relativeTo == bankFrame.searchButton then
                anchoredToSearch = true
                break
            end
        end
        -- Only need to check the first button (the anchor chain starts there)
        break
    end

    Assert(not anchoredToSearch,
        "Bug 1.5",
        "Bank type switcher is NOT anchored to searchButton",
        "First switcher button is anchored relative to bankFrame.searchButton"
    )
end

-- =============================================================================
-- Bug 1.6: Deposit button not visible for Warband (Account) bank
-- =============================================================================
local function TestBug1_6(bankFrame)
    if not bankFrame then return end

    local deposit = bankFrame.deposit
    if not deposit then
        Assert(false, "Bug 1.6", "Deposit button exists", "bankFrame.deposit is nil")
        return
    end

    local activeBankType = bankFrame:GetActiveBankType()
    if activeBankType ~= _G.Enum.BankType.Account then
        -- Switch to Account bank type for this test
        -- We can only check if the current type is Account
        Assert(false, "Bug 1.6",
            "Warband bank is active for deposit test",
            "Current bank type is not Account (type=" .. tostring(activeBankType) .. "). Switch to Warband bank to test."
        )
        return
    end

    Assert(deposit:IsShown(),
        "Bug 1.6",
        "Deposit button is visible when Warband bank is active",
        "deposit:IsShown() = false — button is hidden"
    )
end

-- =============================================================================
-- Bug 1.8: Free slots counter (dropTarget) positioned incorrectly
-- =============================================================================
local function TestBug1_8(bankFrame)
    if not bankFrame then return end

    local dropTarget = bankFrame.dropTarget
    if not dropTarget then
        Assert(false, "Bug 1.8", "dropTarget exists", "bankFrame.dropTarget is nil")
        return
    end

    -- The dropTarget should be positioned consistently. In the current buggy code,
    -- it's appended to self.slots and positioned by ArrangeSlots like a regular slot.
    -- Check if the dropTarget is in the slots array (it shouldn't be treated as a
    -- regular item slot for positioning purposes in the bank).
    local inSlotsArray = false
    if bankFrame.slots then
        for _, slot in ipairs(bankFrame.slots) do
            if slot == dropTarget then
                inSlotsArray = true
                break
            end
        end
    end

    -- For the bank, the dropTarget being in the slots array means it's positioned
    -- by ArrangeSlots like a regular item slot, which causes inconsistent positioning.
    -- We check that the dropTarget has a reasonable position relative to the bank frame.
    local dtBottom = dropTarget:GetBottom()
    local bankBottom = bankFrame:GetBottom()
    local dtTop = dropTarget:GetTop()
    local bankTop = bankFrame:GetTop()

    local positionOK = true
    local detail = ""
    if dtBottom and bankBottom and dtTop and bankTop then
        -- dropTarget should be within the bank frame bounds
        if dtBottom < bankBottom - 5 or dtTop > bankTop + 5 then
            positionOK = false
            detail = string.format("dropTarget outside bank frame bounds (dt: %.0f-%.0f, bank: %.0f-%.0f)",
                dtBottom, dtTop, bankBottom, bankTop)
        end
    else
        detail = "Cannot determine positions (frame may not be visible)"
    end

    Assert(positionOK and not inSlotsArray,
        "Bug 1.8",
        "dropTarget positioned consistently (not as regular slot in grid)",
        inSlotsArray and "dropTarget found in slots array — positioned like a regular item slot" or detail
    )
end

-- =============================================================================
-- Bug 1.9: Tooltip ItemLocation mismatch (uses GetBagID which is wrong)
-- This is verified by the same GetBagID check as Bug 1.3/1.4, but we add
-- an explicit tooltip-focused assertion.
-- =============================================================================
local function TestBug1_9(bankFrame)
    if not bankFrame then return end

    local activeTabID = bankFrame:GetActiveTabID()
    if not activeTabID then
        Assert(false, "Bug 1.9", "Active tab for tooltip test", "No active tab")
        return
    end

    local bankSlotPool = private.GetSlotTypeForBag and private.GetSlotTypeForBag(activeTabID)
    if not bankSlotPool then
        Assert(false, "Bug 1.9", "Bank slot pool accessible", "Cannot access bank slot pool")
        return
    end

    local checkedCount = 0
    local mismatchCount = 0
    local mismatchExample = ""
    for slot in bankSlotPool:EnumerateActive() do
        if slot:IsShown() and slot.location and not slot.location:IsEmpty() then
            local locationBagID, locationSlotIndex = slot.location:GetBagAndSlot()
            if locationBagID == activeTabID then
                checkedCount = checkedCount + 1
                -- Simulate what the tooltip handler does:
                -- It creates ItemLocation from GetBagID() and GetID()
                local tooltipBagID = slot:GetBagID()
                local tooltipSlotID = slot:GetID()
                local tooltipLocation = _G.ItemLocation:CreateFromBagAndSlot(tooltipBagID, tooltipSlotID)

                -- Compare with the actual slot.location
                local locationsMatch = (tooltipBagID == locationBagID and tooltipSlotID == locationSlotIndex)
                if not locationsMatch then
                    mismatchCount = mismatchCount + 1
                    if mismatchExample == "" then
                        mismatchExample = string.format(
                            "slot[%d]: tooltip would use bag=%s,slot=%d but actual is bag=%s,slot=%d",
                            locationSlotIndex,
                            tostring(tooltipBagID), tooltipSlotID,
                            tostring(locationBagID), locationSlotIndex
                        )
                    end
                end
            end
        end
    end

    if checkedCount == 0 then
        Assert(false, "Bug 1.9", "Found bank slots for tooltip test", "No active bank slots")
        return
    end

    Assert(mismatchCount == 0,
        "Bug 1.9",
        "Tooltip ItemLocation matches slot.location for all " .. checkedCount .. " bank slots",
        mismatchCount .. " mismatches. Example: " .. mismatchExample
    )
end

-- =============================================================================
-- Main test runner
-- =============================================================================
function RealUI_BankBugExploration()
    passCount, failCount = 0, 0

    print("=== RealUI Bank Bug Exploration Tests ===")
    print("Expected: Tests FAIL on unfixed code (confirms bugs exist)")
    print("")

    -- Bug 1.7 can run without bank open
    TestBug1_7()

    -- All other tests need the bank frame
    local Inventory = private.Inventory
    local bankFrame = Inventory and Inventory.bank

    if not bankFrame or not bankFrame:IsShown() then
        print("|cFFFFFF00WARNING|r: Bank frame is not open. Open a bank NPC first.")
        print("Only Bug 1.7 was tested. Open bank and re-run for full results.")
        print("")
        print(string.format("=== Results: %d PASS, %d FAIL ===", passCount, failCount))
        return
    end

    TestBug1_1(bankFrame)
    TestBug1_2(bankFrame)
    TestBug1_3_1_4_1_9(bankFrame)
    TestBug1_5(bankFrame)
    TestBug1_6(bankFrame)
    TestBug1_8(bankFrame)
    TestBug1_9(bankFrame)

    print("")
    print(string.format("=== Results: %d PASS, %d FAIL ===", passCount, failCount))
    if failCount > 0 then
        print("|cFFFF0000Bug conditions confirmed — failures prove bugs exist.|r")
    else
        print("|cFF00FF00All tests passed — bugs appear to be fixed!|r")
    end
end

-- Also register a slash command for convenience
_G.SLASH_REALUIBUGTEST1 = "/realuibugtest"
_G.SlashCmdList["REALUIBUGTEST"] = RealUI_BankBugExploration
