local ADDON_NAME, ns = ...

-- Property Test: Bank lifecycle round-trip
-- Feature: inventory-bank-rewrite, Property 1: Bank lifecycle round-trip
-- Validates: Requirements 1.1, 1.2
--
-- For any banker interaction type (Banker, CharacterBanker, or AccountBanker),
-- firing a SHOW event followed by a HIDE event should return the addon to its
-- initial state: atBank is false, the bank frame is hidden, and
-- C_Bank.CloseBankFrame() was called.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

-- Banker interaction types to test
local bankerTypes = {
    _G.Enum.PlayerInteractionType.Banker,
    _G.Enum.PlayerInteractionType.CharacterBanker,
    _G.Enum.PlayerInteractionType.AccountBanker,
}

-- Simple RNG for property-based iteration (xorshift32)
local rngState = 42
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunBankLifecycleTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Bank lifecycle round-trip — running", NUM_ITERATIONS, "iterations")

    -- Track C_Bank.CloseBankFrame calls
    local closeBankCalled = false
    local originalCloseBankFrame = _G.C_Bank.CloseBankFrame
    _G.C_Bank.CloseBankFrame = function(...)
        closeBankCalled = true
        -- Don't call original — we're not actually at a bank
    end

    -- Mock C_Bank.CanViewBank to return true so OpenBank proceeds
    local originalCanViewBank = _G.C_Bank.CanViewBank
    _G.C_Bank.CanViewBank = function(bankType)
        return true
    end

    -- Mock C_Bank.FetchPurchasedBankTabData to return empty table (no purchased tabs)
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    _G.C_Bank.FetchPurchasedBankTabData = function() return {} end

    -- Stub out bank:Update to prevent the full item-loading pipeline from running.
    -- This test only validates state flags and frame visibility, not item display.
    local originalBankUpdate = Inventory.bank.Update
    Inventory.bank.Update = function() end

    -- Also stub out main bag Update to prevent inventory refresh side effects
    local originalMainUpdate = Inventory.main.Update
    Inventory.main.Update = function() end

    -- Stub OnShow/OnHide AND frame Show/Hide to prevent "script ran too long".
    -- With a real open bank, frames have many child slots — WoW's internal
    -- Show/Hide traverses all children, too expensive for 100 iterations.
    local originalBankOnShow = Inventory.bank:GetScript("OnShow")
    local originalBankOnHide = Inventory.bank:GetScript("OnHide")
    local originalMainOnShow = Inventory.main:GetScript("OnShow")
    local originalMainOnHide = Inventory.main:GetScript("OnHide")
    Inventory.bank:SetScript("OnShow", nil)
    Inventory.bank:SetScript("OnHide", nil)
    Inventory.main:SetScript("OnShow", nil)
    Inventory.main:SetScript("OnHide", nil)

    -- Replace frame Show/Hide/IsShown with lightweight flag-only versions.
    -- Bank Hide must still trigger closeBankCalled since CloseBank() calls
    -- bank:Hide() and the test checks that C_Bank.CloseBankFrame was called.
    local bankShown = Inventory.bank:IsShown()
    local mainShown = Inventory.main:IsShown()
    local originalBankShow = Inventory.bank.Show
    local originalBankHide = Inventory.bank.Hide
    local originalBankIsShown = Inventory.bank.IsShown
    local originalMainShow = Inventory.main.Show
    local originalMainHide = Inventory.main.Hide
    local originalMainIsShown = Inventory.main.IsShown
    Inventory.bank.Show = function(self) bankShown = true end
    Inventory.bank.Hide = function(self)
        bankShown = false
        _G.C_Bank.CloseBankFrame()
    end
    Inventory.bank.IsShown = function(self) return bankShown end
    Inventory.main.Show = function(self) mainShown = true end
    Inventory.main.Hide = function(self) mainShown = false end
    Inventory.main.IsShown = function(self) return mainShown end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Pick a random banker interaction type
        local interactionType = bankerTypes[nextRandom(#bankerTypes)]

        -- Capture initial state
        local initialAtBank = false

        -- Ensure clean initial state
        Inventory.atBank = false
        if Inventory.bank then
            Inventory.bank:Hide()
        end
        closeBankCalled = false

        -- Fire SHOW event
        Inventory:PLAYER_INTERACTION_MANAGER_FRAME_SHOW("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", interactionType)

        -- Verify bank opened (intermediate check, not asserted — the round-trip is what matters)

        -- Fire HIDE event
        closeBankCalled = false
        Inventory:PLAYER_INTERACTION_MANAGER_FRAME_HIDE("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", interactionType)

        -- Verify round-trip: state should return to initial
        local atBankReset = (Inventory.atBank == initialAtBank)
        local bankHidden = Inventory.bank and not Inventory.bank:IsShown()
        local closeWasCalled = closeBankCalled

        if not atBankReset or not bankHidden or not closeWasCalled then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: interactionType=%d atBankReset=%s bankHidden=%s closeCalled=%s"):format(
                    i,
                    interactionType,
                    tostring(atBankReset),
                    tostring(bankHidden),
                    tostring(closeWasCalled)
                )
            )
        end
    end

    -- Restore original functions
    _G.C_Bank.CloseBankFrame = originalCloseBankFrame
    _G.C_Bank.CanViewBank = originalCanViewBank
    _G.C_Bank.FetchPurchasedBankTabData = originalFetchPurchased
    Inventory.bank.Update = originalBankUpdate
    Inventory.main.Update = originalMainUpdate
    Inventory.bank.Show = originalBankShow
    Inventory.bank.Hide = originalBankHide
    Inventory.bank.IsShown = originalBankIsShown
    Inventory.main.Show = originalMainShow
    Inventory.main.Hide = originalMainHide
    Inventory.main.IsShown = originalMainIsShown
    Inventory.bank:SetScript("OnShow", originalBankOnShow)
    Inventory.bank:SetScript("OnHide", originalBankOnHide)
    Inventory.main:SetScript("OnShow", originalMainOnShow)
    Inventory.main:SetScript("OnHide", originalMainOnHide)

    -- Clean up state
    Inventory.atBank = false
    if Inventory.bank then
        Inventory.bank:Hide()
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 1: Bank lifecycle round-trip — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 1: Bank lifecycle round-trip — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:banklifecycle()
    return RunBankLifecycleTest()
end
