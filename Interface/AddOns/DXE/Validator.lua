-- Validates Encounter Data

-- Command line usage:
--		lua Validator.lua          - validates all encounters
--		lua Validator.lua <key>... - validates one or more encounters

---------------------------------------------
-- TYPE CONDITIONS
---------------------------------------------
local _C = {}

local function condition_helper(optional,...)
	local cond,desc = {},{}
	if optional then cond["nil"] = true end
	for _,kind in pairs({...}) do
		cond[kind] = true
		desc[#desc+1] = kind
	end
	cond._ = table.concat(desc,", ")
	_C[cond] = true
	return cond
end

local function required_condition(...) return condition_helper(false,...) end
local function optional_condition(...) return condition_helper(true,...) end

local istable = required_condition("table")
local isnumber = required_condition("number")
local isstring = required_condition("string")
local isboolean = required_condition("boolean")
local isstringtable = required_condition("string","table")
local istablenumber = required_condition("table","number")
local isstringnumber = required_condition("string","number")
local isstringtablenumber = required_condition("string","table","number")
local isstringtableboolean = required_condition("string","table","boolean")

local opttable = optional_condition("table")
local optnumber = optional_condition("number")
local optstring = optional_condition("string")
local optboolean = optional_condition("boolean")
local opttablenumber = optional_condition("table","number")
local optstringtable = optional_condition("string","table")
local optnumberstring = optional_condition("number","string")
local optstringtablenumber = optional_condition("string","table","number")

---------------------------------------------
-- EXTERNAL
-- IMPORTANT: Maintain when core changes
---------------------------------------------
local data

local PROXIMITYRANGES = {2,5,6,8,10,11,18,28}

local OPS = {
	["=="] = true,
	["~="] = true,
	["find"] = true,
	[">"] = true,
	[">="] = true,
	["<"] = true,
	["<="] = true,
}

do
	local t = {}
	for k,v in pairs(OPS) do t[#t+1] = k end
	for _,v in ipairs(t) do OPS["not_"..v] = true end
end

local SHORTCUTS = {"srcself","srcother","dstself","dstother"}

-- 'true' means condition shortcut table is added to fire_conds table
local FIRETYPES = {
	alert = true,
	arrow = true,
	raidicon = true,
	announce = true,
	message = true,
	timer = false,
}

local EVENTS = {
	"UNIT_SPELLCAST_CHANNEL_START",
	"UNIT_SPELLCAST_SUCCEEDED",
	"CHAT_MSG_MONSTER_EMOTE",
	"CHAT_MSG_RAID_BOSS_EMOTE","EMOTE",
	"CHAT_MSG_MONSTER_YELL","YELL",
	"CHAT_MSG_RAID_BOSS_WHISPER","WHISPER",
	"UNIT_AURA",
}

local EVENTTYPES = {
	"DAMAGE_SHIELD",
	"DAMAGE_SHIELD_MISSED",
	"DAMAGE_SPLIT",
	"PARTY_KILL",
	"RANGE_DAMAGE",
	"RANGE_MISSED",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REFRESH",
	"SPELL_AURA_REMOVED",
	"SPELL_AURA_REMOVED_DOSE",
	"SPELL_CAST_FAILED",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_CREATE",
	"SPELL_DAMAGE",
	"SPELL_ENERGIZE",
	"SPELL_EXTRA_ATTACKS",
	"SPELL_HEAL",
	"SPELL_INTERRUPT",
	"SPELL_MISSED",
	"SPELL_PERIODIC_DAMAGE",
	"SPELL_PERIODIC_ENERGIZE",
	"SPELL_PERIODIC_HEAL",
	"SPELL_PERIODIC_MISSED",
	"SPELL_RESURRECT",
	"SPELL_SUMMON",
	"SWING_DAMAGE",
	"SWING_MISSED",
	"SPELL_DISPEL",
	"UNIT_DIED",
}

local SOUNDS = {}
for i=1,12 do SOUNDS[#SOUNDS+1] = "ALERT"..i end
SOUNDS[#SOUNDS+1] = "VICTORY"

local COLORS = {
	"BLACK","BLUE","BROWN",
	"CYAN","DCYAN","GOLD",
	"GREEN","GREY","INDIGO",
	"MAGENTA","MIDGREY","ORANGE",
	"PEACH","PINK","PURPLE",
	"RED","TAN","TEAL",
	"TURQUOISE","VIOLET","WHITE",
	"YELLOW",
}

---------------------------------------------
-- SCHEMA
---------------------------------------------

local master_schema = {
	istable,
	hash = true,
	schema = {
		version = {optnumber, range = {min = 1}},
		key = isstring,
		zone = optstring,
		name = isstring,
		title = optstring,
		category = optstring,
		triggers = {
			opttable,
			schema = {
				scan = {
					optstringtablenumber,
					if_number = {range = {min = 1}},
					if_table = {array = {min = 1, each = isnumber}},
				},
				yell = {
					optstringtable,
					if_table = {array = {min = 1, each = isstring}},
				},
				emote = {
					optstringtable,
					if_table = {array = {min = 1, each = isstring}},
				},
			},
		},
		onactivate = {
			opttable,
			schema = {
				tracerstart = optboolean,
				tracerstop = optboolean,
				combatstart = optboolean,
				combatstop = optboolean,
				tracing = {
					opttable,
					array_part = {min = 1, max = 5},
					hash_schema = {
						powers = {opttable, array = {min = 1, max = 5, each = isboolean}},
						--markers = {opttable, each = isnumber, each_key = isstringtable},
						markers1 = {opttable, array_part = {min = 1, max = 5}}
						markers2 = {opttable, array_part = {min = 1, max = 5}}
						markers3 = {opttable, array_part = {min = 1, max = 5}}
						markers4 = {opttable, array_part = {min = 1, max = 5}}
						markers5 = {opttable, array_part = {min = 1, max = 5}}
						--markers = {opttable, array = {min = 1, max = 5, each = isnumber}},
						--	if_table = {array = {min = 1, each = isnumber}},
						--},
					},
				},
				sortedtracing = {opttable, array = {min = 1, each = isnumber}},
				unittracing = {
					opttable,
					array = {
						min = 1,
						max = 5,
						each = {isstring, inclusion = {"boss1","boss2","boss3","boss4","boss5"}},
					}
				},
				defeat =	{
					optstringtablenumber,
					if_table = {array = {min = 1, each = isnumberstring}},
				},
			},
		},
		enrage = {
			opttable,
--~ 			schema = {
--~ 				time10n = optnumer,
--~ 				time25n = optnumer,
--~ 				time10h = optnumer,
--~ 				time25h = optnumer,
--~ 			},
		},
		onstart = {opttable, command_bundle = true},
		onacquired = {opttable, each = {istable, command_bundle = true}, each_key = isnumber},

		userdata = {
			opttable,
			each = {
				isstringtablenumber,
				if_table = {series_or_container_table = true},
				if_string = {replaces = true},
			},
		},

		windows = {
			opttable,
			schema = {
				proxwindow = optboolean,
				proxoverride = optboolean,
				proxrange =	{optnumber, range = {min = 1}},
			},
		},

		timers =	{
			opttable,
			hash = {
				each = {istable, command_bundle = true}
			},
		},
		
		messages = {
			opttable,
			hash = {
				each = {
					istable,
					schema = {
						varname = isstring,
						type = {isstring, inclusion = {"message"}},
						text = {isstringtable, if_table = {series_table = true}, if_string = {replaces = true}},
						sound = {optstring, sound = true},
						color1 =	{optstring, color = true},
						icon = optstring,
						destname = {isstring, replaces = true},
						throttle = optnumber,
						exhealer = optboolean,
						extank = optboolean,
						exdps = optboolean,
						ability = optnumber,
					},
				},
			},
		},

		alerts = {
			opttable,
			hash = {
				each = {
					istable,
					hash = true,
					schema = {
						varname = isstring,
						type = {isstring, inclusion = {"centerpopup","dropdown","simple","focus","absorb"}},
						text = {isstringtable, if_table = {series_table = true}, if_string = {replaces = true}},
						text2 = {optstringtable, if_table = {series_table = true}, if_string = {replaces = true}},
						text3 = {optstringtable, if_table = {series_table = true}, if_string = {replaces = true}},
						text4 = {optstringtable, if_table = {series_table = true}, if_string = {replaces = true}},
						text5 = {optstringtable, if_table = {series_table = true}, if_string = {replaces = true}},
						text6 = {optstringtable, if_table = {series_table = true}, if_string = {replaces = true}},
						text7 = {optstringtable, if_table = {series_table = true}, if_string = {replaces = true}},
						text8 = {optstringtable, if_table = {series_table = true}, if_string = {replaces = true}},
						text9 = {optstringtable, if_table = {series_table = true}, if_string = {replaces = true}},
						time = {isstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time2 = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time3 = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time4 = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time5 = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time6 = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time7 = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time8 = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time9 = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time10n = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time10h = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time25n = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time25h = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						time25lfr = {optstringtablenumber, if_table = {series_table = true}, if_string = {replaces = true}},
						throttle = optnumber,
						flashtime = optnumber,
						sound = {optstring, sound = true},
						audiotime = optnumber,
						color1 =	{optstring, color = true},
						color2 = {optstring, color = true},
						flashscreen = optboolean,
						icon = optstring,
						counter = optboolean,
						behavior = {optstring, inclusion = {"singleton","overwrite"}},
						expect =	{opttable, expect = true},
						tag =	{optstring, replaces = true},
						exhealer = optboolean,
						extank = optboolean,
						exdps = optboolean,
						ability = optnumber,
						--destname = optstring,
						-- absorb bar
						textformat = optstring,
						values =	{opttable, each = isnumber, each_key = isnumber},
						npcid = {optnumberstring, if_string = {replaces = true}},
					},
				},
			},
		},

		arrows = {
			opttable,
			hash = {
				each = {
					istable,
					schema = {
						varname = isstring,
						msg =	isstring,
						persist = isnumber,
						unit = {isstring, replaces = true},
						action =	{isstring, inclusion = {"AWAY","TOWARD"}},
						spell = isstring,
						sound = {optstring, sound = true},
						fixed = optboolean,
						xpos = optnumber,
						ypos = optnumber,
						range1 = optnumber,
						range2 = optnumber,
						range3 = optnumber,
					},
				},
			},
		},

		raidicons = {
			opttable,
				hash = {
				each = {
					istable,
					schema = {
						varname = isstring,
						type = {isstring, inclusion = {"FRIENDLY","MULTIFRIENDLY","ENEMY","MULTIENEMY"}},
						persist = isnumber,
						unit = {isstring, replaces = true},
						icon = isnumber,
						reset = optnumber,
						total = optnumber,
						remove =	optboolean,
					},
				},
			},
		},

		announces = {
			opttable,
			hash = {
				each = {
					istable,
					schema = {
						varname = isstring,
						type = {isstring, inclusion = {"SAY","YELL"}},
						msg =	{isstring, replaces = true},
						enabled = optboolean,
					},
				},
			},
		},
		events = {
			opttable,
			array = {
				each = {
					istable,
					schema = {
						type = {isstring, inclusion = {"event","combatevent"}},
						event = {optstring, inclusion = EVENTS},
						eventtype =	{optstring, inclusion = EVENTTYPES},
						spellid = {opttablenumber, if_table = {each = isnumber}},
						spellid2 = {opttablenumber, if_table = {each = isnumber}},
						srcnpcid = {opttablenumber, if_table = {each = isnumber}},
						dstnpcid = {opttablenumber, if_table = {each = isnumber}},
						srcisplayertype = optboolean,
						srcisnpctype =	optboolean,
						srcisplayerunit = optboolean,
						dstisplayertype = optboolean,
						dstisnpctype =	optboolean,
						dstisplayerunit = optboolean,
						spellname =	{opttablenumber, if_table = {each = isnumber}},
						spellname2 = {opttablenumber, if_table = {each = isnumber}},
						msg =	{optstringtable, if_table = {each = isstring}},
						npcname = {optstringtable, if_table = {each = isstring}},
						throttle = {optnumber, range = {min = 1}},
						sync = {optstringtable, if_table = {each = isstring}},
						execute = {istable, command_bundle = true},
					},
				},
			},
		},
	},
}

local command_bundle_cond
local fire_cond = {}

local function init_command_bundle_cond()
	command_bundle_cond = {
		istable,
		array = {
			each = {
				istable,
				array = {
					min = 2,
					multiple = 2,
					-- every two elements
					each_pair = {
						expect = {istable, expect = true},
						set = {
							istable,
							hash = {
								each = {
									isstringtablenumber,
									if_string = {replaces = true},
									if_table = {series_table = true},
								},
							},
						},
						insert = {
							istable,
							array = {min = 2},
							schema = {
								{isstring, container = true},
								{isstring, replaces = true},
							},
						},
						wipe = {isstring, container = true},
						batchquash = {istable, array = {min = 1, each = fire_cond.alert}},
						quashall = isboolean,
						scheduletimer = {
							istable,
							array = {size = 2},
							schema = {
								{isstring, timer = true},
								{
									isstringnumber,
									if_number = {range = {min = 0}},
									if_string = {replaces = true},
								},
							},
						},
						canceltimer = {isstring, timer = true},
						alert = fire_cond.alert,
						message = fire_cond.message,
						batchalert = {istable, array = {min = 1, each = fire_cond.alert}},
						quash = {isstring, alert = true},
						quashpattern = {isstring},
						cancelalert = {isstring, alert = true},
						sync = {istable, array = {min = 1, each = fire_cond.alert}},
						schedulealert = {
							istable,
							array = {size = 2},
							schema = {
								{isstring, alert = true},
								{
									isstringnumber,
									if_number = {range = {min = 0}},
									if_string = {replaces = true},
								},
							},
						},
						repeatalert = {
							-- same as schedulealert
							istable,
							array = {size = 2},
							schema = {
								{isstring, alert = true},
								{
									isstringnumber,
									if_number = {range = {min = 0}},
									if_string = {replaces = true},
								},
							},
						},
						settimeleft = {
							-- same as schedulealert
							istable,
							array = {size = 2},
							schema = {
								{isstring, alert = true},
								{
									isstringnumber,
									if_number = {range = {min = 0}},
									if_string = {replaces = true},
								},
							},
						},
						resettimer = isboolean,
						tracing = {
							istable,
							array_part = {min = 1, max = 5},
							hash_schema = {
								powers = {opttable, array = {min = 1, max = 5, each = isboolean}},
								markers1 = {opttable, array_part = {min = 1, max = 5},}
								markers2 = {opttable, array_part = {min = 1, max = 5},}
								markers3 = {opttable, array_part = {min = 1, max = 5},}
								markers4 = {opttable, array_part = {min = 1, max = 5},}
								markers5 = {opttable, array_part = {min = 1, max = 5},}
							},
						},
						proximitycheck = {
							istable,
							array = {size = 2},
							schema = {
								{isstring, replaces = true},
								{isnumber, inclusion = PROXIMITYRANGES},
							},
						},
						outproximitycheck = {
							-- same as proximity check
							istable,
							array = {size = 2},
							schema = {
								{isstring, replaces = true},
								{isnumber, inclusion = PROXIMITYRANGES},
							},
						},
						arrow = fire_cond.arrow,
						removearrow = {isstring, replaces = true},
						removeallarrows = isboolean,
						raidicon = fire_cond.raidicon,
						removeraidicon = {isstring, replaces = true},
						--[[target = {
							istable,
							hash = true,
							schema = {
								unit = {optstring, inclusion = {"boss1","boss2","boss3","boss4"}},
								npcid = isnumber,
								raidicon = fire_cond.optraidicon,
								announce = fire_cond.optannounce,
								arrow = fire_cond.optarrow,
								alerts = {
									opttable,
									hash = true,
									schema = {
										self = fire_cond.optalert,
										other = fire_cond.optalert,
										unknown = fire_cond.optalert,
									},
								},
							},
						},]]
						target = {
							istable,
							hash = true,
							schema = {
								source = isstring,
								wait = isnumber,
								raidicon = fire_cond.optraidicon,
								announce = fire_cond.optannounce,
								arrow = fire_cond.optarrow,
								alerts = {
									opttable,
									hash = true,
									schema = {
										self = fire_cond.optalert,
										other = fire_cond.optalert,
										unknown = fire_cond.optalert,
									},
								},
							},
						},
						announce = fire_cond.announce,
						invoke = {istable, command_bundle = true},
						tabinsert = {istable},
						tabupdate = {istable},
					}
				},
			},
		},
	}
end

---------------------------------------------
-- UTILITY
---------------------------------------------

local ipairs,pairs = ipairs,pairs
local assert,type,select = assert,type,select
local sort,concat = table.sort,table.concat
local find,format = string.find,string.format
local sub,gmatch,match = string.sub,string.gmatch,string.match

local function is_table(v) return type(v) == "table" end
local function is_number(v) return type(v) == "number" end
local function is_string(v) return type(v) == "string" end
local function is_boolean(v) return type(v) == "boolean" end
local function is_function(v) return type(v) == "function" end
local function is_nil(v) return type(v) == "nil" end

local function assert_table(v,m) assert(is_table(v),m or "expected a table") end
local function assert_number(v,m) assert(is_number(v),m or "expected a number") end
local function assert_string(v,m) assert(is_string(v),m or "expected a string") end
local function assert_boolean(v,m) assert(is_boolean(v),m or "expected a boolean") end
local function assert_function(v,m) assert(is_function(v),m or "expected a funtion") end

local function f(str,...)
	assert(type(str) == "string")
	local t = {}
	for i=1,select('#',...) do t[#t+1] = tostring(select(i,...)) end
	return string.format(str,unpack(t))
end

local function err(msg,...)
	local t = {...}
	local s = {}
	s[1] = format("<%s>",table.remove(t))
	for i=#t,1,-1 do
		s[#s+1] = is_number(t[i]) and format("[%d]",t[i]) or format(".%s",t[i])
	end
	error(format("Invalid encounter %s: %s",concat(s),msg))
end

local util = {}

function util.table_needed(key,...)
	if not is_table(data[key]) then
		error(key.." table needed in "..(select(select("#",...),...)))
	end
end

function util.to_set_list(t)
	if #t == 0 then
		return "non-existent - a table needs to be defined"
	elseif #t == 1 then
		return format("%q",t[1])
	else
		sort(t)
		return format("{%s, or %s}",concat(t,", ",1,#t-1),t[#t])
	end
end

function util.pretty(v)
	return type(v) == "string" and format("%q",v) or tostring(v)
end

function util.keys(hash)
	assert_table(hash)
	local t = {}
	for k in pairs(hash) do t[#t+1] = util.pretty(k) end
	return util.to_set_list(t)
end

function util.values(array)
	assert_table(array)
	local t = {}
	for _,v in pairs(array) do t[#t+1] = util.pretty(v) end
	return util.to_set_list(t)
end

function util.split(delimiter,text)
  local list = {}
  local pos = 1
  while true do
    local first,last = find(text,delimiter,pos)
    if first then
      list[#list+1] = sub(text,pos,first - 1)
      pos = last + 1
    else
      list[#list+1] = sub(text,pos)
      break
    end
  end
  return list
end

function util.next_s(t,i)
	local k,v = next(t,i)
	if k == nil then return end
	while type(k) ~= "string" do
		k,v = next(t,k)
		if k == nil then return end
	end
	return k,v
end

-- iterates over string keys
function util.spairs(t)
	return util.next_s,t
end

---------------------------------------------
-- VALIDATOR
---------------------------------------------

local validate,helpers = {},{}

function validate:helpers(value,cond,...)
	-- skip cond[1]
	for key,info in util.spairs(cond) do
		local func = helpers[key]

		assert(func or (key == "schema" or
							 key == "hash_schema" or
							 key == "array_schema"))
		if func then
			assert_function(func)
			func(helpers,value,info,...)
		end
	end

	-- must go last
	if cond.schema or cond.hash_schema or cond.array_schema then
		assert_table(value)
		if cond.schema then self:struct(pairs,value,cond.schema,...) end
		if cond.array_schema then self:struct(ipairs,value,cond.array_schema,...) end
		if cond.hash_schema then self:struct(util.spairs,value,cond.hash_schema,...) end
	end
end

function validate:type(v,kinds,...)
	if not kinds[type(v)] then
		err(f("expected a %s - got %q (%s)",kinds._,v,type(v)),...)
	end
end

function validate:struct(iter,struct,schema,...)
	assert_table(schema)
	assert_table(struct)
	assert_function(iter)

	-- key inclusion
	for k in iter(struct) do
		if not schema[k] then
			err(f("unknown key '%s'",k),...)
		end
	end

	-- values
	for k,cond in iter(schema) do
		assert_table(cond)
		self:value(struct[k],cond,k,...)
	end
end

function validate:value(value,cond,...)
	assert(_C[cond] or _C[cond[1]], "invalid condition table")

	if #cond > 0 then
		self:type(value,cond[1],...)
		if not is_nil(value) then
			self:helpers(value,cond,...)
		end
	else
		self:type(value,cond,...)
	end
end

function validate:data(struct)
	assert_table(struct)
	data = struct
	self:value(struct,master_schema,struct.key)
	data = nil
end

---------------------------------------------
-- HELPERS
---------------------------------------------

do
	local function exists(v,kind,...)
		local plural = kind.."s"
		util.table_needed(plural,...)
		if not data[plural][v] then
			err(f("unknown %s %q - expected %s",kind,v,util.keys(data[plural])),...)
		end
	end

	local function build_fire_cond(cond,kind)
		return {
			cond,
			if_table = {
				schema = {
					{optstring, [kind] = true},
					time = {optnumber, range = {min = 2, max = 9}},
					text = {optnumber, range = {min = 2, max = 9}},
					expect = {opttable, expect = true},
				},
			},
			if_string = {[kind] = true},
		}
	end

	for kind,has_cond in pairs(FIRETYPES) do
		-- helper:alert(...), helper:arrow(...), etc. for checking existence
		helpers[kind] = function(self,v,_,...)
			assert_string(v)
			exists(v,kind,...)
		end

		if has_cond then
			fire_cond[kind] = build_fire_cond(isstringtable,kind)
			for _,sc in ipairs(SHORTCUTS) do
				fire_cond[kind].if_table.schema[sc] = {optstring, [kind] = true}
			end

			fire_cond["opt"..kind] = build_fire_cond(optstringtable,kind)
		end
	end

	init_command_bundle_cond()
end

function helpers:inclusion(v,values,...)
	assert_table(values)

	local inside = false

	for _,value in ipairs(values) do
		if v == value then
			inside = true
			break
		end
	end

	if not inside then
		err(f("expected '%s' to be %s",v,util.values(values)),...)
	end
end

function helpers:range(v,rule,...)
	assert_number(v)
	assert_table(rule)
	assert(type(rule.min) == "number" or type(rule.max) == "number")

	local a,b = true,true
	local context = rule.context or "number"
	if rule.min then a = v >= rule.min end
	if rule.max then b = v <= rule.max end
	if not a or not b then
		if rule.min and rule.max then
			err(f("%s should be >= %s and <= %s - got %s",context,rule.min,rule.max,v),...)
		elseif rule.min then
			err(f("%s should be >= %s - got %s",context,rule.min,v),...)
		elseif rule.max then
			err(f("%s should be <= %s - got %s",context,rule.max,v),...)
		end
	end
end

function helpers:multiple(v,rule,...)
	assert_number(v)
	assert_table(rule)
	assert_number(rule.multiple)

	if v % rule.multiple ~= 0 then
		local context = rule.context or "number"
		err(f("%s should be a multiple of %s - got %s",context,rule.multiple,v),...)
	end
end

do
	local function process_rule(v,rule,size,kind,...)
		assert(type(rule) == "boolean" or type(rule) == "table")
		if is_table(rule) then
			rule.context = format("%s size",kind)
			if rule.min or rule.max then
				helpers:range(size,rule,...)
			end

			if rule.multiple then
				helpers:multiple(size,rule,...)
			end

			if rule.size and size ~= rule.size then
				err(f("invalid %s - size must be %s",kind,rule.size),...)
			end

			if rule.each then
				local key = format("%s_each",kind)
				helpers[key](helpers,v,rule.each,...)
			end

			if kind == "array" and rule.each_pair then
				assert_table(rule.each_pair)
				assert(#v % 2 == 0)

				for i=1,#v,2 do
					validate:value(v[i],isstring,i,...)
					local cond = rule.each_pair[v[i]]
					if not cond then
						err(f("unknown key - got %q - expected %s",v[i],util.keys(rule.each_pair)),...)
					end
					validate:value(v[i+1],cond,i+1,...)
				end
			end
		end
	end

	function helpers:hash_part(v,rule,...)
		assert_table(v)

		local size = 0
		for k,v in util.spairs(v) do
			size = size + 1
		end
		if size == 0 then err("invalid hash part - size is 0",...) end

		process_rule(v,rule,size,"hash",...)
	end

	function helpers:hash(v,rule,...)
		assert_table(v)

		local size = 0
		local ok = true
		for k,v in pairs(v) do
			if not is_string(k) then
				ok = false; break
			end
			size = size + 1
		end
		if ok then ok = #v == 0 end
		if ok then ok = size > 0 end
		if not ok then
			err("invalid hash - has no elements or numeric indices",...)
		end

		process_rule(v,rule,size,"hash",...)
	end

	function helpers:array_part(v,rule,...)
		assert_table(v)
		if #v == 0 then err("invalid array part - size is 0",...) end
		process_rule(v,rule,#v,"array",...)
	end

	function helpers:array(v,rule,...)
		assert_table(v)

		local ok = true
		for k,v in pairs(v) do
			if not is_number(k) then
				ok = false break
			end
		end
		if ok then ok = #v > 0 end
		if not ok then err("invalid array - has no elements or non-numeric indices",...) end

		process_rule(v,rule,#v,"array",...)
	end
end

do
	----------------
	-- unclosed
	----------------

	local function unclosed_helper(text,left,right,...)
		local partial = text
		-- check for opening
		if find(partial,left) then
			local ptn = format("%s.-%s(.*)",left,right)
			while #partial > 0 do
				-- discard closure
				local rest = match(partial,ptn)
				-- a match implies closure
				if rest then
					-- check the rest of the string
					if not find(rest,left) then break end
					partial = rest
				else
					err(f("unclosed %s%s replace, got %q",left,right,text),...)
				end
			end
		end
	end

	local function unclosed(text,...)
		unclosed_helper(text,'#','#',...)
		unclosed_helper(text,'<','>',...)
		unclosed_helper(text,'&','&',...)
	end

	----------------
	-- funcs
	----------------

	local REPLACEFUNCS = {
		tft = true,
		tft_unitexists = true,
		tft_isplayer = true,
		tft_unitname = true,
		tft2 = true,
		tft2_unitexists = true,
		tft2_isplayer = true,
		tft2_unitname = true,
		tft3 = true,
		tft3_unitexists = true,
		tft3_isplayer = true,
		tft3_unitname = true,
		tft4 = true,
		tft4_unitexists = true,
		tft4_isplayer = true,
		tft4_unitname = true,
		playerguid = true,
		playername = true,
		vehicleguid  = true,
		vehiclenames = true,
		difficulty = true,
		srcname_or_YOU = true,
		dstname_or_YOU = true,
		upvalue = true,
		-- with params
		-- replace vars and nums don't need to be checked
		npcid = 1,
		playerbuff = 1,
		playerdebuff = 1,
		playerbuffdur = 1,
		playerdebuffdur = 1,
		buffstacks = 2,
		debuffstacks = 2,
		timeleft = {1,function(args,...)
			helpers:alert(args[1],nil,...)
			if args[2] then
				validate:value(tonumber(args[2]),isnumber,...)
			end
		end},
		closest = {1,function(args,...)
			helpers:container(args[1],nil,...)
		end},
		hasicon = {2,function(args,...)
			validate:value(tonumber(args[2]),isnumber,...)
		end},
		channeldur = 1,
		castdur = 1,
		gethp = 1,
		getap = 1,
		getup = 1,
		gettarget = 1,
		list = 1,
		guidisplayertarget = 1,
		tabread = 1,
	}

	local function check_args(args,arity,...)
		-- extra arguments are permitted
		if not args or #args < arity then
			err("missing args in replace func",...)
		end
	end

	local function funcs(text,...)
		for rep in gmatch(text,"%b&&") do
			local args
			local func = match(rep,"&(.+)&")
			if find(func,"|") then
				func,args = match(func,"^([^|]+)|(.+)")
				if is_string(args) then
					args = util.split("|",args)
				end
			end

			local ok = REPLACEFUNCS[func]
			if not ok then
				err(f("replace func %q does not exist - expected %s",rep,util.keys(REPLACEFUNCS)),...)
			end

			if is_number(ok) then
				check_args(args,ok,...)
			elseif is_table(ok) then
				assert_number(ok[1])
				assert_function(ok[2])

				check_args(args,ok[1],...)
				ok[2](args,...)
			end
		end
	end

	----------------
	-- vars
	----------------

	local function vars(text,...)
		for var in gmatch(text,"%b<>") do
			local key = match(var,"<(.+)>")
			-- only whine about userdata table if there is a replace var
			if not data.userdata then
				util.table_needed("userdata",...)
			end
			if not data.userdata[key] then
				err(f("replace var %q does not exist - expected %s",var,util.keys(data.userdata)),...)
			end
		end
	end

	----------------
	-- numbers
	----------------

	local function nums(text,...)
		for var in gmatch(text,"%b##") do
			local num = tonumber(match(var,"#(%d+)#"))
			if not num or num < 1 or num > 11 then
				err(f("replace num invalid; expected [1,11] - got %q",var),...)
			end
		end
	end

	----------------
	-- API
	----------------

	function helpers:replaces(v,_,...)
		assert_string(v)
		unclosed(v,...)
		-- func needs to go first because its params could contain var and num replaces
		funcs(v,...)
		vars(v,...)
		nums(v,...)
	end
end

function helpers:equals(v,wanted,...)
	assert_string(v)
	assert_string(wanted)

	if v ~= wanted then
		err(f("expected value to be %q - got %q",wanted,v),...)
	end
end

function helpers:sound(v,_,...)
	assert_string(v)
	self:inclusion(v,SOUNDS,...)
end

function helpers:color(v,_,...)
	assert_string(v)
	self:inclusion(v,COLORS,...)
end

do
	local expect_cond = {istable,array = {min = 3, each = isstring}}
	local expression_help = {replaces = true}

	function helpers:expect(v,_,...)
		assert_table(v)
		validate:value(v,expect_cond,...)

		if (#v + 1) % 4 ~= 0 then
			err(f("invalid expect array size - got %q",#v),...)
		end

		local triplets = (#v + 1) / 4

		-- check logical operators
		for i=2,triplets do
			local ix = (i-1)*4
			local log_op = v[ix]
			if log_op ~= "AND" and log_op ~= "OR" then
				err(f("unknown logical operator - got %q",log_op),ix,...)
			end
		end

		for i=1,triplets do
			-- left index of triplet
			local j = 4*i - 3
			local v1,op,v2 = v[j],v[j+1],v[j+2]
			if not OPS[op] then
				err(f("unknown relational operator - got %q",op),j+1,...)
			end
			validate:helpers(v1,expression_help,j,...)
			validate:helpers(v2,expression_help,j+2,...)
		end
	end
end



function helpers:command_bundle(v,_,...)
	assert_table(v)
	validate:value(v,command_bundle_cond,...)
end

do
	local cond = {
		istable,
		array_part = {
			min = 1,
			each = {
				isstringnumber,
				if_string = {replaces = true},
			},
		},
		hash_schema = {
			loop = isboolean,
			type = {isstring, equals = "series"},
		}
	}

	function helpers:series_table(v,_,...)
		assert_table(v)
		validate:value(v,cond,...)
	end
end

do
	local cond = {
		istable,
		hash = {
			type = {isstring, equals = "container"} ,
			wipein = isnumber,
		},
	}

	function helpers:container_table(v,_,...)
		assert_table(v)
		validate:value(v,cond,...)
	end

	function helpers:container(v,_,...)
		assert_string(v)
		util.table_needed("userdata",...)
		if not data.userdata[v] or
			data.userdata[v].type ~= "container" then
			err(f("unknown userdata container - got %q",v),...)
		end
	end
end


do
	local cond = {
		istable,
		hash_schema = {
			type = {isstring, inclusion = {"series", "container"}},
			wipein = optnumber,
			loop = optboolean,
		}
	}

	function helpers:series_or_container_table(v,_,...)
		assert_table(v)
		validate:value(v,cond,...)
		helpers[v.type.."_table"](helpers,v,_,...)
	end
end

do
	local function each(iter,collection,cond,...)
		assert_function(iter)
		assert_table(collection)

		for k,v in iter(collection) do
			validate:value(v,cond,k,...)
		end
	end

	function helpers:hash_each(v,cond,...)
		each(util.spairs,v,cond,...)
	end

	function helpers:array_each(v,cond,...)
		each(ipairs,v,cond,...)
	end

	function helpers:each(v,cond,...)
		each(pairs,v,cond,...)
	end

	function helpers:each_key(v,cond,...)
		assert_table(v)

		for k in pairs(v) do
			validate:value(k,cond,k,...)
		end
	end
end

function helpers:subset(set,values,...)
	assert_table(set)
	assert_table(values)
	local superset = {}
	for _,v in ipairs(values) do superset[v] = true end
	for k,v in ipairs(set) do
		if not superset[v] then
			err(f("invalid value '%s'",v),k,...)
		end
	end
end

function helpers:if_number(value,cond,...)
	assert(is_table(cond)); assert(#cond == 0)
	if is_number(value) then validate:helpers(value,cond,...) end
end

function helpers:if_string(value,cond,...)
	assert(is_table(cond)); assert(#cond == 0)
	if is_string(value) then validate:helpers(value,cond,...) end
end

function helpers:if_table(value,cond,...)
	assert(is_table(cond)); assert(#cond == 0)
	if is_table(value) then validate:helpers(value,cond,...) end
end

---------------------------------------------
-- LOADING
---------------------------------------------

if DXE then
	-- WoW
	function DXE:ValidateData(data) validate:data(data) end
else
	-- Command line usage:
	--		lua Validator.lua          - validates all encounters
	--		lua Validator.lua <key>... - validates one or more encounters

	local function setup()
		-- DXE
		local return_key = setmetatable({},{
			__index = function(t,k)
				t[k] = tostring(k)
				return tostring(k)
			end,
		})

		DXE = {
			EDB = {},
			SN = return_key,
			ST = return_key,
			L = setmetatable({},{
				__index = function(t,k)
					rawset(t,k,return_key)
					return return_key
				end,
			})
		}

		function DXE:RegisterEncounter(data)
			if type(data) == "table" then
				if type(data.key) == "string" then
					if DXE.EDB[data.key] then
						error(format("duplicate key %q - there shouldn't be any",data.key))
					end
					DXE.EDB[data.key] = data
				else
					print(debug.traceback():match("[./]+Encounters.-%d+:"),"data has a non-string key")
				end
			else
				print(debug.traceback():match("[./]+Encounters.-%d+:"),"a non-table was passed to RegisterEncounter",1)
			end
		end

		-- GLOBALS
		_G.format = string.format
		_G.UnitFactionGroup = function() return "Alliance" end
		_G.UNKNOWN = "Unknown"
	end

	local function load_all()
		local results = io.popen("find Encounters -name 'Encounters\.lua'")
		for line in results:lines() do
			require(line:gsub("\.lua",""))
		end
	end

	local function run()
		if #arg == 0 then
			-- validate all encounters
			local start = os.clock()
			print("validating all encounters...")
			for _,data in pairs(DXE.EDB) do
				validate:data(data)
			end
			print("all encounters are valid ("..format("%.3fs",os.clock() - start)..")")
		else
			-- validate from command line arguments
			local keys = {}
			for k,v in ipairs(arg) do keys[v] = true end

			local unknown = {}
			for key in pairs(keys) do
				if DXE.EDB[key] then
					validate:data(DXE.EDB[key])
					print(format("%s valid",DXE.EDB[key].key))
				else
					unknown[#unknown+1] = key
				end
			end

			if #unknown > 0 then
				print(format("encounter key(s) '%s' don't exist",table.concat(unknown,", ")))
			end
		end
	end

	setup()
	load_all()
	run()
end

