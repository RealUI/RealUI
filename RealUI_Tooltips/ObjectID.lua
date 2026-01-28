local _, private = ...

-- Lua Globals --
-- luacheck: globals _G select tonumber ipairs tinsert type

local Inventory = private.Inventory

-- RealUI --
local RealUI = _G.RealUI

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

-- Shamelessly copied from PTRFeedback_Tooltips
local LineTypeEnums = _G.Enum.TooltipDataLineType
local TooltipTypeEnums = _G.Enum.TooltipDataType
local TooltipTypes = {
    spell = "Spell",
    item = "Item",
    unit = "Creature",
    quest = "Quest",
    achievement = "Achievement",
    currency = "Currency",
    petBattleAbility = "Pet Battle Ability",
    petBattleCreature = "Pet Battle Creature",
    azerite = "Azerite Essence",
}

local formatString = "%s ID: %d"
--local formatStringGray = Color.gray:WrapTextInColorCode(formatString)
local function AddToTooltip(tooltip, tooltipType, tooltipID)
    if RealUI.isSecret(tooltip) or RealUI.isSecret(tooltipType) or RealUI.isSecret(tooltipID) then
        return
    end
    if not tooltip._id then
        local tooltipText = formatString:format(tooltipType, tooltipID)
        _G.GameTooltip_AddColoredLine(tooltip, tooltipText , Color.gray)
        tooltip._id = tooltipID
    end
end

local function IsSafeTooltipData(tooltip, lineData)
    if RealUI.isSecret(tooltip) or RealUI.isSecret(lineData) then
        return false
    end
    if type(lineData) ~= "table" then
        return false
    end
    return true
end

local function SetupItemTooltips()
    if _G.issecure and _G.issecure() then
        _G.TooltipDataProcessor.AddTooltipPostCall(TooltipTypeEnums.Item, function(tooltip, tooltipData)
            if RealUI.isSecret(tooltip) or RealUI.isSecret(tooltipData) then
                return
            end
            local _, link = _G.TooltipUtil.GetDisplayedItem(tooltip)
            if link then
                local id = link:match("item:(%d*)")
                if id then
                    AddToTooltip(tooltip, TooltipTypes.item, id)
                end
            end
        end)
    end
end

local function SetupQuestTooltips()
    if _G.issecure and _G.issecure() then
        _G.TooltipDataProcessor.AddLinePreCall(LineTypeEnums.QuestTitle, function(tooltip, lineData)
            if not IsSafeTooltipData(tooltip, lineData) then
                return
            end
            if tooltip._unitToken then
                tooltip._questID = lineData.id
            end

            if tooltip._questID then
                lineData.rightText = formatString:format(TooltipTypes.quest, tooltip._questID)
                lineData.rightColor = Color.gray
            end
        end)
    end
    local function QuestTooltipHook(sender, self, questID, isGroup)
        AddToTooltip(_G.GameTooltip, TooltipTypes.item, questID)
        _G.GameTooltip:Show()
    end

    _G.EventRegistry:RegisterCallback("TaskPOI.TooltipShown", QuestTooltipHook, Inventory)
    _G.EventRegistry:RegisterCallback("QuestPin.OnEnter", QuestTooltipHook, Inventory)
    _G.EventRegistry:RegisterCallback("QuestMapLogTitleButton.OnEnter", QuestTooltipHook, Inventory)
    _G.EventRegistry:RegisterCallback("OnQuestBlockHeader.OnEnter", QuestTooltipHook, Inventory)
end

--[[
local function SetupAchievementTooltips()
    local frame = _G.CreateFrame("frame")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(_, _, addonName)
        if addonName == "Blizzard_AchievementUI" then
            for i, button in ipairs(_G.AchievementFrameAchievementsContainer.buttons) do
                button:HookScript("OnEnter", function()
                    if not _G.GameTooltip:IsOwned(button) then
                        _G.GameTooltip:SetOwner(button, "ANCHOR_NONE")
                        _G.GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
                    end

                    if button.id then
                        AddToTooltip(_G.GameTooltip, TooltipTypes.achievement, button.id)
                    end
                end)
                button:HookScript("OnLeave", function()
                    _G.GameTooltip:Hide()
                end)
            end
            frame:UnregisterEvent("ADDON_LOADED")
        end
    end)
end

local function SetupCurrencyTooltips()
    local function setCurrencyTooltipFunction(dialog, link)
        local currencyID = link:match("currency:(%d+)")
        if currencyID then
            AddToTooltip(dialog, TooltipTypes.currency, currencyID)
        end
    end

    private.AddHook("SetHyperlink", setCurrencyTooltipFunction)
    private.AddHook("SetCurrencyToken", function(dialog, index)
        setCurrencyTooltipFunction(dialog, _G.C_CurrencyInfo.GetCurrencyListLink(index))
    end)
end

local function SetupAzeriteTooltips()
    private.AddHook("SetAzeriteEssence", function(dialog, azeriteID, rank)
        if azeriteID then
            AddToTooltip(dialog, TooltipTypes.azerite, azeriteID)
        end
    end)
end
]]

function private.SetupIDTips()
    --SetupSpellTooltips()
    SetupItemTooltips()
    --SetupUnitTooltips()
    SetupQuestTooltips()
    --SetupAchievementTooltips()
    --SetupCurrencyTooltips()
    --SetupAzeriteTooltips()
end
