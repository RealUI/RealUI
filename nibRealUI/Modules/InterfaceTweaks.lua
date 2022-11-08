local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs next sqrt

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "InterfaceTweaks"
local InterfaceTweaks = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local modules, moduleEvents = {}, {}
local moduleAddons = {
    nibRealUI = {
        function()
            for tag, info in next, modules do
                if info.setEnabled then
                    info.setEnabled(InterfaceTweaks.db.global[tag])
                end
            end
        end
    }
}
local function AddTweak(tag, info)
    modules[tag] = info
    if info.addon then
        if not moduleAddons[info.addon] then
            moduleAddons[info.addon] = {}
        end
        tinsert(moduleAddons[info.addon], info.onLoad)
    end
    if info.event then
        if not moduleEvents[info.event] then
            moduleEvents[info.event] = {}
        end

        tinsert(moduleEvents[info.event], info.func)
        InterfaceTweaks:RegisterEvent(info.event, "OnEvent")
    end
end


function InterfaceTweaks:AddTweak(tag, info, enabled)
    if self.db then
        self.db.global[tag] = enabled
    else
        info.isEnabled = enabled
    end

    AddTweak(tag, info)
end
function InterfaceTweaks:GetTweaks()
    return RealUI.ShallowCopy(modules)
end

function InterfaceTweaks:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local addon = ...
        if moduleAddons[addon] then
            for _, func in ipairs(moduleAddons[addon]) do
                func()
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
    func = function(achievementID, alreadyEarned)
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
        line:SetGradient("HORIZONTAL", Color.Create(1, 1, 1, startA), Color.Create(1, 1, 1, endA))
        lines[i] = {line = line, x = 0, y = 0}
    end

    local function GetLength(startX, startY, endX, endY)
        -- Determine dimensions
        local dx, dy = endX - startX, endY - startY

        -- Normalize direction if necessary
        if dx < 0 then
            dx, dy = -dx, -dy
        end

        -- Calculate actual length of line
        return sqrt((dx * dx) + (dy * dy))
    end
    local function UpdateTrail()
        local startX, startY = _G.GetScaledCursorPosition()

        for i = 1, numLines do
            local info = lines[i]

            local endX, endY = info.x, info.y
            if GetLength(startX, startY, endX, endY) < 0.1 then
                info.line:Hide()
            else
                info.line:Show()
                info.line:SetStartPoint("BOTTOMLEFT", _G.UIParent, startX, startY)
                info.line:SetEndPoint("BOTTOMLEFT", _G.UIParent, endX, endY)
            end

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

    for tag, info in next, modules do
        if info.isEnabled ~= nil then
            self.db.global[tag] = info.isEnabled
            info.isEnabled = nil
        end
    end
end
