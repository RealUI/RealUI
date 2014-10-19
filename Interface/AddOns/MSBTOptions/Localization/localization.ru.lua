-------------------------------------------------------------------------------
-- Title: MSBT Options Russian Localization
-- Author: Mikord
-- Russain Translation by: Eritnull (StingerSoft)
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't Russian.
if (GetLocale() ~= "ruRU") then return end

-- Local reference for faster access.
local L = MikSBT.translations

-------------------------------------------------------------------------------
-- Russian Localization
-------------------------------------------------------------------------------


------------------------------
-- Interface messages
------------------------------

L.MSG_CUSTOM_FONTS					= "Пользовательский шрифт"
L.MSG_INVALID_CUSTOM_FONT_NAME		= "Неверное название шрифта."
L.MSG_FONT_NAME_ALREADY_EXISTS		= "Название шрифта уже существует."
L.MSG_INVALID_CUSTOM_FONT_PATH		= "Путь к шрифту должен быть указан на файл .ttf."
--L.MSG_UNABLE_TO_SET_FONT			= "Unable to set specified font." 
--L.MSG_TESTING_FONT			= "Testing the specified font for validity..."
L.MSG_CUSTOM_SOUNDS					= "Пользовательские звуки"
L.MSG_INVALID_CUSTOM_SOUND_NAME		= "Неверное название звукового файла."
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "Название звукового файла уже существует."
L.MSG_NEW_PROFILE					= "Новый профиль"
L.MSG_PROFILE_ALREADY_EXISTS		= "Профиль уже существует."
L.MSG_INVALID_PROFILE_NAME			= "Неверное название профиля."
L.MSG_NEW_SCROLL_AREA				= "Новая область прокрутки"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "Название области прокрутки уже существует."
L.MSG_INVALID_SCROLL_AREA_NAME		= "Неверное название области прокрутки."
L.MSG_ACKNOWLEDGE_TEXT				= "Вы уверены что хотите выполнить данное действие?"
L.MSG_NORMAL_PREVIEW_TEXT			= "Нормальный"
L.MSG_INVALID_SOUND_FILE			= "Звуки должны быть в .ogg формате."
L.MSG_NEW_TRIGGER					= "Новый триггер"
L.MSG_TRIGGER_CLASSES				= "Триггер классы"
L.MSG_MAIN_EVENTS					= "Главные события"
L.MSG_TRIGGER_EXCEPTIONS			= "Триггер исключения"
L.MSG_EVENT_CONDITIONS				= "Условие события"
L.MSG_DISPLAY_QUALITY				= "Показывать оповещение для предметов этого качества."
L.MSG_SKILLS						= "Навыки"
L.MSG_SKILL_ALREADY_EXISTS			= "Название навыка уже существует."
L.MSG_INVALID_SKILL_NAME			= "Неверное название навыка."
L.MSG_HOSTILE						= "Вражеский"
L.MSG_ANY							= "Любой"
L.MSG_CONDITION						= "Условие"
L.MSG_CONDITIONS					= "Условия"
L.MSG_ITEM_QUALITIES				= "Качество предмета"
L.MSG_ITEMS						    = "Предметы"
L.MSG_ITEM_ALREADY_EXISTS			= "Название предмета уже существует."
L.MSG_INVALID_ITEM_NAME			    = "Неверное название предмета."


------------------------------
-- Interface tabs
------------------------------

obj = L.TABS
obj["customMedia"]	= { label="Аудио", tooltip="Настройки управления пользовательскими аудиофайлами."}
obj["general"]		= { label="Основной", tooltip="Основные настройки."}
obj["scrollAreas"]	= { label="Область прокрутки", tooltip="Настройки областей прокрутки, создание, удаление и т.д.\n\nНаведите мышь на иконки кнопок для большей информации."}
obj["events"]		= { label="События", tooltip="Настройки входящих, исходящих, и извещающих событиях.\n\nНаведите мышь на иконки кнопок для большей информации."}
obj["triggers"]		= { label="Триггеры", tooltip="Настройки системы триггеров.\n\nНаведите мышь на иконки кнопок для большей информации."}
obj["spamControl"]	= { label="Контроль спама", tooltip="Настройки спам контроля."}
obj["cooldowns"]	= { label="Срок действия", tooltip="Настройки отображения в извещениях срока действий заклинаний."}
obj["lootAlerts"]	= { label="Оповещения добычи", tooltip="Настройки отображения оповещений о добыче."}
obj["skillIcons"]	= { label="Иконки навыков", tooltip="Настройки иконок навыков."}


------------------------------
-- Interface checkboxes
------------------------------

