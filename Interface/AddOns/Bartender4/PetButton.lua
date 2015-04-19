--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
--[[
	Pet Button template
]]
local _, Bartender4 = ...
local PetButtonPrototype = CreateFrame("CheckButton")
local PetButton_MT = {__index = PetButtonPrototype}

local LBF = LibStub("LibButtonFacade", true)
local Masque = LibStub("Masque", true)
local KeyBound = LibStub("LibKeyBound-1.0")

-- upvalues
local _G = _G
local format, select, setmetatable = string.format, select, setmetatable

-- GLOBALS: InCombatLockdown, CreateFrame, SetDesaturation, IsModifiedClick, GetBindingKey, GetBindingText, SetBinding
-- GLOBALS: AutoCastShine_AutoCastStop, AutoCastShine_AutoCastStart, CooldownFrame_SetTimer
-- GLOBALS: PickupPetAction, , GetPetActionInfo, GetPetActionsUsable, GetPetActionCooldown

local function onEnter(self, ...)
	if not (Bartender4.db.profile.tooltip == "nocombat" and InCombatLockdown()) and Bartender4.db.profile.tooltip ~= "disabled" then
		self:OnEnter(...)
	end
	KeyBound:Set(self)
end

local function onDragStart(self)
	if InCombatLockdown() then return end
	if not Bartender4.db.profile.buttonlock or IsModifiedClick("PICKUPACTION") then
		self:SetChecked(false)
		PickupPetAction(self.id)
		self:Update()
	end
end

local function onReceiveDrag(self)
	if InCombatLockdown() then return end
	self:SetChecked(false)
	PickupPetAction(self.id)
	self:Update()
end

Bartender4.PetButton = {}
Bartender4.PetButton.prototype = PetButtonPrototype
function Bartender4.PetButton:Create(id, parent)
	local name = "BT4PetButton" .. id
	local button = setmetatable(CreateFrame("CheckButton", name, parent, "PetActionButtonTemplate"), PetButton_MT)
	button.showgrid = 0
	button.id = id
	button.parent = parent

	button:SetFrameStrata("MEDIUM")
	button:SetID(id)

	button:UnregisterAllEvents()
	button:SetScript("OnEvent", nil)

	button.OnEnter = button:GetScript("OnEnter")
	button:SetScript("OnEnter", onEnter)

	button:SetScript("OnDragStart", onDragStart)
	button:SetScript("OnReceiveDrag", onReceiveDrag)

	button.flash = _G[name .. "Flash"]
	button.cooldown = _G[name .. "Cooldown"]
	button.icon = _G[name .. "Icon"]
	button.autocastable = _G[name .. "AutoCastable"]
	button.autocast = _G[name .. "Shine"]
	button.hotkey = _G[name .. "HotKey"]

	button:SetNormalTexture("")
	local oldNT = button:GetNormalTexture()
	oldNT:Hide()

	button.normalTexture = button:CreateTexture(("%sBTNT"):format(name))
	button.normalTexture:SetAllPoints(oldNT)

	button.pushedTexture = button:GetPushedTexture()
	button.highlightTexture = button:GetHighlightTexture()

	button.textureCache = {}
	button.textureCache.pushed = button.pushedTexture:GetTexture()
	button.textureCache.highlight = button.highlightTexture:GetTexture()

	if Masque then
		local group = parent.MasqueGroup
		button.MasqueButtonData = {
			Button = button,
			Normal = button.normalTexture,
		}
		group:AddButton(button, button.MasqueButtonData)
	elseif LBF then
		local group = parent.LBFGroup
		button.LBFButtonData = {
			Button = button,
			Normal = button.normalTexture,
		}
		group:AddButton(button, button.LBFButtonData)
	end
	return button
end

