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
local L = RealUI.L
local C_Container = RealUI.C_Container

local BagMixin do
    local HEADER_SPACE = 20
    local BAG_MARGIN = 5

    local SLOT_SPACING = 3
    local SLOTS_PER_ROW = 6

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
        [InventoryType.IndexProfessionToolType] = 25,
        [InventoryType.IndexProfessionGearType] = 25,

        [InventoryType.IndexEquipablespellOffensiveType] = 30,
        [InventoryType.IndexEquipablespellUtilityType] = 30,
        [InventoryType.IndexEquipablespellDefensiveType] = 30,
        [InventoryType.IndexEquipablespellWeaponType] = 30,
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


        local ilvlA = a.item:GetCurrentItemLevel()
        local ilvlB = b.item:GetCurrentItemLevel()
        if ilvlA ~= ilvlB then
            return ilvlA > ilvlB
        end


        local nameA = a.item:GetItemName()
        local nameB = b.item:GetItemName()
        if nameA ~= nameB then
            return nameA < nameB
        end


        local stackA = _G.C_Item.GetStackCount(a.location)
        local stackB = _G.C_Item.GetStackCount(b.location)
        if stackA ~= stackB then
            return stackA > stackB
        end
    end

    BagMixin = {}
    function BagMixin:Init()
        Skin.FrameTypeFrame(self)
        self:EnableMouse(true)
        self.slots = {}

        self.marginTop = HEADER_SPACE
        self.marginBottom = BAG_MARGIN
        self.marginSide = BAG_MARGIN
    end
    function BagMixin:ArrangeSlots()
        Inventory:debug("BagMixin:ArrangeSlots", self.bagType or self.filter.tag)
        local numSlots, numRows = 0, 0
        local previousButton, cornerButton
        local slotSize = 0
        for _, slot in ipairs(self.slots) do
            numSlots = numSlots + 1
            slot:ClearAllPoints() -- The template has anchors
            if not previousButton then
                slot:SetPoint("TOPLEFT", self, self.marginSide, -self.marginTop)
                previousButton = slot
                cornerButton = slot

                slotSize = slot:GetWidth()
                numRows = numRows + 1
            else
                if numSlots % SLOTS_PER_ROW == 1 then -- new row
                    slot:SetPoint("TOPLEFT", cornerButton, "BOTTOMLEFT", 0, -SLOT_SPACING)
                    cornerButton = slot

                    numRows = numRows + 1
                else
                    slot:SetPoint("TOPLEFT", previousButton, "TOPRIGHT", SLOT_SPACING, 0)
                end

                previousButton = slot
            end
        end

        local gapOffsetH = SLOT_SPACING * (SLOTS_PER_ROW - 1)
        local gapOffsetV = SLOT_SPACING * (numRows - 1)
        return (slotSize * SLOTS_PER_ROW) + gapOffsetH, (slotSize * numRows) + gapOffsetV
    end
    function BagMixin:UpdateSize(columnHeight, columnBase, prevBag)
        Inventory:debug("BagMixin:UpdateSize", self.bagType or self.filter.tag)
        sort(self.slots, SortSlots)

        if self.isPrimary then
            tinsert(self.slots, self.dropTarget)
        end

        local slotWidth, slotHeight = self:ArrangeSlots()
        self:SetSize(slotWidth + (self.marginSide * 2), slotHeight + (self.marginTop + self.marginBottom))

        local _, screenHeight, _, scaledHieght = RealUI.GetInterfaceSize()
        local maxHeight = (scaledHieght or screenHeight) * Inventory.db.global.maxHeight
        local height = self:GetHeight()

        local newColumnHeight = columnHeight + height + 5

        if self.isPrimary then
            if self.debugTexture and self.bagType == "main" then
                --print("screenHeight", screenHeight, scaledHieght, maxHeight)
                self.debugTexture:SetPoint("BOTTOMRIGHT", 50, maxHeight)
            end

            return newColumnHeight, self, self
        else
            local parent = self.parent
            self:ClearAllPoints() --Fix bags overlapping sometimes

            if newColumnHeight >= maxHeight then
                if parent.bagType == "main" then
                    self:SetPoint("BOTTOMRIGHT", columnBase, "BOTTOMLEFT", -5, 0)
                else
                    self:SetPoint("TOPLEFT", columnBase, "TOPRIGHT", 5, 0)
                end

                columnHeight, columnBase = height, self
            else
                if parent.bagType == "main" then
                    self:SetPoint("BOTTOMRIGHT", prevBag, "TOPRIGHT", 0, 5)
                else
                    self:SetPoint("TOPLEFT", prevBag, "BOTTOMLEFT", 0, -5)
                end

                columnHeight = newColumnHeight
            end

            return columnHeight, columnBase, self
        end
    end
