local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "ClassResource_EclipseBar"
local EclipseBar = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

local ClassResourceBar = nibRealUI:GetModule("ClassResourceBar")

-------------------------
---- Eclipse Updates ----
-------------------------
local retval = {}
local spellIDs = {
    [ECLIPSE_BAR_SOLAR_BUFF_ID] = 1,
    [ECLIPSE_BAR_LUNAR_BUFF_ID] = 2,
}
local function HasEclipseBuffs()
    retval[1] = false
    retval[2] = false

    local i = 1
    local name, _, texture, applications, _, _, _, _, _, _, auraID = UnitAura("player", i)
    while name do
        if spellIDs[auraID] then
            retval[spellIDs[auraID]] = applications == 0 and true or applications
            break
        end

        i = i + 1
        name, _, texture, applications, _, _, _, _, _, _, auraID = UnitAura("player", i)
    end

    return retval
end

function EclipseBar:OnUpdate(event, unit, powerType)
    --print("EclipseBar:OnUpdate", unit, powerType)
    if unit ~= "player" or powerType ~= "ECLIPSE" then return end
    -- Power Text
    local power = UnitPower("player", SPELL_POWER_ECLIPSE)
    local maxPower = UnitPowerMax("player", SPELL_POWER_ECLIPSE)
    --print("EclipseBar:Power", power, maxPower)
    
    if maxPower <= 0 or power > maxPower then
        return
    end

    --local status = GetEclipseDirection()
    if self.direction == "sun" then
        --print("EclipseBar:Sun", power)

        if power > 0 then
            self.eBar:SetValue("left", 0)
            self.eBar:SetValue("right", power / 100)
        else
            self.eBar:SetValue("right", 0)
            self.eBar:SetValue("left", 0)
            self:ECLIPSE_DIRECTION_CHANGE(event, GetEclipseDirection())
        end

    elseif self.direction == "moon" then
        --print("EclipseBar:Moon", power)

        if power < 0 then
            self.eBar:SetValue("left", abs(power / 100))
            self.eBar:SetValue("right", 0)
        else
            self.eBar:SetValue("right", 0)
            self.eBar:SetValue("left", 0)
            self:ECLIPSE_DIRECTION_CHANGE(event, GetEclipseDirection())
        end

    else
        --print("EclipseBar:None", power)

        self.eBar:SetValue("left", 0)
        self.eBar:SetValue("right", 0)
        self:ECLIPSE_DIRECTION_CHANGE(event, GetEclipseDirection())
    end

    self.eBar:SetText("middle", abs(power))
end

function EclipseBar:UpdateAuras(units)
    if units and not(units.player) then return end

    -- Middle Arrow colors
    if self.direction == "sun" then
        self.eBar:SetBoxColor("middle", nibRealUI.media.colors.orange)

    elseif self.direction == "moon" then
        self.eBar:SetBoxColor("middle", nibRealUI.media.colors.blue)

    else
        self.eBar:SetBoxColor("middle", {0.2, 0.2, 0.2, 1})
    end
end

function EclipseBar:ECLIPSE_DIRECTION_CHANGE(event, ...)
    --print("EclipseBar", event, ...)
    self.direction = ...

    -- End Box colors and Bar colors
    if self.direction == "sun" then
        self.eBar:SetBoxColor("right", nibRealUI.media.colors.orange)
        self.eBar:SetBoxColor("left", nibRealUI.media.background)
    elseif self.direction == "moon" then
        self.eBar:SetBoxColor("right", nibRealUI.media.background)
        self.eBar:SetBoxColor("left", nibRealUI.media.colors.blue)
    else
        self.eBar:SetBoxColor("right", nibRealUI.media.colors.orange)
        self.eBar:SetBoxColor("left", nibRealUI.media.colors.blue)
        self.eBar:ReverseBar("left", false)
        self.eBar:ReverseBar("right", false)
    end
end

