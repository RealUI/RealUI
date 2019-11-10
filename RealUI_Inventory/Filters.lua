local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs

private.filters = {}
private.filterList = {}
local function CreateFilter(tag, info)
    private.filters[tag] = info
    tinsert(private.filterList, tag)
end

CreateFilter("equipment", {
    name = _G.BAG_FILTER_EQUIPMENT,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_ARMOR or typeID == _G.LE_ITEM_CLASS_WEAPON
    end,
})

CreateFilter("tradegoods", {
    name = _G.AUCTION_CATEGORY_TRADE_GOODS,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_TRADEGOODS
    end,
})

CreateFilter("consumables", {
    name = _G.AUCTION_CATEGORY_CONSUMABLES,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_CONSUMABLE
    end,
})

CreateFilter("questitems", {
    name = _G.AUCTION_CATEGORY_QUEST_ITEMS,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_QUESTITEM
    end,
})
