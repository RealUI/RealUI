local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert tremove next ipairs unpack wipe

-- RealUI --
local RealUI = _G.RealUI
local Inventory = private.Inventory

local menu do
    local MenuFrame = RealUI:GetModule("MenuFrame")
    menu = {}

    local menuList = {}
    local title = {
        text = "Choose bag",
        isTitle = true,
    }

    local function SetToFilter(filterButton, arg1, arg2, isChecked)
        if isChecked then
            Inventory.db.global.assignedFilters[menu.item:GetItemID()] = arg1
        else
            Inventory.db.global.assignedFilters[menu.item:GetItemID()] = nil
        end
        private.Update()
    end
    function menu:AddFilter(filter)
        local tag = filter.tag
        tinsert(menuList, filter:GetIndex(), {
            text = filter.name,
            func = SetToFilter,
            arg1 = tag,
            checked = function(...)
                return Inventory.db.global.assignedFilters[self.item:GetItemID()] == tag
            end
        })
    end
    function menu:RemoveFilter(filter)
        tremove(menuList, filter:GetIndex())
    end
    function menu:UpdateLines()
        wipe(menuList)
        for i, filter in Inventory:IndexedFilters() do
            self:AddFilter(filter)
        end
        tinsert(menuList, 1, title)
    end
    function menu:Open(slot)
        if slot.item then
            self.item = slot.item
            if slot:GetBagType() == "main" then
                MenuFrame:Open(slot, "TOPLEFT", menuList)
            else
                MenuFrame:Open(slot, "BOTTOMLEFT", menuList)
            end
        end
    end
    private.menu = menu
end

do
    local filters = {}

    local FilterMixin = {}
    function FilterMixin:GetIndex()
        for i, tag in ipairs(Inventory.db.global.filters) do
            if tag == self.tag then
                return i
            end
        end
    end
    function FilterMixin:SetIndex(newIndex)
        local oldIndex = self:GetIndex()
        if oldIndex == newIndex then return end
        if newIndex < 1 or newIndex > #Inventory.db.global.filters then return end

        tremove(Inventory.db.global.filters, oldIndex)
        tinsert(Inventory.db.global.filters, newIndex, self.tag)

        menu:UpdateLines()
        private.Update()
    end
    function FilterMixin:DoesMatchSlot(slot)
        if self.filter then
            return self.filter(slot)
        end
    end
    function FilterMixin:HasPriority(filterTag)
        -- Lower ranks have priority
        return self.rank < filters[filterTag].rank
    end
    function FilterMixin:Delete()
        filters[self.tag] = nil
        Inventory.db.global.customFilters[self.tag] = nil
        tremove(Inventory.db.global.filters, self:GetIndex())
        menu:UpdateLines()

        for itemID, tag in next, Inventory.db.global.assignedFilters do
            if tag == self.tag then
                Inventory.db.global.assignedFilters[itemID] = nil
            end
        end
    end

    function Inventory:CreateFilter(info)
        local filter = _G.Mixin(info, FilterMixin)

        private.CreateFilterBag(Inventory.main, filter)
        private.CreateFilterBag(Inventory.bank, filter)
        private.CreateFilterBag(Inventory.reagent, filter)

        filters[filter.tag] = filter
    end
    function Inventory:CreateCustomFilter(tag, name)
        if not Inventory.db.global.customFilters[tag] then
            Inventory.db.global.customFilters[tag] = name
            tinsert(Inventory.db.global.filters, 1, tag)
        end

        Inventory:CreateFilter({
            tag = tag,
            name = name,
            isCustom = true,
        })
    end


    local function iPairsFilter(filterTable, index)
        index = index + 1
        local tag = filterTable[index]
        if tag ~= nil then
            return index, filters[tag]
        else
            return nil
        end
    end
    function Inventory:IndexedFilters()
        return iPairsFilter, Inventory.db.global.filters, 0
    end
    function Inventory:GetFilter(tag)
        return filters[tag]
    end
end

private.filterList = {}
tinsert(private.filterList, {
    tag = "new",
    name = _G.NEW,
    rank = 1,
    filter = function(slot)
        return _G.C_NewItems.IsNewItem(slot:GetBagAndSlot())
    end,
})

tinsert(private.filterList, {
    tag = "junk",
    name = _G.BAG_FILTER_JUNK,
    rank = 0,
    filter = function(slot)
        local _, _, _, quality, _, _, _, _, noValue = _G.GetContainerItemInfo(slot:GetBagAndSlot())
        return quality == RealUI.Enum.ItemQuality.Poor and not noValue
    end,
})

tinsert(private.filterList, {
    tag = "consumables",
    name = _G.AUCTION_CATEGORY_CONSUMABLES,
    rank = 10,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_CONSUMABLE
    end,
})

tinsert(private.filterList, {
    tag = "equipment",
    name = _G.BAG_FILTER_EQUIPMENT,
    rank = 21,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_ARMOR or typeID == _G.LE_ITEM_CLASS_WEAPON
    end,
})

tinsert(private.filterList, {
    tag = "sets",
    name = (":"):split(_G.EQUIPMENT_SETS),
    rank = 20,
    filter = function(slot)
        return _G.GetContainerItemEquipmentSetInfo(slot:GetBagAndSlot())
    end,
})

tinsert(private.filterList, {
    tag = "questitems",
    name = _G.AUCTION_CATEGORY_QUEST_ITEMS,
    rank = 3,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_QUESTITEM
    end,
})

local prefix = _G.BAG_FILTER_TRADE_GOODS .. ": %s"
local tradegoods = _G.C_AuctionHouse.GetAuctionItemSubClasses(_G.LE_ITEM_CLASS_TRADEGOODS)
for i = 1, #tradegoods do
    local subClassID = tradegoods[i]
    local name = _G.GetItemSubClassInfo(_G.LE_ITEM_CLASS_TRADEGOODS, subClassID)
    tinsert(private.filterList, {
        tag = "tradegoods_"..subClassID,
        name = prefix:format(name),
        rank = 30,
        filter = function(slot)
            local _, _, _, _, _, typeID, subTypeID = _G.GetItemInfoInstant(slot.item:GetItemID())
            return typeID == _G.LE_ITEM_CLASS_TRADEGOODS and subTypeID == subClassID
        end,
    })
end

local travel = private.travel
tinsert(private.filterList, {
    tag = "travel",
    name = _G.TUTORIAL_TITLE35,
    rank = 2,
    filter = function(slot)
        return travel[slot.item:GetItemID()]
    end,
})

function private.CreateFilters()
    for tag, name in next, Inventory.db.global.customFilters do
        Inventory:CreateCustomFilter(tag, name)
    end

    for i, info in ipairs(private.filterList) do
        Inventory:CreateFilter(info)
    end

    menu:UpdateLines()
end


