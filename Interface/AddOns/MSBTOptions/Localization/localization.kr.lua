-------------------------------------------------------------------------------
-- Title: MSBT Options Korean Localization
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
-- Interface messages
------------------------------

L.MSG_CUSTOM_FONTS					= "사용자 글꼴"
L.MSG_INVALID_CUSTOM_FONT_NAME		= "잘못된 글꼴 이름."
L.MSG_FONT_NAME_ALREADY_EXISTS		= "글꼴 이름이 이미 존재합니다."
L.MSG_INVALID_CUSTOM_FONT_PATH		= "글꼴 경로가 .ttf 파일을 가리켜야 합니다."
--L.MSG_UNABLE_TO_SET_FONT			= "Unable to set specified font." 
--L.MSG_TESTING_FONT			= "Testing the specified font for validity..."
L.MSG_CUSTOM_SOUNDS					= "사용자 소리"
L.MSG_INVALID_CUSTOM_SOUND_NAME		= "잘못된 소리 이름."
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "소리 이름이 이미 존재합니다."
L.MSG_NEW_PROFILE					= "새로운 프로필"
L.MSG_PROFILE_ALREADY_EXISTS		= "프로필이 이미 존재합니다."
L.MSG_INVALID_PROFILE_NAME			= "허용되지 않는 프로필 이름입니다."
L.MSG_NEW_SCROLL_AREA				= "새로운 스크롤 영역"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "스크롤 영역 이름이 이미 존재합니다."
L.MSG_INVALID_SCROLL_AREA_NAME		= "허용되지 않는 스크롤 영역 이름입니다."
L.MSG_ACKNOWLEDGE_TEXT				= "이 동작을 수행 하시겠습니까?"
L.MSG_NORMAL_PREVIEW_TEXT			= "기본"
L.MSG_INVALID_SOUND_FILE			= "효과음은 .ogg 파일이어야 합니다."
L.MSG_NEW_TRIGGER					= "새로운 트리거"
L.MSG_TRIGGER_CLASSES				= "직업 트리거"
L.MSG_MAIN_EVENTS					= "메인 이벤트"
L.MSG_TRIGGER_EXCEPTIONS			= "트리거 예외"
L.MSG_EVENT_CONDITIONS				= "이벤트 조건"
L.MSG_DISPLAY_QUALITY				= "이 품질의 아이템을 위한 알림을 표시합니다."
L.MSG_SKILLS						= "기술"
L.MSG_SKILL_ALREADY_EXISTS			= "기술 이름이 이미 존재합니다."
L.MSG_INVALID_SKILL_NAME			= "허용되지 않는 기술 이름입니다."
L.MSG_HOSTILE						= "적대적"
L.MSG_ANY							= "모두"
L.MSG_CONDITION						= "조건"
L.MSG_CONDITIONS					= "조건 (복수)"
L.MSG_ITEM_QUALITIES				= "아이템 품질"
L.MSG_ITEMS							= "아이템"
L.MSG_ITEM_ALREADY_EXISTS			= "아이템 이름이 이미 존재합니다."
L.MSG_INVALID_ITEM_NAME				= "잘못된 아이템 이름."


------------------------------
-- Interface tabs
------------------------------

obj = L.TABS
obj["customMedia"]	= { label="사용자 미디어", tooltip="사용자 미디어를 관리하기 위한 설정을 표시합니다."}
obj["general"] = { label="일반", tooltip="전반적인 설정을 표시합니다."}
obj["scrollAreas"] = { label="스크롤 영역", tooltip="스크롤 영역의 생성, 삭제, 배치에 관한 설정을 표시합니다.\n\n더 많은 정보를 얻으려면 아이콘 버튼에 마우스 커서를 올리세요."}
obj["events"] = { label="이벤트", tooltip="이벤트에 관한 설정을 표시합니다.\n\n더 많은 정보를 얻으려면 아이콘 버튼에 마우스 커서를 올리세요."}
obj["triggers"] = { label="트리거", tooltip="트리거 시스템에 관한 설정을 표시합니다.\n\n더 많은 정보를 얻으려면 아이콘 버튼에 마우스 커서를 올리세요."}
obj["spamControl"] = { label="스팸 메시지 설정", tooltip="스팸 메시지 조정에 관한 설정을 표시합니다."}
obj["cooldowns"] = { label="재사용 대기시간", tooltip="재사용 대기시간 알림에 관한 설정을 표시합니다.."}
obj["lootAlerts"]	= { label="획득 알림", tooltip="전리품 획득 안내에 대한 설정을 표시합니다."}
obj["skillIcons"] = { label="기술 아이콘", tooltip="기술 아이콘에 관한 설정을 표시합니다."}


------------------------------
-- Interface checkboxes
------------------------------

