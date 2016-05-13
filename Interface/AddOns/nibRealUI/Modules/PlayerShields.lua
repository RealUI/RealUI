local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, ndb

local SpiralBorder = RealUI:GetModule("SpiralBorder")

local MODNAME = "PlayerShields"
local PlayerShields = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local shields = {
    { -- Power Word: Shield
        spellID = 17,
        info = {},
        icon = [[Interface\ICONS\Spell_Holy_PowerWordShield]],
    },
    { -- Illuminated Healing
        spellID = 86273,
        info = {},
        icon = [[Interface\ICONS\Spell_Holy_Absolution]],
    },
    { -- Divine Aegis
        spellID = 47753,
        info = {},
        icon = [[Interface\ICONS\Spell_Holy_DevineAegis]],
    },
    { -- Spirit Shell
        spellID = 114908,
        info = {},
        icon = [[Interface\ICONS\Ability_Shaman_AstralShift]],
    },
    { -- Guard
        spellID = 115295,
        info = {},
        icon = [[Interface\ICONS\Ability_Monk_Guard]],
    },
}
local shieldIDs = {}
for i = 1, #shields do
    local shield = shields[i]
    _G.tinsert(shieldIDs, shield.spellID, shield)
    shieldIDs[shield.spellID].index = i
end

local tankSpecs = {
    ["DEATHKNIGHT"] = 1,
    ["DRUID"] = 3,
    ["MONK"] = 1,
    ["PALADIN"] = 2,
    ["WARRIOR"] = 3,
}

local function TimeFormat(t)
    local h, m, hplus, mplus, s, f

    h = _G.floor(t / 3600)
    m = _G.floor((t - (h * 3600)) / 60)
    s = _G.floor(t - (h * 3600) - (m * 60))

    hplus = _G.floor((t + 3599.99) / 3600)
    mplus = _G.floor((t - (h * 3600) + 59.99) / 60) -- provides compatibility with tooltips

    if t >= 3600 then
        f = ("%.0fh"):format(hplus)
    elseif t >= 60 then
        f = ("%.0fm"):format(mplus)
    else
        f = ("%.0fs"):format(s)
    end

    return f
end

function PlayerShields:CreateButton(i)
    local button = _G.CreateFrame("Frame", "RealUIPlayerShields"..i, self.psF)
        RealUI:CreateBDFrame(button)
        button:SetHeight(23)
        button:SetWidth(23)

    button.bg = button:CreateTexture(nil, "BACKGROUND")
        button.bg:SetAllPoints(button)
        button.bg:SetTexture(shields[i].icon)
        button.bg:SetTexCoord(.08, .92, .08, .92)

    button.absorbBar = _G.CreateFrame("StatusBar", nil, button)
        button.absorbBar:SetMinMaxValues(0, 1)
        button.absorbBar:SetValue(0)
        button.absorbBar:SetStatusBarTexture(RealUI.media.textures.plain)
        button.absorbBar:SetStatusBarColor(0, 0, 0, 0.75)
        button.absorbBar:SetReverseFill(true)
        button.absorbBar:SetAllPoints(button)
        button.absorbBar:SetFrameLevel(button:GetFrameLevel() + 1)

    button.timeStr = button:CreateFontString(nil, "OVERLAY")
        button.timeStr:SetFontObject(_G.RealUIFont_PixelSmall)
        button.timeStr:SetJustifyH("LEFT")
        button.timeStr:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0.5, 0.5)
        button.timeStr:SetParent(button.absorbBar)

    button.elapsed = 0
    button.interval = 1/4
    button:SetScript("OnUpdate", function(btn, elapsed)
        btn.elapsed = btn.elapsed + elapsed
        if btn.elapsed >= btn.interval then
            btn.elapsed = 0
            if btn.startTime and btn.endTime then
                btn.timeStr:SetText(TimeFormat(_G.ceil(btn.endTime - _G.GetTime())))
            else
                btn.timeStr:SetText()
            end
        end
    end)

    button:Show()

    return button
end

