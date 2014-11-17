local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local db, ndb, ndbc

local oUF = oUFembed

UnitFrames.textures = {
    [1] = {
        F1 = { -- Player / Target Frames
            health = {
                width = 222,
                height = 13,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Step]=],
                warn = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Warning]=],
            },
            power = {
                width = 197,
                height = 8,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Step]=],
                warn = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Warning]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_HealthBox_Surround]=],
            },
            statusBox = { -- Combat, Resting, Leader, AFK
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_StatusBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_StatusBox_Surround]=],
            },
            endBox = { -- Tapped, Hostile, Friendly
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_EndBox_Surround]=],
            },
            tanking = {
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Tanking_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Tanking_Surround]=],
            },
            range = {
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Range_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Range_Surround]=],
            },
        },
        F2 = { -- Focus / Target Target
            health = {
                width = 116,
                height = 9,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Step]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_HealthBox_Surround]=],
            },
            statusBox = { -- Combat, Resting, Leader, AFK
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_StatusBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_StatusBox_Surround]=],
            },
            endBox = { -- Tapped, Hostile, Friendly
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_EndBox_Surround]=],
            },
        },
        F3 = { -- Focus Target / Pet
            health = {
                width = 105,
                height = 9,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Step]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_HealthBox_Surround]=],
            },
            endBox = { -- Tapped, Hostile, Friendly
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_EndBox_Surround]=],
            },
        },
    },
    [2] = {
        F1 = { -- Player / Target Frames
            health = {
                width = 259,
                height = 15,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Step]=],
                warn = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Warning]=],
            },
            power = {
                width = 230,
                height = 10,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Step]=],
                warn = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Warning]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_HealthBox_Surround]=],
            },
            statusBox = { -- Combat, Resting, Leader, AFK
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_StatusBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_StatusBox_Surround]=],
            },
            endBox = { -- Tapped, Hostile, Friendly
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_EndBox_Surround]=],
            },
            tanking = {
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Tanking_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Tanking_Surround]=],
            },
            range = {
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Range_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Range_Surround]=],
            },
        },
        F2 = { -- Focus / Target Target
            health = {
                width = 138,
                height = 10,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Step]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_HealthBox_Surround]=],
            },
            statusBox = { -- Combat, Resting, Leader, AFK
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_StatusBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_StatusBox_Surround]=],
            },
            endBox = { -- Tapped, Hostile, Friendly
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_EndBox_Surround]=],
            },
        },
        F3 = { -- Focus Target / Pet
            health = {
                width = 126,
                height = 10,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Step]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_HealthBox_Surround]=],
            },
            endBox = { -- Tapped, Hostile, Friendly
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_EndBox_Surround]=],
            },
        },
    },
}

UnitFrames.ReversePowers = {
    ["RAGE"] = true,
    ["RUNIC_POWER"] = true,
    ["POWER_TYPE_SUN_POWER"] = true,
}

local function updateSteps(unit, type, percent, frame)
    local stepPoints, texture = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"], nil
    local isLargeFrame = false
    if UnitInVehicle("player") then
        if unit == "player" and type == "power" then
            return
        end
        if unit == "vehicle" or unit == "target" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F1[type]
            isLargeFrame = true
        elseif unit == "focus" or unit == "targettarget" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F2[type]
        elseif unit == "focustarget" or unit == "pet" or unit == "player" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F3[type]
        end
    else
        if unit == "player" or unit == "target" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F1[type]
            isLargeFrame = true
        elseif unit == "focus" or unit == "targettarget" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F2[type]
        elseif unit == "focustarget" or unit == "pet" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F3[type]
        end
    end
    for i = 1, 2 do
        if frame.step then
            --print(percent, unit, type, frame:GetParent().unit)
            if frame.bar.reverse then
                --print("step reverse")
                if percent > stepPoints[i] and isLargeFrame then
                    frame.step[i]:SetAlpha(type == "power" and 0 or 1)
                    frame.warn[i]:SetAlpha(type == "power" and 1 or 0)
                else
                    frame.step[i]:SetAlpha(type == "power" and 1 or 0)
                    frame.warn[i]:SetAlpha(type == "power" and 0 or 1)
                end
            else
                --print("step normal")
                if percent < stepPoints[i] and isLargeFrame then
                    frame.step[i]:SetAlpha(0)
                    frame.warn[i]:SetAlpha(1)
                else
                    frame.step[i]:SetAlpha(1)
                    frame.warn[i]:SetAlpha(0)
                end
            end
        else
            --print(percent, unit, type, frame:GetParent().unit)
            if frame.bar.reverse then
                --print("step reverse")
                if percent > stepPoints[i] and isLargeFrame then
                    frame.steps[i]:SetTexture(type == "power" and texture.warn or texture.step)
                else
                    frame.steps[i]:SetTexture(type == "power" and texture.step or texture.warn)
                end
            else
                --print("step normal")
                if percent < stepPoints[i] and isLargeFrame then
                    frame.steps[i]:SetTexture(texture.warn)
                else
                    frame.steps[i]:SetTexture(texture.step)
                end
            end
        end
    end
