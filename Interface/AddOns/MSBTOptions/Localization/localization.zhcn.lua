----------------------------------------------------------------------------
-- Title: MSBT Options Simplified Chinese Localization
-- Author: Mikord
-- Simplified Chinese Translation by:
--	elafor
--	hscui
--	yaroot#gmail_com
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't Simplified Chinese.
if (GetLocale() ~= "zhCN") then return end

-- Local reference for faster access.
local L = MikSBT.translations

-------------------------------------------------------------------------------
-- Simplified Chinese localization
-------------------------------------------------------------------------------


------------------------------
-- Interface messages
------------------------------

L.MSG_CUSTOM_FONTS					= "自定义字体"
L.MSG_INVALID_CUSTOM_FONT_NAME		= "无效字体名."
L.MSG_FONT_NAME_ALREADY_EXISTS		= "字体名字已经存在."
L.MSG_INVALID_CUSTOM_FONT_PATH		= "字体路径必须指向.ttf文件"
L.MSG_UNABLE_TO_SET_FONT			= "无法使用指定字体." 
--L.MSG_TESTING_FONT			= "Testing the specified font for validity..."
L.MSG_CUSTOM_SOUNDS					= "自定义声音"
L.MSG_INVALID_CUSTOM_SOUND_NAME		= "无效声音名"
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "声音名已经存在"
L.MSG_NEW_PROFILE					= "新建配置"
L.MSG_PROFILE_ALREADY_EXISTS		= "此配置文件已存在"
L.MSG_INVALID_PROFILE_NAME			= "无效的配置名字"
L.MSG_NEW_SCROLL_AREA				= "新建滚动区域"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "此滚动区域已存在"
L.MSG_INVALID_SCROLL_AREA_NAME		= "无效的滚动区名字"
L.MSG_ACKNOWLEDGE_TEXT				= "你确定想这样做吗？"
L.MSG_NORMAL_PREVIEW_TEXT			= "普通文字"
L.MSG_INVALID_SOUND_FILE			= "声音必须为OGG文件"
L.MSG_NEW_TRIGGER					= "新建触发器"
L.MSG_TRIGGER_CLASSES				= "触发种类"
L.MSG_MAIN_EVENTS					= "主要事件"
L.MSG_TRIGGER_EXCEPTIONS			= "触发器例外"
L.MSG_EVENT_CONDITIONS				= "事件条件"
L.MSG_DISPLAY_QUALITY				= "当物品为此品质时显示提示"
L.MSG_SKILLS						= "技能"
L.MSG_SKILL_ALREADY_EXISTS			= "技能名字已存在"
L.MSG_INVALID_SKILL_NAME			= "无效的技能名字"
L.MSG_HOSTILE						= "敌对"
L.MSG_ANY							= "任何"
L.MSG_CONDITION						= "条件"
L.MSG_CONDITIONS					= "条件"
L.MSG_ITEM_QUALITIES				= "物品品质"
L.MSG_ITEMS							= "物品"
L.MSG_ITEM_ALREADY_EXISTS			= "物品名已经存在."
L.MSG_INVALID_ITEM_NAME				= "无效物品名."


------------------------------
-- Interface tabs
------------------------------

obj = L.TABS
obj["customMedia"]	= { label="自定义媒体文件", tooltip="设置自定义媒体文件"}
obj["general"]		= { label="常规", tooltip="常规设置"}
obj["scrollAreas"]	= { label="滚动区域", tooltip="创建、删除和配置滚动区域；鼠标指向按钮可得到更多提示"}
obj["events"]		= { label="事件", tooltip="设置承受伤害、输出伤害和通告的事件；鼠标指向按钮可得到更多提示"}
obj["triggers"]		= { label="触发器", tooltip="设置触发器；鼠标指向按钮可得到更多提示"}
obj["spamControl"]	= { label="预防刷屏", tooltip="设置对可能造成刷屏的信息进行控制"}
obj["cooldowns"]	= { label="冷却通告", tooltip="设置冷却通告"}
obj["lootAlerts"]	= { label="拾取通告", tooltip="设置与拾取有关的通告"}
obj["skillIcons"]	= { label="技能图标", tooltip="设置技能图标"}


------------------------------
-- Interface checkboxes
------------------------------

