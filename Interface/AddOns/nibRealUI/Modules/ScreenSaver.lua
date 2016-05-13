local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local db, ndb, ndbc

local MODNAME = "ScreenSaver"
local ScreenSaver = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn
local SecToMin = 1/60
local SecToHour = SecToMin * SecToMin

local IsDark = false
local IsWarning = false
local OpacityLevel = 0
local AFKLevel = 0

-- Timer
function ScreenSaver:UpdateAFKTime(elapsed)
    local Hour = _G.min(_G.floor(elapsed * SecToHour), 99)
    local Min = (elapsed * SecToMin) % 60
    local Sec = _G.floor(elapsed % 60)
    local timeStr
    
    if Hour >= 1 then
        if Min >= 1 then
            timeStr = ("%dh %dm"):format(Hour, Min)
        else
            timeStr = ("%dh"):format(Hour)
        end
    elseif Min >= 10 then
        timeStr = ("%dm"):format(Min)
    elseif Min >= 1 then
        timeStr = ("%d:%02d"):format(Min, Sec)
    else
        timeStr = ("%ds"):format(Sec)
    end
    
    self.time:SetText("|cffC0C0C0"..timeStr.."|r")
    
    if Sec % 60 == 0 then
        self:RepositionPanel(true)
    end
end

local AFKTimer = _G.CreateFrame("Frame")
AFKTimer:Hide()
AFKTimer:SetScript("OnUpdate", function(self, elapsed)
    AFKTimer.elapsed = AFKTimer.elapsed + elapsed
    
    if AFKTimer.elapsed > AFKTimer.lastElapsed + 1 then
        AFKTimer.lastElapsed = AFKTimer.elapsed
        
        -- Set BG opacity
        if AFKTimer.elapsed > 300 then
            OpacityLevel = db.general.opacity2
            AFKLevel = 2
        else
            OpacityLevel = db.general.opacity1
            AFKLevel = 1
        end
        if not( _G.UnitAffectingCombat("player") and db.general.combatwarning ) and _G.GetCVar("autoClearAFK") then
            if ScreenSaver.bg:GetAlpha() ~= OpacityLevel then 
                _G.UIFrameFadeIn(ScreenSaver.bg, 0.2, ScreenSaver.bg:GetAlpha(), OpacityLevel)
                ScreenSaver:ToggleOverlay(true)
            end
        end
        
        -- Make sure Size is still good
        ScreenSaver.bg:SetWidth(_G.UIParent:GetWidth() + 5000)
        ScreenSaver.bg:SetHeight(_G.UIParent:GetHeight() + 2000)
        ScreenSaver.panel:SetWidth(_G.UIParent:GetWidth())
        
        -- Update AFK Time
        ScreenSaver:UpdateAFKTime(AFKTimer.elapsed)
    
        -- Check Auto AFK status
        if not _G.GetCVar("autoClearAFK") then ScreenSaver:AFKEvent() end
    end
end)

-- Show/Hide Warning
function ScreenSaver:ToggleWarning(val)
    if val then
        if not IsWarning then
            IsWarning = true
            
            -- Play warning sound if Screen Saver is active and you get put into combat
            if _G.UnitAffectingCombat("player") and db.general.combatwarning then
                _G.PlaySoundKitID(15262) -- Aggro_Enter_Warning_State
            end
        end
    else
        if IsWarning then
            IsWarning = false
        end
    end
end

-- Show/Hide Screen Saver
function ScreenSaver:ToggleOverlay(val)
    if val and _G.GetCVar("autoClearAFK") then
        if not IsDark then
            IsDark = true
            
            -- Fade In Screen Saver
            self:RepositionPanel()
            _G.UIFrameFadeIn(self.bg, 0.2, 0, db.general["opacity"..AFKLevel])
            _G.UIFrameFadeIn(self.panel, 0.2, 0, 1)
            AFKTimer:Show()
        end
    else
        if IsDark then
            IsDark = false
            
            -- Fade Out Screen Saver
            local function bgHide()
                self.bg:Hide()
            end
            local bgFadeInfo = {
                mode = "OUT",
                timeToFade = 0.2,
                finishedFunc = bgHide,
                startAlpha = self.bg:GetAlpha(),
            }
            _G.UIFrameFade(self.bg, bgFadeInfo)
            
            local function panelHide()
                self.panel:Hide()
                if not _G.UnitIsAFK("player") then
                    self.time:SetText("0s")
                end
            end
            local panelFadeInfo = {
                mode = "OUT",
                timeToFade = 0.2,
                finishedFunc = panelHide,
            }
            _G.UIFrameFade(self.panel, panelFadeInfo)
            
            -- Hide Screen Saver if we're not AFK
            if not _G.UnitIsAFK("player") then
                AFKTimer:Hide()
            end
        end
    end
end

