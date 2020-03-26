local _, private = ...

-- Libs --
local Aurora = _G.Aurora
local Base = Aurora.Base

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "ScreenSaver"
local ScreenSaver = RealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Update AFK status
function ScreenSaver:UpdateTimer(...)
    self:debug("UpdateTimer", _G.UnitIsAFK("player"))
    if _G.UnitIsAFK("player") then
        if not db.afkStart then
            db.afkStart = _G.GetServerTime()
            self.frame.alphaIn:Play()
        end

        if _G.UnitAffectingCombat("player") and db.combatwarning then
            _G.PlaySound(15262, "MASTER") -- Aggro_Enter_Warning_State
        end
    else
        db.afkStart = nil
        self.frame.alphaOut:Play()
    end
end

-- Frame Creation
function ScreenSaver:CreateFrames()
    local frame = _G.CreateFrame("Frame", "RealUIScreenSaver", _G.UIParent)
    frame:SetPoint("TOPLEFT", 0, -300)
    frame:SetPoint("TOPRIGHT", 0, -300)
    frame:SetHeight(21)
    Base.SetBackdrop(frame)
    self.frame = frame

    frame:SetScript("OnUpdate", function(this, elapsed)
        self:debug("OnUpdate", db.afkStart)
        if db.afkStart then
            local timeStr = _G.SecondsToClock(_G.GetServerTime() - db.afkStart)
            this.time:SetFormattedText(_G.MARKED_AFK_MESSAGE, timeStr)
        end
    end)

    local alphaIn = frame:CreateAnimationGroup()
    alphaIn:SetScript("OnPlay", function(this)
        frame:Show()
    end)
    alphaIn:SetScript("OnFinished", function(this)
        frame:SetAlpha(1)
    end)
    local animIn = alphaIn:CreateAnimation("Alpha")
    animIn:SetDuration(0.5)
    animIn:SetFromAlpha(0)
    animIn:SetToAlpha(1)
    frame.alphaIn = alphaIn

    local alphaOut = frame:CreateAnimationGroup()
    alphaOut:SetScript("OnPlay", function(this)
        frame.time:SetText("")
    end)
    alphaOut:SetScript("OnFinished", function(this)
        frame:SetAlpha(0)
        frame:Hide()
    end)
    local animOut = alphaOut:CreateAnimation("Alpha")
    animOut:SetDuration(0.5)
    animOut:SetFromAlpha(1)
    animOut:SetToAlpha(0)
    frame.alphaOut = alphaOut



    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(0, 0, 0, 0.5)
    bg:SetAllPoints(_G.UIParent)

    local left = frame:CreateTexture(nil, "ARTWORK")
    left:SetColorTexture(RealUI.charInfo.class.color:GetRGB())
    left:SetPoint("LEFT", frame, "LEFT", 0, 0)
    left:SetHeight(19)
    left:SetWidth(4)

    local right = frame:CreateTexture(nil, "ARTWORK")
    right:SetColorTexture(RealUI.charInfo.class.color:GetRGB())
    right:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    right:SetHeight(19)
    right:SetWidth(4)

    local timeText = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
    timeText:SetJustifyH("CENTER")
    timeText:SetPoint("CENTER")
    timeText:SetText(_G.MARKED_AFK_MESSAGE)
    frame.time = timeText
end

----
function ScreenSaver:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    self:UpdateTimer("Refresh")
end

function ScreenSaver:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            afkStart = nil,
            combatwarning = true,
        },
    })
    db = self.db.profile

    ScreenSaver:CreateFrames()
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function ScreenSaver:OnEnable()
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "UpdateTimer")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateTimer")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateTimer")

    ScreenSaver:RefreshMod()
end

function ScreenSaver:OnDisable()
    self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")

    self.frame:Hide()
end
