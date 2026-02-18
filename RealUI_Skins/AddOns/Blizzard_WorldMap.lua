local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Hook = Aurora.Hook
local Color = Aurora.Color

local HBD --= _G.LibStub("HereBeDragons-2.0")

do --[[ AddOns\Blizzard_WorldMap.lua ]]
    local colorStr = Color.highlight.colorStr
    local round = _G.RealUI.Scale.Round
    local ticker

    local coordinateFormat = ("|c%s%s"):format(colorStr, "%s: |cffffffff%s, %s|r")
    local coordinateUnavailable = ("|c%s%s: |cffffffff%s|r"):format(colorStr, _G.PLAYER, _G.UNAVAILABLE)
    local function updateCoords(coords, mapFrame)
        if not HBD then
            HBD = _G.LibStub("HereBeDragons-2.0")
        end

        -- Player
        local playerX, playerY = HBD:GetPlayerZonePosition()
        if playerX and playerY then
            playerX = round(100 * playerX, 1)
            playerY = round(100 * playerY, 1)

            coords.player:SetText(coordinateFormat:format(_G.PLAYER, playerX, playerY))
        else
            coords.player:SetText(coordinateUnavailable)
        end

        -- Mouse
        if mapFrame.ScrollContainer:IsMouseOver() then
            local cursorX, cursorY = mapFrame:GetNormalizedCursorPosition()

            cursorX = round(100 * cursorX, 1)
            cursorY = round(100 * cursorY, 1)
            coords.mouse:SetText(coordinateFormat:format(_G.MOUSE_LABEL, cursorX, cursorY))
        else
            coords.mouse:SetText("")
        end
    end

    -- Create a monitoring frame that doesn't taint WorldMapFrame
    local monitorFrame = _G.CreateFrame("Frame")
    monitorFrame:Hide()

    function Hook.StartCoordinateTracking(coords, mapFrame)
        if ticker then
            ticker:Cancel()
        end
        ticker = _G.C_Timer.NewTicker(0.1, function()
            updateCoords(coords, mapFrame)
        end)
        monitorFrame:Show()
    end

    function Hook.StopCoordinateTracking()
        if ticker then
            ticker:Cancel()
            ticker = nil
        end
        monitorFrame:Hide()
    end

    -- Monitor WorldMapFrame visibility without hooking its scripts
    monitorFrame:SetScript("OnUpdate", function(self)
        local mapFrame = _G.WorldMapFrame
        if mapFrame and not mapFrame:IsShown() then
            Hook.StopCoordinateTracking()
        end
    end)
end

--[[ do AddOns\Blizzard_WorldMap.xml
end ]]

_G.hooksecurefunc(private.AddOns, "Blizzard_WorldMap", function()
    local WorldMapFrame = _G.WorldMapFrame

    -- Create coordinate display elements
    local player = WorldMapFrame.BorderFrame:CreateFontString(nil, "OVERLAY")
    player:SetPoint("LEFT", WorldMapFrame.BorderFrame.TitleContainer, -20, 0)
    player:SetFontObject(_G.SystemFont_Shadow_Med1)
    player:SetJustifyH("LEFT")
    player:SetText("")

    local mouse = WorldMapFrame.BorderFrame:CreateFontString(nil, "OVERLAY")
    mouse:SetPoint("LEFT", WorldMapFrame.BorderFrame.TitleContainer, 100, 0)
    mouse:SetFontObject(_G.SystemFont_Shadow_Med1)
    mouse:SetJustifyH("LEFT")
    mouse:SetText("")

    local coords = {
        player = player,
        mouse = mouse
    }

    -- Use an event frame to track map visibility without tainting
    local eventFrame = _G.CreateFrame("Frame")
    eventFrame:RegisterEvent("WORLD_MAP_OPEN")
    eventFrame:RegisterEvent("WORLD_MAP_CLOSE")
    eventFrame:SetScript("OnEvent", function(self, event)
        if event == "WORLD_MAP_OPEN" then
            Hook.StartCoordinateTracking(coords, WorldMapFrame)
        elseif event == "WORLD_MAP_CLOSE" then
            Hook.StopCoordinateTracking()
        end
    end)

    -- Start tracking if map is already open
    if WorldMapFrame:IsShown() then
        Hook.StartCoordinateTracking(coords, WorldMapFrame)
    end
end)
