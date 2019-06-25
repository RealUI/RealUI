local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type strsplit tonumber

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, dbc, dbg
local debug = RealUI.GetDebug("Core")

local version = _G.GetAddOnMetadata(ADDON_NAME, "Version")
RealUI.verinfo = {strsplit(".", version)}
for i = 1, 3 do
    RealUI.verinfo[i] = tonumber(RealUI.verinfo[i])
end
RealUI.verinfo.string = version

RealUI.oocFunctions = {}
RealUI.configModeModules = {}

RealUI.defaultPositions = {
    [1] = {     -- DPS/Tank
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
        ["BossX"] = -32,        -- Boss anchored to RIGHT
        ["BossY"] = 314,
    },
    [2] = {     -- Healing
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
        ["BossX"] = -32,        -- Boss anchored to RIGHT
        ["BossY"] = 314,
    },
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
        ["CastBarTargetY"] = 0,
    },
    [2] = {
        ["UFHorizontal"] = 100,
        ["SpellAlertWidth"] = 100,
        ["ActionBarsY"] = -20,
        ["CastBarPlayerY"] = -20,
        ["CastBarTargetY"] = -20,
    },
}

-- Default Options
local defaults, charInit do
    charInit = {
        installStage = 0,
        initialized = false,
        needchatmoved = true,
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
                stage = -1,
            },
            tags = {
                firsttime = true,
                lowResOptimized = false,
                slashRealUITyped = false,   -- To disable "Type /realui" message
            },
            messages = {
            },
            verinfo = {},
            patchedTOC = 0,
            currency = {},
        },
        char = {
            init = charInit,
            layout = {
                current = 1,    -- 1 = DPS/Tank, 2 = Healing
                needchanged = false,
                spec = spec -- Save layout for each spec
            },
        },
        profile = {
            modules = {
                ['*'] = true,
                ["AchievementScreenshots"] = false,
            },
            registeredChars = {},
            -- HuD positions
            positionsLink = true,
            positions = RealUI.defaultPositions,
            -- Action Bar settings
            abSettingsLink = false,
            -- Dynamic UI settings
            settings = {
                powerMode = 1,  -- 1 = Normal, 2 = Economy, 3 = Turbo
                fontStyle = 2,
                hudSize = 2,
                reverseUnitFrameBars = false,
            },
            media = RealUI.media
        },
    }
end

--------------------------------------------------------

-- Toggle Grid2's "Test Layout"
function RealUI:ToggleGridTestMode(show)
    if not _G.Grid2 then return end
    if show then
        if _G.RealUIGridConfiguring then return end
        if not _G.Grid2Options then _G.Grid2:LoadGrid2Options() end
        _G.RealUIGridConfiguring = _G.Grid2Options.LayoutTestEnable(_G.Grid2Options, "By Group", nil, nil, 20)
    else
        if _G.Grid2Options then
            _G.RealUIGridConfiguring = _G.Grid2Options.LayoutTestEnable(_G.Grid2Options)
        end
    end
    return _G.RealUIGridConfiguring
end

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
    local _, resHeight = _G.GetPhysicalScreenSize()
    return resHeight < 900
end

function RealUI:IsUsingHighResDisplay()
    local _, resHeight = _G.GetPhysicalScreenSize()
    return resHeight >= 1440
end

-- Power Mode
function RealUI:SetPowerMode(val)
    -- TODO: remove cruft
    -- Core\SpiralBorder, HuD\UnitFrames, Modules\PlayerShields, Modules\RaidDebuffs, Modules\Pitch
    db.settings.powerMode = val
    for k, mod in self:IterateModules() do
        if self:GetModuleEnabled(k) and mod.SetUpdateSpeed and type(mod.SetUpdateSpeed) == "function" then
            mod:SetUpdateSpeed()
        end
    end
end

-- Style - Global Colors
function RealUI:StyleUpdateColors()
    for k, mod in self:IterateModules() do
        if self:GetModuleEnabled(k) and mod.UpdateGlobalColors and type(mod.UpdateGlobalColors) == "function" then
            mod:UpdateGlobalColors()
        end
    end
end

-- Layout Updates
function RealUI:SetLayout()
    -- TODO: convert layouts to profiles
    -- Set Current and Not-Current layout variables
    self.cLayout = dbc.layout.current
    self.ncLayout = self.cLayout == 1 and 2 or 1

    if _G.RealUIGridConfiguring then
        self:ScheduleTimer(function()
            self:ToggleGridTestMode(false)
            self:ToggleGridTestMode(true)
        end, 0.5)
    end

    dbc.layout.needchanged = false
