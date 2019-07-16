--local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals time next select tonumber tostring

local RealUI = _G.RealUI
local round = RealUI.Round

local Aurora = _G.Aurora
local Color = Aurora.Color

local LOP = _G.LibStub("LibObjectiveProgress-1.0")

local debug = RealUI.GetDebug("Tooltips")
debug = debug

local normalFont = _G.NORMAL_FONT_COLOR

local defaults = {
    global = {
        showTitles = false,
        showRealm = false,
        position = {
            x = -25,
            y = 200,
            point = "BOTTOMRIGHT"
        }
    }
}

local function GetUnit(self)
    debug("GetUnit", self and self:GetName())
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
-- based on GameTooltip_UnitColor
local function GetUnitColor(unit)
    local r, g, b
    if _G.UnitPlayerControlled(unit) then
        local _, class = _G.UnitClass(unit)
        r, g, b = _G.CUSTOM_CLASS_COLORS[class]:GetRGB()
    elseif _G.UnitIsTapDenied(unit) then
        r, g, b = Color.gray:GetRGB()
    else
        local reaction = _G.UnitReaction(unit, "player")
        if reaction then
            r = _G.FACTION_BAR_COLORS[reaction].r
            g = _G.FACTION_BAR_COLORS[reaction].g
            b = _G.FACTION_BAR_COLORS[reaction].b
        else
            r = 1.0
            g = 1.0
            b = 1.0
        end
    end

    --print("unit color", r, g, b)
    return r, g, b
end


local AddDynamicInfo, ClearDynamicInfo do
    local maxAge, quickRefresh = 600, 10
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
        [_G.LE_ITEM_WEAPON_AXE2H] = true,
        [_G.LE_ITEM_WEAPON_MACE2H] = true,
        [_G.LE_ITEM_WEAPON_SWORD2H] = true,

        [_G.LE_ITEM_WEAPON_POLEARM] = true,
        [_G.LE_ITEM_WEAPON_STAFF] = true,

        [_G.LE_ITEM_WEAPON_BOWS] = true,
        [_G.LE_ITEM_WEAPON_CROSSBOW] = true,
        [_G.LE_ITEM_WEAPON_GUNS] = true,

        [_G.LE_ITEM_WEAPON_FISHINGPOLE] = true
    }
    local DualWield = {
        [_G.LE_ITEM_WEAPON_AXE1H] = true,
        [_G.LE_ITEM_WEAPON_MACE1H] = true,
        [_G.LE_ITEM_WEAPON_SWORD1H] = true,

        [_G.LE_ITEM_WEAPON_WARGLAIVE] = true,
        [_G.LE_ITEM_WEAPON_DAGGER] = true,

        [_G.LE_ITEM_WEAPON_GENERIC] = true,
        [_G.LE_ITEM_ARMOR_SHIELD] = true,
    }

    local frame = _G.CreateFrame("Frame")
    frame:RegisterEvent("INSPECT_READY")
    frame:SetScript("OnEvent", function(self, event, guid)
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
                    debug(id, slot)
                    if link then
                        local _, _, rarity, ilvl, _, _, _, _, _, _, _, _, subTypeID = _G.GetItemInfo(link)
                        if rarity and subTypeID then
                            if rarity ~= _G.LE_ITEM_QUALITY_ARTIFACT then
                                ilvl = _G.RealUI.GetItemLevel(link)
                            end

                            debug(ilvl, _G.strsplit("|", link))
                            if not ilvl or ilvl == 0 then
                                debug("No ilvl data for", slot)
                                isMissingInfo = true
                            end

                            if slot == "MainHand" or slot == "SecondaryHand" then
                                if rarity == _G.LE_ITEM_QUALITY_ARTIFACT then
                                    if slot == "MainHand" then
                                        mainArtifact = ilvl
                                    elseif slot == "SecondaryHand" then
                                        offArtifact = ilvl
                                    end
                                else
                                    totalILvl = totalILvl + ilvl
                                end

                                debug("itemClass", subTypeID)

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
                            debug("No item info for", slot)
                            isMissingInfo = true
                        end
                    else
                        debug("No item link for", slot)
                        if slot ~= "SecondaryHand" then
                            isMissingInfo = true
                        end
                    end
                end
            end

            if not isMissingInfo then
                -- Artifacts are counted as one item
                if mainArtifact or offArtifact then
                    debug("Artifacts", mainArtifact, offArtifact)
                    artifactILvl = _G.max(mainArtifact or 0, offArtifact or 0)
                    totalILvl = totalILvl + artifactILvl

                    if offArtifact then
                        totalILvl = totalILvl + artifactILvl
                    end

                    if artifactILvl <= 750 then
                        totalILvl = nil
                    end
                end

                local numItems = 15
                if hasTwoHander or isDualWield then
                    numItems = 16
                end

                if hasTwoHander and not isDualWield then
                    -- Two handers are counted twice
                    totalILvl = totalILvl + hasTwoHander
                end

                local ilvl
                if totalILvl and totalILvl > 0 then
                    debug("totalILvl", totalILvl, numItems)
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
            if not _G.UnitExists(unit) then return end

            local tarRicon, text = (_G.GetRaidTargetIndex(unit))
            debug("tarRicon:", tarRicon, _G.ICON_LIST[tarRicon])

            if tarRicon and _G.ICON_LIST[tarRicon] then
                text = ("%s %s"):format(_G.ICON_LIST[tarRicon].."10|t", GetTarget(unit))
            else
                text = GetTarget(unit)
            end

            if targetLine and text then
                _G["GameTooltipTextLeft"..targetLine]:SetText(_G.TARGET)
                _G["GameTooltipTextRight"..targetLine]:SetText(text)
            elseif not targetLine then
                _G.GameTooltip:AddDoubleLine(_G.TARGET, text, normalFont.r, normalFont.g, normalFont.b, GetUnitColor(unit))
                targetLine = _G.GameTooltip:NumLines()
            end
        end
        function ClearTargetInfo()
            targetLine = nil
        end
    end

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

        AddTargetInfo(unit.."target")
        AddSpecInfo(isPlayer, unit)
        AddItemLevelInfo(isPlayer, unit)

        updateTime = 0
    end)

    function AddDynamicInfo(unit, isPlayer)
        AddTargetInfo(unit.."target")
        AddSpecInfo(isPlayer, unit)
        AddItemLevelInfo(isPlayer, unit)
        frame:Show()
    end

    function ClearDynamicInfo(...)
        ClearTargetInfo()
        ClearSpecInfo()
        ClearItemLevelInfo()
        frame:Hide()
        updateTime = nil
    end
