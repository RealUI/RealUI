local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type strsplit tonumber

-- RealUI Core System
-- This file contains the main RealUI core functionality including version management,
-- profile system, layout management, and module coordination

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, dbc, dbg
local debug = RealUI.GetDebug("Core")

local LDS = _G.LibStub("LibDualSpec-1.0")

-- Enhanced Version Management System
local version = _G.C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
RealUI.verinfo = {strsplit(".", version)}
for i = 1, 3 do
    RealUI.verinfo[i] = tonumber(RealUI.verinfo[i]) or 0
end
RealUI.verinfo.string = version
RealUI.verinfo.build = select(4, _G.GetBuildInfo())
RealUI.verinfo.gameVersion = _G.GetBuildInfo()

-- Version comparison utilities
function RealUI:CompareVersions(ver1, ver2)
    for i = 1, 3 do
        local v1 = ver1[i] or 0
        local v2 = ver2[i] or 0
        if v1 > v2 then
            return 1
        elseif v1 < v2 then
            return -1
        end
    end
    return 0
end

function RealUI:IsNewerVersion(newVer, oldVer)
    return self:CompareVersions(newVer, oldVer) > 0
end

-- Configuration Mode Management
RealUI.configModeModules = {}
RealUI.isConfigMode = false

-- Layout Position Defaults
RealUI.defaultPositions = {
    [1] = {
        -- DPS/Tank Layout
        ["HuDX"] = 0,
        ["HuDY"] = -38,
        ["UFHorizontal"] = 200,
        ["ActionBarsY"] = -161.5,
        ["ActionBarsBotY"] = 16,
        ["CastBarPlayerX"] = 0,
        ["CastBarPlayerY"] = 0,
        ["CastBarTargetX"] = 0,
        ["CastBarTargetY"] = 0,
        ["SpellAlertWidth"] = 150,
        ["BossX"] = -32, -- Boss anchored to RIGHT
        ["BossY"] = 314
    },
    [2] = {
        -- Healing Layout
        ["HuDX"] = 0,
        ["HuDY"] = -38,
        ["UFHorizontal"] = 200,
        ["ActionBarsY"] = -115.5,
        ["ActionBarsBotY"] = 16,
        ["CastBarPlayerX"] = 0,
        ["CastBarPlayerY"] = -20,
        ["CastBarTargetX"] = 0,
        ["CastBarTargetY"] = -20,
        ["SpellAlertWidth"] = 150,
        ["BossX"] = -32, -- Boss anchored to RIGHT
        ["BossY"] = 314
    }
}

-- Profile to Layout Mapping
private.profileToLayout = {
    ["RealUI"] = 1,
    ["RealUI-Healing"] = 2
}
private.layoutToProfile = {
    "RealUI",
    "RealUI-Healing"
}

-- HuD Size Offset Configuration
RealUI.hudSizeOffsets = {
    [1] = {
        -- Small HuD
        ["UFHorizontal"] = 0,
        ["SpellAlertWidth"] = 0,
        ["ActionBarsY"] = 0,
        ["CastBarPlayerY"] = 0,
        ["CastBarTargetY"] = 0
    },
    [2] = {
        -- Large HuD
        ["UFHorizontal"] = 100,
        ["SpellAlertWidth"] = 100,
        ["ActionBarsY"] = -20,
        ["CastBarPlayerY"] = -20,
        ["CastBarTargetY"] = -20
    }
}