end
function RealUI:UpdateLayout()
    if _G.InCombatLockdown() then
        -- Register to update once combat ends
        if not self.oocFunctions["SetLayout"] then
            self:RegisterLockdownUpdate("SetLayout", function() RealUI:SetLayout() end)
            dbc.layout.needchanged = true
        end
        self:Notification("RealUI", true, L["Layout_ApplyOOC"])
    else
        -- Set layout in 0.5 seconds
        self.oocFunctions["SetLayout"] = nil
        self:ScheduleTimer("SetLayout", 0.5)
    end
end

-- Lockdown check, out-of-combat updates
function RealUI:LockdownUpdates()
    if not _G.InCombatLockdown() then
        local stillProcessing
        for k, fun in next, self.oocFunctions do
            self.oocFunctions[k] = nil
            if type(fun) == "function" then
                fun()
                stillProcessing = true
                break
            end
        end
        if not stillProcessing then
            self:CancelTimer(self.lockdownTimer)
            self.lockdownTimer = nil
        end
    end
end
function RealUI:UpdateLockdown(...)
    if not self.lockdownTimer then self.lockdownTimer = self:ScheduleRepeatingTimer("LockdownUpdates", 0.5) end
end
function RealUI:RegisterLockdownUpdate(id, fun, ...)
    if not _G.InCombatLockdown() then
        self.oocFunctions[id] = nil
        fun(...)
    else
        self.oocFunctions[id] = function(...) fun(...) end
    end
end

local THIRTY_DAYS = 60 * 60 * 24 * 30
function RealUI:InitCurrencyDB()
    if not RealUI.charInfo.realmNormalized then
        local DB = RealUI.db.global.currency

        local charInfo = RealUI.charInfo
        charInfo.realmNormalized = _G.GetNormalizedRealmName()

        local realm   = charInfo.realmNormalized
        local faction = charInfo.faction
        local player  = charInfo.name

        if not DB[realm] then
            DB[realm] = {}
        end

        if faction then
            if not DB[realm][faction] then
                DB[realm][faction] = {}
            end
            if not DB[realm][faction][player] then
                DB[realm][faction][player] = {}
            end

            local now = _G.time()
            local realmDB = DB[realm][faction]
            local cutoff = now - THIRTY_DAYS
            for name, data in next, realmDB do
                if data.lastSeen and data.lastSeen < cutoff then
                    realmDB[name] = nil
                end
            end

            if not realmDB[player] then
                realmDB[player] = {}
            end
            local charDB = realmDB[player]
            charDB.class = charInfo.class.token
            charDB.lastSeen = now
        end
    end
end

local function UpdateSpec()
    local old = RealUI.charInfo.specs.current.index
    local new = _G.GetSpecialization()
    if old ~= new then
        RealUI.charInfo.specs.current = RealUI.charInfo.specs[new]
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
    RealUI:ScheduleRepeatingTimer(function()
        _G.RaidNotice_AddMessage(_G.RaidWarningFrame, _G.CHAT_MSG_RAID_WARNING, { r = 0, g = 1, b = 0 })
        _G.RaidNotice_AddMessage(_G.RaidBossEmoteFrame, _G.CHAT_MSG_RAID_BOSS_EMOTE, { r = 0, g = 1, b = 0 })
    end, 5)
end

function RealUI:CPU_Profiling_Toggle()
    _G.SetCVar("scriptProfile", (_G.GetCVar("scriptProfile") == "1") and "0" or "1")
    _G.ReloadUI()
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
        return RealUI:Notification(L["Alert_CombatLockdown"], true, L["Alert_CantOpenInCombat"], nil, [[Interface\AddOns\nibRealUI\Media\Notification_Alert]])
    end
    debug("is loaded", configLoaded)
    if not configLoaded then
        local reason
        configLoaded, reason = _G.LoadAddOn("nibRealUI_Config")
        debug("LoadAddOn", configLoaded, reason)
        if not configLoaded then
            _G.error(_G.ADDON_LOAD_FAILED:format("nibRealUI_Config", _G["ADDON_"..reason]))
        end
    end
    debug("ToggleConfig", RealUI.ToggleConfig)
    RealUI.ToggleConfig(app, section, ...)
end

function RealUI:OnProfileUpdate(event, database, profile)
    db = database.profile
    dbc = database.char
    dbg = database.global

    RealUI:LoadAddonProfiles()

    for name, module in self:IterateModules() do
       module:OnProfileUpdate(event, profile)
    end

    -- Update old stuff too for now
    dbc.layout.current = private.profileToLayout[profile]
    RealUI:SetLayout()

    if event == "OnProfileReset" then
        debug("OnProfileReset", RealUI.db.char.init, RealUI.db.char.init.installStage)
        RealUI.db.char.init = charInit
        debug("Char", RealUI.db.char.init, RealUI.db.char.init.installStage)
        RealUI:ReloadUIDialog()
    end
end

