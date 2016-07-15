local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, dbc, dbg
local debug = RealUI.GetDebug("Settings")

local Textures = {
    Logo = [[Interface\AddOns\nibRealUI\Media\Install\Logo.tga]],
}
local IWF = {}

local accountCVars = {
    -- Sound
    ["Sound_EnableErrorSpeech"] = 0,

    -- Nameplates
    ["bloatTest"] = 0,
    ["bloatnameplates"] = 0,
    ["bloatthreat"] = 0,

    -- Screenshots
    ["screenshotFormat"] = "jpg",              -- JPG format
    ["screenshotQuality"] = "10",              -- Highest quality

    -- Help
    ["showGameTips"] = 0,                      -- Turn off Loading Screen Tips
    ["showTutorials"] = 0,                     -- Turn off Tutorials
    ["UberTooltips"] = 1,                      -- Turn on Enhanced Tooltips
    ["scriptErrors"] = 1,                      -- Turn on Display Lua Errors

    -- Controls
    ["deselectOnClick"] = 1,                   -- Turn off Sticky Targeting (inverted)

    -- Combat
    ["displaySpellActivationOverlays"] = 1,    -- Turn on Spell Alerts
    ["spellActivationOverlayOpacity"] = 0.75,  -- Spell Alert Opacity

    -- Display
    ["emphasizeMySpellEffects"] = 0,           -- Turn off Emphasize My Spell Effects
    ["SpellTooltip_DisplayAvgValues"] = 0,     -- Turn off Display Points As Average

    -- Social
    ["chatBubbles"] = 0,                       -- Turn off Chat Bubbles
    ["chatBubblesParty"] = 0,                  -- Turn off Party Chat Bubbles
    ["chatStyle"] = "classic",                 -- Chat Style = "Classic"
    ["conversationMode"] = "inline",           -- Conversation Mode = "In-line"

    -- ActionBars
    ["countdownForCooldowns"] = 0,             -- Disable Blizz cooldown count

    -- Quests
    ["autoQuestWatch"] = 1,                    -- Auto Track Quests

    -- Names
    ["UnitNameNPC"] = 1,                       -- Turn on NPC Names
    ["UnitNamePlayerPVPTitle"] = 0,            -- Turn off PvP Player Titles
    ["UnitNameEnemyGuardianName"] = 1,         -- Turn on Enemy Pet Names
    ["UnitNameEnemyTotemName"] = 1,            -- Turn on Enemy Totem Names
    ["nameplateMotion"] = 1,                   -- Stacking Nameplates

    -- Camera
    ["cameraYawSmoothSpeed"] = 210,
    ["cameraView"] = 1,                        -- Camera Stlye
    ["cameraDistanceMax"] = 50,                -- Camera Max Distance
    ["cameraDistanceMaxFactor"] = 2,           -- Camera Follow Speed

    -- Quality of Life
    ["guildShowOffline"] = 0,                  -- Hide Offline Guild Members
    ["profanityFilter"] = 0,                   -- Turn off Profanity Filter
}
local characterCVars = {
    ["useCompactPartyFrames"] = 1,    -- Raid-style party frames
}

-- CVars
local function SetDefaultCVars()
    debug("SetDefaultCVars")
    if _G.IsAddOnLoaded("MikScrollingBattleText") then
        accountCVars["enableCombatText"] = 0   -- Turn off Combat Text
        accountCVars["CombatDamage"] = 0       -- Turn off Combat Text - Damage
        accountCVars["CombatHealing"] = 0      -- Turn off Combat Text - Healing
    end

    for cvar, value in next, accountCVars do
        _G.SetCVar(cvar, value)
    end
end

-- Initial Settings
local function InitialSettings()
    debug("InitialSettings")
    ---- Chat
    -- Lock chat frames
    for i = 1, 10 do
        local cf = _G["ChatFrame"..i]
        if cf then _G.FCF_SetLocked(cf, 1) end
    end

    -- Set all chat channels to color player names by class
    for k, v in next, _G.CHAT_CONFIG_CHAT_LEFT do
        _G.ToggleChatColorNamesByClassGroup(true, v.type)
    end
    for iCh = 1, 15 do
        _G.ToggleChatColorNamesByClassGroup(true, "CHANNEL"..iCh)
    end

    -- Make Chat windows transparent
    _G.SetChatWindowAlpha(1, 0)
    _G.SetChatWindowAlpha(2, 0)

    -- Char specific CVars
    for cvar, value in next, characterCVars do
        _G.SetCVar(cvar, value)
    end

    -- Initial Settings done
    dbc.init.initialized = true
end

