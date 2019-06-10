local _, private = ...

-- Lua Globals --
local next = _G.next

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
        LibWin.RestorePosition(meta.dragFrame)
    end
end

function FramePoint:PositionFrame(mod, frame, position)
    local dragFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    _G.Aurora.Base.SetBackdrop(dragFrame, _G.Aurora.Color.white, 0.2)

    dragFrame:SetSize(frame:GetSize())
    dragFrame:SetHitRectInsets(-5, -5, -5, -5)
    dragFrame:SetMovable(true)
    dragFrame:EnableMouse(true)
    dragFrame:RegisterForDrag("LeftButton")
    dragFrame:SetScript("OnDragStart", LibWin.OnDragStart)
    dragFrame:SetScript("OnDragStop", function(...)
        LibWin.OnDragStop(...)
        if mod.OnDragStop then
            -- this is to live update a gui
            mod:OnDragStop(...)
        end
    end)
    dragFrame:Hide()

    local name = dragFrame:CreateFontString(nil, "BACKGROUND", "Game12Font")
    name:SetText(frame:GetDebugName())
    name:SetAllPoints()

    frame:SetPoint("TOPLEFT", dragFrame)

    LibWin.RegisterConfig(dragFrame, position)
    LibWin.RestorePosition(dragFrame)

    modules[mod].frames[frame] = {
        position = position,
        dragFrame = dragFrame,
    }
end

function FramePoint:IsModLocked(mod)
    return modules[mod].isLocked
end

function FramePoint:RegisterMod(mod)
    modules[mod] = {
        frames = {},
        isLocked = true,
    }
end
