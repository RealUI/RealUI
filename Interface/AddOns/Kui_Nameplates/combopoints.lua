--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('ComboPoints', 'AceEvent-3.0')

mod.uiName = 'Combo points'

local function ComboPointsUpdate(self)
	if self.points and self.points > 0 then
		local i
		
		for i = 1,5 do
			if i <= self.points then
				self[i]:SetAlpha(1)
			else
				self[i]:SetAlpha(.3)
			end

			self[i]:SetVertexColor(unpack(self.colour))
		end

		self:Show()
	elseif self:IsShown() then
		self:Hide()
	end
end
-------------------------------------------------------------- Event handlers --
function mod:UNIT_COMBO_POINTS(event, unit, ...)
	-- only works for player > target
	if unit ~= 'player' then return end

	local guid, name = UnitGUID('target'), UnitName('target')
	local f = addon:GetNameplate(guid, name)
	
	if f and f.combopoints then
		local points = GetComboPoints('player', 'target')

		if points == 5 then
			f.combopoints.colour = { 1, 1, .1 }
			f.combopoints.glow:SetVertexColor(1, 1, .1, .6)
		else
			f.combopoints.colour = { .79, .55, .18 }
			f.combopoints.glow:SetVertexColor(0, 0, 0, .3)
		end

		f.combopoints.points = points
		f.combopoints:Update()

		if points > 0 then
			-- clear points on other frames
			local _, frame
			for _, frame in pairs(addon.frameList) do
				if frame.kui.combopoints and frame.kui ~= f then
					self:HideComboPoints(nil, frame.kui)
				end
			end
		end
	end
end
---------------------------------------------------------------------- Target --
function mod:OnFrameTarget(msg, frame)
	self:UNIT_COMBO_POINTS(nil, 'player')
end
---------------------------------------------------------------------- Create --
function mod:CreateComboPoints(msg, frame)
	-- create combo point icons
	frame.combopoints = CreateFrame('Frame', nil, frame.overlay)
	frame.combopoints:Hide()

	frame.combopoints.glow = frame.combopoints:CreateTexture(nil, 'ARTWORK')
	frame.combopoints.glow:SetDrawLayer('ARTWORK', 1) -- above overlay
	frame.combopoints.glow:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\combopoints-glow')
	frame.combopoints.glow:SetTexCoord(0, .5625, 0, .5625)
	frame.combopoints.glow:SetSize(addon.sizes.tex.cpGlowWidth,
		addon.sizes.tex.cpGlowHeight)

	local i, pcp
	for i=0,4 do
		local cp = frame.combopoints:CreateTexture(nil, 'ARTWORK')
		cp:SetDrawLayer('ARTWORK', 2)
		cp:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\combopoint-round')
		--cp:SetTexCoord(0, .375, 0, .375)
		cp:SetSize(addon.sizes.tex.combopoints, addon.sizes.tex.combopoints)

		if i == 0 then
			cp:SetPoint('BOTTOM', frame.overlay, 'BOTTOM',
				-(addon.sizes.tex.combopoints-1)*2, -3)
		else
			cp:SetPoint('LEFT', pcp, 'RIGHT', -1, 0)
		end

		tinsert(frame.combopoints, i+1, cp)
		pcp = cp -- store previous icon
	end

	frame.combopoints.glow:SetPoint('CENTER', frame.combopoints[3])

	frame.combopoints.Update = ComboPointsUpdate
end
------------------------------------------------------------------------ Hide --
function mod:HideComboPoints(msg, frame)
	if frame.combopoints then
		frame.combopoints.points = nil
		frame.combopoints:Update()
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

-------------------------------------------------------------------- Register --
function mod:GetOptions()
	return {
		enabled = {
			name = 'Show combo points',
			desc = 'Show combo points on the target',
			type = 'toggle',
			order = 0
		},
		scale = {
			name = 'Icon scale',
			desc = 'The scale of the combo point icons and glow',
			type = 'range',
			order = 5,
			min = 0.1,
			softMin = 0.5,
			softMax = 2
		}
	}
end

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, {
		profile = {
			enabled = true,
			scale   = 1,
		}
	})

	addon:RegisterSize('tex', 'combopoints', 4.5 * self.db.profile.scale)
	addon:RegisterSize('tex', 'cpGlowWidth', 30 * self.db.profile.scale)
	addon:RegisterSize('tex', 'cpGlowHeight', 15 * self.db.profile.scale)
	
	addon:InitModuleOptions(self)
	mod:SetEnabledState(self.db.profile.enabled)
end

function mod:OnEnable()
	self:RegisterMessage('KuiNameplates_PostCreate', 'CreateComboPoints')
	self:RegisterMessage('KuiNameplates_PostHide', 'HideComboPoints')
	self:RegisterMessage('KuiNameplates_PostTarget', 'OnFrameTarget')

	self:RegisterEvent('UNIT_COMBO_POINTS')

	local _, frame
	for _, frame in pairs(addon.frameList) do
		if not frame.combopoints then
			self:CreateComboPoints(nil, frame.kui)
		end
	end
end

function mod:OnDisable()
	self:UnregisterEvent('UNIT_COMBO_POINTS')

	local _, frame
	for _, frame in pairs(addon.frameList) do
		self:HideComboPoints(nil, frame.kui)
	end
end
