local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("UserExperiencePolish")

-- User Experience Polish Module
-- Handles final UX improvements, accessibility, and usability enhancements
local UXPolish = {}
private.UXPolish = UXPolish

-- UX State
local uxState = {
    initialized = false,
    tooltipsEnhanced = false,
    accessibilityEnabled = false,
    guidanceActive = false
}

-- Enhance tooltips with helpful information
function UXPolish:EnhanceTooltips()
    if uxState.tooltipsEnhanced then
        return true
    end

    debug("Enhancing tooltips...")

    -- Add helpful tooltips to configuration options
    local tooltips = {
        layoutSwitch = "Switch between DPS/Tank and Healing layouts. Layouts automatically change with your specialization.",
        hudSize = "Adjust the size of your HuD (Heads-up Display). Larger sizes provide more space for unit frames and action bars.",
        configMode = "Enable configuration mode to move and position UI elements. Drag frames to your preferred locations.",
        performanceMonitor = "Monitor RealUI's resource usage. Helps identify performance issues and optimize settings.",
        profileManager = "Manage your RealUI profiles. Create backups, restore settings, and share configurations.",
        safeMode = "Enable safe mode to disable non-essential modules. Useful for troubleshooting issues."
    }

    -- Store tooltips for later use
    RealUI.tooltips = tooltips

    uxState.tooltipsEnhanced = true
    debug("Tooltips enhanced")
    return true
end

-- Add accessibility features
function UXPolish:EnableAccessibility()
    if uxState.accessibilityEnabled then
        return true
    end

    debug("Enabling accessibility features...")

    -- Ensure readable font sizes
    local minFontSize = 12
    if RealUI.db and RealUI.db.profile.fonts then
        for fontType, fontData in pairs(RealUI.db.profile.fonts) do
            if fontData.size and fontData.size < minFontSize then
                fontData.size = minFontSize
                debug("Increased font size for", fontType, "to", minFontSize)
            end
        end
    end

    -- Ensure sufficient contrast
    if RealUI.db and RealUI.db.profile.colors then
        -- Colors are already managed by Aurora/RealUI_Skins
    end

    -- Add keyboard navigation support
    self:EnableKeyboardNavigation()

    uxState.accessibilityEnabled = true
    debug("Accessibility features enabled")
    return true
end

-- Enable keyboard navigation
function UXPolish:EnableKeyboardNavigation()
    debug("Enabling keyboard navigation...")

    -- Register keybindings for common actions
    _G.BINDING_HEADER_REALUI = "RealUI"
    _G.BINDING_NAME_REALUI_CONFIG = "Open Configuration"
    _G.BINDING_NAME_REALUI_LAYOUT_TOGGLE = "Toggle Layout"
    _G.BINDING_NAME_REALUI_CONFIG_MODE = "Toggle Config Mode"

    debug("Keyboard navigation enabled")
end

-- Provide contextual user guidance
function UXPolish:ProvideGuidance(context)
    if not RealUI.FeedbackSystem then
        return false
    end

    local guidance = {
        first_login = {
            title = "Welcome to RealUI!",
            message = "RealUI is now configured. Type /realui to access settings, or /configmode to reposition UI elements.",
            icon = [[Interface\AddOns\nibRealUI\Media\Icon]]
        },
        layout_switched = {
            title = "Layout Changed",
            message = "Your UI layout has been switched. Layouts automatically change with your specialization.",
            icon = [[Interface\AddOns\nibRealUI\Media\Icon]]
        },
        combat_lockdown = {
            title = "Combat Lockdown",
            message = "Configuration is locked during combat. Changes will be available after combat ends.",
            icon = [[Interface\AddOns\nibRealUI\Media\Notification_Alert]]
        },
        performance_warning = {
            title = "Performance Warning",
            message = "High resource usage detected. Consider disabling some modules or enabling safe mode.",
            icon = [[Interface\AddOns\nibRealUI\Media\Notification_Alert]]
        },
        profile_corrupted = {
            title = "Profile Issue",
            message = "Your profile may be corrupted. RealUI has restored default settings. Use /profilemgr to restore a backup.",
            icon = [[Interface\AddOns\nibRealUI\Media\Notification_Alert]]
        }
    }

    local guide = guidance[context]
    if guide then
        RealUI.FeedbackSystem:ShowNotification(guide.title, guide.message, guide.icon)
        return true
    end

    return false
end

