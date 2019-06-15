local ADDON_NAME, ns = ...

-- [[ Lua Globals ]]
-- luacheck: globals next type select ipairs time

local Aurora = _G.Aurora
local Base = Aurora.Base
local round = _G.RealUI.Round

local cfg = {
    -- modifications
    --point = { "BOTTOMRIGHT", -25, 200 },
    cursor = false,

    hideTitles = false,
    hideRealm = true,
    hideFaction = true,
    hidePvP = true,
    hideHealthbar = false,

    colorborderClass = true,
    colorborderItem = true,

    combathide = true,     -- world objects
    combathideALL = false,  -- everything


    -- additions
    powerbar = true, -- enable power bars
    powerManaOnly = true, -- only show mana users
    you = "<You>",

    showFactionIcon = true,
    showRank = true, -- show guild rank

    multiTip = true, -- show more than one linked item tooltip
}
ns.cfg = cfg

local COALESCED_REALM_TOOLTIP1 = _G.strsplit(_G.FOREIGN_SERVER_LABEL, _G.COALESCED_REALM_TOOLTIP)
local INTERACTIVE_REALM_TOOLTIP1 = _G.strsplit(_G.INTERACTIVE_SERVER_LABEL, _G.INTERACTIVE_REALM_TOOLTIP)

ns.Debug = _G.RealUI.GetDebug(ADDON_NAME)

local colors = {power = {}}
for power, color in next, _G.PowerBarColor do
    if type(power) == "string" then
        colors.power[power] = {color.r, color.g, color.b}
    end
end
colors.power.MANA = {.2, .2, 1}
colors.power.RAGE = {1, .2, .2}
local normal = _G.NORMAL_FONT_COLOR

local numberize = function(val)
    if val >= 1e6 then
        return ("%.0fm"):format(val / 1e6)
    elseif val >= 1e3 then
        return ("%.0fk"):format(val / 1e3)
    else
        return ("%d"):format(val)
    end
end

local hex = function(color)
    return (color.r and ("|cff%s"):format(_G.RealUI.GetColorString(color))) or "|cffFFFFFF"
end

local function GameTooltip_UnitColor(unit)
    local r, g, b
    if _G.UnitPlayerControlled(unit) then
        local _, class = _G.UnitClass(unit)
        r = _G.CUSTOM_CLASS_COLORS[class].r
        g = _G.CUSTOM_CLASS_COLORS[class].g
        b = _G.CUSTOM_CLASS_COLORS[class].b
    elseif _G.UnitIsTapDenied(unit) then
        r = 0.6
        g = 0.6
        b = 0.6
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

    return r, g, b
end

local function GetUnit(self)
    ns.Debug("GetUnit", self and self:GetName())
    local _, unit
    if self then
        _, unit = self:GetUnit()
    end

    if not unit then
        local mFocus = _G.GetMouseFocus()
        if mFocus then
            -- mFocus might somehow be a FontString, which doesn't have GetAttribute
            unit = mFocus.unit or (mFocus.GetAttribute and mFocus:GetAttribute("unit"))
        end
    end

    return unit or "mouseover"
end
ns.GetUnit = GetUnit

local function hideLines(self)
    for i = 3, self:NumLines() do
        local tiptext = _G["GameTooltipTextLeft"..i]
        local linetext = tiptext:GetText()

        if linetext then
            if cfg.hidePvP and linetext:find(_G.PVP) then
                tiptext:SetText(nil)
                tiptext:Hide()
            elseif linetext:find(COALESCED_REALM_TOOLTIP1) or linetext:find(INTERACTIVE_REALM_TOOLTIP1) then
                tiptext:SetText(nil)
                tiptext:Hide()

                local pretiptext = _G["GameTooltipTextLeft"..i-1]
                pretiptext:SetText(nil)
                pretiptext:Hide()

                self:Show()
            elseif linetext == _G.FACTION_ALLIANCE then
                if cfg.hideFaction then
                    tiptext:SetText(nil)
                    tiptext:Hide()
                else
                    tiptext:SetText("|cff7788FF"..linetext.."|r")
                end
            elseif linetext == _G.FACTION_HORDE then
                if cfg.hideFaction then
                    tiptext:SetText(nil)
                    tiptext:Hide()
                else
                    tiptext:SetText("|cffFF4444"..linetext.."|r")
                end
            end
        end
    end
