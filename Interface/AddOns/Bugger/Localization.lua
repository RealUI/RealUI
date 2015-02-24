--[[--------------------------------------------------------------------
	Bugger
	Shows the errors captured by !BugGrabber.
	Copyright (c) 2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info23144-Bugger.html
	http://www.curse.com/addons/wow/bugger
	https://github.com/Phanx/Bugger
----------------------------------------------------------------------]]

local BUGGER, Bugger = ...
local L = Bugger.L

-- Please use the CurseForge project page to add or update translations!
-- http://wow.curseforge.com/addons/bugger/localization/

if GetLocale() == "deDE" then -- contributors: Tumbleweed_DSA

	L["/bugger"] = "/fehler"
	L["All Errors"] = "Alle Fehler"
	L["All saved errors have been deleted."] = "Alle eingefangenen Fehler wurden gelöscht."
	L["Alt-click to clear all saved errors."] = "Alt-Klick, um alle eingefangenen Fehler zu löschen."
	L["An error has been captured!"] = "Ein Fehler wurde eingefangen!"
	L["Automatic"] = "Automatisch"
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger kann ohne !BugGrabber nicht funktionieren. !BugGrabber ist bei Curse oder WoWInterface zu finden."
	L["Chat frame alerts"] = "Warnmeldungen im Chatfenster"
	L["Click to open the error window."] = "Klick, um das Fehler-Fenster anzuzeigen."
	L["Click to show or hide the local variables captured with this error."] = "Klick, um die lokalen Variablen anzuzeigen, oder zu verbergen, die mit diesem Fehler eingefangen wurden."
	L["Current Session"] = "Aktuelle Sitzung"
	L["Errors"] = "Fehler"
	L["Locals"] = "Lokale"
	L["Minimap icon"] = "Minikartensymbol anzeigen"
	L["Previous Session"] = "Vorherige Sitzung"
	L["Right-click for options."] = "Rechtsklick für Optionen."
	L["Shift-click to reload the UI."] = "Shift-Klick, um die UI neu zu laden."
	L["Sound alerts"] = "Warnsounds abspielen"
	L["There are no errors to display."] = "Es gibt keine Fehler anzuzeigen."

elseif GetLocale():match("^es") then

	L["/bugger"] = "/errores"
	L["All Errors"] = "Todos errores"
	L["All saved errors have been deleted."] = "Todos los errores guardados se han borrados."
	L["Alt-click to clear all saved errors."] = "Alt-clic para borrar todos errores guardados."
	L["An error has been captured!"] = "Un error se ha capturado!"
	L["Automatic"] = "Automático"
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger no puede funcionar sin !BugGrabber. Encuentralo en Curse o WoWInterface."
	L["Chat frame alerts"] = "Mensajes de alerta en chat"
	L["Click to open the error window."] = "Clic para mostrar la ventana de errores."
	L["Click to show or hide the local variables captured with this error."] = "Clic para mostrar o ocultar las variables locales que fueron capturados con este error."
	L["Current Session"] = "Sesión actual"
	L["Errors"] = "Errores"
	L["Locals"] = "Locales"
	L["Minimap icon"] = "Icono en minimapa"
	L["Previous Session"] = "Sesión anterior"
	L["Right-click for options."] = "Clic derecho para opciones."
	L["Shift-click to reload the UI."] = "Mayús-clic para volver a cargar la IU."
	L["Sound alerts"] = "Sonidos de alerta"
	L["There are no errors to display."] = "No hay errores para mostrar."

elseif GetLocale() == "frFR" then

	L["/bugger"] = "/erreurs"
	L["All Errors"] = "Toutes erreures"
	L["All saved errors have been deleted."] = "Toutes les erreurs enregistrées ont été supprimées."
	L["Alt-click to clear all saved errors."] = "Alt-clic pour effacer toutes les erreurs."
	L["An error has been captured!"] = "Une erreur a été capturé!"
	L["Automatic"] = "Automatique"
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger ne peut pas fonctionner sans !BugGrabber. Trouvez-le sur Curse ou WoWInterface."
	L["Click to show or hide the local variables captured with this error."] = "Cliquez pour afficher ou masquer les variables locales capturées avec cette erreur."
	L["Chat frame alerts"] = "Messages d'alerte dans le discussion"
	L["Click to open the error window."] = "Cliquez pour ouvrir la fenêtre d'erreurs."
	L["Current Session"] = "Session en cours"
	L["Errors"] = "Erreurs"
	L["Locals"] = "Locales"
	L["Minimap icon"] = "Icône sur la minicarte"
	L["Previous Session"] = "Session précédente"
	L["Right-click for options."] = "Clic droit pour options."
	L["Shift-click to reload the UI."] = "Maj-clic pour recharger l'IU."
	L["Sound alerts"] = "Sons d'alerte"
	L["There are no errors to display."] = "Il n'y a pas d'erreur à afficher."

