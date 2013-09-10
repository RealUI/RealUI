-- Original code from DragEmAll by Emelio
-- http://www.wowace.com/addons/drag-em-all/

local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")

local MODNAME = "DragEmAll"
local DragEmAll = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Based on the frame list from NDragIt by Nemes.
-- These frames are hooked on login.
local frames = {
	-- ["FrameName"] = true (the parent frame should be moved) or false (the frame itself should be moved)

	-- Blizzard Frames
	["SpellBookFrame"] = false,
	["QuestLogFrame"] = false,
	["QuestLogDetailFrame"] = false,
	["FriendsFrame"] = false,
	["KnowledgeBaseFrame"] = true,
	["HelpFrame"] = false,
	["GossipFrame"] = false,
	["MerchantFrame"] = false,
	["MailFrame"] = false,
	["OpenMailFrame"] = false,
	["GuildRegistrarFrame"] = false,
	["DressUpFrame"] = false,
	["TabardFrame"] = false,
	["TaxiFrame"] = false,
	["QuestFrame"] = false,
	["TradeFrame"] = false,
	["LootFrame"] = false,
	["PetStableFrame"] = false,
	["StackSplitFrame"] = false,
	["PetitionFrame"] = false,
	["WorldStateScoreFrame"] = false,
	["BattlefieldFrame"] = false,
	["ArenaFrame"] = false,
	["ItemTextFrame"] = false,
	["GameMenuFrame"] = false,
	["InterfaceOptionsFrame"] = false,
	["MacOptionsFrame"] = false,
	["PetPaperDollFrame"] = true,
	["PetPaperDollFrameCompanionFrame"] = "CharacterFrame",
	["PetPaperDollFramePetFrame"] = "CharacterFrame",
	["PaperDollFrame"] = true,
	["ReputationFrame"] = true,
	["SkillFrame"] = true,
	["PVPFrame"] = not cata, -- changed in cataclysm
	["PVPBattlegroundFrame"] = true,
	["SendMailFrame"] = true,
	["TokenFrame"] = true,
	["InterfaceOptionsFrame"] = false,
	["VideoOptionsFrame"] = false,
	["AudioOptionsFrame"] = false,
	["BankFrame"] = false,
	--["WorldMapTitleButton"] = true,
	-- ["WorldMapPositioningGuide"] = true,
	--["TicketStatusFrame"] = false,
	["StaticPopup1"] = false,
	--["GhostFrame"] = false,
	["EncounterJournal"] = false, -- only in 4.2
	["RaidParentFrame"] = false,
	["TutorialFrame"] = false,
	["MissingLootFrame"] = false,
	["ScrollOfResurrectionSelectionFrame"] = false,

	-- New frames in MoP
	["PVPBannerFrame"] = false,
	["PVEFrame"] = false, -- dungeon finder + challenges
	["GuildInviteFrame"] = false,
	
}

