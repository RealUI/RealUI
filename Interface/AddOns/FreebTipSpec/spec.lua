local ADDON_NAME, ns = ...

local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR
local SPECIALIZATION = SPECIALIZATION
local GetMouseFocus = GetMouseFocus
local GameTooltip = GameTooltip
local GetTime = GetTime
local UnitGUID = UnitGUID

local LibInspect = LibStub("LibInspect")

local maxage = 1800 --number of secs to cache each player
LibInspect:SetMaxAge(maxage)

local cache = {}
local specText = "|cffFFFFFF%s|r"

local function getUnit()
	local mFocus = GetMouseFocus()
	local unit = mFocus and (mFocus.unit or mFocus:GetAttribute("unit")) or "mouseover"
	return unit
end

local function ShowSpec(spec)
	if(not GameTooltip.freebtipSpecSet) then
		GameTooltip:AddDoubleLine(SPECIALIZATION, specText:format(spec), NORMAL_FONT_COLOR.r,
		NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		GameTooltip.freebtipSpecSet = true
		GameTooltip:Show()
	end
end

local specUpdate = CreateFrame"Frame"
specUpdate:SetScript("OnUpdate", function(self, elapsed)
	self.update = (self.update or 0) + elapsed
	if(self.update < .08) then return end

	local unit = getUnit()
	local guid = UnitGUID(unit)
	local cacheGUID = cache[guid]
	if(cacheGUID) then
		ShowSpec(cacheGUID.spec)
	end

	self.update = 0
	self:Hide()
end)

local function getTalents(guid, data, age)
	if((not guid) or (data and type(data.talents) ~= "table")) then return end

	local cacheGUID = cache[guid]
	if(cacheGUID and cacheGUID.time > (GetTime()-maxage)) then
		return specUpdate:Show()
	end

	local spec = data.talents.name
	if(spec) then
		cache[guid] = { spec = spec, time = GetTime() }
		specUpdate:Show()
	end
end
LibInspect:AddHook(ADDON_NAME, "talents", function(...) getTalents(...) end)

local function OnSetUnit(self)
	self.freebtipSpecSet = false

	local unit = getUnit()
	local caninspect = LibInspect:RequestData("items", unit)
	specUpdate:Show()
end
GameTooltip:HookScript("OnTooltipSetUnit", OnSetUnit)
