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

-- local bagCost = _G.CreateAtlasMarkup("NPE_RightClick", 20, 20, 0, -2) .. _G.COSTS_LABEL .. " "
local BasicEvents = {
    "BAG_UPDATE",
    "BAG_UPDATE_COOLDOWN",
    "BAG_CLOSED",
    "BAG_UPDATE_DELAYED",
    "BANK_BAG_SLOT_FLAGS_UPDATED",
    "PLAYERBANKSLOTS_CHANGED",
    "UNIT_INVENTORY_CHANGED",
    "INVENTORY_SEARCH_UPDATE",
    "ITEM_LOCK_CHANGED",
    "BAG_CONTAINER_UPDATE",
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
        freeSlots, bagFamily = _G.C_Container.GetContainerNumFreeSlots(bagID)
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
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", 100, -100)
    self:SetUserPlaced(false)
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
        "BANK_TABS_CHANGED",
        "BANK_TAB_SETTINGS_UPDATED",
        "PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED", -- Account bank
        "ACCOUNT_MONEY",
        "PLAYER_MONEY",
    }

    self:ClearAllPoints()
    self:SetPoint("BOTTOMRIGHT", -100, 100)
    self:SetUserPlaced(false)
end
function BankBagMixin:OnShow()
    MainBagMixin.OnShow(self)
    _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPEN)
    if self.bankTypeSwitcher then
        self.bankTypeSwitcher:Refresh()
    end

    -- Deferred re-fetch: server may not have sent custom tab names/icons yet
    -- on initial bank open. Re-refresh the sidebar after a short delay to pick
    -- up freshly arrived C_Bank data.
    if self.tabSidebar and self.activeBankType then
        _G.C_Timer.After(0.5, function()
            if self:IsShown() and self.activeBankType then
                self.tabSidebar:Refresh(self.activeBankType)
            end
        end)
    end
end
function BankBagMixin:OnHide()
    MainBagMixin.OnHide(self)
    _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_CLOSE)
    _G.C_Bank.CloseBankFrame()
end
function BankBagMixin:SetBankType(bankType)
    Inventory:debug("BankBagMixin:SetBankType", bankType)
    self.activeBankType = bankType

    -- Toggle auto-deposit button: visible only for Warband Bank
    if self.deposit then
        local config = private.bankTypeConfig[bankType]
        if config and config.supportsAutoDeposit then
            self.deposit:Show()
        else
            self.deposit:Hide()
        end
    end

    -- Toggle withdraw/deposit money buttons based on money transfer support
    if self.withdrawButton and self.depositButton then
        if _G.C_Bank.DoesBankTypeSupportMoneyTransfer(bankType) then
            self.withdrawButton:Show()
            self.depositButton:Show()
        else
            self.withdrawButton:Hide()
            self.depositButton:Hide()
        end
    end
    self:UpdateMoneyButtonLockState()

    -- Update money frame balance for active bank type
    if self.moneyFrame then
        if bankType == _G.Enum.BankType.Account then
            _G.MoneyFrame_SetType(self.moneyFrame, "ACCOUNT")
        else
            _G.MoneyFrame_SetType(self.moneyFrame, "PLAYER")
        end
        _G.MoneyFrame_UpdateMoney(self.moneyFrame)
    end

    -- Refresh tab sidebar — this will fetch purchased tabs, select the first one,
    -- and call SetActiveTab, which triggers Update.
    if self.tabSidebar then
        self.tabSidebar:Refresh(bankType)
    else
        -- Fallback if sidebar not yet created: select first purchased tab directly
        local purchasedTabs = _G.C_Bank.FetchPurchasedBankTabData(bankType)
        if purchasedTabs and #purchasedTabs > 0 then
            self:SetActiveTab(purchasedTabs[1].ID)
        else
            self:SetActiveTab(nil)
        end
    end
end
function BankBagMixin:SetActiveTab(tabID)
    Inventory:debug("BankBagMixin:SetActiveTab", tabID)
    self.activeTabID = tabID
    -- Release all pooled bank slot frames so old tab content is hidden
    private.ReleaseAllBankSlots()
    wipe(self.bagIDs)
    if tabID then
        tinsert(self.bagIDs, tabID)
    end
    self:Update()
end
function BankBagMixin:GetActiveBankType()
    return self.activeBankType
end
function BankBagMixin:GetActiveTabID()
    return self.activeTabID
end
function BankBagMixin:GetNumFreeSlots()
    if not self.activeTabID then
        return 0
    end
    local freeSlots = _G.C_Container.GetContainerNumFreeSlots(self.activeTabID)
    return freeSlots or 0
