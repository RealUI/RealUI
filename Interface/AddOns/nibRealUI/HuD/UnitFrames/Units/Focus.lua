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
        health = {0.5390625, 1, 0.375, 1},
    },
}

local function CreateHealthBar(parent)
    local texture = F2.health
    local coords = coords[UnitFrames.layoutSize].health
    local health = CreateFrame("Frame", nil, parent)
    health:SetPoint("BOTTOMRIGHT", parent, 0, 0)
    health:SetSize(256, 16)

    health.bar = AngleStatusBar:NewBar(health, -2, -1, texture.width, texture.height - 2, "LEFT", "RIGHT", "LEFT", true)
---[[
    health.bg = health:CreateTexture(nil, "BACKGROUND")
    health.bg:SetTexture(texture.bar)
    --health.bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    health.bg:SetVertexColor(0, 0, 0, 0.4)
    health.bg:SetAllPoints(health)
---]]
    health.border = health:CreateTexture(nil, "BORDER")
    health.border:SetTexture(texture.border)
    --health.border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    health.border:SetAllPoints(health)

    health.Override = UnitFrames.HealthOverride
    return health
end

local function CreatePvPStatus(parent)
    local texture = F2.healthBox
    local pvp = parent:CreateTexture(nil, "OVERLAY", nil, 1)
    pvp:SetTexture(texture.bar)
    pvp:SetSize(texture.width, texture.height)
    pvp:SetPoint("TOPRIGHT", parent, -8, -1)

    local border = parent:CreateTexture(nil, "OVERLAY", nil, 3)
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

local function CreateCombat(parent)
    local texture = F2.statusBox
    local combat = parent:CreateTexture(nil, "BORDER")
    combat:SetTexture(texture.bar)
    combat:SetSize(texture.width, texture.height)
    combat:SetPoint("TOPRIGHT", parent, "TOPLEFT", 8, 0)

    local border = parent:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetAllPoints(combat)

    local combatColor = db.overlay.colors.status.combat
    combat.Override = function(self, event, unit)
        if event == "PLAYER_REGEN_DISABLED" then
            print("Combat Override", self, event, unit)
            self.Combat:SetVertexColor(combatColor[1], combatColor[2], combatColor[3], combatColor[4])
            self.Combat.isCombat = true
        elseif event == "PLAYER_REGEN_ENABLED" then
            print("Combat Override", self, event, unit)
            self.Combat:SetVertexColor(0, 0, 0, 0.6)
            self.Combat.isCombat = false
            self.Resting.Override(self, event, unit)
        end
    end
    
    return combat
end

local function CreateFocus(self)
    self:SetSize(F2.health.width, F2.health.height)
    self.Health = CreateHealthBar(self)
    self.PvP = CreatePvPStatus(self)
    self.Combat = CreateCombat(self)

    self.Name = self:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 0)
    self.Name:SetFont(unpack(nibRealUI:Font()))
    self:Tag(self.Name, "[realui:name]")

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
end

-- Init
tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char
    print("Layout", UnitFrames.layoutSize)
    F2 = UnitFrames.textures[UnitFrames.layoutSize].F2

    oUF:RegisterStyle("RealUI:focus", CreateFocus)
    oUF:SetActiveStyle("RealUI:focus")
    local focus = oUF:Spawn("focus", "RealUIFocusFrame")
    focus:SetPoint("RIGHT", "RealUIPositionersUnitFrames", "LEFT", db.positions[UnitFrames.layoutSize].focus.x, db.positions[UnitFrames.layoutSize].focus.y)
end)