-- Default Options
local defaults, charInit
do
    charInit = {
        installStage = 0,
        initialized = false,
        needchatmoved = true
    }
    local spec = {}
    for specIndex = 1, #RealUI.charInfo.specs do
        local role = RealUI.charInfo.specs[specIndex].role
        debug("Spec info", specIndex, role)
        spec[specIndex] = role == "HEALER" and 2 or 1
    end
    defaults = {
        global = {
            tutorial = {
                stage = -1
            },
            tags = {
                firsttime = true,
                lowResOptimized = false,
                slashRealUITyped = false -- To disable "Type /realui" message
            },
            messages = {},
            verinfo = {},
            patchedTOC = 0,
            currency = {}
        },
        char = {
            init = charInit,
            layout = {
                current = 1, -- 1 = DPS/Tank, 2 = Healing
                spec = spec -- Save layout for each spec
            }
        },
        profile = {
            modules = {
                ["*"] = true
            },
            registeredChars = {},
            -- HuD positions
            positionsLink = true,
            positions = RealUI.defaultPositions,
            -- Action Bar settings
            abSettingsLink = false,
            -- Dynamic UI settings
            settings = {
                hudSize = 2,
                reverseUnitFrameBars = false
            }
        }
    }
end

--------------------------------------------------------

-- Move HuD Up if using a Low Resolution display
function RealUI:SetLowResOptimizations(...)
    local dbp, dp = db.positions, self.defaultPositions
    if (dbp[RealUI.cLayout]["HuDY"] == dp[RealUI.cLayout]["HuDY"]) then
        dbp[RealUI.cLayout]["HuDY"] = -5
    end
    if (dbp[RealUI.ncLayout]["HuDY"] == dp[RealUI.ncLayout]["HuDY"]) then
        dbp[RealUI.ncLayout]["HuDY"] = -5
    end
    db.settings.hudSize = 1

    RealUI:UpdateLayout()

    dbg.tags.lowResOptimized = true
end

function RealUI:IsUsingLowResDisplay()
    local _, pysHeight = _G.GetPhysicalScreenSize()
    return pysHeight < 1080
end

function RealUI:IsUsingHighResDisplay()
    local _, pysHeight = _G.GetPhysicalScreenSize()
    return pysHeight >= 1440
end

-- Layout Updates
function RealUI:UpdateLayout(layout)
    layout = layout or dbc.layout.current

    -- Use LayoutManager if available
    if self.LayoutManager and self.LayoutManager:IsValidLayout(layout) then
        return self.LayoutManager:SwitchToLayout(layout)
    end

    -- Fallback to legacy layout handling
    dbc.layout.current = layout

    -- Set Current and Not-Current layout variables
    self.cLayout = layout
    self.ncLayout = layout == 1 and 2 or 1

    if self.isConfigMode and _G.Grid2Options then
        self:ScheduleTimer(
            function()
                self:ToggleGridTestMode(false)
                self:ToggleGridTestMode(true)
            end,
            0.5
        )
    end
end

-- Version info retrieval
function RealUI:GetVerString()
    return RealUI.verinfo.string
end
function RealUI:GetVersionChange(oldVer, curVer)
    if oldVer[1] == 2 then
        return ((curVer[1] > oldVer[1]) and "major") or ((curVer[2] > oldVer[2]) and "minor")
    else
        return "major"
    end
end

-- To help position UI elements
function _G.RealUI_TestRaidWarnings()
    RealUI:ScheduleRepeatingTimer(
        function()
            _G.RaidNotice_AddMessage(_G.RaidWarningFrame, _G.CHAT_MSG_RAID_WARNING, {r = 0, g = 1, b = 0})
            _G.RaidNotice_AddMessage(_G.RaidBossEmoteFrame, _G.CHAT_MSG_RAID_BOSS_EMOTE, {r = 0, g = 1, b = 0})
        end,
        5
    )
end

function RealUI:Taint_Logging_Toggle()
    local taintLog = _G.GetCVar("taintLog")
    _G.SetCVar("taintLog", (taintLog ~= "0") and "0" or "2")
    _G.ReloadUI()
end

function RealUI:ChatCommand_Config()
    RealUI.Debug("Config", "/real")
    dbg.tags.slashRealUITyped = true
    RealUI.LoadConfig("HuD")
end

