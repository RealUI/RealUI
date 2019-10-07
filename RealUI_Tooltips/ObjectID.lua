local _, private = ...

-- Lua Globals --
-- luacheck: globals select tonumber ipairs tinsert

local RealUI = _G.RealUI
local Aurora = _G.Aurora
local Color = Aurora.Color

-- Shamelessly copied from PTRFeedback_Tooltips
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
local function AddToTooltip(tooltip, tooltipType, tooltipID)
    if not tooltip._id then
        local tooltipText = formatString:format(tooltipType, tooltipID)
        tooltip:AddLine(tooltipText, Color.gray.r, Color.gray.g, Color.gray.b)
        tooltip._id = tooltipID
        tooltip:Show()
    end
end

local function SetupSpellTooltips()
    local function setAuraTooltipFunction(self, unit, slotNumber, auraType)
        local id = select(10, _G.UnitAura(unit, slotNumber, auraType))
        if id then
            AddToTooltip(self, TooltipTypes.spell, id)
        end
    end

    _G.hooksecurefunc(_G.GameTooltip, "SetUnitAura", setAuraTooltipFunction)
    _G.hooksecurefunc(_G.GameTooltip, "SetUnitBuff", function(self, unit, slotNumber) setAuraTooltipFunction(self, unit, slotNumber, "HELPFUL") end)
    _G.hooksecurefunc(_G.GameTooltip, "SetUnitDebuff", function(self, unit, slotNumber) setAuraTooltipFunction(self, unit, slotNumber, "HARMFUL") end)

    private.AddHook("OnTooltipSetSpell", function(self)
        local _, id = self:GetSpell()
        if id then
            AddToTooltip(self, TooltipTypes.spell, id)
        end
    end, true)
end

local function SetupItemTooltips()
    private.AddHook("OnTooltipSetItem", function(self)
        local _, link = self:GetItem()
        if link then
            local id = link:match("item:(%d*)")
            if (id == "" or id == "0") and _G.TradeSkillFrame ~= nil and _G.TradeSkillFrame:IsVisible() and _G.GetMouseFocus().reagentIndex then
                local selectedRecipe = _G.TradeSkillFrame.RecipeList:GetSelectedRecipeID()
                for i = 1, 8 do
                    if _G.GetMouseFocus().reagentIndex == i then
                        id = _G.C_TradeSkillUI.GetRecipeReagentItemLink(selectedRecipe, i):match("item:(%d+):") or nil
                        break
                    end
                end
            end
            if id then
                AddToTooltip(self, TooltipTypes.item, id)
            end
        end
    end, true)
end

local function SetupUnitTooltips()
    private.AddHook("OnTooltipSetUnit", function(self)
        local _, unit = self:GetUnit()
        if unit then
            local guid = _G.UnitGUID(unit) or ""
            local id = tonumber(guid:match("-(%d+)-%x+$"), 10)
            if id and (guid:match("%a+") ~= "Player") then
                AddToTooltip(self, TooltipTypes.unit, id)
            end
        end
    end, true)
end

local function SetupQuestTooltips()
    if RealUI.isClassic then return end
    _G.hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
        if self.questID then
            AddToTooltip(_G.GameTooltip, TooltipTypes.quest, self.questID)
        end
    end)
end

function private.SetupIDTips()
    SetupSpellTooltips()
    SetupItemTooltips()
    SetupUnitTooltips()
    SetupQuestTooltips()
end
