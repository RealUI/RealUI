local _, private = ...

-- Lua Globals --
-- luacheck: globals

-- RealUI --
local RealUI = private.RealUI
local MODNAME = "GridLayout"
local GridLayout = RealUI:NewModule(MODNAME, "AceConsole-3.0")

function GridLayout:Grid2ChatCommand()
    _G.Grid2:OnChatCommand("")
end

function GridLayout:OnInitialize()
    if _G.Grid2 and _G.Grid2Layout and _G.Grid2Frame then
        self:SetEnabledState(true)
    else
        self:SetEnabledState(false)
    end
end

function GridLayout:OnEnable()
    self:debug("OnEnable")

    if RealUI:DoesAddonMove("Grid2") then
        RealUI:ToggleAddonPositionControl("Grid2", false)
    end
    self:RegisterChatCommand("grid", "Grid2ChatCommand")
end

function GridLayout:OnDisable()
end
