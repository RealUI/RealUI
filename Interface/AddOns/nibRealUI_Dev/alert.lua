local _, ns = ...

local achievementAlerts do
    local guild, toon = 4989, 6348
    local achievementID, isGuild, isEarned = toon, false, false
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
            isEarned = {
                name = "Already Earned",
                type = "toggle",
                get = function() return isEarned end,
                set = function(info, value)
                    isEarned = value
                end,
                order = 10,
            },
            achievementGet = {
                name = "Achievement",
                desc = "AchievementAlertSystem",
                type = "execute",
                func = function()
                    if not _G.AchievementFrame then _G.UIParentLoadAddOn("Blizzard_AchievementUI") end
                    _G.AchievementAlertSystem:AddAlert(achievementID, isEarned)
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

    local itemID, apItemID = 30234 --[[ Nordrassil Wrath-Kilt ]], 147406 --[[ Greater Pathfinder's Symbol ]]
    local _, itemLink = _G.GetItemInfo(itemID)
    _G.GetItemInfo(apItemID)
    local rollType, lootSpec = _G.LOOT_ROLL_TYPE_NEED, 268 --[[ Brewmaster ]]
    local currencyID = 823 -- Apexis Crystals
    local bonusPrompt, bonusDuration = 244782, 10
    local rewardType, rewardQuantity = "item", 1
    local bonusResults = {
        "item",
        "currency",
        "money",
        "artifact_power",
    }
    lootAlerts = {
        name = "Loot Alerts",
        type = "group",
        args = {
            header1 = {
                name = "Items",
                type = "header",
                order = 0,
            },
            lootWon = {
                name = "Loot Roll Won",
                desc = "LootAlertSystem",
                type = "execute",
                func = function()
                    _G.GetItemInfo(itemID)
                    _G.LootAlertSystem:AddAlert(itemID, 1, rollType, 98, lootSpec)
                end,
                order = 1,
            },
            lootWonUpgrade = {
                name = "Loot Roll Won (Upgrade)",
                desc = "LootAlertSystem",
                type = "execute",
                func = function()
                    _G.GetItemInfo(itemID)
                    _G.LootAlertSystem:AddAlert(itemID, 1, rollType, 98, lootSpec, nil, nil, nil, nil, true)
                end,
                order = 1,
            },
            lootGiven = {
                name = "Loot Given",
                desc = "LootAlertSystem",
                type = "execute",
                func = function()
                    _G.GetItemInfo(itemID)
                    _G.LootAlertSystem:AddAlert(itemID, 1, nil, nil, lootSpec, nil, nil, nil, true)
                end,
                order = 1,
            },
            lootUpgrade = {
                name = "Loot Upgrade",
                desc = "LootUpgradeAlertSystem",
                type = "execute",
                func = function()
                    _G.GetItemInfo(itemID)
                    _G.LootUpgradeAlertSystem:AddAlert(itemID, 1, lootSpec, 3)
                end,
                order = 1,
            },
            header2 = {
                name = "Bonus Roll",
                type = "header",
                order = 2,
            },
            bonusResultType = {
                name = "Result Type",
                type = "select",
                values = bonusResults,
                get = function()
                    for i, resultType in _G.ipairs(bonusResults) do
                        if resultType == rewardType then
                            return i
                        end
                    end
                end,
                set = function(info, value)
                    rewardType = bonusResults[value]
                    if rewardType == "item" then
                        local _, link = _G.GetItemInfo(itemID)
                        itemLink = link
                        rewardQuantity = 1
                    elseif rewardType == "money" then
                        rewardQuantity = 123456
                    elseif rewardType == "artifact_power" then
                        local _, link = _G.GetItemInfo(147406)
                        itemLink = link
                        rewardQuantity = 123456
                    end
                end,
                order = 3,
            },
            bonusPrompt = {
                name = "Bonus Roll Prompt",
                desc = "LootAlertSystem",
                type = "execute",
                func = function()
                    _G.GetItemInfo(itemID)
                    _G.BonusRollFrame_StartBonusRoll(bonusPrompt, "Woah! A bonus roll!", bonusDuration, currencyID, 2)
                    _G.C_Timer.After(bonusDuration, _G.BonusRollFrame_CloseBonusRoll)
                end,
                order = 3,
            },
            bonusStart = {
                name = "Bonus Roll Start",
                desc = "LootAlertSystem",
                type = "execute",
                func = function()
                    _G.BonusRollFrame_OnEvent(_G.BonusRollFrame, "BONUS_ROLL_STARTED")
                end,
                order = 3,
            },
            bonusResult = {
                name = "Bonus Roll Result",
                desc = "LootAlertSystem",
                type = "execute",
                func = function()
                    _G.BonusRollFrame_OnEvent(_G.BonusRollFrame, "BONUS_ROLL_RESULT", rewardType, itemLink, rewardQuantity, lootSpec)
                end,
                order = 3,
            },
            header3 = {
                name = "Currency",
                type = "header",
                order = 4,
            },
            lootMoney = {
                name = "Loot Money",
                desc = "MoneyWonAlertSystem",
                type = "execute",
                func = function()
                    _G.GetItemInfo(itemID)
                    _G.MoneyWonAlertSystem:AddAlert(123456)
                end,
                order = 5,
            },
            lootCurrency = {
                name = "Loot Currency",
                desc = "LootAlertSystem",
                type = "execute",
                func = function()
                    _G.LootAlertSystem:AddAlert(currencyID, 100, nil, nil, lootSpec, true)
                end,
                order = 5,
            },
            lootGarrisonCache = {
                name = "Loot Garrison Cache",
                desc = "LootAlertSystem",
                type = "execute",
                func = function()
                    _G.LootAlertSystem:AddAlert(824, 100, nil, nil, lootSpec, true, nil, 10)
                end,
                order = 5,
            },
            header4 = {
                name = "Misc",
                type = "header",
                order = 6,
            },
            store = {
                name = "Store Purchase",
                desc = "StorePurchaseAlertSystem",
                type = "execute",
                func = function()
                    local name, _, _, _, _, _, _, _, _, icon = _G.GetItemInfo(itemID)
                    _G.StorePurchaseAlertSystem:AddAlert(icon, name, itemID)
                end,
                order = 7,
            },
            legendary = {
                name = "Legion Legendary",
                desc = "LegendaryItemAlertSystem",
                type = "execute",
                func = function()
                    _G.LegendaryItemAlertSystem:AddAlert(itemID)
                end,
                order = 7,
            },
        },
    }
end
local garrisonAlerts do
    local isUpgraded, talentID = false, 370 --[[ Hunter: Long Range ]]
    local function hasGarrison()
        return _G.C_Garrison.GetLandingPageGarrisonType() > 0
    end
    local function isDraenorGarrison()
        return _G.C_Garrison.GetLandingPageGarrisonType() == _G.LE_GARRISON_TYPE_6_0
    end
    garrisonAlerts = {
        name = "Garrison Alerts",
        disabled = not hasGarrison(),
        type = "group",
        args = {
            header1 = {
                name = "Followers",
                type = "header",
                order = 0,
            },
            isUpgraded = {
                name = "Follower is upgraded",
                type = "toggle",
                get = function() return isUpgraded end,
                set = function(info, value)
                    isUpgraded = value
                end,
                order = 1,
            },
            follower = {
                name = "Garrison Follower",
                desc = "GarrisonFollowerAlertSystem",
                type = "execute",
                func = function()
                    local follower = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_GARRISON_7_0)[1]
                    _G.GarrisonFollowerAlertSystem:AddAlert(follower.followerID, follower.name, follower.level, follower.quality, isUpgraded, follower)
                end,
                order = 1,
            },
            followerShip = {
                name = "Garrison Ship Follower",
                desc = "GarrisonShipFollowerAlertSystem",
                disabled = not isDraenorGarrison(),
                type = "execute",
                func = function()
                    local follower = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2)[1]
                    _G.GarrisonShipFollowerAlertSystem:AddAlert(follower.followerID, follower.name, follower.className, follower.texPrefix, follower.level, follower.quality, isUpgraded, follower)
                end,
                order = 1,
            },
            header2 = {
                name = "Missions",
                type = "header",
                order = 2,
            },
            mission = {
                name = "Garrison Mission",
                desc = "GarrisonMissionAlertSystem",
                type = "execute",
                func = function()
                    local mission = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_GARRISON_7_0)[1]
                    _G.GarrisonMissionAlertSystem:AddAlert(mission)
                end,
                order = 3,
            },
            missionRandom = {
                name = "Garrison Random Mission",
                desc = "GarrisonRandomMissionAlertSystem",
                type = "execute",
                func = function()
                    local mission = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_GARRISON_7_0)[1]
                    _G.GarrisonRandomMissionAlertSystem:AddAlert(mission)
                end,
                order = 3,
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
                order = 3,
            },
            header3 = {
                name = "Misc",
                type = "header",
                order = 4,
            },
            building = {
                name = "Garrison Building",
                desc = "GarrisonBuildingAlertSystem",
                type = "execute",
                func = function()
                    _G.GarrisonBuildingAlertSystem:AddAlert("Barn")
                end,
                order = 5,
            },
            talent = {
                name = "Garrison Talent",
                desc = "GarrisonTalentAlertSystem",
                type = "execute",
                func = function()
                    _G.GarrisonTalentAlertSystem:AddAlert(_G.LE_GARRISON_TYPE_7_0, _G.C_Garrison.GetTalent(talentID))
                end,
                order = 5,
            },
        },
    }
