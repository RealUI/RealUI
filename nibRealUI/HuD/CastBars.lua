local _, private = ...

-- Lua Globals --
-- luacheck: globals assert next

-- RealUI --
local RealUI = private.RealUI
local db

local FramePoint = RealUI:GetModule("FramePoint")
local ASB = RealUI:GetModule("AngleStatusBar")

local MODNAME = "CastBars"
local CastBars = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local Aurora = _G.Aurora
local Color = Aurora.Color

local uninterruptible = Color.Create(0.5, 0.0, 0.0)
local interruptible = Color.Create(0.5, 1.0, 1.0)

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
    local spellNotFound = "The spell for ID %d no longer exists."
    local function RegisterSpellName(spellID, numticks, isInstant)
        assert(_G.GetSpellInfo(spellID), spellNotFound:format(spellID))

        ChannelingTicks[spellID] = {
            ticks = numticks,
            isInstant = isInstant
        }
    end

    -- RegisterSpellName(spellID, (duration / interval), isInstant)

    -- Death Knight
    RegisterSpellName(206931, 3 / 1, true) -- Blooddrinker

    -- Demon Hunter
    RegisterSpellName(198013, 2 / 2, true)    -- Eye Beam
    RegisterSpellName(211053, 2 / 0.25, true) -- Fel Barrage
    RegisterSpellName(212084, 2 / 0.2, true)  -- Fel Devastation

    -- Druid
    RegisterSpellName(740, 8 / 2, true) -- Tranquility

    -- Hunter
    RegisterSpellName(120360, 3 / 0.2, true) -- Barrage
    RegisterSpellName(212640, 6 / 1, false)  -- Mending Bandage

    -- Mage
    RegisterSpellName(5143, 2 / 0.4, false)  -- Arcane Missiles
    RegisterSpellName(12051, 6 / 2, true)    -- Evocation
    RegisterSpellName(205021, 10 / 1, false) -- Ray of Frost

    -- Monk
    RegisterSpellName(117952, 4 / 1, false)     -- Crackling Jade Lightning
    RegisterSpellName(191837, 3 / 1.002, false) -- Essence Font
    RegisterSpellName(113656, 4 / 1, true)      -- Fists of Fury
    RegisterSpellName(115175, 20 / 0.5, false)  -- Soothing Mist
    RegisterSpellName(101546, 1.5 / 0.5, true)  -- Spinning Crane Kick

    -- Priest
    RegisterSpellName(64843, 4 / 2, true)     -- Divine Hymn
    RegisterSpellName(15407, 3 / 0.75, false) -- Mind Flay
    RegisterSpellName(47540, 2 / 1, true)     -- Penance

    -- Shaman
    RegisterSpellName(204437, 6 / 1, false) -- Lightning Lasso

    -- Warlock
    RegisterSpellName(193440, 3 / 0.2, false) -- Demonfire
    RegisterSpellName(193440, 3 / 1, false)   -- Demonwrath
    RegisterSpellName(234153, 6 / 1, false)   -- Drain Life
    RegisterSpellName(198590, 6 / 1, false)   -- Drain Soul
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
        tick:SetSize(2, size.y * db.player.scale)
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

local function PlayFlash(anim)
    CastBars:debug("flashAnim:PlayFlash")
    anim.bar.Time:SetText("")
    anim.bar.Text:SetTextColor(anim.color:GetRGB())
    anim.bar:SetStatusBarColor(anim.color:GetRGB())

    anim.flash:SetFromAlpha(anim.bar:GetAlpha())
    anim.flash:SetToAlpha(0)
end
local function EndFlash(anim, ...)
    CastBars:debug("flashAnim:EndFlash", ...)
    anim.color = nil
    anim.bar:SetAlpha(1)
    anim.bar.Text:SetTextColor(1, 1, 1, 1)
    anim.bar:SetStatusBarColor(uninterruptible:GetRGB())
    anim.bar:Hide()
end

local function PostCastStart(self, unit)
    CastBars:debug("PostCastStart", unit)
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

        if self.channeling then
            self:SetBarTicks(ChannelingTicks[self.spellID])
        end
    end
end
--local function PostCastUpdate(self, unit)
--    CastBars:debug("PostCastUpdate", unit)
--end
local function PostCastStop(self, unit, spellID)
    CastBars:debug("PostCastStop", unit, spellID)
    self.holdTime = self.timeToHold
    self.Text:SetText(_G.SUCCESS)
    self:Show()
    self.flashAnim.color = Color.green
    self.flashAnim:Play()
end
local function PostCastFail(self, unit, spellID)
    CastBars:debug("PostCastFail", unit, spellID)
    self.flashAnim.color = Color.red
    self.flashAnim:Play()
end
local function PostCastInterruptible(self, unit)
    CastBars:debug("PostCastInterruptible", unit)
    if self.notInterruptible then
        self:SetStatusBarColor(uninterruptible:GetRGB())
    else
        self:SetStatusBarColor(interruptible:GetRGB())
    end
end


function CastBars:CreateCastBars(unitFrame, unit, unitData)
    self:debug("CreateCastBars", unit)
    local info, unitDB = unitData.power or unitData.health, db[unit]

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
            return tick
        end, function(pool, tick)
            tick:ClearAllPoints()
            tick:Hide()
        end)
        Castbar.SetBarTicks = CastBars.SetBarTicks
    end

    Castbar.timeToHold = 1
    local flashAnim = Castbar:CreateAnimationGroup()
    flashAnim:SetScript("OnPlay", PlayFlash)
    flashAnim:SetScript("OnFinished", EndFlash)
    flashAnim:SetScript("OnStop", EndFlash)
    flashAnim.bar = Castbar
    Castbar.flashAnim = flashAnim

    local flash = flashAnim:CreateAnimation("Alpha")
    flash:SetDuration(Castbar.timeToHold)
    flash:SetSmoothing("OUT")
    flashAnim.flash = flash

    Castbar.PostCastStart = PostCastStart
    --Castbar.PostCastUpdate = PostCastUpdate
    Castbar.PostCastStop = PostCastStop
    Castbar.PostCastFail = PostCastFail
    Castbar.PostCastInterruptible = PostCastInterruptible

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
