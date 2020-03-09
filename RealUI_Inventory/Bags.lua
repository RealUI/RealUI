local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert next wipe ipairs sort

-- Libs --
local fa = _G.LibStub("LibIconFonts-1.0"):GetIconFont("FontAwesome-4.7")
fa.path = _G.LibStub("LibSharedMedia-3.0"):Fetch("font", "Font Awesome")

local Aurora = _G.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin
local Color = Aurora.Color

-- RealUI --
local RealUI = _G.RealUI

local Inventory = private.Inventory

local InventoryType = _G.Enum.InventoryType
local invTypes = {
    [InventoryType.IndexHeadType] = 1,
    [InventoryType.IndexNeckType] = 2,
    [InventoryType.IndexShoulderType] = 3,
    [InventoryType.IndexCloakType] = 4,
    [InventoryType.IndexChestType] = 5,
    [InventoryType.IndexRobeType] = 5, -- Holiday chest
    [InventoryType.IndexBodyType] = 6, -- Shirt
    [InventoryType.IndexTabardType] = 7,
    [InventoryType.IndexWristType] = 8,
    [InventoryType.IndexHandType] = 9,
    [InventoryType.IndexWaistType] = 10,
    [InventoryType.IndexLegsType] = 11,
    [InventoryType.IndexFeetType] = 12,
    [InventoryType.IndexFingerType] = 13,
    [InventoryType.IndexTrinketType] = 14,

    [InventoryType.Index2HweaponType] = 15,
    [InventoryType.IndexRangedType] = 16, -- Bows
    [InventoryType.IndexRangedrightType] = 16, -- Wands, Guns, and Crossbows

    [InventoryType.IndexWeaponType] = 17, -- One-Hand
    [InventoryType.IndexWeaponmainhandType] = 18,
    [InventoryType.IndexWeaponoffhandType] = 19,
    [InventoryType.IndexShieldType] = 20,

    [InventoryType.IndexHoldableType] = 21,
    [InventoryType.IndexRelicType] = 21,

    [InventoryType.IndexAmmoType] = 22,
    [InventoryType.IndexThrownType] = 22,

    [InventoryType.IndexBagType] = 25,
    [InventoryType.IndexQuiverType] = 25,

    [InventoryType.IndexNonEquipType] = 30,
}
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
    if invTypes[invTypeA] ~= invTypes[invTypeB] then
        return invTypes[invTypeA] < invTypes[invTypeB]
    end


    local nameA = a.item:GetItemName()
    local nameB = b.item:GetItemName()
    if nameA ~= nameB then
        return nameA < nameB
    end


    local stackA = _G.C_Item.GetStackCount(a)
    local stackB = _G.C_Item.GetStackCount(b)
    if stackA ~= stackB then
        return stackA > stackB
    end