obj = L.CHECKBOXES
obj["enableMSBT"]				= { label="Mik's Scrolling Battle Text (MSBT) 사용", tooltip="MSBT를 사용합니다."}
obj["stickyCrits"]				= { label="치명타 고정", tooltip="치명타를 고정 스타일로 표시합니다."}
obj["enableSounds"]				= { label="효과음 사용", tooltip="이벤트와 트리거에 지정된 효과음을 재생합니다."}
obj["textShadowing"]			= { label="문자 그림자", tooltip="글꼴을 또렷하게 개선하도록 문자에 그림자 효과를 적용합니다."}
obj["colorPartialEffects"]		= { label="부분 속성 색상", tooltip="부분 속성을 선택한 색상으로 표시합니다."}
obj["crushing"]					= { label="강타", tooltip="강타를 표시합니다."}
obj["glancing"]					= { label="비껴맞음", tooltip="비껴맞음을 표시합니다."}
obj["absorb"]					= { label="흡수", tooltip="흡수량을 표시합니다."}
obj["block"]					= { label="방어", tooltip="방어량을 표시합니다."}
obj["resist"]					= { label="저항", tooltip="부분 저항 피해량을 표시합니다."}
obj["vulnerability"]			= { label="약점 보너스", tooltip="약점 보너스를 표시합니다."}
obj["overheal"]					= { label="초과 치유", tooltip="초과 치유량을 표시합니다."}
obj["overkill"]					= { label="초과 피해", tooltip="초과 피해량을 표시합니다."}
obj["colorDamageAmounts"]		= { label="피해량 속성 색상", tooltip="피해량 속성을 선택한 색상으로 표시합니다."}
obj["colorDamageEntry"]			= { tooltip="이 피해량 속성에 대한 색상을 활성화 합니다."}
obj["colorUnitNames"]			= { label="유닛 이름 색상", tooltip="유닛 이름을 지정한 직업 색상으로 표시합니다."}
obj["colorClassEntry"]			= { tooltip="이 직업의 색상을 활성화 합니다."}
obj["enableScrollArea"]			= { tooltip="이 스크롤 영역을 활성화 합니다."}
obj["inheritField"]				= { label="상속", tooltip="이 항목 값을 상속합니다. 체크를 하지 않으면 무시됩니다."}
obj["hideSkillIcons"]			= { label="아이콘 숨김", tooltip="이 스크롤 영역 안에 아이콘을 표시하지 않습니다."}
obj["stickyEvent"]				= { label="항상 고정", tooltip="항상 고정 스타일로 이벤트를 표시합니다."}
obj["enableTrigger"]			= { tooltip="트리거를 활성화합니다."}
obj["allPowerGains"]			= { label="모든 마력 (마나/분노 등) 획득", tooltip="전투 로그로 나타나지 않는 것을 포함한 모든 마력 (마나, 분노, 기력, 룬 마력) 획득을 표시합니다..\n\n주의: 이 옵션은 마력 표시 기준 및 출력시간 설정을 무시하므로 원치 않는 메시지를 많이 표시할수 있습니다.\n\n[비 추천]"}
obj["abbreviateSkills"]			= { label="짧은 기술 이름", tooltip="기술 이름을 짧게 표시해줍니다(영문).\n\n이 설정은 %sl 이벤트 코드를 사용한 이벤트에서 무시되어집니다."}
obj["mergeSwings"]				= { label="타격 병합", tooltip="짧은 시간 내에 가한 일반 근접딜러 타격을 병합합니다."}
--obj["shortenNumbers"]			= { label="Shorten Numbers", tooltip="Display numbers in an abbreviated format (example: 32765 -> 33k)."}
--obj["groupNumbers"]				= { label="Group By Thousands", tooltip="Display numbers grouped by thousands (example: 32765 -> 32,765)."}
obj["hideSkills"]				= { label="기술 이름 숨김", tooltip="받은, 대상이 받은 이벤트에서 기술 이름을 표시하지 않습니다.\n\n이 옵션을 사용하면 %s 이벤트 코드를 무시하므로 이벤트에 대한 사용자 설정이 무시되어질 것입니다."}
obj["hideNames"]				= { label="유닛 이름 숨김", tooltip="받은, 대상이 받은 이벤트에서 유닛 이름을 표시하지 않는다.\n\n이 옵션을 사용하면 %n 이벤트 코드를 무시하므로 이벤트에 대한 사용자 설정이 무시되어질 것입니다."}
obj["hideFullOverheals"]		= { label="최대 초과치유 숨김", tooltip="0의 치유량 효과를 가진 치유는 표시하지 않습니다."}
obj["hideFullHoTOverheals"]		= { label="최대 순간 초과치유 숨김", tooltip="0의 치유량 효과를 가진 시간이 지난 치유는 표시하지 않습니다."}
obj["hideMergeTrailer"]			= { label="요약 병합 숨김", tooltip="적중 및 치명타로 병합된 이벤트 마지막에 특정한 숫자 요약을 표시하지 않습니다."}
obj["allClasses"]				= { label="모든 클래스"}
obj["enablePlayerCooldowns"]	= { label="플레이어 재사용 대기시간", tooltip="재사용 대기시간이 종료되면 알림 메세지를 표시합니다."}
obj["enablePetCooldowns"]		= { label="소환수 재사용 대기시간", tooltip="소환수의 재사용 대기시간이 종료되면 알림 메세지를 표시합니다."}
--obj["enableItemCooldowns"]		= { label="Item Cooldowns", tooltip="Display notifications when item cooldowns complete."}
obj["lootedItems"]				= { label="획득한 아이템", tooltip="아이템을 획득했을때 알림 메세지를 표시합니다."}
obj["moneyGains"]				= { label="금전 획득", tooltip="당신의 금전 획득 사용."}
obj["alwaysShowQuestItems"]		= { label="퀘스트 아이템 항상 표시", tooltip="선택된 품질에 관계없이 퀘스트 아이템을 항상 표시합니다."}
obj["enableIcons"]				= { label="기술 아이콘 사용", tooltip="이벤트에 사용 가능한 기술 아이콘이 있을때 아이콘을 표시합니다."}
obj["exclusiveSkills"]			= { label="아이콘이 없을때 기술 이름만 사용", tooltip="사용 가능한 아이콘이 없을때 기술 이름만 표시합니다."}


------------------------------
-- Interface dropdowns
------------------------------

obj = L.DROPDOWNS
obj["profile"]				= { label="현재 프로필:", tooltip="현재 프로필을 설정합니다."}
obj["normalFont"]			= { label="보통 글꼴:", tooltip="치명타가 아닐때 사용할 글꼴을 설정합니다."}
obj["critFont"]				= { label="치명타 글꼴:", tooltip="치명타에 사용할 글꼴을 설정합니다."}
obj["normalOutline"]		= { label="보통 외곽선:", tooltip="치명타가 아닐때 사용할 글꼴의 외곽선을 설정합니다"}
obj["critOutline"]			= { label="치명타 외곽선:", tooltip="치명타에 사용할 글꼴의 외곽선을 설정합니다."}
obj["scrollArea"]			= { label="스크롤 영역:", tooltip="설정할 스크롤 영역을 선택합니다."}
obj["sound"]				= { label="효과음:", tooltip="이벤트 발생 시 재생할 효과음을 선택하세요."}
obj["animationStyle"]		= { label="애니메이션 유형:", tooltip="스크롤 영역에 고정되지 않는 애니매이션 유형."}
obj["stickyAnimationStyle"]	= { label="고정 형태:", tooltip="스크롤 영역에 고정된 애니매이션 유형."}
obj["direction"]			= { label="방향:", tooltip="애니메이션의 방향."}
obj["behavior"]				= { label="움직임:", tooltip="애니메이션의 움직임."}
obj["textAlign"]			= { label="텍스트 정렬:", tooltip="애니메이션의 텍스트 정렬."}
obj["iconAlign"]			= { label="아이콘 정렬:", tooltip="문자와 관련된 기술 아이콘의 정렬."}
obj["eventCategory"]		= { label="이벤트 분류:", tooltip="설정하려는 이벤트 분류."}
obj["outputScrollArea"]		= { label="출력 스크롤 영역:", tooltip="출력에 사용할 스크롤 영역을 선택합니다."}
obj["mainEvent"]			= { label="메인 이벤트:"}
obj["triggerCondition"]		= { label="조건:", tooltip="판별할 조건."}
obj["triggerRelation"]		= { label="관계:"}
obj["triggerParameter"]		= { label="매개변수 (parameter):"}


------------------------------
-- Interface buttons
------------------------------

