
-- GLOBALS: BADBOY_NOLINK, BADBOY_POPUP, InterfaceOptionsFrame_OpenToCategory, PlaySound, SLASH_BADBOY1

--[[ Slash Handler ]]--
SlashCmdList["BADBOY"] = function() InterfaceOptionsFrame_OpenToCategory("BadBoy") end
SLASH_BADBOY1 = "/badboy"

--[[ Localization ]]--
local locNoReportMsg = "Hide the 'spam blocked' message asking you to report"
local locNoReportDesc = "Please DON'T use this. Reporting the spam is what gets the hacked accounts used by the spammers closed down and realms cleaned up. Also, if many people report a spammer, then that spammer looses the ability to chat meaning they can no longer spam, this benefits everyone, especially non-BadBoy users."
local locManualReport = "Show a report player popup (showing the spam) instead of printing in chat"
do
	local L = GetLocale()
	if L == "frFR" then
		locNoReportMsg = "Cacher le message 'spam bloqué' vous demandant de signaler le spam"
		locNoReportDesc = "Veuillez ne PAS utiliser ceci. Le signalement du spam permet aux comptes piratés utilisés par les spammeurs d'être fermés et de nettoyer les royaumes. De plus, si beaucoup de joueurs signalent un spammeur, ce dernier perd la possibilité de discuter et donc de spammer, ce qui est bénéfique pour tous, en particulier pour ceux qui n'utilisent pas BadBoy."
		locManualReport = "Afficher un popup de signalement du joueur au lieu de l'indiquer dans la fenêtre de chat"
	elseif L == "deDE" then
		locNoReportMsg = "Verstecke die 'Spam geblockt' Meldung, die dich bittet, den Spam zu melden"
		locNoReportDesc = "Bitte NICHT nutzen. Spam zu melden hilft die Anzahl der gehackten Accounts, die Spammer nutzen, zu reduzieren und säubert die Server. Wenn viele Leute einen Spammer melden, verlieren diese die Möglichkeit den Chat zu nutzen. Davon profitieren alle, vor allem Leute die BadBoy nicht nutzen."
		locManualReport = "Zeige ein PopUp (zeigt den Spam) anstatt es im Chatfenster anzuzeigen"
	elseif L == "zhTW" then
		locNoReportMsg = "隱藏要你舉報的 '垃圾阻擋' 訊息"
		locNoReportDesc = "請不要使用此。報告的垃圾郵件是什麼讓黑客攻擊的垃圾郵件發送者使用的帳戶關閉和領域的清理。此外，如果很多人報告垃圾郵件發送者，然後，垃圾郵件發送者失去的能力，這意味著他們可以不再垃圾郵件這樣的好處大家，特別是非BADBOY用戶聊天。"
		locManualReport = "顯示彈出的玩家舉報(顯示垃圾訊息)而不是發佈在聊天中"
	elseif L == "zhCN" then
		locNoReportMsg = "隐藏你要举报的“阻挡的垃圾信息”"
		locNoReportDesc = "请不要使用此。报告的垃圾邮件是什么让黑客攻击的垃圾邮件发送者使用的帐户关闭和领域的清理。此外，如果很多人报告垃圾邮件发送者，然后，垃圾邮件发送者失去的能力，这意味着他们可以不再垃圾邮件，这样的好处大家，特别是非BADBOY用户聊天。"
		locManualReport = "显示弹出的玩家举报（显示垃圾信息）而不是显示在聊天中"
	elseif L == "esES" then
		locNoReportMsg = "Ocultar los mensajes 'spam bloqueado' que te piden informar"
		locNoReportDesc = "Por favor, no use esta! Informes de spam son cómo las malas cuentas se bloquean, y los reinos se limpian. Además, si muchas personas informan el spam, el remitente del spam es bloqueado el uso del chat, y no puede enviar más spam. Esto beneficia a todos, especialmente los jugadores sin BadBoy."
		locManualReport = "Mostrar popup de informar (mostrando el spam) en lugar de mensaje en chat"
	elseif L == "esMX" then
		locNoReportMsg = "Ocultar los mensajes 'spam bloqueado' que te piden informar"
		locNoReportDesc = "Por favor, no use esta! Informes de spam son cómo las malas cuentas se bloquean, y los reinos se limpian. Además, si muchas personas informan el spam, el remitente del spam es bloqueado el uso del chat, y no puede enviar más spam. Esto beneficia a todos, especialmente los jugadores sin BadBoy."
		locManualReport = "Mostrar popup de informar (mostrando el spam) en lugar de mensaje en chat"
	elseif L == "ruRU" then
		locNoReportMsg = "Прятать сообщение 'Cпам блокирован', спрашивающее вас о жалобе на игрока."
		locNoReportDesc = "Пожалуйста, не используйте эту функцию. Донесения о спаме это то, что заставляет ГМ закрывать взломанные спамерами аккаунты и очищать игровой мир. Также, если многие люди смогут сообщать о спамерах, то спамеры теряют возможность писать в чат, что выгодно всем, особенно людям не использующим BadBoy."
		locManualReport = "Показать всплывающее окно с отчетом о игроке (показывающее собственно спам) вместо показа сообщения в чате."
	elseif L == "koKR" then

	elseif L == "ptBR" then

	elseif L == "itIT" then
		locNoReportMsg = "Nascondi il messaggio 'Spam bloccata' che ti chiede di riportare"
		locNoReportDesc = "Prego NON usare questo. Riportare le spam è ciò che permette di bloccare account rubati usati dagli spammers. Inoltre se tanti riportano uno spammer, questi non può più scrivere nella chat e ciò va a vantaggio di tutti, anche di coloro che non usano questo addon."
		locManualReport = "Visualizza un messaggio che mostra la spam al posto di scrivere sulla chat"
	end
