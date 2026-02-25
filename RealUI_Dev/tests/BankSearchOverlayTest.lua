local ADDON_NAME, ns = ...

-- Property Test: Search overlay matches isFiltered flag
-- Feature: inventory-bank-rewrite, Property 20: Search overlay matches isFiltered flag
-- Validates: Requirements 8.2
--
-- For any visible bank item slot, after an INVENTORY_SEARCH_UPDATE event,
-- the slot's search overlay (match state) should equal
-- not C_Container.GetContainerItemInfo().isFiltered.

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

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 601
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunBankSearchOverlayTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available. Open a banker first to initialize.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Search overlay matches isFiltered flag — running", NUM_ITERATIONS, "iterations")

    local bank = Inventory.bank
    local failures = 0

    -- We need to verify that when INVENTORY_SEARCH_UPDATE fires, each slot in
    -- the bank's filter bags calls UpdateItemContext, which reads isFiltered
    -- from C_Container.GetContainerItemInfo and sets SetMatchesSearch accordingly.
    --
    -- Strategy: For each iteration, generate a random isFiltered state per slot,
    -- mock C_Container.GetContainerItemInfo to return that state, fire the event,
    -- and verify each slot's SetMatchesSearch was called with `not isFiltered`.

    -- Collect all visible slots across bank filter bags
    local function collectBankSlots()
        local slots = {}
        if not bank.bags then return slots end
        for tag, bag in next, bank.bags do
            if bag.slots then
                for _, slot in ipairs(bag.slots) do
                    if slot:IsShown() and slot.item then
                        slots[#slots + 1] = slot
                    end
                end
            end
        end
        return slots
    end

    local visibleSlots = collectBankSlots()
    if #visibleSlots == 0 then
        _G.print("|cffff9900[SKIP]|r No visible bank slots found. Open a bank tab with items to test.")
        return true
    end

    _G.print("|cff00ccff[PBT]|r Found", #visibleSlots, "visible bank slots to test")

    -- Save originals
    local originalGetContainerItemInfo = _G.C_Container.GetContainerItemInfo

    -- Track SetMatchesSearch calls per slot
    local matchResults = {} -- slot -> bool (the value passed to SetMatchesSearch)
    local originalSetMatchesSearch = {}

    for _, slot in ipairs(visibleSlots) do
        originalSetMatchesSearch[slot] = slot.SetMatchesSearch
        slot.SetMatchesSearch = function(self, matchesSearch)
            matchResults[self] = matchesSearch
        end
    end

    -- Also need to stub UpdateItemContextMatching to avoid side effects
    local originalUpdateItemContextMatching = {}
    for _, slot in ipairs(visibleSlots) do
        originalUpdateItemContextMatching[slot] = slot.UpdateItemContextMatching
        slot.UpdateItemContextMatching = function() end
    end

    for i = 1, NUM_ITERATIONS do
        -- Generate random isFiltered state for each slot
        local expectedFilterState = {} -- slot -> isFiltered (bool)
        for _, slot in ipairs(visibleSlots) do
            expectedFilterState[slot] = (nextRandom(2) == 1)
        end

        -- Mock C_Container.GetContainerItemInfo to return our random isFiltered
        _G.C_Container.GetContainerItemInfo = function(bagID, slotIndex)
            -- Find the slot matching this bagID+slotIndex
            for _, slot in ipairs(visibleSlots) do
                local sBag, sSlot = slot:GetBagAndSlot()
                if sBag == bagID and sSlot == slotIndex then
                    -- Return a table with isFiltered set to our generated value
                    -- plus minimal fields to avoid errors
                    return {
                        isFiltered = expectedFilterState[slot],
                        stackCount = 1,
                        isReadable = false,
                    }
                end
            end
            -- Fallback to original for non-test slots
            return originalGetContainerItemInfo(bagID, slotIndex)
        end

        -- Clear tracking
        wipe(matchResults)

        -- Fire INVENTORY_SEARCH_UPDATE on the bank frame
        -- Reset throttle so the event handler processes it
        bank.time = 0
        bank:OnEvent("INVENTORY_SEARCH_UPDATE")

        -- Verify: each slot's SetMatchesSearch should have been called with
        -- (not isFiltered)
        for _, slot in ipairs(visibleSlots) do
            local isFiltered = expectedFilterState[slot]
            local expectedMatch = not isFiltered
            local actualMatch = matchResults[slot]

            if actualMatch == nil then
                failures = failures + 1
                if failures <= 5 then
                    local bagID, slotIndex = slot:GetBagAndSlot()
                    _G.print(
                        ("|cffff0000[FAIL]|r iteration %d: slot [%d,%d] — SetMatchesSearch was not called"):format(
                            i, bagID, slotIndex
                        )
                    )
                end
            elseif actualMatch ~= expectedMatch then
                failures = failures + 1
                if failures <= 5 then
                    local bagID, slotIndex = slot:GetBagAndSlot()
                    _G.print(
                        ("|cffff0000[FAIL]|r iteration %d: slot [%d,%d] — isFiltered=%s, expected match=%s, got match=%s"):format(
                            i, bagID, slotIndex,
                            tostring(isFiltered), tostring(expectedMatch), tostring(actualMatch)
                        )
                    )
                end
            end
        end
    end

    -- Restore originals
    _G.C_Container.GetContainerItemInfo = originalGetContainerItemInfo
    for _, slot in ipairs(visibleSlots) do
        slot.SetMatchesSearch = originalSetMatchesSearch[slot]
        slot.UpdateItemContextMatching = originalUpdateItemContextMatching[slot]
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 20: Search overlay matches isFiltered flag — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 20: Search overlay matches isFiltered flag — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:banksearchoverlay()
    return RunBankSearchOverlayTest()
end