end

function UnitFrames:HealthOverride(event, unit)
    --print("Health Override", self, event, unit)
    if event == "ClassColorBars" or event == "UpdateUnitFramesHealthColor" then
        UnitFrames:SetHealthColor(self)
    end
    local healthPer, healthCurr, healthMax = nibRealUI:GetSafeVals(UnitHealth(unit), UnitHealthMax(unit))
    updateSteps(unit, "health", healthPer, self.Health)
    if self.Health.info then
        self.Health:SetMinMaxValues(0, healthMax)
        self.Health:SetValue(healthCurr)
    else
        AngleStatusBar:SetValue(self.Health.bar, healthPer)
    end
end

function UnitFrames:PredictOverride(event, unit)
    --print("Predict Override", self, event, unit)
    local hp = self.HealPrediction
    local absorbBar = hp.absorbBar

    local healthPer, healthCurr, healthMax = nibRealUI:GetSafeVals(UnitHealth(unit), UnitHealthMax(unit))
    local absorbTotal = UnitGetTotalAbsorbs(unit)
    local absorbPer = math.min(absorbTotal, healthCurr) / healthMax

    if absorbBar.info then
        --print("Has Info")
        absorbBar:SetMinMaxValues(0, healthCurr)
        absorbBar:SetValue(absorbTotal)
    else
        AngleStatusBar:SetValue(hp.absorbBar, 1-absorbPer, true)
    end
    --print("absorb", absorbTotal, absorbPer, 1 - absorbPer)
    local atMax = (not(ndb.settings.reverseUnitFrameBars) and (healthCurr == healthMax))
    if unit == "player" then
        if atMax then
            absorbBar.bar:SetPoint("TOPRIGHT", self.Health, -2, -1)
        else
            absorbBar.bar:SetPoint("TOPRIGHT", self.Health.bar, "TOPLEFT", absorbBar.info.minWidth, 0)
        end
    else
        if atMax then
            absorbBar:SetPoint("TOPLEFT", self.Health, 2, -1)
        else
            absorbBar:SetPoint("TOPLEFT", self.Health.bar, "TOPRIGHT", 0, 0)
        end
    end
end

function UnitFrames:PowerOverride(event, unit, powerType)
    -- print("Power Override", self, event, unit, powerType)
    --if not self.Power.enabled then return end

    local powerPer = nibRealUI:GetSafeVals(UnitPower(unit), UnitPowerMax(unit))
    updateSteps(unit, "power", powerPer, self.Power)
    AngleStatusBar:SetValue(self.Power.bar, powerPer)
end

function UnitFrames:PvPOverride(event, unit)
    --print("PvP Override", self, event, unit, IsPVPTimerRunning())
    local color = nibRealUI.media.background
    if UnitIsPVP(unit) then
        if UnitIsFriend("player", unit) then
            --print("Friend")
            color = db.overlay.colors.status.pvpFriendly
            self.PvP:SetVertexColor(color[1], color[2], color[3], color[4])
        else
            --print("Enemy")
            color = db.overlay.colors.status.pvpEnemy
            self.PvP:SetVertexColor(color[1], color[2], color[3], color[4])
        end
    else
        self.PvP:SetVertexColor(color[1], color[2], color[3], color[4])
    end
end

function UnitFrames:UpdateClassification(event)
    --print("Classification", self.unit, event, UnitClassification(self.unit))
    local color = db.overlay.colors.status[UnitClassification(self.unit)] or nibRealUI.media.background
    self.Class:SetVertexColor(color[1], color[2], color[3], color[4])
end

function UnitFrames:UpdateStatus(event, ...)
    --print("UpdateStatus", self, event, ...)
    local unit = self.unit
    local color = nibRealUI.media.background
    if UnitIsAFK(unit) then
        --print("AFK", self, event, unit)
        color = db.overlay.colors.status.afk
        self.Leader.status = "afk"
    elseif not(UnitIsConnected(unit)) then
        --print("Offline", self, event, unit)
        color = db.overlay.colors.status.offline
        self.Leader.status = "offline"
    elseif UnitIsGroupLeader(unit) then
        --print("Leader", self, event, unit)
        color = db.overlay.colors.status.leader
        self.Leader.status = "leader"
    else
        --print("Status2: None", self, event, unit)
        self.Leader.status = false
    end
    if self.Leader.status then
        self.Leader:SetVertexColor(color[1], color[2], color[3], color[4])
        self.Leader:Show()
        self.AFK:Show()
    else
        self.Leader:Hide()
        self.AFK:Hide()
    end

    if UnitAffectingCombat(unit) then
        --print("Combat", self, event, unit)
        color = db.overlay.colors.status.combat
        self.Combat.status = "combat"
    elseif IsResting(unit) then
        --print("Resting", self, event, unit)
        color = db.overlay.colors.status.resting
        self.Combat.status = "resting"
    else
        --print("Status1: None", self, event, unit)
        self.Combat.status = false
    end
    if self.Leader.status and not self.Combat.status then
        self.Combat:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
        self.Combat:Show()
        self.Resting:Show()
    elseif self.Combat.status then
        self.Combat:SetVertexColor(color[1], color[2], color[3], color[4])
        self.Combat:Show()
        self.Resting:Show()
    else
        self.Combat:Hide()
        self.Resting:Hide()
    end
