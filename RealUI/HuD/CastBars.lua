local _, private = ...

-- Lua Globals --
-- luacheck: globals _G assert next

-- RealUI --
local RealUI = private.RealUI
local db

local CombatFader = RealUI:GetModule("CombatFader")
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
        assert(_G.C_Spell.GetSpellInfo(spellID), spellNotFound:format(spellID))

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
    -- RegisterSpellName(191837, 3 / 1.002, false) -- Essence Font
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

    -- Safety check: ensure castbar exists
    if not castbar then
        CastBars:debug("Castbar not found for unit:", unit)
        return
    end

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

    local fromAlpha = anim.bar:GetAlpha()
    if _G.issecretvalue(fromAlpha) or type(fromAlpha) ~= "number" then
        fromAlpha = 1
    elseif fromAlpha < 0 then
        fromAlpha = 0
    elseif fromAlpha > 1 then
        fromAlpha = 1
    end
    anim.flash:SetFromAlpha(fromAlpha)
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

    -- Reset tracking for new cast

    -- notInterruptible can be a secret boolean (for other players' casts).
    -- Secret booleans cannot be tested, compared, or even == checked in Lua.
    -- Use issecretvalue() to detect them, then fall back to interruptible color.
    local notInt = self.notInterruptible
    if _G.issecretvalue(notInt) or notInt == nil then
        self:SetStatusBarColor(interruptible:GetRGB())
    elseif notInt then
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
local function PostCastStop(self, unit, empowerComplete)
    CastBars:debug("PostCastStop", unit, empowerComplete)
    self.holdTime = self.timeToHold
    self.Text:SetText(_G.SUCCESS)
    self:Show()
    self.flashAnim.color = Color.green
    if _G.InCombatLockdown and _G.InCombatLockdown() then
        return
    end
    self.flashAnim:Play()
end
local function PostCastFail(self, unit)
    CastBars:debug("PostCastFail", unit)
    self.flashAnim.color = Color.red
    if _G.InCombatLockdown and _G.InCombatLockdown() then
        return
    end
    self.flashAnim:Play()
end
local function PostCastInterruptible(self, unit)
    CastBars:debug("PostCastInterruptible", unit)
    -- notInterruptible can be a secret boolean, use issecretvalue() first
    local notInt = self.notInterruptible
    if _G.issecretvalue(notInt) or notInt == nil then
        self:SetStatusBarColor(interruptible:GetRGB())
    elseif notInt then
        self:SetStatusBarColor(uninterruptible:GetRGB())
    else
        self:SetStatusBarColor(interruptible:GetRGB())
    end
end


function CastBars:CreateCastBars(unitFrame, unit, unitData)
    self:debug("CreateCastBars", unit)
    local info, unitDB = unitData.power or unitData.health, db[unit]
    unitFrame.Castbar = unitFrame:CreateAngle("CastBar", nil, unitFrame)
    local Castbar = unitFrame.Castbar
    Castbar:SetAngleVertex(info.leftVertex, info.rightVertex)
    Castbar:SetStatusBarColor(interruptible:GetRGB())
    -- Castbar:smoothing       (false)
    -- Castbar:SetSmooth(false)
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
        Castbar.tickPool = _G.CreateUnsecuredObjectPool(function(pool)
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

    -- Custom OnUpdate that syncs the native timer to AngleStatusBar fill.
    -- oUF checks element.OnUpdate before falling back to its default onUpdate,
    -- so setting this property ensures oUF uses our function.
    --
    -- Blizzard's own CastingBarMixin:OnUpdate manually tracks self.value via
    -- elapsed and calls SetValue each frame. oUF instead uses SetTimerDuration
    -- which drives the native StatusBar C++ timer, but that doesn't call our
    -- SetBarValue. We follow Blizzard's pattern: query UnitCastingInfo/
    -- UnitChannelInfo for startTime/endTime (works for ALL units), compute
    -- the current value, and drive SetBarValue directly.
    Castbar.OnUpdate = function(self, elapsed)
        if self.casting or self.channeling or self.empowering then
            local ownerUnit = self.__owner and self.__owner.unit
            local startTime, endTime, duration, value

            -- Try oUF's cached values first (player casts)
            if self.startTime and self.endTime then
                startTime = self.startTime
                endTime = self.endTime
            elseif ownerUnit then
                -- Query the API directly for non-player casts.
                -- startTime/endTime may be secret numbers for enemy units,
                -- so we must check with issecretvalue before arithmetic.
                if self.casting then
                    local _, _, _, st, et = _G.UnitCastingInfo(ownerUnit)
                    if st and et and not _G.issecretvalue(st) and not _G.issecretvalue(et) then
                        startTime = st / 1000
                        endTime = et / 1000
                    end
                elseif self.channeling or self.empowering then
                    local _, _, _, st, et = _G.UnitChannelInfo(ownerUnit)
                    if st and et and not _G.issecretvalue(st) and not _G.issecretvalue(et) then
                        startTime = st / 1000
                        endTime = et / 1000
                    end
                end
            end

            if startTime and endTime then
                local now = _G.GetTime()
                duration = endTime - startTime
                if duration > 0 then
                    if self.channeling then
                        value = endTime - now
                    else
                        value = now - startTime
                    end
                    if value < 0 then value = 0 end
                    if value > duration then value = duration end

                    -- Drive the AngleStatusBar fill
                    local meta = ASB:GetBarMeta(self)
                    if meta then
                        meta.minVal = 0
                        meta.maxVal = duration
                        ASB:SetBarValue(self, value)
                    end

                    -- Update Time text
                    if self.Time then
                        local remaining = self.channeling and value or (duration - value)
                        if self.delay and self.delay ~= 0 then
                            self.Time:SetFormattedText('%.1f|cffff0000%s%.2f|r', remaining, self.channeling and '-' or '+', self.delay)
                        else
                            self.Time:SetFormattedText('%.1f', remaining)
                        end
                    end
                end
            else
                -- Secret times fallback for enemy casts.
                -- The native C++ timer engine (driven by oUF's SetTimerDuration)
                -- is already sizing self.fill since fill IS the native StatusBar
                -- texture. Read back the computed width for trapezoid vertex offsets.
                local meta = ASB:GetBarMeta(self)
                if meta then
                    local width = self.fill:GetWidth()
                    if not _G.issecretvalue(width) and width > 0.001 then
                        self.fill:SetShown(true)
                        if meta.isTrapezoid then
                            if width < (meta.minWidth * 2) then
                                local vertexOfs = width / 2
                                self.fill:SetPoint(meta.isTrapezoid, 0, (meta.minWidth - vertexOfs) * (meta.isTrapezoid == "TOP" and -1 or 1))
                                self.fill:SetVertexOffset(meta.leftVertex, vertexOfs, 0)
                                self.fill:SetVertexOffset(meta.rightVertex, -vertexOfs, 0)
                                meta.isLess = true
                            elseif meta.isLess then
                                self.fill:SetPoint(meta.isTrapezoid)
                                self.fill:SetVertexOffset(meta.leftVertex, meta.minWidth, 0)
                                self.fill:SetVertexOffset(meta.rightVertex, -meta.minWidth, 0)
                                meta.isLess = false
                            end
                        end
                    else
                        -- Width is secret or zero — just show fill, native handles it
                        self.fill:SetShown(true)
                    end
                end

                -- Update Time text — SetFormattedText handles secret numbers
                local nativeGetTimer = _G.getmetatable(self).__index.GetTimerDuration
                if nativeGetTimer and self.Time then
                    local ok, durationObj = _G.pcall(nativeGetTimer, self)
                    if ok and durationObj then
                        local ok2, remaining = _G.pcall(function() return durationObj:GetRemainingDuration() end)
                        if ok2 and remaining then
                            self.Time:SetFormattedText('%.1f', remaining)
                        end
                    end
                end
            end
        elseif self.holdTime and self.holdTime > 0 then
            self.holdTime = self.holdTime - elapsed
        else
            -- Reset and hide (same as oUF's default)
            self.castID = nil
            self.casting = nil
            self.channeling = nil
            self.empowering = nil
            self.notInterruptible = nil
            self.spellID = nil
            self.spellName = nil
            for _, pip in _G.next, self.Pips do
                pip:Hide()
            end
            self:Hide()
        end
    end

    unitFrame.Castbar = Castbar
    self[unit] = Castbar
    self:UpdateSettings(unit)
    CombatFader:RegisterFrameForFade(MODNAME, Castbar)
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
        if not castbar then return end

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
            combatfade = {
                enabled = true,
                opacity = {
                    incombat = 1,
                    harmtarget = 0.85,
                    target = 0.75,
                    hurt = 0.6,
                    outofcombat = 0.25,
                },
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    CombatFader:RegisterModForFade(MODNAME, "profile", "combatfade")
    FramePoint:RegisterMod(self, nil, OnDragStop)
end

function CastBars:OnEnable()
    self.configMode = false
end

function CastBars:OnDisable()
    -- Enable default Cast Bars
    if not _G.CastingBarFrame or not _G.PetCastingBarFrame then
        if _G.C_AddOns and _G.C_AddOns.LoadAddOn then
            _G.C_AddOns.LoadAddOn("Blizzard_CastingBarUI")
        else
            _G.LoadAddOn("Blizzard_CastingBarUI")
        end
    end

    if _G.CastingBarFrame and _G.CastingBarFrame.GetScript then
        local onLoad = _G.CastingBarFrame:GetScript("OnLoad")
        if onLoad then
            onLoad(_G.CastingBarFrame)
        end
    end

    if _G.PetCastingBarFrame and _G.PetCastingBarFrame.GetScript then
        local onLoad = _G.PetCastingBarFrame:GetScript("OnLoad")
        if onLoad then
            onLoad(_G.PetCastingBarFrame)
        end
    end
end
