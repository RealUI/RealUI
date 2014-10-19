----------------------------------------------------------------------------
-- Title: MSBT Options Traditional Chinese Localization
-- Author: Mikord
-- Credits:
--	Whitepaw  @ 暗影之月(TW-Shadowmoon)
--	yaroot#gmail_com
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't Traditional Chinese.
if (GetLocale() ~= "zhTW") then return end

-- Local reference for faster access.
local L = MikSBT.translations

-------------------------------------------------------------------------------
-- Traditional Chinese localization
-------------------------------------------------------------------------------


------------------------------
-- Interface messages
------------------------------

L.MSG_CUSTOM_FONTS					= "自定義字體"
L.MSG_INVALID_CUSTOM_FONT_NAME		= "無效字體名."
L.MSG_FONT_NAME_ALREADY_EXISTS		= "字體名字已經存在."
L.MSG_INVALID_CUSTOM_FONT_PATH		= "字體路徑必須指向.ttf文件"
L.MSG_UNABLE_TO_SET_FONT			= "無法使用選定字型" 
--L.MSG_TESTING_FONT			= "Testing the specified font for validity..."
L.MSG_CUSTOM_SOUNDS					= "自定義聲音"
L.MSG_INVALID_CUSTOM_SOUND_NAME		= "無效聲音名"
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "聲音名已經存在"
L.MSG_NEW_PROFILE					= "新建記錄檔"
L.MSG_PROFILE_ALREADY_EXISTS		= "記錄檔已存在"
L.MSG_INVALID_PROFILE_NAME			= "無效的記錄檔名稱"
L.MSG_NEW_SCROLL_AREA				= "新增滾動區域"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "此滾動區域名稱已存在"
L.MSG_INVALID_SCROLL_AREA_NAME		= "無效的滾動區名稱"
L.MSG_ACKNOWLEDGE_TEXT				= "你確定要執行這個動作嗎？"
L.MSG_NORMAL_PREVIEW_TEXT			= "一般"
L.MSG_INVALID_SOUND_FILE			= "音效必須為OGG格式。"
L.MSG_NEW_TRIGGER					= "新增觸發"
L.MSG_TRIGGER_CLASSES				= "觸發職業"
L.MSG_MAIN_EVENTS					= "主要事件"
L.MSG_TRIGGER_EXCEPTIONS			= "觸發例外"
L.MSG_EVENT_CONDITIONS				= "事件條件"
L.MSG_DISPLAY_QUALITY				= "當物品為此品質時顯示提示"
L.MSG_SKILLS						= "技能"
L.MSG_SKILL_ALREADY_EXISTS			= "技能名稱已存在"
L.MSG_INVALID_SKILL_NAME			= "無效的技能名稱"
L.MSG_HOSTILE						= "敵對玩家"
L.MSG_ANY							= "任何"
L.MSG_CONDITION						= "條件"
L.MSG_CONDITIONS					= "條件"
L.MSG_ITEM_QUALITIES				= "物品品質"
L.MSG_ITEMS							= "物品"
L.MSG_ITEM_ALREADY_EXISTS			= "物品名已經存在."
L.MSG_INVALID_ITEM_NAME				= "無效物品名."


------------------------------
-- Interface tabs
------------------------------

obj = L.TABS
obj["customMedia"]	= { label="自定義媒體檔", tooltip="設置自定義媒體檔"}
obj["general"]		= { label="一般設定", tooltip="一般選項設定"}
obj["scrollAreas"]	= { label="滾動區域", tooltip="新增、刪除和設定滾動區域；移動滑鼠到按鈕上可以得到更多訊息"}
obj["events"]		= { label="事件設定", tooltip="設定承受傷害、輸出傷害和通知的事件；移動滑鼠到按鈕可得到更多訊息"}
obj["triggers"]		= { label="技能觸發", tooltip="設定觸發；移動滑鼠到按鈕可得到更多訊息"}
obj["spamControl"]	= { label="洗屏控制", tooltip="設定對可能造成洗畫面的訊息進行控制"}
obj["cooldowns"]	= { label="冷卻通知", tooltip="設定技能冷卻通知"}
obj["lootAlerts"]	= { label="拾取通告", tooltip="設置與拾取有關的通告"}
obj["skillIcons"]	= { label="技能圖示", tooltip="設定技能圖示"}


------------------------------
-- Interface checkboxes
------------------------------

