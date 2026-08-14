local _, private = ...
local NP = private.NP
local Safe = private.Safe

--[[ Standalone castbar. Shares no code or templates with Blizzard's CastingBarFrame
     (known-wow-ui-bugs #3: forbidden-table errors via its mixin chain).

     WoW 12 secret model: for nameplate units, cast name/texture/timings/booleans from
     UnitCastingInfo/UnitChannelInfo can ALL be secret. Therefore:
     - Bar progress is engine-driven: UnitCastingDuration/UnitChannelDuration duration
       objects fed to StatusBar:SetTimerDuration. No timing arithmetic, no OnUpdate.
     - notInterruptible is never stored or truth-tested. The shield and an
       uninterruptible-tint overlay are driven by Region:SetAlphaFromBoolean, which
       accepts secret booleans engine-side.
     - Secret strings/numbers pass straight into SetText/SetTexture (truth tests on
       secret strings/numbers are legal; only secret BOOLEAN truth tests throw). ]]--

-- One interrupt per class is enough to drive ready-coloring; first known spell wins.
local INTERRUPTS = {
    WARRIOR = { 6552 }, PALADIN = { 96231 }, HUNTER = { 147362, 187707 },
    ROGUE = { 1766 }, PRIEST = { 15487 }, DEATHKNIGHT = { 47528 },
    SHAMAN = { 57994 }, MAGE = { 2139 }, MONK = { 116705 },
    DRUID = { 106839 }, DEMONHUNTER = { 183752 }, EVOKER = { 351338 },
}

local interruptSpellID
local function ResolveInterruptSpell()
    interruptSpellID = nil
    local _, class = _G.UnitClass("player")
    for _, spellID in _G.ipairs(INTERRUPTS[class] or {}) do
        if _G.IsPlayerSpell(spellID) then
            interruptSpellID = spellID
            break
        end
    end
end

local function InterruptReady()
    if not interruptSpellID then return false end
    return private.SafeTest(function()
        local cooldown = _G.C_Spell.GetSpellCooldown(interruptSpellID)
        return cooldown and (cooldown.duration == 0
            or (cooldown.startTime + cooldown.duration - _G.GetTime()) <= 0.3)
    end)
end

local CastBar = {}
local MAX_STAGE_TICKS = 4

function CastBar.Create(plate)
    local db = NP.db.profile.enemy.castbar

    local bar = _G.CreateFrame("StatusBar", nil, plate)
    bar:SetPoint("TOPLEFT", plate, "BOTTOMLEFT", 0, -3)
    bar:SetPoint("TOPRIGHT", plate, "BOTTOMRIGHT", 0, -3)
    bar:SetHeight(db.height)
    bar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
    bar:SetMinMaxValues(0, 1)
    bar:Hide()

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(bar)
    bg:SetColorTexture(0.086, 0.086, 0.086, 0.9)

    local border = private.CreateBorder(bar)

    -- Uninterruptible tint over the fill; alpha driven engine-side by the secret bool.
    local uninterruptible = bar:CreateTexture(nil, "OVERLAY", nil, 1)
    uninterruptible:SetAllPoints(bar)
    local uColor = db.colors.uninterruptible
    uninterruptible:SetColorTexture(uColor.r, uColor.g, uColor.b, 0.9)
    uninterruptible:SetAlpha(0)

    local icon = bar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(db.height + NP.db.profile.enemy.health.height + 3,
                 db.height + NP.db.profile.enemy.health.height + 3)
    icon:SetPoint("TOPRIGHT", plate, "TOPLEFT", -4, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local shield = bar:CreateTexture(nil, "OVERLAY", nil, 2)
    shield:SetSize(10, 12)
    shield:SetPoint("RIGHT", bar, "LEFT", -2, 0)
    Safe(shield.SetAtlas, shield, "nameplates-InterruptShield", false)
    shield:SetAlpha(0)

    local spellText = bar:CreateFontString(nil, "OVERLAY")
    private.ApplyFont(spellText, 9)
    spellText:SetPoint("TOP", bar, "BOTTOM", 0, -1)
    spellText:SetWordWrap(false)

    -- Interrupted flash: parented to the plate (survives bar:Hide()), anchored to
    -- the bar's rect.
    local flash = plate:CreateTexture(nil, "OVERLAY")
    flash:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
    flash:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    local iColor = db.colors.interrupted
    flash:SetColorTexture(iColor.r, iColor.g, iColor.b, 0.9)
    flash:Hide()

    local ticks = {}
    for i = 1, MAX_STAGE_TICKS do
        ticks[i] = bar:CreateTexture(nil, "OVERLAY")
        ticks[i]:SetColorTexture(0, 0, 0, 0.8)
        ticks[i]:SetSize(1, db.height)
        ticks[i]:Hide()
    end

    plate.CastBar = {
        bar = bar, border = border, icon = icon, shield = shield,
        uninterruptible = uninterruptible, spellText = spellText,
        flash = flash, ticks = ticks,
    }
end

local function HideTicks(cast)
    for i = 1, MAX_STAGE_TICKS do cast.ticks[i]:Hide() end
end

-- Base fill color: interrupt-readiness (our own cooldown — plain data) or empowered.
-- The uninterruptible overlay masks this when the cast is protected.
local function ApplyCastColor(plate)
    local colors = NP.db.profile.enemy.castbar.colors
    local color
    if plate.state.castEmpowered then
        color = colors.empowered
    else
        color = InterruptReady() and colors.interruptReady or colors.interruptNotReady
    end
    plate.CastBar.bar:SetStatusBarColor(color.r, color.g, color.b)
end

local function LayoutEmpowerTicks(plate)
    local cast = plate.CastBar
    HideTicks(cast)
    Safe(function()
        local percentages = _G.UnitEmpoweredStagePercentages(plate.unit)
        if not percentages then return end
        local width = cast.bar:GetWidth()
        for i = 1, _G.math.min(#percentages, MAX_STAGE_TICKS) do
            local fraction = percentages[i]
            if fraction > 1 then fraction = fraction / 100 end
            if fraction > 0 and fraction < 1 then
                local tick = cast.ticks[i]
                tick:ClearAllPoints()
                tick:SetPoint("LEFT", cast.bar, "LEFT", width * fraction, 0)
                tick:Show()
            end
        end
    end)
end

local function StopCast(plate, interrupted)
    local cast = plate.CastBar
    local state = plate.state
    state.casting, state.castChannel, state.castEmpowered = nil, nil, nil
    cast.bar:Hide()
    HideTicks(cast)
    private.UpdateHealthColor(plate)

    if interrupted then
        cast.flash:Show()
        local token = {}
        state.castLinger = token
        _G.C_Timer.After(0.6, function()
            if state.castLinger == token then
                state.castLinger = nil
                cast.flash:Hide()
            end
        end)
    end
end

local function StartCast(plate, isChannel)
    if plate.design ~= "enemy" or not NP.db.profile.enemy.castbar.enabled then return end
    local unit = plate.unit
    local cast = plate.CastBar
    local state = plate.state

    local name, texture, notInterruptible, duration
    local direction = _G.Enum.StatusBarTimerDirection.ElapsedTime
    local empowered = false
    if isChannel then
        local spellName, _, tex, _, _, _, notInt, _, isEmpowered = _G.UnitChannelInfo(unit)
        name, texture, notInterruptible = spellName, tex, notInt
        -- isEmpowered may be a secret boolean; inaccessible → treat as plain channel.
        empowered = private.SafeBool(isEmpowered) or false
        if empowered then
            duration = Safe(_G.UnitEmpoweredChannelDuration, unit)
        else
            duration = Safe(_G.UnitChannelDuration, unit)
            direction = _G.Enum.StatusBarTimerDirection.RemainingTime
        end
    else
        local spellName, _, tex, _, _, _, _, notInt = _G.UnitCastingInfo(unit)
        name, texture, notInterruptible = spellName, tex, notInt
        duration = Safe(_G.UnitCastingDuration, unit)
    end
    if not name or not duration then return end

    state.castLinger = nil
    cast.flash:Hide()
    state.casting = true
    state.castChannel = isChannel
    state.castEmpowered = empowered or nil

    -- Engine-driven progress; no timing arithmetic on our side.
    if not private.Try(cast.bar.SetTimerDuration, cast.bar, duration, nil, direction) then
        return StopCast(plate, false)
    end

    cast.icon:SetTexture(texture or 136243)  -- fallback: generic cog icon fileID
    cast.icon:SetShown(NP.db.profile.enemy.castbar.icon)
    if NP.db.profile.enemy.texts.spellName then
        Safe(cast.spellText.SetText, cast.spellText, name)
        cast.spellText:Show()
    else
        cast.spellText:Hide()
    end

    -- Secret-boolean-safe: engine resolves the alpha from the boolean.
    private.Try(cast.shield.SetAlphaFromBoolean, cast.shield, notInterruptible, 1, 0)
    private.Try(cast.uninterruptible.SetAlphaFromBoolean, cast.uninterruptible, notInterruptible, 0.9, 0)

    ApplyCastColor(plate)
    if empowered then
        LayoutEmpowerTicks(plate)
    else
        HideTicks(cast)
    end
    cast.bar:Show()
    private.UpdateHealthColor(plate)
end

function CastBar.Attach(plate, unit)
    if plate.design ~= "enemy" then return end
    -- Pick up casts already in progress when the plate appears. Truth tests on
    -- secret strings are legal; wrap anyway in case the API itself throws.
    if private.SafeTest(function() return _G.UnitCastingInfo(unit) end) then
        StartCast(plate, false)
    elseif private.SafeTest(function() return _G.UnitChannelInfo(unit) end) then
        StartCast(plate, true)
    end
end

function CastBar.Detach(plate)
    local cast = plate.CastBar
    cast.bar:Hide()
    cast.icon:Hide()
    cast.spellText:Hide()
    cast.flash:Hide()
    HideTicks(cast)
    plate.state.castLinger = nil
end

function CastBar.OnCastStart(plate)
    StartCast(plate, false)
end

function CastBar.OnChannelStart(plate)
    StartCast(plate, true)
end

function CastBar.OnCastUpdate(plate)
    -- Delayed/updated cast: re-read a fresh duration object.
    if plate.state.casting then
        StartCast(plate, plate.state.castChannel)
    end
end

function CastBar.OnCastStop(plate)
    if plate.state.casting then StopCast(plate, false) end
end

function CastBar.OnCastInterrupted(plate)
    if plate.state.casting then StopCast(plate, true) end
end

function CastBar.OnInterruptibleChanged(plate)
    -- Re-read the (possibly secret) flag and let the engine re-resolve the alphas.
    if not plate.state.casting then return end
    local unit = plate.unit
    local cast = plate.CastBar
    local notInterruptible
    if plate.state.castChannel then
        notInterruptible = _G.select(7, _G.UnitChannelInfo(unit))
    else
        notInterruptible = _G.select(8, _G.UnitCastingInfo(unit))
    end
    private.Try(cast.shield.SetAlphaFromBoolean, cast.shield, notInterruptible, 1, 0)
    private.Try(cast.uninterruptible.SetAlphaFromBoolean, cast.uninterruptible, notInterruptible, 0.9, 0)
end

function CastBar.OnTick(plate, doSlow)
    -- Our interrupt cooldown state can change without a unit event; refresh the base
    -- color on slow ticks (the uninterruptible overlay masks it when irrelevant).
    if doSlow and plate.state.casting then
        ApplyCastColor(plate)
    end
end

-- Live size updates from config (health width/height + castbar height sliders).
function CastBar.OnDimensionsChanged(plate)
    local db = NP.db.profile.enemy
    local cast = plate.CastBar
    cast.bar:SetHeight(db.castbar.height)
    local iconSize = db.castbar.height + db.health.height + 3
    cast.icon:SetSize(iconSize, iconSize)
    for i = 1, MAX_STAGE_TICKS do
        cast.ticks[i]:SetHeight(db.castbar.height)
    end
end

function CastBar.OnEnable()
    ResolveInterruptSpell()
    NP:RegisterEvent("SPELLS_CHANGED", ResolveInterruptSpell)
end

private.RegisterUnitEvent("UNIT_SPELLCAST_START", "OnCastStart")
private.RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "OnCastUpdate")
private.RegisterUnitEvent("UNIT_SPELLCAST_STOP", "OnCastStop")
private.RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "OnCastStop")
private.RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "OnCastInterrupted")
private.RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "OnChannelStart")
private.RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "OnCastUpdate")
private.RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "OnCastStop")
private.RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "OnChannelStart")
private.RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "OnCastUpdate")
private.RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "OnCastStop")
private.RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "OnInterruptibleChanged")
private.RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "OnInterruptibleChanged")

private.AddElement("CastBar", CastBar)
