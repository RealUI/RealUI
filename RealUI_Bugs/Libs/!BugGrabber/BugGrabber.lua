
local _G = _G
local type, table, next, tostring, tonumber, print = type, table, next, tostring, tonumber, print
local playerName = UnitNameUnmodified("player")

-----------------------------------------------------------------------
-- Check if we already exist in the global space
-- If we do - bail out early, there's no version checks.
if _G.BugGrabber then return end

-- Disable outdated/conflicting addons
C_AddOns.DisableAddOn("!Swatter")
C_AddOns.DisableAddOn("!ImprovedErrorFrame")

-----------------------------------------------------------------------
-- If we're embedded we create a .BugGrabber object on the addons
-- table, unless we find a standalone !BugGrabber addon.

local bugGrabberParentAddon, parentAddonTable = ...
local STANDALONE_NAME = "!BugGrabber"
if bugGrabberParentAddon ~= STANDALONE_NAME then
	local enabled = C_AddOns.GetAddOnEnableState(STANDALONE_NAME, playerName)
	if enabled == 2 then return end -- Bail out
end
if not parentAddonTable.BugGrabber then parentAddonTable.BugGrabber = {} end
local addon = parentAddonTable.BugGrabber

local real_seterrorhandler = seterrorhandler

-----------------------------------------------------------------------
-- Global config variables
--

MAX_BUGGRABBER_ERRORS = 500

-- If we get more errors than this per second, we stop all capturing
BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE = 10

-----------------------------------------------------------------------
-- Localization
--

local L = {
	ADDON_CALL_PROTECTED = "[%s] AddOn '%s' tried to call the protected function '%s'.",
	BUGGRABBER_STOPPED = "|cffffff00There are too many errors in your UI. As a result, your game experience may be degraded. Disable or update the failing addons if you don't want to see this message again.|r",
	ERROR_DETECTED = "%s |cffffff00captured, click the link for more information.|r",
	ERROR_UNABLE = "|cffffff00!BugGrabber is unable to retrieve errors from other players by itself. Please install BugSack or a similar display addon that might give you this functionality.|r",
	NO_DISPLAY_1 = "|cffffff00You seem to be running !BugGrabber with no display addon to go along with it. Although a slash command is provided for accessing error reports, a display can help you manage these errors in a more convenient way.|r",
	NO_DISPLAY_2 = "|cffffff00The standard display is called BugSack, and can probably be found on the same site where you found !BugGrabber.|r",
	NO_DISPLAY_STOP = "|cffffff00If you don't want to be reminded about this again, run /stopnag.|r",
	STOP_NAG = "|cffffff00!BugGrabber will not nag about missing a display addon again until next patch.|r",
	USAGE = "|cffffff00Usage: /buggrabber <1-%d>.|r",
}

