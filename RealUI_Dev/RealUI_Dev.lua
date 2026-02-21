local ADDON_NAME, ns = ...

-- Lua Globals --
-- luacheck: globals next select

-- RealUI --
_G.RealUI = _G.RealUI or {}
local getDebug = _G.RealUI.GetDebug
local debug = (type(getDebug) == "function" and getDebug("Dev")) or function() end

_G.RealUI.isDev = true
ns.isClassic = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
ns.isRetail = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE

-- if _G.IsTestBuild() then
--     _G.C_AddOns.DisableAddOn("Blizzard_Deprecated")
-- end

ns.debug = debug
ns.commands = {}

local isClassic = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC)

--_G.GAME_LOCALE ="deDE"
local BlizzAddons = {
    -- Not LoD, listed in order of load
    "Blizzard_CompactRaidFrames",
    "Blizzard_ClientSavedVariables",
    "Blizzard_CUFProfiles",
    "Blizzard_PetBattleUI",
    "Blizzard_TokenUI",
    "Blizzard_StoreUI", -- can be loaded in GlueXML
    "Blizzard_AuthChallengeUI", -- can be loaded in GlueXML
    "Blizzard_UIWidgets",
    "Blizzard_ObjectiveTracker",
    "Blizzard_WowTokenUI",
    "Blizzard_NamePlates",
    "Blizzard_SecureTransferUI",
    "Blizzard_Deprecated",
    "Blizzard_Console",
    "Blizzard_Channels",
    "Blizzard_PTRFeedback", -- Only loaded on PTR/Beta
    "Blizzard_WorldMap",
    "Blizzard_PVPMatch",

    -- LoD
    "Blizzard_AchievementUI",
    "Blizzard_AdventureMap",
    "Blizzard_AlliedRacesUI",
    "Blizzard_APIDocumentation",
    "Blizzard_ArchaeologyUI",
    "Blizzard_ArenaUI",
    "Blizzard_ArtifactUI",
    "Blizzard_AuctionUI",
    "Blizzard_AzeriteEssenceUI",
    "Blizzard_AzeriteRespecUI",
    "Blizzard_AzeriteUI",
    "Blizzard_BarbershopUI",
    "Blizzard_BattlefieldMap",
    "Blizzard_BindingUI",
    "Blizzard_BlackMarketUI",
    "Blizzard_BoostTutorial",
    "Blizzard_Calendar",
    "Blizzard_ChallengesUI",
    "Blizzard_ClassTrial",
    "Blizzard_Collections",
    "Blizzard_CombatLog",
    "Blizzard_CombatText",
    "Blizzard_Commentator",
    "Blizzard_Communities",
    "Blizzard_Contribution",
    "Blizzard_DeathRecap",
    "Blizzard_DebugTools",
    "Blizzard_EncounterJournal",
    "Blizzard_FlightMap",
    "Blizzard_GarrisonTemplates",
    "Blizzard_GarrisonUI",
    "Blizzard_GMChatUI",
    "Blizzard_GMSurveyUI",
    "Blizzard_GuildBankUI",
    "Blizzard_GuildControlUI",
    "Blizzard_GuildRecruitmentUI",
    "Blizzard_GuildUI",
    "Blizzard_InspectUI",
    "Blizzard_IslandsPartyPoseUI",
    "Blizzard_IslandsQueueUI",
    "Blizzard_ItemSocketingUI",
    "Blizzard_ItemUpgradeUI",
    "Blizzard_LookingForGuildUI",
    "Blizzard_MacroUI",
    "Blizzard_MapCanvas",
    "Blizzard_MovePad",
    "Blizzard_ObliterumUI",
    "Blizzard_OrderHallUI",
    "Blizzard_PartyPoseUI",
    "Blizzard_PVPUI",
    "Blizzard_QuestChoice",
    "Blizzard_RaidUI",
    "Blizzard_ScrappingMachineUI",
    "Blizzard_SharedMapDataProviders",
    "Blizzard_SocialUI",
    "Blizzard_TalentUI",
    "Blizzard_TalkingHeadUI",
    "Blizzard_TimeManager",
    "Blizzard_TradeSkillUI",
    "Blizzard_TrainerUI",
    "Blizzard_Tutorial",
    "Blizzard_TutorialTemplates",
    "Blizzard_WarboardUI",
    "Blizzard_WarfrontsPartyPoseUI",
}

