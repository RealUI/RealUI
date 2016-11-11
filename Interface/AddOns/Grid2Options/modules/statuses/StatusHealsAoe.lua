local AOEM = Grid2:GetModule("Grid2AoeHeals")

local L = Grid2Options.L
local select = select
local GetSpellInfo = GetSpellInfo

local classHeals = {
	SHAMAN  = { 1064, 73921, 127944 },     	  -- Chain Heal, Healing Rain, Tide Totem
	PRIEST  = { 34861, 23455, 88686, 64843 }, -- Circle of Healing, Holy Nova, Holy Word: Sanctuary, Divine Himn
	PALADIN = { 85222, 114871, 119952 },   	  -- Light of Dawn, Holy Prism, Arcing Light(Light Hammer's effect)
	DRUID   = { 81269, 740 }, 			      -- Wild Mushroom, Tranquility
	MONK    = { 124040, 130654, 124101, 132463, 115310 }, -- Chi Torpedo, Chi Burst, Zen Sphere: Detonate, Chi Wave, Revival
	ZRAID    = {
				740,    -- Druid Traquility
				127944, -- Shaman Tide Totem
				64843,  -- Priest Divine Himn
				115310, -- Monk Revival
	},
}

-- Misc util functions
local function GetSpellID(name, defaultSpells)
	if tonumber(name) then
		return tonumber(name)
	end
	for _,spells in next, defaultSpells do
		for _,spell in next, spells do
			local spellName = GetSpellInfo(spell)
			if spellName == name then
				return spell
			end
		end
	end	
	local id = 0
	local texture = select(3, GetSpellInfo(name))
	for i=150000, 1, -1  do
		if GetSpellInfo(i) == name then
			id = i
			local _,_,tex = GetSpellInfo(i)
			if tex == texture then
				return i
			end
		end
	end
	return id
end

-- MakeStatusOutgoingOptions()
local MakeStatusOutgoingOptions
do
	-- local prev_spells = {}
	function MakeStatusOutgoingOptions(self, status, options)
		self:MakeStatusColorOptions(status, options)
		options.showIfMine = {
			type = "toggle",
			order = 30,
			name = L["Show if mine"],
			desc = L["Show my spells only."],
			get = function () return status.dbx.mine == true end,
			set = function (_, v) 
				status.dbx.mine = v or nil
				status:UpdateDB() 
			end,
		}
		options.showIfNotMine = {
			type = "toggle",
			order = 35,
			name = L["Show if not mine"],
			desc = L["Show others spells only."],
			get = function () return status.dbx.mine == false end,
			set = function (_, v) 
				if v then
					status.dbx.mine = false
				else
					status.dbx.mine = nil
				end	
				status:UpdateDB() 
			end,
		}
		options.spacer = { type = "header", order = 39, name = "" }
		options.activeTime = {
			name = L["Active time"],
			desc = L["Show the status for the specified number of seconds."],
			order = 40,
			type = "range", min = 0.2, max = 5, step = 0.1,
			get = function()
				return status.dbx.activeTime or 2
			end,
			set = function( _, v )
				status.dbx.activeTime = v
				status:UpdateDB()
			end,
		}
		options.auras = {
			type = "input",
			order = 50,
			width = "full",
			name = L["Spells"],
			desc = L["You can type spell IDs or spell names."],
			multiline= 10,
			get = function()
					local auras = {}
					for _,spell in pairs(status.dbx.spellList) do
						local name = GetSpellInfo(spell)
						if name then 
							auras[#auras+1] = name
						end
					end
					return table.concat( auras, "\n" )
			end,
			set = function(_, v) 
				wipe(status.dbx.spellList)
				local auras = { strsplit("\n,", v) }
				for i,v in pairs(auras) do
					local aura = strtrim(v)
					if #aura>0 then
						local spellID = tonumber(aura)
						if spellID then 
							spellID = GetSpellInfo(spellID) and spellID or 0
						else
							spellID = GetSpellID(aura, classHeals)
						end
						if spellID > 0 then
							table.insert(status.dbx.spellList, spellID)
						end
					end
				end	
				status:UpdateDB()
			end,
		}
		options.addSpells = {
			type = "select",
			order = 45,
			name = L["Add heal spells"],
			desc = L[""],
			get = function () end,
			set = function(_,v)
				for className,spells in pairs(classHeals) do
					if v==className or (v=="" and className~="ZRAID") then
						for _,spellID in pairs(spells) do
							table.insert(status.dbx.spellList, spellID)
						end
					end	
				end
				status:UpdateDB()
			end,
			values = function()
				local list = {}
				for class in pairs(classHeals) do
					list[class] = LOCALIZED_CLASS_NAMES_MALE[class] or L["Raid Cooldowns"]
				end
				list[""] = L["All Classes"]
				return list
			end
		}
		self:MakeStatusDeleteOptions(status, options)
	end
end

-- MakeCategoryOptions() 
local function MakeCategoryOptions() 
	local NewStatusName, NewClassHeals 
	return {
		newOutgoingStatusName = {
			type = "input",
			order = 50,
			name = L["Type New Status Name"],
			desc = L["Type the name of the new AOE-Heals status to create."],
			get = function() return NewStatusName end,
			set = function(_, v) 
				NewStatusName = strtrim(v)
			end,	
			validate = function(_,v)
				v = strtrim(v)
				return (v == "" or Grid2:DbGetValue( "statuses", "aoe-" .. v )) and L["Invalid status name or already in use."] or true
			end,
		},
		addSpells = {
			type = "select",
			order = 51,
			name = L["Select heal spells"],
			desc = L[""],
			get = function () 
				return NewClassHeals or '~'
			end,
			set = function(_,v)
				NewClassHeals = v
			end,
			values = function()
				local list = {}
				for class in pairs(classHeals) do
					list[class] = LOCALIZED_CLASS_NAMES_MALE[class] or L["Raid Cooldowns"]
				end
				list[""]  = L["All Classes"]
				list["~"] = L["None"]
				return list
			end
		},
		createOutgoingStatus = {
			type = "execute",
			order = 55,
			width = "half",
			name = L["Create"],
			func = function() 
				local baseKey = "aoe-" .. NewStatusName
				local spellList = {}
				if not Grid2:DbGetValue("statuses",baseKey) then
					for className,spells in pairs(classHeals) do
						if NewClassHeals==className or (NewClassHeals=="" and className~="ZRAID") then
							for _,spellID in pairs(spells) do
								table.insert(spellList, spellID)
							end
						end	
					end
					local dbx = { type = "aoe-heals", spellList = spellList, activeTime =2, color1 = {r=0, g=0.8, b=1, a=1} }
					Grid2:DbSetValue("statuses", baseKey, dbx) 
					local status = Grid2.setupFunc[dbx.type](baseKey, dbx)
					Grid2Options:MakeStatusOptions(status)
				end
				NewStatusName = nil
				NewClassHeals = nil
			end,
			disabled = function() return NewStatusName==nil end,
		},
	} 
end

Grid2Options:RegisterStatusCategory("aoe-heal", { name = L["AOE Heals"], icon = "Interface\\Icons\\Spell_holy_holynova", options = MakeCategoryOptions() } )
Grid2Options:RegisterStatusOptions("aoe-heals", "aoe-heal", MakeStatusOutgoingOptions, { groupOrder= 50, titleIcon ="Interface\\Icons\\Spell_holy_holybolt" } )