do
	local locale = GetLocale()
	if locale == "koKR" then
		L.ADDON_CALL_PROTECTED = "[%s] 애드온 '%s'|1이;가; 보호된 함수 '%s' 호출을 시도했습니다."
		L.BUGGRABBER_STOPPED = "|cffffff00UI에 오류가 너무 많습니다. 결과적으로 게임 경험이 저하될 수 있습니다. 이 메시지를 다시 보지 않으려면 오류가 있는 애드온을 사용 중지하거나 업데이트하세요.|r"
		L.ERROR_DETECTED = "%s |cffffff00수집됨, 자세한 정보는 링크를 클릭하세요.|r"
		L.ERROR_UNABLE = "|cffffff00!BugGrabber는 혼자서 다른 플레이어의 오류를 검색할 수 없습니다. 이 기능을 제공할 수 있는 BugSack이나 비슷한 디스플레이 애드온을 설치해주세요.|r"
		L.NO_DISPLAY_1 = "|cffffff00당신은 !BugGrabber를 표시 애드온 없이 실행한 것 같습니다. !BugGrabber는 게임 오류 확인을 위한 슬래시 명령어를 제공하고 있지만, 표시 애드온은 당신이 더 편리한 방법으로 이러한 오류를 관리할 수 있게 도와줍니다.|r"
		L.NO_DISPLAY_2 = "|cffffff00표준 디스플레이는 BugSack이라고 하며, 아마도 !BugGrabber를 구한 동일 사이트에서 찾을 수 있습니다.|r"
		L.NO_DISPLAY_STOP = "|cffffff00만약 이에 대해 다시 알림받고 싶지 않다면, /stopnag를 실행하세요.|r"
		L.STOP_NAG = "|cffffff00다음 패치때까지 !BugGrabber는 표시 애드온이 없는 것에 대해 성가시게 하지 않습니다.|r"
		L.USAGE = "|cffffff00사용법: /buggrabber <1-%d>.|r"
	elseif locale == "deDE" then
		L.ADDON_CALL_PROTECTED = "[%s] AddOn '%s' hat versucht die geschützte Funktion '%s' aufzurufen."
		L.BUGGRABBER_STOPPED = "|cffffff00In deinem UI treten zu viele Fehler auf, als Folge davon könnte dein Spiel langsamer laufen. Deaktiviere oder aktualisiere die fehlerhaften Addons, wenn du diese Meldung nicht mehr sehen willst.|r"
		L.ERROR_DETECTED = "%s |cffffff00gefangen, klicke auf den Link für mehr Informationen.|r"
		L.ERROR_UNABLE = "|cffffff00!BugGrabber kann selbst keine Fehler von anderen Spielern anzeigen. Bitte installiere BugSack oder ein vergleichbares Display-Addon, das dir diese Funktionalität bietet.|r"
		L.NO_DISPLAY_1 = "|cffffff00Anscheinend benutzt du !BugGrabber ohne dazugehörigem Display-Addon. Zwar bietet !BugGrabber Slash-Befehle, um auf die Fehler zuzugreifen, mit einem Display-Addon wäre die Fehlerverwaltung aber bequemer.|r"
		L.NO_DISPLAY_2 = "|cffffff00Die Standardanzeige heißt BugSack und kann vermutlich auf der Seite gefunden werden, wo du auch !BugGrabber gefunden hast.|r"
		L.NO_DISPLAY_STOP = "|cffffff00Wenn du diesen Hinweis nicht mehr sehen willst, gib /stopnag ein.|r"
		L.STOP_NAG = "|cffffff00!BugGrabber wird bis zum nächsten Patch nicht mehr auf ein fehlendes Display-Addon hinweisen.|r"
		L.USAGE = "|cffffff00Benutzung: /buggrabber <1-%d>.|r"
	elseif locale == "esES" then
		L.ADDON_CALL_PROTECTED = "[%s] El addon '%s' ha intentado llamar a la función protegida '%s'."
		L.BUGGRABBER_STOPPED = "|cffffff00¡Hay demasiados errores en la interfaz! Esto puede afectar negativamente el rendimiento del juego. Desactivar o actualizar los addons que están causando los errores si no deseas ver este mensaje nunca más.|r"
		L.ERROR_DETECTED = "%s |cffffff00capturado. Haz clic en el vínculo para más información.|r"
		L.ERROR_UNABLE = "|cffffff00!BugGrabber no puede recibir errores de otro jugadores por sí mismo. Instalar BugSack o un addon similar que proporciona esta función.|r"
		L.NO_DISPLAY_1 = "|cffff441Parece que estás usando !BugGrabber sin un addon de visualización para acompañarlo. Aunque !BugGrabber proporciona un comando para ver a los errores, un addon de visualización puede proporciona una interfaz más convenientemente.|r"
		L.NO_DISPLAY_2 = "|cffff4411El addon estándar de visualización para !BugGrabber es |r|cff44ff44BugSack|r|cff4411. Puedes descargarlo desde el mismo lugar donde descargó BugSack.|r"
		L.NO_DISPLAY_STOP = "|cff4411Si no quieres ver este mensaje nunca más, ejecute el comando |r|cff44ff44/stopnag|r|cffff4411.|r"
		L.STOP_NAG = "|cffff4411BugGrabber no te recordará sobre el desaparecido |r|cff44ff44BugSack|r|cffff4411 nunca más, hasta el próximo parche.|r"
		L.USAGE = "|cffffff00Uso: /buggrabber <1-%d>|r"
	elseif locale == "zhTW" then
		L.ADDON_CALL_PROTECTED = "[%s] 插件 '%s' 嘗試調用保護功能 '%s'。"
		L.BUGGRABBER_STOPPED = "|cffffff00你的UI有太多的錯誤。這可能導致糟糕的遊戲體驗。禁用或是更新錯誤的插件如果你不想看到再次看到這個訊息。|r"
		L.ERROR_DETECTED = "%s |cffffff00已捕捉，點擊連結以獲得更多訊息。|r"
		L.ERROR_UNABLE = "|cffffff00!BugGrabber 本身無法檢索其他玩家的錯誤。請安裝 BugSack 或類似的錯誤顯示插件，可能會包含這些功能。|r"
		L.NO_DISPLAY_1 = "|cffffff00你似乎沒有與 !BugGrabber 一起運行的錯誤顯示插件。雖然斜線命令訪問錯誤報告，但錯誤顯示插件可以以更快捷的方式幫助您管理這些錯誤。|r"
		L.NO_DISPLAY_2 = "|cffffff00標準的錯誤顯示插件名叫 BugSack，可以在找到 !BugGrabber 的網站上找到它。|r"
		L.NO_DISPLAY_STOP = "|cffffff00如果你不希望再次被提醒，請輸入 /stopnag。|r"
		L.STOP_NAG = "|cffffff00!BugGrabber將不再提示缺失錯誤顯示插件資訊直到下個版本發佈。|r"
		L.USAGE = "|cffffff00用法：/buggrabber <1-%d>。|r"
	elseif locale == "zhCN" then
		L.ADDON_CALL_PROTECTED = "[%s] 插件 '%s' 尝试调用保护功能 '%s'。"
		L.BUGGRABBER_STOPPED = "|cffffff00用户界面有太多的错误。所以，游戏体验会被降低。如不想再看到此信息请禁用或升级失效插件。|r"
		L.ERROR_DETECTED = "%s |cffffff00已抓取，点击链接获取更多信息。|r"
		L.ERROR_UNABLE = "|cffffff00!BugGrabber 本身无法检索其他玩家的错误。请安装 BugSack 或类似的错误显示插件，可能会包含这些功能。|r"
		L.NO_DISPLAY_1 = "|cffffff00似乎没有与 !BugGrabber 一起运行的错误显示插件。虽然斜线命令访问错误报告，但错误显示插件可以以更快捷的方式帮助您管理这些错误。|r"
		L.NO_DISPLAY_2 = "|cffffff00标准的错误显示插件名叫 BugSack，可以在找到 !BugGrabber 的网站上找到它。|r"
		L.NO_DISPLAY_STOP = "|cffffff00如果你不希望再次被提醒，请输入 /stopnag。|r"
		L.STOP_NAG = "|cffffff00!BugGrabber 将不再提示缺失错误显示插件信息知道下个版本发布。|r"
		L.USAGE = "|cffffff00用法：/buggrabber <1-%d>。|r"
	elseif locale == "ruRU" then
		L.ADDON_CALL_PROTECTED = "[%s] Модификация '%s' пыталась вызвать защищенную функцию '%s'."
		L.BUGGRABBER_STOPPED = "|cffffff00Слишком много ошибок в вашем UI (пользовательском интерфейсе). В результате этого может снизиться играбельность. Отключите или обновите модификации, вызывающие сбои, если больше не хотите видеть это сообщение.|r"
		L.ERROR_DETECTED = "%s |cffffff00перехвачен, нажмите на ссылку для получения дополнительной информации.|r"
		L.ERROR_UNABLE = "|cffffff00!BugGrabber не может самостоятельно получить ошибки от других игроков. Пожалуйста, установите BugSack или аналогичные модификации, которые могли бы дать вам эту функциональность.|r"
		L.NO_DISPLAY_1 = "|cffffff00Кажется, !BugGrabber запущен без модификации для отображения информации. Хотя !BugGrabber предоставляет слеш-команды для доступа к внутриигровым ошибкам, модификация, выводящая информацию на экран, может показать их в более удобной форме.|r"
		L.NO_DISPLAY_2 = "|cffffff00Стандартная модификация для вывода информации называется BugSack, и может быть найдена там же, где вы нашли !BugGrabber.|r"
		L.NO_DISPLAY_STOP = "|cffffff00Если вам не нравятся напоминания об этом, наберите /stopnag.|r"
		L.STOP_NAG = "|cffffff00!BugGrabber не будет напоминать об отсутствующей модификации, выводящей информацию, до следующего патча.|r"
		L.USAGE = "|cffffff00Использование: /buggrabber <1-%d>.|r"
	elseif locale == "frFR" then
		L.ADDON_CALL_PROTECTED = "[%s] L’AddOn '%s' a tenté d’appeler la fonction protégée '%s'."
		L.BUGGRABBER_STOPPED = "|cffffff00Il y a trop d’erreurs dans votre interface utilisateur. En conséquence, votre expérience de jeu pourrait être dégradée. Désactivez ou mettez à jour les AddOns défaillants si vous ne souhaitez plus voir ce message.|r"
		L.ERROR_DETECTED = "%s |cffffff00capturé, cliquez sur le lien pour plus d’informations.|r"
		L.ERROR_UNABLE = "|cffffff00!BugGrabber ne peut pas récupérer les erreurs des autres joueurs par lui-même. Veuillez installer BugSack ou un autre AddOn d’affichage offrant cette fonctionnalité.|r"
		L.NO_DISPLAY_1 = "|cffffff00Il semble que vous utilisiez !BugGrabber sans AddOn d’affichage associé. Bien qu’une commande slash soit disponible pour consulter les erreurs, un affichage dédié vous permet de les gérer plus facilement.|r"
		L.NO_DISPLAY_2 = "|cffffff00L’affichage standard s’appelle BugSack et peut probablement être trouvé sur le même site que celui où vous avez téléchargé !BugGrabber.|r"
		L.NO_DISPLAY_STOP = "|cffffff00Si vous ne souhaitez plus recevoir ce rappel, utilisez la commande /stopnag.|r"
		L.STOP_NAG = "|cffffff00!BugGrabber ne vous rappellera plus l’absence d’un AddOn d’affichage jusqu’au prochain patch.|r"
		L.USAGE = "|cffffff00Utilisation : /buggrabber <1-%d>.|r"
	elseif locale == "esMX" then
		L.ADDON_CALL_PROTECTED = "[%s] El addon '%s' ha intentado llamar a la función protegida '%s'."
		L.BUGGRABBER_STOPPED = "|cffffff00¡Hay demasiados errores en la interfaz! Esto puede afectar negativamente el rendimiento del juego. Desactivar o actualizar los addons que están causando los errores si no deseas ver este mensaje nunca más.|r"
		L.ERROR_DETECTED = "%s |cffffff00capturado. Haz clic en el vínculo para más información.|r"
		L.ERROR_UNABLE = "|cffffff00!BugGrabber no puede recibir errores de otro jugadores por sí mismo. Instalar BugSack o un addon similar que proporciona esta función.|r"
		L.NO_DISPLAY_1 = "|cffffff00Parece que estás usando !BugGrabber sin un addon de visualización para acompañarlo. Aunque !BugGrabber proporciona un comando para ver a los errores, un addon de visualización puede proporciona una interfaz más convenientemente.|r"
		L.NO_DISPLAY_2 = "|cffffff00El addon estándar de visualización para !BugGrabber es |r|cff44ff44BugSack|r|cff4411. Puedes descargarlo desde el mismo lugar donde descargó BugSack.|r"
		L.NO_DISPLAY_STOP = "|cffffff00Si no quieres ver este mensaje nunca más, ejecute el comando |r|cff44ff44/stopnag|r|cffff4411.|r"
		L.STOP_NAG = "|cffffff00!BugGrabber no te recordará sobre el desaparecido |r|cff44ff44BugSack|r|cffff4411 nunca más, hasta el próximo parche.|r"
		L.USAGE = "|cffffff00Uso: /buggrabber <1-%d>|r"
	elseif locale == "ptBR" then
		L.ADDON_CALL_PROTECTED = "[%s] O Addon '%s' tentou chamar a função protegida '%s'."
		L.BUGGRABBER_STOPPED = "|cffffff00Existem muitos erros na sua interface. Como resultado, a experiência com o jogo pode ser desagradável. Desative ou atualize os Addons com falhas, se você não quiser ver essa mensagem novamente.|r"
		L.ERROR_DETECTED = "%s |cffffff00capturado, clique no link para mais informações.|r "
		L.ERROR_UNABLE = "|cffffff00!BugGrabber, por si só, é incapaz de receber erro de outros jogadores. Por favor. instale o BugSack ou outro programa que oferece esta funcionalidade.|r"
		L.NO_DISPLAY_1 = "|cffffff00Parece que você está usando o !BugGrabber sem nenhum addon para visualização. Embora o haja um comando interno para acessar os relatórios de erros, um complemento possa ser necessário para gerenciar esses erros de forma mais conveniente.|r"
		L.NO_DISPLAY_2 = "|cffffff00A ferramenta de exibição padrão é chamada BugSack, e provavelmente, você encontrará no mesmo site que você encontrou o !BugGrabber.|r"
		L.NO_DISPLAY_STOP = "|cffffff00Se você não quiser ser lembrado disto novamente, utilize o comando /stopnag.|r"
		L.STOP_NAG = "|cffffff00!BugGrabber não comentará sobre a ausência de uma ferramenta de exibição até a próxima versão.|r"
		L.USAGE = "|cffffff00Uso: /buggrabber <1-%d>.|r"
	elseif locale == "itIT" then
		L.ADDON_CALL_PROTECTED = "[%s] AddOn '%s' ha cercato di chiamare la funzione protetta '%s'."
		L.BUGGRABBER_STOPPED = "|cffffff00Ci sono troppi errori nella tua UI. Di conseguenza, la tua esperienza di gioco potrebbe essere non completamente appagante. Disabilita o aggiorna l'addon che genera così tanti avvisi se non vuoi più vedere questo messaggio.|r"
		L.ERROR_DETECTED = "%s |cffffff00catturato, clicca sul link per maggiori informazioni.|r"
		L.ERROR_UNABLE = "|cffffff00!BugGrabber non è capace di rivelare errori dovuti ad altri giocatori. Per favore, installa BugSack o un'addon equivalente per poter visualizzare anche questo tipo di errori.|r"
		L.NO_DISPLAY_1 = "lcffff4411Sembra che tu stia eseguendo !BugGrabber senza alcun addon che ne visualizzi gli errori. Anche se !BugGrabber ha un comando per visualizzarli nella chat, un addon aggiuntivo per visualizzarli potrebbe esserti utile.|r"
		L.NO_DISPLAY_2 = "|cffffff00L'addon standard per la visualizzazione degli errori catturati da !BugGrabber si chiama BugSack, e molto probabilmente lo puoi trovare sullo stesso sito dove hai trovato !BugGrabber.|r"
		L.NO_DISPLAY_STOP = "|cffffff00Se non vuoi visualizzare più questo messaggio, esegui il comando /stopnag.|r"
		L.STOP_NAG = "|cffffff00!BugGrabber non ti ricorderà più di installare BugSack fino al prossimo aggiornamento.|r"
		L.USAGE = "|cffffff00Uso: /buggrabber <1-%d>.|r"
	end
