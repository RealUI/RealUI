-- RealUI Feedback System
-- Provides user feedback for configuration changes, system status, and error messaging

local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

local FeedbackSystem = {}
private.FeedbackSystem = FeedbackSystem

-- Feedback message types
local MessageType = {
    SUCCESS = "success",
    INFO = "info",
    WARNING = "warning",
    ERROR = "error"
}

-- Message icons by type
local messageIcons = {
    [MessageType.SUCCESS] = [[Interface\RaidFrame\ReadyCheck-Ready]],
    [MessageType.INFO] = [[Interface\Common\help-i]],
    [MessageType.WARNING] = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
    [MessageType.ERROR] = [[Interface\DialogFrame\UI-Dialog-Icon-AlertOther]]
}

-- Feedback history for troubleshooting
local feedbackHistory = {}
local maxHistorySize = 50

-- Initialize the feedback system
function FeedbackSystem:Initialize()
    self.initialized = true
    RealUI.Debug("FeedbackSystem", "Initialized")
end

-- Add feedback to history
local function addToHistory(messageType, title, message)
    table.insert(feedbackHistory, 1, {
        type = messageType,
        title = title,
        message = message,
        timestamp = time()
    })

    -- Trim history if too large
    while #feedbackHistory > maxHistorySize do
        table.remove(feedbackHistory)
    end
end

-- Show feedback notification
function FeedbackSystem:ShowFeedback(messageType, title, message, clickFunc, customIcon)
    if not self.initialized then
        self:Initialize()
    end

    -- Add to history
    addToHistory(messageType, title, message)

    -- Determine icon
    local icon = customIcon or messageIcons[messageType] or messageIcons[MessageType.INFO]

    -- Show notification
    RealUI:Notification(title, false, message, clickFunc, icon)
end

-- Configuration change feedback
function FeedbackSystem:ConfigurationChanged(settingName, newValue, oldValue)
    local message
    if oldValue ~= nil then
        message = ("Changed from %s to %s"):format(tostring(oldValue), tostring(newValue))
    else
        message = ("Set to %s"):format(tostring(newValue))
    end

    self:ShowFeedback(MessageType.SUCCESS, settingName, message)
end

-- Profile change feedback
function FeedbackSystem:ProfileChanged(profileName)
    self:ShowFeedback(
        MessageType.SUCCESS,
        "Profile Changed",
        ("Switched to profile: %s"):format(profileName)
    )
end

-- Layout change feedback
function FeedbackSystem:LayoutChanged(layoutName, layoutId)
    self:ShowFeedback(
        MessageType.SUCCESS,
        "Layout Changed",
        ("Switched to %s layout"):format(layoutName or ("Layout " .. layoutId))
    )
end

-- Module state feedback
function FeedbackSystem:ModuleStateChanged(moduleName, enabled)
    self:ShowFeedback(
        MessageType.INFO,
        moduleName,
        enabled and "Module enabled" or "Module disabled"
    )
end

-- System status feedback
function FeedbackSystem:SystemStatus(statusMessage, isWarning)
    self:ShowFeedback(
        isWarning and MessageType.WARNING or MessageType.INFO,
        "System Status",
        statusMessage
    )
end

-- Error messaging
function FeedbackSystem:ShowError(errorTitle, errorMessage, troubleshootingFunc)
    self:ShowFeedback(
        MessageType.ERROR,
        errorTitle,
        errorMessage,
        troubleshootingFunc
    )
end

-- Combat lockdown warning
function FeedbackSystem:CombatLockdownWarning(action)
    self:ShowFeedback(
        MessageType.WARNING,
        "Combat Lockdown",
        ("Cannot %s while in combat. Please try again after combat ends."):format(action or "perform this action")
    )
end

-- Installation progress feedback
function FeedbackSystem:InstallationProgress(stage, totalStages, message)
    self:ShowFeedback(
        MessageType.INFO,
        ("Installation Progress (%d/%d)"):format(stage, totalStages),
        message
    )
end

-- Migration feedback
function FeedbackSystem:MigrationComplete(fromVersion, toVersion)
    self:ShowFeedback(
        MessageType.SUCCESS,
        "Migration Complete",
        ("Updated from version %s to %s"):format(fromVersion, toVersion)
    )
end

-- Performance warning
function FeedbackSystem:PerformanceWarning(metric, value, threshold)
    self:ShowFeedback(
        MessageType.WARNING,
        "Performance Warning",
        ("%s is high: %s (threshold: %s)"):format(metric, value, threshold)
    )
end

-- Get feedback history
function FeedbackSystem:GetHistory(count)
    count = count or 10
    local history = {}
    for i = 1, math.min(count, #feedbackHistory) do
        table.insert(history, feedbackHistory[i])
    end
    return history
end

-- Clear feedback history
function FeedbackSystem:ClearHistory()
    feedbackHistory = {}
end

-- Print feedback history to chat
function FeedbackSystem:PrintHistory(count)
    count = count or 10
    print("Recent Feedback Messages:")
    local history = self:GetHistory(count)
    for i, entry in ipairs(history) do
        local timeStr = date("%H:%M:%S", entry.timestamp)
        print(("[%s] [%s] %s: %s"):format(timeStr, entry.type, entry.title, entry.message))
    end
end

-- Troubleshooting guidance
local troubleshootingGuides = {
    ["combat_lockdown"] = {
        title = "Combat Lockdown",
        steps = {
            "Wait for combat to end",
            "Try the action again",
            "If the issue persists, type /reload to reload the UI"
        }
    },
    ["addon_conflict"] = {
        title = "Addon Conflict Detected",
        steps = {
            "Disable conflicting addons",
            "Type /reload to reload the UI",
            "Re-enable addons one at a time to identify the conflict"
        }
    },
    ["profile_corruption"] = {
        title = "Profile Corruption",
        steps = {
            "Type /realui to open configuration",
            "Go to Profiles tab",
            "Reset the current profile or switch to a different one",
            "Type /reload to reload the UI"
        }
    },
    ["performance_issues"] = {
        title = "Performance Issues",
        steps = {
            "Type /perfmon status to check performance metrics",
            "Type /perfmon gc to run garbage collection",
            "Disable unnecessary modules",
            "Consider reducing HuD size with /hudsize 1"
        }
    }
}

function FeedbackSystem:ShowTroubleshootingGuide(guideKey)
    local guide = troubleshootingGuides[guideKey]
    if not guide then
        print("Troubleshooting guide not found:", guideKey)
        return
    end

    print("=== " .. guide.title .. " ===")
    for i, step in ipairs(guide.steps) do
        print(i .. ". " .. step)
    end
end

function FeedbackSystem:GetTroubleshootingGuide(guideKey)
    return troubleshootingGuides[guideKey]
end

-- Register with RealUI
RealUI.FeedbackSystem = FeedbackSystem
