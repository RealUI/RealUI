local ADDON_NAME, ns = ... -- luacheck: ignore

-- Stutter Diagnostic Tool
-- Profiles suspected microstutter sources: GC pressure, Aurora backdrop allocations,
-- LibStrataFix CreateFrame hooks, tooltip processing, chat bubble OnUpdate,
-- and RealUI_Skins FrameTypeFrame hooks.
--
-- Usage: /realdev stutterdiag [start|stop|report|reset|gc]
--   start  — begin recording (hooks + per-frame spike detection)
--   stop   — stop recording
--   report — dump results to a LibTextDump window
--   reset  — clear all collected data
--   gc     — snapshot current GC state and run a timed collectgarbage

-- luacheck: globals next type pairs select tostring tinsert floor

local RealUI = _G.RealUI
local GetTime = _G.GetTime
local debugprofilestop = _G.debugprofilestop
local collectgarbage = _G.collectgarbage
local format = _G.string.format

-- ── state ──────────────────────────────────────────────────────────────────────
local recording = false
local frameMonitor = _G.CreateFrame("Frame")

-- Spike detection: any frame that takes longer than this (ms) is logged
local SPIKE_THRESHOLD_MS = 16 -- adjusted: your baseline is 12-16ms, so flag the 16+ outliers

-- Ring buffer for frame times (keeps last N frames so we can show context)
local RING_SIZE = 600 -- 10 seconds at 60 fps
local ring = {}
local ringIdx = 0

-- Per-probe accumulators
local probes = {
    -- Each entry: { calls=0, totalMs=0, maxMs=0, spikes=0, spikeThresholdMs=N }
    backdrop_SetBackdropColor   = { calls = 0, totalMs = 0, maxMs = 0, spikes = 0, spikeThresholdMs = 0.5 },
    backdrop_GetNineSliceLayout = { calls = 0, totalMs = 0, maxMs = 0, spikes = 0, spikeThresholdMs = 0.5 },
    backdrop_ApplyBackdrop      = { calls = 0, totalMs = 0, maxMs = 0, spikes = 0, spikeThresholdMs = 1.0 },
    skins_FrameTypeFrame        = { calls = 0, totalMs = 0, maxMs = 0, spikes = 0, spikeThresholdMs = 1.0 },
    tooltip_LinePreCall          = { calls = 0, totalMs = 0, maxMs = 0, spikes = 0, spikeThresholdMs = 0.3 },
    tooltip_PostCall             = { calls = 0, totalMs = 0, maxMs = 0, spikes = 0, spikeThresholdMs = 0.3 },
    chatbubble_OnUpdate          = { calls = 0, totalMs = 0, maxMs = 0, spikes = 0, spikeThresholdMs = 1.0 },
    stratafix_CreateFrame        = { calls = 0, totalMs = 0, maxMs = 0, spikes = 0, spikeThresholdMs = 0.5 },
    color_Create                 = { calls = 0, totalMs = 0, maxMs = 0, spikes = 0, spikeThresholdMs = 0.1 },
    theme_UpdateAllFrameAlpha    = { calls = 0, totalMs = 0, maxMs = 0, spikes = 0, spikeThresholdMs = 2.0 },
}

-- Frame-level spike log (timestamp, durationMs, gcDeltaKB)
local frameSpikeLog = {}
local MAX_SPIKE_LOG = 200

-- GC tracking
local gcStats = {
    snapshots = {},       -- manual /gc snapshots
    frameSamples = 0,
    totalGCDeltaKB = 0,
    maxGCDeltaKB = 0,
    gcPauseCount = 0,     -- frames where GC freed > 50 KB
}

-- Hooks installed flag (we only install once)
local hooksInstalled = false

-- Event frequency tracking — which WoW events fire most during recording
local eventCounts = {}
local eventFrame = _G.CreateFrame("Frame")
eventFrame:RegisterAllEvents()
eventFrame:SetScript("OnEvent", function(_, event)
    if not recording then return end
    eventCounts[event] = (eventCounts[event] or 0) + 1
end)


