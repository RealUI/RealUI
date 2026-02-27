local _, private = ...

-- Libs --
local oUF = private.oUF
local Base = _G.Aurora.Base
local Color = _G.Aurora.Color

-- RealUI --
local RealUI = private.RealUI
local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")

--[[ Trinket Cooldown ]]--
local function TimeFormat(seconds)
    if seconds >= 3600 then
        return ("%.0fh"):format(_G.math.ceil(seconds / 3600))
    elseif seconds >= 60 then
        return ("%.0fm"):format(_G.math.ceil(seconds / 60))
    else
        return ("%.0fs"):format(seconds)
    end
end

local function UpdateCC(self, event, unit)
    local spellID, startTime, duration = _G.C_PvP.GetArenaCrowdControlInfo(unit)
    if spellID then
        if startTime ~= 0 and duration ~= 0 then
            self.Trinket:SetCooldown(startTime / 1000.0, duration / 1000.0)
            if not self.hasAnnounced then
                local arenaDB = UnitFrames.db.profile.arena
                if arenaDB.announceUse then
                    local chat = arenaDB.announceChat
                    if chat == "GROUP" then
                        chat = "INSTANCE_CHAT"
                    end
                    _G.C_ChatInfo.SendChatMessage("Trinket used by: " .. _G.GetUnitName(unit, true), chat)
                end
                self.hasAnnounced = true
            end
        else
            self.Trinket:Clear()
            self.hasAnnounced = false
        end
    end
end

--[[ Trinket Indicator ]]--
local function CreateTrinket(parent)
    local iconSize = parent:GetHeight()

    local trinket = _G.CreateFrame("Frame", nil, parent)
    trinket:SetSize(iconSize, iconSize)
    trinket:SetPoint("TOPRIGHT", parent, "TOPLEFT", -3, 0)
    trinket:SetScript("OnUpdate", function(dialog, elapsed)
        dialog.elapsed = dialog.elapsed + elapsed
        if dialog.elapsed >= dialog.interval then
            dialog.elapsed = 0
            if dialog.startTime and dialog.endTime then
                local now = _G.GetTime()
                local remaining = dialog.endTime - now
                if remaining <= 0 then
                    dialog.timer:Hide()
                    dialog.text:SetText("")
                    dialog.startTime = nil
                    dialog.endTime = nil
                    return
                end
                dialog.timer:SetValue(remaining)
                dialog.text:SetText(TimeFormat(remaining))

                local per = remaining / (dialog.endTime - dialog.startTime)
                if per > 0.5 then
                    dialog.timer:SetStatusBarColor(1 - ((per * 2) - 1), 1, 0)
                else
                    dialog.timer:SetStatusBarColor(1, per * 2, 0)
                end
            else
                dialog.timer:Hide()
                dialog.text:SetText("")
            end
        end
    end)
    trinket.elapsed = 0
    trinket.interval = 1 / 4

    trinket.icon = trinket:CreateTexture(nil, "BACKGROUND")
    trinket.icon:SetAllPoints()
    trinket.icon:SetTexture([[Interface\Icons\PVPCurrency-Conquest-Horde]])
    Base.CropIcon(trinket.icon, trinket)

    local timer = _G.CreateFrame("StatusBar", nil, trinket)
    timer:SetMinMaxValues(0, 1)
    timer:SetStatusBarTexture(RealUI.textures.plain)
    timer:SetStatusBarColor(1, 1, 1, 1)
    trinket.timer = timer

    timer:SetPoint("TOPLEFT", trinket, "BOTTOMLEFT", 0, 2)
    timer:SetPoint("BOTTOMRIGHT", trinket)
    timer:SetFrameLevel(trinket:GetFrameLevel() + 2)

    Base.SetBackdrop(timer, Color.black, 0.7)
    timer:SetBackdropOption("offsets", {
        left = -1,
        right = -1,
        top = -1,
        bottom = -1,
    })

    trinket.text = trinket:CreateFontString(nil, "OVERLAY")
    trinket.text:SetFontObject("NumberFont_Outline_Med")
    trinket.text:SetPoint("CENTER", trinket, 0, 0)
    trinket.text:SetJustifyH("LEFT")

    function trinket:SetCooldown(startTime, duration)
        self.startTime = startTime
        self.endTime = startTime + duration

        self.timer:Show()
        self.timer:SetMinMaxValues(0, self.endTime - self.startTime)
    end

    function trinket:Clear()
        self.startTime = nil
        self.endTime = nil
    end

    parent.Trinket = trinket
end

UnitFrames.arena = {
    create = function(dialog)
        CreateTrinket(dialog)

        dialog.Health.text:SetPoint("LEFT", dialog.Health, 1, 0)

        dialog.Name = dialog.Health:CreateFontString(nil, "OVERLAY")
        dialog.Name:SetPoint("RIGHT", dialog.Health, -1, 0)
        dialog.Name:SetFontObject("SystemFont_Shadow_Med1")
        dialog.Name:SetJustifyH("RIGHT")
        dialog:Tag(dialog.Name, "[realui:name]")

        dialog.RaidTargetIndicator = dialog:CreateTexture(nil, "OVERLAY")
        dialog.RaidTargetIndicator:SetSize(20, 20)
        dialog.RaidTargetIndicator:SetPoint("CENTER", dialog)

        dialog:RegisterEvent("ARENA_COOLDOWNS_UPDATE", UpdateCC)
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
    if not db.arena.enabled then return end

    for i = 1, 5 do
        local arena = oUF:Spawn("arena" .. i, "RealUIArenaFrame" .. i)
        if i == 1 then
            arena:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", db.positions[UnitFrames.layoutSize].boss.x, db.positions[UnitFrames.layoutSize].boss.y)
        else
            arena:SetPoint("TOP", _G["RealUIArenaFrame" .. i - 1], "BOTTOM", 0, -db.boss.gap)
        end
        FramePoint:PositionFrame(UnitFrames, arena, {"profile", "units", "arena", "framePoint"})
    end
end)
