local _, private = ...

-- Lua Globals --
-- luacheck: globals _G pcall time next select tonumber tostring tinsert type pairs

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

-- RealUI --
local RealUI = _G.RealUI
--local FramePoint = RealUI:GetModule("FramePoint")
--local round = RealUI.Round

local Tooltips = RealUI:NewModule("Tooltips", "AceEvent-3.0")
private.Tooltips = Tooltips

local defaults = {
    global = {
        showTitles = true,
        showRealm = false,
        showIDs = false,
        showTransmog = true,
        multiTip = true,
        currency = {},
        questCache = {},
        position = {
            atCursor = false,
            x = -100,
            y = 130,
            point = "BOTTOMRIGHT"
        }
    }
}

local normalFont = _G.NORMAL_FONT_COLOR
local classificationTypes = {
    elite = "+",
    rare = " |cff6699ffR|r",
    rareelite = " |cff6699ffR+|r",
    worldboss = (" |cffFF0000%s|r"):format(_G.BOSS)
}

--[[
local function GetUnit(self)
    Tooltips:debug("GetUnit", self and self:GetName())
    local _, unit = _G.GameTooltip:GetUnit()

    if not unit then
        local focus = _G.GetMouseFocus()
        if focus then
            -- focus might somehow be a FontString, which doesn't have GetAttribute
            unit = focus.unit or (focus.GetAttribute and focus:GetAttribute("unit"))
        end
    end

    return unit or "mouseover"
end
]]
local function IsSafeUnitToken(unit)
    return type(unit) == "string" and not RealUI.isSecret(unit) and unit ~= ""
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

local function IsNonSecretTrue(value)
    if RealUI.isSecret(value) or value == nil then
        return false
    end
    return value == true
end

local function IsNonSecretString(value)
    return type(value) == "string" and not RealUI.isSecret(value)
end

local function GetHighlightRGB()
    local c = _G.HIGHLIGHT_FONT_COLOR
    if c and type(c.r) == "number" and type(c.g) == "number" and type(c.b) == "number" then
        return c.r, c.g, c.b
    end
    return 1, 1, 1
end

local function GetSafeGlobalString(key, fallback)
    local value = _G[key]
    if IsNonSecretString(value) and value ~= "" then
        return value
    end
    return fallback
end

