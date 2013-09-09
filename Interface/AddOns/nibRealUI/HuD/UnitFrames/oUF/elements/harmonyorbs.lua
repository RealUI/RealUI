local parent, ns = ...
local oUF = ns.oUF

local SPELL_POWER_CHI = SPELL_POWER_CHI

local Update = function(self, event, unit)
	if(unit ~= 'player') then return end

	local element = self.Harmony
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local chi = UnitPower(unit, SPELL_POWER_CHI)

	for index = 1, UnitPowerMax(unit, SPELL_POWER_CHI) do
		if(index <= chi) then
			element[index]:Show()
		else
			element[index]:Hide()
		end
	end

	if(element.PostUpdate) then
		return element:PostUpdate(chi)
	end
end

local Path = function(self, ...)
	return (self.Harmony.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local element = self.Harmony
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_DISPLAYPOWER', Path, true)
		self:RegisterEvent("UNIT_POWER_FREQUENT", Path)
		self:RegisterEvent("UNIT_MAXPOWER", Path)

		return true
	end
end

local Disable = function(self)
	local element = self.Harmony
	if(element) then
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
	end
end

oUF:AddElement('Harmony', Path, Enable, Disable)