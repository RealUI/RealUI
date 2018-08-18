local ADDON_NAME, ns = ...

-- [[ Lua Globals ]]
-- luacheck: globals next type

local LibInspect = _G.LibStub("LibInspect")

local maxAge = 600 -- 10 mins
local quickRefresh = 30

--number of secs to cache each player
LibInspect:SetMaxAge(maxAge)

local cache = {}
local ilvlText = "|cffFFFFFF%d|r"

local function ShowiLvl(score)
    if score > 0 and not _G.GameTooltip.freebtipiLvlSet then
        _G.GameTooltip:AddDoubleLine(_G.ITEM_LEVEL_ABBR, ilvlText:format(score), _G.NORMAL_FONT_COLOR.r, _G.NORMAL_FONT_COLOR.g, _G.NORMAL_FONT_COLOR.b)
        _G.GameTooltip.freebtipiLvlSet = true
        _G.GameTooltip:Show()
    end
end

local iLvlUpdate = _G.CreateFrame("Frame")
iLvlUpdate:SetScript("OnUpdate", function(self, elapsed)
    self.update = (self.update or 0) + elapsed
    if self.update < .1 then return end

    local unit = ns.GetUnit()
    local guid = _G.UnitGUID(unit)
    local cacheGUID = cache[guid]
    if cacheGUID then
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
                    --ilvl = _G.GetDetailedItemLevelInfo(link)
                    if rarity ~= _G.LE_ITEM_QUALITY_ARTIFACT then
                        ilvl = _G.RealUI.GetItemLevel(link)
                    end

                    ns.Debug(ilvl, _G.strsplit("|", link))
                    if not ilvl or ilvl == 0 then
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
        artifactILvl = _G.max(mainArtifact or 0, offArtifact or 0)
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
        return cache[guid].score == 0 or cache[guid].time < (_G.GetTime() - maxAge)
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
            time = _G.GetTime()
        else
            score = 0
            time = _G.GetTime() - (maxAge - quickRefresh)
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

_G.GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    local unit = ns.GetUnit()
    self.freebtipiLvlSet = false
    --[[
    LibInspect:RequestData("items", unit)
    iLvlUpdate:Show()
    ]]
    if _G.UnitIsUnit(unit, "player") then
        local _, avgItemLevelEquipped = _G.GetAverageItemLevel()
        ShowiLvl(avgItemLevelEquipped)
    else
        LibInspect:RequestData("items", unit)
        iLvlUpdate:Show()
    end
end)
