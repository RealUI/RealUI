local _, private = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, dbc, dbg
local debug = RealUI.GetDebug("Settings")

local accountCVars = {
    -- Sound
    ["Sound_EnableErrorSpeech"] = 0,

    -- Screenshots
    ["screenshotQuality"] = "10",              -- Highest quality

    -- Help
    ["showTutorials"] = 0,                     -- Turn off Tutorials
    ["UberTooltips"] = 1,                      -- Turn on Enhanced Tooltips
    ["scriptErrors"] = 1,                      -- Turn on Display Lua Errors

    -- Controls
    ["deselectOnClick"] = 1,                   -- Turn off Sticky Targeting (inverted)

    -- Combat
    ["spellActivationOverlayOpacity"] = 0.75,  -- Spell Alert Opacity

    -- Social
    ["chatBubbles"] = 0,                       -- Turn off Chat Bubbles
    ["chatBubblesParty"] = 0,                  -- Turn off Party Chat Bubbles
    ["chatStyle"] = "classic",                 -- Chat Style = "Classic"
    ["whisperMode"] = "inline",                -- Whisper Mode = "In-line"

    -- ActionBars
    ["countdownForCooldowns"] = 0,             -- Disable Blizz cooldown count

    -- Quests
    ["autoQuestWatch"] = 1,                    -- Auto Track Quests

    -- Names
    ["UnitNameNPC"] = 1,                       -- Turn on NPC Names
    ["UnitNamePlayerPVPTitle"] = 0,            -- Turn off PvP Player Titles
    ["UnitNameEnemyGuardianName"] = 1,         -- Turn on Enemy Pet Names
    ["UnitNameEnemyTotemName"] = 1,            -- Turn on Enemy Totem Names

    -- Camera
    ["cameraSmoothStyle"] = 0,                 -- Never adjust the camera

    -- Quality of Life
    ["guildShowOffline"] = 0,                  -- Hide Offline Guild Members
    ["profanityFilter"] = 0,                   -- Turn off Profanity Filter
}
local characterCVars = {
    -- Nameplates
    ["nameplateMotion"] = 1,          -- Stacking Nameplates
    ["nameplateShowAll"] = 1,         -- Always show nameplates
    ["nameplateShowSelf"] = 0,        -- Hide Personal Resource Display

    -- Combat
    ["displaySpellActivationOverlays"] = 1,    -- Turn on Spell Alerts

    -- Raid/Party
    ["useCompactPartyFrames"] = 1,    -- Raid-style party frames

    -- Quality of Life
    ["autoLootDefault"] = 1,                   -- Turn on Auto Loot
}

-- CVars
local function SetDefaultCVars()
    debug("SetDefaultCVars")
    if _G.IsAddOnLoaded("MikScrollingBattleText") then
        accountCVars["enableFloatingCombatText"] = 0   -- Turn off Combat Text
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
        RealUI:AddRealUIProfiles()
    end

    RealUI:SetProfilesToRealUI()

    -- Make Chat windows transparent (again)
    _G.SetChatWindowAlpha(1, 0)
    _G.SetChatWindowAlpha(2, 0)

    -- Addon Profiles
    RealUI:SetProfileKeys()
end

