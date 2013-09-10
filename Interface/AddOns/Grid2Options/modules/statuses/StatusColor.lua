local L = Grid2Options.L

local function MakeClassColorOption(status, options, type, translation)
	if not options.colors then
		options.colors = { type = "group", inline = true, name = L["Unit Colors"], args = {}, }
	end
	options.colors.args[type] = {
		type = "color",
		name = (L["%s Color"]):format(translation),
		get = function ()
			local c = status.dbx.colors[type] or status.dbx.colors[translation] or {r=1,g=1,b=1,a=1}
			return c.r, c.g, c.b, c.a
		end,
		set = function (_, r, g, b, a)
			local colorKey = status.dbx.colors[type] and type or translation
			local c = status.dbx.colors[colorKey] 
			c.r, c.g, c.b, c.a = r, g, b, a
			status:UpdateAllIndicators()
		end,
	}
end

local function MakeCharmedToggleOption(status, options)
	options.hostile = {
		type  = "toggle",
		name  = L["Color Charmed Unit"],
		desc  = L["Color Units that are charmed."],
		width = "full",
		order = 105,
		tristate = false,
		get = function () return status.dbx.colorHostile end,
		set = function (_, v) status.dbx.colorHostile = v or nil end,
	}
end

Grid2Options:RegisterStatusOptions("classcolor", "color", function(self, status, options, optionParams)
	MakeCharmedToggleOption(status,options)
	MakeClassColorOption(status, options, "HOSTILE",      L["Charmed unit Color"] )
	MakeClassColorOption(status, options, "UNKNOWN_UNIT", L["Default unit Color"] )
	MakeClassColorOption(status, options, "UNKNOWN_PET",  L["Default pet Color"] )
	for _, class in ipairs{"Beast", "Demon", "Humanoid", "Elemental"} do
		MakeClassColorOption(status, options, class, L[class] )
	end
	for class, translation in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		MakeClassColorOption(status, options, class, translation)
	end
end)

Grid2Options:RegisterStatusOptions("creaturecolor", "color", function(self, status, options, optionParams)
	MakeCharmedToggleOption(status,options)
	MakeClassColorOption(status, options, "HOSTILE",      L["Charmed unit Color"] )
	MakeClassColorOption(status, options, "UNKNOWN_UNIT", L["Default unit Color"] )
	for _, class in ipairs{"Beast", "Demon", "Humanoid", "Elemental"} do
		MakeClassColorOption(status, options, class, L[class])
	end
end)

Grid2Options:RegisterStatusOptions("friendcolor", "color", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	MakeCharmedToggleOption(status,options)
end, {
	color1= L["Player color"],
	color2= L["Pet color"],
	color3= L["Charmed unit Color"],
	width = "full",
})

Grid2Options:RegisterStatusOptions("color", "color", function(self, status, options, optionPararms)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusDeleteOptions(status, options, optionParams)
end)

Grid2Options:RegisterStatusOptions( "charmed", "combat", Grid2Options.MakeStatusColorOptions, {
	titleIcon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
} )