end

local FilterBagMixin = _G.CreateFromMixins(BagMixin)
function FilterBagMixin:Update()
    -- body
end

local bagCost = _G.CreateAtlasMarkup("NPE_RightClick", 20, 20, 0, -2) .. _G.COSTS_LABEL .. " "
local BasicEvents = {
    "BAG_UPDATE",
    "BAG_UPDATE_COOLDOWN",
    "BAG_UPDATE_DELAYED",
    "INVENTORY_SEARCH_UPDATE",
    "ITEM_LOCK_CHANGED",
}

local MainBagMixin = _G.CreateFromMixins(_G.ContinuableContainer, BagMixin)
function MainBagMixin:Init()
    BagMixin.Init(self)
    self.time = _G.GetTime()

    RealUI.MakeFrameDraggable(self)
    self:SetToplevel(true)
    self.isPrimary = true

    local debugTexture
    if RealUI.isDev then
        debugTexture = self:CreateTexture("InventoryMaxHeightDebug", "OVERLAY")
        debugTexture:SetSize(300, 2)
        debugTexture:SetColorTexture(1, 1, 1, 0.8)
        self.debugTexture = debugTexture
    end

    self:SetScript("OnEvent", self.OnEvent)
    self:SetScript("OnShow", self.OnShow)
    self:SetScript("OnHide", self.OnHide)
end
function MainBagMixin:Update()
    if self:AreAnyLoadsOutstanding() then return end

    wipe(self.slots)
    for tag, bag in next, self.bags do
        bag:Hide()
        wipe(bag.slots)
    end

    private.UpdateEquipSetItems()
    for k, bagID in self:IterateBagIDs() do
        private.UpdateSlots(bagID)
    end

    self.dropTarget.count:SetText(self:GetNumFreeSlots())
    self:ContinueOnLoad(function()
        self:UpdateSlots()
    end)
end
function MainBagMixin:UpdateSlots()
    Inventory:debug("MainBagMixin:UpdateSlots", self.bagType or self.filter.tag)
    local columnHeight, columnBase, prevBag = 0, "main"
    columnHeight, columnBase, prevBag = self:UpdateSize(columnHeight, columnBase)

    local numSkipped = 0
    for i, filter in Inventory:IndexedFilters() do
        local bag = self.bags[filter.tag]
        if bag then
            if #bag.slots <= 0 then
                numSkipped = numSkipped + 1
            else
                columnHeight, columnBase, prevBag = bag:UpdateSize(columnHeight, columnBase, prevBag)
                bag:Show()
                numSkipped = 0
            end
        end
    end
end
function MainBagMixin:GetNumFreeSlots()
    local totalFree, freeSlots, bagFamily = 0
    for k, bagID in self:IterateBagIDs() do
        freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(bagID)
        if bagFamily == 0 then
            totalFree = totalFree + freeSlots
        end
    end

    return totalFree
end
function MainBagMixin:GetFirstFreeSlot()
    for k, bagID in self:IterateBagIDs() do
        local slotIndex = private.GetFirstFreeSlot(bagID)
        if slotIndex then
            return bagID, slotIndex
        end
    end

    return false
end
function MainBagMixin:IterateBagIDs()
    return ipairs(self.bagIDs)
