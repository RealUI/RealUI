local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "AlertFrameMove"
local AlertFrameMove = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

if RealUI.isBeta then return end

local AlertFrameHolder = _G.CreateFrame("Frame", "AlertFrameHolder", _G.UIParent)
AlertFrameHolder:SetWidth(180)
AlertFrameHolder:SetHeight(20)
AlertFrameHolder:SetPoint("TOP", _G.UIParent, "TOP", 0, -18)

local AFPosition, AFAnchor, AFYOffset = "TOP", "BOTTOM", -10
local IsMoving = false;

local function PostAlertMove(screenQuadrant)
    AlertFrameMove:debug("PostAlertMove", screenQuadrant)
    AlertFrameMove:debug("Alert points", AFPosition, AFAnchor, AFYOffset)
    AFPosition = "TOP"
    AFAnchor = "BOTTOM"
    AFYOffset = -10
    
    _G.AlertFrame:ClearAllPoints()
    _G.AlertFrame:SetAllPoints(AlertFrameHolder)

    if screenQuadrant then
        AlertFrameMove:debug("Do move")
        IsMoving = true
        _G.AlertFrame_FixAnchors()
        IsMoving = false
    end
    local height = _G.GroupLootContainer:GetHeight()
    if (height > 10) then
        AlertFrameMove:debug("Adjust loot", height)
        -- This is to prevent the alert frames from creeping down the screen.
        _G.GroupLootContainer:SetHeight(1)
    end
end

local hooks = {
    Loot = function(alertAnchor)
        if ( _G.MissingLootFrame:IsShown() ) then
            _G.MissingLootFrame:ClearAllPoints()
            _G.MissingLootFrame:SetPoint(AFPosition, alertAnchor, AFAnchor)
            if ( _G.GroupLootContainer:IsShown() ) then
                _G.GroupLootContainer:ClearAllPoints()
                _G.GroupLootContainer:SetPoint(AFPosition, _G.MissingLootFrame, AFAnchor, 0, AFYOffset)
            end     
        elseif ( _G.GroupLootContainer:IsShown() or IsMoving) then
            _G.GroupLootContainer:ClearAllPoints()
            _G.GroupLootContainer:SetPoint(AFPosition, alertAnchor, AFAnchor)  
        end
    end,
    StorePurchase = _G.StorePurchaseAlertFrame,
    LootWon = function(alertAnchor)
        for i = 1, #_G.LOOT_WON_ALERT_FRAMES do
            local frame = _G.LOOT_WON_ALERT_FRAMES[i]
            if ( frame:IsShown() ) then
                frame:ClearAllPoints()
                frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                alertAnchor = frame
            end
        end
    end,
    LootUpgradeFrame = function(alertAnchor)
        for i=1, #_G.LOOT_UPGRADE_ALERT_FRAMES do
            local frame = _G.LOOT_UPGRADE_ALERT_FRAMES[i]
            if ( frame:IsShown() ) then
                frame:ClearAllPoints()
                frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                alertAnchor = frame
            end
        end
    end,
    MoneyWon = function(alertAnchor)
        for i = 1, #_G.MONEY_WON_ALERT_FRAMES do
            local frame = _G.MONEY_WON_ALERT_FRAMES[i]
            if ( frame:IsShown() ) then
                frame:ClearAllPoints()
                frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                alertAnchor = frame
            end
        end
    end,
    Achievement = function(alertAnchor)
        if ( _G.AchievementAlertFrame1 ) then
            for i = 1, _G.MAX_ACHIEVEMENT_ALERTS do
                local frame = _G["AchievementAlertFrame"..i]
                if ( frame and frame:IsShown() ) then
                    frame:ClearAllPoints()
                    frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                    alertAnchor = frame
                end
            end
        end
    end,
    Criteria = function(alertAnchor)
        if ( _G.CriteriaAlertFrame1 ) then
            for i = 1, _G.MAX_ACHIEVEMENT_ALERTS do
                local frame = _G["CriteriaAlertFrame"..i]
                if ( frame and frame:IsShown() ) then
                    frame:ClearAllPoints()
                    frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                    alertAnchor = frame
                end
            end
        end
    end,
    ChallengeMode = _G.ChallengeModeAlertFrame1,
    DungeonCompletion = _G.DungeonCompletionAlertFrame1,
    Scenario = _G.ScenarioAlertFrame1,
    GuildChallenge = _G.GuildChallengeAlertFrame,
    DigsiteCompleteToastFrame = _G.DigsiteCompleteToastFrame,
    GarrisonBuildingAlertFrame = _G.GarrisonBuildingAlertFrame,
    GarrisonMissionAlertFrame = _G.GarrisonMissionAlertFrame,
    GarrisonShipMissionAlertFrame = _G.GarrisonShipMissionAlertFrame,
    GarrisonFollowerAlertFrame = _G.GarrisonFollowerAlertFrame,
    GarrisonShipFollowerAlertFrame = _G.GarrisonShipFollowerAlertFrame
}

