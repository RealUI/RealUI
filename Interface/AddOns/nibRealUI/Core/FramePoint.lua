local _, private = ...

-- Lua Globals --
local next = _G.next

-- Libs --
local LibWin = _G.LibStub("LibWindow-1.1")

-- RealUI --
local RealUI = private.RealUI
local round = RealUI.Round
local L = RealUI.L

local MODNAME = "FramePoint"
local FramePoint = RealUI:NewModule(MODNAME)

local modules = {}

local function Toggle(mod, isLocked)
    local module = modules[mod]
    if module.locked == isLocked then return end

    for frame, meta in next, module.frames do
        frame:EnableMouse(not isLocked)
        meta.dragBG:SetShown(not isLocked)
    end

    if module.callback then module.callback(mod, isLocked) end
    module.locked = isLocked
end

local function Restore(mod, isLocked)
    local module = modules[mod]
    for frame, meta in next, module.frames do
        frame:RestorePosition()
    end
end

local function PositionFrame(mod, frame, position)
    LibWin:Embed(frame)
    frame:RegisterConfig(position)
    frame:RestorePosition()
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(...)
        LibWin.OnDragStart(...)
    end)
    frame:SetScript("OnDragStop", function(...)
        LibWin.OnDragStop(...)
        _G.LibStub("AceConfigRegistry-3.0"):NotifyChange("HuD")
    end)

    local dragBG = frame:CreateTexture()
    dragBG:SetColorTexture(1, 1, 1, 0.5)
    dragBG:SetAllPoints()
    dragBG:Hide()

    modules[mod].frames[frame] = {
        position = position,
        dragBG = dragBG,
    }
end

local function AddPositionConfig(mod, configDB, position, startOrder)
    configDB.args.headerPos = {
        name = L["General_Position"],
        type = "header",
        order = startOrder,
    }
    configDB.args.position = {
        name = "",
        type = "group",
        inline = true,
        order = startOrder + 1,
        args = {
            lock = {
                name = L["General_Lock"],
                desc = L["General_LockDesc"],
                type = "toggle",
                get = function(info) return modules[mod].locked end,
                set = function(info, value)
                    Toggle(mod, value)
                end,
                order = 0,
            },
            x = {
                name = L["General_XOffset"],
                desc = L["General_XOffsetDesc"],
                type = "input",
                dialogControl = "NumberEditBox",
                get = function(info)
                    print("get", position.x)
                    return _G.tostring(position.x)
                end,
                set = function(info, value)
                    print("set", value)
                    position.x = round(_G.tonumber(value))
                    Restore(mod)
                end,
                order = 10,
            },
            y = {
                name = L["General_YOffset"],
                desc = L["General_YOffsetDesc"],
                type = "input",
                dialogControl = "NumberEditBox",
                get = function(info) return _G.tostring(position.y) end,
                set = function(info, value)
                    position.y = round(_G.tonumber(value))
                    Restore(mod)
                end,
                order = 20,
            },
        },
    }
end

function FramePoint:RegisterMod(mod, callback)
    modules[mod] = {
        frames = {},
        locked = true,
        callback = callback,
    }
    mod.PositionFrame = PositionFrame
    mod.AddPositionConfig = AddPositionConfig
end
