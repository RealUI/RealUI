local _, private = ...

-- Lua Globals --
local _G = _G
local floor = _G.math.floor

-- Libs --
local oUF = _G.oUFembed
local F = _G.Aurora[1]

-- RealUI --
local RealUI = private.RealUI
local db, ndb

local UnitFrames = RealUI:GetModule("UnitFrames")

local prepFrames = {}

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

local function UnitCastUpdate(self, event, unitID, spell, rank, lineID, spellID)
    --print(self.unit, event, unitID, spell, rank, lineID, spellID)
    if spellID == 59752 or spellID == 42292 then
        local startTime, duration = _G.GetSpellCooldown(spellID)
        self.Trinket.startTime = startTime
        self.Trinket.endTime = startTime + duration
        if db.arena.announceUse then
            local chat = db.arena.announceChat
            if chat == "GROUP" then
                chat = "INSTANCE_CHAT"
            end
            _G.SendChatMessage("Trinket used by: ".._G.GetUnitName(unitID, true), chat)
        end
    end
end

local function UpdatePrep(self, event, ...)
    UnitFrames:debug("Arena:----- UpdatePrep -----")
    local notVisible = _G.UnitAffectingCombat("player") and "SetAlpha" or "Hide"
    if event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
        UnitFrames:debug(event)
        local numOpps = _G.GetNumArenaOpponentSpecs()
        for i = 1, 5 do
            local opp = prepFrames[i]
            if (i <= numOpps) then
                local specID, gender = _G.GetArenaOpponentSpec(i)
                --print("Opponent", i, "specID:", specID, "gender:", gender)
                if (specID > 0) then
                    local _, _, _, specIcon = _G.GetSpecializationInfoByID(specID, gender)
                    opp.icon:SetTexture(specIcon)
                    opp:Show()
                else
                    opp:Hide()
                end
            else
                opp[notVisible](opp, 0)
            end
        end
    else
        UnitFrames:debug(event, ...)
        local unit, status = ...
        -- filter arenapet*
        unit = unit:match("arena(%d)")
        UnitFrames:debug(unit, prepFrames[unit])
        if unit then
            local opp = prepFrames[_G.tonumber(unit)]
            if status == "seen" then
                UnitFrames:debug("Arena Opp Seen", unit, opp)
                opp:SetAlpha(1)
            elseif status == "destroyed" then
                UnitFrames:debug("Arena Opp Destroyed", unit, opp)
                opp:SetAlpha(0)
            elseif status == "cleared" then
                UnitFrames:debug("Arena Opp Cleared", unit, opp)
                opp[notVisible](opp, 0)
            end
        end
    end
end

--[[ Parts ]]--
local function CreateHealthBar(parent)
    parent.Health = _G.CreateFrame("StatusBar", nil, parent)
    parent.Health:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 3)
    parent.Health:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    parent.Health:SetStatusBarTexture(RealUI.media.textures.plain)
    local color = parent.colors.health
    parent.Health:SetStatusBarColor(color[1], color[2], color[3], color[4])
    parent.Health.frequentUpdates = true
    if not(ndb.settings.reverseUnitFrameBars) then
        parent.Health:SetReverseFill(true)
        parent.Health.PostUpdate = function(self, unit, min, max)
            self:SetValue(max - self:GetValue())
        end
    end

    F.CreateBDFrame(parent.Health, 0)
end

local function CreateTags(parent)
    parent.HealthValue = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.HealthValue:SetPoint("TOPLEFT", parent.Health, "TOPLEFT", 2.5, -6.5)
    parent.HealthValue:SetFontObject(_G.RealUIFont_Pixel)
    parent.HealthValue:SetJustifyH("LEFT")
    parent:Tag(parent.HealthValue, "[realui:healthPercent]")

    parent.Name = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.Name:SetPoint("TOPRIGHT", parent.Health, "TOPRIGHT", -0.5, -6.5)
    parent.Name:SetFontObject(_G.RealUIFont_Pixel)
    parent.Name:SetJustifyH("RIGHT")
    parent:Tag(parent.Name, "[realui:name]")
end

local function CreatePowerBar(parent)
    parent.Power = _G.CreateFrame("StatusBar", nil, parent)
    parent.Power:SetFrameStrata("MEDIUM")
    parent.Power:SetFrameLevel(6)
    parent.Power:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    parent.Power:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 2)
    parent.Power:SetStatusBarTexture(RealUI.media.textures.plain)
    local color = parent.colors.power["MANA"]
    parent.Power:SetStatusBarColor(color[1], color[2], color[3], color[4])
    parent.Power.colorPower = true
    parent.Power.PostUpdate = function(bar, unit, min, max)
        bar:SetShown(max > 0)
    end

    F.CreateBDFrame(parent.Power, 0)