local configLoaded = false
function RealUI.LoadConfig(app, section, ...)
    debug("RealUI.LoadConfig", app, section, ...)
    if _G.InCombatLockdown() then
        return RealUI:Notification(
            L["Alert_CombatLockdown"],
            true,
            L["Alert_CantOpenInCombat"],
            nil,
            [[Interface\AddOns\nibRealUI\Media\Notification_Alert]]
        )
    end
    debug("is loaded", configLoaded)
    if not configLoaded then
        local reason
        configLoaded, reason = _G.C_AddOns.LoadAddOn("nibRealUI_Config")
        debug("LoadAddOn", configLoaded, reason)
        if not configLoaded then
            _G.error(_G.ADDON_LOAD_FAILED:format("nibRealUI_Config", _G["ADDON_" .. reason]))
        end
    end
    debug("ToggleConfig", RealUI.ToggleConfig)
    RealUI.ToggleConfig(app, section, ...)
end

function RealUI:OnProfileUpdate(event, database, profile)
    db = database.profile
    dbc = database.char
    dbg = database.global

    RealUI:SetProfilesToRealUI()

    for _, module in self:IterateModules() do
        module:OnProfileUpdate(event, profile)
    end

    -- Update old stuff too for now
    RealUI:UpdateLayout(private.profileToLayout[profile])

    if event == "OnProfileReset" then
        debug("OnProfileReset", RealUI.db.char.init, RealUI.db.char.init.installStage)
        RealUI.db.char.init = charInit
        debug("Char", RealUI.db.char.init, RealUI.db.char.init.installStage)
        RealUI:ReloadUIDialog()
    end
end

_G.StaticPopupDialogs["PUDRUIRELOADUI"] = {
    text = L["DoReloadUI"],
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        _G.ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    notClosableByLogout = false
}
function RealUI:ReloadUIDialog()
    _G.StaticPopup_Show("PUDRUIRELOADUI")
end

