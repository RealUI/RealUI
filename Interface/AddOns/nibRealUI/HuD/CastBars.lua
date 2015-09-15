local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = nibRealUI.L
local db, ndb

local MODNAME = "CastBars"
local CastBars = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local layoutSize
local round = nibRealUI.Round

local MaxTicks = 10
local ChannelingTicks = {
    -- Druid
    [GetSpellInfo(16914)] = 10, -- Hurricane
    [GetSpellInfo(106996)] = 10,-- Astral Storm
    [GetSpellInfo(740)] = 4,    -- Tranquility
    -- Mage
    [GetSpellInfo(5143)] = 5,   -- Arcane Missiles
    [GetSpellInfo(10)] = 8,     -- Blizzard
    [GetSpellInfo(12051)] = 3,  -- Evocation
    -- Monk
    [GetSpellInfo(117952)] = 4,  -- Crackling Jade Lightning
    [GetSpellInfo(115175)] = 8,  -- Soothing Mist
    [GetSpellInfo(115294)] = 6,  -- Mana Tea
    [GetSpellInfo(113656)] = 4,  -- Fists of Fury
    -- Priest
    [GetSpellInfo(64843)] = 4,  -- Divine Hymn
    [GetSpellInfo(15407)] = 3,  -- Mind Flay
    [GetSpellInfo(129197)] = 3, -- Mind Flay (Insanity)
    [GetSpellInfo(48045)] = 5,  -- Mind Sear
    [GetSpellInfo(47540)] = 2,  -- Penance
    -- Warlock
    [GetSpellInfo(689)] = 6,    -- Drain Life
    [GetSpellInfo(755)] = 6,    -- Health Funnel
    [GetSpellInfo(4629)] = 6,   -- Rain of Fire
    [GetSpellInfo(103103)] = 6, -- Drain Soul
    [GetSpellInfo(108371)] = 6, -- Harvest Life
}

local UpdateSpeed = 1/60

-- Chanelling Ticks
function CastBars:ClearTicks()
    CastBars:debug("ClearTicks")
    for i = 1, MaxTicks do
        self.tick[i]:Hide()
    end
end

function CastBars:SetBarTicks(numTicks)
    CastBars:debug("SetBarTicks", numTicks)
    if not numTicks then return end
    for i = 1, numTicks do
        self.tick[i]:SetPoint("TOPRIGHT", -(floor(db.size[layoutSize].width * ((i - 1) / numTicks))), 0)
        self.tick[i]:Show()
    end
end

function CastBars:SetAnchors(castbar, unit)
    CastBars:debug("Set config cast", unit)

    local xOfs, x, y = 0, 3, -2
    local iconPoint, iconRelPoint = "TOP", "BOTTOM"
    local textPoint, textRelPoint = "TOP", "TOP"
    local timePoint, timeRelPoint = "BOTTOM", "BOTTOM"
    if not db.text.textOnBottom then
        iconPoint, iconRelPoint = "BOTTOM", "TOP"
        y = -y
    end

    castbar.Time:ClearAllPoints()
    castbar.Text:ClearAllPoints()
    castbar.Icon:ClearAllPoints()

    local horizPoint, horizRelPoint
    if unit == "player" then
        if db.text.textInside then
            castbar.Text:SetJustifyH("RIGHT")
            horizPoint, horizRelPoint = "RIGHT", "LEFT"
            x = -x
        else
            horizPoint, horizRelPoint = "LEFT", "RIGHT"
            --xOfs = 4
        end
        castbar.Text:SetJustifyH(horizPoint)
        castbar.Icon:SetPoint(iconPoint..horizPoint, castbar, iconRelPoint..horizPoint, x, y)
        castbar.Text:SetPoint(textPoint..horizPoint, castbar.Icon, textRelPoint..horizRelPoint, xOfs, -2)
        castbar.Time:SetPoint(timePoint..horizPoint, castbar.Icon, timeRelPoint..horizRelPoint, xOfs, -2)
    elseif unit == "target" then
        if db.text.textInside then
            horizPoint, horizRelPoint = "LEFT", "RIGHT"
            --xOfs = 4
        else
            horizPoint, horizRelPoint = "RIGHT", "LEFT"
            x = -x
        end
        castbar.Text:SetJustifyH(horizPoint)
        castbar.Icon:SetPoint(iconPoint..horizPoint, castbar, iconRelPoint..horizPoint, x, y)
        castbar.Text:SetPoint(textPoint..horizPoint, castbar.Icon, textRelPoint..horizRelPoint, xOfs, -2)
        castbar.Time:SetPoint(timePoint..horizPoint, castbar.Icon, timeRelPoint..horizRelPoint, xOfs, -2)
    elseif unit == "focus" then
        castbar.Icon:SetPoint("BOTTOMLEFT", castbar, "BOTTOMRIGHT", 2, 1)
        castbar.Text:SetPoint("BOTTOMRIGHT", castbar, "TOPRIGHT", 0, 2)
        castbar.Time:SetPoint("BOTTOMLEFT", castbar.Icon, "BOTTOMRIGHT", 2, 0)
    end