end

-----------------------------------------------------------------------
-- Locals
--

-- Should implement :FormatError(errorTable).
local displayObjectName = nil
for i = 1, C_AddOns.GetNumAddOns() do
	local meta = C_AddOns.GetAddOnMetadata(i, "X-BugGrabber-Display")
	if meta then
		local enabled = C_AddOns.GetAddOnEnableState(i, playerName)
		if enabled == 2 then
			displayObjectName = meta
			break
		end
	end
end

-- Shorthand to BugGrabberDB.errors
local db = nil

-- Errors we catch during the addon loading process, before our saved
-- variables are available. After the SVs have loaded, these will be
-- inserted into the proper DB.
local loadErrors = {}

local paused = nil
local isDisplayRegistered = nil

-----------------------------------------------------------------------
-- Callbacks
--

do
	local tbl = {}
	local function callback()
		isDisplayRegistered = true
	end
	EventRegistry:RegisterCallback("BugGrabber.DisplayRegistered", callback, tbl)
end

-----------------------------------------------------------------------
-- Utility
--

local function fetchFromDatabase(database, target)
	for i = #database, 1, -1 do
		local err = database[i]
		if err.message == target then
			-- This error already exists
			return err, i
		end
	end
end

local function printErrorObject(err)
	local found = nil
	if displayObjectName and _G[displayObjectName] then
		local display = _G[displayObjectName]
		if type(display) == "table" and type(display.FormatError) == "function" then
			found = true
			print(display:FormatError(err))
		end
	end
	if not found then
		print(err.message)
		if err.stack then
			print(err.stack)
		end
		if err.locals then
			print(err.locals)
		end
	end