function PlayerShields:CreateFrames()
    self.psF = _G.CreateFrame("Frame", "RealUIPlayerShields", _G.UIParent)

    if _G[db.position.parent] then
        self.psF:SetParent(db.position.parent)
        self.psF:SetPoint(db.position.point, db.position.parent, db.position.rPoint, db.position.x, db.position.y)
    else
        _G.print(L["General_InvalidParent"]:format(MODNAME, "Modules", MODNAME))
    end
    self.psF:SetFrameStrata("MEDIUM")
    self.psF:SetFrameLevel(5)
    self.psF:SetSize(149, 1)

    self.psF.absorbTotal = 0

    for i = 1, #shields do
        self.psF[i] = self:CreateButton(i)
        self.psF[i]:Hide()
        self.psF[i].absorbAmount = 0
        self.psF[i].absorbMax = _G.math.huge
        self.psF[i].needMaxUpdate = true

        if i == 1 then
            self.psF[i]:SetPoint("BOTTOMRIGHT", self.psF, "BOTTOMRIGHT", 0, 0)
        else
            self.psF[i]:SetPoint("BOTTOMRIGHT", self.psF[i-1], "BOTTOMLEFT", -7, 0)
        end

        SpiralBorder:AttachSpiral(self.psF[i], -3, false)
    end

    self.psF.strTotal = self.psF:CreateFontString(nil, "OVERLAY")
        local font, size, outline = _G.RealUIFont_PixelSmall:GetFont()
        self.psF.strTotal:SetFont(font, size * 2, outline)
        self.psF.strTotal:SetJustifyH("RIGHT")
        self.psF.strTotal:SetPoint("BOTTOMRIGHT", self.psF, "BOTTOMLEFT", 2.5, -2.5)

    self.psF.strTotalPer = self.psF:CreateFontString(nil, "OVERLAY")
        self.psF.strTotalPer:SetFontObject(_G.RealUIFont_PixelSmall)
        self.psF.strTotalPer:SetJustifyH("RIGHT")
        self.psF.strTotalPer:SetPoint("TOPRIGHT", self.psF, "TOPLEFT", 2.5, -6.5)

    self.psF.visible = false

    if RealUI:GetModuleEnabled(MODNAME) then
        self:GroupUpdate()
    end
end

----
function PlayerShields:UpdateAbsorbDisplay()
    self.psF.absorbTotal = 0
    for i = 1, #shields do
        self.psF.absorbTotal = self.psF.absorbTotal + self.psF[i].absorbAmount
    end
    if self.psF.absorbTotal > 0 and self.psF.active then
        self.psF.strTotal:SetText(RealUI:ReadableNumber(self.psF.absorbTotal))
        self.psF.strTotalPer:SetFormattedText("%.0f%%", (self.psF.absorbTotal / _G.UnitHealthMax("player")) * 100)
        if not(self.psF.visible) then self:UpdateVisibility() end
    else
        self.psF.strTotal:SetText()
        self.psF.strTotalPer:SetText()
        if self.psF.active and self.psF.visible then self:UpdateVisibility() end
    end
end

local function GetShieldInfo()
    for i = 1, #shields do
        -- reset buff data
        shields[i].info = {}
    end
    for i = 1, 40 do
        local name,_,_,_,_, duration, expirationTime,_,_,_, spellID,_,_,_, absorb = _G.UnitAura("player", i)
        if not name then break end
        if shieldIDs[spellID] then
            PlayerShields:debug("GetShieldInfo", name, duration, expirationTime, absorb)
            shieldIDs[spellID].info = {name, duration, expirationTime, absorb}
        end
    end
end

function PlayerShields:AuraUpdate(units)
    if not self.psF.active then return end
    if not (units) or not (units.player) then return end

    GetShieldInfo()
    for i = 1, #shields do
        local shield = shields[i]
        local name, duration, expirationTime, absorb
        if shield.info then
            name, duration, expirationTime, absorb = shield.info[1], shield.info[2], shield.info[3], shield.info[4]
        end
        if name then
            -- Icon
            self.psF[i].bg:SetDesaturated(nil)
            self.psF[i].bg:SetVertexColor(1, 1, 1)

            -- Cooldown
            if expirationTime then
                self.psF[i].duration = duration
                self.psF[i].startTime = expirationTime - duration
                self.psF[i].offsetTime = 0
            else
                self.psF[i].duration = 0
                self.psF[i].startTime = 0
                self.psF[i].offsetTime = 0
                self.psF[i].endTime = nil
            end

            -- Absorb
            if absorb then
                if self.psF[i].needMaxUpdate then
                    self.psF[i].needMaxUpdate = false
                    self.psF[i].absorbMax = absorb
                    self.psF[i].absorbBar:SetMinMaxValues(0, absorb)
                end
                self.psF[i].absorbAmount = absorb
                self.psF[i].absorbBar:SetValue(self.psF[i].absorbMax - absorb)
                self.psF[i].absorbBar:Show()
            end

        else
            -- Icon
            self.psF[i].bg:SetDesaturated(1)
            self.psF[i].bg:SetVertexColor(0.8, 0.8, 0.8)

            -- Reset Cooldown
            self.psF[i].duration = 0
            self.psF[i].startTime = 0
            self.psF[i].offsetTime = 0
            self.psF[i].endTime = nil
        end
    end

    self:UpdateAbsorbDisplay()
end