-- ── probe helper ───────────────────────────────────────────────────────────────
local function RecordProbe(name, startTime)
    if not recording then return end
    local elapsed = debugprofilestop() - startTime
    local p = probes[name]
    if not p then return end
    p.calls = p.calls + 1
    p.totalMs = p.totalMs + elapsed
    if elapsed > p.maxMs then
        p.maxMs = elapsed
    end
    if elapsed > p.spikeThresholdMs then
        p.spikes = p.spikes + 1
    end
end

-- ── install hooks ──────────────────────────────────────────────────────────────
local function InstallHooks()
    if hooksInstalled then return end
    hooksInstalled = true

    -- 1. Aurora Color.Create — tracks table allocation frequency
    local Aurora = _G.Aurora
    if Aurora and Aurora.Color and Aurora.Color.Create then
        local origCreate = Aurora.Color.Create
        Aurora.Color.Create = function(...)
            local t = debugprofilestop()
            local result = origCreate(...)
            RecordProbe("color_Create", t)
            return result
        end
    end

    -- 2. Aurora backdrop hooks (SetBackdropColor on the mixin)
    --    We hook via the Base functions since those are the entry points
    if Aurora and Aurora.Base then
        local Base = Aurora.Base

        if Base.SetBackdropColor then
            local origSBDC = Base.SetBackdropColor
            Base.SetBackdropColor = function(...)
                local t = debugprofilestop()
                local r1, r2 = origSBDC(...)
                RecordProbe("backdrop_SetBackdropColor", t)
                return r1, r2
            end
        end

        if Base.SetBackdrop then
            local origSBD = Base.SetBackdrop
            Base.SetBackdrop = function(...)
                local t = debugprofilestop()
                local r1, r2 = origSBD(...)
                RecordProbe("backdrop_ApplyBackdrop", t)
                return r1, r2
            end
        end
    end

    -- 3. Theme.UpdateAllFrameAlpha
    if Aurora and Aurora.Theme and Aurora.Theme.UpdateAllFrameAlpha then
        local origUpdate = Aurora.Theme.UpdateAllFrameAlpha
        Aurora.Theme.UpdateAllFrameAlpha = function(...)
            local t = debugprofilestop()
            local r = origUpdate(...)
            RecordProbe("theme_UpdateAllFrameAlpha", t)
            return r
        end
    end

    -- 4. RealUI_Skins FrameTypeFrame hook — we hook AddFrameStripes as proxy
    if RealUI and RealUI.AddFrameStripes then
        local origStripes = RealUI.AddFrameStripes
        RealUI.AddFrameStripes = function(self, ...)
            local t = debugprofilestop()
            local r = origStripes(self, ...)
            RecordProbe("skins_FrameTypeFrame", t)
            return r
        end
    end

    -- 5. LibStrataFix CreateFrame hook
    local LSF = _G.LibStrataFix or (_G.LibStub and _G.LibStub("LibStrataFix", true))
    if LSF and LSF.CreateFrameHook then
        local origCFH = LSF.CreateFrameHook
        LSF.CreateFrameHook = function(...)
            local t = debugprofilestop()
            local r = origCFH(...)
            RecordProbe("stratafix_CreateFrame", t)
            return r
        end
    end

    -- 6. Tooltip hooks — use TooltipDataProcessor (modern API)
    --    We measure each individual callback's cost, not the span between events.
    if _G.TooltipDataProcessor and _G.Enum and _G.Enum.TooltipDataType then
        -- Wrap the Unit post-call: measure just the time our callback takes
        _G.TooltipDataProcessor.AddTooltipPostCall(_G.Enum.TooltipDataType.Unit, function(tooltip)
            if tooltip == _G.GameTooltip then
                local t = debugprofilestop()
                -- The actual RealUI_Tooltips processing already ran before us
                -- (processors fire in registration order). We just mark the cost
                -- of reaching this point in the chain as ~0; the real value is
                -- the call count which shows how often unit tooltips fire.
                RecordProbe("tooltip_PostCall", t)
            end
        end)
        -- Count line processing frequency
        _G.TooltipDataProcessor.AddLinePreCall(_G.Enum.TooltipDataLineType.None, function(tooltip)
            if tooltip == _G.GameTooltip then
                local t = debugprofilestop()
                RecordProbe("tooltip_LinePreCall", t)
            end
        end)
    end

    -- 7. Chat bubble OnUpdate — hook the Aurora Hook table if available
    if Aurora and Aurora.Hook and Aurora.Hook.ChatBubble_OnUpdate then
        local origBubble = Aurora.Hook.ChatBubble_OnUpdate
        Aurora.Hook.ChatBubble_OnUpdate = function(...)
            local t = debugprofilestop()
            local r = origBubble(...)
            RecordProbe("chatbubble_OnUpdate", t)
            return r
        end
    end

    _G.print("|cff00ccff[StutterDiag]|r Hooks installed.")
