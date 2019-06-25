local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local db

local Chat = RealUI:GetModule("Chat")

local MODNAME = "Chat_Opacity"
local Chat_Opacity = RealUI:NewModule(MODNAME, "AceEvent-3.0")

function Chat_Opacity:UpdateAlphas()
	-- Set alphas
	_G.CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	_G.CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	_G.CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1

	_G.CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
	_G.CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.75
	_G.CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1

	_G.CHAT_TAB_SHOW_DELAY = 0.2
	_G.CHAT_TAB_HIDE_DELAY = 0.2
	_G.CHAT_FRAME_FADE_TIME = 0.1
	_G.CHAT_FRAME_FADE_OUT_TIME = 0.5

	for i = 1, 10 do
		_G.FCFTab_UpdateAlpha(_G["ChatFrame"..i])
	end

	_G.DEFAULT_CHATFRAME_ALPHA = 0

	_G.GENERAL_CHAT_DOCK.overflowButton:SetAlpha(_G.CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA)
end

------------
function Chat_Opacity:RefreshMod()
    db = Chat.db.profile.modules.opacity
    if db.enabled then
        self:UpdateAlphas()
    end
end

function Chat_Opacity:OnInitialize()
	db = Chat.db.profile.modules.opacity

	self:SetEnabledState(db.enabled and RealUI:GetModuleEnabled("Chat"))
end

function Chat_Opacity:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN", "UpdateAlphas")
end