obj = L.CHECKBOXES
obj["enableMSBT"]				= { label="Вкл/Выкл Mik's Scrolling Battle Text", tooltip="Вкл/Выкл MSBT."}
obj["stickyCrits"]				= { label="Закреплённый крит", tooltip="Отображение критов используя стиль закрепления."}
obj["enableSounds"]				= { label="Вкл/Выкл звуки", tooltip="Проигрывать звуки заданные в событиях и триггерах."}
obj["textShadowing"]			= { label="Тень текста", tooltip="Применить эффект тени к тексту для улучшения четкости шрифта."}
obj["colorPartialEffects"]		= { label="Цвет частичных эффектов", tooltip="Применяет установленные цвета для частичных эффектов."}
obj["crushing"]					= { label="Сокрушительные удары", tooltip="Отображение трейлера сокрушительных ударов."}
obj["glancing"]					= { label="Скользящие удары", tooltip="Отображение трейлера скользящих ударов."}
obj["absorb"]					= { label="Частичный поглот.", tooltip="Отображение значения частичных поглощении."}
obj["block"]					= { label="Частичный блоки", tooltip="Отображение значения частичных блоков."}
obj["resist"]					= { label="Частичный сопрот.", tooltip="Отображение значения частичной невосприимчивости."}
obj["vulnerability"]			= { label="Бонус уязвимости", tooltip="Отображение значения бонуса уязвимости."}
obj["overheal"]					= { label="Переисциление", tooltip="Отображение значений переисциления."}
obj["overkill"]					= { label="Убийства", tooltip="Отображать значение многократного уничтожения."}
obj["colorDamageAmounts"]		= { label="Цвет урона по значимости", tooltip="Позволяет установить цвета окраски урона по его значимости."}
obj["colorDamageEntry"]			= { tooltip="Вкл/Выкл цвет для этого типа урона."}
obj["colorUnitNames"]			= { label="Окраска имён", tooltip="Применить заданную окраску имён играков/существ."}
obj["colorClassEntry"]			= { tooltip="Включить окраску для этого класа."}
obj["enableScrollArea"]			= { tooltip="Вкл/Выкл область прокрутки."}
obj["inheritField"]				= { label="Перенять", tooltip="Перенять значения полей. Снимите галку для отмены."}
obj["hideSkillIcons"]			= { label="Скрыть иконки", tooltip="Не показывать иконки в этой облости прокрутки."}
obj["stickyEvent"]				= { label="Всегда закреплённый", tooltip="Всегда отображать используя стиль закрепления."}
obj["enableTrigger"]			= { tooltip="Вкл/Выкл триггер."}
obj["allPowerGains"]			= { label="Получ. ВСЕХ энергий", tooltip="Отображение всех получении энергии включая даже те что не отображаются в списке боя.\n\nПРЕДУПРЕЖДЕНИЕ: Эта опция очень спамит и игнорирует все пороги энергии и механику регуляторов.\n\nНЕ РЕКОМЕНДУЕТСЯ."}
obj["abbreviateSkills"]			= { label="Cокращать навыки", tooltip="Cокращать названия навыков (Только английские).\n\nThis can be overriden by each event with the %sl event code."}
obj["mergeSwings"]				= { label="Объединить удары", tooltip="Объединить регулярные удары в ближнем бою, которые ударяют в течение короткого промежутка времени."}
--obj["shortenNumbers"]			= { label="Shorten Numbers", tooltip="Display numbers in an abbreviated format (example: 32765 -> 33k)."}
--obj["groupNumbers"]				= { label="Group By Thousands", tooltip="Display numbers grouped by thousands (example: 32765 -> 32,765)."}
obj["hideSkills"]				= { label="Скрыть навыки", tooltip="Не отображать названия навыков в входящих и исходящих событиях.\n\nYou will give up some customization capability at the event level if you choose to use this option since it causes the %s event code to be ignored."}
obj["hideNames"]				= { label="Скрыть имена", tooltip="Не отображать названия юнитов в входящих и исходящих событиях.\n\nYou will give up some customization capability at the event level if you choose to use this option since it causes the %n event code to be ignored."}
obj["hideFullOverheals"]		= { label="Скрыть избыточное исц.", tooltip="Не показывать исцеление которого эффективное значение лечения равно нулю."}
obj["hideFullHoTOverheals"]		= { label="Скрыть полное избыточное ИзВ", tooltip="Не показывать исцеление за время которого эффективное значение лечения равно нулю."}
obj["hideMergeTrailer"]			= { label="Скрыть трейлер объединенных", tooltip="Не показывать трейлер, который определяет количество попаданий и критов в конце объединенных событий."}
obj["allClasses"]				= { label="Все классы"}
obj["enablePlayerCooldowns"]	= { label="Восстановления игрока", tooltip="Отображать оповещение когда ваши восстановления завершины."}
obj["enablePetCooldowns"]		= { label="Восстановления питомца", tooltip="Отображать оповещение когда восстановления вашего питомца завершины."}
--obj["enableItemCooldowns"]		= { label="Item Cooldowns", tooltip="Display notifications when item cooldowns complete."}
obj["lootedItems"]				= { label="Добыча предметов", tooltip="Выводит оповещение когда вы подбераете предметы."}
obj["moneyGains"]				= { label="Получ. денег", tooltip="Вкл/Выкл оповещение когда вы получаете деньги."}
obj["alwaysShowQuestItems"]		= { label="Предметы заданий", tooltip="Всегда показывать предметы заданий не обращающий внимания на выбор качества."}
obj["enableIcons"]				= { label="Вкл/Выкл иконки навыков", tooltip="Отображение иконок для событий если это возможно и они существуют."}
obj["exclusiveSkills"]			= { label="Особенные названия навыков", tooltip="Показывает только названия навыков когда иконки не доступны."}


------------------------------
-- Interface dropdowns
------------------------------

obj = L.DROPDOWNS
obj["profile"]				= { label="Текущий профиль:", tooltip="Установить текущий профиль."}
obj["normalFont"]			= { label="Шрифт - Обычный:", tooltip="Установить какой будет использоваться шрифт для обычных ударов."}
obj["critFont"]				= { label="Шрифт - Крита:", tooltip="Установить какой будет использоваться шрифт для критов."}
obj["normalOutline"]		= { label="Контур - Обычный:", tooltip="Установить какой будет использоваться стиль контура для обычных ударов."}
obj["critOutline"]			= { label="Контур - Крита:", tooltip="Установить какой будет использоваться стиль контура для критов."}
obj["scrollArea"]			= { label="Область прокрутки:", tooltip="Для настройки выберите желаемую облость прокрутки."}
obj["sound"]				= { label="Звук:", tooltip="Выберите какой проигрывать звук при выполнении события."}
obj["animationStyle"]		= { label="Стиль анимации:", tooltip="Стиль анимации для не-закрепленной анимации в области прокрутки."}
obj["stickyAnimationStyle"]	= { label="Стиль закрепления:", tooltip="Стиль анимации для закрепления в области прокрутки."}
obj["direction"]			= { label="Направление:", tooltip="Направление анимации."}
obj["behavior"]				= { label="Поведение:", tooltip="Поведение анимации."}
obj["textAlign"]			= { label="Выравнивание текста:", tooltip="Выравнивание текста анимации."}
obj["iconAlign"]			= { label="Выравнивание иконки:", tooltip="Выравнивание иконки способности по отношению к тексту."}
obj["eventCategory"]		= { label="Категория события:", tooltip="Для настройки событий выберите желаемую категорию."}
obj["outputScrollArea"]		= { label="Область вывода:", tooltip="Выберите область прокрутки для вывода информации."}
obj["mainEvent"]			= { label="Главные события:"}
obj["triggerCondition"]		= { label="Условие:", tooltip="Условие для теста."}
obj["triggerRelation"]		= { label="Отношение:"}
obj["triggerParameter"]		= { label="Параметр:"}


------------------------------
-- Interface buttons
------------------------------