end

function MainBagMixin:OnEvent(event, ...)
    if event == "ITEM_LOCK_CHANGED" then
        local bagID, slotIndex = ...
        if bagID and slotIndex then
            local slot = private.GetSlot(bagID, slotIndex)
            if slot then
                _G.SetItemButtonDesaturated(slot, slot.item:IsItemLocked())
            end
        end
    elseif event == "BAG_UPDATE_COOLDOWN" then
        for tag, bag in next, self.bags do
            for _, slot in ipairs(bag.slots) do
                slot:UpdateCooldown()
            end
        end
    elseif event == "INVENTORY_SEARCH_UPDATE" then
        for tag, bag in next, self.bags do
            for _, slot in ipairs(bag.slots) do
                slot:UpdateItemContext()
            end
        end
    else
        local now = _G.debugprofilestop()
        if (now - self.time) > 1000 or event == "BAG_UPDATE_DELAYED" then
            self.time = now
            self:Update()
        end
    end
end
function MainBagMixin:OnShow()
    _G.FrameUtil.RegisterFrameForEvents(self, BasicEvents)
    _G.FrameUtil.RegisterFrameForEvents(self, self.events)
    self:Update()
end
function MainBagMixin:OnHide()
    _G.FrameUtil.UnregisterFrameForEvents(self, BasicEvents)
    _G.FrameUtil.UnregisterFrameForEvents(self, self.events)
    self:Cancel()

    if self.showBags then
        self.showBags:ToggleBags(false)
    end
end


local InventoryBagMixin = _G.CreateFromMixins(MainBagMixin)
function InventoryBagMixin:Init()
    MainBagMixin.Init(self)
    self.events = {
        "UNIT_INVENTORY_CHANGED",
        "PLAYER_SPECIALIZATION_CHANGED",
    }

    self.new = {}
    self:SetPoint("BOTTOMRIGHT", -100, 100)
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
    self:RegisterEvent("BAG_NEW_ITEMS_UPDATED")
end
function InventoryBagMixin:OnShow()
    MainBagMixin.OnShow(self)
    _G.PlaySound(_G.SOUNDKIT.IG_BACKPACK_OPEN)
end
function InventoryBagMixin:OnHide()
    MainBagMixin.OnHide(self)
    _G.PlaySound(_G.SOUNDKIT.IG_BACKPACK_CLOSE)
end

local BankBagMixin = _G.CreateFromMixins(MainBagMixin)
function BankBagMixin:Init()
    MainBagMixin.Init(self)
    self.events = {
        "PLAYERBANKSLOTS_CHANGED",
        "PLAYERBANKBAGSLOTS_CHANGED",
        "PLAYERREAGENTBANKSLOTS_CHANGED",
        "REAGENTBANK_PURCHASED",
    }

    self:SetPoint("TOPLEFT", 100, -100)
end
function BankBagMixin:OnShow()
    MainBagMixin.OnShow(self)
    _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPEN)
end
function BankBagMixin:OnHide()
    MainBagMixin.OnHide(self)
    _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_CLOSE)
    _G.CloseBankFrame()
end

function private.UpdateBags()
    Inventory:debug("private.UpdateBags")
    Inventory.main:Update()
    if Inventory.atBank then
        Inventory.bank:Update()
    end
end

