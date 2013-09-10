local Voice = Grid2.statusPrototype:new("voice")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local cache = {}

function Voice:Grid_UnitLeft(_, unit)
	cache[unit] = nil
end

function Voice:OnEnable()
	self:RegisterEvent("VOICE_START")
	self:RegisterEvent("VOICE_STOP")
	self:RegisterMessage("Grid_UnitLeft")
end

function Voice:OnDisable()
	self:UnregisterEvent("VOICE_START")
	self:UnregisterEvent("VOICE_STOP")
	self:UnregisterMessage("Grid_UnitLeft")
	while true do
		local k = next(cache)
		if not k then break end
		cache[k] = nil
	end
end

function Voice:VOICE_START(_, unit)
	cache[unit] = true
	return self:UpdateIndicators(unit)
end

function Voice:VOICE_STOP(_, unit)
	cache[unit] = nil
	return self:UpdateIndicators(unit)
end

function Voice:IsActive(unit)
	return cache[unit]
end

local text = L["talking"]
function Voice:GetText(unitid)
	return text
end

Voice.GetColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Voice, {"color", "text"}, baseKey, dbx)

	return Voice
end

Grid2.setupFunc["voice"] = Create

Grid2:DbSetStatusDefaultValue( "voice", {type = "voice", color1 = {r=1,g=1,b=0,a=1}})