obj = L.CHECKBOXES
obj["enableMSBT"]				= { label="启用MSBT", tooltip="启用MSBT"}
obj["stickyCrits"]				= { label="爆击粘滞显示", tooltip="使用粘滞样式显示爆击"}
obj["enableSounds"]				= { label="启用声音", tooltip="当指定事件和触发器发生时播放声音"}
obj["textShadowing"]			= { label="字体阴影", tooltip="显示字体阴影效果让它们看起来更爽"}
obj["colorPartialEffects"]		= { label="特效着色", tooltip="给某些特殊战斗效果的信息着色"}
obj["crushing"]					= { label="碾压", tooltip="显示碾压提示"}
obj["glancing"]					= { label="偏斜", tooltip="显示偏斜提示"}
obj["absorb"]					= { label="部分吸收", tooltip="显示部分吸收数值"}
obj["block"]					= { label="部分格挡", tooltip="显示部分格挡数值"}
obj["resist"]					= { label="部分抵抗", tooltip="显示部分抵抗数值"}
obj["vulnerability"]			= { label="易伤加成", tooltip="显示易伤加成数值"}
obj["overheal"]					= { label="过量治疗", tooltip="显示过量治疗数值"}
obj["overkill"]					= { label="灭绝", tooltip="显示灭绝总数."}
obj["colorDamageAmounts"]		= { label="伤害数值着色", tooltip="为伤害值着色"}
obj["colorDamageEntry"]			= { tooltip="为此类伤害着色"}
obj["colorUnitNames"]			= { label="名字着色", tooltip="名字使用职业颜色着色."}
obj["colorClassEntry"]			= { tooltip="启用此职业的颜色."}
obj["enableScrollArea"]			= { tooltip="启用滚动区域"}
obj["inheritField"]				= { label="继承", tooltip="继承此区域的值，不勾选则无效"}
obj["hideSkillIcons"]			= { label="隐藏图标", tooltip="滚动区域不显示图标."}
obj["stickyEvent"]				= { label="始终粘滞", tooltip="总是使用粘滞样式显示事件"}
obj["enableTrigger"]			= { tooltip="启用触发器"}
obj["allPowerGains"]			= { label="所有能量获取", tooltip="显示所有获取的能量包括那些战斗日志中不显示的。警告：这个选项将会大量刷屏同时无视能量阈值和抑制显示设置\n不推荐"}
obj["abbreviateSkills"]			= { label="技能简称", tooltip="简缩技能名字（仅适用于英文版）。若事件描述中加入“%sl”代码，此选项即失效"}
obj["mergeSwings"]				= { label="合并普通攻击", tooltip="合并极短时间内的普通攻击伤害"}
--obj["shortenNumbers"]			= { label="Shorten Numbers", tooltip="Display numbers in an abbreviated format (example: 32765 -> 33k)."}
--obj["groupNumbers"]				= { label="Group By Thousands", tooltip="Display numbers grouped by thousands (example: 32765 -> 32,765)."}
obj["hideSkills"]				= { label="隐藏技能", tooltip="在承受伤害和输出伤害中不显示技能名字。开启此选项将使你失去某些事件自定义功能，因为它会忽略“%s”代码"}
obj["hideNames"]				= { label="隐藏名字", tooltip="在承受伤害和输出伤害中不显示单位名字。开启此选项将使你失去某些事件自定义功能，因为它会忽略“%n”代码"}
obj["hideFullOverheals"]		= { label="隐藏全部过量的治疗", tooltip="不显示全部过量的治疗."}
obj["hideFullHoTOverheals"]		= { label="隐藏全部溢出的持续治疗", tooltip="不显示全部溢出的储蓄治疗"}
obj["hideMergeTrailer"]			= { label="隐藏合并攻击细节", tooltip="不在合并攻击后显示被合并的攻击次数及暴击详情"}
obj["allClasses"]				= { label="所有职业"}
obj["enablePlayerCooldowns"]	= { label="技能冷却", tooltip="在技能冷却完成之后显示提示信息"}
obj["enablePetCooldowns"]		= { label="宠物技能冷却", tooltip="在宠物技能冷却完成之后显示提示信息"}
obj["enableItemCooldowns"]		= { label="物品冷却", tooltip="在物品冷却完成后显示提示信息."}
obj["lootedItems"]				= { label="拾取物品", tooltip="显示物品拾取."}
obj["moneyGains"]				= { label="获得金钱", tooltip="显示获得的金钱"}
obj["alwaysShowQuestItems"]		= { label="总是显示任务物品", tooltip="总是显示任务物品, 无论其是何品质."}
obj["enableIcons"]				= { label="启用技能图标", tooltip="如果可能，在技能旁显示图标"}
obj["exclusiveSkills"]			= { label="否则仅显示技能名字", tooltip="如果没有图标，就只显示技能名字"}


------------------------------
-- Interface dropdowns
------------------------------

obj = L.DROPDOWNS
obj["profile"]				= { label="当前配置文件：", tooltip="设置当前配置文件"}
obj["normalFont"]			= { label="普通字体：", tooltip="选择非爆击伤害的字体"}
obj["critFont"]				= { label="爆击字体：", tooltip="选择爆击伤害的字体"}
obj["normalOutline"]		= { label="普通字体描边：", tooltip="选择非爆击伤害字体的描边样式"}
obj["critOutline"]			= { label="爆击字体描边：", tooltip="选择爆击伤害字体的描边样式"}
obj["scrollArea"]			= { label="滚动区域：", tooltip="选择滚动区域进行配置"}
obj["sound"]				= { label="声音：", tooltip="选择事件发生时播放的声音"}
obj["animationStyle"]		= { label="动画样式：", tooltip="滚动区域内非粘滞的动画样式"}
obj["stickyAnimationStyle"]	= { label="粘滞样式：", tooltip="滚动区域内粘滞的动画样式"}
obj["direction"]			= { label="方向：", tooltip="动画的方向"}
obj["behavior"]				= { label="特效：", tooltip="动画的特效"}
obj["textAlign"]			= { label="文本排列：", tooltip="动画中文本的排列方式"}
obj["iconAlign"]			= { label="图标排列:", tooltip="图标相对于文本的位置."}
obj["eventCategory"]		= { label="事件种类：", tooltip="设置事件种类"}
obj["outputScrollArea"]		= { label="输出滚动区域：", tooltip="选择输出伤害滚动区域"}
obj["mainEvent"]			= { label="主要事件:"}
obj["triggerCondition"]		= { label="条件:", tooltip="测试条件."}
obj["triggerRelation"]		= { label="关系:"}
obj["triggerParameter"]		= { label="参数:"}


------------------------------
-- Interface buttons
------------------------------

