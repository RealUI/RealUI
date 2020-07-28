local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs next type

-- Libs --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin

-- RealUI --
local RealUI = _G.RealUI
local Inventory = private.Inventory

local function SlotFactory(pool)
    local numActive = pool:GetNumActive()
    local slot = _G.CreateFrame("ItemButton", "$parent_Slot"..numActive, _G[pool.parent], pool.frameTemplate)
    _G.Mixin(slot, pool.mixin)
    slot:OnLoad()
    return slot
end
local function SlotReset(pool, slot)
    slot:ClearAllPoints()
    slot:Hide()

    if slot.cancel then
        slot.cancel()
    end
    slot.item = nil
    slot:Clear()
end

--[[ Item Slots ]]--
local ItemSlotMixin = _G.CreateFromMixins(_G.ItemLocationMixin)
function ItemSlotMixin:OnLoad()
    self:HookScript("OnClick", self.OnClick)
end
function ItemSlotMixin:Update()
    local bagID, slotIndex = self:GetBagAndSlot()
    local item = self.item

    local _, itemCount, _, _, readable = _G.GetContainerItemInfo(bagID, slotIndex)
    local isQuestItem, questId, isActive = _G.GetContainerItemQuestInfo(bagID, slotIndex)

    local icon = item:GetItemIcon()
    local quality = item:GetItemQuality()
    _G.SetItemButtonTexture(self, icon)
    _G.SetItemButtonQuality(self, quality, item:GetItemLink())
    _G.SetItemButtonCount(self, itemCount)
    _G.SetItemButtonDesaturated(self, item:IsItemLocked())

    if Inventory.main.bags.equipment.filter:DoesMatchSlot(self) then
        self.Count:SetText(self.item:GetCurrentItemLevel())
        if quality and quality > RealUI.Enum.ItemQuality.Poor then
            self.Count:SetTextColor(_G.BAG_ITEM_QUALITY_COLORS[quality]:GetRGB())
        end
        self.Count:Show()
    end

    local questTexture = self.IconQuestTexture
    if questId then
        self._auroraIconBorder:SetBackdropBorderColor(1, 1, 0)
        if not isActive then
            questTexture:SetTexture(_G.TEXTURE_ITEM_QUEST_BANG)
            questTexture:Show()
        elseif isQuestItem then
            questTexture:SetTexture(_G.TEXTURE_ITEM_QUEST_BORDER)
            questTexture:Show()
        end
    else
        questTexture:Hide()
    end

    self:UpdateItemCooldown()
    self.readable = readable

    if self == _G.GameTooltip:GetOwner() then
        self:UpdateTooltip()
    end

    self:UpdateItemContext()
end
function ItemSlotMixin:UpdateItemCooldown()
    _G[self:GetName().."Cooldown"]:Hide()
    _G.ContainerFrame_UpdateCooldown((self:GetBagAndSlot()), self)
end
function ItemSlotMixin:UpdateItemContext()
    local _, _, _, _, _, _, _, isFiltered = _G.GetContainerItemInfo(self:GetBagAndSlot())
    self:UpdateItemContextMatching()
    self:SetMatchesSearch(not isFiltered)
end
function ItemSlotMixin:GetBagType()
    return private.GetBagTypeForBagID(self:GetBagAndSlot())
end
function ItemSlotMixin:OnClick(button)
    if button == "RightButton" and _G.IsAltKeyDown() and _G.IsControlKeyDown() then
        private.menu:Open(self)
    end
end


local InventorySlotMixin = _G.CreateFromMixins(ItemSlotMixin)
function InventorySlotMixin:OnLoad()
    ItemSlotMixin.OnLoad(self)

    self.IconQuestTexture = _G[self:GetName().."IconQuestTexture"]
end
function InventorySlotMixin:Update()
    ItemSlotMixin.Update(self)

    self:UpdateItemUpgradeIcon()
    self.BattlepayItemTexture:SetShown(_G.IsBattlePayItem(self:GetBagAndSlot()))
end
function InventorySlotMixin:UpdateItemUpgradeIcon()
    _G.ContainerFrameItemButton_UpdateItemUpgradeIcon(self)
end
local inventorySlots = _G.CreateObjectPool(SlotFactory, SlotReset)
inventorySlots.frameTemplate = "ContainerFrameItemButtonTemplate"
inventorySlots.parent = "RealUIInventory"
inventorySlots.mixin = InventorySlotMixin