obj = L.BUTTONS
obj["addCustomFont"]			= { label="글꼴 추가", tooltip="사용할 수 있는 글꼴의 목록에 사용자 글꼴을 추가합니다.\n\n주의: 와우가 시작됨 *이전에* 글꼴 파일이 대상의 위치에 존재해야합니다.\n\n문제가 발생되지 않도록 하려면 글꼴은 MikScrollingBattleText\\Fonts 폴더에 넣어두는 것이 좋습니다."}
obj["addCustomSound"]			= { label="소리 추가", tooltip="사용할 수 있는 소리의 목록에 사용자 소리을 추가합니다.\n\n주의: 와우가 시작됨 *이전에* 소리 파일이 대상의 위치에 존재해야합니다.\n\n문제가 발생되지 않도록 하려면 글꼴은 MikScrollingBattleText\\Sounds 폴더에 넣어두는 것이 좋습니다."}
obj["editCustomFont"]			= { tooltip="클릭하여 사용자 글꼴을 편집합니다."}
obj["deleteCustomFont"]			= { tooltip="클릭하여 MSBT로부터 사용자 글꼴을 제거합니다."}
obj["editCustomSound"]			= { tooltip="클릭하여 사용자 소리를 편집합니다."}
obj["deleteCustomSound"]		= { tooltip="클릭하여 MSBT로부터 사용자 소리를 제거합니다."}
obj["copyProfile"]				= { label="프로필 복사", tooltip="명시된 이름의 새 프로필로 프로필을 복사합니다."}
obj["resetProfile"]				= { label="프로필 초기화", tooltip="기본 설정으로 프로필을 초기화합니다."}
obj["deleteProfile"]			= { label="프로필 삭제", tooltip="프로필을 삭제합니다."}
obj["masterFont"]				= { label="주 글꼴 설정", tooltip="모든 스크롤 영역과 이벤트에 상속 적용될(무시되지 않을 경우) 주 글꼴을 설정합니다."}
obj["partialEffects"]			= { label="부분 효과", tooltip="색상으로 표시할 부분 효과를 설정합니다."}
obj["damageColors"]				= { label="피해량 속성 색상", tooltip="피해량 속성에 따른 색상 및 사용 유무를 설정합니다."}
obj["classColors"]				= { label="직업 색상", tooltip="자신의 직업 및 각 직업에 대해 어떤 색상을 사용할 지에 대해 유닛 이름의 색상 코드를 설정합니다." }
obj["inputOkay"]				= { label=OKAY, tooltip="입력을 확인합니다."}
obj["inputCancel"]				= { label=CANCEL, tooltip="입력을 취소합니다."}
obj["genericSave"]				= { label=SAVE, tooltip="변경사항을 저장합니다."}
obj["genericCancel"]			= { label=CANCEL, tooltip="변경사항을 취소합니다."}
obj["addScrollArea"]			= { label="스크롤 영역 추가", tooltip="이벤트와 트리거를 지정할 수 있는 새 스크롤 영역을 추가합니다."}
obj["configScrollAreas"]		= { label="스크롤 영역 배치", tooltip="기본 및 고정 애니메이션 유형, 텍스트 정렬, 스크롤 넓이/높이, 스크롤 영역의 위치를 설정합니다."}
obj["editScrollAreaName"]		= { tooltip="스크롤 영역의 이름을 수정하려면 클릭하세요."}
obj["scrollAreaFontSettings"]	= { tooltip="스크롤 영역에 표시되는 모든 이벤트에 상속 적용될(무시되지 않을 경우) 글꼴 설정을 수정하려면 클릭하세요"}
obj["deleteScrollArea"]			= { tooltip="스크롤 영역을 삭제하려면 클릭하세요."}
obj["scrollAreasPreview"]		= { label="미리보기", tooltip="변경사항을 미리 봅니다."}
obj["toggleAll"]				= { label="모두 바꾸기", tooltip="선택한 분류의 모든 이벤트의 (비)활성화 상태를 반대로 바꿉니다."}
obj["moveAll"]					= { label="모두 이동", tooltip="선택한 분류의 모든 이벤트를 지정한 스크롤 영역으로 이동시킵니다."}
obj["eventFontSettings"]		= { tooltip="이벤트에 대한 글꼴 설정을 수정하려면 클릭하세요."}
obj["eventSettings"]			= { tooltip="스크롤 영역, 출력 메시지, 효과음 등과 같은 이벤트 설정을 수정하려면 클릭하세요."}
obj["customSound"]				= { tooltip="사용자 지정 효과음 파일을 입력하려면 클릭하세요." }
obj["playSound"]				= { label="재생", tooltip="선택된 효과음을 재생하려면 클릭하세요."}
obj["addTrigger"]				= { label="새로운 트리거 추가", tooltip="새로운 트리거를 추가합니다."}
obj["triggerSettings"]			= { tooltip="트리거를 설정하려면 클릭하세요."}
obj["deleteTrigger"]			= { tooltip="트리거를 삭제하려면 클릭하세요."}
obj["editTriggerClasses"]		= { tooltip="트리거를 적용할 클래스를 수정하려면 클릭하세요."}
obj["addMainEvent"]				= { label="이벤트 추가", tooltip="이벤트중 어느 하나라도 발생하여 설정한 조건이 만족되면 아래의 예외 조건이 어느 하나라도 만족되지 않는다면 트리거가 발동 됩니다."}
obj["addTriggerException"]		= { label="예외 추가", tooltip="예외 조건중 어느 하나라도 만족되면, 트리거는 발동되지 않습니다."}
obj["editEventConditions"]		= { tooltip="이벤트에 대한 조건을 수정하려면 클릭하세요."}
obj["deleteMainEvent"]			= { tooltip="이벤트를 삭제하려면 클릭하세요."}
obj["addEventCondition"]		= { label="조건 추가", tooltip="이벤트중 어느 하나라도 발생하여 설정한 조건이 만족되면 아래의 예외 조건이 어느 하나라도 만족되지 않는다면 트리거가 발동 됩니다."}
obj["editCondition"]			= { tooltip="조건을 수정하려면 클릭하세요."}
obj["deleteCondition"]			= { tooltip="조건을 삭제하려면 클릭하세요."}
obj["throttleList"]				= { label="기술 출력시간", tooltip="명시한 기술을 출력하는 단위시간을 설정하십시오."}
obj["mergeExclusions"]			= { label="병합 제외", tooltip="명시한 기술을 병합에서 제외됩니다."}
obj["skillSuppressions"]		= { label="제외시킬 기술", tooltip="제외시킬 기술의 이름을 명시합니다."}
obj["skillSubstitutions"]		= { label="기술 이름 대체", tooltip="기술의 이름을 사용자가 입력한 글자로 대체합니다."}
obj["addSkill"]					= { label="기술 추가", tooltip="목록에 새로운 기술을 추가합니다."}
obj["deleteSkill"]				= { tooltip="기술을 삭제하려면 클릭하세요."}
obj["cooldownExclusions"]		= { label="재사용 대기시간 제외", tooltip="재사용 대기시간 감시에서 제외되는 기술을 명시합니다."}
obj["itemsAllowed"]				= { label="허용된 아이템", tooltip="아이템 품질에 관계없이 특정한 아이템을 항상 표시합니다."}
obj["itemExclusions"]			= { label="제외 아이템", tooltip="특정한 아이템이 계속 표시되는 것으로부터 방지합니다."}
obj["addItem"]					= { label="아이템 추가", tooltip="목록에 새로운 아이템을 추가합니다."}
obj["deleteItem"]				= { tooltip="클릭하여 아이템을 삭제합니다."}


------------------------------
-- Interface editboxes
------------------------------

obj = L.EDITBOXES
obj["customFontName"]	= { label="글꼴 이름:", tooltip="이름은 글꼴을 식별하는데 사용합니다.\n\n사용예: 나의 최강 글꼴"}
obj["customFontPath"]	= { label="글꼴 경로:", tooltip="글꼴 파일이 있는 경로.\n\n노트: 만약 파일이 권장하는 MikScrollingBattleText\\Fonts 폴더 위치에 있으면, 여기엔 오로지 전체 경로 대신 파일 이름을 입력해야 됩니다.\n\n사용예: myFont.ttf "}
obj["customSoundName"]	= { label="소리 이름:", tooltip="이름은 소리를 식별하는데 사용합니다.\n\n사용예: 나의 소리"}
obj["customSoundPath"]	= { label="소리 경로:", tooltip="소리 파일이 있는 경로.\n\n노트: 만약 파일이 권장하는 MikScrollingBattleText\\Sounds 폴더 위치에 있으면, 여기엔 오로지 전체 경로 대신 파일 이름을 입력해야 됩니다.\n\n사용예: mySound.ogg "}
obj["copyProfile"]		= { label="새 프로필 이름 입력:", tooltip="선택된 프로필로부터 복사될 새로운 프로필의 이름."}
obj["partialEffect"]	= { tooltip="부분 효과 발생 시 추가될 메세지."}
obj["scrollAreaName"]	= { label="새 스크롤 영역 이름 입력:", tooltip="새로운 스크롤 영역의 이름."}
obj["xOffset"]			= { label="X 좌표:", tooltip="선택된 스크롤 영역의 X 좌표."}
obj["yOffset"]			= { label="Y 좌표:", tooltip="선택된 스크롤 영역의 Y 좌표."}
obj["eventMessage"]		= { label="출력 메세지 입력:", tooltip="이벤트 발생시 출력되는 메세지."}
obj["soundFile"]		= { label="효과음 파일명:", tooltip="이벤트 발생시 재생할 효과음 파일."}
obj["iconSkill"]		= { label="기술 아이콘:", tooltip="이벤트 발생 시 아이콘을 표시할 기술의 이름입니다."}
obj["skillName"]		= { label="기술 이름 입력:", tooltip="추가되는 기술의 이름."}
obj["substitutionText"]	= { label="대체 텍스트:", tooltip="기술 이름을 대체할 텍스트."}
obj["itemName"]			= { label="아이템 이름:", tooltip="추가시킬 아이템의 이름."}


