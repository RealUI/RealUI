-- Original code from DragEmAll by Emelio
-- http://www.wowace.com/addons/drag-em-all/
local _, private = ...

-- Lua Globals --
-- luacheck: globals next type tinsert

-- Libs --
local LibWin = _G.LibStub("LibWindow-1.1")

-- RealUI --
local RealUI = private.RealUI
local FramePoint = RealUI:GetModule("FramePoint")

local MODNAME = "DragEmAll"
local DragEmAll = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local baseFames = {
    --[[
    FrameName = { list of child frames to hook }
    ]]

    AddonList = {},
    AudioOptionsFrame = {},
    BankFrame = {},
    CharacterFrame = {},
    ChatConfigFrame = {},
    ColorPickerFrame = {},
    DressUpFrame = {},
    FriendsFrame = {},
    GameMenuFrame = {},
    GossipFrame = {},
    GuildInviteFrame = {},
    GuildRegistrarFrame = {},
    HelpFrame = {},
    InterfaceOptionsFrame = {},
    ItemTextFrame = {},
    LootFrame = {},
    MailFrame = {"SendMailFrame", "OpenMailFrame"},
    MerchantFrame = {},
    PetitionFrame = {},
    PetStableFrame = {},
    PVEFrame = {},
    QuestFrame = {},
    QuestLogPopupDetailFrame = {},
    SpellBookFrame = {},
    TabardFrame = {},
    TaxiFrame = {},
    TradeFrame = {},
    TutorialFrame = {},
    VideoOptionsFrame = {},
}

