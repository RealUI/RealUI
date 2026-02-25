local ADDON_NAME, ns = ...

-- Property Test: BAG_UPDATE triggers refresh for active tab only
-- Feature: inventory-bank-rewrite, Property 15: BAG_UPDATE triggers refresh for active tab only
-- Validates: Requirements 5.6
--
-- For any BAG_UPDATE event, the bank frame should refresh its item display
-- if and only if the event's container ID matches the active bank tab's
-- container ID.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

-- All possible bank tab container IDs (Character + Account)
local allBankTabIDs = {
    _G.Enum.BagIndex.CharacterBankTab_1,
    _G.Enum.BagIndex.CharacterBankTab_2,
    _G.Enum.BagIndex.CharacterBankTab_3,
    _G.Enum.BagIndex.CharacterBankTab_4,
    _G.Enum.BagIndex.CharacterBankTab_5,
    _G.Enum.BagIndex.CharacterBankTab_6,
    _G.Enum.BagIndex.AccountBankTab_1,
    _G.Enum.BagIndex.AccountBankTab_2,
    _G.Enum.BagIndex.AccountBankTab_3,
    _G.Enum.BagIndex.AccountBankTab_4,
    _G.Enum.BagIndex.AccountBankTab_5,
}

-- Include some non-bank container IDs to test that unrelated BAG_UPDATE events are ignored
local nonBankContainerIDs = {
    _G.Enum.BagIndex.Backpack,
    _G.Enum.BagIndex.Bag_1,
    _G.Enum.BagIndex.Bag_2,
    _G.Enum.BagIndex.Bag_3,
    _G.Enum.BagIndex.Bag_4,
    _G.Enum.BagIndex.ReagentBag,
}

-- Combined pool of all container IDs for random selection
local allContainerIDs = {}
for _, id in ipairs(allBankTabIDs) do
    allContainerIDs[#allContainerIDs + 1] = id
end
for _, id in ipairs(nonBankContainerIDs) do
    allContainerIDs[#allContainerIDs + 1] = id
end

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 251
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunBankBagUpdateTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r BAG_UPDATE selective refresh — running", NUM_ITERATIONS, "iterations")

    local bank = Inventory.bank

    -- Track whether Update was called by hooking MainBagMixin's throttle path.
    -- BankBagMixin:OnEvent delegates to MainBagMixin.OnEvent for matching BAG_UPDATE,
    -- which either calls self:Update() (via throttle) or skips based on debounce.
    -- We bypass the throttle by setting bank.time far in the past.
    local updateCalled = false
    local originalUpdate = bank.Update
    bank.Update = function(self, ...)
        updateCalled = true
        -- Don't call original — avoid side effects from actual item iteration
    end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Pick a random active tab ID from bank tabs
        local activeTabID = allBankTabIDs[nextRandom(#allBankTabIDs)]
        -- Pick a random container ID from the full pool (may or may not match)
        local eventContainerID = allContainerIDs[nextRandom(#allContainerIDs)]

        -- Set up bank state
        bank.activeTabID = activeTabID
        -- Reset throttle so MainBagMixin.OnEvent will call Update
        bank.time = 0
        updateCalled = false

        -- Fire BAG_UPDATE event directly on the bank frame's OnEvent
        bank:OnEvent("BAG_UPDATE", eventContainerID)

        local shouldRefresh = (eventContainerID == activeTabID)

        if shouldRefresh and not updateCalled then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: activeTab=%d event=%d — expected refresh but Update was NOT called"):format(
                    i, activeTabID, eventContainerID
                )
            )
        elseif not shouldRefresh and updateCalled then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: activeTab=%d event=%d — expected NO refresh but Update WAS called"):format(
                    i, activeTabID, eventContainerID
                )
            )
        end
    end

    -- Restore original Update
    bank.Update = originalUpdate

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 15: BAG_UPDATE triggers refresh for active tab only — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 15: BAG_UPDATE triggers refresh for active tab only — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:bankbagupdate()
    return RunBankBagUpdateTest()
end
