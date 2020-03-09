local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert tremove next ipairs unpack

-- RealUI --
local Inventory = private.Inventory

local menu do
    menu = _G.CreateFrame("Frame", nil, _G.UIParent)
    menu:SetFrameStrata("DIALOG")

    local list = {}
    local menuFrame = _G.LibStub("LibDropDown"):NewMenu(menu, "RealUI_InventoryDropDown")
    menuFrame:SetStyle("REALUI")
    menuFrame:AddLine({
        text = "Choose bag",
        isTitle = true,
    })

    local function SetToFilter(filterButton, button, args)
        if filterButton.checked() then
            Inventory.db.global.assignedFilters[menu.item:GetItemID()] = nil
        else
            Inventory.db.global.assignedFilters[menu.item:GetItemID()] = args
        end
        private.Update()
    end
    function menu:AddFilter(filter)
        local tag = filter.tag
        local index = filter:GetIndex()

        -- Filters might be added out of order, so we need to tweak the
        --     insert index if it's outside the current list.
        if index > (#list + 1) then
            index = #list + 1
        end

        tinsert(list, index, {
            text = filter.name,
            func = SetToFilter,
            args = {tag},
            checked = function(...)
                return Inventory.db.global.assignedFilters[menu.item:GetItemID()] == tag
            end
        })

        if menu.doUpdate then
            menu:UpdateLines()
        end
    end
    function menu:RemoveFilter(filter)
        tremove(list, filter:GetIndex())
    end
    function menu:UpdateLines()
        menuFrame:ClearLines()
        menuFrame:AddLines(unpack(list))

        menu.doUpdate = false
    end
    function menu:Open(slot)
        if slot.item then
            menu.item = slot.item
            menuFrame:SetAnchor("BOTTOMLEFT", slot, "TOPLEFT")
            menuFrame:Toggle()
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
    function FilterMixin:DoesMatchSlot(slot)
        if self.filter then
            return self.filter(slot)
        end
    end
    function FilterMixin:HasPriority(filterTag)
        -- Lower ranks have priority
        return filters[filterTag].rank > self.rank
    end
    function FilterMixin:Delete()
        menu:RemoveFilter(self)
        menu:UpdateLines()

        filters[self.tag] = nil
        Inventory.db.global.customFilters[self.tag] = nil
        tremove(Inventory.db.global.filters, self:GetIndex())

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
        menu:AddFilter(filter)
    end
    function Inventory:CreateCustomFilter(tag, name)
        if not Inventory.db.global.customFilters[tag] then
            Inventory.db.global.customFilters[tag] = name
            tinsert(Inventory.db.global.filters, 1, tag)
            menu.doUpdate = true
        end

        Inventory:CreateFilter({
            tag = tag,
            name = name,
            isCustom = true,
        })
    end
    function Inventory:GetFilter(tag)
        return filters[tag]
    end
end

private.filterList = {}
tinsert(private.filterList, {
    tag = "new",
    name = _G.NEW,
    rank = 0,
    filter = function(slot)
        return _G.C_NewItems.IsNewItem(slot:GetBagAndSlot())
    end,
})

tinsert(private.filterList, {
    tag = "junk",
    name = _G.BAG_FILTER_JUNK,
    rank = -1,
    filter = function(slot)
        local _, _, _, quality, _, _, _, _, noValue = _G.GetContainerItemInfo(slot:GetBagAndSlot())
        return quality == _G.LE_ITEM_QUALITY_POOR and not noValue
    end,
})

tinsert(private.filterList, {
    tag = "consumables",
    name = _G.AUCTION_CATEGORY_CONSUMABLES,
    rank = 1,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_CONSUMABLE
    end,
})

tinsert(private.filterList, {
    tag = "questitems",
    name = _G.AUCTION_CATEGORY_QUEST_ITEMS,
    rank = 0,
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
        rank = 2,
        filter = function(slot)
            local _, _, _, _, _, typeID, subTypeID = _G.GetItemInfoInstant(slot.item:GetItemID())
            return typeID == _G.LE_ITEM_CLASS_TRADEGOODS and subTypeID == subClassID
        end,
    })
end

tinsert(private.filterList, {
    tag = "sets",
    name = (":"):split(_G.EQUIPMENT_SETS),
    rank = 1,
    filter = function(slot)
        return _G.GetContainerItemEquipmentSetInfo(slot:GetBagAndSlot())
    end,
})

tinsert(private.filterList, {
    tag = "equipment",
    name = _G.BAG_FILTER_EQUIPMENT,
    rank = 1,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_ARMOR or typeID == _G.LE_ITEM_CLASS_WEAPON
    end,
})

local travel = private.travel
tinsert(private.filterList, {
    tag = "travel",
    name = _G.TUTORIAL_TITLE35,
    rank = 0,
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


