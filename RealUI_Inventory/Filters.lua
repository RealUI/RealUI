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

    local function SetToFilter(filterButton, button, args)
        if filterButton.checked() then
            Inventory.db.global.assignedFilters[menu.item:GetItemID()] = nil
        else
            Inventory.db.global.assignedFilters[menu.item:GetItemID()] = args
        end
        private.Update()
    end
    function menu:AddFilter(tag)
        menu.list:AddLine({
            text = Inventory:GetFilterName(tag),
            func = SetToFilter,
            args = {tag},
            checked = function(...)
                return Inventory.db.global.assignedFilters[menu.item:GetItemID()] == tag
            end
        })
    end
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
function Inventory:GetFilterIndex(tagQuery)
    for i, tag in ipairs(Inventory.db.global.filters) do
        if tag == tagQuery then
            return i
        end
    end
end
function Inventory:GetFilterName(tagQuery)
    return private.filters[tagQuery].name
end

local function CreateFilter(tag, info)
    private.filters[tag] = info
    tinsert(private.filterList, tag)

    private.menu:AddFilter(tag)
end
function Inventory:CreateFilter(tag, name)
    private.filters[tag] = {
        name = name,
        isCustom = true,
        filter = _G.nop
    }

    if not Inventory.db.global.customFilters[tag] then
        Inventory.db.global.customFilters[tag] = name
        tinsert(Inventory.db.global.filters, 1, tag)

        private.CreateFilterBag(Inventory.main, tag)
        private.CreateFilterBag(Inventory.bank, tag)
    end

    private.menu:AddFilter(tag)
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

CreateFilter("sets", {
    name = (":"):split(_G.EQUIPMENT_SETS),
    rank = 1,
    filter = function(slot)
        return _G.GetContainerItemEquipmentSetInfo(slot:GetBagAndSlot())
    end,
})

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
