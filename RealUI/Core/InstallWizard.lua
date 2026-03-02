local _, private = ...

-- Lua Globals --
-- luacheck: globals next type _G

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("InstallWizard")

-- Installation Wizard Framework
-- Handles first-time setup detection, progressive installation stages, and resumption

local InstallWizard = {}
RealUI.InstallWizard = InstallWizard

-- StaticPopup dialog for reload after setup
_G.StaticPopupDialogs["REALUI_SETUP_RELOAD"] = {
    text = "|cff00ff00RealUI setup is complete!|r\n\nA UI reload is required to apply all settings properly.\n\n|cffff8000Please reload your UI now.|r",
    button1 = "Reload UI",
    button2 = "Later",
    OnAccept = function()
        _G.ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
}

-- Installation stage constants
InstallWizard.STAGE_COMPLETE = -1
InstallWizard.STAGE_WELCOME = 0
InstallWizard.STAGE_LAYOUT = 1
InstallWizard.STAGE_CHAT = 2
InstallWizard.STAGE_FINISH = 3

-- Installation state
local installState = {
    currentStage = InstallWizard.STAGE_WELCOME,
    isFirstTime = false,
    needsResume = false,
    stageData = {}
}

local function ApplyStartupDisplayOptimization()
    if RealUI.IsUsingHighResDisplay and RealUI:IsUsingHighResDisplay() then
        local skinsOptions = RealUI.GetOptions and RealUI.GetOptions("Skins")
        local skinsDB = skinsOptions and skinsOptions.profile

        if skinsDB and not skinsDB.isHighRes and RealUI.UpdateUIScale then
            skinsDB.isHighRes = true
            RealUI.UpdateUIScale(skinsDB.customScale)
            debug("Applied startup high-res scaling for install wizard")
        end
    end

    if RealUI.ResolutionOptimizer and RealUI.ResolutionOptimizer.ReOptimize then
        RealUI.ResolutionOptimizer:ReOptimize()
    end
end

-- Check if this is first-time setup
function InstallWizard:IsFirstTime()
    if not RealUI.db or not RealUI.db.char then
        return true
    end

    local charInit = RealUI.db.char.init
    if not charInit then
        return true
    end

    return not charInit.initialized
end

-- Check if this is an upgrade from previous version
function InstallWizard:IsUpgrade()
    if not RealUI.db or not RealUI.db.char then
        return false
    end

    local charInit = RealUI.db.char.init
    if charInit and charInit.hadPreviousVersion then
        return true, charInit.previousVersion
    end

    return false, nil
end

-- Get current installation stage
function InstallWizard:GetCurrentStage()
    if not RealUI.db or not RealUI.db.char then
        return InstallWizard.STAGE_WELCOME
    end

    local stage = RealUI.db.char.init.installStage or InstallWizard.STAGE_WELCOME
    return stage
end

-- Set installation stage
function InstallWizard:SetStage(stage)
    if not RealUI.db or not RealUI.db.char then
        return
    end

    RealUI.db.char.init.installStage = stage
    installState.currentStage = stage

    debug("Stage set to:", stage)
end

-- Check if installation needs to be resumed
function InstallWizard:NeedsResume()
    local stage = self:GetCurrentStage()
    return stage > InstallWizard.STAGE_WELCOME and stage ~= InstallWizard.STAGE_COMPLETE
end

-- Initialize installation system
function InstallWizard:Initialize()
    installState.isFirstTime = self:IsFirstTime()
    installState.currentStage = self:GetCurrentStage()
    installState.needsResume = self:NeedsResume()

    -- Check if this is an upgrade
    local isUpgrade, oldVersion = self:IsUpgrade()
    installState.isUpgrade = isUpgrade
    installState.oldVersion = oldVersion

    debug("Initialized - FirstTime:", installState.isFirstTime,
          "Stage:", installState.currentStage, "NeedsResume:", installState.needsResume,
          "IsUpgrade:", installState.isUpgrade, "OldVersion:", tostring(installState.oldVersion))

    return installState
end

-- Start installation wizard
function InstallWizard:Start(forceShow)
    -- Allow forcing the wizard to show (for manual /realui setup command)
    if forceShow then
        debug("Forcing installation wizard to show")
        self:SetStage(InstallWizard.STAGE_WELCOME)

        ApplyStartupDisplayOptimization()

        -- Show installation wizard UI
        if RealUI.InstallUI then
            RealUI.InstallUI:Show()
        end

        return true
    end

    if not installState.isFirstTime and not installState.needsResume then
        debug("Installation not needed")
        return false
    end

    if installState.needsResume then
        debug("Resuming installation from stage:", installState.currentStage)
    else
        debug("Starting new installation")
        self:SetStage(InstallWizard.STAGE_WELCOME)
    end

    ApplyStartupDisplayOptimization()

    -- Show installation wizard UI
    if RealUI.InstallUI then
        RealUI.InstallUI:Show()
    end

    return true
end