end

local function HidePower(powerbar)
    if powerbar then
        powerbar:Hide()
    end
end

local function ShowPowerBar(self, unit, statusbar)
    local powerbar = _G[self:GetName().."FreebTipPowerBar"]
    if not unit then return HidePower(powerbar) end

    local min, max = _G.UnitPower(unit), _G.UnitPowerMax(unit)
    local _, ptoken = _G.UnitPowerType(unit)
    if max == 0 or (cfg.powerManaOnly and ptoken ~= 'MANA') then
        return HidePower(powerbar)
    end

    if not powerbar then
        powerbar = _G.CreateFrame("StatusBar", self:GetName().."FreebTipPowerBar", statusbar)
        powerbar:SetHeight(8)
        powerbar:SetPoint("TOPLEFT", statusbar, "BOTTOMLEFT", 0, -2)
        powerbar:SetPoint("TOPRIGHT", statusbar, "BOTTOMRIGHT", 0, -2)

        local texture = powerbar:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints()
        Base.SetTexture(texture, "gradientUp")
        powerbar:SetStatusBarTexture(texture)

        local bg = powerbar:CreateTexture(nil, "BACKGROUND")
        bg:SetColorTexture(0, 0, 0)
        bg:SetPoint("TOPLEFT", -1, 1)
        bg:SetPoint("BOTTOMRIGHT", 1, -1)

        local text = powerbar:CreateFontString(nil, "OVERLAY")
        text:SetPoint("CENTER", powerbar)
        text:SetFontObject(_G.TextStatusBarText)
        powerbar.text = text
    end

    powerbar.unit = unit
    powerbar:SetMinMaxValues(0, max)
    powerbar:SetValue(min)
    powerbar.text:SetText(numberize(min).." / "..numberize(max))

    local color = colors.power[ptoken]
    if color then
        powerbar:SetStatusBarColor(color[1], color[2], color[3])
    end

    powerbar:Show()
end

local function PlayerName(self, unit)
    local unitName, server = _G.UnitName(unit)
    if not cfg.hideTitles then
        -- if the unit is out of range, this will be nil
        unitName = _G.UnitPVPName(unit) or unitName
    end

    if server and server ~= "" then
        if cfg.hideRealm then
            if _G.UnitRealmRelationship(unit) == _G.LE_REALM_RELATION_COALESCED then
                unitName = unitName.._G.FOREIGN_SERVER_LABEL
            end
        else
            unitName = unitName.."-"..server
        end
    end

    local status
    if not _G.UnitIsConnected(unit) then
        status = _G.PLAYER_OFFLINE
    elseif _G.UnitIsAFK(unit) then
        status = _G.CHAT_FLAG_AFK
    elseif _G.UnitIsDND(unit) then
        status = _G.CHAT_FLAG_DND
    end

    if status then
        _G.GameTooltipTextLeft1:SetFormattedText("%s |cff00cc00%s|r", unitName, status)
    else
        _G.GameTooltipTextLeft1:SetText(unitName)
    end
end

local function PlayerGuild(self, unit)
    local unitGuild, unitRank = _G.GetGuildInfo(unit)
    if unitGuild then
        unitRank = cfg.showRank and unitRank or ""
        _G.GameTooltipTextLeft2:SetFormattedText("|cffffffb3<%s> |cff00E6A8%s|r", unitGuild, unitRank)
    end
end