function RealUI:OnInitialize()
    debug("OnInitialize starting...")

    -- Initialize Version Manager first
    if self.VersionManager then
        self.VersionManager:Initialize()
    end

    -- Initialize Profile System
    if self.ProfileSystem then
        self.ProfileSystem:Initialize()
    end

    -- Initialize Dual-Spec System
    if self.DualSpecSystem then
        self.DualSpecSystem:Initialize()
    end

    -- Initialize Configuration Persistence System
    if self.ConfigPersistence then
        self.ConfigPersistence:Initialize()
    end

    -- Initialize Layout Manager
    if self.LayoutManager then
        self.LayoutManager:Initialize()
    end

    -- Initialize AceDB-3.0 database with enhanced defaults from ProfileSystem
    local profileDefaults = self.ProfileSystem and self.ProfileSystem:GetDatabaseDefaults() or defaults
    self.db = _G.LibStub("AceDB-3.0"):New("nibRealUIDB", profileDefaults, private.layoutToProfile[1])

    -- Enhance database with LibDualSpec-1.0 support
    LDS:EnhanceDatabase(self.db, "RealUI")

    -- Create healing profile and set up dual-spec profiles
    self.db:SetProfile(private.layoutToProfile[2]) -- create healing profile
    for specIndex = 1, #RealUI.charInfo.specs do
        local spec = RealUI.charInfo.specs[specIndex]
        if spec.role == "HEALER" then
            self.db:SetDualSpecProfile(private.layoutToProfile[2], spec.index)
        end
    end

    -- Set back to default profile
    self.db:SetProfile(private.layoutToProfile[1])

    -- Initialize ProfileSystem with the database
    if self.ProfileSystem then
        self.ProfileSystem:Initialize(self.db)
    end

    -- Post-initialize DualSpecSystem with database
    if self.DualSpecSystem then
        self.DualSpecSystem:PostInitialize()
    end

    debug("Database initialized", self.db.keys, self.db.char.init.installStage)

    -- Set up database references
    db = self.db.profile
    dbc = self.db.char
    dbg = self.db.global
    self.media = db.media

    -- Character identification
    self.key = ("%s - %s"):format(self.charInfo.name, self.charInfo.realm)
    self.cLayout = dbc.layout.current
    self.ncLayout = self.cLayout == 1 and 2 or 1

    -- Post-initialize LayoutManager with database
    if self.LayoutManager then
        self.LayoutManager:LoadLayoutState()
        self.LayoutManager:ValidateCurrentLayout()
    end

    -- Handle legacy character data migration
    if _G.nibRealUICharacter then
        debug("Migrating legacy character data", self.db.keys.char, _G.nibRealUIDB.profileKeys[self.db.keys.char])
        if db.registeredChars[self.key] then
            dbc.init.installStage = _G.nibRealUICharacter.installStage
            dbc.init.initialized = _G.nibRealUICharacter.initialized
            dbc.init.needchatmoved = _G.nibRealUICharacter.needchatmoved
        end
        _G.nibRealUICharacter = nil
    end

    -- Enhanced version tracking and migration detection
    local currentVersion = RealUI.verinfo
    local savedVersion = dbg.verinfo

    if savedVersion and savedVersion.string and self.VersionManager then
        local versionChange = self.VersionManager:GetVersionType(savedVersion, currentVersion)
        if versionChange ~= "none" then
            debug("Version change detected:", savedVersion.string, "->", currentVersion.string, "Type:", versionChange)
            dbg.versionChange = versionChange

            -- Run any necessary migrations using ConfigPersistence
            if self.ConfigPersistence then
                local configVersion = dbg.configVersion or 0
                local success, err = self.ConfigPersistence:RunMigrations(tostring(configVersion), tostring(1))
                if not success then
                    debug("Configuration migration failed:", err)
                end
            end

            -- Run version-specific migrations
            local success, err = self.VersionManager:RunMigrations(savedVersion, currentVersion)
            if not success then
                debug("Version migration failed:", err)
            end
        end
    end

    -- Update saved version info
    dbg.verinfo = {
        [1] = currentVersion[1],
        [2] = currentVersion[2],
        [3] = currentVersion[3],
        string = currentVersion.string,
        build = currentVersion.build,
        gameVersion = currentVersion.gameVersion
    }

    -- Check library integration
    local libsOk, missingLibs = self:CheckLibraryIntegration()
    if not libsOk then
        debug("Missing libraries detected:", table.concat(missingLibs, ", "))
    end

    -- Register profile change callbacks
    debug("Registering profile callbacks")
    self.db.RegisterCallback(self, "OnNewProfile", "OnProfileUpdate")
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileUpdate")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileUpdate")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileUpdate")

    -- Register game events for specialization tracking (handled by DualSpecSystem)
    -- Events are now registered in DualSpecSystem:Initialize()

    -- Register font recheck system
    self:RegisterEvent(
        "ADDON_LOADED",
        function()
            if RealUI.recheckFonts then
                local SkinsDB = RealUI.GetOptions("Skins").profile
                local LSM = _G.LibStub("LibSharedMedia-3.0")
                for fontType in next, RealUI.recheckFonts do
                    local font = SkinsDB.fonts[fontType]
                    if type(font) == "table" then
                        for name, path in next, LSM.MediaTable.font do
                            if font.name == name then
                                RealUI.recheckFonts[fontType] = nil
                                SkinsDB.fonts[fontType] = {
                                    name = name,
                                    path = path
                                }
                                break
                            elseif font.name == "" and font.path == path then
                                RealUI.recheckFonts[fontType] = nil
                                SkinsDB.fonts[fontType] = {
                                    name = name,
                                    path = path
                                }
                                break
                            end
                        end
                    end
                end
            end
        end
    )

    -- Register chat commands
    self:RegisterChatCommand("real", "ChatCommand_Config")
    self:RegisterChatCommand("realui", "ChatCommand_Config")
    self:RegisterChatCommand(
        "realadv",
        function()
            RealUI.Debug("Config", "/realadv")
            RealUI.LoadConfig("RealUI")
        end
    )
    self:RegisterChatCommand(
        "rl",
        function()
            _G.C_UI.Reload()
        end
    )
    self:RegisterChatCommand("taintLogging", "Taint_Logging_Toggle")
    self:RegisterChatCommand(
        "findSpell",
        function(input)
            -- /findSpell "Spell Name" (player)|target (buff)|debuff
            local spellName, unit, auraType = self:GetArgs(input, 3)
            _G.assert(type(spellName) == "string", "A spell name must be provided")
            unit = unit or "player"
            if auraType == nil then
                -- Default this to false for player, true for target.
                auraType = unit == "target" and "debuff" or "buff"
            end
            self.FindSpellID(spellName, unit, auraType)
        end
    )
    self:RegisterChatCommand(
        "rc",
        function()
            _G.DoReadyCheck()
        end
    )

    -- LayoutManager test commands
    self:RegisterChatCommand(
        "layoutstatus",
        function()
            if self.LayoutManager then
                self.LayoutManager:PrintStatus()
            else
                print("LayoutManager not available")
            end
        end
    )
    self:RegisterChatCommand(
        "layoutswitch",
        function(input)
            if self.LayoutManager then
                local layoutId = tonumber(input)
                if layoutId then
                    local success = self.LayoutManager:SwitchToLayout(layoutId)
                    print("Layout switch to", layoutId, success and "succeeded" or "failed")
                else
                    print("Usage: /layoutswitch <1|2>")
                end
            else
                print("LayoutManager not available")
            end
        end
    )
    self:RegisterChatCommand(
        "layouttoggle",
        function()
            if self.LayoutManager then
                local success = self.LayoutManager:ToggleLayout()
                print("Layout toggle", success and "succeeded" or "failed")
            else
                print("LayoutManager not available")
            end
        end
    )

    -- Initialize chat frame positioning if needed
    if dbc.init.needchatmoved then
        _G.ChatFrame1:ClearAllPoints()
        _G.ChatFrame1:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 6, 32)
        _G.ChatFrame1:SetFrameLevel(15)
        _G.ChatFrame1:SetHeight(145)
        _G.ChatFrame1:SetWidth(400)
        _G.ChatFrame1:SetUserPlaced(true)
        _G.FCF_SavePositionAndDimensions(_G.ChatFrame1)
        dbc.init.needchatmoved = false
    end

    -- Configure user settings synchronization for first-time users
    if dbg.tags.firsttime then
        _G.SetCVar("synchronizeSettings", 1)
        _G.SetCVar("synchronizeConfig", 1)
        _G.SetCVar("synchronizeBindings", 1)
        _G.SetCVar("synchronizeMacros", 1)
    end

    -- Ensure quest text contrast is properly set
    if ((_G.GetCVarNumberOrDefault("questTextContrast")) ~= 4) then
        _G.SetCVar("questTextContrast", 4)
    end

    -- Mark framework as initialized
    RealUI.isInitialized = true

    -- Initialization complete message
    _G.print(("RealUI %s loaded."):format(RealUI:GetVerString(true)))
    if not dbg.tags.slashRealUITyped and dbc.init.installStage == -1 then
        _G.print(L["Slash_RealUI"]:format("|cFFFF8000/realui|r"))
    end

    -- Display account status information
    _G.print(("Limited mode is active: %s."):format(_G.tostring(_G.GameLimitedMode_IsActive())))

    debug("OnInitialize completed successfully")
