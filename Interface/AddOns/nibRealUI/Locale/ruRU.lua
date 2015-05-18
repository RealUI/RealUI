local L = LibStub("AceLocale-3.0"):NewLocale("nibRealUI", "ruRU")

if L then

-- General
L["Alert_CombatLockdown"] = "Блокировка в бою" -- Needs review
L["DoReloadUI"] = "Требуется перезагрузка интерфейса для принятия изменений. Перезагрузить сейчас?" -- Needs review
-- L["Slash_Profile"] = ""
L["Slash_RealUI"] = "Введите %s для изменения стиля, расположения и настроек." -- Needs review
-- L["Slash_Taint"] = ""
L["Version"] = "Версия" -- Needs review


-- Install
L["Install"] = "НАЖМИТЕ ДЛЯ УСТАНОВКИ" -- Needs review
L["Patch_DoApply"] = "Вы хотите применить новейшие настройки RealUI?" -- Needs review
L["Patch_MiniPatch"] = "Мини-обновление RealUI" -- Needs review


-- Options
L["Appearance_ClassColorHealth"] = "Здоровье по цвету класса" -- Needs review
L["Appearance_ClassColorNames"] = "Имена по цвету класса" -- Needs review
L["Appearance_InfoLineBG"] = "Фон инфо-панели" -- Needs review
L["Appearance_StripeOpacity"] = "Непрозр. полосы"
L["Appearance_WinOpacity"] = "Непрозр. окна"
L["Colors_Amber"] = "Янтарный" -- Needs review
L["Colors_Blue"] = "Синий" -- Needs review
L["Colors_Cyan"] = "Голубой" -- Needs review
L["Colors_Green"] = "Зеленый" -- Needs review
L["Colors_Orange"] = "Оранжевый" -- Needs review
L["Colors_Purple"] = "Фиолетовый" -- Needs review
L["Colors_Red"] = "Красный" -- Needs review
L["Colors_Yellow"] = "Желтый" -- Needs review
-- L["CombatFade"] = ""
-- L["CombatFade_HarmTarget"] = ""
-- L["CombatFade_Hurt"] = ""
-- L["CombatFade_InCombat"] = ""
-- L["CombatFade_NoCombat"] = ""
-- L["CombatFade_Target"] = ""
L["Fonts"] = "Шрифты" -- Needs review
L["Fonts_AdvConfig"] = "Дополнительно"
-- L["Fonts_ChangeYellow"] = ""
-- L["Fonts_ChangeYellowDesc"] = ""
-- L["Fonts_Chat"] = ""
-- L["Fonts_ChatDesc"] = ""
-- L["Fonts_Desc"] = ""
-- L["Fonts_Font"] = ""
-- L["Fonts_Header"] = ""
-- L["Fonts_HeaderDesc"] = ""
L["Fonts_Hybrid"] = "Смешанные" -- Needs review
L["Fonts_HybridDesc"] = "Большие и маленькие шрифты" -- Needs review
L["Fonts_LargeDesc"] = "Большие шрифты" -- Needs review
-- L["Fonts_Normal"] = ""
-- L["Fonts_NormalDesc"] = ""
-- L["Fonts_NormalOffset"] = ""
-- L["Fonts_NormalOffsetDesc"] = ""
-- L["Fonts_Outline"] = ""
-- L["Fonts_PixelCooldown"] = ""
-- L["Fonts_PixelLarge"] = ""
-- L["Fonts_PixelNumbers"] = ""
-- L["Fonts_PixelSmall"] = ""
L["Fonts_SmallDesc"] = "Маленькие шрифты" -- Needs review
-- L["Fonts_Standard"] = ""
-- L["Fonts_YellowFont"] = ""
L["General_Enabled"] = "Включено" -- Needs review
-- L["General_EnabledDesc"] = ""
L["General_InvalidParent"] = "Указанного родительского фрейма для %s не существует." -- Needs review
-- L["General_LoadDefaults"] = ""
-- L["General_NoteParent"] = ""
-- L["General_NoteReload"] = ""
-- L["General_Tristatefalse"] = ""
-- L["General_Tristatenil"] = ""
-- L["General_Tristatetrue"] = ""
L["Layout_ApplyOOC"] = "Раскладка будет изменена после окончания боя." -- Needs review
L["Layout_DPSTank"] = "Боец/Танк" -- Needs review
L["Layout_Healing"] = "Лекарь" -- Needs review
L["Layout_Link"] = "Связать" -- Needs review
L["Layout_LinkDesc"] = "Одинаковые настройки для раскладок Боец/Танк и Лекарь." -- Needs review
L["Power_Eco"] = "Экономный" -- Needs review
L["Power_EcoDesc"] = [=[В этом режиме частота обновления графики снижена.
Может повысить производительность на слабых ПК.]=] -- Needs review
L["Power_Normal"] = "Нормальный" -- Needs review
L["Power_NormalDesc"] = "В этом режиме обычная частота обновления графики." -- Needs review
L["Power_PowerMode"] = "Режим работы" -- Needs review
L["Power_Turbo"] = "Турбо" -- Needs review
L["Power_TurboDesc"] = [=[В этом режиме частота обновления графики повышена, анимация интерфейса более плавная.
Повышает нагрузку на ЦП.]=] -- Needs review
L["Reset_Confirm"] = "Вы уверены, что хотите сбросить настройки RealUI?" -- Needs review
L["Reset_SettingsLost"] = "Все пользовательские настройки будут потеряны." -- Needs review
-- L["Tweaks_HideRaidFilter"] = ""
-- L["Tweaks_HideRaidFilterDesc"] = ""


