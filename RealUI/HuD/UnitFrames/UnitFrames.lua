local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db, ndb -- luacheck: ignore

local CombatFader = RealUI:GetModule("CombatFader")
local FramePoint = RealUI:GetModule("FramePoint")

local MODNAME = "UnitFrames"
local UnitFrames = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
local refreshRetryPending = false

UnitFrames.units = {}

-- Maps position anchor to {dialog-side anchor, offsetX, offsetY}
local auraPositionMap = {
    TOPLEFT = {"TOPLEFT", 0, 20},
    TOPRIGHT = {"TOPRIGHT", 0, 20},
    BOTTOMLEFT = {"BOTTOMLEFT", 0, -20},
    BOTTOMRIGHT = {"BOTTOMRIGHT", 0, -20},
    LEFT = {"LEFT", -10, 0},
    RIGHT = {"RIGHT", 10, 0},
    LEFTTOP = {"TOPLEFT", -10, 0},
    LEFTBOTTOM = {"BOTTOMLEFT", -10, 0},
    RIGHTTOP = {"TOPRIGHT", 10, 0},
    RIGHTBOTTOM = {"BOTTOMRIGHT", 10, 0},
}

function UnitFrames.GetInitialAnchor(growthX, growthY)
    return ((growthY == "DOWN") and "TOP" or "BOTTOM") .. ((growthX == "LEFT") and "RIGHT" or "LEFT")
end

function UnitFrames.SetAuraPosition(auraFrame, parent, posAnchor, initialAnchor)
    local pos = auraPositionMap[posAnchor] or auraPositionMap.TOPLEFT
    auraFrame:ClearAllPoints()
    auraFrame:SetPoint(initialAnchor, parent, pos[1], pos[2], pos[3])
end

-- oUF 14: aura containers are AuraContainer intrinsics built via
-- frame:CreateAuras() + AddGroup, replacing the old widget-based
-- Buffs/Debuffs element. One element per legacy container; positioning on
-- the parent stays the caller's job (Player/Target use SetAuraPosition,
-- Boss anchors directly).
-- B19/B45: the timer text we could never restyle is the COOLDOWN WIDGET's
-- built-in countdown (CooldownFrameTemplate draws it by default), not something
-- oUF owns — hence the silent SetFontObject refusals.
--
-- oUF 14 provides the supported route: pass `showDuration` and it creates a
-- `button.Time` FontString and drives it via button:SetDurationText(), with
-- durationFormat / durationFormatter / durationColors as options
-- (oUF/elements/auras.lua:181-190). That FontString is oUF's, so it is ours to
-- style and position. Hiding the cooldown's own numbers leaves exactly one
-- timer per icon. No secret aura data is read at any point.
-- Mirrors Blizzard's DefaultAuraDurationFormatter
-- (Blizzard_AuraContainerShared.lua:93-98) so we own it rather than inherit it.
--
-- B19: the SecondsFormatter path rendered "51 m" — the space belongs to the
-- locale's OneLetter abbreviation ("%d m"), and SetStripIntervalWhitespace
-- only removes whitespace BETWEEN intervals, so no formatter tweak can drop
-- it. The structured textFormat (DurationTextBindingFormatOptions) owns the
-- whole string instead: a NumericRuleFormatter with magnitude breakpoints
-- renders bare seconds, then 51m / 3h / 2d. Seconds round up so 0.4s reads
-- "1", not "0"; m/h/d floor via quotient division, the usual convention.
local durationTextFormat
local function GetDurationTextFormat()
    if durationTextFormat == nil then
        durationTextFormat = false
        if _G.C_StringUtil and _G.C_StringUtil.CreateNumericRuleFormatter then
            local ok, formatter = _G.pcall(_G.C_StringUtil.CreateNumericRuleFormatter)
            if ok and formatter then
                local set = _G.pcall(formatter.SetBreakpoints, formatter, {
                    { threshold = 0, format = "%d", components = {
                        { step = 1, rounding = _G.Enum.NumericRuleFormatRounding.Up },
                    } },
                    { threshold = 60, format = "%dm", components = { { div = 60 } } },
                    { threshold = 3600, format = "%dh", components = { { div = 3600 } } },
                    { threshold = 86400, format = "%dd", components = { { div = 86400 } } },
                })
                if set then
                    durationTextFormat = {
                        -- The binding's placeholder syntax is "{}", one per
                        -- component ("%s" reads as zero placeholders and
                        -- SetTextFormat rejects the mismatch).
                        formatString = "{}",
                        components = {
                            {
                                property = _G.Enum.DurationTextBindingProperty.RemainingDuration,
                                formatter = formatter,
                            },
                        },
                    }
                end
            end
        end
    end
    return durationTextFormat or nil
end

-- Fallback when NumericRuleFormatter is unavailable: the old SecondsFormatter
-- ("51 m" spacing and all). SetDurationText only consults textFormatter when
-- no textFormat was given.
local durationFormatter
local function GetDurationFormatter()
    if durationFormatter == nil and _G.C_StringUtil and _G.C_StringUtil.CreateSecondsFormatter then
        local ok, formatter = _G.pcall(_G.C_StringUtil.CreateSecondsFormatter)
        if ok and formatter then
            _G.pcall(formatter.SetDefaultAbbreviation, formatter, _G.Enum.SecondsFormatterAbbreviation.OneLetter)
            _G.pcall(formatter.SetMinInterval, formatter, _G.Enum.SecondsFormatterInterval.Seconds)
            _G.pcall(formatter.SetDesiredUnitCount, formatter, 1)
            _G.pcall(formatter.SetStripIntervalWhitespace, formatter, true)
            durationFormatter = formatter
        else
            durationFormatter = false
        end
    end
    return durationFormatter or nil