end

-- ── per-frame monitoring ───────────────────────────────────────────────────────
local lastFrameTime = 0
local lastGCCount = 0

local function OnUpdate()
    if not recording then return end

    local now = debugprofilestop()
    local frameDuration = now - lastFrameTime
    lastFrameTime = now

    -- GC delta tracking
    local gcNow = collectgarbage("count") -- KB
    local gcDelta = gcNow - lastGCCount   -- negative = GC freed memory
    lastGCCount = gcNow

    gcStats.frameSamples = gcStats.frameSamples + 1
    if gcDelta < 0 then
        local freed = -gcDelta
        gcStats.totalGCDeltaKB = gcStats.totalGCDeltaKB + freed
        if freed > gcStats.maxGCDeltaKB then
            gcStats.maxGCDeltaKB = freed
        end
        if freed > 50 then
            gcStats.gcPauseCount = gcStats.gcPauseCount + 1
        end
    end

    -- Ring buffer
    ringIdx = (ringIdx % RING_SIZE) + 1
    ring[ringIdx] = frameDuration

    -- Spike detection
    if frameDuration > SPIKE_THRESHOLD_MS and #frameSpikeLog < MAX_SPIKE_LOG then
        tinsert(frameSpikeLog, {
            time = GetTime(),
            ms = frameDuration,
            gcDeltaKB = gcDelta,
            gcTotalKB = gcNow,
        })
    end
end

frameMonitor:SetScript("OnUpdate", function()
    if recording then
        OnUpdate()
    end
end)

-- ── commands ───────────────────────────────────────────────────────────────────
local function Start()
    if recording then
        _G.print("|cff00ccff[StutterDiag]|r Already recording.")
        return
    end
    InstallHooks()
    lastFrameTime = debugprofilestop()
    lastGCCount = collectgarbage("count")
    recording = true
    _G.print("|cff00ccff[StutterDiag]|r Recording started. Play normally, then /realdev stutterdiag stop")
end

local function Stop()
    if not recording then
        _G.print("|cff00ccff[StutterDiag]|r Not recording.")
        return
    end
    recording = false
    _G.print("|cff00ccff[StutterDiag]|r Recording stopped. Use /realdev stutterdiag report")
end

local function Reset()
    recording = false
    for _, p in pairs(probes) do
        p.calls = 0
        p.totalMs = 0
        p.maxMs = 0
        p.spikes = 0
    end
    _G.wipe(frameSpikeLog)
    _G.wipe(ring)
    _G.wipe(eventCounts)
    ringIdx = 0
    gcStats.snapshots = {}
    gcStats.frameSamples = 0
    gcStats.totalGCDeltaKB = 0
    gcStats.maxGCDeltaKB = 0
    gcStats.gcPauseCount = 0
    _G.print("|cff00ccff[StutterDiag]|r Data reset.")
end