obj = L.CHECKBOXES
obj["enableMSBT"]				= { label="啟用MSBT", tooltip="啟用MSBT"}
obj["stickyCrits"]				= { label="爆擊特效顯示", tooltip="使用爆擊特效來顯示致命一擊"}
obj["enableSounds"]				= { label="啟用音效", tooltip="設定是否當指定事件和觸發器發生時播放音效"}
obj["textShadowing"]			= { label="字體陰影", tooltip="顯示字體陰影效果讓它們看起來更爽"}
obj["colorPartialEffects"]		= { label="特效著色", tooltip="設定是否開啟為部分特效指定顏色"}
obj["crushing"]					= { label="碾壓", tooltip="設定是否顯示碾壓訊息"}
obj["glancing"]					= { label="偏斜", tooltip="設定是否顯示偏斜訊息"}
obj["absorb"]					= { label="吸收", tooltip="設定是否顯示部分吸收數值"}
obj["block"]					= { label="格擋", tooltip="設定是否顯示部分格擋數值"}
obj["resist"]					= { label="抵抗", tooltip="設定是否顯示部分抵抗數值"}
obj["vulnerability"]			= { label="虛弱加成", tooltip="設定是否顯示虛弱加成數值"}
obj["overheal"]					= { label="過量治療", tooltip="設定是否顯示過量治療數值"}
obj["overkill"]					= { label="滅絕", tooltip="顯示滅絕總數."}
obj["colorDamageAmounts"]		= { label="傷害數值著色", tooltip="設定是否讓不同的傷害類型顯示不同的顏色"}
obj["colorDamageEntry"]			= { tooltip="讓此傷害類型顯示不同的顏色"}
obj["colorUnitNames"]			= { label="名字著色", tooltip="名字使用職業顏色著色."}
obj["colorClassEntry"]			= { tooltip="啟用此職業的顏色."}
obj["enableScrollArea"]			= { tooltip="啟用滾動區域"}
obj["inheritField"]				= { label="沿用", tooltip="沿用主要字型，不勾選則無效"}
obj["hideSkillIcons"]			= { label="隱藏圖標", tooltip="滾動區域不顯示圖標."}
obj["stickyEvent"]				= { label="套用爆擊", tooltip="使用爆擊效果來顯示事件"}
obj["enableTrigger"]			= { tooltip="啟用觸發"}
obj["allPowerGains"]			= { label="所有能量獲取", tooltip="顯示所有獲取的能量包括那些戰鬥日誌中不顯示的。警告：這個選項將會大量洗頻同時無視能量門檻和抑制顯示設定\n不推薦"}
obj["abbreviateSkills"]			= { label="技能縮寫", tooltip="縮減技能名稱（僅適用於英文版）。若事件描述中加入「%sl」代碼，此選項即失效"}
obj["mergeSwings"]				= { label="合併普通攻擊", tooltip="合併極短時間內的普通攻擊傷害"}
--obj["shortenNumbers"]			= { label="Shorten Numbers", tooltip="Display numbers in an abbreviated format (example: 32765 -> 33k)."}
--obj["groupNumbers"]				= { label="Group By Thousands", tooltip="Display numbers grouped by thousands (example: 32765 -> 32,765)."}
obj["hideSkills"]				= { label="隱藏技能", tooltip="在承受傷害和輸出傷害中不顯示技能名稱。開啟此選項將使你失去某些事件自定義功能，因為它會忽略「%s」代碼"}
obj["hideNames"]				= { label="隱藏名稱", tooltip="在承受傷害和輸出傷害中不顯示單位名稱。開啟此選項將使你失去某些事件自定義功能，因為它會忽略「%n」代碼"}
obj["hideFullOverheals"]		= { label="隱藏全部過量的治療", tooltip="不顯示全部過量的治療."}
obj["hideFullHoTOverheals"]		= { label="隱藏全部溢出的持續治療", tooltip="不顯示全部溢出的儲蓄治療"}
obj["hideMergeTrailer"]			= { label="隱藏合併攻擊細節", tooltip="不在合併攻擊後顯示被合併的攻擊次數及暴擊詳情"}
obj["allClasses"]				= { label="所有職業"}
obj["enablePlayerCooldowns"]	= { label="技能冷卻", tooltip="在技能冷卻完成之後顯示提示信息"}
obj["enablePetCooldowns"]		= { label="寵物技能冷卻", tooltip="在寵物技能冷卻完成之後顯示提示信息"}
obj["enableItemCooldowns"]		= { label="物品冷卻", tooltip="在物品冷卻完成後顯示提示信息."}
obj["lootedItems"]				= { label="拾取物品", tooltip="顯示物品拾取."}
obj["moneyGains"]				= { label="獲得金錢", tooltip="顯示獲得的金錢"}
obj["alwaysShowQuestItems"]		= { label="總是顯示任務物品", tooltip="總是顯示任務物品, 無論其是何品質."}
obj["enableIcons"]				= { label="啟用技能圖示", tooltip="顯示事件的技能圖示"}
obj["exclusiveSkills"]			= { label="排除技能名稱", tooltip="僅在沒有技能圖示時，顯示技能名稱"}


------------------------------
-- Interface dropdowns
------------------------------

obj = L.DROPDOWNS
obj["profile"]				= { label="目前記錄檔：", tooltip="設定目前記錄檔"}
obj["normalFont"]			= { label="一般傷害字型：", tooltip="選擇非爆擊傷害的字型"}
obj["critFont"]				= { label="爆擊傷害字型：", tooltip="選擇爆擊傷害的字型"}
obj["normalOutline"]		= { label="一般文字描邊：", tooltip="選擇非爆擊傷害字型的描邊樣式"}
obj["critOutline"]			= { label="爆擊文字描邊：", tooltip="選擇爆擊傷害字型的描邊樣式"}
obj["scrollArea"]			= { label="滾動區域：", tooltip="選擇滾動區域進行設定"}
obj["sound"]				= { label="音效：", tooltip="選擇事件發生時播放的音效"}
obj["animationStyle"]		= { label="動畫樣式：", tooltip="滾動區域內非黏滯的動畫樣式"}
obj["stickyAnimationStyle"]	= { label="爆擊特效：", tooltip="滾動區域內爆擊特效的動畫樣式"}
obj["direction"]			= { label="方向：", tooltip="動畫的方向"}
obj["behavior"]				= { label="效果：", tooltip="動畫的效果"}
obj["textAlign"]			= { label="對齊：", tooltip="動畫文字的對齊方式"}
obj["iconAlign"]			= { label="圖標排列:", tooltip="圖標相對于文本的位置."}
obj["eventCategory"]		= { label="事件種類：", tooltip="設定事件種類"}
obj["outputScrollArea"]		= { label="輸出滾動區域：", tooltip="選擇輸出傷害滾動區域"}
obj["mainEvent"]			= { label="主要事件:"}
obj["triggerCondition"]		= { label="條件:", tooltip="測試條件."}
obj["triggerRelation"]		= { label="關系:"}
obj["triggerParameter"]		= { label="參數:"}


------------------------------
-- Interface buttons
------------------------------