obj = L.BUTTONS
obj["addCustomFont"]			= { label="添加字体", tooltip="向字体列表添加自定义字体.\n\n警告: 字体文件必须 *在WOW运行之前* 就放置在目标文件夹内.\n\n推荐将其放置在 MikScrollingBattleText\\Fonts 文件夹."}
obj["addCustomSound"]			= { label="添加声音", tooltip="想声音列表添加自定义声音.\n\n警告: 声音文件必须 *在WOW运行之前* 就放置在目标文件夹内.\n\n推荐将其放置在 MikScrollingBattleText\\Sounds 文件夹."}
obj["editCustomFont"]			= { tooltip="点击编辑自定义字体."}
obj["deleteCustomFont"]			= { tooltip="点击将此字体从MSBT中移除."}
obj["editCustomSound"]			= { tooltip="点击编辑自定义声音."}
obj["deleteCustomSound"]		= { tooltip="点击将此声音从MSBT中移除."}
obj["copyProfile"]				= { label="复制配置", tooltip="复制配置文件到新建的配置中"}
obj["resetProfile"]				= { label="重置配置", tooltip="重置配置至默认设置"}
obj["deleteProfile"]			= { label="删除配置", tooltip="删除配置文件"}
obj["masterFont"]				= { label="主要字体", tooltip="设置主要字体样式；除非另有指定，否则所有的滚动区域和事件均将使用这种字体样式"}
obj["partialEffects"]			= { label="特效着色", tooltip="设置显示哪些特殊战斗效果以及着什么颜色"}
obj["damageColors"]				= { label="伤害着色", tooltip="设置是否为某种伤害数值着色以及着什么颜色"}
obj["classColors"]				= { label="职业颜色", tooltip="设置名字是否使用职业颜色着色和每种职业所用的颜色." }
obj["inputOkay"]				= { label=OKAY, tooltip="接受输入"}
obj["inputCancel"]				= { label=CANCEL, tooltip="取消输入"}
obj["genericSave"]				= { label=SAVE, tooltip="保存改变"}
obj["genericCancel"]			= { label=CANCEL, tooltip="取消改变"}
obj["addScrollArea"]			= { label="增加滚动区域", tooltip="增加一个新的滚动区域以包含事件和触发器"}
obj["configScrollAreas"]		= { label="设置滚动区域", tooltip="设置普通和粘滞动画效果，文本排列，滚动区域的宽度/高度，以及区域位置"}
obj["editScrollAreaName"]		= { tooltip="点击编辑滚动区域名字"}
obj["scrollAreaFontSettings"]	= { tooltip="点击设置字体；除非另有指定，否则此区域中所有事件均将使用这种字体样式显示"}
obj["deleteScrollArea"]			= { tooltip="点击删除此滚动区域"}
obj["scrollAreasPreview"]		= { label="预览", tooltip="预览效果"}
obj["toggleAll"]				= { label="开启/关闭所有事件", tooltip="开启/关闭所选事件分类中所有事件显示"}
obj["moveAll"]					= { label="移动所有事件", tooltip="移动所选事件分类中所有事件至指定滚动区域"}
obj["eventFontSettings"]		= { tooltip="点击设置此事件字体"}
obj["eventSettings"]			= { tooltip="点击设置事件效果比如输出区域，输出信息，播放声音等"}
obj["customSound"]				= { tooltip="点击选择自定义声音文件" }
obj["playSound"]				= { label="播放", tooltip="播放选定的声音."}
obj["addTrigger"]				= { label="增加新触发器", tooltip="增加新触发器"}
obj["triggerSettings"]			= { tooltip="点击设置触发条件"}
obj["deleteTrigger"]			= { tooltip="点击删除触发器"}
obj["editTriggerClasses"]		= { tooltip="点击编辑触发器使用职业"}
obj["addMainEvent"]				= { label="增加事件", tooltip="任何事件发生并且条件为真时, 触发器会触发, 除非存在例外条件."}
obj["addTriggerException"]		= { label="增加例外", tooltip="当任何一个例外成立时, 触发器不会被触发."}
obj["editEventConditions"]		= { tooltip="点击编辑事件的条件."}
obj["deleteMainEvent"]			= { tooltip="点击删除事件."}
obj["addEventCondition"]		= { label="增加条件", tooltip="当所有条件都成立时, 触发器会触发, 除非例外条件成立."}
obj["editCondition"]			= { tooltip="点击增加条件."}
obj["deleteCondition"]			= { tooltip="点击删除条件."}
obj["throttleList"]				= { label="抑制列表", tooltip="设置指定技能的自定义抑制时间"}
obj["mergeExclusions"]			= { label="防止合并", tooltip="防止指定技能的伤害数值合并"}
obj["skillSuppressions"]		= { label="技能缩写", tooltip="缩写技能名字"}
obj["skillSubstitutions"]		= { label="技能替换", tooltip="用自定义名称替换技能名字"}
obj["addSkill"]					= { label="增加技能", tooltip="增加新技能到列表中"}
obj["deleteSkill"]				= { tooltip="点击删除技能"}
obj["cooldownExclusions"]		= { label="冷却排除列表", tooltip="不追踪指定技能的冷却"}
obj["itemsAllowed"]				= { label="允许物品", tooltip="总是显示这些物品, 无论其是何物品品质."}
obj["itemExclusions"]			= { label="排除物品", tooltip="永远不显示这些物品."}
obj["addItem"]					= { label="增加物品", tooltip="向列表中增加新的物品."}
obj["deleteItem"]				= { tooltip="点击删除物品."}


------------------------------
-- Interface editboxes
------------------------------

obj = L.EDITBOXES
obj["customFontName"]	= { label="字体名:", tooltip="用来确定字体的名字.\n\n例如: 我的字体"}
obj["customFontPath"]	= { label="字体路径:", tooltip="字体文件的路径.\n\n注意: 如果文件在 MikScrollingBattleText\\Fonts 中的话, 只需要输入文件名就可以.\n\n例如: myFont.ttf "}
obj["customSoundName"]	= { label="音效名:", tooltip="用来确定音效的名字.\n\nExample: 我的音效"}
obj["customSoundPath"]	= { label="音效路径:", tooltip="音效文件的路径.\n\n注意: 如果文件在 MikScrollingBattleText\\Sounds 中的话, 只需要输入文件名就可以.\n\n例如: mySound.ogg "}
obj["copyProfile"]		= { label="新建配置：", tooltip="输入新建配置的名称"}
obj["partialEffect"]	= { tooltip="特效触发时的提示."}
obj["scrollAreaName"]	= { label="新建滚动区域:", tooltip="新建滚动区域的名称"}
obj["xOffset"]			= { label="X值：", tooltip="所选择滚动区域的X值"}
obj["yOffset"]			= { label="Y值：", tooltip="所选择滚动区域的Y值"}
obj["eventMessage"]		= { label="输出信息：", tooltip="事件发生时显示的信息"}
obj["soundFile"]		= { label="声音文件：", tooltip="事件发生时播放的声音"}
obj["iconSkill"]		= { label="技能图标：", tooltip="事件发生时, 法术的图标会被显示.\n\n如果没有指定, MSBT会自动选择一个合适的图标.\n\n注意: 法术ID必须被用来代替一个不在你法术书中的法术. 大多数数据库网站都可以用来查找."}
obj["skillName"]		= { label="技能名称：", tooltip="所增加的技能的名字"}
obj["substitutionText"]	= { label="替代文本：", tooltip="用来代替技能名字的文本"}
obj["itemName"]			= { label="物品名称:", tooltip="要添加物品的名字."}


