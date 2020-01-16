local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert next wipe ipairs sort

-- Libs --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin
local Color = Aurora.Color

-- RealUI --
local RealUI = _G.RealUI

local Inventory = private.Inventory

local function SortSlots(a, b)
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
    if invTypeA ~= invTypeB then
        return invTypeA < invTypeB
    end


    local idA = a.item:GetItemID()
    local idB = b.item:GetItemID()
    if idA ~= idB then
        return idA > idB
    end


    if Inventory.isPatch then
        local stackA = _G.C_Item.GetStackCount(a)
        local stackB = _G.C_Item.GetStackCount(b)
        if stackA ~= stackB then
            return stackA > stackB
        end
    end
end
local function UpdateBagSize(bag, columnHeight, columnBase, numSkipped)
    sort(bag.slots, SortSlots)

    if bag.tag == "main" then
        tinsert(bag.slots, bag.dropTarget)
    end

    local slotWidth, slotHeight = private.ArrangeSlots(bag, bag.offsetTop)
    bag:SetSize(slotWidth + bag.baseWidth, slotHeight + (bag.offsetTop + bag.offsetBottom))

    local height = bag:GetHeight()
    if bag.tag == "main" then
        columnHeight = columnHeight + height + 5
    else
        local parent = bag.parent
        if columnHeight + height >= Inventory.db.global.maxHeight then
            if parent.bagType == "main" then
                bag:SetPoint("BOTTOMRIGHT", parent.bags[columnBase] or parent, "BOTTOMLEFT", -5, 0)
            else
                bag:SetPoint("TOPLEFT", parent.bags[columnBase] or parent, "TOPRIGHT", 5, 0)
            end
            columnBase = bag.tag
            columnHeight = height + 5
        else
            columnHeight = columnHeight + height + 5

            local anchor = "main"
            if bag.index > 1 then
                anchor = Inventory.db.global.filters[bag.index - (1 + numSkipped)]
            end
            if parent.bagType == "main" then
                bag:SetPoint("BOTTOMRIGHT", parent.bags[anchor] or parent, "TOPRIGHT", 0, 5)
            else
                bag:SetPoint("TOPLEFT", parent.bags[anchor] or parent, "BOTTOMLEFT", 0, -5)
            end
        end
    end

    return columnHeight, columnBase
end
local function SetupSlots(main)
    local columnHeight, columnBase = 0, main.tag
    columnHeight, columnBase = UpdateBagSize(main, columnHeight, columnBase)

    local numSkipped = 0
    for i, tag in ipairs(Inventory.db.global.filters) do
        local bag = main.bags[tag]
        if #bag.slots <= 0 then
            bag:Hide()
            numSkipped = numSkipped + 1
        else
            columnHeight, columnBase = UpdateBagSize(bag, columnHeight, columnBase, numSkipped)
            bag:Show()
            numSkipped = 0
        end
    end
end

local function UpdateBag(main)
    if main:AreAnyLoadsOutstanding() then return end

    wipe(main.slots)
    for tag, bag in next, main.bags do
        wipe(bag.slots)
    end

    if main.bagType == "main" then
        for bagID = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS do
            private.UpdateSlots(bagID)
        end
    elseif main.bagType == "bank" then
        private.UpdateSlots(_G.BANK_CONTAINER)
        for bagID = _G.NUM_BAG_SLOTS + 1, _G.NUM_BAG_SLOTS + _G.NUM_BANKBAGSLOTS do
            private.UpdateSlots(bagID)
        end
    end

    main:ContinueOnLoad(function()
        SetupSlots(main)
    end)
end
function private.UpdateBags()
    UpdateBag(Inventory.main)
    if Inventory.showBank then
        UpdateBag(Inventory.bank)
    end
end

function private.AddSlotToBag(slot, bagID)
    local main = Inventory[private.GetBagTypeForBagID(bagID)]

    local filterTag
    for i, tag in ipairs(Inventory.db.global.filters) do
        if private.filters[tag].filter(slot) then
            if filterTag then
                -- Lower ranks have priority
                if private.filters[filterTag].rank > private.filters[tag].rank then
                    filterTag = tag
                end
            else
                filterTag = tag
            end
        end
    end

    local bag = main.bags[filterTag] or main

    tinsert(bag.slots, slot)
    slot:SetParent(private.blizz[bagID])

    main:AddContinuable(slot.item)
end

