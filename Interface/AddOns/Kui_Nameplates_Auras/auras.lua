--[[
-- Kui_Nameplates_Auras
-- By Kesava at curse.com
-- All rights reserved

   Auras module for Kui_Nameplates core layout.
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local whitelist = LibStub('KuiSpellList-1.0').GetImportantSpells(select(2, UnitClass("player")))
local kui = LibStub('Kui-1.0')
local mod = addon:NewModule('Auras', 'AceEvent-3.0')

local GetTime, floor, ceil = GetTime, floor, ceil

-- combat log events to listen to for fading auras
local auraEvents = {
--	['SPELL_DISPEL'] = true,
	['SPELL_AURA_REMOVED'] = true,
	['SPELL_AURA_BROKEN'] = true,
	['SPELL_AURA_BROKEN_SPELL'] = true,
}

local function ArrangeButtons(self)
	local pv, pc
	self.visible = 0
	
	for k,b in ipairs(self.buttons) do
		if b:IsShown() then
			self.visible = self.visible + 1
			
			b:ClearAllPoints()
			
			if pv then
				if (self.visible-1) % 5 == 0 then
					-- start of row
					b:SetPoint('BOTTOMLEFT', pc, 'TOPLEFT', 0, 1)
					pc = b
				else
					-- subsequent button in a row
					b:SetPoint('LEFT', pv, 'RIGHT', 1, 0)
				end
			else
				-- first button
				b:SetPoint('BOTTOMLEFT')
				pc = b
			end
			
			pv = b
		end
	end

	if self.visible == 0 then
		self:Hide()
	else
		self:Show()
	end
end

local function OnAuraUpdate(self, elapsed)
	self.elapsed = self.elapsed - elapsed

	if self.elapsed <= 0 then
		local timeLeft = floor(self.expirationTime - GetTime())
		
		if mod.db.profile.display.timerThreshold > -1 and
		   timeLeft > mod.db.profile.display.timerThreshold
		then
			self.time:Hide()
		else
			local timeLeftS = (timeLeft > 60 and
			                   ceil(timeLeft/60)..'m' or
			                   timeLeft)

			if timeLeft <= 5 then
				-- red text
				self.time:SetTextColor(1,0,0)
			elseif timeLeft <= 20 then
				-- yellow text
				self.time:SetTextColor(1,1,0)
			else
				-- white text
				self.time:SetTextColor(1,1,1)
			end
			
			self.time:SetText(timeLeftS)
			self.time:Show()
		end
		
		if timeLeft < 0 then
			self.time:SetText('0')
		end
		
		self.elapsed = .5
	end
end

local function OnAuraShow(self)
	local parent = self:GetParent()
	parent:ArrangeButtons()
end

local function OnAuraHide(self)
	local parent = self:GetParent()

	if parent.spellIds[self.spellId] == self then
		parent.spellIds[self.spellId] = nil
	end

	self.time:Hide()
	self.spellId = nil

	parent:ArrangeButtons()
end

local function GetAuraButton(self, spellId, icon, count, duration, expirationTime)
	local button

	if self.spellIds[spellId] then
		-- use this spell's current button...
		button = self.spellIds[spellId]
	elseif self.visible ~= #self.buttons then
		-- .. or reuse a hidden button...
		for k,b in pairs(self.buttons) do
			if not b:IsShown() then
				button = b
				break
			end
		end
	end
	
	if not button then
		-- ... or create a new button
		button = CreateFrame('Frame', nil, self)
		button:Hide()
		
		button.icon = button:CreateTexture(nil, 'ARTWORK') 
		
		button.time = self.frame:CreateFontString(button, {
			size = 'large', outline = 'OUTLINE' })
		button.time:SetJustifyH('LEFT')
		button.time:SetPoint('TOPLEFT', -2, 4)
		button.time:Hide()
		
		button.count = self.frame:CreateFontString(button, {
			size = 'name', outline = 'OUTLINE'})
		button.count:SetJustifyH('RIGHT')
		button.count:SetPoint('BOTTOMRIGHT', 2, -2)
		button.count:Hide()

		button:SetHeight(addon.sizes.frame.auraHeight)
		button:SetWidth(addon.sizes.frame.auraWidth)
		button:SetBackdrop({ bgFile = kui.m.t.solid })
		button:SetBackdropColor(0,0,0)

		button.icon:SetPoint('TOPLEFT', 1, -1)
		button.icon:SetPoint('BOTTOMRIGHT', -1, 1)
		
		button.icon:SetTexCoord(.1, .9, .2, .8)
		
		tinsert(self.buttons, button)
		
		button:SetScript('OnHide', OnAuraHide)
		button:SetScript('OnShow', OnAuraShow)
	end
	
	button.icon:SetTexture(icon)

	if count > 1 then
		button.count:SetText(count)
		button.count:Show()
	else
		button.count:Hide()
	end

	if duration == 0 then
		-- hide time on timeless auras
		button:SetScript('OnUpdate', nil)
		button.time:Hide()
	else
		button:SetScript('OnUpdate', OnAuraUpdate)
	end

	button.duration = duration
	button.expirationTime = expirationTime
	button.spellId = spellId
	button.elapsed = 0
	
	self.spellIds[spellId] = button

	return button
end
----------------------------------------------------------------------- hooks --
function mod:Create(msg, frame)
	frame.auras = CreateFrame('Frame', nil, frame.parent)
	frame.auras.frame = frame
	
	frame.auras:SetPoint('BOTTOMLEFT', frame.health, 'BOTTOMLEFT',
		3, addon.sizes.frame.aurasOffset)
	frame.auras:SetPoint('BOTTOMRIGHT', frame.health, 'TOPRIGHT', -3, 0)
	
	frame.auras:SetHeight(50)
	frame.auras:Hide()

	frame.auras.visible = 0
	frame.auras.buttons = {}
	frame.auras.spellIds = {}
	frame.auras.GetAuraButton = GetAuraButton
	frame.auras.ArrangeButtons = ArrangeButtons

	frame.auras:SetScript('OnHide', function(self)
		for k,b in pairs(self.buttons) do
			b:Hide()
		end

		self.visible = 0
	end)
end

function mod:Hide(msg, frame)
	if frame.auras then
		frame.auras:Hide()
	end
end

-------------------------------------------------------------- event handlers --
function mod:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local castTime, event, _, guid, name, _, _, targetGUID, targetName = ...
	if not guid then return end
	if not auraEvents[event] then return end
	if guid ~= UnitGUID('player') then return end

	--print(event..' from '..name..' on '..targetName)

	-- fetch the subject's nameplate
	local f = addon:GetNameplate(targetGUID, targetName)
	if not f or not f.auras then return end

	--print('(frame for guid: '..targetGUID..')')

	local spId = select(12, ...)

	if f.auras.spellIds[spId] then
		f.auras.spellIds[spId]:Hide()
	end
end

function mod:PLAYER_TARGET_CHANGED()
	self:UNIT_AURA('UNIT_AURA', 'target')
end

function mod:UPDATE_MOUSEOVER_UNIT()
	self:UNIT_AURA('UNIT_AURA', 'mouseover')
end

function mod:UNIT_AURA(event, unit)
	-- select the unit's nameplate	
	--unit = 'target' -- DEBUG
	local frame = addon:GetNameplate(UnitGUID(unit), nil)
	if not frame or not frame.auras or frame.trivial then return end
	--unit = 'player' -- DEBUG

	local filter = 'PLAYER '
	if UnitIsFriend(unit, 'player') then
		filter = filter..'HELPFUL'
	else
		filter = filter..'HARMFUL'
	end

	-- hide currently displayed auras
	local _,button
	for _,button in pairs(frame.auras.spellIds) do
		button:Hide()
	end

	for i = 0,40 do
		local name, _, icon, count, _, duration, expirationTime, _, _, _, spellId = UnitAura(unit, i, filter)

		if name and
		   (not self.db.profile.behav.useWhitelist or
		    whitelist[spellId]) and
		   (duration >= self.db.profile.display.lengthMin) and
		   (self.db.profile.display.lengthMax == -1 or (
		   	duration > 0 and
		    duration <= self.db.profile.display.lengthMax))
		then
			local button = frame.auras:GetAuraButton(spellId, icon, count, duration, expirationTime)
			frame.auras:Show()
			button:Show()
		end
	end
end

---------------------------------------------------- Post db change functions --
mod.configChangedFuncs = { runOnce = {} }
mod.configChangedFuncs.runOnce.enabled = function(val)
	if val then
		mod:Enable()
	else
		mod:Disable()
	end
end

---------------------------------------------------- initialisation functions --
function mod:GetOptions()
	return {
		enabled = {
			name = 'Show my auras',
			desc = 'Display auras cast by you on the current target\'s nameplate',
			type = 'toggle',
			order = 1,
			disabled = false
		},
		display = {
			name = 'Display',
			type = 'group',
			inline = true,
			disabled = function()
				return not self.db.profile.enabled
			end,
			args = {
				timerThreshold = {
					name = 'Timer threshold (s)',
					desc = 'Timer text will be displayed on auras when their remaining length is less than or equal to this value. -1 to always display timer.',
					type = 'range',
					order = 10,
					min = -1,
					softMax = 180,
					step = 1
				},
				lengthMin = {
					name = 'Effect length minimum (s)',
					desc = 'Auras with a total duration of less than this value will never be displayed. 0 to disable.',
					type = 'range',
					order = 20,
					min = 0,
					softMax = 60,
					step = 1
				},
				lengthMax = {
					name = 'Effect length maximum (s)',
					desc = 'Auras with a total duration greater than this value will never be displayed. -1 to disable.',
					type = 'range',
					order = 30,
					min = -1,
					softMax= 1800,
					step = 1
				},

			}
		},
		behav = {
			name = 'Behaviour',
			type = 'group',
			inline = true,
			disabled = function()
				return not self.db.profile.enabled
			end,
			args = {
				useWhitelist = {
					name = 'Use whitelist',
					desc = 'Only display spells which your class needs to keep track of for PVP or an effective DPS rotation. Most passive effects are excluded.',
					type = 'toggle',
					order = 0,
				},
			}
		}
	}
end

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, {
		profile = {
			enabled = false,
			display = {
				timerThreshold = 20,
				lengthMin = 0,
				lengthMax = -1,
			},
			behav = {
				useWhitelist = true,
			}
		}
	})

	addon:RegisterSize('frame', 'auraHeight', 14)
	addon:RegisterSize('frame', 'auraWidth', 20)
	addon:RegisterSize('frame', 'aurasOffset', 20)

	addon:InitModuleOptions(self)
	mod:SetEnabledState(self.db.profile.enabled)
end

function mod:OnEnable()
	self:RegisterMessage('KuiNameplates_PostCreate', 'Create')
	self:RegisterMessage('KuiNameplates_PostHide', 'Hide')

	self:RegisterEvent('UNIT_AURA')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

	local _, frame
	for _, frame in pairs(addon.frameList) do
		if not frame.auras then
			self:Create(nil, frame.kui)
		end
	end
end

function mod:OnDisable()
	self:UnregisterEvent('UNIT_AURA')
	self:UnregisterEvent('PLAYER_TARGET_CHANGED')
	self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

	local _, frame
	for _, frame in pairs(addon.frameList) do
		self:Hide(nil, frame.kui)
	end
end
