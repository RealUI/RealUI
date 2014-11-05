local addonName, addon = ...
if not addon.healthCheck then return end
local L = addon.L

-- The sack
local window = nil

-- What state is the sack in?
local state = "BugSackTabAll"
local searchResults = {}
local searchThrough = nil

-- Frame state variables
local currentErrorIndex = nil -- Index of the error in the currentSackContents currently shown
local currentSackContents = nil -- List of all the errors currently navigated in the sack
local currentSackSession = nil -- Current session ID available in the sack
local currentErrorObject = nil

local tabs = nil

local countLabel, sessionLabel, textArea = nil, nil, nil
local nextButton, prevButton, sendButton = nil, nil, nil
local searchLabel, searchBox = nil, nil

local sessionFormat = "%s - |cffff4411%s|r - |cff44ff44%d|r" -- <date> - <sent by> - <session id>
local countFormat = "%d/%d" -- 1/10
local sourceFormat = L["Sent by %s (%s)"]
local localFormat = L["Local (%s)"]

-- Updates the total bug count and so forth.
local lastState = nil
local function updateSackDisplay(forceRefresh)
	if state ~= lastState then forceRefresh = true end
	lastState = state

	if forceRefresh then
		currentErrorObject = nil
		currentErrorIndex = nil
	else
		currentErrorObject = currentSackContents and currentSackContents[currentErrorIndex]
	end

	if state == "BugSackTabAll" then
		currentSackContents = addon:GetErrors()
		currentSackSession = BugGrabber:GetSessionId()
	elseif state == "BugSackTabSession" then
		local s = BugGrabber:GetSessionId()
		currentSackContents = addon:GetErrors(s)
		currentSackSession = s
	elseif state == "BugSackTabLast" then
		local s = BugGrabber:GetSessionId() - 1
		currentSackContents = addon:GetErrors(s)
		currentSackSession = s
	elseif state == "BugSackSearch" then
		currentSackSession = -1
		currentSackContents = searchResults
	end

	local size = #currentSackContents
	local eo = nil

	if forceRefresh then
		-- We need to reset the currently shown error to the highest index
		eo = currentSackContents[size]
		currentErrorIndex = size
	else
		-- we need to adapt the currentErrorIndex index to the new error list
		for i, v in next, currentSackContents do
			if v == currentErrorObject then
				currentErrorIndex = i
				eo = v
				break
			end
		end
	end
	if not eo then eo = currentSackContents[currentErrorIndex] end
	if not eo then eo = currentSackContents[size] end
	if currentSackSession == -1 then currentSackSession = eo.session end

	if size > 0 then
		local source = nil
		if eo.source then source = sourceFormat:format(eo.source, "error")
		else source = localFormat:format("error") end
		if eo.session == BugGrabber:GetSessionId() then
			sessionLabel:SetText(sessionFormat:format(L["Today"], source, eo.session))
		else
			sessionLabel:SetText(sessionFormat:format(eo.time, source, eo.session))
		end
		countLabel:SetText(countFormat:format(currentErrorIndex, size))
		textArea:SetText(addon:FormatError(eo))

		if currentErrorIndex >= size then
			nextButton:Disable()
		else
			nextButton:Enable()
		end
		if currentErrorIndex <= 1 then
			prevButton:Disable()
		else
			prevButton:Enable()
		end
		if sendButton then sendButton:Enable() end
	else
		countLabel:SetText()
		if currentSackSession == BugGrabber:GetSessionId() then
			sessionLabel:SetText(("%s (%d)"):format(L["Today"], BugGrabber:GetSessionId()))
		else
			sessionLabel:SetText(("%d"):format(currentSackSession))
		end
		textArea:SetText(L["You have no bugs, yay!"])
		nextButton:Disable()
		prevButton:Disable()
		if sendButton then sendButton:Disable() end
	end

	for i, t in next, tabs do
		if state == t:GetName() then
			PanelTemplates_SelectTab(t)
		else
			PanelTemplates_DeselectTab(t)
		end
	end
end
hooksecurefunc(addon, "UpdateDisplay", function()
	if not window or not window:IsShown() then return end
	-- can't just hook it right in because it would pass |self| as forceRefresh
	updateSackDisplay()
end)

