local _, private = ...

-- Lua Globals --
local _G = _G
local tremove, tinsert = _G.table.remove, _G.table.insert

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "AchievementScreenshots"
local AchievementScreenshots = RealUI:NewModule(MODNAME, "AceEvent-3.0")

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
end

function AchievementScreenshots:OnEnable()
    self:RegisterEvent("ACHIEVEMENT_EARNED")
end

function AchievementScreenshots:OnDisable()
    self:UnregisterAllEvents()
end
