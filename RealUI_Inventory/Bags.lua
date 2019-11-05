local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert next wipe ipairs

-- Libs --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin

-- RealUI --
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
function private.UpdateBags()
    for tag, bag in next, bags do
        wipe(bag.slots)
    end

    for bagID = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS do
        private.UpdateSlots(bagID)
    end

    for tag, bag in next, bags do
        sort(bag.slots, SortSlots)

        local slotWidth, slotHeight = private.ArrangeSlots(bag, bag.offsetTop)
        bag:SetSize(slotWidth + bag.baseWidth, slotHeight + (bag.offsetTop + bag.offsetBottom))
    end
end

function private.AddSlotToBag(slot, bagID)
    local bag = Inventory.main
    for _, info in ipairs(private.filters) do
        if info.filter(slot) then
            bag = bags[info.tag]
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
local function CreateBag(bagType)
    local main = _G.CreateFrame("Frame", "RealUIInventory", _G.UIParent)
    _G.Mixin(main, _G.ContinuableContainer)
    main:SetPoint("BOTTOMRIGHT", -100, 100)
    main:SetMovable(true)
    main:RegisterForDrag("LeftButton")
    main:SetScript("OnMouseDown", function()
        main:ClearAllPoints()
        main:StartMoving()
    end)
    main:SetScript("OnMouseUp",  main.StopMovingOrSizing)


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

    main:RegisterEvent("BAG_OPEN")
    main:RegisterEvent("BAG_CLOSED")
    main:RegisterEvent("QUEST_ACCEPTED")
    main:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
    main:SetScript("OnEvent", function(event, ...)
        if event == "BAG_OPEN" then
            private.Toggle(true)
        elseif event == "BAG_CLOSED" then
            private.Toggle(false)
        elseif event == "ITEM_LOCK_CHANGED" then
            local bagID, slotIndex = ...
            if bagID and slotIndex then
                local slot = private.GetSlot(bagID, slotIndex)
                _G.SetItemButtonDesaturated(slot, slot:IsItemLocked())
            end
        else
            private.Update()
        end
    end)
    main:Hide()

    main:ContinueOnLoad(function()
        private.Update()
    end)

    for i, info in ipairs(private.filters) do
        local bag = _G.CreateFrame("Frame", "$parent_"..info.tag, main)
        SetupBag(bag)

        local name = bag:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        name:SetPoint("TOPLEFT")
        name:SetPoint("BOTTOMRIGHT", bag, "TOPRIGHT", 0, -15)
        name:SetText(info.name)
        name:SetJustifyV("MIDDLE")
        bag.offsetTop = bag.offsetTop + 15

        bag.tag = info.tag
        bag.filter = info.filter

        local anchor = bagType
        if i > 1 then
            anchor = private.filters[i - 1].tag
        end
        bag:SetPoint("BOTTOMRIGHT", bags[anchor], "TOPRIGHT", 0, 5)

        bags[info.tag] = bag
    end
end


function private.CreateBags()
    CreateBag("main")
end