---- Primary Installation
---- Stage 1
local function RunStage1()
    dbc.init.installStage = -1

    if dbg.tags.firsttime then
        dbg.tags.firsttime = false
        dbg.tutorial.stage = 0

        ---- Addon Data
        -- Initialize Grid2
        if _G.Grid2 and _G.Grid2.LoadConfig then
            _G.Grid2:LoadConfig()
        end

        -- Addon settings
        RealUI:LoadAddonData()

        ---- Extra addon tweaks
        -- Grid - Healing frame height
        local _, resHeight = RealUI:GetResolutionVals()
        if resHeight < 900 then
            if _G.Grid2DB and _G.Grid2DB["namespaces"]["Grid2Frame"]["profiles"]["RealUI-Healing"] then
                _G.Grid2DB["namespaces"]["Grid2Frame"]["profiles"]["RealUI-Healing"]["frameHeight"] = 25
            end
        end
    end

    -- Make Chat windows transparent (again)
    _G.SetChatWindowAlpha(1, 0)
    _G.SetChatWindowAlpha(2, 0)

    -- Addon Profiles
    RealUI:SetProfileKeys()
end

local function CreateIWTextureFrame(texture, width, height, position, color)
    local frame = _G.CreateFrame("Frame", nil, IWF)
    frame:SetParent(IWF)
    frame:SetPoint(_G.unpack(position))
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(IWF:GetFrameLevel() + 1)
    frame:SetWidth(width)
    frame:SetHeight(height)

    frame.bg = frame:CreateTexture()
    frame.bg:SetAllPoints(frame)
    frame.bg:SetTexture(texture)
    frame.bg:SetVertexColor(_G.unpack(color))

    return frame
end

local function CreateInstallWindow()
    debug("CreateInstallWindow")
    -- To help with debugging
    local bdAlpha, ibSizeOffs = 0.9, 0
    if RealUI.isDev then
        bdAlpha = 0.5
        ibSizeOffs = 300
    end

    -- Background
    IWF = _G.CreateFrame("Frame", nil, _G.UIParent)
    IWF:Hide()
        IWF:SetParent(_G.UIParent)
        IWF:SetAllPoints(_G.UIParent)
        IWF:SetFrameStrata("DIALOG")
        IWF:SetFrameLevel(0)
    IWF:SetBackdrop({
        bgFile = RealUI.media.textures.plain,
    })
    IWF:SetBackdropColor(0, 0, 0, bdAlpha)
    RealUI:AddStripeTex(IWF)

    -- Logo
    IWF.logo = CreateIWTextureFrame(Textures.Logo, 256, 256, {"BOTTOM", IWF, "CENTER", 0, 0}, {1, 1, 1, 1})

    -- Line
    local numMovers, moverLength, minSpeed = 4, 2, 6
    local line = IWF:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", IWF, "LEFT", 0, 0)
    line:SetPoint("BOTTOMRIGHT", IWF, "RIGHT", 0, -1)
    line:SetTexture(1, 1, 1, 0.2)
    line.squareTravelLength = _G.UIParent:GetWidth() + moverLength * 2

    -- Moving Line Squares
    local lineSquares = {}
    for i = 1, numMovers do
        lineSquares[i] = _G.CreateFrame("Frame", nil, IWF)
        local lS = lineSquares[i]

        lS:SetSize(moverLength, 1)
        lS.bg = lS:CreateTexture()
            lS.bg:SetAllPoints()
            lS.bg:SetTexture(1, 1, 1, 0.3)

        lS.curX = _G.random(0, line.squareTravelLength) - (line.squareTravelLength / 2)
        lS.direction = i > (numMovers / 2) and -1 or 1
        lS.speed = _G.random(minSpeed, minSpeed + numMovers)
        if (i > 1) and (lS.speed == lineSquares[i - 1].speed) then
            lS.speed = lS.speed + 1
        end
        lS:SetScript("OnUpdate", function(s, e)
            s:ClearAllPoints()
            s.curX = s.curX + s.direction * s.speed
            if s.curX > (line.squareTravelLength / 2) then
                s.curX = -(line.squareTravelLength / 2)
            elseif s.curX < -(line.squareTravelLength / 2) then
                s.curX = (line.squareTravelLength / 2)
            end
            s:SetPoint("BOTTOM", line, "BOTTOM", s.curX, 0)
        end)
    end

    -- Version string
    IWF.verStr = IWF:CreateFontString(nil, "OVERLAY")
        IWF.verStr:SetFont(_G.RealUIFont_Normal:GetFont(), 18)
        IWF.verStr:SetText(L["Version"].." "..RealUI:GetVerString(true))
        IWF.verStr:SetPoint("TOP", IWF, "CENTER", 0, -12)

    -- Button
    IWF.install = _G.CreateFrame("Button", "RealUI_Install", IWF, "SecureActionButtonTemplate")
        IWF.install:SetPoint("CENTER")
        IWF.install:SetSize(_G.UIParent:GetWidth() - ibSizeOffs, _G.UIParent:GetHeight() - ibSizeOffs)
    IWF.install:RegisterForClicks("LeftButtonUp")
    IWF.install:SetScript("OnClick", function()
        RunStage1()
        _G.ReloadUI()
    end)

    -- Click To Install frame + string
    IWF.installTextFrame = _G.CreateFrame("Frame", nil, IWF)
        IWF.installTextFrame:SetPoint("BOTTOM", 0, _G.UIParent:GetHeight() / 4)
        IWF.installTextFrame:SetSize(2,2)
    IWF.installTextFrame.aniGroup = IWF.installTextFrame:CreateAnimationGroup()
        IWF.installTextFrame.aniGroup:SetLooping("BOUNCE")
        local fade = IWF.installTextFrame.aniGroup:CreateAnimation("Alpha")
        fade:SetDuration(1)
        fade:SetFromAlpha(1)
        fade:SetToAlpha(0.5)
        fade:SetOrder(1)
        fade:SetSmoothing("IN_OUT")
        IWF.installTextFrame.fade = fade
    IWF.installTextFrame.aniGroup:Play()

    IWF.installText = IWF.installTextFrame:CreateFontString(nil, "OVERLAY")
        IWF.installText:SetPoint("BOTTOM")
        IWF.installText:SetFont(_G.RealUIFont_Normal:GetFont(), 18)
        IWF.installText:SetText("[ "..L["Install"].." ]")

    -- Combat Check
    IWF:RegisterEvent("PLAYER_ENTERING_WORLD")
    IWF:RegisterEvent("PLAYER_REGEN_ENABLED")
    IWF:RegisterEvent("PLAYER_REGEN_DISABLED")
    IWF:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            if not(_G.InCombatLockdown()) then
                IWF:Show()
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            IWF:Hide()
            _G.print("|cffff0000RealUI Installation paused until you leave combat.|r")
        else
            IWF:Show()
        end
    end)