local function SetStatusBar(self, unit)
    if _G.GameTooltipStatusBar:IsShown() then
        if cfg.hideHealthbar then
            _G.GameTooltipStatusBar:Hide()
            return
        end

        if cfg.powerbar then
            ShowPowerBar(self, unit, _G.GameTooltipStatusBar)
        end
    end

    if unit then
        _G.GameTooltipStatusBar:SetStatusBarColor(GameTooltip_UnitColor(unit))
    else
        _G.GameTooltipStatusBar:SetStatusBarColor(0, .9, 0)
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
local GetInfo do
    local cache = {}
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

    local maxAge = 600
    local quickRefresh = 10

    local inspectFrame = _G.CreateFrame("Frame")
    inspectFrame:RegisterEvent("INSPECT_READY")
    inspectFrame:SetScript("OnEvent", function(self, event, guid)
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
                    ns.Debug(id, slot)
                    if link then
                        local _, _, rarity, ilvl, _, _, _, _, _, _, _, _, subTypeID = _G.GetItemInfo(link)
                        if rarity and subTypeID then
                            if rarity ~= _G.LE_ITEM_QUALITY_ARTIFACT then
                                ilvl = _G.RealUI.GetItemLevel(link)
                            end

                            ns.Debug(ilvl, _G.strsplit("|", link))
                            if not ilvl or ilvl == 0 then
                                ns.Debug("No ilvl data for", slot)
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

                                ns.Debug("itemClass", subTypeID)

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
                            ns.Debug("No item info for", slot)
                            isMissingInfo = true
                        end
                    else
                        ns.Debug("No item link for", slot)
                        if slot ~= "SecondaryHand" then
                            isMissingInfo = true
                        end
                    end
                end
            end

            if not isMissingInfo then
                -- Artifacts are counted as one item
                if mainArtifact or offArtifact then
                    ns.Debug("Artifacts", mainArtifact, offArtifact)
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
                    ns.Debug("totalILvl", totalILvl, numItems)
                    ilvl = round(totalILvl / numItems)
                end
                cache[guid].ilvl = ilvl
            end
        end

        if isMissingInfo then
            cache[guid].time = cache[guid].time - (maxAge - quickRefresh)
        end
    end)

    local function IsCacheFresh(guid)
        if cache[guid] and cache[guid].time then
            return (time() - cache[guid].time) < maxAge
        end
    end
    function GetInfo(infoType, unit)
        local guid = _G.UnitGUID(unit)
        if IsCacheFresh(guid) then
            return cache[guid][infoType]
        else
            if _G.CanInspect(unit) then
                if not cache[guid] then
                    cache[guid] = {
                        unit = unit
                    }
                end

                _G.NotifyInspect(unit)
            end
        end
    end
end

local AddTargetInfo, ClearTargetInfo do -- Target
    local targetLine

    local function GetTarget(unit)
        if _G.UnitIsUnit(unit, "player") then
            return ("|cffff0000%s|r"):format(cfg.you)
        else
            return _G.UnitName(unit)
        end
    end

    function AddTargetInfo(unit)
        if not _G.UnitExists(unit) then return end

        local tarRicon, text = (_G.GetRaidTargetIndex(unit))
        ns.Debug("tarRicon:", tarRicon, _G.ICON_LIST[tarRicon])

        if tarRicon and _G.ICON_LIST[tarRicon] then
            text = ("%s %s"):format(_G.ICON_LIST[tarRicon].."10|t", GetTarget(unit))
        else
            text = GetTarget(unit)
        end

        if targetLine and text then
            _G["GameTooltipTextLeft"..targetLine]:SetText(_G.TARGET)
            _G["GameTooltipTextRight"..targetLine]:SetText(text)
        elseif not targetLine then
            _G.GameTooltip:AddDoubleLine(_G.TARGET, text, normal.r, normal.g, normal.b, GameTooltip_UnitColor(unit))
            targetLine = _G.GameTooltip:NumLines()
        end
    end
    function ClearTargetInfo()
        targetLine = nil
    end
end

local AddSpecInfo, ClearSpecInfo do -- Spec
    local specLine
    local function GetSpec(unit)
        return GetInfo("spec", unit)
    end

    function AddSpecInfo(isPlayer, unit)
        if not isPlayer then return end

        local spec = GetSpec(unit)
        if specLine and spec then
            _G["GameTooltipTextLeft"..specLine]:SetText(_G.SPECIALIZATION)
            _G["GameTooltipTextRight"..specLine]:SetText(spec)
        elseif not specLine then
            _G.GameTooltip:AddDoubleLine(_G.SPECIALIZATION, spec or _G.SEARCH_LOADING_TEXT, normal.r, normal.g, normal.b, 1,1,1)
            specLine = _G.GameTooltip:NumLines()
        end
    end
    function ClearSpecInfo()
        specLine = nil
    end
