local _, private = ...

-- Lua Globals --
-- luacheck: globals next tinsert ceil tostring tostringall

-- Libs --
local LSM = _G.LibStub("LibSharedMedia-3.0")

-- RealUI --
local RealUI = _G.RealUI

local CombatText = RealUI:NewModule("CombatText", "AceEvent-3.0")
private.CombatText = CombatText

local defaults = {
    global = {
        fontNormal = {
            path = LSM:Fetch("font", "Roboto"),
            size = 16,
            flags = "OUTLINE"
        },
        fontSticky = {
            path = LSM:Fetch("font", "Roboto Bold-Italic"),
            size = 20,
            flags = "OUTLINE"
        },
        incoming = {
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
    SPELL_CAST_START = true,
    SPELL_CAST_SUCCESS = true,
    SPELL_CAST_FAILED = true,

    ENCHANT_APPLIED = true,
    ENCHANT_REMOVED = true,
}

local playerGUID = _G.UnitGUID("player")
local function FilterEvent(eventInfo, ...)
    DebugEvent(eventInfo, ...)
    if IGNORE_EVENT[eventInfo.event] then
        return
    end

    local scrollType
    if eventInfo.destGUID == playerGUID then
        scrollType = "incoming"
    elseif eventInfo.sourceGUID == playerGUID then
        scrollType = "outgoing"
    end

    if scrollType then
        eventInfo.scrollType = scrollType
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


    --[[
    local LibSink = _G.LibStub("LibSink-2.0")
    if LibSink then
        local function sink(addon, text, r, g, b, font, size, outline, sticky, location, icon)
            local storage = LibSink.storageForAddon[addon]
            if storage then
                location = storage.sink20ScrollArea or location or "Notification"
                sticky = storage.sink20Sticky or sticky
            end
            self:ShowMessage(text, location, sticky, r, g, b, font, size, outline, icon)
        end
        local function getScrollAreasChoices()
            local tmp = {}
            for k, v in next, self:GetScrollAreasChoices() do
                tmp[#tmp+1] = v
            end
            return tmp
        end

        LibSink:RegisterSink("RealUI_CombatText", "RealUI_CombatText", nil, sink, getScrollAreasChoices, true)
    end
    ]]
end
