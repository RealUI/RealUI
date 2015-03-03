local L = Grid2Options.L

local BuffSubTypes= {
	["Buff"] =  1,
	["Buffs"] =  {},
	["Buffs: Defensive Cooldowns"] = { 
			6940,  --Hand of Sacrifice
			31850, --Ardent Defender
			498,   --Divine Protection
			86657, --Ancient Guardian (It the buff channeled by the Guardian of the Ancient Kings)
			-- War
			2565,  --Shield Block
			871,   --Shield Wall
			12975, --Last Stand
			--Druid
			61336, --Survival Instincts
			22812, --Barkskin
			22842, --Frenzied Regeneration
			--Dk
			55233, --Vampiric Blood
			49028, --Dancing Rune Weapon
			48792, --Icebound Fortitude
			48707, --Anti-Magic Shell
			--Priest
			33206, --Pain Suppression
			47788, --Guardian Spirit
	},
}

local DebuffSubTypes= {
	["Debuff"] =  1,
	["Debuffs"] =  {},
	["Debuffs: Healing Prevented "] = { 
		82170, -- Corrupcion absoluta (Chogall)
		82890, -- Mortalidad (Chimaeron)
		85576, -- Vientos fulminadores (Alakir)
		92787, -- Oscuridad engullidora (Maloriak Hc)
		76903, -- Prision antimagia (Void Seeker/Hall of Originations)
	},
	["Debuffs: Healing Reduced"] = { 
		83908, -- Golpes malevolos (Halfus)
		76727, -- Golpe mortal (Grim Batol)
		22687, -- Velo de sombras (Nefarian)
		93956, -- Velo maldito (Baron Silverlain/Shadowfang Keep)
		93675, -- Herida mortal (Lord Godfrey/Shadowfang Keep)
		75571, -- Golpe hiriente (Rom'ogg Bonecrusher/BlackRock Caverns)
	},
}

local ColorCountValues = {1,2,3,4,5,6,7,8,9}

local ColorizeByValues= { L["Number of stacks"] , L["Remaining time"] }


local NewAuraUsageDescription= L["You can include a descriptive prefix using separators \"@#>\""] 
							   .. " ".. 
							   L["examples: Druid@Regrowth Chimaeron>Low Health"]	

-- {{ Shared code
local NewAuraHandlerMT = {
	Init = function (self)
		self.name = ""
		self.mine = 1
		self.spellName = nil
	end,
	GetKey = function (self)
		local result
		local name = self.name:gsub("[ %.\"]", "")
		if name == "" then return end
		if self.type == "debuff" then
			result = self.realType.."-"..name
		else
			local mine = self.mine
			if mine == 2 then
				mine = "-not-mine"
			elseif mine then
				mine = "-mine"
			else
				mine = ""
			end
			result = self.realType.."-"..name..mine
		end	
		return result
	end,
	GetName = function (self)
		return self.name
	end,
	SetName = function (self, info, value)
		local spellName
		local prefix, spell= string.match(value, "^(.-[@#>])(.*)$")
		if not spell then
			spell, prefix = value, ""
		end	
		spellName = tonumber(spell) or spell
		if type(spellName)=="number" then
			spell= GetSpellInfo(spellName)
			if spell==nil then
				spell,spellName= "", nil
			end
		end
		self.spellName = spellName
		self.name = prefix .. spell
	end,
	GetMine = function (self)
		return self.mine == 1
	end,
	SetMine = function (self, info, value)
		self.mine = value and 1
	end,
	GetNotMine = function (self)
		return self.mine == 2
	end,
	SetNotMine = function (self, info, value)
		self.mine = value and 2
	end,
	GetAvailableSubTypes = function(self)
		local result= {}
		for k in pairs(self.subTypes) do
			result[k]= L[k]
		end
	    return result
	end,
	GetSubType= function(self)
		return self.subType
	end,
	SetSubType= function(self,info,value)
		self.subType  = value
		self.isGroup  = type(self.subTypes[value]) == "table"
		self.realType = self.isGroup and self.type.."s" or self.type
		self.spellName = nil		
		if self.isGroup then
			self.spellName = value
			self.name = L[ string.match(value, "^.-: (.*)$") or value ]
			self.mine = nil
		else
			self.name = ""
			self.mine = 1
		end
	end,
	Create = function (self)
		local baseKey = self:GetKey()
		if baseKey then
			--Add to options and runtime db
			local dbx
			local spellName = (not self.isGroup) and self.spellName or nil
			local color = { r = self.color.r , g = self.color.g, b = self.color.b , a = self.color.a }
			if self.type == "debuff" then
				dbx = {type = self.realType, spellName = spellName, color1 = color }
			else
				dbx = {type = self.realType, spellName = spellName, mine = self.mine, color1 = color }
			end
			if self.isGroup then -- Buffs or Debuffs Group
				local auras = self.subTypes[self.subType]
				if #auras>0 or self.type == "buff" then
					dbx.auras= {} 
					for i,v in pairs(auras) do
						dbx.auras[i]= v
					end
					if self.type == "debuff" then 
						dbx.useWhiteList = true
					end	
				end	
			end
			Grid2.db.profile.statuses[baseKey]= dbx
			--Create the status
			local status = Grid2.setupFunc[dbx.type](baseKey, dbx)
			--Create the status options
			Grid2Options:MakeStatusOptions(status)
			self:Init()
		end
	end,
	IsDisabled = function (self)
		local key = self:GetKey() 
		if key and self.spellName then
			return not not Grid2.statuses[key]
		end
		return true
	end,
}
NewAuraHandlerMT.__index = NewAuraHandlerMT
-- }}

--{{ Buff Creation options
local NewBuffHandler = setmetatable({type = "buff", realType= "buff", subType="Buff", subTypes= BuffSubTypes, color = {r=1,g=1,b=1,a=1}}, NewAuraHandlerMT)

NewBuffHandler.options = {
	newStatusBuffType = {
		type = "select",
		order = 5,
		width="full",
		name = L["Select Type"],
		desc = L["Select Type"],
		get = "GetSubType",
		set = "SetSubType",
		values = "GetAvailableSubTypes",
		handler = NewBuffHandler,
	},
	newStatusBuffName = {
		type = "input", dialogControl = "EditBoxGrid2Buffs",
		order = 5.1,
		width = "full",
		name = L["Name or SpellId"],
		usage = NewAuraUsageDescription,
		get = "GetName",
		set = "SetName",
		handler = NewBuffHandler,
	},
	newStatusBuffMine = {
		type = "toggle",
		order = 5.2,
		name = L["Show if mine"],
		desc = L["Display status only if the buff was cast by you."],
		get = "GetMine",
		set = "SetMine",
		disabled = "GetNotMine",
		handler = NewBuffHandler,
	},
	newStatusBuffNotMine = {
		type = "toggle",
		order = 5.3,
		name = L["Show if not mine"],
		desc = L["Display status only if the buff was not cast by you."],
		get = "GetNotMine",
		set = "SetNotMine",
		disabled = "GetMine",
		handler = NewBuffHandler,
	},
	newStatusBuffSpacer = {
		type = "header",
		order = 5.5,
		name = "",
	},
	newStatusBuff = {
		type = "execute",
		order = 5.6,
		name = L["Create Buff"],
		desc = L["Create a new status."],
		func = "Create",
		disabled = "IsDisabled",
		handler = NewBuffHandler,
	},
}
NewBuffHandler:Init()

Grid2Options:RegisterStatusCategoryOptions("buff", NewBuffHandler.options)
--}}

--{{ Debuff Creation options
local NewDebuffHandler = setmetatable({type = "debuff", realType = "debuff", subType="Debuff", subTypes= DebuffSubTypes, color = {r=1,g=.2,b=.2,a=1}}, NewAuraHandlerMT)

NewDebuffHandler.options = {
	newStatusDebuffType = {
		type = "select",
		order = 5.1,
		width="full",
		name = L["Select Type"],
		desc = L["Select Type"],
		get = "GetSubType",
		set = "SetSubType",
		values = "GetAvailableSubTypes",
		handler = NewDebuffHandler,
	},
	newStatusDebuffName = {
		type = "input", dialogControl = "EditBoxGrid2Debuffs", 
		order = 5.2,
		width = "full",
		name = L["Name or SpellId"],
		usage = NewAuraUsageDescription,
		get = "GetName",
		set = "SetName",
		handler = NewDebuffHandler,
	},
	newStatusDebuffSpacer = {
		type = "header",
		order = 5.4,
		name = ""
	},
	newStatusDebuff = {
		type = "execute",
		order = 5.5,
		name = L["Create Debuff"],
		desc = L["Create a new status."],
		func = "Create",
		disabled = "IsDisabled",
		handler = NewDebuffHandler,
	},
}
NewDebuffHandler:Init()

Grid2Options:RegisterStatusCategoryOptions("debuff", NewDebuffHandler.options)
-- }}
