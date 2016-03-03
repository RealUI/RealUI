local nibRealUI = LibStub("AceAddon-3.0"):NewAddon(RealUI, "nibRealUI", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = nibRealUI.L
local db, dbc, dbg, _
local function debug(...)
    nibRealUI.Debug("Core", ...)
end

_G.RealUI = nibRealUI
nibRealUI.TOC = select(4, GetBuildInfo())
nibRealUI.isBeta = nibRealUI.TOC >= 70000

nibRealUI.verinfo = {}
for word, letter in string.gmatch(GetAddOnMetadata("nibRealUI", "Version"), "(%d+)(%a*)") do
    debug(word, letter)
    if tonumber(word) then
        tinsert(nibRealUI.verinfo, tonumber(word))
    end
    if letter ~= "" then
        tinsert(nibRealUI.verinfo, letter)
    end
end

if not REALUI_STRIPE_TEXTURES then REALUI_STRIPE_TEXTURES = {} end
if not REALUI_WINDOW_FRAMES then REALUI_WINDOW_FRAMES = {} end

nibRealUI.oocFunctions = {}
nibRealUI.configModeModules = {}

-- Localized Fonts
do
    local LSM = LibStub("LibSharedMedia-3.0")
    local lsmFonts = LSM:List("font")
    local function findFont(font, backup)
        local fontPath, fontSize, fontArgs = font:GetFont()
        if not fontPath then
            debug("Font not loaded, set backup")
            fontPath, fontSize, fontArgs = backup:GetFont()
            font:SetFont(fontPath, fontSize, fontArgs)
        end
        local fontName, path
        for i = 1, #lsmFonts do
            fontName = lsmFonts[i]
            path = LSM:Fetch("font", fontName)
            debug("Fonts|", fontName, "|", path, "|", fontPath)
            if path == fontPath then
                debug("Fonts Equal|", fontName, "|", fontSize, "|", fontArgs)
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
        standard = findFont(RealUIFont_Normal, SystemFont_Small),
        chat = findFont(RealUIFont_Chat, NumberFont_Normal_Med),
        crit = findFont(RealUIFont_Crit, NumberFont_Outline_Huge),
        header = findFont(RealUIFont_Header, QuestFont_Huge),
        pixel = {
            small =    findFont(RealUIFont_PixelSmall, SystemFont_Small),
            large =    findFont(RealUIFont_PixelLarge, SystemFont_Med1),
            numbers =  findFont(RealUIFont_PixelNumbers, SystemFont_Large),
            cooldown = findFont(RealUIFont_PixelCooldown, SystemFont_Large),
        }
    }
    nibRealUI.media.font = fonts
end

nibRealUI.defaultPositions = {
    [1] = {     -- DPS/Tank
        ["Nothing"] = 0,
        ["HuDX"] = 0,
        ["HuDY"] = -38,
        ["UFHorizontal"] = 316,
        ["ActionBarsY"] = -161.5,
        ["GridTopX"] = 0,
        ["GridTopY"] = -197.5,
        ["GridBottomX"] = 0,
        ["GridBottomY"] = 58,
        ["CTAurasLeftX"] = 0,
        ["CTAurasLeftY"] = 0,
        ["CTAurasRightX"] = 0,
        ["CTAurasRightY"] = 0,
        ["CTPointsWidth"] = 184,
        ["CTPointsHeight"] = 148,
        ["CastBarPlayerX"] = 0,
        ["CastBarPlayerY"] = 0,
        ["CastBarTargetX"] = 0,
        ["CastBarTargetY"] = 0,
        ["SpellAlertWidth"] = 200,
        ["ClassAuraWidth"] = 80,
        ["ClassResourceX"] = 0,
        ["ClassResourceY"] = 0,
        ["RunesX"] = 0,
        ["RunesY"] = 0,
        ["BossX"] = -32,        -- Boss anchored to RIGHT
        ["BossY"] = 314,
    },
    [2] = {     -- Healing
        ["Nothing"] = 0,
        ["HuDX"] = 0,
        ["HuDY"] = -38,
        ["UFHorizontal"] = 316,
        ["ActionBarsY"] = -161.5,
        ["GridTopX"] = 0,
        ["GridTopY"] = -197.5,
        ["GridBottomX"] = 0,
        ["GridBottomY"] = 58,
        ["CTAurasLeftX"] = 0,
        ["CTAurasLeftY"] = 0,
        ["CTAurasRightX"] = 0,
        ["CTAurasRightY"] = 0,
        ["CTPointsWidth"] = 184,
        ["CTPointsHeight"] = 148,
        ["CastBarPlayerX"] = 0,
        ["CastBarPlayerY"] = 0,
        ["CastBarTargetX"] = 0,
        ["CastBarTargetY"] = 0,
        ["SpellAlertWidth"] = 200,
        ["ClassAuraWidth"] = 80,
        ["ClassResourceX"] = 0,
        ["ClassResourceY"] = 0,
        ["RunesX"] = 0,
        ["RunesY"] = 0,
        ["BossX"] = -32,        -- Boss anchored to RIGHT
        ["BossY"] = 314,
    },
}

