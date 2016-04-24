local parent, ns = ...
local oUF = ns.oUF

local function UNIT_POWER(self, event, unit, powerType)
	if(self.unit ~= unit or (event == 'UNIT_POWER_FREQUENT' and powerType ~= 'BURNING_EMBERS')) then
		return
	end

	local element = self.BurningEmbers

	local total = UnitPower('player', SPELL_POWER_BURNING_EMBERS, true)
	local max = UnitPowerMax('player', SPELL_POWER_BURNING_EMBERS, true)

	local cur = total
	for index = 1, 4 do
		element[index]:SetValue(cur)
		cur = cur - 10
	end
end

local function UPDATE_VISIBILITY(self)
	local element = self.BurningEmbers

	local showElement
	if(IsPlayerSpell(WARLOCK_BURNING_EMBERS)) then
		showElement = true
	end

	if(UnitHasVehicleUI('player')) then
		showElement = false
	end

	if(showElement) then
		for index = 1, 4 do
			element[index]:Show()
		end
	else
		for index = 1, 4 do
			element[index]:Hide()
		end
	end
end

local function Update(self, ...)
	UPDATE_VISIBILITY(self, ...)
	UNIT_POWER(self, ...)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.BurningEmbers
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		for index = 1, 4 do
			element[index]:SetMinMaxValues(0, 10)
		end

		self:RegisterEvent('SPELLS_CHANGED', UPDATE_VISIBILITY, true)
		self:RegisterEvent('UNIT_POWER_FREQUENT', UNIT_POWER)

		return true
	end
end

local function Disable(self)
	if(self.BurningEmbers) then
		self:UnregisterEvent('SPELLS_CHANGED', UPDATE_VISIBILITY)
		self:UnregisterEvent('UNIT_POWER_FREQUENT', UNIT_POWER)
	end
end

oUF:AddElement('BurningEmbers', Update, Enable, Disable)
