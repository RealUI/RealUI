local L = Grid2Options.L

local name
local color = {r=1,g=1,b=1,a=1}

Grid2Options:RegisterStatusCategoryOptions( "color", {
	colorName = {
		type = "input",
		order = 10,
		name = L["Name"],
		get = function()
			return name
		end,
		set = function(info,value) 
			name = value:gsub("[ %.\"]", "")
		end
	},
	colorData = {
		type = "color",
		order = 20,
		width = "half",
		name = L["Color"],
		desc = L["Color"],
		hasAlpha = true,
		get = function() 
			return color.r, color.g, color.b, color.a 
		end,
		set = function(info,r,g,b,a) 
			color.r, color.g, color.b, color.a = r, g, b, a 
		end
	},
	colorExecute= {
		type = "execute",
		order = 30,
		name = L["Create Color"],
		desc = L["Create a new status."],
		func = function()
			local baseKey= "color-"..name
			local dbx = {type = "color", color1 = { r = color.r, g = color.g, b = color.b, a = color.a } }
			Grid2.db.profile.statuses[baseKey]= dbx
			local status = Grid2.setupFunc["color"](baseKey, dbx)
			Grid2Options:MakeStatusOptions(status)
			name = ""
		end,
		disabled= function() 
			return (not name) or Grid2.statuses["color-"..name] 
		end
	},
} )