end

local onLoadMessages = {
    --[[
    test = {
        text = "This is a test",
        func = function(...)
            _G.print("Test message clicked!!")
        end,
    }
    ]]
    reload = {
        text = "When changing the position of UI frames, please be sure to reload the UI with /rl"
    }
}
function RealUI:OnEnable()
    debug("OnEnable starting", dbc.init.installStage)

    -- Check if Installation/Patch is necessary
    self:InstallProcedure()

    if dbc.init.installStage == -1 then
        -- Apply low resolution optimizations if needed
        if self:IsUsingLowResDisplay() and not dbg.tags.lowResOptimized then
            self:SetLowResOptimizations()
        end

        -- Handle tutorial system
        if dbg.tutorial.stage > -1 then
            self:InitTutorial()
        else
            -- Display helpful messages for completed installations
            for name, messageInfo in next, onLoadMessages do
                if not dbg.messages[name] then
                    self:Notification(name, true, messageInfo.text, messageInfo.func, messageInfo.icon)
                    if name ~= "test" then
                        dbg.messages[name] = true
                    end
                end
            end

            -- Localization contribution message
            if not _G.LOCALE_enUS then
                _G.print(
                    "Want to contribute? You can help localize RealUI into your native language at bit.ly/RealUILocale"
                )
            end
        end
    end

    -- Performance debugging notifications
    if _G.GetCVar("taintLog") ~= "0" then
        _G.print(L["Slash_Taint"])
    end

    -- Initialize specialization tracking (handled by DualSpecSystem)
    if self.DualSpecSystem and self.DualSpecSystem:IsInitialized() then
        local currentSpec = self.DualSpecSystem:GetCurrentSpec()
        if currentSpec then
            debug("Current specialization:", currentSpec)
        end
    end

    -- Update frame styling
    self:UpdateFrameStyle()

    -- Mark framework as enabled
    RealUI.isEnabled = true

    debug("OnEnable completed successfully")