end
local function UpdateBagSize(bag, columnHeight, columnBase, numSkipped)
    sort(bag.slots, SortSlots)

    if bag.isPrimary then
        tinsert(bag.slots, bag.dropTarget)
    end

    local slotWidth, slotHeight = private.ArrangeSlots(bag, bag.offsetTop)
    bag:SetSize(slotWidth + bag.baseWidth, slotHeight + (bag.offsetTop + bag.offsetBottom))

    local _, screenHeight = RealUI.GetInterfaceSize()
    local maxHeight = screenHeight * Inventory.db.global.maxHeight

    local height = bag:GetHeight()
    if bag.isPrimary then
        columnHeight = columnHeight + height + 5
    else
        local parent = bag.parent
        bag:ClearAllPoints()

        if columnHeight + height >= maxHeight then
            if parent.bagType == "main" then
                bag:SetPoint("BOTTOMRIGHT", parent.bags[columnBase] or parent, "BOTTOMLEFT", -5, 0)
            else
                bag:SetPoint("TOPLEFT", parent.bags[columnBase] or parent, "TOPRIGHT", 5, 0)
            end
            columnBase = bag.filter.tag
            columnHeight = height + 5
        else
            columnHeight = columnHeight + height + 5

            local anchor = "main"
            local index = bag.filter:GetIndex()
            if index > 1 then
                anchor = Inventory.db.global.filters[index - (1 + numSkipped)]
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
    local columnHeight, columnBase = 0, "main"
    columnHeight, columnBase = UpdateBagSize(main, columnHeight, columnBase)

    local numSkipped = 0
    for i, tag in ipairs(Inventory.db.global.filters) do
        local bag = main.bags[tag]
        if #bag.slots <= 0 then
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
        bag:Hide()
        wipe(bag.slots)
    end

    for k, bagID in private.IterateBagIDs(main.bagType) do
        private.UpdateSlots(bagID)
    end

    main.dropTarget.count:SetText(private.GetNumFreeSlots(main))
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

    local assignedTag = Inventory.db.global.assignedFilters[slot.item:GetItemID()]
    if not Inventory:GetFilter(assignedTag) then
        for i, tag in ipairs(Inventory.db.global.filters) do
            local filter = Inventory:GetFilter(tag)
            if filter:DoesMatchSlot(slot) then
                if assignedTag then
                    if filter:HasPriority(assignedTag) then
                        assignedTag = tag
                    end
                else
                    assignedTag = tag
                end
            end
        end
    end

    local bag = main.bags[assignedTag] or main

    tinsert(bag.slots, slot)
    slot:SetParent(private.bagSlots[main.bagType][bagID])

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

local function CreateFeatureButton(bag, text, atlas, onClick, onEnter)
    local button = _G.CreateFrame("Button", nil, bag)
    button:SetPoint("TOPLEFT", 7, -7)
    button:SetSize(16, 16)

    if fa[atlas] then
        local icon = button:CreateFontString(nil, "ARTWORK")
        icon:SetFont(fa.path, 14, "")
        icon:SetText(fa[atlas])
        icon:SetTextColor(Color.white:GetRGB())
        icon:SetJustifyV("MIDDLE")
        icon:SetJustifyH("CENTER")
        icon:SetAllPoints()
        button.icon = icon
    else
        local atlasInfo = _G.C_Texture.GetAtlasInfo(atlas)
        button:SetNormalAtlas(atlas)
        local texture = button:GetNormalTexture()
        texture:ClearAllPoints()
        texture:SetPoint("CENTER")
        texture:SetSize(atlasInfo.width, atlasInfo.height)
        button.texture = texture
    end

    if text then
        button:SetHitRectInsets(-5, -50, -5, -5)
        button:SetNormalFontObject("GameFontDisableSmall")
        button:SetPushedTextOffset(0, 0)
        button:SetText(text)
        button.text = button:GetFontString()
        button.text:SetPoint("LEFT", button, "RIGHT", 1, 0)
    end

    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnClick", onClick)
    button:SetScript("OnEnter", function(self)
        if self.icon then
            self.icon:SetTextColor(Color.highlight:GetRGB())
        else
            self.texture:SetVertexColor(Color.highlight:GetRGB())
        end

        if onEnter then
            onEnter(self)
        end
    end)
    button:SetScript("OnLeave", function(self)
        if self.icon then
            self.icon:SetTextColor(Color.white:GetRGB())
        else
            self.texture:SetVertexColor(Color.white:GetRGB())
        end
        _G.GameTooltip_Hide()
    end)

    return button
end
function private.CreateFilterBag(main, filter)
    local tag = filter.tag
    local bag = _G.CreateFrame("Frame", "$parent_"..tag, main)
    SetupBag(bag)

    local name = bag:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    name:SetPoint("TOPLEFT")
    name:SetPoint("BOTTOMRIGHT", bag, "TOPRIGHT", 0, -HEADER_SPACE)
    name:SetText(filter.name)
    name:SetJustifyV("MIDDLE")

    bag.parent = main
    bag.filter = filter

    if tag == "new" then
        bag.resetNew = CreateFeatureButton(bag, _G.RESET, "check", function(self)
            for _, slot in ipairs(bag.slots) do
                _G.C_NewItems.RemoveNewItem(slot:GetBagAndSlot())
            end

            UpdateBag(main)
        end)
    end

    if tag == "junk" then
        bag.sellJunk = CreateFeatureButton(bag, _G.AUCTION_HOUSE_SELL_TAB, "trash", private.SellJunk)
        bag.sellJunk:Hide()
    end

    main.bags[tag] = bag

    return bag
