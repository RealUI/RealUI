local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("boss-shields", "misc", function(self, status, options, optionParams)
	local lines = {}
	for map,shields in pairs(status.ShieldsDB) do
		for spell,value in pairs(shields) do
			lines[#lines+1] = string.format("%s - %s  (%.0fK)", map, GetSpellInfo(spell) or "", value/1000 )
		end	
	end
	table.sort(lines)
	self:MakeStatusColorOptions(status, options, optionParams )
	options.header1 = {	type = "header", order = 100, name = L["Supported debuffs"] }
	options.shields = {
		type     = "description",
		order    = 110,
		fontSize = "medium",
		name     = table.concat(lines,"\n")
	}
	options.header2 = {	type = "header", order = 120, name = "" }
end, {
	color1 = L["Normal"], 
	colorDesc1 = L["Normal shield color"],
	color2 = L["Medium"], 
	colorDesc2 = L["Medium shield color"],
	color3 = L["Low"],    
	colorDesc3 = L["Low shield color"],
	title = L["display remaining amount of heal absorb shields"],
	titleIcon = "Interface\\Icons\\spell_fire_ragnaros_lavabolt",
})