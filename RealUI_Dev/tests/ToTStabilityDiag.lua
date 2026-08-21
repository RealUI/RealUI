local ADDON_NAME, ns = ... -- luacheck: ignore

-- Diagnostic: ToT / small-frame stability (B24 blink, B25 shape, B26 vertical)
-- Live-session instrumentation, not a pass/fail test. Four commands:
--
--   /realdev totshape  — B25: snapshot ToT geometry, run ResizeFrames(), diff.
--                        Static analysis predicts ApplySize applies big-frame
--                        geometry to small frames (EndBox 4->6 wide, +2 height,
--                        indicator heights -> newPowerH which is 0 when
--                        healthHeight == 1). This proves or kills that theory.
--   /realdev ufvert    — B26: record Y of positioner + player/target/ToT,
--                        sweep UFHorizontal through a round trip with
--                        UpdatePositioners(), report any Y drift and the
--                        db/apply state (layout, hudSize, HuDY raw vs applied).
--   /realdev totwatch  — B24: 15s watcher counting OnShow/OnHide,
--                        SetSize/SetPoint and UpdateAllElements ticks on the
--                        ToT frame; prints a rate report. Run while the blink
--                        is visible (target something that has a target).
--   /realdev smallnames — B42: dump every FontString region on focus /
--                        focustarget / targettarget with text, layer and
--                        anchor, to find the second stacked name label.

local RealUI = _G.RealUI

local function GetToT()
    return _G.RealUITargetTargetFrame
end

local function fmtNum(v)
    if type(v) == "number" then
        return ("%.1f"):format(v)
    end
    return tostring(v)
end

local function SizeOf(region)
    if not region then return "nil" end
    local w, h = region:GetSize()
    return ("%.1fx%.1f"):format(w or -1, h or -1)
end

-- B25: geometry snapshot around ResizeFrames -------------------------------

local function SnapshotFrame(frame)
    local snap = {
        frame = SizeOf(frame),
        health = SizeOf(frame.Health),
        endBox = frame.EndBox and SizeOf(frame.EndBox[1]) or "nil",
        combatInd = SizeOf(frame.CombatIndicator),
        leaderInd = SizeOf(frame.LeaderIndicator),
        pvpInd = SizeOf(frame.PvPIndicator),
    }
    return snap
end

local function DiffSnapshots(name, before, after)
    local changed = false
    for key, oldVal in _G.next, before do
        local newVal = after[key]
        if oldVal ~= newVal then
            _G.print(("|cffffcc00[%s]|r %s: %s -> %s"):format(name, key, oldVal, newVal))
            changed = true
        end
    end
    if not changed then
        _G.print(("|cff00ff00[%s]|r geometry unchanged"):format(name))
    end
end

function ns.commands:totshape()
    local UnitFrames = RealUI:GetModule("UnitFrames")
    local frames = {
        TargetTarget = GetToT(),
        Focus = _G.RealUIFocusFrame,
        FocusTarget = _G.RealUIFocusTargetFrame,
        Pet = _G.RealUIPetFrame,
    }

    local before = {}
    for name, frame in _G.next, frames do
        if frame then
            before[name] = SnapshotFrame(frame)
        end
    end

    _G.print("|cff00ccff[ToTShape]|r running UnitFrames:ResizeFrames() ...")
    UnitFrames:ResizeFrames()

    for name, frame in _G.next, frames do
        if frame and before[name] then
            DiffSnapshots(name, before[name], SnapshotFrame(frame))
        end
    end
    _G.print("|cff00ccff[ToTShape]|r done. Changes above = ApplySize disagrees with creation geometry (B25).")
end

-- B26: vertical stability across a UFHorizontal round trip -----------------

local function TopOf(frame)
    if not frame then return nil end
    -- GetRect returns left, bottom, width, height
    local l, b, w, h = frame:GetRect()
    if not b then return nil end
    return b + (h or 0), l, w
end

function ns.commands:ufvert()
    local ndb = RealUI.db.profile
    local ndbc = RealUI.db.char
    local layout = (ndbc and ndbc.layout and ndbc.layout.current) or RealUI.cLayout or 1
    local positions = ndb.positions and ndb.positions[layout]
    if not positions then
        _G.print("|cffff0000[UFVert]|r no positions table for layout", layout)
        return
    end

    local posFrame = _G.RealUIPositionersUnitFrames
    local watch = {
        Positioner = posFrame,
        Player = _G.RealUIPlayerFrame,
        Target = _G.RealUITargetFrame,
        ToT = GetToT(),
        Focus = _G.RealUIFocusFrame,
    }

    _G.print(("|cff00ccff[UFVert]|r layout=%s hudSize=%s HuDY(db)=%s UFHorizontal(db)=%s"):format(
        tostring(layout), tostring(ndb.settings and ndb.settings.hudSize),
        tostring(positions.HuDY), tostring(positions.UFHorizontal)))
    if posFrame then
        local point, rel, relPoint, x, y = posFrame:GetPoint(1)
        _G.print(("|cff00ccff[UFVert]|r positioner point: %s -> %s %s (%.1f, %.1f)"):format(
            tostring(point), rel and rel:GetName() or "?", tostring(relPoint), x or 0, y or 0))
    end

    local beforeY = {}
    for name, frame in _G.next, watch do
        if frame then
            local top = TopOf(frame)
            beforeY[name] = top
        end
    end

    local orig = positions.UFHorizontal
    -- Round trip: bump the width, apply, restore, apply.
    positions.UFHorizontal = (orig or 200) + 40
    RealUI:UpdatePositioners()
    positions.UFHorizontal = orig
    RealUI:UpdatePositioners()

    local drifted = false
    for name, frame in _G.next, watch do
        if frame and beforeY[name] then
            local top = TopOf(frame)
            if top and _G.math.abs(top - beforeY[name]) > 0.01 then
                _G.print(("|cffff0000[UFVert]|r %s vertical drift: %.2f -> %.2f"):format(name, beforeY[name], top))
                drifted = true
            end
        end
    end
    if not drifted then
        _G.print("|cff00ff00[UFVert]|r no vertical drift across a UFHorizontal round trip.")
        _G.print("|cff00ccff[UFVert]|r If the live bug still happens, drag the slider in config and re-run to compare state lines above.")
    end