obj = L.BUTTONS
obj["addCustomFont"]			= { label="Добавить шрифт", tooltip="Добовляет пользовательский шрифт к списку доступных шрифтов.\n\nWARNING: Файл шрифта должен находиться в целевой деректории *ДО* запуска WoW.\n\nНастоятельно рекомендуется поместить файл в директорию шрифтов MikScrollingBattleText\\чтобы избежать проблем."}
obj["addCustomSound"]			= { label="Добавить звук", tooltip="Добовляет пользовательский звук к списку доступных звуков.\n\nWARNING: Файл звука должен находиться в целевой деректории *ДО* запуска WoW.\n\nНастоятельно рекомендуется поместить файл в директорию звуков MikScrollingBattleText\\чтобы избежать проблем."}
obj["editCustomFont"]			= { tooltip="Нажмите чтобы редактировать пользовательский шрифт."}
obj["deleteCustomFont"]			= { tooltip="Нажмите чтобы удалить пользовательский шрифт из MSBT."}
obj["editCustomSound"]			= { tooltip="Нажмите чтобы редактировать пользовательский звук."}
obj["deleteCustomSound"]		= { tooltip="Нажмите чтобы удалить пользовательский звук из MSBT."}
obj["copyProfile"]				= { label="Скопировать", tooltip="Скопировать профиль в новый профиль с вами установленным названием."}
obj["resetProfile"]				= { label="Сброс", tooltip="Сброс профиля на стандартные установки."}
obj["deleteProfile"]			= { label="Удалить", tooltip="Удалить профиль."}
obj["masterFont"]				= { label="Основной шрифт", tooltip="Позволяет вам установить основной шрифт который будет использоваться всеми областями прокрутки текста боя и всеми событиями, пока не будет изменён в настройках областей и событий."}
obj["partialEffects"]			= { label="Частичные Эффекты", tooltip="Позволяет настроить отображение частичных эффектов"}
obj["damageColors"]				= { label="Цвета урона", tooltip="Позволяет вам установить цвет не взирая на то что установлены цвета по значимости и типу урона на текущий цвет."}
obj["classColors"]				= { label="Окраска классов", tooltip="Позволяет настроить окраску имен игроков/существ в соответствии с их классом." }
obj["inputOkay"]				= { label=OKAY, tooltip="Применить ввод."}
obj["inputCancel"]				= { label=CANCEL, tooltip="Отменить ввод."}
obj["genericSave"]				= { label=SAVE, tooltip="Сохранить изменения."}
obj["genericCancel"]			= { label=CANCEL, tooltip="Отменить изменения."}
obj["addScrollArea"]			= { label="Добавить область", tooltip="Добавить новую область прокрутки, события и триггеры также могут быть установлены на неё."}
obj["configScrollAreas"]		= { label="Настройка области", tooltip="Настройка местонахождения области прокрутки, ширины/высоты прокрутки, выравнивание текста, стиля закрепления анимации и обычного."}
obj["editScrollAreaName"]		= { tooltip="Кликните для редактирования названия области прокрутки."}
obj["scrollAreaFontSettings"]	= { tooltip="Кликните для редактирования настроек шрифта в области прокрутки который будет присвоен всем событиям в этой области прокрутки"}
obj["deleteScrollArea"]			= { tooltip="Кликните для удаление области прокрутки."}
obj["scrollAreasPreview"]		= { label="Предпросмотр", tooltip="Предпросмотр изменений."}
obj["toggleAll"]				= { label="Переключить ВСЕ", tooltip="Вкл/Выкл ВСЕ события в выбранной категории."}
obj["moveAll"]					= { label="Переместить ВСЕ", tooltip="Переместить ВСЕ события в выбранной категории в указанную область прокрутки."}
obj["eventFontSettings"]		= { tooltip="Кликните для редактирования настройки шрифта для события."}
obj["eventSettings"]			= { tooltip="Кликните для редактирования настроек события, области вывода, исходящие сообщения, звуки, и т.д."}
obj["customSound"]				= { tooltip="Кликните для вставки пользовательского звукового файла." }
obj["playSound"]				= { label="Воспр.", tooltip="Нажмите для воспроизведения выбранного звука."}
obj["addTrigger"]				= { label="Добавить триггер", tooltip="Добавить новый триггер."}
obj["triggerSettings"]			= { tooltip="Кликните для настройки условий триггера."}
obj["deleteTrigger"]			= { tooltip="Кликните для удаления триггера."}
obj["editTriggerClasses"]		= { tooltip="Кликните для редактирования классов к которым будет задействован данный триггер."}
obj["addMainEvent"]				= { label="Добавить событие", tooltip="Когда случаются КАКИЕ-НИБУДЬ события и их условия действительны, триггер просигналит.\n\nЗа исключением если одно из установленных исключений не будет действительно."}
obj["addTriggerException"]		= { label="Добавить исключение", tooltip="Когда КАКОЕ-НИБУДЬ исключение будет действительно, триггер не просигналит."}
obj["editEventConditions"]		= { tooltip="Кликните для редактирования условий события."}
obj["deleteMainEvent"]			= { tooltip="Кликните для удаления события."}
obj["addEventCondition"]		= { label="Добавить условие", tooltip="Когда КАКОЕ-НИБУДЬ условие будет действительно для выбранного события, триггер просигналит если не будет не одного действительного исключения."}
obj["editCondition"]			= { tooltip="Кликните для редактирования условия."}
obj["deleteCondition"]			= { tooltip="Кликните для удаления условия."}
obj["throttleList"]				= { label="Список регулировок", tooltip="Установка индивидуального времени для определённых навыков."}
obj["mergeExclusions"]			= { label="Слияние исключение", tooltip="Предотвращать слияние определённых навыков."}
obj["skillSuppressions"]		= { label="Блокир-ка навыков", tooltip="Скрывать навыки по их названиям."}
obj["skillSubstitutions"]		= { label="Замена навыков", tooltip="Заменить название навыка на пользовательское значение."}
obj["addSkill"]					= { label="Добавить навык", tooltip="Добавить новый навык в список."}
obj["deleteSkill"]				= { tooltip="Кликните для удаления навыка."}
obj["cooldownExclusions"]		= { label="Исключение перезарядки", tooltip="Запись навыков у которых не будут отслеживаться время перезарядки."}
obj["itemsAllowed"]				= { label="Дозволенные предметы", tooltip="Всегда показывать указанные предметы, независимо от качества предмета."}
obj["itemExclusions"]			= { label="Исключение предметов", tooltip="Запрет на отображение, указанных предметов."}
obj["addItem"]					= { label="Добавить предмет", tooltip="Добавить новый предмет в список."}
obj["deleteItem"]				= { tooltip="Нажмите чтобы удалить предмет."}


------------------------------
-- Interface editboxes
------------------------------

obj = L.EDITBOXES
obj["customFontName"]	= { label="Шрифт:", tooltip="Название, используемое для определения шрифта.\n\nПример: Мой Супер Шрифт"}
obj["customFontPath"]	= { label="Путь к шрифту:", tooltip="Путь к файлу шрифта.\n\nNOTE: Если файл находится в рекомендованном директории шрифтов\\MikScrollingBattleText, тогда впишите только названия файла, вместо полного пути.\n\nПример: мойШрифт.ttf "} 
obj["customSoundName"]	= { label="Звук:", tooltip="Название, используемое для определения звука.\n\nПример: Мой Звук"}
obj["customSoundPath"]	= { label="Путь к звуку:", tooltip="Путь к файлу звука.\n\nNOTE: Если файл находится в рекомендованном директории звуков\\MikScrollingBattleText, тогда впишите только названия файла, вместо полного пути.\n\nExample: мойЗвук.ogg "}
obj["copyProfile"]		= { label="Новое название профиля:", tooltip="Название нового профиля в который будет скопирован выбранный профиль."}
obj["partialEffect"]	= { tooltip="Трейлер который будут добавляться при возникновении частичного эффекта."}
obj["scrollAreaName"]	= { label="Новое названия области прокрутки:", tooltip="Новое название для области прокрутки."}
obj["xOffset"]			= { label="X смещение:", tooltip="Смещение по X в выбранной области прокрутки."}
obj["yOffset"]			= { label="Y смещение:", tooltip="Смещение по Y в выбранной области прокрутки."}
obj["eventMessage"]		= { label="Сообщение вывода:", tooltip="Сообщение которое будет отображаться при свершении события."}
obj["soundFile"]		= { label="Звуковой файл:", tooltip="Название звукового файла который будет проигрываться при свершении события."}
obj["iconSkill"]		= { label="Иконка навыка:", tooltip="Название или идентификатор заклинания чья иконка должна отображаться при свершении события.\n\nMSBT будет автоматически пробовать найти подходящую иконку если нет назначенной.\n\nПРИМЕЧАНИЕ: Если навык не может быть найден в книге заклинаний играющего класса в момент свершения событий то идентификатор заклинания должен использоваться вместо названия.  Может быть использовано для поиска большинство онлайновых баз данных таких как wowhead."}
obj["skillName"]		= { label="Название навыка:", tooltip="Название навыка который будет добавлен."}
obj["substitutionText"]	= { label="Текст замещения:", tooltip="Текст который будет заменять название навыка."}
obj["itemName"]			= { label="Название предмета:", tooltip="Название добавляемого предмета."}


------------------------------
-- Interface sliders
------------------------------

