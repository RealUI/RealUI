local _, private = ...

-- Lua Globals --
-- luacheck: globals ceil

-- Libs --
local oUF = private.oUF
local Base = _G.Aurora.Base
local Color = _G.Aurora.Color

-- RealUI --
local RealUI = private.RealUI
local db, ndb -- luacheck: ignore

local UnitFrames = RealUI:GetModule("UnitFrames")
local CombatFader = RealUI:GetModule("CombatFader")
local round = RealUI.Round

local function GetMiscDB()
    return (db and db.misc) or {}
end

local function GetUnitsDB()
    return (db and db.units) or {}
end

local function SafeShow(frame, show)
    if not frame then return end
    if _G.InCombatLockdown() and frame.IsProtected and frame:IsProtected() then
        _G.C_Timer.After(0, function()
            if show then frame:Show() else frame:Hide() end
        end)
    else
        if show then frame:Show() else frame:Hide() end
    end
end

-- Power types where the default state is empty
RealUI.ReversePowers = {
    ["RAGE"] = true,
    ["RUNIC_POWER"] = true,
    ["POWER_TYPE_SUN_POWER"] = true,
    ["LUNAR_POWER"] = true,
    ["INSANITY"] = true,
    ["MAELSTROM"] = true,
    ["FURY"] = true,
    ["PAIN"] = true,
}

local function GetReverseFill(unit, info)
    -- Natural fill direction based on bar side:
    -- Player (RIGHT side): natural=true → fill anchored RIGHT, grows right→left
    -- Target (LEFT side): natural=false → fill anchored LEFT, grows left→right
    local natural = false
    if info and info.point then
        natural = info.point == "RIGHT"
    end

    -- Per-unit toggle flips the natural direction
    local unitDB = db and db.units and db.units[unit]
    if unitDB and unitDB.reverseFill then
        return not natural
    end

    return natural
end

local function GetVertices(info, useOther)
    local side = info.point
    if useOther then
        side = side == "RIGHT" and "LEFT" or "RIGHT"
    end

    if side == "RIGHT" then
        return (info.rightVertex % 2) + 1, info.rightVertex
    else
        return info.leftVertex, (info.leftVertex % 2) + 3
    end
end