local brfMoving = false
local function BonusRollFrame_SetPoint()
    if brfMoving then return end
    brfMoving = true
    _G.BonusRollFrame:ClearAllPoints()
    _G.BonusRollFrame:SetPoint("CENTER", _G.UIParent, "CENTER", 0, 0)
    brfMoving = false
end

local function BonusRollFrame_Show()
    brfMoving = true
    _G.BonusRollFrame:ClearAllPoints()
    _G.BonusRollFrame:SetPoint("CENTER", _G.UIParent, "CENTER", 0, 0)
    brfMoving = false
end

function AlertFrameMove:AlertMovers()
    self:SecureHook('AlertFrame_FixAnchors', PostAlertMove)
    for name, func in next, hooks do
        local funcName = "AlertFrame_Set"..name.."Anchors"
        AlertFrameMove:debug("Set hook", funcName)
        if _G.type(func) ~= "function" then
            local frame = func
            function func(alertAnchor)
                if frame and frame:IsShown() then
                    AlertFrameMove:debug(name..": IsShown", AFPosition, AFAnchor, AFYOffset)
                    frame:ClearAllPoints()
                    frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                    alertAnchor = frame  -- luacheck: ignore
                end
            end
        end

        self:SecureHook(funcName, func)
    end
    
    _G.hooksecurefunc(_G.BonusRollFrame, 'SetPoint', BonusRollFrame_SetPoint)
    _G.hooksecurefunc(_G.BonusRollFrame, 'Show', BonusRollFrame_Show)
    
    _G.UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil

    -- test
    self:RegisterEvent("GARRISON_MISSION_FINISHED", function(...)
        AlertFrameMove:debug("Event Test", ...)
    end)
end

function RealUI:AlertFrameTest()
    _G.LibStub("AceConfigDialog-3.0"):Open("alertTest")
end

