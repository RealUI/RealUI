local _, parentAddonTable = ...
local addon = parentAddonTable.BugGrabber
-- Bail out in case we didn't load up for some reason, which
-- happens for example when an embedded BugGrabber finds a
-- standalone !BugGrabber addon.
if not addon then return end

-- We don't need to bail out here if BugGrabber has been loaded from
-- some other embedding addon already, because :LoadTranslations is
-- only invoked on login. All we do is replace the method with a new
-- one that will never be invoked.

function addon:LoadTranslations(locale, L)
	if locale == "koKR" then
L["ADDON_CALL_PROTECTED"] = "[%s] 애드온 '%s' 보호된 함수 호출 '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (애드온 '.*' 보호된 함수 호출 '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff00!BugGrabber|r와 %s|1은;는; 함께 사용할 수 없습니다; %s|1은;는; 강제로 중지되었습니다. 만약 당신이 원하면, 접속을 종료한 후, !BugGrabber를 비활성하고 %s|1을;를; 활성화하세요.|r"
L["BUGGRABBER_STOPPED"] = "|cffffff00당신의 UI에 매우 많은 오류가 있습니다. 결과적으로, 당신의 게임 환경은 타락했습니다. 이 메시지를 다시 보지 않으려면 오류가 있는 애드온을 비활성하거나 업데이트하세요.|r"
L["ERROR_DETECTED"] = "%s |cffffff00수집됨, 자세한 정보는 링크를 클릭하세요.|r"
L["ERROR_UNABLE"] = "|cffffff00!BugGrabber는 다른 플레이어의 오류는 발견할 수 없습니다. 이런 기능을 지원하는 BugSack이나 비슷한 디스플레이 애드온을 설치해주세요.|r"
L["NO_DISPLAY_1"] = "|cffffff00당신은 !BugGrabber를 디스플레이 애드온 없이 실행한 것 같습니다. !BugGrabber는 게임 오류 확인을 위한 슬래시 명령어를 제공하고 있지만, 표시 애드온은 당신이 더 편리한 방법으로 이러한 오류를 관리할 수 있게 도와줍니다.|r"
L["NO_DISPLAY_2"] = "|cffffff00표준 디스플레이는 BugSack으로 불리며, 아마도 당신은 !BugGrabber를 발견한 동일 사이트에서 찾을 수 있습니다.|r"
L["NO_DISPLAY_STOP"] = "|cffffff00만약 당신이 이것에 대해 다시 떠올리고 싶지 않다면, /stopnag 를 실행하세요.|r"
L["STOP_NAG"] = "|cffffff00다음 패치때까지 !BugGrabber는 디스플레이 애드온이 없는 것에 대해 성가시게 하지 않습니다.|r"
L["USAGE"] = "|cffffff00사용법: /buggrabber <1-%d>.|r"

	elseif locale == "deDE" then
L["ADDON_CALL_PROTECTED"] = "[%s] AddOn '%s' hat versucht die geschützte Funktion '%s' aufzurufen."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (AddOn '.*' hat versucht die geschützte Funktion '.*' aufzurufen.)$"
L["ADDON_DISABLED"] = "|cffffff00!BugGrabber und %s können nicht zusammen laufen, %s wurde deshalb deaktiviert. Wenn du willst, kannst du ausloggen, !BugGrabber deaktivieren und %s wieder aktivieren.|r"
L["BUGGRABBER_STOPPED"] = "|cffffff00In deinem UI treten zu viele Fehler auf, als Folge davon könnte dein Spiel langsamer laufen. Deaktiviere oder aktualisiere die fehlerhaften Addons, wenn du diese Meldung nicht mehr sehen willst.|r"
L["ERROR_DETECTED"] = "%s |cffffff00gefangen, klicke auf den Link für mehr Informationen.|r"
L["ERROR_UNABLE"] = "|cffffff00!BugGrabber kann selbst keine Fehler von anderen Spielern anzeigen. Bitte installiere BugSack oder ein vergleichbares Display-Addon, das dir diese Funktionalität bietet.|r"
L["NO_DISPLAY_1"] = "|cffffff00Anscheinend benutzt du !BugGrabber ohne dazugehörigem Display-Addon. Zwar bietet !BugGrabber Slash-Befehle, um auf die Fehler zuzugreifen, mit einem Display-Addon wäre die Fehlerverwaltung aber bequemer.|r"
L["NO_DISPLAY_2"] = "|cffffff00Die Standardanzeige heißt BugSack und kann vermutlich auf der Seite gefunden werden, wo du auch !BugGrabber gefunden hast.|r"
L["NO_DISPLAY_STOP"] = "|cffffff00Wenn du diesen Hinweis nicht mehr sehen willst, gib /stopnag ein.|r"
L["STOP_NAG"] = "|cffffff00!BugGrabber wird bis zum nächsten Patch nicht mehr auf ein fehlendes Display-Addon hinweisen.|r"
L["USAGE"] = "|cffffff00Benutzung: /buggrabber <1-%d>.|r"

	elseif locale == "esES" then