local function CreateHealthBar(parent, info, isAngled)
    local Health
    if isAngled then
        local width, height = parent:GetWidth(), parent:GetHeight()
        if db.units[parent.unit].healthHeight then
            height = round((height - 3) * db.units[parent.unit].healthHeight)
        end

        Health = parent:CreateAngle("StatusBar", nil, parent.overlay)
        Health:SetAngleVertex(info.leftVertex, info.rightVertex)
        Health:SetSize(width, height)
        Health:SetPoint("TOP"..info.point, parent)
        Health:SetReverseFill(GetReverseFill(parent.unit, info))

        -- Set initial bg color: red when alternative style is active
        -- Use a separate HealthBG StatusBar at the same frame level, with fill at BORDER layer
        -- (above Health's bg at BACKGROUND, below Health's fill at ARTWORK)
        if GetMiscDB().alternativeBarStyle then
            local HealthBG = parent:CreateAngle("StatusBar", nil, parent.overlay)
            HealthBG:SetAngleVertex(info.leftVertex, info.rightVertex)
            HealthBG:SetSize(width, height)
            HealthBG:SetPoint("TOP"..info.point, parent)
            HealthBG:SetReverseFill(GetReverseFill(parent.unit, info))
            HealthBG:SetFrameLevel(Health:GetFrameLevel())
            -- Hide HealthBG's own bg and borders
            HealthBG.bg:SetAlpha(0)
            HealthBG.top:Hide()
            HealthBG.bottom:Hide()
            HealthBG.left:Hide()
            HealthBG.right:Hide()
            -- Put fill at BORDER layer (between BACKGROUND and ARTWORK)
            HealthBG.fill:SetDrawLayer("BORDER")
            HealthBG:SetMinMaxValues(0, 1)
            HealthBG:SetValue(1)
            local unitsDB = GetUnitsDB()
            local hbDB = unitsDB[parent.unit] and unitsDB[parent.unit].healthBar
            local bgColor = (hbDB and hbDB.background) or {0.78, 0.15, 0.15}
            local bgOpacity = (hbDB and hbDB.backgroundOpacity) or 1.0
            HealthBG:SetStatusBarColor(bgColor[1], bgColor[2], bgColor[3], bgOpacity)
            parent.HealthBG = HealthBG
        end

        Health.PreUpdate = function(self)
            self:SetReverseFill(GetReverseFill(parent.unit, info))
        end

        -- Hook overlay alpha to hide HealthBG when faded (prevents red bleed-through)
        -- Delay activation until after CombatFader's initial setup completes
        if GetMiscDB().alternativeBarStyle then
            _G.C_Timer.After(1, function()
                _G.hooksecurefunc(parent.overlay, "SetAlpha", function(overlay, alpha)
                    if not GetMiscDB().alternativeBarStyle then return end
                    if not parent.HealthBG then return end
                    -- Hide only when deeply faded (below "hurt" threshold)
                    -- Target Selected = 0.75, so use 0.5 as threshold
                    if alpha < 0.5 then
                        parent.HealthBG:Hide()
                    else
                        parent.HealthBG:Show()
                    end
                end)
            end)
        end

        -- Health prediction sub-widgets
        local isReverse = GetReverseFill(parent.unit, info)

        local HealingAll = parent:CreateAngle("Prediction", nil, Health)
        HealingAll:SetPoint("TOP", Health)
        HealingAll:SetPoint("BOTTOM", Health)
        if isReverse then
            HealingAll:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT")
            HealingAll:SetReverseFill(true)
        else
            HealingAll:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT")
        end
        HealingAll:SetWidth(Health:GetWidth())
        HealingAll:SetStatusBarColor(0.0, 0.659, 0.608, 0.4)
        Health.HealingAll = HealingAll

        local DamageAbsorb = parent:CreateAngle("Prediction", nil, Health)
        DamageAbsorb:SetPoint("TOP", Health)
        DamageAbsorb:SetPoint("BOTTOM", Health)
        if isReverse then
            DamageAbsorb:SetPoint("RIGHT", HealingAll:GetStatusBarTexture(), "LEFT")
            DamageAbsorb:SetReverseFill(true)
        else
            DamageAbsorb:SetPoint("LEFT", HealingAll:GetStatusBarTexture(), "RIGHT")
        end
        DamageAbsorb:SetWidth(Health:GetWidth())
        DamageAbsorb:SetStatusBarColor(0.75, 0.75, 1.0, 0.35)
        Health.DamageAbsorb = DamageAbsorb

        local HealAbsorb = parent:CreateAngle("Prediction", nil, Health)
        HealAbsorb:SetPoint("TOP", Health)
        HealAbsorb:SetPoint("BOTTOM", Health)
        if isReverse then
            HealAbsorb:SetPoint("LEFT", Health:GetStatusBarTexture(), "LEFT")
        else
            HealAbsorb:SetPoint("RIGHT", Health:GetStatusBarTexture(), "RIGHT")
            HealAbsorb:SetReverseFill(true)
        end
        HealAbsorb:SetWidth(Health:GetWidth())
        HealAbsorb:SetStatusBarColor(0.6, 0.15, 0.15, 0.5)
        Health.HealAbsorb = HealAbsorb
    else
        Health = _G.CreateFrame("StatusBar", nil, parent.overlay)
        Health:SetPoint("TOPLEFT", parent)
        Health:SetPoint("BOTTOMRIGHT", parent, 0, 3)
        Health:SetStatusBarTexture(RealUI.textures.plain)

        Base.SetBackdrop(Health, Color.black, 1)
        Health:SetBackdropOption("offsets", {
            left = -1,
            right = -1,
            top = -1,
            bottom = -1,
        })
    end

    -- Tag health text using composed tag strings
    if info.text then
        Health.text = Health:CreateFontString(nil, "OVERLAY")
        if info.point then
            Health.text:SetPoint("BOTTOM"..info.point, Health, "TOP"..info.point, 2, 2)
        else
            Health.text:SetPoint("CENTER")
        end
        Health.text:SetFontObject("SystemFont_Shadow_Med1")
        local statusText = GetMiscDB().statusText
        parent:Tag(Health.text, UnitFrames.GetHealthTagString(statusText))
    end

    Health.barType = "health"
    local unitDB = GetUnitsDB()[parent.unit] or {}
    local hb = unitDB.healthBar or {}
    Health.colorClass = db.overlay.classColor or hb.colorForegroundByClass
    Health.colorTapping = true
    Health.colorDisconnected = true
    Health.colorHealth = not Health.colorClass
    Health.colorReaction = Health.colorClass

    parent.Health = Health

    -- For angled bars with alternative style: override oUF's UpdateColor to apply dark foreground
    if isAngled then
        Health.UpdateColor = function(self, event, unit)
            if not unit or self.unit ~= unit then return end
            local element = self.Health
            if not element then return end

            if GetMiscDB().alternativeBarStyle then
                -- Alternative style: dark foreground, red bg shows through missing health
                local unitSettings = GetUnitsDB()[unit] or {}
                local healthBarDB = unitSettings.healthBar or {}
                local c = healthBarDB.foreground or {0.08, 0.08, 0.08}
                element:SetStatusBarColor(c[1], c[2], c[3], 1.0)
            else
                -- Default oUF color logic
                local color
                if element.colorDisconnected and not _G.UnitIsConnected(unit) then
                    color = self.colors.disconnected
                elseif element.colorTapping and not _G.UnitPlayerControlled(unit) and _G.UnitIsTapDenied(unit) then
                    color = self.colors.tapped
                elseif element.colorClass and (_G.UnitIsPlayer(unit) or _G.UnitInPartyIsAI(unit)) then
                    local _, class = _G.UnitClass(unit)
                    color = self.colors.class[class]
                elseif element.colorReaction and _G.UnitReaction(unit, "player") then
                    color = self.colors.reaction[_G.UnitReaction(unit, "player")]
                elseif element.colorHealth then
                    color = self.colors.health
                end
                if color then
                    element:SetStatusBarColor(color:GetRGB())
                end
            end
        end
    end
