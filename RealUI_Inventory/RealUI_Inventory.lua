local _, private = ...

-- Lua Globals --
-- luacheck: globals next tinsert ceil

-- Libs --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin

-- RealUI --
local RealUI = _G.RealUI

local Inventory = RealUI:NewModule("Inventory")
Inventory.bags = {}
Inventory.slots = {}

local defaults = {
}

function private.Update()
    for _, slot in next, Inventory.slots do
        local bagID, slotIndex = slot:GetBagAndSlot()
        local _, itemCount, _, _, readable, _, _, isFiltered, noValue = _G.GetContainerItemInfo(bagID, slotIndex)
        local isQuestItem, questId, isActive = _G.GetContainerItemQuestInfo(bagID, slotIndex)

        local icon = slot:GetItemIcon()
        local quality = slot:GetItemQuality()
        _G.SetItemButtonTexture(slot, icon)
        _G.SetItemButtonQuality(slot, quality, slot:GetItemLink())
        _G.SetItemButtonCount(slot, itemCount)
        _G.SetItemButtonDesaturated(slot, slot:IsItemLocked())

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
end
function private.Toggle(show)
    local main = Inventory.bags.main
    if show == nil then
        show = not main:IsShown()
    end

    if show then
        main:RegisterEvent("BAG_UPDATE")
        main:RegisterEvent("UNIT_INVENTORY_CHANGED")
        main:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        main:RegisterEvent("ITEM_LOCK_CHANGED")
        main:RegisterEvent("BAG_UPDATE_COOLDOWN")
        main:RegisterEvent("DISPLAY_SIZE_CHANGED")
        main:RegisterEvent("INVENTORY_SEARCH_UPDATE")
        main:RegisterEvent("BAG_NEW_ITEMS_UPDATED")
        main:RegisterEvent("BAG_SLOT_FLAGS_UPDATED")

        private.Update()
    else
        main:UnregisterEvent("BAG_UPDATE")
        main:UnregisterEvent("UNIT_INVENTORY_CHANGED")
        main:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        main:UnregisterEvent("ITEM_LOCK_CHANGED")
        main:UnregisterEvent("BAG_UPDATE_COOLDOWN")
        main:UnregisterEvent("DISPLAY_SIZE_CHANGED")
        main:UnregisterEvent("INVENTORY_SEARCH_UPDATE")
        main:UnregisterEvent("BAG_NEW_ITEMS_UPDATED")
        main:UnregisterEvent("BAG_SLOT_FLAGS_UPDATED")
    end

    main:SetShown(show)
end

--local oldOpenAllBags = _G.OpenAllBags
function _G.OpenAllBags()
    private.Toggle(true)
end

--local oldCloseAllBags = _G.CloseAllBags
function _G.CloseAllBags()
    private.Toggle(false)
end

--local oldCloseAllBags = _G.CloseAllBags
function _G.ToggleBackpack()
    private.Toggle()
end

--local oldToggleAllBags = _G.ToggleAllBags
_G.ToggleAllBags = _G.ToggleBackpack

--local oldToggleBag = _G.ToggleBag
_G.ToggleBag = _G.nop


function Inventory:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_TemplateDB", defaults, true)

    local main = _G.CreateFrame("Frame", "RealUIInventory", _G.UIParent)
    _G.Mixin(main, _G.ContinuableContainer)
    Base.SetBackdrop(main)
    self.bags.main = main

    local rowSize = 6
    local previousButton, cornerButton
    local numSlots = 0
    for bagID = 0, _G.NUM_BAG_SLOTS do
        local bag = _G.CreateFrame("Frame", "$parentBag"..bagID, main)
        bag:SetID(bagID)
        for slotIndex = 1, _G.GetContainerNumSlots(bagID) do
            numSlots = numSlots + 1
            local itemButton = _G.CreateFrame("ItemButton", "$parent"..numSlots, bag, "ContainerFrameItemButtonTemplate")
            Skin.ContainerFrameItemButtonTemplate(itemButton)
            itemButton:SetID(slotIndex)
            tinsert(self.slots, itemButton)
            bag[slotIndex] = itemButton

            itemButton:ClearAllPoints() -- The template has anchors
            if not previousButton then
                itemButton:SetPoint("BOTTOMRIGHT", main, -5, 5)
                previousButton = itemButton
                cornerButton = itemButton
            else
                if numSlots % rowSize == 1 then
                    itemButton:SetPoint("BOTTOMRIGHT", cornerButton, "TOPRIGHT", 0, 5)
                    cornerButton = itemButton
                else
                    itemButton:SetPoint("TOPRIGHT", previousButton, "TOPLEFT", -5, 0)
                end

                previousButton = itemButton
            end

            _G.Mixin(itemButton, _G.ItemLocationMixin, _G.ItemMixin)
            itemButton:SetBagAndSlot(bagID, slotIndex)
            itemButton:SetItemLocation(itemButton)
            if itemButton:IsValid() then
                main:AddContinuable(itemButton)
            end
            itemButton:Show()
        end
        self.bags[bagID] = bag
    end

    main:SetSize(rowSize * 42 + 5, ceil(#self.slots / rowSize) * 42 + 5)
    main:SetPoint("BOTTOMRIGHT", -100, 100)
    main:EnableMouse(true)
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
                local slot = self.bags[bagID][slotIndex]
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
end
