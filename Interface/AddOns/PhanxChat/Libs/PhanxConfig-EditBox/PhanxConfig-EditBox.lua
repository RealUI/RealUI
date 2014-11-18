--[[--------------------------------------------------------------------
	PhanxConfig-EditBox
	Simple text input widget generator.
	Requires LibStub.
	https://github.com/phanx/PhanxConfigWidgets
	Copyright (c) 2009-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local MINOR_VERSION = tonumber(string.match("$Revision: 185 $", "%d+"))

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-EditBox", MINOR_VERSION)
if not lib then return end

lib.editboxes = lib.editboxes or { }

if not PhanxConfigEditBoxInsertLink then
	hooksecurefunc("ChatEdit_InsertLink", function(...) return _G.PhanxConfigEditBoxInsertLink(...) end)
end

function PhanxConfigEditBoxInsertLink(link)
	for i = 1, #lib.editboxes do
		local editbox = lib.editboxes[ i ]
		if editbox and editbox:IsVisible() and editbox:HasFocus() then
			editbox:Insert(link)
			return true
		end
	end
end

------------------------------------------------------------------------

local scripts = {}

function scripts:OnEnter()
	local container = self:GetParent()
	if container.tooltipText then
		GameTooltip:SetOwner(container, "ANCHOR_RIGHT")
		GameTooltip:SetText(container.tooltipText, nil, nil, nil, nil, true)
	end
end
function scripts:OnLeave()
	GameTooltip:Hide()
end

function scripts:OnEditFocusGained() -- print("OnEditFocusGained")
	CloseDropDownMenus()
	local text = self:GetText()
	self.currText, self.origText = text, text
	self:HighlightText()
end
function scripts:OnEditFocusLost() -- print("OnEditFocusLost")
	self:SetText(self.origText or "")
	self.currText, self.origText = nil, nil
end

function scripts:OnTextChanged(userInput)
	if not self:HasFocus() then return end

	local text = self:GetText()
	if text:len() == 0 then text = nil end -- experimental

	local parent = self:GetParent()
	local callback = parent.OnTextChanged
	if callback and text ~= self.currText then
		callback(parent, text, userInput)
		self.currText = text
	end
end

function scripts:OnEnterPressed() -- print("OnEnterPressed")
	local text = self:GetText()
	if strlen(text) == 0 then text = nil end -- experimental
	self:ClearFocus()

	local parent = self:GetParent()
	local callback = parent.OnValueChanged
	if callback then
		callback(parent, text)
	end
end

function scripts:OnEscapePressed() -- print("OnEscapePressed")
	self:ClearFocus()
end

function scripts:OnReceiveDrag()
	local type, arg1, arg2, arg3, arg4 = GetCursorInfo()
	if type == "item" then
		-- itemID, itemLink
		if self:IsNumeric() then
			self:SetNumber(arg1)
		else
			local name = GetItemInfo(arg1)
			self:SetText(name)
		end
	elseif type == "macro" then
		-- index
		if self:IsNumeric() then
			self:SetNumber(arg1)
		else
			local name = GetMacroInfo(arg1)
			self:SetText(name)
		end
	elseif type == "merchant" then
		-- index
		if self:IsNumeric() then
			local link = GetMerchantItemLink(arg1)
			local id = strmatch(link, "|Hitem:(%d+)")
			if id then
				self:SetNumber(id)
			else
				self:SetText("")
			end
		else
			local name = GetMerchantItemInfo(arg1)
			self:SetText(name)
		end
	elseif type == "money" then
		-- amount in copper
		if self:IsNumeric() then
			self:SetNumber(arg1)
		else
			local mode = ENABLE_COLORBLIND_MODE
			ENABLE_COLORBLIND_MODE = "1"
			local text = GetMoneyString(arg1)
			ENABLE_COLORBLIND_MODE = mode
			self:SetText(text)
		end
	elseif type == "spell" then
		-- index, bookType, spellID
		if self:IsNumeric() then
			self:SetNumber(arg3)
		else
			local name = GetSpellInfo(arg3)
			self:SetText(name)
		end
	end
	scripts.OnEnterPressed(self)
	ClearCursor()
end

------------------------------------------------------------------------

local methods = {}

function methods:GetText()
	return self.editbox:GetText()
end
function methods:SetText(text)
	return self.editbox:SetText(text)
end
function methods:SetFormattedText(text, ...)
	return self.editbox:SetText(format(text, ...))
end

function methods:GetLabel()
	return self.labelText:GetText()
end
function methods:SetLabel(text)
	self.labelText:SetText(text)
end

function methods:GetTooltip()
	return self.tooltipText
end
function methods:SetTooltip(text)
	self.tooltipText = text
end

------------------------------------------------------------------------

function lib:New(parent, name, tooltipText, maxLetters)
	assert(type(parent) == "table" and parent.CreateFontString, "PhanxConfig-EditBox: Parent is not a valid frame!")
	if type(name) ~= "string" then name = nil end
	if type(tooltipText) ~= "string" then tooltipText = nil end
	if type(maxLetters) ~= "number" then maxLetters = nil end

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(144)
	frame:SetHeight(42)

--	local bg = frame:CreateTexture(nil, "BACKGROUND")
--	bg:SetAllPoints(frame)
--	bg:SetTexture(0, 0, 0)
--	frame.bg = bg

	local editbox = CreateFrame("EditBox", nil, frame)
	editbox:SetPoint("LEFT", 5, 0)
	editbox:SetPoint("RIGHT", -5, 0)
	editbox:SetHeight(19)
	editbox:EnableMouse(true)
	editbox:SetAltArrowKeyMode(false)
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetMaxLetters(maxLetters or 256)
	editbox:SetTextInsets(0, 0, 3, 3)
	lib.editboxes[ #lib.editboxes + 1 ] = editbox
	frame.editbox = editbox

	editbox.bgLeft = editbox:CreateTexture(nil, "BACKGROUND")
	editbox.bgLeft:SetPoint("TOPLEFT", 0, 0)
	editbox.bgLeft:SetPoint("BOTTOMLEFT", 0, 0)
	editbox.bgLeft:SetSize(8, 20)
	editbox.bgLeft:SetTexture([[Interface\Common\Common-Input-Border]])
	editbox.bgLeft:SetTexCoord(0, 0.0625, 0, 0.625)

	editbox.bgRight = editbox:CreateTexture(nil, "BACKGROUND")
	editbox.bgRight:SetPoint("TOPRIGHT", 0, 0)
	editbox.bgRight:SetPoint("BOTTOMRIGHT", 0, 0)
	editbox.bgRight:SetSize(8, 20)
	editbox.bgRight:SetTexture([[Interface\Common\Common-Input-Border]])
	editbox.bgRight:SetTexCoord(0.9375, 1, 0, 0.625)

	editbox.bgMiddle = editbox:CreateTexture(nil, "BACKGROUND")
	editbox.bgMiddle:SetPoint("TOPLEFT", editbox.bgLeft, "TOPRIGHT")
	editbox.bgMiddle:SetPoint("BOTTOMRIGHT", editbox.bgRight, "BOTTOMLEFT")
	editbox.bgMiddle:SetSize(10, 20)
	editbox.bgMiddle:SetTexture([[Interface\Common\Common-Input-Border]])
	editbox.bgMiddle:SetTexCoord(0.0625, 0.9375, 0, 0.625)

	local label = editbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("BOTTOMLEFT", editbox, "TOPLEFT")
	label:SetPoint("BOTTOMRIGHT", editbox, "TOPRIGHT")
	label:SetJustifyH("LEFT")
	frame.labelText = label

	for name, func in pairs(scripts) do
		editbox:SetScript(name, func) -- NOT on the frame!
	end
	for name, func in pairs(methods) do
		frame[name] = func
	end

	frame.labelText:SetText(name)
	frame.tooltipText = tooltipText

	return frame
end

function lib.CreateEditBox(...) return lib:New(...) end