-- Complete installation
function InstallWizard:Complete()
    self:SetStage(InstallWizard.STAGE_COMPLETE)

    if RealUI.db and RealUI.db.char then
        RealUI.db.char.init.initialized = true
    end

    -- Disable old tutorial system
    local dbg = RealUI.db and RealUI.db.global
    if dbg and dbg.tutorial then
        dbg.tutorial.stage = -1
        debug("Disabled old tutorial system")
    end

    -- Apply first-time account CVars if this is first time
    if dbg and dbg.tags and dbg.tags.firsttime then
        debug("Applying first-time account CVars")
        self:ApplyAccountCVars()
        dbg.tags.firsttime = false
        dbg.tutorial = dbg.tutorial or {}
        dbg.tutorial.stage = -1
    end

    -- Apply RealUI addon profiles (from old setup system)
    if RealUI.AddRealUIProfiles then
        debug("Adding RealUI profiles to addons")
        RealUI:AddRealUIProfiles()
    end

    if RealUI.SetProfilesToRealUI then
        debug("Setting addon profiles to RealUI")
        RealUI:SetProfilesToRealUI()
    end

    -- Set profile keys for all addons
    if RealUI.SetProfileKeys then
        debug("Setting profile keys")
        RealUI:SetProfileKeys()
    end

    -- Perform character initialization
    if RealUI.CharacterInit then
        RealUI.CharacterInit:Setup()
    end

    -- Complete setup in SetupSystem
    if RealUI.SetupSystem then
        RealUI.SetupSystem:CompleteSetup()
    end

    debug("Installation completed")

    -- Force ActionBars to apply settings and update button layouts
    local ActionBars = RealUI:GetModule("ActionBars", true)
    if ActionBars and ActionBars:IsEnabled() then
        -- Apply settings now that installStage is -1
        ActionBars:ApplyABSettings()

        -- Force all bars to update their button layouts with multiple attempts
        local updateAttempts = {0.2, 0.5, 1.0}
        for _, delay in ipairs(updateAttempts) do
            _G.C_Timer.After(delay, function()
                local BT4 = _G.LibStub("AceAddon-3.0"):GetAddon("Bartender4", true)
                if not BT4 then return end

                local BT4ActionBars = BT4:GetModule("ActionBars", true)

                -- Force all action bars (1-6) button layout update
                if BT4ActionBars then
                    for i = 1, 6 do
                        if BT4ActionBars.actionbars[i] and not BT4ActionBars.actionbars[i].disabled then
                            local bar = BT4ActionBars.actionbars[i]
                            if bar.UpdateButtonLayout then
                                bar:UpdateButtonLayout()
                            end
                        end
                    end
                end

                -- Force pet bar button layout update if it exists
                if _G.BT4BarPetBar and _G.BT4BarPetBar.UpdateButtonLayout then
                    _G.BT4BarPetBar:UpdateButtonLayout()
                end

                -- Force stance bar button layout update if it exists
                if _G.BT4BarStanceBar and _G.BT4BarStanceBar.UpdateButtonLayout then
                    _G.BT4BarStanceBar:UpdateButtonLayout()
                end
            end)
        end
    end

    -- Hide installation wizard UI
    if RealUI.InstallUI then
        RealUI.InstallUI:Hide()
    end

    -- Show completion message
    print("|cff00ff00RealUI 3.0.0 setup completed successfully!|r")

    -- Show reload UI dialog
    _G.StaticPopup_Show("REALUI_SETUP_RELOAD")
end

-- Apply account-wide CVars (first-time setup only)
function InstallWizard:ApplyAccountCVars()
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

    -- Check if RealUI_CombatText is loaded
    if _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded("RealUI_CombatText") and not RealUI.isMidnight then
        accountCVars["enableFloatingCombatText"] = 0   -- Turn off Combat Text
    end

    for cvar, value in next, accountCVars do
        _G.SetCVar(cvar, value)
    end

    debug("Account CVars applied")
end


-- Advance to next stage
function InstallWizard:NextStage()
    local currentStage = self:GetCurrentStage()

    if currentStage == InstallWizard.STAGE_COMPLETE then
        return
    end

    local nextStage = currentStage + 1

    if nextStage > InstallWizard.STAGE_FINISH then
        self:Complete()
    else
        self:SetStage(nextStage)

        -- Update UI if available
        if RealUI.InstallUI then
            RealUI.InstallUI:UpdateStage(nextStage)
        end
    end
end

-- Go to previous stage
function InstallWizard:PreviousStage()
    local currentStage = self:GetCurrentStage()

    if currentStage <= InstallWizard.STAGE_WELCOME then
        return
    end

    local prevStage = currentStage - 1
    self:SetStage(prevStage)

    -- Update UI if available
    if RealUI.InstallUI then
        RealUI.InstallUI:UpdateStage(prevStage)
    end
end

-- Reset installation
function InstallWizard:Reset()
    self:SetStage(InstallWizard.STAGE_WELCOME)

    if RealUI.db and RealUI.db.char then
        RealUI.db.char.init.initialized = false
    end

    installState.stageData = {}

    debug("Installation reset")
end

-- Store data for current stage
function InstallWizard:SetStageData(key, value)
    local stage = self:GetCurrentStage()

    if not installState.stageData[stage] then
        installState.stageData[stage] = {}
    end

    installState.stageData[stage][key] = value
end

-- Get data for current stage
function InstallWizard:GetStageData(key)
    local stage = self:GetCurrentStage()

    if not installState.stageData[stage] then
        return nil
    end

    return installState.stageData[stage][key]
end

-- Get installation state
function InstallWizard:GetState()
    return installState
end
