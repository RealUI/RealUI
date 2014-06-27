--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('TankMode', 'AceEvent-3.0')

mod.uiName = 'Threat'

function mod:OnEnable()
	self:Toggle()
end
--------------------------------------------------------- tank mode functions --
function mod:Update()
	if self.db.profile.enabled == 1 then
		-- smart - judge by spec
		local spec = GetSpecialization()
		local role = spec and GetSpecializationRole(spec) or nil

		if role == 'TANK' then
			addon.TankMode = true
		else
			addon.TankMode = false
		end
	else
		addon.TankMode = (self.db.profile.enabled == 3)
	end
end

function mod:Toggle()
	if self.db.profile.enabled == 1 then
		-- smart tank mode, listen for spec changes
		self:RegisterEvent('PLAYER_TALENT_UPDATE', 'Update')
		self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'Update')
	else
		self:UnregisterEvent('PLAYER_TALENT_UPDATE')
		self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED')
	end

	self:Update()
end

---------------------------------------------------- Post db change functions --
mod.configChangedFuncs = { runOnce = {} }
mod.configChangedFuncs.runOnce.enabled = function()
	mod:Toggle()
end
-------------------------------------------------------------------- Register --
function mod:GetOptions()
	return {
		enabled = {
			name = 'Tank mode',
			desc = 'Change the colour of a plate\'s health bar and border when you have threat on its unit.\n\nSelecting "Smart" (default) will automatically enable or disable tank mode based on your current specialisation\'s role.',
			type = 'select',
			values = { 'Smart', 'Disabled', 'Enabled' },
			order = 0
		},
		barcolour = {
			name = 'Bar colour',
			desc = 'The bar colour to use when you have threat',
			type = 'color',
			order = 1
		},
		midcolour = {
			name = 'Transitional colour',
			desc = 'The bar colour to use when you are losing or gaining threat.',
			type = 'color',
			order = 1
		},
		glowcolour = {
			name = 'Glow colour',
			desc = 'The glow (border) colour to use when you have threat',
			type = 'color',
			hasAlpha = true,
			order = 2
		},
	}
end

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, {
		profile = {
			enabled = 1,
			barcolour = { .2, .9, .1 },
			midcolour = { 1, .5, 0 },
			glowcolour = { 1, 0, 0, 1 }
		}
	})

	addon:InitModuleOptions(self)
	mod:SetEnabledState(true)
end

function mod:OnEnable()
	addon.TankModule = self
	self:Toggle()
end