------------------------------
-- Interface sliders
------------------------------

obj = L.SLIDERS
obj["animationSpeed"]		= { label="애니메이션 속도", tooltip="기본 애니메이션 속도를 설정합니다..\n\n각 스크롤 영역은 각기 다른 속도로 설정될수도 있습니다.."}
obj["normalFontSize"]		= { label="보통 크기", tooltip="치명타가 아닐때 사용할 글꼴 크기를 설정합니다."}
obj["normalFontOpacity"]	= { label="보통 투명도", tooltip="치명타가 아닐때 사용할 글꼴 투명도를 설정합니다."}
obj["critFontSize"]			= { label="치명타 폰트 크기", tooltip="치명타에 사용할 글꼴 크기를 설정합니다."}
obj["critFontOpacity"]		= { label="치명타 폰트 간격", tooltip="치명타에 사용할 글꼴 투명도를 설정합니다."}
obj["scrollHeight"]			= { label="스크롤 높이", tooltip="스크롤 영역의 높이."}
obj["scrollWidth"]			= { label="스크롤 넓이", tooltip="스크롤 영역의 넓이."}
obj["scrollAnimationSpeed"]	= { label="애니메이션 속도", tooltip="스크롤 영역의 애니메이션 속도를 설정합니다."}
obj["powerThreshold"]		= { label="마력 변화 표시 기준", tooltip="마력 (마나, 분노, 기력, 룬 마력) 획득이 표시되기 위해 초과되어야 하는 기준 수치."}
obj["healThreshold"]		= { label="치유량 표시 기준", tooltip="치유량이 표시되기 위해 초과되어야 하는 기준 수치."}
obj["damageThreshold"]		= { label="피해량 표시 기준", tooltip="피해량이 표시되기 위해 초과되어야 하는 기준 수치."}
obj["dotThrottleTime"]		= { label="지속적인 피해량 (DoT) 출력시간", tooltip="지속적인 피해량 (DoT)을 출력하는 단위시간 (초)."}
obj["hotThrottleTime"]		= { label="지속적인 치유량 (HoT) 출력시간", tooltip="지속적인 치유량 (HoT)을 출력하는 단위시간 (초)."}
obj["powerThrottleTime"]	= { label="마력 변화 출력시간", tooltip="마력 (마나, 분노, 기력, 룬 마력) 변화를 출력하는 단위시간 (초)"}
obj["skillThrottleTime"]	= { label="출력시간 (초)", tooltip="기술을 출력하는 단위시간 (초)."}
obj["cooldownThreshold"]	= { label="재사용 대기시간 기준", tooltip="기술이 표시되기 위해 초과되어야 하는 재사용 대기시간의 기준 시간."}


------------------------------
-- Event categories
------------------------------
obj = L.EVENT_CATEGORIES
obj[1] = "자신이 받은 메시지"
obj[2] = "자신이 받은 메시지 [소환수]"
obj[3] = "대상이 받은 메시지"
obj[4] = "대상이 받은 메시지 [소환수]"
obj[5] = "알림 메시지"


------------------------------
-- Event codes
------------------------------

obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - 받은 피해량.\n"
obj["HEALING_TAKEN"]		= "%a - 받은 치유량.\n"
obj["DAMAGE_DONE"]			= "%a - 피해량.\n"
obj["HEALING_DONE"]			= "%a - 치유량.\n"
obj["ABSORBED_AMOUNT"]		= "%a - 피해 흡수량.\n"
obj["AURA_AMOUNT"]			= "%a - 오라에 대한 중첩량.\n"
obj["ENERGY_AMOUNT"]		= "%a - 기력.\n"
--obj["CHI_AMOUNT"]			= "%a - Amount of chi you have.\n"
obj["CP_AMOUNT"]			= "%a - 연계 점수.\n"
obj["HOLY_POWER_AMOUNT"]	= "%a - 보유한 신성한 힘.\n"
--obj["SHADOW_ORBS_AMOUNT"]	= "%a - Amount of shadow orbs you have.\n"
obj["HONOR_AMOUNT"]			= "%a - 명예 점수.\n"
obj["REP_AMOUNT"]			= "%a - 평판 수치.\n"
obj["ITEM_AMOUNT"]			= "%a - 획득한 아이템 수량.\n"
obj["SKILL_AMOUNT"]			= "%a - 기술 점수.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - 획득한 경험치.\n"
obj["PARTIAL_AMOUNT"]		= "%a - 부분 효과 횟수.\n"
obj["ATTACKER_NAME"]		= "%n - 공격자 이름.\n"
obj["HEALER_NAME"]			= "%n - 치유자 이름.\n"
obj["ATTACKED_NAME"]		= "%n - 피해자 이름.\n"
obj["HEALED_NAME"]			= "%n - 치유 받은 유닛 이름.\n"
obj["BUFFED_NAME"]			= "%n - 버프 받은 유닛 이름.\n"
obj["UNIT_KILLED"]			= "%n - 죽은 유닛의 이름.\n"
obj["SKILL_NAME"]			= "%s - 기술의 이름.\n"
obj["SPELL_NAME"]			= "%s - 주문의 이름.\n"
obj["DEBUFF_NAME"]			= "%s - 디버프의 이름.\n"
obj["BUFF_NAME"]			= "%s - 버프의 이름.\n"
obj["ITEM_BUFF_NAME"]		= "%s - 아이템 버프의 이름.\n"
obj["EXTRA_ATTACKS"]		= "%s - 추가타 공격을 부여한 기술의 이름.\n"
obj["SKILL_LONG"]			= "%sl - %s의 긴 이름. 이벤트 설정에서 짧은 이름 사용 무시.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - 받은 피해량 속성.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - 피해량 속성.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - 피해량 원인 (낙하, 호흡, 용암 등...)\n"
obj["FACTION_NAME"]			= "%e - 평판 이름.\n"
obj["EMOTE_TEXT"]			= "%e - 감정 표현 텍스트.\n"
obj["MONEY_TEXT"]			= "%e - 획득한 금전의 텍스트.\n"
obj["COOLDOWN_NAME"]		= "%e - 준비된 기술의 이름.\n"
--obj["ITEM_COOLDOWN_NAME"]	= "%e - The name of item that is ready.\n"
obj["ITEM_NAME"]			= "%e - 획득한 아이템의 이름.\n"
obj["POWER_TYPE"]			= "%p - 마력의 유형 (마나, 분노, 기력, 룬마력).\n"
obj["TOTAL_ITEMS"]			= "%t - 소지품 속 획득한 아이템의 합계."


