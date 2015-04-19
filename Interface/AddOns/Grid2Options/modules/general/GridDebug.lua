--[[
	Debug options
--]]

local L = Grid2Options.L

function Grid2Options:AddModuleDebugMenu(name, module)
	local option= {}
   	option[name]= {
		type = "toggle",
		order = 3,
		name = name,
		desc = L["Toggle debugging for %s."]:format(name),
		get = function () return module.db.profile.debug end,
		set = function ()
			local v = not module.db.profile.debug
			module.db.profile.debug = v or nil
			module.debugging = v
		end,
	}
	Grid2Options:AddGeneralOptions( "Debug", nil,  option )
end

Grid2Options:AddModuleDebugMenu("Grid2", Grid2 )
for name, module in Grid2:IterateModules() do
	Grid2Options:AddModuleDebugMenu(name, module)
end

