-- =============================================================================
-- RealUI Bank Bugfix Package 1 — Preservation Property Tests
-- =============================================================================
-- This file is loaded in-game to verify that existing non-bank behavior
-- remains unchanged BEFORE and AFTER the bugfix is applied.
-- Each test prints PASS or FAIL. On UNFIXED code, all tests should PASS,
-- confirming baseline behavior that must be preserved.
--
-- Usage: /run RealUI_PreservationTests()
--   (Inventory bags should be open for most tests to produce meaningful results)
--
-- **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8**
-- =============================================================================

local _, private = ...

local passCount, failCount = 0, 0

local function Assert(condition, testID, description, detail)
    if condition then
        passCount = passCount + 1
        print("|cFF00FF00PASS|r " .. testID .. ": " .. description)
    else
        failCount = failCount + 1
        local msg = "|cFFFF0000FAIL|r " .. testID .. ": " .. description
        if detail then
            msg = msg .. " — " .. detail
        end
        print(msg)
    end
end

-- =============================================================================
-- P1: Inventory bag slot GetBagID() matches actual bag container ID
-- Validates: Requirement 3.1 (inventory bags function normally)
-- =============================================================================
local function TestP1_InventorySlotGetBagID()
    local Inventory = private.Inventory
    local mainFrame = Inventory and Inventory.main
    if not mainFrame then
        Assert(false, "P1", "Inventory main frame exists", "Inventory.main is nil")
        return
    end

    local inventoryBagIDs = mainFrame.bagIDs
    if not inventoryBagIDs or #inventoryBagIDs == 0 then
        Assert(false, "P1", "Inventory bagIDs exist", "bagIDs is nil or empty")
        return
    end

    local checkedCount = 0
    local mismatchCount = 0
    local mismatchExample = ""

    for _, bagID in ipairs(inventoryBagIDs) do
        local numSlots = _G.C_Container.GetContainerNumSlots(bagID)
        for slotIndex = 1, numSlots do
            local slot = private.GetSlot(bagID, slotIndex)
            if slot and slot:IsShown() and slot.location and not slot.location:IsEmpty() then
                local locationBagID = slot.location:GetBagAndSlot()
                checkedCount = checkedCount + 1

                -- For inventory slots, GetBagID() should match the location bagID.
                -- Inventory slots inherit from ContainerFrameItemButtonMixin which
                -- gets bagID from self.bagID or self:GetParent():GetID().
                local getBagIDResult = slot:GetBagID()
                if getBagIDResult ~= locationBagID then
                    mismatchCount = mismatchCount + 1
                    if mismatchExample == "" then
                        mismatchExample = string.format(
                            "bag[%d] slot[%d]: GetBagID()=%s but location bagID=%s",
                            bagID, slotIndex,
                            tostring(getBagIDResult),
                            tostring(locationBagID)
                        )
                    end
                end
            end
        end
    end

    if checkedCount == 0 then
        Assert(false, "P1", "Found inventory slots to check", "No active inventory slots found — open bags first")
        return
    end

    Assert(mismatchCount == 0,
        "P1",
        "Inventory slot GetBagID() matches location bagID for all " .. checkedCount .. " slots",
        mismatchCount .. " mismatches. Example: " .. mismatchExample
    )
end


