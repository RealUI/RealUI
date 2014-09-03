local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local db, ndb, ndbc

local oUF = oUFembed

local function CreateTargetTarget(self)
    self:SetSize(F2.health.width, F2.health.height)
    local bg = self:CreateTexture()
    bg:SetTexture(0, 0, 0, 0.6)
    bg:SetAllPoints(self)

    local texture = self:CreateTexture()
    texture:SetTexture(1, 1, 1)

    self.Health = CreateFrame("StatusBar", nil, self)      
    self.Health:SetStatusBarTexture(texture)
    self.Health:SetAllPoints()
end

-- Init
tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char
    F2 = UnitFrames.textures[UnitFrames.layoutSize].F2

    oUF:RegisterStyle("RealUI:targettarget", CreateTargetTarget)
    oUF:SetActiveStyle("RealUI:targettarget")
    local targettarget = oUF:Spawn("targettarget", "RealUITargetTargetFrame")
    targettarget:SetPoint("LEFT", "RealUITargetFrame", db.positions[UnitFrames.layoutSize].targettarget.x, db.positions[UnitFrames.layoutSize].targettarget.y)
end)
