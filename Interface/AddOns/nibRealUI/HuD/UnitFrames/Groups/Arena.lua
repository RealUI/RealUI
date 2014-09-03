local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local db, ndb, ndbc

local oUF = oUFembed

local function CreateArena(self)
    -- body
end

-- Init
tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char

    oUF:RegisterStyle("RealUI:arena", CreateArena)
    oUF:SetActiveStyle("RealUI:arena")
    -- Bosses and arenas are mutually excusive, so we'll just use some boss stuff for both for now.
    for i = 1, MAX_BOSS_FRAMES do
        local arena = oUF:Spawn("arena" .. i, "RealUIArenaFrame" .. i)
        if (i == 1) then
            arena:SetPoint("LEFT", "RealUIPositionersBossFrames", "RIGHT", db.positions[UnitFrames.layoutSize].boss.x, db.positions[UnitFrames.layoutSize].boss.y)
        else
            arena:SetPoint("TOP", _G["RealUIArenaFrame" .. i - 1], "BOTTOM", 0, -db.boss.gap)
        end
    end
end)
