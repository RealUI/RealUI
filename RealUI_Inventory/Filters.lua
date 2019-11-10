local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs

private.filters = {}
private.filterList = {}
local function CreateFilter(tag, info)
    private.filters[tag] = info
    tinsert(private.filterList, tag)
end

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

local tradegoods, prefix = {}, _G.BAG_FILTER_TRADE_GOODS .. ": %s"
local classIndex = _G.LE_ITEM_CLASS_TRADEGOODS
local subClassIndex = 0
local subClassName = _G.GetItemSubClassInfo(classIndex, subClassIndex)

while subClassName and subClassName ~= "" do
    tradegoods[subClassIndex] = subClassName

    subClassIndex = subClassIndex + 1
    subClassName = _G.GetItemSubClassInfo(classIndex, subClassIndex)
end

for i = 0, #tradegoods do
    if not tradegoods[i]:find("OBSOLETE") then
        CreateFilter("tradegoods_"..tradegoods[i], {
            name = prefix:format(tradegoods[i]),
            filter = function(slot)
                local _, _, _, _, _, typeID, subTypeID = _G.GetItemInfoInstant(slot.item:GetItemID())
                return typeID == _G.LE_ITEM_CLASS_TRADEGOODS and subTypeID == i
            end,
        })
    end
end

CreateFilter("equipment", {
    name = _G.BAG_FILTER_EQUIPMENT,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_ARMOR or typeID == _G.LE_ITEM_CLASS_WEAPON
    end,
})
