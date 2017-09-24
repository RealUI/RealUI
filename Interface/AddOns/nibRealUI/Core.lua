local ADDON_NAME, private = ...

-- Lua Globals --
local next, type = _G.next, _G.type

-- Libs --
local C = _G.Aurora[2]

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, dbc, dbg
local debug = RealUI.GetDebug("Core")

RealUI.verinfo = {}
for word, letter in _G.GetAddOnMetadata(ADDON_NAME, "Version"):gmatch("(%d+)(%a*)") do
    debug(word, letter)
    if _G.tonumber(word) then
        _G.tinsert(RealUI.verinfo, _G.tonumber(word))
    end
    if letter ~= "" then
        _G.tinsert(RealUI.verinfo, letter)
    end
end

if not _G.REALUI_STRIPE_TEXTURES then _G.REALUI_STRIPE_TEXTURES = {} end
if not _G.REALUI_WINDOW_FRAMES then _G.REALUI_WINDOW_FRAMES = {} end

RealUI.oocFunctions = {}
RealUI.configModeModules = {}

-- Localized Fonts
do
    local LSM = _G.LibStub("LibSharedMedia-3.0")
    local lsmFonts = LSM:List("font")
    local function findFont(font, backup)
        local fontPath, fontSize, fontArgs = font:GetFont()
        if not fontPath then
            fontPath, fontSize, fontArgs = backup:GetFont()
            font:SetFont(fontPath, fontSize, fontArgs)
        end
        local fontName, path
        for i = 1, #lsmFonts do
            fontName = lsmFonts[i]
            path = LSM:Fetch("font", fontName)
            if path == fontPath then
                local tab = {
                    fontName,
                    fontSize,
                    fontArgs,
                    fontPath,
                }
                return tab
            end
        end
    end
    local fonts = {
        standard = findFont(_G.RealUIFont_Normal, _G.SystemFont_Small),
        chat = findFont(_G.RealUIFont_Chat, _G.NumberFont_Normal_Med),
        crit = findFont(_G.RealUIFont_Crit, _G.NumberFont_Outline_Huge),
        header = findFont(_G.RealUIFont_Header, _G.QuestFont_Huge),
        pixel = {
            small =    findFont(_G.RealUIFont_PixelSmall, _G.SystemFont_Small),
            large =    findFont(_G.RealUIFont_PixelLarge, _G.SystemFont_Med1),
            numbers =  findFont(_G.RealUIFont_PixelNumbers, _G.SystemFont_Large),
            cooldown = findFont(_G.RealUIFont_PixelCooldown, _G.SystemFont_Large),
        }
    }
    RealUI.media.font = fonts
end

RealUI.defaultPositions = {
    [1] = {     -- DPS/Tank
        ["HuDX"] = 0,
        ["HuDY"] = -38,
        ["UFHorizontal"] = 200,
        ["ActionBarsY"] = -161.5,
        ["ActionBarsBotY"] = 16,
        ["GridTopX"] = 0,
        ["GridTopY"] = -197.5,
        ["GridBottomX"] = 0,
        ["GridBottomY"] = 58,
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
        ["GridTopX"] = 0,
        ["GridTopY"] = -197.5,
        ["GridBottomX"] = 0,
        ["GridBottomY"] = 58,
        ["CastBarPlayerX"] = 0,
        ["CastBarPlayerY"] = -20,
        ["CastBarTargetX"] = 0,
        ["CastBarTargetY"] = -20,
        ["SpellAlertWidth"] = 150,
        ["BossX"] = -32,        -- Boss anchored to RIGHT
        ["BossY"] = 314,
    },
}