function private.AddSlotToBag(slot, bagID)
    local bagType = private.GetBagTypeForBagID(bagID)
    local main = Inventory[bagType]

    local _, slotIndex = slot:GetBagAndSlot()
    Inventory:debug("private.AddSlotToBag", bagID, slotIndex)
    if bagType == "main" and _G.C_NewItems.IsNewItem(bagID, slotIndex) then
        if not main.new[bagID] then
            main.new[bagID] = {}
        end
        main.new[bagID][slotIndex] = true
    end

    local assignedTag = Inventory.db.global.assignedFilters[slot.item:GetItemID()]
    if Inventory.db.char.junk[bagID] and Inventory.db.char.junk[bagID][slotIndex] then
        assignedTag = "junk"
    end

    if not Inventory:GetFilter(assignedTag) then
        for i, filter in Inventory:IndexedFilters() do
            if filter:DoesMatchSlot(slot) then
                if assignedTag then
                    if filter:HasPriority(assignedTag) then
                        assignedTag = filter.tag
                    end
                else
                    assignedTag = filter.tag
                end
            end
        end
    end
    Inventory:debug("assignedTag", assignedTag)

    --[[
    if slot.item:GetItemID() == 98091 then
        print("Found item", bagID, slotIndex, assignedTag)
    end
    ]]

    slot.assignedTag = assignedTag or "main"
    local bag = main.bags[assignedTag] or main

    tinsert(bag.slots, slot)
    slot:SetParent(private.bagSlots[main.bagType][bagID])

    main:AddContinuable(slot.item)
end

local function CreateFeatureButton(bag, text, atlas, onClick, onEnter)
    local button = _G.CreateFrame("Button", nil, bag)
    button:SetSize(16, 16)

    if fa[atlas] then
        local icon = button:CreateFontString(nil, "ARTWORK")
        icon:SetPoint("CENTER")
        icon:SetFont(fa.path, 14, "")
        icon:SetText(fa[atlas])
        icon:SetTextColor(Color.white:GetRGB())
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
    Inventory:debug("private.CreateFilterBag", main.bagType, filter.tag)
    local tag = filter.tag
    local bag = _G.CreateFrame("Frame", "$parent_"..tag, main)
    _G.Mixin(bag, FilterBagMixin)
    bag:Init()

    local name = bag:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    name:SetPoint("TOPLEFT")
    name:SetPoint("BOTTOMRIGHT", bag, "TOPRIGHT", 0, -bag.marginTop)
    name:SetText(filter.name)
    name:SetJustifyV("MIDDLE")

    bag.parent = main
    bag.filter = filter

    if tag == "new" then
        bag.resetNew = CreateFeatureButton(bag, _G.RESET, "check", function(self)
            for bagID, items in next, main.new do
                for slotIndex in next, items do
                    _G.C_NewItems.RemoveNewItem(bagID, slotIndex)
                end
            end

            wipe(main.new)
            main:Update()
        end)

        bag.resetNew:SetPoint("TOPLEFT", 5, -2)
    end

    if tag == "junk" then
        bag.sellJunk = CreateFeatureButton(bag, _G.AUCTION_HOUSE_SELL_TAB, "trash", private.SellJunk,
        function(self)
            _G.GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, _G.GetMoneyString(bag.profit, true), nil, true)

            _G.GameTooltip:Show()
        end)
        bag.sellJunk:Hide()
        bag.sellJunk:SetPoint("TOPLEFT", 5, -2)
    end

    main.bags[tag] = bag

    return bag
end