end


local CreateHealthStatus do
    local classification = {
        rareelite = {r=1, g=0.5, b=0},
        elite = {r=1, g=1, b=0},
        rare = {r=0.75, g=0.75, b=0.75},
    }

    local function UpdatePvP(self, event, unit)
        local PvPIndicator = self.PvPIndicator
        if _G.UnitIsPVP(unit) then
            local reaction = _G.UnitReaction(unit, "player")
            if not reaction then
                reaction = _G.UnitIsFriend(unit, "player") and 5 or 2
            end
            local color = self.colors.reaction[reaction]
            PvPIndicator:SetBackgroundColor(color[1], color[2], color[3], color[4])
        else
            PvPIndicator:SetBackgroundColor(_G.Aurora.Color.frame:GetRGBA())
        end
    end
    local function UpdateClassification(self, event)
        local color = classification[_G.UnitClassification(self.unit)] or _G.Aurora.Color.frame
        self.Classification:SetBackgroundColor(color.r, color.g, color.b, color.a)
    end

    function CreateHealthStatus(parent, info, isAngled)
        local PvPIndicator
        if isAngled then
            local leftVertex, rightVertex = GetVertices(info)
            local width, height = 4, _G.ceil(parent.Health:GetHeight() * 0.65)
            PvPIndicator = parent:CreateAngle("Frame", nil, parent.Health)
            PvPIndicator:SetSize(width, height)
            PvPIndicator:SetPoint("TOP"..info.point, parent.Health, info.point == "RIGHT" and -8 or 8, 0)
            PvPIndicator:SetAngleVertex(leftVertex, rightVertex)

            PvPIndicator.Override = UpdatePvP

            if not (parent.unit == "player" or parent.unit == "pet") then
                local class = parent:CreateAngle("Frame", nil, parent.Health)
                class:SetSize(width, height)
                class:SetPoint("TOP"..info.point, parent.Health, info.point == "RIGHT" and -16 or 16, 0)
                class:SetAngleVertex(leftVertex, rightVertex)

                class.Update = UpdateClassification
                parent.Classification = class
                parent:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", UpdateClassification)
            end
        else
            PvPIndicator = parent.overlay:CreateTexture(nil, 'ARTWORK', nil, 1)
            PvPIndicator:SetSize(16, 16)
            PvPIndicator:SetPoint('RIGHT', parent.overlay, 'LEFT')
        end
        parent.PvPIndicator = PvPIndicator
    end
