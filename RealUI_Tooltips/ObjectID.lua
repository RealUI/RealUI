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
-- Per-tooltip state from RealUI_Tooltips.lua (weak tables, not tooltip fields)
local tipUnit, tipQuest, tipID = private.tipUnit, private.tipQuest, private.tipID
--local formatStringGray = Color.gray:WrapTextInColorCode(formatString)
local function AddToTooltip(tooltip, tooltipType, tooltipID)
    if RealUI.isSecret(tooltip) or RealUI.isSecret(tooltipType) or RealUI.isSecret(tooltipID) then
        return
    end
    if not tipID[tooltip] then
        local tooltipText = formatString:format(tooltipType, tooltipID)
        _G.GameTooltip_AddColoredLine(tooltip, tooltipText , Color.gray)
        tipID[tooltip] = tooltipID
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
            if tipUnit[tooltip] then
                tipQuest[tooltip] = lineData.id
            end

            if tipQuest[tooltip] then
                lineData.rightText = formatString:format(TooltipTypes.quest, tipQuest[tooltip])
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

function private.SetupIDTips()
    SetupItemTooltips()
    SetupQuestTooltips()
end
