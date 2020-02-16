local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs next

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "InterfaceTweaks"
local InterfaceTweaks = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local modules, moduleEvents = {}, {}
local function AddTweak(tag, name, event, func)
    modules[tag] = name
    if event then
        if not moduleEvents[event] then
            moduleEvents[event] = {}
        end

        tinsert(moduleEvents[event], func)
    end
end


----====####$$$$%%%%%$$$$####====----
--     Achievement Screenshots     --
----====####$$$$%%%%%$$$$####====----
AddTweak("achShots", "Tweaks_Achievements", "ACHIEVEMENT_EARNED", function(self, event, achievementID, alreadyEarned)
    if not InterfaceTweaks.db.global.achShots then return end

    _G.C_Timer.After(1, function()
        _G.Screenshot()
    end)
end)


----====####$$$$%%%%%$$$$####====----
--        Auto Holiday Boss        --
----====####$$$$%%%%%$$$$####====----
AddTweak("autoHoliday", "Tweaks_AutoHoliday") do
    local doneHoliday
    _G.LFDParentFrame:HookScript("OnShow", function()
        if not InterfaceTweaks.db.global.autoHoliday then return end

        if not doneHoliday then
            for index = 1, _G.GetNumRandomDungeons() do
                local dungeonID = _G.GetLFGRandomDungeonInfo(index)
                local isHoliday = _G.select(15, _G.GetLFGDungeonInfo(dungeonID))
                if isHoliday then
                    if _G.GetLFGDungeonRewards(dungeonID) then
                        doneHoliday = true
                    else
                        _G.LFDQueueFrame_SetType(dungeonID)
                    end
                end
            end
        end
    end)
end


----====####$$$$%%%%%$$$$####====----
--           Mouse Trail           --
----====####$$$$%%%%%$$$$####====----
AddTweak("mouseTrail", "Tweaks_MouseTrail") do
    local pollingRate, numLines = 0.05, 15

    local lines = {}
    for i = 1, numLines do
        local line = _G.UIParent:CreateLine()
        line:SetThickness(_G.Lerp(5, 1, (i - 1)/numLines))
        line:SetColorTexture(1, 1, 1)

        local startA, endA = _G.Lerp(1, 0, (i - 1)/numLines), _G.Lerp(1, 0, i/numLines)
        line:SetGradientAlpha("HORIZONTAL", 1, 1, 1, startA, 1, 1, 1, endA)

        lines[i] = {line = line, x = 0, y = 0}
    end

    _G.C_Timer.NewTicker(pollingRate, function()
        if not InterfaceTweaks.db.global.mouseTrail then return end

        local scale = _G.UIParent:GetEffectiveScale()
        local startX, startY = _G.GetCursorPosition()

        for i = 1, numLines do
            local info = lines[i]

            local endX, endY = info.x, info.y
            info.line:SetStartPoint("BOTTOMLEFT", _G.UIParent, startX / scale, startY / scale)
            info.line:SetEndPoint("BOTTOMLEFT", _G.UIParent, endX / scale, endY / scale)

            info.x, info.y = startX, startY
            startX, startY = endX, endY
        end
    end)
end


function InterfaceTweaks:GetTweaks()
    return RealUI.ShallowCopy(modules)
end

function InterfaceTweaks:OnEvent(event, ...)
    for _, func in ipairs(moduleEvents[event]) do
        func(...)
    end
end

function InterfaceTweaks:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        global = {
            ["**"] = false
        },
    })

    for event in next, moduleEvents do
        self:RegisterEvent(event, "OnEvent")
    end
end
