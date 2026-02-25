local ADDON_NAME, ns = ...

-- Property Test: Bags track bank visibility
-- Feature: inventory-bank-rewrite, Property 2: Bags track bank visibility
-- Validates: Requirements 1.3, 1.4
--
-- For any bank open/close cycle initiated by a banker interaction, the
-- inventory bags should be shown when the bank opens and hidden when the
-- bank closes (provided the bags were not already open before the bank
-- interaction).

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

-- Banker interaction types
local bankerTypes = {
    _G.Enum.PlayerInteractionType.Banker,
    _G.Enum.PlayerInteractionType.CharacterBanker,
    _G.Enum.PlayerInteractionType.AccountBanker,
}

-- Simple RNG (xorshift32), same as BankLifecycleTest
local rngState = 137
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function nextBool()
    return nextRandom(2) == 1
end

local function RunBankBagsVisibilityTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank or not Inventory.main then
        _G.print("|cffff0000[ERROR]|r Inventory module, bank frame, or main bag not available. Open a banker first to initialize.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Bags track bank visibility — running", NUM_ITERATIONS, "iterations")

    -- Mock C_Bank.CanViewBank to return true
    local originalCanViewBank = _G.C_Bank.CanViewBank
    _G.C_Bank.CanViewBank = function() return true end

    -- Mock C_Bank.CloseBankFrame to no-op
    local originalCloseBankFrame = _G.C_Bank.CloseBankFrame
    _G.C_Bank.CloseBankFrame = function() end

    -- Mock C_Bank.FetchPurchasedBankTabData to return empty table
    local originalFetchPurchased = _G.C_Bank.FetchPurchasedBankTabData
    _G.C_Bank.FetchPurchasedBankTabData = function() return {} end

    -- Stub out bank:Update and main:Update to prevent the full item-loading
    -- pipeline from running. This test only validates visibility state.
    local originalBankUpdate = Inventory.bank.Update
    Inventory.bank.Update = function() end
    local originalMainUpdate = Inventory.main.Update
    Inventory.main.Update = function() end

    -- Stub OnShow/OnHide AND the frame Show/Hide methods themselves to prevent
    -- "script ran too long". With a real open bank, frames have many child
    -- slots with textures — WoW's internal Show/Hide traverses all children,
    -- which is too expensive for 100 iterations.
    local originalBankOnShow = Inventory.bank:GetScript("OnShow")
    local originalBankOnHide = Inventory.bank:GetScript("OnHide")
    local originalMainOnShow = Inventory.main:GetScript("OnShow")
    local originalMainOnHide = Inventory.main:GetScript("OnHide")
    Inventory.bank:SetScript("OnShow", nil)
    Inventory.bank:SetScript("OnHide", nil)
    Inventory.main:SetScript("OnShow", nil)
    Inventory.main:SetScript("OnHide", nil)

    -- Replace frame Show/Hide with lightweight flag-only versions
    local bankShown = Inventory.bank:IsShown()
    local mainShown = Inventory.main:IsShown()
    local originalBankShow = Inventory.bank.Show
    local originalBankHide = Inventory.bank.Hide
    local originalBankIsShown = Inventory.bank.IsShown
    local originalMainShow = Inventory.main.Show
    local originalMainHide = Inventory.main.Hide
    local originalMainIsShown = Inventory.main.IsShown
    Inventory.bank.Show = function(self) bankShown = true end
    Inventory.bank.Hide = function(self) bankShown = false end
    Inventory.bank.IsShown = function(self) return bankShown end
    Inventory.main.Show = function(self) mainShown = true end
    Inventory.main.Hide = function(self) mainShown = false end
    Inventory.main.IsShown = function(self) return mainShown end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local interactionType = bankerTypes[nextRandom(#bankerTypes)]
        local bagsAlreadyOpen = nextBool()

        -- Reset state
        Inventory.atBank = false
        Inventory.openedBagsForBank = false
        Inventory.bank:Hide()

        -- Set initial bags state
        if bagsAlreadyOpen then
            Inventory.main:Show()
        else
            Inventory.main:Hide()
        end

        -- Fire SHOW event (open bank)
        Inventory:PLAYER_INTERACTION_MANAGER_FRAME_SHOW("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", interactionType)

        -- After bank opens, bags should always be visible
        local bagsVisibleAfterOpen = Inventory.main:IsShown()

        -- Fire HIDE event (close bank)
        Inventory:PLAYER_INTERACTION_MANAGER_FRAME_HIDE("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", interactionType)

        -- After bank closes, bags should match their pre-bank state
        local bagsVisibleAfterClose = Inventory.main:IsShown()
        local expectedAfterClose = bagsAlreadyOpen

        local openOk = bagsVisibleAfterOpen
        local closeOk = (bagsVisibleAfterClose == expectedAfterClose)

        if not openOk or not closeOk then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: type=%d bagsAlreadyOpen=%s bagsAfterOpen=%s bagsAfterClose=%s expected=%s"):format(
                    i,
                    interactionType,
                    tostring(bagsAlreadyOpen),
                    tostring(bagsVisibleAfterOpen),
                    tostring(bagsVisibleAfterClose),
                    tostring(expectedAfterClose)
                )
            )
        end
    end

    -- Restore original functions
    _G.C_Bank.CanViewBank = originalCanViewBank
    _G.C_Bank.CloseBankFrame = originalCloseBankFrame
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
    Inventory.openedBagsForBank = false
    Inventory.bank:Hide()
    Inventory.main:Hide()

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 2: Bags track bank visibility — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 2: Bags track bank visibility — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:bankbagsvisibility()
    return RunBankBagsVisibilityTest()
end
