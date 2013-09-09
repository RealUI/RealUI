local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")
local db, ndb

local Chat = nibRealUI:GetModule("Chat")
local MODNAME = "Chat_Opacity"
local Chat_Opacity = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

function Chat_Opacity:UpdateAlphas()
	-- Set alphas
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1
	
	CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.75
	CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
	
	CHAT_TAB_SHOW_DELAY = 0.2
	CHAT_TAB_HIDE_DELAY = 0.2
	CHAT_FRAME_FADE_TIME = 0.1
	CHAT_FRAME_FADE_OUT_TIME = 0.5
	
	for i = 1, 10 do
		FCFTab_UpdateAlpha(_G["ChatFrame"..i])
	end
	
	DEFAULT_CHATFRAME_ALPHA = 0

	GENERAL_CHAT_DOCK.overflowButton:SetAlpha(CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA)
end

function Chat_Opacity:PLAYER_LOGIN()
	self:UpdateAlphas()
end

------------
function Chat_Opacity:OnInitialize()
	db = Chat.db.profile.modules.opacity
	ndb = nibRealUI.db.profile
	
	self:SetEnabledState(db.enabled and nibRealUI:GetModuleEnabled("Chat"))
end

function Chat_Opacity:OnEnable() 
	self:RegisterEvent("PLAYER_LOGIN")
end