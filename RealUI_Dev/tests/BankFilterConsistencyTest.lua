local ADDON_NAME, ns = ...

-- Property Test: Item filter assignment consistency
-- Feature: inventory-bank-rewrite, Property 9: Item filter assignment consistency
-- Validates: Requirements 4.2
--
-- For any item in a bank tab, the filter assignment should produce the same
-- result as the inventory bag filter system — i.e., the same item placed in
-- a bag slot vs. a bank slot should be assigned to the same filter tag.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

-- Inventory bag IDs (main bags)
local mainBagIDs = {
    _G.Enum.BagIndex.Backpack,
    _G.Enum.BagIndex.Bag_1,
    _G.Enum.BagIndex.Bag_2,
    _G.Enum.BagIndex.Bag_3,
    _G.Enum.BagIndex.Bag_4,
}

-- Bank tab IDs
local bankTabIDs = {
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

-- Item archetypes with known filter-relevant properties
-- Each entry: { itemID, quality, typeID, subTypeID, invType, description }
local ItemClass = _G.Enum.ItemClass
local itemArchetypes = {
    { itemID = 100001, quality = _G.Enum.ItemQuality.Common,    typeID = ItemClass.Consumable,  subTypeID = 0, invType = _G.Enum.InventoryType.IndexNonEquipType, desc = "Consumable" },
    { itemID = 100002, quality = _G.Enum.ItemQuality.Uncommon,  typeID = ItemClass.Armor,       subTypeID = 1, invType = _G.Enum.InventoryType.IndexChestType,    desc = "Equipment (Armor)" },
    { itemID = 100003, quality = _G.Enum.ItemQuality.Rare,      typeID = ItemClass.Weapon,      subTypeID = 0, invType = _G.Enum.InventoryType.IndexWeaponType,   desc = "Equipment (Weapon)" },
    { itemID = 100004, quality = _G.Enum.ItemQuality.Common,    typeID = ItemClass.Tradegoods,  subTypeID = 5, invType = _G.Enum.InventoryType.IndexNonEquipType, desc = "Trade Goods" },
    { itemID = 100005, quality = _G.Enum.ItemQuality.Common,    typeID = ItemClass.Questitem,   subTypeID = 0, invType = _G.Enum.InventoryType.IndexNonEquipType, desc = "Quest Item" },
    { itemID = 100006, quality = _G.Enum.ItemQuality.Poor,      typeID = ItemClass.Miscellaneous, subTypeID = 0, invType = _G.Enum.InventoryType.IndexNonEquipType, desc = "Junk" },
    { itemID = 100007, quality = _G.Enum.ItemQuality.Epic,      typeID = ItemClass.Armor,       subTypeID = 4, invType = _G.Enum.InventoryType.IndexHeadType,     desc = "Epic Head Armor" },
    { itemID = 100008, quality = _G.Enum.ItemQuality.Rare,      typeID = ItemClass.Consumable,  subTypeID = 1, invType = _G.Enum.InventoryType.IndexNonEquipType, desc = "Rare Consumable" },
    { itemID = 100009, quality = _G.Enum.ItemQuality.Uncommon,  typeID = ItemClass.Tradegoods,  subTypeID = 7, invType = _G.Enum.InventoryType.IndexNonEquipType, desc = "Trade Goods (sub 7)" },
    { itemID = 100010, quality = _G.Enum.ItemQuality.Legendary, typeID = ItemClass.Weapon,      subTypeID = 1, invType = _G.Enum.InventoryType.Index2HweaponType, desc = "Legendary 2H Weapon" },
}

-- Simple RNG (xorshift32), same pattern as other tests
local rngState = 409
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunBankFilterConsistencyTest()
    local Inventory = RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.main or not Inventory.bank then
        _G.print("|cffff0000[ERROR]|r Inventory module, main bag, or bank frame not available.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Item filter assignment consistency — running", NUM_ITERATIONS, "iterations")

    -- Save originals for APIs we need to mock
    local origGetItemInfoInstant = _G.C_Item.GetItemInfoInstant
    local origGetContainerItemInfo = _G.C_Container.GetContainerItemInfo
    local origGetItemInfo = _G.C_Item.GetItemInfo
    local origIsAnimaItemByID = _G.C_Item.IsAnimaItemByID

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Pick a random item archetype
        local archetype = itemArchetypes[nextRandom(#itemArchetypes)]
        -- Pick a random main bag and bank tab
        local mainBagID = mainBagIDs[nextRandom(#mainBagIDs)]
        local bankBagID = bankTabIDs[nextRandom(#bankTabIDs)]
        local slotIndex = nextRandom(36) -- random slot 1..36

        -- Mock C_Item.GetItemInfoInstant to return our archetype's type info
        _G.C_Item.GetItemInfoInstant = function(itemID)
            return itemID, archetype.desc, archetype.desc, archetype.invType, nil, archetype.typeID, archetype.subTypeID
        end

        -- Mock C_Container.GetContainerItemInfo to return quality and hasNoValue
        _G.C_Container.GetContainerItemInfo = function(bagID, slot)
            return {
                quality = archetype.quality,
                hasNoValue = (archetype.quality ~= _G.Enum.ItemQuality.Poor),
                stackCount = 1,
                isFiltered = false,
            }
        end

        -- Mock C_Item.GetItemInfo to return bind type (non-BnetAccountUntilEquipped)
        _G.C_Item.GetItemInfo = function(itemID)
            return archetype.desc, nil, archetype.quality, 1, 1, nil, nil, nil, nil, nil, 0, nil, nil, _G.Enum.ItemBind.OnEquip
        end

        -- Mock C_Item.IsAnimaItemByID to return false
        _G.C_Item.IsAnimaItemByID = function(itemID)
            return false
        end

        -- Create mock slot objects for main and bank with identical item properties
        -- but different bag locations
        local mockItem = {
            GetItemID = function() return archetype.itemID end,
            GetItemQuality = function() return archetype.quality end,
            GetInventoryType = function() return archetype.invType end,
            GetCurrentItemLevel = function() return 200 end,
            GetItemName = function() return archetype.desc end,
            GetItemLink = function() return "|cffffffff|Hitem:" .. archetype.itemID .. "::::::::::::|h[" .. archetype.desc .. "]|h|r" end,
            IsItemLocked = function() return false end,
        }

        local mainSlot = {
            item = mockItem,
            GetBagAndSlot = function() return mainBagID, slotIndex end,
            GetBagType = function() return "main" end,
            GetItemType = function()
                local invType = archetype.invType
                if invType ~= _G.Enum.InventoryType.IndexNonEquipType then
                    return "equipment"
                end
                return nil
            end,
        }

        local bankSlot = {
            item = mockItem,
            GetBagAndSlot = function() return bankBagID, slotIndex end,
            GetBagType = function() return "bank" end,
            GetItemType = function()
                local invType = archetype.invType
                if invType ~= _G.Enum.InventoryType.IndexNonEquipType then
                    return "equipment"
                end
                return nil
            end,
        }

        -- Run filter matching for both slots using the same IndexedFilters pipeline
        -- This replicates the core logic from private.AddSlotToBag
        local function getFilterTag(slot, bagID)
            local assignedTag = Inventory.db.global.assignedFilters[slot.item:GetItemID()]
            if Inventory.db.char.junk[bagID] and Inventory.db.char.junk[bagID][slotIndex] then
                assignedTag = "junk"
            end

            if not Inventory:GetFilter(assignedTag) then
                for _, filter in Inventory:IndexedFilters() do
                    if filter:DoesMatchSlot(slot) then
                        if assignedTag then
                            if filter:HasPriority(assignedTag) then
                                assignedTag = filter.tag
                            end
                        else
                            assignedTag = filter.tag
                        end
                    end
                end
            end

            return assignedTag or "main"
        end

        local mainTag = getFilterTag(mainSlot, mainBagID)
        local bankTag = getFilterTag(bankSlot, bankBagID)

        if mainTag ~= bankTag then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: item=%s mainBag=%d bankBag=%d mainTag=%s bankTag=%s"):format(
                    i, archetype.desc, mainBagID, bankBagID, tostring(mainTag), tostring(bankTag)
                )
            )
        end
    end

    -- Restore original functions
    _G.C_Item.GetItemInfoInstant = origGetItemInfoInstant
    _G.C_Container.GetContainerItemInfo = origGetContainerItemInfo
    _G.C_Item.GetItemInfo = origGetItemInfo
    _G.C_Item.IsAnimaItemByID = origIsAnimaItemByID

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 9: Item filter assignment consistency — %d/%d iterations passed"):format(NUM_ITERATIONS, NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 9: Item filter assignment consistency — %d/%d failures"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:bankfilterconsistency()
    return RunBankFilterConsistencyTest()
end
