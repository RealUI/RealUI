local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb, ndbc

local _
local MODNAME = "ConfigBar"
local ConfigBar = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local Animations = nibRealUI:GetModule("Animations")

local Bar
local Elements = {}
local ElementButtons = {}

local ElementHeight = 56
local ElementPadding = 14

local TexturesRed = {}

-- On MouseDown
function ConfigBar_Element_OnMouseDown(self)
	if ConfigBar.hiding then return end
	local element = self.element

	-- Close/Open Element Window
	if element.active then
		element.active = false
		if element.window and element.window:IsVisible() then self.info.closeFunc(true) end
		return
	else
		element.active = true
		self.highlight:Show()
	end

	-- Close any other open element windows
	for k, eB in ipairs(ElementButtons) do
		if eB.element.window and (eB.element.window:IsVisible() and (eB ~= self)) then
			eB.info.closeFunc()
			eB.element.active = false
			eB.highlight:Hide()
		end
	end

	-- Open active element's window
	local hasOpened = self.info.openFunc()
	if hasOpened then
		if self.info.window then
			if self.info.window.position == "BUTTONLEFT" then
				element.window:SetPoint("TOPLEFT", self, "BOTTOMLEFT", self.info.window.xOfs - 1, 0)
			else
				element.window:SetPoint("TOP", Bar, "BOTTOM", self.info.window.xOfs, 0)
			end
		end
	else
		self.element.active = false
	end

	-- Hook for when the window closes
	-- element.window:HookScript("OnHide", function(self)
		-- if (ActiveHighlight ~= self) and ActiveButton then ActiveButton.highlight:Hide() end
		-- ActiveButton = nil
		-- if not self.element.highlighted then self.element.button.highlight:Hide() end
		-- self.element.active = false
	-- end)

end

-- On Enter
local function Element_OnEnter(self)
	self.element.highlighted = true
	self.highlight:Show()
end

-- On Leave
local function Element_OnLeave(self)
	self.element.highlighted = false
	if not self.element.active then self.highlight:Hide() end
end

-- Create individual element
function ConfigBar:CreateElement(element, order)
	local info = element.info
	local NewElement = CreateFrame("Frame", nil, Bar)
		NewElement.element = element
		element.button = NewElement
		NewElement.info = info
		NewElement:EnableMouse()

	-- Position
	if order == 1 then
		NewElement:SetPoint("LEFT", Bar, "LEFT")
	else
		NewElement:SetPoint("LEFT", ElementButtons[order - 1], "RIGHT")
	end

	-- Icon
	NewElement.icon = NewElement:CreateTexture(nil, "OVERLAY")
		NewElement.icon:SetPoint("TOP", NewElement, "TOP", (info.iconXoffset or 0), -7)
		NewElement.icon:SetSize(32, 32)
		NewElement.icon:SetTexture(info.icon)
		if info.isDisabled then
			NewElement.icon:SetVertexColor(0.5, 0.5, 0.5)
		else
			if info.iconRed then
				tinsert(TexturesRed, NewElement.icon)
				NewElement.icon:SetVertexColor(unpack(nibRealUI.media.colors.red))
			else
				NewElement.icon:SetVertexColor(0.9, 0.9, 0.9)
			end
		end

	-- Label
	NewElement.label = NewElement:CreateFontString()
		NewElement.label:SetPoint("BOTTOM", NewElement, "BOTTOM", 0.5, 7.5)
		NewElement.label:SetFont(nibRealUI.font.standard, 10)
		NewElement.label:SetText(info.label)
		if info.isDisabled then
			NewElement.label:SetTextColor(0.5, 0.5, 0.5)
		end

	-- Highlight
	NewElement.highlight = NewElement:CreateTexture(nil, "BACKGROUND")
		NewElement.highlight:SetAllPoints()
		NewElement.highlight:SetTexture(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], 0.2)
		NewElement.highlight:Hide()

	-- Size
	local width = max(ceil((NewElement.label:GetWidth() + (ElementPadding * 2)) / 2) * 2, 50)
	NewElement:SetSize(width, ElementHeight)

	-- Enter/Leave/MouseDown
	if not info.isDisabled then
		NewElement:SetScript("OnEnter", Element_OnEnter)
		NewElement:SetScript("OnLeave", Element_OnLeave)
		NewElement:SetScript("OnMouseDown", ConfigBar_Element_OnMouseDown)
	end

	return NewElement