--------------------
---- Visibility ----
--------------------
function EclipseBar:UpdateVisibility(event, unit)
    if unit and unit ~= "player" then return end

    if self.configMode then
        self.eBar:Show()
        return
    end

    local targetCondition = (UnitExists("target") and not(UnitIsDeadOrGhost("target"))) and (db.visibility.showHostile and (UnitIsEnemy("player", "target") or UnitCanAttack("player", "target")))
    local pvpCondition = db.visibility.showPvP and self.inPvP
    local pveCondition = db.visibility.showPvE and self.inPvE
    local combatCondition = (db.visibility.showCombat and self.inCombat) or not(db.visibility.showCombat)

    local form = GetShapeshiftFormID()
    if ((not(form) or (form and (form == MOONKIN_FORM))) and (GetSpecialization() == 1) and not(UnitInVehicle("player")) and not(UnitIsDeadOrGhost("player"))) and 
        (targetCondition or combatCondition or pvpCondition or pveCondition) then
            self.eBar:Show()
    else
        self.eBar:Hide()
    end
end

function EclipseBar:PLAYER_REGEN_DISABLED(event, ...)
    --print("EclipseBar", event, ...)
    self.inCombat = true
    self:UpdateVisibility()
end

function EclipseBar:PLAYER_REGEN_ENABLED(event, ...)
    --print("EclipseBar", event, ...)
    self.inCombat = false
    self:UpdateVisibility()
end

function EclipseBar:UpdatePlayerLocation()
    local Inst, InstType = IsInInstance()
    if not(Inst and InstType) then
        self.inPvP = false
        self.inPvE = false
    elseif (InstType == "pvp") or (InstType == "arena") then
        self.inPvP = true
        self.inPvE = false
    elseif (InstType == "party") or (InstType == "raid") then
        self.inPvE = true
        self.inPvP = false
    end
end

function EclipseBar:PLAYER_ENTERING_WORLD(event, ...)
    --print("EclipseBar", event, ...)
    self:UpdatePlayerLocation()
    self:UpdateVisibility()
    self:UpdateAuras()
    self:OnUpdate(event, "player", "ECLIPSE")
end

-----------------------
---- Frame Updates ----
-----------------------
function EclipseBar:UpdateGlobalColors()
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    self:ECLIPSE_DIRECTION_CHANGE()
end

------------
function EclipseBar:ToggleConfigMode(val)
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    if self.configMode == val then return end

    self.configMode = val
    self:UpdateVisibility()
end

function EclipseBar:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            visibility = {
                showCombat = true,
                showHostile = true,
                showPvP = true,
                showPvE = false,
            },
        },
    })
    db = self.db.profile
    ndb = nibRealUI.db.profile
    
    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME) and nibRealUI.class == "DRUID")
    nibRealUI:RegisterConfigModeModule(self)
end

function EclipseBar:OnEnable()
    self.configMode = false

    if not self.eBar then 
        self.eBar = ClassResourceBar:New("short", L["Resource_Eclipse"])
    end

    local updateSpeed
    if nibRealUI.db.profile.settings.powerMode == 1 then
        updateSpeed = 1/8
    elseif nibRealUI.db.profile.settings.powerMode == 2 then
        updateSpeed = 1/5
    else
        updateSpeed = 1/10
    end

    -- Events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "UpdateVisibility")
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateVisibility")
    self:RegisterEvent("MASTERY_UPDATE", "UpdateVisibility")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateVisibility")
    self:RegisterEvent("PLAYER_UNGHOST", "UpdateVisibility")
    self:RegisterEvent("PLAYER_ALIVE", "UpdateVisibility")
    self:RegisterEvent("PLAYER_DEAD", "UpdateVisibility")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterBucketEvent("UNIT_AURA", updateSpeed, "UpdateAuras")
    self:RegisterEvent("UNIT_POWER_FREQUENT", "OnUpdate")
    --self:RegisterEvent("ECLIPSE_DIRECTION_CHANGE")
end

function EclipseBar:OnDisable()
    self:UnregisterAllEvents()
    self:UnregisterAllBuckets()
end
