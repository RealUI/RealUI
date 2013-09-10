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
	--[[ Tooltip mods by Alza mostly ]]
	ITEM_LEVEL = "|cff00ffffilvl: %d|r" -- Blue color

	if GetLocale() == "enUS" or GetLocale() == "enGB" then
		ITEM_BIND_ON_EQUIP = "BoE"
		ITEM_BIND_ON_PICKUP = "BoP"
		ITEM_BIND_ON_USE = "Bind on use"
		ITEM_CLASSES_ALLOWED = "Class: %s"
		ITEM_CONJURED = "Conjured"
		ITEM_CREATED_BY = "" -- No creator name
		ITEM_LEVEL_AND_MIN = "Level: %d (min: %d)"
		ITEM_LEVEL_RANGE = "Requires level: %d - %d"
		ITEM_LEVEL_RANGE_CURRENT = "Requires level: %d - %d (%d)"
		ITEM_LIMIT_CATEGORY_MULTIPLE = "BoE: %s (%d)"

		if not(IsAddOnLoaded("Pawn")) and not(IsAddOnLoaded("Reforgerade")) and not(REALUI_TOOLTIPSTRINGS_DISABLE) then
			ITEM_MOD_AGILITY = "%c%s Agility"
			ITEM_MOD_AGILITY_SHORT = "Agility"
			ITEM_MOD_ARMOR_PENETRATION_RATING = "ARP +%s"
			ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT = "ARP"
			ITEM_MOD_ATTACK_POWER = "AP +%s"
			ITEM_MOD_BLOCK_RATING = "Block rating +%s"
			ITEM_MOD_BLOCK_RATING_SHORT = "Block rating"
			ITEM_MOD_BLOCK_VALUE = "Block value +%s"
			ITEM_MOD_BLOCK_VALUE_SHORT = "Block value"
			ITEM_MOD_CRIT_MELEE_RATING = "Crit (melee) +%s"
			ITEM_MOD_CRIT_MELEE_RATING_SHORT = "Crit (melee)"
			ITEM_MOD_CRIT_RANGED_RATING = "Crit (ranged) +%s"
			ITEM_MOD_CRIT_RANGED_RATING_SHORT = "Crit (ranged)"
			ITEM_MOD_CRIT_RATING = "Crit +%s"
			ITEM_MOD_CRIT_RATING_SHORT = "Crit"
			ITEM_MOD_CRIT_SPELL_RATING = "Crit (spell) +%s"
			ITEM_MOD_CRIT_SPELL_RATING_SHORT = "Crit (spell)"
			ITEM_MOD_DAMAGE_PER_SECOND_SHORT = "DPS"
			ITEM_MOD_DEFENSE_SKILL_RATING = "Defence +%s"
			ITEM_MOD_DEFENSE_SKILL_RATING_SHORT = "Defence"
			ITEM_MOD_DODGE_RATING = "Dodge +%s"
			ITEM_MOD_DODGE_RATING_SHORT = "Dodge"
			ITEM_MOD_EXPERTISE_RATING = "Expertise +%s"
			ITEM_MOD_EXPERTISE_RATING_SHORT = "Expertise"
			ITEM_MOD_FERAL_ATTACK_POWER = "Feral AP +%s"
			ITEM_MOD_FERAL_ATTACK_POWER_SHORT = "Feral AP"
			ITEM_MOD_HASTE_MELEE_RATING = "Haste (melee) +%s"
			ITEM_MOD_HASTE_MELEE_RATING_SHORT = "Haste (melee)"
			ITEM_MOD_HASTE_RANGED_RATING = "Haste (ranged) +%s"
			ITEM_MOD_HASTE_RANGED_RATING_SHORT = "Haste (ranged)"
			ITEM_MOD_HASTE_RATING = "Haste +%s"
			ITEM_MOD_HASTE_RATING_SHORT = "Haste"
			ITEM_MOD_HASTE_SPELL_RATING = "Haste (spell) +%s"
			ITEM_MOD_HASTE_SPELL_RATING_SHORT = "Haste (spell)"
			ITEM_MOD_HEALTH = "%c%s Health"
			ITEM_MOD_HEALTH_REGEN = "%d Hp5"
			ITEM_MOD_HEALTH_REGEN_SHORT = "Hp5"
			ITEM_MOD_HEALTH_REGENERATION = "%d Hp5"
			ITEM_MOD_HEALTH_REGENERATION_SHORT = "Hp5"
			ITEM_MOD_HIT_MELEE_RATING = "Hit (melee) +%s"
			ITEM_MOD_HIT_MELEE_RATING_SHORT = "Hit (melee)"
			ITEM_MOD_HIT_RANGED_RATING = "Hit (ranged) +%s"
			ITEM_MOD_HIT_RANGED_RATING_SHORT = "Hit (ranged)"
			ITEM_MOD_HIT_RATING = "Hit +%s"
			ITEM_MOD_HIT_RATING_SHORT = "Hit"
			ITEM_MOD_HIT_SPELL_RATING = "Hit (spell) +%s"
			ITEM_MOD_HIT_SPELL_RATING_SHORT = "Hit (spell)"
			ITEM_MOD_HIT_TAKEN_RATING = "Miss +%s"
			ITEM_MOD_HIT_TAKEN_RATING_SHORT = "Miss"
			ITEM_MOD_HIT_TAKEN_SPELL_RATING = "Spell miss +%s"
			ITEM_MOD_HIT_TAKEN_SPELL_RATING_SHORT = "Spell miss"
			ITEM_MOD_HIT_TAKEN_MELEE_RATING = "Melee miss +%s"
			ITEM_MOD_HIT_TAKEN_MELEE_RATING_SHORT = "Melee miss"
			ITEM_MOD_HIT_TAKEN_RANGED_RATING = "Ranged miss +%s"
			ITEM_MOD_HIT_TAKEN_RANGED_RATING_SHORT = "Ranged miss"
			ITEM_MOD_INTELLECT = "%c%s Intellect"
			ITEM_MOD_MANA = "%c%s Mana"
			ITEM_MOD_MANA_REGENERATION = "+%d Mp5"
			ITEM_MOD_MANA_REGENERATION_SHORT = "Mp5"
			ITEM_MOD_MASTERY_RATING = "Mastery +%s"
			ITEM_MOD_MELEE_ATTACK_POWER_SHORT = "AP (melee)"
			ITEM_MOD_PARRY_RATING = "Parry +%s"
			ITEM_MOD_RANGED_ATTACK_POWER = "AP (ranged) +%s"
			ITEM_MOD_RANGED_ATTACK_POWER_SHORT = "AP (ranged)"
			ITEM_MOD_RESILIENCE_RATING = "Resi +%s"
			ITEM_MOD_RESILIENCE_RATING_SHORT = "Resi"
			ITEM_MOD_SPELL_DAMAGE_DONE = "Spellpower +%s"
			ITEM_MOD_SPELL_DAMAGE_DONE_SHORT = "Spellpower"
			ITEM_MOD_SPELL_HEALING_DONE = "Healing +%s"
			ITEM_MOD_SPELL_HEALING_DONE_SHORT = "Healing"
			ITEM_MOD_SPELL_POWER = "Spellpower +%s"
			ITEM_MOD_SPELL_PENETRATION = "Spell Penetration +%s"

			ITEM_RANDOM_ENCHANT = "Random enchant"
			ITEM_SOCKETABLE = "" -- No gem info line
			ITEM_SOCKET_BONUS = "Bonus: %s"
			ITEM_SPELL_TRIGGER_ONPROC = "Proc:"
			EMPTY_SOCKET_RED = "red"
			EMPTY_SOCKET_YELLOW = "yellow"
			EMPTY_SOCKET_BLUE = "blue"
			EMPTY_SOCKET_META = "meta"
			EMPTY_SOCKET_NO_COLOR = "prismatic"
			
			ARMOR_TEMPLATE = "Armor: %s"
			DAMAGE_TEMPLATE = "Damage: %s - %s"
			DPS_TEMPLATE = "%s DPS"
			DURABILITY_TEMPLATE = "Durability: %d/%d"
			SHIELD_BLOCK_TEMPLATE = "Block: %d"
		end
		
		ITEM_OPENABLE = "Open!"
		ITEM_RACES_ALLOWED = "Race: %s"
		ITEM_RESIST_ALL = "%c%d All resistances"
		ITEM_RESIST_SINGLE = "Resist: %c%d %s"
		ITEM_SIGNABLE = "Sign!"
		ITEM_SOLD_COLON = "Sold:"
		ITEM_SPELL_CHARGES = "%d charges"
		ITEM_STARTS_QUEST = "Starts quest"
		ITEM_WRONG_CLASS = "Wrong class!"
		ITEM_UNSELLABLE = "Can't be sold"
		SELL_PRICE = "Price"

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
		-- |cff818181 on roll type
		--[[LOOT_ROLL_WON_NO_SPAM_DE = "|HlootHistory:%d|h[Loot]|h: %s (Disenchant - %d) Won: %s"
		LOOT_ROLL_WON_NO_SPAM_GREED = "|HlootHistory:%d|h[Loot]|h: %s (Greed - %d) Won: %s"
		LOOT_ROLL_WON_NO_SPAM_NEED = "|HlootHistory:%d|h[Loot]|h: %s (Need - %d) Won: %s"
		LOOT_ROLL_YOU_WON_NO_SPAM_DE = "|HlootHistory:%d|h[Loot]|h: You (Disenchant - %d) Won: %s"
		LOOT_ROLL_YOU_WON_NO_SPAM_GREED = "|HlootHistory:%d|h[Loot]|h: You (Greed - %d) Won: %s"
		LOOT_ROLL_YOU_WON_NO_SPAM_NEED = "|HlootHistory:%d|h[Loot]|h: You (Need - %d) Won: %s"]]

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