end

local function CreateTrinket(parent)
    local trinket = _G.CreateFrame("Frame", nil, parent)
    trinket:SetSize(22, 22)
    trinket:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -3, 0)
    trinket:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= self.interval then
            self.elapsed = 0
            if self.startTime and self.endTime then
                --print("UpdateIcon", self.startTime, self.endTime)
                if self.needsUpdate then
                    self.timer:Show()
                    self.timer:SetMinMaxValues(0, self.endTime - self.startTime)
                end

                local now = _G.GetTime()
                self.timer:SetValue(self.endTime - now)
                self.text:SetText(TimeFormat(_G.ceil(self.endTime - now)))

                local per = (self.endTime - now) / (self.endTime - self.startTime)
                if per > 0.5 then
                    self.timer:SetStatusBarColor(1 - ((per*2)-1), 1, 0)
                else
                    self.timer:SetStatusBarColor(1, (per*2), 0)
                end
            else
                --print("HideIcon", self.startTime, self.endTime)
                self.timer:Hide()
                self.text:SetText()
            end
        end
    end)
    trinket.elapsed = 0
    trinket.interval = 1/4

    trinket.icon = trinket:CreateTexture(nil, "BACKGROUND")
    trinket.icon:SetAllPoints()
    trinket.icon:SetTexture([[Interface\Icons\PVPCurrency-Conquest-Horde]])
    trinket.icon:SetTexCoord(.08, .92, .08, .92)
    F.ReskinIcon(trinket.icon)

    trinket.timer = _G.CreateFrame("StatusBar", nil, trinket)
    trinket.timer:SetMinMaxValues(0, 1)
    trinket.timer:SetStatusBarTexture(RealUI.media.textures.plain)
    trinket.timer:SetStatusBarColor(1,1,1,1)

    trinket.timer:SetPoint("BOTTOMLEFT", trinket, "BOTTOMLEFT", 1, 1)
    trinket.timer:SetPoint("TOPRIGHT", trinket, "BOTTOMRIGHT", -1, 3)
    trinket.timer:SetFrameLevel(trinket:GetFrameLevel() + 2)
    F.CreateBDFrame(trinket.timer)

    trinket.text = trinket:CreateFontString(nil, "OVERLAY")
    trinket.text:SetFontObject(_G.RealUIFont_PixelSmall)
    trinket.text:SetPoint("BOTTOMLEFT", trinket, "BOTTOMLEFT", 1.5, 4)
    trinket.text:SetJustifyH("LEFT")
    parent.Trinket = trinket
end

local function CreateArena(self)
    --print("CreateArena", self.unit)
    self:SetSize(135, 22)
    F.CreateBD(self, 0.7)

    CreateHealthBar(self)
    CreateTags(self)
    CreatePowerBar(self)
    CreateTrinket(self)

    self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')
    self.RaidIcon:SetSize(21, 21)
    self.RaidIcon:SetPoint("CENTER", self)

    self:SetScript("OnEnter", _G.UnitFrame_OnEnter)
    self:SetScript("OnLeave", _G.UnitFrame_OnLeave)
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UnitCastUpdate)
end

local function SetupPrepFrames(index)
    UnitFrames:debug("SetupPrepFrames")
    local prep = _G.CreateFrame("Frame", nil, _G.UIParent)
    if (index == 1) then
        prep:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", db.positions[UnitFrames.layoutSize].boss.x, db.positions[UnitFrames.layoutSize].boss.y)
    else
        prep:SetPoint("TOP", prepFrames[index - 1], "BOTTOM", 0, -db.boss.gap)
    end
    prep:SetSize(22, 22)
    prep:Hide()
    prep.icon = prep:CreateTexture(nil, 'OVERLAY')
    prep.icon:SetAllPoints()
    prep.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    F.ReskinIcon(prep.icon)
    prepFrames[index] = prep
end

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = RealUI.db.profile
    if not db.arena.enabled then return end

    oUF:RegisterStyle("RealUI:arena", CreateArena)
    oUF:SetActiveStyle("RealUI:arena")
    -- Bosses and arenas are mutually excusive, so we'll just use some boss stuff for both for now.
    for i = 1, _G.MAX_BOSS_FRAMES do
        SetupPrepFrames(i)
        local arena = oUF:Spawn("arena" .. i, "RealUIArenaFrame" .. i)
        arena:SetPoint("RIGHT", prepFrames[i], "LEFT", -3, 0)
    end
    prepFrames[1]:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
    prepFrames[1]:RegisterEvent("ARENA_OPPONENT_UPDATE")
    prepFrames[1]:SetScript("OnEvent", UpdatePrep)
end)
