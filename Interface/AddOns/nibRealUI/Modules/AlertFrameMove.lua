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

function AlertFrameMove:AlertFrame_SetLootWonAnchors(alertAnchor)
	for i = 1, #LOOT_WON_ALERT_FRAMES do
		local frame = LOOT_WON_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:ClearAllPoints()
			frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset);
			alertAnchor = frame
		end
	end
end

function AlertFrameMove:AlertFrame_SetMoneyWonAnchors(alertAnchor)
	for i = 1, #MONEY_WON_ALERT_FRAMES do
		local frame = MONEY_WON_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:ClearAllPoints()
			frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset);
			alertAnchor = frame
		end
	end
end

function AlertFrameMove:AlertFrame_SetAchievementAnchors(alertAnchor)
	if ( AchievementAlertFrame1 ) then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame"..i];
			if ( frame and frame:IsShown() ) then
				frame:ClearAllPoints()
				frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset);
				alertAnchor = frame
			end
		end
	end
end

function AlertFrameMove:AlertFrame_SetCriteriaAnchors(alertAnchor)
	if ( CriteriaAlertFrame1 ) then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["CriteriaAlertFrame"..i];
			if ( frame and frame:IsShown() ) then
				frame:ClearAllPoints()
				frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset);
				alertAnchor = frame
			end
		end
	end
end

function AlertFrameMove:AlertFrame_SetChallengeModeAnchors(alertAnchor)
	local frame = ChallengeModeAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset);
	end
end

function AlertFrameMove:AlertFrame_SetDungeonCompletionAnchors(alertAnchor)
	local frame = DungeonCompletionAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset);
	end
end

function AlertFrameMove:AlertFrame_SetScenarioAnchors(alertAnchor)
	local frame = ScenarioAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset);
	end
end

function AlertFrameMove:AlertFrame_SetGuildChallengeAnchors(alertAnchor)
	local frame = GuildChallengeAlertFrame;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(AFPosition, alertAnchor, AFAnchor, 0, AFYOffset);
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
	self:SecureHook('AlertFrame_SetLootWonAnchors')
	self:SecureHook('AlertFrame_SetMoneyWonAnchors')
	self:SecureHook('AlertFrame_SetAchievementAnchors')
	self:SecureHook('AlertFrame_SetCriteriaAnchors')
	self:SecureHook('AlertFrame_SetChallengeModeAnchors')
	self:SecureHook('AlertFrame_SetDungeonCompletionAnchors')
	self:SecureHook('AlertFrame_SetScenarioAnchors')
	self:SecureHook('AlertFrame_SetGuildChallengeAnchors')
	
	hooksecurefunc(BonusRollFrame, 'SetPoint', BonusRollFrame_SetPoint)
	hooksecurefunc(BonusRollFrame, 'Show', BonusRollFrame_Show)
	
	UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil
end

----------
function AlertFrameMove:OnInitialize()
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function AlertFrameMove:OnEnable()
	self:AlertMovers()
end