obj = L.SLIDERS
obj["animationSpeed"]		= { label="Скорость анимации", tooltip="Установка основной скорости анимации.\n\nКаждая область прокрутки также может быть настроена в независимости от основной скорости."}
obj["normalFontSize"]		= { label="Обычный размер шрифта", tooltip="Установка размера шрифта для обычного текста."}
obj["normalFontOpacity"]	= { label="Прозрачность текста", tooltip="Установка прозрачности для обычного текста."}
obj["critFontSize"]			= { label="Размер шрифта Крита", tooltip="Установка размера шрифта для критических ударов."}
obj["critFontOpacity"]		= { label="Прозрачность Крита", tooltip="Установка прозрачности для критических ударов."}
obj["scrollHeight"]			= { label="Высота прокрутки", tooltip="Регулировка высоты области прокрутки."}
obj["scrollWidth"]			= { label="Ширина прокрутки", tooltip="Регулировка ширины области прокрутки."}
obj["scrollAnimationSpeed"]	= { label="Скорость анимации", tooltip="Регулировка скорости анимации в области прокрутки."}
obj["powerThreshold"]		= { label="Порог. вел. энергии", tooltip="Порог величины энергии, привысев который она будет отображаться."}
obj["healThreshold"]		= { label="Порог. вел. исцеления", tooltip="Порог величины исцеления, привысев который она будет отображаться."}
obj["damageThreshold"]		= { label="Порог. вел. урона", tooltip="Порог величины урона, привысев который она будет отображаться."}
obj["dotThrottleTime"]		= { label="Регулятор УзВ", tooltip="Число секунд, чтобы замедлить отображение Урона за Время."}
obj["hotThrottleTime"]		= { label="Регулятор ИзВ", tooltip="Число секунд, чтобы замедлить отображение Исцеления за Время."}
obj["powerThrottleTime"]	= { label="Регулятор времени энергии", tooltip="Число секунд, чтобы замедлить отображение изменения энергии."}
obj["skillThrottleTime"]	= { label="Регулятор время", tooltip="Число секунд, чтобы замедлить отображение навыков."}
obj["cooldownThreshold"]	= { label="Порог. вел. перезарядки", tooltip="Навыки с перезарядкой меньший чем установленное число секунд не будут отображаться."}


------------------------------
-- Event categories
------------------------------
obj = L.EVENT_CATEGORIES
obj[1] = "Входящий - Игрок"
obj[2] = "Входящий - Питомец"
obj[3] = "Исходящий - Игрок"
obj[4] = "Исходящий - Питомец"
obj[5] = "Извещения"


------------------------------
-- Event codes
------------------------------

obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - Значение получаемого урона.\n"
obj["HEALING_TAKEN"]		= "%a - Значение получаемого лечения.\n"
obj["DAMAGE_DONE"]			= "%a - Значение нанесённого урона.\n"
obj["HEALING_DONE"]			= "%a - Значение нанесённого лечения.\n"
obj["ABSORBED_AMOUNT"]		= "%a - Значение поглот. урона.\n"
obj["AURA_AMOUNT"]			= "%a - Значение стеков ауры.\n"
obj["ENERGY_AMOUNT"]		= "%a - Значение энергии.\n"
--obj["CHI_AMOUNT"]			= "%a - Amount of chi you have.\n"
obj["CP_AMOUNT"]			= "%a - Значение сколько приёмов в серии.\n"
obj["HOLY_POWER_AMOUNT"]	= "%a - Значение вашей энергии Света.\n"
--obj["SHADOW_ORBS_AMOUNT"]	= "%a - Amount of shadow orbs you have.\n"
obj["HONOR_AMOUNT"]			= "%a - Значение чести.\n"
obj["REP_AMOUNT"]			= "%a - Значение репутации.\n"
obj["ITEM_AMOUNT"]			= "%a - Значение добытого предмета.\n"
obj["SKILL_AMOUNT"]			= "%a - Значение очков полученного навыка.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - Значение полученного опыта.\n"
obj["PARTIAL_AMOUNT"]		= "%a - Значение частичного эффекта.\n"
obj["ATTACKER_NAME"]		= "%n - Имя атакующего.\n"
obj["HEALER_NAME"]			= "%n - Имя лекаря.\n"
obj["ATTACKED_NAME"]		= "%n - Имя атакующего юнита.\n"
obj["HEALED_NAME"]			= "%n - Имя исцеляющего юнита.\n"
obj["BUFFED_NAME"]			= "%n - Имя юнита с положительным эффектом.\n"
obj["UNIT_KILLED"]			= "%n - Название убитого юнита.\n"
obj["SKILL_NAME"]			= "%s - Название навыка.\n"
obj["SPELL_NAME"]			= "%s - Название заклинания.\n"
obj["DEBUFF_NAME"]			= "%s - Название отрицательного эффекта.\n"
obj["BUFF_NAME"]			= "%s - Название положительного эффектов\n"
obj["ITEM_BUFF_NAME"]		= "%s - Название предмета с положительным эффектом.\n"
obj["EXTRA_ATTACKS"]		= "%s - Название навыка предоставляющий дополнительную атаку.\n"
obj["SKILL_LONG"]			= "%sl - Длинный от %s. Используется для замены сокращений событий.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - Типа полученного урона.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - Типа нанесенного урона.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - Название источника урона (падение, утопление, лава, т.д. и т.п...)\n"
obj["FACTION_NAME"]			= "%e - Название фракции.\n"
obj["EMOTE_TEXT"]			= "%e - Текст эмоций.\n"
obj["MONEY_TEXT"]			= "%e - Текст получения денег.\n"
obj["COOLDOWN_NAME"]		= "%e - Название готового навыка.\n"
--obj["ITEM_COOLDOWN_NAME"]	= "%e - The name of item that is ready.\n"
obj["ITEM_NAME"]			= "%e - Название добытого предмета.\n"
obj["POWER_TYPE"]			= "%p - Тип энергии (энергия, ярость, мана).\n"
obj["TOTAL_ITEMS"]			= "%t - Общее количество добытых предметов в инвентаре."


------------------------------
-- Incoming events
------------------------------

obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="Ближний удар", tooltip="Вкл/Выкл входящие ближние удары."}
obj["INCOMING_DAMAGE_CRIT"]					= { label="Ближний крит", tooltip="Вкл/Выкл входящие ближние критические удары."}
obj["INCOMING_MISS"]						= { label="Ближний промах", tooltip="Вкл/Выкл входящие ближние промахи."}
obj["INCOMING_DODGE"]						= { label="Ближний уклон.", tooltip="Вкл/Выкл входящие ближние уклонения."}
obj["INCOMING_PARRY"]						= { label="Ближний парир.", tooltip="Вкл/Выкл входящие ближние парирования."}
obj["INCOMING_BLOCK"]						= { label="Ближний блок", tooltip="Вкл/Выкл входящие ближние блоки."}
obj["INCOMING_DEFLECT"]						= { label="Ближний отклон.", tooltip="Вкл/Выкл входящие ближние отклонения."}
obj["INCOMING_ABSORB"]						= { label="Ближний поглот.", tooltip="Вкл/Выкл входящие поглощения ближнего урона."}
obj["INCOMING_IMMUNE"]						= { label="Ближний невоспр.", tooltip="Вкл/Выкл входящий ближний урон к которому вы невосприимчевы."}
obj["INCOMING_SPELL_DAMAGE"]				= { label="Удар заклинания", tooltip="Вкл/Выкл входящие удары заклинания."}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Крит заклинания", tooltip="Вкл/Выкл входящие критические удары заклинания."}
obj["INCOMING_SPELL_DOT"]					= { label="УзВ заклинания", tooltip="Вкл/Выкл входящий урон за время заклинанием."}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="Крит УзВ", tooltip="Вкл/Выкл входящий крит урона за время."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Удары Ранящиего щита", tooltip="Вкл/Выкл входящий урон Ранящиего щита."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Криты Ранящего щита", tooltip="Вкл/Выкл входящий крит Ранящего щита."}
obj["INCOMING_SPELL_MISS"]					= { label="Промах заклинания", tooltip="Вкл/Выкл входящие промахи заклинания."}
obj["INCOMING_SPELL_DODGE"]					= { label="Уклон. заклинания", tooltip="Вкл/Выкл входящие уклонения от заклинания."}
obj["INCOMING_SPELL_PARRY"]					= { label="Парир. заклинания", tooltip="Вкл/Выкл входящие парирования заклинания."}
obj["INCOMING_SPELL_BLOCK"]					= { label="Блок заклинания", tooltip="Вкл/Выкл входящие блоки заклинания."}
obj["INCOMING_SPELL_DEFLECT"]				= { label="Отклон заклинания", tooltip="Вкл/Выкл входящие отклонения заклинания."}
obj["INCOMING_SPELL_RESIST"]				= { label="Сопрот. Заклинания", tooltip="Вкл/Выкл входящие сопротивления заклинания."}
obj["INCOMING_SPELL_ABSORB"]				= { label="Поглот. Заклинания", tooltip="Вкл/Выкл входящие поглощения урона от нанесённых вам заклинаний."}
obj["INCOMING_SPELL_IMMUNE"]				= { label="Невоспр. Заклинания", tooltip="Вкл/Выкл входящий урон от заклинаний к которому вы невосприимчевы."}
obj["INCOMING_SPELL_REFLECT"]				= { label="Отраж. Заклинания", tooltip="Вкл/Выкл входящий урон заклинаний которые вы отразили."}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="Прерв. Заклинания", tooltip="Вкл/Выкл входящие прерывания заклинаний."}
obj["INCOMING_HEAL"]						= { label="Исцеление", tooltip="Вкл/Выкл входящие исцеления."}
obj["INCOMING_HEAL_CRIT"]					= { label="Крит исцеления", tooltip="Вкл/Выкл входящие критические исцеления."}
obj["INCOMING_HOT"]							= { label="Исцеление за Время", tooltip="Вкл/Выкл входящие Исцеление за Время."}
obj["INCOMING_HOT_CRIT"]					= { label="Крит исцеление за время", tooltip="Вкл/Выкл входящий крит Исцеление за Время."}
obj["INCOMING_ENVIRONMENTAL"]				= { label="Урон окружающей среды", tooltip="Урон окружающей среды (Падение, Утопление, Лава, т.д. и т.п...)."}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="Ближний удар", tooltip="Вкл/Выкл вашего питомца входящие ближние удары."}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="Ближний крит", tooltip="Вкл/Выкл вашего питомца входящие ближние критические удары."}
obj["PET_INCOMING_MISS"]						= { label="Ближний промах", tooltip="Вкл/Выкл вашего питомца входящие ближние промахи."}
obj["PET_INCOMING_DODGE"]						= { label="Ближний уклон.", tooltip="Вкл/Выкл вашего питомца входящие ближние уклонения."}
obj["PET_INCOMING_PARRY"]						= { label="Ближний парир.", tooltip="Вкл/Выкл вашего питомца входящие ближние парирования."}
obj["PET_INCOMING_BLOCK"]						= { label="Ближний блок", tooltip="Вкл/Выкл вашего питомца входящие ближние блоки."}
obj["PET_INCOMING_DEFLECT"]						= { label="Ближний отклон.", tooltip="Вкл/Выкл вашего питомца входящие ближние отклонения."}
obj["PET_INCOMING_ABSORB"]						= { label="Ближний поглот.", tooltip="Вкл/Выкл поглощения вашем питомцем входящего ближнего урона."}
obj["PET_INCOMING_IMMUNE"]						= { label="Ближний невоспр.", tooltip="Вкл/Выкл входящий ближний урон к которому имуннен питомец."}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="Удар заклинания", tooltip="Вкл/Выкл вашего питомца входящие удары заклинания."}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Крит заклинания", tooltip="Вкл/Выкл вашего питомца входящие критические удары заклинания."}
obj["PET_INCOMING_SPELL_DOT"]					= { label="УзВ заклинания", tooltip="Вкл/Выкл вашего питомца входящий урон за время заклинанием."}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="Крит УзВ", tooltip="Вкл/Выкл входящий крит урона за время."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Удары ранящего щита", tooltip="Вкл/Выкл входящий урон по вашему питомцу от Ранящего щита."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Криты ранящиего щита", tooltip="Вкл/Выкл входящий крит по вашему питомцу от Ранящиего щита."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="Промах заклинания", tooltip="Вкл/Выкл вашего питомца входящие промахи заклинания."}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="Уклон. заклинания", tooltip="Вкл/Выкл вашего питомца входящие уклонения от заклинания."}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="Парир. заклинания", tooltip="Вкл/Выкл вашего питомца входящие парирования заклинания."}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="Блок Заклинания", tooltip="Вкл/Выкл вашего питомца входящие блоки заклинания."}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="Отклон заклинания", tooltip="Вкл/Выкл вашего питомца входящие отклонения заклинания."}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="Сопрот. Заклинания", tooltip="Вкл/Выкл вашего питомца входящие сопротивления заклинания."}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="Поглот. Заклинания", tooltip="Вкл/Выкл поглощения урона вашим питомцем от входящих заклинаний."}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="Невоспр. Заклинания", tooltip="Вкл/Выкл входящий урон от заклинаний к которому невосприимчив ваш питомец."}
obj["PET_INCOMING_HEAL"]						= { label="Исцеление", tooltip="Вкл/Выкл вашего питомца входящие исцеления."}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="Крит исцеления", tooltip="Вкл/Выкл вашего питомца входящие критические исцеления."}
obj["PET_INCOMING_HOT"]							= { label="Исцеление за Время", tooltip="Вкл/Выкл вашего питомца входящие исцеления за время."}
obj["PET_INCOMING_HOT_CRIT"]					= { label="Крит исцеление за время", tooltip="Вкл/Выкл вашего питомца входящий крит Исцеление за Время."}


------------------------------
-- Outgoing events
------------------------------

obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="Ближний удар", tooltip="Вкл/Выкл исходящие ближние удары."}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="Ближний крит", tooltip="Вкл/Выкл исходящие ближние критические удары."}
obj["OUTGOING_MISS"]						= { label="Ближний промах", tooltip="Вкл/Выкл исходящие ближние промахи."}
obj["OUTGOING_DODGE"]						= { label="Ближний уклон.", tooltip="Вкл/Выкл исходящие ближние уклонения."}
obj["OUTGOING_PARRY"]						= { label="Ближний парир.", tooltip="Вкл/Выкл исходящие ближние парирования."}
obj["OUTGOING_BLOCK"]						= { label="Ближний блок", tooltip="Вкл/Выкл исходящие ближние блоки."}
obj["OUTGOING_DEFLECT"]						= { label="Ближний отклон.", tooltip="Вкл/Выкл исходящие ближние отклонения."}
obj["OUTGOING_ABSORB"]						= { label="Ближний поглот.", tooltip="Вкл/Выкл исходящие поглощения ближнего урона."}
obj["OUTGOING_IMMUNE"]						= { label="Ближний невоспр.", tooltip="Вкл/Выкл исходящий ближний урон когда враг невосприимчив к нему."}
obj["OUTGOING_EVADE"]						= { label="Ближний 'Мимо'", tooltip="Вкл/Выкль исходящие ближние evades."}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="Удар заклинания", tooltip="Вкл/Выкл исходящие удары заклинаний."}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Крит заклинания", tooltip="Вкл/Выкл исходящие критические удары заклинаний."}
obj["OUTGOING_SPELL_DOT"]					= { label="УзВ заклинания", tooltip="Вкл/Выкл исходящий урон за время заклинания."}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="Крит УзВ", tooltip="Вкл/Выкл исходящий крит урона за время."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Удары ранящего щита", tooltip="Вкл/Выкл исходящий урон от Ранящего щита."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Криты ранящего щита", tooltip="Вкл/Выкл исходящий крит от Ранящего щита."}
obj["OUTGOING_SPELL_MISS"]					= { label="Промах заклинания", tooltip="Вкл/Выкл исходящие промахи заклинаний."}
obj["OUTGOING_SPELL_DODGE"]					= { label="Уклон. Заклинания", tooltip="Вкл/Выкл исходящие уклонения от заклинаний."}
obj["OUTGOING_SPELL_PARRY"]					= { label="Парир. Заклинания", tooltip="Вкл/Выкл исходящие парирования заклинаний."}
obj["OUTGOING_SPELL_BLOCK"]					= { label="Блок Заклинания", tooltip="Вкл/Выкл исходящие блокирование заклинаний."}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="Отклон заклинания", tooltip="Вкл/Выкл исходящие отклонения заклинания."}
obj["OUTGOING_SPELL_RESIST"]				= { label="Сопрот. заклинания", tooltip="Вкл/Выкл исходящие сопротивление заклинаниям."}
obj["OUTGOING_SPELL_ABSORB"]				= { label="Поглот. заклинания", tooltip="Вкл/Выкл исходящие поглощения урона от исходящих заклинаний."}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="Невоспр. заклинания", tooltip="Вкл/Выкл исходящий урон заклинаний когда враг невосприимчив к нему."}
obj["OUTGOING_SPELL_REFLECT"]				= { label="Отраж. заклинания", tooltip="Вкл/Выкл исходящий урон заклинаний отраженный назад на вас."}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="Прерывание заклинания", tooltip="Вкл/Выкл исходящие прерывания заклинаний."}
obj["OUTGOING_SPELL_EVADE"]					= { label="'Мимо' заклинания", tooltip="Вкл/Выкл исходящие 'Мимо' Заклинаний."}
obj["OUTGOING_HEAL"]						= { label="Исцеление", tooltip="Вкл/Выкл исходящие исцеления."}
obj["OUTGOING_HEAL_CRIT"]					= { label="Крит исцеления", tooltip="Вкл/Выкл исходящие критические исцеления."}
obj["OUTGOING_HOT"]							= { label="Исцеление за Время", tooltip="Вкл/Выкл исходящие исцеления за время."}
obj["OUTGOING_HOT_CRIT"]					= { label="Крит исцеление за время", tooltip="Вкл/Выкл исходящий крит исцеления за время."}
obj["OUTGOING_DISPEL"]						= { label="Рассеивания", tooltip="Вкл/Выкл исходящие рассеивания."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="Ближний удар", tooltip="Вкл/Выкл вашего питомца исходящие ближние удары."}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="Ближний крит", tooltip="Вкл/Выкл вашего питомца исходящие ближние критические удары."}
obj["PET_OUTGOING_MISS"]						= { label="Ближний промах", tooltip="Вкл/Выкл вашего питомца исходящие ближние промахи."}
obj["PET_OUTGOING_DODGE"]						= { label="Ближний уклон.", tooltip="Вкл/Выкл вашего питомца исходящие ближние уклонения."}
obj["PET_OUTGOING_PARRY"]						= { label="Ближний парир.", tooltip="Вкл/Выкл вашего питомца исходящие ближние парирования."}
obj["PET_OUTGOING_BLOCK"]						= { label="Ближний блок", tooltip="Вкл/Выкл вашего питомца исходящие ближние блоки."}
obj["PET_OUTGOING_DEFLECT"]						= { label="Ближний отклон.", tooltip="Вкл/Выкл вашего питомца исходящие ближние отклонения."}
obj["PET_OUTGOING_ABSORB"]						= { label="Ближний поглот.", tooltip="Вкл/Выкл вашего питомца исходящие поглощения ближнего урона."}
obj["PET_OUTGOING_IMMUNE"]						= { label="Ближний невоспр.", tooltip="Вкл/Выкл вашего питомца исходящие ближней урон к которому невосприимчив враг."}
obj["PET_OUTGOING_EVADE"]						= { label="Ближний 'Мимо'", tooltip="Вкл/Выкл вашего питомца исходящие ближние 'Мимо'."}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="Удар заклинания", tooltip="Вкл/Выкл вашего питомца исходящие удары заклинаний."}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Крит заклинания", tooltip="Вкл/Выкл вашего питомца исходящие критические удары заклинаний."}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="УзВ заклинания", tooltip="Вкл/Выкл исходящие заклинания наносящие урон за время."}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="Крит УзВ", tooltip="Вкл/Выкл исходящий крит урона за время."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Удары ранящего щита", tooltip="Вкл/Выкл исходящий урот вашего питомца от Ранящего щита."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Криты ранящего щита", tooltip="Вкл/Выкл исходящий крит вашего питомца от Ранящего щита.."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="Промах заклинания", tooltip="Вкл/Выкл вашего питомца исходящие промахи заклинаний."}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="Уклон. заклинания", tooltip="Вкл/Выкл вашего питомца исходящие уклонения от заклинаний."}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="Парир. заклинания", tooltip="Вкл/Выкл вашего питомца исходящие парирования заклинаний."}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="Блок заклинания", tooltip="Вкл/Выкл вашего питомца исходящие блокирование заклинаний."}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="Отклон заклинания", tooltip="Вкл/Выкл вашего питомца исходящие отклонения заклинания."}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="Сопрот. заклинания", tooltip="Вкл/Выкл вашего питомца исходящие сопротивление заклинаниям."}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="Поглот. заклинания", tooltip="Вкл/Выкл исходящие поглощения урона от исходящих заклинаний."}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="Невоспр. заклинания", tooltip="Вкл/Выкл исходящий урон от заклинаний к которому невосприимчив враг."}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="'Мимо' заклинаний", tooltip="Вкл/Выкл исходящие 'Мимо' Заклинаний."}
obj["PET_OUTGOING_HEAL"]						= { label="Исцеление", tooltip="Вкл/Выкл исходящие исцеления питомца."}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="Крит исцеления", tooltip="Вкл/Выкл исходящие критические исцеления питомца."}
obj["PET_OUTGOING_HOT"]							= { label="Исцеление за Время", tooltip="Вкл/Выкл исходящие исцеления за время питомца."}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="Крит исцеление за время", tooltip="Вкл/Выкл исходящий крит исцеления за время питомца."}
obj["PET_OUTGOING_DISPEL"]						= { label="Рассеивания", tooltip="Вкл/Выкл исходящие рассеивания"}


