local _, private = ...
-- Lua Globals --
-- luacheck: globals next tinsert ceil tostring tostringall

-- RealUI --
local RealUI = _G.RealUI
local FramePoint = RealUI:GetModule("FramePoint")

local CombatText = RealUI:NewModule("CombatText", "AceEvent-3.0")
private.CombatText = CombatText

if RealUI.isMidnight then
    _G.print("CombatText is not supported in Midnight. Disabling module.")
    return
end

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
        scrollDuration = 2,
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
    SPELL_EXTRA_ATTACKS = true,

    SPELL_AURA_APPLIED = true,
    SPELL_AURA_REMOVED = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_REMOVED_DOSE = true,
    SPELL_AURA_REFRESH = true,
    SPELL_AURA_BROKEN = true,
    SPELL_AURA_BROKEN_SPELL = true,

    SPELL_CAST_START = true,
    SPELL_CAST_SUCCESS = true,
    SPELL_CAST_FAILED = true,

    SPELL_EMPOWER_START = true,
    SPELL_EMPOWER_END = true,

    ENCHANT_APPLIED = true,
    ENCHANT_REMOVED = true,

    SPELL_ABSORBED = true,
    SPELL_RESURRECT = true,
    SPELL_SUMMON  = true,
    SPELL_CREATE  = true,
}

private.player = {
    guid = _G.UnitGUID("player"),
    name = _G.UnitName("player"),
    flags = 0x00000400,
    raidFlags = 0x01
}
private.other = {
    guid = "Player-1234-1234ABCD",
    name = "Other",
    flags = 0x10A48,
    raidFlags = 0x20
}

local COMBATLOG_FILTER_MINE = _G.COMBATLOG_FILTER_MINE
local COMBATLOG_FILTER_MY_PET = _G.COMBATLOG_FILTER_MY_PET
local CombatLog_Object_IsA = _G.C_CombatLog.DoesObjectMatchFilter
local cachedGUIDs = {
    [private.player.guid] = "player"
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
local function Dispatch(eventInfo, ...)
    DebugEvent(eventInfo, ...)
    if DoesEventAffectPlayer(eventInfo) then
        if private.player.guid == eventInfo.sourceGUID then
            private.player.flags = eventInfo.sourceFlags
            private.player.raidFlags = eventInfo.sourceRaidFlags
            private.other.flags = eventInfo.sourceFlags
            private.other.raidFlags = eventInfo.sourceRaidFlags
        end

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
            _G.print("report event data", eventInfo.event)
        end
    end
end

local function FilterEvent(timestamp, event, ...)
    if IGNORE_EVENT[event] then
        return
    end

    Dispatch(FormatEventInfo(timestamp, event, ...))
end
private.FilterEvent = FilterEvent
function CombatText:COMBAT_LOG_EVENT_UNFILTERED()
    FilterEvent(_G.C_CombatLog.GetCurrentEntryInfo())
end

function CombatText:PLAYER_REGEN_ENABLED()
    local eventInfo = {
        string = _G.LEAVING_COMBAT,
        scrollType = "notification",
    }
    private.AddEvent(eventInfo)
end
function CombatText:PLAYER_REGEN_DISABLED()
    local eventInfo = {
        string = _G.ENTERING_COMBAT,
        scrollType = "notification",
    }
    private.AddEvent(eventInfo)
end

function CombatText:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_CombatTextDB", defaults, true)
    FramePoint:RegisterMod(self)

    for event in next, self.db.global.ignore do
        IGNORE_EVENT[event] = true
    end

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    private.CreateScrollAreas()


    local LibSink = _G.LibStub("LibSink-2.0", true)
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