local BankSlotMixin = _G.CreateFromMixins(ItemSlotMixin)
function BankSlotMixin:Update()
    ItemSlotMixin.Update(self)

    _G.BankFrameItemButton_UpdateLocked(self)
end
local bankSlots = _G.CreateObjectPool(SlotFactory, SlotReset)
bankSlots.frameTemplate = "BankItemButtonGenericTemplate"
bankSlots.parent = "RealUIBank"
bankSlots.mixin = BankSlotMixin


local ReagentSlotMixin = _G.CreateFromMixins(ItemSlotMixin)
function ReagentSlotMixin:Update()
    ItemSlotMixin.Update(self)

    _G.BankFrameItemButton_UpdateLocked(self)
end
local reagentSlots = _G.CreateObjectPool(SlotFactory, SlotReset)
reagentSlots.frameTemplate = "ReagentBankItemButtonGenericTemplate"
reagentSlots.parent = "RealUIReagent"
reagentSlots.mixin = ReagentSlotMixin


function private.UpdateSlots(bagID)
    Inventory:debug("private.UpdateSlots", bagID)
    for slotIndex = 1, _G.GetContainerNumSlots(bagID) do
        local slot = private.GetSlot(bagID, slotIndex)
        if slot then
            slot.cancel = slot.item:ContinueWithCancelOnItemLoad(function()
                slot:Update()
                private.AddSlotToBag(slot, bagID)
            end)
            slot:Show()
        end
    end
end

function private.GetSlot(bagID, slotIndex)
    --Inventory:debug("private.GetSlot", bagID, slotIndex)
    local slots = private.GetSlotTypeForBag(bagID)

    for slot in slots:EnumerateActive() do
        if slot:IsEqualToBagAndSlot(bagID, slotIndex) then
            if slot:IsValid() then
                return slot
            else
                slots:Release(slot)
                return
            end
        end
    end

    local slot = slots:Acquire()
    slot:SetBagAndSlot(bagID, slotIndex)
    if slot:IsValid() then
        slot:SetID(slotIndex)
        slot.item = _G.Item:CreateFromItemLocation(slot)
        return slot
    else
        slots:Release(slot)
    end
end

function private.GetFirstFreeSlot(bagID)
    if _G.GetContainerNumFreeSlots(bagID) > 0 then
        local numSlots = _G.GetContainerNumSlots(bagID)
        for slotIndex = 1, numSlots do
            if not _G.GetContainerItemLink(bagID, slotIndex) then
                return slotIndex
            end
        end
    end
end

function private.GetSlotTypeForBag(bagIDorBagType)
    local slots = inventorySlots

    if type(bagIDorBagType) == "number" then
        if bagIDorBagType == _G.BANK_CONTAINER then
            slots = bankSlots
        elseif bagIDorBagType == _G.REAGENTBANK_CONTAINER then
            slots = reagentSlots
        end
    else
        if bagIDorBagType == "bank" then
            slots = bankSlots
        elseif bagIDorBagType == "reagent" then
            slots = reagentSlots
        end
    end

    return slots
end

--[[ Bag Slots ]]--
local searchBags = {}
local function SearchItemsForBag(bagType)
    local slots = private.GetSlotTypeForBag(bagType)

    for slot in slots:EnumerateActive() do
        slot:SetMatchesSearch(searchBags[(slot:GetBagAndSlot())])
    end
end
private.SearchItemsForBag = SearchItemsForBag

local mainBags = {
    [_G.BACKPACK_CONTAINER] = _G.BACKPACK_TOOLTIP,
    [_G.BANK_CONTAINER] = _G.BANK,
    [_G.REAGENTBANK_CONTAINER] = _G.REAGENT_BANK,
}
local BagSlotMixin = {}
function BagSlotMixin:Init(bagID)
    self:SetID(bagID)
    self:SetSize(20, 20)
    self:SetFrameLevel(5)

    local highlight = self:CreateTexture(nil, "OVERLAY")
    highlight:SetAllPoints()
    highlight:SetBlendMode("ADD")
    highlight:SetTexture([[Interface\Buttons\CheckButtonHilight]])
    Base.CropIcon(highlight)
    self.highlight = highlight

    self:RegisterForDrag("LeftButton")
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("INVENTORY_SEARCH_UPDATE")
    self:SetScript("OnEvent", self.OnEvent)
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", self.OnLeave)
    self:SetScript("OnClick", self.OnClick)
    self:SetScript("OnDragStart", self.OnDragStart)
    self:SetScript("OnReceiveDrag", self.OnReceiveDrag)

    self.bagType = private.GetBagTypeForBagID(bagID)
    self.isBag = not mainBags[bagID]

    Skin.FrameTypeItemButton(self)
    if self.isBag then
        if self.bagType == "main" then
            self.inventorySlot = "Bag"..(bagID - 1).."Slot"

            self.inventoryID, self.fallbackTexture = _G.GetInventorySlotInfo(self.inventorySlot)
        else
            local slotID = bagID - _G.NUM_BAG_SLOTS
            self.inventorySlot = "Bag"..slotID

            self.inventoryID, self.fallbackTexture = _G.GetInventorySlotInfo(self.inventorySlot)
            self.inventoryID = _G.BankButtonIDToInvSlotID(slotID, 1)

            self.bankSlotID = slotID
        end
    else
        self.fallbackTexture = [[Interface\Buttons\Button-Backpack-Up]]
    end

    _G.SetItemButtonTexture(self, self.fallbackTexture)