end
function BankBagMixin:UpdateMoneyButtonLockState()
    if not self.withdrawButton or not self.depositButton then return end
    if not self.activeBankType then return end

    local lockedReason = _G.C_Bank.FetchBankLockedReason(self.activeBankType)
    local isLocked = (lockedReason ~= nil)

    self.withdrawButton:SetEnabled(not isLocked)
    self.depositButton:SetEnabled(not isLocked)

    -- Dim the icons when disabled
    if self.withdrawButton.icon then
        if isLocked then
            self.withdrawButton.icon:SetTextColor(0.5, 0.5, 0.5)
        else
            self.withdrawButton.icon:SetTextColor(Color.white:GetRGB())
        end
    end
    if self.depositButton.icon then
        if isLocked then
            self.depositButton.icon:SetTextColor(0.5, 0.5, 0.5)
        else
            self.depositButton.icon:SetTextColor(Color.white:GetRGB())
        end
    end
end
function BankBagMixin:OnEvent(event, ...)
    if event == "BAG_UPDATE" then
        local containerID = ...
        if containerID ~= self.activeTabID then
            return
        end
    elseif event == "BANK_TABS_CHANGED" then
        if self.tabSidebar and self.activeBankType then
            self.tabSidebar:Refresh(self.activeBankType)
        end
        return
    elseif event == "BANK_TAB_SETTINGS_UPDATED" then
        local bankType = ...
        if bankType == self.activeBankType and self.tabSidebar then
            self.tabSidebar:Refresh(self.activeBankType)
        end
        return
    elseif event == "PLAYER_ACCOUNT_BANK_TAB_SLOTS_CHANGED" then
        if self.activeBankType == _G.Enum.BankType.Account then
            self:Update()
        end
        return
    elseif event == "ACCOUNT_MONEY" then
        if self.activeBankType == _G.Enum.BankType.Account and self.moneyFrame then
            _G.MoneyFrame_UpdateMoney(self.moneyFrame)
            self:UpdateMoneyButtonLockState()
        end
        return
    elseif event == "PLAYER_MONEY" then
        if self.activeBankType == _G.Enum.BankType.Character and self.moneyFrame then
            _G.MoneyFrame_UpdateMoney(self.moneyFrame)
            self:UpdateMoneyButtonLockState()
        end
        return
    end

    -- Delegate to parent for all other events and for matching BAG_UPDATE
    MainBagMixin.OnEvent(self, event, ...)
end

-- Deposit filter flags for bank tab settings
local depositFilterFlags = {
    { flag = _G.Enum.BagSlotFlags.ClassEquipment, label = _G.BAG_FILTER_EQUIPMENT },
    { flag = _G.Enum.BagSlotFlags.ClassConsumables, label = _G.BAG_FILTER_CONSUMABLES },
    { flag = _G.Enum.BagSlotFlags.ClassProfessionGoods, label = _G.BAG_FILTER_PROFESSION_GOODS },
    { flag = _G.Enum.BagSlotFlags.ClassJunk, label = _G.BAG_FILTER_JUNK },
    { flag = _G.Enum.BagSlotFlags.ClassQuestItems, label = _G.BAG_FILTER_QUEST_ITEMS },
    { flag = _G.Enum.BagSlotFlags.ClassReagents, label = _G.BAG_FILTER_REAGENTS },
}

-- Common bank tab icons for the icon picker
local BANK_TAB_ICONS = {
    134400,  -- INV_Misc_QuestionMark (default)
    133784,  -- INV_Misc_Bag_07
    133639,  -- INV_Chest_Cloth_17
    132761,  -- INV_Misc_Coin_01
    135725,  -- INV_Misc_Gem_01
    132594,  -- INV_Misc_Food_01
    136243,  -- Trade_Engineering
    134939,  -- Spell_Holy_MagicalSentry
    132997,  -- INV_Misc_Herb_01
    136192,  -- Trade_Alchemy
    132281,  -- Ability_Repair
    133743,  -- INV_Misc_Ammo_Arrow_01
    237274,  -- Garrison_Building_Storehouse
    134532,  -- INV_Misc_Rune_01
    132764,  -- INV_Misc_Coin_17
}

local function CreateIconPickerPopup(menu)
    local popup = _G.CreateFrame("Frame", "$parentIconPicker", menu, "BackdropTemplate")
    local cols = 5
    local rows = 3
    local btnSize = 32
    local padding = 4
    local popupW = cols * (btnSize + padding) + padding
    local popupH = rows * (btnSize + padding) + padding
    popup:SetSize(popupW, popupH)
    popup:SetPoint("TOP", menu, "BOTTOM", 0, -4)
    popup:SetFrameStrata("DIALOG")
    popup:SetToplevel(true)
    popup:EnableMouse(true)
    Base.SetBackdrop(popup, Color.frame)

    popup.buttons = {}
    for i, iconID in ipairs(BANK_TAB_ICONS) do
        local row = math.floor((i - 1) / cols)
        local col = (i - 1) % cols
        local btn = _G.CreateFrame("Button", nil, popup)
        btn:SetSize(btnSize, btnSize)
        btn:SetPoint("TOPLEFT", padding + col * (btnSize + padding), -(padding + row * (btnSize + padding)))

        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints()
        tex:SetTexture(iconID)
        btn.icon = tex

        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, 1, 1, 0.3)

        btn:SetScript("OnClick", function()
            menu.selectedIcon = iconID
            menu.iconDisplay:SetTexture(iconID)
            popup:Hide()
        end)

        popup.buttons[i] = btn
    end

    popup:Hide()
    return popup