end
local miscAlerts do
    local recipeID, questID, archRace = 42141 --[[]], 42114 --[[]], 1 --[[ Dwarf ]]
    miscAlerts = {
        name = "Misc Alerts",
        type = "group",
        args = {
            digsite = {
                name = "Digsite Complete",
                desc = "DigsiteCompleteAlertSystem",
                type = "execute",
                func = function()
                    _G.DigsiteCompleteAlertSystem:AddAlert(archRace)
                end,
            },
            newRecipe = {
                name = "New Recipe Learned",
                desc = "NewRecipeLearnedAlertSystem",
                type = "execute",
                func = function()
                    _G.NewRecipeLearnedAlertSystem:AddAlert(recipeID)
                end,
            },
            worldQuest = {
                name = "World Quest Complete",
                desc = "WorldQuestCompleteAlertSystem",
                type = "execute",
                func = function()
                    _G.WorldQuestCompleteAlertSystem:AddAlert(questID)
                end,
            },
        },
    }
end

local alert = {
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

function ns.commands:alert()
    local AceConfig = _G.LibStub("AceConfig-3.0", true)
    if AceConfig then
        if alert.init then
            alert.init = nil
            AceConfig:RegisterOptionsTable("alert", alert)
        end
        _G.LibStub("AceConfigDialog-3.0"):Open("alert")
    else
        _G.print("AceConfig does not exist.")
    end
end
