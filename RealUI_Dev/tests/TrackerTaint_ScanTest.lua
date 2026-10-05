local _, ns = ... -- luacheck: ignore

--[[ TrackerTaint_ScanTest.lua — tracker-widget-taint-rewrite, task 1 (R7 of
     .kiro/steering/objective-tracker-taint.md).

     Usage: /realdev trackerscan          summary, PASS/FAIL, fields grouped by key
            /realdev trackerscan full     every addon-owned field, one per line
            /realdev trackerscan hooks    the spike (task 1.3) on its own

     Walks Blizzard's objective tracker (container, modules, their children and
     regions) and the allow-listed widget containers (design.md D4), and reports
     every string field that issecurevariable attributes to an addon. A poisoned
     tracker writes its OWN layout fields under addon taint (contentsHeight,
     usedBlocks, nextBlock, ...), so those show up here as well as any plant.
     Passing means zero addon-owned fields; the absence of errors proves nothing.

     Strictly read only: it iterates tables and calls Get* methods, and writes
     nothing to any Blizzard object. Run it after a session, not mid-pull.

     The "hooks" section answers task 1.3: Aurora installs hooksecurefunc on
     module instances (GetBlock, GetProgressBar) and on global mixin tables. If
     those keys read as secure, a hooksecurefunc post-hook does not taint the
     hooked field, and instance hooks stay allowed (design decision 5). ]]

local MAX_FRAME_DEPTH = 10   -- tracker: container > module > contents > block > line > bar ...
local MAX_TABLE_DEPTH = 2    -- plain tables hanging off a frame (usedBlocks[template][id], ...)
local LIST_LIMIT = 40        -- summary mode prints at most this many grouped keys

-- design.md D4
local WIDGET_CONTAINERS = {
    "UIWidgetTopCenterContainerFrame",
    "UIWidgetBelowMinimapContainerFrame",
    "UIWidgetPowerBarContainerFrame",
}

-- Mixin tables Aurora hooks today (Util.Mixin = hooksecurefunc per key) plus
-- the widget mixins the rewrite will hook. A key here that reads insecure was
-- written by addon code.
local MIXIN_TABLES = {
    "ObjectiveTrackerFrameMixin",
    "ObjectiveTrackerBlockMixin",
    "ObjectiveTrackerContainerHeaderMixin",
    "ObjectiveTrackerModuleHeaderMixin",
    "ObjectiveTrackerQuestPOIBlockMixin",
    "UIWidgetContainerMixin",
    "UIWidgetManagerMixin",
    "UIWidgetTemplateStatusBarMixin",
    "UIWidgetTemplateDoubleStatusBarMixin",
    "UIWidgetBaseStatusBarTemplateMixin",
}

-- Module instances and the methods Aurora hooks on them (Blizzard_ObjectiveTracker.lua SkinModule).
local MODULES = {
    "QuestObjectiveTracker", "CampaignQuestObjectiveTracker", "AchievementObjectiveTracker",
    "BonusObjectiveTracker", "WorldQuestObjectiveTracker", "AdventureObjectiveTracker",
    "ProfessionsRecipeTracker", "UIWidgetObjectiveTracker", "InitiativeTasksObjectiveTracker",
    "MonthlyActivitiesObjectiveTracker", "ScenarioObjectiveTracker",
}
local HOOKED_MODULE_KEYS = { "GetBlock", "GetProgressBar" }

-- Blizzard globals an addon may have replaced (the B97 wrapper).
local GLOBALS = { "ShouldShowMawBuffs" }

local function IsFrame(value)
    return type(value) == "table" and type(value.GetObjectType) == "function"
end

-- Some secure-environment frames cannot be indexed at all from insecure code
-- (LibStrataFix lesson, aurora-121-surfaces 0.7), so every probe is pcall'd.
local function IsAccessible(frame)
    local ok, forbidden = pcall(function() return frame:IsForbidden() end)
    return ok and not forbidden