function PlayerShields:UNIT_ABSORB_AMOUNT_CHANGED(_, unit)
    if not self.psF.active then return end
    if unit ~= "player" then return end

    self:AuraUpdate({player = true})
end

function PlayerShields:COMBAT_LOG_EVENT_UNFILTERED(_, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName, ...)
    if not self.psF.active then return end
    if destGUID ~= self.guid then return end

    local shield = shieldIDs[spellID]
    if event == "SPELL_AURA_REMOVED" then
        self:debug(event)
        if shield then
            self.psF[shield.index].absorbAmount = 0
            self.psF[shield.index].needMaxUpdate = true
            self.psF[shield.index].absorbBar:Hide()
            self:UpdateAbsorbDisplay()
        end

    elseif event == "SPELL_AURA_APPLIED" then
        if shield then
            self.psF[shield.index].needMaxUpdate = true
        end
    end
end

function PlayerShields:UpdateVisibility()
    local show
    if (db.show.onlySpec) and not (tankSpecs[RealUI.class] == (self.psF.spec)) or
            (db.show.onlyRole) and not (self.psF.tankRole) then
        show = false
    elseif (db.show.solo) or (db.show.pve and self.psF.pve) or (db.show.pvp and self.psF.pvp) then
        show = true
    end
    self.psF.active = show

    if (self.psF.absorbTotal <= 0) then show = false end

    if not (show) then
        if self.psF.visible then
            self.psF.visible = false
            self.psF:SetHeight(1)
            for i = 1, #shields do
                self.psF[i]:Hide()
            end
            self.psF.strTotal:SetText()
            self.psF.strTotalPer:SetText()
        end
    else
        if not(self.psF.visible) then
            self.psF.visible = true
            self.psF:SetHeight(31)
            for i = 1, #shields do
                self.psF[i]:Show()
            end
            self:AuraUpdate({player = true})
        end
    end

    self:ToggleRaven(self.psF.active)
end

function PlayerShields:RoleCheck()
    if  (_G.UnitGroupRolesAssigned("player") == "TANK") or _G.GetPartyAssignment("MAINTANK", "player") or
            _G.GetPartyAssignment("MAINASSIST", "player") then
        self.psF.tankRole = true
    else
        self.psF.tankRole = false
    end
end

function PlayerShields:GroupUpdate()
    self.psF.inGroup = _G.GetNumGroupMembers() > 0
    self:RoleCheck()
    self:UpdateVisibility()
end

function PlayerShields:SpecUpdate()
    self.psF.spec = _G.GetSpecialization() or 0
    self:UpdateVisibility()
end

function PlayerShields:PLAYER_ENTERING_WORLD()
    self.guid = _G.UnitGUID("player")

    local _, InstType = _G.IsInInstance()
    if (InstType == "pvp") or (InstType == "arena") then
        self.psF.pvp = true
    elseif (InstType == "party") or (InstType == "raid") then
        self.psF.pve = true
    else
        self.psF.pve = false
        self.psF.pvp = false
    end

    self:RoleCheck()
    self:UpdateVisibility()
end

function PlayerShields:PLAYER_LOGIN()
    self.guid = 0
    self:CreateFrames()

    if not RealUI:GetModuleEnabled(MODNAME) then return end

    local auraUpdateSpeed
    if ndb.settings.powerMode == 1 then
        auraUpdateSpeed = 0.5
    elseif ndb.settings.powerMode == 2 then
        auraUpdateSpeed = 1
    else
        auraUpdateSpeed = 0.25
    end
    self:RegisterBucketEvent("UNIT_AURA", auraUpdateSpeed, "AuraUpdate")
    self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 0.5, "GroupUpdate")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")

    self:SpecUpdate()
end

function PlayerShields:ToggleRaven(val)
    if _G.IsAddOnLoaded("Raven") and _G.RavenDB then
        if _G.RavenDB["global"]["SpellLists"]["PlayerExclusions"] then
            for i = 1, #shields do
                local shield = shields[i]
                _G.RavenDB["global"]["SpellLists"]["PlayerExclusions"]["#"..shield.spellID] = val
            end
        end
    end
end

----
function PlayerShields:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            show = {
                solo = false,
                pvp = true,
                pve = true,
                onlyRole = false,
                onlySpec = true,
            },
            position = {
                parent = "RealUIPlayerFrame",
                point = "BOTTOMRIGHT",
                rPoint = "TOPLEFT",
                x = -8,
                y = 5,
            },
        },
    })
    db = self.db.profile
    ndb = RealUI.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    self:RegisterEvent("PLAYER_LOGIN")
end

function PlayerShields:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "SpecUpdate")
end

function PlayerShields:OnDisable()
    self:UnregisterAllEvents()
    self:UnregisterAllBuckets()

    self:ToggleRaven(false)
end