-- Offset some UI Elements for Large/Small HuD size settings
nibRealUI.hudSizeOffsets = {
    [1] = {
        ["UFHorizontal"] = 0,
        ["SpellAlertWidth"] = 0,
        ["ActionBarsY"] = 0,
        ["GridTopY"] = 0,
        ["CastBarPlayerY"] = 0,
        ["CastBarTargetY"] = 0,
        ["ClassResourceY"] = 0,
        ["CTPointsHeight"] = 0,
        ["CTAurasLeftX"] = 0,
        ["CTAurasLeftY"] = 0,
        ["CTAurasRightX"] = 0,
        ["CTAurasRightY"] = 0,
        ["RunesY"] = 0,
    },
    [2] = {
        ["UFHorizontal"] = 50,
        ["SpellAlertWidth"] = 50,
        ["ActionBarsY"] = -20,
        ["GridTopY"] = -20,
        ["CastBarPlayerY"] = -20,
        ["CastBarTargetY"] = -20,
        ["ClassResourceY"] = -20,
        ["CTPointsHeight"] = 40,
        ["CTAurasLeftX"] = -1,
        ["CTAurasLeftY"] = -20,
        ["CTAurasRightX"] = 1,
        ["CTAurasRightY"] = -20,
        ["RunesY"] = -20,
    },
}

-- Default Options
local defaults = {
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
    },
    char = {
        layout = {
            current = 1,    -- 1 = DPS/Tank, 2 = Healing
            needchanged = false,
            spec = {1, 1},  -- Save layout for each spec
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
        positions = nibRealUI.defaultPositions,
        -- Action Bar settings
        abSettingsLink = false,
        -- Dynamic UI settings
        settings = {
            powerMode = 1,  -- 1 = Normal, 2 = Economy, 3 = Turbo
            fontStyle = 2,
            infoLineBackground = true,
            stripeOpacity = 0.5,
            hudSize = 1,
            reverseUnitFrameBars = false,
        },
        media = nibRealUI.media
    },
}
--------------------------------------------------------

-- Toggle Grid2's "Test Layout"
function nibRealUI:ToggleGridTestMode(show)
    if not Grid2 then return end
    if show then
        if RealUIGridConfiguring then return end
        if not Grid2Options then Grid2:LoadGrid2Options() end
        Grid2Options.LayoutTestEnable(Grid2Options, "By Group 20")
        RealUIGridConfiguring = true
    else
        RealUIGridConfiguring = false
        if Grid2Options then
            Grid2Options.LayoutTestEnable(Grid2Options)
        end
    end
end

-- Move HuD Up if using a Low Resolution display
function nibRealUI:SetLowResOptimizations(...)
    local dbp, dp = db.positions, self.defaultPositions
    if (dbp[nibRealUI.cLayout]["HuDY"] == dp[nibRealUI.cLayout]["HuDY"]) then
        dbp[nibRealUI.cLayout]["HuDY"] = -5
    end
    if (dbp[nibRealUI.ncLayout]["HuDY"] == dp[nibRealUI.ncLayout]["HuDY"]) then
        dbp[nibRealUI.ncLayout]["HuDY"] = -5
    end

    nibRealUI:UpdateLayout()

    dbg.tags.lowResOptimized = true
end

