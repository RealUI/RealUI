local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type strsplit tonumber

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, dbc, dbg
local debug = RealUI.GetDebug("Core")

local LDS = _G.LibStub("LibDualSpec-1.0")

local version = _G.C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
RealUI.verinfo = {strsplit(".", version)}
for i = 1, 3 do
    RealUI.verinfo[i] = tonumber(RealUI.verinfo[i])
end
RealUI.verinfo.string = version

RealUI.configModeModules = {}
RealUI.defaultPositions = {
    [1] = {
        -- DPS/Tank
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
        -- Healing
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

private.profileToLayout = {
    ["RealUI"] = 1,
    ["RealUI-Healing"] = 2
}
private.layoutToProfile = {
    "RealUI",
    "RealUI-Healing"
}

-- Offset some UI Elements for Large/Small HuD size settings
RealUI.hudSizeOffsets = {
    [1] = {
        ["UFHorizontal"] = 0,
        ["SpellAlertWidth"] = 0,
        ["ActionBarsY"] = 0,
        ["CastBarPlayerY"] = 0,
        ["CastBarTargetY"] = 0
    },
    [2] = {
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
    dbc.layout.current = layout

    -- TODO: convert layouts to profiles
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

local function UpdateSpec(...)
    if _G.IsPlayerInitialSpec() then
        LDS.currentSpec = RealUI.charInfo.specs.current.index

        for addonDB, addonName in LDS:IterateDatabases() do
            addonDB:CheckDualSpecState()
        end

        return
    end

    local specInfo = RealUI.charInfo.specs
    local new = _G.C_SpecializationInfo.GetSpecialization()
    if specInfo.current.index ~= new then
        specInfo.current = RealUI.charInfo.specs[new]

        if dbc.layout.spec[specInfo.current.index] ~= dbc.layout.current then
            RealUI:UpdateLayout(dbc.layout.spec[specInfo.current.index])
        end
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
    self.db = _G.LibStub("AceDB-3.0"):New("nibRealUIDB", defaults, private.layoutToProfile[1])
    LDS:EnhanceDatabase(self.db, "RealUI")

    self.db:SetProfile(private.layoutToProfile[2]) -- create healing profile
    for specIndex = 1, #RealUI.charInfo.specs do
        local spec = RealUI.charInfo.specs[specIndex]
        if spec.role == "HEALER" then
            self.db:SetDualSpecProfile(private.layoutToProfile[2], spec.index)
        end
    end

    self.db:SetProfile(private.layoutToProfile[1]) -- set back to default

    debug("OnInitialize", self.db.keys, self.db.char.init.installStage)
    db = self.db.profile
    dbc = self.db.char
    dbg = self.db.global
    self.media = db.media

    -- Vars
    self.key = ("%s - %s"):format(self.charInfo.name, self.charInfo.realm)
    self.cLayout = dbc.layout.current
    self.ncLayout = self.cLayout == 1 and 2 or 1

    if _G.nibRealUICharacter then
        debug("Keys", self.db.keys.char, _G.nibRealUIDB.profileKeys[self.db.keys.char])
        if db.registeredChars[self.key] then
            dbc.init.installStage = _G.nibRealUICharacter.installStage
            dbc.init.initialized = _G.nibRealUICharacter.initialized
            dbc.init.needchatmoved = _G.nibRealUICharacter.needchatmoved
        end
        _G.nibRealUICharacter = nil
    end

    -- Open before login to stop taint
    --_G.ToggleFrame(_G.SpellBookFrame)

    -- Profile change
    debug("Char", dbc.init.installStage)
    self.db.RegisterCallback(self, "OnNewProfile", "OnProfileUpdate")
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileUpdate")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileUpdate")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileUpdate")

    -- Register events
    self:RegisterEvent("UNIT_LEVEL", UpdateSpec)
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", UpdateSpec)
    self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateSpec)
    self:RegisterEvent("TRAIT_CONFIG_UPDATED", UpdateSpec)

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

    -- Chat Commands
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

    -- Position Chat Frame
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

    -- Synch user's settings
    if dbg.tags.firsttime then
        _G.SetCVar("synchronizeSettings", 1)
        _G.SetCVar("synchronizeConfig", 1)
        _G.SetCVar("synchronizeBindings", 1)
        _G.SetCVar("synchronizeMacros", 1)
    end
    if ((_G.GetCVarNumberOrDefault("questTextContrast")) ~= 4) then
        _G.SetCVar("questTextContrast", 4)
    end
    -- Done
    _G.print(("RealUI %s loaded."):format(RealUI:GetVerString(true)))
    if not dbg.tags.slashRealUITyped and dbc.init.installStage == -1 then
        _G.print(L["Slash_RealUI"]:format("|cFFFF8000/realui|r"))
    end
    -- Check AccountStatus
    _G.print(("Limited mode is active: %s."):format(_G.tostring(_G.GameLimitedMode_IsActive())))
    -- Check AddOnProfiler status
    _G.print(("AddOnProfiler is active: %s."):format(_G.tostring(_G.C_AddOnProfiler.IsEnabled())))
    if _G.C_AddOnProfiler.IsEnabled() then
        _G.print("Addon Profiler is active. Patch 11.1.5 removed the ability to disable the profiler. It is now permanently enabled..")
        -- if not RealUI.isDev then
        --     _G.print("Deactivating AddOnProfiler...")
        --     _G.C_CVar.RegisterCVar("addonProfilerEnabled", "1")
        --     _G.C_CVar.SetCVar("addonProfilerEnabled", "0")
        -- else
        --     _G.print("Deactivating AddOnProfiler...")
        --     _G.C_CVar.RegisterCVar("addonProfilerEnabled", "1")
        --     _G.C_CVar.SetCVar("addonProfilerEnabled", "0")
        --     _G.print("RealUI Developer - to turn on use /dev addonprofiler")
        -- end
    else
        if RealUI.isDev then
            _G.print("RealUI Developer - to turn on use /dev addonprofiler")
        end
    end
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
    debug("OnEnable", dbc.init.installStage)

    -- Check if Installation/Patch is necessary
    self:InstallProcedure()

    if dbc.init.installStage == -1 then
        if self:IsUsingLowResDisplay() and not dbg.tags.lowResOptimized then
            self:SetLowResOptimizations()
        end

        if dbg.tutorial.stage > -1 then
            self:InitTutorial()
        else
            -- Helpful messages
            for name, messageInfo in next, onLoadMessages do
                if not dbg.messages[name] then
                    self:Notification(name, true, messageInfo.text, messageInfo.func, messageInfo.icon)
                    if name ~= "test" then
                        dbg.messages[name] = true
                    end
                end
            end
            if not _G.LOCALE_enUS then
                _G.print(
                    "Want to contribute? You can help localize RealUI into your native language at bit.ly/RealUILocale"
                )
            end
        end
    end

    -- WoW Debugging settings - notify if enabled as they have a performance impact and user may have left them on
    if _G.GetCVar("taintLog") ~= "0" then
        _G.print(L["Slash_Taint"])
    end

    UpdateSpec()

    -- Update styling
    self:UpdateFrameStyle()
end

do
    local prototype = {
        isPatch = RealUI.isPatch,
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
