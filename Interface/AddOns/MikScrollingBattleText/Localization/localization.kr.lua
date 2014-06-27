-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Korean Localization
-- Author: Mikord
-- Korean Translation by: Slowhand, Fenlis, chkid
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't Korean.
if (GetLocale() ~= "koKR") then return end

-- Local reference for faster access.
local L = MikSBT.translations

-------------------------------------------------------------------------------
-- Korean Localization
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
 ["[WoW] 기본 글꼴"]		= "Fonts\\2002.TTF",
 ["[WoW] 타이틀 글꼴"]		= "Fonts\\2002B.TTF",
 ["[WoW] 데미지 글꼴"]		= "Fonts\\K_Damage.TTF",
}

L.DEFAULT_FONT_NAME = "[WoW] 기본 글꼴"


------------------------------
-- Commands
------------------------------
L.COMMAND_USAGE = {
 "사용법: " .. MikSBT.COMMAND .. " <명령어> [옵션]",
 " 명령어:",
 "  " .. L.COMMAND_RESET .. " - 현재 프로필을 기본 설정으로 초기화합니다.",
 "  " .. L.COMMAND_DISABLE .. " - 애드온의 사용을 중지합니다.",
 "  " .. L.COMMAND_ENABLE .. " - 애드온을 사용합니다.",
 "  " .. L.COMMAND_SHOWVER .. " - 현재 버전을 표시합니다.",
 "  " .. L.COMMAND_HELP .. " - 명령어 사용법을 표시합니다.",
}


------------------------------
-- Output messages
------------------------------

L.MSG_DISABLE				= "애드온의 사용을 중지합니다."
L.MSG_ENABLE				= "애드온을 사용합니다."
L.MSG_PROFILE_RESET			= "프로필이 초기화 되었습니다."
L.MSG_HITS					= "회"
L.MSG_CRIT					= "치명타"
L.MSG_CRITS					= "x치명타"
L.MSG_MULTIPLE_TARGETS		= "다수"
L.MSG_READY_NOW				= "[대기완료]"


------------------------------
-- Scroll area names
------------------------------

L.MSG_INCOMING			= "자신이 받은 메세지"
L.MSG_OUTGOING			= "대상이 받은 메세지"
L.MSG_NOTIFICATION		= "알림 메세지"
L.MSG_STATIC			= "정적 메시지"


----------------------------------------
-- Master profile event output messages
----------------------------------------

L.MSG_COMBAT					= "전투 상태"
L.MSG_DISPEL					= "해제"
--L.MSG_CHI_FULL					= "Full Chi"
L.MSG_CP						= "연계 점수"
L.MSG_CP_FULL					= "마무리 공격"
L.MSG_HOLY_POWER_FULL			= "최대 신성한 힘"
--L.MSG_SHADOW_ORBS_FULL			= "Full Shadow Orbs"
L.MSG_KILLING_BLOW				= "결정타"
L.MSG_TRIGGER_LOW_HEALTH		= "생명력 낮음"
L.MSG_TRIGGER_LOW_MANA			= "마나 낮음"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "소환수 생명력 낮음"
