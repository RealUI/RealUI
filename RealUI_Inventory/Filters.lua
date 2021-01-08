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
            if arg1 == "junk" then
                local bagID, slotIndex = menu.slot:GetBagAndSlot()
                if not Inventory.db.char.junk[bagID] then
                    Inventory.db.char.junk[bagID] = {}
                end

                Inventory.db.char.junk[bagID][slotIndex] = true
            else
                Inventory.db.global.assignedFilters[menu.slot.item:GetItemID()] = arg1
            end
        else
            if arg1 == "junk" then
                local bagID, slotIndex = menu.slot:GetBagAndSlot()
                if not Inventory.db.char.junk[bagID] then
                    Inventory.db.char.junk[bagID] = {}
                end

                Inventory.db.char.junk[bagID][slotIndex] = nil
            else
                Inventory.db.global.assignedFilters[menu.slot.item:GetItemID()] = nil
            end
        end
        private.Update()
        MenuFrame:Close(1, true)
    end
    function menu:AddFilter(filter)
        local tag = filter.tag
        tinsert(menuList, {
            text = filter.name,
            func = SetToFilter,
            arg1 = tag,
            checked = function(...)
                if tag == "junk" then
                    local bagID, slotIndex = menu.slot:GetBagAndSlot()
                    if Inventory.db.char.junk[bagID] then
                        return Inventory.db.char.junk[bagID][slotIndex] or false
                    end

                    return false
                else
                    return Inventory.db.global.assignedFilters[self.slot.item:GetItemID()] == tag
                end
            end
        })
    end
    function menu:UpdateLines()
        wipe(menuList)
        tinsert(menuList, 1, title)
        for i, filter in Inventory:IndexedFilters() do
            if filter:IsEnabled() then
                self:AddFilter(filter)
            end
        end
    end
    function menu:Open(slot)
        if slot.item then
            self.slot = slot
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
        if not self:IsEnabled() then return false end
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
    function FilterMixin:SetEnabled(enabled)
        Inventory.db.global.disabledFilters[self.tag] = not enabled
        menu:UpdateLines()
    end
    function FilterMixin:IsEnabled()
        if self.isCustom then return true end
        --print("FilterMixin:IsEnabled", self.tag, not Inventory.db.global.disabledFilters[self.tag])
        return not Inventory.db.global.disabledFilters[self.tag]
    end

    function Inventory:CreateFilter(info)
        local filter = _G.Mixin(info, FilterMixin)

        private.CreateFilterBag(Inventory.main, filter)

        if filter.tag ~= "new" then
            private.CreateFilterBag(Inventory.bank, filter)
            private.CreateFilterBag(Inventory.reagent, filter)
        end

        filters[filter.tag] = filter
        return filter
    end
    function Inventory:CreateCustomFilter(tag, name, fromConfig)
        if not Inventory.db.global.customFilters[tag] then
            Inventory.db.global.customFilters[tag] = name
            tinsert(Inventory.db.global.filters, 1, tag)
        end

        local filter = Inventory:CreateFilter({
            tag = tag,
            name = name,
            isCustom = true,
        })

        if fromConfig then
            menu:AddFilter(filter)
        end

        return filter
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
        local bagID, slotIndex = slot:GetBagAndSlot()
        if Inventory.main.new[bagID] then
            return Inventory.main.new[bagID][slotIndex]
        end
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
        return slot:GetItemType() == "equipment"
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
for i = 1, (#tradegoods - 1) do
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

tinsert(private.filterList, {
    tag = "tradegoods",
    name = _G.BAG_FILTER_TRADE_GOODS,
    rank = 31,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_TRADEGOODS
    end,
})

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