L["ADDON_CALL_PROTECTED"] = "[%s] El addon '%s' ha intentado llamar a la función protegida '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (El accesorio '.*' ha intentado llamar a la función protegida '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r y |cffffff7f%s|r no pueden coexistir juntos. |cffffff7f%s|r ha sido desactivado por la fuerza. Si lo deseas, puedes salir del juego, desactivar |cffffff7fBugGrabber|r y reactivar |cffffff7f%s|r."
L["BUGGRABBER_STOPPED"] = "|cffffff00¡Hay demasiados errores en la interfaz! Esto puede afectar negativamente el rendimiento del juego. Desactivar o actualizar los addons que están causando los errores si no deseas ver este mensaje nunca más.|r"
L["ERROR_DETECTED"] = "%s |cffffff00capturado. Haz clic en el vínculo para más información.|r"
L["ERROR_UNABLE"] = "|cffffff00!BugGrabber no puede recibir errores de otro jugadores por sí mismo. Instalar BugSack o un addon similar que proporciona esta función.|r"
L["NO_DISPLAY_1"] = "|cffff441Parece que estás usando !BugGrabber sin un addon de visualización para acompañarlo. Aunque !BugGrabber proporciona un comando para ver a los errores, un addon de visualización puede proporciona una interfaz más convenientemente.|r"
L["NO_DISPLAY_2"] = "|cffff4411El addon estándar de visualización para !BugGrabber es |r|cff44ff44BugSack|r|cff4411. Puedes descargarlo desde el mismo lugar donde descargó BugSack.|r"
L["NO_DISPLAY_STOP"] = "|cff4411Si no quieres ver este mensaje nunca más, ejecute el comando |r|cff44ff44/stopnag|r|cffff4411.|r"
L["STOP_NAG"] = "|cffff4411BugGrabber no te recordará sobre el desaparecido |r|cff44ff44BugSack|r|cffff4411 nunca más, hasta el próximo parche.|r"
L["USAGE"] = "Uso: /buggrabber <1-%d>"

	elseif locale == "zhTW" then