------------------------------
-- Incoming events
------------------------------

obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="근접 평타", tooltip="자신이 받은 근접 평타를 활성화합니다."}
obj["INCOMING_DAMAGE_CRIT"]					= { label="근접 치명타", tooltip="자신이 받은 근접 치명타를 활성화합니다."}
obj["INCOMING_MISS"]						= { label="근접 빗나감", tooltip="자신에게 적중하지 않은 근접 공격을 활성화합니다."}
obj["INCOMING_DODGE"]						= { label="근접 회피", tooltip="자신의 근접 회피를 활성화합니다."}
obj["INCOMING_PARRY"]						= { label="근접 막음", tooltip="자신의 근접 막음을 활성화합니다."}
obj["INCOMING_BLOCK"]						= { label="근접 방어", tooltip="자신의 근접 방어를 활성화합니다."}
obj["INCOMING_DEFLECT"]						= { label="근접 튕김", tooltip="자신의 근접 튕김을 활성화합니다."}
obj["INCOMING_ABSORB"]						= { label="근접 흡수", tooltip="자신이 흡수한 근접 피해량을 활성화합니다."}
obj["INCOMING_IMMUNE"]						= { label="근접 면역", tooltip="자신에게 면역인 근접 공격을 활성화합니다."}
obj["INCOMING_SPELL_DAMAGE"]				= { label="주문 적중", tooltip="자신이 받은 주문 피해량을 활성화합니다."}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="주문 치명상", tooltip="자신이 받은 주문의 치명상 피해량을 활성화합니다."}
obj["INCOMING_SPELL_DOT"]					= { label="주문 주기적 피해", tooltip="자신이 받은 주기적인 주문의 피해량을 활성화합니다."}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="주문 주기적 치명상 피해", tooltip="자신이 받은 주기적인 주문의 치명상 피해량을 활성화합니다."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="피해막 적중", tooltip="가시, 응보의 오라 등으로 자신이 받은 피해량을 활성화합니다."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="피해막 치명상", tooltip="가시, 응보의 오라 등으로 자신이 받은 치명상을 활성화합니다."}
obj["INCOMING_SPELL_MISS"]					= { label="주문 빗나감", tooltip="자신에게 적중하지 않은 주문 공격을 활성화합니다."}
obj["INCOMING_SPELL_DODGE"]					= { label="주문 회피", tooltip="자신의 주문 회피를 활성화합니다."}
obj["INCOMING_SPELL_PARRY"]					= { label="주문 막음", tooltip="자신의 주문 막음을 활성화합니다."}
obj["INCOMING_SPELL_BLOCK"]					= { label="주문 방어", tooltip="자신의 주문 방어를 활성화합니다."}
obj["INCOMING_SPELL_DEFLECT"]				= { label="주문 튕김", tooltip="자신의 주문 튕김을 활성화합니다."}
obj["INCOMING_SPELL_RESIST"]				= { label="주문 저항", tooltip="자신의 주문 저항을 활성화합니다."}
obj["INCOMING_SPELL_ABSORB"]				= { label="주문 흡수", tooltip="자신이 흡수한 주문 피해량을 활성화합니다."}
obj["INCOMING_SPELL_IMMUNE"]				= { label="주문 면역", tooltip="자신에게 면역인 주문 공격을 활성화합니다."}
obj["INCOMING_SPELL_REFLECT"]				= { label="주문 반사", tooltip="자신이 반사한 주문 피해량을 활성화합니다."}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="주문 차단", tooltip="자신이 받은 주문 차단을 활성화합니다."}
obj["INCOMING_HEAL"]						= { label="치유", tooltip="자신이 받은 치유량을 활성화합니다."}
obj["INCOMING_HEAL_CRIT"]					= { label="치유 극대화", tooltip="자신이 받은 치유 극대화를 활성화합니다."}
obj["INCOMING_HOT"]							= { label="주기적 치유", tooltip="자신이 받은 주기적 치유를 활성화합니다."}
obj["INCOMING_HOT_CRIT"]					= { label="주기적 치유 극대화", tooltip="자신의 받은 주기적 치유 극대화를 활성화합니다."}
obj["INCOMING_ENVIRONMENTAL"]				= { label="환경 피해", tooltip="자신이 받은 환경 피해 (낙하, 호흡, 용암 등...)를 활성화 합니다."}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="근접 평타", tooltip="소환수가 받은 근접 평타 활성화합니다."}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="근접 치명타", tooltip="소환수가 받은 근접 치명타를 활성화합니다."}
obj["PET_INCOMING_MISS"]						= { label="근접 빗나감", tooltip="소환수에게 적중하지 않은 근접 공격을 활성화합니다."}
obj["PET_INCOMING_DODGE"]						= { label="근접 회피", tooltip="소환수의 근접 회피를 활성화합니다."}
obj["PET_INCOMING_PARRY"]						= { label="근접 막음", tooltip="소환수의 근접 막음을 활성화합니다."}
obj["PET_INCOMING_BLOCK"]						= { label="근접 방어", tooltip="소환수의 근접 방어를 활성화합니다."}
obj["PET_INCOMING_DEFLECT"]						= { label="근접 튕김", tooltip="소환수의 근접 튕김을 활성화합니다."}
obj["PET_INCOMING_ABSORB"]						= { label="근접 흡수", tooltip="소환수가 흡수한 근접 피해량을 활성화합니다."}
obj["PET_INCOMING_IMMUNE"]						= { label="근접 면역", tooltip="소환수에게 면역인 근접 공격을 활성화합니다."}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="주문 적중", tooltip="소환수가 받은 주문 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="주문 치명상", tooltip="소환수가 받은 주문의 치명상 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_DOT"]					= { label="주문 주기적 피해", tooltip="소환수가 받은 주기적인 주문 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="주문 주기적 치명상 피해", tooltip="소환수가 받은 주기적인 주문의 치명상 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="피해막 적중", tooltip="가시, 응보의 오라 등으로 소환수가 받은 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="피해막 치명상", tooltip="가시, 응보의 오라 등으로 소환수가 받은 치명상 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="주문 공격 빗나감", tooltip="소환수에게 적중하지 않은 주문 공격을 활성화합니다."}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="주문 회피", tooltip="소환수의 주문 회피를 활성화합니다."}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="주문 막음", tooltip="소환수의 주문 막음을 활성화합니다."}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="주문 방어", tooltip="소환수의 주문 방어를 활성화합니다."}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="주문 튕김", tooltip="소환수의 주문 튕김을 활성화합니다."}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="주문 저항", tooltip="소환수의 주문 저항을 활성화합니다."}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="주문 흡수", tooltip="소환수가 흡수한 주문 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="주문 면역", tooltip="소환수에게 면역인 주문 공격를 활성화합니다."}
obj["PET_INCOMING_HEAL"]						= { label="치유", tooltip="소환수가 받은 치유량을 활성화합니다."}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="치유 극대화", tooltip="소환수가 받은 치유 극대화를 활성화합니다."}
obj["PET_INCOMING_HOT"]							= { label="주기적 치유", tooltip="소환수가 받은 주기적 치유를 활성화합니다."}
obj["PET_INCOMING_HOT_CRIT"]					= { label="주기적 치유 극대화", tooltip="소환수가 받은 받은 주기적 치유 극대화를 활성화합니다."}


