local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local db, ndb, ndbc

local oUF = oUFembed

local function CreateFocusTarget(self)
    self:SetSize(F3.health.width, F3.health.height)
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
    F3 = UnitFrames.textures[UnitFrames.layoutSize].F3

    oUF:RegisterStyle("RealUI:focustarget", CreateFocusTarget)
    oUF:SetActiveStyle("RealUI:focustarget")
    local focustarget = oUF:Spawn("focustarget", "RealUIFocusTargetFrame")
    focustarget:SetPoint("RIGHT", "RealUIFocusFrame", db.positions[UnitFrames.layoutSize].focustarget.x, db.positions[UnitFrames.layoutSize].focustarget.y)
end)
