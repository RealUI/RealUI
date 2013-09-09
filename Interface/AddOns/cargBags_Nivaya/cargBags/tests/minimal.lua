-- This Implementation "Minimal" contains only the absolute minimum of things
-- cargBags would not display anything, because the layout-code is missing,
-- but at least it should not produce any errors.

-- cargBags should nevertheless register it for events, update it and try
-- to find a correct container (even if there are none)

-- The dynamic nature of cargBags should still make it possible to
-- spawn containers and the whole layout later on at runtime

-- :RegisterBlizzard() is not called, so you have to toggle the implementation
-- via cargBags:GetImplementation("Minimal"):Toggle()

local Implementation = cargBags:NewImplementation("Minimal")

function Implementation:OnOpen()
	print("Implementation was opened")
end

function Implementation:OnClose()
	print("Implementation was closed")
end