end

--[[ Main Panel ]]--
local badboy = CreateFrame("Frame", "BadBoyConfig", InterfaceOptionsFramePanelContainer)
badboy:Hide()
badboy.name = "BadBoy"
local title = badboy:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("BadBoy v13.025") -- wowace magic, replaced with tag version
InterfaceOptions_AddCategory(badboy)

--[[ No Report Chat Message Checkbox ]]--
local btnNoReportMsg = CreateFrame("CheckButton", "BadBoyConfigSilenceButton", badboy, "OptionsBaseCheckButtonTemplate")
btnNoReportMsg:SetPoint("TOPLEFT", 16, -35)
btnNoReportMsg:SetScript("OnClick", function(frame)
	if frame:GetChecked() then
		PlaySound("igMainMenuOptionCheckBoxOn")
		BADBOY_NOLINK = true
	else
		PlaySound("igMainMenuOptionCheckBoxOff")
		BADBOY_NOLINK = nil
	end
end)
btnNoReportMsg:SetScript("OnShow", function(frame)
	frame:SetChecked(BADBOY_NOLINK)
end)
local btnNoReportMsgText = btnNoReportMsg:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
btnNoReportMsgText:SetPoint("LEFT", btnNoReportMsg, "RIGHT", 0, 1)
btnNoReportMsgText:SetText(locNoReportMsg)
local btnNoReportMsgDesc = btnNoReportMsg:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
btnNoReportMsgDesc:SetPoint("TOPLEFT", btnNoReportMsgText, "BOTTOMLEFT", 0, -2)
btnNoReportMsgDesc:SetJustifyH("LEFT")
btnNoReportMsgDesc:SetWordWrap(true)
btnNoReportMsgDesc:SetWidth(560)
btnNoReportMsgDesc:SetText(locNoReportDesc)

--[[ No Automatic Report Checkbox ]]--
local btnManualReport = CreateFrame("CheckButton", "BadBoyConfigPopupButton", badboy, "OptionsBaseCheckButtonTemplate")
btnManualReport:SetPoint("TOPLEFT", 16, -112)
btnManualReport:SetScript("OnClick", function(frame)
	if frame:GetChecked() then
		PlaySound("igMainMenuOptionCheckBoxOn")
		BADBOY_POPUP = true
	else
		PlaySound("igMainMenuOptionCheckBoxOff")
		BADBOY_POPUP = nil
	end
end)
btnManualReport:SetScript("OnShow", function(frame)
	frame:SetChecked(BADBOY_POPUP)
end)
local btnManualReportText = btnManualReport:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
btnManualReportText:SetPoint("LEFT", btnManualReport, "RIGHT", 0, 1)
btnManualReportText:SetJustifyH("LEFT")
btnManualReportText:SetWordWrap(true)
btnManualReportText:SetWidth(560)
btnManualReportText:SetText(locManualReport)

--[[ BadBoy_Levels Title ]]--
local levelsTitle = badboy:CreateFontString("BadBoyLevelsConfigTitle", "ARTWORK", "GameFontNormalLarge")
levelsTitle:SetPoint("TOPLEFT", btnManualReport, "BOTTOMLEFT", 0, -3)
levelsTitle:SetText("BadBoy_Levels ["..ADDON_MISSING.."]")

--[[ BadBoy_Guilded Title ]]--
local guildedTitle = badboy:CreateFontString("BadBoyGuildedConfigTitle", "ARTWORK", "GameFontNormalLarge")
guildedTitle:SetPoint("TOPLEFT", btnManualReport, "BOTTOMLEFT", 0, -48)
guildedTitle:SetText("BadBoy_Guilded ["..ADDON_MISSING.."]")

--[[ BadBoy_CCleaner Title ]]--
local ccleanerTitle = badboy:CreateFontString("BadBoyCCleanerConfigTitle", "ARTWORK", "GameFontNormalLarge")
ccleanerTitle:SetPoint("TOPLEFT", btnManualReport, "BOTTOMLEFT", 0, -116)
ccleanerTitle:SetText("BadBoy_CCleaner ["..ADDON_MISSING.."]")

