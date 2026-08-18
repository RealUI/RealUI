local _, private = ...
local AB = private.AB

--[[ RealUI HuD integration (spec task 9): compute the RealUI bar layout from
     the HuD settings and write it into our own DB — the same geometry
     RealUI's ActionBars module used to drive INTO Bartender4 (ported from
     Modules/ActionBars.lua ApplyABSettings; constants: 35px math cells,
     buttonPadding 1, BT4-semantics bar padding -9, infobar-height bottom
     base). Standalone (no RealUI) keeps the static defaults.

     Trigger: RealUI recomputes on layout/spec/HuD changes through
     ApplyABSettings — we hooksecurefunc it and ride the same web. ]]--

local MATH_BUTTON = 35       -- geometry cell (matches ApplyABSettings' buttonSizes.bars)
local MATH_PADDING = 1       -- geometry padding (fixedSettings.buttonPadding)
-- Read-fallbacks only (mirror Defaults.lua) — the geometry reads the user's
-- per-bar buttonSize/padding/scale and never writes them back.
local BUTTON_SIZE = 27       -- == BT4's 36 at -9 overlap, without the overlap
local BUTTON_GAP = 2         -- true visible gap between buttons (B28)

local function IsOdd(value)
    return value % 2 == 1
end

local function GetBottomBase()
    local infobar = _G.RealUI_Infobar
    if infobar and infobar.GetHeight then
        local height = infobar:GetHeight()
        if height and height > 0 then return height end
    end
    local RealUI = _G.RealUI
    if RealUI and RealUI.Scale and RealUI.Scale.Value then
        return RealUI.Scale.Value(16)
    end
    return 16
end

function private.ApplyRealUILayout()
    local RealUI = _G.RealUI
    if not (RealUI and RealUI.db and RealUI.db.profile) then return false, "RealUI db not ready" end
    local abModule = RealUI.GetModule and RealUI:GetModule("ActionBars", true)
    if not (abModule and abModule.db and abModule.db.profile) then return false, "RealUI ActionBars module db not ready" end

    local cLayout = RealUI.cLayout or 1
    local barSettings = abModule.db.profile[cLayout]
    if not barSettings then return false, "no barSettings for layout " .. _G.tostring(cLayout) end

    local ndb = RealUI.db.profile
    local layoutPositions = ndb.positions and ndb.positions[cLayout]
    if not layoutPositions then return false, "no positions for layout " .. _G.tostring(cLayout) end

    local numTopBars = (barSettings.centerPositions or 2) - 1
    local sidePositions
    if barSettings.sidePositions == 1 then
        sidePositions = { [4] = "RIGHT", [5] = "RIGHT" }
    elseif barSettings.sidePositions == 2 then
        sidePositions = { [4] = "RIGHT", [5] = "LEFT" }
    else
        sidePositions = { [4] = "LEFT", [5] = "LEFT" }
    end

    local hudSizeOffsets = RealUI.hudSizeOffsets or {}
    local hudSize = ndb.settings and ndb.settings.hudSize
    local sizeOffsets = (hudSize and hudSizeOffsets[hudSize]) or hudSizeOffsets[2] or hudSizeOffsets[1] or {}
    local topYOfs = (layoutPositions.HuDY or 0) + (layoutPositions.ActionBarsY or 0)
        + (sizeOffsets.ActionBarsY or 0)
    -- B11: the HuD "Vertical" slider writes positions[layout].ActionBarsY,
    -- which only top (CENTER-anchored) bars consume via topYOfs — bottom
    -- bars sat at the infobar and ignored it, so the slider was dead on any
    -- layout with bottom bars. Bottom bars now follow the USER's slider
    -- delta: current value minus the computed baseline HuDPositioning keeps
    -- in RealUI.defaultPositions. Untouched slider -> delta 0 -> bottom bars
    -- stay exactly on the infobar, same as always.
    local defaultLayoutPositions = RealUI.defaultPositions and RealUI.defaultPositions[cLayout]
    local baselineY = defaultLayoutPositions and defaultLayoutPositions.ActionBarsY
    local sliderDelta = 0
    if baselineY and layoutPositions.ActionBarsY then
        sliderDelta = layoutPositions.ActionBarsY - baselineY
    end
    local bottomBase = GetBottomBase() + 14 + sliderDelta
    local centerPadding = MATH_PADDING / 2
    local barGap = _G.math.ceil(centerPadding + centerPadding)

    local border = private.BUTTON_BORDER or 1

    local barSizes = {}
    for id = 1, 5 do
        local db = AB.dbActionBars.profile.actionbars[id]
        if db and db.enabled then
            local numButtons = db.buttons or 12
            -- Per-bar look settings belong to the USER. They are AceDB
            -- defaults (Defaults.lua: 27px buttons, 2px visible gap,
            -- scale 1), so the shipped look arrives as a default — the
            -- geometry only READS them. Force-writing 27/0/1 here on every
            -- recompute was the last settings-reset vector left after the
            -- B43/B44 coordinator fixes: with RealUI_ActionBarsDB now
            -- profile-switched via ProfileCoordinator, every swap ran a
            -- recompute that wiped configured per-bar values.
            local buttonSize = db.buttonSize or BUTTON_SIZE
            local gap = (db.padding or BUTTON_GAP) + border * 2  -- frame gap (B28 box model)
            local scale = db.scale or 1
            -- REAL rendered extent in SCREEN pixels (border-aware gaps, bar
            -- scale applied), not the 35+1 math cells ApplyABSettings used —
            -- centering with the math width left bars half-a-cell-per-button
            -- off on screen.
            local frameExtent = buttonSize * numButtons + gap * (numButtons - 1)
            barSizes[id] = frameExtent * scale

            local isVertBar = id > 3
            local isRightBar = isVertBar and sidePositions[id] == "RIGHT"
            local isTopBar = not isVertBar and id <= numTopBars

            local x, y, point
            if isVertBar then
                -- B05: the bar's grow corner IS its screen corner (Bar.lua
                -- anchoring) and the 1px border overhangs the frame — the
                -- BT4-era x = +/-8 pushed side bars 8px past the screen edge
                -- (clipping the keybind text with them). Inset one border
                -- width so the bar sits fully on-screen, border flush with
                -- the edge.
                x = (isRightBar and -border or border) * scale
                if sidePositions[4] == sidePositions[5] then
                    -- Linked side bars stack: bar 4 above bar 5, with the
                    -- same visible gap between the bars as between buttons.
                    if id == 4 then
                        y = barSizes[4] + gap * scale + 10.5
                    else
                        y = 10.5
                    end
                else
                    -- Vertically centered on the side point (top edge at half
                    -- the real height; half-pixel nudge keeps odd heights on
                    -- the pixel grid).
                    y = (barSizes[id] / 2) + 10
                    if IsOdd(frameExtent) then y = y + 0.5 end
                end
                point = sidePositions[id]
                db.flyoutDirection = (sidePositions[id] == "LEFT") and "RIGHT" or "LEFT"
                db.rows = 12
                db.growHorizontal = isRightBar and "LEFT" or "RIGHT"
            else
                -- Horizontally centered: left edge at half the real width
                -- (the outside borders overhang symmetrically, so centering
                -- the frame centers the visual too).
                x = -(barSizes[id] / 2)
                if IsOdd(frameExtent) then x = x + 0.5 end

                local barPlace
                if id == 1 then
                    barPlace = (numTopBars > 0) and 1 or (3 - numTopBars)
                elseif id == 2 then
                    barPlace = 2
                else
                    barPlace = isTopBar and 3 or 1
                end

                if barPlace == 1 then
                    y = isTopBar and topYOfs or bottomBase
                elseif barPlace == 2 then
                    y = isTopBar and (-(MATH_BUTTON + barGap) + topYOfs)
                        or (bottomBase + MATH_BUTTON + barGap)
                else
                    local pad2 = _G.math.ceil(centerPadding * 4)
                    y = isTopBar and (-((MATH_BUTTON * 2) + pad2) + topYOfs)
                        or (bottomBase + (MATH_BUTTON * 2) + pad2)
                end

                point = isTopBar and "CENTER" or "BOTTOM"
                db.flyoutDirection = isTopBar and "DOWN" or "UP"
                db.rows = 1
                db.growHorizontal = "RIGHT"
            end

            -- NO writes to buttonSize/padding/scale here — user-owned (see
            -- above). The layout engine owns only orientation + position.
            db.growVertical = "DOWN"
            db.position.point = point
            -- x/y above are screen-space intents; SetPoint offsets live in
            -- the bar's scaled space (Bar.lua sets scale before anchoring),
            -- so store them divided by the bar's scale.
            db.position.x = x / scale
            db.position.y = y / scale
        else
            barSizes[id] = 0
        end
    end

    private.ApplyAllBars()
    return true
end

function private.SetupRealUIIntegration()
    local RealUI = _G.RealUI
    if not (RealUI and RealUI.GetModule) then return end
    local abModule = RealUI:GetModule("ActionBars", true)
    if not abModule then return end

    -- Ride RealUI's own recompute triggers (layout swaps, HuD size, spec
    -- changes): whenever it would have re-driven Bartender4, re-drive us.
    _G.hooksecurefunc(abModule, "ApplyABSettings", function()
        private.QueueSecure(private.ApplyRealUILayout)
    end)
end