end

-- Create Config Bar
function ConfigBar:CreateBar()
	Bar = CreateFrame("Frame", "RealUIConfigBar", UIParent)
	Bar:SetPoint("TOP", UIParent, "TOP", 0, 0)
	Bar:SetFrameStrata("HIGH")
	Bar:SetFrameLevel("1")

	local widthTotal = 0
	for k, element in ipairs(Elements) do
		ElementButtons[k] = self:CreateElement(element, k)
		widthTotal = widthTotal + ElementButtons[k]:GetWidth()
	end
	Bar:SetSize(widthTotal, ElementHeight)

	local barBG = nibRealUI:CreateBDFrame(Bar, nil, true)
	barBG:SetBackdropColor(unpack(nibRealUI.media.window))
	tinsert(REALUI_WINDOW_FRAMES, barBG)

	Bar:Hide()
end

-- Register Element
function ConfigBar:RegisterElement(element, order)
	Elements[order] = element
end

function ConfigBar:PLAYER_REGEN_DISABLED()
	self:Toggle(false, true)
end

-- Show/Hide Config Bar
function ConfigBar:Toggle(val, skipSlide)
	if InCombatLockdown() then
		nibRealUI:Notification(L["Combat Lockdown"], true, L["Cannot open RealUI Configuration while in combat."], nil, [[Interface\AddOns\nibRealUI\Media\Icons\Notification_Alert]])
		return
	end
	if val then
		-- Watch for combat so we can hide window
		self:RegisterEvent("PLAYER_REGEN_DISABLED")

		if not Bar then self:CreateBar() end
		for k, eB in ipairs(ElementButtons) do
			eB.highlight:Hide()
			eB.element.active = false
		end
		if not Bar:IsVisible() then
			Bar:Show()
			if not skipSlide then
				Bar:ClearAllPoints()
				Bar:SetPoint("BOTTOM", UIParent, "TOP", 0, 0)
				Bar.finish_hide = false
				Animations:Slide(Bar, "DOWN", Bar:GetHeight() + 1, 120)
			else
				Bar:ClearAllPoints()
				Bar:SetPoint("TOP", UIParent, "TOP", 0, 0)
			end
		end
	else
		-- Close any open element windows
		for k, eB in ipairs(ElementButtons) do
			if eB.element.window then
				eB.info.closeFunc()
			end
			eB.highlight:Hide()
			eB.element.active = false
		end
		if Bar:IsVisible() then
			if not skipSlide then
				Bar.finish_hide = true
				Animations:Slide(Bar, "UP", Bar:GetHeight(), 120)
			else
				Bar:Hide()
			end
		end
		RealUIGridConfiguring = false
	end
end
function RealUIConfigBarToggle(val, skipSlide)
	ConfigBar:Toggle(val, skipSlide)
end

function ConfigBar:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self.closeElement = {
		info = {
			label = CLOSE,
			icon = [[Interface\AddOns\nibRealUI\Media\Config\Close]],
			iconRed = true,
			openFunc = function() ConfigBar:Toggle(false) end,
			closeFunc = function() end,
		}
	}
	ConfigBar:RegisterElement(self.closeElement, #Elements + 1)

	-- ConfigBar:Toggle(true)
end

----------
function ConfigBar:UpdateGlobalColors()
	for k, tex in pairs(TexturesRed) do
		tex:SetVertexColor(unpack(nibRealUI.media.colors.red))
	end
end

function ConfigBar:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function nibRealUI:ShowConfigBar()
	ConfigBar:Toggle(true)
end