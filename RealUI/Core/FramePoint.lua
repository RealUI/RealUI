local _, private = ...

-- Lua Globals --
-- luacheck: globals next

-- Libs --
local LibWin = _G.LibStub("LibWindow-1.1")

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "FramePoint"
local FramePoint = RealUI:NewModule(MODNAME)

local modules = {}

---------------------------------------------------------------------------
-- Unit-frame anchoring
--
-- LibWindow stores positions relative to UIParent, which is right for a
-- free-floating HuD element but wrong when the user wants something pinned
-- to a unit frame (class power under the player frame, a cast bar on its
-- unit). When a frame's config carries `anchorTo`, we bypass LibWindow's
-- restore and anchor the dragFrame to that unit frame instead, keeping
-- `point`/`x`/`y` as an offset from it.
--
-- `anchorTo` is nil/"screen" by default, so existing profiles are unchanged.
---------------------------------------------------------------------------
local ANCHOR_FRAMES = {
    player = "RealUIPlayerFrame",
    target = "RealUITargetFrame",
    focus  = "RealUIFocusFrame",
}
FramePoint.ANCHOR_FRAMES = ANCHOR_FRAMES

--- Resolve a config's `anchorTo` to a live frame, or nil for screen-anchored.
local function GetAnchorFrame(config)
    if not config then return end

    local key = config.anchorTo
    if not key or key == "screen" then return end

    local globalName = ANCHOR_FRAMES[key]
    return globalName and _G[globalName]
end
FramePoint.GetAnchorFrame = GetAnchorFrame

--- Screen-space coordinates of a named anchor point on a frame, in that
--- frame's own units. Callers multiply by effective scale to compare frames.
local function GetPointCoords(frame, point)
    local left, bottom, width, height = frame:GetRect()
    if not left then return end

    local x
    if point:find("LEFT") then
        x = left
    elseif point:find("RIGHT") then
        x = left + width
    else
        x = left + (width / 2)
    end

    local y
    if point:find("BOTTOM") then
        y = bottom
    elseif point:find("TOP") then
        y = bottom + height
    else
        y = bottom + (height / 2)
    end

    return x, y
end

