--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
------------------------------------------------------------------------
	German localization
	See the end of this file for a complete list of translators.
----------------------------------------------------------------------]]

if GetLocale() ~= "deDE" then return end
local _, PhanxChat = ...
local C, S, L = PhanxChat.ChannelNames, PhanxChat.ShortStrings, PhanxChat.L

------------------------------------------------------------------------
--	Channel Names
--	Must match the default channel names shown in your game client.
------------------------------------------------------------------------

C.Conversation    = "Chat"
C.General         = "Allgemein"
C.LocalDefense    = "LokaleVerteidigung"
C.LookingForGroup = "SucheNachGruppe"
C.Trade           = "Handel"
C.WorldDefense    = "WeltVerteidigung"

------------------------------------------------------------------------
-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
------------------------------------------------------------------------

S.Conversation     = "C"
S.General          = "A"
S.LocalDefense     = "LV"
S.LookingForGroup  = "LFG"
S.Trade            = "H"
S.WorldDefense     = "GV"

S.Guild              = "G"
S.InstanceChat       = "I"
S.InstanceChatLeader = "IF"
S.Officer            = "O"
S.Party              = "G"
S.PartyGuide         = "GL"
S.PartyLeader        = "GL"
S.Raid               = "SZ"
S.RaidLeader         = "SZL"
S.RaidWarning        = "SZW"
S.Say                = "S"
S.WhisperIncoming    = "W"
S.WhisperOutgoing    = "@"
S.Yell               = "S"

S.PET_BATTLE_COMBAT_LOG = "Kampf"

------------------------------------------------------------------------
--	Options Panel
------------------------------------------------------------------------

L.All = "Alle"
L.Default = "Standard"
L.EnableArrows = "Pfeiltasten aktivieren"
L.EnableArrows_Desc = "Aktiviere die Pfeiltasten im Eingabefeld des Chats."
L.EnableResizeEdges = "Alle Ecken veränderbar"
L.EnableResizeEdges_Desc = "Aktivieren um die Größe des Chatfenster an allen Ecken zu verändern, anstatt nur in der unteren rechten Ecke."
L.EnableSticky = "Channel merken"
L.EnableSticky_Desc = "Festlegen, welche Channels gemerkt werden sollen."
L.FadeTime = "Ausblenden des Textes"
L.FadeTime_Desc = "Zeit bis zum Ausblenden des Textes in Minuten (0 = deaktiviert)."
L.FontSize = "Schriftgröße"
L.FontSize_Desc = "Schriftgröße für alle Chatfenster festlegen."
L.FontSize_Note = "Beachte, dass dies nur eine Kurzform zum Konfigurieren jedes einzelne Chatfenster durch die Blizzard Chatoptionen ist."
L.HideButtons = "Buttons verstecken"
L.HideButtons_Desc = "Verstecke das Chat Menü und die Scroll Buttons."
L.HideFlash = "Blinken der Tabs verhindern"
L.HideFlash_Desc = "Deaktiviere das Blinken der Chat Tabs, bei dennen eine neue Nachricht erhalten wurde."
L.HideNotices = "Meldungen verhindern"
L.HideNotices_Desc = "Channel-Meldungen unterdrücken"
L.HidePetCombatLog = "Haustierkampflog deactivieren"
L.HidePetCombatLog_Desc = "Verhindere, dass ein neues Kampflog-Fenster für Haustierkämpfe geöffnet wird."
L.HideRepeats = "Wiederholungen verhindern"
L.HideRepeats_Desc = "Unterdrücke Nachrichten die in öffentlichen Channels wiederholt werden."
L.HideTextures = "Extra Texturen verstecken"
L.HideTextures_Desc = "Verstecke die Extra-Texturen der Chat Tabs und dem Chat Eingabefeld, die in Patch 3.3.5 hinzugefügt wurden."
L.LinkURLs = "URLs verlinken"
L.LinkURLs_Desc = "URLs im Chat für einfaches Kopieren anklickbar machen."
L.LockTabs = "Tabs sperren"
L.LockTabs_Desc = "Verhindert, dass fixierte Tabs verschoben werden. Zum Verschieben die ALT-Taste gedrückt halten."
L.MoveEditBox = "Eingabefeld verschieben"
L.MoveEditBox_Desc = "Das Eingabefeld über dem Chatfenster anzeigen."
L.None = "Keine"
L.OptionLocked = "Diese Option wurde von PhanxChat gesperrt. Benutze die %q Option in PhanxChat stattdessen."
L.OptionLockedConditional = "Diese Option ist in PhanxChat gesperrt. Wenn du sie ändern möchtest, musst du zunächst die Option %q in PhanxChat deaktivieren."
L.RemoveRealmNames = "Servernamen entfernen"
L.RemoveRealmNames_Desc = "Kürze die Spielernamen, indem der Servername entfernt werden."
L.ReplaceRealNames = "Echte Namen ersetzen"
L.ReplaceRealNames_Desc = "Ersetzt die echten Namen mit den Charakternamen."
L.ShortenChannelNames = "Channelnamen abkürzen"
L.ShortenChannelNames_Desc = "Abkürzen der Channelnamen und Chat-Bezeichnungen."
L.ShortenRealNames = "Echter Namen abkürzen"
L.ShortenRealNames_Desc = "Wählen, um Real ID Namen abzukürzen."
L.ShortenRealNames_UseBattleTag = "Ersetzt mit BattleTag"
L.ShortenRealNames_UseFirstName = "Anzeigt nur die Vornamen "
L.ShortenRealNames_UseFullName = "Erhaltet der volle Name"
L.ShowClassColors = "Klassenfarben anzeigen"
L.ShowClassColors_Desc = "Klassenfarben in allen Chatkanälen anzeigen."
L.Whisper_BadTarget = "Du kannst dieses Ziel nicht anflüstern!"
L.Whisper_NoTarget = "Du hast kein Ziel zum anflüstern!"
L.WhoStatus_Battlenet = "%s ist zur Zeit in der Battle.net-Software."
L.WhoStatus_Offline = "%s ist zur Zeit offline."
L.WhoStatus_PlayingOtherGame = "%s spielt zur Zeit %s."

--[[--------------------------------------------------------------------
	Special thanks to the following people who have contributed
	German translations for PhanxChat:
	- ac3r @ WoWInterface
	- bigx2 @ CurseForge
	- staratnight @ CurseForge
----------------------------------------------------------------------]]