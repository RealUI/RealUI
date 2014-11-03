--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
------------------------------------------------------------------------
	Traditional Chinese localization
	See the end of this file for a complete list of translators.
----------------------------------------------------------------------]]

if GetLocale() ~= "zhTW" then return end
local _, PhanxChat = ...
local C, S, L = PhanxChat.ChannelNames, PhanxChat.ShortStrings, PhanxChat.L

------------------------------------------------------------------------
--	Channel Names
--	Must match the default channel names shown in your game client.
------------------------------------------------------------------------

C.Conversation    = "對話"
C.General         = "綜合"
C.LocalDefense    = "本地防務"
C.LookingForGroup = "尋求組隊"
C.Trade           = "交易"
C.WorldDefense    = "世界防務"

------------------------------------------------------------------------
-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
------------------------------------------------------------------------

S.Conversation    = "話"
S.General         = "綜"
S.LocalDefense    = "本"
S.LookingForGroup = "尋"
S.Trade           = "交"
S.WorldDefense    = "世"

S.Guild              = "公"
S.InstanceChat       = "副"
S.InstanceChatLeader = "領"
S.Officer            = "官"
S.Party              = "隊"
S.PartyGuide         = "領"
S.PartyLeader        = "領"
S.Raid               = "團"
S.RaidLeader         = "領"
S.RaidWarning        = "警"
S.Say                = "說"
S.WhisperIncoming    = "自"
S.WhisperOutgoing    = "往"
S.Yell               = "喊"

S.PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG -- default is ok

------------------------------------------------------------------------
-- Options Panel
------------------------------------------------------------------------

L.All = "所有"
L.Default = "預設"
L.EnableArrows = "輸入框中使用方向鍵"
L.EnableArrows_Desc = "允許在輸入框中使用方向鍵。"
L.EnableResizeEdges = "開啟邊緣調整"
L.EnableResizeEdges_Desc = "開啟聊天框邊緣調整，而不只是在右下角調整。"
L.EnableSticky = "保持聊天頻道與類型"
L.EnableSticky_Desc = "設定哪一聊天輸出頻道將被保持。"
L.FadeTime = "漸隱時間"
L.FadeTime_Desc = "設置文字消失時間，以分為單位，設為0將不消失。"
L.FontSize = "字體大小"
L.FontSize_Desc = "為所有聊天框設置字體大小。"
L.FontSize_Note = "注意，這只是連結到暴雪每個單獨的聊天框設置的快捷方式。"
L.HideButtons = "隱藏按鈕"
L.HideButtons_Desc = "隱藏聊天視窗選單和滾動按鈕。"
L.HideFlash = "隱藏標籤閃爍"
L.HideFlash_Desc = "禁用聊天框收到消息後標籤的閃爍效果。"
L.HideNotices = "隱藏警告"
L.HideNotices_Desc = "隱藏聊天框內的警告訊息。"
--L.HidePetCombatLog = "Disable pet battle log"
--L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
L.HideRepeats = "隱藏重複訊息"
L.HideRepeats_Desc = "隱藏公共頻道中的重複刷頻訊息。"
L.HideTextures = "隱藏額外材質"
L.HideTextures_Desc = "隱藏在3.3.5中為聊天框標籤和聊天輸入框額外加入的材質。"
L.LinkURLs = "URL連結快速複製"
L.LinkURLs_Desc = "轉換聊天中的URL為可點擊的連結以便複製。"
L.LockTabs = "鎖定附著標籤"
L.LockTabs_Desc = "鎖定已附著的聊天標籤（按住Shift移動）。"
L.MoveEditBox = "移動聊天輸入框"
L.MoveEditBox_Desc = "移動聊天輸入框到該訊息框頂部。"
L.None = "無"
L.OptionLocked = "此選項已由PhanxChat鎖定。使用PhanxChat中的 %q 選項來替代。"
L.OptionLockedConditional = "此選項已由PhanxChat鎖定。如果你想要改動，你必須先取消PhanxChat中 %q 的選項。"
L.RemoveRealmNames = "移除伺服器名稱"
L.RemoveRealmNames_Desc = "移除伺服器名稱以縮短玩家名稱。"
L.ReplaceRealNames = "替換玩家實名"
L.ReplaceRealNames_Desc = "以玩家角色名取代顯示戰網ID。"
L.ShortenChannelNames = "縮短頻道名"
L.ShortenChannelNames_Desc = "縮短頻道名和聊天類型名。"
L.ShortenRealNames = "縮短玩家實名"
L.ShortenRealNames_Desc = "選擇如何縮短玩家實名，如果是所有。"
L.ShortenRealNames_UseBattleTag = "替換為BattleTag"
L.ShortenRealNames_UseFirstName = "僅顯示姓"
L.ShortenRealNames_UseFullName = "保留全名"
L.ShowClassColors = "顯示職業顏色"
L.ShowClassColors_Desc = "顯示職業顏色在所有頻道。"
L.Whisper_BadTarget = "你無法密語目標! "
L.Whisper_NoTarget = "你沒有目標可密語!"
--L.WhoStatus_Battlenet = "%s is currently in the Battle.net Desktop App."
L.WhoStatus_Offline = "%s 目前為離線。"
L.WhoStatus_PlayingOtherGame = "%s 目前正在玩 %s。"

--[[--------------------------------------------------------------------
	Special thanks to the following people who have contributed
	Traditional Chinese translations for PhanxChat:
	- BNSSNB @ CurseForge
	- yunrong @ CurseForge
----------------------------------------------------------------------]]