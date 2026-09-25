local _, private = ...

-- Libs --
local oUF = private.oUF

-- Libs --
local Base = _G.Aurora.Base
local Color = _G.Aurora.Color

-- RealUI --
local RealUI = private.RealUI
local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")

-- B56: HuD castbar colours (HuD/CastBars.lua), so boss casts read like the
-- target's. The uninterruptible tint is a texture whose alpha the engine sets
-- from the (possibly secret) notInterruptible flag.
local CAST_INTERRUPTIBLE = Color.Create(0.5, 1.0, 1.0)
local CAST_UNINTERRUPTIBLE = Color.Create(0.5, 0.0, 0.0)
local CASTBAR_HEIGHT = 10

local function SetCastTint(castbar, notInterruptible)
    _G.pcall(castbar.Tint.SetAlphaFromBoolean, castbar.Tint, notInterruptible, 1, 0)
end
local function PostCastStart(castbar, _, _, notInterruptible)
    SetCastTint(castbar, notInterruptible)
end
local function PostCastInterruptible(castbar, _, _, notInterruptible)
    SetCastTint(castbar, notInterruptible)
end

local function CreateCastbar(dialog)
    local Castbar = _G.CreateFrame("StatusBar", nil, dialog)
    Castbar:SetPoint("TOPLEFT", dialog, "BOTTOMLEFT", 0, -2)
    Castbar:SetPoint("TOPRIGHT", dialog, "BOTTOMRIGHT", 0, -2)
    Castbar:SetHeight(CASTBAR_HEIGHT)
    Castbar:SetStatusBarTexture(RealUI.textures.plain)
    Castbar:SetStatusBarColor(CAST_INTERRUPTIBLE:GetRGB())
    Base.SetBackdrop(Castbar, Color.black, 0.7)

    local Tint = Castbar:CreateTexture(nil, "ARTWORK", nil, 1)
    Tint:SetAllPoints(Castbar)
    Tint:SetColorTexture(CAST_UNINTERRUPTIBLE:GetRGB())
    Tint:SetAlpha(0)
    Castbar.Tint = Tint

    local Text = Castbar:CreateFontString(nil, "OVERLAY")
    Text:SetFontObject("SystemFont_Shadow_Small")
    Text:SetPoint("LEFT", Castbar, 2, 0)
    Text:SetPoint("RIGHT", Castbar, -30, 0)
    Text:SetJustifyH("LEFT")
    Text:SetWordWrap(false)
    Castbar.Text = Text

    local Time = Castbar:CreateFontString(nil, "OVERLAY")
    Time:SetFontObject("SystemFont_Shadow_Small")
    Time:SetPoint("RIGHT", Castbar, -2, 0)
    Castbar.Time = Time

    Castbar.PostCastStart = PostCastStart
    Castbar.PostCastInterruptible = PostCastInterruptible
    return Castbar
end

-- B56: which of the five is your target. UnitIsUnit can be secret, so the
-- engine resolves the border's alpha from it.
local function UpdateTargetHighlight(dialog)
    local highlight = dialog.TargetHighlight
    if not highlight then return end
    local unit = dialog.__unit
    local exists = unit and _G.UnitExists(unit)
    if _G.issecretvalue(exists) then exists = true end
    if not exists or not dialog.showTargetHighlight then
        highlight:SetAlpha(0)
        return
    end
    if not _G.pcall(highlight.SetAlphaFromBoolean, highlight, _G.UnitIsUnit(unit, "target"), 1, 0) then
        highlight:SetAlpha(0)
    end
end

local function CreateTargetHighlight(dialog)
    local highlight = _G.CreateFrame("Frame", nil, dialog)
    highlight:SetPoint("TOPLEFT", dialog, -2, 2)
    highlight:SetPoint("BOTTOMRIGHT", dialog, 2, -2)
    highlight:SetFrameLevel(dialog:GetFrameLevel())
    Base.SetBackdrop(highlight, Color.highlight, 0)
    highlight:SetBackdropBorderColor(Color.highlight:GetRGB())
    highlight:SetAlpha(0)
    dialog.TargetHighlight = highlight
    dialog.showTargetHighlight = UnitFrames.db.profile.boss.targetHighlight ~= false

    local function update() UpdateTargetHighlight(dialog) end
    dialog:RegisterEvent("PLAYER_TARGET_CHANGED", update, true)
    dialog:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", update, true)
    dialog:HookScript("OnShow", update)
end
UnitFrames.UpdateBossTargetHighlight = UpdateTargetHighlight