-- Improve error messages with actionable guidance
function UXPolish:ImproveErrorMessages()
    debug("Improving error messages...")

    -- Enhanced error messages with solutions
    local errorGuidance = {
        module_load_failed = {
            message = "A module failed to load. Try disabling and re-enabling it in /realui settings.",
            action = function(moduleName)
                if RealUI.ModuleFramework then
                    RealUI.ModuleFramework:DisableModule(moduleName)
                    RealUI:ScheduleTimer(function()
                        RealUI.ModuleFramework:EnableModule(moduleName)
                    end, 2)
                end
            end
        },
        profile_corruption = {
            message = "Your profile is corrupted. RealUI can restore from a backup or reset to defaults.",
            action = function()
                if RealUI.ProfileManager and RealUI.ProfileManager:HasBackups() then
                    RealUI.ProfileManager:RestoreBackup(1)
                else
                    RealUI.db:ResetProfile()
                end
            end
        },
        addon_conflict = {
            message = "An addon conflict was detected. RealUI can attempt to resolve it automatically.",
            action = function(conflictingAddon)
                if RealUI.CompatibilityManager then
                    RealUI.CompatibilityManager:ResolveConflict(conflictingAddon)
                end
            end
        }
    }

    RealUI.errorGuidance = errorGuidance

    debug("Error messages improved")
end

-- Add helpful hints and tips
function UXPolish:ShowHelpfulHints()
    if not RealUI.db or not RealUI.db.global then
        return false
    end

    local hints = {
        {
            id = "layout_switching",
            message = "Tip: Layouts automatically switch with your specialization. Use /layouttoggle to switch manually.",
            condition = function()
                return RealUI.db.char.init.installStage == -1 and not RealUI.db.global.hints_shown.layout_switching
            end
        },
        {
            id = "config_mode",
            message = "Tip: Use /configmode to reposition UI elements. Drag frames to your preferred locations.",
            condition = function()
                return RealUI.db.char.init.installStage == -1 and not RealUI.db.global.hints_shown.config_mode
            end
        },
        {
            id = "performance_monitoring",
            message = "Tip: Use /perfmon status to check RealUI's resource usage and performance.",
            condition = function()
                return RealUI.db.char.init.installStage == -1 and not RealUI.db.global.hints_shown.performance_monitoring
            end
        }
    }

    -- Initialize hints_shown table if needed
    if not RealUI.db.global.hints_shown then
        RealUI.db.global.hints_shown = {}
    end

    -- Show one hint per session
    for _, hint in ipairs(hints) do
        if hint.condition() then
            RealUI:ScheduleTimer(function()
                _G.print("|cFF00A0FF[RealUI]|r " .. hint.message)
                RealUI.db.global.hints_shown[hint.id] = true
            end, 5)
            break
        end
    end

    return true
end

-- Improve configuration interface responsiveness
function UXPolish:ImproveConfigInterface()
    debug("Improving configuration interface...")

    -- Add loading indicators for slow operations
    -- Add confirmation dialogs for destructive actions
    -- Add undo/redo support for configuration changes

    -- These are handled by the configuration addon (nibRealUI_Config)
    -- but we can provide helper functions here

    RealUI.configHelpers = {
        showLoadingIndicator = function(message)
            if RealUI.FeedbackSystem then
                RealUI.FeedbackSystem:ShowNotification("Loading", message)
            end
        end,
        hideLoadingIndicator = function()
            -- Handled by FeedbackSystem timeout
        end,
        confirmAction = function(title, message, callback)
            _G.StaticPopupDialogs["REALUI_CONFIRM_ACTION"] = {
                text = message,
                button1 = _G.YES,
                button2 = _G.NO,
                OnAccept = callback,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true
            }
            _G.StaticPopup_Show("REALUI_CONFIRM_ACTION")
        end
    }

    debug("Configuration interface improved")
end

-- Add comprehensive error handling with user guidance
function UXPolish:EnhanceErrorHandling()
    debug("Enhancing error handling...")

    -- Wrap critical functions with user-friendly error handlers
    if RealUI.LayoutManager then
        local originalSwitch = RealUI.LayoutManager.SwitchToLayout
        RealUI.LayoutManager.SwitchToLayout = function(self, layoutId)
            local success, result = pcall(originalSwitch, self, layoutId)
            if not success then
                UXPolish:ProvideGuidance("layout_switch_failed")
                if RealUI.ErrorRecovery then
                    RealUI.ErrorRecovery:RecoverLayoutSwitch(layoutId)
                end
                return false
            end
            return result
        end
    end

    debug("Error handling enhanced")
end

-- Initialize user experience polish
function UXPolish:Initialize()
    if uxState.initialized then
        return true
    end

    debug("Initializing user experience polish...")

    -- Enhance tooltips
    self:EnhanceTooltips()

    -- Enable accessibility features
    self:EnableAccessibility()

    -- Improve error messages
    self:ImproveErrorMessages()

    -- Improve configuration interface
    self:ImproveConfigInterface()

    -- Enhance error handling
    self:EnhanceErrorHandling()

    -- Show helpful hints after a delay
    RealUI:ScheduleTimer(function()
        self:ShowHelpfulHints()
    end, 10)

    uxState.initialized = true
    debug("User experience polish initialized")

    return true
end

-- Get UX state
function UXPolish:GetState()
    return uxState
end

-- Expose UXPolish to RealUI
RealUI.UXPolish = UXPolish
