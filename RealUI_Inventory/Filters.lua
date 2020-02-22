local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs

-- Libs --
local LDD = _G.LibStub("LibDropDown")

-- RealUI --
local Inventory = private.Inventory

local menu do
    menu = _G.CreateFrame("Frame", nil, _G.UIParent)
    menu:SetFrameStrata("DIALOG")

    local list = LDD:NewMenu(menu, "RealUI_InventoryDropDown")
    list:SetStyle("REALUI")
    list:AddLine({
        text = "Choose bag",
        isTitle = true,
    })
    menu.list = list

    function menu:Open(slot)
        if slot.item then
            menu.item = slot.item
            list:SetAnchor("BOTTOMLEFT", slot, "TOPLEFT")
            list:Toggle()
        end
    end
    private.menu = menu
end

private.filters = {}
private.filterList = {}
local function SetToFilter(filterButton, button, args)
    if filterButton.checked() then
        Inventory.db.global.assignedFilters[menu.item:GetItemID()] = nil
    else
        Inventory.db.global.assignedFilters[menu.item:GetItemID()] = args
    end
    private.Update()
end

local function CreateFilter(tag, info)
    private.filters[tag] = info
    tinsert(private.filterList, tag)
    menu.list:AddLine({
        text = info.name,
        func = SetToFilter,
        args = {tag},
        checked = function(...)
            return Inventory.db.global.assignedFilters[menu.item:GetItemID()] == tag
        end
    })
end

CreateFilter("new", {
    name = _G.NEW,
    rank = 0,
    filter = function(slot)
        return _G.C_NewItems.IsNewItem(slot:GetBagAndSlot())
    end,
})

CreateFilter("junk", {
    name = _G.BAG_FILTER_JUNK,
    rank = -1,
    filter = function(slot)
        local _, _, _, quality, _, _, _, _, noValue = _G.GetContainerItemInfo(slot:GetBagAndSlot())
        return quality == _G.LE_ITEM_QUALITY_POOR and not noValue
    end,
})

CreateFilter("consumables", {
    name = _G.AUCTION_CATEGORY_CONSUMABLES,
    rank = 1,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_CONSUMABLE
    end,
})

CreateFilter("questitems", {
    name = _G.AUCTION_CATEGORY_QUEST_ITEMS,
    rank = 0,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_QUESTITEM
    end,
})

local prefix = _G.BAG_FILTER_TRADE_GOODS .. ": %s"
local tradegoods
if Inventory.isPatch then
    tradegoods = _G.C_AuctionHouse.GetAuctionItemSubClasses(_G.LE_ITEM_CLASS_TRADEGOODS)
else
    tradegoods = {_G.GetAuctionItemSubClasses(_G.LE_ITEM_CLASS_TRADEGOODS)}
end

for i = 1, #tradegoods do
    local subClassID = tradegoods[i]
    local name = _G.GetItemSubClassInfo(_G.LE_ITEM_CLASS_TRADEGOODS, subClassID)
    CreateFilter("tradegoods_"..subClassID, {
        name = prefix:format(name),
        rank = 2,
        filter = function(slot)
            local _, _, _, _, _, typeID, subTypeID = _G.GetItemInfoInstant(slot.item:GetItemID())
            return typeID == _G.LE_ITEM_CLASS_TRADEGOODS and subTypeID == subClassID
        end,
    })
end

CreateFilter("equipment", {
    name = _G.BAG_FILTER_EQUIPMENT,
    rank = 1,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_ARMOR or typeID == _G.LE_ITEM_CLASS_WEAPON
    end,
})

local travel = private.travel
CreateFilter("travel", {
    name = _G.TUTORIAL_TITLE35,
    rank = 0,
    filter = function(slot)
        return travel[slot.item:GetItemID()]
    end,
})