end

local function CreateTabSettingsMenu(bankFrame)
    local menu = _G.CreateFrame("Frame", "RealUIBankTabSettings", bankFrame, "BackdropTemplate")
    menu:SetSize(240, 300)
    menu:SetPoint("CENTER", _G.UIParent, "CENTER")
    menu:SetFrameStrata("DIALOG")
    menu:SetToplevel(true)
    menu:EnableMouse(true)
    Base.SetBackdrop(menu, Color.frame)

    -- Title
    local title = menu:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText(_G.BANK_TAB_SETTINGS or "Tab Settings")
    menu.title = title

    -- Icon picker button
    local iconBtn = _G.CreateFrame("Button", "$parentIconBtn", menu)
    iconBtn:SetSize(36, 36)
    iconBtn:SetPoint("TOPLEFT", 15, -32)

    local iconDisplay = iconBtn:CreateTexture(nil, "ARTWORK")
    iconDisplay:SetAllPoints()
    iconDisplay:SetTexture(134400)
    menu.iconDisplay = iconDisplay

    local iconHighlight = iconBtn:CreateTexture(nil, "HIGHLIGHT")
    iconHighlight:SetAllPoints()
    iconHighlight:SetColorTexture(1, 1, 1, 0.2)

    iconBtn:SetScript("OnClick", function()
        if not menu.iconPicker then
            menu.iconPicker = CreateIconPickerPopup(menu)
        end
        if menu.iconPicker:IsShown() then
            menu.iconPicker:Hide()
        else
            menu.iconPicker:Show()
        end
    end)
    menu.iconBtn = iconBtn

    -- Tab name edit box
    local nameLabel = menu:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    nameLabel:SetPoint("LEFT", iconBtn, "RIGHT", 8, 8)
    nameLabel:SetText(_G.NAME or "Name")

    local nameBox = _G.CreateFrame("EditBox", "$parentNameBox", menu, "InputBoxTemplate")
    nameBox:SetSize(168, 20)
    nameBox:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -4)
    nameBox:SetAutoFocus(false)
    nameBox:SetMaxLetters(32)
    Skin.InputBoxTemplate(nameBox)
    menu.nameBox = nameBox

    -- Deposit filter checkboxes (Bug 6 fix: use plain label, not the format string)
    local filterLabel = menu:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    filterLabel:SetPoint("TOPLEFT", 15, -80)
    filterLabel:SetText("Deposit Filters")

    menu.checkboxes = {}
    local lastAnchor = filterLabel
    for i, info in ipairs(depositFilterFlags) do
        local cb = _G.CreateFrame("CheckButton", "$parentFilter" .. i, menu, "UICheckButtonTemplate")
        cb:SetSize(24, 24)
        cb:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", i == 1 and -4 or 0, -2)
        cb.text = cb.text or cb:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        if cb.text then
            cb.text:SetText(info.label)
        end
        -- Use the WoW 12+ Text property if available
        if cb.Text then
            cb.Text:SetText(info.label)
        end
        cb.settingFlag = info.flag
        Skin.UICheckButtonTemplate(cb)
        menu.checkboxes[i] = cb
        lastAnchor = cb
    end

    -- OK / Cancel buttons
    local okBtn = _G.CreateFrame("Button", "$parentOK", menu, "UIPanelButtonTemplate")
    okBtn:SetSize(80, 22)
    okBtn:SetPoint("BOTTOMRIGHT", menu, "BOTTOM", -5, 10)
    okBtn:SetText(_G.OKAY)
    Skin.UIPanelButtonTemplate(okBtn)
    menu.okBtn = okBtn

    local cancelBtn = _G.CreateFrame("Button", "$parentCancel", menu, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80, 22)
    cancelBtn:SetPoint("BOTTOMLEFT", menu, "BOTTOM", 5, 10)
    cancelBtn:SetText(_G.CANCEL)
    Skin.UIPanelButtonTemplate(cancelBtn)
    menu.cancelBtn = cancelBtn

    cancelBtn:SetScript("OnClick", function()
        menu:Hide()
    end)

    okBtn:SetScript("OnClick", function()
        local tabData = menu.tabData
        if not tabData then
            menu:Hide()
            return
        end

        local bankType = tabData.bankType or bankFrame:GetActiveBankType()
        local tabID = tabData.ID
        local tabName = menu.nameBox:GetText() or ""
        local tabIcon = menu.selectedIcon or tabData.icon or 134400

        -- Collect deposit flags from checkboxes
        local depositFlags = 0
        for _, cb in ipairs(menu.checkboxes) do
            if cb.settingFlag and cb:GetChecked() then
                depositFlags = _G.bit.bor(depositFlags, cb.settingFlag)
            end
        end

        _G.C_Bank.UpdateBankTabSettings(bankType, tabID, tabName, tabIcon, depositFlags)
        _G.PlaySound(_G.SOUNDKIT.GS_TITLE_OPTION_OK)
        menu:Hide()
    end)

    menu:SetScript("OnShow", function()
        _G.PlaySound(_G.SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end)
    menu:SetScript("OnHide", function()
        _G.PlaySound(_G.SOUNDKIT.IG_CHARACTER_INFO_TAB)
        if menu.iconPicker then
            menu.iconPicker:Hide()
        end
    end)

    menu:Hide()
    return menu
end

function BankBagMixin:OnTabSettingsRequested(tabID)
    if not self.activeBankType then return end

    -- Fetch current tab data
    local purchasedTabs = _G.C_Bank.FetchPurchasedBankTabData(self.activeBankType)
    if not purchasedTabs then return end

    local tabData
    for _, td in ipairs(purchasedTabs) do
        if td.ID == tabID then
            tabData = td
            break
        end
    end
    if not tabData then return end

    -- Lazily create the settings menu
    if not self.tabSettingsMenu then
        self.tabSettingsMenu = CreateTabSettingsMenu(self)
    end

    local menu = self.tabSettingsMenu
    tabData.bankType = self.activeBankType
    menu.tabData = tabData

    -- Populate name
    menu.nameBox:SetText(tabData.name or "")
    menu.nameBox:HighlightText()

    -- Populate icon picker with current tab icon
    local currentIcon = tabData.icon or 134400
    menu.selectedIcon = currentIcon
    menu.iconDisplay:SetTexture(currentIcon)

    -- Populate deposit filter checkboxes from tabData.depositFlags
    local currentFlags = tabData.depositFlags or 0
    for _, cb in ipairs(menu.checkboxes) do
        if cb.settingFlag then
            cb:SetChecked(_G.bit.band(currentFlags, cb.settingFlag) ~= 0)
        end
    end

    menu:Show()
end

private.bankTypeConfig = {
    [_G.Enum.BankType.Character] = {
        tabRange = {
            _G.Enum.BagIndex.CharacterBankTab_1,
            _G.Enum.BagIndex.CharacterBankTab_2,
            _G.Enum.BagIndex.CharacterBankTab_3,
            _G.Enum.BagIndex.CharacterBankTab_4,
            _G.Enum.BagIndex.CharacterBankTab_5,
            _G.Enum.BagIndex.CharacterBankTab_6,
        },
        sortFunc = function() _G.C_Container.SortBankBags() end,
        supportsAutoDeposit = false,
    },
    [_G.Enum.BankType.Account] = {
        tabRange = {
            _G.Enum.BagIndex.AccountBankTab_1,
            _G.Enum.BagIndex.AccountBankTab_2,
            _G.Enum.BagIndex.AccountBankTab_3,
            _G.Enum.BagIndex.AccountBankTab_4,
            _G.Enum.BagIndex.AccountBankTab_5,
        },
        sortFunc = function() _G.C_Container.SortAccountBankBags() end,
        supportsAutoDeposit = true,
    },
}

-- Static popup for bank sort confirmation (replaces Blizzard's BankCleanUpConfirmationPopup
-- which depends on BankPanelSystemMixin and the suppressed BankFrame)
_G.StaticPopupDialogs["REALUI_BANK_SORT_CONFIRM"] = {
    text = _G.BANK_CONFIRM_CLEANUP_PROMPT or "Are you sure you want to sort this bank tab?",
    button1 = _G.OKAY,
    button2 = _G.CANCEL,
    OnAccept = function(self, data)
        local config = data and private.bankTypeConfig[data.bankType]
        if config then
            _G.PlaySound(_G.SOUNDKIT.UI_BAG_SORTING_01)
            config.sortFunc()
        end
    end,
    hasItemFrame = false,
    timeout = 0,
    whileDead = false,
    hideOnEscape = true,
    preferredIndex = 3,
}

local TAB_BUTTON_SIZE = 37
local TAB_BUTTON_SPACING = 5

local TabSidebarMixin = {}
function TabSidebarMixin:Init(bankFrame)
    self.bankFrame = bankFrame
    self.tabButtons = {}
    self.selectedTabID = nil

    -- Purchase button — uses Blizzard's BankPanelPurchaseButtonScriptTemplate
    -- so the OnClick calls StaticPopup_Show("CONFIRM_BUY_BANK_TAB") from
    -- Blizzard's secure code path, avoiding ADDON_ACTION_FORBIDDEN taint.
    local purchaseBtn = _G.CreateFrame("Button", "RealUIBankPurchaseTabBtn", bankFrame, "BankPanelPurchaseButtonScriptTemplate")
    purchaseBtn:SetSize(TAB_BUTTON_SIZE, TAB_BUTTON_SIZE)
    Base.CreateBackdrop(purchaseBtn, {
        bgFile = [[Interface\PaperDoll\UI-Backpack-EmptySlot]],
        tile = false,
        offsets = { left = -1, right = -1, top = -1, bottom = -1 },
    })
    Base.CropIcon(purchaseBtn:GetBackdropTexture("bg"))
    purchaseBtn:SetBackdropColor(0.2, 0.8, 0.2, 0.5)
    purchaseBtn:SetBackdropBorderColor(Color.frame:GetRGB())

    local plusIcon = purchaseBtn:CreateFontString(nil, "ARTWORK")
    plusIcon:SetPoint("CENTER")
    plusIcon:SetFont(fa.path, 20, "")
    plusIcon:SetText(fa["plus"])
    plusIcon:SetTextColor(Color.white:GetRGB())
    purchaseBtn.icon = plusIcon

    purchaseBtn:RegisterForClicks("LeftButtonUp")
    -- PreClick sets the overrideBankType attribute so the Blizzard mixin
    -- knows which bank type to purchase a tab for.
    purchaseBtn:SetScript("PreClick", function(btn)
        local bankType2 = bankFrame:GetActiveBankType()
        btn:SetAttribute("overrideBankType", bankType2)
    end)
    -- PostClick refreshes our sidebar after the purchase popup is shown
    purchaseBtn:SetScript("PostClick", function()
        -- The popup is now shown; when the user confirms and BANK_TABS_CHANGED
        -- fires, BankBagMixin:OnEvent will refresh the sidebar automatically.
    end)
    purchaseBtn:SetScript("OnEnter", function(btn)
        local bankType = bankFrame:GetActiveBankType()
        if not bankType then return end
        local tabData = _G.C_Bank.FetchNextPurchasableBankTabData(bankType)
        _G.GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
        if tabData then
            _G.GameTooltip_SetTitle(_G.GameTooltip, tabData.purchasePromptTitle, nil, true)
            _G.GameTooltip_AddNormalLine(_G.GameTooltip, _G.GetMoneyString(tabData.tabCost, true))
        end
        _G.GameTooltip:Show()
    end)
    purchaseBtn:SetScript("OnLeave", _G.GameTooltip_Hide)
    purchaseBtn:Hide()
    self.purchaseButton = purchaseBtn
end
function TabSidebarMixin:Refresh(bankType)
    -- Hide all existing tab buttons
    for _, btn in ipairs(self.tabButtons) do
        btn:Hide()
    end

    if not bankType then return end

    local purchasedTabs = _G.C_Bank.FetchPurchasedBankTabData(bankType)
    if not purchasedTabs then purchasedTabs = {} end
    local lastButton

    for i, tabData in ipairs(purchasedTabs) do
        local btn = self.tabButtons[i]
        if not btn then
            btn = _G.CreateFrame("Button", nil, self.bankFrame)
            btn:SetSize(TAB_BUTTON_SIZE, TAB_BUTTON_SIZE)
            Base.CreateBackdrop(btn, {
                bgFile = [[Interface\PaperDoll\UI-Backpack-EmptySlot]],
                tile = false,
                offsets = { left = -1, right = -1, top = -1, bottom = -1 },
            })
            Base.CropIcon(btn:GetBackdropTexture("bg"))
            btn:SetBackdropBorderColor(Color.frame:GetRGB())

            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(btn:GetBackdropTexture("bg"))
            btn.tabIcon = icon

            btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            btn:SetScript("OnClick", function(b, button)
                if button == "RightButton" and b.tabData then
                    -- Right-click opens tab settings (task 9)
                    if self.bankFrame.OnTabSettingsRequested then
                        self.bankFrame:OnTabSettingsRequested(b.tabData.ID)
                    end
                else
                    self:SelectTab(b.tabData.ID)
                end
            end)
            btn:SetScript("OnEnter", function(b)
                if not b.tabData then return end
                _G.GameTooltip:SetOwner(b, "ANCHOR_LEFT")
                _G.GameTooltip_SetTitle(_G.GameTooltip, b.tabData.name, nil, true)
                _G.GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", _G.GameTooltip_Hide)

            self.tabButtons[i] = btn
        end

        btn.tabData = tabData
        btn.tabIcon:SetTexture(tabData.icon or _G.QUESTION_MARK_ICON)
        Base.CropIcon(btn.tabIcon)

        if not lastButton then
            btn:SetPoint("TOPRIGHT", self.bankFrame, "TOPLEFT", -TAB_BUTTON_SPACING, -30)
        else
            btn:SetPoint("TOP", lastButton, "BOTTOM", 0, -TAB_BUTTON_SPACING)
        end

        btn:Show()
        lastButton = btn
    end

    -- Purchase button
    self:AddPurchaseButton(bankType, lastButton)

    -- Auto-select first purchased tab if current selection is invalid
    if #purchasedTabs > 0 then
        -- Hide empty-state label if it was shown
        if self.emptyLabel then
            self.emptyLabel:Hide()
        end

        local currentValid = false
        if self.selectedTabID then
            for _, td in ipairs(purchasedTabs) do
                if td.ID == self.selectedTabID then
                    currentValid = true
                    break
                end
            end
        end
        if not currentValid then
            self:SelectTab(purchasedTabs[1].ID)
        else
            self:UpdateHighlight()
        end
    else
        self.selectedTabID = nil
        self.bankFrame:SetActiveTab(nil)

        -- No tabs purchased: show a hint inside the bank frame
        if not self.emptyLabel then
            local label = self.bankFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            label:SetPoint("CENTER", self.bankFrame, "CENTER", 0, 0)
            label:SetWidth(200)
            label:SetJustifyH("CENTER")
            self.emptyLabel = label
        end
        if not _G.C_Bank.HasMaxBankTabs(bankType) then
            self.emptyLabel:SetText(_G.BANKSLOTPURCHASE_LABEL or "Purchase Bank Tab")
            self.emptyLabel:Show()
        end
    end
end
function TabSidebarMixin:AddPurchaseButton(bankType, lastButton)
    if _G.C_Bank.HasMaxBankTabs(bankType) then
        self.purchaseButton:Hide()
        return
    end

    if not lastButton then
        self.purchaseButton:SetPoint("TOPRIGHT", self.bankFrame, "TOPLEFT", -TAB_BUTTON_SPACING, -30)
    else
        self.purchaseButton:SetPoint("TOP", lastButton, "BOTTOM", 0, -TAB_BUTTON_SPACING)
    end
    self.purchaseButton:Show()
end
function TabSidebarMixin:SelectTab(tabID)
    if self.selectedTabID == tabID then return end
    self.selectedTabID = tabID
    self:UpdateHighlight()
    self.bankFrame:SetActiveTab(tabID)
end
function TabSidebarMixin:GetSelectedTabID()
    return self.selectedTabID
end
function TabSidebarMixin:UpdateHighlight()
    for _, btn in ipairs(self.tabButtons) do
        if btn:IsShown() and btn.tabData then
            if btn.tabData.ID == self.selectedTabID then
                btn:SetBackdropBorderColor(Color.highlight:GetRGB())
            else
                btn:SetBackdropBorderColor(Color.frame:GetRGB())
            end
        end
    end
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
    button:SetScript("OnEnter", function(dialog)
        if dialog.icon then
            dialog.icon:SetTextColor(Color.highlight:GetRGB())
        else
            dialog.texture:SetVertexColor(Color.highlight:GetRGB())
        end

        if onEnter then
            onEnter(dialog)
        end
    end)
    button:SetScript("OnLeave", function(dialog)
        if dialog.icon then
            dialog.icon:SetTextColor(Color.white:GetRGB())
        else
            dialog.texture:SetVertexColor(Color.white:GetRGB())
        end
        _G.GameTooltip_Hide()
    end)

    return button
end

local BankTypeSwitcherMixin = {}
function BankTypeSwitcherMixin:Init(bankFrame)
    self.bankFrame = bankFrame
    self.buttons = {}

    local bankTypes = {
        { type = _G.Enum.BankType.Character, icon = "user", label = "Character" },
        { type = _G.Enum.BankType.Account, icon = "users", label = "Warband" },
    }

    local prevButton
    for _, info in ipairs(bankTypes) do
        local btn = CreateFeatureButton(bankFrame, info.label, info.icon,
        function()
            self:SetActiveType(info.type)
        end)
        btn.bankType = info.type

        if not prevButton then
            btn:SetPoint("BOTTOMLEFT", bankFrame.searchButton, "TOPLEFT", 0, 5)
        else
            btn:SetPoint("LEFT", prevButton.text, "RIGHT", 10, 0)
        end

        self.buttons[info.type] = btn
        prevButton = btn
    end
end
function BankTypeSwitcherMixin:Refresh()
    local firstAvailable
    for bankType, btn in next, self.buttons do
        local canView = _G.C_Bank.CanViewBank(bankType)
        if canView then
            btn:Show()
            if not firstAvailable then
                firstAvailable = bankType
            end
        else
            btn:Hide()
        end
    end

    if firstAvailable then
        self:SetActiveType(firstAvailable)
    end
end
function BankTypeSwitcherMixin:SetActiveType(bankType)
    self.activeType = bankType

    for bt, btn in next, self.buttons do
        if bt == bankType then
            btn.icon:SetTextColor(Color.highlight:GetRGB())
        else
            btn.icon:SetTextColor(Color.white:GetRGB())
        end
    end

    self.bankFrame:SetBankType(bankType)
end
function BankTypeSwitcherMixin:GetActiveType()
    return self.activeType
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
    local bagSlotParent = private.bagSlots[main.bagType][bagID] or main
    slot:SetParent(bagSlotParent)

    main:AddContinuable(slot.item)
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
        bag.resetNew = CreateFeatureButton(bag, _G.RESET, "check", function(dialog)
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
        function(dialog)
            _G.GameTooltip:SetOwner(dialog, "ANCHOR_LEFT")
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
        bagIDs = {_G.Enum.BagIndex.Backpack, _G.Enum.BagIndex.Bag_1, _G.Enum.BagIndex.Bag_2, _G.Enum.BagIndex.Bag_3, _G.Enum.BagIndex.Bag_4, _G.Enum.BagIndex.ReagentBag}, -- BACKPACK_CONTAINER through NUM_TOTAL_EQUIPPED_BAG_SLOTS
    },
    bank = {
        name = "RealUIBank",
        mixin = BankBagMixin,
        bagIDs = {}, -- Dynamic: set when a tab is selected via BankBagMixin:SetActiveTab()
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
    function(dialog, button)
        if bagType == "bank" and button == "RightButton" then
            -- Tab purchasing is handled by the sidebar "+" button which uses
            -- Blizzard's BankPanelPurchaseButtonScriptTemplate for taint-free
            -- secure purchase flow. Nothing to do here on right-click.
            return
        else
            dialog:ToggleBags()
        end
    end,
    function(dialog)
        if bagType == "bank" then
            local bankType2 = main:GetActiveBankType()
            if not bankType2 then return end
            _G.GameTooltip:SetOwner(dialog, "ANCHOR_BOTTOMRIGHT")
            if _G.C_Bank.HasMaxBankTabs(bankType2) then
                _G.GameTooltip_SetTitle(_G.GameTooltip, _G.BANKSLOTPURCHASE_LABEL, nil, true)
                _G.GameTooltip_AddNormalLine(_G.GameTooltip, _G.BANK_ALL_TABS_PURCHASED or "All bank tabs purchased")
            else
                local tabData = _G.C_Bank.FetchNextPurchasableBankTabData(bankType2)
                if tabData then
                    _G.GameTooltip_SetTitle(_G.GameTooltip, tabData.purchasePromptTitle or _G.BANKSLOTPURCHASE_LABEL, nil, true)
                    local costText = _G.GetMoneyString(tabData.tabCost, true)
                    if _G.GetMoney() >= tabData.tabCost then
                        _G.GameTooltip_AddNormalLine(_G.GameTooltip, costText)
                    else
                        _G.GameTooltip_AddErrorLine(_G.GameTooltip, costText)
                    end
                end
            end
            _G.GameTooltip:Show()
        end
    end)

    showBags:SetPoint("TOPLEFT", 5, -5)
    function showBags:ToggleBags(show)
        if show == nil then
            show = not self.isShowing
        end

        local firstBag = _G.BACKPACK_CONTAINER
        if bagType == "bank" then
            firstBag = _G.Enum.BagIndex.CharacterBankTab_1 -- _G.BANK_CONTAINER
        end


        local bagSlots = private.bagSlots[bagType]
        if show then
            self:SetText("")
            self:SetHitRectInsets(-5, -5, -5, -5)

            if bagSlots[firstBag] then
                bagSlots[firstBag]:SetPoint("TOPLEFT", main.showBags, "TOPRIGHT", 5, 0)
            end
            for k, bagID in main:IterateBagIDs() do
                if bagSlots[bagID] then
                    bagSlots[bagID]:Update()
                end
            end
        else
            self:SetText(_G.BAGSLOTTEXT)
            self:SetHitRectInsets(-5, -50, -5, -5)

            if bagSlots[firstBag] then
                bagSlots[firstBag]:SetPoint("TOPLEFT", _G.UIParent, "TOPRIGHT", 5, 0)
            end
            for k, bagID in main:IterateBagIDs() do
                if bagSlots[bagID] then
                    bagSlots[bagID]:Update()
                end
            end

            if bagSlots[firstBag] then
                private.SearchItemsForBag(firstBag)
            end
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
        function(dialog)
            RealUI.LoadConfig("RealUI", "inventory")
        end,
        function(dialog)
            _G.GameTooltip:SetOwner(dialog, "ANCHOR_LEFT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, _G.SETTINGS, nil, true)

            _G.GameTooltip:Show()
        end)

        settingsButton:SetPoint("TOPRIGHT", close:GetBackdropTexture("bg"), "TOPLEFT", -5, 0)
        main.settingsButton = settingsButton

        local restackButton = CreateFeatureButton(main, nil, "repeat",
        function(dialog)
            _G.PlaySound(_G.SOUNDKIT.UI_BAG_SORTING_01)
            _G.C_Container.SortBags()
        end,
        function(dialog)
            _G.GameTooltip:SetOwner(dialog, "ANCHOR_LEFT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, L.Inventory_Restack, nil, true)

            _G.GameTooltip:Show()
        end)

        restackButton:SetPoint("TOPRIGHT", settingsButton, "TOPLEFT", -5, 0)
        main.restackButton = restackButton
    end
    if bagType == "bank" then
        local deposit = CreateFeatureButton(main, nil, "download",
        function()
            _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION)
            if _G.C_Bank.HasRefundableItemsInBags() then
                _G.StaticPopup_Show("ACCOUNT_BANK_DEPOSIT_ALL_NO_REFUND_CONFIRM")
            else
                _G.C_Bank.AutoDepositItemsIntoBank(_G.Enum.BankType.Account)
            end
        end,
        function(dialog)
            _G.GameTooltip:SetOwner(dialog, "ANCHOR_BOTTOMRIGHT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, _G.ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL or "Deposit Warbound Items", nil, true)
            _G.GameTooltip:Show()
        end)

        deposit:SetPoint("TOPRIGHT", close:GetBackdropTexture("bg"), "TOPLEFT", -5, 0)
        deposit:Hide() -- Hidden by default; shown when Warband Bank is active
        main.deposit = deposit

        local restackButton = CreateFeatureButton(main, nil, "repeat",
        function(dialog)
            local bankType = main:GetActiveBankType()
            local config = bankType and private.bankTypeConfig[bankType]
            if not config then return end

            -- Warband Bank: check bankConfirmTabCleanUp CVar before sorting
            if bankType == _G.Enum.BankType.Account and _G.GetCVarBool("bankConfirmTabCleanUp") then
                _G.StaticPopup_Show("REALUI_BANK_SORT_CONFIRM", nil, nil, { bankType = bankType })
                return
            end

            _G.PlaySound(_G.SOUNDKIT.UI_BAG_SORTING_01)
            config.sortFunc()
        end,
        function(dialog)
            _G.GameTooltip:SetOwner(dialog, "ANCHOR_LEFT")
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
    _G.hooksecurefunc(searchBox, "ClearFocus", function(dialog)
        dialog:Hide()
        main.moneyFrame:Show()
        main.searchButton:Show()
    end)
    Skin.BagSearchBoxTemplate(searchBox)
    main.searchBox = searchBox

    local searchButton = CreateFeatureButton(main, _G.SEARCH, "common-search-magnifyingglass",
    function(dialog)
        dialog:Hide()
        main.moneyFrame:Hide()
        main.searchBox:Show()
        main.searchBox:SetFocus()
    end)
    searchButton:SetPoint("TOPLEFT", searchBox, 0, -3)
    searchButton.texture:SetSize(10, 10)
    searchButton.text:SetPoint("LEFT", searchButton, "RIGHT", 1, 1)
    main.searchButton = searchButton

    -- Create bank type switcher and tab sidebar AFTER searchButton exists,
    -- so BankTypeSwitcherMixin can anchor to bankFrame.searchButton
    if bagType == "bank" then
        local bankTypeSwitcher = _G.CreateFrame("Frame", nil, main)
        _G.Mixin(bankTypeSwitcher, BankTypeSwitcherMixin)
        bankTypeSwitcher:Init(main)
        main.bankTypeSwitcher = bankTypeSwitcher

        local tabSidebar = _G.CreateFrame("Frame", nil, main)
        _G.Mixin(tabSidebar, TabSidebarMixin)
        tabSidebar:Init(main)
        main.tabSidebar = tabSidebar
    end

    local moneyFrame = _G.CreateFrame("Frame", "$parentMoney", main, "SmallMoneyFrameTemplate")
    moneyFrame:SetPoint("BOTTOMRIGHT", 8, 8)
    main.moneyFrame = moneyFrame
    main.marginBottom = main.marginBottom + 25

    if bagType == "bank" then
        local withdrawButton = CreateFeatureButton(main, nil, "arrow-up",
        function()
            _G.StaticPopup_Show("BANK_MONEY_WITHDRAW")
        end,
        function(dialog)
            _G.GameTooltip:SetOwner(dialog, "ANCHOR_LEFT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, _G.BANK_WITHDRAW or "Withdraw", nil, true)
            _G.GameTooltip:Show()
        end)
        withdrawButton:SetPoint("RIGHT", moneyFrame, "LEFT", -4, 0)
        withdrawButton:Hide()
        main.withdrawButton = withdrawButton

        local depositButton = CreateFeatureButton(main, nil, "arrow-down",
        function()
            _G.StaticPopup_Show("BANK_MONEY_DEPOSIT")
        end,
        function(dialog)
            _G.GameTooltip:SetOwner(dialog, "ANCHOR_LEFT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, _G.BANK_DEPOSIT or "Deposit", nil, true)
            _G.GameTooltip:Show()
        end)
        depositButton:SetPoint("RIGHT", withdrawButton, "LEFT", -4, 0)
        depositButton:Hide()
        main.depositButton = depositButton
    end

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
