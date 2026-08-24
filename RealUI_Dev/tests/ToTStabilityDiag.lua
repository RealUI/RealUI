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

-- GetText on a unit-name FontString returns a SECRET string for restricted
-- units in combat (hit live 2026-08-21 — `text ~= ""` threw). House guard:
-- canaccessvalue when present, pcall-strsub probe otherwise.
local function SafeText(value)
    if type(value) ~= "string" then return nil end
    if _G.canaccessvalue then
        return _G.canaccessvalue(value) and value or "<secret>"
    end
    local ok = _G.pcall(function() return _G.strsub(value, 1, 0) end)
    return ok and value or "<secret>"
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

local watcher -- { counts = {} }
local hookedFrames = {}

local function BumpCount(key)
    if watcher then
        watcher.counts[key] = (watcher.counts[key] or 0) + 1
    end
end

local function InstallHooks(frame, tag)
    if hookedFrames[frame] then return end
    hookedFrames[frame] = true

    frame:HookScript("OnShow", function() BumpCount(tag .. " OnShow") end)
    frame:HookScript("OnHide", function() BumpCount(tag .. " OnHide") end)
    _G.hooksecurefunc(frame, "SetSize", function() BumpCount(tag .. " frame SetSize") end)
    _G.hooksecurefunc(frame, "SetPoint", function() BumpCount(tag .. " frame SetPoint") end)
    _G.hooksecurefunc(frame, "UpdateAllElements", function() BumpCount(tag .. " UpdateAllElements") end)
    _G.hooksecurefunc(frame, "SetAlpha", function(_, alpha)
        if _G.issecretvalue(alpha) then
            BumpCount(tag .. " frame SetAlpha(<secret>)")
        else
            BumpCount(("%s frame SetAlpha(%.2f)"):format(tag, alpha))
        end
    end)

    -- CombatFader drives frame.overlay's alpha; a re-triggering fade would
    -- pulse everything parented to it — the "whole frame flickers" suspect.
    if frame.overlay then
        _G.hooksecurefunc(frame.overlay, "SetAlpha", function(_, alpha)
            if _G.issecretvalue(alpha) then
                BumpCount(tag .. " overlay SetAlpha(<secret>)")
            else
                BumpCount(("%s overlay SetAlpha(%.2f)"):format(tag, alpha))
            end
        end)
    end

    local Health = frame.Health
    if Health then
        _G.hooksecurefunc(Health, "SetSize", function() BumpCount(tag .. " Health SetSize") end)
        if Health.SetSmooth then
            _G.hooksecurefunc(Health, "SetSmooth", function(_, enable)
                BumpCount(tag .. (enable and " SetSmooth(true)" or " SetSmooth(false)"))
            end)
        end
        if Health.SetValue then
            _G.hooksecurefunc(Health, "SetValue", function() BumpCount(tag .. " Health SetValue") end)
        end
        -- The fill texture is what actually renders; catch geometry churn and
        -- visibility flapping directly on it.
        local fill = Health.fill
        if fill then
            _G.hooksecurefunc(fill, "SetShown", function(_, shown)
                BumpCount(tag .. (shown and " fill SetShown(true)" or " fill SetShown(false)"))
            end)
            _G.hooksecurefunc(fill, "Hide", function() BumpCount(tag .. " fill Hide") end)
            _G.hooksecurefunc(fill, "SetVertexOffset", function() BumpCount(tag .. " fill SetVertexOffset") end)
            _G.hooksecurefunc(fill, "SetTexCoord", function() BumpCount(tag .. " fill SetTexCoord") end)
        end
    end
end

function ns.commands:totwatch()
    local frames = {
        ToT = GetToT(),
        FocusTarget = _G.RealUIFocusTargetFrame,
    }
    if not frames.ToT then
        _G.print("|cffff0000[ToTWatch]|r RealUITargetTargetFrame not found.")
        return
    end

    if watcher then
        _G.print("|cffffcc00[ToTWatch]|r already running.")
        return
    end

    for tag, frame in _G.next, frames do
        if frame then
            InstallHooks(frame, tag)
        end
    end

    local DURATION = 15
    watcher = { counts = {} }
    _G.print(("|cff00ccff[ToTWatch]|r watching ToT + FocusTarget for %ds — keep the flicker on screen..."):format(DURATION))

    _G.C_Timer.After(DURATION, function()
        local counts = watcher.counts
        watcher = nil
        _G.print("|cff00ccff[ToTWatch]|r results over " .. DURATION .. "s:")
        -- Sorted output so repeated runs compare cleanly
        local keys = {}
        for key in _G.next, counts do
            keys[#keys + 1] = key
        end
        _G.table.sort(keys)
        for _, key in _G.ipairs(keys) do
            _G.print(("  %s: %d (%.1f/s)"):format(key, counts[key], counts[key] / DURATION))
        end
        if #keys == 0 then
            _G.print("  no instrumented activity at all")
        end
        _G.print("|cff00ccff[ToTWatch]|r overlay SetAlpha churn = CombatFader re-fading (whole-frame pulse); fill SetShown/Hide = bar visibility flapping.")
    end)
end

-- B24 round 5: what do the ToT fill's anchors ACTUALLY look like, and do they
-- change between two poll ticks? Decides "native engine rewrites anchors every
-- tick" (ownership war — needs a real fix) vs "FillAnchorsIntact is buggy".
function ns.commands:fillstate()
    local frame = GetToT()
    local fill = frame and frame.Health and frame.Health.fill
    if not fill then
        _G.print("|cffff0000[FillState]|r no ToT Health.fill")
        return
    end

    local function describe(label)
        local n = fill:GetNumPoints()
        local parts = {}
        for i = 1, n do
            local point, rel, relPoint, x, y = fill:GetPoint(i)
            local sx = (x == nil or _G.issecretvalue(x)) and "?" or ("%.1f"):format(x)
            local sy = (y == nil or _G.issecretvalue(y)) and "?" or ("%.1f"):format(y)
            parts[#parts + 1] = ("%s->%s@%s(%s,%s)"):format(
                tostring(point), rel and rel:GetDebugName() or "?", tostring(relPoint), sx, sy)
        end
        local w, h = fill:GetSize()
        local sw = _G.issecretvalue(w) and "?" or ("%.1f"):format(w or -1)
        local sh = _G.issecretvalue(h) and "?" or ("%.1f"):format(h or -1)
        _G.print(("|cff00ccff[FillState]|r %s: %d points, size %sx%s"):format(label, n, sw, sh))
        for _, p in _G.ipairs(parts) do
            _G.print("    " .. p)
        end
    end

    describe("now")
    _G.C_Timer.After(0.7, function() describe("after 0.7s (1+ poll)") end)
    _G.C_Timer.After(1.4, function() describe("after 1.4s (2+ polls)") end)
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
                    local text = SafeText(region:GetText())
                    if text and text ~= "" then
                        local point, _, relPoint, x, y = region:GetPoint(1)
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
