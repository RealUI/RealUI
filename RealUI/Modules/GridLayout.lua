local _, private = ...

-- Lua Globals --
-- luacheck: globals

-- RealUI --
local RealUI = private.RealUI
local MODNAME = "GridLayout"
local GridLayout = RealUI:NewModule(MODNAME, "AceConsole-3.0")

-- Grid2 position presets per layout
local positions = {
    [1] = { -- DPS/Tank: bottom-left, above chat
        anchor = "BOTTOMLEFT",
        groupAnchor = "BOTTOMLEFT",
        PosX = 80,
        PosY = 200,
    },
    [2] = { -- Healing: center-bottom
        anchor = "BOTTOM",
        groupAnchor = "BOTTOMLEFT",
        PosX = 0,
        PosY = 200,
    },
}

function GridLayout:ApplyPosition()
    if not _G.Grid2 then return end
    local layout = RealUI.cLayout or 1
    local pos = positions[layout]
    if not pos then return end

    local Grid2LayoutMod = _G.Grid2Layout
    if not Grid2LayoutMod then return end

    -- Update the live DB
    local db = Grid2LayoutMod.db and Grid2LayoutMod.db.profile
    if not db then return end

    -- Grid2 stores positions in UI-root-scaled coordinates
    -- We need to convert our desired anchor/offset into what Grid2 expects
    local s = _G.UIParent:GetEffectiveScale()
    db.anchor = pos.anchor
    db.groupAnchor = pos.groupAnchor
    db.PosX = pos.PosX * s
    db.PosY = pos.PosY * s

    -- Force Grid2 to reposition
    if Grid2LayoutMod.RestorePosition then
        Grid2LayoutMod:RestorePosition()
    end

    RealUI:Print(("Grid2 position: %s (%.0f, %.0f)"):format(pos.anchor, pos.PosX, pos.PosY))
end

function GridLayout:Grid2ChatCommand()
    _G.Grid2:OnChatCommand("")
end

function GridLayout:GridPosCommand()
    self:ApplyPosition()
end

function GridLayout:OnInitialize()
    self:SetEnabledState(not not _G.Grid2)
end

function GridLayout:OnEnable()
    self:debug("OnEnable")
    self:RegisterChatCommand("grid", "Grid2ChatCommand")
    self:RegisterChatCommand("gridpos", "GridPosCommand")

    local AddonControl = RealUI:GetModule("AddonControl")
    if AddonControl.db.profile.addonControl.Grid2 then
        AddonControl.db.profile.addonControl.Grid2 = nil
        _G.StaticPopup_Show("RealUI_ResetAddonProfile", "Grid2")
    end
end

function GridLayout:OnDisable()
end
