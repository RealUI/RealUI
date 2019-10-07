local _, private = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local db

local FramePoint = RealUI:GetModule("FramePoint")
local ASB = RealUI:GetModule("AngleStatusBar")

local MODNAME = "CastBars"
local CastBars = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local Aurora = _G.Aurora
local uninterruptible = Aurora.Color.Create(0.5, 0.0, 0.0)
local interruptible = Aurora.Color.Create(0.5, 1.0, 1.0)

local castbarSizes = {
    player = {
        x = 230,
        y = 8,
        icon = 28,
    },
    target = {
        x = 230,
        y = 8,
        icon = 28,
    },
    focus = {
        x = 126,
        y = 5,
        icon = 16,
    },
}

local ChannelingTicks = {}
do
    local function RegisterSpellName(spellID, numticks, isInstant)
        local name = _G.GetSpellInfo(spellID)
        if name then
            ChannelingTicks[name] = {
                id = spellID,
                ticks = numticks,
                isInstant = isInstant
            }
        else
            _G.print("The spell for ID", spellID, "no longer exists.")
        end
    end

    -- RegisterSpellName(spellID, (duration / interval), isInstant)

    -- Druid
    RegisterSpellName(740, 8 / 2, true) -- Tranquility

    -- Mage
    RegisterSpellName(5143, 2 / 0.4, false)  -- Arcane Missiles
    RegisterSpellName(12051, 6 / 2, true)    -- Evocation

    -- Priest
    RegisterSpellName(15407, 3 / 0.75, false) -- Mind Flay

    -- Warlock
    RegisterSpellName(755, 6 / 1, false)      -- Health Funnel
end

function CastBars:SetBarTicks(tickInfo)
    CastBars:debug("SetBarTicks", tickInfo)
    if not tickInfo then return end
    local size = castbarSizes.player

    local numTicks = tickInfo.ticks
    local haste = _G.UnitSpellHaste("player") / 100 + 1
    numTicks = _G.floor(numTicks * haste + 0.5)
    for i = 1, numTicks do
        local xOfs
        if i == 1 and tickInfo.isInstant then
            xOfs = 0
        else
            xOfs = _G.floor((size.x * db.player.scale) * ((i - 1) / numTicks))
        end
        local tick = self.tickPool:Acquire()
        tick:SetPoint("TOPRIGHT", -xOfs, 0)
        tick:Show()
    end
end

function CastBars:UpdateSettings(unit)
    CastBars:debug("Set config cast", unit)
    local castbar = CastBars[unit]
    local unitDB = db[unit]
    local size = castbarSizes[unit]

    castbar:SetReverseFill(unitDB.reverse)
    castbar:SetSize(size.x * unitDB.scale, size.y * unitDB.scale)
    castbar.Icon:SetSize(size.icon * unitDB.scale, size.icon * unitDB.scale)

    if unit == "focus" then
        castbar.Icon:SetPoint("BOTTOMLEFT", castbar, "BOTTOMRIGHT", 2, 1)
        castbar.Text:SetPoint("BOTTOMRIGHT", castbar, "TOPRIGHT", 0, 2)
        castbar.Time:SetPoint("BOTTOMLEFT", castbar.Icon, "BOTTOMRIGHT", 2, 0)
    else
        local iconX, iconY
        local iconPoint, iconRelPoint

        local textX, textY
        local textPoint, textRelPoint
        local timePoint, timeRelPoint

        local setOnTop = unitDB.text:find("TOP")
        if setOnTop then
            iconY = 2
            iconPoint, iconRelPoint = "BOTTOM", "TOP"

            textY = 0
            textPoint = "BOTTOM"
            timePoint = "TOP"
        else
            iconY = -2
            iconPoint, iconRelPoint = "TOP", "BOTTOM"

            textY = 0
            textPoint = "TOP"
            timePoint = "BOTTOM"
        end

        local horizPoint
        local setOnLeft = unitDB.text:find("LEFT")
        if setOnLeft then
            horizPoint = "LEFT"

            iconX = 0
            iconPoint, iconRelPoint = iconPoint..horizPoint, iconRelPoint..horizPoint

            textX = 2
            textPoint, textRelPoint = textPoint..horizPoint, textPoint.."RIGHT"
            timePoint, timeRelPoint = timePoint..horizPoint, timePoint.."RIGHT"
        else
            horizPoint = "RIGHT"

            iconX = 0
            iconPoint, iconRelPoint = iconPoint..horizPoint, iconRelPoint..horizPoint

            textX = -2
            textPoint, textRelPoint = textPoint..horizPoint, textPoint.."LEFT"
            timePoint, timeRelPoint = timePoint..horizPoint, timePoint.."LEFT"
        end

        castbar.Text:SetJustifyH(horizPoint)

        castbar.Time:ClearAllPoints()
        castbar.Text:ClearAllPoints()
        castbar.Icon:ClearAllPoints()

        ASB:AttachFrame(castbar.Icon, iconPoint, castbar, iconRelPoint, iconX, iconY)
        castbar.Text:SetPoint(textPoint, castbar.Icon, textRelPoint, textX, textY)
        castbar.Time:SetPoint(timePoint, castbar.Icon, timeRelPoint, textX, textY)
    end
end

local function PostCastStart(self, unit, name)
    CastBars:debug("PostCastStart", unit, name)
    if self.flashAnim:IsPlaying() then
        self.flashAnim:Stop()
    end

    if self.notInterruptible then
        self:SetStatusBarColor(uninterruptible:GetRGB())
    else
        self:SetStatusBarColor(interruptible:GetRGB())
    end

    if self.tickPool then
        self.tickPool:ReleaseAll()
    end
