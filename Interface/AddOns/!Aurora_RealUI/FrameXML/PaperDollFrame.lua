local _, mods = ...

-- Lua Globals --
local _G = _G

_G.tinsert(mods["nibRealUI"], function(F, C)
    mods.debug("PaperDollFrame", F, C)
    local r, g, b = C.r, C.g, C.b

    -- Lua Globals --
    local next, floor = _G.next, _G.floor

    -- Libs --
    local LIU = _G.LibStub("LibItemUpgradeInfo-1.0")

    local RealUI = _G.RealUI
    local maxUpgrades = 6

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
            iLvl:SetFontObject(_G.SystemFont_Outline_Small) --SetFont(unpack(RealUI.font.pixel1))
            iLvl:SetPoint("BOTTOMRIGHT", 2, 1.5)
            itemSlot.ilvl = iLvl

            local upgradeBG = itemSlot:CreateTexture(nil, "OVERLAY", -8)
            if RealUI.isBeta then
                upgradeBG:SetColorTexture(0, 0, 0, 1)
            else
                upgradeBG:SetTexture(0, 0, 0, 1)
            end
            if item.slot == "SecondaryHand" then
                upgradeBG:SetPoint("TOPRIGHT", itemSlot, "TOPLEFT", 1, 0)
                upgradeBG:SetPoint("BOTTOMLEFT", itemSlot, "BOTTOMLEFT", -1, 0)
            else
                upgradeBG:SetPoint("TOPLEFT", itemSlot, "TOPRIGHT", -1, 0)
                upgradeBG:SetPoint("BOTTOMRIGHT", itemSlot, "BOTTOMRIGHT", 1, 0)
            end
            itemSlot.upgradeBG = upgradeBG

            itemSlot.upgrade = {}
            for i = 1, maxUpgrades do
                local tex = itemSlot:CreateTexture(nil, "OVERLAY")
                tex:SetWidth(1)
                if i == 1 then
                    if item.slot == "SecondaryHand" then
                        tex:SetPoint("TOPRIGHT", itemSlot, "TOPLEFT", 0, 0)
                    else
                        tex:SetPoint("TOPLEFT", itemSlot, "TOPRIGHT", 0, 0)
                    end
                else
                    tex:SetPoint("TOPLEFT", itemSlot.upgrade[i-1], "BOTTOMLEFT", 0, -1)
                end
                itemSlot["Upgrade"..i] = tex
                itemSlot.upgrade[i] = tex
            end
            if item.hasDura then
                local dura = _G.CreateFrame("StatusBar", nil, itemSlot)
                
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

    _G.PaperDollFrame.ilvl = _G.PaperDollFrame:CreateFontString("ARTWORK")
    _G.PaperDollFrame.ilvl:SetFontObject(_G.SystemFont_Small)
    _G.PaperDollFrame.ilvl:SetPoint("TOP", _G.PaperDollFrame, "TOP", 0, -20)

    -- Toggle Helm and Cloak
    if not RealUI.isBeta then
        local helmcloak = {
            Head = "Helm",
            Back = "Cloak",
        }
        for slot, item in next, helmcloak do
            local isShown = _G["Showing" .. item]
            local itemSlot = _G["Character" .. slot .. "Slot"]
            local check = _G.CreateFrame("CheckButton", "RealUI" .. item, itemSlot, "UICheckButtonTemplate")
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
                _G.GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 13, -10)
                _G.GameTooltip:AddLine(_G["SHOW_" .. item:upper()])
                _G.GameTooltip:Show()
            end)

            check:SetScript("OnLeave", function() 
                _G.GameTooltip:Hide()
            end)
        end
    end

    local ilvlLimits = 385
    local function GetILVLColor(lvl, ilvl)
        -- ilvlLimits = (lvl - (maxLvL + 1)) * 9 + minQuestReward
        if lvl > 100 then
            ilvlLimits = (lvl - 101) * 9 + 685
        elseif lvl > 90 then
            ilvlLimits = (lvl - 91) * 9 + 510
        end
        if ilvl >= ilvlLimits + 28 then
            return _G.ITEM_QUALITY_COLORS[4] -- epic
        elseif ilvl >= ilvlLimits + 14 then
            return _G.ITEM_QUALITY_COLORS[3] -- rare
        elseif ilvl >= ilvlLimits then
            return _G.ITEM_QUALITY_COLORS[2] -- uncommon
        else
            return _G.ITEM_QUALITY_COLORS[1] -- common
        end
    end

    local function HideItemLevelInfo(itemSlot)
        itemSlot.ilvl:SetText("")
        itemSlot.upgradeBG:Hide()
        for i, tex in next, itemSlot.upgrade do
            tex:Hide()
        end
    end

    -- Update Item display
    local f, timer = _G.CreateFrame("Frame")
    local function UpdateItems()
        if not _G.CharacterFrame:IsVisible() then return end
        
        for slotID = 1, #itemSlots do
            local item = itemSlots[slotID]
            if item.slot then
                local itemSlot = _G["Character" .. item.slot .. "Slot"]
                local itemLink = _G.GetInventoryItemLink("player", slotID)
                if itemLink then
                    local _, _, itemRarity = _G.GetItemInfo(itemLink)
                    local itemLevel = LIU:GetUpgradedItemLevel(itemLink)
                    mods.debug("PaperDollFrame", item.slot, itemLevel)
                    mods.debug(_G.strsplit("|", itemLink))

                    if itemLevel and itemLevel > 0 then
                        itemSlot.ilvl:SetTextColor(_G.ITEM_QUALITY_COLORS[itemRarity].r, _G.ITEM_QUALITY_COLORS[itemRarity].g, _G.ITEM_QUALITY_COLORS[itemRarity].b)
                        itemSlot.ilvl:SetText(itemLevel)

                        -- item:itemID:0:0:0:0:0:0:uniqueID:linkLevel:specializationID:upgradeTypeID:0:numBonusIDs:bonusID1:bonusID2:...:upgradeID"
                        -- itemLink = "item:105385:0:0:0:0:0:0:1293870592:100:268:4:0:0:50"..(5 + (slotID % 2))
                        local cur, max, delta = LIU:GetItemUpgradeInfo(itemLink)
                        mods.debug("ItemUpgradeInfo", cur, max, delta, LIU:GetUpgradeID(itemLink))
                        itemSlot.upgradeBG:SetShown(cur and cur > 0)
                        for i, tex in next, itemSlot.upgrade do
                            if cur and i <= cur then
                                if RealUI.isBeta then
                                    tex:SetColorTexture(r, g, b)
                                else
                                    tex:SetTexture(r, g, b)
                                end
                                tex:SetHeight((itemSlot:GetHeight() / max) - (i < max and 1 or 0))
                                --tex:SetPoint("TOPLEFT", -1 + ((dotSize*.75)*(i-1)), 1)
                                tex:Show()
                            else
                                tex:Hide()
                            end
                        end
                    else
                        HideItemLevelInfo(itemSlot)
                    end
                else
                    HideItemLevelInfo(itemSlot)
                end
                if item.hasDura then
                    local min, max = _G.GetInventoryItemDurability(slotID)
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

        local avgItemLevel, avgItemLevelEquipped = _G.GetAverageItemLevel()
        local aILColor = GetILVLColor(_G.UnitLevel("player"), avgItemLevel)["hex"]
        local aILEColor = GetILVLColor(_G.UnitLevel("player"), avgItemLevelEquipped)["hex"]
        avgItemLevel = floor(avgItemLevel)
        avgItemLevelEquipped = floor(avgItemLevelEquipped)
        _G.PaperDollFrame.ilvl:SetText(" "..aILEColor..avgItemLevelEquipped.."|r |cffffffff/|r "..aILColor..avgItemLevel)
        timer = false
    end

    f:SetScript("OnEvent", function(self, event, ...)
        if not timer then
            _G.C_Timer.After(.25, UpdateItems)
            timer = true
        end
    end)
    _G.CharacterFrame:HookScript("OnShow", function()
        f:RegisterEvent("UNIT_INVENTORY_CHANGED")
        f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        f:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
        UpdateItems()
    end)
    _G.CharacterFrame:HookScript("OnHide", function()
        f:UnregisterEvent("UNIT_INVENTORY_CHANGED")
        f:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
        f:UnregisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
    end)
end)
