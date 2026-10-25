local _, private = ...

-- [[ Lua Globals ]]
-- luacheck: globals next tonumber min type

-- [[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin

local RealUI = _G.RealUI

do --[[ FrameXML\PaperDollFrame.lua ]]
    local ShouldHaveEnchant do
        -- true: enchantable on every client; an expansion level: only there.
        -- The armor slots were gated on 8 (Shadowlands), so on Midnight they
        -- never flagged a missing enchant. Midnight enchants head, shoulders,
        -- chest, legs and feet; bracers, cloak and gloves no longer take one.
        local MIDNIGHT = _G.LE_EXPANSION_MIDNIGHT
        local enchantSlots = {
            [1] = MIDNIGHT, -- Head
            [3] = MIDNIGHT, -- Shoulder
            [5] = MIDNIGHT, -- Chest
            [7] = MIDNIGHT, -- Legs
            [8] = MIDNIGHT, -- Boots
            [11] = true, -- Ring 1
            [12] = true, -- Ring 2
            [16] = true, -- Main Hand
            [17] = true, -- Off Hand
        }
        function ShouldHaveEnchant(slotID, quality)
            local canEnchant = enchantSlots[slotID]
            if type(canEnchant) == "number" then
                canEnchant = _G.GetClientDisplayExpansionLevel() == canEnchant
            end
            return canEnchant and quality ~= _G.Enum.ItemQuality.Artifact
        end
    end

    local function HideInfo(self)
        self.ilvl:Hide()
        for i, tex in next, self.upgrades do
            tex:Hide()
        end
        self.dura:Hide()
        self.enchant:Hide()
        self.gems:Hide()
    end

    function Hook.PaperDollItemSlotButton_Update(self)
        if not self.ilvl then return end

        local slotID = self:GetID()
        local itemLink = _G.GetInventoryItemLink("player", slotID)
        if itemLink then
            local itemLevel = RealUI.GetItemLevel(itemLink)
            if itemLevel > 1 then
                local quality = _G.GetInventoryItemQuality("player", slotID)
                local color
                if quality then
                    color = _G.ITEM_QUALITY_COLORS[quality]
                    if color then
                        self.ilvl:SetTextColor(color.r, color.g, color.b)
                    else
                        self.ilvl:SetTextColor(1, 1, 1) -- Default to white
                    end
                else
                    self.ilvl:SetTextColor(1, 1, 1) -- Default to white if quality is nil
                end
                self.ilvl:SetText(itemLevel)
                self.ilvl:Show()

                -- Native upgrade track (12.x and Forever); replaced
                -- LibItemUpgradeInfo, whose static bonus-ID table went stale and
                -- whose cached GetItemInfo is nil since 12.1.5.
                local upgrade = _G.C_Item.GetItemUpgradeInfo(itemLink)
                local cur, max
                if upgrade and upgrade.maxLevel and upgrade.maxLevel > 0 then
                    cur, max = upgrade.currentLevel, upgrade.maxLevel
                end
                for i, tex in next, self.upgrades do
                    if cur then
                        if i == "bg" then
                            tex:Show()
                        elseif i <= cur then
                            tex:SetColorTexture(color.r, color.g, color.b)
                            tex:SetHeight((self:GetHeight() / max) - (i < max and 1 or 0))
                            --tex:SetPoint("TOPLEFT", -1 + ((dotSize*.75)*(i-1)), 1)
                            tex:Show()
                        else
                            tex:Hide()
                        end
                    else
                        tex:Hide()
                    end
                end

                local curDurability, maxDurability = _G.GetInventoryItemDurability(slotID)
                if maxDurability then
                    self.dura:SetValue(RealUI.GetSafeVals(curDurability, maxDurability))
                    self.dura:SetStatusBarColor(RealUI.GetDurabilityColor(curDurability, maxDurability):GetRGB())
                    self.dura:Show()
                else
                    self.dura:Hide()
                end

                if _G.GameRulesUtil.IsPlayerAtEffectiveMaxLevel() then
                    local itemString = itemLink:match("item[%-?%d:]+") or ""
                    local _, _, enchantID, gem1, gem2, gem3, gem4 = _G.strsplit(":", itemString)
                    if tonumber(enchantID) then
                        self.enchant:SetTexture([[Interface\Icons\INV_Misc_EnchantedScroll]])
                        self.enchant:Show()
                    else
                        if ShouldHaveEnchant(slotID, quality) then
                            self.enchant:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
                            self.enchant:Show()
                        else
                            self.enchant:Hide()
                        end
                    end

                    -- Filled sockets come from the link's gem fields; the rest
                    -- of the item's sockets are empty. The socket count used
                    -- to come from a hidden scanning tooltip whose lines never
                    -- matched EMPTY_SOCKET_PRISMATIC, so empty sockets never
                    -- showed.
                    local gemIDs = {gem1, gem2, gem3, gem4}
                    local socketIdx = 0
                    for i = 1, 4 do
                        local gemID = tonumber(gemIDs[i])
                        if gemID then
                            socketIdx = socketIdx + 1
                            self.gems[socketIdx]:SetTexture(_G.C_Item.GetItemIconByID(gemID))
                            self.gems[socketIdx]:Show()
                        end
                    end
                    local numSockets = _G.C_Item.GetItemNumSockets(itemLink) or 0
                    for i = socketIdx + 1, min(numSockets, 4) do
                        self.gems[i]:SetTexture([[Interface\ItemSocketingFrame\UI-EmptySocket-Prismatic]])
                        self.gems[i]:Show()
                        socketIdx = i
                    end
                    self.gems:Hide(socketIdx + 1)
                else
                    self.enchant:Hide()
                    self.gems:Hide()
                end
            else
                HideInfo(self)
            end
        else
            HideInfo(self)
        end
    end
end

do --[[ FrameXML\PaperDollFrame.xml ]]
    local MAX_UPGRADES = 6
    local function CreateRegions(Button)
        local name = Button:GetName()

        local ilvl = Button:CreateFontString(name.."ItemLevel", "OVERLAY")
        ilvl:SetFontObject(_G.NumberFont_Outline_Med)
        ilvl:SetPoint("BOTTOMRIGHT", 0, 1)
        ilvl:SetPoint("BOTTOMLEFT", 1, 1)
        Button.ilvl = ilvl

        local upgrades = {}
        local upgradeBG = Button:CreateTexture(nil, "OVERLAY", nil, -8)
        upgradeBG:SetColorTexture(0, 0, 0, 1)
        upgrades.bg = upgradeBG

        for i = 1, MAX_UPGRADES do
            local tex = Button:CreateTexture(nil, "OVERLAY")
            tex:SetWidth(1)
            if i == 1 then
                tex:SetPoint("TOPLEFT", upgradeBG)
            else
                tex:SetPoint("TOPLEFT", upgrades[i-1], "BOTTOMLEFT", 0, -1)
            end
            upgrades[i] = tex
        end
        Button.upgrades = upgrades

        local dura = _G.CreateFrame("StatusBar", nil, Button)
        dura:SetStatusBarTexture(private.textures.plain)
        dura:SetOrientation("VERTICAL")
        dura:SetMinMaxValues(0, 1)
        dura:SetValue(0)

        local duraBG = dura:CreateTexture(nil, "BACKGROUND", nil, -8)
        duraBG:SetColorTexture(0, 0, 0, 1)
        duraBG:SetPoint("TOPLEFT", -1, 0)
        duraBG:SetPoint("BOTTOMRIGHT", 1, 0)
        Button.dura = dura

        local enchant = Button:CreateTexture(name.."Enchant", "OVERLAY")
        enchant:SetTexture([[Interface\Icons\inv_misc_enchantedscroll]])
        enchant:SetSize(10, 10)
        Base.CropIcon(enchant)
        Button.enchant = enchant

        Button.gems = {}
        function Button.gems:Hide(start)
            for i = (start or 1), 4 do
                self[i]:Hide()
            end
        end
        for i = 1, 4 do
            local gem = Button:CreateTexture(name.."Gem"..i, "OVERLAY")
            gem:SetSize(10, 10)
            Base.CropIcon(gem)
            Button.gems[i] = gem
        end
    end

    _G.hooksecurefunc(Skin, "PaperDollItemSlotButtonLeftTemplate", function(Button)
        CreateRegions(Button)

        Button.ilvl:SetJustifyH("RIGHT")
        Button.ilvl:SetText("Button.ilvl")

        local upgrades = Button.upgrades
        upgrades.bg:SetPoint("TOPLEFT", -1, 0)
        upgrades.bg:SetPoint("BOTTOMRIGHT", Button, "BOTTOMLEFT")

        Button.dura:SetPoint("TOPLEFT", 1, 0)
        Button.dura:SetPoint("BOTTOMRIGHT", Button, "BOTTOMLEFT", 2, 0)

        Button.enchant:SetPoint("TOPLEFT", Button, "TOPRIGHT", 2, -2)

        local gems = Button.gems
        gems[1]:SetPoint("TOPLEFT", Button.enchant, "BOTTOMLEFT", 0, -2)
        gems[2]:SetPoint("TOPLEFT", gems[1], "BOTTOMLEFT", 0, -2)
        gems[3]:SetPoint("TOPLEFT", gems[1], "TOPRIGHT", 2, 0)
        gems[4]:SetPoint("TOPLEFT", gems[3], "BOTTOMLEFT", 0, -2)
    end)
    _G.hooksecurefunc(Skin, "PaperDollItemSlotButtonRightTemplate", function(Button)
        CreateRegions(Button)

        Button.ilvl:SetJustifyH("LEFT")
        Button.ilvl:SetText("Button.ilvl")

        local upgrades = Button.upgrades
        upgrades.bg:SetPoint("TOPRIGHT", 1, 0)
        upgrades.bg:SetPoint("BOTTOMLEFT", Button, "BOTTOMRIGHT")

        Button.dura:SetPoint("TOPRIGHT", -1, 0)
        Button.dura:SetPoint("BOTTOMLEFT", Button, "BOTTOMRIGHT", -2, 0)

        Button.enchant:SetPoint("TOPRIGHT", Button, "TOPLEFT", -2, -2)
        Button.gems[1]:SetPoint("TOPRIGHT", Button.enchant, "BOTTOMRIGHT", 0, -2)

        local gems = Button.gems
        gems[1]:SetPoint("TOPRIGHT", Button.enchant, "BOTTOMRIGHT", 0, -2)
        gems[2]:SetPoint("TOPRIGHT", gems[1], "BOTTOMRIGHT", 0, -2)
        gems[3]:SetPoint("TOPRIGHT", gems[1], "TOPLEFT", -2, 0)
        gems[4]:SetPoint("TOPRIGHT", gems[3], "BOTTOMRIGHT", 0, -2)
    end)
    function Skin.PaperDollItemSlotButtonBottomTemplate(Button)
        if Button:GetName():find("MainHand") then
            Skin.PaperDollItemSlotButtonRightTemplate(Button)
        else
            Skin.PaperDollItemSlotButtonLeftTemplate(Button)
        end
    end
end

-- Enchanting or socketing an equipped item changes its link without a
-- PLAYER_EQUIPMENT_CHANGED for the slot, so Blizzard never re-runs the slot
-- update and the enchant and gem markers stay stale until the sheet reopens.
-- Refresh only RealUI's own regions; Blizzard's update is left alone. The
-- refresh is deferred and batched: the events arrive in bursts, and the new
-- link can land a moment after the spell or socket result.
local slotNames = {
    "Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist",
    "Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1",
    "MainHand", "SecondaryHand",
}
local refreshPending = false
local function RefreshSlotInfo()
    refreshPending = false
    if not _G.PaperDollFrame:IsVisible() then return end
    for _, slotName in next, slotNames do
        local button = _G["Character"..slotName.."Slot"]
        if button then
            Hook.PaperDollItemSlotButton_Update(button)
        end
    end
end
local function QueueRefresh()
    if refreshPending or not _G.PaperDollFrame:IsVisible() then return end
    refreshPending = true
    _G.C_Timer.After(0.2, RefreshSlotInfo)
end

_G.hooksecurefunc(private.FrameXML, "PaperDollFrame", function()
    _G.hooksecurefunc("PaperDollItemSlotButton_Update", Hook.PaperDollItemSlotButton_Update)

    local inventoryWatcher = _G.CreateFrame("Frame")
    inventoryWatcher:SetScript("OnEvent", QueueRefresh)
    inventoryWatcher:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
    inventoryWatcher:RegisterEvent("ENCHANT_SPELL_COMPLETED")
    inventoryWatcher:RegisterEvent("SOCKET_INFO_SUCCESS")
    inventoryWatcher:RegisterEvent("SOCKET_INFO_UPDATE")
end)
