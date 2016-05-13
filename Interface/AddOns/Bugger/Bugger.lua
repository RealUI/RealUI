--[[--------------------------------------------------------------------
	Bugger
	Shows the errors captured by !BugGrabber.
	Copyright (c) 2015-2015 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info23144-Bugger.html
	http://www.curse.com/addons/wow/bugger
	https://github.com/Phanx/Bugger
----------------------------------------------------------------------]]

local BUGGER, Bugger = ...
local L = Bugger.L

if not BugGrabber then
	function Bugger:OnLogin()
		DEFAULT_CHAT_FRAME:AddMessage(L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."])
	end
	return
end

_G[BUGGER] = Bugger

------------------------------------------------------------------------

local defaults = {
	chat  = true,  -- show a message in the chat frame when an error is captured
	sound = false, -- play a sound when an error is captured
	minimapAuto = true,
	minimap = {
		hide = true,
	},
}

------------------------------------------------------------------------

local MIN_INTERVAL = 10

local ICON_GREEN = "Interface\\AddOns\\Bugger\\Icons\\Bug-Green"
local ICON_RED   = "Interface\\AddOns\\Bugger\\Icons\\Bug-Red"

local c = {
	BLUE   = BATTLENET_FONT_COLOR_CODE,
	GOLD   = NORMAL_FONT_COLOR_CODE,
	GRAY   = "|cff9f9f9f",
	GREEN  = "|cff7fff7f",
	ORANGE = "|cffff9f7f",
	PURPLE = "|cff9f7fff",
}

------------------------------------------------------------------------

Bugger.dataObject = {
	type = "data source",
	icon = ICON_GREEN,
	text = 0,
	label = L["Errors"],
	OnClick = function(self, button)
		if button == "RightButton" then
			-- level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay
			ToggleDropDownMenu(nil, nil, Bugger.menu, self, 0, 0, nil, nil, 10)
		elseif IsShiftKeyDown() then
			ReloadUI()
		elseif IsAltKeyDown() then
			BugGrabber:Reset()
		else
			Bugger:ToggleFrame()
		end
	end,
	OnTooltipShow = function(tt)
		local total = Bugger:GetNumErrors()

		tt:AddDoubleLine(BUGGER, total > 0 and total or "", nil, nil, nil, 1, 1, 1)

		if total > 0 then
			tt:AddLine(" ")
			local errors = BugGrabber:GetDB()
			for i = 1, min(total, 3) do
				local err = errors[#errors + 1 - i]
				tt:AddLine(format("%s%d.|r %s", c.GRAY, total + 1 - i, Bugger:FormatError(err, "short")), 1, 1, 1)
			end
			tt:AddLine(" ")
		end

		tt:AddLine(L["Click to open the error window."])
		tt:AddLine(L["Alt-click to clear all saved errors."])
		tt:AddLine(L["Shift-click to reload the UI."])
		tt:AddLine(L["Right-click for options."])
	end,
}

------------------------------------------------------------------------

function Bugger:OnLoad()
	self.db = self:InitializeDB("BuggerDB", defaults)
	LibStub("LibDataBroker-1.1"):NewDataObject(BUGGER, self.dataObject)
	LibStub("LibDBIcon-1.0"):Register(BUGGER, self.dataObject, self.db.minimap)
end

function Bugger:OnLogin()
	BugGrabber.RegisterCallback(self, "BugGrabber_BugGrabbed")
	if self:GetNumErrors() > 0 then
		return self:BugGrabber_BugGrabbed()
	elseif self.db.minimapAuto then
		LibStub("LibDBIcon-1.0"):Hide(BUGGER)
	end
end

------------------------------------------------------------------------

hooksecurefunc(BugGrabber, "Reset", function()
	Bugger:Print(L["All saved errors have been deleted."])

	Bugger.dataObject.icon = ICON_GREEN
	Bugger.dataObject.text = 0

	if Bugger.db.minimapAuto then
		LibStub("LibDBIcon-1.0"):Hide(BUGGER)
	end
end)

------------------------------------------------------------------------

function Bugger:GetNumErrors(session)
	local errors = BugGrabber:GetDB()
	local total = #errors
	if total == 0 then return 0 end

	if session == "all" then
		return total, 1, total
	end

	if session == "previous" then
		session = BugGrabber:GetSessionId() - 1
	else
		session = BugGrabber:GetSessionId()
	end

	local total, first, last = 0
	for i = 1, #errors do
		if errors[i].session == session then
			total = total + 1
			first = first or i
			last = i
		end
	end
	return total, first, last
end

------------------------------------------------------------------------

--[[
	errorObject = {
		message = sanitizedMessage,
		stack = table.concat(tmp, "\n"),
		locals = debuglocals(4),
		session = BugGrabber:GetSessionId(),
		time = date("%Y/%m/%d %H:%M:%S"),
		counter = 1,
	}
]]
function Bugger:BugGrabber_BugGrabbed(callback, err)
	self.dataObject.text = self:GetNumErrors()
	self.dataObject.icon = ICON_RED

	if self.db.minimapAuto then
		LibStub("LibDBIcon-1.0"):Show(BUGGER)
	end

	if (self.lastError or 0) + MIN_INTERVAL < GetTime() then
		if self.db.chat then
			self:Print("|Hbugger:0|h[" .. L["An error has been captured!"] .. "]|h")
		end
		if self.db.sound then
			PlaySoundFile(self.db.sound, "Master")
		end
	end
	self.lastError = GetTime()
end

------------------------------------------------------------------------

local orig_OnHyperlinkShow = ChatFrame_OnHyperlinkShow

function ChatFrame_OnHyperlinkShow(frame, link, ...)
	if strsub(link, 1, 6) == "bugger" then
		return Bugger:ToggleFrame()
	end
	return orig_OnHyperlinkShow(frame, link, ...)
end

------------------------------------------------------------------------

do
	local FILE_TEMPLATE   = c.GRAY .. "%1%2\\|r%3:" .. c.GREEN .. "%4|r" .. c.GRAY .. "%5|r%6"
	local STRING_TEMPLATE = c.GRAY .. "%1[string |r\"" .. c.BLUE .. "%2\"|r" .. c.GRAY .. "]|r:" .. c.GREEN .. "%3|r" .. c.GRAY .. "%4|r%5"
	local NAME_TEMPLATE   = c.BLUE .. "'%1'|r"
	local IN_C = c.GOLD .. "[C]|r" .. c.GRAY .. ":|r"

	function Bugger:FormatStack(message, stack)
		message = message and tostring(message)
		if not message then return "" end
		stack = stack and tostring(stack)
		if stack then
			message = message .. "\n" .. stack
		end
		message = gsub(message, "Interface\\", "")
		message = gsub(message, "AddOns\\", "")
		message = gsub(message, "%[C%]", IN_C)
		message = gsub(message, "(<?)(%a+)\\(.-%.[lx][um][al]):(%d+)(>?)(:?)", FILE_TEMPLATE)
		message = gsub(message, "(<?)%[string \"(.-)\"]:(%d+)(>?)(:?)", STRING_TEMPLATE)
		message = gsub(message, "['`]([^`']+)'", NAME_TEMPLATE)
		return message
	end
end

do
	local LOCALS_TEMPLATE = "\n\n" .. c.GOLD .. "Locals:|r%s"
	local FILE_TEMPLATE   = c.GRAY .. "%1\\|r%2:" .. c.GREEN .. "%3|r"
	local GRAY    = c.GRAY .. "%1|r"
	local EQUALS  = c.GRAY .. " = |r"
	local BOOLEAN = EQUALS .. c.PURPLE .. "%1|r"
	local NUMBER  = EQUALS .. c.ORANGE .. "%1|r"
	local STRING  = EQUALS .. c.BLUE .. "\"%1\"|r"
	-- TODO: color other types

	function Bugger:FormatLocals(locals)
		locals = locals and tostring(locals)
		if not locals then return "" end
		locals = "\n" .. locals
		locals = gsub(locals, "> {\n}", ">")
		locals = gsub(locals, "%(%*temporary%)", GRAY)
		locals = gsub(locals, "(<[a-z]+>)", GRAY)
		locals = gsub(locals, " = ([ftn][ari][lu]s?e?)", BOOLEAN)
		locals = gsub(locals, " = ([0-9%.%-]+)", NUMBER)
		locals = gsub(locals, " = \"([^\"]+)\"", STRING)
		locals = gsub(locals, "Interface\\A?d?d?[Oo]?n?s?\\?(%a+)\\(.-%.[lx][um][al]):([0-9]+)", FILE_TEMPLATE)
		return format(LOCALS_TEMPLATE, locals)
	end
end

do
	local FULL_TEMPLATE = "%d" .. c.GRAY .. "x|r %s%s"
	local SHORT_TEMPLATE = "%s " .. c.GRAY .. "(x%d)|r"

	function Bugger:FormatError(err, style)
		if style == "short" then
			return format(SHORT_TEMPLATE, self:FormatStack(err.message), err.counter or 1)
		elseif style == "extended" then
			return format(FULL_TEMPLATE, err.counter or 1, self:FormatStack(err.message, err.stack), self:FormatLocals(err.locals))
		end
		return format(FULL_TEMPLATE, err.counter or 1, self:FormatStack(err.message, err.stack), "")
	end
end

------------------------------------------------------------------------

function Bugger:ShowError(index, showLocals)
	if not self.frame then
		self:SetupFrame()
	end

	self.frame:Show()

	local errors = BugGrabber:GetDB()
	local total, first, last = self:GetNumErrors(self.session)

	if total == 0 then
		self.error = 0
		self.editBox:SetText(c.GRAY .. L["There are no errors to display."])
		self.editBox:SetCursorPosition(0)
		self.editBox:ClearFocus()
		self.scrollFrame:SetVerticalScroll(0)
		self.title:SetText(LUA_ERROR)
		self.indexLabel:SetText("")
		self.showLocals:Disable()
		self.previous:Disable()
		self.next:Disable()
		self.clear:SetEnabled(#errors > 0)
		return
	end

	local err = index and index >= first and index <= last and errors[index]
	if not err then
		index = last
		err = errors[index]
	end

	self.first, self.last, self.error = first, last, index

	local sdiff = BugGrabber:GetSessionId() - err.session
	if self.session == "all" and sdiff > 0 then
		self.title:SetFormattedText("%s %s(%d)|r", err.time, c.GRAY, sdiff)
	else
		self.title:SetText(err.time)
	end

	if err.locals == "" or not err.locals then
		showLocals = false
		self.showLocals:Disable()
		self.showLocals:GetHighlightTexture():SetDrawLayer("HIGHLIGHT")
	else
		self.showLocals:Enable()
		self.showLocals:GetHighlightTexture():SetDrawLayer(showLocals and "OVERLAY" or "HIGHLIGHT")
	end

	self.editBox:SetText(self:FormatError(err, showLocals and "extended" or nil))
	self.editBox:SetCursorPosition(1)
	self.editBox:ClearFocus()

	self.scrollFrame:SetVerticalScroll(0)

	self.indexLabel:SetFormattedText("%d / %d", index + 1 - first, total)

	self.clear:Enable()
	self.previous:SetEnabled(index > first)
	self.next:SetEnabled(index < last)
end

------------------------------------------------------------------------

function Bugger:ShowSession(session)
	if session ~= "all" and session ~= "previous" then
		session = "current"
	end

	if not self.frame then
		self:SetupFrame()
	end

	for i = 1, #self.tabs do
		local tab = self.tabs[i]
		if tab.session == session then
			PanelTemplates_SelectTab(tab)
		else
			PanelTemplates_DeselectTab(tab)
		end
	end

	self.session = session
	self:ShowError()
end

------------------------------------------------------------------------

function Bugger:ToggleFrame()
	if self.frame and self.frame:IsShown() then
		self.frame:Hide()
	else
		self:ShowSession()
	end
end

------------------------------------------------------------------------

function Bugger:SetupFrame()
	if not IsAddOnLoaded("Blizzard_DebugTools") then
		LoadAddOn("Blizzard_DebugTools")
	end

	tinsert(UISpecialFrames, "ScriptErrorsFrame")
	ScriptErrorsFrame_OnError = function() end
	ScriptErrorsFrame_Update  = function() end

	self.frame       = ScriptErrorsFrame
	self.scrollFrame = ScriptErrorsFrameScrollFrame
	self.editBox     = ScriptErrorsFrameScrollFrameText
	self.title       = self.frame.title
	self.indexLabel  = self.frame.indexLabel
	self.reload      = self.frame.reload
	self.previous    = self.frame.previous
	self.next        = self.frame.next
	self.clear       = self.frame.close

	self.frame:SetParent(UIParent)
	self.frame:SetScript("OnShow", nil)

	self.editBox:SetFontObject(GameFontHighlight)
	self.editBox:SetTextColor(0.9, 0.9, 0.9)

	local addWidth = 150
	self.frame:SetWidth(self.frame:GetWidth() + addWidth)
	self.scrollFrame:SetWidth(self.scrollFrame:GetWidth() + addWidth - 4)
	self.editBox:SetWidth(self.editBox:GetWidth() + addWidth)

	local addHeight = 50
	self.frame:SetHeight(self.frame:GetHeight() + addHeight)
	self.scrollFrame:SetHeight(self.scrollFrame:GetHeight() + addHeight - 4)

	self.scrollFrame:SetPoint("TOPLEFT", 16, -32)
	self.scrollFrame.ScrollBar:SetPoint("TOPLEFT", self.scrollFrame, "TOPRIGHT", 6, -13)

	self.clear:ClearAllPoints()
	self.clear:SetPoint("BOTTOMLEFT", 12, 12)
	self.clear:SetPoint("LEFT", self.reload, "RIGHT", 4, 0)
	self.clear:SetText(CLEAR_ALL)
	self.clear:SetWidth(self.clear:GetFontString():GetStringWidth() + 20)
	self.clear:SetScript("OnClick", function()
		BugGrabber:Reset()
		self:ShowError()
	end)

	self.next:ClearAllPoints()
	self.next:SetPoint("BOTTOMRIGHT", -10, 12)

	self.previous:ClearAllPoints()
	self.previous:SetPoint("RIGHT", self.next, "LEFT", -4, 0)

	self.showLocals = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
	self.showLocals:SetPoint("RIGHT", self.previous, "LEFT", -4, 0)
	self.showLocals:SetText(L["Locals"])
	self.showLocals:SetHeight(self.previous:GetHeight())
	self.showLocals:SetWidth(self.showLocals:GetFontString():GetStringWidth() + 20)
	self.showLocals:SetScript("OnClick", function(this)
		local showLocals = this:GetHighlightTexture():GetDrawLayer() == "HIGHLIGHT"
		Bugger:ShowError(Bugger.error, showLocals)
	end)

	self.indexLabel:ClearAllPoints()
	self.indexLabel:SetPoint("LEFT", self.clear, "RIGHT", 4, 0)
	self.indexLabel:SetPoint("RIGHT", self.showLocals, "LEFT", -4, 0)
	self.indexLabel:SetJustifyH("CENTER")

	self.error = 0
	self.session = "current"

	self.previous:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			self:ShowError(self.first)
		else
			self:ShowError(self.error - 1)
		end
	end)

	self.next:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			self:ShowError(self.last)
		else
			self:ShowError(self.error + 1)
		end
	end)

	local tabLevel = self.frame:GetFrameLevel()
	local tabWidth = (self.frame:GetWidth() - 16) / 3
	local function clickTab(tab)
		Bugger:ShowSession(tab.session)
	end
	self.tabs = {}
	self.frame:SetFrameLevel(tabLevel + 1)
	for i = 1, 3 do
		local tab = CreateFrame("Button", "$parentTab"..i, self.frame, "CharacterFrameTabButtonTemplate")
		tab:UnregisterAllEvents()
		tab:SetScript("OnEvent", nil)
		tab:SetScript("OnClick", clickTab)
		tab:SetScript("OnShow",  nil)
		tab:SetScript("OnEnter", nil)
		tab:SetScript("OnLeave", nil)
		tab:SetFrameLevel(tabLevel)
		PanelTemplates_TabResize(tab, 0, tabWidth)
		self.tabs[i] = tab
	end

	self.tabs[1].session = "all"
	self.tabs[1]:SetText(L["All Errors"])
	self.tabs[1]:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT", 8, 7)

	self.tabs[2].session = "previous"
	self.tabs[2]:SetText(L["Previous Session"])
	self.tabs[2]:SetPoint("TOPLEFT", self.tabs[1], "TOPRIGHT")

	self.tabs[3].session = "current"
	self.tabs[3]:SetText(L["Current Session"])
	self.tabs[3]:SetPoint("TOPLEFT", self.tabs[2], "TOPRIGHT")

	self.frame:SetClampRectInsets(0, 0, 0, -self.tabs[3]:GetHeight())

	local optButton = CreateFrame("Button", nil, ScriptErrorsFrameTitleButton)
	optButton:SetPoint("TOPRIGHT", ScriptErrorsFrameClose, "TOPLEFT", -2, -8)
	optButton:SetSize(16, 16)
	optButton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
	optButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	optButton:RegisterForClicks("AnyUp")
	optButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:SetText(L["Right-click for options."])
	end)
	optButton:SetScript("OnLeave", GameTooltip_Hide)
	optButton:SetScript("OnClick", function(self, button)
		if button ~= "RightButton" then return end
		ToggleDropDownMenu(nil, nil, Bugger.menu, self, 0, 0, nil, nil, 10)
	end)

	local reloadButton = CreateFrame("Button", nil, ScriptErrorsFrameTitleButton)
	reloadButton:SetPoint("RIGHT", optButton, "LEFT", -2, -1)
	reloadButton:SetSize(18, 18)
	reloadButton:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
	reloadButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	reloadButton:RegisterForClicks("AnyUp")
	reloadButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:SetText(L["Shift-click to reload the UI."])
	end)
	reloadButton:SetScript("OnLeave", GameTooltip_Hide)
	reloadButton:SetScript("OnClick", function(self, button)
		if IsShiftKeyDown() then
			ReloadUI()
		end
	end)
