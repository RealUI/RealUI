local _, private = ...

-- Lua Globals --
-- luacheck: globals next type

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("TutorialSystem")

-- Tutorial and Guidance System
-- Manages tutorial stage progression, helpful messages, and user guidance

local TutorialSystem = {}
RealUI.TutorialSystem = TutorialSystem

-- Tutorial stage constants
TutorialSystem.STAGE_COMPLETE = -1
TutorialSystem.STAGE_WELCOME = 0
TutorialSystem.STAGE_INTERFACE = 1
TutorialSystem.STAGE_LAYOUT = 2
TutorialSystem.STAGE_MODULES = 3
TutorialSystem.STAGE_FINISH = 4

-- Tutorial messages and guidance
local tutorialMessages = {
    [TutorialSystem.STAGE_WELCOME] = {
        title = "Welcome to RealUI!",
        message = "This tutorial will help you understand the key features of RealUI.",
        instructions = {
            "RealUI is a complete UI replacement with modular design",
            "You can customize every aspect through the configuration menu",
            "Type /realui to access settings at any time"
        }
    },
    [TutorialSystem.STAGE_INTERFACE] = {
        title = "Interface Overview",
        message = "Let's explore the main interface elements.",
        instructions = {
            "The HuD (Heads-up Display) shows your player and target frames",
            "Action bars are positioned at the bottom of the screen",
            "The minimap is in the top-right corner",
            "Info bars at the bottom provide system information"
        }
    },
    [TutorialSystem.STAGE_LAYOUT] = {
        title = "Layout System",
        message = "RealUI provides role-specific layouts.",
        instructions = {
            "Layout 1 (DPS/Tank): Optimized for damage and tanking",
            "Layout 2 (Healing): Optimized for healing with raid frames",
            "Layouts switch automatically based on your specialization",
            "You can manually switch layouts using /layoutswitch"
        }
    },
    [TutorialSystem.STAGE_MODULES] = {
        title = "Modular Components",
        message = "RealUI consists of independent modules you can enable or disable.",
        instructions = {
            "Each module handles a specific feature (chat, bags, tooltips, etc.)",
            "Modules can be enabled/disabled in the configuration menu",
            "Some modules have their own configuration options",
            "Disabling modules can improve performance if needed"
        }
    },
    [TutorialSystem.STAGE_FINISH] = {
        title = "Tutorial Complete!",
        message = "You're ready to use RealUI!",
        instructions = {
            "Access settings anytime with /realui or /real",
            "Use /configmode to reposition UI elements",
            "Check /realadv for advanced options",
            "Visit the RealUI website for more information"
        }
    }
}

-- Initialize tutorial system
function TutorialSystem:Initialize()
    if not RealUI.db or not RealUI.db.global then
        return false
    end

    -- Ensure tutorial data structure exists
    if not RealUI.db.global.tutorial then
        RealUI.db.global.tutorial = {
            stage = TutorialSystem.STAGE_COMPLETE
        }
    end

    debug("Tutorial system initialized")
    return true
end

-- Get current tutorial stage
function TutorialSystem:GetCurrentStage()
    if not RealUI.db or not RealUI.db.global or not RealUI.db.global.tutorial then
        return TutorialSystem.STAGE_COMPLETE
    end

    return RealUI.db.global.tutorial.stage
end

-- Set tutorial stage
function TutorialSystem:SetStage(stage)
    if not RealUI.db or not RealUI.db.global or not RealUI.db.global.tutorial then
        return
    end

    RealUI.db.global.tutorial.stage = stage
    debug("Tutorial stage set to:", stage)
end

-- Check if tutorial is active
function TutorialSystem:IsActive()
    local stage = self:GetCurrentStage()
    return stage >= TutorialSystem.STAGE_WELCOME and stage < TutorialSystem.STAGE_COMPLETE
end

-- Start tutorial
function TutorialSystem:Start()
    self:SetStage(TutorialSystem.STAGE_WELCOME)

    -- Show first tutorial message
    self:ShowStageMessage(TutorialSystem.STAGE_WELCOME)

    debug("Tutorial started")
end

-- Advance to next stage
function TutorialSystem:NextStage()
    local currentStage = self:GetCurrentStage()

    if currentStage >= TutorialSystem.STAGE_FINISH then
        self:Complete()
        return
    end

    local nextStage = currentStage + 1
    self:SetStage(nextStage)

    -- Show next stage message
    self:ShowStageMessage(nextStage)

    debug("Advanced to stage:", nextStage)
end

-- Go to previous stage
function TutorialSystem:PreviousStage()
    local currentStage = self:GetCurrentStage()

    if currentStage <= TutorialSystem.STAGE_WELCOME then
        return
    end

    local prevStage = currentStage - 1
    self:SetStage(prevStage)

    -- Show previous stage message
    self:ShowStageMessage(prevStage)

    debug("Returned to stage:", prevStage)
end

-- Complete tutorial
function TutorialSystem:Complete()
    self:SetStage(TutorialSystem.STAGE_COMPLETE)

    -- Show completion message
    RealUI:Notification(
        "tutorial_complete",
        false,
        "Tutorial completed! You can restart it anytime from the configuration menu.",
        nil,
        [[Interface\AddOns\nibRealUI\Media\Icon]]
    )

    debug("Tutorial completed")
end