end

local function StoreError(errorObject)
	if db then
		local newCount = #db + 1
		db[newCount] = errorObject
		-- Save only the last MAX_BUGGRABBER_ERRORS errors (otherwise the SV gets too big)
		if newCount > MAX_BUGGRABBER_ERRORS then
			table.remove(db, 1)
		end
	else
		loadErrors[#loadErrors + 1] = errorObject
	end
end

-----------------------------------------------------------------------
-- Slash handler
--

local function slashHandler(index)
	if not db then return end
	index = tonumber(index)
	local err = type(index) == "number" and db[index] or nil
	if not index or not err or type(err) ~= "table" or (type(err.message) ~= "string" and type(err.message) ~= "table") then
		print(L.USAGE:format(#db))
		return
	end
	printErrorObject(err)
end

-----------------------------------------------------------------------
-- Error Handler
--

local grabError
do
	local GetErrorStack
	do
		local GetCallstackHeight, GetErrorCallstackHeight, debugstack = GetCallstackHeight, GetErrorCallstackHeight, debugstack
		function GetErrorStack() -- This code is lifted from Blizzard's error handler, and adapted to compensate for GetErrorCallstackHeight sometimes being nil
			local currentStackHeight = GetCallstackHeight()
			local errorCallStackHeight = GetErrorCallstackHeight()
			if errorCallStackHeight then
				local errorStackOffset = errorCallStackHeight - 1
				local debugStackLevel = currentStackHeight - errorStackOffset

				local stack = debugstack(debugStackLevel)
				return stack, debugStackLevel
			else
				local stack = debugstack(3)
				return stack, 3
			end
		end
	end
	local GetErrorLocals
	do
		local debuglocals = debuglocals
		function GetErrorLocals(level)
			local locals = debuglocals(level)
			return locals
		end
	end

	local msgsAllowed = BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE
	local GetTime, time = GetTime, time
	local msgsAllowedLastTime = GetTime()
	local lastWarningTime = 0
	local issecretvalue = issecretvalue or function() return false end
	function grabError(errorMessage, isSimple)
		-- Flood protection --
		msgsAllowed = msgsAllowed + (GetTime()-msgsAllowedLastTime)*BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE
		msgsAllowedLastTime = GetTime()
		if msgsAllowed < 1 then
			if not paused then
				if bugGrabberParentAddon == STANDALONE_NAME then
					if GetTime() > lastWarningTime + 10 then
						print(L.BUGGRABBER_STOPPED)
						lastWarningTime = GetTime()
					end
				end
				paused=true
			end
			return
		end
		paused=false
		if msgsAllowed > BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE then
			msgsAllowed = BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE
		end
		msgsAllowed = msgsAllowed - 1
		errorMessage = tostring(errorMessage)

		if issecretvalue(errorMessage) or (not isSimple and errorMessage:find("BugGrabber", nil, true)) then
			print("|cffffff00BugGrabber|r:", errorMessage)
			return
		end

		-- Insert the error into the correct database if it's not there
		-- already. If it is, just increment the counter.
		local errorObject, positionInDatabase
		if db then
			errorObject, positionInDatabase = fetchFromDatabase(db, errorMessage)
		else
			errorObject, positionInDatabase = fetchFromDatabase(loadErrors, errorMessage)
		end

		if not errorObject then -- New error
			-- Store the error
			if isSimple then
				errorObject = {
					message = errorMessage,
					session = addon:GetSessionId(),
					time = time(),
					counter = 1,
				}
				StoreError(errorObject)
			else
				errorObject = {
					message = errorMessage,
					session = addon:GetSessionId(),
					time = time(),
					counter = 1,
				}
				StoreError(errorObject) -- Always store the error before checking stack/locals incase something goes wrong whilst calling them
				local stack, level = GetErrorStack()
				errorObject.stack = stack or "Debugstack was nil."
				local locals = GetErrorLocals(level)
				errorObject.locals = locals or "Debuglocals was nil."
			end
		else -- Old error
			errorObject.counter = errorObject.counter + 1
			local session = addon:GetSessionId()
			if errorObject.session ~= session then -- Error from a different session, update it
				-- Do not re-arrange this error in the DB unless it's from an older session
				table.remove(db or loadErrors, positionInDatabase)
				StoreError(errorObject)
				errorObject.time = time()

				errorObject.session = session
				if not isSimple then
					local stack, level = GetErrorStack()
					errorObject.stack = stack or "Debugstack was nil."
					local locals = GetErrorLocals(level)
					errorObject.locals = locals or "Debuglocals was nil."
				end
			else
				local curTime = time()
				local errorTime = errorObject.time
				errorObject.time = curTime
				-- Do not re-arrange this error in the DB unless 10 seconds have elapsed since the last time the error occured (timer will reset if the error is spamming)
				if curTime - errorTime > 10 then
					table.remove(db or loadErrors, positionInDatabase)
					StoreError(errorObject)
				end

				if not isSimple and curTime - errorTime > 120 then -- More than 2 minutes, update the stack again
					local stack, level = GetErrorStack()
					errorObject.stack = stack or "Debugstack was nil."
					local locals = GetErrorLocals(level)
					errorObject.locals = locals or "Debuglocals was nil."
				end
			end
		end

		if not isDisplayRegistered then
			print(L.ERROR_DETECTED:format(addon:GetChatLink(errorObject)))
		end

		local tableID = tostring(errorObject)
		EventRegistry:TriggerEvent("BugGrabber.BugGrabbed", tableID)
	end
end

-----------------------------------------------------------------------
-- API
--

function addon:StoreError(errorObject) -- XXX remove me eventually
	StoreError(errorObject)
end

do
	EventRegistry:RegisterCallback("SetItemRef", function(_, link)
		local player, tableId = link:match("^addon:buggrabber:([^:]+):(table: [^:]+):")
		if player and tableId then
			addon:HandleBugLink(player, tableId)
		end
	end)

	local chatLinkFormat = "|Haddon:buggrabber:%s:%s:|h|cffff0000[Error %s]|r|h"
	function addon:GetChatLink(errorObject)
		local tableId = tostring(errorObject)
		local tableIdTrimmed = tableId:sub(8) -- Trim away "table: "
		return chatLinkFormat:format(playerName, tableId, tableIdTrimmed)
	end
end

function addon:GetErrorByPlayerAndID(player, tableId)
	if player == playerName then return addon:GetErrorByID(tableId) end
	print(L.ERROR_UNABLE)
end

function addon:GetErrorByID(tableID)
	for i = #db, 1, -1 do
		local err = db[i]
		if tostring(err) == tableID then
			return err
		end
	end
end

function addon:Reset() if BugGrabberDB then db = {} BugGrabberDB.errors = db BugGrabberDB.session = 1 end end
function addon:GetDB() return db or loadErrors end
function addon:GetSessionId() return BugGrabberDB and BugGrabberDB.session or -1 end
function addon:IsPaused() return paused end

function addon:HandleBugLink(player, tableId)
	local errorObject = addon:GetErrorByPlayerAndID(player, tableId)
	if errorObject then
		printErrorObject(errorObject)
	end
end

-----------------------------------------------------------------------
-- Initialization
--

do
	-- Persist defaults and make sure we have sane SavedVariables
	if type(BugGrabberDB) ~= "table" then BugGrabberDB = {} end
	local sv = BugGrabberDB
	if type(sv.session) ~= "number" then sv.session = 0 end
	if type(sv.errors) ~= "table" then sv.errors = {} end

	-- From now on we can persist errors. Create a new session.
	sv.session = sv.session + 1

	-- Determine the correct database
	db = BugGrabberDB.errors -- db is a file-local variable
	-- Cut down on the nr of errors if it is over the MAX_BUGGRABBER_ERRORS
	while #db > MAX_BUGGRABBER_ERRORS do
		table.remove(db, 1)
	end

	-- If there were any load errors, we need to iterate them and
	-- insert the relevant ones into our SV DB.
	for _, err in next, loadErrors do
		err.session = sv.session -- Update the session ID directly
		local exists, positionInDatabase = fetchFromDatabase(db, err.message)
		if exists then
			table.remove(db, positionInDatabase)
			StoreError(exists)
		else
			StoreError(err)
		end
	end
	loadErrors = nil

	if type(sv.lastSanitation) ~= "number" or sv.lastSanitation ~= 3 then
		for i, v in next, db do
			if type(v.message) == "table" then table.remove(db, i) end
		end
		sv.lastSanitation = 3
	end

	-- Only warn about missing display if we're running standalone.
	if not displayObjectName and bugGrabberParentAddon == STANDALONE_NAME then
		local _, _, _, currentInterface = GetBuildInfo()
		if type(currentInterface) ~= "number" then currentInterface = 0 end
		if not sv.stopnag or sv.stopnag < currentInterface then
			print(L.NO_DISPLAY_1)
			print(L.NO_DISPLAY_2)
			print(L.NO_DISPLAY_STOP)
			_G.SlashCmdList.BugGrabberStopNag = function()
				print(L.STOP_NAG)
				sv.stopnag = currentInterface
			end
			_G.SLASH_BugGrabberStopNag1 = "/stopnag"
		end
	end
end

local events = {}
do
	local frame = CreateFrame("Frame")
	frame:SetScript("OnEvent", function(_, event, ...) events[event](events, event, ...) end)
	frame:RegisterEvent("ADDON_ACTION_BLOCKED")
	frame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	frame:RegisterEvent("LUA_WARNING")
	local function noop() end -- Prevent abusive addons
	frame.RegisterEvent = noop
	frame.UnregisterEvent = noop
	frame.SetScript = noop
end

do
	local badAddons = {}
	function events:ADDON_ACTION_FORBIDDEN(event, addonName, addonFunc)
		local name = addonName or "<name>"
		if not badAddons[name] then
			badAddons[name] = true
			grabError(L.ADDON_CALL_PROTECTED:format(event, name or "<name>", addonFunc or "<func>"))
		end
	end
	events.ADDON_ACTION_BLOCKED = events.ADDON_ACTION_FORBIDDEN
	UIParent:UnregisterEvent("ADDON_ACTION_FORBIDDEN")
	UIParent:UnregisterEvent("ADDON_ACTION_BLOCKED")
end

function events:LUA_WARNING(_, warningText)
	if not warningText then warningText = "" end
	warningText = "LUA_WARNING: " .. warningText
	grabError(warningText, true)
end
ScriptErrorsFrame:UnregisterEvent("LUA_WARNING")

real_seterrorhandler(grabError)
function seterrorhandler() end

-- Set up slash command
SlashCmdList.BugGrabber = slashHandler
SLASH_BugGrabber1 = "/buggrabber"
BugGrabber = setmetatable({}, { __index = addon, __newindex = function() end, __metatable = false })
