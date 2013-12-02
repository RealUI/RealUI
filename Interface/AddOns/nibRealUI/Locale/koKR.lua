local L = LibStub("AceLocale-3.0"):NewLocale("nibRealUI", "koKR")

if L then

L["Enabled"] = "Enabled"
L["Type /realui"] = "UI의 위치와 설정을 하려면 %s 를 입력하십시오."
L["Combat Lockdown"] = "Combat Lockdown"
L["Layout will change after you leave combat."] = "전투가 종료된 후에 레이아웃이 변경됩니다."
L["Info Line currency tracking will update after UI Reload (/rl)"] = "Info Line currency tracking will update after UI Reload (/rl)"

-- Installation
L["INSTALL"] = "클릭하여 설치합니다"

L["RealUI Mini Patch"] = "RealUI Mini Patch"
L["RealUI's settings have been updated."] = "RealUI의 설정이 변경되었습니다."
L["Do you wish to apply the latest RealUI settings?"] = "Do you wish to apply the latest RealUI settings?"

L["Confirm reset RealUI?\n\nAll user settings will be lost."] = "RealUI의 설정을 초기화 시키시겠습니까?\n\n모든 사용자 설정이 없어질 것입니다."
L["Reload UI now to apply these changes?"] = "변경된 UI를 적용하기 위해서 리로드를 하시겠습니까?"
L["You need to Reload the UI for changes to take effect. Reload Now?"] = "변경된 UI를 적용하기 위해서 리로드를 해야합니다. 리로드하시겠습니까?"

-- Power Mode
L["PowerModeEconomy"] =
[[|cff0099ffRealUI|r|cffffffff: 절약모드 활성화.
이 모드는 기본모드보다 약간 느리게 그리픽 요소를 갱신합니다.
저사양 PC 사용자에게 도움이 될 것입니다.]]

L["PowerModeNormal"] =
[[|cff0099ffRealUI|r|cffffffff: 기본모드 활성화.
보통속도로 그래픽 요소를 갱신합니다.]]

L["PowerModeTurbo"] =
[[|cff0099ffRealUI|r|cffffffff: 터보모드 활성화.
이 모드는 그래픽 요소를 보다 빠르게 갱신하여 UI를 보다 부드럽게 보이게 합니다.
CPU 사용률이 증가할 수 있습니다.]]

-- RealUI Config
L["RealUI Config"] = "RealUI 설정"
L["Position"] = "위치"
L["Positions"] = "위치"
L["Vertical"] = "수직"
L["Horizontal"] = "수평"
L["Width"] = "너비"
L["Height"] = "높이"

L["AddOn Control"] = "애드온 조정"

L["Untick"] = "체크해제"
L["Use"] = "사용"	-- i.e Use General Colors
L["to set"] = "적용"
L["custom colors"] = "개인 색상"

L["Fonts"] = "Fonts"
L["Chat Font Outline"] = "Chat Font Outline"
L["FS:Hybrid"] = "하이브리드"	-- Mixed
L["Use small fonts"] = "작은 글꼴 사용"
L["Use a mix of small and large fonts"] = "작은 글꼴과 큰 글꼴을 섞어서 사용"
L["Use large fonts"] = "큰 글꼴 사용"

L["Latency"] = "Latency"
L["Info Line"] = "정보표기줄"
L["Bars"] = "Bars"	-- Class Color Health "Bars"

L["Link Layouts"] = "레이아웃 연동"
L["Use same settings between DPS/Tank and Healing layouts."] = "레이아웃 구성을 딜러/탱커구성과 힐러구성을 같이 사용합니다."
L["Use Large HuD"] = "Use Large HuD"
L["Increases size of key HuD elements (Unit Frames, etc)."] = "Increases size of key HuD elements (Unit Frames, etc)."
L["Changing HuD size will alter the size of several UI Elements, therefore it is recommended to check UI Element positions once the HuD Size changes have taken effect."] = "Changing HuD size will alter the size of several UI Elements, therefore it is recommended to check UI Element positions once the HuD Size changes have taken effect."

-- 단축키
L["RealUI Control"] = "RealUI 조정"
L["Allow RealUI to control the action bars."] = "단축키영역을 RealUI가 조정할 수 있습니다."
L["Check to allow RealUI to control the Stance Bar's position."] = "Check to allow RealUI to control the Stance Bar's position."
L["Check to allow RealUI to control the Pet Bar's position."] = "Check to allow RealUI to control the Pet Bar's position."
L["Check to allow RealUI to control the Extra Action Button's position."] = "Check to allow RealUI to control the Extra Action Button's position."
L["Move Stance Bar"] = "Move Stance Bar"
L["Move Pet Bar"] = "Move Pet Bar"
L["Move Extra Button"] = "Move Extra Button"
L["Sizes"] = "크기"
L["Buttons"] = "버튼"
L["Padding"] = "여백"
L["Center"] = "중앙"
L["Bottom"] = "바닥"
L["Left"] = "왼쪽"
L["Right"] = "오른쪽"
L["Stance Bar"] = "특성관련 영역"
L["Pet Bar"] = "펫관련 영역"

