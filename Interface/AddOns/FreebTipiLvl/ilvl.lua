local ADDON_NAME, ns = ...

local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR
local ITEM_LEVEL_ABBR = ITEM_LEVEL_ABBR
local GetMouseFocus = GetMouseFocus
local GameTooltip = GameTooltip
local GetTime = GetTime
local UnitGUID = UnitGUID

local ItemUpgradeInfo = LibStub("LibItemUpgradeInfo-1.0")
local LibInspect = LibStub("LibInspect")

local maxage = 1800 --number of secs to cache each player
LibInspect:SetMaxAge(maxage)

ns.Debug = RealUI.GetDebug(ADDON_NAME)

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
	if(not GameTooltip.freebtipiLvlSet) then
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
local function getItems(guid, data, age)
	if not artifactcolor then artifactcolor =_G.ITEM_QUALITY_COLORS[_G.LE_ITEM_QUALITY_ARTIFACT].hex end
	if ((not guid) or (data and type(data.items) ~= "table")) then return end

	local cacheGUID = cache[guid]
	if (cacheGUID and (cacheGUID.time > (GetTime()-maxage)) and not cacheGUID.doRefresh) then
		return iLvlUpdate:Show()
	end

	local totalILvl, doRefresh = 0, false
	local hasTwoHander, isDualWield
	local artifactILvl, mainArtifact, offArtifact

	for id, slot in next, slots do
		if slot ~= "Shirt" then
			local link = data.items[id]
			ns.Debug(id, slot)

			if (link) then
				local ilvl = ItemUpgradeInfo:GetUpgradedItemLevel(link)
				ns.Debug(ilvl, _G.strsplit("|", link))
				if not ilvl then
					return ns.Debug("No ilvl data for", slot)
				end

				if slot == "MainHand" or slot == "SecondaryHand" then
					if link:find(artifactcolor) then
						if slot == "MainHand" then
							mainArtifact = ilvl
						elseif slot == "SecondaryHand" then
							offArtifact = ilvl
						end
					else
						totalILvl = totalILvl + ilvl
					end

					local itemSubClassID = select(13, GetItemInfo(link))
					ns.Debug("itemClass", itemSubClassID)

					if itemSubClassID then
						if slot == "MainHand" then
							hasTwoHander = TwoHanders[itemSubClassID] and ilvl
						elseif slot == "SecondaryHand" then
							if hasTwoHander then
								isDualWield = TwoHanders[itemSubClassID] -- Titan's Grip
							else
								isDualWield = DualWield[itemSubClassID]
							end
						end
					end
				else
					totalILvl = totalILvl + ilvl
				end
			else
				doRefresh = true
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

		if not doRefresh then
			doRefresh = artifactILvl <= 750
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
	--print("numItems", numItems)

	if (totalILvl > 0) then
		ns.Debug(totalILvl, numItems)
		local score = totalILvl / numItems
		cache[guid] = { score = score, time = GetTime(), doRefresh = doRefresh }
		if not doRefresh then
			iLvlUpdate:Show()
		end
	end
end
LibInspect:AddHook(ADDON_NAME, "items", function(...) getItems(...) end)

local function OnSetUnit(self)
	self.freebtipiLvlSet = false

	local unit = getUnit()
	local caninspect = LibInspect:RequestData("items", unit)
	iLvlUpdate:Show()
end
GameTooltip:HookScript("OnTooltipSetUnit", OnSetUnit)
