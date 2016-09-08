local _, private = ...

-- Lua Globals --
local _G = _G
local next, ipairs = _G.next, _G.ipairs

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "AlertFrameMove"
local AlertFrameMove = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

local AlertFrameHolder = _G.CreateFrame("Frame", "AlertFrameHolder", _G.UIParent)
AlertFrameHolder:SetWidth(180)
AlertFrameHolder:SetHeight(20)
AlertFrameHolder:SetPoint("TOP", _G.UIParent, "TOP", 0, -18)

local alertBlacklist
local ReplaceAnchors do
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

    function ReplaceAnchors(alertFrameSubSystem)
        if alertFrameSubSystem.alertFramePool then
            local frame = alertFrameSubSystem.alertFramePool:GetNextActive()
            AlertFrameMove:debug("Queue system", frame and frame:GetName())
            if alertBlacklist[alertFrameSubSystem.alertFramePool.frameTemplate] then
                return alertFrameSubSystem.alertFramePool.frameTemplate, true
            else
                alertFrameSubSystem.AdjustAnchors = QueueAdjustAnchors
            end
        elseif alertFrameSubSystem.alertFrame then
            local frame = alertFrameSubSystem.alertFrame
            AlertFrameMove:debug("Simple system", frame:GetName())
            if alertBlacklist[frame:GetName()] then
                return frame:GetName(), true
            else
                alertFrameSubSystem.AdjustAnchors = SimpleAdjustAnchors
            end
        elseif alertFrameSubSystem.anchorFrame then
            local frame = alertFrameSubSystem.anchorFrame
            AlertFrameMove:debug("Anchor system", frame:GetName())
            if alertBlacklist[frame:GetName()] then
                return frame:GetName(), true
            else
                alertFrameSubSystem.AdjustAnchors = AnchorAdjustAnchors
            end
        end
    end
end

local function SetUpAlert()
    AlertFrameMove:debug("SetUpAlert")
    _G.hooksecurefunc(_G.AlertFrame, "UpdateAnchors", function(self)
        AlertFrameMove:debug("UpdateAnchors")
        self:ClearAllPoints()
        self:SetAllPoints(AlertFrameHolder)
    end)
    _G.hooksecurefunc(_G.AlertFrame, "AddAlertFrameSubSystem", function(self, alertFrameSubSystem)
        AlertFrameMove:debug("AddAlertFrameSubSystem")
        local _, isBlacklisted = ReplaceAnchors(alertFrameSubSystem)

        if isBlacklisted then
            for i, alertSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
                AlertFrameMove:debug("iterate SubSystems", i)
                if alertFrameSubSystem == alertSubSystem then
                    return _G.table.remove(_G.AlertFrame.alertFrameSubSystems, i)
                end
            end
        end
    end)

    local remove = {}
    for i, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
        AlertFrameMove:debug("iterate SubSystems", i)
        local name, isBlacklisted = ReplaceAnchors(alertFrameSubSystem)

        if isBlacklisted then
            remove[i] = name
        end
    end

    for i, name in next, remove do
        AlertFrameMove:debug("iterate remove", i, name)
        _G.table.remove(_G.AlertFrame.alertFrameSubSystems, i)
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
    alertBlacklist = {
        GroupLootContainer = RealUI:GetModuleEnabled("Loot"),
        TalkingHeadFrame = true,
    }

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
