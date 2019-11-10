local _, private = ...

-- Lua Globals --
-- luacheck: globals next tinsert ceil

-- RealUI --
local RealUI = _G.RealUI

local CombatText = RealUI:NewModule("CombatText")
private.CombatText = CombatText

local defaults = {
    global = {
        incoming = {
            position = {
                x = -200,
                y = 0,
                point = "CENTER"
            }
        },
        outgoing = {
            position = {
                x = 200,
                y = 0,
                point = "CENTER"
            }
        }
    }
}

function CombatText:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_CombatTextDB", defaults, true)

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
