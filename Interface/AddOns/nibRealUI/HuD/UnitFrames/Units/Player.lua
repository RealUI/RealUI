local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local db, ndb, ndbc

local oUF = oUFembed

local positions = {
    [1] = {
        health = {
            x = -2,
            widthOfs = 13,
            coords = {0.1328125, 1, 0.1875, 1},
        },
        power = {
            x = -7,
            widthOfs = 10,
            coords = {0.23046875, 1, 0, 0.5},
        },
        endBox = {
            x = -10,
            y = -4
        }
    },
    [2] = {
        health = {
            x = -2,
            widthOfs = 15,
            coords = {0.494140625, 1, 0.0625, 1},
        },
        power = {
            x = -9,
            widthOfs = 12,
            coords = {0.1015625, 1, 0, 0.625},
        },
        endBox = {
            x = -11,
            y = -2
        }
    },
}

local function CreateHealthBar(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.health
    local pos = positions[UnitFrames.layoutSize].health
    local health = CreateFrame("Frame", nil, parent)
    health:SetPoint("TOPRIGHT", parent, 0, 0)
    health:SetSize(texture.width, texture.height)

    health.bar = AngleStatusBar:NewBar(health, pos.x, -1, texture.width - pos.widthOfs, texture.height - 2, "LEFT", "LEFT", "LEFT", true)

    health.bg = health:CreateTexture(nil, "BACKGROUND")
    health.bg:SetTexture(texture.bar)
    health.bg:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    health.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
    health.bg:SetAllPoints(health)

    health.border = health:CreateTexture(nil, "BORDER")
    health.border:SetTexture(texture.border)
    health.border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    health.border:SetAllPoints(health)

    health.text = health:CreateFontString(nil, "OVERLAY")
    health.text:SetPoint("BOTTOMRIGHT", health, "TOPRIGHT", 2, 2)
    health.text:SetFont(unpack(nibRealUI:Font()))
    parent:Tag(health.text, "[realui:health]")

    local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
    health.steps = {}
    for i = 1, 2 do
        health.steps[i] = health:CreateTexture(nil, "OVERLAY")
        health.steps[i]:SetTexture(texture.step)
        health.steps[i]:SetSize(16, 16)
        health.steps[i]:SetPoint("TOPLEFT", health, floor(stepPoints[i] * texture.width) - 6, 0)
    end

    health.frequentUpdates = true
    health.Override = UnitFrames.HealthOverride
    return health
end

local function CreatePowerBar(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.power
    local pos = positions[UnitFrames.layoutSize].power
    local power = CreateFrame("Frame", nil, parent)
    power:SetPoint("BOTTOMRIGHT", parent, -5, 0)
    power:SetSize(texture.width, texture.height)
    -- texture.width - 17 | Layout 1?
    power.bar = AngleStatusBar:NewBar(power, pos.x, -1, texture.width - pos.widthOfs, texture.height - 2, "RIGHT", "RIGHT", "LEFT", true)

    ---[[
    power.bg = power:CreateTexture(nil, "BACKGROUND")
    power.bg:SetTexture(texture.bar)
    power.bg:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    power.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
    power.bg:SetAllPoints(power)
    ---]]

    power.border = power:CreateTexture(nil, "BORDER")
    power.border:SetTexture(texture.border)
    power.border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    power.border:SetAllPoints(power)

    power.text = power:CreateFontString(nil, "OVERLAY")
    power.text:SetPoint("TOPRIGHT", power, "BOTTOMRIGHT", 2, -3)
    power.text:SetFont(unpack(nibRealUI:Font()))
    parent:Tag(power.text, "[realui:power]")

    local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
    power.steps = {}
    for i = 1, 2 do
        power.steps[i] = power:CreateTexture(nil, "OVERLAY")
        power.steps[i]:SetSize(16, 16)
        --power.steps[i]:SetPoint("BOTTOMLEFT", power, floor(stepPoints[i] * texture.width) - 6, 0)
    end

    power.frequentUpdates = true
    power.Override = UnitFrames.PowerOverride
    return power
end

local function CreatePvPStatus(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.healthBox
    local pvp = parent:CreateTexture(nil, "OVERLAY", nil, 1)
    pvp:SetTexture(texture.bar)
    pvp:SetSize(texture.width, texture.height)
    pvp:SetPoint("TOPRIGHT", parent, -8, -1)

    local border = parent:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetAllPoints(pvp)

    pvp.Override = UnitFrames.PvPOverride
    return pvp
end

local function CreatePowerStatus(parent) -- Combat, AFK, etc.
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.statusBox
    local status = {}
    for i = 1, 2 do
        status[i] = {}
        status[i].bg = parent.Power:CreateTexture(nil, "BORDER")
        status[i].bg:SetTexture(texture.bar)
        status[i].bg:SetSize(texture.width, texture.height)

        status[i].border = parent.Power:CreateTexture(nil, "OVERLAY", nil, 3)
        status[i].border:SetTexture(texture.border)
        status[i].border:SetAllPoints(status[i].bg)

        status[i].bg.Override = UnitFrames.UpdateStatus
        status[i].border.Override = UnitFrames.UpdateStatus

        if i == 1 then
            status[i].bg:SetPoint("TOPRIGHT", parent.Power, "TOPLEFT", 8, 0)
            parent.Combat = status[i].bg
            parent.Resting = status[i].border
        else
            status[i].bg:SetPoint("TOPRIGHT", parent.Power, "TOPLEFT", 2, 0)
            parent.Leader = status[i].bg
            parent.AFK = status[i].border
        end
    end
end

local function CreateStats(parent)
    local stats = {}
    for i = 1, 2 do
        stats[i] = {}
        stats[i].icon = parent:CreateTexture(nil, "OVERLAY")
        stats[i].icon:SetTexture(nibRealUI.media.icons.DoubleArrow)
        stats[i].icon:SetSize(16, 16)
        if i == 1 then
            stats[i].icon:SetPoint("BOTTOMLEFT", parent.Health, "BOTTOMRIGHT", 10, 0)
        else
            stats[i].icon:SetPoint("TOPLEFT", parent.Power, "TOPRIGHT", 15, 5)
        end

        stats[i].text = parent:CreateFontString(nil, "OVERLAY")
        stats[i].text:SetFont(unpack(nibRealUI:Font()))
        stats[i].text:SetPoint("BOTTOMLEFT", stats[i].icon, "BOTTOMRIGHT", 0, 0)
    end
    return stats
end

local function CreateEndBox(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.endBox
    local pos = positions[UnitFrames.layoutSize].endBox
    local endBox = parent:CreateTexture(nil, "BORDER")
    endBox:SetTexture(texture.bar)
    endBox:SetSize(texture.width, texture.height)
    endBox:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", pos.x, pos.y)

    local border = parent:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetAllPoints(endBox)

    endBox.Update = UnitFrames.UpdateEndBox
   
    return endBox
end

local function CreatePlayer(self)
    self.Health = CreateHealthBar(self)
    self.Power = CreatePowerBar(self)
    self.PvP = CreatePvPStatus(self.Health)
    CreatePowerStatus(self)
    self.Stats = CreateStats(self)
    self.endBox = CreateEndBox(self)

    self.PvP.text = self:CreateFontString(nil, "OVERLAY")
    self.PvP.text:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 15, 2)
    self.PvP.text:SetFont(unpack(nibRealUI:Font()))
    self.PvP.text:SetJustifyH("LEFT")
    self.PvP.text.frequentUpdates = 1
    self:Tag(self.PvP.text, "[realui:pvptimer]")

    self:SetSize(self.Health:GetWidth(), self.Health:GetHeight() + self.Power:GetHeight() + 3)
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    function self:PostUpdate(event)
        self.endBox.Update(self, event)

        local _, powerType = UnitPowerType(self.unit)
        AngleStatusBar:SetBarColor(self.Power.bar, db.overlay.colors.power[powerType])
        self.Power.bar.reverse = UnitFrames.ReversePowers[powerType] or false
        self.Power.enabled = true

        local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.power
        local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
        if self.Power.bar.reverse then
            for i = 1, 2 do
                self.Power.steps[i]:ClearAllPoints()
                self.Power.steps[i]:SetPoint("BOTTOMRIGHT", self.Power, -(floor(stepPoints[i] * texture.width) - 6), 0)
            end
        else
            for i = 1, 2 do
                self.Power.steps[i]:ClearAllPoints()
                self.Power.steps[i]:SetPoint("BOTTOMLEFT", self.Power, floor(stepPoints[i] * texture.width) - 6, 0)
            end
        end
    end
end

-- Init
tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char

    oUF:RegisterStyle("RealUI:player", CreatePlayer)
    oUF:SetActiveStyle("RealUI:player")
    local player = oUF:Spawn("player", "RealUIPlayerFrame")
    player:SetPoint("RIGHT", "RealUIPositionersUnitFrames", "LEFT", db.positions[UnitFrames.layoutSize].player.x, db.positions[UnitFrames.layoutSize].player.y)
    player:RegisterEvent("PLAYER_FLAGS_CHANGED", UnitFrames.UpdateStatus)
end)