local addonFrames = {
    --[[
    AddonName = {
        FrameName = { list of child frames to hook }
            OR
        FrameName = "Name of parent in baseFames"
    ]]

    Blizzard_AchievementUI = {
         AchievementFrame = {"AchievementFrameHeader", "AchievementFrameCategoriesContainer"},
    },
    --Blizzard_AlliedRacesUI = {},
    Blizzard_ArchaeologyUI = {
        ArchaeologyFrame = {}
    },
    --Blizzard_ArenaUI = {},
    --Blizzard_ArtifactUI = {},
    Blizzard_AuctionHouseUI = {
        AuctionHouseFrame = {}
    },
    Blizzard_AzeriteEssenceUI = {
        AzeriteEssenceUI = {}
    },
    Blizzard_AzeriteRespecUI = {
        AzeriteRespecFrame = {}
    },
    Blizzard_AzeriteUI = {
        AzeriteEmpoweredItemUI = {}
    },
    Blizzard_BarbershopUI = {
        BarberShopFrame = {}
    },
    --Blizzard_BattlefieldMap = {},
    Blizzard_BindingUI = {
        KeyBindingFrame = {}
    },
    Blizzard_BlackMarketUI = {
        BlackMarketFrame = {}
    },
    --Blizzard_BoostTutorial = {},
    Blizzard_Calendar = {
        CalendarFrame = {"CalendarCreateEventFrame"}
    },
    Blizzard_ChallengesUI = {
        ChallengesLeaderboardFrame = {}
    },
    Blizzard_Channels = {
        ChannelFrame = {}
    },
    --Blizzard_ClassTrial = {},
    Blizzard_Collections = {
        CollectionsJournal = {}
    },
    Blizzard_Communities = {
        CommunitiesFrame = {"CommunitiesGuildLogFrame"}
    },
    --Blizzard_CompactRaidFrames = {},
    --Blizzard_Contribution = {},
    --Blizzard_DeathRecap = {},
    --Blizzard_DebugTools = {},
    Blizzard_EncounterJournal = {
        EncounterJournal = {}
    },
    Blizzard_FlightMap = {
        FlightMapFrame = {}
    },
    Blizzard_GarrisonUI = {
        GarrisonLandingPage = {},
        GarrisonBuildingFrame = {},
        GarrisonMissionFrame = {}
    },
    --Blizzard_GMChatUI = {},
    Blizzard_GMSurveyUI = {
        GMSurveyFrame = {}
    },
    Blizzard_GuildBankUI = {
        GuildBankFrame = {"GuildBankEmblemFrame"}
    },
    --Blizzard_GuildControlUI = {},
    Blizzard_GuildUI = {
        GuildFrame = {"GuildRosterFrame", "TitleMouseover" }
    },
    Blizzard_InspectUI = {
        InspectFrame = {"InspectPVPFrame", "InspectTalentFrame"}
    },
    --Blizzard_IslandsPartyPoseUI = {},
    --Blizzard_IslandsQueueUI = {},
    Blizzard_ItemInteractionUI = {
        ItemInteractionFrame = {}
    },
    Blizzard_ItemSocketingUI = {
        ItemSocketingFrame = {}
    },
    Blizzard_ItemUpgradeUI = {
        ItemUpgradeFrame = {},
    },
    Blizzard_LookingForGuildUI = {
        LookingForGuildFrame = {}
    },
    Blizzard_MacroUI = {
        MacroFrame = {}
    },
    --Blizzard_ObjectiveTracker = {},
    Blizzard_ObliterumUI = {},
    Blizzard_OrderHallUI = {
        OrderHallTalentFrame = {}
    },
    --Blizzard_PartyPoseUI = {},
    --Blizzard_PVPMatch = {},
    --Blizzard_PVPUI = {},
    Blizzard_QuestChoice = {
        QuestChoiceFrame = {}
    },
    --Blizzard_RaidUI = {},
    Blizzard_ScrappingMachineUI = {},
    --Blizzard_SocialUI = {},
    --Blizzard_StoreUI = {},
    Blizzard_TalentUI = {
        PlayerTalentFrame = {}
    },
    Blizzard_TimeManager = {
        TimeManagerFrame = {}
    },
    --Blizzard_TokenUI = {},
    Blizzard_TradeSkillUI = {
        TradeSkillFrame = {}
    },
    Blizzard_TrainerUI = {
        ClassTrainerFrame = {}
    },
    Blizzard_VoidStorageUI = {
        VoidStorageFrame = {"VoidStorageBorderFrameMouseBlockFrame"},
    },
    Blizzard_WarboardUI = {
        WarboardQuestChoiceFrame = {}
    },
    --Blizzard_WarfrontsPartyPoseUI = {},
    Blizzard_WorldMap = {
        WorldMapFrame = {}
    },
}

local frames = {}
function DragEmAll:HookFrames(list)
    for frameName, children in next, list do
        self:HookFrame(frameName, children)
    end
end

function DragEmAll:HookFrame(frameName, children)
    local frame = _G[frameName]
    if not frame then return end

    if type(children) == "string" then
        local parentName = children
        frame = _G[parentName]

        children = frames[parentName]
        tinsert(children, frameName)

        frameName = parentName
    end

    for i, childName in next, children do
        local child = _G[childName] or frame[childName]
        if child then
            child:HookScript("OnMouseDown", function(this)
                FramePoint.OnDragStart(frame)
            end)
            child:HookScript("OnMouseUp", function(this)
                FramePoint.OnDragStop(frame)
            end)
        end
    end

    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(false)
    frame:HookScript("OnDragStart", FramePoint.OnDragStart)
    frame:HookScript("OnDragStop", FramePoint.OnDragStop)

    LibWin.RegisterConfig(frame, self.db.global[frameName])
    frames[frameName] = children
end

local function _UpdateFrames()
    for frameName, children in next, frames do
        local frame = _G[frameName]
        if frame:IsVisible() and not DragEmAll.db.global[frameName].seen then
            LibWin.SavePosition(frame)
            DragEmAll.db.global[frameName].seen = true
        end

        if DragEmAll.db.global[frameName].seen then
            LibWin.RestorePosition(frame)
        end
    end
end
local function UpdateFrames()
    RealUI.TryInCombat(_UpdateFrames)
end

local function ResetFrames()
    local reset
    local left, right, top, bottom
    left = _G.UIParent:GetLeft()
    right = _G.UIParent:GetRight()
    top = _G.UIParent:GetTop()
    bottom = _G.UIParent:GetBottom()

    for frameName, children in next, frames do
        local frame = _G[frameName]
        if frame:IsVisible() then
            if frame:GetLeft() > right then
                reset = true
            end

            if frame:GetRight() < left then
                reset = true
            end

            if frame:GetTop() > top then
                reset = true
            end

            if frame:GetBottom() < bottom then
                reset = true
            end

            if reset then
                frame:ClearAllPoints()
                frame:SetPoint("CENTER")
                _G.print(_G.INSTANCE_RESET_SUCCESS:format(frame:GetName()))
                reset = false
            end
        end
    end
end

function DragEmAll:ADDON_LOADED(event, name)
    local frameList = addonFrames[name]
    if frameList then
        self:HookFrames(frameList)
    end
end

--------------------
-- Initialization --
--------------------
function DragEmAll:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        global = {
            ["**"] = {
                x = 0,
                y = 0,
                point = "TOPLEFT",
                seen = false,
            }
        },
    })

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    RealUI:GetModule("InterfaceTweaks"):AddTweak("dragFrames", {
        name = "DragFrames",
        setEnabled = function(enabled)
            RealUI:SetModuleEnabled(MODNAME, enabled)
        end,
    }, RealUI:GetModuleEnabled(MODNAME))
end

function DragEmAll:OnEnable()
    self:HookFrames(baseFames)

    -- Hook prior loaded addons
    for addon, frameList in next, addonFrames do
        if _G.IsAddOnLoaded(addon) then
            self:HookFrames(frameList)
        end
    end

    -- Making the ColorPickerFrame itself draggable makes interacting with the
    -- color picker widgets difficult, so we need to do something different to
    -- make it movable.
    local ColorPickerFrame = _G.ColorPickerFrame
    ColorPickerFrame:RegisterForDrag()

    local Header = ColorPickerFrame.Header
    Header:HookScript("OnMouseDown", function(this)
        FramePoint.OnDragStart(ColorPickerFrame)
    end)
    Header:HookScript("OnMouseUp", function(this)
        FramePoint.OnDragStop(ColorPickerFrame)
    end)

    _G.hooksecurefunc("ShowUIPanel", UpdateFrames)
    _G.hooksecurefunc("HideUIPanel", UpdateFrames)
    _G.hooksecurefunc("UpdateUIPanelPositions", UpdateFrames)

    self:RegisterEvent("ADDON_LOADED")
    RealUI:RegisterChatCommand("resetFrames", function()
        RealUI.TryInCombat(ResetFrames)
    end)
end

function DragEmAll:OnDisable()
    RealUI:ReloadUIDialog()
end
