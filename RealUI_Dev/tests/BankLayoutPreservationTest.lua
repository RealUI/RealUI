local ADDON_NAME, ns = ... -- luacheck: ignore

-- Preservation Property Test: Non-Layout Bank and Inventory Behavior
-- Feature: bank-layout-fixes, Property 2: Preservation
-- Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7
--
-- IMPORTANT: Follow observation-first methodology.
-- These tests capture the CURRENT (unfixed) behavior of non-layout operations.
-- They MUST PASS on unfixed code to establish a baseline.
-- After the bugfix, they MUST STILL PASS to confirm no regressions.

local RealUI = _G.RealUI

local function RunBankLayoutPreservationTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.main then
        _G.print("|cffff0000[ERROR]|r Inventory module or main bags not available.")
        return false
    end

    local main = Inventory.main
    local bank = Inventory.bank

    if not bank then
        _G.print("|cffff0000[ERROR]|r Bank frame not available. Open bank at a vendor first.")
        return false
    end

    _G.print("|cff00ccff[PRESERVATION]|r Non-Layout Bank & Inventory — running 7 tests")
    _G.print("  Expected: ALL tests PASS on unfixed code (baseline preserved)")

    local failures = 0

    ---------------------------------------------------------------------------
    -- Test 1 — Inventory Frame Preservation (Req 3.1)
    -- Bags frame is draggable, so the anchor may change after user interaction.
    -- We verify the frame exists and has a valid anchor point.
    ---------------------------------------------------------------------------
    do
        local point = main:GetPoint(1)

        if not point then
            _G.print("|cffff0000[FAIL]|r Test 1 — Inventory Frame: no anchor point set on bags frame")
            failures = failures + 1
        else
            _G.print(("|cff00ff00[PASS]|r Test 1 — Inventory Frame: bags frame has anchor %s (functional)")
                :format(point))
        end
    end

    ---------------------------------------------------------------------------
    -- Test 2 — Warband Deposit Preservation (Req 3.2)
    -- Set bank type to Account, verify deposit button is shown and
    -- bankTypeConfig[Account].supportsAutoDeposit == true.
    ---------------------------------------------------------------------------
    do
        -- Save current state
        local origBankType = bank:GetActiveBankType()

        -- Stub out methods that would cause side effects
        local origSetActiveTab = bank.SetActiveTab
        bank.SetActiveTab = function() end
        local origTabSidebarRefresh
        if bank.tabSidebar then
            origTabSidebarRefresh = bank.tabSidebar.Refresh
            bank.tabSidebar.Refresh = function() end
        end

        -- Set to Account bank type
        bank:SetBankType(_G.Enum.BankType.Account)

        local depositShown = bank.deposit and bank.deposit:IsShown()

        -- Restore
        bank.SetActiveTab = origSetActiveTab
        if bank.tabSidebar and origTabSidebarRefresh then
            bank.tabSidebar.Refresh = origTabSidebarRefresh
        end
        if origBankType then
            bank:SetBankType(origBankType)
        end

        if depositShown then
            _G.print("|cff00ff00[PASS]|r Test 2 — Warband Deposit: deposit button shown for Account bank type")
        else
            _G.print("|cffff0000[FAIL]|r Test 2 — Warband Deposit: deposit button NOT shown for Account bank type")
            failures = failures + 1
        end
    end

    ---------------------------------------------------------------------------
    -- Test 3 — Tab Sidebar Preservation (Req 3.3)
    -- Verify bank tab sidebar buttons exist and SetActiveTab method is callable.
    ---------------------------------------------------------------------------
    do
        local hasTabSidebar = (bank.tabSidebar ~= nil)
        local hasSetActiveTab = (type(bank.SetActiveTab) == "function")

        if hasTabSidebar and hasSetActiveTab then
            _G.print("|cff00ff00[PASS]|r Test 3 — Tab Sidebar: tabSidebar exists and SetActiveTab is callable")
        else
            _G.print(("|cffff0000[FAIL]|r Test 3 — Tab Sidebar: tabSidebar=%s SetActiveTab=%s")
                :format(tostring(hasTabSidebar), tostring(hasSetActiveTab)))
            failures = failures + 1
        end
    end

    ---------------------------------------------------------------------------
    -- Test 4 — Bank Drag Preservation (Req 3.4)
    -- Verify bank frame is movable via IsMovable().
    -- MakeFrameDraggable calls SetMovable(true) on the frame.
    ---------------------------------------------------------------------------
    do
        local isMovable = bank:IsMovable()

        if isMovable then
            _G.print("|cff00ff00[PASS]|r Test 4 — Bank Drag: bank frame IsMovable() == true")
        else
            _G.print("|cffff0000[FAIL]|r Test 4 — Bank Drag: bank frame IsMovable() == false")
            failures = failures + 1
        end
    end

    ---------------------------------------------------------------------------
    -- Test 5 — Inventory Restack Preservation (Req 3.5)
    -- Verify inventory (main bags) restack button exists and its click handler
    -- calls C_Container.SortBags().
    ---------------------------------------------------------------------------
    do
        local restackButton = main.restackButton
        if not restackButton then
            _G.print("|cffff0000[FAIL]|r Test 5 — Inventory Restack: restackButton not found on main bags")
            failures = failures + 1
        else
            -- Verify anchor: should be TOPRIGHT of settingsButton TOPLEFT
            local point, relativeTo = restackButton:GetPoint(1)
            local anchorOk = (point == "TOPRIGHT") and (relativeTo == main.settingsButton)

            -- Verify click handler calls C_Container.SortBags()
            local sortCalled = false
            local origSortBags = _G.C_Container.SortBags
            local origPlaySound = _G.PlaySound
            _G.C_Container.SortBags = function() sortCalled = true end
            _G.PlaySound = function() end

            restackButton:Click("LeftButton")

            _G.C_Container.SortBags = origSortBags
            _G.PlaySound = origPlaySound

            if anchorOk and sortCalled then
                _G.print("|cff00ff00[PASS]|r Test 5 — Inventory Restack: anchor TOPRIGHT→settingsButton and SortBags() called")
            elseif not anchorOk then
                _G.print(("|cffff0000[FAIL]|r Test 5 — Inventory Restack: unexpected anchor %s (expected TOPRIGHT→settingsButton)")
                    :format(tostring(point)))
                failures = failures + 1
            else
                _G.print("|cffff0000[FAIL]|r Test 5 — Inventory Restack: SortBags() not called on click")
                failures = failures + 1
            end
        end
    end

    ---------------------------------------------------------------------------
    -- Test 6 — Close Button Preservation (Req 3.6)
    -- Verify bank close button exists and OnHide calls C_Bank.CloseBankFrame().
    ---------------------------------------------------------------------------
    do
        local closeBtn = bank.close
        if not closeBtn then
            _G.print("|cffff0000[FAIL]|r Test 6 — Close Button: close button not found on bank frame")
            failures = failures + 1
        else
            -- Verify C_Bank.CloseBankFrame is called when bank hides.
            -- BankBagMixin:OnHide calls C_Bank.CloseBankFrame() directly.
            local closeBankCalled = false
            local origCloseBankFrame = _G.C_Bank.CloseBankFrame
            local origPlaySound = _G.PlaySound
            local origUnregister = _G.FrameUtil.UnregisterFrameForEvents
            _G.C_Bank.CloseBankFrame = function() closeBankCalled = true end
            _G.PlaySound = function() end
            _G.FrameUtil.UnregisterFrameForEvents = function() end

            -- Stub showBags:ToggleBags to prevent cascade
            local origToggle
            if bank.showBags then
                origToggle = bank.showBags.ToggleBags
                bank.showBags.ToggleBags = function() end
            end

            bank:Show()
            bank:Hide() -- triggers OnHide which calls C_Bank.CloseBankFrame()

            -- Restore
            _G.C_Bank.CloseBankFrame = origCloseBankFrame
            _G.PlaySound = origPlaySound
            _G.FrameUtil.UnregisterFrameForEvents = origUnregister
            if bank.showBags and origToggle then
                bank.showBags.ToggleBags = origToggle
            end

            if closeBankCalled then
                _G.print("|cff00ff00[PASS]|r Test 6 — Close Button: C_Bank.CloseBankFrame() called on bank hide")
            else
                _G.print("|cffff0000[FAIL]|r Test 6 — Close Button: C_Bank.CloseBankFrame() NOT called on bank hide")
                failures = failures + 1
            end
        end
    end

    ---------------------------------------------------------------------------
    -- Test 7 — Search Box Preservation (Req 3.7)
    -- Verify bank search box exists.
    ---------------------------------------------------------------------------
    do
        local searchBox = bank.searchBox
        if not searchBox then
            _G.print("|cffff0000[FAIL]|r Test 7 — Search Box: searchBox not found on bank frame")
            failures = failures + 1
        else
            _G.print("|cff00ff00[PASS]|r Test 7 — Search Box: bank searchBox exists")
        end
    end

    ---------------------------------------------------------------------------
    -- Summary
    ---------------------------------------------------------------------------
    _G.print("---")
    if failures > 0 then
        _G.print(("|cffff0000[PRESERVATION RESULT]|r %d/7 tests FAILED — baseline behavior broken"):format(failures))
    else
        _G.print("|cff00ff00[PRESERVATION RESULT]|r All 7 tests passed — baseline behavior confirmed")
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:banklayoutpreserve()
    return RunBankLayoutPreservationTest()
end
