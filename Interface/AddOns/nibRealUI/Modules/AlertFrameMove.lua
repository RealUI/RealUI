local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "AlertFrameMove"
local AlertFrameMove = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Alert Frame Mover",
        desc = "Move the Blizzard Alert Frame and all attached frames.",
        arg = MODNAME,
        -- order = 112,
        args = {
            header = {
                type = "header",
                name = "Alert Frame Mover",
                order = 10,
            },
            desc = {
                type = "description",
                name = "Move the Blizzard Alert Frame and all attached frames.",
                fontSize = "medium",
                order = 20,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Alert Frame Mover module.",
                get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value) 
                    nibRealUI:SetModuleEnabled(MODNAME, value)
                end,
                order = 30,
            },
        },
    }
    end
    
    return options
end

local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", UIParent)
AlertFrameHolder:SetWidth(180)
AlertFrameHolder:SetHeight(20)
AlertFrameHolder:SetPoint("TOP", UIParent, "TOP", 0, -18)

local AFPosition, AFAnchor, AFYOffset = "TOP", "BOTTOM", -10
local IsMoving = false;

local function PostAlertMove(screenQuadrant)
    AlertFrameMove:debug("PostAlertMove", screenQuadrant)
    AlertFrameMove:debug("Alert points", AFPosition, AFAnchor, AFYOffset)
    AFPosition = "TOP"
    AFAnchor = "BOTTOM"
    AFYOffset = -10
    
    AlertFrame:ClearAllPoints()
    AlertFrame:SetAllPoints(AlertFrameHolder)

    if screenQuadrant then
        AlertFrameMove:debug("Do move")
        IsMoving = true
        AlertFrame_FixAnchors()
        IsMoving = false
    end
    local height = GroupLootContainer:GetHeight()
    if (height > 10) then
        AlertFrameMove:debug("Adjust loot")
        -- This is to prevent the alert frames from creeping down the screen.
        GroupLootContainer:SetHeight(1)
    end
end

local hooks = {
    Loot = function(alertAnchor)
        if ( MissingLootFrame:IsShown() ) then
            MissingLootFrame:ClearAllPoints()
            MissingLootFrame:SetPoint(AFPosition, alertAnchor, AFAnchor)
            if ( GroupLootContainer:IsShown() ) then
                GroupLootContainer:ClearAllPoints()
                GroupLootContainer:SetPoint(AFPosition, MissingLootFrame, AFAnchor, 0, AFYOffset)
            end     
        elseif ( GroupLootContainer:IsShown() or IsMoving) then
            GroupLootContainer:ClearAllPoints()
            GroupLootContainer:SetPoint(AFPosition, alertAnchor, AFAnchor)  
        end
    end,
    StorePurchase = StorePurchaseAlertFrame,
    LootWon = function(alertAnchor)
        for i = 1, #LOOT_WON_ALERT_FRAMES do
            local frame = LOOT_WON_ALERT_FRAMES[i]
            if ( frame:IsShown() ) then
                frame:ClearAllPoints()
                frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                alertAnchor = frame
            end
        end
    end,
    LootUpgradeFrame = function(alertAnchor)
        for i=1, #LOOT_UPGRADE_ALERT_FRAMES do
            local frame = LOOT_UPGRADE_ALERT_FRAMES[i]
            if ( frame:IsShown() ) then
                frame:ClearAllPoints()
                frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                alertAnchor = frame
            end
        end
    end,
    MoneyWon = function(alertAnchor)
        for i = 1, #MONEY_WON_ALERT_FRAMES do
            local frame = MONEY_WON_ALERT_FRAMES[i]
            if ( frame:IsShown() ) then
                frame:ClearAllPoints()
                frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                alertAnchor = frame
            end
        end
    end,
    Achievement = function(alertAnchor)
        if ( AchievementAlertFrame1 ) then
            for i = 1, MAX_ACHIEVEMENT_ALERTS do
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
        if ( CriteriaAlertFrame1 ) then
            for i = 1, MAX_ACHIEVEMENT_ALERTS do
                local frame = _G["CriteriaAlertFrame"..i]
                if ( frame and frame:IsShown() ) then
                    frame:ClearAllPoints()
                    frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                    alertAnchor = frame
                end
            end
        end
    end,
    ChallengeMode = ChallengeModeAlertFrame1,
    DungeonCompletion = DungeonCompletionAlertFrame1,
    Scenario = ScenarioAlertFrame1,
    GuildChallenge = GuildChallengeAlertFrame,
    DigsiteCompleteToastFrame = DigsiteCompleteToastFrame,
    GarrisonBuildingAlertFrame = GarrisonBuildingAlertFrame,
    GarrisonMissionAlertFrame = GarrisonMissionAlertFrame,
    GarrisonShipMissionAlertFrame = GarrisonShipMissionAlertFrame,
    GarrisonFollowerAlertFrame = GarrisonFollowerAlertFrame,
    GarrisonShipFollowerAlertFrame = GarrisonShipFollowerAlertFrame
}

local brfMoving = false
local function BonusRollFrame_SetPoint()
    if brfMoving then return end
    brfMoving = true
    BonusRollFrame:ClearAllPoints()
    BonusRollFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    brfMoving = false
end

local function BonusRollFrame_Show()
    brfMoving = true
    BonusRollFrame:ClearAllPoints()
    BonusRollFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    brfMoving = false
end