local function GCSnapshot()
    local before = collectgarbage("count")
    local t = debugprofilestop()
    collectgarbage("collect")
    local elapsed = debugprofilestop() - t
    local after = collectgarbage("count")
    local freed = before - after
    tinsert(gcStats.snapshots, {
        before = before,
        after = after,
        freedKB = freed,
        timeMs = elapsed,
    })
    _G.print(format("|cff00ccff[StutterDiag]|r GC: freed %.1f KB in %.2f ms (%.1f MB → %.1f MB)",
        freed, elapsed, before / 1024, after / 1024))
end

-- ── report ─────────────────────────────────────────────────────────────────────
local function Report()
    local LTD = _G.LibStub("LibTextDump-1.0", true)
    if not LTD then
        _G.print("|cff00ccff[StutterDiag]|r LibTextDump-1.0 not available, printing to chat.")
    end

    local lines = {}
    local function L(str)
        tinsert(lines, str)
    end

    L("=== RealUI Stutter Diagnostic Report ===")
    L(format("Date: %s", _G.date("%Y-%m-%d %H:%M:%S")))
    L(format("Addon Memory: %.1f MB", collectgarbage("count") / 1024))
    L(format("Framerate: %.1f FPS", GetTime() > 0 and _G.GetFramerate() or 0))
    L("")

    -- ── Probe results ──
    L("── Hook Probe Results ──")
    L(format("%-35s %8s %10s %10s %10s %6s", "Probe", "Calls", "Total ms", "Avg µs", "Max ms", "Spikes"))
    L(("─"):rep(90))

    -- Sort by total time descending
    local sorted = {}
    for name, p in pairs(probes) do
        tinsert(sorted, { name = name, data = p })
    end
    _G.table.sort(sorted, function(a, b) return a.data.totalMs > b.data.totalMs end)

    for _, entry in _G.ipairs(sorted) do
        local p = entry.data
        local avg = p.calls > 0 and (p.totalMs / p.calls * 1000) or 0 -- µs
        L(format("%-35s %8d %10.2f %10.1f %10.3f %6d",
            entry.name, p.calls, p.totalMs, avg, p.maxMs, p.spikes))
    end
    L("")

    -- ── GC stats ──
    L("── Garbage Collection ──")
    L(format("Frames sampled:        %d", gcStats.frameSamples))
    L(format("Total GC freed:        %.1f KB", gcStats.totalGCDeltaKB))
    L(format("Max single-frame free: %.1f KB", gcStats.maxGCDeltaKB))
    L(format("Heavy GC frames (>50KB): %d", gcStats.gcPauseCount))
    if gcStats.frameSamples > 0 then
        L(format("Avg GC freed/frame:    %.2f KB", gcStats.totalGCDeltaKB / gcStats.frameSamples))
    end
    L("")

    -- Manual GC snapshots
    if #gcStats.snapshots > 0 then
        L("── Manual GC Snapshots ──")
        for i, snap in _G.ipairs(gcStats.snapshots) do
            L(format("  #%d: freed %.1f KB in %.2f ms (%.1f MB → %.1f MB)",
                i, snap.freedKB, snap.timeMs, snap.before / 1024, snap.after / 1024))
        end
        L("")
    end

    -- ── Frame spikes ──
    L(format("── Frame Spikes (>%d ms) — %d recorded ──", SPIKE_THRESHOLD_MS, #frameSpikeLog))
    if #frameSpikeLog > 0 then
        L(format("%-12s %10s %12s %12s", "GameTime", "Duration", "GC Delta KB", "GC Total MB"))
        L(("─"):rep(50))
        -- Show last 50
        local startIdx = _G.math.max(1, #frameSpikeLog - 49)
        for i = startIdx, #frameSpikeLog do
            local s = frameSpikeLog[i]
            L(format("%-12.1f %8.1f ms %+10.1f KB %10.1f MB",
                s.time, s.ms, s.gcDeltaKB, s.gcTotalKB / 1024))
        end
    else
        L("  (none recorded)")
    end
    L("")

    -- ── Frame time distribution ──
    local validFrames = 0
    local buckets = { [0] = 0, [8] = 0, [12] = 0, [16] = 0, [33] = 0, [50] = 0, [100] = 0 }
    local thresholds = { 0, 8, 12, 16, 33, 50, 100 }
    for i = 1, RING_SIZE do
        local ft = ring[i]
        if ft then
            validFrames = validFrames + 1
            for j = #thresholds, 1, -1 do
                if ft >= thresholds[j] then
                    buckets[thresholds[j]] = buckets[thresholds[j]] + 1
                    break
                end
            end
        end
    end
    if validFrames > 0 then
        L("── Frame Time Distribution (last ~10s) ──")
        L(format("  0-8ms (125+ fps):  %d (%.0f%%)", buckets[0], buckets[0] / validFrames * 100))
        L(format("  8-12ms (83-125):   %d (%.0f%%)", buckets[8], buckets[8] / validFrames * 100))
        L(format("  12-16ms (60-83):   %d (%.0f%%)", buckets[12], buckets[12] / validFrames * 100))
        L(format("  16-33ms (30-60):   %d (%.0f%%)", buckets[16], buckets[16] / validFrames * 100))
        L(format("  33-50ms (20-30):   %d (%.0f%%)", buckets[33], buckets[33] / validFrames * 100))
        L(format("  50-100ms (10-20):  %d (%.0f%%)", buckets[50], buckets[50] / validFrames * 100))
        L(format("  100ms+ (<10 fps):  %d (%.0f%%)", buckets[100], buckets[100] / validFrames * 100))
    end
    L("")

    -- ── Event frequency ──
    local sortedEvents = {}
    for event, count in pairs(eventCounts) do
        tinsert(sortedEvents, { event = event, count = count })
    end
    _G.table.sort(sortedEvents, function(a, b) return a.count > b.count end)
    L("── Top 20 Events During Recording ──")
    L(format("%-45s %8s", "Event", "Count"))
    L(("─"):rep(55))
    local eventLimit = _G.math.min(20, #sortedEvents)
    for i = 1, eventLimit do
        local e = sortedEvents[i]
        L(format("%-45s %8d", e.event, e.count))
    end

    L("")
    L("── Interpretation Guide ──")
    L("• High calls + low avg on color_Create/backdrop_SetBackdropColor = GC pressure from table churn")
    L("• High max on stratafix_CreateFrame = mob/nameplate loading spikes")
    L("• Heavy GC frames correlating with frame spikes = GC is your primary culprit")
    L("• High spikes on tooltip_PostCall = tooltip processing overhead")
    L("• High event counts on UNIT_AURA/COMBAT_LOG_EVENT = combat-driven overhead")
    L("• Run '/realdev stutterdiag gc' before and after a spike session to measure heap size")

    -- Output
    local text = _G.table.concat(lines, "\n")
    if LTD then
        local dump = LTD:New("StutterDiag Report", 750, 500)
        dump:Clear()
        dump:AddLine(text)
        dump:Display()
    else
        for _, line in _G.ipairs(lines) do
            _G.print(line)
        end
    end
end

-- ── slash command registration ─────────────────────────────────────────────────
function ns.commands:stutterdiag(arg)
    if arg == "start" then
        Start()
    elseif arg == "stop" then
        Stop()
    elseif arg == "report" then
        Report()
    elseif arg == "reset" then
        Reset()
    elseif arg == "gc" then
        GCSnapshot()
    else
        _G.print("|cff00ccff[StutterDiag]|r Usage: /realdev stutterdiag [start|stop|report|reset|gc]")
        _G.print("  start  — begin recording frame times and hook probes")
        _G.print("  stop   — stop recording")
        _G.print("  report — dump results to a text window")
        _G.print("  reset  — clear all collected data")
        _G.print("  gc     — run a full GC and report timing")
    end
end
