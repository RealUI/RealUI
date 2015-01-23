--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
-- register module
local StanceBarMod = Bartender4:NewModule("StanceBar", "AceEvent-3.0")

-- fetch upvalues
local ButtonBar = Bartender4.ButtonBar.prototype

local _G = _G
local format, setmetatable, min, select = string.format, setmetatable, min, select

-- GLOBALS: CreateFrame, InCombatLockdown, ClearOverrideBindings, GetBindingKey, GetBindingText, SetOverrideBindingClick, SetBinding
-- GLOBALS: GetNumShapeshiftForms, GetShapeshiftFormInfo, GetShapeshiftFormCooldown, CooldownFrame_SetTimer

-- create prototype information
local StanceBar = setmetatable({}, {__index = ButtonBar})
local StanceButtonPrototype = CreateFrame("CheckButton")
local StanceButton_MT = {__index = StanceButtonPrototype}

local LBF = LibStub("LibButtonFacade", true)
local Masque = LibStub("Masque", true)
local KeyBound = LibStub("LibKeyBound-1.0")

local defaults = { profile = Bartender4:Merge({
	enabled = true,
	position = {
		scale = 1.5,
	},
	hidehotkey = true,
}, Bartender4.ButtonBar.defaults) }

function StanceBarMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("StanceBar", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function StanceBarMod:OnEnable()
	if not self.bar then
		self.bar = setmetatable(Bartender4.ButtonBar:Create("StanceBar", self.db.profile, L["Stance Bar"]), {__index = StanceBar})
		self.bar:SetScript("OnEvent", StanceBar.OnEvent)
	end
	self.bar:Enable()

	self:ToggleOptions()
	self.bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.bar:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self.bar:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	self.bar:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	self.bar:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
	self.bar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	self.bar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
	self.bar:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
	self.bar:RegisterEvent("UPDATE_POSSESS_BAR")
	self.bar:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
	self.bar:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings")
	self:ReassignBindings()
	self:ApplyConfig()
end

StanceBarMod.button_count = 10

function StanceBarMod:ApplyConfig()
	if not self:IsEnabled() then return end
	self.bar:ApplyConfig(self.db.profile)

	if GetNumShapeshiftForms() == 0 then
		self:Disable()
	end
end

function StanceBarMod:ReassignBindings()
	if InCombatLockdown() then return end
	if not self.bar or not self.bar.buttons then return end
	ClearOverrideBindings(self.bar)
	for i = 1, min(#self.bar.buttons, 10) do
		local button, real_button = ("SHAPESHIFTBUTTON%d"):format(i), ("BT4StanceButton%d"):format(i)
		for k=1, select('#', GetBindingKey(button)) do
			local key = select(k, GetBindingKey(button))
			SetOverrideBindingClick(self.bar, false, key, real_button)
		end
	end
end

function StanceButtonPrototype:Update()
	if not self:IsShown() then return end
	local id = self:GetID()
	local texture, name, isActive, isCastable = GetShapeshiftFormInfo(id)

	self.icon:SetTexture(texture)

	-- manage cooldowns
	if texture then
		self.cooldown:Show()
	else
		self.cooldown:Hide()
	end
	local start, duration, enable = GetShapeshiftFormCooldown(id)
	CooldownFrame_SetTimer(self.cooldown, start, duration, enable)

	if isActive then
		self:SetChecked(true)
	else
		self:SetChecked(false)
	end

	if isCastable then
		self.icon:SetVertexColor(1.0, 1.0, 1.0)
	else
		self.icon:SetVertexColor(0.4, 0.4, 0.4)
	end

	self:UpdateHotkeys()
end

function StanceButtonPrototype:UpdateHotkeys()
	local key = self:GetHotkey() or ""
	local hotkey = self.hotkey

	if key == "" or self.parent.config.hidehotkey then
		hotkey:Hide()
	else
		hotkey:SetText(key)
		hotkey:Show()
	end
end

function StanceButtonPrototype:GetHotkey()
	local key = GetBindingKey(format("SHAPESHIFTBUTTON%d", self:GetID())) or GetBindingKey("CLICK "..self:GetName()..":LeftButton")
	return key and KeyBound:ToShortKey(key)
end

function StanceButtonPrototype:GetBindings()
	local keys, binding = ""

	binding = format("SHAPESHIFTBUTTON%d", self:GetID())
	for i = 1, select('#', GetBindingKey(binding)) do
		local hotKey = select(i, GetBindingKey(binding))
		if keys ~= "" then
			keys = keys .. ', '
		end
		keys = keys .. GetBindingText(hotKey,'KEY_')
	end

	binding = "CLICK "..self:GetName()..":LeftButton"
	for i = 1, select('#', GetBindingKey(binding)) do
		local hotKey = select(i, GetBindingKey(binding))
		if keys ~= "" then
			keys = keys .. ', '
		end
		keys = keys.. GetBindingText(hotKey,'KEY_')
	end

	return keys
end

function StanceButtonPrototype:SetKey(key)
	SetBinding(key, format("SHAPESHIFTBUTTON%d", self:GetID()))
end

function StanceButtonPrototype:ClearBindings()
	local binding = format("SHAPESHIFTBUTTON%d", self:GetID())
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end

	binding = "CLICK "..self:GetName()..":LeftButton"
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end
end

local actionTmpl = "Stance Button %d (%s)"
function StanceButtonPrototype:GetActionName()
	local id = self:GetID()
	return format(actionTmpl, id, select(2, GetShapeshiftFormInfo(id)))
end


function StanceButtonPrototype:ClearSetPoint(...)
	self:ClearAllPoints()
	self:SetPoint(...)
end

local function onEnter(self, ...)
	if not (Bartender4.db.profile.tooltip == "nocombat" and InCombatLockdown()) and Bartender4.db.profile.tooltip ~= "disabled" then
		self:OnEnter(...)
	end
	KeyBound:Set(self)
end

function StanceBarMod:CreateStanceButton(id)
	local button = setmetatable(CreateFrame("CheckButton", "BT4StanceButton" .. id, self.bar, "StanceButtonTemplate"), StanceButton_MT)
	button.parent = self.bar
	button:SetID(id)
	button.icon = _G[button:GetName() .. "Icon"]
	button.cooldown = _G[button:GetName() .. "Cooldown"]
	button.hotkey = _G[button:GetName() .. "HotKey"]
	button.normalTexture = button:GetNormalTexture()
	button.normalTexture:SetTexture("")
--	button.checkedTexture = button:GetCheckedTexture()
--	button.checkedTexture:SetTexture("")

	button.OnEnter = button:GetScript("OnEnter")
	button:SetScript("OnEnter", onEnter)

	if Masque then
		local group = self.bar.MasqueGroup
		button.MasqueButtonData = {
			Button = button
		}
		group:AddButton(button, button.MasqueButtonData)
	elseif LBF then
		local group = self.bar.LBFGroup
		button.LBFButtonData = {
			Button = button
		}
		group:AddButton(button, button.LBFButtonData)
	end

	return button
end

function StanceBar:ApplyConfig(config)
	ButtonBar.ApplyConfig(self, config)

	if not self.config.position.x then
		self:ClearSetPoint("CENTER", -55, -10)
		self:SavePosition()
	end

	self:UpdateStanceButtons()
	self:ForAll("ApplyStyle", self.config.style)
end

StanceBar.button_width = 30
StanceBar.button_height = 30
function StanceBar:UpdateStanceButtons()
	local buttons = self.buttons or {}

	local num_stances = GetNumShapeshiftForms()

	local updateBindings = (num_stances > #buttons)

	for i = (#buttons+1), num_stances do
		buttons[i] = StanceBarMod:CreateStanceButton(i)
	end

	for i = 1, num_stances do
		buttons[i]:Show()
		buttons[i]:Update()
	end

	for i = num_stances+1, #buttons do
		buttons[i]:Hide()
	end

	StanceBarMod.button_count = num_stances
	if StanceBarMod.optionobject then
		StanceBarMod.optionobject.table.general.args.rows.max = num_stances
	end

	self.buttons = buttons

	self:UpdateButtonLayout()
	if updateBindings then
		StanceBarMod:ReassignBindings()
	end
	self.disabled = (GetNumShapeshiftForms() == 0) and true or nil

	-- need to re-set clickthrough after creating new buttons
	self:SetClickThrough()
end

function StanceBar:OnEvent(event, ...)
	if event == "UPDATE_SHAPESHIFT_COOLDOWN" then
		self:ForAll("Update")
	elseif event == "PLAYER_REGEN_ENABLED" then
		if self.updateStateOnCombatLeave and not InCombatLockdown() then
			self.updateStateOnCombatLeave = nil
			self:UpdateStanceButtons()
		end
	else
		if InCombatLockdown() then
			self.updateStateOnCombatLeave = true
			self:ForAll("Update")
		else
			self:UpdateStanceButtons()
		end
	end
end