------------------------------
-- Interface sliders
------------------------------

obj = L.SLIDERS
obj["animationSpeed"]		= { label="动画速度", tooltip="设置主动画速度\n每个滚动区域也可以设置自身独有的速度"}
obj["normalFontSize"]		= { label="普通字体大小", tooltip="设置非爆击字体的大小"}
obj["normalFontOpacity"]	= { label="普通字体不透明度", tooltip="设置非爆击字体的不透明度"}
obj["critFontSize"]			= { label="爆击字体大小", tooltip="设置爆击字体大小"}
obj["critFontOpacity"]		= { label="爆击字体不透明度", tooltip="设置爆击字体不透明度"}
obj["scrollHeight"]			= { label="滚动高度", tooltip="滚动区域高度"}
obj["scrollWidth"]			= { label="滚动宽度", tooltip="滚动区域宽度"}
obj["scrollAnimationSpeed"]	= { label="动画速度", tooltip="设置滚动区域内动画速度"}
obj["powerThreshold"]		= { label="能量阈值", tooltip="能量获得只有超过此值才会被显示"}
obj["healThreshold"]		= { label="治疗阈值", tooltip="治疗量只有超过此值才会被显示"}
obj["damageThreshold"]		= { label="伤害阈值", tooltip="伤害量只有超过此值才会被显示"}
obj["dotThrottleTime"]		= { label="持续伤害抑制显示", tooltip="在设定的秒数中造成的持续伤害将合并为一次显示"}
obj["hotThrottleTime"]		= { label="持续治疗抑制显示", tooltip="在设定的秒数中造成的持续治疗将合并为一次显示"}
obj["powerThrottleTime"]	= { label="能量抑制显示", tooltip="在设定的秒数中持续获得的能量将合并为一次显示"}
obj["skillThrottleTime"]	= { label="技能抑制显示", tooltip="在设定的秒数中持续使用的技能将只显示一次"}
obj["cooldownThreshold"]	= { label="冷却阈值", tooltip="冷却时间低于设定秒数的技能不会被显示"}


------------------------------
-- Event categories
------------------------------
obj = L.EVENT_CATEGORIES
obj[1] = "玩家受到伤害"
obj[2] = "宠物受到伤害"
obj[3] = "玩家输出伤害"
obj[4] = "宠物输出伤害"
obj[5] = "通告"


------------------------------
-- Event codes
------------------------------

obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - 受到伤害总数.\n"
obj["HEALING_TAKEN"]		= "%a - 受到治疗总数.\n"
obj["DAMAGE_DONE"]			= "%a - 输出伤害总数.\n"
obj["HEALING_DONE"]			= "%a - 输出治疗总数.\n"
obj["ABSORBED_AMOUNT"]		= "%a - 吸收伤害总数.\n"
obj["AURA_AMOUNT"]			= "%a - 光环的堆叠数量.\n"
obj["ENERGY_AMOUNT"]		= "%a - 能量总数.\n"
--obj["CHI_AMOUNT"]			= "%a - Amount of chi you have.\n"
obj["CP_AMOUNT"]			= "%a - 你的连击点总数.\n"
obj["HOLY_POWER_AMOUNT"]	= "%a - Amount of holy power you have.\n"
--obj["SHADOW_ORBS_AMOUNT"]	= "%a - Amount of shadow orbs you have.\n"
obj["HONOR_AMOUNT"]			= "%a - 荣誉总数.\n"
obj["REP_AMOUNT"]			= "%a - 声望总数.\n"
obj["ITEM_AMOUNT"]			= "%a - 拾取物品的数量.\n"
obj["SKILL_AMOUNT"]			= "%a - 技能点总数.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - 获得经验总数.\n"
obj["PARTIAL_AMOUNT"]		= "%a - 特效触发总数.\n"
obj["ATTACKER_NAME"]		= "%n - 攻击者名字.\n"
obj["HEALER_NAME"]			= "%n - 治疗者名字.\n"
obj["ATTACKED_NAME"]		= "%n - 被攻击者名字.\n"
obj["HEALED_NAME"]			= "%n - 被治疗者名字.\n"
obj["BUFFED_NAME"]			= "%n - 被Buff者名字.\n"
obj["UNIT_KILLED"]			= "%n - 被杀死的单位名字.\n"
obj["SKILL_NAME"]			= "%s - 技能名.\n"
obj["SPELL_NAME"]			= "%s - 法术名.\n"
obj["DEBUFF_NAME"]			= "%s - Debuff名.\n"
obj["BUFF_NAME"]			= "%s - Buff名.\n"
obj["ITEM_BUFF_NAME"]		= "%s - 物品Buff名.\n"
obj["EXTRA_ATTACKS"]		= "%s - 获得额外攻击的技能名.\n"
obj["SKILL_LONG"]			= "%sl - %s 全称. 用来缩写事件.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - 受到伤害类型.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - 输出伤害类型.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - 伤害来源 (掉落, 溺水, 岩浆, 等等...)\n"
obj["FACTION_NAME"]			= "%e - 声望阵营名.\n"
obj["EMOTE_TEXT"]			= "%e - 表情文字.\n"
obj["MONEY_TEXT"]			= "%e - 获取金钱文字.\n"
obj["COOLDOWN_NAME"]		= "%e - 就绪的法术名字.\n"
obj["ITEM_COOLDOWN_NAME"]	= "%e - 就绪的物品名字.\n"
obj["ITEM_NAME"]			= "%e - 拾取物品的名称.\n"
obj["POWER_TYPE"]			= "%p - 能力类别 (能量, 怒气, 法力).\n"
obj["TOTAL_ITEMS"]			= "%t - 拾取物品的总数."


------------------------------
-- Incoming events
------------------------------

obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="近战伤害", tooltip="显示被近战伤害"}
obj["INCOMING_DAMAGE_CRIT"]					= { label="近战爆击", tooltip="显示被近战爆击"}
obj["INCOMING_MISS"]						= { label="近战未命中", tooltip="显示未被近战命中"}
obj["INCOMING_DODGE"]						= { label="近战闪躲", tooltip="显示闪躲近战攻击"}
obj["INCOMING_PARRY"]						= { label="近战招架", tooltip="显示招架近战攻击"}
obj["INCOMING_BLOCK"]						= { label="近战格挡", tooltip="显示格挡近战攻击"}
obj["INCOMING_DEFLECT"]						= { label="近战偏斜", tooltip="显示偏斜近战攻击"}
obj["INCOMING_ABSORB"]						= { label="近战吸收", tooltip="显示吸收近战伤害"}
obj["INCOMING_IMMUNE"]						= { label="近战免疫", tooltip="显示免疫近战伤害"}
obj["INCOMING_SPELL_DAMAGE"]				= { label="技能伤害", tooltip="显示被技能伤害"}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="技能爆击", tooltip="显示被技能爆击"}
obj["INCOMING_SPELL_DOT"]					= { label="技能持续伤害", tooltip="显示被技能持续伤害"}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="技能持续伤害暴击", tooltip="显示被技能持续伤害暴击"}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="伤害护盾伤害", tooltip="显示被伤害护盾伤害"}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="伤害护盾爆击", tooltip="显示伤被害护盾爆击"}
obj["INCOMING_SPELL_MISS"]					= { label="技能未命中", tooltip="显示未被技能命中"}
obj["INCOMING_SPELL_DODGE"]					= { label="技能闪躲", tooltip="显示闪躲技能攻击"}
obj["INCOMING_SPELL_PARRY"]					= { label="技能招架", tooltip="显示招架技能攻击"}
obj["INCOMING_SPELL_BLOCK"]					= { label="技能格挡", tooltip="显示格挡技能攻击"}
obj["INCOMING_SPELL_DEFLECT"]				= { label="技能偏斜", tooltip="显示偏斜技能"}
obj["INCOMING_SPELL_RESIST"]				= { label="法术抵抗", tooltip="显示抵抗法术攻击"}
obj["INCOMING_SPELL_ABSORB"]				= { label="技能吸收", tooltip="显示吸收技能伤害"}
obj["INCOMING_SPELL_IMMUNE"]				= { label="技能免疫", tooltip="显示免疫技能伤害"}
obj["INCOMING_SPELL_REFLECT"]				= { label="技能反射", tooltip="显示反射技能伤害"}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="法术打断", tooltip="显示打断法术"}
obj["INCOMING_HEAL"]						= { label="治疗", tooltip="显示被治疗"}
obj["INCOMING_HEAL_CRIT"]					= { label="爆击治疗", tooltip="显示被治疗爆击"}
obj["INCOMING_HOT"]							= { label="持续治疗", tooltip="显示被持续治疗"}
obj["INCOMING_HOT_CRIT"]					= { label="持续治疗暴击", tooltip="显示持续治疗暴击"}
obj["INCOMING_ENVIRONMENTAL"]				= { label="环境伤害", tooltip="显示环境伤害（如跌落，窒息，熔岩等）"}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="近战伤害", tooltip="显示宠物被近战伤害"}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="近战爆击", tooltip="显示宠物被近战爆击"}
obj["PET_INCOMING_MISS"]						= { label="近战未命中", tooltip="显示宠物未被近战命中"}
obj["PET_INCOMING_DODGE"]						= { label="近战闪躲", tooltip="显示宠物闪躲近战攻击"}
obj["PET_INCOMING_PARRY"]						= { label="近战招架", tooltip="显示宠物招架近战攻击"}
obj["PET_INCOMING_BLOCK"]						= { label="近战格挡", tooltip="显示宠物格挡近战攻击"}
obj["PET_INCOMING_DEFLECT"]						= { label="近战偏斜", tooltip="显示宠物偏斜近战攻击"}
obj["PET_INCOMING_ABSORB"]						= { label="近战吸收", tooltip="显示宠物吸收近战伤害"}
obj["PET_INCOMING_IMMUNE"]						= { label="近战免疫", tooltip="显示宠物免疫近战伤害"}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="技能伤害", tooltip="显示宠物被技能伤害"}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="技能爆击", tooltip="显示宠物被技能爆击"}
obj["PET_INCOMING_SPELL_DOT"]					= { label="技能持续伤害", tooltip="显示宠物被技能持续伤害"}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="技能持续伤害暴击", tooltip="显示宠物被技能持续伤害暴击"}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="伤害护盾伤害", tooltip="显示宠物被伤害护盾的伤害"}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="伤害护盾爆击", tooltip="显示宠物被伤害护盾的爆击"}
obj["PET_INCOMING_SPELL_MISS"]					= { label="技能未命中", tooltip="显示宠物未被技能命中"}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="技能闪躲", tooltip="显示宠物闪躲技能攻击"}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="技能招架", tooltip="显示宠物招架技能攻击"}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="技能格挡", tooltip="显示宠物格挡技能攻击"}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="技能偏斜", tooltip="显示宠物近战技能"}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="法术抵抗", tooltip="显示宠物抵抗法术攻击"}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="技能吸收", tooltip="显示宠物吸收技能伤害"}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="技能免疫", tooltip="显示宠物免疫技能伤害"}
obj["PET_INCOMING_HEAL"]						= { label="治疗", tooltip="显示宠物被治疗"}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="治疗爆击", tooltip="显示宠物被治疗爆击"}
obj["PET_INCOMING_HOT"]							= { label="持续治疗", tooltip="显示宠物被持续治疗"}
obj["PET_INCOMING_HOT_CRIT"]					= { label="持续治疗暴击", tooltip="显示宠物持续治疗暴击"}


------------------------------
-- Outgoing events
------------------------------

obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="近战伤害", tooltip="显示对敌近战伤害"}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="近战爆击", tooltip="显示对敌近战爆击"}
obj["OUTGOING_MISS"]						= { label="近战未命中", tooltip="显示近战未命中敌人"}
obj["OUTGOING_DODGE"]						= { label="近战闪躲", tooltip="显示敌人闪躲近战攻击"}
obj["OUTGOING_PARRY"]						= { label="近战招架", tooltip="显示敌人招架近战攻击"}
obj["OUTGOING_BLOCK"]						= { label="近战格挡", tooltip="显示敌人格挡近战攻击"}
obj["OUTGOING_DEFLECT"]						= { label="近战偏斜", tooltip="显示敌人偏斜近战攻击"}
obj["OUTGOING_ABSORB"]						= { label="近战吸收", tooltip="显示敌人吸收近战伤害"}
obj["OUTGOING_IMMUNE"]						= { label="近战免疫", tooltip="显示敌人免疫近战伤害"}
obj["OUTGOING_EVADE"]						= { label="近战闪避", tooltip="显示敌人闪避近战攻击"}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="技能伤害", tooltip="显示技能伤害敌人"}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="技能爆击", tooltip="显示技能爆击敌人"}
obj["OUTGOING_SPELL_DOT"]					= { label="技能持续伤害", tooltip="显示技能持续伤害敌人"}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="技能持续伤害暴击", tooltip="显示输出技能持续伤害暴击"}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="伤害护盾伤害", tooltip="显示伤害护盾的伤害"}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="伤害护盾爆击", tooltip="显示伤害护盾的爆击"}
obj["OUTGOING_SPELL_MISS"]					= { label="技能未命中", tooltip="显示技能未命中敌人"}
obj["OUTGOING_SPELL_DODGE"]					= { label="技能闪躲", tooltip="显示敌人闪躲技能攻击"}
obj["OUTGOING_SPELL_PARRY"]					= { label="技能招架", tooltip="显示敌人招架技能攻击"}
obj["OUTGOING_SPELL_BLOCK"]					= { label="技能格挡", tooltip="显示敌人格挡技能攻击"}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="技能偏斜", tooltip="显示敌人偏斜技能"}
obj["OUTGOING_SPELL_RESIST"]				= { label="法术抵抗", tooltip="显示敌人抵抗法术攻击"}
obj["OUTGOING_SPELL_ABSORB"]				= { label="技能吸收", tooltip="显示敌人吸收法术伤害"}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="技能免疫", tooltip="显示敌人免疫技能伤害"}
obj["OUTGOING_SPELL_REFLECT"]				= { label="技能反射", tooltip="显示敌人反射技能伤害"}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="法术打断", tooltip="显示法术攻击被打断"}
obj["OUTGOING_SPELL_EVADE"]					= { label="技能闪避", tooltip="显示技能攻击被闪避"}
obj["OUTGOING_HEAL"]						= { label="治疗", tooltip="显示治疗目标"}
obj["OUTGOING_HEAL_CRIT"]					= { label="治疗爆击", tooltip="显示爆击治疗目标"}
obj["OUTGOING_HOT"]							= { label="持续治疗", tooltip="显示持续治疗目标"}
obj["OUTGOING_HOT_CRIT"]					= { label="持续治疗暴击", tooltip="显示持续治疗暴击."}
obj["OUTGOING_DISPEL"]						= { label="驱散", tooltip="显示驱散."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="近战伤害", tooltip="显示宠物近战伤害"}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="近战爆击", tooltip="显示宠物近战爆击"}
obj["PET_OUTGOING_MISS"]						= { label="近战未命中", tooltip="显示宠物的近战攻击未命中敌人"}
obj["PET_OUTGOING_DODGE"]						= { label="近战闪躲", tooltip="显示宠物的近战攻击被闪躲"}
obj["PET_OUTGOING_PARRY"]						= { label="近战招架", tooltip="显示宠物的近战攻击被招架"}
obj["PET_OUTGOING_BLOCK"]						= { label="近战格挡", tooltip="显示宠物的近战攻击被格挡"}
obj["PET_OUTGOING_DEFLECT"]						= { label="近战偏斜", tooltip="显示宠物的近战攻击偏斜"}
obj["PET_OUTGOING_ABSORB"]						= { label="近战吸收", tooltip="显示宠物的近战伤害被吸收"}
obj["PET_OUTGOING_IMMUNE"]						= { label="近战免疫", tooltip="显示宠物的近战伤害被免疫"}
obj["PET_OUTGOING_EVADE"]						= { label="近战闪避", tooltip="显示宠物的近战攻击被闪避"}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="技能伤害", tooltip="显示宠物的技能伤害"}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="技能爆击", tooltip="显示宠物的技能爆击"}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="技能持续伤害", tooltip="显示宠物技能的持续伤害"}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="技能持续伤害暴击", tooltip="显示宠物的技能持续伤害暴击."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="伤害护盾伤害", tooltip="显示宠物的伤害护盾的伤害."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="伤害护盾爆击", tooltip="显示宠物的伤害护盾的爆击."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="技能未命中", tooltip="显示宠物技能攻击未命中敌人"}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="技能闪躲", tooltip="显示宠物的技能攻击被闪躲"}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="技能招架", tooltip="显示宠物的技能攻击被招架"}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="技能格挡", tooltip="显示宠物的技能攻击被格挡"}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="技能偏斜", tooltip="显示宠物的技能偏斜"}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="法术抵抗", tooltip="显示宠物的法术攻击被抵抗"}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="技能吸收", tooltip="显示宠物的技能伤害被吸收"}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="技能免疫", tooltip="显示宠物的技能伤害被免疫"}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="技能闪避", tooltip="显示宠物的技能攻击被闪避"}
obj["PET_OUTGOING_HEAL"]						= { label="治疗", tooltip="显示宠物治疗"}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="治疗暴击", tooltip="显示宠物治疗暴击"}
obj["PET_OUTGOING_HOT"]							= { label="持续治疗", tooltip="显示宠物持续治疗"}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="持续治疗暴击", tooltip="显示宠物持续治疗暴击"}
obj["PET_OUTGOING_DISPEL"]						= { label="驱散", tooltip="显示宠物的驱散."}


------------------------------
-- Notification events
------------------------------

obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="Debuff", tooltip="显示你得到的Debuff"}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="Debuff堆叠", tooltip="显示Debuff堆叠数量"}
obj["NOTIFICATION_BUFF"]				= { label="Buff", tooltip="显示你得到的Buff"}
obj["NOTIFICATION_BUFF_STACK"]			= { label="Buff堆叠", tooltip="显示Buff堆叠数量"}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="物品Buff", tooltip="显示使用物品得到的Buff"}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="Debuff消失", tooltip="显示从你身上消失的Debuff"}
obj["NOTIFICATION_BUFF_FADE"]			= { label="Buff消失", tooltip="显示从你身上消失的Buff"}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="物品Buff消失", tooltip="显示从你身上消失的物品Buff"}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="战斗开始", tooltip="显示你已经开始战斗"}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="战斗结束", tooltip="显示你已经结束了战斗"}
obj["NOTIFICATION_POWER_GAIN"]			= { label="能量获得", tooltip="显示你额外获得的法力，怒气或者能量"}
obj["NOTIFICATION_POWER_LOSS"]			= { label="能量行动", tooltip="显示你失去的法力，怒气或者能量"}
--obj["NOTIFICATION_ALT_POWER_GAIN"]		= { label="Alternate Power Gains", tooltip="Enable when you gain alternate power such as sound level on Atramedes."}
--obj["NOTIFICATION_ALT_POWER_LOSS"]		= { label="Alternate Power Losses", tooltip="Enable when you lose alternate power from drains."}
--obj["NOTIFICATION_CHI_CHANGE"]			= { label="Chi Changes", tooltip="Enable when you change chi."}
--obj["NOTIFICATION_CHI_FULL"]			= { label="Chi Full", tooltip="Enable when you attain full chi."}
obj["NOTIFICATION_CP_GAIN"]				= { label="连击点获得", tooltip="显示你获得的连击点"}
obj["NOTIFICATION_CP_FULL"]				= { label="连击点已满", tooltip="显示你的连击点已满"}
obj["NOTIFICATION_HOLY_POWER_CHANGE"]	= { label="神圣能量变化", tooltip="显示你的神圣能量变化"}
obj["NOTIFICATION_HOLY_POWER_FULL"]		= { label="神圣能量已满", tooltip="显示你的神圣能量已满"}
--obj["NOTIFICATION_SHADOW_ORBS_CHANGE"]	= { label="Shadow Orb Changes", tooltip="Enable when you change shadow orbs."}
--obj["NOTIFICATION_SHADOW_ORBS_FULL"]	= { label="Shadow Orbs Full", tooltip="Enable when you attain full shadow orbs."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="获得荣誉", tooltip="显示你获得荣誉"}
obj["NOTIFICATION_REP_GAIN"]			= { label="声望提高", tooltip="显示你的声望提高"}
obj["NOTIFICATION_REP_LOSS"]			= { label="声望下降", tooltip="显示你的声望下降"}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="获得技能点", tooltip="显示你获得了技能点"}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="获得经验", tooltip="显示你获得了经验值"}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="击杀玩家", tooltip="显示你击杀了一个敌对玩家"}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="击杀NPC", tooltip="显示你击杀了一个敌对NPC"}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="额外攻击", tooltip="显示你从风怒，痛击之刃，剑系掌握等方面获得了一次额外攻击"}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="敌人获得Buff", tooltip="显示当前敌对目标获得的Buff"}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="怪物表情", tooltip="显示当前目标怪物表情"}


------------------------------
-- Trigger info
------------------------------

-- Main events.
obj = L.TRIGGER_DATA
obj["SWING_DAMAGE"]				= "平砍伤害"
obj["RANGE_DAMAGE"]				= "远程伤害"
obj["SPELL_DAMAGE"]				= "技能伤害"
obj["GENERIC_DAMAGE"]			= "平砍/远程/技能伤害"
obj["SPELL_PERIODIC_DAMAGE"]	= "周期性技能伤害(DoT)"
obj["DAMAGE_SHIELD"]			= "伤害护盾伤害"
obj["DAMAGE_SPLIT"]				= "分摊伤害"
obj["ENVIRONMENTAL_DAMAGE"]		= "环境伤害"
obj["SWING_MISSED"]				= "平砍未命中"
obj["RANGE_MISSED"]				= "远程未命中"
obj["SPELL_MISSED"]				= "技能未命中"
obj["GENERIC_MISSED"]			= "平砍/远程/技能未命中"
obj["SPELL_PERIODIC_MISSED"]	= "周期性技能未命中"
obj["SPELL_DISPEL_FAILED"]		= "驱散失败"
obj["DAMAGE_SHIELD_MISSED"]		= "伤害护盾未命中"
obj["SPELL_HEAL"]				= "治疗"
obj["SPELL_PERIODIC_HEAL"]		= "周期性治疗(HoT)"
obj["SPELL_ENERGIZE"]			= "能量获取"
obj["SPELL_PERIODIC_ENERGIZE"]	= "周期性能量获取"
obj["SPELL_DRAIN"]				= "能量消耗"
obj["SPELL_PERIODIC_DRAIN"]		= "周期性能量消耗"
obj["SPELL_LEECH"]				= "能量吸取"
obj["SPELL_PERIODIC_LEECH"]		= "周期性能量吸取"
obj["SPELL_INTERRUPT"]			= "技能打断"
obj["SPELL_AURA_APPLIED"]		= "获得光环"
obj["SPELL_AURA_REMOVED"]		= "光环消失"
obj["SPELL_STOLEN"]				= "偷取光环"
obj["SPELL_DISPEL"]				= "光环被驱散"
obj["SPELL_AURA_REFRESH"]		= "光环刷新"
obj["SPELL_AURA_BROKEN_SPELL"]	= "光环打破"
obj["ENCHANT_APPLIED"]			= "附魔效果触发"
obj["ENCHANT_REMOVED"]			= "附魔效果消失"
obj["SPELL_CAST_START"]			= "开始施法"
obj["SPELL_CAST_SUCCESS"]		= "施法成功"
obj["SPELL_CAST_FAILED"]		= "施法失败"
obj["SPELL_SUMMON"]				= "召唤"
obj["SPELL_CREATE"]				= "创造"
obj["PARTY_KILL"]				= "队友击杀"
obj["UNIT_DIED"]				= "单位死亡"
obj["UNIT_DESTROYED"]			= "单位被摧毁"
obj["SPELL_EXTRA_ATTACKS"]		= "额外攻击"
obj["UNIT_HEALTH"]				= "生命值改变"
obj["UNIT_POWER"]				= "法力值改变"
obj["SKILL_COOLDOWN"]			= "技能冷却完成"
obj["PET_COOLDOWN"]				= "宠物技能冷却完成"
obj["ITEM_COOLDOWN"]			= "物品冷却完成"
 