function AlertFrameMove:AlertMovers()
    self:SecureHook('AlertFrame_FixAnchors', PostAlertMove)
    for name, func in next, hooks do
        local funcName = "AlertFrame_Set"..name.."Anchors"
        AlertFrameMove:debug("Set hook", funcName)
        if type(func) ~= "function" then
            local frame = func
            func = function(alertAnchor)
                if frame and frame:IsShown() then
                    AlertFrameMove:debug(name..": IsShown", AFPosition, AFAnchor, AFYOffset)
                    frame:ClearAllPoints()
                    frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
                    alertAnchor = frame
                end
            end
        end

        self:SecureHook(funcName, func)
    end
    
    hooksecurefunc(BonusRollFrame, 'SetPoint', BonusRollFrame_SetPoint)
    hooksecurefunc(BonusRollFrame, 'Show', BonusRollFrame_Show)
    
    UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil

    -- test
    self:RegisterEvent("GARRISON_MISSION_FINISHED", function(...)
        AlertFrameMove:debug("Event Test", ...)
    end)
end

function RealUIAlertFrameTest()
    LibStub("AceConfigDialog-3.0"):Open("alertTest")
end

local ID = {
    spec = 268, -- Brewmaster
    item = 30234, -- Nordrassil Wrath-Kilt
    rollType = LOOT_ROLL_TYPE_NEED,
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
                        if not AchievementFrame then UIParentLoadAddOn("Blizzard_AchievementUI") end
                        AchievementAlertFrame_ShowAlert(6348)
                    end,
                },
                achievementCrit = {
                    name = "Achievement Criteria",
                    desc = "CriteriaAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        if not AchievementFrame then UIParentLoadAddOn("Blizzard_AchievementUI") end
                        CriteriaAlertFrame_ShowAlert(6348, 1)
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
                    disabled = not GetLFGCompletionReward(),
                    type = "execute",
                    func = function()
                        ScenarioAlertFrame_ShowAlert()
                    end,
                },
                dungeon = {
                    name = "Dungeon",
                    desc = "DungeonCompletionAlertFrame_ShowAlert",
                    disabled = not GetLFGCompletionReward(),
                    type = "execute",
                    func = function()
                        DungeonCompletionAlertFrame_ShowAlert()
                    end,
                },
                guildDungeon = {
                    name = "Guild Dungeon",
                    desc = "GuildChallengeAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        GuildChallengeAlertFrame_ShowAlert(1, 2, 5)
                    end,
                },
                challenge = {
                    name = "Challenge Mode",
                    desc = "ChallengeModeAlertFrame_ShowAlert",
                    disabled = not GetChallengeModeCompletionInfo(),
                    type = "execute",
                    func = function()
                        ChallengeModeAlertFrame_ShowAlert()
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
                        LootWonAlertFrame_ShowAlert(ID.item, 1, rollType, 98)
                    end,
                },
                lootGiven = {
                    name = "Loot Given",
                    desc = "LootWonAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        LootWonAlertFrame_ShowAlert(ID.item, 1, nil, nil, specID)
                    end,
                },
                lootMoney = {
                    name = "Loot Money",
                    desc = "MoneyWonAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        MoneyWonAlertFrame_ShowAlert(ID.item)
                    end,
                },
                lootCurrency = {
                    name = "Loot Currency",
                    desc = "LootWonAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        LootWonAlertFrame_ShowAlert(ID.currency, 100, nil, nil, ID.spec, true, false, 2)
                    end,
                },
                lootGarrisonCache = {
                    name = "Loot Garrison Cache",
                    desc = "LootWonAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        LootWonAlertFrame_ShowAlert(137, 100, nil, nil, specID, true, false, 10)
                    end,
                },
                lootUpgrade = {
                    name = "Loot Upgrade",
                    desc = "LootUpgradeFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        LootUpgradeFrame_ShowAlert(ID.item, 1, 2, 3)
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
                        GarrisonBuildingAlertFrame_ShowAlert("Barn")
                    end,
                },
                mission = {
                    name = "Garrison Mission",
                    desc = "GarrisonMissionAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        local mission = C_Garrison.GetAvailableMissions(LE_FOLLOWER_TYPE_GARRISON_6_0)[1]
                        GarrisonMissionAlertFrame_ShowAlert(mission.missionID)
                    end,
                },
                follower = {
                    name = "Garrison Follower",
                    desc = "GarrisonFollowerAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        local follower = C_Garrison.GetFollowers(LE_FOLLOWER_TYPE_GARRISON_6_0)[1]
                        GarrisonFollowerAlertFrame_ShowAlert(follower.followerID, follower.name, follower.displayID, follower.level, follower.quality)
                    end,
                },
                missionShip = {
                    name = "Garrison Ship Mission",
                    desc = "GarrisonShipMissionAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        local mission = C_Garrison.GetAvailableMissions(LE_FOLLOWER_TYPE_SHIPYARD_6_2)[1] 
                        GarrisonMissionAlertFrame_ShowAlert(mission.missionID)
                    end,
                },
                followerShip = {
                    name = "Garrison Ship Follower",
                    desc = "GarrisonShipFollowerAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        local follower = C_Garrison.GetFollowers(LE_FOLLOWER_TYPE_SHIPYARD_6_2)[1]
                        GarrisonShipFollowerAlertFrame_ShowAlert(follower.followerID, follower.name, follower.className, follower.texPrefix, follower.level, follower.quality)
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
                        StorePurchaseAlertFrame_ShowAlert("Interface\\Icons\\inv_pants_mail_15", "Nordrassil Wrath-Kilt", ID.item)
                    end,
                },
                digsite = {
                    name = "Digsite Complete",
                    desc = "DigsiteCompleteToastFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        DigsiteCompleteToastFrame_ShowAlert(ID.archRace)
                    end,
                },
            },
        },
    },
}

----------
function AlertFrameMove:OnInitialize()
    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)

    local AceConfig = LibStub("AceConfig-3.0")
    AceConfig:RegisterOptionsTable("alertTest", alertTest, {"/alertTest"})
end

function AlertFrameMove:OnEnable()
    self:AlertMovers()
end