L["Cannot open RealUI Configuration while in combat."] = "전투 중에는 RealUI 설정창을 열 수 없습니다."
L["Note: Bartender settings"] = "첨언: 고급설정을 사용하여 바텐더 설정창을 열수 있습니다.\n      |cff30d0ffRealUI 조정|r 체크를 해제하여 위치, 크기, 여백, 버튼을 \n      당신이 원하는 설정대로 바꿀 수 있습니다."
L["Hint: Hold down Ctrl to view action bars."] = "조언: 컨트롤키를 누르는 동안에 단축키영역이 보입니다."
L["Note: After changing bar positions..."] = "첨언: 설정을 변경한 후에는 위치설정을 확인하십시오. 설정을 변경한 후에는 \n          UI 요소들이 겹치지 않도록 위치설정을 확인하십시오."

-- 그리드
L["Allow RealUI to control STR position settings."] = "RealUI가 %s의 위치를 조절하도록 합니다."
L["Layout"] = "Layout"
L["Allow RealUI to control STR layout settings."] = "RealUI가 %s의 레이아웃 설정을 조절하도록 합니다."
L["Style"] = "Style"
L["Allow RealUI to style STR."] = "RealUI가 %s 의 스타일을 조절하도록 합니다. \n(UI 재시작이 필요함: /rl)"

L["Horizontal Groups"] = "수평 그룹"
L["Show Pet Frames"] = "Show Pet Frames"
L["Show While Solo"] = "Show While Solo"
L["Note: Grid2 settings"] = "첨언: 고급 설정을 사용하여 그리드2의 설정창을 열수있습니다.\n      |cff30d0ffRealUI 조정|r의 위치, 레이아웃, 스타일의 체크를 해제하여\n      당신이 원하는 설정대로 바꿀 수 있습니다."

L["Element Settings"] = "요소 선택"
L["Choose UI element to configure."] = "설정할 UI 요소를 선택하십시오."
L["(use mouse-wheel for precision adjustment of sliders)"] = "(마우스의 휠을 사용하여 정밀하게 조절할 수 있습니다.)"

L["Reverse Bar"] = "역방향 바"
L["Reverse the direction of the cast bar."] = "시전바의 방향을 역으로 합니다."

L["Create New Tracker"] = "새로운 추적기 생성"
L["Disable Selected Tracker"] = "Disable Selected Tracker"
L["Enable Selected Tracker"] = "Enable Selected Tracker"
L["Are you sure you wish to reset Tracking information to defaults?"] = "추적기 정보를 기본상태로 초기화 시키겠습니까?"
L["Tracker Options"] = "추적기 설정"
L["Choose Tracker type."] = "추적기 종류"
L["Buff"] = "버프"
L["Debuff"] = "디버프"
L["Spell Name or ID"] = "주문 이름 또는 ID"
L["Note: Spell Name or ID must match the spell you wish to track exactly. Capitalization and spaces matter."] = "첨언: 추적하고자 하는 주문과 완전히 일치하는 주문 이름이나 ID를 입력해야 합니다. \n대소문자 및 띄워쓰기에 주의하세요."
L["Static"] = "고정"
L["Static Trackers remain visible and in the same location."] = "고정 추적기는 같은 위치에서 항상보입니다."
L["Min Level (0 = ignore)"] = "최소 레벨(0 = 무시)"
L["Ignore Spec"] = "Ignore Spec"
L["Show tracker regardless of current specialization"] = "Show tracker regardless of current specialization"
L["Cat"] = "야수폼"
L["Bear"] = "곰폼"
L["Moonkin"] = "달빛 야수폼"
L["Human"] = "인간폼"
L["Hide Out-Of-Combat"] = "전투가 아닐 때 숨김"
L["Force this Tracker to hide OOC, even if it's active."] = "활성화가 되더라도 전투 중이 아니라면 안보이게 합니다."
L["Hide Stack Count"] = "중첩 숫자 숨김"
L["Don't show Buff/Debuff stack count on this tracker."] = "버프/디버프의 중첩을 안보이게 합니다."

L["Indicator size"] = "Indicator Size"
L["Indicator padding"] = "Indicator Padding"
L["Inactive indicator opacity"] = "Inactive Indicator Opacity"
L["Show in combat"] = "Show in combat"
L["Show Indicators when you are in combat"] = "Show Indicators when you are in combat"
L["Show w/ hostile"] = "Show w/ hostile"
L["Show Indicators when you have an attackable target"] = "Show Indicators when you have an attackable target"
L["Show in PvE"] = "Show in PvE"
L["Show Indicators when you are in a PvE instance"] = "Show Indicators when you are in a PvE instance"
L["Show in PvP"] = "Show in PvP"
L["Show Indicators when you are in a PvP instance"] = "Show Indicators when you are in a PvP instance"
L["Vertical Cooldown"] = "Vertical Cooldown"
L["Use vertical cooldown indicator instead of spiral"] = "Use vertical cooldown indicator instead of spiral"

L["Stripe Opacity"] = "Stripe Opacity"
L["Window Opacity"] = "Window Opacity"