end

local function AuraPostCreateButton(_, button)
    if button.Icon then
        _G.Aurora.Base.CropIcon(button.Icon, button)
    end

    -- B19: the double icon on dispellable target debuffs. With the default
    -- Border style the engine stamps AuraUtil.SetAuraBorderAtlas — full-size
    -- Blizzard border art at OVERLAY over our cropped icon, reading as two
    -- stacked squares. The group passes dispelBorderStyle = PreserveAsset, so
    -- the engine only ever SetVertexColors this texture (dispel color,
    -- through oUF's colors.dispel map) and never touches its asset. Reshape
    -- it into Aurora's iconBorder geometry — a white fill 1px outside the
    -- icon at BACKGROUND 1: above the black CropIcon border (BACKGROUND 0),
    -- below the icon. Dispellable debuffs get a colored 1px border, exactly
    -- the RealUI button style. NOT done in Auras:PostUpdate (oUF 14.0.1):
    -- that fires only on oUF-initiated updates, while the engine restyles
    -- recycled buttons on its own — asset-preservation is the reliable path.
    if button.Border then
        button.Border:SetColorTexture(1, 1, 1)
        button.Border:SetDrawLayer("BACKGROUND", 1)
        button.Border:ClearAllPoints()
        if button.Icon then
            button.Border:SetPoint("TOPLEFT", button.Icon, -1, 1)
            button.Border:SetPoint("BOTTOMRIGHT", button.Icon, 1, -1)
        else
            button.Border:SetAllPoints(button)
        end
    end
    if button.Count then
        button.Count:SetFontObject("NumberFont_Outline_Med")
    end

    -- Blizzard's countdown numbers on the cooldown spiral: unstylable from here
    -- and the source of the oversized digits. oUF's Time string replaces them.
    if button.Cooldown and button.Cooldown.SetHideCountdownNumbers then
        button.Cooldown:SetHideCountdownNumbers(true)
    end

    if button.Time then
        -- NumberFont_Outline_Small does NOT exist; the outline family is only
        -- Med/Large/Huge. Shadow_Small is the smallest number font available.
        button.Time:SetFontObject("NumberFont_Shadow_Small")
        button.Time:ClearAllPoints()
        button.Time:SetPoint("BOTTOM", button, "BOTTOM", 0, 1)
    end
end

-- settings = {filter, count, size, spacing, growthX, growthY, maxWidth,
--             cancelButton (RegisterForClicks string, e.g. "RightButtonUp" —
--             combat-legal cancel; player buffs),
--             showDebuffBorder (dispel-type coloring from colors.dispel)}
function UnitFrames.CreateAuraElement(dialog, settings)
    local frameWidth = (settings.maxWidth and settings.maxWidth > 0 and settings.maxWidth) or dialog:GetWidth()
    local element = dialog:CreateAuras({
        initialAnchor = UnitFrames.GetInitialAnchor(settings.growthX, settings.growthY),
        growthX = settings.growthX,
        growthY = settings.growthY,
        layoutLimit = frameWidth,
    })
    element.PostCreateButton = AuraPostCreateButton
    element._ruiGroupKey = element:AddGroup(settings.filter, {
        maxFrameCount = settings.count,
        size = settings.size,
        elementSpacing = settings.spacing,
        lineSpacing = settings.spacing,
        showCount = true,
        -- B19: oUF-owned duration text (button.Time), replacing the cooldown
        -- widget's own countdown numbers which cannot be restyled. Minutes and
        -- hours are shown without decimals so long raid buffs stay narrow.
        showDuration = true,
        durationFormat = GetDurationTextFormat(),
        durationFormatter = GetDurationFormatter(),
        cancelButton = settings.cancelButton,
        showDebuffBorder = settings.showDebuffBorder,
        -- B19: PreserveAsset = the engine colors button.Border but never
        -- replaces its asset (see AuraPostCreateButton).
        dispelBorderStyle = _G.Enum.CustomAuraButtonDispelTypeTextureStyle
            and _G.Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
        -- Must be an AddGroup option, not a post-hoc element flag: the intrinsic
        -- pre-creates its button pool during AddGroup, so flags set after
        -- CreateAuraElement returns are too late (raid-cell mini icons).
        disableCooldown = settings.disableCooldown,
    })
    return element
end

-- Runtime config refresh. Everything except button size is live-mutable on
-- the intrinsic (SetAuraGroupMaxFrameCount + the SetFlowLayout* family);
-- size is resolved at button creation and needs a /reload to change.
-- opts = {show, count, layout (auraLayout sub-table), defaultAnchor,
--         defaultGrowthX, defaultGrowthY}; defaultAnchor nil = caller owns
--         positioning (boss frames).
function UnitFrames.RefreshAuraElement(element, frame, opts)
    element:SetEnabled(opts.show and true or false)
    if not opts.show then return end

    if element._ruiGroupKey then
        element:SetAuraGroupMaxFrameCount(element._ruiGroupKey, opts.count or 16)
    end

    local layout = opts.layout or {}
    local growthX = layout.growthX or opts.defaultGrowthX
    local growthY = layout.growthY or opts.defaultGrowthY
    local initialAnchor = UnitFrames.GetInitialAnchor(growthX, growthY)
    element:SetFlowLayoutAnchorPoint(initialAnchor)
    element:SetFlowLayoutGrowthDirection(growthX == "LEFT" and -1 or 1, growthY == "DOWN" and -1 or 1)
    -- B19 note: target buffs and debuffs share the frame's top edge and grow
    -- toward each other (debuffs TOPLEFT→right, buffs TOPRIGHT→left), so with
    -- many of both they meet in the middle and overlap. Capping each at half the
    -- frame width was tried 2026-08-19 and is WORSE — they wrap after ~3 icons
    -- into a tall narrow block. The real fix is separate anchors for the two
    -- groups, which is a layout decision, not a line-size tweak.
    local maxWidth = layout.maxWidth
    element:SetFlowLayoutMaximumLineSize((maxWidth and maxWidth > 0 and maxWidth) or frame:GetWidth())
    if opts.defaultAnchor then
        UnitFrames.SetAuraPosition(element, frame, layout.anchor or opts.defaultAnchor, initialAnchor)
    end

    element:ForceUpdate()
end

local units = {
    "Player",
    "Target",
    "Focus",
    "FocusTarget",
    "Pet",
    "TargetTarget",
}

function UnitFrames:ApplyStatusTextFont(fontString)
    if not fontString then return end

    local misc = db and db.misc or {}
    local mode = misc.statusTextOutline or "outline"

    if mode == "shadow" then
        fontString:SetFontObject("SystemFont_Shadow_Med1")
        return
    end

    -- Start from the shadowed base font, then swap in outline flags.
    fontString:SetFontObject("SystemFont_Shadow_Med1")
    local font, size = fontString:GetFont()
    if not font or not size then
        fontString:SetFontObject("SystemFont_Shadow_Med1_Outline")
        return
    end

    if mode == "thick" then
        fontString:SetFont(font, size, "THICKOUTLINE")
    else
        fontString:SetFont(font, size, "OUTLINE")
    end
end

function UnitFrames:RefreshUnits(event) --luacheck: ignore 561
    -- Swap oUF.colors.health based on alternative bar style (only affects angled bars via UpdateColor override)
    oUF.colors.health = oUF:CreateColor(0.66, 0.22, 0.22)

    -- Profile may not be fully populated on a fresh profile switch; bail and wait for the
    -- next RefreshMod call which will retry once AceDB has settled the new profile.
    if not db.units or not db.overlay then return end

    for i = 1, #units do
        local frame = _G["RealUI" .. units[i] .. "Frame"]
        if not frame then
            self:debug("Unit frame not found:", units[i])
        else
            -- oUF 14 privatized frame.unit; the key derives from our own
            -- units table ("Player" -> "player", "FocusTarget" -> "focustarget")
            local unitKey = units[i]:lower()
            local unitData = UnitFrames[unitKey]

            -- Update class color settings
            if frame.Health then
                local unitDB = db.units[unitKey]
                local hb = unitDB and unitDB.healthBar
                local colorByClass = db.overlay.classColor or (hb and hb.colorForegroundByClass)
                frame.Health.colorClass = colorByClass
                frame.Health.colorReaction = colorByClass
                frame.Health.colorHealth = not colorByClass

                -- Update alternative bar style
                if frame.Health and frame.Health.bg then
                    if db.misc.alternativeBarStyle then
                        if not frame.HealthBG then
                            -- Create HealthBG on demand
                            local unitData2 = UnitFrames[unitKey]
                            if unitData2 and unitData2.health and unitData2.health.leftVertex then
                                local HealthBG = frame:CreateAngle("StatusBar", nil, frame.overlay)
                                HealthBG:SetAngleVertex(unitData2.health.leftVertex, unitData2.health.rightVertex)
                                HealthBG:SetSize(frame.Health:GetWidth(), frame.Health:GetHeight())
                                HealthBG:SetPoint("TOP"..(unitData2.health.point or "RIGHT"), frame)
                                HealthBG:SetFrameLevel(frame.Health:GetFrameLevel())
                                HealthBG.bg:SetAlpha(0)
                                HealthBG.top:Hide()
                                HealthBG.bottom:Hide()
                                HealthBG.left:Hide()
                                HealthBG.right:Hide()
                                HealthBG.fill:SetDrawLayer("BORDER")
                                HealthBG:SetMinMaxValues(0, 1)
                                HealthBG:SetValue(1)
                                frame.HealthBG = HealthBG
                            end
                        else
                            frame.HealthBG:Show()
                        end

                        -- Re-apply background color every refresh (not just at creation)
                        -- so "Background Color" / "Class Color Background" changes take
                        -- effect immediately, and honor colorBackgroundByClass the same
                        -- way the foreground bar honors colorForegroundByClass.
                        if frame.HealthBG then
                            local bgOpacity = (hb and hb.backgroundOpacity) or 1.0
                            local bgColor
                            if hb and hb.colorBackgroundByClass then
                                local _, class = _G.UnitClass(unitKey)
                                bgColor = class and frame.colors and frame.colors.class[class]
                            end
                            if bgColor then
                                local r, g, b = bgColor:GetRGB()
                                frame.HealthBG:SetStatusBarColor(r, g, b, bgOpacity)
                            else
                                local c = (hb and hb.background) or {0.78, 0.15, 0.15}
                                frame.HealthBG:SetStatusBarColor(c[1], c[2], c[3], bgOpacity)
                            end
                        end
                    elseif frame.HealthBG then
                        frame.HealthBG:Hide()
                    end
                end

                -- Force oUF to re-run color logic (Health.UpdateColor) immediately with
                -- the flags/style just set above, instead of waiting for the next
                -- natural health-update event (UNIT_HEALTH, etc). Without this, color
                -- config changes only visibly apply once something else happens to
                -- trigger a health update (e.g. taking damage).
                if frame.Health.ForceUpdate then
                    frame.Health:ForceUpdate()
                end

                -- Update fill direction (shared rule: natural side, parent
                -- inheritance for pet/targettarget, per-unit toggle)
                if frame.Health.SetReverseFill then
                    frame.Health:SetReverseFill(UnitFrames.GetReverseFill(unitKey, unitData and unitData.health))
                end

                -- Retag health text
                if frame.Health.text then
                    self:ApplyStatusTextFont(frame.Health.text)
                    frame:Untag(frame.Health.text)
                    frame:Tag(frame.Health.text, UnitFrames.GetHealthTagString(db.misc.statusText))
                end
            end

            -- Update power fill direction and retag power text
            if frame.Power then
                local pInfo = unitData and unitData.power

                -- Update alternative bar style (mirrors the Health block above)
                if db.misc.alternativeBarStyle then
                    if not frame.PowerBG then
                        -- Create PowerBG on demand (style enabled mid-session)
                        if pInfo and pInfo.leftVertex and frame.CreateAngle and frame.Health then
                            local hbUnitDB = db.units[unitKey]
                            local healthHeightPct = (hbUnitDB and hbUnitDB.healthHeight) or 0.6
                            local pWidth = RealUI.Round(frame:GetWidth() * 0.9)
                            local pHeight = RealUI.Round((frame:GetHeight() - 3) * (1 - healthHeightPct))
                            local xOffset = frame.Health:GetHeight() - pHeight
                            local PowerBG = frame:CreateAngle("StatusBar", nil, frame.overlay)
                            PowerBG:SetSize(pWidth, pHeight)
                            PowerBG:SetPoint("BOTTOM"..(pInfo.point or "LEFT"), frame, pInfo.point == "RIGHT" and -xOffset or xOffset, 0)
                            PowerBG:SetAngleVertex(pInfo.leftVertex, pInfo.rightVertex)
                            PowerBG:SetReverseFill(UnitFrames.GetReverseFill(unitKey, pInfo))
                            PowerBG:SetFrameLevel(frame.Power:GetFrameLevel())
                            PowerBG.bg:SetAlpha(0)
                            PowerBG.top:Hide()
                            PowerBG.bottom:Hide()
                            PowerBG.left:Hide()
                            PowerBG.right:Hide()
                            PowerBG.fill:SetDrawLayer("BORDER")
                            PowerBG:SetMinMaxValues(0, 1)
                            PowerBG:SetValue(1)
                            frame.PowerBG = PowerBG
                        end
                    else
                        frame.PowerBG:Show()
                    end
                elseif frame.PowerBG then
                    frame.PowerBG:Hide()
                end

                -- Re-run color logic now (PostUpdateColor repaints the fill
                -- dark and recolors PowerBG) instead of waiting for the next
                -- natural power event
                if frame.Power.ForceUpdate then
                    frame.Power:ForceUpdate()
                end

                if frame.Power.SetReverseFill then
                    frame.Power:SetReverseFill(UnitFrames.GetReverseFill(unitKey, pInfo))
                end

                if frame.Power.text then
                    self:ApplyStatusTextFont(frame.Power.text)
                    frame:Untag(frame.Power.text)
                    local _, powerType = _G.UnitPowerType(unitKey)
                    frame:Tag(frame.Power.text, UnitFrames.GetPowerTagString(db.misc.statusText, powerType))
                end
            end

            -- Update aura toggles/counts on target frame (oUF 14: live
            -- intrinsic mutation via RefreshAuraElement; size needs /reload)
            if unitKey == "target" then
                if frame.Debuffs then
                    UnitFrames.RefreshAuraElement(frame.Debuffs, frame, {
                        show = db.units.target.showTargetDebuffs,
                        count = db.units.target.debuffCount,
                        layout = db.units.target.auraLayout and db.units.target.auraLayout.debuffs,
                        defaultAnchor = "TOPLEFT",
                        defaultGrowthX = "RIGHT",
                        defaultGrowthY = "UP",
                    })
                end
                if frame.Buffs then
                    UnitFrames.RefreshAuraElement(frame.Buffs, frame, {
                        show = db.units.target.showTargetBuffs,
                        count = db.units.target.buffCount,
                        layout = db.units.target.auraLayout and db.units.target.auraLayout.buffs,
                        defaultAnchor = "TOPRIGHT",
                        defaultGrowthX = "LEFT",
                        defaultGrowthY = "UP",
                    })
                end
            end

            -- Update aura toggles/counts on player frame
            if unitKey == "player" then
                if frame.Buffs then
                    UnitFrames.RefreshAuraElement(frame.Buffs, frame, {
                        show = db.units.player.showPlayerBuffs,
                        count = db.units.player.buffCount,
                        layout = db.units.player.auraLayout and db.units.player.auraLayout.buffs,
                        defaultAnchor = "TOPLEFT",
                        defaultGrowthX = "RIGHT",
                        defaultGrowthY = "UP",
                    })
                end
            end

            -- Toggle Private Auras
            if frame._privateAurasFrame then
                if db.misc.showPrivateAuras then
                    if not frame.PrivateAuras then
                        frame.PrivateAuras = frame._privateAurasFrame
                        -- oUF 14: EnableElement defaults to the frame's __unit
                        frame:EnableElement("PrivateAuras")
                    end
                else
                    if frame.PrivateAuras then
                        frame:DisableElement("PrivateAuras")
                        frame.PrivateAuras = nil
                    end
                end
            end

            -- Toggle Health Prediction sub-widgets
            if frame.Health then
                local predictionWidgets = {"HealingAll", "DamageAbsorb", "HealAbsorb"}
                for _, wn in ipairs(predictionWidgets) do
                    local widget = frame.Health[wn]
                    if widget then
                        if db.misc.showPrediction then
                            widget:Show()
                        else
                            widget:Hide()
                        end
                    end
                end
            end

            frame:UpdateAllElements(event)
        end
    end

    -- Refresh boss frames
    for i = 1, 5 do
        local frame = _G["RealUIBossFrame" .. i]
        if frame then
            -- B56: live-apply the alt-power-only toggle (UpdateAllElements
            -- below re-runs the Power update with the new flag)
            if frame.Power then
                frame.Power.displayAltPowerOnly = (db.boss and db.boss.altPowerOnly) or nil
            end

            if frame.Health then
                local hb = db.units.boss and db.units.boss.healthBar
                local colorByClass = db.overlay.classColor or (hb and hb.colorForegroundByClass)
                frame.Health.colorClass = colorByClass
                frame.Health.colorReaction = colorByClass
                frame.Health.colorHealth = not colorByClass

                -- Update alternative bar style on boss frames
                if frame.HealthBG then
                    if db.misc.alternativeBarStyle then
                        frame.HealthBG:Show()
                    else
                        frame.HealthBG:Hide()
                    end
                end

                if frame.Health.text then
                    frame:Untag(frame.Health.text)
                    frame:Tag(frame.Health.text, UnitFrames.GetHealthTagString(db.misc.statusText))
                end
            end

            -- oUF 14: boss anchors are fixed (no defaultAnchor = caller-owned
            -- positioning); growth defaults mirror the create site
            -- (B34: debuffs anchor to the frame's left edge and grow LEFT)
            if frame.Debuffs and db.boss then
                UnitFrames.RefreshAuraElement(frame.Debuffs, frame, {
                    show = db.boss.showBossDebuffs,
                    count = db.boss.debuffCount,
                    defaultGrowthX = "LEFT",
                    defaultGrowthY = "UP",
                })
            end
            if frame.Buffs and db.boss then
                UnitFrames.RefreshAuraElement(frame.Buffs, frame, {
                    show = db.boss.showBossBuffs,
                    count = db.boss.buffCount,
                    defaultGrowthX = "RIGHT",
                    defaultGrowthY = "DOWN",
                })
            end

            frame:UpdateAllElements(event)
        end
    end

    -- Refresh arena frames
    for i = 1, 5 do
        local frame = _G["RealUIArenaFrame" .. i]
        if frame then
            if frame.Health then
                frame.Health.colorClass = db.overlay.classColor
                frame.Health.colorReaction = db.overlay.classColor
                frame.Health.colorHealth = not db.overlay.classColor

                if frame.Health.text then
                    frame:Untag(frame.Health.text)
                    frame:Tag(frame.Health.text, UnitFrames.GetHealthTagString(db.misc.statusText))
                end
            end

            frame:UpdateAllElements(event)
        end
    end
end

UnitFrames.steppoints = {
    default = {0.35, 0.25},
    health = {
        HUNTER  = {0.8, 0.2},
        PALADIN = {0.4, 0.2},
        WARRIOR = {0.35, 0.2},
    },
    power = {
        MAGE    = {0.7, 0.25},
        WARLOCK = {0.6, 0.4},
    },
}

local unitGroups = {
    Arena = 5,
    Boss = 5,
}
function RealUI:DemoUnitGroup(unitType, toggle)
    local baseName = "RealUI" .. unitType .. "Frame"
    for i = 1, unitGroups[unitType] do
        local frame = _G[baseName .. i]
        if frame then
            -- oUF 14: the unit attribute swap is still honoured (the
            -- attribute driver rewrites __unit and updates all elements);
            -- the old direct frame.unit writes were inert and are gone.
            -- _ruiRealUnit is RealUI-owned (was __realunit — one capital
            -- letter from oUF's private __realUnit).
            if toggle then
                if not frame._ruiRealUnit then
                    frame._ruiRealUnit = frame:GetAttribute("unit")
                    frame:SetAttribute("unit", "player")
                    frame:Show()
                end
            else
                if frame._ruiRealUnit then
                    frame:SetAttribute("unit", frame._ruiRealUnit)
                    frame._ruiRealUnit = nil
                    frame:Hide()
                end
            end
        end
    end
end

----------------------------
------ Initialization ------
----------------------------
function UnitFrames:RefreshMod()
    db = self.db.profile
    ndb = RealUI.db.profile
    self.layoutSize = RealUI.cLayout or RealUI.db.char.layout.current or 1

    -- During early login, profile updates can fire before oUF frames are spawned.
    -- Delay one tick so frame reposition/refresh does not run against nil frames.
    if not _G.RealUIPlayerFrame then
        if not refreshRetryPending then
            refreshRetryPending = true
            self:ScheduleTimer(function()
                refreshRetryPending = false
                if self:IsEnabled() then
                    self:RefreshMod()
                end
            end, 0.5)
        end
        return
    end

    -- Reposition unit frames for the new layout
    self:RepositionFrames()

    -- Resize unit frames if layoutSize changed since they were spawned
    self:ResizeFrames()

    self:RefreshUnits("RefreshMod")
end

function UnitFrames:ResizeFrames()
    local sizeMod = self.layoutSize == 1 and 0.85 or 1
    local round = RealUI.Round

    for i = 1, #units do
        local frame = _G["RealUI" .. units[i] .. "Frame"]
        if frame then
            local unitKey = units[i]:lower() -- oUF 14: frame.unit privatized
            local unitDB = db.units[unitKey]
            if unitDB and unitDB.size then
                local width = round(unitDB.size.x * sizeMod)
                local height = round(unitDB.size.y * sizeMod)
                if frame.ApplySize then
                    frame:ApplySize(width, height)
                else
                    frame:SetSize(width - 2, height - 2)
                end
            end
        end
    end

    -- Resize boss frames
    for i = 1, 5 do
        local frame = _G["RealUIBossFrame" .. i]
        if frame then
            local unitDB = db.units.boss
            if unitDB and unitDB.size then
                local width = round(unitDB.size.x * sizeMod)
                local height = round(unitDB.size.y * sizeMod)
                frame:SetSize(width, height)
            end
        end
    end

    -- Resize arena frames
    for i = 1, 5 do
        local frame = _G["RealUIArenaFrame" .. i]
        if frame then
            local unitDB = db.units.arena
            if unitDB and unitDB.size then
                local width = round(unitDB.size.x * sizeMod)
                local height = round(unitDB.size.y * sizeMod)
                frame:SetSize(width, height)
            end
        end
    end
end

function UnitFrames:OnProfileUpdate(event, profile)
    -- Profile changed, refresh unit frames for the new profile's settings
    self:RefreshMod()
end

function UnitFrames:RepositionFrames()
    -- Get the positioner frame and force it to update its layout
    local positioner = _G["RealUIPositionersUnitFrames"]
    if positioner then
        -- Force the positioner frame to update its size/position immediately
        positioner:SetScript("OnUpdate", nil)  -- Clear any pending updates
        positioner:GetCenter()  -- Force layout calculation
    end

    -- Reposition player frame
    local player = _G["RealUIPlayerFrame"]
    if player and db.positions[self.layoutSize] then
        player:ClearAllPoints()
        player:SetPoint("RIGHT", "RealUIPositionersUnitFrames", "LEFT",
            db.positions[self.layoutSize].player.x,
            db.positions[self.layoutSize].player.y)
    end

    -- Reposition target frame
    local target = _G["RealUITargetFrame"]
    if target and db.positions[self.layoutSize] then
        target:ClearAllPoints()
        target:SetPoint("LEFT", "RealUIPositionersUnitFrames", "RIGHT",
            db.positions[self.layoutSize].target.x,
            db.positions[self.layoutSize].target.y)
    end

    -- Reposition pet frame (anchored to player)
    local pet = _G["RealUIPetFrame"]
    if pet and db.positions[self.layoutSize] then
        pet:ClearAllPoints()
        pet:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame",
            db.positions[self.layoutSize].pet.x,
            db.positions[self.layoutSize].pet.y)
    end

    -- Reposition focus frame (anchored to player)
    local focus = _G["RealUIFocusFrame"]
    if focus and db.positions[self.layoutSize] then
        focus:ClearAllPoints()
        focus:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame",
            db.positions[self.layoutSize].focus.x,
            db.positions[self.layoutSize].focus.y)
    end

    -- Reposition focustarget frame (anchored to focus)
    local focustarget = _G["RealUIFocusTargetFrame"]
    if focustarget and db.positions[self.layoutSize] then
        focustarget:ClearAllPoints()
        focustarget:SetPoint("TOPLEFT", "RealUIFocusFrame", "BOTTOMLEFT",
            db.positions[self.layoutSize].focustarget.x,
            db.positions[self.layoutSize].focustarget.y)
    end

    -- Reposition targettarget frame (anchored to target)
    local targettarget = _G["RealUITargetTargetFrame"]
    if targettarget and db.positions[self.layoutSize] then
        targettarget:ClearAllPoints()
        targettarget:SetPoint("BOTTOMRIGHT", "RealUITargetFrame",
            db.positions[self.layoutSize].targettarget.x,
            db.positions[self.layoutSize].targettarget.y)
    end

    -- Force all frames to update their layout immediately
    if player then player:GetCenter() end
    if target then target:GetCenter() end
    if pet then pet:GetCenter() end
    if focus then focus:GetCenter() end
    if focustarget then focustarget:GetCenter() end
    if targettarget then targettarget:GetCenter() end

    -- Reposition boss frames
    for i = 1, 5 do
        local boss = _G["RealUIBossFrame" .. i]
        if boss and db.positions[self.layoutSize] then
            boss:ClearAllPoints()
            if i == 1 then
                boss:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT",
                    db.positions[self.layoutSize].boss.x,
                    db.positions[self.layoutSize].boss.y)
            else
                boss:SetPoint("TOP", _G["RealUIBossFrame" .. (i - 1)], "BOTTOM", 0, -db.boss.gap)
            end
        end
    end

    -- Reposition arena frames
    for i = 1, 5 do
        local arena = _G["RealUIArenaFrame" .. i]
        if arena and db.positions[self.layoutSize] then
            arena:ClearAllPoints()
            if i == 1 then
                arena:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT",
                    db.positions[self.layoutSize].boss.x,
                    db.positions[self.layoutSize].boss.y)
            else
                arena:SetPoint("TOP", _G["RealUIArenaFrame" .. (i - 1)], "BOTTOM", 0, -db.boss.gap)
            end
        end
    end

    -- Re-anchor FramePoint-managed frames to their drag frames and restore any
    -- LibWindow-saved positions. RepositionFrames() sets frame anchors directly,
    -- which breaks the frame -> dragFrame -> LibWindow chain for frames the user
    -- has moved in the frame editor.
    FramePoint:RestorePosition(self)
