local _, private = ...
-- Lua Globals --
-- luacheck: globals next tinsert ceil tostring tostringall

-- WoW 12 API Migration: Lost Features
-- C_CombatText.GetCurrentEventInfo() does not provide:
--   - Spell IDs: spell-specific icons can no longer be displayed
--   - Spell school data: spell school color coding is unavailable
--   - Source/destination GUIDs: incoming vs outgoing distinction is not possible
--   - Spell names: spell-name-based merge grouping is not possible
--   - Interrupt/dispel/stolen spell names: these notifications are unavailable

-- RealUI --
local RealUI = _G.RealUI
local FramePoint = RealUI:GetModule("FramePoint")

local CombatText = RealUI:NewModule("CombatText", "AceEvent-3.0")
private.CombatText = CombatText
CombatText._testPrivate = private

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
        blizzardFCT = {
            enableFloatingCombatText = true,
            floatingCombatTextCombatDamage = true,
            floatingCombatTextCombatHealing = true,
            nameplateShowDamage = true,
        },
    }
}

function CombatText:PLAYER_REGEN_ENABLED()
    private.FlushQueues()
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

function CombatText:COMBAT_TEXT_UPDATE(event, messageType)
    local desc1, desc2 = _G.GetCurrentCombatTextEventInfo()
    private.HandleMessageType(messageType, desc1, desc2)
end

function CombatText:UNIT_ENTERED_VEHICLE(event, unit, showVehicle, ...)
    if unit == "player" and showVehicle then
        _G.C_CombatText.SetActiveUnit("vehicle")
    end
end

function CombatText:UNIT_EXITING_VEHICLE(event, unit)
    if unit == "player" then
        _G.C_CombatText.SetActiveUnit("player")
    end
end

function CombatText:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_CombatTextDB", defaults, true)
    FramePoint:RegisterMod(self)

    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    _G.C_CombatText.SetActiveUnit("player")
    self:RegisterEvent("COMBAT_TEXT_UPDATE")
    self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    self:RegisterEvent("UNIT_EXITING_VEHICLE")
    private.CreateScrollAreas()

    -- Apply Blizzard FCT CVar settings
    local fct = self.db.global.blizzardFCT
    _G.SetCVar("enableFloatingCombatText", fct.enableFloatingCombatText and "1" or "0")
    _G.SetCVar("floatingCombatTextCombatDamage", fct.floatingCombatTextCombatDamage and "1" or "0")
    _G.SetCVar("floatingCombatTextCombatHealing", fct.floatingCombatTextCombatHealing and "1" or "0")
    _G.SetCVar("nameplateShowDamage", fct.nameplateShowDamage and "1" or "0")

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
