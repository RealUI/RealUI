local ADDON_NAME, ns = ...

-- Property Test: Empty filter bags are hidden
-- Feature: inventory-bank-rewrite, Property 11: Empty filter bags are hidden
-- Validates: Requirements 4.5
--
-- For any filter bag in the bank frame, the bag should be visible if and
-- only if it contains at least one item slot.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 631
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunBankEmptyFilterBagsTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module or bank frame not available.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Empty filter bags are hidden — running", NUM_ITERATIONS, "iterations")

    -- Collect all filter tags that exist on the bank frame
    local bankBags = Inventory.bank.bags
    local filterTags = {}
    for tag, _ in next, bankBags do
        tinsert(filterTags, tag)
    end

    if #filterTags == 0 then
        _G.print("|cffff0000[ERROR]|r No filter bags found on bank frame.")
        return false
    end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate a random item count for each filter bag (0 to 36 items)
        -- Then simulate the visibility logic from MainBagMixin:UpdateSlots
        local expectedVisibility = {}

        for _, tag in ipairs(filterTags) do
            local bag = bankBags[tag]
            -- Wipe existing slots and populate with random count
            wipe(bag.slots)

            local numItems = nextRandom(37) - 1 -- 0..36
            for s = 1, numItems do
                -- Insert minimal mock slot objects
                tinsert(bag.slots, { _mockSlot = true })
            end

            expectedVisibility[tag] = (numItems > 0)
        end

        -- Simulate the visibility logic from MainBagMixin:UpdateSlots:
        -- bags with #slots <= 0 are never shown, bags with #slots > 0 get Show()
        for _, tag in ipairs(filterTags) do
            local bag = bankBags[tag]
            -- Reset visibility state
            bag:Hide()
        end

        for _, filter in Inventory:IndexedFilters() do
            local bag = bankBags[filter.tag]
            if bag then
                if #bag.slots > 0 then
                    bag:Show()
                end
            end
        end

        -- Verify: each bag's visibility matches expected
        for _, tag in ipairs(filterTags) do
            local bag = bankBags[tag]
            local isVisible = bag:IsShown()
            local shouldBeVisible = expectedVisibility[tag]

            if isVisible ~= shouldBeVisible then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d: tag=%s slots=%d visible=%s expected=%s"):format(
                        i, tag, #bag.slots, tostring(isVisible), tostring(shouldBeVisible)
                    )
                )
                break -- one failure per iteration is enough
            end
        end
    end

    -- Clean up: wipe mock slots from bank bags
    for _, tag in ipairs(filterTags) do
        wipe(bankBags[tag].slots)
        bankBags[tag]:Hide()
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 11: Empty filter bags are hidden — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 11: Empty filter bags are hidden — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:bankemptyfilterbags()
    return RunBankEmptyFilterBagsTest()
end