obj = L.BUTTONS
obj["addCustomFont"]			= { label="添加字體", tooltip="向字體列表添加自定義字體.\n\n警告: 字體檔必須 *在WOW運行之前* 就放置在目標檔夾內.\n\n推薦將其放置在 MikScrollingBattleText\\Fonts 文件夾."}
obj["addCustomSound"]			= { label="添加聲音", tooltip="想聲音列表添加自定義聲音.\n\n警告: 音效檔案必須 *在WOW運行之前* 就放置在目標檔夾內.\n\n推薦將其放置在 MikScrollingBattleText\\Sounds 文件夾."}
obj["editCustomFont"]			= { tooltip="點擊編輯自定義字體."}
obj["deleteCustomFont"]			= { tooltip="點擊將此字體從MSBT中移除."}
obj["editCustomSound"]			= { tooltip="點擊編輯自定義聲音."}
obj["deleteCustomSound"]		= { tooltip="點擊將此聲音從MSBT中移除."}
obj["copyProfile"]				= { label="複製記錄檔", tooltip="複製記錄檔到新增的記錄檔中"}
obj["resetProfile"]				= { label="重置記錄檔", tooltip="重置記錄檔至默認設定"}
obj["deleteProfile"]			= { label="刪除記錄檔", tooltip="刪除記錄檔"}
obj["masterFont"]				= { label="主要字型", tooltip="設定主要字型樣式；除非另有指定，否則所有的滾動區域和事件均將使用這種字型樣式"}
obj["partialEffects"]			= { label="特效著色", tooltip="設定顯示哪些特殊戰鬥效果以及著什麼顏色"}
obj["damageColors"]				= { label="傷害著色", tooltip="設定是否為某種傷害數值著色以及著什麼顏色"}
obj["classColors"]				= { label="職業顏色", tooltip="設置名字是否使用職業顏色著色和每種職業所用的顏色." }
obj["inputOkay"]				= { label=OKAY, tooltip="接受輸入"}
obj["inputCancel"]				= { label=CANCEL, tooltip="取消輸入"}
obj["genericSave"]				= { label=SAVE, tooltip="儲存改變"}
obj["genericCancel"]			= { label=CANCEL, tooltip="取消改變"}
obj["addScrollArea"]			= { label="新增滾動區域", tooltip="增加一個新的滾動區域以包含事件和觸發"}
obj["configScrollAreas"]		= { label="設定滾動區域", tooltip="設定普通和黏滯動畫效果，對齊，滾動區域的寬度/高度，以及區域位置"}
obj["editScrollAreaName"]		= { tooltip="編輯滾動區域名稱"}
obj["scrollAreaFontSettings"]	= { tooltip="設定字型；除非另有指定，否則此區域中所有事件均將使用這種字型樣式顯示"}
obj["deleteScrollArea"]			= { tooltip="刪除此滾動區域"}
obj["scrollAreasPreview"]		= { label="預覽", tooltip="預覽效果"}
obj["toggleAll"]				= { label="開啟/關閉所有事件", tooltip="開啟/關閉所選事件分類中所有事件顯示"}
obj["moveAll"]					= { label="移動所有事件", tooltip="移動所選事件分類中所有事件至指定滾動區域"}
obj["eventFontSettings"]		= { tooltip="設定此事件字型"}
obj["eventSettings"]			= { tooltip="設定事件效果比如輸出區域，輸出訊息，播放音效等"}
obj["customSound"]				= { tooltip="選擇自定義音效文件" }
obj["playSound"]				= { label="播放", tooltip="播放選定的聲音."}
obj["addTrigger"]				= { label="增加新觸發", tooltip="增加新觸發"}
obj["triggerSettings"]			= { tooltip="設定觸發條件"}
obj["deleteTrigger"]			= { tooltip="刪除觸發"}
obj["editTriggerClasses"]		= { tooltip="編輯觸發使用職業"}
obj["addMainEvent"]				= { label="新增事件", tooltip="當任何此類事件發生，並且跟設定的條件相符，將會啟動觸發，除非發生以下的例外"}
obj["addTriggerException"]		= { label="新增例外", tooltip="當任何此類例外發生，觸發就不會啟動"}
obj["editEventConditions"]		= { tooltip="設定這個事件的條件"}
obj["deleteMainEvent"]			= { tooltip="刪除事件"}
obj["addEventCondition"]		= { label="增加條件", tooltip="當所有條件都成立時, 觸發器會觸發, 除非例外條件成立."}
obj["editCondition"]			= { tooltip="點擊增加條件."}
obj["deleteCondition"]			= { tooltip="點擊刪除條件."}
obj["throttleList"]				= { label="抑制列表", tooltip="設定指定技能的自定義抑制時間"}
obj["mergeExclusions"]			= { label="合併排除", tooltip="排除指定技能的傷害數值合併"}
obj["skillSuppressions"]		= { label="技能縮寫", tooltip="縮寫技能名稱"}
obj["skillSubstitutions"]		= { label="技能替換", tooltip="用自定義名稱替換技能名稱"}
obj["addSkill"]					= { label="增加技能", tooltip="增加新技能到列表中"}
obj["deleteSkill"]				= { tooltip="點擊刪除技能"}
obj["cooldownExclusions"]		= { label="冷卻排除", tooltip="不追蹤指定技能的冷卻"}
obj["itemsAllowed"]				= { label="允許物品", tooltip="總是顯示這些物品, 無論其是何物品品質."}
obj["itemExclusions"]			= { label="排除物品", tooltip="永遠不顯示這些物品."}
obj["addItem"]					= { label="增加物品", tooltip="向列表中增加新的物品."}
obj["deleteItem"]				= { tooltip="點擊刪除物品."}


------------------------------
-- Interface editboxes
------------------------------

obj = L.EDITBOXES
obj["customFontName"]	= { label="字體名:", tooltip="用來確定字體的名字.\n\n例如: 我的字體"}
obj["customFontPath"]	= { label="字體路徑:", tooltip="字體檔的路徑.\n\n注意: 如果檔在 MikScrollingBattleText\\Fonts 中的話, 只需要輸入檔案名就可以.\n\n例如: myFont.ttf "}
obj["customSoundName"]	= { label="音效名:", tooltip="用來確定音效的名字.\n\n例如: 我的音效"}
obj["customSoundPath"]	= { label="音效路徑:", tooltip="音效檔的路徑.\n\n注意: 如果檔在 MikScrollingBattleText\\Sounds 中的話, 只需要輸入檔案名就可以.\n\n例如: mySound.ogg "}
obj["copyProfile"]		= { label="新增記錄檔：", tooltip="輸入新增記錄檔的名稱"}
obj["partialEffect"]	= { tooltip="特效觸發時的提示."}
obj["scrollAreaName"]	= { label="新增滾動區域:", tooltip="新增滾動區域的名稱"}
obj["xOffset"]			= { label="X值：", tooltip="所選擇滾動區域的X值"}
obj["yOffset"]			= { label="Y值：", tooltip="所選擇滾動區域的Y值"}
obj["eventMessage"]		= { label="顯示訊息：", tooltip="事件發生時顯示的訊息"}
obj["soundFile"]		= { label="音效檔：", tooltip="事件發生時播放的音效"}
obj["iconSkill"]		= { label="技能圖示：", tooltip="事件發生時會顯示該技能的圖示\n\n如果沒有圖示MSBT會自動找一個圖示\n\n注意: 如果目前玩家的技能書中無該技能，必須用技能ID取代技能名稱。可以在各大網站(例：WOWhead)找到技能ID。"}
obj["skillName"]		= { label="技能名稱：", tooltip="所增加的技能的名稱"}
obj["substitutionText"]	= { label="替代文字：", tooltip="用來代替技能名稱的文字"}
obj["itemName"]			= { label="物品名稱:", tooltip="要添加物品的名字."}


