local _, private = ...

-- Lua Globals --
local floor = _G.math.floor

-- Libs --
local oUF = private.oUF
local Base = _G.Aurora.Base
local Color = _G.Aurora.Color

-- RealUI --
local RealUI = private.RealUI
local UnitFrames = RealUI:GetModule("UnitFrames")

--[[ Utils ]]--
local function TimeFormat(t)
    local h, m, hplus, mplus, s, f

    h = floor(t / 3600)
    m = floor((t - (h * 3600)) / 60)
    s = floor(t - (h * 3600) - (m * 60))

    hplus = floor((t + 3599.99) / 3600)
    mplus = floor((t - (h * 3600) + 59.99) / 60) -- provides compatibility with tooltips

    if t >= 3600 then
        f = ("%.0fh"):format(hplus)
    elseif t >= 60 then
        f = ("%.0fm"):format(mplus)
    else
        f = ("%.0fs"):format(s)
    end

    return f
end

local function AttachStatusBar(button)
    --print("AttachStatusBar")
    local sBar = _G.CreateFrame("StatusBar", "$parentStatusBar", button)
    sBar:SetMinMaxValues(0, 1)
    sBar:SetStatusBarTexture(RealUI.textures.plain)
    sBar:SetStatusBarColor(1,1,1,1)

    sBar:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, 2)
    sBar:SetPoint("BOTTOMRIGHT", button)
    sBar:SetFrameLevel(button:GetFrameLevel() + 2)

    Base.SetBackdrop(sBar, Color.black, 0.7)
    sBar:SetBackdropOption("offsets", {
        left = -1,
        right = -1,
        top = -1,
        bottom = -1,
    })

    local timeStr = button:CreateFontString(nil, "OVERLAY")
    timeStr:SetFontObject("NumberFont_Outline_Med")
    timeStr:SetPoint("CENTER", button, 0, 0)
    timeStr:SetJustifyH("LEFT")

    return sBar, timeStr
end

--[[ Parts ]]--
local function CreateAuras(parent)
    local bossDB = UnitFrames.db.profile.boss
    local iconSize = parent:GetHeight()
    local frameWidth = iconSize * (bossDB.buffCount + bossDB.debuffCount)

    UnitFrames:debug("Boss:CreateAuras")
    local auras = _G.CreateFrame("Frame", nil, parent)
    auras:SetPoint("TOPRIGHT", parent, "TOPLEFT", -3, 0)
    auras:SetSize(frameWidth, iconSize)

    auras.disableCooldown = true
    auras.size = iconSize
    auras.spacing = 3
    auras["growth-x"] = "LEFT"
    auras.initialAnchor = "TOPRIGHT"

    auras.numBuffs = bossDB.buffCount
    auras.numDebuffs = bossDB.debuffCount

    -- oUF can perform partial UNIT_AURA updates before a full update;
    -- ensure these caches exist to avoid nil-index assignment errors.
    auras.allBuffs = auras.allBuffs or {}
    auras.activeBuffs = auras.activeBuffs or {}
    auras.allDebuffs = auras.allDebuffs or {}
    auras.activeDebuffs = auras.activeDebuffs or {}
    auras.sortedBuffs = auras.sortedBuffs or {}
    auras.sortedDebuffs = auras.sortedDebuffs or {}

    auras.FilterAura = function(dialog, unit, data)
        --    name, texture, count, debuffType, duration, expiration, caster
        local duration, expiration, sourceUnit = data.duration, data.expirationTime, data.sourceUnit

        -- Early return if sourceUnit is nil, secret, or not a string
        if not sourceUnit then return false end
        if RealUI.isSecret(sourceUnit) then return false end
        if type(sourceUnit) ~= "string" then return false end

        UnitFrames:debug("Boss:FilterAura", dialog, unit, duration, expiration, sourceUnit)


        -- Cast by Player
        if data.isPlayerAura and UnitFrames.db.profile.boss.showPlayerAuras then return true end

        -- Cast by NPC
        if UnitFrames.db.profile.boss.showNPCAuras then
            local guid = _G.UnitGUID(sourceUnit)
            -- Check if guid is secret before attempting string operations
            if guid and not RealUI.isSecret(guid) and type(guid) == "string" then
                local unitType = _G.strsplit("-", guid)
                local isNPC = (unitType == "Creature")
                return isNPC
            end
        end

        return false
    end
    auras.PostCreateButton = function(dialog, button)
        UnitFrames:debug("Boss:PostCreateButton", dialog, button)
        Base.CropIcon(button.Icon, button)
        button.Count:SetFontObject("NumberFont_Outline_Med")

        button.sCooldown, button.timeStr = AttachStatusBar(button)
        button.elapsed = 0
        button.interval = 1/4
        button:SetScript("OnUpdate", function(this, elapsed)
            if this.endTime then
                this.elapsed = this.elapsed + elapsed
                if this.elapsed >= this.interval or this.needsUpdate then
                    this.elapsed = 0

                    local now = _G.GetTime()
                    this.sCooldown:SetValue(this.endTime - now)
                    this.timeStr:SetText(TimeFormat(_G.ceil(this.endTime - now)))

                    local per = (this.endTime - now) / (this.endTime - this.startTime)
                    if per > 0.5 then
                        this.sCooldown:SetStatusBarColor(1 - ((per*2)-1), 1, 0)
                    else
                        this.sCooldown:SetStatusBarColor(1, (per*2), 0)
                    end
                end
            else
                --print("HideIcon", ico.startTime, ico.endTime)
                this.sCooldown:Hide()
                this.timeStr:SetText()
            end
        end)
    end
    auras.PostUpdateButton = function(dialog, button, unit, data, position)
        UnitFrames:debug("Boss:PostUpdateButton", dialog, unit, button, position)

        local duration, expiration = data.duration, data.expirationTime
        if duration and duration > 0 then
            button.startTime = expiration - duration
            button.endTime = expiration

            button.sCooldown:Show()
            button.sCooldown:SetMinMaxValues(0, button.endTime - button.startTime)
        else
            button.endTime = nil
        end
        data.needsUpdate = true
    end
    -- auras.showType = true
    -- auras.showStealableAuras = true

    parent.Auras = auras
end

UnitFrames.boss = {
    create = function(dialog)
        CreateAuras(dialog)
        dialog.Health.text:SetPoint("LEFT", dialog.Health, 1, 0)
        dialog.Power.displayAltPower = true

        dialog.Name = dialog.Health:CreateFontString(nil, "OVERLAY")
        dialog.Name:SetPoint("RIGHT", dialog.Health, -1, 0)
        dialog.Name:SetFontObject("SystemFont_Shadow_Med1")
        dialog.Name:SetJustifyH("RIGHT")
        dialog:Tag(dialog.Name, "[realui:name]")

        dialog.RaidTargetIndicator = dialog:CreateTexture(nil, 'OVERLAY')
        dialog.RaidTargetIndicator:SetSize(20, 20)
        dialog.RaidTargetIndicator:SetPoint("CENTER", dialog)
    end,
    health = {
        text = "[realui:healthPercent]",
    },
    power = {
    },
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    local db = UnitFrames.db.profile

    for i = 1, _G.MAX_BOSS_FRAMES do
        local boss = oUF:Spawn("boss" .. i, "RealUIBossFrame" .. i)
        if (i == 1) then
            boss:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", db.positions[UnitFrames.layoutSize].boss.x, db.positions[UnitFrames.layoutSize].boss.y)
        else
            boss:SetPoint("TOP", _G["RealUIBossFrame" .. i - 1], "BOTTOM", 0, -db.boss.gap)
        end
    end
end)