-- Config
L["Alert_CantOpenInCombat"] = "Невозможно открыть конфигурацию RealUI в бою." -- Needs review
L["Appearance_DefaultColors"] = "По умолчанию"
L["Appearance_DefaultColorsDesc"] = [=[Отключите для
своего цвета]=]
-- L["AuraTrack"] = ""
L["AuraTrack_Buff"] = "Бафф" -- Needs review
L["AuraTrack_Create"] = "Добавить новый" -- Needs review
L["AuraTrack_Debuff"] = "Дебафф" -- Needs review
L["AuraTrack_DruidBear"] = "Медведь" -- Needs review
L["AuraTrack_DruidCat"] = "Кошка" -- Needs review
L["AuraTrack_DruidHuman"] = "Человек" -- Needs review
L["AuraTrack_DruidMoonkin"] = "Совух" -- Needs review
L["AuraTrack_HideOOC"] = "Скрывать вне боя" -- Needs review
L["AuraTrack_HideOOCDesc"] = "Принудительно скрывать вне боя, даже если индикатор активен."
L["AuraTrack_HideStack"] = "Скрывать стаки"
L["AuraTrack_HideStackDesc"] = "Не показывать количество стаков." -- Needs review
L["AuraTrack_HideTime"] = "Скрывать время"
L["AuraTrack_HideTimeDesc"] = "Не показывать оставшееся время." -- Needs review
L["AuraTrack_IgnoreSpec"] = "Все"
L["AuraTrack_IgnoreSpecDesc"] = "Показывать индикатор независимо от специализации" -- Needs review
L["AuraTrack_InactiveOpacity"] = "Непрозрачность"
-- L["AuraTrack_InvalidName"] = ""
L["AuraTrack_MinLevel"] = "Мин. уровень (0 = все)"
L["AuraTrack_NoteSpellID"] = [=[Важно: название или ID заклинания должно точно соответствовать тому,
которое вы хотите отслеживать.
Для отслеживания нескольких заклинаний введите их ID через запятую (1122,2233).]=]
L["AuraTrack_Padding"] = "Отступ"
-- L["AuraTrack_Remove"] = ""
-- L["AuraTrack_RemoveConfirm"] = ""
L["AuraTrack_Reset"] = "Вы уверены, что хотите сбросить настойки отслеживания?" -- Needs review
-- L["AuraTrack_Selected"] = ""
L["AuraTrack_ShowHostile"] = "Показывать для цели"
L["AuraTrack_ShowHostileDesc"] = "Отображать индикаторы, когда можно атаковать цель" -- Needs review
L["AuraTrack_ShowInCombat"] = "Показывать в бою" -- Needs review
L["AuraTrack_ShowInCombatDesc"] = "Отображать индикаторы в бою" -- Needs review
L["AuraTrack_ShowInPvE"] = "Показывать в ПвЕ" -- Needs review
L["AuraTrack_ShowInPvEDesc"] = "Отображать индикаторы в ПвЕ"
L["AuraTrack_ShowInPvP"] = "Показывать в ПвП" -- Needs review
L["AuraTrack_ShowInPvPDesc"] = "Отображать индикаторы в ПвП"
L["AuraTrack_Size"] = "Размер индикатора" -- Needs review
L["AuraTrack_SpellNameID"] = "Название или ID"
L["AuraTrack_Static"] = "Статичный" -- Needs review
L["AuraTrack_StaticDesc"] = "Статичные индикаторы отображаются всегда и на одной позиции" -- Needs review
L["AuraTrack_TrackerOptions"] = "Настройки индикатора" -- Needs review
-- L["AuraTrack_TristateSpecfalse"] = ""
-- L["AuraTrack_TristateSpecnil"] = ""
-- L["AuraTrack_TristateSpectrue"] = ""
-- L["AuraTrack_Type"] = ""
-- L["AuraTrack_TypeDesc"] = ""
-- L["AuraTrack_Unit"] = ""
L["AuraTrack_VerticalCD"] = "Вертикальный кулдаун" -- Needs review
L["AuraTrack_VerticalCDDesc"] = "Вертикальный кулдаун вместо спирального" -- Needs review
-- L["AuraTrack_Visibility"] = ""
L["Bars_Bottom"] = "низ" -- Needs review
L["Bars_Buttons"] = "Кнопок" -- Needs review
L["Bars_Center"] = "центр" -- Needs review
L["Bars_Control"] = "Разрешить RealUI управлять панелями команд." -- Needs review
L["Bars_HintCtrlView"] = "Нажмите Ctrl для отображения панелей" -- Needs review
L["Bars_Left"] = "слева" -- Needs review
L["Bars_MoveEAB"] = "Доп. кнопка"
L["Bars_MoveEABDesc"] = "RealUI управляет расположением дополнительной кнопки действия."
L["Bars_MovePet"] = "Панель питомца"
L["Bars_MovePetDesc"] = "RealUI управляет расположением панели питомца."
L["Bars_MoveStance"] = "Панель стоек"
L["Bars_MoveStanceDesc"] = "RealUI управляет расположением панели стоек."
L["Bars_NoteAdvSettings"] = [=[Важно: нажмите |cffffa500Дополнительные Параметры|r для конфигурации Bartender.
             Отключите |cff30d0ffКонтроль RealUI,|r если хотите изменить настройки,
             контролируемые RealUI (расположение, размер и т. д.).]=]