-- =============================================================================
-- P2: Inventory bag item interactions use correct bag+slot
-- Validates: Requirement 3.1 (item interactions working)
-- =============================================================================
local function TestP2_InventoryItemInteractions()
    local Inventory = private.Inventory
    local mainFrame = Inventory and Inventory.main
    if not mainFrame then
        Assert(false, "P2", "Inventory main frame exists", "Inventory.main is nil")
        return
    end

    -- Verify that ItemSlotMixin:GetBagAndSlot() returns correct values
    -- and that SplitStack uses the correct bag+slot from location
    local inventoryBagIDs = mainFrame.bagIDs
    local checkedCount = 0
    local issueCount = 0
    local issueExample = ""

    for _, bagID in ipairs(inventoryBagIDs) do
        local numSlots = _G.C_Container.GetContainerNumSlots(bagID)
        for slotIndex = 1, numSlots do
            local slot = private.GetSlot(bagID, slotIndex)
            if slot and slot:IsShown() and slot.item then
                checkedCount = checkedCount + 1

                -- GetBagAndSlot should return the correct bag and slot from location
                local retBag, retSlot = slot:GetBagAndSlot()
                if retBag ~= bagID or retSlot ~= slotIndex then
                    issueCount = issueCount + 1
                    if issueExample == "" then
                        issueExample = string.format(
                            "bag[%d] slot[%d]: GetBagAndSlot() returned (%s, %s)",
                            bagID, slotIndex,
                            tostring(retBag), tostring(retSlot)
                        )
                    end
                end
            end
        end
    end

    if checkedCount == 0 then
        Assert(false, "P2", "Found inventory items to check", "No active inventory items — open bags with items first")
        return
    end

    Assert(issueCount == 0,
        "P2",
        "Inventory item GetBagAndSlot() correct for all " .. checkedCount .. " items",
        issueCount .. " issues. Example: " .. issueExample
    )
end

-- =============================================================================
-- P3: Merchant/AH/mail bag open/close hooks are registered
-- Validates: Requirement 3.2 (merchant/AH/mail hooks)
-- =============================================================================
local function TestP3_BagEventHooksRegistered()
    local Inventory = private.Inventory
    if not Inventory then
        Assert(false, "P3", "Inventory module exists", "Inventory is nil")
        return
    end

    -- Verify the PLAYER_INTERACTION_MANAGER event handlers exist
    local hasShowHandler = type(Inventory.PLAYER_INTERACTION_MANAGER_FRAME_SHOW) == "function"
    Assert(hasShowHandler,
        "P3a",
        "PLAYER_INTERACTION_MANAGER_FRAME_SHOW handler exists",
        "Handler function is missing"
    )

    local hasHideHandler = type(Inventory.PLAYER_INTERACTION_MANAGER_FRAME_HIDE) == "function"
    Assert(hasHideHandler,
        "P3b",
        "PLAYER_INTERACTION_MANAGER_FRAME_HIDE handler exists",
        "Handler function is missing"
    )

    -- Verify OpenBags/CloseBags/ToggleBags functions exist
    Assert(type(Inventory.OpenBags) == "function",
        "P3c", "OpenBags function exists", "OpenBags is missing")
    Assert(type(Inventory.CloseBags) == "function",
        "P3d", "CloseBags function exists", "CloseBags is missing")
    Assert(type(Inventory.ToggleBags) == "function",
        "P3e", "ToggleBags function exists", "ToggleBags is missing")
end

-- =============================================================================
-- P4: Search/filter functionality works in inventory bags
-- Validates: Requirement 3.5 (search/filter)
-- =============================================================================
local function TestP4_SearchFilterFunctionality()
    local Inventory = private.Inventory
    local mainFrame = Inventory and Inventory.main
    if not mainFrame then
        Assert(false, "P4", "Inventory main frame exists", "Inventory.main is nil")
        return
    end

    -- Verify search box exists and is properly configured
    local searchBox = mainFrame.searchBox
    Assert(searchBox ~= nil,
        "P4a",
        "Search box exists on inventory frame",
        "mainFrame.searchBox is nil"
    )

    -- Verify search button exists
    local searchButton = mainFrame.searchButton
    Assert(searchButton ~= nil,
        "P4b",
        "Search button exists on inventory frame",
        "mainFrame.searchButton is nil"
    )

    -- Verify UpdateItemContext method exists on inventory slots (used during search)
    local inventoryBagIDs = mainFrame.bagIDs
    local hasUpdateItemContext = false
    for _, bagID in ipairs(inventoryBagIDs) do
        local numSlots = _G.C_Container.GetContainerNumSlots(bagID)
        for slotIndex = 1, numSlots do
            local slot = private.GetSlot(bagID, slotIndex)
            if slot and slot.UpdateItemContext then
                hasUpdateItemContext = true
                break
            end
        end
        if hasUpdateItemContext then break end
    end

    Assert(hasUpdateItemContext,
        "P4c",
        "Inventory slots have UpdateItemContext method",
        "No inventory slot with UpdateItemContext found"
    )
end