end

local AddItemLevelInfo, ClearItemLevelInfo do -- ItemLevel
    local iLvlLine

    local function GetItemLevel(unit)
        if _G.UnitIsUnit(unit, "player") then
            local _, avgItemLevelEquipped = _G.GetAverageItemLevel()
            return avgItemLevelEquipped
        else
            return GetInfo("ilvl", unit)
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
            _G.GameTooltip:AddDoubleLine(_G.ITEM_LEVEL_ABBR, iLvl or _G.SEARCH_LOADING_TEXT, normal.r, normal.g, normal.b, 1,1,1)
            iLvlLine = _G.GameTooltip:NumLines()
        end
    end
    function ClearItemLevelInfo()
        iLvlLine = nil
    end
end

local updateFrame = _G.CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    self.freebtipUpdate = (self.freebtipUpdate or 0) + elapsed
    if self.freebtipUpdate < 1 then return end

    local unit = GetUnit(_G.GameTooltip)
    local isPlayer = _G.UnitIsPlayer(unit)

    AddTargetInfo(unit.."target")
    AddSpecInfo(isPlayer, unit)
    AddItemLevelInfo(isPlayer, unit)

    self.freebtipUpdate = 0
end)

_G.GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    ns.Debug("--- OnSetUnit ---")
    if cfg.combathide and _G.InCombatLockdown() then
        return self:Hide()
    end

    hideLines(self)

    local unit = GetUnit(self)
    ns.Debug("unit:", unit)
    if _G.UnitExists(unit) then
        if cfg.showFactionIcon then
            if not self.factionIcon then
                self.factionIcon = self:CreateTexture(nil, "BORDER")
                self.factionIcon:SetPoint("CENTER", _G.GameTooltip, "LEFT", 0, 0)
            end

            if _G.UnitIsPVP(unit) then
                local icon = factionIcon[_G.UnitFactionGroup(unit) or "Neutral"]
                self.factionIcon:SetTexture(icon.texture)
                self.factionIcon:SetTexCoord(icon.coords[1], icon.coords[2], icon.coords[3], icon.coords[4])
                self.factionIcon:SetSize(32, 38)
                self.factionIcon:Show()
            else
                self.factionIcon:Hide()
            end
        end

        local isPlayer = _G.UnitIsPlayer(unit)
        if isPlayer then
            PlayerName(self, unit)
            PlayerGuild(self, unit)
        end

        local line1 = _G.GameTooltipTextLeft1:GetText()

        local ricon = _G.GetRaidTargetIndex(unit)
        ns.Debug("ricon:", ricon, _G.ICON_LIST[ricon])
        if ricon and _G.ICON_LIST[ricon] then
            -- ricon can be > 8, which is outside ICON_LIST's index
            _G.GameTooltipTextLeft1:SetFormattedText("%s %s", _G.ICON_LIST[ricon].."12|t", line1)
        end
        _G.GameTooltipTextLeft1:SetTextColor(GameTooltip_UnitColor(unit))

        local level
        local IsBattlePet = _G.UnitIsBattlePet(unit)
        if IsBattlePet then
            level = _G.UnitBattlePetLevel(unit)
        else
            level = _G.UnitLevel(unit)
        end

        local dead = _G.UnitIsDeadOrGhost(unit)
        if level then
            local unitType
            if isPlayer then
                unitType = ("%s |cff%s%s|r"):format(_G.UnitRace(unit), _G.RealUI.GetColorString(GameTooltip_UnitColor(unit)), _G.UnitClass(unit))
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
            local textLevel = ("%s%s%s|r"):format(hex(diff), level, classification[classify] or "")

            for i = 2, self:NumLines() do
                local tiptext = _G["GameTooltipTextLeft"..i]
                local linetext = tiptext:GetText()

                if linetext and linetext:find(_G.LEVEL) then
                    tiptext:SetFormattedText(("%s %s %s"), textLevel, unitType or "unitType", (dead and "|cffCCCCCC".._G.DEAD.."|r" or ""))
                    break
                end
            end
        end

        AddTargetInfo(unit.."target")
        AddSpecInfo(isPlayer, unit)
        AddItemLevelInfo(isPlayer, unit)

        if dead then
            _G.GameTooltipStatusBar:Hide()
        end

        updateFrame:Show()
        self.freebtipUpdate = 0
    end

    SetStatusBar(self, unit)
