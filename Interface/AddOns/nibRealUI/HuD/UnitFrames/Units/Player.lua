local _, private = ...

-- Lua Globals --
local _G = _G

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local round = RealUI.Round
local db, ndb

local UnitFrames = RealUI:GetModule("UnitFrames")

local frameInfo = {
    health = {
        leftAngle = [[/]],
        rightAngle = [[/]],
        debug = true
    },
    predict = {
        leftAngle = [[/]],
        rightAngle = [[/]],
    },
    power = {
        leftAngle = [[\]],
        rightAngle = [[\]],
    },
    [1] = {
        x = 222,
        y = 24,
        endBox = {
            x = -10,
            y = -4,
        },
    },
    [2] = {
        x = 259,
        y = 28,
        endBox = {
            x = -11,
            y = -2,
        },
    },
}

local function CreateHealthBar(parent)
    local width, height = parent:GetWidth(), round((parent:GetHeight() - 3) * db.units.player.healthHeight)
    local info = frameInfo.health
    info.debug = info.debug and "playerHealth"
    local health = parent:CreateAngleFrame("Status", width, height, parent.overlay, info)
    health:SetPoint("TOPRIGHT", parent, 0, 0)
    health:SetMinMaxValues(0, 1)
    health:SetReverseFill(true)
    health:SetReversePercent(not ndb.settings.reverseUnitFrameBars)

    health.text = health:CreateFontString(nil, "OVERLAY")
    health.text:SetPoint("BOTTOMRIGHT", health, "TOPRIGHT", 2, 2)
    health.text:SetFontObject(_G.RealUIFont_Pixel)
    parent:Tag(health.text, "[realui:health]")

    local stepHeight = round(height / 2)
    health.step = {}
    health.warn = {}
    for i = 1, 2 do
        info.debug = info.debug and "playerHealthStep" .. i
        health.step[i] = parent:CreateAngleFrame("Frame", stepHeight + 2, stepHeight, health, info)
        health.step[i]:SetBackgroundColor(.5, .5, .5, RealUI.media.background[4])

        info.debug = info.debug and "playerHealthWarn" .. i
        health.warn[i] = parent:CreateAngleFrame("Frame", height + 2, height, health, info)
        health.warn[i]:SetBackgroundColor(.5, .5, .5, RealUI.media.background[4])
    end

    health.colorClass = db.overlay.classColor
    health.colorHealth = true
    health.frequentUpdates = true

    health.PositionSteps = UnitFrames.PositionSteps
    health.PostUpdate = UnitFrames.UpdateSteps
    parent.Health = health
end

local function CreatePredictBar(parent)
    local width, height = parent.Health:GetSize()
    local info = frameInfo.predict
    info.debug = info.debug and "playerPredict"
    local absorbBar = parent:CreateAngleFrame("Bar", width, height, parent.Health, info)
    absorbBar:SetStatusBarColor(1, 1, 1, db.overlay.bar.opacity.absorb)

    parent.HealPrediction = {
        frequentUpdates = true,
        maxOverflow = 1,
        absorbBar = absorbBar,
        Override = UnitFrames.PredictOverride,
    }
end

local function CreatePvPStatus(parent)
    local _, height = parent.Health:GetSize()
    local info = frameInfo.health
    info.debug = info.debug and "playerPvP"

    height = _G.ceil(height * 0.65)
    local pvp = parent:CreateAngleFrame("Frame", height + 4, height, parent.Health, info)
    pvp:SetPoint("TOPRIGHT", parent.Health, -8, 0)

    pvp.text = pvp:CreateFontString(nil, "OVERLAY")
    pvp.text:SetPoint("BOTTOMLEFT", parent.Health, "TOPLEFT", 15, 2)
    pvp.text:SetFontObject(_G.RealUIFont_Pixel)
    pvp.text:SetJustifyH("LEFT")
    pvp.text.frequentUpdates = 1
    parent:Tag(pvp.text, "[realui:pvptimer]")

    pvp.Override = UnitFrames.PvPOverride
    parent.PvP = pvp
end

