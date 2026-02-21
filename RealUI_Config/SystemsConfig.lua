local _, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs

-- RealUI --
local RealUI = _G.RealUI
local L = RealUI.L

local options = private.options
local debug = private.debug

-- Configuration options for new systems
local function CreateSystemsConfig()
    debug("Creating Systems Configuration")

    local systemsConfig = {
        name = "Systems",
        type = "group",
        order = 100,
        args = {
            header = {
                name = "Advanced System Configuration",
                type = "header",
                order = 1,
            },
            desc = {
                name = "Configure advanced RealUI systems including modules, performance monitoring, profiles, and layouts.",
                type = "description",
                fontSize = "medium",
                order = 2,
            },
        }
    }

    -- Module Framework Configuration
    if RealUI.ModuleFramework then
        systemsConfig.args.moduleFramework = {
            name = "Module Framework",
            type = "group",
            order = 10,
            args = {
                header = {
                    name = "Module Framework",
                    type = "header",
                    order = 1,
                },
                status = {
                    name = "Status",
                    type = "group",
                    inline = true,
                    order = 10,
                    args = {
                        info = {
                            name = function()
                                local status = RealUI.ModuleFramework:GetFrameworkStatus()
                                return ("Initialized: %s\nTotal Modules: %d\nEnabled: %d\nDisabled: %d"):format(
                                    status.initialized and "Yes" or "No",
                                    status.totalModules,
                                    status.enabledModules,
                                    status.disabledModules
                                )
                            end,
                            type = "description",
                            fontSize = "medium",
                            order = 1,
                        },
                    },
                },
                modules = {
                    name = "Registered Modules",
                    type = "group",
                    inline = true,
                    order = 20,
                    args = {
                        refresh = {
                            name = "Refresh",
                            type = "execute",
                            func = function()
                                -- Force options refresh
                                _G.LibStub("AceConfigRegistry-3.0"):NotifyChange("RealUI")
                            end,
                            order = 1,
                        },
                    },
                },
            },
        }

        -- Dynamically add module toggles
        local modules = RealUI.ModuleFramework:GetRegisteredModules()
        local order = 10
        for name, info in pairs(modules) do
            order = order + 1
            local state = RealUI.ModuleFramework:GetModuleState(name)

            systemsConfig.args.moduleFramework.args.modules.args[name] = {
                name = name,
                desc = ("Type: %s\nState: %s"):format(info.type, state),
                type = "toggle",
                get = function()
                    local currentState = RealUI.ModuleFramework:GetModuleState(name)
                    return currentState == "enabled"
                end,
                set = function(_, value)
                    if value then
                        RealUI.ModuleFramework:EnableModule(name)
                    else
                        RealUI.ModuleFramework:DisableModule(name)
                    end
                    -- Refresh the config to show updated state
                    _G.C_Timer.After(0.1, function()
                        _G.LibStub("AceConfigRegistry-3.0"):NotifyChange("RealUI")
                    end)
                end,
                order = order,
            }
        end
    end

    -- Performance Monitor Configuration
    if RealUI.PerformanceMonitor then
        systemsConfig.args.performance = {
            name = "Performance Monitor",
            type = "group",
            order = 20,
            args = {
                header = {
                    name = "Performance Monitor",
                    type = "header",
                    order = 1,
                },
                enabled = {
                    name = L["Sys_PerformanceMonitorEnabled"],
                    desc = L["Sys_PerformanceMonitorEnabledDesc"],
                    type = "toggle",
                    order = 5,
                    get = function()
                        return RealUI.db and RealUI.db.profile.settings.performanceMonitorEnabled
                    end,
                    set = function(_, value)
                        if RealUI.db then
                            RealUI.db.profile.settings.performanceMonitorEnabled = value
                        end
                        if value then
                            if not RealUI.PerformanceMonitor:IsMonitoring() then
                                RealUI.PerformanceMonitor:StartMonitoring()
                            end
                        else
                            if RealUI.PerformanceMonitor:IsMonitoring() then
                                RealUI.PerformanceMonitor:StopMonitoring()
                            end
                        end
                    end,
                },
                stats = {
                    name = "Current Statistics",
                    type = "group",
                    inline = true,
                    order = 10,
                    args = {
                        info = {
                            name = function()
                                local perfData = RealUI.PerformanceMonitor:GetPerformanceData()
                                if perfData then
                                    return ("Memory: %.2f MB (Peak: %.2f MB)\nCPU: %.2f ms (Peak: %.2f ms)\nFramerate: %.1f FPS (Min: %.1f FPS)"):format(
                                        (perfData.memory.current or 0) / 1024,
                                        (perfData.memory.peak or 0) / 1024,
                                        perfData.cpu.current or 0,
                                        perfData.cpu.peak or 0,
                                        perfData.framerate.current or 0,
                                        perfData.framerate.min or 0
                                    )
                                else
                                    return "Performance data not available"
                                end
                            end,
                            type = "description",
                            fontSize = "medium",
                            order = 1,
                        },
                        refresh = {
                            name = "Refresh",
                            type = "execute",
                            func = function()
                                _G.LibStub("AceConfigRegistry-3.0"):NotifyChange("RealUI")
                            end,
                            order = 2,
                        },
                    },
                },
            },
        }
    end

    -- Profile System Configuration
    if RealUI.ProfileSystem then
        systemsConfig.args.profiles = {
            name = "Profile System",
            type = "group",
            order = 30,
            args = {
                header = {
                    name = "Profile System",
                    type = "header",
                    order = 1,
                },
                current = {
                    name = "Current Profile",
                    type = "group",
                    inline = true,
                    order = 10,
                    args = {
                        profile = {
                            name = function()
                                return "Active: " .. (RealUI.ProfileSystem:GetCurrentProfile() or "Unknown")
                            end,
                            type = "description",
                            fontSize = "medium",
                            order = 1,
                        },
                    },
                },
                switch = {
                    name = "Switch Profile",
                    type = "group",
                    inline = true,
                    order = 20,
                    args = {
                        select = {
                            name = "Select Profile",
                            type = "select",
                            values = function()
                                local profiles = RealUI.ProfileSystem:GetProfileList()
                                local profileTable = {}
                                for _, name in ipairs(profiles) do
                                    profileTable[name] = name
                                end
                                return profileTable
                            end,
                            get = function()
                                return RealUI.ProfileSystem:GetCurrentProfile()
                            end,
                            set = function(info, value)
                                RealUI.ProfileSystem:SwitchProfile(value)
                            end,
                            order = 1,
                        },
                    },
                },
            },
        }
    end

    -- Layout Manager Configuration
    if RealUI.LayoutManager then
        systemsConfig.args.layout = {
            name = "Layout Manager",
            type = "group",
            order = 40,
            args = {
                header = {
                    name = "Layout Manager",
                    type = "header",
                    order = 1,
                },
                current = {
                    name = "Current Layout",
                    type = "group",
                    inline = true,
                    order = 10,
                    args = {
                        info = {
                            name = function()
                                local current = RealUI.LayoutManager:GetCurrentLayout()
                                local name = RealUI.LayoutManager:GetCurrentLayoutName()
                                return ("Layout: %d - %s"):format(current, name)
                            end,
                            type = "description",
                            fontSize = "medium",
                            order = 1,
                        },
                    },
                },
                switch = {
                    name = "Switch Layout",
                    type = "group",
                    inline = true,
                    order = 20,
                    args = {
                        dps = {
                            name = "DPS/Tank Layout",
                            type = "execute",
                            func = function()
                                RealUI.LayoutManager:SwitchToDPSTankLayout()
                            end,
                            order = 1,
                        },
                        healing = {
                            name = "Healing Layout",
                            type = "execute",
                            func = function()
                                RealUI.LayoutManager:SwitchToHealingLayout()
                            end,
                            order = 2,
                        },
                        toggle = {
                            name = "Toggle Layout",
                            type = "execute",
                            func = function()
                                RealUI.LayoutManager:ToggleLayout()
                            end,
                            order = 3,
                        },
                    },
                },
                autoSwitch = {
                    name = "Auto-Switch Settings",
                    type = "group",
                    inline = true,
                    order = 30,
                    args = {
                        enabled = {
                            name = "Enable Auto-Switch",
                            desc = "Automatically switch layouts based on specialization",
                            type = "toggle",
                            get = function()
                                return RealUI.LayoutManager:IsAutoSwitchEnabled()
                            end,
                            set = function(info, value)
                                RealUI.LayoutManager:SetAutoSwitchEnabled(value)
                            end,
                            order = 1,
                        },
                    },
                },
            },
        }
    end

    -- Resolution Optimizer Configuration
    if RealUI.ResolutionOptimizer then
        systemsConfig.args.resolution = {
            name = "Resolution Optimizer",
            type = "group",
            order = 50,
            args = {
                header = {
                    name = "Resolution Optimizer",
                    type = "header",
                    order = 1,
                },
                current = {
                    name = "Current Resolution",
                    type = "group",
                    inline = true,
                    order = 10,
                    args = {
                        info = {
                            name = function()
                                local width, height = RealUI.ResolutionOptimizer:GetScreenDimensions()
                                local profile, category = RealUI.ResolutionOptimizer:GetOptimizationProfile()
                                if profile then
                                    return ("Screen: %dx%d\nCategory: %s\n%s"):format(
                                        width, height, category, profile.description
                                    )
                                else
                                    return ("Screen: %dx%d\nNo optimization profile"):format(width, height)
                                end
                            end,
                            type = "description",
                            fontSize = "medium",
                            order = 1,
                        },
                    },
                },
                actions = {
                    name = "Actions",
                    type = "group",
                    inline = true,
                    order = 20,
                    args = {
                        reoptimize = {
                            name = "Re-optimize",
                            desc = "Force re-optimization for current resolution",
                            type = "execute",
                            func = function()
                                RealUI.ResolutionOptimizer:ReOptimize()
                            end,
                            order = 1,
                        },
                    },
                },
            },
        }
    end

    -- Compatibility Manager Configuration
    if RealUI.CompatibilityManager then
        systemsConfig.args.compatibility = {
            name = "Compatibility",
            type = "group",
            order = 60,
            args = {
                header = {
                    name = "Compatibility Manager",
                    type = "header",
                    order = 1,
                },
                check = {
                    name = "Compatibility Check",
                    type = "group",
                    inline = true,
                    order = 10,
                    args = {
                        run = {
                            name = "Check Compatibility",
                            type = "execute",
                            func = function()
                                local issues = RealUI.CompatibilityManager:CheckCompatibility()
                                if #issues > 0 then
                                    for _, issue in ipairs(issues) do
                                        _G.print(("[%s] %s: %s"):format(issue.severity, issue.addon, issue.message))
                                    end
                                else
                                    _G.print("No compatibility issues detected")
                                end
                            end,
                            order = 1,
                        },
                    },
                },
            },
        }
    end

    -- Deployment Validator Configuration
    if RealUI.DeploymentValidator then
        systemsConfig.args.deployment = {
            name = "Deployment",
            type = "group",
            order = 70,
            args = {
                header = {
                    name = "Deployment Validator",
                    type = "header",
                    order = 1,
                },
                validation = {
                    name = "Validation Status",
                    type = "group",
                    inline = true,
                    order = 10,
                    args = {
                        status = {
                            name = function()
                                local state = RealUI.DeploymentValidator:GetValidationState()
                                return ("Validated: %s\nPassed: %s\nErrors: %d\nWarnings: %d"):format(
                                    state.validated and "Yes" or "No",
                                    state.passed and "Yes" or "No",
                                    #state.errors,
                                    #state.warnings
                                )
                            end,
                            type = "description",
                            fontSize = "medium",
                            order = 1,
                        },
                        validate = {
                            name = "Run Validation",
                            type = "execute",
                            func = function()
                                local passed, errors = RealUI.DeploymentValidator:RunValidation()
                                if passed then
                                    _G.print("Validation passed!")
                                else
                                    _G.print("Validation failed:")
                                    for _, error in ipairs(errors) do
                                        _G.print(("  %s: %s"):format(error.check, error.message))
                                    end
                                end
                                _G.LibStub("AceConfigRegistry-3.0"):NotifyChange("RealUI")
                            end,
                            order = 2,
                        },
                    },
                },
            },
        }
    end

    return systemsConfig
end

-- Add to options when config is loaded
local function OnConfigLoad()
    if not options.RealUI then
        options.RealUI = {
            name = "|cffffffffRealUI|r "..RealUI:GetVerString(true),
            type = "group",
            args = {}
        }
    end

    options.RealUI.args.systems = CreateSystemsConfig()
end

-- Hook into initialization
if RealUI.isInitialized then
    OnConfigLoad()
else
    local frame = _G.CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_LOGIN" then
            _G.C_Timer.After(1, OnConfigLoad)
            self:UnregisterAllEvents()
        end
    end)
end