function nibRealUI:LowResOptimizationCheck(...)
    local resWidth, resHeight = nibRealUI:GetResolutionVals()
    if (resHeight < 900) and not(dbg.tags.lowResOptimized) then
        nibRealUI:SetLowResOptimizations(...)
    end
end

-- Check if user is using a Retina Display
function nibRealUI:RetinaDisplayCheck()
    local resWidth, resHeight = nibRealUI:GetResolutionVals()
    if (resWidth > 2560) and (resHeight > 1600) then
        return true
    else
        dbg.tags.retinaDisplay.checked = true
        dbg.tags.retinaDisplay.set = false
        return false
    end
end

-- Power Mode
function nibRealUI:SetPowerMode(val)
    -- Core\SpiralBorder, HuD\UnitFrames, Modules\PlayerShields, Modules\RaidDebuffs, Modules\Pitch
    db.settings.powerMode = val
    for k, mod in self:IterateModules() do
        if self:GetModuleEnabled(k) and mod.SetUpdateSpeed and type(mod.SetUpdateSpeed) == "function" then
            mod:SetUpdateSpeed()
        end
    end
end

---- Style Updates ----
function nibRealUI:StyleSetWindowOpacity()
    for k, frame in pairs(REALUI_WINDOW_FRAMES) do
        if frame.SetBackdropColor then
            frame:SetBackdropColor(unpack(nibRealUI.media.window))
        end
    end
end

function nibRealUI:StyleSetStripeOpacity()
    for k, tex in pairs(REALUI_STRIPE_TEXTURES) do
        if tex.SetAlpha then
            tex:SetAlpha(RealUI_InitDB.stripeOpacity)
        end
    end
end

-- Style - Global Colors
function nibRealUI:StyleUpdateColors()
    for k, mod in self:IterateModules() do
        if self:GetModuleEnabled(k) and mod.UpdateGlobalColors and type(mod.UpdateGlobalColors) == "function" then
            mod:UpdateGlobalColors()
        end
    end
end

-- Layout Updates
function nibRealUI:SetLayout()
    -- Set Current and Not-Current layout variables
    self.cLayout = dbc.layout.current
    self.ncLayout = self.cLayout == 1 and 2 or 1

    -- Set AddOn profiles
    self:SetProfileLayout()

    -- Set Positioners
    self:UpdatePositioners()


    if RealUIGridConfiguring then
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
        if GL then GL:SettingsUpdate("nibRealUI:SetLayout") end
    end

    -- Layout Button (For Installation)
    if self:GetModuleEnabled("InfoLine") then
        local IL = self:GetModule("InfoLine", true)
        if IL then IL:Refresh() end
    end

    -- FrameMover
    if self:GetModuleEnabled("FrameMover") then
        local FM = self:GetModule("FrameMover", true)
        if FM then FM:MoveAddons() end
    end

    dbc.layout.needchanged = false
end
function nibRealUI:UpdateLayout()
    if InCombatLockdown() then
        -- Register to update once combat ends
        if not self.oocFunctions["SetLayout"] then
            self:RegisterLockdownUpdate("SetLayout", function() nibRealUI:SetLayout() end)
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
function nibRealUI:LockdownUpdates()
    if not InCombatLockdown() then
        local stillProcessing
        for k, fun in pairs(self.oocFunctions) do
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
function nibRealUI:UpdateLockdown(...)
    if not self.lockdownTimer then self.lockdownTimer = self:ScheduleRepeatingTimer("LockdownUpdates", 0.5) end
end
function nibRealUI:RegisterLockdownUpdate(id, fun, ...)
    if not InCombatLockdown() then
        self.oocFunctions[id] = nil
        fun(...)
    else
        self.oocFunctions[id] = function(...) fun(...) end
    end
end

-- Version info retrieval
function nibRealUI:GetVerString(returnLong)
    local verinfo = nibRealUI.verinfo
    if returnLong then
        return string.format("|cFFFF6014%d|r.|cFF269BFF%d|r |cFF21E521r%d%s|r", verinfo[1], verinfo[2], verinfo[3], verinfo[4] or "")
    else
        return string.format("%s.%s", verinfo[1], verinfo[2])
    end
end
function nibRealUI:MajorVerChange(oldVer, curVer)
    return ((curVer[1] > oldVer[1]) and "major") or ((curVer[2] > oldVer[2]) and "minor")
