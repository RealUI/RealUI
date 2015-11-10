--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('ComboPoints', addon.Prototype, 'AceEvent-3.0')
local _

mod.uiName = 'Combo points'

local ANTICIPATION_NAME -- the localised buff name
local ANTICIPATION_IS_KNOWN
local ANTICIPATION_TALENT_ID = 114015
local ANTICIPATION_ID = 115189
local ICON_SPACING = -1

local anticipationWasActive

local colours = {
	full         = {  1,   1,  .1     },
	partial      = { .79, .55, .18    },
	anti         = {  1,  .3,  .3     },
	glowFull     = {  1,   1,  .1, .6 },
	glowPartial  = {  0,   0,   0, .3 },
	glowAnti     = {  1,  .1,  .1, .8 }
}
local sizes = {}
local defaultSizes = {}

local function ComboPointsUpdate(self)
	if self.points and self.points > 0 then
		if self.points == 5 then
			self.colour = colours.full
			self.glowColour = colours.glowFull
		else
			self.colour = colours.partial
			self.glowColour = colours.glowPartial
		end

		local i
		for i = 1,5 do
			if i <= self.points then
				self[i]:SetAlpha(1)
			else
				self[i]:SetAlpha(.3)
			end

			if ANTICIPATION_IS_KNOWN and (self.stacks and i <= self.stacks) then
				-- colour icons for anticipation
				self[i]:SetVertexColor(unpack(colours.anti))
				self.glows[i]:SetVertexColor(unpack(colours.glowAnti))
			else
				self[i]:SetVertexColor(unpack(self.colour))
				self.glows[i]:SetVertexColor(unpack(self.glowColour))
			end
		end

		self:Show()
	elseif self:IsShown() then
		self:Hide()
	end
end
-------------------------------------------------------------- Event handlers --
function mod:PLAYER_TALENT_UPDATE()
	ANTICIPATION_IS_KNOWN = IsSpellKnown(ANTICIPATION_TALENT_ID)

	if ANTICIPATION_IS_KNOWN then
		self:RegisterEvent('UNIT_AURA')
	else
		self:UnregisterEvent('UNIT_AURA')
	end
end
function mod:UNIT_AURA(event,unit)
	if unit ~= 'player' then return end
	local anticipationIsActive = UnitBuff(unit,ANTICIPATION_NAME)

	if anticipationIsActive or anticipationWasActive then
		-- force another combo point update after the buff update
		-- this is necessary for 2 reasons:
		-- 1. the buff has a time limit
		-- 2. the buff doesn't update until after UNIT_COMBO_POINTS is fired
		self:UNIT_COMBO_POINTS('UNIT_COMBO_POINTS',unit)
	end

	anticipationWasActive = anticipationIsActive
end
function mod:UNIT_COMBO_POINTS(event,unit)
	-- only works for player > target
	if unit ~= 'player' then return end

	local f = addon:GetUnitPlate('target')

	if f and f.combopoints then
		local points = GetComboPoints('player', 'target')
		local stacks

		if ANTICIPATION_IS_KNOWN then
			-- get anticipation stacks
			stacks = select(4,UnitBuff(unit,ANTICIPATION_NAME))
		end

		f.combopoints.stacks = stacks
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
function mod:OnFrameTarget(msg, frame, is_target)
    if is_target then
        self:UNIT_COMBO_POINTS(nil, 'player')
    end
end
---------------------------------------------------------------------- Create --
function mod:CreateComboPoints(msg, frame)
	-- create combo point icons
	frame.combopoints = CreateFrame('Frame', nil, frame.overlay)
	frame.combopoints.glows = {}
	frame.combopoints:Hide()

	local i, pcp
	for i=0,4 do
		-- create individual combo point icons
        -- size and position of first icon is set in ScaleComboPoints
		local cp = frame.combopoints:CreateTexture(nil, 'ARTWORK')
		cp:SetDrawLayer('ARTWORK', 2)
		cp:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\combopoint-round')

		if i > 0 then
			cp:SetPoint('LEFT', pcp, 'RIGHT', ICON_SPACING, 0)
		end

		tinsert(frame.combopoints, i+1, cp)
		pcp = cp

		-- and their glows
		local glow = frame.combopoints:CreateTexture(nil, 'ARTWORK')

		glow:SetDrawLayer('ARTWORK',1)
		glow:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\combopoint-glow')
		glow:SetPoint('CENTER',cp)

		tinsert(frame.combopoints.glows, i+1, glow)
	end

    self:ScaleComboPoints(frame)
	frame.combopoints.Update = ComboPointsUpdate
end
-- update/set frame sizes ------------------------------------------------------
function mod:ScaleComboPoints(frame)
    local i,cp
    for i,cp in ipairs(frame.combopoints) do
		cp:SetSize(sizes.combopoints, sizes.combopoints)

        if i == 1 then
            -- place first icon to offset others to center
			cp:SetPoint('BOTTOM', frame.overlay, 'BOTTOM',
				-(sizes.combopoints+ICON_SPACING)*2, -3)
        end

        frame.combopoints.glows[i]:SetSize(sizes.combopoints + 8, sizes.combopoints + 8)
    end
end
------------------------------------------------------------------------ Hide --
function mod:HideComboPoints(msg, frame)
	if frame.combopoints then
		frame.combopoints.points = nil
		frame.combopoints:Update()
	end
end
---------------------------------------------------- Post db change functions --
mod:AddConfigChanged('enabled', function(v)
    mod:Toggle(v)
end)
mod:AddConfigChanged('scale',
    function(v)
        sizes.combopoints = defaultSizes.combopoints * v
    end,
    function(f,v)
        mod:ScaleComboPoints(f)
    end
)
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

	-- fetch the localised name of anticipation
	ANTICIPATION_NAME = GetSpellInfo(ANTICIPATION_ID) or 'Anticipation'

    defaultSizes.combopoints = 6.5

    -- scale size with user option
    self.configChangedFuncs.scale.ro(self.db.profile.scale)

	addon:InitModuleOptions(self)
	mod:SetEnabledState(self.db.profile.enabled)
end

function mod:OnEnable()
	self:RegisterMessage('KuiNameplates_PostCreate', 'CreateComboPoints')
	self:RegisterMessage('KuiNameplates_PostHide', 'HideComboPoints')
	self:RegisterMessage('KuiNameplates_PostTarget', 'OnFrameTarget')

	self:RegisterEvent('UNIT_COMBO_POINTS')
	self:RegisterEvent('PLAYER_TALENT_UPDATE')

	self:PLAYER_TALENT_UPDATE()

	local _, frame
	for _, frame in pairs(addon.frameList) do
		if not frame.combopoints then
			self:CreateComboPoints(nil, frame.kui)
		end
	end
end

function mod:OnDisable()
	self:UnregisterEvent('UNIT_COMBO_POINTS')
	self:UnregisterEvent('UNIT_AURA')
	self:UnregisterEvent('PLAYER_TALENT_UPDATE')

	local _, frame
	for _, frame in pairs(addon.frameList) do
		self:HideComboPoints(nil, frame.kui)
	end
end
