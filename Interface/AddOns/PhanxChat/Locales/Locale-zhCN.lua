--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
------------------------------------------------------------------------
	Simplified Chinese localization
	See the end of this file for a complete list of translators.
----------------------------------------------------------------------]]

if GetLocale() ~= "zhCN" then return end
local _, PhanxChat = ...
local C, S, L = PhanxChat.ChannelNames, PhanxChat.ShortStrings, PhanxChat.L

------------------------------------------------------------------------
--	Channel Names
--	Must match the default channel names shown in your game client.
------------------------------------------------------------------------

C.Conversation    = "对话"
C.General         = "综合"
C.LocalDefense    = "本地防务"
C.LookingForGroup = "寻求组队"
C.Trade           = "交易"
C.WorldDefense    = "世界防务"

------------------------------------------------------------------------
-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
------------------------------------------------------------------------

S.Conversation    = "话"
S.General         = "综"
S.LocalDefense    = "本"
S.LookingForGroup = "寻"
S.Trade           = "交"
S.WorldDefense    = "世"

S.Guild              = "公"
S.InstanceChat       = "副本"
S.InstanceChatLeader = "副本首"
S.Officer            = "官"
S.Party              = "队"
S.PartyGuide         = "领队"
S.PartyLeader        = "队首"
S.Raid               = "团"
S.RaidLeader         = "领"
S.RaidWarning        = "团警"
S.Say                = "说"
S.WhisperIncoming    = "密自"
S.WhisperOutgoing    = "密往"
S.Yell               = "喊"

S.PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG -- default is ok

------------------------------------------------------------------------
-- Options Panel
------------------------------------------------------------------------

L.All = "所有"
L.Default = "默认"
L.EnableArrows = "输入框中使用方向键"
L.EnableArrows_Desc = "允许在输入框中使用方向键。"
L.EnableResizeEdges = "开启边缘调整"
L.EnableResizeEdges_Desc = "开启聊天框边缘调整，而不只是在右下角调整。"
L.EnableSticky = "保持聊天频道与类型"
L.EnableSticky_Desc = "设定哪一聊天输出频道将被保持。"
L.FadeTime = "渐隐时间"
L.FadeTime_Desc = "设置文本消失时间，设为0将不消失。"
L.FontSize = "字体大小"
L.FontSize_Desc = "为所有聊天框设置字体大小。"
L.FontSize_Note = "注意，这只是链接到暴雪每个单独的聊天框设置的快捷方式。"
L.HideButtons = "隐藏按钮"
L.HideButtons_Desc = "隐藏聊天框菜单和滚动按钮。"
L.HideFlash = "隐藏标签闪烁"
L.HideFlash_Desc = "禁用聊天框收到消息后标签的闪烁效果。"
L.HideNotices = "隐藏警告"
L.HideNotices_Desc = "隐藏聊天框内的警告信息。"
--L.HidePetCombatLog = "Disable pet battle log"
--L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
L.HideRepeats = "屏蔽重复信息"
L.HideRepeats_Desc = "屏蔽公共频道中的重复刷屏信息。"
L.HideTextures = "隐藏额外材质"
L.HideTextures_Desc = "隐藏在3.3.5中为聊天框标签和聊天输入框额外加入的材质。"
L.LinkURLs = "URL链接快速复制"
L.LinkURLs_Desc = "被点击的URL内容将被递交到聊天输入框以便复制。"
L.LockTabs = "隐藏附着标签"
L.LockTabs_Desc = "锁定已附着的聊天标签（按住Shift移动）。"
L.MoveEditBox = "移动聊天输入框"
L.MoveEditBox_Desc = "移动聊天输入框到该信息框顶部。"
L.None = "无"
L.OptionLocked = "此选项已被 PhanxChat 锁定。使用 PhanxChat 的 %q 选项代替。"
L.OptionLockedConditional = "此选项被 PhanxChat 锁定。如果你想改变设置，必须先在 PhanxChat 里禁用 %q 选项。"
L.RemoveRealmNames = "移除服务器名"
L.RemoveRealmNames_Desc = "移除玩家服务器名来缩短名字长度。"
L.ReplaceRealNames = "替换玩家实名"
L.ReplaceRealNames_Desc = "以玩家角色名替换显示战网实名。"
L.ShortenChannelNames = "缩短频道名"
L.ShortenChannelNames_Desc = "缩短频道名和聊天类型名。"
L.ShortenRealNames = "缩短玩家实名"
L.ShortenRealNames_Desc = "如果可行，选择如何去缩短玩家实名。"
L.ShortenRealNames_UseBattleTag = "用战网昵称代替"
L.ShortenRealNames_UseFirstName = "只显示角色名"
L.ShortenRealNames_UseFullName = "保持全名"
L.ShowClassColors = "显示职业颜色"
L.ShowClassColors_Desc = "在所有频道显示职业颜色。"
L.Whisper_BadTarget = "你无法密语此目标！"
L.Whisper_NoTarget = "你无法在没有目标时密语！"
L.WhoStatus_Battlenet = "%s 战网桌面客户端在线。"
L.WhoStatus_Offline = "%s 离线。"
L.WhoStatus_PlayingOtherGame = "%s 在线 %s。"

--[[--------------------------------------------------------------------
	Special thanks to the following people who have contributed
	Simplified Chinese translations for PhanxChat:
	- tss1398383123 @ CurseForge
----------------------------------------------------------------------]]