end

-- Events
function nibRealUI:VARIABLES_LOADED()
    ---- Blizzard Bug Fixes
    -- No Map emote
    hooksecurefunc("DoEmote", function(emote)
        if emote == "READ" and WorldMapFrame:IsShown() then
            CancelEmote()
        end
    end)

    -- -- Temp solution for Blizzard's 5.4.1 craziness
    -- UIParent:HookScript("OnEvent", function(self, event, a1, a2)
    --  if event:find("ACTION_FORBIDDEN") and ((a1 or "")..(a2 or "")):find("IsDisabledByParentalControls") then
    --      StaticPopup_Hide(event)
    --  end
    -- end)

    -- Fix Regeant shift+clicking in TradeSkill window
    LoadAddOn("Blizzard_TradeSkillUI")
    local function TradeSkillReagent_OnClick(self)
        local link, name = GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, self:GetID())
        if not link then
            name, link = GameTooltip:GetItem()
            if name ~= self.name:GetText() then
                return
            end
        end
        HandleModifiedItemClick(link)
    end
    for i = 1, 8 do
        _G["TradeSkillReagent"..i]:SetScript("OnClick", TradeSkillReagent_OnClick)
    end
end

-- Delayed updates
function nibRealUI:UPDATE_PENDING_MAIL()
    self:UnregisterEvent("UPDATE_PENDING_MAIL")

    CancelEmote()   -- Cancel Map Holding animation

    -- Refresh WatchFrame lines and positioning
    if ObjectiveTrackerFrame and ObjectiveTrackerFrame.collapsed then
        ObjectiveTracker_Collapse()
        ObjectiveTracker_Expand()
    end
end

local lastGarbageCollection = 0
function nibRealUI:PLAYER_ENTERING_WORLD()
    self:LockdownUpdates()

    -- Modify Main Menu
    for i = 1, GameMenuFrame:GetNumRegions() do
        local region = select(i, GameMenuFrame:GetRegions())
        if region:GetObjectType() == "FontString" then
            if region:GetText() == MAINMENU_BUTTON then
                region:SetFontObject(RealUIFont_PixelSmall)
                region:SetTextColor(unpack(nibRealUI.classColor))
                region:SetShadowColor(0, 0, 0, 0)
                region:SetPoint("TOP", GameMenuFrame, "TOP", 0, -10.5)
            end
        end
    end

    GameMenuButtonStore:SetScale(0.00001)
    GameMenuButtonStore:SetAlpha(0)

    -- RealUI Control
    local ConfigStr = string.format("|cffffffffReal|r|cff%sUI|r Config", nibRealUI:ColorTableToStr(nibRealUI.media.colors.red))
    GameMenuFrame.realuiControl = nibRealUI:CreateTextButton(ConfigStr, GameMenuFrame, "GameMenuButtonTemplate")
    GameMenuFrame.realuiControl:SetPoint("TOP", GameMenuButtonContinue, "BOTTOM", 0, -16)
    GameMenuFrame.realuiControl:SetScript("OnMouseUp", function() nibRealUI:LoadConfig("HuD"); HideUIPanel(GameMenuFrame) end)

    -- Button Backgrounds
    nibRealUI:CreateBGSection(GameMenuFrame, GameMenuButtonHelp, GameMenuButtonWhatsNew)
    nibRealUI:CreateBGSection(GameMenuFrame, GameMenuButtonOptions, GameMenuButtonAddons)

    nibRealUI:CreateBGSection(GameMenuFrame, GameMenuButtonLogout, GameMenuButtonQuit)
    nibRealUI:CreateBGSection(GameMenuFrame, GameMenuButtonContinue, GameMenuButtonContinue)
    nibRealUI:CreateBGSection(GameMenuFrame, GameMenuFrame.realuiControl, GameMenuFrame.realuiControl)

    -- >= 10 minute garbage collection
    self:ScheduleTimer(function()
        local now = GetTime()
        if now >= lastGarbageCollection + 600 then
            collectgarbage("collect")
            lastGarbageCollection = now
        end
    end, 1)

    -- Position Chat Frame
    if nibRealUICharacter.needchatmoved then
        ChatFrame1:ClearAllPoints()
        ChatFrame1:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 6, 32)
        ChatFrame1:SetFrameLevel(15)
        ChatFrame1:SetHeight(145)
        ChatFrame1:SetWidth(400)
        ChatFrame1:SetUserPlaced(true)
        FCF_SavePositionAndDimensions(ChatFrame1)
        nibRealUICharacter.needchatmoved = false
    end
