local _, private = ...
local AB = private.AB

--[[ RealUI HuD integration: compute the bar layout from the HuD settings and
     write it into our own DB. Standalone (no RealUI) keeps the static
     defaults from Defaults.lua.

     The geometry is expressed in RealUI_ActionBars' own terms — real rendered
     extents, the B28 box model (visible gap = padding, frame gap = padding +
     2 borders), per-bar buttonSize/scale read from the user's settings.

     Lineage, since it explains the comments below: this math was ported from
     RealUI's `Modules/ActionBars.lua` ApplyABSettings, which computed in
     Bartender4 proportions (35px "math cells", 36px effective button pitch,
     -9 overlap padding). Those units are NOT ours and every one of them that
     survived the port has produced a bug — off-centre bars (fixed by
     switching horizontal centering to real extents) and a 5px-per-row error
     in vertical stacking (fixed the same way). If a bare numeric constant
     appears in this file again, check which addon's button size it belongs to.

     Trigger: RealUI recomputes on layout/spec/HuD changes through
     ApplyABSettings — we hooksecurefunc it and ride the same web. ]]--

-- Read-fallbacks only (mirror Defaults.lua) — the geometry reads the user's
-- per-bar buttonSize/padding/scale and never writes them back.
local BUTTON_SIZE = 27       -- RealUI's button face
local BUTTON_GAP = 2         -- true visible gap between borders (B28 box model)

local function IsOdd(value)
    return value % 2 == 1
end

--[[ Height of the strip the bottom bar row must clear (the Infobar).

     Takes the LARGER of the live frame height and the scaled BAR_HEIGHT
     constant rather than preferring the live value outright. The old
     `height > 0` guard accepted any positive number, so an Infobar caught
     mid-construction — sized but not yet laid out — yielded a too-small base
     and sat the bottom bar row on top of it. B65 is an unreproduced report of
     exactly that, and the failure is invisible afterwards because nothing
     re-runs the layout once the Infobar finishes sizing.

     The raw `16` last resort is deliberately last: it is the UNSCALED
     constant and is known to put bars ~29px under the Infobar on HiDPI (see
     the ActionBarsBotY section of the spec-swap steering doc). ]]
local function GetBottomBase()
    local RealUI = _G.RealUI
    local scaled = 16
    if RealUI and RealUI.Scale and RealUI.Scale.Value then
        scaled = RealUI.Scale.Value(16) or 16
    end

    local infobar = _G.RealUI_Infobar
    if infobar and infobar.GetHeight then
        local height = infobar:GetHeight()
        if height and height > scaled then return height end
    end

    return scaled
end

--[[ B65, the other half: taking the larger value stops us BELIEVING a
     half-built Infobar, but it does not fix the case the comment above
     admits — "nothing re-runs the layout once the Infobar finishes sizing".
     A layout computed while the Infobar was still smaller than its final
     height stays wrong for the rest of the session, which is exactly the
     shape of an unreproducible overlap report: it depends on load-order
     timing, and once it has happened nothing disturbs it.

     So watch the Infobar and recompute when its height actually changes.
     Cheap: OnSizeChanged fires rarely, the layout is only re-driven when the
     base moves by more than a rounding wobble, and there is no feedback loop
     because the bar layout never sizes the Infobar. ]]
local lastBottomBase
local function OnInfobarResized()
    local base = GetBottomBase()
    if lastBottomBase and _G.math.abs(base - lastBottomBase) < 0.5 then return end
    private.QueueSecure(private.ApplyRealUILayout)
end