UnitFrames.boss = {
    create = function(dialog)

        dialog.Health.text:SetPoint("LEFT", dialog.Health, 1, 0)
        dialog.Power.displayAltPower = true
        -- B56: optionally hide the power strip unless the encounter supplies
        -- alternative power (oUF 14.0.1 displayAltPowerOnly). Off by default —
        -- always-visible power keeps boss mana readable on drain/interrupt
        -- fights. oUF re-Shows the element on the next update when cleared.
        local bossDB = UnitFrames.db.profile.boss
        dialog.Power.displayAltPowerOnly = (bossDB and bossDB.altPowerOnly) or nil

        dialog.Name = dialog.Health:CreateFontString(nil, "OVERLAY")
        dialog.Name:SetPoint("RIGHT", dialog.Health, -1, 0)
        dialog.Name:SetFontObject("SystemFont_Shadow_Med1")
        dialog.Name:SetJustifyH("RIGHT")
        dialog:Tag(dialog.Name, "[realui:name]")

        dialog.RaidTargetIndicator = dialog:CreateTexture(nil, "OVERLAY")
        dialog.RaidTargetIndicator:SetSize(20, 20)
        dialog.RaidTargetIndicator:SetPoint("CENTER", dialog)

        -- Boss Debuffs (oUF 14: AuraContainer elements; boss anchors are
        -- fixed, so positioning stays a direct SetPoint here)
        -- B34: boss frames sit at the right screen edge, so debuffs hang off
        -- the frame's LEFT edge and grow LEFT (toward screen center). The
        -- container auto-sizes to content with its RIGHT edge pinned, and
        -- wrapped rows stay vertically centered on the frame.
        local db = UnitFrames.db.profile
        local bossDB = db.boss or {}
        local layout = bossDB.auraLayout or {}

        -- B56: filter/sort/cutoff from the same presets as the target frame
        -- (default "Cast by me" — plain HARMFUL was every raider's debuffs).
        local filter, candidates, sortMethod, sortDirection =
            UnitFrames.ResolveAuraFilter("HARMFUL", layout.debuffs)
        local Debuffs = UnitFrames.CreateAuraElement(dialog, {
            filter = filter, candidates = candidates,
            sortMethod = sortMethod, sortDirection = sortDirection,
            count = bossDB.debuffCount or 16,
            size = bossDB.debuffSize or 20,
            spacing = 2,
            growthX = "LEFT",
            growthY = "UP",
        })
        Debuffs:SetPoint("RIGHT", dialog, "LEFT", -4, 0)
        dialog.Debuffs = Debuffs

        -- Boss Buffs. B56: these hung below the frame and grew DOWN into the
        -- next boss frame 3px away. They now sit left of the debuffs, growing
        -- left, so the column of five frames stays clear. Default filter
        -- "Dispellable": the buffs you can act on.
        filter, candidates, sortMethod, sortDirection =
            UnitFrames.ResolveAuraFilter("HELPFUL", layout.buffs)
        local Buffs = UnitFrames.CreateAuraElement(dialog, {
            filter = filter, candidates = candidates,
            sortMethod = sortMethod, sortDirection = sortDirection,
            count = bossDB.buffCount or 16,
            size = bossDB.buffSize or 20,
            spacing = 2,
            growthX = "LEFT",
            growthY = "UP",
        })
        Buffs:SetPoint("RIGHT", Debuffs, "LEFT", -4, 0)
        dialog.Buffs = Buffs

        -- B56: boss cast bar under the frame (the gap default makes room).
        -- oUF enables elements after this style function, so a disabled bar is
        -- kept aside rather than handed to oUF; RefreshUnits toggles it live.
        dialog._ruiCastbar = CreateCastbar(dialog)
        if bossDB.showCastbar ~= false then
            dialog.Castbar = dialog._ruiCastbar
        else
            dialog._ruiCastbar:Hide()
        end

        CreateTargetHighlight(dialog)
    end,
    health = {
        text = true,
    },
    power = {
    },
}

-- Init
_G.tinsert(UnitFrames.units, function()
    local db = UnitFrames.db.profile

    for i = 1, 5 do
        local boss = oUF:Spawn("boss" .. i, "RealUIBossFrame" .. i)
        if i == 1 then
            boss:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", db.positions[UnitFrames.layoutSize].boss.x, db.positions[UnitFrames.layoutSize].boss.y)
            FramePoint:PositionFrame(UnitFrames, boss, {"profile", "units", "boss", "framePoint"})
        else
            boss:SetPoint("TOP", _G["RealUIBossFrame" .. i - 1], "BOTTOM", 0, -db.boss.gap)
        end
    end
end)
