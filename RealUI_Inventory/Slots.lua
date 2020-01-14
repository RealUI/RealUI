local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs next

-- RealUI --
--local Inventory = private.Inventory

local function SlotReset(pool, slot)
    slot:ClearAllPoints()
    slot:Hide()

    if slot.cancel then
        slot.cancel()
    end
    slot.item = nil
    slot:Clear()
end

local InventoryItemMixin = _G.CreateFromMixins(_G.ItemLocationMixin)
function InventoryItemMixin:Update()
    local bagID, slotIndex = self:GetBagAndSlot()
    local item = self.item

    local _, itemCount, _, _, readable, _, _, isFiltered, noValue = _G.GetContainerItemInfo(bagID, slotIndex)
    local isQuestItem, questId, isActive = _G.GetContainerItemQuestInfo(bagID, slotIndex)

    local icon = item:GetItemIcon()
    local quality = item:GetItemQuality()
    _G.SetItemButtonTexture(self, icon)
    _G.SetItemButtonQuality(self, quality, item:GetItemLink())
    _G.SetItemButtonCount(self, itemCount)
    _G.SetItemButtonDesaturated(self, item:IsItemLocked())

    local questTexture = _G[self:GetName().."IconQuestTexture"]
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

    local isNewItem = _G.C_NewItems.IsNewItem(bagID, slotIndex)
    local isBattlePayItem = _G.IsBattlePayItem(bagID, slotIndex)

    local battlepayItemTexture = self.BattlepayItemTexture
    local newItemTexture = self.NewItemTexture
    local flash = self.flashAnim
    local newItemAnim = self.newitemglowAnim

    if isNewItem then
        if isBattlePayItem then
            newItemTexture:Hide()
            battlepayItemTexture:Show()
        else
            if (quality and _G.NEW_ITEM_ATLAS_BY_QUALITY[quality]) then
                newItemTexture:SetAtlas(_G.NEW_ITEM_ATLAS_BY_QUALITY[quality])
            else
                newItemTexture:SetAtlas("bags-glow-white")
            end
            battlepayItemTexture:Hide()
            newItemTexture:Show()
        end
        if (not flash:IsPlaying() and not newItemAnim:IsPlaying()) then
            flash:Play()
            newItemAnim:Play()
        end
    else
        battlepayItemTexture:Hide()
        newItemTexture:Hide()
        if (flash:IsPlaying() or newItemAnim:IsPlaying()) then
            flash:Stop()
            newItemAnim:Stop()
        end
    end

    self.JunkIcon:Hide()
    _G[self:GetName().."Cooldown"]:Hide()

    if self:IsValid() then
        local isJunk = quality == _G.LE_ITEM_QUALITY_POOR and not noValue and _G.MerchantFrame:IsShown()
        self.JunkIcon:SetShown(isJunk)
        _G.ContainerFrame_UpdateCooldown(bagID, self)
    end

    self:UpdateItemContextMatching()
    _G.ContainerFrameItemButton_UpdateItemUpgradeIcon(self)
    self.readable = readable

    if self == _G.GameTooltip:GetOwner() then
        if _G.GetContainerItemInfo(bagID, slotIndex) then
            self.UpdateTooltip(self)
        else
            _G.GameTooltip:Hide()
        end
    end

    self:SetMatchesSearch(not isFiltered)
end
local function InventoryItemFactory(pool)
    local numActive = pool:GetNumActive()
    local slot = _G.CreateFrame("ItemButton", "$parent_Slot"..numActive, _G.RealUIInventory, pool.frameTemplate)
    _G.Mixin(slot, InventoryItemMixin)
    return slot
end
local inventorySlots = _G.CreateObjectPool(InventoryItemFactory, SlotReset)
inventorySlots.frameTemplate = "ContainerFrameItemButtonTemplate"