function private.WatchInfobarHeight()
    local infobar = _G.RealUI_Infobar
    if not (infobar and infobar.HookScript) or infobar._ruiABHeightWatch then return end
    infobar._ruiABHeightWatch = true
    infobar:HookScript("OnSizeChanged", OnInfobarResized)
    -- The Infobar may already have grown past whatever the first layout used.
    OnInfobarResized()
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
    -- A MISSING key is not zero. `positions[layout]` can exist while individual
    -- keys were never populated — observed 2026-08-22 on RealUI-Healing, where
    -- /bardumptrace reported `abY=nil hudY=nil`. The old `or 0` silently
    -- substituted screen origin for the layout's intended baseline: layout 2
    -- should total -38 + -115.5 + -20 = -173.5 and instead got -20, lifting
    -- every centre bar 153 units up the screen. Fall back to the layout
    -- DEFAULTS, which is what an unpopulated profile is supposed to inherit.
    local defaultLayoutPositions = (RealUI.defaultPositions and RealUI.defaultPositions[cLayout]) or {}
    local hudY = layoutPositions.HuDY or defaultLayoutPositions.HuDY or 0
    local abY = layoutPositions.ActionBarsY or defaultLayoutPositions.ActionBarsY or 0
    local topYOfs = hudY + abY + (sizeOffsets.ActionBarsY or 0)
    -- B11: the HuD "Vertical" slider writes positions[layout].ActionBarsY,
    -- which only top (CENTER-anchored) bars consume via topYOfs — bottom
    -- bars sat at the infobar and ignored it, so the slider was dead on any
    -- layout with bottom bars. Bottom bars now follow the USER's slider
    -- delta: current value minus the computed baseline HuDPositioning keeps
    -- in RealUI.defaultPositions. Untouched slider -> delta 0 -> bottom bars
    -- stay exactly on the infobar, same as always.
    -- Uses the same resolved `abY` as topYOfs above: when the profile has no
    -- saved value it equals the baseline, so the delta is 0 and bottom bars
    -- sit on the infobar exactly as an untouched slider should leave them.
    local baselineY = defaultLayoutPositions.ActionBarsY
    local sliderDelta = 0
    if baselineY then
        sliderDelta = abY - baselineY
    end
    local rawBottomBase = GetBottomBase()
    -- Remembered so the Infobar watcher can tell a real height change from
    -- the float wobble a rescale produces (B65).
    lastBottomBase = rawBottomBase
    local bottomBase = rawBottomBase + 14 + sliderDelta

    local border = private.BUTTON_BORDER or 1

    --[[ Vertical stacking of the centre/bottom bars.

         This used to advance a fixed 36px per row (a 35px "math cell" plus 1)
         — inherited from ApplyABSettings, where 36 is BARTENDER4's button
         height. RealUI's own buttons are 27px with the B28 box model, so the
         correct row pitch is buttonSize + frame gap = 27 + 4 = 31, which is
         exactly what the shipped static defaults encode (Defaults.lua bars 2
         and 3 sit 31 apart). The computed layout and the static defaults
         therefore disagreed by 5px per stacked row, and every stacked bar
         carried BT4's proportions rather than ours.

         Now the rows stack on the REAL rendered heights, the same correction
         the horizontal centering already got. Bars may differ in size, so the
         offset for a row is the cumulative pitch of the rows beneath it.

         Row mapping is hoisted out of the placement loop below (it only
         depends on id and numTopBars) so the cumulative sums can be built
         before any bar is positioned. ]]--
    local rowOf, isTopOf = {}, {}
    local pitchOf = {}
    for id = 1, 3 do
        local db = AB.dbActionBars.profile.actionbars[id]
        local isTopBar = id <= numTopBars
        isTopOf[id] = isTopBar
        if id == 1 then
            rowOf[id] = (numTopBars > 0) and 1 or (3 - numTopBars)
        elseif id == 2 then
            rowOf[id] = 2
        else
            rowOf[id] = isTopBar and 3 or 1
        end

        if db and db.enabled then
            local buttonSize = db.buttonSize or BUTTON_SIZE
            local gap = (db.padding or BUTTON_GAP) + border * 2
            pitchOf[id] = (buttonSize + gap) * (db.scale or 1)
        else
            pitchOf[id] = 0
        end
    end

    --- Cumulative offset from a group's base to the given row: the summed
    --- pitch of every enabled bar occupying a lower row in the same group.
    local function StackOffset(isTopBar, row)
        local offset = 0
        for id = 1, 3 do
            if isTopOf[id] == isTopBar and rowOf[id] < row then
                offset = offset + pitchOf[id]
            end
        end
        return offset
    end

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

                -- Real-height stacking (see StackOffset above): top bars grow
                -- downward from the HuD offset, bottom bars upward from the
                -- infobar base.
                local stack = StackOffset(isTopBar, rowOf[id])
                y = isTopBar and (topYOfs - stack) or (bottomBase + stack)

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
    -- changes): whenever it recomputes the bar layout, re-apply ours.
    _G.hooksecurefunc(abModule, "ApplyABSettings", function()
        private.QueueSecure(private.ApplyRealUILayout)
    end)

    -- B65: recompute if the Infobar settles at a different height than the
    -- one the first layout saw.
    private.WatchInfobarHeight()
end