end

------------------------------------------------------------------------

SLASH_BUGGER1 = "/bugger"
SLASH_BUGGER2 = L["/bugger"]

SlashCmdList["BUGGER"] = function(cmd)
	cmd = strlower(strtrim(cmd or ""))
	if cmd == "reset" then
		BugGrabber:Reset()
	else
		Bugger:ToggleFrame()
	end
end

------------------------------------------------------------------------

local menu = CreateFrame("Frame", "BuggerMenu", UIParent, "UIDropDownMenuTemplate")
menu.displayMode = "MENU"

menu.chatGet = function(self)
	return Bugger.db.chat
end
menu.chatSet = function(_, _, _, checked)
	Bugger.db.chat = checked
end

menu.soundGet = function()
	return Bugger.db.sound
end
menu.soundSet = function(_, _, _, checked)
	Bugger.db.sound = checked
end

menu.iconShowGet = function()
	return not Bugger.db.minimap.hide and not Bugger.db.minimapAuto
end
menu.iconShowSet = function()
	Bugger.db.minimapAuto = false
	Bugger.db.minimap.hide = false
	LibStub("LibDBIcon-1.0"):Show(BUGGER)
end

menu.iconHideGet = function()
	return Bugger.db.minimap.hide and not Bugger.db.minimapAuto