end

local function InstallationStage1()
    debug("InstallationStage1")
    -- Create Installation Window
    CreateInstallWindow()

    -- First Time
    if dbg.tags.firsttime then
        -- CVars
        SetDefaultCVars()
    end

    -- Initial Character Settings
    if not dbc.init.initialized then
        InitialSettings()
    end

    -- Set version info
    dbg.verinfo = {}
    for k,v in next, RealUI.verinfo do
        dbg.verinfo[k] = v
    end

    _G.DEFAULT_CHATFRAME_ALPHA = 0
end

---- Process
local function PrimaryInstallation()
    debug("PrimaryInstallation", dbc.init.installStage)
    if dbc.init.installStage > -1 then
        InstallationStage1()
    end
end

-- Mini Patch
local function ApplyMiniPatches(patches)
    for i = 1, #patches do
        local patch = i + dbg.verinfo[3]
        debug("Apply", patch)
        patches[i](patch)
    end

    -- Set version info
    dbg.verinfo = {}
    for k,v in next, RealUI.verinfo do
        dbg.verinfo[k] = v
    end
end

local function MiniPatchInstallation()
    local curVer = RealUI.verinfo
    local oldVer = dbg.verinfo
    local minipatches = RealUI.minipatches

    -- Find out which Mini Patches are needed
    local patches = {}
    debug("minipatch", oldVer[3], curVer[3])
    if oldVer[3] then
        for i = oldVer[3] + 1, curVer[3] do
            debug("checking", i)
            if minipatches[i] then
                -- This needs to be an array to ensure patches are applied sequentially.
                _G.tinsert(patches, minipatches[i])
            end
        end
    end

    debug("TOC minipatch", dbg.patchedTOC, RealUI.TOC)
    if dbg.patchedTOC ~= RealUI.TOC then
        if minipatches[RealUI.TOC] then
            -- Add minipatch for TOC change
            _G.tinsert(patches, minipatches[RealUI.TOC])
        end
        dbg.patchedTOC = RealUI.TOC
    end

    debug("numPatches", #patches)
    if #patches > 0 then
        _G.StaticPopupDialogs["PUDRUIMP"] = {
            text = "|cff85e0ff"..L["Patch_MiniPatch"].."|r\n\n|cffffffff"..L["Patch_DoApply"],
            button1 = _G.OKAY,
            OnAccept = function()
                ApplyMiniPatches(patches)
                _G.ReloadUI()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = false,
            notClosableByLogout = false,
        }
        _G.StaticPopup_Show("PUDRUIMP")
    end
end

-- Install Procedure
function RealUI:InstallProcedure()
    debug("InstallProcedure", RealUI.db.char.init.installStage)
    db = self.db.profile
    dbc = self.db.char
    dbg = self.db.global

    ---- Version checking
    local curVer = RealUI.verinfo
    local oldVer = (dbg.verinfo[1] and dbg.verinfo) or RealUI.verinfo
    local newVer = RealUI:MajorVerChange(oldVer, curVer)
    debug("Version", curVer, oldVer, newVer)

    -- Reset DB if new Major version
    if newVer == "major" then
        RealUI.db:ResetDB("RealUI")
        if _G.StaticPopup1 then
            _G.StaticPopup1:Hide()
        end
    end

    db.registeredChars[self.key] = true
    dbg.minipatches = nil

    -- Primary Stages
    debug("Stage", dbc.init.installStage)
    if dbc.init.installStage > -1 then
        PrimaryInstallation()

    -- Mini Patch
    else
        MiniPatchInstallation()
    end
end