L["Bars_NoteCheckUIElements"] = [=[Важно: после изменения настроек здесь убедитесь, что элементы
             интерфейса не перекрывают друг друга.]=]
L["Bars_Padding"] = "Отступ" -- Needs review
L["Bars_PetBar"] = "Панель питомца" -- Needs review
L["Bars_Right"] = "справа" -- Needs review
L["Bars_Sizes"] = "Размеры" -- Needs review
L["Control_AddonControl"] = "Контроль RealUI"
L["General_Position"] = "Позиция"
L["General_Positions"] = "Расположение" -- Needs review
L["HuD_AlertHuDChangeSize"] = "После изменения размера интерфейса может измениться расположение некоторых элементов. Проверьте расположение после применения изменений." -- Needs review
-- L["HuD_CastBars"] = ""
L["HuD_ChooseElement"] = "Выберите элемент для изменения." -- Needs review
L["HuD_ElementSettings"] = "Настройки"
L["HuD_Height"] = "Высота" -- Needs review
L["HuD_HideElements"] = "Скрыть интерфейс"
L["HuD_Horizontal"] = "Горизонталь"
L["HuD_Instructions"] = "Подсказка"
L["HuD_Instructions1"] = "|cffffa500Шаг 1:|r нажмите |cff30ff30Показать интерфейс|r для отображения элементов."
L["HuD_Instructions2"] = "|cffffa500Шаг 2:|r выберите в |cff30ff30Настройках|r элемент для изменения."
L["HuD_Instructions3"] = "|cffffa500Шаг 3:|r нажмите |cff30ff30Скрыть интерфейс|r после окончания настройки."
L["HuD_Latency"] = "Задержка" -- Needs review
L["HuD_MouseWheelSliders"] = "(используйте колесико мыши для точной настройки)" -- Needs review
L["HuD_ReverseBars"] = "Обратное направление полос" -- Needs review
L["HuD_ShowElements"] = "Показать интерфейс"
L["HuD_Uninterruptible"] = "Непрерываемое" -- Needs review
L["HuD_UseLarge"] = "Увеличить" -- Needs review
L["HuD_UseLargeDesc"] = "Увеличенный размер ключевых элементов (здоровье и т. д.)." -- Needs review
L["HuD_Vertical"] = "Вертикаль"
L["HuD_Width"] = "Ширина" -- Needs review
L["Raid_30Width"] = "Ширина 30 игроков"
L["Raid_40Width"] = "Ширина 40 игроков"
L["Raid_ControlLayout"] = "Управляет раскладкой %s."
L["Raid_ControlPosition"] = "Управляет расположением %s."
L["Raid_ControlStyle"] = "Стилизует %s (требуется перезагрузка интерфейса)."
L["Raid_Layout"] = "Раскладка" -- Needs review
L["Raid_NoteAdvSettings"] = [=[Важно: нажмите |cffffa500Дополнительные Параметры|r для конфигурации Grid2.
             Отключите |cff30d0ffКонтроль RealUI,|r если хотите изменить настройки,
             контролируемые RealUI (расположение, размер и т. д.).]=]
