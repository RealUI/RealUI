local ADDON_NAME, ns = ...

-- Lua Globals --
-- luacheck: globals next select

-- RealUI --
local debug = _G.RealUI.GetDebug("Dev")
_G.RealUI.isDev = true

if _G.IsTestBuild() then
    _G.DisableAddOn("Blizzard_Deprecated")
end

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
    "Blizzard_VoidStorageUI",
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
    local loaded = _G.IsAddOnLoaded(addonList[i])
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
    combatEvents = "Blizzard_DebugTools",
}
local eventFrame = _G.CreateFrame("Frame")
eventFrame:RegisterAllEvents()
eventFrame:SetScript("OnEvent", function(self, event, ...)
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
    "nibRealUI_Dev",
    "RealUI_Bugs",
}

local realuiAddons = {
    "nibRealUI",
    "nibRealUI_Config",
    "nibRealUI_Dev",
    "RealUI_Bugs",
    "RealUI_Chat",
    "RealUI_CombatText",
    "RealUI_Inventory",
    "RealUI_Skins",
    "RealUI_Tooltips",

    "HereBeDragons",
    "Kui_Nameplates",
    "Kui_Nameplates_Core",
}

local function AddOptDeps(list, optDeps)
    for i = 1, #optDeps do
        list[#list + 1] = optDeps[i]
    end
end

for i = 1, #realuiAddons do
    AddOptDeps(realuiAddons, {_G.GetAddOnOptionalDependencies(realuiAddons[i])})
end

function ns.commands:realui()
    for i = 1, #realuiAddons do
        if _G.GetAddOnInfo(realuiAddons[i]) then
            _G.EnableAddOn(realuiAddons[i], _G.UnitName("player"))
        end
    end

    _G.print("RealUI addons loaded.")
    _G.AddonList_Update()
end

function ns.commands:aurora()
    for i = 1, #auroraAddons do
        if _G.GetAddOnInfo(auroraAddons[i]) then
            _G.EnableAddOn(auroraAddons[i], _G.UnitName("player"))
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

            if _G.RealUI.GetOptions("DragEmAll", {"global", frame}) then
                _G.LibStub("LibWindow-1.1").SavePosition(frame)
            end
        end
    end)
end

function ns.commands:combatEvents()
    local function addArgs(args, index, ...)
        for i = 1, select("#", ...) do
            if not args[i] then
                args[i] = {}
            end
            args[i][index] = select(i, ...)
        end
    end

    _G.EventTraceFrame:HookScript("OnEvent", function(this, event)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" and not this.ignoredEvents[event] and this.events[this.lastIndex] == event then
            addArgs(this.args, this.lastIndex, _G.CombatLogGetCurrentEventInfo())
        end
    end)
end

-- Slash Commands
_G.SLASH_DEV1 = "/dev"
function _G.SlashCmdList.DEV(msg, editBox)
    local command, arg = _G.strsplit(" ", msg)
    ns.debug("msg:", command, arg, editBox)
    if ns.commands[command] then
        ns.commands[command](ns.commands, arg)
    else
        _G.print("Usage: /dev |cff22dd22command|r")
        for cmd, value in next, ns.commands do
            _G.print(cmd)
        end
    end
end
