--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
------------------------------------------------------------------------
	Korean localization
	See the end of this file for a complete list of translators.
----------------------------------------------------------------------]]

if GetLocale() ~= "koKR" then return end
local _, PhanxChat = ...
local C, S, L = PhanxChat.ChannelNames, PhanxChat.ShortStrings, PhanxChat.L

------------------------------------------------------------------------
--	Channel Names
--	Must match the default channel names shown in your game client.
------------------------------------------------------------------------

C.Conversation    = "대화"
C.General         = "공개"
C.LocalDefense    = "수비"
C.LookingForGroup = "파티찾기"
C.Trade           = "거래"
C.WorldDefense    = "전쟁"

------------------------------------------------------------------------
-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
------------------------------------------------------------------------

S.Conversation    = "대화"
S.General         = "공"
S.LocalDefense    = "수"
S.LookingForGroup = "파찾"
S.Trade           = "거"
S.WorldDefense    = "쟁"

S.Guild              = "길"
S.InstanceChat       = "인던"
S.InstanceChatLeader = "인던장"
S.Officer            = "관"
S.Party              = "파"
S.PartyGuide         = "파장"
S.PartyLeader        = "파장"
S.Raid               = "공"
S.RaidLeader         = "공대"
S.RaidWarning        = "공경"
S.Say                = "일"
S.WhisperIncoming    = "귓받"
S.WhisperOutgoing    = "귓전"
S.Yell               = "외"

S.PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG -- default is ok

------------------------------------------------------------------------
-- Options Panel
------------------------------------------------------------------------

L.All = "모두"
L.Default = "기본값"
L.EnableArrows = "화살표 키 활성화"
L.EnableArrows_Desc = "대화 입력 박스에서 화살표 키를 활성화합니다."
L.EnableResizeEdges = "구석 크기 조절 활성화"
L.EnableResizeEdges_Desc = "하단 오른쪽 모서리에 한정 된 것이 아닌, 모든 대화창 구석에서의 크기 조절을 활성화합니다."
L.EnableSticky = "채널 고정"
L.EnableSticky_Desc = "어떤 유형의 채널을 고정할 것인지를 설정합니다."
L.FadeTime = "사라짐 시간"
L.FadeTime_Desc = "대화 메시지가 사라지기 전에 기다려야 할 분단위 시간을 설정합니다. 이것을 0으로 설정하면 사라짐 기능을 비활성화하게 됩니다."
L.FontSize = "글꼴 크기"
L.FontSize_Desc = "대화창 모두에 적용할 글꼴 크기를 설정합니다."
L.FontSize_Note = "이것은 블리자드 대화창 옵션을 통해 각각의 대화창을 개별적으로 설정하기 위한 하나의 지름길이란 점에 유의하십시요."
L.HideButtons = "버튼 숨김"
L.HideButtons_Desc = "대화창 메뉴와 스크롤 버튼을 숨깁니다."
L.HideFlash = "탭 번쩍임 숨김"
L.HideFlash_Desc = "새로운 메시지를 받은 경우에 대화창 탭에서의 번쩍임 효과를 비활성화합니다."
L.HideNotices = "알림 메시지 숨김"
L.HideNotices_Desc = "채널 알림 메시지를 숨깁니다."
--L.HidePetCombatLog = "Disable pet battle log"
--L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
L.HideRepeats = "반복 메시지 숨김"
L.HideRepeats_Desc = "공용 채널에서 반복되는 메시지를 숨깁니다."
L.HideTextures = "별도의 텍스쳐 숨김"
L.HideTextures_Desc = "3.3.5. 패치에서 대화창 탭과 편집 박스에 추가된 별도의 텍스쳐를 숨깁니다."
L.LinkURLs = "URL 링크"
L.LinkURLs_Desc = "대화 메시지에서 쉬운 복사를 위해 클릭이 가능한 링크로 URL을 변환합니다."
L.LockTabs = "고정된 탭 잠금"
L.LockTabs_Desc = "고정된 대화창 탭을 Shift 키를 누르지 않고도 잡아 끌 수 있는 것을 방지합니다."
L.MoveEditBox = "대화 입력 박스 이동"
L.MoveEditBox_Desc = "대화 입력 박스를 그것의 각각의 대화창의 상단으로 이동합니다."
L.None = "없음"
--L.OptionLocked = "This option is locked by PhanxChat. Use the %q option in PhanxChat instead."
--L.OptionLockedConditional = "This option is locked by PhanxChat. If you wish to change it, you must first disable the %q option in PhanxChat."
--L.RemoveRealmNames = "Remove realm names"
--L.RemoveRealmNames_Desc = "Shorten player names by removing realm names."
L.ReplaceRealNames = "서버 이름 대체"
L.ReplaceRealNames_Desc = "캐릭터 이름으로 실제 ID 이름을 대체합니다."
L.ShortenChannelNames = "채널 이름 줄임"
L.ShortenChannelNames_Desc = "채널 이름과 대화 구문열을 줄입니다."
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

--[[--------------------------------------------------------------------
	Special thanks to the following people who have contributed
	Korean translations for PhanxChat:
	- talkswind @ Curse
----------------------------------------------------------------------]]