-- Update AFK status
function ScreenSaver:AFKEvent()
    if not _G.GetCVar("autoClearAFK") then
        -- Disable ScreenSaver if Auto Clear AFK is disabled
        self:ToggleOverlay(false)
        self:ToggleWarning(false)
        AFKLevel = 0
    elseif _G.UnitIsAFK("player") then
        -- AFK
        if not AFKTimer:IsShown() then
            AFKTimer.elapsed = 0
            AFKTimer.lastElapsed = 0
            if not( _G.UnitAffectingCombat("player") and db.general.combatwarning ) then
                _G.UIFrameFadeIn(self.bg, 0.2, self.bg:GetAlpha(), db.general.opacity1)
                _G.UIFrameFadeIn(self.panel, 0.2, 0, 1)
            end
            AFKTimer:Show()
            AFKLevel = 1
        end
        
        if ( _G.UnitAffectingCombat("player") and db.general.combatwarning ) then
            -- AFK and In Combat
            if IsDark then
                self:ToggleOverlay(false)   -- Hide Screen Saver
                self:ToggleWarning(true)        -- Activate Warning             
            end
        else
            -- AFK and not In Combat
            if not IsDark then
                self:ToggleOverlay(true)        -- Show Screen Saver
                self:ToggleWarning(false)   -- Deactivate Warning
                AFKLevel = 1
            end
        end
    else
        -- Not AFK
        AFKTimer.elapsed = 0
        AFKTimer.lastElapsed = 0
        AFKTimer:Hide()
        AFKLevel = 0
        
        self:ToggleOverlay(false)   -- Hide Screen Saver
        self:ToggleWarning(false)   -- Deactivate Warning
    end
end

function ScreenSaver:RepositionPanel(...)
    if ... and not db.panel.automove then return end
    self.panel:ClearAllPoints()
    self.panel:SetPoint("BOTTOM", _G.UIParent, "CENTER", 0, _G.math.random(
        ndb.positions[ndbc.layout.current]["HuDY"] + 100,
        (_G.UIParent:GetHeight() / 2) - 180
    ))
end

-- Frame Updates
function ScreenSaver:UpdateFrames()
    -- self.panel:SetBackdropColor(0.075, 0.075, 0.075, db.panel.opacity)
    
    -- Make sure Size is still good
    self.bg:SetWidth(_G.UIParent:GetWidth() + 5000)
    self.bg:SetHeight(_G.UIParent:GetHeight() + 2000)
    
    self.panel:SetSize(_G.UIParent:GetWidth(), 21)
end

-- Initialize / Refresh
function ScreenSaver:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    
    db = self.db.profile
    ndb = RealUI.db.profile

    self:UpdateFrames()
    self:AFKEvent()
end

function ScreenSaver:PLAYER_LOGIN()
    LoggedIn = true
    
    self:RefreshMod()
end

-- Frame Creation
function ScreenSaver:CreateFrames()
    -- Dark Background
    self.bg = _G.CreateFrame("Frame", nil, _G.UIParent)
        self.bg:SetAllPoints(_G.UIParent)
        self.bg:SetFrameStrata("BACKGROUND")
        self.bg:SetFrameLevel(0)
        self.bg:SetBackdrop({
            bgFile = RealUI.media.textures.plain,
        })
        self.bg:SetBackdropColor(0, 0, 0, 1)
        self.bg:SetAlpha(0)
        self.bg:Hide()
    
    -- Panel
    self.panel = _G.CreateFrame("Frame", "RealUIScreenSaver", _G.UIParent)
        self.panel:SetFrameStrata("MEDIUM")
        self.panel:SetFrameLevel("1")
        self.panel:SetSize(_G.UIParent:GetWidth(), 21)
        -- self.panel:SetBackdropColor(0.075, 0.075, 0.075, db.panel.opacity)
        RealUI:CreateBD(self.panel, nil, true)
        self.panel:SetBackdropColor(RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3], RealUI.media.window[4])
        self.panel:SetAlpha(0)
        self.panel:Hide()
        self:RepositionPanel()
    
    self.panel.left = self.panel:CreateTexture(nil, "ARTWORK")
        self.panel.left:SetTexture(RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3])
        self.panel.left:SetPoint("LEFT", self.panel, "LEFT", 0, 0)
        self.panel.left:SetHeight(19)
        self.panel.left:SetWidth(4)
    
    self.panel.right = self.panel:CreateTexture(nil, "ARTWORK")
        self.panel.right:SetTexture(RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3])
        self.panel.right:SetPoint("RIGHT", self.panel, "RIGHT", 0, 0)
        self.panel.right:SetHeight(19)
        self.panel.right:SetWidth(4)
    
    -- Timer
    self.timeLabel = RealUI:CreateFS(self.panel, "CENTER")
        self.timeLabel:SetPoint("RIGHT", self.panel, "CENTER", 15, 0)
        self.timeLabel:SetFontObject(_G.RealUIFont_PixelSmall)
        self.timeLabel:SetText("|cffffffffAFK |r|cff"..RealUI:ColorTableToStr(RealUI.classColor).."TIME:")
    
    self.time = RealUI:CreateFS(self.panel, "LEFT")
        self.time:SetPoint("LEFT", self.panel, "CENTER", 17, 0)
        self.time:SetFontObject(_G.RealUIFont_PixelSmall)
        self.time:SetText("0s")
end

----
function ScreenSaver:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            general = {
                opacity1 = 0.30,
                opacity2 = 0.50,
                combatwarning = true,
            },
            panel = {
                automove = true,
            },
        },
    })
    db = self.db.profile
    ndb = RealUI.db.profile
    ndbc = RealUI.db.char
    
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    ScreenSaver:CreateFrames()
    
    self:RegisterEvent("PLAYER_LOGIN")
end

function ScreenSaver:OnEnable()
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "AFKEvent")
    self:RegisterEvent("WORLD_MAP_UPDATE", "AFKEvent")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "AFKEvent")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "AFKEvent") 
    
    if LoggedIn then 
        ScreenSaver:RefreshMod()
    end
end

function ScreenSaver:OnDisable()
    self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
    self:UnregisterEvent("WORLD_MAP_UPDATE")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    
    AFKTimer.elapsed = 0
    AFKTimer.lastElapsed = 0
    self.panel:Hide()
    AFKTimer:Hide()
    ScreenSaver:ToggleOverlay(false)
    ScreenSaver:ToggleWarning(false)
end