end
--[==[
local function PostCastFailed(self, unit)
    CastBars:debug("PostCastFailed", unit)
end
]==]
local function PostCastInterrupted(self, unit)
    CastBars:debug("PostCastInterrupted", unit)
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
local function PostCastInterruptible(self, unit)
    CastBars:debug("PostCastInterruptible", unit)
    self:SetStatusBarColor(interruptible:GetRGB())
end
local function PostCastNotInterruptible(self, unit)
    CastBars:debug("PostCastNotInterruptible", unit)
    self:SetStatusBarColor(uninterruptible:GetRGB())
end
--[==[
local function PostCastDelayed(self, unit, name)
    CastBars:debug("PostCastDelayed", unit, name)
end
local function PostCastStop(self, unit, name)
    CastBars:debug("PostCastStop", unit, name)
end
]==]

local function PostChannelStart(self, unit, name)
    CastBars:debug("PostChannelStart", unit, name)
    if self.SetBarTicks then
        self.tickPool:ReleaseAll()
        self:SetBarTicks(ChannelingTicks[name])
    end
end
--[==[
local function PostChannelUpdate(self, unit, name)
    CastBars:debug("PostChannelUpdate", unit, name)
end
local function PostChannelStop(self, unit, name)
    CastBars:debug("PostChannelStop", unit, name)
end
]==]

local function CustomDelayText(self, duration)
    CastBars:debug("CustomDelayText", duration)
    self.Time:SetFormattedText("%.1f", duration)
end
local function CustomTimeText(self, duration)
    CastBars:debug("CustomTimeText", duration)
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

function CastBars:CreateCastBars(unitFrame, unit, unitData)
    self:debug("CreateCastBars", unit)
    local info, unitDB = unitData.power or unitData.health, db[unit]
    local size = castbarSizes[unit]

    unitFrame.Castbar = unitFrame:CreateAngle("StatusBar", nil, unitFrame)
    local Castbar = unitFrame.Castbar
    Castbar:SetAngleVertex(info.leftVertex, info.rightVertex)
    Castbar:SetStatusBarColor(interruptible:GetRGB())
    Castbar:SetSmooth(false)
    Castbar:SetReverseFill(unitDB.reverse)

    Castbar.Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Aurora.Base.CropIcon(Castbar.Icon, Castbar)

    Castbar.Text = Castbar:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1_Outline")
    Castbar.Time = Castbar:CreateFontString(nil, "OVERLAY", "NumberFont_Outline_Large")

    local SafeZone = unitFrame:CreateAngle("Texture", nil, Castbar)
    SafeZone:SetColorTexture(uninterruptible:GetRGB())
    SafeZone:SetSize(10, 10)
    Castbar.SafeZone = SafeZone

    if unit == "player" then
        Castbar.tickPool = _G.CreateObjectPool(function(pool)
            local tick = unitFrame:CreateAngle("Texture", nil, Castbar)
            tick:SetColorTexture(1, 1, 1, 0.5)
            tick:SetSize(2, size.y * unitDB.scale)
            return tick
        end, function(pool, tick)
            tick:ClearAllPoints()
            tick:Hide()
        end)
        Castbar.SetBarTicks = CastBars.SetBarTicks
    end

    local flashAnim = Castbar:CreateAnimationGroup()
    Castbar.flashAnim = flashAnim
    local function PostFlash(anim, ...)
        CastBars:debug("flashAnim:OnFinished", ...)
        Castbar:SetAlpha(1)
        Castbar.Text:SetTextColor(1, 1, 1, 1)
        Castbar:SetStatusBarColor(uninterruptible:GetRGB())
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
    self[unit] = Castbar
    self:UpdateSettings(unit)
    FramePoint:PositionFrame(self, Castbar, {"profile", unit, "position"})
end

local function OnDragStop(castbar)
    FramePoint.OnDragStop(castbar)
    _G.LibStub("AceConfigRegistry-3.0"):NotifyChange("HuD")
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
            castbar.SafeZone:Hide()

            -- We need to wait a bit for the game to register that we have a target and focus
            _G.C_Timer.After(0.2, function()
                castbar:Show()
                CastBars:debug("IsShown", unit, castbar:IsShown())
            end)
        end
    end
end

function CastBars:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    db = self.db.profile

    self:UpdateSettings("player")
    self:UpdateSettings("target")
    self:UpdateSettings("focus")
end

function CastBars:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            player = {
                position = {
                    point = "CENTER",
                    x = -121,
                    y = -141,
                },
                scale = 1,
                text = "BOTTOMRIGHT",
                reverse = true,
                debug = false
            },
            target = {
                position = {
                    point = "CENTER",
                    x = 121,
                    y = -141,
                },
                scale = 1,
                text = "BOTTOMLEFT",
                reverse = false,
                debug = false
            },
            focus = {
                position = {
                    point = "LEFT",
                    x = 432,
                    y = -72.5,
                },
                scale = 1,
                reverse = true,
                debug = false
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    FramePoint:RegisterMod(self, nil, OnDragStop)
end

function CastBars:OnEnable()
    self.configMode = false
end

function CastBars:OnDisable()
    -- Enable default Cast Bars
    _G.CastingBarFrame:GetScript("OnLoad")(_G.CastingBarFrame)
    _G.PetCastingBarFrame:GetScript("OnLoad")(_G.PetCastingBarFrame)
end