function RealUI:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("nibRealUIDB", defaults, private.layoutToProfile[1])
    _G.LibStub("LibDualSpec-1.0"):EnhanceDatabase(self.db, "RealUI")

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
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", UpdateSpec)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "LockdownUpdates")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLockdown")
    self:RegisterEvent("ADDON_LOADED", function()
        if RealUI.recheckFonts then
            local SkinsDB = RealUI:GetAddOnDB("RealUI_Skins").profile
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
    end)

    -- Chat Commands
    self:RegisterChatCommand("real", "ChatCommand_Config")
    self:RegisterChatCommand("realui", "ChatCommand_Config")
    self:RegisterChatCommand("realadv", function()
        RealUI.Debug("Config", "/realadv")
        RealUI.LoadConfig("RealUI")
    end)
    self:RegisterChatCommand("memory", "MemoryDisplay")
    self:RegisterChatCommand("rl", _G.ReloadUI)
    self:RegisterChatCommand("cpuProfiling", "CPU_Profiling_Toggle")
    self:RegisterChatCommand("taintLogging", "Taint_Logging_Toggle")
    self:RegisterChatCommand("findSpell", function(input)
        -- /findSpell "Spell Name" (player)|target (buff)|debuff
        local spellName, unit, auraType = self:GetArgs(input, 3)
        _G.assert(type(spellName) == "string", "A spell name must be provided")
        unit = unit or "player"
        if auraType == nil then
            -- Default this to false for player, true for target.
            auraType = unit == "target" and "debuff" or "buff"
        end
        self:FindSpellID(spellName, unit, auraType)
    end)

    -- Hide store button
    _G.GameMenuButtonStore:SetScale(0.00001)
    _G.GameMenuButtonStore:SetAlpha(0)

    -- Add RealUI Config button
    local configBtn = _G.CreateFrame("Button", nil, _G.GameMenuFrame, "GameMenuButtonTemplate")
    configBtn:SetText(("|cffffffffReal|r|c%sUI|r Config"):format(_G.Aurora.Color.highlight.colorStr))
    _G.Aurora.Skin.UIPanelButtonTemplate(configBtn)
    configBtn:SetPoint("TOP", _G.GameMenuButtonUIOptions, "BOTTOM", 0, -1)
    configBtn:SetScript("OnMouseUp", function()
        RealUI.Debug("Config", "GameMenuFrame")
        RealUI.LoadConfig("HuD")
        _G.HideUIPanel(_G.GameMenuFrame)
    end)

    _G.GameMenuButtonKeybindings:SetPoint("TOP", configBtn, "BOTTOM", 0, -1)
    _G.hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", function(menuFrame)
        debug("GameMenuFrame_UpdateVisibleButtons")
        local height = 332

        if not _G.SplashFrameCanBeShown() then
            height = height - 20
        end

        menuFrame:SetHeight(height)
    end)

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

    _G.SetCVar("useCompactPartyFrames", 1)

    -- Done
     _G.print(("RealUI %s loaded."):format(RealUI:GetVerString(true)))
    if not dbg.tags.slashRealUITyped and dbc.init.installStage == -1 then
         _G.print(L["Slash_RealUI"]:format("|cFFFF8000/realui|r"))
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
}
function RealUI:OnEnable()
    debug("OnEnable", dbc.init.installStage)
    RealUI:InitCurrencyDB()

    -- Check if Installation/Patch is necessary
    self:InstallProcedure()

    -- Do we need a Layout change?
    if dbc.layout.needchanged then
        RealUI:UpdateLayout()
    end


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
                 _G.print("Help localize RealUI to your language. Go to http://goo.gl/SHZewK")
            end
        end
    end

    -- WoW Debugging settings - notify if enabled as they have a performance impact and user may have left them on
    if _G.GetCVar("scriptProfile") == "1" then
         _G.print(L["Slash_Profile"])
    end
    if _G.GetCVar("taintLog") ~= "0" then
         _G.print(L["Slash_Taint"])
    end

    UpdateSpec()

    -- Update styling
    self:UpdateFrameStyle()
end


function RealUI:RegisterConfigModeModule(module)
    if module and module.ToggleConfigMode and type(module.ToggleConfigMode) == "function" then
        _G.tinsert(self.configModeModules, module)
    end
end
local addonSkins = {}
function RealUI:RegisterAddOnSkin(name)
    local skin = self:NewModule(name, "AceEvent-3.0")
    skin:SetEnabledState(self:GetModuleEnabled(name))
    _G.tinsert(addonSkins, name)
    return skin
end
function RealUI:GetAddOnSkins()
    return addonSkins
end

do
    local prototype = {
        debug = function(self, ...)
            return RealUI.Debug(self.moduleName, ...)
        end,
        OnProfileUpdate = function(self, ...)
            self:SetEnabledState(RealUI.db.profile.modules[self.moduleName])
            if self.RefreshMod then
                self:RefreshMod(...)
            end
        end,
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

