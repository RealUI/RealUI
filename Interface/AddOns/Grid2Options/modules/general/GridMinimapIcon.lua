--[[
	General -> Misc Tab -> Hide Raid Frames section
--]]

local L = Grid2Options.L

if Grid2Layout.minimapIcon then
	Grid2Options:AddGeneralOptions( "Misc", "Minimap Icon", {
		showMinimapIcon = {
			type = "toggle",
			name = L["Show Minimap Icon"],
			desc = L["Show Minimap Icon"],
			width = "full",
			order = 119,
			get = function () return not Grid2Layout.db.profile.minimapIcon.hide end,
			set = function (_, v) 
				Grid2Layout.db.profile.minimapIcon.hide = not v 
				if v then
					Grid2Layout.minimapIcon:Show("Grid2")
				else
					Grid2Layout.minimapIcon:Hide("Grid2")
				end
			end,
		},
	})
end
