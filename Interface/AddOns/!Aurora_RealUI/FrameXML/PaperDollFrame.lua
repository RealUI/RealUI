local _, mods = ...

tinsert(mods["Aurora"], function(F, C)
    --print("HELLO WORLD!!!", F, C)
    local itemSlots = {
        {slot = "Head", hasDura = true},
        {slot = "Neck", hasDura = false},
        {slot = "Shoulder", hasDura = true},
        {}, -- shirt
        {slot = "Chest", hasDura = true},
        {slot = "Waist", hasDura = true},
        {slot = "Legs", hasDura = true},
        {slot = "Feet", hasDura = true},
        {slot = "Wrist", hasDura = true},
        {slot = "Hands", hasDura = true},
        {slot = "Finger0", hasDura = false},
        {slot = "Finger1", hasDura = false},
        {slot = "Trinket0", hasDura = false},
        {slot = "Trinket1", hasDura = false},
        {slot = "Back", hasDura = false},
        {slot = "MainHand", hasDura = true},
        {slot = "SecondaryHand", hasDura = true},
    }
    -- Set up iLvl and Durability
    for slotID = 1, #itemSlots do
        local item = itemSlots[slotID]
        if item.slot then
            local itemSlot = _G["Character" .. item.slot .. "Slot"]
            local iLvl = itemSlot:CreateFontString(item.slot .. "ItemLevel", "OVERLAY")
            iLvl:SetFontObject(SystemFont_Outline_Small) --SetFont(unpack(RealUI.font.pixel1))
            iLvl:SetPoint("BOTTOMRIGHT", itemSlot, "BOTTOMRIGHT", 2, 1.5)
            itemSlot.ilvl = iLvl
            if item.hasDura then
                local dura = CreateFrame("StatusBar", nil, itemSlot)
                
                if item.slot == "SecondaryHand" then
                    dura:SetPoint("TOPLEFT", itemSlot, "TOPRIGHT", 2, 0)
                    dura:SetPoint("BOTTOMRIGHT", itemSlot, "BOTTOMRIGHT", 3, 0)
                else
                    dura:SetPoint("TOPRIGHT", itemSlot, "TOPLEFT", -2, 0)
                    dura:SetPoint("BOTTOMLEFT", itemSlot, "BOTTOMLEFT", -3, 0)
                end
                
                dura:SetStatusBarTexture(RealUI.media.textures.plain)
                dura:SetOrientation("VERTICAL")
                dura:SetMinMaxValues(0, 1)
                dura:SetValue(0)
                
                F.CreateBDFrame(dura)
                dura:SetFrameLevel(itemSlot:GetFrameLevel() + 4)
                itemSlot.dura = dura
            end
        end
    end

    PaperDollFrame.ilvl = PaperDollFrame:CreateFontString("ARTWORK")
    PaperDollFrame.ilvl:SetFontObject(SystemFont_Small)
    PaperDollFrame.ilvl:SetPoint("TOP", PaperDollFrame, "TOP", 0, -20)

    -- Toggle Helm and Cloak
    local helmcloak = {
        Head = "Helm",
        Back = "Cloak",
    }
    for slot, item in next, helmcloak do
        local isShown = _G["Showing" .. item]
        local itemSlot = _G["Character" .. slot .. "Slot"]
        local check = CreateFrame("CheckButton", "RealUI" .. item, itemSlot, "UICheckButtonTemplate")
        check:SetSize(18, 18)
        check:SetPoint("TOPLEFT", itemSlot, -4, 4)
        F.ReskinCheck(check)

        check:SetScript("OnShow", function(self) 
            self:SetChecked(isShown())
        end)

        check:SetScript("OnClick", function() 
            _G["Show" .. item](not isShown()) 
        end)

        check:SetScript("OnEnter", function(self) 
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 13, -10)
            GameTooltip:AddLine(_G["SHOW_" .. strupper(item)])
            GameTooltip:Show()
        end)

        check:SetScript("OnLeave", function() 
            GameTooltip:Hide()
        end)
    end

    local ilvlLimits = 385
    local function GetILVLColor(lvl, ilvl)
        if lvl > 90 then
            ilvlLimits = (lvl - 91) * 9 + 510
        end
        if ilvl >= ilvlLimits + 28 then
            return ITEM_QUALITY_COLORS[4] -- epic
        elseif ilvl >= ilvlLimits + 14 then
            return ITEM_QUALITY_COLORS[3] -- rare
        elseif ilvl >= ilvlLimits then
            return ITEM_QUALITY_COLORS[2] -- uncommon
        else
            return ITEM_QUALITY_COLORS[1] -- common
        end
    end

    -- Update Item display
    local f, timer = CreateFrame("Frame")
    local function UpdateItems()
        if not CharacterFrame:IsVisible() then return end
        
        for slotID = 1, #itemSlots do
            local item = itemSlots[slotID]
            if item.slot then
                local itemSlot = _G["Character" .. item.slot .. "Slot"]
                local itemLink = GetInventoryItemLink("player", slotID)
                if itemLink then
                    local _, _, itemRarity, itemLevel = GetItemInfo(itemLink)

                    if itemLevel and itemLevel > 0 then
                        itemSlot.ilvl:SetTextColor(ITEM_QUALITY_COLORS[itemRarity].r, ITEM_QUALITY_COLORS[itemRarity].g, ITEM_QUALITY_COLORS[itemRarity].b)
                        itemSlot.ilvl:SetText(itemLevel)
                    else
                        itemSlot.ilvl:SetText("")
                    end
                else
                    itemSlot.ilvl:SetText("")
                end
                if item.hasDura then
                    local min, max = GetInventoryItemDurability(slotID)
                    if max then
                        local percent = RealUI:GetSafeVals(min, max)
                        itemSlot.dura:SetValue(percent)
                        itemSlot.dura:SetStatusBarColor(RealUI:GetDurabilityColor(percent))
                        itemSlot.dura:Show()
                    else
                        itemSlot.dura:Hide()
                    end
                end
            end
        end

        local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
        local aILColor = GetILVLColor(UnitLevel("player"), avgItemLevel)["hex"]
        local aILEColor = GetILVLColor(UnitLevel("player"), avgItemLevelEquipped)["hex"]
        avgItemLevel = floor(avgItemLevel)
        avgItemLevelEquipped = floor(avgItemLevelEquipped)
        PaperDollFrame.ilvl:SetText(" "..aILEColor..avgItemLevelEquipped.."|r |cffffffff/|r "..aILColor..avgItemLevel)
        timer = false
    end

    f:SetScript("OnEvent", function(self, event, ...)
        if not timer then
            C_Timer.After(UpdateItems, .25)
            timer = true
        end
    end)
    CharacterFrame:HookScript("OnShow", function()
        f:RegisterEvent("UNIT_INVENTORY_CHANGED")
        f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        UpdateItems()
    end)
    CharacterFrame:HookScript("OnHide", function()
        f:UnregisterEvent("UNIT_INVENTORY_CHANGED")
        f:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
    end)
end)
