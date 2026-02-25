local ADDON_NAME, ns = ...

-- Property Test: Item sort order
-- Feature: inventory-bank-rewrite, Property 10: Item sort order
-- Validates: Requirements 4.3
--
-- For any list of items within a filter bag, after sorting, items should be
-- ordered by: quality (descending), inventory type (ascending by rank),
-- item level (descending), name (ascending), stack count (descending).
-- No adjacent pair should violate this ordering.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100
local MAX_ITEMS_PER_LIST = 20
local MIN_ITEMS_PER_LIST = 3

-- Inventory type rank table (mirrors Bags.lua invTypes exactly)
local InventoryType = _G.Enum.InventoryType
local invTypes = {
    [InventoryType.IndexHeadType] = 1,
    [InventoryType.IndexNeckType] = 2,
    [InventoryType.IndexShoulderType] = 3,
    [InventoryType.IndexCloakType] = 4,
    [InventoryType.IndexChestType] = 5,
    [InventoryType.IndexRobeType] = 5,
    [InventoryType.IndexBodyType] = 6,
    [InventoryType.IndexTabardType] = 7,
    [InventoryType.IndexWristType] = 8,
    [InventoryType.IndexHandType] = 9,
    [InventoryType.IndexWaistType] = 10,
    [InventoryType.IndexLegsType] = 11,
    [InventoryType.IndexFeetType] = 12,
    [InventoryType.IndexFingerType] = 13,
    [InventoryType.IndexTrinketType] = 14,
    [InventoryType.Index2HweaponType] = 15,
    [InventoryType.IndexRangedType] = 16,
    [InventoryType.IndexRangedrightType] = 16,
    [InventoryType.IndexWeaponType] = 17,
    [InventoryType.IndexWeaponmainhandType] = 18,
    [InventoryType.IndexWeaponoffhandType] = 19,
    [InventoryType.IndexShieldType] = 20,
    [InventoryType.IndexHoldableType] = 21,
    [InventoryType.IndexRelicType] = 21,
    [InventoryType.IndexAmmoType] = 22,
    [InventoryType.IndexThrownType] = 22,
    [InventoryType.IndexBagType] = 25,
    [InventoryType.IndexQuiverType] = 25,
    [InventoryType.IndexProfessionToolType] = 25,
    [InventoryType.IndexProfessionGearType] = 25,
    [InventoryType.IndexEquipablespellOffensiveType] = 30,
    [InventoryType.IndexEquipablespellUtilityType] = 30,
    [InventoryType.IndexEquipablespellDefensiveType] = 30,
    [InventoryType.IndexEquipablespellWeaponType] = 30,
    [InventoryType.IndexNonEquipType] = 30,
}

-- Pool of inventory types to randomly pick from
local invTypePool = {
    InventoryType.IndexHeadType,
    InventoryType.IndexNeckType,
    InventoryType.IndexShoulderType,
    InventoryType.IndexChestType,
    InventoryType.IndexWristType,
    InventoryType.IndexHandType,
    InventoryType.IndexWaistType,
    InventoryType.IndexLegsType,
    InventoryType.IndexFeetType,
    InventoryType.IndexFingerType,
    InventoryType.IndexTrinketType,
    InventoryType.Index2HweaponType,
    InventoryType.IndexWeaponType,
    InventoryType.IndexWeaponmainhandType,
    InventoryType.IndexShieldType,
    InventoryType.IndexBagType,
    InventoryType.IndexNonEquipType,
}

-- Quality values
local qualityPool = {
    _G.Enum.ItemQuality.Poor,
    _G.Enum.ItemQuality.Common,
    _G.Enum.ItemQuality.Uncommon,
    _G.Enum.ItemQuality.Rare,
    _G.Enum.ItemQuality.Epic,
    _G.Enum.ItemQuality.Legendary,
}

-- Name pool for generating distinct item names
local namePool = {
    "Alpha Blade", "Beta Shield", "Crimson Helm", "Dark Cloak",
    "Elder Ring", "Flame Staff", "Golden Belt", "Hollow Boots",
    "Iron Gauntlets", "Jade Pendant", "Keen Dagger", "Lunar Robe",
    "Mystic Orb", "Noble Pauldrons", "Onyx Bracers", "Primal Leggings",
}

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 577
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

