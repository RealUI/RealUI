--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
------------------------------------------------------------------------
	Italian localization
	***
----------------------------------------------------------------------]]

if GetLocale() ~= "itIT" then return end
local _, PhanxChat = ...
local C, S, L = PhanxChat.ChannelNames, PhanxChat.ShortStrings, PhanxChat.L

------------------------------------------------------------------------
--	Channel Names
--	Must match the default channel names shown in your game client.
------------------------------------------------------------------------

C.Conversation    = "Conversazione"
C.General         = "Generale"
C.LocalDefense    = "DifesaLocale"
C.LookingForGroup = "CercaGruppo"
C.Trade           = "Commercio"
C.WorldDefense    = "DifesaMondiale"

------------------------------------------------------------------------
-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
------------------------------------------------------------------------

S.Conversation    = "BN"
S.General         = "G"
S.LocalDefense    = "DL"
S.LookingForGroup = "CG"
S.Trade           = "C"
S.WorldDefense    = "DM"

S.Guild              = "G"
S.InstanceChat       = "i"
S.InstanceChatLeader = "Ci"
S.Officer            = "Uf"
S.Party              = "Gr"
S.PartyGuide         = "GS"
S.PartyLeader        = "CG"
S.Raid               = "I"
S.RaidLeader         = "CI"
S.RaidWarning        = "AI"
S.Say                = "D"
S.WhisperIncoming    = "Sd"
S.WhisperOutgoing    = "Sa"
S.Yell               = "Ur"

S.PET_BATTLE_COMBAT_LOG = "Scontro"

------------------------------------------------------------------------
-- Options Panel
------------------------------------------------------------------------

--L.All = "All"
--L.Default = "Default"
--L.EnableArrows = "Enable arrow keys"
--L.EnableArrows_Desc = "Enable arrow keys in the chat edit box."
--L.EnableResizeEdges = "Enable resize edges"
--L.EnableResizeEdges_Desc = "Enable resize controls at all edges of chat frames, instead of only the bottom right corner."
--L.EnableSticky = "Sticky chat"
--L.EnableSticky_Desc = "Set which chat types should be sticky."
--L.FadeTime = "Fade time"
--L.FadeTime_Desc = "Set the time, in minutes, to wait before fading chat text. A setting of 0 will disable fading."
--L.FontSize = "Font size"
--L.FontSize_Desc = "Set the font size for all chat frames."
--L.FontSize_Note = "Note that this is just a shortcut to configuring each chat frame individually through the Blizzard chat options."
--L.HideButtons = "Hide buttons"
--L.HideButtons_Desc = "Hide the chat frame menu and scroll buttons."
--L.HideFlash = "Hide tab flash"
--L.HideFlash_Desc = "Disable the flashing effect on chat tabs that receive new messages."
--L.HideNotices = "Hide notices"
--L.HideNotices_Desc = "Hide channel notification messages."
--L.HidePetCombatLog = "Disable pet battle log"
--L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
--L.HideRepeats = "Hide repeats"
--L.HideRepeats_Desc = "Hide repeated messages in public channels."
--L.HideTextures = "Hide extra textures"
--L.HideTextures_Desc = "Hide the extra textures on chat tabs and chat edit boxes added in patch 3.3.5."
--L.LinkURLs = "Link URLs"
--L.LinkURLs_Desc = "Transform URLs in chat into clickable links for easy copying."
--L.LockTabs = "Lock docked tabs"
--L.LockTabs_Desc = "Prevent docked chat tabs from being dragged unless the Shift key is down."
--L.MoveEditBox = "Move edit boxes"
--L.MoveEditBox_Desc = "Move chat edit boxes to the top their respective chat frames."
--L.None = "None"
--L.OptionLocked = "This option is locked by PhanxChat. Use the %q option in PhanxChat instead."
--L.OptionLockedConditional = "This option is locked by PhanxChat. If you wish to change it, you must first disable the %q option in PhanxChat."
--L.RemoveRealmNames = "Remove realm names"
--L.RemoveRealmNames_Desc = "Shorten player names by removing realm names."
--L.ReplaceRealNames = "Replace real names"
--L.ReplaceRealNames_Desc = "Replace Real ID names and BattleTags with WoW character names when possible."
--L.ShortenChannelNames = "Short channel names"
--L.ShortenChannelNames_Desc = "Shorten channel names and chat strings."
--L.ShortenRealNames = "Shorten real names"
--L.ShortenRealNames_Desc = "Choose how to shorten Real ID names, if at all."
--L.ShortenRealNames_UseBattleTag = "Replace with BattleTag"
--L.ShortenRealNames_UseFirstName = "Show first name only"
--L.ShortenRealNames_UseFullName = "Keep full name"
--L.ShowClassColors = "Show class colors"
--L.ShowClassColors_Desc = "Show class colors in all channels."
--L.Whisper_BadTarget = "You can't whisper that target!"
--L.Whisper_NoTarget = "You don't have a target to whisper!"
--L.WhoStatus_Battlenet = "%s is currently in the Battle.net Desktop App."
--L.WhoStatus_Offline = "%s is currently offline."
--L.WhoStatus_PlayingOtherGame = "%s is currently playing %s."