------------------------------
-- Notification events
------------------------------

obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="Отриц. эффекты", tooltip="Вкл/Выкл оповещение о заражении отрицательными эффектами."}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="Стаки дебаффа", tooltip="Включить оповещение сколькими стаками отрицательных эффектов вы поражены."}
obj["NOTIFICATION_BUFF"]				= { label="Полож. эффекты", tooltip="Вкл/Выкл оповещение о получении положительных эффектов."}
obj["NOTIFICATION_BUFF_STACK"]			= { label="Стаки баффа", tooltip="Включить оповещение сколько стаков положительного эффектка вы получили."}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="Полож. эффекты Предметов", tooltip="Вкл/Выкл оповещение о положительных эффектах полученных вашими предметами."}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="Пропад. отриц. эффектов", tooltip="Вкл/Выкл оповещение о пропадание с вас отрицательных эффектов."}
obj["NOTIFICATION_BUFF_FADE"]			= { label="Пропад. полож. эффектов", tooltip="Вкл/Выкл оповещение о пропадание с вас положительных эффектов."}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="Пропад. полож. эф. предметов", tooltip="Вкл/Выкл оповещение о пропадание с предметов положительных эффектов."}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="Начало боя", tooltip="Вкл/Выкл оповещение о том когда вы начинаете бой."}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="Выход из боя", tooltip="Вкл/Выкл оповещение о том когда вы выходите из бой."}
obj["NOTIFICATION_POWER_GAIN"]			= { label="Получ. энергии", tooltip="Вкл/Выкл оповещение когда вы получаете дополнительную ману, ярость, или энергию."}
obj["NOTIFICATION_POWER_LOSS"]			= { label="Потеря энергии", tooltip="Вкл/Выкл оповещение когда теряете ману, ярость, или энергию от похищения."}
--obj["NOTIFICATION_ALT_POWER_GAIN"]		= { label="Alternate Power Gains", tooltip="Enable when you gain alternate power such as sound level on Atramedes."}
--obj["NOTIFICATION_ALT_POWER_LOSS"]		= { label="Alternate Power Losses", tooltip="Enable when you lose alternate power from drains."}
--obj["NOTIFICATION_CHI_CHANGE"]			= { label="Chi Changes", tooltip="Enable when you change chi."}
--obj["NOTIFICATION_CHI_FULL"]			= { label="Chi Full", tooltip="Enable when you attain full chi."}
obj["NOTIFICATION_CP_GAIN"]				= { label="Получ. Приёма в Серии", tooltip="Вкл/Выкл оповещение когда вы получаете приём в серии."}
obj["NOTIFICATION_CP_FULL"]				= { label="Макс. Приёмов в Серии", tooltip="Вкл/Выкл оповещение когда вы достигаете максимального количества приемов в серии."}
obj["NOTIFICATION_HOLY_POWER_CHANGE"]	= { label="Изменение энергии Света", tooltip="Вкл/Выкл оповещение изменения вашей энергии Света."}
obj["NOTIFICATION_HOLY_POWER_FULL"]		= { label="Полная энергия Света", tooltip="Вкл/Выкл оповещение когда вы достигаете полной энергии Света."}
--obj["NOTIFICATION_SHADOW_ORBS_CHANGE"]	= { label="Shadow Orb Changes", tooltip="Enable when you change shadow orbs."}
--obj["NOTIFICATION_SHADOW_ORBS_FULL"]	= { label="Shadow Orbs Full", tooltip="Enable when you attain full shadow orbs."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="Получ. чести", tooltip="Вкл/Выкл оповещение когда вы получаете очки чести."}
obj["NOTIFICATION_REP_GAIN"]			= { label="Получ. репутации", tooltip="Вкл/Выкл оповещение когда вы получаете очки репутации."}
obj["NOTIFICATION_REP_LOSS"]			= { label="Потеря репутации", tooltip="Вкл/Выкл оповещение когда вы теряете очки репутации."}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="Получ. навыков", tooltip="Вкл/Выкл оповещение когда вы получаете очки к навыку."}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="Получ. опыта", tooltip="Вкл/Выкл оповещение когда вы получаете очки опыта."}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="Игрока победный удар", tooltip="Вкл/Выкл оповещение когда вы рядом с враждебным игроком получаете Победный удар."}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="Победный удар НИПа", tooltip="Вкл/Выкл оповещение когда вы рядом с НИПом получаете Победный удар."}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="Экстра атаки", tooltip="Вкл/Выкл оповещение когда вы получаете дополнительные атаки такие как Оружие неистовства ветра, Специализация на владении мечами, и т.д."}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="Получ. врагом полож. эффектов", tooltip="Вкл/Выкл оповещение о получении положительных эффектов вашей текущей враждебной цели."}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="Эмоции монстров", tooltip="Вкл/Выкл эмоции монстров которые в текущий момент в цели."}


------------------------------
-- Trigger info
------------------------------

-- Main events.
obj = L.TRIGGER_DATA
obj["SWING_DAMAGE"]				= "Обычный Урон"
obj["RANGE_DAMAGE"]				= "Дальний урон"
obj["SPELL_DAMAGE"]				= "Урон навыков"
obj["GENERIC_DAMAGE"]			= "Рывок/Навык/Дальний урон"
obj["SPELL_PERIODIC_DAMAGE"]	= "Периодический урон навыка (УзВ)"
obj["DAMAGE_SHIELD"]			= "Урон от Ранящего щита"
obj["DAMAGE_SPLIT"]				= "Прерывистый урон"
obj["ENVIRONMENTAL_DAMAGE"]		= "Урон окружающей среды"
obj["SWING_MISSED"]				= "Промах рывка"
obj["RANGE_MISSED"]				= "Дальний промах"
obj["SPELL_MISSED"]				= "Промах навыка"
obj["GENERIC_MISSED"]			= "Рывок/Навык/Дальний промах"
obj["SPELL_PERIODIC_MISSED"]	= "Промах Периодического навыка"
obj["SPELL_DISPEL_FAILED"]		= "Неудачное Рассеивание"
obj["DAMAGE_SHIELD_MISSED"]		= "Промах Ранящего щита"
obj["SPELL_HEAL"]				= "Исцеление"
obj["SPELL_PERIODIC_HEAL"]		= "Периодическое исцеление (ИзВ)"
obj["SPELL_ENERGIZE"]			= "Прирост энергии"
obj["SPELL_PERIODIC_ENERGIZE"]	= "Периодический прирост энергии"
obj["SPELL_DRAIN"]				= "Похищение энергии"
obj["SPELL_PERIODIC_DRAIN"]		= "Периодическое похищение энергии"
obj["SPELL_LEECH"]				= "Выпивание энергии"
obj["SPELL_PERIODIC_LEECH"]		= "Периодическое выпивание энергии"
obj["SPELL_INTERRUPT"]			= "Прерывание Навыка"
obj["SPELL_AURA_APPLIED"]		= "Использование Ауры"
obj["SPELL_AURA_REMOVED"]		= "Снятие Аура"
obj["SPELL_STOLEN"]				= "Хищение Ауры"
obj["SPELL_DISPEL"]				= "Рассеивание Ауры"
obj["SPELL_AURA_REFRESH"]		= "Обновление ауры"
obj["SPELL_AURA_BROKEN_SPELL"]	= "Прекращение ауры"
obj["ENCHANT_APPLIED"]			= "Использование Очарования"
obj["ENCHANT_REMOVED"]			= "Снятие очарования"
obj["SPELL_CAST_START"]			= "Начало Чтения"
obj["SPELL_CAST_SUCCESS"]		= "Успешное Чтение"
obj["SPELL_CAST_FAILED"]		= "Неудачное Чтение"
obj["SPELL_SUMMON"]				= "Призывание   "
obj["SPELL_CREATE"]				= "Создавание"
obj["PARTY_KILL"]				= "Победный Удар"
obj["UNIT_DIED"]				= "Смерть объекта"
obj["UNIT_DESTROYED"]			= "Ликвидация объекта"
obj["SPELL_EXTRA_ATTACKS"]		= "Экстра атаки"
obj["UNIT_HEALTH"]				= "Изменение здоровья"
obj["UNIT_POWER"]				= "Изменение энергии"
obj["SKILL_COOLDOWN"]			= "Завершение восстановления игрока"
obj["PET_COOLDOWN"]				= "Завершение восстановления питомца"
--obj["ITEM_COOLDOWN"]			= "Item Cooldown Complete"
 