-- Info Line
L["XP/Rep"] = "경험치/평판"
L["SysInfo"] = "시스템정보"
L["Spec Changer"] = "특성변경"
L["Layout Changer"] = "레이아웃변경"
L["Meter Toggle"] = "미터기"

L["Menu"] = "메뉴"

L["Meters"] = "Meters"

L["Stat"] = "상태"
L["Cur"] = "현재"
L["Max"] = "최고"
L["Min"] = "최저"
L["Avg"] = "평균"

L["In"] = "In"
L["Out"] = "Out"
L["kbps"] = "kbps"
L["ms"] = "ms"
L["FPS"] = "FPS"

L["Date"] = "날짜"
L["Wintergrasp Time Left"] = "겨울손아귀 호수 남은 시간:"
L["No Wintergrasp Time Available"] = "현재 겨울손아귀 호수 불가능"
L["Tol Barad Time Left"] = "톨 바라드 남은 시간:"
L["No Tol Barad Time Available"] = "현재 톨 바라드 불가능"
L["Pending Invites:"] = "Pending Invites:"

L["Layout Changer"] = "레이아웃 변경"
L["Current Layout:"] = "현재 레이아웃:"
L["DPS/Tank"] = "딜러/탱커"
L["Healing"] = "힐러"

L["Meter Toggle"] = "미터기"
L["Active Meters:"] = "활성화된 미터기:"

L["Start"] = "시작"

L["Current"] = "현재"
L["Remaining"] = "남음"

L["Honor Points"] = "HP"
L["Conquest Points"] = "CP"
L["Justice Points"] = "JP"
L["Valor Points"] = "VP"
L["Updated"] = "Upd."
L["To track additional currencies, use the Currency tab in the Player Frame and set desired Currency to 'Show On Backpack'"] = "To track additional currencies, use the Currency tab in the Player Frame and set desired Currency to 'Show On Backpack'"

L["Faction not set"] = "평판이 설정되지 않음"

L["<Click> to switch between"] = "<클릭> 경험치 또는 평판을 표시."
L["XP and Rep display."] = "경험치와 평판 표시."
L["<Click> to switch currency displayed."] = "<클릭> 골드 및 각종 화폐 정보를 표시"
L["<Alt+Click> to erase highlighted character data."] = "<알트키+클릭> 선택된 캐릭터의 데이터를 삭제."
L["<Shift+Click> to reset weekly caps."] = "<쉬프트+클릭> 주간 상한을 초기화."
L["Note: Weekly caps will reset upon loading currency data"] = "첨언: 주간 상한은 주간 상한을 초기한 캐릭터의"
L["on a character whose weekly caps have reset."] = "화폐 데이터를 불러올 때 초기화 됩니다."
L["<Click> to whisper, <Alt+Click> to invite."] = "<클릭> 귓말, <알트+클릭> 초대."

L["Stat Display"] = "스탯 표시"
L["<Spec Click> to change talent specs."] = "<특성 클릭> 특성 변경"
L["<Equip Click> to equip."] = "<장비구성 클릭> 장착."
L["<Equip Ctl+Click> to assign to "] = "<장비구성 컨트롤+클릭> 특성에 할당 : "
L["<Equip Alt+Click> to assign to "] = "<장비구성 알트+클릭> 특성에 할당 : "
L["<Equip Shift+Click> to unassign."] = "<장비구성 쉬프트+클릭> 할당 취소."
L["<Stat Click> to configure."] = "<스탯 클릭> 설정."

L["<Click> to cycle through equipment sets."] = "<클릭> 장비구성을 변경"
L["<Click> to show calendar."] = "<클릭> 달력을 보기."
L["<Shift+Click> to show timer."] = "<쉬프트+클릭> 타이머 보기."
L["<Click> to change layouts."] = "<클릭> 레이아웃 변경하기."
L["<Alt+Click> to change resolution."] = "<알트+클릭> 해상도 변경하기."
L["<Click> to toggle meters."] = "<클릭> 미터기 보기/숨기기"

-- HuD Config
L["Instructions"] = "설명"
L["Load Defaults"] = "초기설정"
L["Show UI Elements"] = "UI 구성 보기"
L["Hide UI Elements"] = "UI 구성 숨기기"
L["HuD Instructions"] = [[
		|cffffa500Step 1:|r UI 구성 요소를 재배치할 때 |cff30ff30UI 구성 보기|r를 사용하면 편리합니다.
		|cffffa500Step 2:|cff30ff30 구성 요소 설정|r을 사용하여 UI 구성 요소의 위치와 크기를 조절할 수 있습니다.
		|cffffa500Step 3:|r 끝낼 때는 |cff30ff30UI 구성 숨기기|r를 클릭합니다.
	]]

-- World Boss Info
L["Galleon"]="Galleon"
L["Sha Of Anger"]="Sha Of Anger"
L["Nalak"]="Nalak"
L["Oondasta"]="Oondasta"
L["Celestials"]="Celestials"
L["Ordos"]="Ordos"

L["World Boss Done"]="\124cff00ff00Done\124r"
L["World Boss Not Done"]="\124cffff0000Not Done\124r"

end