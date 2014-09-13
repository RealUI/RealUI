local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local db, ndb, ndbc

local oUF = oUFembed

local F2
local coords = {
    [1] = {
        health = {0.546875, 1, 0.4375, 1},
    },
    [2] = {
        health = {0.4609375, 1, 0.375, 1},
    },
}

local function CreateHealthBar(parent)
    local texture = F2.health
    local coords = coords[UnitFrames.layoutSize].health
    local health = CreateFrame("Frame", nil, parent)
    health:SetPoint("BOTTOMRIGHT", parent, 0, 0)
    health:SetAllPoints(parent)

    health.bar = AngleStatusBar:NewBar(health, -2, -1, texture.width - 3, texture.height - 2, "LEFT", "RIGHT", "LEFT", true)

    health.bg = health:CreateTexture(nil, "BACKGROUND")
    health.bg:SetTexture(texture.bar)
    health.bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    health.bg:SetVertexColor(0, 0, 0, 0.4)
    health.bg:SetAllPoints(health)

    health.border = health:CreateTexture(nil, "BORDER")
    health.border:SetTexture(texture.border)
    health.border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    health.border:SetAllPoints(health)

    local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
    health.steps = {}
    for i = 1, 2 do
        health.steps[i] = health:CreateTexture(nil, "OVERLAY")
        health.steps[i]:SetSize(16, 16)
        health.steps[i]:SetPoint("TOPLEFT", health, floor(stepPoints[i] * texture.width), 0)
    end

    health.Override = UnitFrames.HealthOverride
    return health
end

local function CreatePvPStatus(parent)
    local texture = F2.healthBox
    local pvp = parent.Health:CreateTexture(nil, "OVERLAY", nil, 1)
    pvp:SetTexture(texture.bar)
    pvp:SetSize(texture.width, texture.height)
    pvp:SetPoint("TOPRIGHT", parent, -8, -1)

    local border = parent.Health:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetAllPoints(pvp)

    pvp.Override = function(self, event, unit)
        --print("PvP Override", self, event, unit, IsPVPTimerRunning())
        pvp:SetVertexColor(0, 0, 0, 0.6)
        if UnitIsPVP(unit) then
            if UnitIsFriend(unit, "focus") then
                self.PvP:SetVertexColor(unpack(db.overlay.colors.status.pvpFriendly))
            else
                self.PvP:SetVertexColor(unpack(db.overlay.colors.status.pvpEnemy))
            end
        end
    end
    return pvp
end

local function CreateCombatResting(parent)
    local texture = F2.statusBox
    local combat = parent:CreateTexture(nil, "BORDER")
    combat:SetTexture(texture.bar)
    combat:SetSize(texture.width, texture.height)
    combat:SetPoint("TOPRIGHT", parent, "TOPLEFT", 7, 0)

    local resting = parent:CreateTexture(nil, "OVERLAY", nil, 3)
    resting:SetTexture(texture.border)
    resting:SetAllPoints(combat)

    combat.Override = UnitFrames.CombatResting
    resting.Override = UnitFrames.CombatResting
    
    return combat, resting
end

local function CreateEndBox(parent)
    local texture = F2.endBox
    local endBox = parent:CreateTexture(nil, "BORDER")
    endBox:SetTexture(texture.bar)
    endBox:SetSize(texture.width, texture.height)
    endBox:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -6 - UnitFrames.layoutSize, 0)

    local border = parent:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetAllPoints(endBox)
   
    return endBox
end

local function CreateFocus(self)
    self:SetSize(F2.health.width, F2.health.height)
    self.Health = CreateHealthBar(self)
    self.PvP = CreatePvPStatus(self)
    self.Combat, self.Resting = CreateCombatResting(self)
    self.endBox = CreateEndBox(self)

    self.Name = self:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
    self.Name:SetFont(unpack(nibRealUI:Font()))
    self:Tag(self.Name, "[realui:name]")

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    function self:PostUpdate(event)
        self.Combat.Override(self, event)
        UnitFrames:UpdateEndBox(self, event)
    end
end

-- Init
tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char
    F2 = UnitFrames.textures[UnitFrames.layoutSize].F2

    oUF:RegisterStyle("RealUI:focus", CreateFocus)
    oUF:SetActiveStyle("RealUI:focus")
    local focus = oUF:Spawn("focus", "RealUIFocusFrame")
    focus:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame", db.positions[UnitFrames.layoutSize].focus.x, db.positions[UnitFrames.layoutSize].focus.y)
end)

