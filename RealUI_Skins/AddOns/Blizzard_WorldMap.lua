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

    -- Cache ScrollContainer reference to avoid repeated table lookups on
    -- WorldMapFrame from insecure timer callbacks, which can propagate taint
    -- to the pin creation code path (AcquirePin → ScrollContainer:MarkCanvasDirty
    -- → CheckMouseButtonPassthrough → SetPassThroughButtons).
    local cachedScrollContainer

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

        -- Mouse: use cached ScrollContainer to avoid insecure access to
        -- mapFrame.ScrollContainer, which shares the object used by
        -- AcquirePin's secure pin creation path.  Also call
        -- GetNormalizedCursorPosition on the ScrollContainer directly
        -- instead of going through mapFrame (WorldMapFrame) to avoid an
        -- insecure method call on the map canvas.
        local sc = cachedScrollContainer
        if sc and sc:IsMouseOver() then
            local cursorX, cursorY = sc:GetNormalizedCursorPosition()

            cursorX = round(100 * cursorX, 1)
            cursorY = round(100 * cursorY, 1)
            coords.mouse:SetText(coordinateFormat:format(_G.MOUSE_LABEL, cursorX, cursorY))
        else
            coords.mouse:SetText("")
        end
    end

    function Hook.StartCoordinateTracking(coords, mapFrame)
        if ticker then
            ticker:Cancel()
        end
        ticker = _G.C_Timer.NewTicker(0.1, function()
            updateCoords(coords, mapFrame)
        end)
    end

    function Hook.StopCoordinateTracking()
        if ticker then
            ticker:Cancel()
            ticker = nil
        end
    end

    function Hook.SetCachedScrollContainer(sc)
        cachedScrollContainer = sc
    end
end

--[[ do AddOns\Blizzard_WorldMap.xml
end ]]

_G.hooksecurefunc(private.AddOns, "Blizzard_WorldMap", function()
    local WorldMapFrame = _G.WorldMapFrame

    -- Cache ScrollContainer once during initialization so that the coordinate
    -- tracking ticker never needs to index into WorldMapFrame at runtime.
    -- Accessing WorldMapFrame.ScrollContainer from insecure timer callbacks was
    -- a taint vector for the pin creation path (ADDON_ACTION_BLOCKED on
    -- SetPassThroughButtons).
    Hook.SetCachedScrollContainer(WorldMapFrame.ScrollContainer)

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

    -- Use an invisible child frame to detect WorldMapFrame visibility changes.
    -- This avoids both HookScript on WorldMapFrame (which taints its script
    -- chain) and the previous OnUpdate monitor (which called
    -- WorldMapFrame:IsShown() ~60 times/sec from insecure code, propagating
    -- taint to the map canvas pin system).
    local visMonitor = _G.CreateFrame("Frame", nil, WorldMapFrame)
    visMonitor:SetScript("OnShow", function()
        Hook.StartCoordinateTracking(coords, WorldMapFrame)
    end)
    visMonitor:SetScript("OnHide", function()
        Hook.StopCoordinateTracking()
    end)

    -- Start tracking if map is already open
    if WorldMapFrame:IsShown() then
        Hook.StartCoordinateTracking(coords, WorldMapFrame)
    end
end)