-- Main event conditions.
obj["sourceName"]				= "来源玩家名字"
obj["sourceAffiliation"]		= "来源玩家联系"
obj["sourceReaction"]			= "来源玩家反应"
obj["sourceControl"]			= "来源玩家控制"
obj["sourceUnitType"]			= "来源玩家类型"
obj["recipientName"]			= "接受玩家名字"
obj["recipientAffiliation"]		= "接受玩家联系"
obj["recipientReaction"]		= "接受玩家反应"
obj["recipientControl"]			= "接受玩家控制"
obj["recipientUnitType"]		= "接受玩家类型"
obj["skillID"]					= "技能 ID"
obj["skillName"]				= "技能名字"
obj["skillSchool"]				= "技能类型"
obj["extraSkillID"]				= "额外技能 ID"
obj["extraSkillName"]			= "额外技能名字"
obj["extraSkillSchool"]			= "额外技能类型"
obj["amount"]					= "总数"
obj["overkillAmount"]			= "灭绝总数"
obj["damageType"]				= "伤害类型"
obj["resistAmount"]				= "抵抗总数"
obj["blockAmount"]				= "格挡总数"
obj["absorbAmount"]				= "吸收总数"
obj["isCrit"]					= "爆击"
obj["isGlancing"]				= "偏斜"
obj["isCrushing"]				= "致命攻击"
obj["extraAmount"]				= "额外总数"
obj["missType"]					= "未命中类型"
obj["hazardType"]				= "危害类型"
obj["powerType"]				= "能量类型"
obj["auraType"]					= "光环类型"
obj["threshold"]				= "起点阀值"
obj["unitID"]					= "玩家 ID"
obj["unitReaction"]				= "玩家反应"
obj["itemID"]					= "物品 ID"
obj["itemName"]					= "物品名字"

-- Exception conditions.
obj["activeTalents"]			= "启用天赋"
obj["buffActive"]				= "BUFF生效"
obj["buffInactive"]				= "Buff失效"
obj["currentCP"]				= "当前连击点"
obj["currentPower"]				= "当前能量"
obj["inCombat"]					= "战斗中"
obj["recentlyFired"]			= "触发器最近被触发"
obj["trivialTarget"]			= "无效目标"
obj["unavailableSkill"]			= "不可用技能"
obj["warriorStance"]			= "战士姿态"
obj["zoneName"]					= "地区名字"
obj["zoneType"]					= "地区类型"
 
-- Relationships.
obj["eq"]						= "相等"
obj["ne"]						= "不相等"
obj["like"]						= "像"
obj["unlike"]					= "不像"
obj["lt"]						= "少于"
obj["gt"]						= "多于"
 
-- Affiliations.
obj["affiliationMine"]			= "我的"
obj["affiliationParty"]			= "队友"
obj["affiliationRaid"]			= "团队成员"
obj["affiliationOutsider"]		= "其他"
obj["affiliationTarget"]		= TARGET
obj["affiliationFocus"]			= FOCUS
obj["affiliationYou"]			= YOU

-- Reactions.
obj["reactionFriendly"]			= "友善"
obj["reactionNeutral"]			= "中立"
obj["reactionHostile"]			= HOSTILE

-- Control types.
obj["controlServer"]			= "服务器"
obj["controlHuman"]				= "玩家"

-- Unit types.
obj["unitTypePlayer"]			= PLAYER 
obj["unitTypeNPC"]				= "NPC"
obj["unitTypePet"]				= PET
obj["unitTypeGuardian"]			= "护卫"
obj["unitTypeObject"]			= "物体"

-- Aura types.
obj["auraTypeBuff"]				= "Buff"
obj["auraTypeDebuff"]			= "Debuff"

-- Zone types.
obj["zoneTypeArena"]			= "竞技场"
obj["zoneTypePvP"]				= BATTLEGROUND
obj["zoneTypeParty"]			= "小队副本"
obj["zoneTypeRaid"]				= "团队副本"

-- Booleans
obj["booleanTrue"]				= "True"
obj["booleanFalse"]				= "False"


------------------------------
-- Font info
------------------------------

-- Font outlines.
obj = L.OUTLINES
obj[1] = "无"
obj[2] = "细"
obj[3] = "粗"
obj[4] = "单线"
obj[5] = "单线 细"
obj[6] = "单线 粗"

-- Text aligns.
obj = L.TEXT_ALIGNS
obj[1] = "左边"
obj[2] = "中间"
obj[3] = "右边"


------------------------------
-- Sound info
------------------------------

obj = L.SOUNDS
obj["MSBT Low Mana"]	= "MSBT 能量不足"
obj["MSBT Low Health"]	= "MSBT 血量不足"
obj["MSBT Cooldown"]	= "MSBT 冷却"


------------------------------
-- Animation style info
------------------------------

-- Animation styles
obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "V型"
obj["Horizontal"]	= "水平"
obj["Parabola"]		= "抛物线"
obj["Straight"]		= "直线"
obj["Static"]		= "静止"
obj["Pow"]			= "抖动"

-- Animation style directions.
obj["Alternate"]	= "交替"
obj["Left"]			= "左"
obj["Right"]		= "右"
obj["Up"]			= "上"
obj["Down"]			= "下"

-- Animation style behaviors.
obj["AngleUp"]			= "V型向上"
obj["AngleDown"]		= "V型向下"
obj["GrowUp"]			= "向上增长"
obj["GrowDown"]			= "向下增长"
obj["CurvedLeft"]		= "向左抛出"
obj["CurvedRight"]		= "向右抛出"
obj["Jiggle"]			= "摇动"
obj["Normal"]			= "普通"