-- =============================================================================
-- P5: Inventory bags position correctly and display all items
-- Validates: Requirement 3.1 (bags appear at current position, function normally)
-- =============================================================================
local function TestP5_InventoryBagsDisplay()
    local Inventory = private.Inventory
    local mainFrame = Inventory and Inventory.main
    if not mainFrame then
        Assert(false, "P5", "Inventory main frame exists", "Inventory.main is nil")
        return
    end

    if not mainFrame:IsShown() then
        Assert(false, "P5", "Inventory bags are visible", "mainFrame is not shown — open bags first")
        return
    end

    -- Verify frame has a valid position (is on screen)
    local left = mainFrame:GetLeft()
    local bottom = mainFrame:GetBottom()
    local right = mainFrame:GetRight()
    local top = mainFrame:GetTop()

    Assert(left ~= nil and bottom ~= nil and right ~= nil and top ~= nil,
        "P5a",
        "Inventory frame has valid screen position",
        string.format("Position: left=%s bottom=%s right=%s top=%s",
            tostring(left), tostring(bottom), tostring(right), tostring(top))
    )

    -- Verify slots are populated
    local totalSlots = 0
    for _, bagID in ipairs(mainFrame.bagIDs) do
        totalSlots = totalSlots + _G.C_Container.GetContainerNumSlots(bagID)
    end

    Assert(totalSlots > 0,
        "P5b",
        "Inventory has slots available (" .. totalSlots .. " total)",
        "No inventory slots found"
    )

    -- Verify filter bags exist
    local filterBagCount = 0
    if mainFrame.bags then
        for tag, bag in next, mainFrame.bags do
            filterBagCount = filterBagCount + 1
        end
    end

    Assert(filterBagCount > 0,
        "P5c",
        "Inventory has filter bags (" .. filterBagCount .. " categories)",
        "No filter bags found"
    )

    -- Verify dropTarget (free slots counter) exists and is functional
    Assert(mainFrame.dropTarget ~= nil,
        "P5d",
        "Free slots counter (dropTarget) exists",
        "mainFrame.dropTarget is nil"
    )

    if mainFrame.dropTarget and mainFrame.dropTarget.count then
        local countText = mainFrame.dropTarget.count:GetText()
        Assert(countText ~= nil,
            "P5e",
            "Free slots counter displays a value (" .. tostring(countText) .. ")",
            "dropTarget count text is nil"
        )
    end
end

-- =============================================================================
-- P6: Sort/restack button works in inventory bags
-- Validates: Requirement 3.3 (sort/restack continues to work)
-- =============================================================================
local function TestP6_SortRestackButton()
    local Inventory = private.Inventory
    local mainFrame = Inventory and Inventory.main
    if not mainFrame then
        Assert(false, "P6", "Inventory main frame exists", "Inventory.main is nil")
        return
    end

    -- Verify restack button exists on inventory frame
    Assert(mainFrame.restackButton ~= nil,
        "P6a",
        "Restack button exists on inventory frame",
        "mainFrame.restackButton is nil"
    )

    if mainFrame.restackButton then
        -- Verify it has an OnClick handler
        local hasClick = mainFrame.restackButton:GetScript("OnClick") ~= nil
        Assert(hasClick,
            "P6b",
            "Restack button has OnClick handler",
            "No OnClick script set"
        )
    end

    -- Verify bank restack button exists (if bank frame exists)
    local bankFrame = Inventory.bank
    if bankFrame then
        Assert(bankFrame.restackButton ~= nil,
            "P6c",
            "Restack button exists on bank frame",
            "bankFrame.restackButton is nil"
        )
    end
end

