local ADDON_NAME, ns = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local debug = _G.RealUI.GetDebug("Dev")
_G.RealUI.isDev = true

ns.debug = debug
ns.commands = {}

--_G.GAME_LOCALE ="deDE"
local BlizzAddons = {
    -- Not LoD, in order of load
    "Blizzard_CompactRaidFrames",
    "Blizzard_ClientSavedVariables",
    "Blizzard_CUFProfiles",
    "Blizzard_PetBattleUI",
    "Blizzard_TokenUI",
    "Blizzard_StoreUI", -- can be loaded in GlueXML
    "Blizzard_AuthChallengeUI", -- can be loaded in GlueXML
    "Blizzard_ObjectiveTracker",
    "Blizzard_WowTokenUI",
    "Blizzard_NamePlates",
    "Blizzard_SecureTransferUI",
    "Blizzard_Deprecated",
    "Blizzard_Console",

    -- LoD
    "Blizzard_AchievementUI",
    "Blizzard_AdventureMap",
    "Blizzard_APIDocumentation",
    "Blizzard_ArchaeologyUI",
    "Blizzard_ArenaUI",
    "Blizzard_ArtifactUI",
    "Blizzard_AuctionUI",
    "Blizzard_BarbershopUI",
    "Blizzard_BattlefieldMinimap",
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
    "Blizzard_GuildUI",
    "Blizzard_InspectUI",
    "Blizzard_ItemSocketingUI",
    "Blizzard_ItemUpgradeUI",
    "Blizzard_LookingForGuildUI",
    "Blizzard_MacroUI",
    "Blizzard_MapCanvas",
    "Blizzard_MovePad",
    "Blizzard_ObliterumUI",
    "Blizzard_OrderHallUI",
    "Blizzard_PVPUI",
    "Blizzard_QuestChoice",
    "Blizzard_RaidUI",
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
}

for i = 1, #BlizzAddons do
    local loaded = _G.IsAddOnLoaded(BlizzAddons[i])
    if loaded then
        debug("Pre-loaded:", BlizzAddons[i])
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
    alert = false,
    test = false,
    testFrame = false,
}
local frame = _G.CreateFrame("Frame")
frame:RegisterAllEvents()
frame:SetScript("OnEvent", function(self, event, ...)
    lastEvent = event
    if event == "PLAYER_LOGIN" then
        for command, run in next, autorunScripts do
            if run then
                ns.commands[command](ns.commands)
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
    "cargBags_Nivaya",
    "EasyMail",
    "FreebTip",
    "nibRealUI",
    "nibRealUI_Dev",
    "nibRealUI_Config",
    "RealUI_Bugs",
    "RealUI_Skins",
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
