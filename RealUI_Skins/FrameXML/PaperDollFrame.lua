local _, private = ...

-- [[ Lua Globals ]]
-- luacheck: globals next tonumber max type

-- [[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin

local RealUI = _G.RealUI
local LIU = _G.LibStub("LibItemUpgradeInfo-1.0")

do --[[ FrameXML\PaperDollFrame.lua ]]
    local ShouldHaveEnchant, GetNumSockets do
        local enchantSlots = {
            [2] = 110, -- Neck
            [15] = 110, -- Cloak
            [11] = true, -- Ring 1
            [12] = true, -- Ring 2
            [16] = 120, -- Main Hand
            [17] = 120, -- Off Hand
        }
        function ShouldHaveEnchant(slotID, quality)
            local canEnchant = enchantSlots[slotID]
            if type(canEnchant) == "number" then
                canEnchant = _G.GetEffectivePlayerMaxLevel() == canEnchant
            end
            return canEnchant and quality ~= RealUI.Enum.ItemQuality.Artifact
        end

        local scanningTooltip = _G.RealUIScanningTooltip
        function GetNumSockets(itemLink)
            scanningTooltip:ClearLines()
            local success = _G.pcall(scanningTooltip.SetHyperlink, scanningTooltip, itemLink)
            if not success then
                return 0
            end

            local numSockets, hasMeta = 0, false
            for i = 5, 20 do
                local l = _G["RealUIScanningTooltipTextLeft"..i]
                if l then
                    local text = l:GetText()
                    if text then
                        if text:find(_G.EMPTY_SOCKET_META) then
                            numSockets = numSockets + 1
                            hasMeta = true
                        elseif text:find(_G.EMPTY_SOCKET_PRISMATIC) then
                            numSockets = numSockets + 1
                        end
                    end
                end
            end
            return numSockets, hasMeta
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
                local color = _G.ITEM_QUALITY_COLORS[quality]
                self.ilvl:SetTextColor(color.r, color.g, color.b)
                self.ilvl:SetText(itemLevel)
                self.ilvl:Show()

                local cur, max = LIU:GetItemUpgradeInfo(itemLink)
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

                if _G.IsPlayerAtEffectiveMaxLevel() then
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

                    local gems = {tonumber(gem1), tonumber(gem2), tonumber(gem3), tonumber(gem4)}
                    local numSockets, hasMeta = GetNumSockets(itemLink)
                    local socketIdx = 0
                    if #gems > 0 then
                        for i, gem in next, gems do
                            self.gems[i]:SetTexture(_G.GetItemIcon(gem))
                            self.gems[i]:Show()
                            socketIdx = i
                        end
                    end
                    if numSockets > 0 then
                        for i = socketIdx + 1, socketIdx + numSockets do
                            if hasMeta then
                                self.gems[i]:SetTexture([[Interface\ItemSocketingFrame\UI-EmptySocket-Meta]])
                                hasMeta = false
                            else
                                self.gems[i]:SetTexture([[Interface\ItemSocketingFrame\UI-EmptySocket-Prismatic]])
                            end
                            self.gems[i]:Show()
                            socketIdx = i
                        end
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

_G.hooksecurefunc(private.FrameXML, "PaperDollFrame", function()
    _G.hooksecurefunc("PaperDollItemSlotButton_Update", Hook.PaperDollItemSlotButton_Update)
end)