-- Only invoked when actually clicking a tab
local function setActiveMethod(tab)
	searchLabel:Hide()
	searchBox:Hide()
	sessionLabel:Show()
	wipe(searchResults)
	if searchThrough then
		wipe(searchThrough)
		searchThrough = nil
	end

	state = type(tab) == "table" and tab:GetName() or tab
	updateSackDisplay(true)
end

local function clearSearch()
	setActiveMethod("BugSackTabAll")
end

local function filterSack(editbox)
	for i, t in next, tabs do
		PanelTemplates_DeselectTab(t)
	end
	wipe(searchResults)

	local text = editbox:GetText()
	-- If there's no text in the box, we reset to all bugs so the search can start over
	if not searchThrough or not text or text:trim():len() == 0 then
		state = "BugSackTabAll"
	else
		for i, err in next, searchThrough do
			if err.message and err.message:find(text) then
				searchResults[#searchResults + 1] = err
			elseif err.stack and err.stack:find(text) then
				searchResults[#searchResults + 1] = err
			elseif err.locals and err.locals:find(text) then
				searchResults[#searchResults + 1] = err
			end
		end
		state = "BugSackSearch"
	end
	updateSackDisplay(true)
end

local function createBugSack()
	window = CreateFrame("Frame", "BugSackFrame", UIParent)
	window:Hide()

	window:SetFrameStrata("FULLSCREEN_DIALOG")
	window:SetWidth(500)
	window:SetHeight(500 / 1.618)
	window:SetPoint("CENTER")
	window:SetMovable(true)
	window:EnableMouse(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)
	window:SetScript("OnShow", function()
		PlaySound("igQuestLogOpen")
	end)
	window:SetScript("OnHide", function()
		PlaySound("igQuestLogClose")
		currentErrorObject = nil
		currentSackSession = nil
		currentSackContents = nil
	end)

	local titlebg = window:CreateTexture(nil, "BORDER")
	titlebg:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background")
	titlebg:SetPoint("TOPLEFT", 9, -6)
	titlebg:SetPoint("BOTTOMRIGHT", window, "TOPRIGHT", -28, -24)

	local dialogbg = window:CreateTexture(nil, "BACKGROUND")
	dialogbg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-CharacterTab-L1")
	dialogbg:SetPoint("TOPLEFT", 8, -12)
	dialogbg:SetPoint("BOTTOMRIGHT", -6, 8)
	dialogbg:SetTexCoord(0.255, 1, 0.29, 1)

	local topleft = window:CreateTexture(nil, "BORDER")
	topleft:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	topleft:SetWidth(64)
	topleft:SetHeight(64)
	topleft:SetPoint("TOPLEFT")
	topleft:SetTexCoord(0.501953125, 0.625, 0, 1)

	local topright = window:CreateTexture(nil, "BORDER")
	topright:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	topright:SetWidth(64)
	topright:SetHeight(64)
	topright:SetPoint("TOPRIGHT")
	topright:SetTexCoord(0.625, 0.75, 0, 1)

	local top = window:CreateTexture(nil, "BORDER")
	top:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	top:SetHeight(64)
	top:SetPoint("TOPLEFT", topleft, "TOPRIGHT")
	top:SetPoint("TOPRIGHT", topright, "TOPLEFT")
	top:SetTexCoord(0.25, 0.369140625, 0, 1)

	local bottomleft = window:CreateTexture(nil, "BORDER")
	bottomleft:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	bottomleft:SetWidth(64)
	bottomleft:SetHeight(64)
	bottomleft:SetPoint("BOTTOMLEFT")
	bottomleft:SetTexCoord(0.751953125, 0.875, 0, 1)

	local bottomright = window:CreateTexture(nil, "BORDER")
	bottomright:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	bottomright:SetWidth(64)
	bottomright:SetHeight(64)
	bottomright:SetPoint("BOTTOMRIGHT")
	bottomright:SetTexCoord(0.875, 1, 0, 1)

	local bottom = window:CreateTexture(nil, "BORDER")
	bottom:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	bottom:SetHeight(64)
	bottom:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMRIGHT")
	bottom:SetPoint("BOTTOMRIGHT", bottomright, "BOTTOMLEFT")
	bottom:SetTexCoord(0.376953125, 0.498046875, 0, 1)

	local left = window:CreateTexture(nil, "BORDER")
	left:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	left:SetWidth(64)
	left:SetPoint("TOPLEFT", topleft, "BOTTOMLEFT")
	left:SetPoint("BOTTOMLEFT", bottomleft, "TOPLEFT")
	left:SetTexCoord(0.001953125, 0.125, 0, 1)

	local right = window:CreateTexture(nil, "BORDER")
	right:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	right:SetWidth(64)
	right:SetPoint("TOPRIGHT", topright, "BOTTOMRIGHT")
	right:SetPoint("BOTTOMRIGHT", bottomright, "TOPRIGHT")
	right:SetTexCoord(0.1171875, 0.2421875, 0, 1)

	local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 2, 1)
	close:SetScript("OnClick", addon.CloseSack)

	countLabel = window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	countLabel:SetPoint("TOPRIGHT", titlebg, -6, -3)
	countLabel:SetJustifyH("RIGHT")
	countLabel:SetTextColor(1, 1, 1, 1)

	sessionLabel = CreateFrame("Button", nil, window)
	sessionLabel:SetNormalFontObject("GameFontNormalLeft")
	sessionLabel:SetHighlightFontObject("GameFontHighlightLeft")
	sessionLabel:SetPoint("TOPLEFT", titlebg, 6, -4)
	sessionLabel:SetPoint("BOTTOMRIGHT", countLabel, "BOTTOMLEFT", -4, 1)
	sessionLabel:SetScript("OnHide", function()
		window:StopMovingOrSizing()
	end)
	sessionLabel:SetScript("OnMouseUp", function()
		window:StopMovingOrSizing()
	end)
	sessionLabel:SetScript("OnMouseDown", function()
		window:StartMoving()
	end)
	sessionLabel:SetScript("OnDoubleClick", function()
		sessionLabel:Hide()
		searchLabel:Show()
		searchBox:Show()
		searchThrough = currentSackContents
	end)
	local quickTips = "|cff44ff44Double-click|r to filter bug reports. After you are done with the search results, return to the full sack by selecting a tab at the bottom. |cff44ff44Left-click|r and drag to move the window. |cff44ff44Right-click|r to close the sack and open the interface options for BugSack."
	sessionLabel:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -8, 8)
		GameTooltip:AddLine("Quick tips")
		GameTooltip:AddLine(quickTips, 1, 1, 1, 1)
		GameTooltip:Show()
	end)
	sessionLabel:SetScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	searchLabel = window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	searchLabel:SetText("Filter:")
	searchLabel:SetJustifyH("LEFT")
	searchLabel:SetPoint("TOPLEFT", titlebg, 6, -3)
	searchLabel:SetTextColor(1, 1, 1, 1)
	searchLabel:Hide()

	searchBox = CreateFrame("EditBox", nil, window)
	searchBox:SetTextInsets(4, 4, 0, 0)
	searchBox:SetMaxLetters(50)
	searchBox:SetFontObject("ChatFontNormal")
	searchBox:SetBackdrop({
		edgeFile = nil,
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
		tile = true,
		tileSize = 16,
		edgeSize = 0,
	})
	searchBox:SetBackdropColor(0, 0, 0, 0.5)
	searchBox:SetScript("OnShow", function(self)
		self:SetFocus()
	end)
	searchBox:SetScript("OnHide", function(self)
		self:ClearFocus()
		self:SetText("")
	end)
	searchBox:SetScript("OnEscapePressed", clearSearch)
	searchBox:SetScript("OnTextChanged", filterSack)
	searchBox:SetAutoFocus(false)
	searchBox:SetPoint("TOPLEFT", searchLabel, "TOPRIGHT", 6, 1)
	searchBox:SetPoint("BOTTOMRIGHT", countLabel, "BOTTOMLEFT", -3, -1)
	searchBox:Hide()

	nextButton = CreateFrame("Button", "BugSackNextButton", window, "UIPanelButtonTemplate")
	nextButton:SetPoint("BOTTOMRIGHT", window, -11, 16)
	nextButton:SetWidth(130)
	nextButton:SetText(L["Next >"])
	nextButton:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			currentErrorIndex = #currentSackContents
		else
			currentErrorIndex = currentErrorIndex + 1
		end
		updateSackDisplay()
	end)

	prevButton = CreateFrame("Button", "BugSackPrevButton", window, "UIPanelButtonTemplate")
	prevButton:SetPoint("BOTTOMLEFT", window, 14, 16)
	prevButton:SetWidth(130)
	prevButton:SetText(L["< Previous"])
	prevButton:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			currentErrorIndex = 1
		else
			currentErrorIndex = currentErrorIndex - 1
		end
		updateSackDisplay()
	end)

	if addon.Serialize then
		sendButton = CreateFrame("Button", "BugSackSendButton", window, "UIPanelButtonTemplate")
		sendButton:SetPoint("LEFT", prevButton, "RIGHT")
		sendButton:SetPoint("RIGHT", nextButton, "LEFT")
		sendButton:SetText(L["Send bugs"])
		sendButton:SetScript("OnClick", function()
			local eo = currentSackContents[currentErrorIndex]
			local popup = StaticPopup_Show("BugSackSendBugs", eo.session)
			popup.data = eo.session
			window:Hide()
		end)
	end

	local scroll = CreateFrame("ScrollFrame", "BugSackScroll", window, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", window, "TOPLEFT", 16, -36)
	scroll:SetPoint("BOTTOMRIGHT", nextButton, "TOPRIGHT", -24, 8)

	textArea = CreateFrame("EditBox", "BugSackScrollText", scroll)
	textArea:SetTextColor(.5, .5, .5, 1)
	textArea:SetAutoFocus(false)
	textArea:SetMultiLine(true)
	textArea:SetFontObject(_G[addon.db.fontSize] or GameFontHighlightSmall)
	textArea:SetMaxLetters(99999)
	textArea:EnableMouse(true)
	textArea:SetScript("OnEscapePressed", textArea.ClearFocus)
	-- XXX why the fuck doesn't SetPoint work on the editbox?
	textArea:SetWidth(450)

	scroll:SetScrollChild(textArea)

	local all = CreateFrame("Button", "BugSackTabAll", window, "CharacterFrameTabButtonTemplate")
	all:SetFrameStrata("FULLSCREEN")
	all:SetPoint("TOPLEFT", window, "BOTTOMLEFT", 0, 8)
	all:SetText(L["All bugs"])
	all:SetScript("OnLoad", nil)
	all:SetScript("OnShow", nil)
	all:SetScript("OnClick", setActiveMethod)
	all.bugs = "all"

	local session = CreateFrame("Button", "BugSackTabSession", window, "CharacterFrameTabButtonTemplate")
	session:SetFrameStrata("FULLSCREEN")
	session:SetPoint("LEFT", all, "RIGHT")
	session:SetText(L["Current session"])
	session:SetScript("OnLoad", nil)
	session:SetScript("OnShow", nil)
	session:SetScript("OnClick", setActiveMethod)
	session.bugs = "currentSession"

	local last = CreateFrame("Button", "BugSackTabLast", window, "CharacterFrameTabButtonTemplate")
	last:SetFrameStrata("FULLSCREEN")
	last:SetPoint("LEFT", session, "RIGHT")
	last:SetText(L["Previous session"])
	last:SetScript("OnLoad", nil)
	last:SetScript("OnShow", nil)
	last:SetScript("OnClick", setActiveMethod)
	last.bugs = "previousSession"

	tabs = {all, session, last}
	local size = 500 / 3
	for i, t in next, tabs do
		PanelTemplates_TabResize(t, nil, size, size)
		if i == 1 then
			PanelTemplates_SelectTab(t)
		else
			PanelTemplates_DeselectTab(t)
		end
	end
end

-- Called when the sack is supposed to be opened or refreshed,
-- and can only be called by :OpenSack or something that is available
-- from the sack window, so we know that currentSackContents is set.
local function show()
	if createBugSack then
		createBugSack()
		createBugSack = nil
	end
	updateSackDisplay()
	window:Show()
end

function addon:CloseSack()
	window:Hide()
end

function addon:OpenSack(errorObject)
	if window and window:IsShown() then
		-- Window is already open, we just need to update various texts.
		return
	end

	-- XXX we should show the most recent error (from this session) that has not previously been shown in the sack
	-- XXX so, 5 errors are caught, the user clicks the icon, we start it at the first of those 5 errors.
	--[[if not currentSackContents then
		currentSackContents = BugGrabber:GetDB(currentSackSession)
	end]]
	show()
end

