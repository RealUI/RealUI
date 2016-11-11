local ADDON_NAME = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local debug = _G.RealUI.GetDebug("Dev")

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

    -- LoD
    "Blizzard_AchievementUI",
    "Blizzard_AdventureMap",
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

local taintCheck = {
    WorldMap_UpdateQuestBonusObjectives = false,
    WorldMapFrame = false,
}
local seenEvent, lastEvent = {}
local eventWhitelist = {
    BAG_UPDATE = true,
    GET_ITEM_INFO_RECEIVED = true,
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
frame:RegisterAllEvents()
frame:SetScript("OnEvent", function(self, event, ...)
    lastEvent = event
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

        --debug("GetScreenHeight", _G.GetScreenHeight())
        --debug("UIParent:GetSize", _G.UIParent:GetSize())
        if not eventWhitelist[event] then
            seenEvent[event] = true
        end
    end
end)

local alertTest
_G.SLASH_ALERTTEST1 = "/alertTest"
_G.SlashCmdList.ALERTTEST = function(msg, editBox)
    local AceConfig = _G.LibStub("AceConfig-3.0", true)
    if AceConfig then
        if alertTest.init then
            alertTest.init = nil
            AceConfig:RegisterOptionsTable("alertTest", alertTest)
        end
        _G.LibStub("AceConfigDialog-3.0"):Open("alertTest")
    else
        _G.print("AceConfig does not exist.")
    end
end

local ID = {
    spec = 268, -- Brewmaster
    item = 30234, -- Nordrassil Wrath-Kilt
    rollType = _G.LOOT_ROLL_TYPE_NEED,
    currency = 823, -- Apexis Crystals
    recipe = 42141,
    quest = 42114,
    archRace = 1, -- Dwarf
}
do
    local achievementAlerts do
        local guild, toon = 4989, 6348
        local achievementID, isGuild = toon, false
        achievementAlerts = {
            name = "Achievement Alerts",
            type = "group",
            args = {
                isGuild = {
                    name = "Guild Achievement",
                    type = "toggle",
                    get = function() return isGuild end,
                    set = function(info, value)
                        isGuild = value
                        achievementID = isGuild and guild or toon
                    end,
                    order = 10,
                },
                achievementGet = {
                    name = "Achievement",
                    desc = "AchievementAlertSystem",
                    type = "execute",
                    func = function()
                        if not _G.AchievementFrame then _G.UIParentLoadAddOn("Blizzard_AchievementUI") end
                        _G.AchievementAlertSystem:AddAlert(achievementID)
                    end,
                },
                achievementCrit = {
                    name = "Achievement Criteria",
                    desc = "CriteriaAlertSystem",
                    type = "execute",
                    func = function()
                        if not _G.AchievementFrame then _G.UIParentLoadAddOn("Blizzard_AchievementUI") end
                        local criteriaString = _G.GetAchievementCriteriaInfo(achievementID, 1)
                        _G.CriteriaAlertSystem:AddAlert(achievementID, criteriaString)
                    end,
                },
            },
        }
    end
    local lfgAlerts do
        lfgAlerts = {
            name = "LFG Alerts",
            type = "group",
            args = {
                scenario = {
                    name = "Scenario",
                    desc = "ScenarioAlertSystem",
                    disabled = not _G.GetLFGCompletionReward(),
                    type = "execute",
                    func = function()
                        _G.ScenarioAlertSystem:AddAlert()
                    end,
                },
                dungeon = {
                    name = "Dungeon",
                    desc = "DungeonCompletionAlertSystem",
                    --disabled = not _G.GetLFGCompletionReward(),
                    type = "execute",
                    func = function()
                        _G.GetLFGCompletionReward = function()
                            return "Test", nil, 2, "Dungeon", 10, 2, 10, 3, 4, 3
                        end
                        _G.DungeonCompletionAlertSystem:AddAlert()
                    end,
                },
                guildDungeon = {
                    name = "Guild Dungeon",
                    desc = "GuildChallengeAlertSystem",
                    type = "execute",
                    func = function()
                        _G.GuildChallengeAlertSystem:AddAlert(1, 2, 5)
                    end,
                },
            },
        }
    end
    local lootAlerts do
        -- _G.LootAlertSystem:AddAlert(itemLink, quantity, rollType, roll, specID, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded)
        -- _G.LootUpgradeAlertSystem:AddAlert(itemLink, quantity, specID, baseQuality)
        -- _G.MoneyWonAlertSystem:AddAlert(amount)
        lootAlerts = {
            name = "Loot Alerts",
            type = "group",
            args = {
                lootWon = {
                    name = "Loot Roll Won",
                    desc = "LootAlertSystem",
                    type = "execute",
                    func = function()
                        _G.GetItemInfo(ID.item)
                        _G.LootAlertSystem:AddAlert(ID.item, 1, ID.rollType, 98, ID.spec)
                    end,
                },
                lootWonUpgrade = {
                    name = "Loot Roll Won (Upgrade)",
                    desc = "LootAlertSystem",
                    type = "execute",
                    func = function()
                        _G.GetItemInfo(ID.item)
                        _G.LootAlertSystem:AddAlert(ID.item, 1, ID.rollType, 98, ID.spec, nil, nil, nil, nil, true)
                    end,
                },
                lootGiven = {
                    name = "Loot Given",
                    desc = "LootAlertSystem",
                    type = "execute",
                    func = function()
                        _G.GetItemInfo(ID.item)
                        _G.LootAlertSystem:AddAlert(ID.item, 1, nil, nil, ID.spec, nil, nil, nil, true)
                    end,
                },
                lootMoney = {
                    name = "Loot Money",
                    desc = "MoneyWonAlertSystem",
                    type = "execute",
                    func = function()
                        _G.GetItemInfo(ID.item)
                        _G.MoneyWonAlertSystem:AddAlert(123456)
                    end,
                },
                lootCurrency = {
                    name = "Loot Currency",
                    desc = "LootAlertSystem",
                    type = "execute",
                    func = function()
                        _G.LootAlertSystem:AddAlert(ID.currency, 100, nil, nil, ID.spec, true)
                    end,
                },
                lootGarrisonCache = {
                    name = "Loot Garrison Cache",
                    desc = "LootAlertSystem",
                    type = "execute",
                    func = function()
                        _G.LootAlertSystem:AddAlert(824, 100, nil, nil, ID.spec, true, nil, 10)
                    end,
                },
                lootUpgrade = {
                    name = "Loot Upgrade",
                    desc = "LootUpgradeAlertSystem",
                    type = "execute",
                    func = function()
                        _G.GetItemInfo(ID.item)
                        _G.LootUpgradeAlertSystem:AddAlert(ID.item, 1, ID.spec, 3)
                    end,
                },
            },
        }
    end
    local garrisonAlerts do
        local function isDraenorGarrison()
            return _G.C_Garrison.GetLandingPageGarrisonType() == _G.LE_GARRISON_TYPE_6_0
        end
        garrisonAlerts = {
            name = "Garrison Alerts",
            disabled = _G.C_Garrison.GetLandingPageGarrisonType() == 0,
            type = "group",
            args = {
                building = {
                    name = "Garrison Building",
                    desc = "GarrisonBuildingAlertSystem",
                    type = "execute",
                    func = function()
                        _G.GarrisonBuildingAlertSystem:AddAlert("Barn")
                    end,
                },
                mission = {
                    name = "Garrison Mission",
                    desc = "GarrisonMissionAlertSystem",
                    type = "execute",
                    func = function()
                        local mission = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_GARRISON_7_0)[1]
                        _G.GarrisonMissionAlertSystem:AddAlert(mission.missionID)
                    end,
                },
                follower = {
                    name = "Garrison Follower",
                    desc = "GarrisonFollowerAlertSystem",
                    type = "execute",
                    func = function()
                        local follower = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_GARRISON_7_0)[1]
                        _G.GarrisonFollowerAlertSystem:AddAlert(follower.followerID, follower.name, follower.level, follower.quality)
                    end,
                },
                missionShip = {
                    name = "Garrison Ship Mission",
                    desc = "GarrisonShipMissionAlertSystem",
                    disabled = not isDraenorGarrison(),
                    type = "execute",
                    func = function()
                        local mission = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2)[1] 
                        _G.GarrisonShipMissionAlertSystem:AddAlert(mission.missionID)
                    end,
                },
                followerShip = {
                    name = "Garrison Ship Follower",
                    desc = "GarrisonShipFollowerAlertSystem",
                    disabled = not isDraenorGarrison(),
                    type = "execute",
                    func = function()
                        local follower = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2)[1]
                        _G.GarrisonShipFollowerAlertSystem:AddAlert(follower.followerID, follower.name, follower.className, follower.texPrefix, follower.level, follower.quality)
                    end,
                },
                missionRandom = {
                    name = "Garrison Random Mission",
                    desc = "GarrisonRandomMissionAlertSystem",
                    type = "execute",
                    func = function()
                        local mission = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_GARRISON_7_0)[1] 
                        _G.GarrisonRandomMissionAlertSystem:AddAlert(mission.missionID)
                    end,
                },
                talent = {
                    name = "Garrison Talent",
                    desc = "GarrisonTalentAlertSystem",
                    type = "execute",
                    func = function()
                        _G.GarrisonTalentAlertSystem:AddAlert(_G.LE_GARRISON_TYPE_7_0)
                    end,
                },
            },
        }
    end
    local miscAlerts do
        miscAlerts = {
            name = "Misc Alerts",
            type = "group",
            args = {
                store = {
                    name = "Store Purchase",
                    desc = "StorePurchaseAlertSystem",
                    type = "execute",
                    func = function()
                        local name, _, _, _, _, _, _, _, _, icon = _G.GetItemInfo(ID.item)
                        _G.StorePurchaseAlertSystem:AddAlert(icon, name, ID.item)
                    end,
                },
                digsite = {
                    name = "Digsite Complete",
                    desc = "DigsiteCompleteAlertSystem",
                    type = "execute",
                    func = function()
                        _G.DigsiteCompleteAlertSystem:AddAlert(ID.archRace)
                    end,
                },
                newRecipe = {
                    name = "New Recipe Learned",
                    desc = "NewRecipeLearnedAlertSystem",
                    type = "execute",
                    func = function()
                        _G.NewRecipeLearnedAlertSystem:AddAlert(ID.recipe)
                    end,
                },
                worldQuest = {
                    name = "World Quest Complete",
                    desc = "WorldQuestCompleteAlertSystem",
                    type = "execute",
                    func = function()
                        _G.WorldQuestCompleteAlertSystem:AddAlert(ID.quest)
                    end,
                },
                legendary = {
                    name = "Legion Legendary",
                    desc = "LegendaryItemAlertSystem",
                    type = "execute",
                    func = function()
                        _G.LegendaryItemAlertSystem:AddAlert(ID.item)
                    end,
                },
            },
        }
    end

    alertTest = {
        init = true,
        type = "group",
        args = {
            achievementAlerts = achievementAlerts,
            lfgAlerts = lfgAlerts,
            lootAlerts = lootAlerts,
            garrisonAlerts = garrisonAlerts,
            miscAlerts = miscAlerts,
        }
    }
end
