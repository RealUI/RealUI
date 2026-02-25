local ADDON_NAME, ns = ...

-- Preservation Property Test: Non-Bank Bag Behavior Unchanged
-- Feature: bank-cosmetic-fixes, Property 2: Preservation
-- Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6
--
-- IMPORTANT: Follow observation-first methodology.
-- These tests capture the CURRENT (unfixed) behavior of non-bank bag operations.
-- They MUST PASS on unfixed code to establish a baseline.
-- After the bugfix, they MUST STILL PASS to confirm no regressions.

local RealUI = _G.RealUI

local function RunBankPreservationTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.main then
        _G.print("|cffff0000[ERROR]|r Inventory module or main bags not available.")
        return false
    end

    local main = Inventory.main
    local bank = Inventory.bank

    _G.print("|cff00ccff[PRESERVATION]|r Non-Bank Bag Behavior — running 6 tests")
    _G.print("  Expected: ALL tests PASS on unfixed code (baseline preserved)")

    local failures = 0

    ---------------------------------------------------------------------------
    -- Test 1 — Bag-Only Position (Req 3.1)
    -- Bags frame is draggable, so the anchor may change after user interaction.
    -- We verify the frame exists and is functional rather than checking a
    -- specific anchor, since MakeFrameDraggable intentionally allows repositioning.
    ---------------------------------------------------------------------------
    do
        local point = main:GetPoint(1)

        if not point then
            _G.print("|cffff0000[FAIL]|r Test 1 — Bag-Only Position: no anchor point set on bags frame")
            failures = failures + 1
        else
            _G.print(("|cff00ff00[PASS]|r Test 1 — Bag-Only Position: bags frame has anchor %s (draggable)")
                :format(point))
        end
    end

    ---------------------------------------------------------------------------
    -- Test 2 — Merchant/AH/Mail Bag Open Hook (Req 3.2)
    -- PLAYER_INTERACTION_MANAGER_FRAME_SHOW for merchant/AH/mail opens bags.
    -- Observed: Inventory:PLAYER_INTERACTION_MANAGER_FRAME_SHOW calls OpenBags
    -- for Merchant, Auctioneer, GuildBanker, TradePartner interaction types.
    ---------------------------------------------------------------------------
    do
        -- Ensure bags are hidden first
        local wasShown = main:IsShown()
        main:Hide()

        local openCalled = false
        local origOpenBags = Inventory.OpenBags
        Inventory.OpenBags = function(self, frame)
            if frame == nil then
                openCalled = true
            end
            -- Don't actually show to keep test clean
        end

        -- Simulate merchant interaction show
        Inventory:PLAYER_INTERACTION_MANAGER_FRAME_SHOW(
            "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
            _G.Enum.PlayerInteractionType.Merchant
        )

        Inventory.OpenBags = origOpenBags

        -- Restore original state
        if wasShown then main:Show() else main:Hide() end

        if not openCalled then
            _G.print("|cffff0000[FAIL]|r Test 2 — Merchant Bag Open: OpenBags not called for Merchant interaction")
            failures = failures + 1
        else
            _G.print("|cff00ff00[PASS]|r Test 2 — Merchant Bag Open: OpenBags called for Merchant interaction")
        end
    end

    ---------------------------------------------------------------------------
    -- Test 3 — Merchant/AH/Mail Bag Close Hook (Req 3.2)
    -- PLAYER_INTERACTION_MANAGER_FRAME_HIDE for merchant/AH/mail closes bags.
    ---------------------------------------------------------------------------
    do
        local closeCalled = false
        local origCloseBags = Inventory.CloseBags
        Inventory.CloseBags = function(self, frame)
            if frame == nil then
                closeCalled = true
            end
        end

        -- Simulate merchant interaction hide
        Inventory:PLAYER_INTERACTION_MANAGER_FRAME_HIDE(
            "PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
            _G.Enum.PlayerInteractionType.Merchant
        )

        Inventory.CloseBags = origCloseBags

        if not closeCalled then
            _G.print("|cffff0000[FAIL]|r Test 3 — Merchant Bag Close: CloseBags not called for Merchant hide")
            failures = failures + 1
        else
            _G.print("|cff00ff00[PASS]|r Test 3 — Merchant Bag Close: CloseBags called for Merchant hide")
        end
    end


    ---------------------------------------------------------------------------
    -- Test 4 — Search Filter Propagation (Req 3.5)
    -- INVENTORY_SEARCH_UPDATE event triggers UpdateItemContext on filter bag slots.
    -- Observed on unfixed code: MainBagMixin:OnEvent iterates self.bags (filter bags)
    -- and calls slot:UpdateItemContext() on each slot. The primary bag's own slots
    -- (main.slots) are NOT iterated by this path — only filter bag slots are updated.
    -- This is the baseline behavior we preserve.
    ---------------------------------------------------------------------------
    do
        local updateCount = 0

        -- Hook only filter bag slots — these are the ones the event handler touches
        local hookedSlots = {}
        for tag, bag in _G.next, main.bags do
            for _, slot in _G.ipairs(bag.slots) do
                if slot.UpdateItemContext then
                    local orig = slot.UpdateItemContext
                    slot.UpdateItemContext = function(self, ...)
                        updateCount = updateCount + 1
                        return orig(self, ...)
                    end
                    _G.tinsert(hookedSlots, { slot = slot, orig = orig })
                end
            end
        end

        local totalFilterSlots = #hookedSlots

        -- Fire the event handler directly
        if totalFilterSlots > 0 then
            main:OnEvent("INVENTORY_SEARCH_UPDATE")
        end

        -- Restore originals
        for _, entry in _G.ipairs(hookedSlots) do
            entry.slot.UpdateItemContext = entry.orig
        end

        if totalFilterSlots == 0 then
            -- No slots loaded — structural check: verify the event handler exists
            local hasHandler = (main.OnEvent ~= nil)
            if hasHandler then
                _G.print("|cff00ff00[PASS]|r Test 4 — Search Filter: OnEvent handler exists (no filter slots to verify)")
            else
                _G.print("|cffff0000[FAIL]|r Test 4 — Search Filter: no OnEvent handler on main bag")
                failures = failures + 1
            end
        elseif updateCount >= totalFilterSlots then
            _G.print(("|cff00ff00[PASS]|r Test 4 — Search Filter: %d/%d filter bag slots received UpdateItemContext")
                :format(updateCount, totalFilterSlots))
        else
            _G.print(("|cffff0000[FAIL]|r Test 4 — Search Filter: only %d/%d filter bag slots received UpdateItemContext")
                :format(updateCount, totalFilterSlots))
            failures = failures + 1
        end
    end

    ---------------------------------------------------------------------------
    -- Test 5 — Bank Close Hides Bank Frame (Req 3.6)
    -- Inventory:CloseBank() hides the bank frame.
    ---------------------------------------------------------------------------
    do
        if not bank then
            _G.print("|cffff0000[FAIL]|r Test 5 — Bank Close: bank frame not available")
            failures = failures + 1
        else
            -- Stub C_Bank.CloseBankFrame to prevent errors when bank isn't actually open
            local origCloseBankFrame = _G.C_Bank.CloseBankFrame
            _G.C_Bank.CloseBankFrame = function() end

            -- Stub PlaySound to prevent audio
            local origPlaySound = _G.PlaySound
            _G.PlaySound = function() end

            -- Stub FrameUtil to prevent event unregistration errors
            local origUnregister = _G.FrameUtil.UnregisterFrameForEvents
            _G.FrameUtil.UnregisterFrameForEvents = function() end

            -- Stub showBags:ToggleBags to prevent cascade
            local origToggle
            if bank.showBags then
                origToggle = bank.showBags.ToggleBags
                bank.showBags.ToggleBags = function() end
            end

            bank:Show()
            local wasShown = bank:IsShown()

            -- Call CloseBank which should hide the bank
            Inventory:CloseBank()
            local isHidden = not bank:IsShown()

            -- Restore
            _G.C_Bank.CloseBankFrame = origCloseBankFrame
            _G.PlaySound = origPlaySound
            _G.FrameUtil.UnregisterFrameForEvents = origUnregister
            if bank.showBags and origToggle then
                bank.showBags.ToggleBags = origToggle
            end
            bank:Hide()

            if wasShown and isHidden then
                _G.print("|cff00ff00[PASS]|r Test 5 — Bank Close: bank frame hidden after CloseBank()")
            else
                _G.print(("|cffff0000[FAIL]|r Test 5 — Bank Close: wasShown=%s isHidden=%s")
                    :format(tostring(wasShown), tostring(isHidden)))
                failures = failures + 1
            end
        end
    end

    ---------------------------------------------------------------------------
    -- Test 6 — Bank Close Auto-Closes Bags (Req 3.6)
    -- If bags were auto-opened for bank, CloseBank() also closes bags.
    ---------------------------------------------------------------------------
    do
        if not bank then
            _G.print("|cffff0000[FAIL]|r Test 6 — Bank Auto-Close Bags: bank frame not available")
            failures = failures + 1
        else
            -- Stub C_Bank.CloseBankFrame
            local origCloseBankFrame = _G.C_Bank.CloseBankFrame
            _G.C_Bank.CloseBankFrame = function() end

            local origPlaySound = _G.PlaySound
            _G.PlaySound = function() end

            local origUnregister = _G.FrameUtil.UnregisterFrameForEvents
            _G.FrameUtil.UnregisterFrameForEvents = function() end

            local origToggle
            if bank.showBags then
                origToggle = bank.showBags.ToggleBags
                bank.showBags.ToggleBags = function() end
            end

            -- Simulate: bags were auto-opened for bank
            Inventory.openedBagsForBank = true
            bank:Show()

            local closeBagsCalled = false
            local origCloseBags = Inventory.CloseBags
            Inventory.CloseBags = function(self, frame)
                if frame == nil then
                    closeBagsCalled = true
                end
            end

            Inventory:CloseBank()

            Inventory.CloseBags = origCloseBags
            _G.C_Bank.CloseBankFrame = origCloseBankFrame
            _G.PlaySound = origPlaySound
            _G.FrameUtil.UnregisterFrameForEvents = origUnregister
            if bank.showBags and origToggle then
                bank.showBags.ToggleBags = origToggle
            end
            bank:Hide()
            Inventory.openedBagsForBank = false

            if closeBagsCalled then
                _G.print("|cff00ff00[PASS]|r Test 6 — Bank Auto-Close Bags: CloseBags called when openedBagsForBank=true")
            else
                _G.print("|cffff0000[FAIL]|r Test 6 — Bank Auto-Close Bags: CloseBags NOT called despite openedBagsForBank=true")
                failures = failures + 1
            end
        end
    end

    ---------------------------------------------------------------------------
    -- Summary
    ---------------------------------------------------------------------------
    _G.print("---")
    if failures > 0 then
        _G.print(("|cffff0000[PRESERVATION RESULT]|r %d/6 tests FAILED — baseline behavior broken"):format(failures))
    else
        _G.print("|cff00ff00[PRESERVATION RESULT]|r All 6 tests passed — baseline behavior confirmed")
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:bankpreservation()
    return RunBankPreservationTest()
end
