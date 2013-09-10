-- local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
-- local LSM = LibStub("LibSharedMedia-3.0")
-- local db, ndb

-- local Chat = nibRealUI:GetModule("Chat")
-- local MODNAME = "Chat_Opacity"
-- local Chat_Opacity = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")


-- function Chat_Opacity:PLAYER_LOGIN()
-- 	self:HookFCF()
-- end

-- ------------
-- function Chat_Opacity:UpdateFonts()
-- 	self:UpdateTabs(true)
-- end

-- function Chat_Opacity:OnInitialize()
-- 	db = Chat.db.profile
-- 	ndb = nibRealUI.db.profile
	
-- 	self:SetEnabledState(db.modules.opacity.enabled)
-- end

-- function Chat_Opacity:OnEnable() 
-- 	self:RegisterEvent("PLAYER_LOGIN")
-- end