local BankItemMixin = _G.CreateFromMixins(_G.ItemLocationMixin)
function BankItemMixin:Update()
    local bagID, slotIndex = self:GetBagAndSlot()
    local item = self.item

    local _, itemCount, _, _, _, _, _, isFiltered = _G.GetContainerItemInfo(bagID, slotIndex)
    local isQuestItem, questId, isActive = _G.GetContainerItemQuestInfo(bagID, slotIndex)

    local icon = item:GetItemIcon()
    local quality = item:GetItemQuality()
    _G.SetItemButtonTexture(self, icon)
    _G.SetItemButtonCount(self, itemCount)
    _G.SetItemButtonDesaturated(self, item:IsItemLocked())

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

    self:UpdateItemContextMatching()
    self:SetMatchesSearch(not isFiltered)

    _G.SetItemButtonQuality(self, quality, item:GetItemLink())

    _G.BankFrameItemButton_UpdateLocked(self)
    _G.ContainerFrame_UpdateCooldown(bagID, self)
end
local function BankItemFactory(pool)
    local numActive = pool:GetNumActive()
    local slot = _G.CreateFrame("ItemButton", "$parent_Slot"..numActive, _G.RealUIBank, pool.frameTemplate)
    _G.Mixin(slot, BankItemMixin)
    return slot
end
local bankSlots = _G.CreateObjectPool(BankItemFactory, SlotReset)
bankSlots.frameTemplate = "BankItemButtonGenericTemplate"

function private.UpdateSlots(bagID)
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

local rowSize, gap = 6, 5
function private.ArrangeSlots(bag, offsetTop)
    local numSlots, numRows = 0, 0
    local previousButton, cornerButton
    local slotSize = 0
    for _, slot in ipairs(bag.slots) do
        numSlots = numSlots + 1
        slot:ClearAllPoints() -- The template has anchors
        if not previousButton then
            slot:SetPoint("TOPLEFT", bag, gap, -offsetTop)
            previousButton = slot
            cornerButton = slot

            slotSize = slot:GetWidth()
            numRows = numRows + 1
        else
            if numSlots % rowSize == 1 then -- new row
                slot:SetPoint("TOPLEFT", cornerButton, "BOTTOMLEFT", 0, -gap)
                cornerButton = slot

                numRows = numRows + 1
            else
                slot:SetPoint("TOPLEFT", previousButton, "TOPRIGHT", gap, 0)
            end

            previousButton = slot
        end
    end

    slotSize = slotSize + gap
    return slotSize * rowSize, slotSize * numRows
end

function private.GetSlot(bagID, slotIndex)
    local slots = inventorySlots
    if bagID == _G.BANK_CONTAINER then
        slots = bankSlots
    end

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

function private.GetNumFreeSlots(bag)
    local totalFree, freeSlots, bagFamily = 0
    if bag.bagType == "main" then
        for bagID = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS do
            freeSlots, bagFamily = _G.GetContainerNumFreeSlots(bagID)
            if bagFamily == 0 then
                totalFree = totalFree + freeSlots
            end
        end
    elseif bag.bagType == "bank" then
        totalFree = totalFree + _G.GetContainerNumFreeSlots(_G.BANK_CONTAINER)
        for bagID = _G.NUM_BAG_SLOTS + 1, _G.NUM_BAG_SLOTS + _G.NUM_BANKBAGSLOTS do
            freeSlots, bagFamily = _G.GetContainerNumFreeSlots(bagID)
            if bagFamily == 0 then
                totalFree = totalFree + freeSlots
            end
        end
    end

    return totalFree
end
local function GetFirstFreeSlot(bagID)
    if _G.GetContainerNumFreeSlots(bagID) > 0 then
        local numSlots = _G.GetContainerNumSlots(bagID)
        for slotIndex = 1, numSlots do
            if not _G.GetContainerItemLink(bagID, slotIndex) then
                return slotIndex
            end
        end
    end
end
function private.GetFirstFreeSlot(bagType)
    if bagType == "main" then
        for bagID = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS do
            local slotIndex = GetFirstFreeSlot(bagID)
            if slotIndex then
                return bagID, slotIndex
            end
        end
    elseif bagType == "bankReagent" then
        local bagID = _G.REAGENTBANK_CONTAINER
        local slotIndex = GetFirstFreeSlot(bagID)
        if slotIndex then
            return bagID, slotIndex
        end
    else
        local containerIDs = {-1,5,6,7,8,9,10,11}
        for _, bagID in next, containerIDs do
            local slotIndex = GetFirstFreeSlot(bagID)
            if slotIndex then
                return bagID, slotIndex
            end
        end
    end
    return false
end