local function FormatMoneyIcons(amount)
    local gold = math.floor(amount / 10000)
    local silver = math.floor((amount % 10000) / 100)
    local copper = amount % 100

    local parts = {}
    if gold > 0 then
        parts[#parts + 1] = ("%d|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t"):format(gold)
    end
    if gold > 0 or silver > 0 then
        parts[#parts + 1] = ("%d|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:2:0|t"):format(silver)
    end
    parts[#parts + 1] = ("%d|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t"):format(copper)
    return table.concat(parts, " ")
end

local function AddTooltipMoneyText(tooltip, amount, prefix)
    if RealUI.isSecret(amount) or type(amount) ~= "number" then
        return
    end

    local moneyText = FormatMoneyIcons(amount)
    if prefix then
        local r, g, b = GetHighlightRGB()
        tooltip:AddDoubleLine(prefix, moneyText, r, g, b, 1, 1, 1)
    else
        tooltip:AddLine(moneyText, 1, 1, 1)
    end
end

local function SafeTooltip_OnTooltipAddMoney(self, cost, maxcost)
    if RealUI.isSecret(cost) or type(cost) ~= "number" then
        return
    end

    if _G.GameTooltip_ClearMoney then
        pcall(_G.GameTooltip_ClearMoney, self)
    end

    if maxcost ~= nil and (RealUI.isSecret(maxcost) or type(maxcost) ~= "number") then
        maxcost = nil
    end

    local sellPrice = GetSafeGlobalString("SELL_PRICE", "Sell Price")
    local minimum = GetSafeGlobalString("MINIMUM", "Minimum")
    local maximum = GetSafeGlobalString("MAXIMUM", "Maximum")

    if maxcost ~= nil and maxcost >= 1 then
        local r, g, b = GetHighlightRGB()
        self:AddLine(("%s:"):format(sellPrice), r, g, b)
        local indent = string.rep(" ", 4)
        AddTooltipMoneyText(self, cost, ("%s%s:"):format(indent, minimum))
        AddTooltipMoneyText(self, maxcost, ("%s%s:"):format(indent, maximum))
    else
        AddTooltipMoneyText(self, cost, string.format("%s:", sellPrice))
    end
end
local function GetUnitColor(unit)
    if not IsSafeUnitToken(unit) then
        return Color.white
    end
    local color
    if IsNonSecretTrue(_G.UnitPlayerControlled(unit)) then
        local _, class = _G.UnitClass(unit)
        color = _G.CUSTOM_CLASS_COLORS[class]
    elseif IsNonSecretTrue(_G.UnitIsTapDenied(unit)) then
        color = Color.gray
    else
        local reaction = _G.UnitReaction(unit, "player")
        if RealUI.isSecret(reaction) or reaction == nil then
            color = Color.white
        else
            color = _G.FACTION_BAR_COLORS[reaction]
        end
    end

    --print("unit color", color:GetRGB())
    return color
end
local function GetUnitName(unit)
    if not IsSafeUnitToken(unit) then
        return "Unknown"
    end
    local unitName, server = _G.UnitName(unit)
    if RealUI.isSecret(unitName) then
        return "Unknown"
    end
    if RealUI.isSecret(server) then
        server = ""
    end
    if Tooltips.db.global.showTitles and not RealUI.isSecret(unit) then
        local pvpName = _G.UnitPVPName(unit)
        if pvpName ~= nil and not RealUI.isSecret(pvpName) then
            unitName = pvpName
        end
    end

    if server and server ~= "" then
        if Tooltips.db.global.showRealm then
            unitName = unitName.."-"..server
        else
            local relationship = _G.UnitRealmRelationship(unit)
            if not RealUI.isSecret(relationship) then
                --print("relationship", relationship)
                if relationship == _G.LE_REALM_RELATION_VIRTUAL then
                    unitName = unitName.._G.INTERACTIVE_SERVER_LABEL
                elseif relationship == _G.LE_REALM_RELATION_COALESCED then
                    unitName = unitName.._G.FOREIGN_SERVER_LABEL
                end
            end
        end
    end

    if not RealUI.isSecret(unit) then
        local iconIndex = (_G.GetRaidTargetIndex(unit))
        if RealUI.isSecret(iconIndex) then
            iconIndex = nil
        end
        if iconIndex and _G.ICON_LIST[iconIndex] then
            unitName = ("%s12|t %s"):format(_G.ICON_LIST[iconIndex], unitName)
        end
    end

    return unitName
end
local function GetUnitClassification(unit)
    if not IsSafeUnitToken(unit) then
        return
    end
    local level
    local IsBattlePet = IsNonSecretTrue(_G.UnitIsBattlePet(unit))
    if IsBattlePet then
        level = _G.UnitBattlePetLevel(unit)
    else
        level = _G.UnitLevel(unit)
    end

    if RealUI.isSecret(level) or level == nil then return end

    local unitType
    if IsNonSecretTrue(_G.UnitIsPlayer(unit)) then
        local unitRace = _G.UnitRace(unit)
        if unitRace == nil or RealUI.isSecret(unitRace) then
            unitRace = ""
        end
        local unitClassName = _G.UnitClass(unit)
        if unitClassName == nil or RealUI.isSecret(unitClassName) then
            unitClassName = ""
        end
        unitType = ("%s |c%s%s|r"):format(unitRace, _G.RealUI.GetColorString(GetUnitColor(unit)), unitClassName)
    elseif IsBattlePet then
        unitType = _G["BATTLE_PET_NAME_".._G.UnitBattlePetType(unit)]
    else
        local creatureType = _G.UnitCreatureType(unit)
        if creatureType == nil or RealUI.isSecret(creatureType) then
            unitType = "unitType"
        else
            unitType = creatureType
        end
    end

    local diff
    if level == -1 then
        level = "??"
        diff = _G.QuestDifficultyColors.impossible
    elseif IsBattlePet then
        local teamLevel = _G.C_PetJournal.GetPetTeamAverageLevel()
        if teamLevel ~= nil and not RealUI.isSecret(teamLevel) then -- from WorldMapFrame.lua: 2522
            if teamLevel < level then
                --add 2 to the min level because it's really hard to fight higher level pets
                diff = _G.GetRelativeDifficultyColor(teamLevel, level + 2)
            elseif teamLevel > level then
                diff = _G.GetRelativeDifficultyColor(teamLevel, level)
            else
                --if your team is in the level range, no need to call the function, just make it yellow
                diff = _G.QuestDifficultyColors.difficult
            end
        else
            --If you unlocked pet battles but have no team, level ranges are meaningless so make them grey
            diff = _G.QuestDifficultyColors.header
        end
    else
        diff = _G.GetCreatureDifficultyColor(level)
    end

    if IsNonSecretTrue(_G.UnitIsDeadOrGhost(unit)) then
        unitType = ("%s |cffCCCCCC%s|r"):format(unitType, _G.DEAD)
    end

    return ("|c%s%s%s|r %s"):format(RealUI.GetColorString(diff), level, classificationTypes[_G.UnitClassification(unit)] or "", unitType)
end

local Hooks = {}
local Scripts = {}
function private.AddHook(name, func, isScript)
    if isScript then
        if not Scripts[name] then
            Scripts[name] = {}
        end
        tinsert(Scripts[name], func)
    else
        if not Hooks[name] then
            Hooks[name] = {}
        end
        tinsert(Hooks[name], func)
    end
end
function private.HookTooltip(tooltip)
    for scriptName, funcs in next, Scripts do
        tooltip:HookScript(scriptName, function(...)
            for i = 1, #funcs do
                funcs[i](tooltip)
            end
        end)
    end

    for hookName, funcs in next, Hooks do
        _G.hooksecurefunc(tooltip, hookName, function(...)
            for i = 1, #funcs do
                funcs[i](...)
            end
        end)
    end
end

--local AddDynamicInfo, ClearDynamicInfo
local factionIcon = {
    Alliance = {
        texture = "pvpqueue-sidebar-honorbar-badge-alliance",
        width = 32,
        height = 38,
    },
    Horde = {
        texture = "pvpqueue-sidebar-honorbar-badge-horde",
        width = 32,
        height = 38,
    },
    Neutral = {
        texture = "UI-HUD-UnitFrame-Player-PVP-FFAIcon",
        width = 28,
        height = 44,
    },
}

--[[
local follow = {
    args = true,
    lines = true,
}
local function PrintDataArgs(note, data, isRec)
    if not isRec then
        print(note)
        note = "data"
    end

    for k, v in next, data do
        print("    "..note, k, v)
        if follow[k] then
            PrintDataArgs("    "..k, v, true)
        end
    end
end
]]

local LineTypeEnums = _G.Enum.TooltipDataLineType
local TooltipTypeEnums = _G.Enum.TooltipDataType
if _G.issecure and _G.issecure() then
    _G.TooltipDataProcessor.AddLinePostCall(LineTypeEnums.QuestTitle, function(tooltip, lineData)
        if not IsSafeTooltipData(tooltip, lineData) then
            return
        end
        if tooltip._unitToken then
            tooltip._questID = lineData.id
        end
    end)
    _G.TooltipDataProcessor.AddLinePreCall(LineTypeEnums.QuestObjective, function(tooltip, lineData)
        if not IsSafeTooltipData(tooltip, lineData) then
            return
        end
        if tooltip._unitToken and tooltip._questID then
            private.AddObjectiveProgress(tooltip, lineData)
        end
    end)
    _G.TooltipDataProcessor.AddLinePreCall(LineTypeEnums.UnitName, function(tooltip, lineData)
        if not IsSafeTooltipData(tooltip, lineData) then
            return
        end
        local unitToken = lineData.unitToken
        if IsSafeUnitToken(unitToken) then
            lineData.leftText = GetUnitName(unitToken)
            lineData.leftColor = GetUnitColor(unitToken)

            tooltip._unitToken = unitToken
        else
            tooltip._unitToken = nil
        end
    end)
    _G.TooltipDataProcessor.AddLinePreCall(LineTypeEnums.None, function(tooltip, lineData)
        if not IsSafeTooltipData(tooltip, lineData) then
            return
        end
        --PrintDataArgs("AddLinePreCall:None", lineData)
        if tooltip._unitToken then
            local unitToken = tooltip._unitToken
            if tooltip:NumLines() == 1 then
                if IsNonSecretTrue(_G.UnitIsPlayer(unitToken)) then
                    local unitGuild, unitRank = _G.GetGuildInfo(unitToken)
                    if unitGuild then
                        lineData.leftText = ("|cffffffb3<%s> |cff00E6A8%s|r"):format(unitGuild, unitRank)
                    end
                end
            end

            local classification = GetUnitClassification(unitToken)
            if classification then
                if IsNonSecretString(lineData.leftText) and lineData.leftText:find(_G.LEVEL) then
                    lineData.leftText = classification
                end
            end
        end
    end)
    _G.TooltipDataProcessor.AddTooltipPostCall(TooltipTypeEnums.Unit, function(tooltip, tooltipData)
        if RealUI.isSecret(tooltip) or RealUI.isSecret(tooltipData) then
            return
        end
        if not tooltip.factionIcon then
            tooltip.factionIcon = tooltip:CreateTexture(nil, "BORDER")
            tooltip.factionIcon:SetPoint("CENTER", tooltip, "LEFT", 0, 0)
        end

        local unitToken = tooltip._unitToken
        if not IsSafeUnitToken(unitToken) then
            tooltip.factionIcon:Hide()
            return
        end

        if IsNonSecretTrue(_G.UnitIsPVP(unitToken)) then
            local unitFactionGroup = _G.UnitFactionGroup(unitToken)
            if not IsNonSecretString(unitFactionGroup) then
                unitFactionGroup = "Neutral"
            end
            local icon = factionIcon[unitFactionGroup] or factionIcon.Neutral
            tooltip.factionIcon:SetAtlas(icon.texture)
            tooltip.factionIcon:SetSize(icon.width, icon.height)
            tooltip.factionIcon:Show()
        else
            tooltip.factionIcon:Hide()
        end

        --private.AddObjectiveProgress(tooltip, unitToken, previousLine)

        local unitTarget = unitToken.."target"
        if IsNonSecretTrue(_G.UnitExists(unitTarget)) then
            local text
            if IsNonSecretTrue(_G.UnitIsUnit(unitTarget, "player")) then
                text = ("|cffff0000%s|r"):format("> ".._G.YOU.." <")
            else
                text = GetUnitName(unitTarget)
            end

            if text then
                _G.GameTooltip_AddColoredDoubleLine(tooltip, _G.TARGET, text, normalFont, GetUnitColor(unitTarget))
            end
        end
    end)
end

local TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN_CHECKMARK = "|A:common-icon-checkmark:16:16:0:-1|a ".._G.TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN;
if _G.issecure and _G.issecure() then
    _G.TooltipDataProcessor.AddTooltipPostCall(TooltipTypeEnums.Item, function(tooltip, tooltipData)
        if RealUI.isSecret(tooltip) or RealUI.isSecret(tooltipData) then
            return
        end
        local owner = tooltip:GetOwner()
        if (owner and owner.GetParent) and owner:GetParent() == _G.DressUpFrame.CustomSetDetailsPanel then
            return
        end

        --PrintDataArgs("AddTooltipPostCall:Item", tooltipData)
        local _, link = _G.TooltipUtil.GetDisplayedItem(tooltip)
        if Tooltips.db.global.showTransmog and link then
            local itemAppearanceID, itemModifiedAppearanceID = _G.C_TransmogCollection.GetItemInfo(link)
            if itemAppearanceID and itemModifiedAppearanceID then
                local sourceInfo = _G.C_TransmogCollection.GetSourceInfo(itemModifiedAppearanceID)
                if _G.C_TransmogCollection.PlayerHasTransmog(sourceInfo.itemID, sourceInfo.itemModID) then
                    _G.GameTooltip_AddColoredLine(tooltip, TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN_CHECKMARK , _G.GREEN_FONT_COLOR)
                end
                local _, canCollect =_G.C_TransmogCollection.PlayerCanCollectSource(itemModifiedAppearanceID)
                if not canCollect then
                    local invSlot = _G.C_Transmog.GetSlotForInventoryType(sourceInfo.invType)
                    _, canCollect = _G.C_TransmogCollection.AccountCanCollectSource(itemModifiedAppearanceID)
                    if not canCollect and (invSlot == _G.INVSLOT_MAINHAND or invSlot == _G.INVSLOT_OFFHAND) then
                        local pairedTransmogID = _G.C_TransmogCollection.GetPairedArtifactAppearance(itemModifiedAppearanceID);
                        if pairedTransmogID then
                            _, canCollect = _G.C_TransmogCollection.AccountCanCollectSource(pairedTransmogID);
                        end
                    end

                    if canCollect then
                        _G.GameTooltip_AddErrorLine(tooltip, _G.TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNUSABLE)
                    else
                        _G.GameTooltip_AddErrorLine(tooltip, _G.TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNCOLLECTABLE)
                    end
                end
            end
        end
    end)
end

--[[
private.AddHook("OnTooltipSetUnit", function(dialog)
    Tooltips:debug("--- OnTooltipSetUnit ---")
    local unit = GetUnit(dialog)
    if not _G.UnitExists(unit) then return end
    Tooltips:debug("unit:", unit)


    private.AddObjectiveProgress(dialog, unit, previousLine)

    AddDynamicInfo(unit, _G.UnitIsPlayer(unit))

    if _G.UnitIsDeadOrGhost(unit) then
        _G.GameTooltipStatusBar:Hide()
    end
end, true)

]]

local frameColor = Aurora.Color.frame
private.AddHook("OnTooltipCleared", function(tooltip)
    tooltip._unitToken = nil
    tooltip._questID = nil
    if tooltip.factionIcon then
        tooltip.factionIcon:Hide()
    end

    --ClearDynamicInfo()
    tooltip._id = nil
    tooltip.NineSlice:SetBorderColor(frameColor.r, frameColor.g, frameColor.b)
end, true)

function Tooltips:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_TooltipsDB", defaults, true)

    --[[
    FramePoint:RegisterMod(self)
    FramePoint:PositionFrame(self, tooltipAnchor, {"global", "position"})
    Tooltips:PositionAnchor()

    if RealUI.realmInfo.realmNormalized then
        private.SetupCurrency()
    else
        self:RegisterMessage("CurrencyDBInitialized", private.SetupCurrency)
    end

    if self.db.global.multiTip then
        private.SetupMultiTip()
    end
    ]]
    if self.db.global.showIDs then
        private.SetupIDTips()
    end
    private.questCache = self.db.global.questCache
    for _, tooltip in next, {_G.GameTooltip, _G.ItemRefTooltip} do
        private.HookTooltip(tooltip)
    end

    if not private._moneyHooked and type(_G.GameTooltip_OnTooltipAddMoney) == "function" then
        private._moneyHooked = true
        private._origGameTooltip_OnTooltipAddMoney = _G.GameTooltip_OnTooltipAddMoney
        _G.GameTooltip_OnTooltipAddMoney = SafeTooltip_OnTooltipAddMoney
    end

    if not private._moneyFrameUpdateHooked and type(_G.MoneyFrame_Update) == "function" then
        private._moneyFrameUpdateHooked = true
        private._origMoneyFrame_Update = _G.MoneyFrame_Update
        _G.MoneyFrame_Update = function(frameName, money, forceShow)
            if RealUI.isSecret(frameName) or RealUI.isSecret(money) or RealUI.isSecret(forceShow) then
                return
            end

            local ok, result = pcall(private._origMoneyFrame_Update, frameName, money, forceShow)
            if ok then
                return result
            end
        end
    end

    if not private._setTooltipMoneyHooked and type(_G.SetTooltipMoney) == "function" then
        private._setTooltipMoneyHooked = true
        private._origSetTooltipMoney = _G.SetTooltipMoney
        _G.SetTooltipMoney = function(frame, money, moneyType, prefixText, suffixText)
            if RealUI.isSecret(frame) or RealUI.isSecret(money) or RealUI.isSecret(moneyType)
                or RealUI.isSecret(prefixText) or RealUI.isSecret(suffixText) then
                return
            end

            local ok, result = pcall(private._origSetTooltipMoney, frame, money, moneyType, prefixText, suffixText)
            if ok then
                return result
            end

            if type(frame) == "table" and type(frame.AddLine) == "function" then
                local prefix = prefixText
                if not prefix or prefix == "" then
                    prefix = suffixText
                end
                AddTooltipMoneyText(frame, money, prefix)
            end
        end
    end
end
