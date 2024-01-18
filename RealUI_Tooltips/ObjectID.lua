local _, private = ...

-- Lua Globals --
-- luacheck: globals select tonumber ipairs tinsert

local Inventory = private.Inventory

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
    if not tooltip._id then
        local tooltipText = formatString:format(tooltipType, tooltipID)
        _G.GameTooltip_AddColoredLine(tooltip, tooltipText , Color.gray)
        tooltip._id = tooltipID
    end
end

local function SetupItemTooltips()
    _G.TooltipDataProcessor.AddTooltipPostCall(TooltipTypeEnums.Item, function(tooltip, tooltipData)
        local _, link = _G.TooltipUtil.GetDisplayedItem(tooltip)
        if link then
            local id = link:match("item:(%d*)")
            if id then
                AddToTooltip(tooltip, TooltipTypes.item, id)
            end
        end
    end)
end

local function SetupQuestTooltips()
    _G.TooltipDataProcessor.AddLinePreCall(LineTypeEnums.QuestTitle, function(tooltip, lineData)
        if tooltip._unitToken then
            tooltip._questID = lineData.id
        end

        if tooltip._questID then
            lineData.rightText = formatString:format(TooltipTypes.quest, tooltip._questID)
            lineData.rightColor = Color.gray
        end
    end)
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
    local function setCurrencyTooltipFunction(self, link)
        local currencyID = link:match("currency:(%d+)")
        if currencyID then
            AddToTooltip(self, TooltipTypes.currency, currencyID)
        end
    end

    private.AddHook("SetHyperlink", setCurrencyTooltipFunction)
    private.AddHook("SetCurrencyToken", function(self, index)
        setCurrencyTooltipFunction(self, _G.C_CurrencyInfo.GetCurrencyListLink(index))
    end)
end

local function SetupAzeriteTooltips()
    private.AddHook("SetAzeriteEssence", function(self, azeriteID, rank)
        if azeriteID then
            AddToTooltip(self, TooltipTypes.azerite, azeriteID)
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