elseif GetLocale() == "itIT" then

	L["/bugger"] = "/errori"
	L["All Errors"] = "Tutti errori"
	L["All saved errors have been deleted."] = "Tutti gli errori salvati sono stati cancellari."
	L["Alt-click to clear all saved errors."] = "Alt-clic per cancellare tutti gli errori salvati."
	L["An error has been captured!"] = "Un errore è stato catturato!"
	L["Automatic"] = "Automatico"
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger non può funzionare senza !BugGrabber. Lo si può trovare su Curse o WoWInterface."
	L["Click to show or hide the local variables captured with this error."] = "Fare clic per visualizzare o nascondere le variabili locali catturate con questo errore."
	L["Chat frame alerts"] = "Messaggi di avviso nel chat"
	L["Click to open the error window."] = "Clicca per mostrare la finestra di errori."
	L["Current Session"] = "Sessione corrente"
	L["Errors"] = "Errori"
	L["Locals"] = "Locali"
	L["Minimap icon"] = "Icona sulla minimappa"
	L["Previous Session"] = "Sessione precedente"
	L["Right-click for options."] = "Clic destro per le opzioni."
	L["Shift-click to reload the UI."] = "Maiusc + clic per ricaricare l'interfaccia utente."
	L["Sound alerts"] = "Suoni di avviso"
	L["There are no errors to display."] = "Non ci sono errori da mostrare."

elseif GetLocale() == "ptBR" then

	L["/bugger"] = "/erros"
	L["All Errors"] = "Todos erros"
	L["All saved errors have been deleted."] = "Todos os erros guardados foram apogados."
	L["Alt-click to clear all saved errors."] = "Alt-clique para apagar todos os erros guardados."
	L["An error has been captured!"] = "Um erro foi capturado!"
	L["Automatic"] = "Automático"
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger não pode funcionar sem !BugGrabber. Procurar no Curse ou WoWInterface."
	L["Click to show or hide the local variables captured with this error."] = "Clique para mostrar ou ocultar as variáveis ​​locais capturadas com este erro."
	L["Chat frame alerts"] = "Mensagens de alerta no chat"
	L["Click to open the error window."] = "Clique para mostrar a janela de erros."
	L["Current Session"] = "Sessão atual"
	L["Errors"] = "Erros"
	L["Locals"] = "Locais"
	L["Minimap icon"] = "Ícone no minimapa"
	L["Previous Session"] = "Sessão anterior"
	L["Right-click for options."] = "Clique direito para opções."
	L["Shift-click to reload the UI."] = "Shift-clique para recarregar a IU."
	L["Sound alerts"] = "Sons de alerta"
	L["There are no errors to display."] = "Não há erros para mostrar."

elseif GetLocale() == "ruRU" then

	-- MISSING

elseif GetLocale() == "koKR" then

	-- MISSING

elseif GetLocale() == "zhCN" then -- contributors: q09q09

	L["/bugger"] = "/出错"
	L["All Errors"] = "所有出错"
	L["All saved errors have been deleted."] = "所有保存出错已经删除。"
	L["Alt-click to clear all saved errors."] = "按住Alt点击清除所有保存的出错。"
	L["An error has been captured!"] = "已捕做到一个出错！"
	L["Automatic"] = "自动"
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger基于!BugGrabber运作。请到Curse或WoWInterface搜寻它。"
	L["Chat frame alerts"] = "聊天框警报"
	L["Click to open the error window."] = "点击打开出错窗口。"
	L["Click to show or hide the local variables captured with this error."] = "点击显示或隐藏与此出错捕获的局部变量。"
	L["Current Session"] = "当前会话"
	L["Errors"] = "出错"
	L["Locals"] = "本地"
	L["Minimap icon"] = "迷你地图图标"
	L["Previous Session"] = "之前会话"
	L["Right-click for options."] = "右键单击选项。"
	L["Shift-click to reload the UI."] = "按住Shift键单击重新加载UI。"
	L["Sound alerts"] = "声音警报"
	L["There are no errors to display."] = "没有出错显示。"

elseif GetLocale() == "zhTW" then -- contributors: BNSSNB

	L["/bugger"] = "/錯誤"
	L["All Errors"] = "所有錯誤"
	L["All saved errors have been deleted."] = "所有儲存的錯誤已被刪除。"
	L["Alt-click to clear all saved errors."] = "Alt-點擊以清除所有儲存的錯誤。"
	L["An error has been captured!"] = "一個錯誤已被捕捉！"
	L["Automatic"] = "自動"
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger沒有!BugGrabber將無法運作。請在Curse或WoWInterface尋找它。"
	L["Click to show or hide the local variables captured with this error."] = "按一下以顯示或隱藏此錯誤捕捉的本地變數。"
	L["Chat frame alerts"] = "聊天框架警告"
	L["Click to open the error window."] = "點擊開啟錯誤視窗。"
	L["Current Session"] = "目前階段"
	L["Errors"] = "錯誤"
	L["Locals"] = "本地"
	L["Minimap icon"] = "小地圖圖標"
	L["Previous Session"] = "之前階段"
	L["Right-click for options."] = "右鍵點擊開啟選項。"
	L["Shift-click to reload the UI."] = "Shift-點擊重載UI。"
	L["Sound alerts"] = "聲音警告"
	L["There are no errors to display."] = "沒有錯誤可顯示。"

end