end

function CastBars:UpdateAnchors()
    for _, unit in next, {"player", "target"} do
        self:SetAnchors(CastBars[unit], unit)
    end
end

local info = {
    player = {
        leftAngle = [[\]],
        rightAngle = [[\]],
        smooth = false,
        debug = "playerCast"
    },
    target = {
        leftAngle = [[/]],
        rightAngle = [[/]],
        smooth = false,
        debug = "targetCast"
    },
    focus = {
        leftAngle = [[\]],
        rightAngle = [[/]],
        smooth = false,
        debug = "focusCast"
    },
}

-- From oUF castbar
local updateSafeZone = function(self)
    local sz = self.safeZone
    local width = self:GetWidth()
    local _, _, _, ms = GetNetStats()

    -- Guard against GetNetStats returning latencies of 0.
    if (ms ~= 0) then
        -- MADNESS!
        local safeZonePercent = (width / self.max) * (ms / 1e5)
        CastBars:debug("updateSafeZone", safeZonePercent, ms)
        if (safeZonePercent > 1) then safeZonePercent = 1 end
        sz:SetWidth(width * safeZonePercent)
        sz:Show()
    else
        sz:Hide()
    end
end

local function PostCastStart(self, unit, ...)
    CastBars:debug("PostCastStart", unit, ...)
    if self.flashAnim:IsPlaying() then
        self.flashAnim:Stop()
    end

    if self.interrupt then
        local color = db.colors.uninterruptible
        self:SetStatusBarColor(color[1], color[2], color[3], color[4])
    else
        local color = db.colors[unit]
        self:SetStatusBarColor(color[1], color[2], color[3], color[4])
    end

    local sz = self.safeZone
    sz:ClearAllPoints()
    if self:GetReverseFill() then
        sz:SetPoint("TOPLEFT", self, 2, 0)
    else
        sz:SetPoint("TOPRIGHT", self, -2, 0)
    end
    updateSafeZone(self)

    if self.ClearTicks then
        self:ClearTicks()
    end
end
--[==[
local function PostCastFailed(self, unit, ...)
    CastBars:debug("PostCastFailed", unit, ...)
end
]==]
local function PostCastInterrupted(self, unit, ...)
    CastBars:debug("PostCastInterrupted", unit, ...)
    self.castid = nil
    if not self.flashAnim:IsPlaying() then
        CastBars:debug("PlayFlash")
        self.Time:SetText("")
        self.Text:SetText(SPELL_FAILED_INTERRUPTED)
        self.Text:SetTextColor(1, 0, 0, 1)
        self:SetStatusBarColor(1, 0, 0, 1)
        self:Show()
        self.flash:SetChange(-(self:GetAlpha()))
        self.flashAnim:Play()
    end
end
local function PostCastInterruptible(self, unit, ...)
    CastBars:debug("PostCastInterruptible", unit, ...)
    local color = db.colors[unit]
    self:SetStatusBarColor(color[1], color[2], color[3], color[4])
end
local function PostCastNotInterruptible(self, unit, ...)
    CastBars:debug("PostCastNotInterruptible", unit, ...)
    local color = db.colors.uninterruptible
    self:SetStatusBarColor(color[1], color[2], color[3], color[4])
end
--[==[
local function PostCastDelayed(self, unit, ...)
    CastBars:debug("PostCastDelayed", unit, ...)
end
local function PostCastStop(self, unit, ...)
    CastBars:debug("PostCastStop", unit, ...)
end
]==]

local function PostChannelStart(self, unit, spellName)
    CastBars:debug("PostChannelStart", unit, spellName)
    local sz = self.safeZone
    sz:ClearAllPoints()
    local point, x
    if self:GetReverseFill() then
        point, x = "TOPRIGHT", -1
    else
        point, x = "TOPLEFT", 1
    end
    sz:SetPoint(point, self, x, 0)
    updateSafeZone(self)

    if self.SetBarTicks then
        self:SetBarTicks(ChannelingTicks[spellName])
    end
end
--[==[
local function PostChannelUpdate(self, unit, ...)
    CastBars:debug("PostChannelUpdate", unit, ...)
end
local function PostChannelStop(self, unit, ...)
    CastBars:debug("PostChannelStop", unit, ...)
end
]==]

