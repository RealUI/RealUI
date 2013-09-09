-- This Implementation "Basic" contains only the absolute minimum of things
-- to make a normal cargBags Implementation working correctly
-- It's not a pretty layout (just a bunch of items!), but should nevertheless be fully functional

local Implementation = cargBags:NewImplementation("Basic")
local Container = Implementation:GetContainerClass()
Implementation:RegisterBlizzard()

function Implementation:OnInit()
	Container:New("Main"):SetPoint("CENTER")
end

function Container:OnContentsChanged()
	self:SortButtons("bagSlot")
	local cols = math.ceil((#self.buttons)^0.5) -- Just to let columns and rows be equal
	local width, height = self:LayoutButtons("grid", cols, 5)
	self:SetSize(width, height)
end

