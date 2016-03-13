local _, private = ...

-- Lua Globals --
local _G = _G
local tremove, tinsert = _G.table.remove, _G.table.insert

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "AchievementScreenshots"
local AchievementScreenshots = RealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Achievement Screenshots",
        desc = "Takes a screenshot whenever an achievement is earned.",
        arg = MODNAME,
        -- order = 1916,
        args = {
            header = {
                type = "header",
                name = "Achievement Screenshots",
                order = 10,
            },
            desc = {
                type = "description",
                name = "Takes a screenshot whenever an achievement is earned.",
                fontSize = "medium",
                order = 20,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Achievement Screenshots module.",
                get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value) 
                    RealUI:SetModuleEnabled(MODNAME, value)
                end,
                order = 30,
            },
        },
    }
    end
    return options
end

----------------------------------------------------------------------------------------
--  Take screenshots of Achievements(Based on Achievement Screenshotter by Blamdarot)
----------------------------------------------------------------------------------------
local function TakeScreen(delay, func, ...)
    local waitTable = {}
    local waitFrame = _G.CreateFrame("Frame", "WaitFrame", _G.UIParent)
    waitFrame:SetScript("onUpdate", function (self, elapse)
        local count = #waitTable
        local i = 1
        while (i <= count) do
            local waitRecord = tremove(waitTable, i)
            local d = tremove(waitRecord, 1)
            local f = tremove(waitRecord, 1)
            local p = tremove(waitRecord, 1)
            if d > elapse then
                tinsert(waitTable, i, {d-elapse, f, p})
                i = i + 1
            else
                count = count - 1
                f(_G.unpack(p))
            end
        end
    end)
    tinsert(waitTable, {delay, func, {...} })
end

local function TakeScreenshot()
    TakeScreen(1, TakeScreenshot)
end

function AchievementScreenshots:ACHIEVEMENT_EARNED()
    TakeScreenshot()
end

function AchievementScreenshots:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
        },
    })
    
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    RealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function AchievementScreenshots:OnEnable()
    self:RegisterEvent("ACHIEVEMENT_EARNED")
end

function AchievementScreenshots:OnDisable()
    self:UnregisterAllEvents()
end