-- Offset some UI Elements for Large/Small HuD size settings
RealUI.hudSizeOffsets = {
    [1] = {
        ["UFHorizontal"] = 0,
        ["SpellAlertWidth"] = 0,
        ["ActionBarsY"] = 0,
        ["GridTopY"] = 0,
        ["CastBarPlayerY"] = 0,
        ["CastBarTargetY"] = 0,
    },
    [2] = {
        ["UFHorizontal"] = 100,
        ["SpellAlertWidth"] = 100,
        ["ActionBarsY"] = -20,
        ["GridTopY"] = -20,
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
    for specIndex = 1, RealUI.numSpecs do
        local _, _, _, _, role = _G.GetSpecializationInfoForClassID(RealUI.classID, specIndex)
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
                retinaDisplay = {
                    checked = false,
                    set = false,
                },
                lowResOptimized = false,
                slashRealUITyped = false,   -- To disable "Type /realui" message
            },
            messages = {
                resetNew = false,
                largeHuDOption = false,
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
                stripeOpacity = 0.5,
                hudSize = 1,
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

    RealUI:UpdateLayout()

    dbg.tags.lowResOptimized = true
end

function RealUI:LowResOptimizationCheck(...)
    local _, resHeight = RealUI:GetResolutionVals()
    if (resHeight < 900) and not(dbg.tags.lowResOptimized) then
        RealUI:SetLowResOptimizations(...)
    end
end

-- Check if user is using a Retina Display
function RealUI:RetinaDisplayCheck()
    local resWidth, resHeight = RealUI:GetResolutionVals()
    if (resWidth > 2560) and (resHeight > 1600) then
        return true
    else
        dbg.tags.retinaDisplay.checked = true
        dbg.tags.retinaDisplay.set = false
        return false
    end
end

-- Power Mode
function RealUI:SetPowerMode(val)
    -- Core\SpiralBorder, HuD\UnitFrames, Modules\PlayerShields, Modules\RaidDebuffs, Modules\Pitch
    db.settings.powerMode = val
    for k, mod in self:IterateModules() do
        if self:GetModuleEnabled(k) and mod.SetUpdateSpeed and type(mod.SetUpdateSpeed) == "function" then
            mod:SetUpdateSpeed()
        end
    end
end

---- Style Updates ----
function RealUI:StyleSetWindowOpacity()
    if RealUI.isAuroraUpdated then
        local r, g, b = _G.Aurora.frameColor:GetRGB()
        for i = 1, #C.frames do
            C.frames[i]:SetBackdropColor(r, g, b, _G.AuroraConfig.alpha)
        end
    else
        local color = RealUI.media.window
        for k, frame in next, _G.REALUI_WINDOW_FRAMES do
            if frame.SetBackdropColor then
                frame:SetBackdropColor(color[1], color[2], color[3], color[4])
            end
        end
    end
end

function RealUI:StyleSetStripeOpacity()
    for k, tex in next, _G.REALUI_STRIPE_TEXTURES do
        if tex.SetAlpha then
            tex:SetAlpha(_G.RealUI_InitDB.stripeOpacity)
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
    -- Set Current and Not-Current layout variables
    self.cLayout = dbc.layout.current
    self.ncLayout = self.cLayout == 1 and 2 or 1

    -- Set AddOn profiles
    self:SetProfileLayout()

    -- Set Positioners
    self:UpdatePositioners()


    if _G.RealUIGridConfiguring then
        self:ScheduleTimer(function()
            self:ToggleGridTestMode(false)
            self:ToggleGridTestMode(true)
        end, 0.5)
    end

    -- ActionBars
    if self:GetModuleEnabled("ActionBars") then
        local AB = self:GetModule("ActionBars", true)
        AB:RefreshDoodads()
        AB:ApplyABSettings()
    end

    -- Grid Layout changer
    if self:GetModuleEnabled("GridLayout") then
        local GL = self:GetModule("GridLayout", true)
        if GL then GL:SettingsUpdate("RealUI:SetLayout") end
    end

    -- FrameMover
    if self:GetModuleEnabled("FrameMover") then
        local FM = self:GetModule("FrameMover", true)
        if FM then FM:MoveAddons() end
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
    if not RealUI.realmNormalized then
        local DB = RealUI.db.global.currency

        RealUI.realmNormalized = _G.GetNormalizedRealmName()
        local realm   = RealUI.realmNormalized
        local faction = RealUI.faction
        local player  = RealUI.charName

        if not DB[realm] then
            DB[realm] = {}
        end

        for k, v in next, DB[realm] do
            if k ~= "Alliance" and k ~= "Horde" then
                DB[realm][k] = nil
            end
        end

        if faction and faction ~= "Neutral" then
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

            local charDB = realmDB[player]
            charDB.class = RealUI.class
            charDB.lastSeen = now
        else
            DB[realm][faction] = nil
        end
    end
end

-- Version info retrieval
function RealUI:GetVerString(returnLong)
    local verinfo = RealUI.verinfo
    if returnLong then
        return ("|cFFFF6014%d|r.|cFF269BFF%d|r |cFF21E521r%d%s|r"):format(verinfo[1], verinfo[2], verinfo[3], verinfo[4] or "")
    else
        return ("%s.%s"):format(verinfo[1], verinfo[2])
    end
end
function RealUI:MajorVerChange(oldVer, curVer)
    return ((curVer[1] > oldVer[1]) and "major") or ((curVer[2] > oldVer[2]) and "minor")
end

-- Events
function RealUI:VARIABLES_LOADED()
    ---- Blizzard Bug Fixes
    -- No Map emote
    _G.hooksecurefunc("DoEmote", function(emote)
        if emote == "READ" and _G.WorldMapFrame:IsShown() then
            _G.CancelEmote()
        end
    end)
end

-- Delayed updates
function RealUI:UPDATE_PENDING_MAIL()
    self:UnregisterEvent("UPDATE_PENDING_MAIL")

    _G.CancelEmote()   -- Cancel Map Holding animation

    -- Refresh WatchFrame lines and positioning
    if _G.ObjectiveTrackerFrame and _G.ObjectiveTrackerFrame.collapsed then
        _G.ObjectiveTracker_Collapse()
        _G.ObjectiveTracker_Expand()
    end
end

function RealUI:PLAYER_ENTERING_WORLD()
    self:LockdownUpdates()

    -- Hide store button
    _G.GameMenuButtonStore:SetScale(0.00001)
    _G.GameMenuButtonStore:SetAlpha(0)

    -- RealUI Config
    local configBtn
    if RealUI.isAuroraUpdated then
        configBtn = _G.CreateFrame("Button", nil, _G.GameMenuFrame, "GameMenuButtonTemplate")
        configBtn:SetText(("|cffffffffReal|r|c%sUI|r Config"):format(_G.Aurora.highlightColor.colorStr))
        _G.Aurora.Skin.UIPanelButtonTemplate(configBtn)
    else
        local configStr = ("|cffffffffReal|r|cff%sUI|r Config"):format(RealUI:ColorTableToStr(RealUI.media.colors.red))
        configBtn = RealUI:CreateTextButton(configStr, _G.GameMenuFrame, "GameMenuButtonTemplate")
    end
    configBtn:SetPoint("TOP", _G.GameMenuButtonUIOptions, "BOTTOM", 0, -1)
    configBtn:SetScript("OnMouseUp", function()
        RealUI.Debug("Config", "GameMenuFrame")
        RealUI:LoadConfig("HuD")
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
end

function RealUI:PLAYER_LOGIN()
    debug("PLAYER_LOGIN", dbc.init.installStage)
    -- Retina Display check
    if not(dbg.tags.retinaDisplay.checked) and self:RetinaDisplayCheck() then
        self:InitRetinaDisplayOptions()
        return
    end

    RealUI:InitCurrencyDB()

    -- Low Res optimization check
    if (dbc.init.installStage == -1) then
        self:LowResOptimizationCheck()
    end

    -- Tutorial
    if (dbc.init.installStage == -1) then
        if (dbg.tutorial.stage == 0) then
            self:InitTutorial()
        end
    end

    -- Check if Installation/Patch is necessary
    self:InstallProcedure()

    -- Do we need a Layout change?
    if dbc.layout.needchanged then
        RealUI:UpdateLayout()
    end

    -- Helpful messages
    local blue = RealUI:ColorTableToStr(RealUI.media.colors.blue)
    local red = RealUI:ColorTableToStr(RealUI.media.colors.red)

    if (dbc.init.installStage == -1) and (dbg.tutorial.stage == -1) then
        if not(dbg.messages.resetNew) then
            -- This part should be in the bag addon
            if _G.IsAddOnLoaded("cargBags_Nivaya") then
                _G.hooksecurefunc(_G.Nivaya, "OnShow", function()
                    if RealUI.db.global.messages.resetNew then return end
                    RealUI:Notification("Inventory", true, "Categorize New Items with the Reset New button.", nil, [[Interface\AddOns\cargBags_Nivaya\media\ResetNew_Large]], 0, 1, 0, 1)
                    RealUI.db.global.messages.resetNew = true
                end)
            end
        end
        if not _G.LOCALE_enUS then
             _G.print("Help localize RealUI to your language. Go to http://goo.gl/SHZewK")
        end
    end

    -- WoW Debugging settings - notify if enabled as they have a performance impact and user may have left them on
    if _G.GetCVar("scriptProfile") == "1" then
         _G.print(L["Slash_Profile"]:format(red, blue))
    end
    if _G.GetCVar("taintLog") ~= "0" then
         _G.print(L["Slash_Taint"]:format(red, blue))
    end

    -- Update styling
    self:StyleSetStripeOpacity()
    self:StyleSetWindowOpacity()
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

function RealUI:ADDON_LOADED(event, addon)
    if addon ~= ADDON_NAME then return end

    -- Open before login to stop taint
    _G.ToggleFrame(_G.SpellBookFrame)
end

function RealUI:ChatCommand_Config()
    RealUI.Debug("Config", "/real")
    dbg.tags.slashRealUITyped = true
    RealUI:LoadConfig("HuD")
end

local configLoaded = false
function RealUI:LoadConfig(app, section, ...)
    if _G.InCombatLockdown() then
        return RealUI:Notification(L["Alert_CombatLockdown"], true, L["Alert_CantOpenInCombat"], nil, [[Interface\AddOns\nibRealUI\Media\Icons\Notification_Alert]])
    end
    if not configLoaded then
        local reason
        configLoaded, reason = _G.LoadAddOn("nibRealUI_Config")
        if not configLoaded then
            _G.error(_G.ADDON_LOAD_FAILED:format("nibRealUI_Config", _G["ADDON_"..reason]))
        end
    end
    self:ToggleConfig(app, section, ...)
end

function RealUI:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("nibRealUIDB", defaults, "RealUI")
    debug("OnInitialize", self.db.keys, self.db.char.init.installStage)
    db = self.db.profile
    dbc = self.db.char
    dbg = self.db.global
    self.media = db.media

    -- Vars
    self.classColor = RealUI:GetClassColor(self.class)
    self.key = ("%s - %s"):format(self.charName, self.realm)
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

    -- Profile change
    debug("Char", dbc.init.installStage)
    self.db.RegisterCallback(self, "OnProfileChanged", "ReloadUIDialog")
    self.db.RegisterCallback(self, "OnProfileCopied", "ReloadUIDialog")
    self.db.RegisterCallback(self, "OnProfileReset", function()
        debug("OnProfileReset", RealUI.db.char.init, RealUI.db.char.init.installStage)
        RealUI.db.char.init = charInit
        debug("Char", RealUI.db.char.init, RealUI.db.char.init.installStage)
        RealUI:ReloadUIDialog()
    end)

    -- Register events
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLockdown")
    self:RegisterEvent("VARIABLES_LOADED")
    self:RegisterEvent("UPDATE_PENDING_MAIL")

    -- Chat Commands
    self:RegisterChatCommand("real", "ChatCommand_Config")
    self:RegisterChatCommand("realui", "ChatCommand_Config")
    self:RegisterChatCommand("realadv", function()
        RealUI.Debug("Config", "/realadv")
        RealUI:LoadConfig("RealUI")
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

    -- Synch user's settings
    if dbg.tags.firsttime then
        _G.SetCVar("synchronizeSettings", 1)
        _G.SetCVar("synchronizeConfig", 1)
        _G.SetCVar("synchronizeBindings", 1)
        _G.SetCVar("synchronizeMacros", 1)
    end

    if db.settings.stripeOpacity then
        _G.RealUI_InitDB.stripeOpacity = db.settings.stripeOpacity
        db.settings.stripeOpacity = nil
    end

    _G.SetCVar("useCompactPartyFrames", 1)

    -- Remove Interface Options cancel button because it = taint
    --InterfaceOptionsFrameCancel:Hide()
    --InterfaceOptionsFrameOkay:SetAllPoints(InterfaceOptionsFrameCancel)

    -- Make clicking cancel the same as clicking okay
    --InterfaceOptionsFrameCancel:SetScript("OnClick", function()
    --  InterfaceOptionsFrameOkay:Click()
    --end)

    -- Done
     _G.print(("RealUI %s loaded."):format(RealUI:GetVerString(true)))
    if not dbg.tags.slashRealUITyped and dbc.init.installStage == -1 then
         _G.print(L["Slash_RealUI"]:format("|cFFFF8000/realui|r"))
    end
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
    }
    RealUI:SetDefaultModulePrototype(prototype)
end

function RealUI:GetModuleEnabled(module)
    return db.modules[module]
end

function RealUI:SetModuleEnabled(module, value)
    local old = db.modules[module]
    db.modules[module] = value
    if old ~= value then
        if value then
            self:EnableModule(module)
        else
            self:DisableModule(module)
        end
        return value
    end
end