local ClassicAddons = {
    -- Not LoD, listed in order of load
    "Blizzard_CompactRaidFrames",
    "Blizzard_ClientSavedVariables",
    "Blizzard_CUFProfiles",
    "Blizzard_StoreUI", -- can be loaded in GlueXML
    "Blizzard_AuthChallengeUI", -- can be loaded in GlueXML
    "Blizzard_WowTokenUI",
    "Blizzard_NamePlates",
    "Blizzard_SecureTransferUI",
    "Blizzard_Console",
    "Blizzard_Channels",
    "Blizzard_UIWidgets",
    "Blizzard_PTRFeedback", -- Only loaded on PTR/Beta
    "Blizzard_WorldMap",

    -- LoD
    "Blizzard_APIDocumentation",
    "Blizzard_AuctionUI",
    "Blizzard_BattlefieldMap",
    "Blizzard_BindingUI",
    "Blizzard_CombatLog",
    "Blizzard_CombatText",
    "Blizzard_Commentator",
    "Blizzard_Communities",
    "Blizzard_CraftUI",
    "Blizzard_DebugTools",
    "Blizzard_FlightMap",
    "Blizzard_GMChatUI",
    "Blizzard_GMSurveyUI",
    "Blizzard_InspectUI",
    "Blizzard_MacroUI",
    "Blizzard_MapCanvas",
    "Blizzard_MovePad",
    "Blizzard_RaidUI",
    "Blizzard_SharedMapDataProviders",
    "Blizzard_SocialUI",
    "Blizzard_TalentUI",
    "Blizzard_TimeManager",
    "Blizzard_TradeSkillUI",
    "Blizzard_TrainerUI",
}

local addonList = isClassic and ClassicAddons or BlizzAddons
for i = 1, #addonList do
    local loaded = _G.C_AddOns.IsAddOnLoaded(addonList[i])
    if loaded then
        debug("Pre-loaded:", addonList[i])
    end
end

local function profileTest(skip)
    if skip then return end
    local start, _ = _G.debugprofilestop()
    for i = 1, 1000000 do
        _ = "text" .. "concat" .. i
    end
    _G.print("concat", _, _G.debugprofilestop() - start)

    start = _G.debugprofilestop()
    for i = 1, 1000000 do
        _ = ("%s%s%d"):format("text", "concat", i)
    end
    _G.print("format", _, _G.debugprofilestop() - start)
end

local seenEvent, lastEvent = {}
local taintCheck = {
    WorldMap_UpdateQuestBonusObjectives = false,
    NUM_WORLDMAP_DEBUG_ZONEMAP = false,
    WorldMapFrame = false,
    CUF_SHOW_BORDER = false,
}
local eventWhitelist = {
    ADDONS_UNLOADING = true,
    ARENA_PREP_OPPONENT_SPECIALIZATIONS = true,
}
_G.C_Timer.NewTicker(1, function()
    for varName, isTainted in next, taintCheck do
        if not isTainted then
            local isSecure, taint = _G.issecurevariable(varName)
            if not isSecure then
                _G.print(varName, "is tainted by", taint, lastEvent)
                debug(varName, "is tainted by", taint, lastEvent)
                debug(_G.debugstack())
                taintCheck[varName] = true
            end
        end
    end
end)


local autorunScripts = {
    test = false,
    testFrame = false,
    nudgeFrame = true,
}

local autorunAddon = {
    combatEvents = "Blizzard_EventTrace",
}
local eventFrame = _G.CreateFrame("Frame")
eventFrame:RegisterAllEvents()
eventFrame:SetScript("OnEvent", function(dialog, event, ...)
    lastEvent = event
    if event == "PLAYER_LOGIN" then
        for command, run in next, autorunScripts do
            if run then
                ns.commands[command](ns.commands, true)
            end
        end
    end

    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == ADDON_NAME then
            profileTest(true)
        end

        if addonName:match("Blizzard") or addonName:match("RealUI") then
            debug("Loaded:", addonName)
        end

        for command, addon in next, autorunAddon do
            if addon and addon == addonName then
                ns.commands[command](ns.commands, true)
            end
        end
    elseif not seenEvent[event] then
        debug(event)
        if ... then
            debug("", ...)
        end

        if eventWhitelist[event] then
            _G.print("Dev", event, ...)
        else
            seenEvent[event] = true
        end
    end
end)

local auroraAddons = {
    "Aurora",
    "RealUI_Dev",
    "RealUI_Bugs",
}

local realuiAddons = {
    "RealUI",
    "RealUI_Config",
    "RealUI_Dev",
    "RealUI_Bugs",
    "RealUI_Chat",
    "RealUI_CombatText",
    "RealUI_Inventory",
    "RealUI_Skins",
    "RealUI_Tooltips",

    "HereBeDragons",
    "Grid2RaidDebuffs",
    -- "Platynator",
}