L["Raid_ShowSolo"] = "Показывать соло" -- Needs review
L["Raid_Style"] = "Стиль" -- Needs review
-- L["UnitFrames_AnchorWidth"] = ""
-- L["UnitFrames_AnchorWidthDesc"] = ""
-- L["UnitFrames_AnnounceChatDesc"] = ""
-- L["UnitFrames_AnnounceTrink"] = ""
-- L["UnitFrames_AnnounceTrinkDesc"] = ""
-- L["UnitFrames_BuffCount"] = ""
-- L["UnitFrames_DebuffCount"] = ""
-- L["UnitFrames_Gap"] = ""
-- L["UnitFrames_GapDesc"] = ""
-- L["UnitFrames_ModifierKey"] = ""
-- L["UnitFrames_NPCAuras"] = ""
-- L["UnitFrames_NPCAurasDesc"] = ""
-- L["UnitFrames_PlayerAuras"] = ""
-- L["UnitFrames_PlayerAurasDesc"] = ""
-- L["UnitFrames_SetFocus"] = ""
-- L["UnitFrames_SetFocusDesc"] = ""
-- L["UnitFrames_Units"] = ""
-- L["UnitFrames_XOffset"] = ""
-- L["UnitFrames_YOffset"] = ""


-- InfoLine
L["Clock_CalenderInvites"] = "Приглашения:" -- Needs review
L["Clock_Date"] = "Дата" -- Needs review
L["Clock_NoTBTime"] = "Тол Барад недоступен" -- Needs review
L["Clock_NoWGTime"] = "Озеро Ледяных Оков недоступно" -- Needs review
L["Clock_ShowCalendar"] = "<ЛКМ> для отображения календаря." -- Needs review
L["Clock_ShowTimer"] = "<Shift+ЛКМ> для отображения таймера." -- Needs review
L["Clock_TBTime"] = "Тол Барад через:" -- Needs review
L["Clock_WGTime"] = "Озеро Ледяных Оков через:" -- Needs review
L["Currency_Cycle"] = "<ЛКМ> для переключения валюты." -- Needs review
L["Currency_EraseData"] = "<Alt+ЛКМ> для сброса данных подсвеченного персонажа." -- Needs review
-- L["Currency_NoteWeeklyReset"] = ""
-- L["Currency_ResetCaps"] = ""
L["Currency_TrackMore"] = "Для отображения дополнительной валюты отметьте ее на вкладке валют и выберите \"Отображать в рюкзаке\"" -- Needs review
L["Currency_UpdatedAbbr"] = "Обн." -- Needs review
L["Friend_WhisperInvite"] = "<ЛКМ> для шепота, <Alt+ЛКМ> для приглашения." -- Needs review
L["Guild_WhisperInvite"] = "<ЛКМ> для шепота, <Alt+ЛКМ> для приглашения." -- Needs review
L["InfoLine"] = "Инфо-панель" -- Needs review
L["Layout_Change"] = "<ЛКМ> для смены раскладки." -- Needs review
L["Layout_Current"] = "Текущая раскладка:" -- Needs review
L["Layout_LayoutChanger"] = "Смена раскладки" -- Needs review
L["Meters_Active"] = "Активные измерители:" -- Needs review
L["Meters_Header"] = "Метр переключения" -- Needs review
L["Meters_Toggle"] = "<ЛКМ>для переключения измерителей." -- Needs review
L["Spec_ChangeSpec"] = "<ЛКМ> по специализации для смены талантов." -- Needs review
-- L["Spec_Equip"] = ""
-- L["Spec_EquipAssignPrimary"] = ""
-- L["Spec_EquipAssignSecondary"] = ""
-- L["Spec_EquipUnassign"] = ""
L["Spec_SpecChanger"] = "Изменить специализацию" -- Needs review
L["Spec_StatConfig"] = "<ЛКМ> по характеристике для настройки." -- Needs review
L["Spec_StatDisplay"] = "Отображение характеристик" -- Needs review
L["Start"] = "Инфо-панель" -- Needs review
L["Start_Config"] = "Конфигурация RealUI" -- Needs review
L["Sys_AverageAbbr"] = "Сред." -- Needs review
L["Sys_CurrentAbbr"] = "Тек." -- Needs review
L["Sys_FPS"] = "Кадров в секунду"
L["Sys_In"] = "Вход." -- Needs review
L["Sys_kbps"] = "кб/с" -- Needs review
L["Sys_Max"] = "Макс." -- Needs review
L["Sys_Min"] = "Мин." -- Needs review
L["Sys_ms"] = "мс" -- Needs review
L["Sys_Out"] = "Исх." -- Needs review
L["Sys_Stat"] = "Характеристика" -- Needs review
L["Sys_SysInfo"] = "Системная информация" -- Needs review
L["XPRep"] = "Опыт/репутация" -- Needs review
L["XPRep_Current"] = "Текущий" -- Needs review
L["XPRep_NoFaction"] = "Фракция не выбрана" -- Needs review
L["XPRep_Remaining"] = "Осталось" -- Needs review
L["XPRep_Toggle"] = "<ЛКМ> для переключения опыта/репутации." -- Needs review

end
