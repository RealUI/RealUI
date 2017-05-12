local ADDON_NAME, ns = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local debug = _G.RealUI.GetDebug("Dev")

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

local oldIsTestBuild = _G.IsTestBuild
local function newIsTestBuild() return false end

local seenEvent, lastEvent = {}
local taintCheck = {
    WorldMap_UpdateQuestBonusObjectives = false,
    WorldMapFrame = false,
}
local eventWhitelist = {
    ARENA_PREP_OPPONENT_SPECIALIZATIONS = true
}
local frame = _G.CreateFrame("Frame")
frame:SetScript("OnUpdate", function(self, elapsed)
    for varName, isTainted in next, taintCheck do
        if not isTainted and not _G.issecurevariable(varName) then
            _G.print(varName, "is tainted", lastEvent)
            debug(varName, "is tainted", lastEvent)
            debug(_G.debugstack())
            taintCheck[varName] = true
        end
    end
end)

local autorunScripts = {
    alert = true
}
frame:RegisterAllEvents()
frame:SetScript("OnEvent", function(self, event, ...)
    lastEvent = event
    if event == "PLAYER_ENTERING_WORLD" then
        for k in next, autorunScripts do
            print("Run", k, ns.commands[k])
            ns.commands[k](ns.commands)
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

        if addonName == "Blizzard_SecureTransferUI" then
            _G.IsTestBuild = newIsTestBuild
        elseif _G.IsTestBuild == newIsTestBuild then
            _G.IsTestBuild = oldIsTestBuild
        end
    elseif not seenEvent[event] then
        debug(event)
        if ... then
            debug("", ...)
        end

        debug("GetNormalizedRealmName", _G.GetNormalizedRealmName())
        --debug("UIParent:GetSize", _G.UIParent:GetSize())
        if eventWhitelist[event] then
            _G.print("Dev", event, ...)
        else
            seenEvent[event] = true
        end
    end
end)

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
