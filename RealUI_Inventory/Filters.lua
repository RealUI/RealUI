local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs

private.filters = {}
local function CreateFilter(info)
    tinsert(private.filters, info)
end

CreateFilter({
    tag = "equipment",
    name = _G.BAG_FILTER_EQUIPMENT,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_ARMOR or typeID == _G.LE_ITEM_CLASS_WEAPON
    end,
})

CreateFilter({
    tag = "tradegoods",
    name = _G.AUCTION_CATEGORY_TRADE_GOODS,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_TRADEGOODS
    end,
})

CreateFilter({
    tag = "consumables",
    name = _G.AUCTION_CATEGORY_CONSUMABLES,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_CONSUMABLE
    end,
})

CreateFilter({
    tag = "questitems",
    name = _G.AUCTION_CATEGORY_QUEST_ITEMS,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_QUESTITEM
    end,
})
