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
    self:SetEnabledState(not not _G.Grid2)
end

function GridLayout:OnEnable()
    self:debug("OnEnable")
    self:RegisterChatCommand("grid", "Grid2ChatCommand")


    local AddonControl = RealUI:GetModule("AddonControl")
    if AddonControl.db.profile.addonControl.Grid2 then
        AddonControl.db.profile.addonControl.Grid2 = nil
        _G.StaticPopup_Show("RealUI_ResetAddonProfile", "Grid2")
    end
end

function GridLayout:OnDisable()
end