local HEADER_SPACE = 27
local BAG_MARGIN = 5
local function SetupBag(bag)
    Base.SetBackdrop(bag)
    bag:EnableMouse(true)
    bag.slots = {}

    bag.offsetTop = BAG_MARGIN + HEADER_SPACE
    bag.offsetBottom = 0
    bag.baseWidth = BAG_MARGIN
end

local function DropTargetFindSlot(bagType)
    local bagID, slotIndex = private.GetFirstFreeSlot(bagType)
    if bagID then
        _G.PickupContainerItem(bagID, slotIndex)
    end
end

local ContinuableContainer = _G.CreateFromMixins(_G.ContinuableContainer)
function ContinuableContainer:RecheckEvictableContinuables()
    local areAllLoaded = true
    if self.evictableObjects then
        for i, evictableObject in ipairs(self.evictableObjects) do
            if not evictableObject:IsItemDataCached() then
                areAllLoaded = false

                self.numOutstanding = self.numOutstanding + 1

                -- The version of this in FrameXML uses `continuable` instead of `evictableObject`
                tinsert(self.continuables, evictableObject:ContinueWithCancelOnItemLoad(self.onContinuableLoadedCallback))
            end
        end
    end
    return areAllLoaded
end

local BagEvents = {
    "BAG_UPDATE",
    "BAG_UPDATE_COOLDOWN",
    "INVENTORY_SEARCH_UPDATE",
    "ITEM_LOCK_CHANGED",
}
local function CreateBag(bagType)
    local main
    if bagType == "main" then
        main = _G.CreateFrame("Frame", "RealUIInventory", _G.UIParent)
        main:SetPoint("BOTTOMRIGHT", -100, 100)
        main:RegisterEvent("BAG_OPEN")
        main:RegisterEvent("BAG_CLOSED")
        main:RegisterEvent("QUEST_ACCEPTED")
        main:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
        main:SetScript("OnEvent", function(self, event, ...)
            if event == "BAG_OPEN" then
                private.Toggle(true)
            elseif event == "BAG_CLOSED" then
                private.Toggle(false)
            elseif event == "ITEM_LOCK_CHANGED" then
                local bagID, slotIndex = ...
                if bagID and slotIndex then
                    local slot = private.GetSlot(bagID, slotIndex)
                    if slot then
                        _G.SetItemButtonDesaturated(slot, slot.item:IsItemLocked())
                    end
                end
            else
                UpdateBag(self)
                self.dropTarget.count:SetText(private.GetNumFreeSlots(self))
            end
        end)
        main:SetScript("OnShow", function(self)
            _G.FrameUtil.RegisterFrameForEvents(self, BagEvents)
            self:RegisterEvent("UNIT_INVENTORY_CHANGED")
            self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            self:RegisterEvent("BAG_NEW_ITEMS_UPDATED")
            self:RegisterEvent("BAG_SLOT_FLAGS_UPDATED")

            UpdateBag(self)
            self.dropTarget.count:SetText(private.GetNumFreeSlots(self))
        end)
        main:SetScript("OnHide", function(self)
            _G.FrameUtil.UnregisterFrameForEvents(self, BagEvents)
            self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
            self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            self:UnregisterEvent("BAG_NEW_ITEMS_UPDATED")
            self:UnregisterEvent("BAG_SLOT_FLAGS_UPDATED")
            self:Cancel()
        end)
    elseif bagType == "bank" then
        main = _G.CreateFrame("Frame", "RealUIBank", _G.UIParent)
        main:SetPoint("TOPLEFT", 100, -100)
        main:RegisterEvent("BANKFRAME_OPENED")
        main:RegisterEvent("BANKFRAME_CLOSED")
        main:SetScript("OnEvent", function(self, event, ...)
            if event == "BANKFRAME_OPENED" then
                Inventory.showBank = true
                private.Toggle(true)
            elseif event == "BANKFRAME_CLOSED" then
                Inventory.showBank = false
                private.Toggle(false)
            elseif event == "ITEM_LOCK_CHANGED" then
                local bagID, slotIndex = ...
                if bagID and slotIndex then
                    local slot = private.GetSlot(bagID, slotIndex)
                    if slot then
                        _G.SetItemButtonDesaturated(slot, slot.item:IsItemLocked())
                    end
                end
            else
                UpdateBag(self)
                self.dropTarget.count:SetText(private.GetNumFreeSlots(self))
            end
        end)
        main:SetScript("OnShow", function(self)
            _G.FrameUtil.RegisterFrameForEvents(self, BagEvents)
            self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
            self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
            self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
            self:RegisterEvent("BANK_BAG_SLOT_FLAGS_UPDATED")

            UpdateBag(self)
            self.dropTarget.count:SetText(private.GetNumFreeSlots(self))
        end)
        main:SetScript("OnHide", function(self)
            _G.FrameUtil.UnregisterFrameForEvents(self, BagEvents)
            self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
            self:UnregisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
            self:UnregisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
            self:UnregisterEvent("BANK_BAG_SLOT_FLAGS_UPDATED")
        end)
    end

    _G.Mixin(main, ContinuableContainer)
    RealUI.MakeFrameDraggable(main)
    main:SetToplevel(true)
    main:Hide()
    main.tag = "main"
    main.bagType = bagType

    Inventory[bagType] = main
    SetupBag(main)

    local close = _G.CreateFrame("Button", "$parentClose", main, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 5, 5)
    Skin.UIPanelCloseButton(close)
    main.close = close

    local money = _G.CreateFrame("Frame", "$parentMoney", main, "SmallMoneyFrameTemplate")
    money:SetPoint("BOTTOMRIGHT", 8, 8)
    main.money = money

    local searchButton = _G.CreateFrame("Button", "$parentSearchButton", main)
    searchButton:SetHitRectInsets(-5, -40, -5, -5)
    searchButton:SetPoint("BOTTOMLEFT", 8, 9)
    searchButton:SetSize(10, 10)
    searchButton:SetNormalFontObject("GameFontDisableSmall")
    searchButton:SetText("Search")
    searchButton:GetFontString():SetPoint("LEFT", searchButton, "RIGHT", 4, 1)
    searchButton:SetNormalAtlas("common-search-magnifyingglass")
    searchButton:GetNormalTexture():SetVertexColor(0.6, 0.6, 0.6)
    searchButton:SetHighlightAtlas("common-search-magnifyingglass")
    searchButton:SetScript("OnClick", function(self)
        self:Hide()
        main.money:Hide()
        main.searchBox:Show()
        main.searchBox:SetFocus()
    end)
    main.searchButton = searchButton

    local searchBox = _G.CreateFrame("EditBox", "$parentSearchBox", main, "BagSearchBoxTemplate")
    searchBox:SetPoint("BOTTOMLEFT", 5, 5)
    searchBox:SetPoint("BOTTOMRIGHT", -5, 5)
    searchBox:SetHeight(20)
    searchBox:Hide()
    _G.hooksecurefunc(searchBox, "ClearFocus", function(self)
        self:Hide()
        main.money:Show()
        main.searchButton:Show()
    end)
    Skin.BagSearchBoxTemplate(searchBox)
    main.searchBox = searchBox
    main.offsetBottom = main.offsetBottom + 25

    local dropTarget = _G.CreateFrame("Button", "$parentEmptySlot", main)
    dropTarget:SetSize(37, 37)
    Base.CreateBackdrop(dropTarget, {
        bgFile = [[Interface\PaperDoll\UI-Backpack-EmptySlot]],
        tile = false,
        offsets = {
            left = -1,
            right = -1,
            top = -1,
            bottom = -1,
        }
    })
    Base.CropIcon(dropTarget:GetBackdropTexture("bg"))
    dropTarget:SetBackdropColor(1, 1, 1, 0.75)
    dropTarget:SetBackdropBorderColor(Color.frame:GetRGB())
    dropTarget:SetScript("OnMouseUp", function()
        DropTargetFindSlot(bagType)
    end)
    dropTarget:SetScript("OnReceiveDrag", function()
        DropTargetFindSlot(bagType)
    end)
    main.dropTarget = dropTarget

    local count = dropTarget:CreateFontString(nil, "ARTWORK")
    count:SetFontObject("NumberFontNormal")
    count:SetPoint("BOTTOMRIGHT", 0, 2)
    count:SetText(private.GetNumFreeSlots(main))
    dropTarget.count = count

    main.bags = {}
    private.CreateDummyBags(bagType)
    for i, tag in ipairs(Inventory.db.global.filters) do
        local bag = _G.CreateFrame("Frame", "$parent_"..tag, main)
        SetupBag(bag)

        local info = private.filters[tag]
        local name = bag:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        name:SetPoint("TOPLEFT")
        name:SetPoint("BOTTOMRIGHT", bag, "TOPRIGHT", 0, -HEADER_SPACE)
        name:SetText(info.name)
        name:SetJustifyV("MIDDLE")

        bag.index = i
        bag.tag = tag
        bag.parent = main

        main.bags[tag] = bag
    end
end


function private.CreateBags()
    CreateBag("main")
    CreateBag("bank")
end
