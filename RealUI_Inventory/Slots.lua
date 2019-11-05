local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs next

-- RealUI --
--local Inventory = private.Inventory

local function SlotFactory(pool)
    local numActive = pool:GetNumActive()
    local slot = _G.CreateFrame("ItemButton", "$parent_Slot"..numActive, _G.RealUIInventory, pool.frameTemplate)
    _G.Mixin(slot, _G.ItemLocationMixin)
    return slot
end
local function SlotReset(pool, slot)
    slot:ClearAllPoints()
    slot:Hide()

    slot.item = nil
    slot:Clear()
end

local slots = _G.CreateObjectPool(SlotFactory, SlotReset)
slots.frameTemplate = "ContainerFrameItemButtonTemplate"
private.slots = slots

local function UpdateSlot(slot)
    local bagID, slotIndex = slot:GetBagAndSlot()
    local item = slot.item

    local _, itemCount, _, _, readable, _, _, isFiltered, noValue = _G.GetContainerItemInfo(bagID, slotIndex)
    local isQuestItem, questId, isActive = _G.GetContainerItemQuestInfo(bagID, slotIndex)

    local icon = item:GetItemIcon()
    local quality = item:GetItemQuality()
    _G.SetItemButtonTexture(slot, icon)
    _G.SetItemButtonQuality(slot, quality, item:GetItemLink())
    _G.SetItemButtonCount(slot, itemCount)
    _G.SetItemButtonDesaturated(slot, item:IsItemLocked())

    local questTexture = _G[slot:GetName().."IconQuestTexture"]
    if questId and not isActive then
        questTexture:SetTexture(_G.TEXTURE_ITEM_QUEST_BANG)
        questTexture:Show()
    elseif questId or isQuestItem then
        questTexture:SetTexture(_G.TEXTURE_ITEM_QUEST_BORDER)
        questTexture:Show()
    else
        questTexture:Hide()
    end

    local isNewItem = _G.C_NewItems.IsNewItem(bagID, slotIndex)
    local isBattlePayItem = _G.IsBattlePayItem(bagID, slotIndex)

    local battlepayItemTexture = slot.BattlepayItemTexture
    local newItemTexture = slot.NewItemTexture
    local flash = slot.flashAnim
    local newItemAnim = slot.newitemglowAnim

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

    slot.JunkIcon:Hide()
    _G[slot:GetName().."Cooldown"]:Hide()

    if slot:IsValid() then
        local isJunk = quality == _G.LE_ITEM_QUALITY_POOR and not noValue and _G.MerchantFrame:IsShown()
        slot.JunkIcon:SetShown(isJunk)
        _G.ContainerFrame_UpdateCooldown(bagID, slot)
    end

    slot:UpdateItemContextMatching()
    _G.ContainerFrameItemButton_UpdateItemUpgradeIcon(slot)
    slot.readable = readable

    if slot == _G.GameTooltip:GetOwner() then
        if _G.GetContainerItemInfo(bagID, slotIndex) then
            slot.UpdateTooltip(slot)
        else
            _G.GameTooltip:Hide()
        end
    end

    slot:SetMatchesSearch(not isFiltered)
end

function private.UpdateSlots(bagID)
    for slotIndex = 1, _G.GetContainerNumSlots(bagID) do
        local slot = private.GetSlot(bagID, slotIndex)
        if slot then
            private.AddSlotToBag(slot, bagID)
            UpdateSlot(slot)
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
    else
        slots:Release(slot)
    end
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