------------------------------
-- Outgoing events
------------------------------

obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="근접 평타", tooltip="대상이 받은 근접 평타를 활성화합니다."}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="근접 치명타", tooltip="대상이 받은 근접 치명타를 활성화합니다."}
obj["OUTGOING_MISS"]						= { label="근접 빗나감", tooltip="대상에게 적중하지 않은 근접 공격을 활성화합니다."}
obj["OUTGOING_DODGE"]						= { label="근접 회피", tooltip="근접 공격에 대한 대상의 회피를 활성화합니다."}
obj["OUTGOING_PARRY"]						= { label="근접 막음", tooltip="근접 공격에 대한 대상의 막음을 활성화합니다."}
obj["OUTGOING_BLOCK"]						= { label="근접 방어", tooltip="근접 공격에 대한 대상의 방어를 활성화합니다."}
obj["OUTGOING_DEFLECT"]						= { label="근접 튕김", tooltip="근접 공격에 대한 대상의 튕김을 활성화합니다."}
obj["OUTGOING_ABSORB"]						= { label="근접 흡수", tooltip="근접 공격에 대하여 대상이 흡수한 피해량을 활성화합니다."}
obj["OUTGOING_IMMUNE"]						= { label="근접 면역", tooltip="근접 공격에 대한 대상의 면역을 활성화합니다."}
obj["OUTGOING_EVADE"]						= { label="근접 벗어남", tooltip="대상에게 벗어난 근접 공격을 활성화합니다."}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="주문 적중", tooltip="대상이 받은 주문 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="주문 치명타", tooltip="대상이 받은 주문의 치명상 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_DOT"]					= { label="주문 주기적 피해", tooltip="대상이 받은 주기적인 주문 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="주문 주기적 치명상 피해", tooltip="대상이 받은 주기적인 주문의 치명상 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="피해막 적중", tooltip="가시, 응보의 오라 등으로 대상이 받은 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="피해막 치명타", tooltip="가시, 응보의 오라 등으로 대상이 받은 치명상 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_MISS"]					= { label="주문 빗나감", tooltip="대상에게 적중하지 않은 주문 공격을 활성화합니다."}
obj["OUTGOING_SPELL_DODGE"]					= { label="주문 회피", tooltip="주문 공격에 대한 대상의 회피를 활성화합니다."}
obj["OUTGOING_SPELL_PARRY"]					= { label="주문 막음", tooltip="주문 공격에 대한 대상의 막음을 활성화합니다."}
obj["OUTGOING_SPELL_BLOCK"]					= { label="주문 방어", tooltip="주문 공격에 대한 대상의 방어를 활성화합니다."}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="주문 튕김", tooltip="주문 공격에 대한 대상의 튕김을 활성화합니다."}
obj["OUTGOING_SPELL_RESIST"]				= { label="주문 저항", tooltip="주문 공격에 대한 대상의 저항을 활성화합니다."}
obj["OUTGOING_SPELL_ABSORB"]				= { label="주문 흡수", tooltip="주문 공격에 대하여 대상이 흡수한 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="주문 면역", tooltip="주문 공격에 대한 대상의 면역을 활성화합니다."}
obj["OUTGOING_SPELL_REFLECT"]				= { label="주문 반사", tooltip="주문 공격에 대하여 대상이 반사한 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="주문 차단", tooltip="대상이 받은 주문 차단을 활성화합니다."}
obj["OUTGOING_SPELL_EVADE"]					= { label="주문 벗어남", tooltip="대상에게 벗어난 주문 공격을 활성화합니다."}
obj["OUTGOING_HEAL"]						= { label="치유", tooltip="대상이 받은 치유량을 활성화합니다."}
obj["OUTGOING_HEAL_CRIT"]					= { label="치유 극대화", tooltip="대상이 받은 치유 극대화를 활성화합니다."}
obj["OUTGOING_HOT"]							= { label="주기적 치유", tooltip="대상이 받은 주기적 치유를 활성화합니다."}
obj["OUTGOING_HOT_CRIT"]					= { label="주기적 치유 극대화", tooltip="대상이 받은 주기적 치유 극대화를 활성화합니다."}
obj["OUTGOING_DISPEL"]						= { label="해제", tooltip="대상이 받은 해제를 활성화합니다."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="근접 평타", tooltip="소환수가 대상에게 준 근접 평타를 활성화합니다."}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="근접 치명타", tooltip="소환수가 대상에게 준 근접 치명타를 활성화합니다."}
obj["PET_OUTGOING_MISS"]						= { label="근접 빗나감", tooltip="대상에게 적중하지 않은 소환수의 근접 공격을 활성화합니다."}
obj["PET_OUTGOING_DODGE"]						= { label="근접 회피", tooltip="소환수의 근접 공격에 대한 대상의 회피를 활성화합니다."}
obj["PET_OUTGOING_PARRY"]						= { label="근접 막음", tooltip="소환수의 근접 공격에 대한 대상의 막음을 활성화합니다."}
obj["PET_OUTGOING_BLOCK"]						= { label="근접 방어", tooltip="소환수의 근접 공격에 대한 대상의 방어를 활성화합니다."}
obj["PET_OUTGOING_DEFLECT"]						= { label="근접 튕김", tooltip="소환수의 근접 공격에 대한 대상의 튕김을 활성화합니다."}
obj["PET_OUTGOING_ABSORB"]						= { label="근접 흡수", tooltip="소환수의 근접 공격에 대하여 대상이 흡수한 피해량을 활성화합니다."}
obj["PET_OUTGOING_IMMUNE"]						= { label="근접 면역", tooltip="소환수의 근접 공격에 대한 대상의 면역을 활성화합니다."}
obj["PET_OUTGOING_EVADE"]						= { label="근접 벗어남", tooltip="대상에게 벗어난 소환수의 근접 공격을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="주문 적중", tooltip="소환수가 대상에게 준 주문 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="주문 치명타", tooltip="소환수가 대상에게 준 주문의 치명상 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="주문 주기적 피해", tooltip="소환수가 대상에게 준 주기적인 주문 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="주문 주기적 치명상 피해", tooltip="소환수가 대상에게 준 주기적인 주문의 치명상 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="피해막 적중", tooltip="가시, 응보의 오라 등으로 소환수가 대상에게 준 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="피해막 치명타", tooltip="가시, 응보의 오라 등으로 소환수가 대상에게 준 치명상 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="주문 빗나감", tooltip="대상에게 적중하지 않은 소환수의 주문 공격을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="주문 회피", tooltip="소환수의 주문 공격에 대한 대상의 회피를 활성화합니다."}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="주문 막음", tooltip="소환수의 주문 공격에 대한 대상의 막음을 활성화합니다."}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="주문 방어", tooltip="소환수의 주문 공격에 대한 대상의 방어를 활성화합니다."}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="주문 튕김", tooltip="소환수의 주문 공격에 대한 대상의 튕김을 활성화합니다."}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="주문 저항", tooltip="소환수의 주문 공격에 대한 대상의 저항을 활성화합니다."}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="주문 흡수", tooltip="소환수의 주문 공격에 대하여 대상이 흡수한 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="주문 면역", tooltip="소환수의 주문 공격에 대한 대상의 면역을 활성화합니다."}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="주문 벗어남", tooltip="대상에게 벗어난 소환수의 주문 공격을 활성화합니다."}
obj["PET_OUTGOING_HEAL"]						= { label="치유", tooltip="소환수가 받은 치유량을 활성화합니다."}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="치유 극대화", tooltip="소환수가 받은 치유 극대화를 활성화합니다."}
obj["PET_OUTGOING_HOT"]							= { label="주기적 치유", tooltip="소환수가 받은 주기적 치유를 활성화합니다."}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="주기적 치유 극대화", tooltip="소환수가 받은 주기적 치유 극대화를 활성화합니다."}
obj["PET_OUTGOING_DISPEL"]						= { label="해제", tooltip="소환수의 해제를 활성화합니다."}


