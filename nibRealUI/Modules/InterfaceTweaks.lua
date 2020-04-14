local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs next

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "InterfaceTweaks"
local InterfaceTweaks = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local modules, moduleEvents = {}, {}
local function AddTweak(tag, info)
    modules[tag] = info
    if info.event then
        if not moduleEvents[info.event] then
            moduleEvents[info.event] = {}
        end

        tinsert(moduleEvents[info.event], info.func)
        InterfaceTweaks:RegisterEvent(info.event, "OnEvent")
    end
end


function InterfaceTweaks:AddTweak(tag, info, enabled)
    AddTweak(tag, info)
    self.db.global[tag] = enabled
end
function InterfaceTweaks:GetTweaks()
    return RealUI.ShallowCopy(modules)
end

function InterfaceTweaks:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        if ... == "nibRealUI" then
            self:UnregisterEvent("ADDON_LOADED")
            for tag, info in next, modules do
                if info.setEnabled then
                    info.setEnabled(self.db.global[tag])
                end
            end
        end
    else
        for _, func in ipairs(moduleEvents[event]) do
            func(...)
        end
    end
end


----====####$$$$%%%%%$$$$####====----
--     Achievement Screenshots     --
----====####$$$$%%%%%$$$$####====----
AddTweak("achShots", {
    name = "Tweaks_Achievements",
    event = "ACHIEVEMENT_EARNED",
    func = function(self, event, achievementID, alreadyEarned)
        if not InterfaceTweaks.db.global.achShots then return end

        _G.C_Timer.After(1, function()
            _G.Screenshot()
        end)
    end
})


----====####$$$$%%%%%$$$$####====----
--        Auto Holiday Boss        --
----====####$$$$%%%%%$$$$####====----
do
    AddTweak("autoHoliday", {
        name = "Tweaks_AutoHoliday",
    })
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
do
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

    local function UpdateTrail()
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
    end

    local ticker
    AddTweak("mouseTrail", {
        name = "Tweaks_MouseTrail",
        setEnabled = function(enabled)
            if enabled then
                ticker = _G.C_Timer.NewTicker(pollingRate, UpdateTrail)
            elseif ticker then
                ticker:Cancel()
            end
        end,
    })
end


InterfaceTweaks:RegisterEvent("ADDON_LOADED", "OnEvent")
function InterfaceTweaks:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        global = {
            ["**"] = false
        },
    })
end