end

local classification = {
    elite = "+",
    rare = " |cff6699ffR|r",
    rareelite = " |cff6699ffR+|r",
    worldboss = (" |cffFF0000%s|r"):format(_G.BOSS)
}
local factionIcon = {
    Alliance = {
        texture = [[Interface\PVPFrame\PVP-Conquest-Misc]],
        coords = {0.693359375, 0.748046875, 0.603515625, 0.732421875}
    },
    Horde = {
        texture = [[Interface\PVPFrame\PVP-Conquest-Misc]],
        coords = {0.638671875, 0.693359375, 0.603515625, 0.732421875},
    },
    Neutral = {
        texture = [[Interface\PVPFrame\TournamentOrganizer]],
        coords = {0.2529296875, 0.3154296875, 0.22265625, 0.298828125},
    },
}
_G.GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    debug("--- OnTooltipSetUnit ---")

    local unit = GetUnit(self)
    debug("unit:", unit)
    if _G.UnitExists(unit) then
        if not self.factionIcon then
            self.factionIcon = self:CreateTexture(nil, "BORDER")
            self.factionIcon:SetPoint("CENTER", _G.GameTooltip, "LEFT", 0, 0)
        end

        local faction =  _G.UnitFactionGroup(unit)
        if _G.UnitIsPVP(unit) then
            local icon = factionIcon[faction or "Neutral"]
            self.factionIcon:SetTexture(icon.texture)
            self.factionIcon:SetTexCoord(icon.coords[1], icon.coords[2], icon.coords[3], icon.coords[4])
            self.factionIcon:SetSize(32, 38)
            self.factionIcon:Show()
        else
            self.factionIcon:Hide()
        end

        local isPlayer = _G.UnitIsPlayer(unit)
        do -- Name
            local lineText = _G.GameTooltipTextLeft1:GetText()
            --print("text", lineText, isPlayer)

            if isPlayer then
                local unitName, server = _G.UnitName(unit)
                --print("player", unitName, defaults.global.showTitles)
                if defaults.global.showTitles then
                    unitName = _G.UnitPVPName(unit) or unitName
                    --print("title", unitName)
                end

                --print("realm", server, defaults.global.showRealm)
                if server and server ~= "" then
                    if defaults.global.showRealm then
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

                --print("name", unitName)
                lineText = unitName
            end

            local iconIndex = _G.GetRaidTargetIndex(unit)
            debug("iconIndex:", iconIndex, _G.ICON_LIST[iconIndex])
            if iconIndex and _G.ICON_LIST[iconIndex] then
                -- iconIndex can be > 8, which is outside ICON_LIST's index
                _G.GameTooltipTextLeft1:SetFormattedText("%s12|t %s", _G.ICON_LIST[iconIndex], lineText)
            else
                _G.GameTooltipTextLeft1:SetText(lineText)
            end
            --print("text", lineText)
            _G.GameTooltipTextLeft1:SetTextColor(GetUnitColor(unit))
        end

        --do return end
        if isPlayer then -- guild
            local unitGuild, unitRank = _G.GetGuildInfo(unit)
            if unitGuild then
                _G.GameTooltipTextLeft2:SetFormattedText("|cffffffb3<%s> |cff00E6A8%s|r", unitGuild, unitRank)
            end
        end

        local level
        local IsBattlePet = _G.UnitIsBattlePet(unit)
        if IsBattlePet then
            level = _G.UnitBattlePetLevel(unit)
        else
            level = _G.UnitLevel(unit)
        end

        local previousLine = 1
        local dead = _G.UnitIsDeadOrGhost(unit)
        if level then
            local unitType
            if isPlayer then
                unitType = ("%s |cff%s%s|r"):format(_G.UnitRace(unit), _G.RealUI.GetColorString(GetUnitColor(unit)), _G.UnitClass(unit))
            elseif IsBattlePet then
                unitType = _G["BATTLE_PET_NAME_".._G.UnitBattlePetType(unit)]
            else
                unitType = _G.UnitCreatureType(unit)
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
                        diff = _G.QuestDifficultyColors["difficult"]
                    end
                else
                    --If you unlocked pet battles but have no team, level ranges are meaningless so make them grey
                    diff = _G.QuestDifficultyColors["header"]
                end
            else
                diff = _G.GetCreatureDifficultyColor(level)
            end

            local classify = _G.UnitClassification(unit) or ""
            local textLevel = ("|cff%s%s%s|r"):format(RealUI.GetColorString(diff), level, classification[classify] or "")

            for i = previousLine + 1, self:NumLines() do
                local tiptext = _G["GameTooltipTextLeft"..i]
                local linetext = tiptext:GetText()

                if linetext and linetext:find(_G.LEVEL) then
                    tiptext:SetFormattedText(("%s %s %s"), textLevel, unitType or "unitType", (dead and "|cffCCCCCC".._G.DEAD.."|r" or ""))
                    previousLine = i
                    break
                end
            end
        end

        do -- Objective Progress
            local npcID = select(6, ("-"):split(_G.UnitGUID(unit)))
            local line, addedProgress

            local challengeMapID = _G.C_ChallengeMode.GetActiveChallengeMapID()
            if challengeMapID then
                local isTeeming = false
                local _, activeAffixIDs = _G.C_ChallengeMode.GetActiveKeystoneInfo()
                for i = 1, #activeAffixIDs do
                    if activeAffixIDs[i] == 5 then
                        isTeeming = true
                        break
                    end
                end

                local _, _, _, _, _, _, _, instanceMapID = _G.GetInstanceInfo()
                local isAlternate = challengeMapID == 234 -- Upper Karazhan
                if instanceMapID == 1822 then -- Siege of Boralus
                    isAlternate = faction == "Horde"
                end

                addedProgress = LOP:GetNPCWeightByMap(instanceMapID, npcID, isTeeming, isAlternate)
            else
                local weightsTable = LOP:GetNPCWeightByCurrentQuests(tonumber(npcID))
                if weightsTable then
                    for questID, npcWeight in next, weightsTable do
                        local questTitle = _G.C_TaskQuest.GetQuestInfoByQuestID(questID)
                        for i = previousLine + 1, self:NumLines() do
                            line = _G["GameTooltipTextLeft" .. i]
                            if line and line:GetText() == questTitle then
                                addedProgress = npcWeight
                                break
                            end
                        end
                    end
                end
            end

            if line and addedProgress then
                line:SetFormattedText(("%s | +%s%%"), line:GetText(), addedProgress)
            end
        end

        AddDynamicInfo(unit, isPlayer)

        if dead then
            _G.GameTooltipStatusBar:Hide()
        end
    end

    --SetStatusBar(self, unit)
end)

local frameColor = Aurora.Color.frame
_G.GameTooltip:HookScript("OnTooltipCleared", function(self)
    if self.factionIcon then
        self.factionIcon:Hide()
    end

    ClearDynamicInfo()

    self:SetBackdropBorderColor(frameColor.r, frameColor.g, frameColor.b)
end)

--local skinsDB = _G.LibStub("AceDB-3.0"):New("RealUI_TooltipsDB", defaults, true)