local function CreatePowerBar(parent)
    local width, height = round(parent:GetWidth() * 0.89), round((parent:GetHeight() - 3) * (1 - db.units.player.healthHeight))
    local info = frameInfo.power
    info.debug = info.debug and "playerPower"
    local power = parent:CreateAngleFrame("Status", width, height, parent.overlay, info)
    local _, powerType = _G.UnitPowerType(parent.unit)
    power:SetPoint("BOTTOMRIGHT", parent, -5, 0)
    power:SetMinMaxValues(0, 1)
    power:SetReverseFill(true)
    if ndb.settings.reverseUnitFrameBars then
        power:SetReversePercent(RealUI.ReversePowers[powerType])
    else
        power:SetReversePercent(not RealUI.ReversePowers[powerType])
    end

    power.text = power:CreateFontString(nil, "OVERLAY")
    power.text:SetPoint("TOPRIGHT", power, "BOTTOMRIGHT", 2, -3)
    power.text:SetFontObject(_G.RealUIFont_Pixel)
    parent:Tag(power.text, "[realui:power]")

    local stepHeight = round(height * .6)
    power.step = {}
    power.warn = {}
    for i = 1, 2 do
        info.debug = info.debug and "playerPowerStep" .. i
        power.step[i] = parent:CreateAngleFrame("Frame", stepHeight + 2, stepHeight, power, info)
        power.step[i]:SetBackgroundColor(.5, .5, .5, RealUI.media.background[4])

        info.debug = info.debug and "playerPowerWarn" .. i
        power.warn[i] = parent:CreateAngleFrame("Frame", height + 2, height, power, info)
        power.warn[i]:SetBackgroundColor(.5, .5, .5, RealUI.media.background[4])
    end

    power.colorPower = true
    power.frequentUpdates = true

    power.PositionSteps = UnitFrames.PositionSteps
    power.PostUpdate = UnitFrames.UpdateSteps
    parent.Power = power

    --[[ Druid Mana ]]--
    if RealUI.class == "DRUID" then
        local druidMana = _G.CreateFrame("StatusBar", nil, power)
        druidMana:SetStatusBarTexture(RealUI.media.textures.plain, "BORDER")
        druidMana:SetStatusBarColor(0, 0, 0, 0.75)
        druidMana:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", -height, 0)
        druidMana:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, 0)
        druidMana:SetHeight(1)

        function druidMana:PostUpdate(unit, min, max)
            if min == max then
                self:Hide()
            end
        end

        --[[ test 
        druidMana:SetMinMaxValues(0, 1)
        druidMana:SetValue(0.75)
        druidMana:SetReverseFill(ndb.settings.reverseUnitFrameBars)
        ]]
        -- Add a background
        local bg = druidMana:CreateTexture(nil, 'BACKGROUND')
        bg:SetAllPoints(druidMana)
        bg:SetTexture(.2, .2, 1)

        parent.DruidMana = druidMana
        parent.DruidMana.bg = bg
    end
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

local function CreateEndBox(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.endBox
    local pos = frameInfo[UnitFrames.layoutSize].endBox
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
    _G.hooksecurefunc("TotemFrame_Update", function()
        totemBar:ClearAllPoints()
        totemBar:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 10, -4)
    end)
    for i = 1, 4 do
        local name = "TotemFrameTotem"..i
        local totem = _G[name]
        totem:SetSize(22, 22)
        totem:ClearAllPoints()
        totem:SetPoint("TOPLEFT", totemBar, i * (totem:GetWidth() + 3), 0)
        RealUI:CreateBG(totem)

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
    self:SetSize(frameInfo[UnitFrames.layoutSize].x, frameInfo[UnitFrames.layoutSize].y)

    CreateHealthBar(self)
    CreatePredictBar(self)
    CreatePvPStatus(self)
    CreatePowerBar(self)
    CreatePowerStatus(self)
    CreateEndBox(self)
    CreateTotems(self)

    self.RaidIcon = self:CreateTexture(nil, "OVERLAY")
    self.RaidIcon:SetSize(20, 20)
    self.RaidIcon:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 10, 4)

    function self.PreUpdate(frame, event)
        if event == "ClassColorBars" then
            frame.Health.colorClass = db.overlay.classColor
        elseif event == "ReverseBars" then
            frame.Health:SetReversePercent(not frame.Health:GetReversePercent())
            frame.Power:SetReversePercent(not frame.Power:GetReversePercent())
            if frame.DruidMana then
                frame.DruidMana:SetReverseFill(ndb.settings.reverseUnitFrameBars)
            end
        end
    end

    function self.PostUpdate(frame, event)
        frame.endBox.Update(frame, event)
        frame.Health:PositionSteps("TOP")
        frame.Power:PositionSteps("BOTTOM")
    end
end

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = RealUI.db.profile

    local player = oUF:Spawn("player", "RealUIPlayerFrame")
    player:SetPoint("RIGHT", "RealUIPositionersUnitFrames", "LEFT", db.positions[UnitFrames.layoutSize].player.x, db.positions[UnitFrames.layoutSize].player.y)
    player:RegisterEvent("PLAYER_FLAGS_CHANGED", UnitFrames.UpdateStatus)
    player:RegisterEvent("UPDATE_SHAPESHIFT_FORM", player.PostUpdate)
end)