end

function nibRealUI:PLAYER_LOGIN()
    -- Retina Display check
    if not(dbg.tags.retinaDisplay.checked) and self:RetinaDisplayCheck() then
        self:InitRetinaDisplayOptions()
        return
    end

    -- Low Res optimization check
    if (nibRealUICharacter and nibRealUICharacter.installStage == -1) then
        self:LowResOptimizationCheck()
    end

    -- Tutorial
    if (nibRealUICharacter and nibRealUICharacter.installStage == -1) then
        if (dbg.tutorial.stage == 0) then
            self:InitTutorial()
        end
    end

    -- Check if Installation/Patch is necessary
    self:InstallProcedure()

    -- Do we need a Layout change?
    if dbc.layout.needchanged then
        nibRealUI:UpdateLayout()
    end

    -- Helpful messages
    local blue = nibRealUI:ColorTableToStr(nibRealUI.media.colors.blue)
    local red = nibRealUI:ColorTableToStr(nibRealUI.media.colors.red)

    if (nibRealUICharacter.installStage == -1) and (dbg.tutorial.stage == -1) then
        if not(dbg.messages.resetNew) then
            -- This part should be in the bag addon
            if IsAddOnLoaded("cargBags_Nivaya") then
                hooksecurefunc(Nivaya, "OnShow", function()
                    if nibRealUI.db.global.messages.resetNew then return end
                    nibRealUI:Notification("Inventory", true, "Categorize New Items with the Reset New button.", nil, [[Interface\AddOns\cargBags_Nivaya\media\ResetNew_Large]], 0, 1, 0, 1)
                    nibRealUI.db.global.messages.resetNew = true
                end)
            end
        end
        if not LOCALE_enUS then
            print("Help localize RealUI to your language. Go to http://goo.gl/SHZewK")
        end
    end

    if not nibRealUI.db.global.messages.AuraTrackerReset and nibRealUI.verinfo[3] <= 14 then
        StaticPopupDialogs["RUI_AURATRACKER_RESET"] = {
            text = "In the next revision update (r15), Aura Tracker settings will be reset. See this thread for details.",
            button1 = OKAY,
            OnAccept = function()
                nibRealUI.db.global.messages.AuraTrackerReset = true
            end,
            whileDead = true,
            hideOnEscape = true,
            hasEditBox = true,
            OnShow = function(self)
                self.editBox:SetFocus()
                self.editBox:SetText("http://www.wowinterface.com/forums/showthread.php?t=52754")
                self.editBox:HighlightText()
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
                ClearCursor()
            end
        }
        StaticPopup_Show("RUI_AURATRACKER_RESET")
    end

    -- WoW Debugging settings - notify if enabled as they have a performance impact and user may have left them on
    if GetCVar("scriptProfile") == "1" then
        print(format(L["Slash_Profile"], red, blue))
    end
    if GetCVar("taintLog") ~= "0" then
        print(format(L["Slash_Taint"], red, blue))
    end

    -- Update styling
    self:StyleSetStripeOpacity()
    self:StyleSetWindowOpacity()
end

-- To help position UI elements
function RealUI_TestRaidWarnings()
    nibRealUI:ScheduleRepeatingTimer(function()
        RaidNotice_AddMessage(RaidWarningFrame, CHAT_MSG_RAID_WARNING, { r = 0, g = 1, b = 0 })
        RaidNotice_AddMessage(RaidBossEmoteFrame, CHAT_MSG_RAID_BOSS_EMOTE, { r = 0, g = 1, b = 0 })
    end, 5)
end

function nibRealUI:CPU_Profiling_Toggle()
    SetCVar("scriptProfile", (GetCVar("scriptProfile") == "1") and "0" or "1")
    ReloadUI()
end

function nibRealUI:Taint_Logging_Toggle()
    local taintLog = GetCVar("taintLog")
    SetCVar("taintLog", (taintLog ~= "0") and "0" or "2")
    ReloadUI()