local function CreateInstallWindow()
    debug("CreateInstallWindow")

    local pointOfs = RealUI.isDev and 500 or 0
    local installFrame = _G.CreateFrame("Button", "RealUI_Install", _G.UIParent, "SecureActionButtonTemplate")
    installFrame:SetPoint("TOPLEFT", pointOfs, -pointOfs)
    installFrame:SetPoint("BOTTOMRIGHT", -pointOfs, pointOfs)
    installFrame:SetFrameStrata("DIALOG")
    installFrame:RegisterForClicks("LeftButtonUp")
    installFrame:SetScript("OnClick", function()
        RunStage1()
        _G.ReloadUI()
    end)
    installFrame:Hide()

    local bg = installFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(0, 0, 0, 0.8)
    bg:SetAllPoints()

    local logo = installFrame:CreateTexture(nil, "ARTWORK")
    logo:SetTexture([[Interface\AddOns\nibRealUI\Media\Logo]])
    logo:SetSize(256, 256)
    logo:SetPoint("BOTTOM", installFrame, "CENTER")

    local line = installFrame:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", installFrame, "LEFT", 0, 0)
    line:SetPoint("BOTTOMRIGHT", installFrame, "RIGHT", 0, -1)
    line:SetColorTexture(1, 1, 1, 0.2)

    local lineWidth = line:GetWidth()
    local numMovers = RealUI.Round(lineWidth / 25)

    -- Moving Line Squares
    local lineAnim1 = installFrame:CreateAnimationGroup()
    lineAnim1:SetLooping("REPEAT")
    local lineAnim2 = installFrame:CreateAnimationGroup()
    lineAnim2:SetLooping("REPEAT")

    local half = numMovers / 2
    for i = 1, numMovers do
        local dot = installFrame:CreateTexture(nil, "ARTWORK")
        dot:SetSize(1, 1)
        dot:SetColorTexture(1, 1, 1, 0.8)

        local direction
        if i % 2 == 1 then
            direction = -1
            dot:SetPoint("RIGHT", line)
        else
            direction = 1
            dot:SetPoint("LEFT", line)
        end

        local anim
        if i < half then
            anim = lineAnim1:CreateAnimation("Translation")
        else
            anim = lineAnim2:CreateAnimation("Translation")
        end

        anim:SetDuration(_G.random(2, 5))
        anim:SetOffset(direction * lineWidth, 0)
        anim:SetStartDelay(_G.random(0, 6))
        anim:SetOrder(1)
        anim:SetTarget(dot)
    end
    lineAnim1:Play()
    _G.C_Timer.After(4, function()
        lineAnim2:Play()
    end)

    -- Version string
    local verStr = installFrame:CreateFontString(nil, "OVERLAY")
    verStr:SetFontObject("Fancy16Font")
    verStr:SetText(L["Version"].." "..RealUI:GetVerString(true))
    verStr:SetPoint("TOP", installFrame, "CENTER", 0, -12)

    -- Click To Install
    local installText = installFrame:CreateFontString(nil, "OVERLAY")
    installText:SetPoint("BOTTOM", 0, installFrame:GetHeight() / 3)
    installText:SetFontObject("SystemFont_Shadow_Large2")
    installText:SetText("[ "..L["Install"].." ]")

    if RealUI:IsUsingHighResDisplay() then
        local skinsDB = RealUI.GetOptions("Skins").profile

        local setHighRes = _G.CreateFrame("CheckButton", nil, installFrame, "OptionsBaseCheckButtonTemplate")
        setHighRes:SetPoint("TOPLEFT", installText, "BOTTOMLEFT", -10, -20)
        setHighRes:SetScript("OnClick", function(self)
            local isChecked = self:GetChecked()
            if isChecked then
                _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            else
                _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            end
            skinsDB.isHighRes = isChecked
            _G.ReloadUI()
        end)
        setHighRes.tooltipText = L["Install_UseHighResDec"]
        setHighRes:SetChecked(skinsDB.isHighRes)
        _G.Aurora.Skin.OptionsBaseCheckButtonTemplate(setHighRes)

        local highResText = setHighRes:CreateFontString(nil, "OVERLAY")
        highResText:SetPoint("LEFT", setHighRes, "RIGHT", 0, 0)
        highResText:SetFontObject("SystemFont_Shadow_Med1")
        highResText:SetText(L["Install_UseHighRes"])
    end

    local textAnim = installFrame:CreateAnimationGroup()
    textAnim:SetLooping("BOUNCE")
    local fade = textAnim:CreateAnimation("Alpha")
    fade:SetDuration(2)
    fade:SetFromAlpha(1)
    fade:SetToAlpha(0.25)
    fade:SetOrder(1)
    fade:SetTarget(installText)
    fade:SetSmoothing("IN_OUT")
    textAnim:Play()

    -- Combat Check
    installFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    installFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    installFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    installFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            if not(_G.InCombatLockdown()) then
                self:Show()
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            self:Hide()
            _G.print("|cffff0000RealUI Installation paused until you leave combat.|r")
        else
            self:Show()
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
        patches[i]()
    end

    -- Set version info
    dbg.verinfo = {}
    for k,v in next, RealUI.verinfo do
        dbg.verinfo[k] = v
    end
end

local function MiniPatchInstallation(newVer)
    local curVer = RealUI.verinfo
    local oldVer = dbg.verinfo
    local minipatches = RealUI.minipatches

    -- Find out which Mini Patches are needed
    local patches = {}

    debug("minipatch", newVer, oldVer[3], curVer[3])
    if newVer then
        if minipatches[0] then
            _G.tinsert(patches, minipatches[0])
        end
    else
        if oldVer[3] then
            for i = oldVer[3] + 1, curVer[3] do
                debug("checking", i)
                if minipatches[i] then
                    -- This needs to be an array to ensure patches are applied sequentially.
                    _G.tinsert(patches, minipatches[i])
                end
            end
        end
    end


    debug("TOC minipatch", dbg.patchedTOC, RealUI.TOC)
    if dbg.patchedTOC ~= RealUI.TOC then
        if dbg.patchedTOC > 0 and minipatches[RealUI.TOC] then
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
    local newVer = RealUI:GetVersionChange(oldVer, curVer)
    debug("Version", curVer, oldVer, newVer)

    db.registeredChars[self.key] = true
    dbg.minipatches = nil

    -- Primary Stages
    debug("Stage", dbc.init.installStage)
    if dbc.init.installStage > -1 then
        PrimaryInstallation()
    else
        MiniPatchInstallation(newVer)
    end
end