end

-- B24: blink watcher --------------------------------------------------------

local watcher -- { counts = {}, endTime, ticker }
local hooksInstalled = false

local function BumpCount(key)
    if watcher then
        watcher.counts[key] = (watcher.counts[key] or 0) + 1
    end
end

local function InstallHooks(frame)
    if hooksInstalled then return end
    hooksInstalled = true

    frame:HookScript("OnShow", function() BumpCount("OnShow") end)
    frame:HookScript("OnHide", function() BumpCount("OnHide") end)
    _G.hooksecurefunc(frame, "SetSize", function() BumpCount("frame SetSize") end)
    _G.hooksecurefunc(frame, "SetPoint", function() BumpCount("frame SetPoint") end)
    _G.hooksecurefunc(frame, "UpdateAllElements", function() BumpCount("UpdateAllElements") end)
    if frame.Health then
        _G.hooksecurefunc(frame.Health, "SetSize", function() BumpCount("Health SetSize") end)
        if frame.Health.SetSmooth then
            _G.hooksecurefunc(frame.Health, "SetSmooth", function(_, enable)
                BumpCount(enable and "SetSmooth(true)" or "SetSmooth(false)")
            end)
        end
        if frame.Health.SetValue then
            _G.hooksecurefunc(frame.Health, "SetValue", function() BumpCount("Health SetValue") end)
        end
    end
end

function ns.commands:totwatch()
    local frame = GetToT()
    if not frame then
        _G.print("|cffff0000[ToTWatch]|r RealUITargetTargetFrame not found.")
        return
    end

    if watcher then
        _G.print("|cffffcc00[ToTWatch]|r already running.")
        return
    end

    InstallHooks(frame)

    local DURATION = 15
    watcher = { counts = {} }
    _G.print(("|cff00ccff[ToTWatch]|r watching for %ds — keep the blink on screen (target something that has a target)..."):format(DURATION))

    _G.C_Timer.After(DURATION, function()
        local counts = watcher.counts
        watcher = nil
        _G.print("|cff00ccff[ToTWatch]|r results over " .. DURATION .. "s:")
        local any = false
        for key, count in _G.next, counts do
            _G.print(("  %s: %d (%.1f/s)"):format(key, count, count / DURATION))
            any = true
        end
        if not any then
            _G.print("  no instrumented activity at all")
        end
        _G.print("|cff00ccff[ToTWatch]|r OnShow/OnHide pairs = unit-watch churn; SetSmooth pairs at ~2/s = eventless poll re-render (blink suspect).")
    end)
end

-- B42: stacked label hunt ----------------------------------------------------

local function DumpFontStrings(frame, label)
    if not frame then
        _G.print(("|cffff0000[SmallNames]|r %s not found"):format(label))
        return
    end

    _G.print(("|cff00ccff[SmallNames]|r %s:"):format(label))
    local seen = {}
    local function walk(f, depth)
        if not f or seen[f] or depth > 4 then return end
        seen[f] = true
        if f.GetRegions then
            for i = 1, _G.select("#", f:GetRegions()) do
                local region = _G.select(i, f:GetRegions())
                if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                    local text = region:GetText()
                    if text and text ~= "" then
                        local point, rel, relPoint, x, y = region:GetPoint(1)
                        _G.print(("  \"%s\" on %s [%s] %s->%s (%s, %s) shown=%s"):format(
                            text, f:GetDebugName() or "?", region:GetDrawLayer() or "?",
                            tostring(point), tostring(relPoint), fmtNum(x), fmtNum(y),
                            tostring(region:IsShown())))
                    end
                end
            end
        end
        if f.GetChildren then
            for i = 1, _G.select("#", f:GetChildren()) do
                walk(_G.select(i, f:GetChildren()), depth + 1)
            end
        end
    end
    walk(frame, 0)
end

function ns.commands:smallnames()
    DumpFontStrings(_G.RealUIFocusFrame, "Focus")
    DumpFontStrings(_G.RealUIFocusTargetFrame, "FocusTarget")
    DumpFontStrings(GetToT(), "TargetTarget")
end