end


local function CreatePowerBar(parent, info, isAngled)
    local Power
    if isAngled then
        local width, height = round(parent:GetWidth() * 0.9), round((parent:GetHeight() - 3) * (1 - db.units[parent.unit].healthHeight))
        local xOffset = parent.Health:GetHeight() - height

        Power = parent:CreateAngle("StatusBar", nil, parent.overlay)
        Power:SetSize(width, height)
        Power:SetPoint("BOTTOM"..info.point, parent, info.point == "RIGHT" and -xOffset or xOffset, 0)
        Power:SetAngleVertex(info.leftVertex, info.rightVertex)
        Power:SetReverseFill(GetReverseFill(parent.unit, info))
    else
        Power = _G.CreateFrame("StatusBar", nil, parent.overlay)
        Power:SetPoint("TOPLEFT", parent.Health, "BOTTOMLEFT", 0, -1)
        Power:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
        Power:SetStatusBarTexture(RealUI.textures.plain)

        Base.SetBackdrop(Power, Color.black, 1)
        Power:SetBackdropOption("offsets", {
            left = -1,
            right = -1,
            top = -1,
            bottom = -1,
        })
    end

    -- Tag power text using composed tag strings
    if info.text then
        Power.text = Power:CreateFontString(nil, "OVERLAY")
        if info.point then
            Power.text:SetPoint("TOP"..info.point, Power, "BOTTOM"..info.point, 2, -3)
        else
            Power.text:SetPoint("CENTER")
        end
        Power.text:SetFontObject("SystemFont_Shadow_Med1")
        local statusText = GetMiscDB().statusText
        local _, powerType = _G.UnitPowerType(parent.unit)
        parent:Tag(Power.text, UnitFrames.GetPowerTagString(statusText, powerType))
    end

    Power.barType = "power"
    Power.colorPower = true
    Power.frequentUpdates = true

    parent.Power = Power
end