-- Main event conditions.
obj["sourceName"]				= "Название источника"
obj["sourceAffiliation"]		= "Источник принадлежности объекта"
obj["sourceReaction"]			= "Источник реакции объекта"
obj["sourceControl"]			= "Источник контроля объекта"
obj["sourceUnitType"]			= "Тип источника"
obj["recipientName"]			= "Название получателя"
obj["recipientAffiliation"]		= "Получатель принадлежности объекта"
obj["recipientReaction"]		= "Получатель реакции объекта"
obj["recipientControl"]			= "Получатель контроля объекта"
obj["recipientUnitType"]		= "Тип получателя"
obj["skillID"]					= "ID навыка"
obj["skillName"]				= "Название навыка"
obj["skillSchool"]				= "Школа навыка"
obj["extraSkillID"]				= "Экстра ID навыка"
obj["extraSkillName"]			= "Экстра название навыка"
obj["extraSkillSchool"]			= "Экстра школа навыка"
obj["amount"]					= "Значение"
obj["overkillAmount"]			= "Значение многократного уничтожения"
obj["damageType"]				= "Тип урона"
obj["resistAmount"]				= "Значение сопрот."
obj["blockAmount"]				= "Значение блока"
obj["absorbAmount"]				= "Значение поглот."
obj["isCrit"]					= "Крит"
obj["isGlancing"]				= "Косые удары"
obj["isCrushing"]				= "Сокрушительный удар"
obj["extraAmount"]				= "Экстра значение"
obj["missType"]					= "Тип промаха"
obj["hazardType"]				= "Тип опасности"
obj["powerType"]				= "Тип энергии"
obj["auraType"]					= "Тип ауры"
obj["threshold"]				= "Порог"
obj["unitID"]					= "ID объекта"
obj["unitReaction"]				= "Реакция объекта"
--obj["itemID"]					= "Item ID"
--obj["itemName"]					= "Item Name"

-- Exception conditions.
obj["activeTalents"]			= "Активный талант"
obj["buffActive"]				= "Активность заклинания"
obj["buffInactive"]				= "Бездействующий бафф"
obj["currentCP"]				= "Текущие очки энергии"
obj["currentPower"]				= "Текущая сила"
obj["inCombat"]				    = "В бою"
obj["recentlyFired"]			= "Недавно просигналивший триггер"
obj["trivialTarget"]			= "Обычная цель"
obj["unavailableSkill"]			= "Недоступный навык"
obj["warriorStance"]			= "Стоики война"
obj["zoneName"]					= "Название зоны"
obj["zoneType"]					= "Тип зоны"
 
-- Relationships.
obj["eq"]						= "Равен"
obj["ne"]						= "Не равен"
obj["like"]						= "Похожий"
obj["unlike"]					= "Не похожий"
obj["lt"]						= "Меньше чем"
obj["gt"]						= "Больше чем"
 
-- Affiliations.
obj["affiliationMine"]			= "Моё"
obj["affiliationParty"]			= "Участник группы"
obj["affiliationRaid"]			= "Участник рейда"
obj["affiliationOutsider"]		= "Аутсайдер"
obj["affiliationTarget"]		= TARGET
obj["affiliationFocus"]			= "Фокус"
obj["affiliationYou"]			= YOU

-- Reactions.
obj["reactionFriendly"]			= "Дружелюбный"
obj["reactionNeutral"]			= "Нейтральный"
obj["reactionHostile"]			= HOSTILE

-- Control types.
obj["controlServer"]			= "Сервер"
obj["controlHuman"]				= "Человек"

-- Unit types.
obj["unitTypePlayer"]			= PLAYER 
obj["unitTypeNPC"]				= "НИП"
obj["unitTypePet"]				= PET
obj["unitTypeGuardian"]			= "Страж"
obj["unitTypeObject"]			= "Объект"

-- Aura types.
obj["auraTypeBuff"]				= "Полож. эффект"
obj["auraTypeDebuff"]			= "Отриц. эффект"

-- Zone types.
obj["zoneTypeArena"]			= "Арена"
obj["zoneTypePvP"]				= BATTLEGROUND
obj["zoneTypeParty"]			= "Подземелье на 5-чел"
obj["zoneTypeRaid"]				= "Рейдовое подземелье"

-- Booleans
obj["booleanTrue"]				= "Верный"
obj["booleanFalse"]				= "Неверный"


------------------------------
-- Font info
------------------------------

-- Font outlines.
obj = L.OUTLINES
obj[1] = "Нету"
obj[2] = "Тонкий"
obj[3] = "Жирный"
--obj[4] = "Monochrome"
--obj[5] = "Monochrome + Thin"
--obj[6] = "Monochrome + Thick"

-- Text aligns.
obj = L.TEXT_ALIGNS
obj[1] = "Влево"
obj[2] = "По центру"
obj[3] = "Вправо"


------------------------------
-- Sound info
------------------------------

obj = L.SOUNDS
obj["MSBT Low Mana"]	= "Малый запас маны"
obj["MSBT Low Health"]	= "Малый запас здоровья"
obj["MSBT Cooldown"]	= "Перезарядка"


------------------------------
-- Animation style info
------------------------------

-- Animation styles
obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "Угловой"
obj["Horizontal"]	= "Горизонтальный"
obj["Parabola"]		= "Парабола"
obj["Straight"]		= "Прямой"
obj["Static"]		= "Статика"
obj["Pow"]			= "Ручеёк"

-- Animation style directions.
obj["Alternate"]	= "Чередоваться"
obj["Left"]			= "Влево"
obj["Right"]		= "Вправо"
obj["Up"]			= "Вверх"
obj["Down"]			= "Вниз"

-- Animation style behaviors.
obj["AngleUp"]			= "Угол вверх"
obj["AngleDown"]		= "Угол вниз"
obj["GrowUp"]			= "Увеличиваться"
obj["GrowDown"]			= "Уменьшаться"
obj["CurvedLeft"]		= "Изогнутый влево"
obj["CurvedRight"]		= "Изогнутый вправо"
obj["Jiggle"]			= "Тряска"
obj["Normal"]			= "Нормальный"