end

function UnitFrames:OnInitialize()
    ---[[
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            misc = {
                focusclick = true,
                focuskey = "shift",
                -- B27: default to "Both" so fresh installs always see HP values.
                -- The old default ("smart") isn't offered by the config dropdown
                -- (it rendered as a blank selection) and Tags.lua treats it as
                -- percent-only. NO migration for saved profiles here — that's
                -- the B47 one-time defaults nudge, handled separately.
                statusText = "both",
                statusTextOutline = "outline",
                alwaysDisplayFullHealth = true,
                showPrediction = true,
                showPrivateAuras = true,
                alternativeBarStyle = false,
                textColors = {
                    health = nil,
                    power = nil,
                    name = nil,
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
            units = {
                -- Eventually, these settings will be used to adjust unit frame size.
                player = {
                    size = {x = 259, y = 28},
                    position = {x = 0, y = 0},
                    healthHeight = 0.6, --percentage of the unit height used by the healthbar
                    reverseFill = false,
                    reverseMissing = false,
                    reversePercent = false,
                    framePoint = {},
                    buffCount = 16,
                    buffSize = 28,
                    showPlayerBuffs = true,
                    auraLayout = {
                        buffs = {
                            anchor = "TOPLEFT",
                            growthX = "RIGHT",
                            growthY = "UP",
                            maxWidth = 0,
                        },
                    },
                    healthBar = {
                        foreground = {0.08, 0.08, 0.08},
                        foregroundOpacity = 0.8,
                        background = {0.78, 0.15, 0.15},
                        backgroundOpacity = 1.0,
                        colorForegroundByClass = false,
                        colorBackgroundByClass = false,
                    },
                },
                target = {
                    size = {x = 259, y = 28},
                    position = {x = 0, y = 0},
                    healthHeight = 0.6, --percentage of the unit height used by the healthbar
                    reverseFill = false,
                    framePoint = {},
                    debuffCount = 16,
                    debuffSize = 28,
                    buffCount = 16,
                    buffSize = 28,
                    showTargetDebuffs = true,
                    showTargetBuffs = true,
                    auraLayout = {
                        debuffs = {
                            anchor = "TOPLEFT",
                            growthX = "RIGHT",
                            growthY = "UP",
                            maxWidth = 0,
                        },
                        buffs = {
                            anchor = "TOPRIGHT",
                            growthX = "LEFT",
                            growthY = "UP",
                            maxWidth = 0,
                        },
                    },
                    healthBar = {
                        foreground = {0.08, 0.08, 0.08},
                        foregroundOpacity = 0.8,
                        background = {0.78, 0.15, 0.15},
                        backgroundOpacity = 1.0,
                        colorForegroundByClass = false,
                        colorBackgroundByClass = false,
                    },
                },
                -- B14: the small (health-only) frames declare healthHeight = 1
                -- so creation (Shared.lua CreateHealthBar) and runtime resizing
                -- (ApplySize, which falls back to 0.6 when healthHeight is nil)
                -- agree on the health bar height. Without it, the first
                -- ResizeFrames call squished these bars to 60% of the frame.
                -- size.y is 13 so the (y - 3) health height stays the familiar
                -- 10px bar.
                targettarget = {
                    size = {x = 138, y = 13},
                    position = {x = 0, y = 0},
                    healthHeight = 1,
                    reverseFill = false,
                    framePoint = {},
                },
                focus = {
                    size = {x = 138, y = 13},
                    position = {x = 0, y = 0},
                    healthHeight = 1,
                    framePoint = {},
                },
                focustarget = {
                    size = {x = 126, y = 13},
                    position = {x = 0, y = 0},
                    healthHeight = 1,
                    framePoint = {},
                },
                pet = {
                    size = {x = 126, y = 13},
                    position = {x = 0, y = 0},
                    healthHeight = 1,
                    reverseFill = false,
                    framePoint = {},
                },
                arena = {
                    size = {x = 135, y = 22},
                    position = {x = 0, y = 0},
                    framePoint = {},
                },
                boss = {
                    size = {x = 135, y = 22},
                    position = {x = 0, y = 0},
                    framePoint = {},
                    healthBar = {
                        foreground = {0.08, 0.08, 0.08},
                        foregroundOpacity = 0.8,
                        background = {0.78, 0.15, 0.15},
                        backgroundOpacity = 1.0,
                        colorForegroundByClass = false,
                        colorBackgroundByClass = false,
                    },
                },
                raid = {
                    enabled = true,
                    size = {x = 70, y = 30},
                    spacing = 2,
                    rangeAlpha = 0.4,
                    icons = {
                        centerDebuff = true,
                        hots = true,
                        hotsCount = 2,
                        hotsFilter = true,
                    },
                    framePoint = {},
                    -- B31: party header sub-settings (own anchor + orientation).
                    -- Registering these here makes the guarded runtime
                    -- defaults-extension in Groups/Raid.lua a no-op.
                    party = {
                        horizontal = false,
                        framePoint = {},
                    },
                },
            },
            arena = {
                enabled = true,
                announceUse = true,
                announceChat = "GROUP",
                showCast = true,
                showPets = true,
            },
            boss = {
                gap = 3,
                -- B56: hide the boss power strip unless the encounter provides
                -- alt power. Default off = current always-visible behaviour.
                altPowerOnly = false,
                debuffCount = 16,
                debuffSize = 20,
                buffCount = 16,
                buffSize = 20,
                showBossDebuffs = true,
                showBossBuffs = true,
            },
            -- TODO: Convert to FramePoint
            positions = {
                [1] = {
                    player =       { x = 0,   y = 0},   -- Anchored to Positioner
                    pet =          { x = 51,  y = -84}, -- Anchored to Player
                    focus =        { x = 29,  y = -62}, -- Anchored to Player
                    focustarget =  { x = 11,  y = -2},  -- Anchored to Focus
                    target =       { x = 0,   y = 0},   -- Anchored to Positioner
                    targettarget = { x = -29, y = -62}, -- Anchored to Target
                    boss =         { x = 0,   y = 0},   -- Anchored to Positioner
                },
                [2] = {
                    player =       { x = 0,   y = 0},   -- Anchored to Positioner
                    pet =          { x = 60,  y = -91}, -- Anchored to Player
                    focus =        { x = 36,  y = -67}, -- Anchored to Player
                    focustarget =  { x = 12,  y = -2},  -- Anchored to Focus
                    target =       { x = 0,   y = 0},   -- Anchored to Positioner
                    targettarget = { x = -36, y = -67}, -- Anchored to Target
                    boss =         { x = 0,   y = 0},   -- Anchored to Positioner
                },
            },
            overlay = {
                bar = {
                    opacity = {
                        absorb = 0.25,          -- Absorb Bar
                    },
                },
                classColor = false,
                classColorNames = true,
            },
        },
    })
    db = self.db.profile
    ndb = RealUI.db.profile

    self.layoutSize = RealUI.cLayout or RealUI.db.char.layout.current or 1
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    CombatFader:RegisterModForFade(MODNAME, "profile", "misc", "combatfade")
    FramePoint:RegisterMod(self)
end

function UnitFrames:ResetPositions()
    -- Clear saved FramePoint positions for all units, restoring defaults
    for unitKey, unitConf in _G.next, db.units do
        if unitConf.framePoint then
            _G.wipe(unitConf.framePoint)
        end
    end
    FramePoint:RestorePosition(self)
end

function UnitFrames:OnEnable()
    -- Override the green that oUF uses
    oUF.colors.health = oUF:CreateColor(0.66, 0.22, 0.22)
    oUF.colors.power.MANA = RealUI.ColorDesaturate(0.1, oUF.colors.power.MANA)
    oUF.colors.power.MANA = RealUI.ColorShift(-0.07, oUF.colors.power.MANA)
    -- Mute the new oUF 13.4.0 class-power colors to match RealUI's subdued palette
    oUF.colors.power.ICICLES = RealUI.ColorDesaturate(0.15, oUF.colors.power.ICICLES)
    oUF.colors.power.TIP_OF_THE_SPEAR = RealUI.ColorDesaturate(0.15, oUF.colors.power.TIP_OF_THE_SPEAR)
    self:InitializeLayout()

    -- Apply saved aura toggle state after frames are spawned.
    -- Without this, frames created visible by default ignore Show/Hide settings until
    -- a config change triggers RefreshUnits.
    _G.C_Timer.After(0, function()
        self:RefreshUnits("InitAuraState")
    end)
end
