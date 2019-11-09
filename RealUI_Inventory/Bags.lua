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

local bags = {}
Inventory.bags = bags

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

local function UpdateBag(index, tag, columnHeight, columnBase)
    local bag = bags[tag]
    sort(bag.slots, SortSlots)

    if tag == "main" then
        tinsert(bag.slots, bag.dropTarget)
    end

    local slotWidth, slotHeight = private.ArrangeSlots(bag, bag.offsetTop)
    bag:SetSize(slotWidth + bag.baseWidth, slotHeight + (bag.offsetTop + bag.offsetBottom))

    local height = bag:GetHeight()
    if tag == "main" then
        columnHeight = columnHeight + height + 5
    else
        if columnHeight + height >= Inventory.db.global.maxHeight then
            bag:SetPoint("BOTTOMRIGHT", bags[columnBase], "BOTTOMLEFT", -5, 0)
            columnBase = tag
            columnHeight = height + 5
        else
            columnHeight = columnHeight + height + 5

            local anchor = "main"
            if index > 1 then
                anchor = Inventory.db.global.filters[index - 1]
            end
            bag:SetPoint("BOTTOMRIGHT", bags[anchor], "TOPRIGHT", 0, 5)
        end
    end

    return columnHeight, columnBase
end
function private.UpdateBags()
    for tag, bag in next, bags do
        wipe(bag.slots)
    end

    for bagID = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS do
        private.UpdateSlots(bagID)
    end

    local columnHeight, columnBase = 0, "main"
    columnHeight, columnBase = UpdateBag(nil, columnBase, columnHeight, columnBase)

    for i, tag in ipairs(Inventory.db.global.filters) do
        columnHeight, columnBase = UpdateBag(i, tag, columnHeight, columnBase)
    end
end

function private.AddSlotToBag(slot, bagID)
    local bag = Inventory.main
    for i, tag in ipairs(Inventory.db.global.filters) do
        if private.filters[tag].filter(slot) then
            bag = bags[tag]
        end
    end

    tinsert(bag.slots, slot)
    slot:SetParent(private.blizz[bagID])
    Inventory.main:AddContinuable(slot.item)
end

local function SetupBag(bag)
    Base.SetBackdrop(bag)
    bag:EnableMouse(true)
    bag.slots = {}

    bag.offsetTop = 5
    bag.offsetBottom = 0
    bag.baseWidth = 5
end

local function DropTargetFindSlot(bagType)
    local bagID, slotIndex = private.GetFirstFreeSlot(bagType)
    if bagID then
        _G.PickupContainerItem(bagID, slotIndex)
    end
end
local function CreateBag(bagType)
    local main = _G.CreateFrame("Frame", "RealUIInventory", _G.UIParent)
    _G.Mixin(main, _G.ContinuableContainer)
    main:SetPoint("BOTTOMRIGHT", -100, 100)
    RealUI.MakeFrameDraggable(main)

    main.tag = "main"
    main.filter = function()
        return true
    end

    bags[bagType] = main
    Inventory[bagType] = main
    SetupBag(main)

    local money = _G.CreateFrame("Frame", "$parentMoney", main, "SmallMoneyFrameTemplate")
    money:SetPoint("TOPRIGHT", 10, -3)
    main.money = money
    main.offsetTop = main.offsetTop + 15

    local search = _G.CreateFrame("EditBox", "$parentSearch", main, "BagSearchBoxTemplate")
    search:SetPoint("BOTTOMLEFT", 5, 5)
    search:SetPoint("BOTTOMRIGHT", -5, 5)
    search:SetHeight(20)
    Skin.BagSearchBoxTemplate(search)
    main.search = search
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
    count:SetText(_G.CalculateTotalNumberOfFreeBagSlots())
    dropTarget.count = count

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
            private.Update()
            dropTarget.count:SetText(_G.CalculateTotalNumberOfFreeBagSlots())
        end
    end)
    main:Hide()

    for i, tag in ipairs(Inventory.db.global.filters) do
        local bag = _G.CreateFrame("Frame", "$parent_"..tag, main)
        SetupBag(bag)

        local info = private.filters[tag]
        local name = bag:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        name:SetPoint("TOPLEFT")
        name:SetPoint("BOTTOMRIGHT", bag, "TOPRIGHT", 0, -15)
        name:SetText(info.name)
        name:SetJustifyV("MIDDLE")
        bag.offsetTop = bag.offsetTop + 15

        bags[tag] = bag
    end

    main:ContinueOnLoad(function()
        private.Update()
    end)
end


function private.CreateBags()
    CreateBag("main")
end
