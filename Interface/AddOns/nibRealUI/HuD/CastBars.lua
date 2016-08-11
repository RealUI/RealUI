local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local round = RealUI.Round
local db, ndb

local MODNAME = "CastBars"
local CastBars = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local layoutSize

local MaxTicks = 10
local ChannelingTicks = {}
do
    local function RegisterSpellName(spellID, numticks)
        local name = _G.GetSpellInfo(spellID)
        if name then
            ChannelingTicks[name] = numticks
        else
            _G.print("The spell for ID", spellID, "no longer exists.")
        end
    end

    -- Druid
    RegisterSpellName(740, 4) -- Tranquility

    -- Mage
    RegisterSpellName(5143, 5)  -- Arcane Missiles
    RegisterSpellName(12051, 3) -- Evocation

    -- Monk
    RegisterSpellName(117952, 4) -- Crackling Jade Lightning
    RegisterSpellName(191837, 2)  -- Essence Font
    RegisterSpellName(113656, 4) -- Fists of Fury

    -- Priest
    RegisterSpellName(64843, 4) -- Divine Hymn
    RegisterSpellName(15407, 3) -- Mind Flay
    RegisterSpellName(48045, 5) -- Mind Sear
    RegisterSpellName(47540, 2) -- Penance

    -- Warlock
    RegisterSpellName(689, 6)  -- Drain Life
    RegisterSpellName(755, 6)  -- Health Funnel
    RegisterSpellName(4629, 6) -- Rain of Fire
end

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
        self.tick[i]:SetPoint("TOPRIGHT", -(_G.floor(db.size[layoutSize].width * ((i - 1) / numTicks))), 0)
        self.tick[i]:Show()
    end
end

function CastBars:SetAnchors(castbar, unit)
    CastBars:debug("Set config cast", unit)

    local iconX, iconY = 3, -2
    local iconPoint, iconRelPoint = "TOP", "BOTTOM"
    if not db.text.textOnBottom then
        iconPoint, iconRelPoint = "BOTTOM", "TOP"
        iconY = -iconY
    end

    local textX, textY = 0, -2
    local textPoint, textRelPoint = "TOP", "TOP"
    local timePoint, timeRelPoint = "BOTTOM", "BOTTOM"

    castbar.Time:ClearAllPoints()
    castbar.Text:ClearAllPoints()
    castbar.Icon:ClearAllPoints()

    local horizPoint, horizRelPoint
    if unit == "player" then
        if db.text.textInside then
            castbar.Text:SetJustifyH("RIGHT")
            horizPoint, horizRelPoint = "RIGHT", "LEFT"
            iconX = -iconX
        else
            horizPoint, horizRelPoint = "LEFT", "RIGHT"
        end
        castbar.Text:SetJustifyH(horizPoint)
        castbar.Icon:SetPoint(iconPoint..horizPoint, castbar, iconRelPoint..horizPoint, iconX, iconY)
        castbar.Text:SetPoint(textPoint..horizPoint, castbar.Icon, textRelPoint..horizRelPoint, textX, textY)
        castbar.Time:SetPoint(timePoint..horizPoint, castbar.Icon, timeRelPoint..horizRelPoint, textX, textY)
    elseif unit == "target" then
        if db.text.textInside then
            horizPoint, horizRelPoint = "LEFT", "RIGHT"
        else
            horizPoint, horizRelPoint = "RIGHT", "LEFT"
            iconX = -iconX
        end
        castbar.Text:SetJustifyH(horizPoint)
        castbar.Icon:SetPoint(iconPoint..horizPoint, castbar, iconRelPoint..horizPoint, iconX, iconY)
        castbar.Text:SetPoint(textPoint..horizPoint, castbar.Icon, textRelPoint..horizRelPoint, textX, textY)
        castbar.Time:SetPoint(timePoint..horizPoint, castbar.Icon, timeRelPoint..horizRelPoint, textX, textY)
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

local frameInfo = {
    player = {
        leftAngle = [[\]],
        rightAngle = [[\]],
        smooth = false,
    },
    target = {
        leftAngle = [[/]],
        rightAngle = [[/]],
        smooth = false,
    },
    focus = {
        leftAngle = [[\]],
        rightAngle = [[/]],
        smooth = false,
    },
}

-- From oUF castbar
local updateSafeZone = function(self)
    local sz = self.safeZone
    local width = self:GetWidth()
    local _, _, _, ms = _G.GetNetStats()

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
    self:SetValue(0, true)

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
        self.Text:SetText(_G.SPELL_FAILED_INTERRUPTED)
        self.Text:SetTextColor(1, 0, 0, 1)
        self:SetStatusBarColor(1, 0, 0, 1)
        self:Show()
        self.flash:SetFromAlpha(self:GetAlpha())
        self.flash:SetToAlpha(0)
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
    self:SetValue(self.duration, true)

    local sz = self.safeZone
    sz:ClearAllPoints()
    if self:GetReverseFill() then
        sz:SetPoint("TOPRIGHT", self, -1, 0)
    else
        sz:SetPoint("TOPLEFT", self, 1, 0)
    end
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
    CastBars:debug("Cast status", self.casting, self.channeling, self.config)
    if (self.casting or self.config) then
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

