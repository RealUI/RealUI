-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Localization
-- Author: Mikord
-------------------------------------------------------------------------------

-- Local reference for faster access.
local L = MikSBT.translations

-------------------------------------------------------------------------------
-- English localization (Default)
-------------------------------------------------------------------------------

------------------------------
-- Fonts
------------------------------

L.FONT_FILES = {
 ["MSBT Adventure"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\adventure.ttf",
 ["MSBT Bazooka"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\bazooka.ttf",
 ["MSBT Cooline"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\cooline.ttf",
 ["MSBT Diogenes"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\diogenes.ttf",
 ["MSBT Ginko"]			= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\ginko.ttf",
 ["MSBT Heroic"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\heroic.ttf",
 ["MSBT Porky"]			= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\porky.ttf",
 ["MSBT Talisman"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\talisman.ttf",
 ["MSBT Transformers"]	= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\transformers.ttf",
 ["MSBT Yellowjacket"]	= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\yellowjacket.ttf",
}

L.DEFAULT_FONT_NAME = "MSBT Porky"


------------------------------
-- Commands
------------------------------

L.COMMAND_RESET		= "reset"
L.COMMAND_DISABLE	= "disable"
L.COMMAND_ENABLE	= "enable"
L.COMMAND_SHOWVER	= "version"
L.COMMAND_HELP		= "help"

L.COMMAND_USAGE = {
 "Usage: " .. MikSBT.COMMAND .. " <command> [params]",
 " Commands:",
 "  " .. L.COMMAND_RESET .. " - Reset the current profile to the default settings.",
 "  " .. L.COMMAND_DISABLE .. " - Disables the mod.",
 "  " .. L.COMMAND_ENABLE .. " - Enables the mod.",
 "  " .. L.COMMAND_SHOWVER .. " - Shows the current version.",
 "  " .. L.COMMAND_HELP .. " - Show the command usage.",
}


------------------------------
-- Output messages
------------------------------

L.MSG_DISABLE				= "Mod disabled."
L.MSG_ENABLE				= "Mod enabled."
L.MSG_PROFILE_RESET			= "Profile Reset"
L.MSG_HITS					= "Hits"
L.MSG_CRIT					= "Crit"
L.MSG_CRITS					= "Crits"
L.MSG_MULTIPLE_TARGETS		= "Multiple"
L.MSG_READY_NOW				= "Ready Now"


------------------------------
-- Scroll area names
------------------------------

L.MSG_INCOMING			= "Incoming"
L.MSG_OUTGOING			= "Outgoing"
L.MSG_NOTIFICATION		= "Notification"
L.MSG_STATIC			= "Static"


----------------------------------------
-- Master profile event output messages
----------------------------------------

L.MSG_COMBAT					= "Combat"
L.MSG_DISPEL					= "Dispel"
L.MSG_CP						= "CP"
L.MSG_CHI_FULL					= "Full Chi"
L.MSG_CP_FULL					= "Finish It"
L.MSG_HOLY_POWER_FULL			= "Full Holy Power"
L.MSG_SHADOW_ORBS_FULL			= "Full Shadow Orbs"
L.MSG_KILLING_BLOW				= "Killing Blow"
L.MSG_TRIGGER_LOW_HEALTH		= "Low Health"
L.MSG_TRIGGER_LOW_MANA			= "Low Mana"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "Low Pet Health"