end)

local frameColor = Aurora.Color.frame
_G.GameTooltip:HookScript("OnTooltipCleared", function(self)
    if self.factionIcon then
        self.factionIcon:Hide()
    end

    ClearTargetInfo()
    ClearSpecInfo()
    ClearItemLevelInfo()

    self:SetBackdropBorderColor(frameColor.r, frameColor.g, frameColor.b)

    updateFrame:Hide()
end)

_G.GameTooltipStatusBar:SetHeight(8)
_G.GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
    if not value then
        return
    end
    local min, max = self:GetMinMaxValues()
    if value < min or (value > max) then
        return
    end

    if not self.text then
        -- xRUI
        self.text = self:CreateFontString(nil, "OVERLAY")
        self.text:SetPoint("CENTER", self)
        self.text:SetFontObject(_G.TextStatusBarText)
    end
    self.text:Show()
    local hp = numberize(self:GetValue()).." / "..numberize(max)
    self.text:SetText(hp)
end)

local itemTips = {}
local function style(frame)
    if not frame or frame:IsForbidden() then return end

    local frameName = frame:GetName()
    if cfg.colorborderItem and frame.GetItem then
        frame._setQualityColors = true
    end

    if not frameName then return end
    if frameName ~= "GameTooltip" and frame.NumLines then
        for index=1, frame:NumLines() do
            if index==1 then
                _G[frameName..'TextLeft'..index]:SetFontObject(_G.GameTooltipHeaderText)
            else
                _G[frameName..'TextLeft'..index]:SetFontObject(_G.GameTooltipText)
            end
            _G[frameName..'TextRight'..index]:SetFontObject(_G.GameTooltipText)
        end
    end

    if _G[frameName.."MoneyFrame1"] then
        _G[frameName.."MoneyFrame1PrefixText"]:SetFontObject(_G.GameTooltipText)
        _G[frameName.."MoneyFrame1SuffixText"]:SetFontObject(_G.GameTooltipText)
        _G[frameName.."MoneyFrame1GoldButtonText"]:SetFontObject(_G.GameTooltipText)
        _G[frameName.."MoneyFrame1SilverButtonText"]:SetFontObject(_G.GameTooltipText)
        _G[frameName.."MoneyFrame1CopperButtonText"]:SetFontObject(_G.GameTooltipText)
    end

    if _G[frameName.."MoneyFrame2"] then
        _G[frameName.."MoneyFrame2PrefixText"]:SetFontObject(_G.GameTooltipText)
        _G[frameName.."MoneyFrame2SuffixText"]:SetFontObject(_G.GameTooltipText)
        _G[frameName.."MoneyFrame2GoldButtonText"]:SetFontObject(_G.GameTooltipText)
        _G[frameName.."MoneyFrame2SilverButtonText"]:SetFontObject(_G.GameTooltipText)
        _G[frameName.."MoneyFrame2CopperButtonText"]:SetFontObject(_G.GameTooltipText)
    end
end
ns.style = style

local tooltips = {
    "GameTooltip",
    "ItemRefTooltip",
    "ShoppingTooltip1",
    "ShoppingTooltip2",
    "FriendsTooltip",
    "WorldMapTooltip",
    "WorldMapCompareTooltip1",
    "WorldMapCompareTooltip2",
    "ItemRefShoppingTooltip1",
    "ItemRefShoppingTooltip2",
    "FloatingBattlePetTooltip",
    "BattlePetTooltip",
}
local eventFrame = _G.CreateFrame("Frame")
eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")

        for i, tip in ipairs(tooltips) do
            local frame = _G[tip]

            if frame then
                frame:HookScript("OnShow", function(this)
                    if cfg.combathideALL and _G.InCombatLockdown() then
                        return this:Hide()
                    end

                    style(this)
                end)
            end
        end

        style(_G.GameTooltip)
    else
        for k in next, itemTips do
            local tip = _G[k]
            if tip and tip:IsShown() then
                style(tip)
            end
        end
    end
end)
