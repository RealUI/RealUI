-- Lua Globals --
local _G = _G

if _G.select(2, _G.UnitClass("player")) ~= "WARLOCK" then return end

local _, ns = ...
local oUF = ns.oUF

-- Holds the class specific stuff.
local ClassPowerType, RequireSpec = "BURNING_EMBERS", _G.SPEC_WARLOCK_DESTRUCTION
local ClassPowerEnable, ClassPowerDisable

local Update = function(self, event, unit, powerType)
	if(self.unit ~= unit or (event == 'UNIT_POWER_FREQUENT' and powerType ~= ClassPowerType)) then
		return
	end

	local element = self.BurningEmbers

	local curFull, curRaw
	local maxFull, maxRaw
	if(event ~= 'ClassPowerDisable') then
		curRaw = _G.UnitPower('player', _G.SPELL_POWER_BURNING_EMBERS, true)
		maxRaw = _G.UnitPowerMax('player', _G.SPELL_POWER_BURNING_EMBERS, true)
		curFull, maxFull = _G.floor(curRaw/10), _G.floor(maxRaw/10)

		local cur = curRaw
		for index = 1, 4 do
			element[index]:SetValue(cur)
			cur = cur - 10
		end
	end

	--[[ :PostUpdate(curFull, curRaw, maxFull, maxRaw, event)

	 Called after the element has been updated

	 Arguments

	 self          - The BurningEmbers element
	 curFull       - The current amount of full embers
	 curRaw        - The current raw amount of embers
	 maxFull       - The maximum amount of full embers
	 maxRaw        - The maximum raw amount of embers
	 event         - The event, which the update happened for
	]]
	if(element.PostUpdate) then
		return element:PostUpdate(curFull, curRaw, maxFull, maxRaw, event)
	end
end

local Path = function(self, ...)
	return (self.BurningEmbers.Override or Update) (self, ...)
end

local function Visibility(self, event, unit)
	local element = self.BurningEmbers
	local shouldEnable


	if(not _G.UnitHasVehicleUI('player')) then
		if(RequireSpec == _G.GetSpecialization()) then
			shouldEnable = true
		end
	end

	local isEnabled = element.isEnabled
	if(shouldEnable and not isEnabled) then
		ClassPowerEnable(self)
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		ClassPowerDisable(self)
	elseif(shouldEnable and isEnabled) then
		Path(self, event, unit, ClassPowerType)
	end
end

local VisibilityPath = function(self, ...)
	return (self.BurningEmbers.OverrideVisibility or Visibility) (self, ...)
end

local ForceUpdate = function(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

do
	ClassPowerEnable = function(self)
		_G.print("ClassPowerEnable")
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
		Path(self, 'ClassPowerEnable', 'player', ClassPowerType)
		self.BurningEmbers.isEnabled = true
	end

	ClassPowerDisable = function(self)
		_G.print("ClassPowerDisable")
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)

		local element = self.BurningEmbers
		for i = 1, #element do
			element[i]:Hide()
		end

		Path(self, 'ClassPowerDisable', 'player', ClassPowerType)
		self.BurningEmbers.isEnabled = false
	end
end

local Enable = function(self, unit)
	_G.print("Enable")
	if(unit ~= 'player') then return end

	local element = self.BurningEmbers
	if(not element) then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	self:RegisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath, true)

	element.ClassPowerEnable = ClassPowerEnable
	element.ClassPowerDisable = ClassPowerDisable

	for index = 1, #element do
		element[index]:SetMinMaxValues(0, 10)
	end

	return true
end

local Disable = function(self)
	_G.print("Disable")
	local element = self.BurningEmbers
	if(not element) then return end

	ClassPowerDisable(self)
end

oUF:AddElement('BurningEmbers', VisibilityPath, Enable, Disable)
