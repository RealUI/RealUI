local _, private = ...

-- Lua Globals --
local _G = _G
local ipairs = _G.ipairs

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "AlertFrameMove"
local AlertFrameMove = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

local AlertFrameHolder = _G.CreateFrame("Frame", "AlertFrameHolder", _G.UIParent)
AlertFrameHolder:SetWidth(180)
AlertFrameHolder:SetHeight(20)
AlertFrameHolder:SetPoint("TOP", _G.UIParent, "TOP", 0, -18)

local alertPoint, alertRelPoint, alertYofs = "TOP", "BOTTOM", -10
local function QueueAdjustAnchors(self, relativeAlert)
    for alertFrame in self.alertFramePool:EnumerateActive() do
        AlertFrameMove:debug("Queue", alertFrame, alertPoint, relativeAlert:GetName() or relativeAlert, alertRelPoint, alertYofs)
        alertFrame:ClearAllPoints()
        alertFrame:SetPoint(alertPoint, relativeAlert, alertRelPoint, 0, alertYofs)
        relativeAlert = alertFrame
    end
    return relativeAlert
end
local function SimpleAdjustAnchors(self, relativeAlert)
    if self.alertFrame:IsShown() then
        AlertFrameMove:debug("Simple", self.alertFrame:GetName(), alertPoint, relativeAlert:GetName(), alertRelPoint, alertYofs)
        self.alertFrame:ClearAllPoints()
        self.alertFrame:SetPoint(alertPoint, relativeAlert, alertRelPoint, 0, alertYofs)
        return self.alertFrame
    end
    return relativeAlert
end
local function AnchorAdjustAnchors(self, relativeAlert)
    if self.anchorFrame:IsShown() then
        AlertFrameMove:debug("Anchor:AdjustAnchors", relativeAlert:GetName())
        return self.anchorFrame;
    end
    return relativeAlert
end

local function SetUpAlert()
    AlertFrameMove:debug("SetUpAlert")
    _G.hooksecurefunc(_G.AlertFrame, "UpdateAnchors", function(self)
        self:ClearAllPoints()
        self:SetAllPoints(AlertFrameHolder)
    end)
    for i, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
        if alertFrameSubSystem.QueueAlert then
            local frame = alertFrameSubSystem.alertFramePool:GetNextActive()
            AlertFrameMove:debug(i, "Queue system", frame and frame:GetName())
            alertFrameSubSystem.AdjustAnchors = QueueAdjustAnchors
            --_G.hooksecurefunc(alertFrameSubSystem, "AdjustAnchors", QueueAdjustAnchors)
        elseif alertFrameSubSystem.AddAlert then
            AlertFrameMove:debug(i, "Simple system", alertFrameSubSystem.alertFrame:GetName())
            alertFrameSubSystem.AdjustAnchors = SimpleAdjustAnchors
            --_G.hooksecurefunc(alertFrameSubSystem, "AdjustAnchors", SimpleAdjustAnchors)
        else
            AlertFrameMove:debug(i, "Anchor system")
            alertFrameSubSystem.AdjustAnchors = AnchorAdjustAnchors
            --_G.hooksecurefunc(alertFrameSubSystem, "AdjustAnchors", AnchorAdjustAnchors)
        end
    end
end
----------
local alertTest
function AlertFrameMove:OnInitialize()
    self:SetEnabledState(true)

    local AceConfig = _G.LibStub("AceConfig-3.0")
    AceConfig:RegisterOptionsTable("alertTest", alertTest, "alertTest")
end

function AlertFrameMove:OnEnable()
    SetUpAlert()
end

function RealUI:AlertFrameTest()
    _G.LibStub("AceConfigDialog-3.0"):Open("alertTest")
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
        local achievementID = 6348
        achievementAlerts = {
            name = "Achievement Alerts",
            type = "group",
            args = {
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
                    disabled = not _G.GetLFGCompletionReward(),
                    type = "execute",
                    func = function()
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
        local _, link = _G.GetItemInfo(ID.item)
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
                        _G.LootAlertSystem:AddAlert(link, 1, ID.rollType, 98, ID.spec)
                    end,
                },
                lootWonUpgrade = {
                    name = "Loot Roll Won (Upgrade)",
                    desc = "LootAlertSystem",
                    type = "execute",
                    func = function()
                        _G.LootAlertSystem:AddAlert(link, 1, ID.rollType, 98, ID.spec, nil, nil, nil, nil, true)
                    end,
                },
                lootGiven = {
                    name = "Loot Given",
                    desc = "LootAlertSystem",
                    type = "execute",
                    func = function()
                        _G.LootAlertSystem:AddAlert(link, 1, nil, nil, ID.spec, nil, nil, nil, true)
                    end,
                },
                lootMoney = {
                    name = "Loot Money",
                    desc = "MoneyWonAlertSystem",
                    type = "execute",
                    func = function()
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
                        _G.LootUpgradeAlertSystem:AddAlert(link, 1, ID.spec, 3)
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
        local name, link, _, _, _, _, _, _, _, icon = _G.GetItemInfo(ID.item)
        miscAlerts = {
            name = "Misc Alerts",
            type = "group",
            args = {
                store = {
                    name = "Store Purchase",
                    desc = "StorePurchaseAlertSystem",
                    type = "execute",
                    func = function()
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
                        _G.LegendaryItemAlertSystem:AddAlert(link)
                    end,
                },
            },
        }
    end

    alertTest = {
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