end

local bagCost = _G.CreateAtlasMarkup("NPE_RightClick", 20, 20, 0, -2) .. _G.COSTS_LABEL .. " "
local BasicEvents = {
    "BAG_UPDATE",
    "BAG_UPDATE_COOLDOWN",
    "INVENTORY_SEARCH_UPDATE",
    "ITEM_LOCK_CHANGED",
}
local BagEvents = {
    "UNIT_INVENTORY_CHANGED",
    "PLAYER_SPECIALIZATION_CHANGED",
    "BAG_NEW_ITEMS_UPDATED",
}
local BankEvents = {
    "PLAYERBANKSLOTS_CHANGED",
    "PLAYERBANKBAGSLOTS_CHANGED",
}
local ReagentEvents = {
    "PLAYERREAGENTBANKSLOTS_CHANGED",
    "REAGENTBANK_PURCHASED",
}
local function CreateBag(bagType)
    local main
    if bagType == "main" then
        main = _G.CreateFrame("Frame", "RealUIInventory", _G.UIParent)
        main:SetPoint("BOTTOMRIGHT", -100, 100)
        main:RegisterEvent("QUEST_ACCEPTED")
        main:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
        main:SetScript("OnEvent", function(self, event, ...)
            if event == "ITEM_LOCK_CHANGED" then
                local bagID, slotIndex = ...
                if bagID and slotIndex then
                    local slot = private.GetSlot(bagID, slotIndex)
                    if slot then
                        _G.SetItemButtonDesaturated(slot, slot.item:IsItemLocked())
                    end
                end
            else
                UpdateBag(self)
            end
        end)
        main:SetScript("OnShow", function(self)
            _G.FrameUtil.RegisterFrameForEvents(self, BasicEvents)
            _G.FrameUtil.RegisterFrameForEvents(self, BagEvents)
            UpdateBag(self)
        end)
        main:SetScript("OnHide", function(self)
            _G.FrameUtil.UnregisterFrameForEvents(self, BasicEvents)
            _G.FrameUtil.UnregisterFrameForEvents(self, BagEvents)
            self.showBags:ToggleBags(false)
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
            end
        end)
        main:SetScript("OnShow", function(self)
            _G.FrameUtil.RegisterFrameForEvents(self, BasicEvents)
            _G.FrameUtil.RegisterFrameForEvents(self, BankEvents)
            UpdateBag(self)
        end)
        main:SetScript("OnHide", function(self)
            _G.FrameUtil.UnregisterFrameForEvents(self, BasicEvents)
            _G.FrameUtil.UnregisterFrameForEvents(self, BankEvents)
            self.showBags:ToggleBags(false)
            self:Cancel()
        end)
    elseif bagType == "reagent" then
        main = _G.CreateFrame("Frame", "RealUIReagent", _G.UIParent)
        main:SetPoint("TOPLEFT", 100, -100)
        main:SetScript("OnEvent", function(self, event, ...)
            if event == "ITEM_LOCK_CHANGED" then
                local bagID, slotIndex = ...
                if bagID and slotIndex then
                    local slot = private.GetSlot(bagID, slotIndex)
                    if slot then
                        _G.SetItemButtonDesaturated(slot, slot.item:IsItemLocked())
                    end
                end
            else
                UpdateBag(self)
            end
        end)
        main:SetScript("OnShow", function(self)
            _G.FrameUtil.RegisterFrameForEvents(self, BasicEvents)
            _G.FrameUtil.RegisterFrameForEvents(self, ReagentEvents)
            UpdateBag(self)
        end)
        main:SetScript("OnHide", function(self)
            _G.FrameUtil.UnregisterFrameForEvents(self, BasicEvents)
            _G.FrameUtil.UnregisterFrameForEvents(self, ReagentEvents)
            self:Cancel()
        end)
    end

    _G.Mixin(main, ContinuableContainer)
    RealUI.MakeFrameDraggable(main)
    main:SetToplevel(true)
    main.isPrimary = true
    main.bagType = bagType

    Inventory[bagType] = main
    SetupBag(main)

    if bagType == "reagent" then
        local deposit = CreateFeatureButton(main, _G.BAGSLOTTEXT, "download",
        function(self, button)
            if _G.IsReagentBankUnlocked() then
                _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION)
                _G.DepositReagentBank()
            else
                _G.StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
            end
        end,
        function(self)
            _G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
            if _G.IsReagentBankUnlocked() then
                _G.GameTooltip_SetTitle(_G.GameTooltip, _G.REAGENTBANK_DEPOSIT, nil, true)
            else
                local cost = _G.GetReagentBankCost()
                _G.GameTooltip_SetTitle(_G.GameTooltip, _G.REAGENTBANK_PURCHASE_TEXT, nil, true)
                _G.GameTooltip_AddBlankLineToTooltip(_G.GameTooltip)

                local text = bagCost .. _G.GetMoneyString(cost)
                if _G.GetMoney() >= cost then
                    _G.GameTooltip_AddNormalLine(_G.GameTooltip, text)
                else
                    _G.GameTooltip_AddErrorLine(_G.GameTooltip, text)
                end
            end
            _G.GameTooltip:Show()
        end)
        main.deposit = deposit
    else
        local showBags = CreateFeatureButton(main, _G.BAGSLOTTEXT, "shopping-bag",
        function(self, button)
            if bagType == "bank" and button == "RightButton" then
                _G.StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
            else
                self:ToggleBags()
            end
        end,
        function(self)
            if bagType == "bank" then
                local numSlots, full = _G.GetNumBankSlots()
                if not full then
                    local cost = _G.GetBankSlotCost(numSlots)
                    _G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                    _G.GameTooltip_SetTitle(_G.GameTooltip, _G.BANKSLOTPURCHASE_LABEL, nil, true)
                    _G.GameTooltip_AddBlankLineToTooltip(_G.GameTooltip)

                    local text = bagCost .. _G.GetMoneyString(cost)
                    if _G.GetMoney() >= cost then
                        _G.GameTooltip_AddNormalLine(_G.GameTooltip, text)
                    else
                        _G.GameTooltip_AddErrorLine(_G.GameTooltip, text)
                    end

                    _G.GameTooltip:Show()
                end
            end
        end)
        function showBags:ToggleBags(show)
            if show == nil then
                show = not self.isShowing
            end

            local firstBag = _G.BACKPACK_CONTAINER
            if bagType == "bank" then
                firstBag = _G.BANK_CONTAINER
            elseif bagType == "reagent" then
                firstBag = _G.REAGENTBANK_CONTAINER
            end

            local bagSlots = private.bagSlots[bagType]
            if show then
                self:SetText("")
                self:SetHitRectInsets(-5, -5, -5, -5)

                bagSlots[firstBag]:SetPoint("TOPLEFT", main.showBags, "TOPRIGHT", 5, 1)
                for k, bagID in private.IterateBagIDs(bagType) do
                    bagSlots[bagID]:Update()
                end
            else
                self:SetText(_G.BAGSLOTTEXT)
                self:SetHitRectInsets(-5, -50, -5, -5)

                bagSlots[firstBag]:SetPoint("TOPLEFT", _G.UIParent, "TOPRIGHT", 5, 0)
                for k, bagID in private.IterateBagIDs(bagType) do
                    bagSlots[bagID]:Update()
                end

                private.SearchItemsForBag(bagType)
            end

            self.isShowing = show
        end
        main.showBags = showBags
    end

    local close = _G.CreateFrame("Button", "$parentClose", main, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 5, 5)
    Skin.UIPanelCloseButton(close)
    main.close = close

    if bagType == "main" then
        local settingsButton = CreateFeatureButton(main, nil, "cog",
        function(self)
            RealUI.LoadConfig("RealUI", "inventory")
        end,
        function(self)
            _G.GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, _G.SETTINGS, nil, true)

            _G.GameTooltip:Show()
        end)
        settingsButton:ClearAllPoints()
        settingsButton:SetPoint("TOPRIGHT", close:GetBackdropTexture("bg"), "TOPLEFT", -5, 0)
        main.settingsButton = settingsButton
    else
        local reagents
        if bagType == "bank" then
            reagents = CreateFeatureButton(main, nil, "archive",
            function(self)
                local point, anchor, relPoint, x, y = main:GetPoint()
                Inventory.reagent:Show()
                Inventory.reagent:SetPoint(point, anchor, relPoint, x, y)
                main:Hide()
            end,
            function(self)
                _G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                _G.GameTooltip_SetTitle(_G.GameTooltip, _G.BROWSE .. " " .. _G.REAGENT_BANK, nil, true)
                _G.GameTooltip_AddNormalLine(_G.GameTooltip, _G.REAGENT_BANK_HELP)

                _G.GameTooltip:Show()
            end)
            reagents:ClearAllPoints()
            reagents:SetPoint("TOPRIGHT", close:GetBackdropTexture("bg"), "TOPLEFT", -5, 0)
            main.reagents = reagents
        elseif bagType == "reagent" then
            reagents = CreateFeatureButton(main, nil, "bank",
            function(self)
                local point, anchor, relPoint, x, y = main:GetPoint()
                Inventory.bank:Show()
                Inventory.bank:SetPoint(point, anchor, relPoint, x, y)
                main:Hide()
            end,
            function(self)
                _G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                _G.GameTooltip_SetTitle(_G.GameTooltip, _G.BROWSE .. " " .. _G.BANK, nil, true)
                _G.GameTooltip_AddNormalLine(_G.GameTooltip, _G.REAGENT_BANK_HELP)

                _G.GameTooltip:Show()
            end)
        end

        reagents:ClearAllPoints()
        reagents:SetPoint("TOPRIGHT", close:GetBackdropTexture("bg"), "TOPLEFT", -5, 0)
        main.reagents = reagents
    end

    local searchBox = _G.CreateFrame("EditBox", "$parentSearchBox", main, "BagSearchBoxTemplate")
    searchBox:SetPoint("BOTTOMLEFT", 9, 5)
    searchBox:SetPoint("BOTTOMRIGHT", -4, 5)
    searchBox:SetHeight(20)
    searchBox:Hide()
    _G.hooksecurefunc(searchBox, "ClearFocus", function(self)
        self:Hide()
        main.moneyFrame:Show()
        main.searchButton:Show()
    end)
    Skin.BagSearchBoxTemplate(searchBox)
    main.searchBox = searchBox

    local searchButton = CreateFeatureButton(main, _G.SEARCH, "common-search-magnifyingglass",
    function(self)
        self:Hide()
        main.moneyFrame:Hide()
        main.searchBox:Show()
        main.searchBox:SetFocus()
    end)
    searchButton:SetPoint("TOPLEFT", searchBox, 0, -3)
    searchButton.texture:SetSize(10, 10)
    searchButton.text:SetPoint("LEFT", searchButton, "RIGHT", 1, 1)
    main.searchButton = searchButton

    local moneyFrame = _G.CreateFrame("Frame", "$parentMoney", main, "SmallMoneyFrameTemplate")
    moneyFrame:SetPoint("BOTTOMRIGHT", 8, 8)
    main.moneyFrame = moneyFrame
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
    private.CreateBagSlots(main)

    main:Hide()
end


function private.CreateBags()
    CreateBag("main")
    CreateBag("bank")
    CreateBag("reagent")
end
