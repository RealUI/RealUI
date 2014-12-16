local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "AlertFrameMove"
local AlertFrameMove = nibRealUI:NewModule(MODNAME, "AceHook-3.0")

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
    AFPosition = "TOP"
    AFAnchor = "BOTTOM"
    AFYOffset = -10
    
    AlertFrame:ClearAllPoints()
    AlertFrame:SetAllPoints(AlertFrameHolder)

    if screenQuadrant then
        IsMoving = true
        AlertFrame_FixAnchors()
        IsMoving = false
    end
end

function AlertFrameMove:AlertFrame_SetLootAnchors(alertAnchor)
    --print("AlertFrame_SetLootAnchors", IsMoving)
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
end

function AlertFrameMove:AlertFrame_SetStorePurchaseAnchors(alertAnchor)
    --print("AlertFrame_SetStorePurchaseAnchors", IsMoving)
    local frame = StorePurchaseAlertFrame
    if ( frame:IsShown() ) then
        frame:ClearAllPoints()
        frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
    end
end

function AlertFrameMove:AlertFrame_SetLootWonAnchors(alertAnchor)
    --print("AlertFrame_SetLootWonAnchors", IsMoving)
    for i = 1, #LOOT_WON_ALERT_FRAMES do
        local frame = LOOT_WON_ALERT_FRAMES[i]
        if ( frame:IsShown() ) then
            frame:ClearAllPoints()
            frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
            alertAnchor = frame
        end
    end
end

function AlertFrameMove:AlertFrame_SetLootUpgradeFrameAnchors(alertAnchor)
    --print("AlertFrame_SetLootUpgradeFrameAnchors", IsMoving)
    for i=1, #LOOT_UPGRADE_ALERT_FRAMES do
        local frame = LOOT_UPGRADE_ALERT_FRAMES[i]
        if ( frame:IsShown() ) then
            frame:ClearAllPoints()
            frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
            alertAnchor = frame
        end
    end
end

function AlertFrameMove:AlertFrame_SetMoneyWonAnchors(alertAnchor)
    --print("AlertFrame_SetMoneyWonAnchors", IsMoving)
    for i = 1, #MONEY_WON_ALERT_FRAMES do
        local frame = MONEY_WON_ALERT_FRAMES[i]
        if ( frame:IsShown() ) then
            frame:ClearAllPoints()
            frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
            alertAnchor = frame
        end
    end
end

function AlertFrameMove:AlertFrame_SetAchievementAnchors(alertAnchor)
    --print("AlertFrame_SetAchievementAnchors", IsMoving)
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
end

function AlertFrameMove:AlertFrame_SetCriteriaAnchors(alertAnchor)
    --print("AlertFrame_SetCriteriaAnchors", IsMoving)
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
end

function AlertFrameMove:AlertFrame_SetChallengeModeAnchors(alertAnchor)
    --print("AlertFrame_SetChallengeModeAnchors", IsMoving)
    local frame = ChallengeModeAlertFrame1
    if ( frame:IsShown() ) then
        frame:ClearAllPoints()
        frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
        alertAnchor = frame
    end
end

function AlertFrameMove:AlertFrame_SetDungeonCompletionAnchors(alertAnchor)
    --print("AlertFrame_SetDungeonCompletionAnchors", IsMoving)
    local frame = DungeonCompletionAlertFrame1
    if ( frame:IsShown() ) then
        frame:ClearAllPoints()
        frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
        alertAnchor = frame
    end
end

function AlertFrameMove:AlertFrame_SetScenarioAnchors(alertAnchor)
    --print("AlertFrame_SetScenarioAnchors", IsMoving)
    local frame = ScenarioAlertFrame1
    if ( frame:IsShown() ) then
        frame:ClearAllPoints()
        frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
        alertAnchor = frame
    end
end

function AlertFrameMove:AlertFrame_SetGuildChallengeAnchors(alertAnchor)
    --print("AlertFrame_SetGuildChallengeAnchors", IsMoving)
    local frame = GuildChallengeAlertFrame
    if ( frame:IsShown() ) then
        frame:ClearAllPoints()
        frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
        alertAnchor = frame
    end
end

