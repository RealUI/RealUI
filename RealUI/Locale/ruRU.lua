local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

if RealUI.locale == "ruRU" then

-- cf-localization: locale="ruRU", format="lua_additive_table", handle-unlocalized="comment"
L["ActionBars_ActionBarsDesc"] = "Изменение положения и размера панели команд."
L["ActionBars_Center"] = "Центр"
L["ActionBars_CenterDesc"] = "Регулировка расположения трех центральных панелей команд."
L["ActionBars_CenterOption"] = "%d Центр - %d Низ"
L["ActionBars_EAB"] = "Дополнительная кнопка действий"
L["ActionBars_Move"] = "Передвижение %s"
L["ActionBars_MoveDesc"] = "Проверьте, чтобы RealUI мог контролировать положение %s"
L["ActionBars_Pet"] = "Панель питомца"
L["ActionBars_ShowDoodads"] = "Показать стойки"
L["ActionBars_ShowDoodadsDesc"] = "Показать дополнительную панель питомца и стоек."
L["ActionBars_Sides"] = "Стороны"
L["ActionBars_SidesDesc"] = "Регулировка расположения двух сторон панели команд."
L["ActionBars_SidesOption"] = "%d Лево - %d Право"
L["ActionBars_Stance"] = "Панель стоек"
L["Alert_CantOpenInCombat"] = "Невозможно открыть конфигурацию RealUI в бою."
L["Alert_CombatLockdown"] = "Блокировка в бою"
L["Alert_WaitCombatLockdown"] = "Действуют ограничения боевого режима. Интерфейс будет изменён, когда бой закончится."
L["Appearance_ButtonColor"] = "Цвет Кнопок"
L["Appearance_ClassColorHealth"] = "Здоровье по цвету класса"
L["Appearance_ClassColorNames"] = "Имена по цвету класса"
L["Appearance_FrameColor"] = "Цвет Рамки"
L["Appearance_HighRes"] = "Высокое Разрешение"
L["Appearance_HighResDesc"] = "Удвоить текущий масштаб UI для улучшения читаемости интерфейса.\\n\\nNote: Рекомендуется только при использовании монитора с вертикальным разрешением 1440 px или более."
L["Appearance_ModScale"] = "Модификатор Масштаба UI"
L["Appearance_ModScaleDesc"] = "Пока влияет только на некоторые элементы интерфейса, но скоро будет влиять на Весь UI.\\n\\n%s"
L["Appearance_Pixel"] = "Pixel Perfect"
L["Appearance_PixelDesc"] = "Установить размер интерфейса так, чтобы игровой пиксель совпадал с действительным пикселем монитора."
L["Appearance_Skins"] = "Темы"
L["Appearance_StripeOpacity"] = "Непрозр. полосы"
L["Appearance_UIScale"] = "Настроить масштаб интерфейса"
L["Appearance_UIScaleDesc"] = "Установить своё значение размера UI (%.2f - %.2f). Подсказка: Элементы UI могут стать менее четкими."
L["BindingsReminder"] = "Напоминания о привязке"
L["BindingsReminderDesc"] = "Показывает визуальное напоминание о том, какие действия привязаны к каждой клавише."
L["CastBars"] = "Панель заклинаний"
L["CastBars_Bottom"] = "Низ"
L["CastBars_BottomDesc"] = "Имя и продолжительность отображаются ниже панели заклинаний."
L["CastBars_Inside"] = "Внутри"
L["CastBars_InsideDesc"] = "Имя и продолжительность отображаются слева от игрока и справа для цели."
L["Chat"] = "Чат"
L["Chat_ClassColor"] = "Имена окрашены в цвета класса"
L["Chat_ClassColorDesc"] = "Показывает имена игроков в цветах их классов"
L["Clock_CalenderInvites"] = "Неподтвержденные приглашения:"
L["Clock_Date"] = "Дата"
L["Clock_ShowCalendar"] = "<ЛКМ> Показать календарь"
L["Clock_ShowTimer"] = "<Alt+ЛКМ> Настройки часов"
L["CombatFade"] = "Боевое обесцвечивание"
L["CombatFade_Desc"] = "Автоматическая смена непрозрачности рамки в зависимости от статуса боя, здоровья и статуса цели."
L["CombatFade_HarmTarget"] = "Атака цели"
L["CombatFade_Hurt"] = "Получение урона"
L["CombatFade_InCombat"] = "В бою"
L["CombatFade_NoCombat"] = "Вне боя"
L["CombatFade_Target"] = "Выбор цели"
--[[Translation missing --]]
--[[ L["CombatText"] = "Combat Text"--]] 
--[[Translation missing --]]
--[[ L["CombatText_MergeHits"] = " [%d Hits]"--]] 
L["Control_AddonControl"] = "Контроль RealUI"
L["Control_Layout"] = "Контроль расположения"
L["Control_LayoutDesc"] = "Разрешить RealUI контролировать расположение %s"
L["Control_Position"] = "Контроль позиции"
L["Control_PositionDesc"] = "Разрешить RealUI контролировать позицию %s"
L["Currency_Cycle"] = "<ЛКМ> Открыть список валют, <Alt+ЛКМ> отобразить следующую валюту"
L["Currency_EraseData"] = "<Alt+ЛКМ> Очистить данные выделенного персонажа"
L["Currency_TotalMoney"] = "Денег на сервере:"
L["Currency_UpdatedAbbr"] = "Обн."
L["DoReloadUI"] = "Требуется перезагрузка интерфейса для принятия изменений. Перезагрузить сейчас?"
L["Fonts"] = "Шрифты"
L["Fonts_Chat"] = "Шрифт Чата"
L["Fonts_ChatDesc"] = "Этот шрифт используется для окна чата а так же цифр."
--[[Translation missing --]]
--[[ L["Fonts_Crit"] = "Crit Font"--]] 
L["Fonts_Header"] = "Шрифт Заголовков"
L["Fonts_HeaderDesc"] = "Этот шрифт используется в основном для названий и заголовков."
L["Fonts_Normal"] = "Нормальный шрифт"
L["Fonts_NormalDesc"] = "Этот шрифт используется для основы интерфейса, для подсказок, заданий и целей."
--[[Translation missing --]]
--[[ L["General_AnchorPoint"] = "Anchor Point"--]] 
L["General_Debug"] = "Отладка"
L["General_DebugDesc"] = "Обеспечивает отладочной информацией"
L["General_Enabled"] = "Включено"
L["General_EnabledDesc"] = "Включить/Выключить %s"
L["General_InvalidParent"] = "Указанного родительского фрейма для %s не существует. Введите /realadv и перейдите к %s -> %s что бы задать новое значение."
L["General_Lock"] = "Заблокировано"
L["General_LockDesc"] = "Переключение передвижения или блокировки окна."
L["General_NoteParent"] = "Что бы найти имя фрейма, введите /fstack и наведите курсор мыши на фрейм который вы хотите присоединить. Нажмите ALT что бы зациклить зеленую зону"
L["General_NoteReload"] = "Примечание: Вам нужно перезагрузить UI (/rl) что бы изменения вступили в силу."
L["General_Position"] = "Позиция"
L["General_Positions"] = "Расположение"
L["General_Tristatefalse"] = "|cffff0000Игнорируется|r - Один - Множество"
L["General_Tristatenil"] = "Игнорируется - Один - |cff00ff00Множество|r"
L["General_Tristatetrue"] = "Игнорируется - |cff00ff00Один|r - Множество"
L["General_XOffset"] = "X Смещение"
L["General_XOffsetDesc"] = "Смещение в направлении X (по горизонтали) от заданной точки якоря."
L["General_YOffset"] = "Y Смещение"
L["General_YOffsetDesc"] = "Смещение в направлении Y (по вертикали) от заданной точки якоря."
L["GuildFriend_WhisperInvite"] = "<ЛКМ> шепнуть, <Alt+ЛКМ> %s"
L["HuD_AlertHuDChangeSize"] = "После изменения размера интерфейса может измениться расположение некоторых элементов. Проверьте расположение после применения изменений."
L["HuD_Height"] = "Высота"
L["HuD_Horizontal"] = "Горизонталь"
L["HuD_ReverseBars"] = "Обратное направление полос"
L["HuD_ShowElements"] = "Показать интерфейс"
L["HuD_Uninterruptible"] = "Непрерываемое"
L["HuD_UseLarge"] = "Использовать увеличенный HuD"
L["HuD_UseLargeDesc"] = "Увеличенный размер ключевых элементов (здоровье и т. д.)."
L["HuD_Vertical"] = "Вертикаль"
L["HuD_VerticalDesc"] = "Регулировка вертикального положения HuD."
L["HuD_Width"] = "Ширина"
L["Infobar"] = "Панель информации"
L["Infobar_AllBlocks"] = "Все Элементы"
L["Infobar_BlockGap"] = "Отступ элементов"
L["Infobar_BlockGapDesc"] = "Расстояние между двумя соседними элементами информационной панели."
L["Infobar_CombatTooltips"] = "Всплывающая информация во время боя"
L["Infobar_CombatTooltipsDesc"] = "Отображение всплывающей информации во время боя"
L["Infobar_Desc"] = "Отображение данных поддерживаемых LibDataBroker"
L["Infobar_ShowIcon"] = "Отобразить значки элементов"
L["Infobar_ShowLabel"] = "Отобразить название эелементов"
L["Infobar_ShowStatusBar"] = "Отобразить полосы прогресса"
L["Infobar_ShowStatusBarDesc"] = "Отображает полосы прогресса опыта, опыта артефакта, талантов чести, отслеживаемой репутации"
L["Install"] = "НАЖМИТЕ ДЛЯ УСТАНОВКИ"
--[[Translation missing --]]
--[[ L["Install_UseHighRes"] = "Enable high resolution scaling"--]] 
--[[Translation missing --]]
--[[ L["Install_UseHighResDec"] = "Set up RealUI using 2x UI Scaling so that UI elements are easier to see on a high resolution display."--]] 
--[[Translation missing --]]
--[[ L["Inventory"] = "Inventory"--]] 
--[[Translation missing --]]
--[[ L["Inventory_AddFilter"] = "Create a new filter bag"--]] 
--[[Translation missing --]]
--[[ L["Inventory_AddFilterDesc"] = "New filter bags cannot share a name with an existing one. They are not case sensitive."--]] 
--[[Translation missing --]]
--[[ L["Inventory_Duplicate"] = "A filter with this name already exists."--]] 
--[[Translation missing --]]
--[[ L["Inventory_MaxHeight"] = "Max Height"--]] 
--[[Translation missing --]]
--[[ L["Inventory_MaxHeightDesc"] = "The height at which Inventory will create a new column, as a percentage of screen height."--]] 
--[[Translation missing --]]
--[[ L["Inventory_Restack"] = "Re-stack Items"--]] 
--[[Translation missing --]]
--[[ L["Inventory_SellJunk"] = "Auto Sell Junk"--]] 
L["Layout_ApplyOOC"] = "Раскладка будет изменена после окончания боя."
L["Layout_DPSTank"] = "Боец/Танк"
L["Layout_Healing"] = "Лекарь"
L["Layout_Layout"] = "Раскладка"
L["Layout_Link"] = "Связать"
L["Layout_LinkDesc"] = "Одинаковые настройки для раскладок Боец/Танк и Лекарь."
L["Misc_SpellAlertsDesc"] = "Изменить положение и размер оповещения заклинания."
L["Misc_SpellAlertsWidthDesc"] = "Регулировка расстояния между левым и правым оповещением о заклинании."
L["Patch_DoApply"] = "Патч применен, вы должны перезагрузить UI (/rl) что бы изменения вступили в силу."
L["Patch_MiniPatch"] = "Мини-обновление RealUI"
--[[Translation missing --]]
--[[ L["Patch_UpdateAddonSettings"] = "The default settings for %s have been updated. Would you like to apply these changes?"--]] 
L["Progress"] = "Отслеживание"
L["Progress_Cycle"] = "<Alt+ЛКМ> Смена расположения отслеживаемых элементов"
L["Progress_OpenArt"] = "<ЛКМ> Открыть окно артефакта"
L["Progress_OpenHonor"] = "<ЛКМ> Открыть таланты чести"
L["Progress_OpenRep"] = "<ЛКМ> Открыть окно репутации"
L["Raid_30Width"] = "Ширина 30 игроков"
L["Raid_40Width"] = "Ширина 40 игроков"
L["Raid_HideRaidFilter"] = "Скрыть фильтры рейдов"
L["Raid_HideRaidFilterDesc"] = "Скрыть фильтры групп для стандартных рамок рейда"
L["Raid_LargeGroup"] = "Большие группы"
L["Raid_LargeGroupDesc"] = "Используйте горизонтальные группы в больших группах, таких как рейды или поля боя"
L["Raid_ShowSolo"] = "Показывать без группы"
L["Raid_SmallGroup"] = "Маленькие группы"
L["Raid_SmallGroupDesc"] = "Используйте горизонтальные группы в маленьких группах, таких как подземелья или арены"
L["Reset_Confirm"] = "Вы уверены, что хотите сбросить настройки RealUI?"
L["Reset_SettingsLost"] = "Все пользовательские настройки будут потеряны."
L["Resource"] = "Ресурс класса"
L["Resource_Gap"] = "Отступ"
L["Resource_GapDesc"] = "Расстояние между каждым %s"
L["Resource_HeightDesc"] = "Установите высоту якоря ресурсов."
L["Resource_HideUnused"] = "Скрыть неиспользованные %s"
L["Resource_HideUnusedDesc"] = "Показывать только имеющиеся %s"
L["Resource_Reverse"] = "Отразить положение"
L["Resource_ReverseDesc"] = "Отразить положение %s на экране."
L["Resource_WidthDesc"] = "Установите размер якоря ресурсов."
L["Slash_Profile"] = [=[|cFFBB0000CPU Profiling включен!|r Что бы выключить, введите: 
|cFF8080FF/cpuProfiling|r]=]
L["Slash_RealUI"] = "Введите %s для изменения стиля, расположения и настроек."
L["Slash_Taint"] = [=[|cFFBB0000Taint Logging включен!|r Что бы выключить, введите: 
|cFF8080FF/taintLogging|r]=]
--[[Translation missing --]]
--[[ L["Spec_ChangeGear"] = "<Right+Click> Cycle equip sets, <Alt+Right+Click> Unassign equip set"--]] 
L["Spec_ChangeSpec"] = "<ЛКМ> Смена специализации, <Alt+ЛКМ> Смена специализации добычи\\n<ПКМ+ЛКМ> Следующий набор снаряжения, <Alt+ПКМ+ЛКМ> Очистить наборы экипировки"
L["Spec_Open"] = "<ЛКМ> Открыть окно талантов"
L["Spec_SpecChanger"] = "Смена специализации"
L["Start"] = "Пуск"
L["Start_Config"] = "Настройка RealUI"
L["Sys_AverageAbbr"] = "Сред"
L["Sys_CurrentAbbr"] = "Тек."
L["Sys_Stat"] = "Статистика"
L["Sys_SysInfo"] = "Системная информация"
--[[Translation missing --]]
--[[ L["Tooltips"] = "Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_AtCursor"] = "At Cursor"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_AtCursorDesc"] = "Position the tooltip at the cursor by default."--]] 
--[[Translation missing --]]
--[[ L["Tooltips_ShowIDs"] = "Show object IDs"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_ShowRealm"] = "Show realm names"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_ShowTitles"] = "Show player titles"--]] 
L["Tweaks_CooldownCount"] = "Отсчет времени восстановления "
L["Tweaks_CooldownCountDesc"] = "Изменить шрифты обратных отсчетов"
L["Tweaks_UITweaks"] = "Настройка интерфейса"
L["Tweaks_UITweaksDesc"] = "Незначительные функциональные настройки для стандартного интерфейса"
L["UnitFrames_AnchorWidth"] = "Якорь ширины"
L["UnitFrames_AnchorWidthDesc"] = "Объем пространства между рамкой игрока и целью."
L["UnitFrames_AnnounceChatDesc"] = "Чат канал, используемый для объявления."
L["UnitFrames_AnnounceTrink"] = "Объявление о аксессуаре."
L["UnitFrames_AnnounceTrinkDesc"] = "Объявление использования противником аксессуара в чат."
L["UnitFrames_BuffCount"] = "Подсчет баффов"
L["UnitFrames_DebuffCount"] = "Подсчет дебаффов"
L["UnitFrames_Gap"] = "Отступ"
L["UnitFrames_GapDesc"] = "Вертикальное расстояние между каждым блоком."
L["UnitFrames_ModifierKey"] = "Ключ модификатора"
L["UnitFrames_NPCAuras"] = "Показать ауры NPC"
L["UnitFrames_NPCAurasDesc"] = "Показать Баффы/Дебаффы наложенные NPC."
L["UnitFrames_PlayerAuras"] = "Показать ауры игрока"
L["UnitFrames_PlayerAurasDesc"] = "Показать Баффы/Дебаффы наложенные вами."
L["UnitFrames_SetFocus"] = "Нажмите что бы установить фокус"
L["UnitFrames_SetFocusDesc"] = "Установить фокус по нажатию+модификатор на рамку портрета."
L["UnitFrames_Units"] = "Рамки"
L["Version"] = "Версия"
--[[Translation missing --]]
--[[ L["WorldMarker"] = "World Marker"--]] 
--[[Translation missing --]]
--[[ L["WorldMarker_Show"] = "Show the World Marker in..."--]] 
--[[Translation missing --]]
--[[ L["WorldMarkerDesc"] = "Quick access to World Markers"--]] 
-- cf-localization end
end
