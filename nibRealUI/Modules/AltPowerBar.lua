local _, private = ...

-- Libs --
local Aurora = _G.Aurora

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "AltPowerBar"
local AltPowerBar = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false
local UpdateInterval = 0

--[[ Testing spots:
    ALT_POWER_TYPE_HORIZONTAL:
        Draenor, SMV: Akeeta's Hovel > Pillars of Fate -- click portal
        EK, Hillsbrad: Quest > Peacebloom vs. Scourge -- uses vehicle
        ToT, Lei Shen: Uses the bar on boss units

    ALT_POWER_TYPE_CIRCULAR:
        BWD, Atramedes:

    ALT_POWER_TYPE_COUNTER:
        Darkmoon Fair: Tonk Commander -- Uses vehicle with both HORIZONTAL and COUNTER
            see also: https://github.com/oUF-wow/oUF/issues/293


]]
-- Events
function AltPowerBar:PowerUpdate()
    if _G.UnitAlternatePowerInfo("player") then
        self.bar:Show()
    else
        self.bar:Hide()
    end
end

-- Position
function AltPowerBar:UpdatePosition()
    local bar = self.bar
    bar:SetPoint(db.position.anchorfrom, _G.UIParent, db.position.anchorto, db.position.x, db.position.y)

    bar:SetFrameStrata("MEDIUM")
    bar:SetFrameLevel(1)

    bar:SetHeight(db.size.height)
    bar:SetWidth(db.size.width)
end

-- Refresh
function AltPowerBar:PLAYER_LOGIN()
    LoggedIn = true
    self:RefreshMod()
end

-- Create Frames
function AltPowerBar:CreateFrames()
    local bar = _G.CreateFrame("StatusBar", "RealUI_AltPowerBar", _G.UIParent)
    Aurora.Skin.FrameTypeStatusBar(bar)
    bar:SetStatusBarColor(Aurora.Color.green:GetRGB())
    bar:SetPoint(db.position.anchorfrom, _G.UIParent, db.position.anchorto, db.position.x, db.position.y)
    self.bar = bar

    local text = bar:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER", bar)
    text:SetFontObject("SystemFont_Shadow_Med1")
    text:SetTextColor(1, 1, 1, 1)
    bar.text = text

    -- Update Power
    UpdateInterval = 0
    bar:SetScript("OnUpdate", function(this, elapsed)
        UpdateInterval = UpdateInterval + elapsed

        if UpdateInterval > 0.1 then
            local CurPower = _G.UnitPower("player", _G.ALTERNATE_POWER_INDEX)
            local MaxPower = _G.UnitPowerMax("player", _G.ALTERNATE_POWER_INDEX)
            this:SetMinMaxValues(0, MaxPower)
            this:SetValue(CurPower)
            if MaxPower > 0 then
                text:SetText(CurPower.."/"..MaxPower)
            else
                text:SetText("0")
            end
            UpdateInterval = 0
        end
    end)
end

----------
function AltPowerBar:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    db = self.db.profile

    self:UpdatePosition()
    self:PowerUpdate()
end

function AltPowerBar:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            size = {width = 160, height = 16},
            position = {
                anchorto = "TOP",
                anchorfrom = "TOP",
                x = 0,
                y = -200,
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))

    self:CreateFrames()
end

function AltPowerBar:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("UNIT_POWER_UPDATE", "PowerUpdate")
    self:RegisterEvent("UNIT_POWER_BAR_SHOW", "PowerUpdate")
    self:RegisterEvent("UNIT_POWER_BAR_HIDE", "PowerUpdate")

    -- Hide Default
    _G.PlayerPowerBarAlt:SetAlpha(0)

    if LoggedIn then
        self:RefreshMod()
    end
end

function AltPowerBar:OnDisable()
    self:UnregisterEvent("PLAYER_LOGIN")
    self:UnregisterEvent("UNIT_POWER_UPDATE")
    self:UnregisterEvent("UNIT_POWER_BAR_SHOW")
    self:UnregisterEvent("UNIT_POWER_BAR_HIDE")

    self.bar:Hide()
    _G.PlayerPowerBarAlt:SetAlpha(1)
end