local bagInfo = {
    main = {
        name = "RealUIInventory",
        mixin = InventoryBagMixin,
        bagIDs = {0, 1, 2, 3, 4, 5}, -- BACKPACK_CONTAINER through NUM_TOTAL_EQUIPPED_BAG_SLOTS
    },
    bank = {
        name = "RealUIBank",
        mixin = BankBagMixin,
        bagIDs = {-1, 6, 7, 8, 9, 10, 11, -3}, -- BANK_CONTAINER, (NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1) through (NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), REAGENTBANK_CONTAINER
    },
}
local function CreateBag(bagType)
    local info = bagInfo[bagType]

    local main = _G.CreateFrame("Frame", info.name, _G.UIParent)
    _G.Mixin(main, info.mixin)
    main:Init()
    main.bagType = bagType
    main.bagIDs = info.bagIDs
    Inventory[bagType] = main
    tinsert(_G.UISpecialFrames, info.name)

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

    showBags:SetPoint("TOPLEFT", 5, -5)
    function showBags:ToggleBags(show)
        if show == nil then
            show = not self.isShowing
        end

        local firstBag = _G.BACKPACK_CONTAINER
        if bagType == "bank" then
            firstBag = _G.Enum.BagIndex.Bank -- _G.BANK_CONTAINER
        end

        local bagSlots = private.bagSlots[bagType]
        if show then
            self:SetText("")
            self:SetHitRectInsets(-5, -5, -5, -5)

            bagSlots[firstBag]:SetPoint("TOPLEFT", main.showBags, "TOPRIGHT", 5, 0)
            for k, bagID in main:IterateBagIDs() do
                bagSlots[bagID]:Update()
            end
        else
            self:SetText(_G.BAGSLOTTEXT)
            self:SetHitRectInsets(-5, -50, -5, -5)

            bagSlots[firstBag]:SetPoint("TOPLEFT", _G.UIParent, "TOPRIGHT", 5, 0)
            for k, bagID in main:IterateBagIDs() do
                bagSlots[bagID]:Update()
            end

            private.SearchItemsForBag(firstBag)
        end

        self.isShowing = show
    end
    main.showBags = showBags

    local close = _G.CreateFrame("Button", "$parentClose", main, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    Skin.UIPanelCloseButton(close)
    main.close = close
    main.marginTop = main.marginTop + 10

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

        settingsButton:SetPoint("TOPRIGHT", close:GetBackdropTexture("bg"), "TOPLEFT", -5, 0)
        main.settingsButton = settingsButton

        local restackButton = CreateFeatureButton(main, nil, "repeat",
        function(self)
            _G.PlaySound(_G.SOUNDKIT.UI_BAG_SORTING_01)
            _G.C_Container.SortBags()
        end,
        function(self)
            _G.GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, L.Inventory_Restack, nil, true)

            _G.GameTooltip:Show()
        end)

        restackButton:SetPoint("TOPRIGHT", settingsButton, "TOPLEFT", -5, 0)
        main.restackButton = restackButton
    else
        local deposit = CreateFeatureButton(main, nil, "download",
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
                local freeSlots = C_Container.GetContainerNumFreeSlots(_G.REAGENTBANK_CONTAINER)

                local text = _G.NUM_FREE_SLOTS:format(freeSlots)
                if freeSlots == 0 then
                    _G.GameTooltip_AddErrorLine(_G.GameTooltip, text)
                else
                    _G.GameTooltip_AddNormalLine(_G.GameTooltip, text)
                end
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

        deposit:SetPoint("TOPRIGHT", close:GetBackdropTexture("bg"), "TOPLEFT", -5, 0)
        main.deposit = deposit

        local restackButton = CreateFeatureButton(main, nil, "repeat",
        function(self)
            _G.PlaySound(_G.SOUNDKIT.UI_BAG_SORTING_01)
            _G.C_Container.SortBankBags()
            _G.C_Container.SortReagentBankBags()
        end,
        function(self)
            _G.GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, L.Inventory_Restack, nil, true)

            _G.GameTooltip:Show()
        end)

        restackButton:SetPoint("TOPRIGHT", deposit, "TOPLEFT", -5, 0)
        main.restackButton = restackButton
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
    main.marginBottom = main.marginBottom + 25

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
    function dropTarget:FindSlot()
        local bagID, slotIndex = main:GetFirstFreeSlot()
        if bagID then
            _G.C_Container.PickupContainerItem(bagID, slotIndex)
        end
    end
    dropTarget:SetScript("OnMouseUp", dropTarget.FindSlot)
    dropTarget:SetScript("OnReceiveDrag", dropTarget.FindSlot)
    main.dropTarget = dropTarget

    local count = dropTarget:CreateFontString(nil, "ARTWORK")
    count:SetFontObject("NumberFontNormal")
    count:SetPoint("BOTTOMRIGHT", 0, 2)
    count:SetText(main:GetNumFreeSlots())
    dropTarget.count = count

    main.bags = {}
    private.CreateBagSlots(main)

    main:Hide()
end


function private.CreateBags()
    Inventory:debug("private.CreateBags")
    CreateBag("main")
    CreateBag("bank")
end