end

function nibRealUI:ADDON_LOADED(event, addon)
    if addon ~= "nibRealUI" then return end

    -- Open before login to stop taint
    ToggleFrame(SpellBookFrame)
end

function nibRealUI:ChatCommand_Config()
    dbg.tags.slashRealUITyped = true
    nibRealUI:LoadConfig("HuD")
end

local configLoaded, configFailed = false, false
function nibRealUI:LoadConfig(app, section, ...)
    if not configLoaded then
        configLoaded = true
        local loaded, reason = LoadAddOn("nibRealUI_Config")
        if not loaded then
            print("Failed to load nibRealUI_Config:", reason)
            configFailed = true
        end
    end
    if not configFailed then return self:ToggleConfig(app, section, ...) end

    -- For compat until new config is finished
    nibRealUI:SetUpOptions()
    if app == "HuD" and not ... then
        return nibRealUI:ShowConfigBar()
    end
    if LibStub("AceConfigDialog-3.0").OpenFrames[app] then
        LibStub("AceConfigDialog-3.0"):Close(app)
    else
        LibStub("AceConfigDialog-3.0"):Open(app, section, ...)
    end
end

function nibRealUI:OnInitialize()
    -- Initialize settings, options, slash commands
    self.db = LibStub("AceDB-3.0"):New("nibRealUIDB", defaults, "RealUI")
    db = self.db.profile
    dbc = self.db.char
    dbg = self.db.global
    self.media = db.media

    -- Vars
    self.realm = GetRealmName()
    self.faction = UnitFactionGroup("player")
    self.classLocale, self.class, self.classID = UnitClass("player")
    self.classColor = nibRealUI:GetClassColor(self.class)
    self.name = UnitName("player")
    self.key = string.format("%s - %s", self.name, self.realm)
    self.cLayout = dbc.layout.current
    self.ncLayout = self.cLayout == 1 and 2 or 1

    -- Profile change
    self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
    self.db.RegisterCallback(self, "OnProfileReset", "Refresh")

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
    self:RegisterChatCommand("realadv", function() nibRealUI:LoadConfig("nibRealUI") end)
    self:RegisterChatCommand("memory", "MemoryDisplay")
    self:RegisterChatCommand("rl", function() ReloadUI() end)
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
    GameMenuFrame:HookScript("OnShow", function() GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 27) end)

    -- Synch user's settings
    if dbg.tags.firsttime then
        SetCVar("synchronizeSettings", 1)
        SetCVar("synchronizeConfig", 1)
        SetCVar("synchronizeBindings", 1)
        SetCVar("synchronizeMacros", 1)
    end

    if db.settings.stripeOpacity then
        RealUI_InitDB.stripeOpacity = db.settings.stripeOpacity
        db.settings.stripeOpacity = nil
    end

    -- Remove Interface Options cancel button because it = taint
    --InterfaceOptionsFrameCancel:Hide()
    --InterfaceOptionsFrameOkay:SetAllPoints(InterfaceOptionsFrameCancel)

    -- Make clicking cancel the same as clicking okay
    --InterfaceOptionsFrameCancel:SetScript("OnClick", function()
    --  InterfaceOptionsFrameOkay:Click()
    --end)

    -- Done
    print(format("RealUI %s loaded.", nibRealUI:GetVerString(true)))
    if not(dbg.tags.slashRealUITyped) and nibRealUICharacter and (nibRealUICharacter.installStage == -1) then
        print(string.format(L["Slash_RealUI"], "|cFFFF8000/realui|r"))
    end
end

function nibRealUI:RegisterConfigModeModule(module)
    if module and module.ToggleConfigMode and type(module.ToggleConfigMode) == "function" then
        tinsert(self.configModeModules, module)
    end
end

do
    local prototype = {
        debug = function(self, ...)
            nibRealUI.Debug(self.moduleName, ...)
        end,
    }
    function nibRealUI:CreateModule(name, ...)
        return self:NewModule(name, prototype, ...)
    end
end

function nibRealUI:GetModuleEnabled(module)
    return db.modules[module]
end

function nibRealUI:SetModuleEnabled(module, value)
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

function nibRealUI:Refresh()
    nibRealUI:ReloadUIDialog()
end
