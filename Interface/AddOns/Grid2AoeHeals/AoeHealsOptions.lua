local AOEM = Grid2:GetModule("Grid2AoeHeals")

-- Forward declaration of Grid2Options Locales
local L

local select = select
local GetSpellInfo = GetSpellInfo

local classHeals = {
	SHAMAN  = { 1064, 73921, 127944 },     	  -- Chain Heal, Healing Rain, Tide Totem
	PRIEST  = { 34861, 23455, 88686, 64843 }, -- Circle of Healing, Holy Nova, Holy Word: Sanctuary, Divine Himn
	PALADIN = { 85222, 114871, 119952 },   	  -- Light of Dawn, Holy Prism, Arcing Light(Light Hammer's effect)
	DRUID   = { 81269, 740 }, 			      -- Wild Mushroom, Tranquility
	MONK    = { 124040, 130654, 124101, 132463, 115310 }, -- Chi Torpedo, Chi Burst, Zen Sphere: Detonate, Chi Wave, Revival
	RAID    = {
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
					if v==className or (v=="" and className~="RAID") then
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

-- MakeStatusHighlighterOptions()
local function MakeStatusHighlighterOptions(self, status, options)
	local statuses= { ["Autodetect"] = L["Autodetect"] }
	for name in next, AOEM.hlStatuses do
		statuses[name]= L[ strsub(name,5) ]
	end 
	options.highlightStatus = {
		type  = "select",
		order = 20,
		name  = L["Highlight status"],
		desc  = L["Select the status the Highlighter will use."],
		get   = function () return status.dbx.highlightStatus or "Autodetect" end,
		set   = function (_, v)
			if v == "Autodetect" then v = nil end
			status.dbx.highlightStatus= v  
			status:UpdateDB()	
		end,
		values= statuses,
	}
	options.spacer1 = {
		type = "header",
		order = 23,
		name = "",
	}
	options.delayEnter = {
		type = "range",
		order = 25,
		name = L["Mouse Enter Delay"],
		desc = L["Delay in seconds before showing the status."],
		min = 0,
		max = 2,
		step = 0.05,
		get = function () return status.dbx.delayEnter or 0.1 end,
		set = function (_, v)
			status.dbx.delayEnter = v
			status:UpdateDB()
		end,
	}
	options.delayLeave = {
		type = "range",
		order = 30,
		name = L["Mouse Leave Delay"],
		desc = L["Delay in seconds before hiding the status."],
		min = 0,
		max = 2,
		step = 0.05,
		get = function () return status.dbx.delayLeave or 0.25 end,
		set = function (_, v)
			status.dbx.delayLeave = v
			status:UpdateDB()
		end,
	}
end

-- MakeStatusAoeHealOptions()
local MakeStatusAoeHealOptions
do
	local function MakeStatusPlayersDistanceOptions(self, status, options)
		options.spacer1 = {
			type = "header",
			order = 20,
			name = "",
		}
		options.radius = {
			type = "range",
			order = 29,
			name = L["Radius"],
			desc = L["Max distance of nearby units."],
			min = 0,
			softMax = 50,
			step = 0.5,
			get = function () return status.dbx.radius end,
			set = function (_, v) 
				status.dbx.radius = v  
				status:UpdateDB() 
			end,
		}
		options.minPlayers = {
			type = "range",
			order = 30,
			name = L["Min players"],
			desc = L["Minimum players to enable the status."],
			min = 1,
			max = (status.name == "aoe-PrayerOfHealing") and 5 or 6,
			step = 1,
			get = function () return status.dbx.minPlayers end,
			set = function (_, v) 
				status.dbx.minPlayers = v  
				status:UpdateDB() 
			end,
		}
	end
	local function MakeStatusHealthThresholdOptions(self, status, options)	
		options.healthThreshold = {
			type = "range",
			order = 40,
			name = L["Health deficit"],
			desc = L["Minimum health deficit of units to enable the status."],
			min = 0,
			softMax = 250000,
			step = 1,
			bigStep = 500,
			get = function () return status.dbx.healthDeficit end,
			set = function (_, v) 
				status.dbx.healthDeficit = v  
				status:UpdateDB() 
			end,
		}
	end
	local function MakeStatusKeepPrevSolutionsOptions(self, status, options)
		options.keepPrevHeals = {
			type = "toggle",
			order = 17,
			name = L["Keep same targets"],
			desc = L["Try to keep same heal targets solutions if posible."],
			get = function () return status.dbx.keepPrevHeals end,
			set = function (_, v) 
				status.dbx.keepPrevHeals = v	 
				status:UpdateDB() 
			end,
		}
	end
	local function MakeStatusAllSolutionsOptions(self, status, options)
		options.showAllSol = {
			type = "toggle",
			order = 17,
			name = L["Display all solutions"],
			desc = L["Display all solutions instead of only one solution per group."],
			get = function () return status.dbx.showAllSolutions end,
			set = function (_, v) 
				status.dbx.showAllSolutions = v or nil
				status:UpdateDB() 
			end,
		}
	end
	local function MakeStatusOverlapedOptions(self, status, options)
		options.showOverlapHeal = {
			type = "toggle",
			order = 15,
			name = L["Show overlapping heals"],
			desc = L["Show heal targets even if they overlap with other heals."],
			get = function () return status.dbx.showOverlapHeals end,
			set = function (_, v)  
				status.dbx.showOverlapHeals = v  
				status:UpdateDB() 
			end,
		}
	end
	local function MakeStatusRaidHealOptions(self, status, options)
		options.maxSolutions = {
			type = "range",
			order = 45,
			name = L["Max solutions"],
			desc = L["Maximum number of solutions to display."],
			min = 1,
			max = 10,
			step = 1,
			get = function () return status.dbx.maxSolutions end,
			set = function (_, v) 
				status.dbx.maxSolutions = v  
				status:UpdateDB() 
			end,
		}
		options.hideOnCooldown = {
			type = "toggle",
			order = 15,
			name = L["Hide on cooldown"],
			desc = L["Hide the status while the spell is on cooldown."],
			get = function () return status.dbx.hideOnCooldown end,
			set = function (_, v) 
				status.dbx.hideOnCooldown = v
				status:UpdateDB() 
			end,
		}
	end
	function MakeStatusAoeHealOptions(self, status, options)
		local name = status.name
		self:MakeStatusColorOptions(status, options)
		if name == "aoe-highlighter" then
			MakeStatusHighlighterOptions(self, status, options)
		else
			MakeStatusPlayersDistanceOptions(self, status, options)
			MakeStatusHealthThresholdOptions(self, status, options)	
			if name == "aoe-ChainHeal" then
				MakeStatusKeepPrevSolutionsOptions(self, status, options)
				MakeStatusOverlapedOptions(self, status, options)
			elseif name == "aoe-WildGrowth" or name == "aoe-CircleOfHealing" then
				MakeStatusKeepPrevSolutionsOptions(self, status, options)
				MakeStatusRaidHealOptions(self, status, options)
			elseif name == "aoe-PrayerOfHealing" then 
				MakeStatusAllSolutionsOptions(self, status, options)
			end
		end	
	end
end

-- MakeCategoryOptions() 
local function MakeCategoryOptions() 
	local NewStatusName
	return {
		showInCombat = {
			type = "toggle",
			order = 10,
			name = L["Show only in combat"],
			desc = L["Enable the statuses only in combat."],
			get = function () return AOEM.db.profile.showInCombat end,
			set = function (_, v)  
				AOEM.db.profile.showInCombat = v	
				AOEM:RefreshDisplayState()
			end,
		},
		showInRaid = {
			type = "toggle",
			order = 20,
			name = L["Show only in raid"],
			desc = L["Enable the statuses only in raid."],
			get = function () return AOEM.db.profile.showInRaid end,
			set = function (_, v) 
				AOEM.db.profile.showInRaid = v 
				AOEM:RefreshDisplayState()
			end,
		},
		spacer1 = {
			type = "header",
			order = 25,
			name = "",
		},		
		updateRate = {
			type = "range",
			order = 30,
			name = L["Update rate"],
			desc = L["Rate at which the status gets updated"],
			min = 0.1,
			max = 5,
			step = 0.05,
			get = function () return AOEM.db.profile.updateRate end,
			set = function (_, v)
				AOEM.db.profile.updateRate = v
				AOEM:RefreshUpdateRate()
			end,
		},
		spacer2 = {
			type = "header",
			order = 35,
			name = L["Statuses Creation"],
		},
		newOutgoingStatusName = {
			type = "input",
			order = 50,
			name = L["aoe-heals status name"],
			desc = L["Type the name of the new status."],
			get = function() return NewStatusName end,
			set = function(_, v) 
				NewStatusName = strtrim(v)
			end,	
			validate = function(_,v)
				v = strtrim(v)
				return (v == "" or Grid2:DbGetValue( "statuses", "aoe-" .. v )) and L["Invalid status name or already in use."] or true
			end,
		},
		createOutgoingStatus = {
			type = "execute",
			order = 55,
			width = "half",
			name = L["Create"],
			func = function() 
				local baseKey = "aoe-" .. NewStatusName
				if not Grid2:DbGetValue("statuses",baseKey ) then
					local dbx = { type = "aoe-heals", spellList = {}, activeTime =2, color1 = {r=0, g=0.8, b=1, a=1} }
					Grid2:DbSetValue("statuses", baseKey, dbx) 
					local status = Grid2.setupFunc[dbx.type](baseKey, dbx)
					Grid2Options:MakeStatusOptions(status)
				end
				NewStatusName = nil
			end,
			disabled = function() return NewStatusName==nil end,
		},
	} 
end

-- Hook to load options
local prev_LoadOptions = Grid2.LoadOptions
function Grid2:LoadOptions()
	L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
	Grid2Options:RegisterStatusCategory("aoe-heal", { name = L["AOE Heals"], icon = "Interface\\Icons\\Spell_holy_holynova", options = MakeCategoryOptions() } )
	Grid2Options:RegisterStatusOptions("aoe-heals", "aoe-heal", MakeStatusOutgoingOptions, { groupOrder= 50, titleIcon ="Interface\\Icons\\Spell_holy_holybolt" } )
	for name in next,AOEM.setupFunc do
		local status = Grid2.statuses[name]
		if status then
			Grid2Options:RegisterStatusOptions( name, "aoe-heal", MakeStatusAoeHealOptions, { groupOrder = 10, titleIcon = status.texture } )
		end	
	end
	prev_LoadOptions(self)
end