------------------------------
-- Interface sliders
------------------------------

obj = L.SLIDERS
obj["animationSpeed"]		= { label="動畫速度", tooltip="設定主動畫速度\n每個滾動區域也可以設定自身獨有的速度"}
obj["normalFontSize"]		= { label="一般字型大小", tooltip="設定非爆擊字型的大小"}
obj["normalFontOpacity"]	= { label="普通字型不透明度", tooltip="設定非爆擊字型的不透明度"}
obj["critFontSize"]			= { label="一般字型大小", tooltip="設定爆擊字型大小"}
obj["critFontOpacity"]		= { label="爆擊字型不透明度", tooltip="設定爆擊字型不透明度"}
obj["scrollHeight"]			= { label="滾動高度", tooltip="滾動區域高度"}
obj["scrollWidth"]			= { label="滾動寬度", tooltip="滾動區域寬度"}
obj["scrollAnimationSpeed"]	= { label="動畫速度", tooltip="設定滾動區域內動畫速度"}
obj["powerThreshold"]		= { label="能量門檻", tooltip="能量獲得只有超過此值才會被顯示"}
obj["healThreshold"]		= { label="治療門檻", tooltip="治療量只有超過此值才會被顯示"}
obj["damageThreshold"]		= { label="傷害門檻", tooltip="傷害量只有超過此值才會被顯示"}
obj["dotThrottleTime"]		= { label="持續傷害抑制顯示", tooltip="在設定的秒數中造成的持續傷害將合併為一次顯示"}
obj["hotThrottleTime"]		= { label="持續治療抑制顯示", tooltip="在設定的秒數中造成的持續治療將合併為一次顯示"}
obj["powerThrottleTime"]	= { label="能量抑制顯示", tooltip="在設定的秒數中持續獲得的能量將合併為一次顯示"}
obj["skillThrottleTime"]	= { label="技能抑制顯示", tooltip="在設定的秒數中持續使用的技能將只顯示一次"}
obj["cooldownThreshold"]	= { label="冷卻計時門檻", tooltip="冷卻時間低於設定秒數的技能不會被顯示"}


------------------------------
-- Event categories
------------------------------
obj = L.EVENT_CATEGORIES
obj[1] = "玩家受到傷害"
obj[2] = "寵物受到傷害"
obj[3] = "玩家輸出傷害"
obj[4] = "寵物輸出傷害"
obj[5] = "訊息通知"


------------------------------
-- Event codes
------------------------------

obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - 受到傷害總數.\n"
obj["HEALING_TAKEN"]		= "%a - 受到治療總數.\n"
obj["DAMAGE_DONE"]			= "%a - 輸出傷害總數.\n"
obj["HEALING_DONE"]			= "%a - 輸出治療總數.\n"
obj["ABSORBED_AMOUNT"]		= "%a - 吸收傷害總數.\n"
obj["AURA_AMOUNT"]			= "%a - 光環的堆疊數量.\n"
obj["ENERGY_AMOUNT"]		= "%a - 能量總數.\n"
--obj["CHI_AMOUNT"]			= "%a - Amount of chi you have.\n"
obj["CP_AMOUNT"]			= "%a - 你的連擊點總數.\n"
obj["HOLY_POWER_AMOUNT"]	= "%a - Amount of holy power you have.\n"
--obj["SHADOW_ORBS_AMOUNT"]	= "%a - Amount of shadow orbs you have.\n"
obj["HONOR_AMOUNT"]			= "%a - 榮譽總數.\n"
obj["REP_AMOUNT"]			= "%a - 聲望總數.\n"
obj["ITEM_AMOUNT"]			= "%a - 拾取物品的數量.\n"
obj["SKILL_AMOUNT"]			= "%a - 技能點總數.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - 獲得經驗總數.\n"
obj["PARTIAL_AMOUNT"]		= "%a - 特效觸發總數.\n"
obj["ATTACKER_NAME"]		= "%n - 攻擊者名字.\n"
obj["HEALER_NAME"]			= "%n - 治療者名字.\n"
obj["ATTACKED_NAME"]		= "%n - 被攻擊者名字.\n"
obj["HEALED_NAME"]			= "%n - 被治療著名字.\n"
obj["BUFFED_NAME"]			= "%n - 被Buff著名字.\n"
obj["UNIT_KILLED"]			= "%n - 被殺死的單位名字.\n"
obj["SKILL_NAME"]			= "%s - 技能名.\n"
obj["SPELL_NAME"]			= "%s - 法術名.\n"
obj["DEBUFF_NAME"]			= "%s - Debuff名.\n"
obj["BUFF_NAME"]			= "%s - Buff名.\n"
obj["ITEM_BUFF_NAME"]		= "%s - 物品Buff名.\n"
obj["EXTRA_ATTACKS"]		= "%s - 獲得額外攻擊的技能名.\n"
obj["SKILL_LONG"]			= "%sl - %s 全稱. 用來縮寫事件.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - 受到傷害類型.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - 輸出傷害類型.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - 傷害來源 (掉落, 溺水, 巖漿, 等等...)\n"
obj["FACTION_NAME"]			= "%e - 聲望陣營名.\n"
obj["EMOTE_TEXT"]			= "%e - 表情文字.\n"
obj["MONEY_TEXT"]			= "%e - 獲取金錢文字.\n"
obj["COOLDOWN_NAME"]		= "%e - 就緒的法術名字.\n"
obj["ITEM_COOLDOWN_NAME"]	= "%e - 就緒的物品名字.\n"
obj["ITEM_NAME"]			= "%e - 拾取物品的名稱.\n"
obj["POWER_TYPE"]			= "%p - 能力類別 (能量, 怒氣, 法力).\n"
obj["TOTAL_ITEMS"]			= "%t - 拾取物品的總數."


------------------------------
-- Incoming events
------------------------------

obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="近戰傷害", tooltip="顯示被近戰傷害"}
obj["INCOMING_DAMAGE_CRIT"]					= { label="近戰爆擊", tooltip="顯示被近戰爆擊"}
obj["INCOMING_MISS"]						= { label="近戰未命中", tooltip="顯示未被近戰命中"}
obj["INCOMING_DODGE"]						= { label="近戰閃躲", tooltip="顯示閃躲近戰攻擊"}
obj["INCOMING_PARRY"]						= { label="近戰招架", tooltip="顯示招架近戰攻擊"}
obj["INCOMING_BLOCK"]						= { label="近戰格擋", tooltip="顯示格擋近戰攻擊"}
obj["INCOMING_DEFLECT"]						= { label="近戰偏斜", tooltip="顯示偏斜近戰攻擊"}
obj["INCOMING_ABSORB"]						= { label="近戰吸收", tooltip="顯示吸收近戰傷害"}
obj["INCOMING_IMMUNE"]						= { label="近戰免疫", tooltip="顯示免疫近戰傷害"}
obj["INCOMING_SPELL_DAMAGE"]				= { label="技能傷害", tooltip="顯示被技能傷害"}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="技能爆擊", tooltip="顯示被技能爆擊"}
obj["INCOMING_SPELL_DOT"]					= { label="技能持續傷害", tooltip="顯示被技能持續傷害"}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="技能持續傷害暴擊", tooltip="顯示被技能持續傷害暴擊."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="傷害護盾傷害", tooltip="顯示被傷害護盾傷害."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="傷害護盾爆擊", tooltip="顯示傷被害護盾爆擊."}
obj["INCOMING_SPELL_MISS"]					= { label="技能未命中", tooltip="顯示未被技能命中"}
obj["INCOMING_SPELL_DODGE"]					= { label="技能閃躲", tooltip="顯示閃躲技能攻擊"}
obj["INCOMING_SPELL_PARRY"]					= { label="技能招架", tooltip="顯示招架技能攻擊"}
obj["INCOMING_SPELL_BLOCK"]					= { label="技能格擋", tooltip="顯示格擋技能攻擊"}
obj["INCOMING_SPELL_DEFLECT"]				= { label="技能偏斜", tooltip="顯示偏斜技能"}
obj["INCOMING_SPELL_RESIST"]				= { label="法術抵抗", tooltip="顯示抵抗法術攻擊"}
obj["INCOMING_SPELL_ABSORB"]				= { label="技能吸收", tooltip="顯示吸收技能傷害"}
obj["INCOMING_SPELL_IMMUNE"]				= { label="技能免疫", tooltip="顯示免疫技能傷害"}
obj["INCOMING_SPELL_REFLECT"]				= { label="技能反射", tooltip="顯示反射技能傷害"}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="法術打斷", tooltip="顯示打斷法術"}
obj["INCOMING_HEAL"]						= { label="治療", tooltip="顯示被治療"}
obj["INCOMING_HEAL_CRIT"]					= { label="爆擊治療", tooltip="顯示被治療爆擊"}
obj["INCOMING_HOT"]							= { label="持續治療", tooltip="顯示被持續治療"}
obj["INCOMING_HOT_CRIT"]					= { label="持續治療暴擊", tooltip="顯示持續治療暴擊"}
obj["INCOMING_ENVIRONMENTAL"]				= { label="環境傷害", tooltip="顯示環境傷害（如跌落，窒息，熔岩等）"}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="近戰傷害", tooltip="顯示寵物被近戰傷害"}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="近戰爆擊", tooltip="顯示寵物被近戰爆擊"}
obj["PET_INCOMING_MISS"]						= { label="近戰未命中", tooltip="顯示寵物未被近戰命中"}
obj["PET_INCOMING_DODGE"]						= { label="近戰閃躲", tooltip="顯示寵物閃躲近戰攻擊"}
obj["PET_INCOMING_PARRY"]						= { label="近戰招架", tooltip="顯示寵物招架近戰攻擊"}
obj["PET_INCOMING_BLOCK"]						= { label="近戰格擋", tooltip="顯示寵物格擋近戰攻擊"}
obj["PET_INCOMING_DEFLECT"]						= { label="近戰偏斜", tooltip="顯示寵物偏斜近戰攻擊"}
obj["PET_INCOMING_ABSORB"]						= { label="近戰吸收", tooltip="顯示寵物吸收近戰傷害"}
obj["PET_INCOMING_IMMUNE"]						= { label="近戰免疫", tooltip="顯示寵物免疫近戰傷害"}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="技能傷害", tooltip="顯示寵物被技能傷害"}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="技能爆擊", tooltip="顯示寵物被技能爆擊"}
obj["PET_INCOMING_SPELL_DOT"]					= { label="技能持續傷害", tooltip="顯示寵物被技能持續傷害"}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="技能持續傷害暴擊", tooltip="顯示寵物被技能持續傷害暴擊."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="傷害護盾傷害", tooltip="顯示寵物被傷害護盾的傷害."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="傷害護盾爆擊", tooltip="顯示寵物被傷害護盾的爆擊."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="技能未命中", tooltip="顯示寵物未被技能命中"}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="技能閃躲", tooltip="顯示寵物閃躲技能攻擊"}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="技能招架", tooltip="顯示寵物招架技能攻擊"}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="技能格擋", tooltip="顯示寵物格擋技能攻擊"}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="技能偏斜", tooltip="顯示寵物近戰技能"}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="法術抵抗", tooltip="顯示寵物抵抗法術攻擊"}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="技能吸收", tooltip="顯示寵物吸收技能傷害"}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="技能免疫", tooltip="顯示寵物免疫技能傷害"}
obj["PET_INCOMING_HEAL"]						= { label="治療", tooltip="顯示寵物被治療"}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="治療爆擊", tooltip="顯示寵物被治療爆擊"}
obj["PET_INCOMING_HOT"]							= { label="持續治療", tooltip="顯示寵物被持續治療"}
obj["PET_INCOMING_HOT_CRIT"]					= { label="持續治療暴擊", tooltip="顯示寵物持續治療暴擊"}


------------------------------
-- Outgoing events
------------------------------

obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="近戰傷害", tooltip="顯示對敵近戰傷害"}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="近戰爆擊", tooltip="顯示對敵近戰爆擊"}
obj["OUTGOING_MISS"]						= { label="近戰未命中", tooltip="顯示近戰未命中敵人"}
obj["OUTGOING_DODGE"]						= { label="近戰閃躲", tooltip="顯示敵人閃躲近戰攻擊"}
obj["OUTGOING_PARRY"]						= { label="近戰招架", tooltip="顯示敵人招架近戰攻擊"}
obj["OUTGOING_BLOCK"]						= { label="近戰格擋", tooltip="顯示敵人格擋近戰攻擊"}
obj["OUTGOING_DEFLECT"]						= { label="近戰偏斜", tooltip="顯示敵人偏斜近戰攻擊"}
obj["OUTGOING_ABSORB"]						= { label="近戰吸收", tooltip="顯示敵人吸收近戰傷害"}
obj["OUTGOING_IMMUNE"]						= { label="近戰免疫", tooltip="顯示敵人免疫近戰傷害"}
obj["OUTGOING_EVADE"]						= { label="近戰閃避", tooltip="顯示敵人閃避近戰攻擊"}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="技能傷害", tooltip="顯示技能傷害敵人"}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="技能爆擊", tooltip="顯示技能爆擊敵人"}
obj["OUTGOING_SPELL_DOT"]					= { label="技能持續傷害", tooltip="顯示技能持續傷害敵人"}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="技能持續傷害暴擊", tooltip="顯示輸出技能持續傷害暴擊."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="傷害護盾傷害", tooltip="顯示傷害護盾的傷害."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="傷害護盾爆擊", tooltip="顯示傷害護盾的爆擊."}
obj["OUTGOING_SPELL_MISS"]					= { label="技能未命中", tooltip="顯示技能未命中敵人"}
obj["OUTGOING_SPELL_DODGE"]					= { label="技能閃躲", tooltip="顯示敵人閃躲技能攻擊"}
obj["OUTGOING_SPELL_PARRY"]					= { label="技能招架", tooltip="顯示敵人招架技能攻擊"}
obj["OUTGOING_SPELL_BLOCK"]					= { label="技能格擋", tooltip="顯示敵人格擋技能攻擊"}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="技能偏斜", tooltip="顯示敵人偏斜技能"}
obj["OUTGOING_SPELL_RESIST"]				= { label="法術抵抗", tooltip="顯示敵人抵抗法術攻擊"}
obj["OUTGOING_SPELL_ABSORB"]				= { label="技能吸收", tooltip="顯示敵人吸收法術傷害"}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="技能免疫", tooltip="顯示敵人免疫技能傷害"}
obj["OUTGOING_SPELL_REFLECT"]				= { label="技能反射", tooltip="顯示敵人反射技能傷害"}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="法術打斷", tooltip="顯示法術攻擊被打斷"}
obj["OUTGOING_SPELL_EVADE"]					= { label="技能閃避", tooltip="顯示技能攻擊被閃避"}
obj["OUTGOING_HEAL"]						= { label="治療", tooltip="顯示治療目標"}
obj["OUTGOING_HEAL_CRIT"]					= { label="治療爆擊", tooltip="顯示爆擊治療目標"}
obj["OUTGOING_HOT"]							= { label="持續治療", tooltip="顯示持續治療目標"}
obj["OUTGOING_HOT_CRIT"]					= { label="持續治療暴擊", tooltip="顯示持續治療暴擊."}
obj["OUTGOING_DISPEL"]						= { label="淨化法術", tooltip="顯示你的淨化法術"}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="近戰傷害", tooltip="顯示寵物近戰傷害"}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="近戰爆擊", tooltip="顯示寵物近戰爆擊"}
obj["PET_OUTGOING_MISS"]						= { label="近戰未命中", tooltip="顯示寵物的近戰攻擊未命中敵人"}
obj["PET_OUTGOING_DODGE"]						= { label="近戰閃躲", tooltip="顯示寵物的近戰攻擊被閃躲"}
obj["PET_OUTGOING_PARRY"]						= { label="近戰招架", tooltip="顯示寵物的近戰攻擊被招架"}
obj["PET_OUTGOING_BLOCK"]						= { label="近戰格擋", tooltip="顯示寵物的近戰攻擊被格擋"}
obj["PET_OUTGOING_DEFLECT"]						= { label="近戰偏斜", tooltip="顯示寵物的近戰攻擊偏斜"}
obj["PET_OUTGOING_ABSORB"]						= { label="近戰吸收", tooltip="顯示寵物的近戰傷害被吸收"}
obj["PET_OUTGOING_IMMUNE"]						= { label="近戰免疫", tooltip="顯示寵物的近戰傷害被免疫"}
obj["PET_OUTGOING_EVADE"]						= { label="近戰閃避", tooltip="顯示寵物的近戰攻擊被閃避"}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="技能傷害", tooltip="顯示寵物的技能傷害"}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="技能爆擊", tooltip="顯示寵物的技能爆擊"}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="技能持續傷害", tooltip="顯示寵物技能的持續傷害"}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="技能持續傷害暴擊", tooltip="顯示寵物的技能持續傷害暴擊."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="傷害護盾傷害", tooltip="顯示寵物的傷害護盾的傷害."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="傷害護盾爆擊", tooltip="顯示寵物的傷害護盾的爆擊."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="技能未命中", tooltip="顯示寵物技能攻擊未命中敵人"}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="技能閃躲", tooltip="顯示寵物的技能攻擊被閃躲"}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="技能招架", tooltip="顯示寵物的技能攻擊被招架"}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="技能格擋", tooltip="顯示寵物的技能攻擊被格擋"}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="技能偏斜", tooltip="顯示寵物的技能偏斜"}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="法術抵抗", tooltip="顯示寵物的法術攻擊被抵抗"}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="技能吸收", tooltip="顯示寵物的技能傷害被吸收"}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="技能免疫", tooltip="顯示寵物的技能傷害被免疫"}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="技能閃避", tooltip="顯示寵物的技能攻擊被閃避"}
obj["PET_OUTGOING_HEAL"]						= { label="治療", tooltip="顯示寵物治療"}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="治療暴擊", tooltip="顯示寵物治療暴擊"}
obj["PET_OUTGOING_HOT"]							= { label="持續治療", tooltip="顯示寵物持續治療"}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="持續治療暴擊", tooltip="顯示寵物持續治療暴擊"}
obj["PET_OUTGOING_DISPEL"]						= { label="淨化法術", tooltip="顯示寵物的淨化法術"}


------------------------------
-- Notification events
------------------------------

obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="Debuff", tooltip="顯示你遭受的Debuff"}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="Debuff堆疊", tooltip="顯示Debuff堆疊數量"}
obj["NOTIFICATION_BUFF"]				= { label="Buff", tooltip="顯示你得到的Buff"}
obj["NOTIFICATION_BUFF_STACK"]			= { label="Buff堆疊", tooltip="顯示Buff堆疊數量"}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="物品Buff", tooltip="顯示使用物品得到的Buff"}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="Debuff消失", tooltip="顯示從你身上消失的Debuff"}
obj["NOTIFICATION_BUFF_FADE"]			= { label="Buff消失", tooltip="顯示從你身上消失的Buff"}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="物品Buff消失", tooltip="顯示從你身上消失的物品Buff"}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="戰鬥開始", tooltip="顯示你已經開始戰鬥"}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="戰鬥結束", tooltip="顯示你已經結束了戰鬥"}
obj["NOTIFICATION_POWER_GAIN"]			= { label="能量獲得", tooltip="顯示你額外獲得的法力，怒氣或者能量"}
obj["NOTIFICATION_POWER_LOSS"]			= { label="能量失去", tooltip="顯示你失去的法力，怒氣或者能量"}
--obj["NOTIFICATION_ALT_POWER_GAIN"]		= { label="Alternate Power Gains", tooltip="Enable when you gain alternate power such as sound level on Atramedes."}
--obj["NOTIFICATION_ALT_POWER_LOSS"]		= { label="Alternate Power Losses", tooltip="Enable when you lose alternate power from drains."}
--obj["NOTIFICATION_CHI_CHANGE"]			= { label="Chi Changes", tooltip="Enable when you change chi."}
--obj["NOTIFICATION_CHI_FULL"]			= { label="Chi Full", tooltip="Enable when you attain full chi."}
obj["NOTIFICATION_CP_GAIN"]				= { label="連擊點獲得", tooltip="顯示你獲得的連擊點"}
obj["NOTIFICATION_CP_FULL"]				= { label="連擊點全滿", tooltip="顯示你的連擊點已滿"}
obj["NOTIFICATION_HOLY_POWER_CHANGE"]	= { label="神聖能量變化", tooltip="顯示你神聖能量的變化"}
obj["NOTIFICATION_HOLY_POWER_FULL"]		= { label="神聖能量已滿", tooltip="顯示你神聖能量已滿"}
--obj["NOTIFICATION_SHADOW_ORBS_CHANGE"]	= { label="Shadow Orb Changes", tooltip="Enable when you change shadow orbs."}
--obj["NOTIFICATION_SHADOW_ORBS_FULL"]	= { label="Shadow Orbs Full", tooltip="Enable when you attain full shadow orbs."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="獲得榮譽", tooltip="顯示你獲得榮譽"}
obj["NOTIFICATION_REP_GAIN"]			= { label="聲望提高", tooltip="顯示你的聲望提高"}
obj["NOTIFICATION_REP_LOSS"]			= { label="聲望下降", tooltip="顯示你的聲望下降"}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="獲得技能點", tooltip="顯示你獲得了技能點"}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="獲得經驗", tooltip="顯示你獲得了經驗值"}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="擊殺玩家", tooltip="顯示你擊殺了一個敵對玩家"}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="擊殺NPC", tooltip="顯示你擊殺了一個敵對NPC"}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="額外攻擊", tooltip="顯示你從風怒，痛擊之刃，劍系掌握等方面獲得了一次額外攻擊"}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="敵人獲得Buff", tooltip="顯示目前敵對目標獲得的Buff"}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="怪物表情", tooltip="顯示目前目標怪物表情"}


------------------------------
-- Trigger info
------------------------------

-- Main events.
obj = L.TRIGGER_DATA
obj["SWING_DAMAGE"]				= "平砍傷害"
obj["RANGE_DAMAGE"]				= "遠程傷害"
obj["SPELL_DAMAGE"]				= "技能傷害"
obj["GENERIC_DAMAGE"]			= "平砍/遠程/技能傷害"
obj["SPELL_PERIODIC_DAMAGE"]	= "周期性技能傷害(DoT)"
obj["DAMAGE_SHIELD"]			= "傷害護盾傷害"
obj["DAMAGE_SPLIT"]				= "分攤傷害"
obj["ENVIRONMENTAL_DAMAGE"]		= "環境傷害"
obj["SWING_MISSED"]				= "平砍未命中"
obj["RANGE_MISSED"]				= "遠程未命中"
obj["SPELL_MISSED"]				= "技能未命中"
obj["GENERIC_MISSED"]			= "平砍/遠程/技能未命中"
obj["SPELL_PERIODIC_MISSED"]	= "周期性技能未命中"
obj["SPELL_DISPEL_FAILED"]		= "驅散失敗"
obj["DAMAGE_SHIELD_MISSED"]		= "傷害護盾未命中"
obj["SPELL_HEAL"]				= "治療"
obj["SPELL_PERIODIC_HEAL"]		= "周期性治療(HoT)"
obj["SPELL_ENERGIZE"]			= "能量獲取"
obj["SPELL_PERIODIC_ENERGIZE"]	= "周期性能量獲取"
obj["SPELL_DRAIN"]				= "能量消耗"
obj["SPELL_PERIODIC_DRAIN"]		= "周期性能量消耗"
obj["SPELL_LEECH"]				= "能量吸取"
obj["SPELL_PERIODIC_LEECH"]		= "周期性能量吸取"
obj["SPELL_INTERRUPT"]			= "技能打斷"
obj["SPELL_AURA_APPLIED"]		= "獲得光環"
obj["SPELL_AURA_REMOVED"]		= "光環消失"
obj["SPELL_STOLEN"]				= "偷取光環"
obj["SPELL_DISPEL"]				= "光環被驅散"
obj["SPELL_AURA_REFRESH"]		= "光環刷新"
obj["SPELL_AURA_BROKEN_SPELL"]	= "光環打破"
obj["ENCHANT_APPLIED"]			= "附魔效果觸發"
obj["ENCHANT_REMOVED"]			= "附魔效果消失"
obj["SPELL_CAST_START"]			= "開始施法"
obj["SPELL_CAST_SUCCESS"]		= "施法成功"
obj["SPELL_CAST_FAILED"]		= "施法失敗"
obj["SPELL_SUMMON"]				= "召喚"
obj["SPELL_CREATE"]				= "創造"
obj["PARTY_KILL"]				= "隊友擊殺"
obj["UNIT_DIED"]				= "單位死亡"
obj["UNIT_DESTROYED"]			= "單位被摧毀"
obj["SPELL_EXTRA_ATTACKS"]		= "額外攻擊"
obj["UNIT_HEALTH"]				= "生命值改變"
obj["UNIT_POWER"]				= "法力值改變"
obj["SKILL_COOLDOWN"]			= "技能冷卻完成"
obj["PET_COOLDOWN"]				= "寵物技能冷卻完成"
obj["ITEM_COOLDOWN"]			= "物品冷卻完成"
 