end
menu.iconHideSet = function()
	Bugger.db.minimapAuto = false
	Bugger.db.minimap.hide = true
	LibStub("LibDBIcon-1.0"):Hide(BUGGER)
end

menu.iconAutoGet = function()
	return Bugger.db.minimapAuto
end
menu.iconAutoSet = function()
	Bugger.db.minimapAuto = true
	if Bugger:GetNumErrors() > 0 then
		Bugger.db.minimap.hide = false
		LibStub("LibDBIcon-1.0"):Show(BUGGER)
	else
		Bugger.db.minimap.hide = true
		LibStub("LibDBIcon-1.0"):Hide(BUGGER)
	end
end

menu.close = function()
	CloseDropDownMenus()
end

menu.initialize = function(_, level)
	if level == 1 then
		local info = UIDropDownMenu_CreateInfo()
		
		info.text = BUGGER
		info.isTitle = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)
		wipe(info)

		info.text = L["Chat frame alerts"]
		info.checked = menu.chatGet
		info.func = menu.chatSet
		info.isNotRadio = 1
		info.keepShownOnClick = 1
		UIDropDownMenu_AddButton(info, level)
		wipe(info)

	--[[
		info.text = L["Sound alerts"]
		info.checked = Bugger.db.sound
		info.func = menu.soundSet
		info.isNotRadio = 1
		info.keepShownOnClick = 1
		UIDropDownMenu_AddButton(info, level)
		wipe(info)
	]]

		info.text = L["Minimap icon"]
		info.hasArrow = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)
		wipe(info)

		info.text = CLOSE
		info.func = menu.close
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

	elseif level == 2 then
		local info = UIDropDownMenu_CreateInfo()

		info.text = SHOW
		info.checked = menu.iconShowGet
		info.func = menu.iconShowSet
		info.arg1 = false
		UIDropDownMenu_AddButton(info, level)

		info.text = HIDE
		info.checked = menu.iconHideGet
		info.func = menu.iconHideSet
		info.arg1 = true
		UIDropDownMenu_AddButton(info, level)

		info.text = L["Automatic"]
		info.func = menu.iconAutoSet
		info.checked = Bugger.db.minimapAuto
		UIDropDownMenu_AddButton(info, level)
	end
end

Bugger.menu = menu
