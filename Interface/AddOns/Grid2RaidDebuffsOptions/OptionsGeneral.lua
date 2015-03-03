-- Raid Debuffs general options

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local RDO = Grid2Options.RDO

local options = {}
RDO.OPTIONS_GENERAL = options

function RDO:InitGeneralOptions()
	Grid2Options:MakeStatusTitleOptions( RDO.statuses[1], options)
end

-- raid-debuffs statuses
do
	local statusColor = {
		type = "color",
		width = "full",
		name = function(info) 
			return RDO.statusesNames[info.arg]
		end,
		hasAlpha = true,
		get = function(info)
			local c = RDO.statuses[info.arg].dbx.color1
			return c.r, c.g, c.b, c.a
		end,
		set = function(info, r,g,b,a)
			local c = RDO.statuses[info.arg].dbx.color1
			c.r, c.g, c.b, c.a = r, g, b, a
		 end, 
		hidden = function(info)
			return info.arg>#RDO.statuses
		end
	}
	local meta = { __index = statusColor }
	options.status1 = setmetatable( { order = 10 , arg=1 }, meta )
	options.status2 = setmetatable( { order = 11 , arg=2 }, meta )
	options.status3 = setmetatable( { order = 12 , arg=3 }, meta )
	options.status4 = setmetatable( { order = 13 , arg=4 }, meta )
	options.status5 = setmetatable( { order = 14 , arg=5 }, meta )
end

options.newStatus = {
	type = "execute",
	order = 50,
	width = "half",
	name = L["New"],
	desc = L["New Status"],
	func = function(info) 
		local name = string.format("raid-debuffs%d", #RDO.statuses+1)
		Grid2:DbSetValue( "statuses", name, {type = "raid-debuffs", debuffs={}, color1 = {r=1,g=.5,b=1,a=1}} )
		Grid2.setupFunc["raid-debuffs"]( name, Grid2:DbGetValue("statuses", name) )
		RDO:LoadStatuses()
	end,
	hidden = function() return #RDO.statuses>=5 end
}

options.deleteStatus = {
	type = "execute",
	order = 51,
	width = "half",
	name = L["Delete"],
	desc = L["Delete last status"],
	func = function(info) 
		local status = RDO.statuses[#RDO.statuses]
		options[status.name] = nil
		Grid2:DbSetValue( "statuses", status.name, nil)
		Grid2:UnregisterStatus( status )
		RDO:LoadStatuses()
	end,
	confirm = function(info)
		return string.format( "Are your sure you want to delete %s status ?", RDO.statusesNames[#RDO.statuses] )
	end,
	disabled = function()
		local status = RDO.statuses[#RDO.statuses]
		return status.enabled or next(status.dbx.debuffs) or RDO.auto_enabled 
	end,
	hidden = function() 
		return #RDO.statuses<=1
	end,
}

-- debuffs autodetection

do
	function AddToTooltip(tooltip)
		tooltip:AddDoubleLine( L["RaidDebuffs Autodetection"], L["Enabled"], 255,255,255, 255,255,0)
	end

	options.autodetect = { type = "group", order = 100,	name = L["Debuffs Autodetection"], inline= true, args = {
		autoenable = {
			type = "toggle",
			order = 1,
			name = L["Enable Autodetection"],
			desc = L["Enable Zones and Debuffs autodetection"],
			get = function() 
				return RDO.auto_enabled 
			end,
			set = function(_, v) 
				RDO:SetAutodetect(v) 
				if (not v) and RDO:RegisterAutodetectedDebuffs() then
					RDO:RefreshAdvancedOptions()
				end	
				Grid2.tooltipFunc["Grid2RaidDebuffs"] = v and AddToTooltip or nil
			end,
		},
		autostatus = {	
			type = "select",
			order = 2,
			name = L["Assigned to"],
			desc = L["Assign autodetected raid debuffs to the specified status"],
			get = function () 
				return RDO.db.profile.autodetect.status or 1
			end,
			set = function (_, v) 
				local status = RDO.statuses[v]
				if status then
					RDO.db.profile.autodetect.status = v>1 and v or nil
					RDO:RefreshAutodetect()
				end
			end,
			values = RDO.statusesNames,
			disabled = function() return RDO.auto_enabled end
		}
	} }
end

-- enabled/disable modules
do
	local modules = {}
	options.modules= {
		type = "multiselect",
		name = L["Enabled raid debuffs modules"],
		order = 150,
		get = function(info,key)
			return RDO.db.profile.enabledModules[key] ~= nil
		end,
		set = function(_,module,state)
			RDO.db.profile.enabledModules[module] = state or nil
			for instance in pairs(RDO.RDDB[module]) do
				if state then
					RDO:EnableInstanceAllDebuffs(module,instance)
				else
					RDO:DisableInstanceAllDebuffs(instance)
				end	
			end
			RDO:UpdateZoneSpells()
			RDO:RefreshAdvancedOptions()
		end,
		values = function()
			wipe(modules)
			for name in pairs(RDO.RDDB) do
				if name ~= "[Custom Debuffs]" then
					modules[name] = L[name]
				end	
			end
			return modules
		end,
		disabled = function() return RDO.auto_enabled end
	}
end

-- encounter journal
options.header3 = { type = "header", order = 52, name = "" }

options.difficulty = {
	type = "select",
	order = 200,
	name = L["Encounter Journal difficulty"],
	desc = L["Default difficulty for Encounter Journal links"],
	get = function () 
		return RDO.db.profile.defaultEJ_difficulty or 14 
	end,
	set = function (_, v) 
		RDO.db.profile.defaultEJ_difficulty = v
	end,
	values = {
		[14] = PLAYER_DIFFICULTY1, -- Normal
		[15] = PLAYER_DIFFICULTY2, -- Heroic
		[16] = PLAYER_DIFFICULTY6, -- Mythic
		[17] = PLAYER_DIFFICULTY3  -- LFR
	},
}
