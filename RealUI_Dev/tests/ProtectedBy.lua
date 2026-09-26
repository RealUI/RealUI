local ADDON_NAME, ns = ... -- luacheck: ignore

-- /realdev protectedby <GlobalName>[:parent]
--
-- Why is this frame implicitly protected? `frame:IsProtected()` returning
-- `true, false` says "protected, but not explicitly", and nothing tells you
-- which secure frame is responsible. Found while chasing RealUIHuDConfig's
-- ADDON_ACTION_BLOCKED on ClearAllPoints in combat (2026-09-26).
--
-- Reports every EXPLICITLY protected frame that makes the target protected:
--   1. the target itself, if explicit;
--   2. explicitly protected descendants of the target;
--   3. explicitly protected frames anywhere in the UI whose anchor chain
--      (GetPoint relativeTo, followed recursively, regions resolved to their
--      parent frame) reaches the target or one of its descendants.
-- ":parent" starts from the named frame's parent, for frames with no global
-- name of their own (RealUIHuDConfig's highlight used to shadow the bar's).
-- Read-only; run it out of combat.

local MAX_DEPTH = 25

local function Name(frame)
    local ok, name = _G.pcall(frame.GetDebugName, frame)
    return (ok and name) or tostring(frame)
end

local function IsExplicit(frame)
    local ok, protected, explicit = _G.pcall(frame.IsProtected, frame)
    return ok and protected and explicit
end

local function AsFrame(region)
    if not region then return end
    if region.GetObjectType and region:IsObjectType("Frame") then return region end
    if region.GetParent then return region:GetParent() end
end

local function CollectDescendants(frame, into, depth)
    into[frame] = true
    if depth > MAX_DEPTH then return end
    for _, child in _G.ipairs({ frame:GetChildren() }) do
        CollectDescendants(child, into, depth + 1)
    end
end

-- Follow every anchor of `frame` recursively; return the chain (as names)
-- that first reaches a frame in `targets`, or nil.
local function AnchorChainTo(frame, targets, visited, depth, path)
    if depth > MAX_DEPTH or visited[frame] then return end
    visited[frame] = true
    local ok, numPoints = _G.pcall(frame.GetNumPoints, frame)
    if not ok or not numPoints then return end
    for i = 1, numPoints do
        local pointOk, point, relativeTo = _G.pcall(frame.GetPoint, frame, i)
        local relFrame = pointOk and AsFrame(relativeTo)
        if relFrame then
            local step = ("%s -[%s]-> %s"):format(Name(frame), tostring(point), Name(relativeTo))
            path[#path + 1] = step
            if targets[relFrame] then return path end
            local found = AnchorChainTo(relFrame, targets, visited, depth + 1, path)
            if found then return found end
            path[#path] = nil
        end
    end
end

local function Resolve(arg)
    if not arg or arg == "" then return end
    local name, modifier = arg:match("^([^:]+):?(%a*)$")
    local frame = name and _G[name]
    if frame and modifier == "parent" then
        frame = frame:GetParent()
    end
    if type(frame) == "table" and frame.IsProtected then return frame end
end

function ns.commands:protectedby(arg)
    local target = Resolve(arg)
    if not target then
        _G.print("|cff00ccff[protectedby]|r usage: /realdev protectedby GlobalName[:parent]")
        return
    end
    if _G.InCombatLockdown() then
        _G.print("|cff00ccff[protectedby]|r run this out of combat.")
        return
    end

    local protected, explicit = target:IsProtected()
    _G.print(("|cff00ccff[protectedby]|r %s: protected=%s explicit=%s"):format(
        Name(target), tostring(protected), tostring(explicit)))
    if not protected then return end
    if explicit then
        _G.print("  the frame is explicitly protected itself.")
    end

    local targets = {}
    CollectDescendants(target, targets, 0)

    local found = 0
    -- 2. explicitly protected descendants
    for frame in _G.next, targets do
        if frame ~= target and IsExplicit(frame) then
            found = found + 1
            _G.print(("  child: %s"):format(Name(frame)))
        end
    end

    -- 3. explicitly protected frames anchored into the target's tree
    local frame = _G.EnumerateFrames()
    while frame do
        if not targets[frame] and not (frame.IsForbidden and frame:IsForbidden()) and IsExplicit(frame) then
            local chain = AnchorChainTo(frame, targets, {}, 0, {})
            if chain then
                found = found + 1
                _G.print(("  anchored: %s"):format(Name(frame)))
                for _, step in _G.ipairs(chain) do
                    _G.print("    " .. step)
                end
            end
        end
        frame = _G.EnumerateFrames(frame)
    end

    if found == 0 then
        _G.print("  no explicitly protected child or anchor chain found (the cause may be a forbidden frame, which cannot be inspected).")
    end
end