end
function BagSlotMixin:GetItemContextMatchResult()
    return _G.ItemButtonUtil.GetItemContextMatchResultForContainer(self:GetID())
end
function BagSlotMixin:Update()
    if self.isBag then
        local textureName = _G.GetInventoryItemTexture("player", self.inventoryID)
        _G.SetItemButtonTexture(self, textureName or self.fallbackTexture)

        local quality = _G.GetInventoryItemQuality("player", self.inventoryID)
        _G.SetItemButtonQuality(self, quality, _G.GetInventoryItemID("player", self.inventoryID), true)

        if self.bagType == "bank" then
            if self.bankSlotID <= _G.GetNumBankSlots() then
                _G.SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0)
                self.tooltipText = _G.BANK_BAG
            else
                _G.SetItemButtonTextureVertexColor(self, 1.0, 0.1, 0.1)
                self.tooltipText = _G.BANK_BAG_PURCHASE
            end
        else
            self.tooltipText = _G.EQUIP_CONTAINER
        end
    else
        self.tooltipText = mainBags[self:GetID()]
    end

    searchBags[self:GetID()] = true
    self.highlight:Show()
    self:UpdateItemContextMatching()
end

function BagSlotMixin:OnEvent(event, ...)
    if event == "INVENTORY_SEARCH_UPDATE" then
        self:SetMatchesSearch(not _G.IsContainerFiltered(self:GetID()))
    else
        self:Update()
    end
end
function BagSlotMixin:OnEnter()
    _G.GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    local hasItem = self.inventoryID and _G.GameTooltip:SetInventoryItem("player", self.inventoryID)
    if not hasItem then
        _G.GameTooltip:SetText(self.tooltipText, 1.0, 1.0, 1.0)
    end

    _G.GameTooltip:Show()
end
function BagSlotMixin:OnLeave()
    _G.GameTooltip:Hide()
    _G.ResetCursor()
end
function BagSlotMixin:OnClick(button)
    local hadItem = self.isBag and _G.PutItemInBag(self.inventoryID)
    local needsPurchase = self.bankSlotID and self.bankSlotID > _G.GetNumBankSlots()
    if not hadItem and not needsPurchase then
        if self.highlight:IsShown() then
            searchBags[self:GetID()] = false
            self.highlight:Hide()
        else
            searchBags[self:GetID()] = true
            self.highlight:Show()
        end

        SearchItemsForBag(self.bagType)
    end
end
function BagSlotMixin:OnDragStart()
    if self.inventoryID then
        _G.PickupBagFromSlot(self.inventoryID)
    end
end
function BagSlotMixin:OnReceiveDrag()
    self:OnClick()
end

private.bagSlots = {}
function private.CreateBagSlots(main)
    Inventory:debug("private.CreateBagSlots", main.bagType)
    local bagSlots, bagType = private.bagSlots, main.bagType
    bagSlots[bagType] = {}

    local bagSlot, previousButton
    for k, bagID in main:IterateBagIDs() do
        bagSlot = _G.CreateFrame("ItemButton", "$parent_Bag"..bagID, main)
        _G.Mixin(bagSlot, BagSlotMixin)
        bagSlot:Init(bagID)

        if previousButton then
            bagSlot:SetPoint("TOPLEFT", previousButton, "TOPRIGHT", 5, 0)
        end

        previousButton = bagSlot
        bagSlots[bagType][bagID] = bagSlot
    end
end