------------------------------
-- Notification events
------------------------------

obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="디버프", tooltip="당신이 걸린 디버프를 알려줍니다."}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="중첩 디버프", tooltip="당신이 걸린 중첩 디버프를 알려줍니다."}
obj["NOTIFICATION_BUFF"]				= { label="버프", tooltip="당신이 받은 버프를 알려줍니다."}
obj["NOTIFICATION_BUFF_STACK"]			= { label="중첩 버프", tooltip="당신이 받은 중첩 버프를 알려줍니다."}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="아이템 버프", tooltip="당신이 받은 아이템 버프를 알려줍니다."}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="디버프 사라짐", tooltip="사라진 디버프를 알려줍니다."}
obj["NOTIFICATION_BUFF_FADE"]			= { label="버프 사라짐", tooltip="사라진 버프를 알려줍니다."}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="아이템 버프 사라짐", tooltip="사라진 아이템 버프를 알려줍니다."}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="전투 시작", tooltip="전투 상태 시작을 알려줍니다."}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="전투 종료", tooltip="전투 상태 종료를 알려줍니다."}
obj["NOTIFICATION_POWER_GAIN"]			= { label="마력 (마나/분노 등) 획득", tooltip="추가적인 마나, 분노, 기력, 룬 마력 획득을 알려줍니다."}
obj["NOTIFICATION_POWER_LOSS"]			= { label="마력 (마나/분노 등) 손실", tooltip="유출에 의한 마나, 분노, 기력, 룬 마력 손실을 알려줍니다."}
--obj["NOTIFICATION_ALT_POWER_GAIN"]		= { label="Alternate Power Gains", tooltip="Enable when you gain alternate power such as sound level on Atramedes."}
--obj["NOTIFICATION_ALT_POWER_LOSS"]		= { label="Alternate Power Losses", tooltip="Enable when you lose alternate power from drains."}
--obj["NOTIFICATION_CHI_CHANGE"]			= { label="Chi Changes", tooltip="Enable when you change chi."}
--obj["NOTIFICATION_CHI_FULL"]			= { label="Chi Full", tooltip="Enable when you attain full chi."}
obj["NOTIFICATION_CP_GAIN"]				= { label="연계 점수 획득", tooltip="연계 점수 획득을 알려줍니다."}
obj["NOTIFICATION_CP_FULL"]				= { label="연계 점수 마무리", tooltip="연계 점수가 절정 (5 포인트)에 도달했음을 알려줍니다."}
obj["NOTIFICATION_HOLY_POWER_CHANGE"]	= { label="신성한 힘 변환", tooltip="신성한 힘이 변환되면 알려줍니다."}
obj["NOTIFICATION_HOLY_POWER_FULL"]		= { label="신성한 힘 최대", tooltip="최대 신성한 힘에 도달하면 알려줍니다."}
--obj["NOTIFICATION_SHADOW_ORBS_CHANGE"]	= { label="Shadow Orb Changes", tooltip="Enable when you change shadow orbs."}
--obj["NOTIFICATION_SHADOW_ORBS_FULL"]	= { label="Shadow Orbs Full", tooltip="Enable when you attain full shadow orbs."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="명예 획득", tooltip="명예 점수 획득을 알려줍니다.."}
obj["NOTIFICATION_REP_GAIN"]			= { label="평판 상승", tooltip="평판 수치 획득을 알려줍니다.."}
obj["NOTIFICATION_REP_LOSS"]			= { label="평판 하락", tooltip="평판 수치 감소를 알려줍니다."}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="기술 획득", tooltip="기술 점수 획득을 알려줍니다."}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="경험치 획득", tooltip="경험치 획득을 알려줍니다."}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="플레이어 결정타", tooltip="적대적 대상에 대해 결정타를 입혔을때 알려줍니다."}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="NPC 결정타", tooltip="NPC에 대해 결정타를 입혔을때 알려줍니다."}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="추가타 공격", tooltip="추가타 공격 (우뢰 폭풍, 도검 전문화 등.) 효과를 얻었음을 알려줍니다."}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="적의 버프 획득", tooltip="당신의 적대적 대상이 버프를 획득하면 알려줍니다."}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="몬스터 감정표현", tooltip="당신의 대상 몬스터의 감정 표현을 알려줍니다."}


------------------------------
-- Trigger info
------------------------------

-- Main events.
obj = L.TRIGGER_DATA
obj["SWING_DAMAGE"]				= "근접 피해"
obj["RANGE_DAMAGE"]				= "원거리 피해"
obj["SPELL_DAMAGE"]				= "주문 피해"
obj["GENERIC_DAMAGE"]			= "피해량"
obj["SPELL_PERIODIC_DAMAGE"]	= "주기적인 주문 피해 (DoT)"
obj["DAMAGE_SHIELD"]			= "피해막 피해"
obj["DAMAGE_SPLIT"]				= "분할 피해"
obj["ENVIRONMENTAL_DAMAGE"]		= "환경적인 피해"
obj["SWING_MISSED"]				= "근접 빗나감"
obj["RANGE_MISSED"]				= "원거리 빗나감"
obj["SPELL_MISSED"]				= "주문 빗나감"
obj["GENERIC_MISSED"]			= "빗나감 (적중하지 않음)"
obj["SPELL_PERIODIC_MISSED"]	= "주기적인 주문 빗나감"
obj["SPELL_DISPEL_FAILED"]		= "주문 해제 실패"
obj["DAMAGE_SHIELD_MISSED"]		= "피해막 빗나감"
obj["SPELL_HEAL"]				= "치유"
obj["SPELL_PERIODIC_HEAL"]		= "주기적인 치유 (HoT)"
obj["SPELL_ENERGIZE"]			= "마력 (마나/분노 등) 획득"
obj["SPELL_PERIODIC_ENERGIZE"]	= "주기적인 마력 (마나/분노 등) 획득"
obj["SPELL_DRAIN"]				= "마력 (마나/분노 등) 유출"
obj["SPELL_PERIODIC_DRAIN"]		= "주기적인 (마나/분노 등) 마력 유출"
obj["SPELL_LEECH"]				= "마력 (마나/분노 등) 착취"
obj["SPELL_PERIODIC_LEECH"]		= "주기적인 마력 (마나/분노 등) 착취"
obj["SPELL_INTERRUPT"]			= "주문 차단"
obj["SPELL_AURA_APPLIED"]		= "오라 받음"
obj["SPELL_AURA_REMOVED"]		= "오라 사라짐"
obj["SPELL_STOLEN"]				= "주문 훔치기"
obj["SPELL_DISPEL"]				= "주문 해제"
obj["SPELL_AURA_REFRESH"]		= "오라 복원"
obj["SPELL_AURA_BROKEN_SPELL"]	= "오라 중단됨"
obj["ENCHANT_APPLIED"]			= "무기 강화 받음"
obj["ENCHANT_REMOVED"]			= "무기 강화 사라짐"
obj["SPELL_CAST_START"]			= "시전 시작"
obj["SPELL_CAST_SUCCESS"]		= "시전 성공"
obj["SPELL_CAST_FAILED"]		= "시전 실패"
obj["SPELL_SUMMON"]				= "소환"
obj["SPELL_CREATE"]				= "창조"
obj["PARTY_KILL"]				= "결정타"
obj["UNIT_DIED"]				= "유닛 죽음"
obj["UNIT_DESTROYED"]			= "유닛 사라짐"
obj["SPELL_EXTRA_ATTACKS"]		= "추가 공격"
obj["UNIT_HEALTH"]				= "생명력 변화"
obj["UNIT_POWER"]				= "마력 변화"
obj["SKILL_COOLDOWN"]			= "플레이어 재사용 대기시간 종료"
obj["PET_COOLDOWN"]				= "소환수 재사용 대기시간 종료"
--obj["ITEM_COOLDOWN"]			= "Item Cooldown Complete"
 