local CreatePowerStatus do
    local status = {
        afk = {1, 1, 0},
        offline = oUF.colors.disconnected,
        leader = {0, 1, 1},
        combat = {1, 0, 0},
        resting = {0, 1, 0},
    }
    local function UpdateStatus(self, event)
        local unit = self.unit
        local isConnected = _G.UnitIsConnected(unit)
        local isLeader = _G.UnitIsGroupLeader(unit)
        local inCombat = _G.UnitAffectingCombat(unit)
        local isResting = _G.IsResting()

        -- UnitIsAFK can return a secret boolean in tainted execution contexts;
        -- check with issecretvalue before testing it
        local isAFK = _G.UnitIsAFK(unit)
        if _G.issecretvalue(isAFK) then isAFK = false end

        if isAFK then
            self.LeaderIndicator.status = "afk"
        elseif not isConnected then
            self.LeaderIndicator.status = "offline"
        elseif isLeader then
            self.LeaderIndicator.status = "leader"
        else
            self.LeaderIndicator.status = false
        end

        if self.LeaderIndicator.status then
            local color = status[self.LeaderIndicator.status]
            self.LeaderIndicator:SetBackgroundColor(color[1], color[2], color[3], color[4])
            SafeShow(self.LeaderIndicator, true)
        else
            SafeShow(self.LeaderIndicator, false)
        end

        if inCombat then
            self.CombatIndicator.status = "combat"
        elseif isResting then
            self.CombatIndicator.status = "resting"
        else
            self.CombatIndicator.status = false
        end

        if self.LeaderIndicator.status and not self.CombatIndicator.status then
            self.CombatIndicator:SetBackgroundColor(_G.Aurora.Color.frame:GetRGBA())
            SafeShow(self.CombatIndicator, true)
        elseif self.CombatIndicator.status then
            local color = status[self.CombatIndicator.status]
            self.CombatIndicator:SetBackgroundColor(color[1], color[2], color[3], color[4])
            SafeShow(self.CombatIndicator, true)
        else
            SafeShow(self.CombatIndicator, false)
        end
    end

    function CreatePowerStatus(parent, data)
        local point, anchor, relPoint, x, info
        if data.power then
            info, anchor = data.power, parent.Power
        else
            info, anchor = data.health, parent.Health
        end
        if info.point == "LEFT" then
            point, relPoint, x = "TOPLEFT", "TOPRIGHT", -8
        else
            point, relPoint, x = "TOPRIGHT", "TOPLEFT", 8
        end
        local leftVertex, rightVertex = GetVertices(info, not data.isBig)
        local width, height = 4, anchor:GetHeight()

        local CombatRest = parent:CreateAngle("Frame", nil, anchor)
        CombatRest:SetSize(width, height)
        CombatRest:SetPoint(point, anchor, relPoint, x, 0)
        CombatRest:SetAngleVertex(leftVertex, rightVertex)
        CombatRest.Override = UpdateStatus
        parent.CombatIndicator = CombatRest
        parent.RestingIndicator = CombatRest

        local LeaderAFK = parent:CreateAngle("Frame", nil, anchor)
        LeaderAFK:SetSize(width, height)
        LeaderAFK:SetPoint(point, CombatRest, relPoint, x, 0)
        LeaderAFK:SetAngleVertex(leftVertex, rightVertex)
        LeaderAFK.Override = UpdateStatus
        parent.LeaderIndicator = LeaderAFK
        parent.AwayIndicator = LeaderAFK
    end
end


local CreateEndBox do
    local function UpdateEndBox(self, ...)
        local unit = self.unit
        local isPlayer = _G.UnitIsPlayer(unit)
        local isPlayerControlled = _G.UnitPlayerControlled(unit)
        local isTapDenied = _G.UnitIsTapDenied(unit)

        local color
        if isPlayer or (isPlayerControlled and not isPlayer) then
            local _, classToken = _G.UnitClass(unit)
            color = self.colors.class[classToken]
        elseif not isPlayerControlled and isTapDenied then
            color = self.colors.tapped
        elseif _G.UnitReaction(unit, "player") then
            color = self.colors.reaction[_G.UnitReaction(unit, "player")]
        else
            color = self.colors.selection[_G.UnitSelectionType(unit, true)]
        end

        for i = 1, #self.EndBox do
            self.EndBox[i]:SetBackgroundColor(color[1], color[2], color[3], 1)
        end
    end
    function CreateEndBox(parent, data)
        local height = parent.Health:GetHeight()
        local boxHeight = height + (data.isBig and 2 or 0)
        local boxWidth = data.isBig and 6 or 4
        local point, relPoint, x
        if data.health.point == "RIGHT" then
            point, relPoint, x = "TOPLEFT", "TOPRIGHT", -(height - 2)
        else
            point, relPoint, x = "TOPRIGHT", "TOPLEFT", (height - 2)
        end
        parent.EndBox = {
            Update = UpdateEndBox
        }

        local healthBox = parent:CreateAngle("Frame", nil, parent.Health)
        healthBox:SetSize(boxWidth, boxHeight)
        healthBox:SetPoint(point, parent.Health, relPoint, x, 0)
        healthBox:SetAngleVertex(GetVertices(data.health))
        parent.EndBox[1] = healthBox

        if data.isBig then
            height = parent.Power:GetHeight()
            boxHeight = height + 2
            boxWidth = data.isBig and 6 or 4
            if data.power.point == "RIGHT" then
                point, relPoint, x = "BOTTOMLEFT", "BOTTOMRIGHT", -(height - 2)
            else
                point, relPoint, x = "BOTTOMRIGHT", "BOTTOMLEFT", (height - 2)
            end
            local powerBox = parent:CreateAngle("Frame", nil, parent.Power)
            powerBox:SetSize(boxWidth, boxHeight)
            powerBox:SetPoint(point, parent.Power, relPoint, x, 0)
            powerBox:SetAngleVertex(GetVertices(data.power))
            parent.EndBox[2] = powerBox

            -- hide the line between the two boxes
            SafeShow(healthBox.bottom, false)
            SafeShow(powerBox.top, false)
        end
    end