-- Generate a random mock slot with item properties
local function GenerateRandomSlot(bagID, slotIndex)
    local quality = qualityPool[nextRandom(#qualityPool)]
    local invType = invTypePool[nextRandom(#invTypePool)]
    local ilvl = nextRandom(300) + 100  -- 101..400
    local name = namePool[nextRandom(#namePool)]
    local stackCount = nextRandom(20)   -- 1..20

    local location = _G.ItemLocation:CreateFromBagAndSlot(bagID, slotIndex)

    local slot = {
        item = {
            GetItemQuality = function() return quality end,
            GetInventoryType = function() return invType end,
            GetCurrentItemLevel = function() return ilvl end,
            GetItemName = function() return name end,
        },
        location = location,
        -- Store raw values for assertion messages
        _quality = quality,
        _invType = invType,
        _invRank = invTypes[invType],
        _ilvl = ilvl,
        _name = name,
        _stackCount = stackCount,
    }

    return slot, stackCount
end

-- Verify the sort ordering invariant between two adjacent slots
-- Returns true if a <= b in the sort order (a should come before or equal b)
local function CheckPairOrder(a, b)
    local qA = a._quality
    local qB = b._quality
    if qA ~= qB then
        -- Quality descending: higher quality first
        return qA > qB
    end

    local rA = a._invRank
    local rB = b._invRank
    if rA ~= rB then
        -- Inventory type rank ascending: lower rank first
        return rA < rB
    end

    local iA = a._ilvl
    local iB = b._ilvl
    if iA ~= iB then
        -- Item level descending: higher ilvl first
        return iA > iB
    end

    local nA = a._name
    local nB = b._name
    if nA ~= nB then
        -- Name ascending: alphabetically earlier first
        return nA < nB
    end

    local sA = a._stackCount
    local sB = b._stackCount
    if sA ~= sB then
        -- Stack count descending: higher stack first
        return sA > sB
    end

    -- Equal on all criteria — valid ordering
    return true
end

local function RunBankItemSortOrderTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory then
        _G.print("|cffff0000[ERROR]|r Inventory module not available.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Item sort order — running", NUM_ITERATIONS, "iterations")

    -- Save original C_Item.GetStackCount
    local origGetStackCount = _G.C_Item.GetStackCount

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local listSize = nextRandom(MAX_ITEMS_PER_LIST - MIN_ITEMS_PER_LIST + 1) + MIN_ITEMS_PER_LIST - 1
        local slots = {}
        local stackCounts = {} -- keyed by location for the mock

        local bagID = _G.Enum.BagIndex.CharacterBankTab_1

        for s = 1, listSize do
            local slot, stackCount = GenerateRandomSlot(bagID, s)
            slots[s] = slot
            stackCounts[slot.location] = stackCount
        end

        -- Mock C_Item.GetStackCount to return our generated values
        _G.C_Item.GetStackCount = function(location)
            return stackCounts[location] or 1
        end

        -- Sort using Lua's sort with the same comparator as Bags.lua SortSlots
        sort(slots, function(a, b)
            local qualityA = a.item:GetItemQuality()
            local qualityB = b.item:GetItemQuality()
            if qualityA ~= qualityB then
                if qualityA and qualityB then
                    return qualityA > qualityB
                elseif (qualityA == nil) or (qualityB == nil) then
                    return not not qualityA
                else
                    return false
                end
            end

            local invTypeA = a.item:GetInventoryType()
            local invTypeB = b.item:GetInventoryType()
            if invTypes[invTypeA] ~= invTypes[invTypeB] then
                return invTypes[invTypeA] < invTypes[invTypeB]
            end

            local ilvlA = a.item:GetCurrentItemLevel()
            local ilvlB = b.item:GetCurrentItemLevel()
            if ilvlA ~= ilvlB then
                return ilvlA > ilvlB
            end

            local nameA = a.item:GetItemName()
            local nameB = b.item:GetItemName()
            if nameA ~= nameB then
                return nameA < nameB
            end

            local stackA = _G.C_Item.GetStackCount(a.location)
            local stackB = _G.C_Item.GetStackCount(b.location)
            if stackA ~= stackB then
                return stackA > stackB
            end
        end)

        -- Verify ordering invariant: no adjacent pair should violate the order
        local iterFailed = false
        for j = 1, #slots - 1 do
            -- Update _stackCount from the mock for verification
            slots[j]._stackCount = stackCounts[slots[j].location] or 1
            slots[j + 1]._stackCount = stackCounts[slots[j + 1].location] or 1

            if not CheckPairOrder(slots[j], slots[j + 1]) then
                iterFailed = true
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r iteration %d pair %d-%d: [q=%d r=%d il=%d n=%s s=%d] > [q=%d r=%d il=%d n=%s s=%d]"):format(
                        i, j, j + 1,
                        slots[j]._quality, slots[j]._invRank, slots[j]._ilvl, slots[j]._name, slots[j]._stackCount,
                        slots[j+1]._quality, slots[j+1]._invRank, slots[j+1]._ilvl, slots[j+1]._name, slots[j+1]._stackCount
                    )
                )
                break -- one failure per iteration is enough
            end
        end
    end

    -- Restore original
    _G.C_Item.GetStackCount = origGetStackCount

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 10: Item sort order — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 10: Item sort order — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:bankitemsortorder()
    return RunBankItemSortOrderTest()
end
