local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "PaperDoll"
local PaperDoll = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0", "AceHook-3.0")

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
function PaperDoll:MakeFrames()
    -- Set up iLvl and Durability
    for slotID = 1, #itemSlots do
        local item = itemSlots[slotID]
        if item.slot then
            local itemSlot = _G["Character" .. item.slot .. "Slot"]
            local iLvl = itemSlot:CreateFontString(item.slot .. "ItemLevel", "OVERLAY")
            iLvl:SetFont(unpack(nibRealUI.font.pixel1))
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
                
                dura:SetStatusBarTexture(nibRealUI.media.textures.plain)
                dura:SetOrientation("VERTICAL")
                dura:SetMinMaxValues(0, 1)
                dura:SetValue(0)
                
                nibRealUI:CreateBDFrame(dura)
                dura:SetFrameLevel(itemSlot:GetFrameLevel() + 4)
                itemSlot.dura = dura
            end
        end
    end

    self.ilvl = PaperDollFrame:CreateFontString("ARTWORK")
    self.ilvl:SetFontObject(SystemFont_Small)
    self.ilvl:SetPoint("TOP", PaperDollFrame, "TOP", 0, -20)

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
        --F.ReskinCheck(check)

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
end

-- Update Item display
function PaperDoll:UpdateItems()
    if not CharacterFrame:IsVisible() then return end
    
    for slotID = 1, #itemSlots do
        local item = itemSlots[slotID]
        if item.slot then
            local itemSlot = _G["Character" .. item.slot .. "Slot"]
            local itemLink = GetInventoryItemLink("player", slotID)
            if itemLink then
                local _, _, itemRarity, itemLevel = GetItemInfo(itemLink)

                if itemLevel and itemLevel > 0 then
                    if maxUpgradeLevel and currentUpgradeLevel and (tonumber(currentUpgradeLevel) > 0) then
                        if itemRarity <= 3 then
                            itemLevel = itemLevel + (tonumber(currentUpgradeLevel) * 8)
                        else
                            itemLevel = itemLevel + (tonumber(currentUpgradeLevel) * 4)
                        end
                    end
                    itemSlot.ilvl:SetTextColor(ITEM_QUALITY_COLORS[itemRarity].r, ITEM_QUALITY_COLORS[itemRarity].g, ITEM_QUALITY_COLORS[itemRarity].b)
                    itemSlot.ilvl:SetText(itemLevel)
                else
                    itemSlot.ilvl:SetText("")
                end
            else
                itemSlot.ilvl:SetText("")
            end
            if item.hasDura then
                local percent, min, max = nibRealUI:GetSafeVals(GetInventoryItemDurability(slotID))
                if (max ~= 0) then
                    itemSlot.dura:SetValue(percent)
                    itemSlot.dura:SetStatusBarColor(nibRealUI:GetDurabilityColor(min/max))
                    itemSlot.dura:Show()
                else
                    itemSlot.dura:Hide()
                end
            end
        end
    end

    local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
    local aILColor = nibRealUI:GetILVLColor(UnitLevel("player"), avgItemLevel)["hex"]
    local aILEColor = nibRealUI:GetILVLColor(UnitLevel("player"), avgItemLevelEquipped)["hex"]
    avgItemLevel = floor(avgItemLevel)
    avgItemLevelEquipped = floor(avgItemLevelEquipped)
    self.ilvl:SetText(" "..aILEColor..avgItemLevelEquipped.."|r |cffffffff/|r "..aILColor..avgItemLevel)
end

function PaperDoll:CharacterFrame_OnShow()
    self:RegisterBucketEvent({"UNIT_INVENTORY_CHANGED", "UPDATE_INVENTORY_DURABILITY"}, 0.25, "UpdateItems")
    self:UpdateItems()
end

function PaperDoll:CharacterFrame_OnHide()
    self:UnregisterAllBuckets()
end

--------------------
-- Initialization --
--------------------
function PaperDoll:OnInitialize()
    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterSkin(MODNAME, "Character Window")
end

function PaperDoll:OnEnable()
    self:SecureHookScript(CharacterFrame, "OnShow", "CharacterFrame_OnShow")
    self:SecureHookScript(CharacterFrame, "OnHide", "CharacterFrame_OnHide")
    self:MakeFrames()
end
