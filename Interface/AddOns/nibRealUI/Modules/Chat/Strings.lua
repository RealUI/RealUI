local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")
local db, ndb

local Chat = nibRealUI:GetModule("Chat")
local MODNAME = "Chat_Strings"
local Chat_Strings = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local _COPPER_AMOUNT
local _SILVER_AMOUNT
local _GOLD_AMOUNT
local _YOU_LOOT_MONEY
local _YOU_LOOT_MONEY_GUILD
local _LOOT_MONEY_SPLIT
local _LOOT_MONEY_SPLIT_GUILD

----------------------
---- CHAT STRINGS ----
----------------------
function Chat_Strings:MAIL_CLOSED()
	self:ChangeStrings()
end

function Chat_Strings:MAIL_SHOW()
	COPPER_AMOUNT = _COPPER_AMOUNT
	SILVER_AMOUNT = _SILVER_AMOUNT
	GOLD_AMOUNT = _GOLD_AMOUNT
end

function Chat_Strings:ChangeStrings()
	if GetLocale() == "enUS" or GetLocale() == "enGB" then
		--[[ Loot mods ]]
		LOOT_ITEM = "%s + %s"
		LOOT_ITEM_MULTIPLE = "%s + % sx%d"
		LOOT_ITEM_SELF = "+ %s"
		LOOT_ITEM_SELF_MULTIPLE = "+ %s x%d"
		LOOT_ITEM_PUSHED_SELF = "+ %s"
		LOOT_ITEM_PUSHED_SELF_MULTIPLE = "+ %s x%d"
		LOOT_MONEY = "|cff00a956+|r |cffffffff%s"
		YOU_LOOT_MONEY = "|cff00a956+|r |cffffffff%s"
		LOOT_MONEY_SPLIT = "|cff00a956+|r |cffffffff%s"
		LOOT_ROLL_ALL_PASSED = "|HlootHistory:%d|h[Loot]|h: All passed on %s"
		LOOT_ROLL_PASSED_AUTO = "%s passed %s (auto)"
		LOOT_ROLL_PASSED_AUTO_FEMALE = "%s passed %s (auto)"
		LOOT_ROLL_PASSED_SELF = "|HlootHistory:%d|h[Loot]|h: passed %s"
		LOOT_ROLL_PASSED_SELF_AUTO = "|HlootHistory:%d|h[Loot]|h: passed %s (auto)"

		--[[ Chat mods ]]
		ACHIEVEMENT_BROADCAST = "%s achieved %s!"
		BN_INLINE_TOAST_FRIEND_OFFLINE = "\124TInterface\\FriendsFrame\\UI-Toast-ToastIcons.tga:16:16:0:0:128:64:2:29:34:61\124t%s has gone |cffff0000offline|r."
		BN_INLINE_TOAST_FRIEND_ONLINE = "\124TInterface\\FriendsFrame\\UI-Toast-ToastIcons.tga:16:16:0:0:128:64:2:29:34:61\124t%s has come |cff00ff00online|r."
		CHAT_BN_WHISPER_GET = "From %s:\32"
		CHAT_BN_WHISPER_INFORM_GET = "To %s:\32"
		CHAT_FLAG_AFK = "[AFK] "
		CHAT_FLAG_DND = "[DND] "
		CHAT_YOU_CHANGED_NOTICE = "|Hchannel:%d|h[%s]|h"
		ERR_FRIEND_OFFLINE_S = "%s has gone |cffff0000offline|r."
		ERR_FRIEND_ONLINE_SS = "|Hplayer:%s|h[%s]|h has come |cff00ff00online|r."
		ERR_SKILL_UP_SI = "%s |cff1eff00%d|r"
		FACTION_STANDING_DECREASED = "%s -%d"
		FACTION_STANDING_INCREASED = "%s +%d"
		FACTION_STANDING_INCREASED_ACH_BONUS = "%s +%d (+%.1f)"
		FACTION_STANDING_INCREASED_ACH_PART = "(+%.1f)"
		FACTION_STANDING_INCREASED_BONUS = "%s + %d (+%.1f RAF)"
		FACTION_STANDING_INCREASED_DOUBLE_BONUS = "%s +%d (+%.1f RAF) (+%.1f)"
		FACTION_STANDING_INCREASED_REFER_PART = "(+%.1f RAF)"
		FACTION_STANDING_INCREASED_REST_PART = "(+%.1f Rested)"

		--[[ Text colours ]]
		NORMAL_QUEST_DISPLAY = "|cffffffff%s|r"
		TRIVIAL_QUEST_DISPLAY = "|cffffffff%s (low level)|r"
		ERR_AUCTION_SOLD_S = "|cff1eff00%s|r |cffffffffsold.|r"
	end

	-- [[ Misc ]]
	COPPER_AMOUNT = "%d\124TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0\124t"
	SILVER_AMOUNT = "%d\124TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0\124t"
	GOLD_AMOUNT = "%d\124TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0\124t"
end

function Chat_Strings:PLAYER_ENTERING_WORLD()
	self:ChangeStrings()
end

function Chat_Strings:VARIABLES_LOADED()
	_COPPER_AMOUNT = COPPER_AMOUNT
	_SILVER_AMOUNT = SILVER_AMOUNT
	_GOLD_AMOUNT = GOLD_AMOUNT
	nibRealUI.goldstr = _GOLD_AMOUNT
	_YOU_LOOT_MONEY = YOU_LOOT_MONEY
	_YOU_LOOT_MONEY_GUILD = YOU_LOOT_MONEY_GUILD
	_LOOT_MONEY_SPLIT = LOOT_MONEY_SPLIT
	_LOOT_MONEY_SPLIT_GUILD = LOOT_MONEY_SPLIT_GUILD
end

------------
function Chat_Strings:OnInitialize()
	db = Chat.db.profile.modules.strings
	ndb = nibRealUI.db.profile
	
	self:SetEnabledState(db.enabled and nibRealUI:GetModuleEnabled("Chat"))
end

function Chat_Strings:OnEnable() 
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("MAIL_SHOW")
	self:RegisterEvent("MAIL_CLOSED")
end