function PetButtonPrototype:Update()
	local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(self.id)

	if not isToken then
		self.icon:SetTexture(texture)
		self.tooltipName = name;
	else
		self.icon:SetTexture(_G[texture])
		self.tooltipName = _G[name]
	end

	self.isToken = isToken
	self.tooltipSubtext = subtext
	self:SetChecked(isActive)
	if autoCastAllowed and not autoCastEnabled then
		self.autocastable:Show()
		AutoCastShine_AutoCastStop(self.autocast)
	elseif autoCastAllowed then
		self.autocastable:Hide()
		AutoCastShine_AutoCastStart(self.autocast)
	else
		self.autocastable:Hide()
		AutoCastShine_AutoCastStop(self.autocast)
	end

	if texture then
		if GetPetActionsUsable() then
			SetDesaturation(self.icon, nil)
		else
			SetDesaturation(self.icon, 1)
		end
		self.icon:Show()
		self.normalTexture:SetTexture("Interface\\Buttons\\UI-Quickslot2")
		self.normalTexture:SetTexCoord(0, 0, 0, 0)
		self:ShowButton()
		self.normalTexture:Show()
		if self.overlay then
			self.overlay:Show()
		end
	else
		self.icon:Hide()
		self.normalTexture:SetTexture("Interface\\Buttons\\UI-Quickslot")
		self.normalTexture:SetTexCoord(-0.1, 1.1, -0.1, 1.12)
		self:HideButton()
		if self.showgrid == 0 and not self.parent.config.showgrid then
			self.normalTexture:Hide()
			if self.overlay then
				self.overlay:Hide()
			end
		end
	end
	self:UpdateCooldown()
	self:UpdateHotkeys()
end

function PetButtonPrototype:UpdateHotkeys()
	local key = self:GetHotkey() or ""
	local hotkey = self.hotkey

	if key == "" or self.parent.config.hidehotkey then
		hotkey:Hide()
	else
		hotkey:SetText(key)
		hotkey:Show()
	end
end

function PetButtonPrototype:ShowButton()
	self.pushedTexture:SetTexture(self.textureCache.pushed)
	self.highlightTexture:SetTexture(self.textureCache.highlight)
	local backdrop, gloss
	if Masque then
		backdrop, gloss = Masque:GetBackdrop(self), Masque:GetGloss(self)
	elseif LBF then
		backdrop, gloss = LBF:GetBackdropLayer(self), LBF:GetGlossLayer(self)
	end
	-- Toggle backdrop/gloss
	if backdrop then
		backdrop:Show()
	end
	if gloss then
		gloss:Show()
	end
	self:SetAlpha(1.0)
end

function PetButtonPrototype:HideButton()
	self.textureCache.pushed = self.pushedTexture:GetTexture()
	self.textureCache.highlight = self.highlightTexture:GetTexture()

	self.pushedTexture:SetTexture("")
	self.highlightTexture:SetTexture("")
	local backdrop, gloss
	if Masque then
		backdrop, gloss = Masque:GetBackdrop(self), Masque:GetGloss(self)
	elseif LBF then
		backdrop, gloss = LBF:GetBackdropLayer(self), LBF:GetGlossLayer(self)
	end
	-- Toggle backdrop/gloss
	if backdrop then
		backdrop:Hide()
	end
	if gloss then
		gloss:Hide()
	end
	if self.showgrid == 0 and not self.parent.config.showgrid then
		self:SetAlpha(0.0)
	end
end

function PetButtonPrototype:ShowGrid()
	self.showgrid = self.showgrid + 1
	self.normalTexture:Show()
	self:SetAlpha(1.0)
end

function PetButtonPrototype:HideGrid()
	if self.showgrid > 0 then self.showgrid = self.showgrid - 1 end
	if self.showgrid == 0  and not (GetPetActionInfo(self.id)) and not self.parent.config.showgrid then
		self.normalTexture:Hide()
		self:SetAlpha(0.0)
	end
end

function PetButtonPrototype:UpdateCooldown()
	local start, duration, enable = GetPetActionCooldown(self.id)
	CooldownFrame_SetTimer(self.cooldown, start, duration, enable)
end

function PetButtonPrototype:GetHotkey()
	local key = GetBindingKey(format("BONUSACTIONBUTTON%d", self.id)) or GetBindingKey("CLICK "..self:GetName()..":LeftButton")
	return key and KeyBound:ToShortKey(key)
end

function PetButtonPrototype:GetBindings()
	local keys, binding = ""

	binding = format("BONUSACTIONBUTTON%d", self.id)
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

function PetButtonPrototype:SetKey(key)
	SetBinding(key, format("BONUSACTIONBUTTON%d", self.id))
end

function PetButtonPrototype:ClearBindings()
	local binding = format("BONUSACTIONBUTTON%d", self:GetID())
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end

	binding = "CLICK "..self:GetName()..":LeftButton"
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end
end

local actionTmpl = "Pet Button %d (%s)"
function PetButtonPrototype:GetActionName()
	local id = self.id
	local name, _, _, token = GetPetActionInfo(id)
	if token and name then name = _G[name] end
	return format(actionTmpl, id, name or "empty")
end

function PetButtonPrototype:ClearSetPoint(...)
	self:ClearAllPoints()
	self:SetPoint(...)
end
