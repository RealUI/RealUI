local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "AchievementScreenshots"
local AchievementScreenshots = RealUI:NewModule(MODNAME, "AceEvent-3.0")

function AchievementScreenshots:ACHIEVEMENT_EARNED(event, achievementID, alreadyEarned)
    self:debug(achievementID, alreadyEarned)
    _G.C_Timer.After(1, function()
        _G.Screenshot()
    end)
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
