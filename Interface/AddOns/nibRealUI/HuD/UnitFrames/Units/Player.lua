local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local db, ndb, ndbc

local oUF = oUFembed

local info = {
    [1] = {
        health = {
            leftAngle = [[/]],
            rightAngle = [[/]],
            growDirection = "LEFT",
            smooth = true,
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
            leftAngle = [[/]],
            rightAngle = [[/]],
            growDirection = "LEFT",
            smooth = true,
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
    local pos = info[UnitFrames.layoutSize].health
    --parent.Health = CreateFrame("Frame", nil, parent.overlay) -- comment this for new bars
    parent.Health = parent:CreateAngleStatusBar(texture.width, texture.height, parent.overlay, pos)
    parent.Health:SetPoint("TOPRIGHT", parent, 0, 0)
    parent.Health:SetSize(texture.width, texture.height)

    --parent.Health.bar = AngleStatusBar:NewBar(parent.Health, pos.x, -1, texture.width - pos.widthOfs - 2, texture.height - 2, "LEFT", "LEFT", "LEFT", true)
    if ndb.settings.reverseUnitFrameBars then 
        AngleStatusBar:SetReverseFill(parent.Health, true)
    end
    UnitFrames:SetHealthColor(parent)

    --[[ comment these for new bars
    parent.Health.bg = parent.Health:CreateTexture(nil, "BACKGROUND")
    parent.Health.bg:SetTexture(texture.bar)
    parent.Health.bg:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Health.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
    parent.Health.bg:SetAllPoints(parent.Health)

    parent.Health.border = parent.Health:CreateTexture(nil, "BORDER")
    parent.Health.border:SetTexture(texture.border)
    parent.Health.border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Health.border:SetAllPoints(parent.Health)
    --]]
    parent.Health.text = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.Health.text:SetPoint("BOTTOMRIGHT", parent.Health, "TOPRIGHT", 2, 2)
    parent.Health.text:SetFont(unpack(nibRealUI:Font()))
    parent:Tag(parent.Health.text, "[realui:smartHealth]")

    local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
    parent.Health.steps = {}
    for i = 1, 2 do
        parent.Health.steps[i] = parent.Health:CreateTexture(nil, "OVERLAY")
        parent.Health.steps[i]:SetTexture(texture.step)
        parent.Health.steps[i]:SetSize(16, 16)
        if parent.Health.bar.reverse then
            parent.Health.steps[i]:SetPoint("TOPRIGHT", parent.Health, -(floor(stepPoints[i] * texture.width) - 6), 0)
        else
        parent.Health.steps[i]:SetPoint("TOPLEFT", parent.Health, floor(stepPoints[i] * texture.width) - 6, 0)
    end
    end

    parent.Health.frequentUpdates = true
    parent.Health.Override = UnitFrames.HealthOverride
end

local function CreatePredictBar(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.health
    local pos = info[UnitFrames.layoutSize].health
    local absorbBar = AngleStatusBar:NewBar(parent.Health, pos.x, -1, texture.width - pos.widthOfs - 2, texture.height - 2, "LEFT", "LEFT", "LEFT", true)
    AngleStatusBar:SetBarColor(absorbBar, 1, 1, 1, db.overlay.bar.opacity.absorb)

    parent.HealPrediction = {
        absorbBar = absorbBar,
        frequentUpdates = true,
        Override = UnitFrames.PredictOverride,
    }
end

local function CreatePvPStatus(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.healthBox
    parent.PvP = parent.Health:CreateTexture(nil, "OVERLAY", nil, 1)
    parent.PvP:SetTexture(texture.bar)
    parent.PvP:SetSize(texture.width, texture.height)
    parent.PvP:SetPoint("TOPRIGHT", parent.Health, -8, -1)

    local border = parent.Health:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetAllPoints(parent.PvP)

    parent.PvP.text = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.PvP.text:SetPoint("BOTTOMLEFT", parent.Health, "TOPLEFT", 15, 2)
    parent.PvP.text:SetFont(unpack(nibRealUI:Font()))
    parent.PvP.text:SetJustifyH("LEFT")
    parent.PvP.text.frequentUpdates = 1
    parent:Tag(parent.PvP.text, "[realui:pvptimer]")

    parent.PvP.Override = UnitFrames.PvPOverride
end

local function CreatePowerBar(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.power
    local pos = info[UnitFrames.layoutSize].power
    parent.Power = CreateFrame("Frame", nil, parent.overlay)
    parent.Power:SetPoint("BOTTOMRIGHT", parent, -5, 0)
    parent.Power:SetSize(texture.width, texture.height)
    -- texture.width - 17 | Layout 1?
    parent.Power.bar = AngleStatusBar:NewBar(parent.Power, pos.x, -1, texture.width - pos.widthOfs, texture.height - 2, "RIGHT", "RIGHT", "LEFT", true)

    parent.Power.bg = parent.Power:CreateTexture(nil, "BACKGROUND")
    parent.Power.bg:SetTexture(texture.bar)
    parent.Power.bg:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Power.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
    parent.Power.bg:SetAllPoints(parent.Power)

    parent.Power.border = parent.Power:CreateTexture(nil, "BORDER")
    parent.Power.border:SetTexture(texture.border)
    parent.Power.border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Power.border:SetAllPoints(parent.Power)

    parent.Power.text = parent.Power:CreateFontString(nil, "OVERLAY")
    parent.Power.text:SetPoint("TOPRIGHT", parent.Power, "BOTTOMRIGHT", 2, -3)
    parent.Power.text:SetFont(unpack(nibRealUI:Font()))
    parent:Tag(parent.Power.text, "[realui:power]")

    local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
    parent.Power.steps = {}
    for i = 1, 2 do
        parent.Power.steps[i] = parent.Power:CreateTexture(nil, "OVERLAY")
        parent.Power.steps[i]:SetSize(16, 16)
    end

    parent.Power.frequentUpdates = true
    parent.Power.Override = UnitFrames.PowerOverride
end

local function CreatePowerStatus(parent) -- Combat, AFK, etc.
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.statusBox
    local status = {}
    for i = 1, 2 do
        status.bg = parent.Power:CreateTexture(nil, "BORDER")
        status.bg:SetTexture(texture.bar)
        status.bg:SetSize(texture.width, texture.height)

        status.border = parent.Power:CreateTexture(nil, "OVERLAY", nil, 3)
        status.border:SetTexture(texture.border)
        status.border:SetAllPoints(status.bg)

        status.bg.Override = UnitFrames.UpdateStatus
        status.border.Override = UnitFrames.UpdateStatus

        if i == 1 then
            status.bg:SetPoint("TOPRIGHT", parent.Power, "TOPLEFT", 8, 0)
            parent.Combat = status.bg
            parent.Resting = status.border
        else
            status.bg:SetPoint("TOPRIGHT", parent.Power, "TOPLEFT", 2, 0)
            parent.Leader = status.bg
            parent.AFK = status.border
        end
    end
end

local function CreateStats(parent)
    parent.Stats = {}
    for i = 1, 2 do
        parent.Stats[i] = {}
        parent.Stats[i].icon = parent.overlay:CreateTexture(nil, "OVERLAY")
        parent.Stats[i].icon:SetTexture(nibRealUI.media.icons.DoubleArrow)
        parent.Stats[i].icon:SetSize(16, 16)
        if i == 1 then
            parent.Stats[i].icon:SetPoint("BOTTOMLEFT", parent.Health, "BOTTOMRIGHT", 10, 0)
        else
            parent.Stats[i].icon:SetPoint("TOPLEFT", parent.Power, "TOPRIGHT", 15, 5)
        end

        parent.Stats[i].text = parent.overlay:CreateFontString(nil, "OVERLAY")
        parent.Stats[i].text:SetFont(unpack(nibRealUI:Font()))
        parent.Stats[i].text:SetPoint("BOTTOMLEFT", parent.Stats[i].icon, "BOTTOMRIGHT", 0, 0)
    end
end

local function CreateEndBox(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.endBox
    local pos = info[UnitFrames.layoutSize].endBox
    parent.endBox = parent.overlay:CreateTexture(nil, "BORDER")
    parent.endBox:SetTexture(texture.bar)
    parent.endBox:SetSize(texture.width, texture.height)
    parent.endBox:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", pos.x, pos.y)

    local border = parent.overlay:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetAllPoints(parent.endBox)

    parent.endBox.Update = UnitFrames.UpdateEndBox
end

local function CreateTotems(parent)
    -- DestroyTotem is protected, so we hack the default
    local totemBar = _G["TotemFrame"]
    totemBar:SetParent(parent.overlay)
    hooksecurefunc("TotemFrame_Update", function()
        totemBar:ClearAllPoints()
        totemBar:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 10, -4)
    end)
    for i = 1, 4 do
        local name = "TotemFrameTotem"..i
        local totem = _G[name]
        totem:SetSize(22, 22)
        totem:ClearAllPoints()
        totem:SetPoint("TOPLEFT", totemBar, i * (totem:GetWidth() + 3), 0)
        nibRealUI:CreateBG(totem)
        
        local bg = _G[name.."Background"]
        bg:SetTexture("")
        local dur = _G[name.."Duration"]
        dur:Hide()
        dur.Show = function() end
        
        local icon = _G[name.."IconTexture"]
        icon:SetTexCoord(.08, .92, .08, .92)
        icon:ClearAllPoints()
        icon:SetAllPoints()
        
        local _, border = totem:GetChildren()
        border:DisableDrawLayer("OVERLAY")
    end
end

UnitFrames["player"] = function(self)
    CreateHealthBar(self)
    CreatePredictBar(self)
    CreatePvPStatus(self)
    CreatePowerBar(self)
    CreatePowerStatus(self)
    CreateStats(self)
    CreateEndBox(self)
    CreateTotems(self)

    self:SetSize(self.Health:GetWidth(), self.Health:GetHeight() + self.Power:GetHeight() + 3)

    function self:PostUpdate(event)
        self.endBox.Update(self, event)

        local _, powerType = UnitPowerType(self.unit)
        AngleStatusBar:SetBarColor(self.Power.bar, UnitFrames.PowerColors[powerType])
        AngleStatusBar:SetReverseFill(self.Power.bar, UnitFrames.ReversePowers[powerType] or (ndb.settings.reverseUnitFrameBars))
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

    local player = oUF:Spawn("player", "RealUIPlayerFrame")
    player:SetPoint("RIGHT", "RealUIPositionersUnitFrames", "LEFT", db.positions[UnitFrames.layoutSize].player.x, db.positions[UnitFrames.layoutSize].player.y)
    player:RegisterEvent("PLAYER_FLAGS_CHANGED", UnitFrames.UpdateStatus)
    player:RegisterEvent("UPDATE_SHAPESHIFT_FORM", player.PostUpdate)
end)