local function CustomDelayText(self, duration, ...)
    CastBars:debug("CustomDelayText", duration, ...)
    self.Time:SetFormattedText("%.1f", duration)
end
local function CustomTimeText(self, duration, ...)
    CastBars:debug("CustomTimeText", duration, ...)
    self.Time:SetFormattedText("%.1f", duration)
end

local function OnUpdate(self, elapsed)
    CastBars:debug("OnUpdate", self.__owner.unit, elapsed)
    if (self.casting or self.config) then
        CastBars:debug("Casting", self.config)
        local duration = self.duration + elapsed
        if (duration >= self.max) then
            CastBars:debug("Duration", duration, self.max)
            if self.config then
                duration = 0
            else
                self.casting = nil
                self:Hide()

                if (self.PostCastStop) then self:PostCastStop(self.__owner.unit) end
                return
            end
        end

        if (self.Time) then
            if(self.delay ~= 0) then
                if(self.CustomDelayText) then
                    self:CustomDelayText(duration)
                else
                    self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, self.delay)
                end
            else
                if(self.CustomTimeText) then
                    self:CustomTimeText(duration)
                else
                    self.Time:SetFormattedText("%.1f", duration)
                end
            end
        end

        self.duration = duration
        self:SetValue(duration)

        if (self.Spark) then
            self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
        end
    elseif (self.channeling) then
        local duration = self.duration - elapsed

        if (duration <= 0) then
            self.channeling = nil
            self:Hide()

            if (self.PostChannelStop) then self:PostChannelStop(self.__owner.unit) end
            return
        end

        if (self.Time) then
            if (self.delay ~= 0) then
                if (self.CustomDelayText) then
                    self:CustomDelayText(duration)
                else
                    self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, self.delay)
                end
            else
                if (self.CustomTimeText) then
                    self:CustomTimeText(duration)
                else
                    self.Time:SetFormattedText("%.1f", duration)
                end
            end
        end

        self.duration = duration
        self:SetValue(duration)
        if(self.Spark) then
            self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
        end
    elseif (self.flashAnim:IsPlaying()) then
        self:SetValue(self.max)
    else
        self.unitName = nil
        self.casting = nil
        self.castid = nil
        self.channeling = nil

        self:SetValue(1)
        self:Hide()
    end
end

function CastBars:CreateCastBars(self, unit)
    CastBars:debug("CreateCastBars", unit)
    local info, unitDB = info[unit], db[unit]
    local size, color = db.size[layoutSize], db.colors[unit]
    local width, height = size[unit] and size[unit].width or size.width, size[unit] and size[unit].height or size.height
    if not unitDB.debug then info.debug = nil end
    local Castbar = self:CreateAngleFrame("Status", width, height, self, info)
    Castbar:SetStatusBarColor(color[1], color[2], color[3], color[4])
    if db.reverse[unit] then
        Castbar:SetReverseFill(true)
    end

    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Castbar.Icon = Icon
    Icon:SetSize(unitDB.icon, unitDB.icon)
    Aurora[1].ReskinIcon(Icon)

    local Text = Castbar:CreateFontString(nil, "OVERLAY")
    Castbar.Text = Text
    Text:SetFontObject(RealUIFont_Pixel)

    local Time = Castbar:CreateFontString(nil, "OVERLAY")
    Castbar.Time = Time
    Time:SetFontObject(RealUIFont_PixelNumbers)

    local safeZone, color = self:CreateAngleFrame("Bar", width, height, Castbar, info), db.colors.latency
    Castbar.safeZone = safeZone
    safeZone:SetValue(1, true)
    safeZone:SetStatusBarColor(color[1], color[2], color[3], color[4])

    if unit == "player" then
        CastBars:debug("Set positions", unit)
        Castbar:SetPoint("TOPRIGHT", RealUIPositionersCastBarPlayer, "TOPRIGHT", 0, 0)

        Castbar.tick = {}
        for i = 1, MaxTicks do
            local tick = self:CreateAngleFrame("Bar", width, height, Castbar, info)
            tick:SetStatusBarColor(0, 0, 0, 0.5)
            tick:SetWidth(round(width * 0.08))
            tick:ClearAllPoints()
            Castbar.tick[i] = tick
        end
        Castbar.ClearTicks = CastBars.ClearTicks
        Castbar.SetBarTicks = CastBars.SetBarTicks
    elseif unit == "target" then
        CastBars:debug("Set positions", unit)
        Castbar:SetPoint("TOPLEFT", RealUIPositionersCastBarTarget, "TOPLEFT", 0, 0)
    elseif unit == "focus" then
        CastBars:debug("Set positions", unit)
        Castbar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 5, 1)
    end
    CastBars:SetAnchors(Castbar, unit)

    local flashAnim = Castbar:CreateAnimationGroup()
    Castbar.flashAnim = flashAnim
    flashAnim:SetScript("OnFinished", function(self, ...)
        CastBars:debug("flashAnim:OnFinished", ...)
        Castbar:SetAlpha(-(Castbar.flash:GetChange()))
        Castbar.Text:SetTextColor(1, 1, 1, 1)
        Castbar:SetStatusBarColor(color[1], color[2], color[3], color[4])
        Castbar:Hide()
    end)
    local flash = flashAnim:CreateAnimation("Alpha")
    Castbar.flash = flash
    flash:SetDuration(1)
    flash:SetSmoothing("OUT")

    Castbar.PostCastStart = PostCastStart
    Castbar.PostCastFailed = PostCastFailed
    Castbar.PostCastInterrupted = PostCastInterrupted
    Castbar.PostCastInterruptible = PostCastInterruptible
    Castbar.PostCastNotInterruptible = PostCastNotInterruptible
    Castbar.PostCastDelayed = PostCastDelayed
    Castbar.PostCastStop = PostCastStop

    Castbar.PostChannelStart = PostChannelStart
    --Castbar.PostChannelUpdate = PostChannelUpdate
    --Castbar.PostChannelStop = PostChannelStop

    Castbar.CustomDelayText = CustomDelayText
    Castbar.CustomTimeText = CustomTimeText

    Castbar.OnUpdate = OnUpdate

    self.Castbar = Castbar
    CastBars[unit] = Castbar