local function AddOptDeps(list, optDeps)
    for i = 1, #optDeps do
        list[#list + 1] = optDeps[i]
    end
end

for i = 1, #realuiAddons do
    AddOptDeps(realuiAddons, {_G.C_AddOns.GetAddOnOptionalDependencies(realuiAddons[i])})
end

function ns.commands:realui()
    for i = 1, #realuiAddons do
        if _G.C_AddOns.GetAddOnInfo(realuiAddons[i]) then
            _G.C_AddOns.EnableAddOn(realuiAddons[i], _G.UnitName("player"))
        end
    end

    _G.print("RealUI addons loaded.")
    _G.AddonList_Update()
end

function ns.commands:aurora()
    for i = 1, #auroraAddons do
        if _G.C_AddOns.GetAddOnInfo(auroraAddons[i]) then
            _G.C_AddOns.EnableAddOn(auroraAddons[i], _G.UnitName("player"))
        end
    end

    _G.print("Aurora addons loaded.")
    _G.AddonList_Update()
end

local keys = {
    LEFT = function(frame)
        local point, anchor, relPoint, x, y = frame:GetPoint()
        frame:SetPoint(point, anchor, relPoint, x - 1, y)
    end,
    RIGHT = function(frame)
        local point, anchor, relPoint, x, y = frame:GetPoint()
        frame:SetPoint(point, anchor, relPoint, x + 1, y)
    end,
    UP = function(frame)
        local point, anchor, relPoint, x, y = frame:GetPoint()
        frame:SetPoint(point, anchor, relPoint, x, y + 1)
    end,
    DOWN = function(frame)
        local point, anchor, relPoint, x, y = frame:GetPoint()
        frame:SetPoint(point, anchor, relPoint, x, y - 1)
    end,
}
function ns.commands:nudgeFrame()
    local keyFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    keyFrame:SetSize(1, 1)
    keyFrame:SetPoint("TOPLEFT")
    keyFrame:SetFrameStrata("DIALOG")
    keyFrame:EnableKeyboard(true)
    keyFrame:SetPropagateKeyboardInput(true)
    keyFrame:SetScript("OnKeyDown", function(this, key, ...)
        if not _G.FrameStackTooltip then return end
        if not _G.FrameStackTooltip.highlightFrame then return end

        local frame = _G.FrameStackTooltip.highlightFrame
        if keys[key] then
            keys[key](frame)

            local getOptions = _G.RealUI and _G.RealUI.GetOptions
            if type(getOptions) == "function" and getOptions("DragEmAll", {"global", frame}) then
                -- FIXMELATER: Throws errors at random...|
                _G.LibStub("LibWindow-1.1").SavePosition(frame)
            end
        end
    end)
end

function ns.commands:combatEvents()
    local originalOnEvent = _G.EventTrace:GetScript("OnEvent")

    _G.EventTrace:SetScript("OnEvent", function(this, event, ...)
        if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            this:LogEvent(event, _G.C_CombatLog.GetCurrentEntryInfo())
        else
            originalOnEvent(this, event, ...)
        end
    end)
end

-- Test ModuleFramework
function ns.commands:testmodules()
    local RealUI = _G.RealUI
    if not RealUI.ModuleFramework then
        _G.print("ModuleFramework not available")
        return
    end

    _G.print("=== Module Framework Test ===")
    local status = RealUI.ModuleFramework:GetFrameworkStatus()
    _G.print("Initialized:", status.initialized)
    _G.print("Total Modules:", status.totalModules)
    _G.print("Enabled Modules:", status.enabledModules)
    _G.print("Disabled Modules:", status.disabledModules)

    local modules = RealUI.ModuleFramework:GetRegisteredModules()
    _G.print("\nRegistered Modules:")
    for name, info in pairs(modules) do
        local state = RealUI.ModuleFramework:GetModuleState(name)
        _G.print(("  %s: %s [%s]"):format(name, info.type, state))
    end
end

-- Test PerformanceMonitor
function ns.commands:testperf()
    local RealUI = _G.RealUI
    if not RealUI.PerformanceMonitor then
        _G.print("PerformanceMonitor not available")
        return
    end

    _G.print("=== Performance Monitor Test ===")
    local perfData = RealUI.PerformanceMonitor:GetPerformanceData()
    if perfData then
        _G.print("Memory:")
        _G.print(("  Current: %.2f MB"):format((perfData.memory.current or 0) / 1024))
        _G.print(("  Peak: %.2f MB"):format((perfData.memory.peak or 0) / 1024))
        _G.print("CPU:")
        _G.print(("  Current: %.2f ms"):format(perfData.cpu.current or 0))
        _G.print(("  Peak: %.2f ms"):format(perfData.cpu.peak or 0))
        _G.print("Framerate:")
        _G.print(("  Current: %.1f FPS"):format(perfData.framerate.current or 0))
        _G.print(("  Min: %.1f FPS"):format(perfData.framerate.min or 0))
    end
end

-- Test ProfileSystem
function ns.commands:testprofile()
    local RealUI = _G.RealUI
    if not RealUI.ProfileSystem then
        _G.print("ProfileSystem not available")
        return
    end

    _G.print("=== Profile System Test ===")
    local current = RealUI.ProfileSystem:GetCurrentProfile()
    _G.print("Current Profile:", current)

    local profiles = RealUI.ProfileSystem:GetProfileList()
    _G.print("\nAvailable Profiles:")
    for _, name in ipairs(profiles) do
        _G.print("  " .. name)
    end

    local chars = RealUI.ProfileSystem:GetRegisteredCharacters()
    _G.print("\nRegistered Characters:")
    for key, info in pairs(chars) do
        _G.print(("  %s: %s"):format(key, info.profile))
    end
end

-- Test LayoutManager
function ns.commands:testlayout()
    local RealUI = _G.RealUI
    if not RealUI.LayoutManager then
        _G.print("LayoutManager not available")
        return
    end

    _G.print("=== Layout Manager Test ===")
    local current = RealUI.LayoutManager:GetCurrentLayout()
    local name = RealUI.LayoutManager:GetCurrentLayoutName()
    _G.print("Current Layout:", current, "-", name)

    local state = RealUI.LayoutManager:GetLayoutState()
    _G.print("Auto-switch enabled:", state.autoSwitchEnabled)
    _G.print("Last switch time:", state.lastSwitchTime)

    local configs = RealUI.LayoutManager:GetAllLayoutConfigurations()
    _G.print("\nLayout Configurations:")
    for id, config in pairs(configs) do
        _G.print(("  Layout %d: %s"):format(id, config.name))
    end
end

-- Test ResolutionOptimizer
function ns.commands:testresolution()
    local RealUI = _G.RealUI
    if not RealUI.ResolutionOptimizer then
        _G.print("ResolutionOptimizer not available")
        return
    end

    _G.print("=== Resolution Optimizer Test ===")
    local width, height = RealUI.ResolutionOptimizer:GetScreenDimensions()
    _G.print(("Screen: %dx%d"):format(width, height))

    local profile, category = RealUI.ResolutionOptimizer:GetOptimizationProfile()
    if profile then
        _G.print("Category:", category)
        _G.print("Description:", profile.description)
        _G.print("HuD Size:", profile.hudSize)
    end
end

-- Test CompatibilityManager
function ns.commands:testcompat()
    local RealUI = _G.RealUI
    if not RealUI.CompatibilityManager then
        _G.print("CompatibilityManager not available")
        return
    end

    _G.print("=== Compatibility Manager Test ===")
    local issues = RealUI.CompatibilityManager:CheckCompatibility()
    if #issues > 0 then
        _G.print("Compatibility Issues Found:")
        for _, issue in ipairs(issues) do
            _G.print(("  [%s] %s: %s"):format(issue.severity, issue.addon, issue.message))
        end
    else
        _G.print("No compatibility issues detected")
    end
end

-- Test DeploymentValidator
function ns.commands:testdeploy()
    local RealUI = _G.RealUI
    if not RealUI.DeploymentValidator then
        _G.print("DeploymentValidator not available")
        return
    end

    _G.print("=== Deployment Validator Test ===")
    local passed, errors = RealUI.DeploymentValidator:RunValidation()
    _G.print("Validation:", passed and "PASSED" or "FAILED")

    if not passed and errors then
        _G.print("\nValidation Errors:")
        for _, error in ipairs(errors) do
            _G.print(("  %s: %s"):format(error.check, error.message))
        end
    end

    local state = RealUI.DeploymentValidator:GetValidationState()
    _G.print("\nValidation State:")
    _G.print("  Validated:", state.validated)
    _G.print("  Passed:", state.passed)
    _G.print("  Errors:", #state.errors)
    _G.print("  Warnings:", #state.warnings)
end

-- Run all tests
function ns.commands:testall()
    ns.commands:testmodules()
    _G.print("\n")
    ns.commands:testperf()
    _G.print("\n")
    ns.commands:testprofile()
    _G.print("\n")
    ns.commands:testlayout()
    _G.print("\n")
    ns.commands:testresolution()
    _G.print("\n")
    ns.commands:testcompat()
    _G.print("\n")
    ns.commands:testdeploy()
end


-- Slash Commands
_G.SLASH_DEV1 = "/realdev"
function _G.SlashCmdList.DEV(msg, editBox)
    local command, arg = _G.strsplit(" ", msg)
    ns.debug("msg:", command, arg, editBox)
    if ns.commands[command] then
        ns.commands[command](ns.commands, arg)
    else
        _G.print("Usage: /realdev |cff22dd22command|r")
        for cmd, value in next, ns.commands do
            _G.print(cmd)
        end
    end
end
