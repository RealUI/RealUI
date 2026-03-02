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

    -- Cached references captured once during init.  The ticker must NEVER
    -- index into WorldMapFrame at runtime – doing so from insecure timer
    -- callbacks propagates taint to the secure pin creation path
    -- (AcquirePin → CheckMouseButtonPassthrough → SetPassThroughButtons).
    local cachedScrollContainer
    local coordOverlay  -- independent UIParent-rooted frame for the font strings

    local function updateCoords(coords)
        if not HBD then
            HBD = _G.LibStub("HereBeDragons-2.0")
        end

        -- Auto-stop: if the ScrollContainer is no longer shown the map was
        -- closed.  This avoids any need for child frames or HookScript on
        -- WorldMapFrame that would inject addon code into its show/hide chain.
        local sc = cachedScrollContainer
        if not sc or not sc:IsShown() then
            Hook.StopCoordinateTracking()
            if coordOverlay then coordOverlay:Hide() end
            return
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

        -- Mouse – call on the cached ScrollContainer directly; never go
        -- through WorldMapFrame:GetNormalizedCursorPosition().
        if sc:IsMouseOver() then
            local cursorX, cursorY = sc:GetNormalizedCursorPosition()
            cursorX = round(100 * cursorX, 1)
            cursorY = round(100 * cursorY, 1)
            coords.mouse:SetText(coordinateFormat:format(_G.MOUSE_LABEL, cursorX, cursorY))
        else
            coords.mouse:SetText("")
        end
    end

    -- No WorldMapFrame reference in the closure – only `coords` (our own
    -- table with font strings) is captured.
    function Hook.StartCoordinateTracking(coords)
        if ticker then
            ticker:Cancel()
        end
        if coordOverlay then coordOverlay:Show() end
        ticker = _G.C_Timer.NewTicker(0.1, function()
            updateCoords(coords)
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

    function Hook.SetCoordOverlay(overlay)
        coordOverlay = overlay
    end
end

--[[ do AddOns\Blizzard_WorldMap.xml
end ]]

_G.hooksecurefunc(private.AddOns, "Blizzard_WorldMap", function()
    -- Read references ONCE during initialisation.  Do NOT store
    -- WorldMapFrame itself in any closure or upvalue used by the ticker.
    local scrollContainer = _G.WorldMapFrame.ScrollContainer
    local titleContainer  = _G.WorldMapFrame.BorderFrame.TitleContainer
    Hook.SetCachedScrollContainer(scrollContainer)

    -- Create coordinate display as a standalone overlay parented to UIParent.
    -- Adding children or font strings directly to WorldMapFrame / BorderFrame
    -- modifies the C-side frame hierarchy from addon code, which the engine's
    -- taint tracking propagates into the secure pin creation path and
    -- eventually blocks SetPassThroughButtons.
    local overlay = _G.CreateFrame("Frame", nil, _G.UIParent)
    overlay:SetFrameStrata("HIGH")
    overlay:SetFrameLevel(200)
    overlay:Hide()
    Hook.SetCoordOverlay(overlay)

    local player = overlay:CreateFontString(nil, "OVERLAY")
    player:SetPoint("LEFT", titleContainer, -20, 0)
    player:SetFontObject(_G.SystemFont_Shadow_Med1)
    player:SetJustifyH("LEFT")
    player:SetText("")

    local mouse = overlay:CreateFontString(nil, "OVERLAY")
    mouse:SetPoint("LEFT", titleContainer, 100, 0)
    mouse:SetFontObject(_G.SystemFont_Shadow_Med1)
    mouse:SetJustifyH("LEFT")
    mouse:SetText("")

    local coords = {
        player = player,
        mouse = mouse,
    }

    -- Detect map opening via WORLD_MAP_OPEN game event.  The ticker's
    -- self-check on ScrollContainer:IsShown() handles stopping when the
    -- map closes, so no WORLD_MAP_CLOSE / HookScript / child frame is
    -- needed – all of which would inject addon code into WorldMapFrame's
    -- show/hide processing and taint the pin creation path.
    local eventFrame = _G.CreateFrame("Frame")
    eventFrame:RegisterEvent("WORLD_MAP_OPEN")
    eventFrame:SetScript("OnEvent", function()
        Hook.StartCoordinateTracking(coords)
    end)

    -- Start tracking if map is already open at load time
    if _G.WorldMapFrame:IsShown() then
        Hook.StartCoordinateTracking(coords)
    end
end)