-- Frames provided by load on demand addons, hooked when the addon is loaded.
local lodFrames = {
	-- AddonName = { list of frames, same syntax as above }
	Blizzard_AuctionUI = { ["AuctionFrame"] = false },
	Blizzard_BindingUI = { ["KeyBindingFrame"] = false },
	Blizzard_CraftUI = { ["CraftFrame"] = false },
	Blizzard_GMSurveyUI = { ["GMSurveyFrame"] = false },
	Blizzard_InspectUI = { ["InspectFrame"] = false, ["InspectPVPFrame"] = true, ["InspectTalentFrame"] = true },
	Blizzard_ItemSocketingUI = { ["ItemSocketingFrame"] = false },
	Blizzard_MacroUI = { ["MacroFrame"] = false },
	Blizzard_TalentUI = { ["PlayerTalentFrame"] = false },
	Blizzard_TradeSkillUI = { ["TradeSkillFrame"] = false },
	Blizzard_TrainerUI = { ["ClassTrainerFrame"] = false },
	Blizzard_GuildBankUI = { ["GuildBankFrame"] = false, ["GuildBankEmblemFrame"] = true },
	Blizzard_TimeManager = { ["TimeManagerFrame"] = false },
	Blizzard_AchievementUI = { ["AchievementFrame"] = false, ["AchievementFrameHeader"] = true, ["AchievementFrameCategoriesContainer"] = "AchievementFrame" },
	Blizzard_TokenUI = { ["TokenFrame"] = true },
	Blizzard_ItemSocketingUI = { ["ItemSocketingFrame"] = false },
	--Blizzard_GlyphUI = { ["GlyphFrame"] = true },
	Blizzard_BarbershopUI = { ["BarberShopFrame"] = false },
	Blizzard_Calendar = { ["CalendarFrame"] = false, ["CalendarCreateEventFrame"] = true },
	Blizzard_GuildUI = { ["GuildFrame"] = false, ["GuildRosterFrame"] = true },
	Blizzard_ReforgingUI = { ["ReforgingFrame"] = false, ["ReforgingFrameInvisibleButton"] = true, ["ReforgingFrame.InvisibleButton"] = true },
	Blizzard_ArchaeologyUI = { ["ArchaeologyFrame"] = false },
	Blizzard_LookingForGuildUI = { ["LookingForGuildFrame"] = false },
	Blizzard_VoidStorageUI = { ["VoidStorageFrame"] = false, ["VoidStorageBorderFrameMouseBlockFrame"] = "VoidStorageFrame" },
	Blizzard_ItemAlterationUI = { ["TransmogrifyFrame"] = false },
	Blizzard_EncounterJournal = { ["EncounterJournal"] = false }, -- as of 4.3

	-- New frames in MoP
	Blizzard_PetJournal = { ["PetJournalParent"] = false },
	Blizzard_BlackMarketUI = { ["BlackMarketFrame"] = false }, -- UNTESTED
	Blizzard_ChallengesUI = { ["ChallengesLeaderboardFrame"] = false }, -- UNTESTED
	Blizzard_ItemUpgradeUI = { ["ItemUpgradeFrame"] = false, }, -- UNTESTED

	Blizzard_PVPUI = { ["PVPUIFrame"] = false },
}

local parentFrame = {}
local hooked = {}

local function MouseDownHandler(frame, button)
	frame = parentFrame[frame] or frame
	if frame and button == "LeftButton" then
		frame:StartMoving()
		frame:SetUserPlaced(false)
	end
end

local function MouseUpHandler(frame, button)
	frame = parentFrame[frame] or frame
	if frame and button == "LeftButton" then
		frame:StopMovingOrSizing()
	end
end

function DragEmAll:HookFrames(list)
	for name, child in pairs(list) do
		self:HookFrame(name, child)
	end
end

function DragEmAll:HookFrame(name, moveParent)
	local frame = _G
	local s
	for s in string.gmatch(name, "%w+") do
		if frame then
			frame = frame[s]
		end
	end
	-- check if frame was found
	if frame == _G then
		frame = nil
	end
	
	local parent
	if frame and not hooked[name] then
		if moveParent then
			if type(moveParent) == "string" then
				parent = _G[moveParent]
			else
				parent = frame:GetParent()
			end
			if not parent then
				return
			end
			parentFrame[frame] = parent
		end
		if parent then
			parent:SetMovable(true)
			parent:SetClampedToScreen(false)
		end
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetClampedToScreen(false)
		nibRealUI:HookScript(frame, "OnMouseDown", MouseDownHandler)
		nibRealUI:HookScript(frame, "OnMouseUp", MouseUpHandler)
		hooked[name] = true
	end
end

function DragEmAll:ADDON_LOADED(event, name)
	local frameList = lodFrames[name]
	if frameList then
		self:HookFrames(frameList)
	end
end

function DragEmAll:PLAYER_LOGIN()
	self:HookFrames(frames)
end

--------------------
-- Initialization --
--------------------
function DragEmAll:OnInitialize()
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
end

function DragEmAll:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("ADDON_LOADED")
end