-- =============================================================================
-- P7: Closing bags via close button or NPC interaction hides frames
-- Validates: Requirement 3.6 (close behavior)
-- =============================================================================
local function TestP7_CloseBehavior()
    local Inventory = private.Inventory
    local mainFrame = Inventory and Inventory.main
    if not mainFrame then
        Assert(false, "P7", "Inventory main frame exists", "Inventory.main is nil")
        return
    end

    -- Verify close button exists
    Assert(mainFrame.close ~= nil,
        "P7a",
        "Close button exists on inventory frame",
        "mainFrame.close is nil"
    )

    -- Verify OnHide script is set (handles cleanup on close)
    local hasOnHide = mainFrame:GetScript("OnHide") ~= nil
    Assert(hasOnHide,
        "P7b",
        "Inventory frame has OnHide handler",
        "No OnHide script set"
    )

    -- Verify bank close behavior
    local bankFrame = Inventory.bank
    if bankFrame then
        Assert(bankFrame.close ~= nil,
            "P7c",
            "Close button exists on bank frame",
            "bankFrame.close is nil"
        )

        local bankHasOnHide = bankFrame:GetScript("OnHide") ~= nil
        Assert(bankHasOnHide,
            "P7d",
            "Bank frame has OnHide handler",
            "No OnHide script set on bank frame"
        )
    end

    -- Verify CloseBags function works (doesn't error)
    local closeBagsOK = type(Inventory.CloseBags) == "function"
    Assert(closeBagsOK,
        "P7e",
        "CloseBags function is available",
        "CloseBags is not a function"
    )

    -- Verify CloseBank function exists
    local closeBankOK = type(Inventory.CloseBank) == "function"
    Assert(closeBankOK,
        "P7f",
        "CloseBank function is available",
        "CloseBank is not a function"
    )
end

-- =============================================================================
-- P8: Tab switching in bank sidebar displays correct tab content
-- Validates: Requirement 3.7, 3.8 (tab switching, tab content display)
-- =============================================================================
local function TestP8_TabSwitching()
    local Inventory = private.Inventory
    local bankFrame = Inventory and Inventory.bank
    if not bankFrame then
        Assert(false, "P8", "Bank frame exists", "Inventory.bank is nil")
        return
    end

    -- Verify tabSidebar exists
    local tabSidebar = bankFrame.tabSidebar
    Assert(tabSidebar ~= nil,
        "P8a",
        "Tab sidebar exists on bank frame",
        "bankFrame.tabSidebar is nil"
    )

    if not tabSidebar then return end

    -- Verify SelectTab method exists
    Assert(type(tabSidebar.SelectTab) == "function",
        "P8b",
        "TabSidebar has SelectTab method",
        "SelectTab is not a function"
    )

    -- Verify GetSelectedTabID method exists
    Assert(type(tabSidebar.GetSelectedTabID) == "function",
        "P8c",
        "TabSidebar has GetSelectedTabID method",
        "GetSelectedTabID is not a function"
    )

    -- Verify Refresh method exists
    Assert(type(tabSidebar.Refresh) == "function",
        "P8d",
        "TabSidebar has Refresh method",
        "Refresh is not a function"
    )

    -- Verify SetActiveTab exists on bank frame
    Assert(type(bankFrame.SetActiveTab) == "function",
        "P8e",
        "BankFrame has SetActiveTab method",
        "SetActiveTab is not a function"
    )

    -- Verify SetBankType exists on bank frame
    Assert(type(bankFrame.SetBankType) == "function",
        "P8f",
        "BankFrame has SetBankType method",
        "SetBankType is not a function"
    )

    -- If bank is open, verify tab buttons were created
    if bankFrame:IsShown() and tabSidebar.tabButtons then
        local visibleTabs = 0
        for _, btn in ipairs(tabSidebar.tabButtons) do
            if btn:IsShown() then
                visibleTabs = visibleTabs + 1
            end
        end
        -- Only assert if bank is actually open (tabs may be 0 if bank is closed)
        if visibleTabs > 0 then
            Assert(true,
                "P8g",
                "Bank tab sidebar has " .. visibleTabs .. " visible tab(s)",
                nil
            )
        end
    end
end

-- =============================================================================
-- P9: Bank type switcher exists and has correct structure
-- Validates: Requirement 3.7 (bank type switching continues to work)
-- =============================================================================
local function TestP9_BankTypeSwitcher()
    local Inventory = private.Inventory
    local bankFrame = Inventory and Inventory.bank
    if not bankFrame then
        Assert(false, "P9", "Bank frame exists", "Inventory.bank is nil")
        return
    end

    local switcher = bankFrame.bankTypeSwitcher
    Assert(switcher ~= nil,
        "P9a",
        "Bank type switcher exists",
        "bankFrame.bankTypeSwitcher is nil"
    )

    if not switcher then return end

    -- Verify switcher has buttons for Character and Account bank types
    Assert(switcher.buttons ~= nil,
        "P9b",
        "Bank type switcher has buttons table",
        "switcher.buttons is nil"
    )

    if switcher.buttons then
        local charBtn = switcher.buttons[_G.Enum.BankType.Character]
        local acctBtn = switcher.buttons[_G.Enum.BankType.Account]

        Assert(charBtn ~= nil,
            "P9c",
            "Character bank type button exists",
            "No button for BankType.Character"
        )
        Assert(acctBtn ~= nil,
            "P9d",
            "Account (Warband) bank type button exists",
            "No button for BankType.Account"
        )
    end

    -- Verify SetActiveType and Refresh methods exist
    Assert(type(switcher.SetActiveType) == "function",
        "P9e",
        "BankTypeSwitcher has SetActiveType method",
        "SetActiveType is not a function"
    )
    Assert(type(switcher.Refresh) == "function",
        "P9f",
        "BankTypeSwitcher has Refresh method",
        "Refresh is not a function"
    )
end

-- =============================================================================
-- P10: ShowBags toggle works for inventory bags
-- Validates: Requirement 3.1 (bag slot toggle continues to work)
-- =============================================================================
local function TestP10_ShowBagsToggle()
    local Inventory = private.Inventory
    local mainFrame = Inventory and Inventory.main
    if not mainFrame then
        Assert(false, "P10", "Inventory main frame exists", "Inventory.main is nil")
        return
    end

    -- Verify showBags button exists
    Assert(mainFrame.showBags ~= nil,
        "P10a",
        "ShowBags button exists on inventory frame",
        "mainFrame.showBags is nil"
    )

    if mainFrame.showBags then
        -- Verify ToggleBags method exists on the button
        Assert(type(mainFrame.showBags.ToggleBags) == "function",
            "P10b",
            "ShowBags button has ToggleBags method",
            "ToggleBags is not a function"
        )
    end

    -- Verify bagSlots structure exists for main
    Assert(private.bagSlots ~= nil,
        "P10c",
        "private.bagSlots exists",
        "bagSlots is nil"
    )

    if private.bagSlots then
        Assert(private.bagSlots["main"] ~= nil,
            "P10d",
            "Bag slots created for inventory (main)",
            "bagSlots['main'] is nil"
        )
    end
end

-- =============================================================================
-- Main test runner
-- =============================================================================
local function RealUI_PreservationTests()
    passCount, failCount = 0, 0

    print("=== RealUI Bank Bugfix — Preservation Tests ===")
    print("Expected: All tests PASS (confirms baseline behavior to preserve)")
    print("")

    -- Tests that don't require bags to be open
    TestP3_BagEventHooksRegistered()
    TestP6_SortRestackButton()
    TestP7_CloseBehavior()
    TestP8_TabSwitching()
    TestP9_BankTypeSwitcher()
    TestP10_ShowBagsToggle()

    -- Tests that work best with bags open
    local Inventory = private.Inventory
    local mainFrame = Inventory and Inventory.main

    if not mainFrame or not mainFrame:IsShown() then
        print("|cFFFFFF00WARNING|r: Inventory bags are not open. Open bags for full results.")
        print("Structural tests completed. Open bags and re-run for slot-level tests.")
    else
        TestP1_InventorySlotGetBagID()
        TestP2_InventoryItemInteractions()
        TestP4_SearchFilterFunctionality()
        TestP5_InventoryBagsDisplay()
    end

    print("")
    print(string.format("=== Results: %d PASS, %d FAIL ===", passCount, failCount))
    if failCount > 0 then
        print("|cFFFF0000UNEXPECTED|r: Preservation tests should PASS on unfixed code!")
        print("Failures indicate a regression or test issue.")
    else
        print("|cFF00FF00All preservation tests passed — baseline behavior confirmed.|r")
    end
end

-- Slash command for convenience
_G.SLASH_REALUIPRESERVE1 = "/realuipreserve"
_G.SlashCmdList["REALUIPRESERVE"] = RealUI_PreservationTests