end


-- Init
local function Shared(self, unit)
    unit = unit:match("(%a+)%d*")
    UnitFrames:debug("Shared", self, self.unit, unit)

    self:SetScript("OnEnter", _G.UnitFrame_OnEnter)
    self:SetScript("OnLeave", _G.UnitFrame_OnLeave)
    self:RegisterForClicks("AnyUp")

    local misc = GetMiscDB()
    if misc.focusclick then
        local ModKey = misc.focuskey or "SHIFT"
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
    self.overlay = _G.CreateFrame("Frame", nil, self)
    self.overlay:SetFrameStrata("BACKGROUND")
    self.overlay:EnableMouse(false)
    CombatFader:RegisterFrameForFade("UnitFrames", self.overlay)

    local unitData = UnitFrames[unit]
    local unitDB = db.units[unit]
    local sizeMod = UnitFrames.layoutSize == 1 and 0.85 or 1

    local width, height = round(unitDB.size.x * sizeMod), round(unitDB.size.y * sizeMod)
    local isAngled = unitData.health and unitData.health.leftVertex and unitData.health.rightVertex

    if isAngled then
        self:SetSize(width, height)
    else
        -- Account for backdrop borders
        self:SetSize(width - 2, height - 2)
    end
    unitData.nameLength = ceil(width / 10)

    if unitData.health then
        CreateHealthBar(self, unitData.health, isAngled)
        CreateHealthStatus(self, unitData.health, isAngled)
    end

    if unitData.power then
        CreatePowerBar(self, unitData.power, isAngled)
    end

    if isAngled then
        CreatePowerStatus(self, unitData)
        CreateEndBox(self, unitData)
    end

    unitData.create(self)

    -- Create CastBars for units that had them before the rewrite
    if (unit == "player" or unit == "target" or unit == "focus") and RealUI:GetModuleEnabled("CastBars") then
        RealUI:GetModule("CastBars"):CreateCastBars(self, unit, unitData)
    end

    function self.PreUpdate(frame, event)
        if isAngled then
            frame.Health:SetSmooth(false)
            if frame.Power then
                frame.Power:SetSmooth(false)
            end
        end

        if unitData.PreUpdate then
            unitData.PreUpdate(frame, event)
        end
    end

    function self.PostUpdate(frame, event)
        if isAngled then
            frame.Health:SetSmooth(true)
            if frame.Power then
                frame.Power:SetSmooth(true)
            end
            frame.EndBox.Update(frame, event)
        end

        if frame.Classification then
            frame.Classification.Update(frame, event)
        end
        if unitData.PostUpdate then
            unitData.PostUpdate(frame, event)
        end
    end

    -- Deferred color kick: the native StatusBar engine for secret values (player
    -- health/power) needs one frame to initialize before colors stick. Force an
    -- oUF update after the first render so bars aren't grey on reload.
    -- Also ensures PostUpdateColor fires for alternative bar style on all units.
    _G.C_Timer.After(0, function()
        if self.Health then self.Health:ForceUpdate() end
        if self.Power then self.Power:ForceUpdate() end
    end)
end

function UnitFrames:InitializeLayout()
    db = UnitFrames.db.profile
    ndb = RealUI.db.profile
    oUF:RegisterStyle("RealUI", Shared)
    oUF:Factory(function(...)
        oUF:SetActiveStyle("RealUI")
        for i = 1, #UnitFrames.units do
            UnitFrames.units[i]()
        end
    end)
end