L["ADDON_CALL_PROTECTED"] = "[%s] 插件 '%s' 嘗試調用保護功能 '%s'。"
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (插件 '.*' 嘗試調用保護功能 '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff00!BugGrabber和%s不能共存;%s已經被強制停用。如果你要使用它,你可能需要登出，然後禁用!BugGrabber，再啟用%s。|r"
L["BUGGRABBER_STOPPED"] = "|cffffff00你的UI有太多的錯誤。這可能導致糟糕的遊戲體驗。禁用或是更新錯誤的插件如果你不想看到再次看到這個訊息。|r"
L["ERROR_DETECTED"] = "%s |cffffff00已捕捉，點擊連結以獲得更多訊息。|r"
L["ERROR_UNABLE"] = "|cffffff00!BugGrabber 本身無法檢索其他玩家的錯誤。請安裝 BugSack 或類似的錯誤顯示插件，可能會包含這些功能。|r"
L["NO_DISPLAY_1"] = "|cffffff00你似乎沒有與 !BugGrabber 一起運行的錯誤顯示插件。雖然斜線命令訪問錯誤報告，但錯誤顯示插件可以以更快捷的方式幫助您管理這些錯誤。|r"
L["NO_DISPLAY_2"] = "|cffffff00標準的錯誤顯示插件名叫 BugSack，可以在找到 !BugGrabber 的網站上找到它。|r"
L["NO_DISPLAY_STOP"] = "|cffffff00如果你不希望再次被提醒，請輸入 /stopnag。|r"
L["STOP_NAG"] = "|cffffff00!BugGrabber將不再提示缺失錯誤顯示插件資訊直到下個版本發佈。|r"
L["USAGE"] = "用法：/buggrabber <1-%d>。"

	elseif locale == "zhCN" then
L["ADDON_CALL_PROTECTED"] = "[%s] 插件 '%s' 尝试调用保护功能 '%s'。"
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (插件 '.*' 尝试调用保护功能 '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff00!BugGrabber|r 和 %s 不能共存。%s 已被强制停用。如果愿意，可在登出游戏后，停用 !BugGrabber 并启用 %s|r。"
L["BUGGRABBER_STOPPED"] = "|cffffff00用户界面有太多的错误。所以，游戏体验会被降低。如不想再看到此信息请禁用或升级失效插件。|r"
L["ERROR_DETECTED"] = "%s |cffffff00已抓取，点击链接获取更多信息。|r"
L["ERROR_UNABLE"] = "|cffffff00!BugGrabber 本身无法检索其他玩家的错误。请安装 BugSack 或类似的错误显示插件，可能会包含这些功能。|r"
L["NO_DISPLAY_1"] = "|cffffff00似乎没有与 !BugGrabber 一起运行的错误显示插件。虽然斜线命令访问错误报告，但错误显示插件可以以更快捷的方式帮助您管理这些错误。|r"
L["NO_DISPLAY_2"] = "|cffffff00标准的错误显示插件名叫 BugSack，可以在找到 !BugGrabber 的网站上找到它。|r"
L["NO_DISPLAY_STOP"] = "|cffffff00如果你不希望再次被提醒，请输入 /stopnag。|r"
L["STOP_NAG"] = "|cffffff00!BugGrabber 将不再提示缺失错误显示插件信息知道下个版本发布。|r"
L["USAGE"] = "|cffffff00用法：/buggrabber <1-%d>。|r"

	elseif locale == "ruRU" then
L["ADDON_CALL_PROTECTED"] = "[%s] Аддон '%s' пытался вызвать защищенную функцию '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (Аддон '.*' пытался вызвать защищенную функцию '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r и |cffffff7f%s|r не могут работать вместе. Поэтому |cffffff7f%s|r был отключен. Если хотите, можете выйти из игрового мира,отключить |cffffff7fBugGrabber|r и включить |cffffff7f%s|r." -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r прекратил захватывать ошибки, так как захватил более %d ошибок  в секунду. Захват возобновится через %d секунд." -- Needs review
L["NO_DISPLAY_1"] = "|cffff4411Кажется, !BugGrabber запущен без поддержки аддона для отображения информации. Хотя !BugGrabber предоставляет слеш-команды для доступа к внутриигровым ошибкам, визуализирующий аддон может показать их в более удобной форме.|r" -- Needs review
L["NO_DISPLAY_2"] = "|cffff4411Стандартный аддон для отображения информации от !BugGrabber называется |r|cff44ff44BugSack|r|cffff4411, и может быть найден там же, где вы нашли !BugGrabber.|r" -- Needs review
L["NO_DISPLAY_STOP"] = "|cffff4411Если вам не нравятся напоминания об этом, наберите |cff44ff44/stopnag|r|cffff4411.|r" -- Needs review
L["STOP_NAG"] = "|cffff4411!BugGrabber больше не будет напоминать об отсутствующем |r|cff44ff44BugSack|r|cffff4411 до следующего патча.|r" -- Needs review
L["USAGE"] = "Использование: /buggrabber <1-%d>." -- Needs review

	elseif locale == "frFR" then
L["ADDON_CALL_PROTECTED"] = "[%s] L'AddOn '%s' a tenté d'appeler la fonction protégée '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (L'AddOn '.*' a tenté d'appeler la fonction protégée '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r et |cffffff7f%s|r ne peuvent pas être lancés en même temps. |cffffff7f%s|r a été désactivé. Si vous le souhaitez, vous pouvez vous déconnecter, désactiver |cffffff7fBugGrabber|r et réactiver |cffffff7f%s|r." -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r a cessé de capturer des erreurs, car plus de %d erreurs ont été capturées par seconde. La capture sera reprise dans %d secondes." -- Needs review
L["NO_DISPLAY_1"] = "|cffff4411Vous ne semblez pas utiliser !BugGrabber avec un add-on d'affichage. Bien que les erreurs enregistrées par !BugGrabber soient accessibles par ligne de commande, un add-on d'affichage peut vous aidez à gérer ces erreurs plus aisément.|r" -- Needs review
L["NO_DISPLAY_2"] = "|cffff4411L'add-on d'affichage originel s'appelle |r|cff44ff44BugSack|r|cffff4411, vous devriez pouvoir le trouver sur le même site que !BugGrabber.|r" -- Needs review
L["NO_DISPLAY_STOP"] = [=[|cffff4411Pour ne plus voir ce rappel, utiliser la commande |cff44ff44/stopnag|r|cffff4411.|r
]=] -- Needs review
L["STOP_NAG"] = "|cffff4411!BugGrabber ne vous rappellera plus l'existence de |r|cff44ff44BugSack|r|cffff4411 jusqu'à la prochaine mise à jour.|r" -- Needs review
L["USAGE"] = "Utilisation: /buggrabber <1-%d>." -- Needs review

	elseif locale == "esMX" then
L["ADDON_CALL_PROTECTED"] = "[%s] El addon '%s' ha intentado llamar a la función protegida '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (El accesorio '.*' ha intentado llamar a la función protegida '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r y |cffffff7f%s|r no pueden coexistir juntos. |cffffff7f%s|r ha sido desactivado por la fuerza. Si lo deseas, puedes salir del juego, desactivar |cffffff7fBugGrabber|r y reactivar |cffffff7f%s|r."
L["BUGGRABBER_STOPPED"] = "|cffffff00¡Hay demasiados errores en la interfaz! Esto puede afectar negativamente el rendimiento del juego. Desactivar o actualizar los addons que están causando los errores si no deseas ver este mensaje nunca más.|r"
L["ERROR_DETECTED"] = "%s |cffffff00capturado. Haz clic en el vínculo para más información.|r"
L["ERROR_UNABLE"] = "|cffffff00!BugGrabber no puede recibir errores de otro jugadores por sí mismo. Instalar BugSack o un addon similar que proporciona esta función.|r"
L["NO_DISPLAY_1"] = "|cffff441Parece que estás usando !BugGrabber sin un addon de visualización para acompañarlo. Aunque !BugGrabber proporciona un comando para ver a los errores, un addon de visualización puede proporciona una interfaz más convenientemente.|r"
L["NO_DISPLAY_2"] = "|cffff4411El addon estándar de visualización para !BugGrabber es |r|cff44ff44BugSack|r|cff4411. Puedes descargarlo desde el mismo lugar donde descargó BugSack.|r"
L["NO_DISPLAY_STOP"] = "|cff4411Si no quieres ver este mensaje nunca más, ejecute el comando |r|cff44ff44/stopnag|r|cffff4411.|r"
L["STOP_NAG"] = "|cffff4411BugGrabber no te recordará sobre el desaparecido |r|cff44ff44BugSack|r|cffff4411 nunca más, hasta el próximo parche.|r"
L["USAGE"] = "Uso: /buggrabber <1-%d>"

	elseif locale == "ptBR" then
L["ADDON_CALL_PROTECTED"] = "[%s] O AddOn '%s' tentou chamar a função protegida '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (AddOn '.*' tentou chamar a função protegida '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r e |cffffff7f%s|r não podem existir juntos. |cffffff7f%s|r foi desabilitado por causa disso. Se você quiser, você pode sair, desabilitar o |cffffff7fBugGrabber|r e habilitar o |cffffff7f%s|r." -- Needs review
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r parou de capturar erros, já que capturou mais de %d erros por segundo. A captura será resumida em %d segundos." -- Needs review
L["ERROR_DETECTED"] = "%s |cffffff00capturado, clique no link para mais informações.|r" -- Needs review
L["ERROR_UNABLE"] = "|cffffff00!BugGrabber não pode receber erros por outros jogadores por si só. Por favor, instale BugSack ou outro programa que oferece essa funcionalidade." -- Needs review
L["NO_DISPLAY_1"] = "|cffff4411Aparentemente você está usando !BugGrabber sem nenhum addon de exibição para acompanhá-lo. Apesar do !BugGrabber fornecer um comando para acessar os erros dentro do jogo, um addon de exibição pode ajudar você a gerenciar esses erros de uma forma mais conveniente.|r" -- Needs review
L["NO_DISPLAY_2"] = "|cffff4411O exibidor padrão do !BugGrabber é conhecido por |r|cff44ff44BugSack|r|cffff4411, e pode provavelmente ser encontrado no mesmo site onde você achou o !BugGrabber.|r" -- Needs review
L["NO_DISPLAY_STOP"] = "|cffff4411Se você não deseja ser lembrado disso novamente, por favor utilize o comando |cff44ff44/stopnag|r|cffff4411.|r" -- Needs review
L["STOP_NAG"] = "|cffff4411!BugGrabber não irá perturbar sobre não ter detectado o |r|cff44ff44BugSack|r|cffff4411 até a próxima atualização.|r" -- Needs review
L["USAGE"] = "Uso: /buggraber <1-%d>" -- Needs review

	elseif locale == "itIT" then
L["ADDON_CALL_PROTECTED"] = "[%s] AddOn '%s' ha cercato di chiamare la funzione protetta '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (AddOn '.*' ha cercato di chiamare la funzione protetta '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r e %s non possono essere contemporaneamente installati. %s è stato quindi disabilitato. Se vuoi, puoi uscire dal gioco, disabilitare !BugGrabber e riattivare %s."
L["BUGGRABBER_STOPPED"] = "|cffffff00Ci sono troppi errori nella tua UI. Di conseguenza, la tua esperienza di gioco potrebbe essere non completamente appagante. Disabilita o aggiorna l'addon che genera così tanti avvisi se non vuoi più vedere questo messaggio.|r"
L["ERROR_DETECTED"] = "%s |cffffff00catturato, clicca sul link per maggiori informazioni.|r"
L["ERROR_UNABLE"] = "|cffffff00!BugGrabber non è capace di rivelare errori dovuti ad altri giocatori. Per favore, installa BugSack o un'addon equivalente per poter visualizzare anche questo tipo di errori.|r"
L["NO_DISPLAY_1"] = "lcffff4411Sembra che tu stia eseguendo !BugGrabber senza alcun addon che ne visualizzi gli errori. Anche se !BugGrabber ha un comando per visualizzarli nella chat, un addon aggiuntivo per visualizzarli potrebbe esserti utile.|r"
L["NO_DISPLAY_2"] = "|cffffff00L'addon standard per la visualizzazione degli errori catturati da !BugGrabber si chiama BugSack, e molto probabilmente lo puoi trovare sullo stesso sito dove hai trovato !BugGrabber.|r"
L["NO_DISPLAY_STOP"] = "|cffffff00Se non vuoi visualizzare più questo messaggio, esegui il comando /stopnag.|r"
L["STOP_NAG"] = "|cffffff00!BugGrabber non ti ricorderà più di installare BugSack fino al prossimo aggiornamento.|r"
L["USAGE"] = "Uso: /buggrabber <1-%d>."

	end
end

