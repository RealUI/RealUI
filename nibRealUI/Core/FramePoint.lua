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

function FramePoint:RestorePosition(mod)
    local module = modules[mod]
    for frame, meta in next, module.frames do
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", meta.dragFrame)
        LibWin.RestorePosition(meta.dragFrame)
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

function FramePoint.OnDragStart(frame)
    LibWin.OnDragStart(frame)
    if frame.dragBG then
        frame.dragBG:Show()
    end
end
function FramePoint.OnDragStop(frame)
    local point, anchor, relPoint, x, y = frame:GetPoint()
    if not x then
        _G.C_Timer.After(0, function ()
            FramePoint.OnDragStop(frame)
        end)
    else
        if frame:GetName() == "CollectionsJournalMover" then
            FixCollectionJournal(point, anchor, relPoint, x, y)
        end
        if frame:GetName() == "CommunitiesFrameMover" then
            FixCommunitiesFrame(point, anchor, relPoint, x, y)
        end

        RealUI.SetPixelPoint(frame)
        LibWin.OnDragStop(frame)
        if frame.dragBG then
            frame.dragBG:Hide()
        end
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
    name:SetText(frame:GetDebugName())
    name:SetPoint("CENTER")

    frame:SetPoint("CENTER", dragFrame)

    LibWin.RegisterConfig(dragFrame, RealUI.GetOptions(mod.moduleName, optionPath))
    LibWin.RestorePosition(dragFrame)

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