end

local function DebugName(object, fallback)
    local ok, name = pcall(function() return object:GetDebugName() end)
    return (ok and name and name ~= "") and name or fallback
end

local function NewResult(name)
    return { name = name, objects = 0, fields = {}, skipped = 0 }
end

local function ScanTable(result, seen, tbl, label, depth)
    result.objects = result.objects + 1
    pcall(function()
        for key, value in next, tbl do
            if type(key) == "string" then
                local isSecure, owner = _G.issecurevariable(tbl, key)
                if not isSecure then
                    result.fields[#result.fields + 1] = { key = key, label = label, owner = owner or "?" }
                end
                if depth < MAX_TABLE_DEPTH and type(value) == "table" and not IsFrame(value)
                    and not seen[value] then
                    seen[value] = true
                    ScanTable(result, seen, value, label .. "." .. key, depth + 1)
                end
            end
        end
    end)
end

local function WalkFrame(result, seen, frame, label, depth)
    if seen[frame] then return end
    seen[frame] = true
    if not IsAccessible(frame) then
        result.skipped = result.skipped + 1
        return
    end

    ScanTable(result, seen, frame, label, 0)

    -- Regions: Lua fields planted on textures/fontstrings count too.
    local regions = { pcall(function() return frame:GetRegions() end) }
    if regions[1] then
        for i = 2, #regions do
            local region = regions[i]
            if type(region) == "table" and not seen[region] then
                seen[region] = true
                ScanTable(result, seen, region, DebugName(region, label .. ":region" .. (i - 1)), MAX_TABLE_DEPTH)
            end
        end
    end

    if depth >= MAX_FRAME_DEPTH then return end
    local children = { pcall(function() return frame:GetChildren() end) }
    if children[1] then
        for i = 2, #children do
            local child = children[i]
            if IsFrame(child) then
                WalkFrame(result, seen, child, DebugName(child, label .. ">child" .. (i - 1)), depth + 1)
            end
        end
    end
end

local function ScanTracker()
    local result, seen = NewResult("Tracker"), {}
    local OTF = _G.ObjectiveTrackerFrame
    if not OTF then
        result.missing = true
        return result
    end
    WalkFrame(result, seen, OTF, "ObjectiveTrackerFrame", 0)
    -- Modules are normally children of the container, but an inactive one
    -- (Scenario outside instances) may not be: walk the named ones too.
    for _, name in ipairs(MODULES) do
        local module = _G[name]
        if IsFrame(module) then
            WalkFrame(result, seen, module, name, 1)
        end
    end
    return result
end

local function ScanWidgets()
    local result, seen = NewResult("Widgets"), {}
    for _, name in ipairs(WIDGET_CONTAINERS) do
        local container = _G[name]
        if IsFrame(container) then
            WalkFrame(result, seen, container, name, 0)
        end
    end
    return result
end

local function ScanMixins()
    local result = NewResult("Mixins")
    for _, name in ipairs(MIXIN_TABLES) do
        local mixin = _G[name]
        if type(mixin) == "table" then
            ScanTable(result, {}, mixin, name, MAX_TABLE_DEPTH)
        end
    end
    return result
end

local function ScanGlobals()
    local result = NewResult("Globals")
    for _, name in ipairs(GLOBALS) do
        result.objects = result.objects + 1
        local isSecure, owner = _G.issecurevariable(name)
        if not isSecure then
            result.fields[#result.fields + 1] = { key = name, label = "_G", owner = owner or "?" }
        end
    end
    return result
end

-- Task 1.3: does hooksecurefunc on an instance leave the hooked key secure?
local function ReportHooks()
    local secure, insecure, notHooked = 0, {}, 0
    for _, name in ipairs(MODULES) do
        local module = _G[name]
        if IsFrame(module) then
            for _, key in ipairs(HOOKED_MODULE_KEYS) do
                if rawget(module, key) ~= nil then
                    local isSecure, owner = _G.issecurevariable(module, key)
                    if isSecure then
                        secure = secure + 1
                    else
                        insecure[#insecure + 1] = ("%s.%s <- %s"):format(name, key, owner or "?")
                    end
                else
                    notHooked = notHooked + 1
                end
            end
        end
    end
    print(("|cff8080FFSpike (1.3):|r hooked module keys: %d secure, %d addon-owned, %d absent")
        :format(secure, #insecure, notHooked))
    for i = 1, #insecure do
        print("  |cffff8000" .. insecure[i] .. "|r")
    end
    if secure > 0 and #insecure == 0 then
        print("  -> hooksecurefunc on an instance leaves the key secure: instance hooks allowed.")
    elseif #insecure > 0 then
        print("  -> hooked keys read addon-owned: use global mixin-table hooks only.")
    else
        print("  -> nothing hooked (tracker skin off?): enable \"Skin Objective Tracker\" and rerun.")
    end
    print("  Note: Aurora only hooks when the objectiveTracker skin is on; check the Mixins section too.")
end

local function PrintResult(result, full)
    local count = #result.fields
    local colour = count == 0 and "|cff22dd22" or "|cffff4040"
    local extra = result.skipped > 0 and (" (%d forbidden, skipped)"):format(result.skipped) or ""
    if result.missing then
        print(("  %s: |cff888888not loaded|r"):format(result.name))
        return
    end
    print(("  %s: %d objects, %s%d addon-owned fields|r%s"):format(result.name, result.objects, colour, count, extra))
    if count == 0 then return end

    if full then
        table.sort(result.fields, function(a, b)
            if a.label == b.label then return a.key < b.key end
            return a.label < b.label
        end)
        for _, field in ipairs(result.fields) do
            print(("    |cffffff00%s|r.|cffff8000%s|r <- |cffff0000%s|r"):format(field.label, field.key, field.owner))
        end
        return
    end

    -- Grouped by key: a poisoned subsystem repeats the same layout fields on
    -- every module and block, so counts per key read better than 300 lines.
    local byKey, order = {}, {}
    for _, field in ipairs(result.fields) do
        local id = field.key .. "\0" .. field.owner
        local entry = byKey[id]
        if not entry then
            entry = { key = field.key, owner = field.owner, count = 0, example = field.label }
            byKey[id] = entry
            order[#order + 1] = entry
        end
        entry.count = entry.count + 1
    end
    table.sort(order, function(a, b)
        if a.count == b.count then return a.key < b.key end
        return a.count > b.count
    end)
    for i = 1, math.min(#order, LIST_LIMIT) do
        local entry = order[i]
        print(("    |cffff8000%s|r x%d <- |cffff0000%s|r  (e.g. %s)"):format(entry.key, entry.count, entry.owner, entry.example))
    end
    if #order > LIST_LIMIT then
        print(("    ... %d more keys: /realdev trackerscan full"):format(#order - LIST_LIMIT))
    end
end

function ns.commands:trackerscan(arg)
    if arg == "hooks" then
        return ReportHooks()
    end

    local full = arg == "full"
    local _, instanceType = _G.GetInstanceInfo()
    print(("|cff8080FFTracker taint scan|r (%s, instance: %s)"):format(_G.date("%Y-%m-%d %H:%M"), instanceType or "?"))

    local total = 0
    for _, scan in ipairs({ ScanTracker, ScanWidgets, ScanMixins, ScanGlobals }) do
        local result = scan()
        total = total + #result.fields
        PrintResult(result, full)
    end

    ReportHooks()

    if total == 0 then
        print("|cff22dd22PASS|r — no addon-owned fields on the tracker, the allow-listed widgets, the hooked mixins or the globals.")
    else
        print(("|cffff4040FAIL|r — %d addon-owned fields. Baseline (task 1.4): paste this output into the spec."):format(total))
    end
end
