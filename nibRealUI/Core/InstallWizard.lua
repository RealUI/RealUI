local _, private = ...

-- Lua Globals --
-- luacheck: globals next type

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("InstallWizard")

-- Installation Wizard Framework
-- Handles first-time setup detection, progressive installation stages, and resumption

local InstallWizard = {}
RealUI.InstallWizard = InstallWizard

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

    debug("Initialized - FirstTime:", installState.isFirstTime,
          "Stage:", installState.currentStage, "NeedsResume:", installState.needsResume)

    return installState
end

-- Start installation wizard
function InstallWizard:Start()
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

    -- Perform character initialization
    if RealUI.CharacterInit then
        RealUI.CharacterInit:Setup()
    end

    debug("Installation completed")

    -- Hide installation wizard UI
    if RealUI.InstallUI then
        RealUI.InstallUI:Hide()
    end
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