function AlertFrameMove:AlertFrame_SetDigsiteCompleteToastFrameAnchors(alertAnchor)
    --print("AlertFrame_SetDigsiteCompleteToastFrameAnchors", IsMoving)
    local frame = DigsiteCompleteToastFrame
    if frame and frame:IsShown() then
        frame:ClearAllPoints()
        frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
        alertAnchor = frame
    end
end

function AlertFrameMove:AlertFrame_SetGarrisonBuildingAlertFrameAnchors(alertAnchor)
    print("AlertFrame_SetGarrisonBuildingAlertFrameAnchors", IsMoving)
    local frame = GarrisonBuildingAlertFrame
    if frame and frame:IsShown() then
        frame:ClearAllPoints()
        frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
        alertAnchor = frame
    end
end

function AlertFrameMove:AlertFrame_SetGarrisonMissionAlertFrameAnchors(alertAnchor)
    print("AlertFrame_SetGarrisonMissionAlertFrameAnchors", IsMoving)
    local frame = GarrisonMissionAlertFrame
    if frame and frame:IsShown() then
        frame:ClearAllPoints()
        frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
        alertAnchor = frame
    end
end

function AlertFrameMove:AlertFrame_SetGarrisonFollowerAlertFrameAnchors(alertAnchor)
    print("AlertFrame_SetGarrisonFollowerAlertFrameAnchors", IsMoving)
    local frame = GarrisonFollowerAlertFrame
    if frame and frame:IsShown() then
        frame:ClearAllPoints()
        frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset)
        alertAnchor = frame
    end
end

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
    self:SecureHook('AlertFrame_SetLootAnchors')
    self:SecureHook('AlertFrame_SetStorePurchaseAnchors');
    self:SecureHook('AlertFrame_SetLootWonAnchors')
    self:SecureHook('AlertFrame_SetLootUpgradeFrameAnchors');
    self:SecureHook('AlertFrame_SetMoneyWonAnchors')
    self:SecureHook('AlertFrame_SetAchievementAnchors')
    self:SecureHook('AlertFrame_SetCriteriaAnchors')
    self:SecureHook('AlertFrame_SetChallengeModeAnchors')
    self:SecureHook('AlertFrame_SetDungeonCompletionAnchors')
    self:SecureHook('AlertFrame_SetScenarioAnchors')
    self:SecureHook('AlertFrame_SetGuildChallengeAnchors')
    self:SecureHook('AlertFrame_SetDigsiteCompleteToastFrameAnchors');
    self:SecureHook('AlertFrame_SetGarrisonBuildingAlertFrameAnchors');
    self:SecureHook('AlertFrame_SetGarrisonMissionAlertFrameAnchors');
    self:SecureHook('AlertFrame_SetGarrisonFollowerAlertFrameAnchors');
    
    hooksecurefunc(BonusRollFrame, 'SetPoint', BonusRollFrame_SetPoint)
    hooksecurefunc(BonusRollFrame, 'Show', BonusRollFrame_Show)
    
    UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil
end

local ID = {
    spec = 268, -- Brewmaster
    item = 30234, -- Nordrassil Wrath-Kilt
    rollType = LOOT_ROLL_TYPE_NEED,
    currency = 823, -- Apexis Crystals
    building = "Barn",
    mission = 165,
    follower = 208, -- Ahm
    archRace = 1, -- 
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
                    type = "execute",
                    func = function()
                        ScenarioAlertFrame_ShowAlert()
                    end,
                },
                dungeon = {
                    name = "Dungeon",
                    desc = "DungeonCompletionAlertFrame_ShowAlert",
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
                        GarrisonBuildingAlertFrame_ShowAlert(ID.building)
                    end,
                },
                mission = {
                    name = "Garrison Mission",
                    desc = "GarrisonMissionAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        GarrisonMissionAlertFrame_ShowAlert(ID.mission)
                    end,
                },
                follower = {
                    name = "Garrison Follower",
                    desc = "GarrisonFollowerAlertFrame_ShowAlert",
                    type = "execute",
                    func = function()
                        GarrisonFollowerAlertFrame_ShowAlert(ID.follower, "Ahm", 208, 100, 2)
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
function RealUIAlertFrameTest()
    LibStub("AceConfigDialog-3.0"):Open("alertTest")
end

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
