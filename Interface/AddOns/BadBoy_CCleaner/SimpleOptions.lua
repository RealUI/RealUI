
do
	BadBoyCCleanerConfigTitle:SetText("BadBoy_CCleaner r99-release") --wowace magic, replaced with tag version

	local ccleanerNoIcons = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
	ccleanerNoIcons:SetPoint("TOPLEFT", BadBoyConfigPopupButton, "BOTTOMLEFT", 0, -135)
	ccleanerNoIcons:SetScript("OnClick", function(frame)
		local tick = frame:GetChecked()
		if tick then
			PlaySound("igMainMenuOptionCheckBoxOn")
			BADBOY_NOICONS = true
		else
			PlaySound("igMainMenuOptionCheckBoxOff")
			BADBOY_NOICONS = nil
		end
	end)
	ccleanerNoIcons:SetScript("OnShow", function(frame)
		frame:SetChecked(BADBOY_NOICONS)
	end)

	local noIconsMsgText = ccleanerNoIcons:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	noIconsMsgText:SetPoint("LEFT", ccleanerNoIcons, "RIGHT", 0, 1)

	noIconsMsgText:SetText("Remove raid icons from public chat")
	local L = GetLocale()
	if L == "frFR" then
		noIconsMsgText:SetText("Enlever les icônes de raid des discussions publiques")
	elseif L == "deDE" then
		noIconsMsgText:SetText("Entferne Schlachtzugssymbole im Öffentlichen Chat")
	elseif L == "zhTW" then
		noIconsMsgText:SetText("Remove raid icons from public chat")
	elseif L == "zhCN" then
		noIconsMsgText:SetText("從公共頻道中移除團隊標記圖示")
	elseif L == "esES" then
		noIconsMsgText:SetText("Remove raid icons from public chat")
	elseif L == "esMX" then
		noIconsMsgText:SetText("Remove raid icons from public chat")
	elseif L == "ruRU" then
		noIconsMsgText:SetText("Убирать из чата рейдовые метки (квадрат, череп и тому подобные)")
	elseif L == "koKR" then
		noIconsMsgText:SetText("Remove raid icons from public chat")
	elseif L == "ptBR" then
		noIconsMsgText:SetText("Remove raid icons from public chat")
	elseif L == "itIT" then
		noIconsMsgText:SetText("Remove raid icons from public chat")
	end

	local ccleanerInput = CreateFrame("EditBox", nil, BadBoyConfig, "InputBoxTemplate")
	ccleanerInput:SetPoint("TOPLEFT", ccleanerNoIcons, "BOTTOMLEFT", 10, -5)
	ccleanerInput:SetAutoFocus(false)
	ccleanerInput:EnableMouse(true)
	ccleanerInput:SetWidth(250)
	ccleanerInput:SetHeight(20)
	ccleanerInput:SetMaxLetters(100)
	ccleanerInput:SetScript("OnEscapePressed", function(frame)
		frame:SetText("")
		frame:ClearFocus()
	end)
	ccleanerInput:SetScript("OnTextChanged", function(frame, changed)
		if changed then
			local msg = (frame:GetText()):lower()
			frame:SetText(msg)
		end
	end)
	ccleanerInput:Show()

	local ccleanerButton = CreateFrame("Button", nil, ccleanerInput, "UIPanelButtonTemplate")
	ccleanerButton:SetWidth(110)
	ccleanerButton:SetHeight(20)
	ccleanerButton:SetPoint("LEFT", ccleanerInput, "RIGHT")
	ccleanerButton:SetText(ADD.."/"..REMOVE)
	ccleanerButton:SetScript("OnClick", function(frame)
		ccleanerInput:ClearFocus()
		local t = ccleanerInput:GetText()
		if t == "" or t:find("^ *$") then ccleanerInput:SetText("") return end
		t = t:lower()
		local found
		for i=1, #BADBOY_CCLEANER do
			if BADBOY_CCLEANER[i] == t then found = i end
		end
		if found then
			tremove(BADBOY_CCLEANER, found)
		else
			tinsert(BADBOY_CCLEANER, t)
		end
		table.sort(BADBOY_CCLEANER)
		local text
		for i=1, #BADBOY_CCLEANER do
			if not text then
				text = BADBOY_CCLEANER[i]
			else
				text = text.."\n"..BADBOY_CCLEANER[i]
			end
		end
		BadBoyCCleanerEditBox:SetText(text or "")
		ccleanerInput:SetText("")
	end)
	ccleanerInput:SetScript("OnEnterPressed", function() ccleanerButton:Click() end)

	local ccleanerScrollArea = CreateFrame("ScrollFrame", "BadBoyCCleanerConfigScroll", BadBoyConfig, "UIPanelScrollFrameTemplate")
	ccleanerScrollArea:SetPoint("TOPLEFT", ccleanerInput, "BOTTOMLEFT", 0, -7)
	ccleanerScrollArea:SetPoint("BOTTOMRIGHT", BadBoyConfig, "BOTTOMRIGHT", -30, 10)

	local ccleanerEditBox = CreateFrame("EditBox", "BadBoyCCleanerEditBox", BadBoyConfig)
	ccleanerEditBox:SetMultiLine(true)
	ccleanerEditBox:SetMaxLetters(99999)
	ccleanerEditBox:EnableMouse(false)
	ccleanerEditBox:SetAutoFocus(false)
	ccleanerEditBox:SetFontObject(ChatFontNormal)
	ccleanerEditBox:SetWidth(350)
	ccleanerEditBox:SetHeight(250)
	ccleanerEditBox:Show()

	ccleanerScrollArea:SetScrollChild(ccleanerEditBox)

	local ccleanerBackdrop = CreateFrame("Frame", nil, BadBoyConfig)
	ccleanerBackdrop:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 3, right = 3, top = 5, bottom = 3}}
	)
	ccleanerBackdrop:SetBackdropColor(0,0,0,1)
	ccleanerBackdrop:SetPoint("TOPLEFT", ccleanerInput, "BOTTOMLEFT", -5, 0)
	ccleanerBackdrop:SetPoint("BOTTOMRIGHT", BadBoyConfig, "BOTTOMRIGHT", -27, 5)
end