-- Main event conditions.
obj["sourceName"]				= "이벤트를 제공한 유닛의 이름"
obj["sourceAffiliation"]		= "이벤트를 제공한 유닛의 소속"
obj["sourceReaction"]			= "이벤트를 제공한 유닛과의 관계"
obj["sourceControl"]			= "이벤트를 제공한 유닛의 제어"
obj["sourceUnitType"]			= "이벤트를 제공한 유닛 유형"
obj["recipientName"]			= "이벤트를 받은 유닛의 이름"    
obj["recipientAffiliation"]		= "이벤트를 받은 유닛의 소속"
obj["recipientReaction"]		= "이벤트를 받은 유닛과의 관계"
obj["recipientControl"]			= "이벤트를 받은 유닛의 제어"
obj["recipientUnitType"]		= "이벤트를 받은 유닛의 유형"
obj["skillID"]					= "기술 ID"
obj["skillName"]				= "기술 이름"
obj["skillSchool"]				= "기술 속성"
obj["extraSkillID"]				= "추가 기술 ID"
obj["extraSkillName"]			= "추가 기술 이름"
obj["extraSkillSchool"]			= "추가 기술 속성"
obj["amount"]					= "수치 (양)"
obj["overkillAmount"]			= "초과 피해"
obj["damageType"]				= "피해 속성"
obj["resistAmount"]				= "저항한 피해"
obj["blockAmount"]				= "방어한 피해"
obj["absorbAmount"]				= "흡수한 피해"
obj["isCrit"]					= "치명타"
obj["isGlancing"]				= "비껴맞음"
obj["isCrushing"]				= "강타"
obj["extraAmount"]				= "추가 피해"
obj["missType"]					= "빗나감 종류"
obj["hazardType"]				= "위험요소 종류"
obj["powerType"]				= "마력 종류"
obj["auraType"]					= "오라 종류"
obj["threshold"]				= "기준 (양/시간)"
obj["unitID"]					= "유닛 ID"
obj["unitReaction"]				= "유닛 반응"
--obj["itemID"]					= "Item ID"
--obj["itemName"]					= "Item Name"

-- Exception conditions.
obj["activeTalents"]			= "활성된 특성"
obj["buffActive"]				= "활성된 버프"
obj["buffInactive"]				= "비활성된 버프"
obj["currentCP"]				= "현재 연계 점수"
obj["currentPower"]				= "현재 마력 (마나/분노 등)"
obj["inCombat"]					= "전투중"
obj["recentlyFired"]			= "최근 발동된 트리거"
obj["trivialTarget"]			= "무시 대상"
obj["unavailableSkill"]			= "배우지 않은 기술"
obj["warriorStance"]			= "전사 태세"
obj["zoneName"]					= "지역 이름"
obj["zoneType"]					= "지역 유형"
 
-- Relationships.
obj["eq"]						= "일치함 ( = )"
obj["ne"]						= "일치하지 않음 ( ≠ )"
obj["like"]						= "유사함"
obj["unlike"]					= "유사하지 않음"
obj["lt"]						= "보다 작음 ( < )"
obj["gt"]						= "보다 큼 ( > )"
 
-- Affiliations.
obj["affiliationMine"]			= "자신의 것"
obj["affiliationParty"]			= "파티원"
obj["affiliationRaid"]			= "공격대원"
obj["affiliationOutsider"]		= "제 3자"
obj["affiliationTarget"]		= TARGET
obj["affiliationFocus"]			= "주시 대상"
obj["affiliationYou"]			= YOU

-- Reactions.
obj["reactionFriendly"]			= "우호적인"
obj["reactionNeutral"]			= "중립적인"
obj["reactionHostile"]			= "적대적인"

-- Control types.
obj["controlServer"]			= "서버"
obj["controlHuman"]				= "유저"

-- Unit types.
obj["unitTypePlayer"]			= PLAYER 
obj["unitTypeNPC"]				= "NPC"
obj["unitTypePet"]				= PET
obj["unitTypeGuardian"]			= "수호물"
obj["unitTypeObject"]			= "객체"

-- Aura types.
obj["auraTypeBuff"]				= "버프"
obj["auraTypeDebuff"]			= "디버프"

-- Zone types.
obj["zoneTypeArena"]			= "투기장"
obj["zoneTypePvP"]				= BATTLEGROUND
obj["zoneTypeParty"]			= "5인 던전"
obj["zoneTypeRaid"]				= "공격대 던전"

-- Booleans
obj["booleanTrue"]				= "True"
obj["booleanFalse"]				= "False"


------------------------------
-- Font info
------------------------------

-- Font outlines.
obj = L.OUTLINES
obj[1] = "없음"
obj[2] = "얇게"
obj[3] = "굵게"
--obj[4] = "Monochrome"
--obj[5] = "Monochrome + Thin"
--obj[6] = "Monochrome + Thick"

-- Text aligns.
obj = L.TEXT_ALIGNS
obj[1] = "왼쪽"
obj[2] = "가운데"
obj[3] = "오른쪽"


------------------------------
-- Sound info
------------------------------

obj = L.SOUNDS
obj["MSBT Low Mana"]	= "MSBT: 마나 낮음"
obj["MSBT Low Health"]	= "MSBT: 생명력 낮음"
obj["MSBT Cooldown"]	= "MSBT: 재사용 대기시간"


------------------------------
-- Animation style info
------------------------------

-- Animation styles
obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "각도"
obj["Horizontal"]	= "수평"
obj["Parabola"]		= "포물선"
obj["Straight"]		= "직선"
obj["Static"]		= "고정"
obj["Pow"]			= "타격 효과"

-- Animation style directions.
obj["Alternate"]	= "교차"
obj["Left"]			= "좌로"
obj["Right"]		= "우로"
obj["Up"]			= "위로"
obj["Down"]			= "아래로"

-- Animation style behaviors.
obj["AngleUp"]			= "상향 각도로"
obj["AngleDown"]		= "하향 각도로"
obj["GrowUp"]			= "위로 확장"
obj["GrowDown"]			= "아래로 확장"
obj["CurvedLeft"]		= "좌로 휘어짐"
obj["CurvedRight"]		= "우로 휘어짐"
obj["Jiggle"]			= "흔들림"
obj["Normal"]			= "효과 없음"
