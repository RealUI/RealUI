local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Chat Copy", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Copy Chat"]

local lines = {}
local table_concat = _G.table.concat
local CreateFrame = _G.CreateFrame
local GetSpellInfo = _G.GetSpellInfo
local select = _G.select
local tinsert = _G.tinsert
local tostring = _G.tostring

local PaneBackdrop  = {
	bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
	edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local InsetBackdrop  = {
	bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local tex = select(3, GetSpellInfo(586))
local buttons = {}
local defaults = {
	profile = {
		copyIcon = false,
	}
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("CopyChat", defaults)

	local frame = CreateFrame("Frame", "ChatterCopyFrame", UIParent)
	tinsert(UISpecialFrames, "ChatterCopyFrame")
	frame:SetBackdrop(PaneBackdrop)
	frame:SetBackdropColor(0,0,0,1)
	frame:SetWidth(500)
	frame:SetHeight(400)
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:Hide()
	frame:SetFrameStrata("DIALOG")
	self.frame = frame
	
	local scrollArea = CreateFrame("ScrollFrame", "ChatterCopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	
	local editBox = CreateFrame("EditBox", nil, frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(400)
	editBox:SetHeight(270)
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
	self.editBox = editBox
	
	scrollArea:SetScrollChild(editBox)
	
	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
end

local options
function mod:GetOptions()
	options = options or {
		guildNotes = {
			order=100,
			type = "toggle",
			name = L["Show copy icon"],
			desc = L["Toggle the copy icon on the chat frame."],
			get = function()
				return mod.db.profile.copyIcon
			end,
			set = function(info, v)
				mod.db.profile.copyIcon = v
				mod:HideCopyButton(v)
			end,
		},
	}
	return options
end

function mod:Decorate(frame)
	local button = self:MakeCopyButton(frame)
	local tab = _G["ChatFrame" .. frame:GetID()]
	self:HookScript(tab, "OnShow")
	self:HookScript(tab, "OnHide")
	tab.copyButton = button
	if self.db.profile.copyIcon then
		tab.copyButton:Show()
	end
end
function mod:OnEnable()
	Chatter:AddMenuHook(self, "Menu")
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		self:MakeCopyButton(cf)
	end
	for index,f in ipairs(self.TempChatFrames) do
		local cf = _G[f]
		self:MakeCopyButton(cf)
	end
	for i = 1, #buttons do
		local p = buttons[i]:GetParent()
		local tab = _G["ChatFrame" .. p:GetID()]
		self:HookScript(tab, "OnShow")
		self:HookScript(tab, "OnHide")
		tab.copyButton = buttons[i]
		if self.db.profile.copyIcon then
			tab.copyButton:Show()
		else
			tab.copyButton:Hide()
		end
	end
end

function mod:OnDisable()
	Chatter:RemoveMenuHook(self)
	for i = 1, #buttons do
		buttons[i]:Hide()
	end
end

function mod:HideCopyButton(val)
	if not val then
		for i = 1, #buttons do
			buttons[i]:Hide()
		end
	else
		for i = 1, #buttons do
			buttons[i]:Show()
		end
	end
end

function mod:MakeCopyButton(frame)
	for index,cb in ipairs(buttons) do
		if cb:GetParent() == frame then
			return nil
		end
	end
	local button = CreateFrame("Button", nil, frame)
	button:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, -5)
	button:SetHeight(10)
	button:SetWidth(10)
	button:SetNormalTexture(tex)
	button:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]])
	button:SetScript("OnClick", function() mod:Copy(frame) end)
	button:SetScript("OnEnter", function(self)
		self:SetHeight(28)
		self:SetWidth(28)
		GameTooltip:SetOwner(self)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Copy text from this frame."])
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		button:SetHeight(10)
		button:SetWidth(10)
		GameTooltip:Hide()
	end)
	button:Hide()
	tinsert(buttons, button)
	return button
end

local menuButtons = {}
function mod:Menu(chatTab, button)
	local frame = _G["ChatFrame" .. chatTab:GetID()]
	
	local info = menuButtons[chatTab:GetID()]
	if not info then
		info = {}
		info.text = L["Copy Text"]
		info.func = function() mod:Copy(frame) end
		info.notCheckable = 1;
		menuButtons[chatTab:GetID()] = info
	end
	return info
end

function mod:Copy(frame)
	local _, size = frame:GetFont()
	FCF_SetChatWindowFontSize(frame, frame, 0.01)
	local lineCt = self:GetLines(frame:GetRegions())
	local text = table_concat(lines, "\n", 1, lineCt)
	FCF_SetChatWindowFontSize(frame, frame, size)
	self.frame:Show()
	self.editBox:SetText(text)
	self.editBox:HighlightText(0)
end

local function fixName(misc, id, moreMisc, fakeName, tag, colon)
	local _, charName, _, _, _, _, _, englishClass = BNGetToonInfo(id)
	return charName..colon
end

function mod:GetLines(...)
	local ct = 1
	wipe(lines)
	for i = select("#", ...), 1, -1 do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			local linez = tostring(region:GetText())
			lines[ct] = gsub(linez, "(|HBNplayer:%S-|k:)(%d-)(:%S-|h)(%S-)(|?h?)(:)", fixName)
			lines[ct] = gsub(lines[ct], "(|TInterface(.*)|t)", "")
			ct = ct + 1
		end
	end
	return ct - 1
end


function mod:OnShow(cft)
	local cfn = cft:GetName():match("ChatFrame%d")
	if cfn and _G[cfn]:IsVisible() and self.db.profile.copyIcon then
		cft.copyButton:Show()
	end
end

function mod:OnHide(cft)
	local cfn = cft:GetName():match("ChatFrame%d")
	if cfn and _G[cfn]:IsVisible() then
		cft.copyButton:Hide()
	end
end

function mod:Info()
	return L["Lets you copy text out of your chat frames."]
end
