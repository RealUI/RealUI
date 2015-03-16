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

local cache = {}
local ilvlText = "|cffFFFFFF%d|r"

local function getUnit()
	local mFocus = GetMouseFocus()
	local unit = mFocus and (mFocus.unit or mFocus:GetAttribute("unit")) or "mouseover"
	return unit
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

local slots = { "Back", "Chest", "Feet", "Finger0", "Finger1", "Hands", "Head", "Legs",
"MainHand", "Neck", "SecondaryHand", "Shoulder", "Trinket0", "Trinket1", "Waist", "Wrist" }

local slotIDs = {}
for i, slot in next, slots do
	local slotName = slot.."Slot"
	local id = GetInventorySlotInfo(slotName)

	if(id) then
		slotIDs[i] = id
	end
end

local function getItems(guid, data, age)
	if((not guid) or (data and type(data.items) ~= "table")) then return end

	local cacheGUID = cache[guid]
	if(cacheGUID and cacheGUID.time > (GetTime()-maxage)) then
		return iLvlUpdate:Show()
	end

	local numItems = 0
	local itemsTotal = 0

	for i, id in next, slotIDs do
		local link = data.items[id]

		if(link) then
			local ilvl = ItemUpgradeInfo:GetUpgradedItemLevel(link)

			numItems = numItems + 1
			itemsTotal = itemsTotal + ilvl
		end
	end

	if(numItems > 0) then
		local score = itemsTotal / numItems
		cache[guid] = { score = score, time = GetTime() }
		iLvlUpdate:Show()
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
