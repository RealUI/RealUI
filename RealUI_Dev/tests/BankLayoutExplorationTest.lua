local ADDON_NAME, ns = ... -- luacheck: ignore

-- Bug Condition Exploration Test: Bank Layout Defects
-- Feature: bank-layout-fixes, Property 1: Bug Condition
-- Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5
--
-- CRITICAL: These tests MUST FAIL on unfixed code — failure confirms the bugs exist.
-- DO NOT attempt to fix the test or the code when it fails.
-- GOAL: Surface counterexamples that demonstrate the 4 layout bugs exist.

local RealUI = _G.RealUI

local function RunBankLayoutExplorationTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    local bank = Inventory.bank

    _G.print("|cff00ccff[BUG EXPLORATION]|r Bank Layout Defects -- running 5 tests")
    _G.print("  Expected: ALL tests FAIL on unfixed code (failure = bug confirmed)")

    local failures = 0

    ---------------------------------------------------------------------------
    -- Test 1 -- Bank Frame Position (Bug 1.1)
    -- Expected (fixed): CENTER, UIParent, CENTER, 200, 0
    -- Bug: RIGHT, UIParent, RIGHT, -100, 0
    ---------------------------------------------------------------------------
    do
        bank:ClearAllPoints()
        bank:SetPoint("RIGHT", _G.UIParent, "RIGHT", -100, 0)

        local point, relativeTo, relativePoint, xOfs, yOfs = bank:GetPoint(1)
        local relName = relativeTo and relativeTo:GetName() or tostring(relativeTo)

        if point ~= "CENTER" or relativePoint ~= "CENTER"
            or math.floor(xOfs + 0.5) ~= 200 or math.floor(yOfs + 0.5) ~= 0 then
            _G.print(("|cffff0000[FAIL]|r Test 1 -- Bank Frame Position: got %s, %s, %s, %d, %d (want CENTER, UIParent, CENTER, 200, 0)")
                :format(tostring(point), relName, tostring(relativePoint),
                    math.floor(xOfs + 0.5), math.floor(yOfs + 0.5)))
            failures = failures + 1
        else
            _G.print("|cff00ff00[PASS]|r Test 1 -- Bank Frame Position: anchor correct")
        end
    end

    ---------------------------------------------------------------------------
    -- Test 2 -- Restack Anchor Chain (Bug 1.2)
    -- Expected (fixed): restack anchored to close button backdrop, not deposit
    -- Bug: restack anchored to deposit
    ---------------------------------------------------------------------------
    do
        local restackButton = bank.restackButton
        local close = bank.close
        local deposit = bank.deposit

        if not restackButton or not close then
            _G.print("|cffff0000[ERROR]|r Test 2 -- restack or close button not found")
        else
            local _, anchorTarget = restackButton:GetPoint(1)
            local closeBg = close:GetBackdropTexture("bg")

            if anchorTarget == closeBg then
                _G.print("|cff00ff00[PASS]|r Test 2 -- Restack Anchor Chain: restack anchored to close backdrop")
            else
                local anchorName = "unknown"
                if anchorTarget == deposit then
                    anchorName = "deposit"
                elseif anchorTarget == close then
                    anchorName = "close (frame, not backdrop)"
                elseif anchorTarget and anchorTarget.GetName then
                    anchorName = anchorTarget:GetName() or "anonymous frame"
                end
                _G.print(("|cffff0000[FAIL]|r Test 2 -- Restack Anchor Chain: restack anchored to %s (want close backdrop)")
                    :format(anchorName))
                failures = failures + 1
            end
        end
    end

    ---------------------------------------------------------------------------
    -- Test 3 -- Restack Position (Character bank) (Bug 1.3)
    -- When Character bank is active, deposit is hidden. Restack should still
    -- be positioned next to close (not anchored to hidden deposit).
    ---------------------------------------------------------------------------
    do
        local restackButton = bank.restackButton
        local close = bank.close
        local deposit = bank.deposit

        if not restackButton or not close or not deposit then
            _G.print("|cffff0000[ERROR]|r Test 3 -- required buttons not found")
        else
            local origShown = deposit:IsShown()
            deposit:Hide()

            local _, anchorTarget = restackButton:GetPoint(1)
            local closeBg = close:GetBackdropTexture("bg")

            if anchorTarget == closeBg then
                _G.print("|cff00ff00[PASS]|r Test 3 -- Restack Position (Character): restack next to close when deposit hidden")
            else
                local anchorName = "unknown"
                if anchorTarget == deposit then
                    anchorName = "deposit (hidden)"
                elseif anchorTarget and anchorTarget.GetName then
                    anchorName = anchorTarget:GetName() or "anonymous frame"
                end
                _G.print(("|cffff0000[FAIL]|r Test 3 -- Restack Position (Character): restack anchored to %s when deposit hidden (want close backdrop)")
                    :format(anchorName))
                failures = failures + 1
            end

            if origShown then
                deposit:Show()
            end
        end
    end

    ---------------------------------------------------------------------------
    -- Test 4 -- Character Reagent Deposit (Bug 1.4)
    -- Expected (fixed): deposit button visible for Character bank type
    -- Bug: deposit hidden because supportsAutoDeposit = false for Character
    ---------------------------------------------------------------------------
    do
        local deposit = bank.deposit

        if not deposit then
            _G.print("|cffff0000[ERROR]|r Test 4 -- deposit button not found on bank frame")
        else
            local origFetch = _G.C_Bank.FetchPurchasedBankTabData
            _G.C_Bank.FetchPurchasedBankTabData = function() return {} end

            local origSidebarRefresh
            if bank.tabSidebar then
                origSidebarRefresh = bank.tabSidebar.Refresh
                bank.tabSidebar.Refresh = function(self)
                    self.selectedTabID = nil
                    bank:SetActiveTab(nil)
                end
            end

            bank:SetBankType(_G.Enum.BankType.Character)
            local isShown = deposit:IsShown()

            _G.C_Bank.FetchPurchasedBankTabData = origFetch
            if bank.tabSidebar and origSidebarRefresh then
                bank.tabSidebar.Refresh = origSidebarRefresh
            end

            if isShown then
                _G.print("|cff00ff00[PASS]|r Test 4 -- Character Reagent Deposit: deposit visible for Character bank")
            else
                _G.print("|cffff0000[FAIL]|r Test 4 -- Character Reagent Deposit: deposit hidden for Character bank (supportsAutoDeposit = false)")
                failures = failures + 1
            end
        end
    end


    ---------------------------------------------------------------------------
    -- Test 5 -- Vertical Alignment (Bug 1.5)
    -- Expected (fixed): showBags text and switcher buttons share same Y-center
    -- Bug: TOPLEFT-to-TOPRIGHT anchor causes vertical mismatch
    ---------------------------------------------------------------------------
    do
        local showBags = bank.showBags
        local switcher = bank.bankTypeSwitcher

        if not showBags or not switcher then
            _G.print("|cffff0000[ERROR]|r Test 5 -- showBags or bankTypeSwitcher not found")
        else
            local firstBtn
            for _, btn in _G.next, switcher.buttons do
                if btn:IsShown() then
                    firstBtn = btn
                    break
                end
            end

            if not firstBtn then
                _G.print("|cffff0000[ERROR]|r Test 5 -- no visible switcher button found")
            else
                local _, showBagsCenter = showBags:GetCenter()
                local _, switcherCenter = firstBtn:GetCenter()

                if showBagsCenter and switcherCenter then
                    local diff = math.abs(showBagsCenter - switcherCenter)
                    if diff < 1 then
                        _G.print(("|cff00ff00[PASS]|r Test 5 -- Vertical Alignment: Y diff = %.2f (< 1)"):format(diff))
                    else
                        _G.print(("|cffff0000[FAIL]|r Test 5 -- Vertical Alignment: Y diff = %.2f (want < 1)"):format(diff))
                        failures = failures + 1
                    end
                else
                    _G.print("|cffff0000[ERROR]|r Test 5 -- could not get center coordinates (frame not shown?)")
                end
            end
        end
    end


    ---------------------------------------------------------------------------
    -- Summary
    ---------------------------------------------------------------------------
    _G.print("---")
    if failures > 0 then
        _G.print(("|cffff0000[EXPLORATION RESULT]|r %d/5 tests FAILED -- bugs confirmed"):format(failures))
        _G.print("  Counterexamples documented above. These failures are EXPECTED on unfixed code.")
    else
        _G.print("|cff00ff00[EXPLORATION RESULT]|r All 5 tests passed -- bugs may be fixed")
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:banklayoutexplore()
    return RunBankLayoutExplorationTest()
end