--- Apply a config's anchor to its dragFrame. Returns true when the frame was
--- anchored to a unit frame (so callers know to skip LibWindow's restore).
local function ApplyAnchor(dragFrame, config)
    local anchorFrame = GetAnchorFrame(config)
    if not anchorFrame then return false end

    local point = config.point or "CENTER"
    dragFrame:ClearAllPoints()
    dragFrame:SetPoint(point, anchorFrame, point, config.x or 0, config.y or 0)

    return true
end
FramePoint.ApplyAnchor = ApplyAnchor

function FramePoint:LockMod(mod)
    local module = modules[mod]

    for frame, meta in next, module.frames do
        meta.dragFrame:Hide()
    end

    if mod.ToggleConfigMode then
        mod:ToggleConfigMode(false)
    end

    module.isLocked = true
end

function FramePoint:UnlockMod(mod)
    local module = modules[mod]

    for frame, meta in next, module.frames do
        meta.dragFrame:Show()
    end

    if mod.ToggleConfigMode then
        mod:ToggleConfigMode(true)
    end

    module.isLocked = false
end

function FramePoint:IsModLocked(mod)
    if not modules[mod] then
        return true
    end
    return modules[mod].isLocked
end

function FramePoint:ToggleMod(mod, setLocked)
    if self:IsModLocked(mod) then
        FramePoint:UnlockMod(mod)
    else
        FramePoint:LockMod(mod)
    end
end

function FramePoint:ToggleAll(setLocked)
    for mod, module in next, modules do
        if setLocked then
            FramePoint:LockMod(mod)
        else
            FramePoint:UnlockMod(mod)
        end
    end
end

--- Switch a managed frame between screen- and unit-frame anchoring, keeping
--- it visually in place.
---
--- `point`/`x`/`y` mean different things in each mode (UIParent-relative vs
--- offset-from-anchor), so simply writing `anchorTo` would teleport the frame.
--- This captures where it currently sits and rewrites the offsets into the
--- new coordinate space before re-applying.
---@param mod table          the module that owns the frame
---@param optionPath table   same path passed to PositionFrame
---@param anchorTo string    "screen" | key of ANCHOR_FRAMES
function FramePoint:SetAnchorTo(mod, optionPath, anchorTo)
    local module = modules[mod]
    if not module then return end

    -- Option paths are built fresh at each call site, so compare by content.
    -- Several frames can share one path (ClassResource registers both the
    -- holder and the rune frame under "class.points.position"); matching the
    -- first is enough because RestorePosition below re-applies to all of them.
    local function PathsMatch(a, b)
        if not a or not b or #a ~= #b then return false end
        for i = 1, #a do
            if a[i] ~= b[i] then return false end
        end
        return true
    end

    for _, meta in next, module.frames do
        if PathsMatch(meta.optionPath, optionPath) then
            local dragFrame = meta.dragFrame
            local config = RealUI.GetOptions(mod.moduleName, meta.optionPath)
            if not config then return end

            local point = config.point or "CENTER"
            local scale = dragFrame:GetEffectiveScale()
            local fx, fy = GetPointCoords(dragFrame, point)

            config.anchorTo = anchorTo

            local anchorFrame = GetAnchorFrame(config)
            if fx then
                if anchorFrame then
                    -- screen -> anchored: offsets become relative to the unit frame
                    local ax, ay = GetPointCoords(anchorFrame, point)
                    local anchorScale = anchorFrame:GetEffectiveScale()
                    if ax then
                        config.x = RealUI.Round((fx * scale - ax * anchorScale) / scale, 1)
                        config.y = RealUI.Round((fy * scale - ay * anchorScale) / scale, 1)
                    end
                else
                    -- anchored -> screen: offsets become UIParent-relative, which
                    -- is what LibWindow expects on the next restore.
                    local parentScale = _G.UIParent:GetEffectiveScale()
                    local px, py = GetPointCoords(_G.UIParent, point)
                    if px then
                        config.x = RealUI.Round((fx * scale - px * parentScale) / scale, 1)
                        config.y = RealUI.Round((fy * scale - py * parentScale) / scale, 1)
                    end
                end
            end

            self:RestorePosition(mod)
            return
        end
    end
end

function FramePoint:RestorePosition(mod)
    local module = modules[mod]
    if not module then return end
    for frame, meta in next, module.frames do
        local config = RealUI.GetOptions(mod.moduleName, meta.optionPath)
        if config and config.x then
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", meta.dragFrame)

            -- Profile/layout switches swap the options table out from under
            -- LibWindow: the dragFrame was registered against the OLD
            -- profile's framePoint table at spawn, so RestorePosition would
            -- re-apply the old profile's coordinates and strand the frame
            -- (B43: focus/focustarget orphaned after a layout switch).
            -- Re-register against the table the CURRENT profile resolves to
            -- before restoring.
            LibWin.RegisterConfig(meta.dragFrame, config)
            meta.dragFrame._framePointConfig = config

            if not ApplyAnchor(meta.dragFrame, config) then
                LibWin.RestorePosition(meta.dragFrame)
            end
        end
    end
end

local function FixCollectionJournal(point, anchor, relPoint, x, y)
    local CollectionsJournal = _G.CollectionsJournal
    local mover = _G.CollectionsJournalMover

    CollectionsJournal:ClearAllPoints()
    CollectionsJournal:SetPoint(point, _G.UIParent, relPoint, x, y)
    mover:Show()
end
FramePoint.FixCollectionJournal = FixCollectionJournal

local function FixCommunitiesFrame(point, anchor, relPoint, x, y)
    local CommunitiesFrame = _G.CommunitiesFrame
    local mover = _G.CommunitiesFrameMover

    CommunitiesFrame:ClearAllPoints()
    CommunitiesFrame:SetPoint(point, _G.UIParent, relPoint, x, y)
    mover:Show()
end
FramePoint.FixCommunitiesFrame = FixCommunitiesFrame

local function FixHouseEditorStoragePanel(point, anchor, relPoint, x, y)
    local HouseEditorFrame = _G.HouseEditorFrame
    local mover = _G.HouseEditorStoragePanelMover

    if HouseEditorFrame.StoragePanel then
        HouseEditorFrame.StoragePanel:ClearAllPoints()
        HouseEditorFrame.StoragePanel:SetPoint(point, _G.UIParent, relPoint, x, y)
    end

    if HouseEditorFrame.StorageButton then
        HouseEditorFrame.StorageButton:ClearAllPoints()
        HouseEditorFrame.StorageButton:SetPoint(point, _G.UIParent, relPoint, x, y)
    end

    mover:Show()
end
FramePoint.FixHouseEditorStoragePanel = FixHouseEditorStoragePanel

function FramePoint.OnDragStart(frame)
    LibWin.OnDragStart(frame)
    if frame.dragBG then
        frame.dragBG:Show()
    end
end
function FramePoint.OnDragStop(frame, retries)
    -- Stop the move IMMEDIATELY and unconditionally. The anchored branch
    -- below never called StopMovingOrSizing at all (LibWin.OnDragStop only
    -- ran for screen-anchored frames), so dragging a PINNED frame could stay
    -- glued to the cursor with mouse capture held — hit live 2026-08-21 on
    -- the player and focus cast bars right after the B47 nudge pinned them.
    -- The nil-x retry path had the same hole, and mid-drag GetPoint can also
    -- hand back SECRET coords, where a bare `not x` test throws.
    frame:StopMovingOrSizing()

    local point, anchor, relPoint, x, y = frame:GetPoint()
    if x == nil or _G.issecretvalue(x) or _G.issecretvalue(y) then
        retries = retries or 0
        if retries < 10 then
            _G.C_Timer.After(0, function ()
                FramePoint.OnDragStop(frame, retries + 1)
            end)
        elseif frame.dragBG then
            -- Give up on saving this drag; the frame is already released.
            frame.dragBG:Hide()
        end
        return
    end

    if frame:GetName() == "CollectionsJournalMover" then
        FixCollectionJournal(point, anchor, relPoint, x, y)
    end
    if frame:GetName() == "CommunitiesFrameMover" then
        FixCommunitiesFrame(point, anchor, relPoint, x, y)
    end
    if frame:GetName() == "HouseEditorStoragePanelMover" then
        FixHouseEditorStoragePanel(point, anchor, relPoint, x, y)
    end

    RealUI.SetPixelPoint(frame)

    -- Anchored frames store offsets from their unit frame, not from
    -- UIParent, so LibWindow's save would write the wrong numbers.
    -- Convert the dragged position into anchor-relative offsets and
    -- re-apply, keeping drag working the same as for screen-anchored
    -- frames.
    local config = frame._framePointConfig
    local anchorFrame = GetAnchorFrame(config)
    if anchorFrame then
        local anchorPoint = config.point or "CENTER"
        local scale = frame:GetEffectiveScale()
        local anchorScale = anchorFrame:GetEffectiveScale()

        local fx, fy = GetPointCoords(frame, anchorPoint)
        local ax, ay = GetPointCoords(anchorFrame, anchorPoint)
        if fx and ax and not (_G.issecretvalue(fx) or _G.issecretvalue(fy)
            or _G.issecretvalue(ax) or _G.issecretvalue(ay)) then
            config.x = RealUI.Round((fx * scale - ax * anchorScale) / scale, 1)
            config.y = RealUI.Round((fy * scale - ay * anchorScale) / scale, 1)
            ApplyAnchor(frame, config)
        end
    else
        LibWin.OnDragStop(frame)
    end

    if frame.dragBG then
        frame.dragBG:Hide()
    end
end
function FramePoint:PositionFrame(mod, frame, optionPath)
    local dragFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    _G.Aurora.Base.SetBackdrop(dragFrame, _G.Aurora.Color.white, 0.2)

    local module = modules[mod]
    dragFrame:SetSize(frame:GetSize())
    dragFrame:SetHitRectInsets(-5, -5, -5, -5)
    dragFrame:SetClampedToScreen(true)
    dragFrame:SetMovable(true)
    dragFrame:EnableMouse(true)
    dragFrame:RegisterForDrag("LeftButton")
    dragFrame:SetScript("OnDragStart", module.OnDragStart)
    dragFrame:SetScript("OnDragStop", module.OnDragStop)
    dragFrame:Hide()

    local name = dragFrame:CreateFontString(nil, "BACKGROUND", "Game12Font")
    -- Anonymous frames render GetDebugName() as a parent chain ending in a
    -- hex address (the class points mover read "RealUIPlayerFr...cfe0").
    -- Build a readable label from the module + option path instead; named
    -- frames keep their real name.
    local label = frame:GetName()
    if not label then
        local structuralKeys = {
            profile = true, class = true, char = true, global = true,
            units = true, position = true, framePoint = true,
        }
        local parts = {mod.moduleName}
        if type(optionPath) == "table" then
            for i = 1, #optionPath do
                if not structuralKeys[optionPath[i]] then
                    parts[#parts + 1] = optionPath[i]
                end
            end
        end
        label = _G.table.concat(parts, " ")
    end
    name:SetText(label)
    name:SetPoint("CENTER")

    -- Copy the frame's original anchor onto the dragFrame as the default position.
    -- This ensures the dragFrame starts where the frame was placed by its unit file.
    -- LibWin.RestorePosition will override this only if saved data exists.
    local numPoints = frame:GetNumPoints()
    if numPoints > 0 then
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(1)
        if point and relativeTo then
            dragFrame:SetPoint(point, relativeTo, relativePoint, xOfs or 0, yOfs or 0)
        end
    end

    frame:ClearAllPoints()
    frame:SetPoint("CENTER", dragFrame)

    local config = RealUI.GetOptions(mod.moduleName, optionPath)
    LibWin.RegisterConfig(dragFrame, config)

    -- OnDragStop needs the config to convert a drag into anchor-relative
    -- offsets; LibWindow keeps its own reference privately.
    dragFrame._framePointConfig = config

    -- Unit-frame anchoring wins over LibWindow's UIParent-relative position.
    if not ApplyAnchor(dragFrame, config) then
        -- Only call RestorePosition if LibWindow has actual saved data.
        -- An empty table means the user never moved the frame, so keep the inherited anchor.
        if config and _G.next(config) ~= nil then
            LibWin.RestorePosition(dragFrame)
        end
    end

    modules[mod].frames[frame] = {
        optionPath = optionPath,
        dragFrame = dragFrame,
    }
end

function FramePoint:RefreshMod()
    for mod, module in next, modules do
        for frame, meta in next, module.frames do
            LibWin.RegisterConfig(meta.dragFrame, RealUI.GetOptions(mod.moduleName, meta.optionPath))
            LibWin.RestorePosition(meta.dragFrame)
        end
    end
end

function FramePoint:RegisterMod(mod, OnDragStart, OnDragStop)
    modules[mod] = {
        frames = {},
        isLocked = true,
        OnDragStart = OnDragStart or LibWin.OnDragStart,
        OnDragStop = OnDragStop or LibWin.OnDragStop,
    }
end