end

----------
function CastBars:SetUpdateSpeed()
    if ndb.settings.powerMode == 2 then -- Economy
        UpdateSpeed = 1/40
    else
        UpdateSpeed = 1/60
    end
end

function CastBars:ToggleConfigMode(isConfigMode)
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    if self.configMode == isConfigMode then return end
    CastBars:debug("ToggleConfigMode", isConfigMode)
    self.configMode = isConfigMode

    for _, unit in next, {"player", "target", "focus"} do
        CastBars:debug("Set config cast", unit)
        local castbar = CastBars[unit]
        castbar.config = isConfigMode
        if isConfigMode then
            CastBars:debug("Setup bar", castbar.__owner.unit, castbar.config)
            castbar.duration, castbar.max = 0, 10
            castbar:SetMinMaxValues(castbar.duration, castbar.max)
            castbar.Text:SetText(SPELL_CASTING)
            castbar.Icon:SetTexture([[Interface\Icons\INV_Misc_Dice_02]])
            castbar.safeZone:Hide()

            -- We need to wait a bit for the game to register that we have a target and focus
            C_Timer.After(0.2, function()
                castbar:Show()
                CastBars:debug("IsShown", unit, castbar:IsShown())
            end)
        end
    end
end

function CastBars:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            reverse = {
                player = true,
                target = false,
            },
            player = {
                size = {x = 230, y = 28},
                position = {x = 0, y = 0},
                icon = 28,
                debug = true
            },
            target = {
                size = {x = 230, y = 28},
                position = {x = 0, y = 0},
                icon = 28,
                debug = false
            },
            focus = {
                size = {x = 146, y = 28},
                position = {x = 0, y = 0},
                icon = 16,
                debug = true
            },
            size = {
                [1] = {
                    width = 200,
                    height = 6,
                    focus = {
                        width = 126,
                        height = 4,
                        x = 3,
                        y = 6,
                    },
                },
                [2] = {
                    width = 230,
                    height = 8,
                    focus = {
                        width = 146,
                        height = 5,
                        x = 4,
                        y = 7,
                    },
                },
            },
            colors = {
                useGlobal = true,
                player =            {0.15, 0.61, 1.00, 1},
                focus =             {1.00, 0.38, 0.08, 1},
                target =            {0.15, 0.61, 1.00, 1},
                uninterruptible =   {0.85, 0.14, 0.14, 1},
                latency =           {0.80, 0.13, 0.13, 1},
            },
            text = {
                textOnBottom = true,
                textInside = true,
            },
        },
    })
    db = self.db.profile
    ndb = nibRealUI.db.profile

    layoutSize = ndb.settings.hudSize

    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterConfigModeModule(self)
end

function CastBars:OnEnable()
    self.configMode = false
end

function CastBars:OnDisable()
    -- Enable default Cast Bars
    CastingBarFrame:GetScript("OnLoad")(CastingBarFrame)
    PetCastingBarFrame:GetScript("OnLoad")(PetCastingBarFrame)
end