local ID = {
    spec = 268, -- Brewmaster
    item = 30234, -- Nordrassil Wrath-Kilt
    rollType = _G.LOOT_ROLL_TYPE_NEED,
    currency = 823, -- Apexis Crystals
    archRace = 1, -- Dwarf
}
local alertTest = {
    type = "group",
    args = {
        achievementAlerts = {
            name = "Achievement Alerts",
            type = "group",
            args = {
                achievementGet = {
                    name = "Achievement",
                    desc = "AchievementAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        if not _G.AchievementFrame then _G.UIParentLoadAddOn("Blizzard_AchievementUI") end
                        _G.AchievementAlertFrame_ShowAlert(6348)
                    end,
                },
                achievementCrit = {
                    name = "Achievement Criteria",
                    desc = "CriteriaAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        if not _G.AchievementFrame then _G.UIParentLoadAddOn("Blizzard_AchievementUI") end
                        _G.CriteriaAlertFrame_ShowAlert(6348, 1)
                    end,
                },
            },
        },
        lfgAlerts = {
            name = "LFG Alerts",
            type = "group",
            args = {
                scenario = {
                    name = "Scenario",
                    desc = "ScenarioAlertFrame_ShowAlert",
                    disabled = not _G.GetLFGCompletionReward(),
                    type = "execute",
                    func = function()
                        _G.ScenarioAlertFrame_ShowAlert()
                    end,
                },
                dungeon = {
                    name = "Dungeon",
                    desc = "DungeonCompletionAlertFrame_ShowAlert",
                    disabled = not _G.GetLFGCompletionReward(),
                    type = "execute",
                    func = function()
                        _G.DungeonCompletionAlertFrame_ShowAlert()
                    end,
                },
                guildDungeon = {
                    name = "Guild Dungeon",
                    desc = "GuildChallengeAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        _G.GuildChallengeAlertFrame_ShowAlert(1, 2, 5)
                    end,
                },
            },
        },
        lootAlerts = {
            name = "Loot Alerts",
            type = "group",
            args = {
                lootWon = {
                    name = "Loot Roll Won",
                    desc = "LootWonAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        _G.LootWonAlertFrame_ShowAlert(ID.item, 1, ID.rollType, 98)
                    end,
                },
                lootGiven = {
                    name = "Loot Given",
                    desc = "LootWonAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        _G.LootWonAlertFrame_ShowAlert(ID.item, 1, nil, nil, ID.spec)
                    end,
                },
                lootMoney = {
                    name = "Loot Money",
                    desc = "MoneyWonAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        _G.MoneyWonAlertFrame_ShowAlert(ID.item)
                    end,
                },
                lootCurrency = {
                    name = "Loot Currency",
                    desc = "LootWonAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        _G.LootWonAlertFrame_ShowAlert(ID.currency, 100, nil, nil, ID.spec, true, false, 2)
                    end,
                },
                lootGarrisonCache = {
                    name = "Loot Garrison Cache",
                    desc = "LootWonAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        _G.LootWonAlertFrame_ShowAlert(137, 100, nil, nil, ID.spec, true, false, 10)
                    end,
                },
                lootUpgrade = {
                    name = "Loot Upgrade",
                    desc = "LootUpgradeFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        _G.LootUpgradeFrame_ShowAlert(ID.item, 1, 2, 3)
                    end,
                },
            },
        },
        garrisonAlerts = {
            name = "Garrison Alerts",
            type = "group",
            args = {
                building = {
                    name = "Garrison Building",
                    desc = "GarrisonBuildingAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        _G.GarrisonBuildingAlertFrame_ShowAlert("Barn")
                    end,
                },
                mission = {
                    name = "Garrison Mission",
                    desc = "GarrisonMissionAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        local mission = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_GARRISON_6_0)[1]
                        _G.GarrisonMissionAlertFrame_ShowAlert(mission.missionID)
                    end,
                },
                follower = {
                    name = "Garrison Follower",
                    desc = "GarrisonFollowerAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        local follower = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_GARRISON_6_0)[1]
                        _G.GarrisonFollowerAlertFrame_ShowAlert(follower.followerID, follower.name, follower.displayID, follower.level, follower.quality)
                    end,
                },
                missionShip = {
                    name = "Garrison Ship Mission",
                    desc = "GarrisonShipMissionAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        local mission = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2)[1] 
                        _G.GarrisonMissionAlertFrame_ShowAlert(mission.missionID)
                    end,
                },
                followerShip = {
                    name = "Garrison Ship Follower",
                    desc = "GarrisonShipFollowerAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        local follower = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2)[1]
                        _G.GarrisonShipFollowerAlertFrame_ShowAlert(follower.followerID, follower.name, follower.className, follower.texPrefix, follower.level, follower.quality)
                    end,
                },
            },
        },
        miscAlerts = {
            name = "Misc Alerts",
            type = "group",
            args = {
                store = {
                    name = "Store Purchase",
                    desc = "StorePurchaseAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        _G.StorePurchaseAlertFrame_ShowAlert([[Interface\Icons\inv_pants_mail_15]], "Nordrassil Wrath-Kilt", ID.item)
                    end,
                },
                digsite = {
                    name = "Digsite Complete",
                    desc = "DigsiteCompleteToastFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        _G.DigsiteCompleteToastFrame_ShowAlert(ID.archRace)
                    end,
                },
            },
        },
    },
}

----------
function AlertFrameMove:OnInitialize()
    self:SetEnabledState(true)

    local AceConfig = _G.LibStub("AceConfig-3.0")
    AceConfig:RegisterOptionsTable("alertTest", alertTest, {"/alertTest"})
end

function AlertFrameMove:OnEnable()
    self:AlertMovers()
end
