local ADDON_NAME, ns = ...

-- [[ Lua Globals ]]
-- luacheck: globals type

local LibInspect = _G.LibStub("LibInspect")

local maxage = 1800 --number of secs to cache each player
LibInspect:SetMaxAge(maxage)

local cache = {}
local specText = "|cffFFFFFF%s|r"

local function ShowSpec(spec)
    if not _G.GameTooltip.freebtipSpecSet then
        _G.GameTooltip:AddDoubleLine(_G.SPECIALIZATION, specText:format(spec), _G.NORMAL_FONT_COLOR.r, _G.NORMAL_FONT_COLOR.g, _G.NORMAL_FONT_COLOR.b)
        _G.GameTooltip.freebtipSpecSet = true
        _G.GameTooltip:Show()
    end
end

local specUpdate = _G.CreateFrame("Frame")
specUpdate:SetScript("OnUpdate", function(self, elapsed)
    self.update = (self.update or 0) + elapsed
    if self.update < .08 then return end

    local unit = ns.GetUnit()
    local guid = _G.UnitGUID(unit)
    local cacheGUID = cache[guid]
    if cacheGUID then
        ShowSpec(cacheGUID.spec)
    end

    self.update = 0
    self:Hide()
end)

local function getTalents(guid, data, age)
    if not guid or (data and type(data.talents) ~= "table") then return end

    local cacheGUID = cache[guid]
    if cacheGUID and cacheGUID.time > (_G.GetTime()-maxage) then
        return specUpdate:Show()
    end

    local spec = data.talents.name
    if spec then
        cache[guid] = { spec = spec, time = _G.GetTime() }
        specUpdate:Show()
    end
end
LibInspect:AddHook(ADDON_NAME, "talents", function(...) getTalents(...) end)

_G.GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    self.freebtipSpecSet = false
    LibInspect:RequestData("items", ns.GetUnit())
    specUpdate:Show()
end)
