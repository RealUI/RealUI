-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text German Localization
-- Author: Mikord
-- German Translation by: Farook, mojosdojo
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't German.
if (GetLocale() ~= "deDE") then return end

-- Local reference for faster access.
local L = MikSBT.translations

-------------------------------------------------------------------------------
-- German localization
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

L.COMMAND_USAGE = {
 "Usage: " .. MikSBT.COMMAND .. " <Befehl> [Parameter]",
 " Befehle:",
 "  " .. L.COMMAND_RESET .. " - Das aktuelle Profil auf Standardwerte zurücksetzen.",
 "  " .. L.COMMAND_DISABLE .. " - Das Addon deaktivieren.",
 "  " .. L.COMMAND_ENABLE .. " - Das Addon aktivieren.",
 "  " .. L.COMMAND_SHOWVER .. " - Die aktuelle Version anzeigen.",
 "  " .. L.COMMAND_HELP .. " - Hilfe anzeigen.",
}


------------------------------
-- Output messages
------------------------------

L.MSG_DISABLE				= "Addon deaktiviert."
L.MSG_ENABLE				= "Addon aktiviert."
L.MSG_PROFILE_RESET			= "Profil zurückgesetzt."
L.MSG_HITS					= "Treffer"
L.MSG_CRIT					= "Krit"
L.MSG_CRITS					= "Krits"
L.MSG_MULTIPLE_TARGETS		= "Mehrere"
L.MSG_READY_NOW				= "verfügbar"


------------------------------
-- Scroll area names
------------------------------

L.MSG_INCOMING			= "Eingehend"
L.MSG_OUTGOING			= "Ausgehend"
L.MSG_NOTIFICATION		= "Benachrichtigung"
L.MSG_STATIC			= "Statisch"


----------------------------------------
-- Master profile event output messages
----------------------------------------

L.MSG_COMBAT					= "Kampf"
L.MSG_DISPEL					= "Dispel"
--L.MSG_CHI_FULL					= "Full Chi"
L.MSG_CP						= "CP"
L.MSG_CP_FULL					= "Alle CP"
L.MSG_HOLY_POWER_FULL			= "Alle Heilige Kraft"
--L.MSG_SHADOW_ORBS_FULL			= "Full Shadow Orbs"
L.MSG_KILLING_BLOW				= "Todesstoß"
L.MSG_TRIGGER_LOW_HEALTH		= "Wenig Gesundheit"
L.MSG_TRIGGER_LOW_MANA			= "Wenig Mana"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "Wenig Begleiter Gesundheit"