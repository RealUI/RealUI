local ADDON_NAME, ns = ...

local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR
local SPECIALIZATION = SPECIALIZATION
local GameTooltip = GameTooltip
local GetTime = GetTime

local specText = "|cffFFFFFF%s|r"
local cacheTime = 900 --number of secs to cache each player's spec

local LibInspect = LibStub("LibInspect")

local cache = {}

local function ShowSpec(self, unit, uGUID)
	local cacheGUID = cache[uGUID]
	if(cacheGUID and cacheGUID.gtime > GetTime()-cacheTime) then

		if(not self.freebtipSpecSet) then
			self:AddDoubleLine(SPECIALIZATION, specText:format(cacheGUID.spec), NORMAL_FONT_COLOR.r,
			NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

			self.freebtipSpecSet = true
		end

		self:Show()
	elseif(not InspectFrame or (InspectFrame and not InspectFrame:IsShown())) then
		cache[uGUID] = nil
		local caninspect, unitfound, refreshing = LibInspect:RequestData("talents", unit, true)
	end
end

local function getTalents(uGUID, data, age)
	if((uGUID and cache[uGUID]) or (data and type(data.talents) ~= "table")) then return end

	local spec = data.talents.name

	if(spec) then
		cache[uGUID] = { spec = spec, gtime = GetTime() }

		local unit = GetMouseFocus() and GetMouseFocus().unit or "mouseover"
		local mGUID = UnitGUID(unit)

		if(uGUID == mGUID) then
			ShowSpec(GameTooltip, "mouseover", uGUID)
		end
	end
end

LibInspect:AddHook(ADDON_NAME, "talents", function(...) getTalents(...) end)

local function OnSetUnit(self)
	self.freebtipSpecSet = false

	local _, unit = self:GetUnit()
	if(not unit) then
		unit = GetMouseFocus() and GetMouseFocus().unit or nil
	end

	if(UnitExists(unit) and UnitIsPlayer(unit)) then
		local level = UnitLevel(unit) or 0
		local canInspect = CanInspect(unit)
		local uGUID = UnitGUID(unit)

		if(canInspect and level > 9) then
			ShowSpec(self, unit, uGUID)
		end
	end
end

GameTooltip:HookScript("OnTooltipSetUnit", OnSetUnit)