function CastBars:CreateCastBars(unitFrame, unit)
    CastBars:debug("CreateCastBars", unit)
    local info, unitDB = frameInfo[unit], db[unit]
    local size, color = db.size[layoutSize], db.colors[unit]
    local width, height = size[unit] and size[unit].width or size.width, size[unit] and size[unit].height or size.height
    if not unitDB.debug then info.debug = nil end
    local Castbar = unitFrame:CreateAngleFrame("Status", width, height, unitFrame, info)
    Castbar:SetStatusBarColor(color[1], color[2], color[3], color[4])
    if db.reverse[unit] then
        Castbar:SetReverseFill(true)
    end

    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Castbar.Icon = Icon
    Icon:SetSize(unitDB.icon, unitDB.icon)
    _G.Aurora[1].ReskinIcon(Icon)

    local Text = Castbar:CreateFontString(nil, "OVERLAY")
    Castbar.Text = Text
    Text:SetFontObject(_G.RealUIFont_Pixel)

    local Time = Castbar:CreateFontString(nil, "OVERLAY")
    Castbar.Time = Time
    Time:SetFontObject(_G.RealUIFont_PixelNumbers)

    color = db.colors.latency
    local safeZone = unitFrame:CreateAngleFrame("Bar", width, height, Castbar, info)
    Castbar.safeZone = safeZone
    safeZone:SetValue(1, true)
    safeZone:SetStatusBarColor(color[1], color[2], color[3], color[4])

    if unit == "player" then
        CastBars:debug("Set positions", unit)
        Castbar:SetPoint("TOPRIGHT", _G.RealUIPositionersCastBarPlayer, "TOPRIGHT", 0, 0)

        Castbar.tick = {}
        for i = 1, MaxTicks do
            local tick = unitFrame:CreateAngleFrame("Bar", width, height, Castbar, info)
            tick:SetStatusBarColor(0, 0, 0, 0.5)
            tick:SetWidth(round(width * 0.08))
            tick:ClearAllPoints()
            Castbar.tick[i] = tick
        end
        Castbar.ClearTicks = CastBars.ClearTicks
        Castbar.SetBarTicks = CastBars.SetBarTicks
    elseif unit == "target" then
        CastBars:debug("Set positions", unit)
        Castbar:SetPoint("TOPLEFT", _G.RealUIPositionersCastBarTarget, "TOPLEFT", 0, 0)
    elseif unit == "focus" then
        CastBars:debug("Set positions", unit)
        Castbar:SetPoint("BOTTOMRIGHT", unitFrame, "TOPRIGHT", 5, 1)
    end
    CastBars:SetAnchors(Castbar, unit)

    local flashAnim = Castbar:CreateAnimationGroup()
    Castbar.flashAnim = flashAnim
    local function PostFlash(anim, ...)
        CastBars:debug("flashAnim:OnFinished", ...)
        Castbar:SetAlpha(1)
        Castbar.Text:SetTextColor(1, 1, 1, 1)
        Castbar:SetStatusBarColor(color[1], color[2], color[3], color[4])
        Castbar:Hide()
    end
    flashAnim:SetScript("OnFinished", PostFlash)
    flashAnim:SetScript("OnStop", PostFlash)

    local flash = flashAnim:CreateAnimation("Alpha")
    Castbar.flash = flash
    flash:SetDuration(1)
    flash:SetSmoothing("OUT")

    Castbar.PostCastStart = PostCastStart
    --Castbar.PostCastFailed = PostCastFailed
    Castbar.PostCastInterrupted = PostCastInterrupted
    Castbar.PostCastInterruptible = PostCastInterruptible
    Castbar.PostCastNotInterruptible = PostCastNotInterruptible
    --Castbar.PostCastDelayed = PostCastDelayed
    --Castbar.PostCastStop = PostCastStop

    Castbar.PostChannelStart = PostChannelStart
    --Castbar.PostChannelUpdate = PostChannelUpdate
    --Castbar.PostChannelStop = PostChannelStop

    Castbar.CustomDelayText = CustomDelayText
    Castbar.CustomTimeText = CustomTimeText

    Castbar.OnUpdate = OnUpdate

    unitFrame.Castbar = Castbar
    CastBars[unit] = Castbar
end

function CastBars:ToggleConfigMode(isConfigMode)
    if not RealUI:GetModuleEnabled(MODNAME) then return end
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
            castbar.Text:SetText(_G.SPELL_CASTING)
            castbar.Icon:SetTexture([[Interface\Icons\INV_Misc_Dice_02]])
            castbar.safeZone:Hide()

            -- We need to wait a bit for the game to register that we have a target and focus
            _G.C_Timer.After(0.2, function()
                castbar:Show()
                CastBars:debug("IsShown", unit, castbar:IsShown())
            end)
        end
    end
end

function CastBars:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
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
                debug = false
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
                debug = false
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
    ndb = RealUI.db.profile

    layoutSize = ndb.settings.hudSize

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    RealUI:RegisterConfigModeModule(self)
end

function CastBars:OnEnable()
    self.configMode = false
end

function CastBars:OnDisable()
    -- Enable default Cast Bars
    _G.CastingBarFrame:GetScript("OnLoad")(_G.CastingBarFrame)
    _G.PetCastingBarFrame:GetScript("OnLoad")(_G.PetCastingBarFrame)
end