-- Skip tutorial
function TutorialSystem:Skip()
    self:SetStage(TutorialSystem.STAGE_COMPLETE)
    debug("Tutorial skipped")
end

-- Reset tutorial
function TutorialSystem:Reset()
    self:SetStage(TutorialSystem.STAGE_WELCOME)
    debug("Tutorial reset")
end

-- Show stage message
function TutorialSystem:ShowStageMessage(stage)
    local stageInfo = tutorialMessages[stage]

    if not stageInfo then
        return
    end

    -- Build message text
    local messageText = stageInfo.title .. "\n\n" .. stageInfo.message .. "\n\n"

    if stageInfo.instructions then
        for i, instruction in ipairs(stageInfo.instructions) do
            messageText = messageText .. "• " .. instruction .. "\n"
        end
    end

    -- Show notification
    RealUI:Notification(
        "tutorial_stage_" .. stage,
        false,
        messageText,
        function()
            self:NextStage()
        end,
        [[Interface\AddOns\nibRealUI\Media\Icon]]
    )
end

-- Get helpful message for context
function TutorialSystem:GetHelpfulMessage(context)
    local messages = {
        first_login = "Welcome to RealUI! Type /realui to access configuration options.",
        layout_switch = "Layout switched! Your UI is now optimized for your current role.",
        config_mode = "Config Mode activated. Move UI elements by dragging them. Type /configmode again to exit.",
        module_disabled = "Module disabled. You can re-enable it in the configuration menu.",
        low_performance = "Performance issue detected. Consider disabling some modules to improve FPS.",
        combat_lockdown = "Cannot access configuration during combat. Please try again after combat ends."
    }

    return messages[context] or "Need help? Type /realui for configuration options."
end

-- Show helpful message
function TutorialSystem:ShowHelpfulMessage(context, persistent)
    local message = self:GetHelpfulMessage(context)

    RealUI:Notification(
        "help_" .. context,
        persistent or false,
        message,
        nil,
        [[Interface\AddOns\nibRealUI\Media\Icon]]
    )
end

-- Get setup instructions
function TutorialSystem:GetSetupInstructions()
    return {
        {
            title = "Basic Configuration",
            steps = {
                "Type /realui to open the configuration menu",
                "Navigate through the tabs to customize settings",
                "Changes are saved automatically",
                "Some changes may require a UI reload (/rl)"
            }
        },
        {
            title = "Layout Configuration",
            steps = {
                "Use /layoutswitch to manually change layouts",
                "Layouts automatically switch with specialization changes",
                "Each layout has independent positioning settings",
                "You can customize HuD size in the configuration menu"
            }
        },
        {
            title = "Module Management",
            steps = {
                "Enable/disable modules in the configuration menu",
                "Each module can be configured independently",
                "Disabled modules don't load, saving resources",
                "Some modules require other modules to function"
            }
        },
        {
            title = "Frame Positioning",
            steps = {
                "Type /configmode to enter configuration mode",
                "Drag frames to reposition them",
                "Right-click frames for additional options",
                "Type /configmode again to save and exit"
            }
        }
    }
end

-- Show setup instructions
function TutorialSystem:ShowSetupInstructions(category)
    local instructions = self:GetSetupInstructions()

    if category then
        -- Show specific category
        for _, instruction in ipairs(instructions) do
            if instruction.title:lower():find(category:lower()) then
                local messageText = instruction.title .. "\n\n"
                for i, step in ipairs(instruction.steps) do
                    messageText = messageText .. i .. ". " .. step .. "\n"
                end

                RealUI:Notification(
                    "instructions_" .. category,
                    false,
                    messageText,
                    nil,
                    [[Interface\AddOns\nibRealUI\Media\Icon]]
                )
                return
            end
        end
    else
        -- Show all instructions
        local messageText = "RealUI Setup Instructions\n\n"
        for _, instruction in ipairs(instructions) do
            messageText = messageText .. instruction.title .. ":\n"
            for i, step in ipairs(instruction.steps) do
                messageText = messageText .. "  " .. i .. ". " .. step .. "\n"
            end
            messageText = messageText .. "\n"
        end

        RealUI:Notification(
            "instructions_all",
            false,
            messageText,
            nil,
            [[Interface\AddOns\nibRealUI\Media\Icon]]
        )
    end
end

-- Get configuration explanation
function TutorialSystem:GetConfigurationExplanation(setting)
    local explanations = {
        hudSize = "HuD Size controls the scale and positioning of the player and target frames. Larger sizes provide more visibility but take up more screen space.",
        layout = "Layouts optimize the UI for different roles. DPS/Tank layout focuses on action bars, while Healing layout emphasizes raid frames.",
        modules = "Modules are independent components that can be enabled or disabled. Disabling unused modules can improve performance.",
        positions = "Frame positions can be customized in Config Mode. Each layout has independent positioning settings.",
        reverseUnitFrameBars = "Reverses the fill direction of health and power bars on unit frames for better visual tracking."
    }

    return explanations[setting] or "No explanation available for this setting."
end

-- Show configuration explanation
function TutorialSystem:ShowConfigurationExplanation(setting)
    local explanation = self:GetConfigurationExplanation(setting)

    RealUI:Notification(
        "explain_" .. setting,
        false,
        setting .. "\n\n" .. explanation,
        nil,
        [[Interface\AddOns\nibRealUI\Media\Icon]]
    )
end