-- Main event conditions.
obj["sourceName"]				= "來源玩家名字"
obj["sourceAffiliation"]		= "來源玩家聯系"
obj["sourceReaction"]			= "來源玩家反應"
obj["sourceControl"]			= "來源玩家控制"
obj["sourceUnitType"]			= "來源玩家類型"
obj["recipientName"]			= "接受玩家名字"
obj["recipientAffiliation"]		= "接受玩家聯系"
obj["recipientReaction"]		= "接受玩家反應"
obj["recipientControl"]			= "接受玩家控制"
obj["recipientUnitType"]		= "接受玩家類型"
obj["skillID"]					= "技能 ID"
obj["skillName"]				= "技能名字"
obj["skillSchool"]				= "技能類型"
obj["extraSkillID"]				= "額外技能 ID"
obj["extraSkillName"]			= "額外技能名字"
obj["extraSkillSchool"]			= "額外技能類型"
obj["amount"]					= "總數"
obj["overkillAmount"]			= "極限殺戮總數"
obj["damageType"]				= "傷害類型"
obj["resistAmount"]				= "抵抗總數"
obj["blockAmount"]				= "格擋總數"
obj["absorbAmount"]				= "吸收總數"
obj["isCrit"]					= "暴擊"
obj["isGlancing"]				= "偏斜"
obj["isCrushing"]				= "致命攻擊"
obj["extraAmount"]				= "額外總數"
obj["missType"]					= "未命中類型"
obj["hazardType"]				= "危害類型"
obj["powerType"]				= "能量類型"
obj["auraType"]					= "光環類型"
obj["threshold"]				= "起點閥值"
obj["unitID"]					= "玩家 ID"
obj["unitReaction"]				= "玩家反應"
obj["itemID"]					= "物品 ID"
obj["itemName"]					= "物品名字"

-- Exception conditions.
obj["activeTalents"]			= "啟用天賦"
obj["buffActive"]				= "Buff生效"
obj["buffInactive"]				= "Buff失效"
obj["currentCP"]				= "當前連擊點"
obj["currentPower"]				= "當前能量"
obj["inCombat"]					= "戰斗中"
obj["recentlyFired"]			= "觸發器最近被觸發"
obj["trivialTarget"]			= "無效目標"
obj["unavailableSkill"]			= "不可用技能"
obj["warriorStance"]			= "戰士姿態"
obj["zoneName"]					= "地區名字"
obj["zoneType"]					= "地區類型"

-- Relationships.
obj["eq"]						= "相等"
obj["ne"]						= "不相等"
obj["like"]						= "像"
obj["unlike"]					= "不像"
obj["lt"]						= "少于"
obj["gt"]						= "多于"
 
-- Affiliations.
obj["affiliationMine"]			= "我的"
obj["affiliationParty"]			= "隊友"
obj["affiliationRaid"]			= "團隊成員r"
obj["affiliationOutsider"]		= "其他"
obj["affiliationTarget"]		= TARGET
obj["affiliationFocus"]			= FOCUS
obj["affiliationYou"]			= YOU

-- Reactions.
obj["reactionFriendly"]			= "友善"
obj["reactionNeutral"]			= "中立"
obj["reactionHostile"]			= HOSTILE

-- Control types.
obj["controlServer"]			= "服務器"
obj["controlHuman"]				= "玩家"

-- Unit types.
obj["unitTypePlayer"]			= PLAYER 
obj["unitTypeNPC"]				= "NPC"
obj["unitTypePet"]				= PET
obj["unitTypeGuardian"]			= "護衛"
obj["unitTypeObject"]			= "物體"

-- Aura types.
obj["auraTypeBuff"]				= "Buff"
obj["auraTypeDebuff"]			= "Debuff"

-- Zone types.
obj["zoneTypeArena"]			= "競技場"
obj["zoneTypePvP"]				= BATTLEGROUND
obj["zoneTypeParty"]			= "小隊副本"
obj["zoneTypeRaid"]				= "團隊副本"

-- Booleans
obj["booleanTrue"]				= "True"
obj["booleanFalse"]				= "False"


------------------------------
-- Font info
------------------------------

-- Font outlines.
obj = L.OUTLINES
obj[1] = "無"
obj[2] = "細"
obj[3] = "粗"
obj[4] = "單線"
obj[5] = "單線 細"
obj[6] = "單線 粗"

-- Text aligns.
obj = L.TEXT_ALIGNS
obj[1] = "左邊"
obj[2] = "中間"
obj[3] = "右邊"


------------------------------
-- Sound info
------------------------------

obj = L.SOUNDS
obj["MSBT Low Mana"]	= "MSBT 法力過低"
obj["MSBT Low Health"]	= "MSBT 生命過低"
obj["MSBT Cooldown"]	= "MSBT 冷卻"


------------------------------
-- Animation style info
------------------------------

-- Animation styles
obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "V型"
obj["Horizontal"]	= "水平"
obj["Parabola"]		= "拋物線"
obj["Straight"]		= "直線"
obj["Static"]		= "靜止"
obj["Pow"]			= "繃跳"

-- Animation style directions.
obj["Alternate"]	= "交替"
obj["Left"]			= "左"
obj["Right"]		= "右"
obj["Up"]			= "上"
obj["Down"]			= "下"

-- Animation style behaviors.
obj["AngleUp"]			= "V型向上"
obj["AngleDown"]		= "V型向下"
obj["GrowUp"]			= "漸漸向上"
obj["GrowDown"]			= "漸漸向下"
obj["CurvedLeft"]		= "弧形向左"
obj["CurvedRight"]		= "弧形向右"
obj["Jiggle"]			= "抖動"
obj["Normal"]			= "一般"