end

function UnitFrames:UpdateEndBox(...)
    --print("UpdateEndBox", self and self.unit, ...)
    local unit, color = self.unit, nil
    local _, class = UnitClass(unit)
    if UnitIsPlayer(unit) then
        color = nibRealUI:GetClassColor(class)
    else
        if ( not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) ) then
            color = db.overlay.colors.status.tapped
        elseif UnitIsEnemy("player", unit) then
            color = db.overlay.colors.status.hostile
        elseif UnitCanAttack("player", unit) then
            color = db.overlay.colors.status.neutral
        else
            color = db.overlay.colors.status.friendly
        end
    end
    self.endBox:Show()
    self.endBox:SetVertexColor(color[1], color[2], color[3], 1)
end

function UnitFrames:SetHealthColor(self)
    local healthColor
    if db.overlay.classColor and (self.unit ~= "player") and UnitIsPlayer(self.unit) then
        local _, class = UnitClass(self.unit)
        healthColor = nibRealUI:GetClassColor(class)
        healthColor = nibRealUI:ColorDarken(healthColor, 0.15)
        healthColor = nibRealUI:ColorDesaturate(healthColor, 0.2)
    else
        healthColor = db.overlay.colors.health.normal
    end
    AngleStatusBar:SetBarColor(self.Health.bar, healthColor)
end

-- Dropdown Menu
local dropdown = CreateFrame("Frame", "RealUIUnitFramesDropDown", UIParent, "UIDropDownMenuTemplate")

hooksecurefunc("UnitPopup_OnClick",function(self)
    local button = self.value
    if button == "SET_FOCUS" or button == "CLEAR_FOCUS" then
        if StaticPopup1 then
            StaticPopup1:Hide()
        end
        if db.misc.focusclick then
            nibRealUI:Notification("RealUI", true, "Use "..db.misc.focuskey.."+click to set Focus.", nil, [[Interface\AddOns\nibRealUI\Media\Icons\Notification_Alert]])
        end
    elseif button == "PET_DISMISS" then
        if StaticPopup1 then
            StaticPopup1:Hide()
        end
    end
end)
local function menu(self)
    dropdown:SetParent(self)
    return ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
end
local init = function(self)
    local unit = self:GetParent().unit
    local menu, name, id

    if (not unit) then
        return
    end

    if (UnitIsUnit(unit, "player")) then
        menu = "SELF"
    elseif (UnitIsUnit(unit, "vehicle")) then
        menu = "VEHICLE"
    elseif (UnitIsUnit(unit, "pet")) then
        menu = "PET"
    elseif (UnitIsPlayer(unit)) then
        id = UnitInRaid(unit)
        if(id) then
            menu = "RAID_PLAYER"
            name = GetRaidRosterInfo(id)
        elseif(UnitInParty(unit)) then
            menu = "PARTY"
        else
            menu = "PLAYER"
        end
    else
        menu = "TARGET"
        name = RAID_TARGET_ICON
    end

    if (menu) then
        UnitPopup_ShowMenu(self, menu, unit, name, id)
    end
end
UIDropDownMenu_Initialize(dropdown, init, "MENU")

-- Init
local function Shared(self, unit)
    --print("Shared", self, self.unit, unit)
    self.menu = menu

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:RegisterForClicks("AnyUp")

    if db.misc.focusclick then
        local ModKey = db.misc.focuskey
        local MouseButton = 1
        local key = ModKey .. "-type" .. (MouseButton or "")
        if(self.unit == "focus") then
            self:SetAttribute(key, "macro")
            self:SetAttribute("macrotext", "/clearfocus")
        else
            self:SetAttribute(key, "focus")
        end
    end

    -- Create a proxy frame for the CombatFader to avoid taint city.
    self.overlay = CreateFrame("Frame", nil, self)

    -- TODO: combine duplicate frame creation. eg healthbar, endbox, etc.
    UnitFrames[unit](self)
end

function UnitFrames:InitializeLayout()
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char

    oUF:RegisterStyle("RealUI", Shared)
    oUF:SetActiveStyle("RealUI")

    for i = 1, #UnitFrames.units do
        UnitFrames.units[i]()
    end
end

