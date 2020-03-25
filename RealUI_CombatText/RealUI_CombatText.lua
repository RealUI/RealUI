local _, private = ...

-- Lua Globals --
-- luacheck: globals next tinsert ceil tostring tostringall

-- RealUI --
local RealUI = _G.RealUI

local CombatText = RealUI:NewModule("CombatText", "AceEvent-3.0")
private.CombatText = CombatText

local defaults = {
    global = {
        fonts = {
            normal = {
                name = "Roboto",
                size = 10,
                flags = "OUTLINE"
            },
            sticky = {
                name = "Roboto Bold-Italic",
                size = 14,
                flags = "OUTLINE"
            },
        },
        incoming = {
            justify = "RIGHT",
            size = {
                x = 100,
                y = 300,
            },
            position = {
                x = -200,
                y = 0,
                point = "CENTER"
            }
        },
        outgoing = {
            justify = "LEFT",
            size = {
                x = 100,
                y = 300,
            },
            position = {
                x = 200,
                y = 0,
                point = "CENTER"
            }
        },
        notification = {
            justify = "CENTER",
            size = {
                x = 200,
                y = 50,
            },
            position = {
                x = 0,
                y = 200,
                point = "CENTER"
            }
        },
        ignore = {}
    }
}

local debugFormat = [[%s - %s
    hideCaster: %s
    sourceGUID: %s
    sourceName: %s
    sourceFlags: %X
    sourceRaidFlags: %X
    destGUID: %s
    destName: %s
    destFlags: %X
    destRaidFlags: %X
    args:
]]
local function DebugEvent(eventInfo, ...)
    CombatText:debug(debugFormat:format(eventInfo.timestamp, eventInfo.event, tostring(eventInfo.hideCaster),
        eventInfo.sourceGUID, eventInfo.sourceName or "nil", eventInfo.sourceFlags, eventInfo.sourceRaidFlags,
        eventInfo.destGUID, eventInfo.destName or "nil", eventInfo.destFlags, eventInfo.destRaidFlags),
        tostringall(...))
end

local IGNORE_EVENT = {
    SPELL_AURA_APPLIED = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_REMOVED = true,
    SPELL_AURA_REMOVED_DOSE = true,
    SPELL_AURA_REFRESH = true,
    SPELL_AURA_BROKEN = true,
    SPELL_AURA_BROKEN_SPELL = true,

    SPELL_CAST_START = true,
    SPELL_CAST_SUCCESS = true,
    SPELL_CAST_FAILED = true,

    ENCHANT_APPLIED = true,
    ENCHANT_REMOVED = true,

    SPELL_ABSORBED = true,
}

local COMBATLOG_FILTER_MINE = _G.COMBATLOG_FILTER_MINE
local COMBATLOG_FILTER_MY_PET = _G.COMBATLOG_FILTER_MY_PET
local CombatLog_Object_IsA = _G.CombatLog_Object_IsA
local cachedGUIDs = {
    [_G.UnitGUID("player")] = "player"
}
local function DoesEventAffectPlayer(eventInfo)
    local sourceUnit = cachedGUIDs[eventInfo.sourceGUID]
    if not sourceUnit then
        if CombatLog_Object_IsA(eventInfo.sourceFlags, COMBATLOG_FILTER_MINE) then
            sourceUnit = "player"
        elseif CombatLog_Object_IsA(eventInfo.sourceFlags, COMBATLOG_FILTER_MY_PET) then
            sourceUnit = "pet"
        else
            sourceUnit = "external"
        end
        cachedGUIDs[eventInfo.sourceGUID] = sourceUnit
    end

    local destUnit = cachedGUIDs[eventInfo.destGUID]
    if not destUnit then
        if CombatLog_Object_IsA(eventInfo.destFlags, COMBATLOG_FILTER_MINE) then
            destUnit = "player"
        elseif CombatLog_Object_IsA(eventInfo.destFlags, COMBATLOG_FILTER_MY_PET) then
            destUnit = "pet"
        else
            destUnit = "external"
        end
        cachedGUIDs[eventInfo.destGUID] = destUnit
    end

    local scrollType
    if destUnit == "player" or destUnit == "pet" then
        scrollType = "incoming"
    elseif sourceUnit == "player" or sourceUnit == "pet" then
        scrollType = "outgoing"
    end

    if scrollType then
        eventInfo.sourceUnit = sourceUnit
        eventInfo.destUnit = destUnit
        eventInfo.scrollType = scrollType
        return true
    end
end


local function FilterEvent(eventInfo, ...)
    DebugEvent(eventInfo, ...)
    if IGNORE_EVENT[eventInfo.event] then
        return
    end

    if DoesEventAffectPlayer(eventInfo) then
        eventInfo.data = {}
        if private.eventSpecial[eventInfo.event] then
            return private.eventSpecial[eventInfo.event](eventInfo, ...)
        end

        local eventBase, eventType = eventInfo.event:match("(%w+)_([%w_]+)")
        if eventType:find("PERIODIC") or eventType:find("BUILDING") then
            local eventMod
            eventMod, eventType = eventType:match("(%w+)_([%w_]+)")
            eventBase = eventBase .. "_" .. eventMod
        end
        eventInfo.eventBase, eventInfo.eventType = eventBase, eventType


        if private.eventPrefix[eventBase] then
            private.eventPrefix[eventBase](eventInfo, ...)
        else
            _G.print("missing base event", eventBase, eventType)
        end
    end
end

local function FormatEventInfo(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    local eventInfo = {
        timestamp = timestamp,
        event = event,
        hideCaster = hideCaster,
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        sourceFlags = sourceFlags,
        sourceRaidFlags = sourceRaidFlags,
        destGUID = destGUID,
        destName = destName,
        destFlags = destFlags,
        destRaidFlags = destRaidFlags,

        canMerge = true,
    }
    return eventInfo, ...
end
function CombatText:COMBAT_LOG_EVENT_UNFILTERED()
    FilterEvent(FormatEventInfo(_G.CombatLogGetCurrentEventInfo()))
end

function CombatText:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_CombatTextDB", defaults, true)

    for event in next, self.db.global.ignore do
        IGNORE_EVENT[event] = true
    end

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    private.CreateScrollAreas()


    local LibSink = _G.LibStub("LibSink-2.0")
    if LibSink then
        local textFormat = "|c%s%s|r"
        local function sink(addon, text, r, g, b, font, size, outline, sticky, location, icon)
            local eventInfo = {
                string = textFormat:format(RealUI.GetColorString(r, g, b), text),
                icon = icon,
                scrollType = location or "notification",
                isSticky = sticky,
            }
            private.AddEvent(eventInfo)
        end

        local scrollAreas = {"incoming", "outgoing", "notification"}
        local function getScrollAreasChoices()
            return scrollAreas
        end

        LibSink:RegisterSink("CombatText", "RealUI CombatText", nil, sink, getScrollAreasChoices, true)
    end
end
