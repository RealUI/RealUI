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
    local bottomBase = GetBottomBase() + 14
    local centerPadding = MATH_PADDING / 2
    local barGap = _G.math.ceil(centerPadding + centerPadding)

    local barSizes = {}
    for id = 1, 5 do
        local db = AB.dbActionBars.profile.actionbars[id]
        if db and db.enabled then
            local numButtons = db.buttons or 12
            -- REAL rendered extent (button size + overlap pitch), not the
            -- 35+1 math cells ApplyABSettings used — centering with the math
            -- width left bars half-a-cell-per-button off on screen.
            local buttonSize = db.buttonSize or 27
            local pitch = buttonSize + (db.padding or 0)
            barSizes[id] = buttonSize + pitch * (numButtons - 1)

            local isVertBar = id > 3
            local isRightBar = isVertBar and sidePositions[id] == "RIGHT"
            local isTopBar = not isVertBar and id <= numTopBars

            local x, y, point
            if isVertBar then
                x = isRightBar and 8 or -8
                if sidePositions[4] == sidePositions[5] then
                    -- Linked side bars stack: bar 4 above bar 5.
                    if id == 4 then
                        y = barSizes[4] + MATH_PADDING + 10.5
                    else
                        y = 10.5
                    end
                else
                    -- Vertically centered on the side point (top edge at half
                    -- the real height).
                    y = (barSizes[id] / 2) + 10
                    if not IsOdd(MATH_PADDING) or IsOdd(numButtons) then y = y + 0.5 end
                end
                point = sidePositions[id]
                db.flyoutDirection = (sidePositions[id] == "LEFT") and "RIGHT" or "LEFT"
                db.rows = 12
                db.growHorizontal = isRightBar and "LEFT" or "RIGHT"
            else
                -- Horizontally centered: left edge at half the real width.
                x = -(barSizes[id] / 2)
                if not IsOdd(MATH_PADDING) or IsOdd(numButtons) then x = x + 1.0 end

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

            db.padding = 0
            db.buttonSize = 27  -- == BT4's 36 at -9 overlap, without the overlap
            db.scale = 1
            db.growVertical = "DOWN"
            db.position.point = point
            db.position.x = x
            db.position.y = y
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
