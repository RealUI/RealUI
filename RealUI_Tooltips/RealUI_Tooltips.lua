local _, private = ...

-- Lua Globals --
-- luacheck: globals time next select tonumber tostring tinsert

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
local function GetUnitColor(unit)
    local color
    if _G.UnitPlayerControlled(unit) then
        local _, class = _G.UnitClass(unit)
        color = _G.CUSTOM_CLASS_COLORS[class]
    elseif _G.UnitIsTapDenied(unit) then
        color = Color.gray
    else
        local reaction = _G.UnitReaction(unit, "player")
        if reaction then
            color = _G.FACTION_BAR_COLORS[reaction]
        else
            color = Color.white
        end
    end

    --print("unit color", color:GetRGB())
    return color
end
local function GetUnitName(unit)
    local unitName, server = _G.UnitName(unit)
    if Tooltips.db.global.showTitles then
        unitName = _G.UnitPVPName(unit) or unitName
    end

    if server and server ~= "" then
        if Tooltips.db.global.showRealm then
            unitName = unitName.."-"..server
        else
            local relationship = _G.UnitRealmRelationship(unit)
            --print("relationship", relationship)
            if relationship == _G.LE_REALM_RELATION_VIRTUAL then
                unitName = unitName.._G.INTERACTIVE_SERVER_LABEL
            elseif relationship == _G.LE_REALM_RELATION_COALESCED then
                unitName = unitName.._G.FOREIGN_SERVER_LABEL
            end
        end
    end

    local iconIndex = (_G.GetRaidTargetIndex(unit))
    if iconIndex and _G.ICON_LIST[iconIndex] then
        unitName = ("%s12|t %s"):format(_G.ICON_LIST[iconIndex], unitName)
    end

    return unitName
end
local function GetUnitClassification(unit)
    local level
    local IsBattlePet = _G.UnitIsBattlePet(unit)
    if IsBattlePet then
        level = _G.UnitBattlePetLevel(unit)
    else
        level = _G.UnitLevel(unit)
    end

    if not level then return end

    local unitType
    if _G.UnitIsPlayer(unit) then
        unitType = ("%s |c%s%s|r"):format(_G.UnitRace(unit), _G.RealUI.GetColorString(GetUnitColor(unit)), _G.UnitClass(unit))
    elseif IsBattlePet then
        unitType = _G["BATTLE_PET_NAME_".._G.UnitBattlePetType(unit)]
    else
        unitType = _G.UnitCreatureType(unit) or "unitType"
    end

    local diff
    if level == -1 then
        level = "??"
        diff = _G.QuestDifficultyColors.impossible
    elseif IsBattlePet then
        local teamLevel = _G.C_PetJournal.GetPetTeamAverageLevel()
        if teamLevel then -- from WorldMapFrame.lua: 2522
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

    if _G.UnitIsDeadOrGhost(unit) then
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

_G.TooltipDataProcessor.AddLinePostCall(LineTypeEnums.QuestTitle, function(tooltip, lineData)
    if tooltip._unitToken then
        tooltip._questID = lineData.id
    end
end)
_G.TooltipDataProcessor.AddLinePreCall(LineTypeEnums.QuestObjective, function(tooltip, lineData)
    if tooltip._unitToken and tooltip._questID then
        private.AddObjectiveProgress(tooltip, lineData)
    end
end)
_G.TooltipDataProcessor.AddLinePreCall(LineTypeEnums.UnitName, function(tooltip, lineData)
    local unitToken = lineData.unitToken
    if unitToken then
        lineData.leftText = GetUnitName(unitToken)
        lineData.leftColor = GetUnitColor(unitToken)

        tooltip._unitToken = unitToken
    end
end)
_G.TooltipDataProcessor.AddLinePreCall(LineTypeEnums.None, function(tooltip, lineData)
    --PrintDataArgs("AddLinePreCall:None", lineData)
    if tooltip._unitToken then
        local unitToken = tooltip._unitToken
        if tooltip:NumLines() == 1 then
            if _G.UnitIsPlayer(unitToken) then
                local unitGuild, unitRank = _G.GetGuildInfo(unitToken)
                if unitGuild then
                    lineData.leftText = ("|cffffffb3<%s> |cff00E6A8%s|r"):format(unitGuild, unitRank)
                end
            end
        end

        local classification = GetUnitClassification(unitToken)
        if classification then
            if lineData.leftText:find(_G.LEVEL) then
                lineData.leftText = classification
            end
        end
    end
end)
_G.TooltipDataProcessor.AddTooltipPostCall(TooltipTypeEnums.Unit, function(tooltip, tooltipData)
    if not tooltip.factionIcon then
        tooltip.factionIcon = tooltip:CreateTexture(nil, "BORDER")
        tooltip.factionIcon:SetPoint("CENTER", tooltip, "LEFT", 0, 0)
    end

    local unitToken = tooltip._unitToken
    if not unitToken then return end

    if _G.UnitIsPVP(unitToken) then
        local icon = factionIcon[_G.UnitFactionGroup(unitToken) or "Neutral"]
        tooltip.factionIcon:SetAtlas(icon.texture)
        tooltip.factionIcon:SetSize(icon.width, icon.height)
        tooltip.factionIcon:Show()
    end

    --private.AddObjectiveProgress(tooltip, unitToken, previousLine)

    local unitTarget = unitToken.."target"
    if _G.UnitExists(unitTarget) then
        local text
        if _G.UnitIsUnit(unitTarget, "player") then
            text = ("|cffff0000%s|r"):format("> ".._G.YOU.." <")
        else
            text = GetUnitName(unitTarget)
        end

        _G.GameTooltip_AddColoredDoubleLine(tooltip, _G.TARGET, text, normalFont, GetUnitColor(unitTarget))
    end
end)

local TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN_CHECKMARK = "|A:common-icon-checkmark:16:16:0:-1|a ".._G.TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN;
_G.TooltipDataProcessor.AddTooltipPostCall(TooltipTypeEnums.Item, function(tooltip, tooltipData)
    local owner = tooltip:GetOwner()
    if (owner and owner.GetParent) and owner:GetParent() == _G.DressUpFrame.OutfitDetailsPanel then
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


--[=[
local tooltipAnchor = _G.CreateFrame("Frame", "RealUI_TooltipsAnchor", _G.UIParent)
tooltipAnchor:SetSize(50, 50)
local pollingRate, tooltipTicker = 0.05
local function UpdateAnchor()
    local x, y = _G.GetScaledCursorPosition()
    local uiX, uiY = RealUI.GetInterfaceSize()

    local point = Tooltips.db.global.position.point
    if point:find("RIGHT") then
        x = x - uiX
    elseif not point:find("LEFT") then
        x = x - (uiX / 2)
    end

    if point:find("TOP") then
        y = y - uiY
    elseif not point:find("BOTTOM") then
        y = y - (uiY / 2)
    end

    tooltipAnchor:ClearAllPoints()
    tooltipAnchor:SetPoint(point, _G.UIParent, x, y)
end
function Tooltips:PositionAnchor()
    if Tooltips.db.global.position.atCursor then
        if not tooltipTicker then
            tooltipTicker = _G.C_Timer.NewTicker(pollingRate, UpdateAnchor)
        end
    elseif tooltipTicker then
        tooltipTicker:Cancel()
        tooltipTicker = nil
    end

    if not tooltipTicker then
        FramePoint:RestorePosition(Tooltips)
    end
end

do -- AddDynamicInfo, ClearDynamicInfo
    local maxAge, quickRefresh = 600, 10
    local ItemWeaponSubclass = _G.Enum.ItemWeaponSubclass
    local ItemArmorSubclass = _G.Enum.ItemArmorSubclass
    local cache = {}

    local function IsCacheFresh(guid)
        if cache[guid] and cache[guid].time then
            return (time() - cache[guid].time) < maxAge
        end
    end

    local slots = {
        "Head",
        "Neck",
        "Shoulder",
        "Shirt",
        "Chest",
        "Waist",
        "Legs",
        "Feet",
        "Wrist",
        "Hands",
        "Finger0",
        "Finger1",
        "Trinket0",
        "Trinket1",
        "Back",
        "MainHand",
        "SecondaryHand",
    }
    local TwoHanders = {
        [ItemWeaponSubclass.Axe2H] = true,
        [ItemWeaponSubclass.Mace2H] = true,
        [ItemWeaponSubclass.Sword2H] = true,

        [ItemWeaponSubclass.Polearm] = true,
        [ItemWeaponSubclass.Staff] = true,

        [ItemWeaponSubclass.Bows] = true,
        [ItemWeaponSubclass.Crossbow] = true,
        [ItemWeaponSubclass.Guns] = true,

        [ItemWeaponSubclass.Fishingpole] = true
    }
    local DualWield = {
        [ItemWeaponSubclass.Axe1H] = true,
        [ItemWeaponSubclass.Mace1H] = true,
        [ItemWeaponSubclass.Sword1H] = true,

        [ItemWeaponSubclass.Warglaive] = true,
        [ItemWeaponSubclass.Dagger] = true,

        [ItemWeaponSubclass.Generic] = true,
        [ItemArmorSubclass.Shield] = true,
    }

    local frame = _G.CreateFrame("Frame")
    frame:RegisterEvent("INSPECT_READY")
    frame:SetScript("OnEvent", function(dialog, event, guid)
        if not cache[guid] or _G.UnitGUID(cache[guid].unit) ~= guid then return end
        local unit = cache[guid].unit


        if not _G.CanInspect(unit) then return end
        cache[guid].time = time()
        local isMissingInfo

        do -- spec
            local specID = _G.GetInspectSpecialization(unit)
            if specID then
                local _, specName = _G.GetSpecializationInfoByID(specID, _G.UnitSex(unit))
                cache[guid].spec = specName
            else
                isMissingInfo = true
            end
        end

        do -- item level
            local totalILvl = 0
            local hasTwoHander, isDualWield
            local artifactILvl, mainArtifact, offArtifact

            for id, slot in next, slots do
                if slot ~= "Shirt" then
                    local link = _G.GetInventoryItemLink(cache[guid].unit, id)
                    Tooltips:debug(id, slot)
                    if link then
                        local _, _, rarity, ilvl, _, _, _, _, _, _, _, _, subTypeID = _G.C_Item.GetItemInfo(link)
                        if rarity and subTypeID then
                            if rarity ~= _G.Enum.ItemQuality.Artifact then
                                ilvl = _G.RealUI.GetItemLevel(link)
                            end

                            Tooltips:debug(ilvl, _G.strsplit("|", link))
                            if not ilvl or ilvl == 0 then
                                Tooltips:debug("No ilvl data for", slot)
                                isMissingInfo = true
                            end

                            if slot == "MainHand" or slot == "SecondaryHand" then
                                if rarity == _G.Enum.ItemQuality.Artifact then
                                    if slot == "MainHand" then
                                        mainArtifact = ilvl
                                    elseif slot == "SecondaryHand" then
                                        offArtifact = ilvl
                                    end
                                else
                                    totalILvl = totalILvl + ilvl
                                end

                                Tooltips:debug("itemClass", subTypeID)

                                if subTypeID then
                                    if slot == "MainHand" then
                                        hasTwoHander = TwoHanders[subTypeID] and ilvl
                                    elseif slot == "SecondaryHand" then
                                        if hasTwoHander then
                                            isDualWield = TwoHanders[subTypeID] -- Titan's Grip
                                        else
                                            isDualWield = DualWield[subTypeID]
                                        end
                                    end
                                end
                            else
                                totalILvl = totalILvl + ilvl
                            end
                        else
                            Tooltips:debug("No item info for", slot)
                            isMissingInfo = true
                        end
                    else
                        Tooltips:debug("No item link for", slot)
                        if slot ~= "SecondaryHand" then
                            isMissingInfo = true
                        end
                    end
                end
            end

            if not isMissingInfo then
                -- Artifacts are counted as one item
                if mainArtifact or offArtifact then
                    Tooltips:debug("Artifacts", mainArtifact, offArtifact)
                    artifactILvl = _G.max(mainArtifact or 0, offArtifact or 0)
                    totalILvl = totalILvl + artifactILvl

                    if offArtifact then
                        totalILvl = totalILvl + artifactILvl
                    end

                    if artifactILvl < 20 then
                        totalILvl = nil
                    end
                end

                local numItems = 15
                if hasTwoHander or isDualWield then
                    numItems = 16
                end

                if totalILvl and (hasTwoHander and not isDualWield) then
                    -- Two handers are counted twice
                    totalILvl = totalILvl + hasTwoHander
                end

                local ilvl
                if totalILvl and totalILvl > 0 then
                    Tooltips:debug("totalILvl", totalILvl, numItems)
                    ilvl = round(totalILvl / numItems)
                end
                cache[guid].ilvl = ilvl
            end
        end

        if isMissingInfo then
            cache[guid].time = cache[guid].time - (maxAge - quickRefresh)
        end
    end)

    local function GetInspectInfo(infoType, unit)
        local guid = _G.UnitGUID(unit)
        if IsCacheFresh(guid) then
            return cache[guid][infoType]
        else
            if _G.CanInspect(unit) then
                if not cache[guid] then
                    cache[guid] = {}
                end

                cache[guid].unit = unit
                _G.NotifyInspect(unit)
            end
        end
    end

    --[[
    local AddTargetInfo, ClearTargetInfo do
        local targetLine
        local targetYou = ">".._G.YOU.."<"

        local function GetTarget(unit)
            if _G.UnitIsUnit(unit, "player") then
                return ("|cffff0000%s|r"):format(targetYou)
            else
                return _G.UnitName(unit)
            end
        end

        function AddTargetInfo(unit)
            local leftText, rightText
            if _G.UnitExists(unit) then
                local tarRicon = (_G.GetRaidTargetIndex(unit))
                Tooltips:debug("tarRicon:", tarRicon, _G.ICON_LIST[tarRicon])

                leftText = _G.TARGET
                if tarRicon and _G.ICON_LIST[tarRicon] then
                    rightText = ("%s %s"):format(_G.ICON_LIST[tarRicon].."10|t", GetTarget(unit))
                else
                    rightText = GetTarget(unit)
                end
            else
                leftText = "target"
                rightText = ""
            end


            if targetLine and leftText then
                _G["GameTooltipTextLeft"..targetLine]:SetText(leftText)
                _G["GameTooltipTextRight"..targetLine]:SetText(rightText)
                _G["GameTooltipTextRight"..targetLine]:SetTextColor(GetUnitColor(unit))
            elseif not targetLine then
                _G.GameTooltip:AddDoubleLine(leftText, rightText, normalFont.r, normalFont.g, normalFont.b, GetUnitColor(unit))
                targetLine = _G.GameTooltip:NumLines()
            end
        end
        function ClearTargetInfo()
            targetLine = nil
        end
    end
    ]]

    local AddSpecInfo, ClearSpecInfo do
        local specLine
        local function GetSpec(unit)
            return GetInspectInfo("spec", unit)
        end

        function AddSpecInfo(isPlayer, unit)
            if not isPlayer then return end

            local spec = GetSpec(unit)
            if specLine and spec then
                _G["GameTooltipTextLeft"..specLine]:SetText(_G.SPECIALIZATION)
                _G["GameTooltipTextRight"..specLine]:SetText(spec)
            elseif not specLine then
                _G.GameTooltip:AddDoubleLine(_G.SPECIALIZATION, spec or _G.SEARCH_LOADING_TEXT, normalFont.r, normalFont.g, normalFont.b, 1,1,1)
                specLine = _G.GameTooltip:NumLines()
            end
        end
        function ClearSpecInfo()
            specLine = nil
        end
    end

    local AddItemLevelInfo, ClearItemLevelInfo do
        local iLvlLine

        local function GetItemLevel(unit)
            if _G.UnitIsUnit(unit, "player") then
                local _, avgItemLevelEquipped = _G.GetAverageItemLevel()
                return avgItemLevelEquipped
            else
                return GetInspectInfo("ilvl", unit)
            end
        end

        function AddItemLevelInfo(isPlayer, unit)
            if not isPlayer then return end

            local iLvl = GetItemLevel(unit)
            if iLvl and iLvl <= 0 then
                iLvl  = nil
            end

            if iLvlLine and iLvl then
                _G["GameTooltipTextLeft"..iLvlLine]:SetText(_G.ITEM_LEVEL_ABBR)
                _G["GameTooltipTextRight"..iLvlLine]:SetText(iLvl)
            elseif not iLvlLine then
                _G.GameTooltip:AddDoubleLine(_G.ITEM_LEVEL_ABBR, iLvl or _G.SEARCH_LOADING_TEXT, normalFont.r, normalFont.g, normalFont.b, 1,1,1)
                iLvlLine = _G.GameTooltip:NumLines()
            end
        end
        function ClearItemLevelInfo()
            iLvlLine = nil
        end
    end

    local updateTime = 0
    frame:SetScript("OnUpdate", function(self, elapsed)
        updateTime = (updateTime or 0) + elapsed
        if updateTime < 1 then return end

        local unit = GetUnit(_G.GameTooltip)
        local isPlayer = _G.UnitIsPlayer(unit)

        --AddTargetInfo(unit.."target")
        AddSpecInfo(isPlayer, unit)
        AddItemLevelInfo(isPlayer, unit)

        updateTime = 0
    end)

    function AddDynamicInfo(unit, isPlayer)
        --AddTargetInfo(unit.."target")
        AddSpecInfo(isPlayer, unit)
        AddItemLevelInfo(isPlayer, unit)
        frame:Show()
    end

    function ClearDynamicInfo(...)
        --ClearTargetInfo()
        ClearSpecInfo()
        ClearItemLevelInfo()
        frame:Hide()
        updateTime = nil
    end
end
]=]


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
end