end

-- Enhanced Module Management System
do
    local prototype = {
        isRetail = RealUI.isRetail,
        isDragonflight = RealUI.isDragonflight,
        isMidnight = RealUI.isMidnight,
        debug = function(dialog, ...)
            return RealUI.Debug(dialog.moduleName, ...)
        end,
        OnProfileUpdate = function(dialog, ...)
            dialog:SetEnabledState(dialog.db.profile.modules[dialog.moduleName])
            if dialog.RefreshMod then
                dialog:RefreshMod(...)
            end
        end
    }
    RealUI:SetDefaultModulePrototype(prototype)
end

-- Module State Management
function RealUI:GetModuleEnabled(module)
    return self.db.profile.modules[module]
end

function RealUI:SetModuleEnabled(module, value)
    if self.db.profile.modules[module] ~= value then
        self.db.profile.modules[module] = value
        if value then
            self:EnableModule(module)
        else
            self:DisableModule(module)
        end
        return value
    end
end

-- Framework Status Functions
function RealUI:IsFrameworkReady()
    return self.isInitialized and self.isEnabled
end

function RealUI:GetFrameworkStatus()
    return {
        initialized = self.isInitialized,
        enabled = self.isEnabled,
        version = self.verinfo,
        layout = self.cLayout,
        installStage = dbc and dbc.init.installStage or 0
    }
end

-- Enhanced Library Integration Check
function RealUI:CheckLibraryIntegration()
    local libraries = {
        "AceAddon-3.0",
        "AceConsole-3.0",
        "AceEvent-3.0",
        "AceTimer-3.0",
        "LibDualSpec-1.0"
    }

    local missing = {}
    for _, lib in ipairs(libraries) do
        if not _G.LibStub:GetLibrary(lib, true) then
            table.insert(missing, lib)
        end
    end

    if #missing > 0 then
        debug("Missing libraries:", table.concat(missing, ", "))
        return false, missing
    end

    return true, {}
end

-- Namespace Management
function RealUI:RegisterNamespace(name, namespace)
    if not self.namespaces then
        self.namespaces = {}
    end
    self.namespaces[name] = namespace
    debug("Registered namespace:", name)
end

function RealUI:GetNamespace(name)
    return self.namespaces and self.namespaces[name]
end
