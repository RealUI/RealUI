local ADDON_NAME, ns = ...

local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR
local ITEM_LEVEL_ABBR = ITEM_LEVEL_ABBR
local GetMouseFocus = GetMouseFocus
local GameTooltip = GameTooltip
local GetTime = GetTime
local UnitGUID = UnitGUID

local ItemUpgradeInfo = LibStub("LibItemUpgradeInfo-1.0")
local LibInspect = LibStub("LibInspect")

local maxAge = 600 -- 10 mins
local quickRefresh = 30

--number of secs to cache each player
LibInspect:SetMaxAge(maxAge)

ns.Debug = RealUI.GetDebug(ADDON_NAME) -- FreebTipiLvl

local cache = {}
local ilvlText = "|cffFFFFFF%d|r"

local function getUnit()
    local mFocus = GetMouseFocus()
    if mFocus then
        -- mFocus might somehow be a FontString, which doesn't have GetAttribute
        unit = mFocus.unit or (mFocus.GetAttribute and mFocus:GetAttribute("unit"))
    end

    return unit or "mouseover"
end

local function ShowiLvl(score)
    if score > 0 and not GameTooltip.freebtipiLvlSet then
        GameTooltip:AddDoubleLine(ITEM_LEVEL_ABBR, ilvlText:format(score), NORMAL_FONT_COLOR.r,
        NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        GameTooltip.freebtipiLvlSet = true
        GameTooltip:Show()
    end
end

local iLvlUpdate = CreateFrame"Frame"
iLvlUpdate:SetScript("OnUpdate", function(self, elapsed)
    self.update = (self.update or 0) + elapsed
    if(self.update < .1) then return end

    local unit = getUnit()
    local guid = UnitGUID(unit)
    local cacheGUID = cache[guid]
    if(cacheGUID) then
        ShowiLvl(cacheGUID.score)
    end

    self.update = 0
    self:Hide()
end)

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
    [LE_ITEM_WEAPON_AXE2H] = true,
    [LE_ITEM_WEAPON_MACE2H] = true,
    [LE_ITEM_WEAPON_SWORD2H] = true,

    [LE_ITEM_WEAPON_POLEARM] = true,
    [LE_ITEM_WEAPON_STAFF] = true,

    [LE_ITEM_WEAPON_BOWS] = true,
    [LE_ITEM_WEAPON_CROSSBOW] = true,
    [LE_ITEM_WEAPON_GUNS] = true,

    [LE_ITEM_WEAPON_FISHINGPOLE] = true
}
local DualWield = {
    [LE_ITEM_WEAPON_AXE1H] = true,
    [LE_ITEM_WEAPON_MACE1H] = true,
    [LE_ITEM_WEAPON_SWORD1H] = true,

    [LE_ITEM_WEAPON_WARGLAIVE] = true,
    [LE_ITEM_WEAPON_DAGGER] = true,

    [LE_ITEM_WEAPON_GENERIC] = true,
    [LE_ITEM_ARMOR_SHIELD] = true,
}

local artifactcolor
local function GetItemLevel(guid, data, age)
    if not artifactcolor then artifactcolor =_G.ITEM_QUALITY_COLORS[_G.LE_ITEM_QUALITY_ARTIFACT].hex end
    if ((not guid) or (data and type(data.items) ~= "table")) then return end


    local totalILvl = 0
    local hasTwoHander, isDualWield
    local artifactILvl, mainArtifact, offArtifact

    for id, slot in next, slots do
        if slot ~= "Shirt" then
            local link = data.items[id]
            ns.Debug(id, slot)
            if link then
                local _, _, rarity, ilvl, _, _, _, _, _, _, _, _, subTypeID = _G.GetItemInfo(link)
                if rarity and subTypeID then
                    if rarity ~= _G.LE_ITEM_QUALITY_ARTIFACT then
                        ilvl = ItemUpgradeInfo:GetUpgradedItemLevel(link)
                    end

                    ns.Debug(ilvl, _G.strsplit("|", link))
                    if not ilvl then
                        return ns.Debug("No ilvl data for", slot)
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
                    return ns.Debug("No item info for", slot)
                end
            else
                ns.Debug("No item link for", slot)
                if slot ~= "SecondaryHand" then
                    return
                end
            end
        end
    end

    -- Artifacts are counted as one item
    if mainArtifact or offArtifact then
        ns.Debug("Artifacts", mainArtifact, offArtifact)
        artifactILvl = max(mainArtifact or 0, offArtifact or 0)
        totalILvl = totalILvl + artifactILvl

        if offArtifact then
            totalILvl = totalILvl + artifactILvl
        end

        if artifactILvl <= 750 then
            return false
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

    return totalILvl, numItems
end

local function doRefresh(guid)
    if cache[guid] then
        return cache[guid].score == 0 or cache[guid].time < (GetTime() - maxAge)
    else
        return true
    end
end
LibInspect:AddHook(ADDON_NAME, "items", function(guid, ...)
    ns.Debug("------------ Inspect hook ------------", guid, ...)
    if doRefresh(guid) then
        local result, numItems = GetItemLevel(guid, ...)
        local score, time
        if result and result > 0 then
            ns.Debug("totalILvl", result, numItems)
            score = result / numItems
            time = GetTime()
        else
            score = 0
            time = GetTime() - (maxAge - quickRefresh)
        end
        ns.Debug("Set score", score)
        cache[guid] = {
            score = score,
            time = time,
        }
    else
        iLvlUpdate:Show()
    end
end)

local function OnSetUnit(self)
    local unit = getUnit()
    self.freebtipiLvlSet = false
    if UnitIsUnit(unit, "player") then
        local _, avgItemLevelEquipped = GetAverageItemLevel()
        ShowiLvl(avgItemLevelEquipped)
    else
        local caninspect = LibInspect:RequestData("items", unit)
        iLvlUpdate:Show()
    end
end
GameTooltip:HookScript("OnTooltipSetUnit", OnSetUnit)
