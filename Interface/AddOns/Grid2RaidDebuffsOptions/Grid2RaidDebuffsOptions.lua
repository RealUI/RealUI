--[[
Created by Michael
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
-- local BZ = LibStub("LibBabble-Zone-3.0"):GetUnstrictLookupTable()
-- local BB = {} -- seems like prepared table for BabbleBoss, not needed now

local GSRD = Grid2:GetModule("Grid2RaidDebuffs")
local RDDB = {}

local statuses = {}

local curModule
local curInstance
local curDebuffs = {}
local curDebuffsOrder = {}
local curBossesOrder = {}
local moduleList = {}
local statusesList = {}

local optionModules
local optionInstances
local optionDebuffs
local optionsDebuffsCache= {}

local newSpellId
local newDebuffName
local fmt= string.format
local find=string.find
local tonumber = tonumber
local select = select

-- forward declarations
local AddBossDebuffOptions

local ICON_SKULL= "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local ICON_CHECKED = READY_CHECK_READY_TEXTURE
local ICON_UNCHECKED = READY_CHECK_NOT_READY_TEXTURE

function Grid2Options:GetRaidDebuffsTable()
	return RDDB
end

local function UpdateZoneSpells()
	if curInstance == GSRD:GetCurrentZone() then
		GSRD:UpdateZoneSpells()
	end
end

local function GetOptionsFromCache()
	return optionsDebuffsCache[ curModule..curInstance ]
end

local function SetOptionsToCache(options)
	optionsDebuffsCache[ curModule..curInstance ] = options
end

local function GetLocalizedStatusName(key)
	local localizedText = L["raid-debuffs"]
	local index = select(3, find(key, "(%d+)")) or 1
    return index==1 and localizedText or fmt( "%s(%d)",localizedText,index)
end

local function GetCustomDebuffs()
	local debuffs = GSRD.db.profile.debuffs
	if debuffs then --updating variables after LibBabble-Zone removal
		for k,v in pairs(debuffs) do
			if type(k) == "string" and GSRD.engMapName_to_mapID[k] then
				debuffs[GSRD.engMapName_to_mapID[k]]=v
				debuffs[k]=nil
			end
		end
	end
	
	return GSRD.db.profile.debuffs and GSRD.db.profile.debuffs[curInstance] or {}
end

local function GetDebuffOrder(boss, spellId, isCustom, priority)
	local status = curDebuffs[spellId]
	if status then
		return curBossesOrder[boss] * 1000 + statuses[status]*50 + curDebuffsOrder[spellId]
	else
		return curBossesOrder[boss] * 1000 + (isCustom and 750 or 500) + (priority or 200)
	end
end

local function CalculateAvailableStatuses()
	wipe(statuses)
	for _,status in Grid2:IterateStatuses() do
		if status.dbx and status.dbx.type == "raid-debuffs" then
			statuses[#statuses+1] = status
		end
	end
	table.sort( statuses, function(a,b) 
			local index_a = tonumber(select(3, find(a.name, "(%d+)")) or 1)
			local index_b = tonumber(select(3, find(b.name, "(%d+)")) or 1)
			return index_a < index_b  
		end )
	wipe(statusesList)
	for index,status in ipairs(statuses) do
		statuses[status] = index
		statusesList[index] = GetLocalizedStatusName( status.name )
	end	
end

local function LoadEnabledDebuffs()
	curDebuffs = {}
	curDebuffsOrder = {}
	for _,status in ipairs(statuses) do
		local dbx = status.dbx.debuffs[curInstance] or {}
		for index,value in ipairs(dbx) do
			local key = math.abs(value)
			curDebuffs[ key ] = status
			curDebuffsOrder[ key ] = index
		end	
	end
end

local function ClearEnabledDebuffs()
	curDebuffs = {}
	curDebuffsOrder = {}
end

local function LoadBosses()
    wipe(curBossesOrder)
	local order = 30
	local bosses = RDDB[curModule][curInstance]
	for boss in pairs(bosses) do
		local EJ_Order = select(3, find(boss, "%-(%d+)%]"))
		if EJ_Order then
			curBossesOrder[boss] = tonumber(EJ_Order)
		else
			curBossesOrder[boss] = order
			order = order + 1
		end
	end
end

local function LoadModuleList()
	wipe(moduleList)
	local modules = GSRD.db.profile.enabledModules or {}
	for name in pairs(modules) do
		moduleList[name] = L[name]
	end
end

local function ResetAdvancedOptions()
	curModule= ""
	curInstance= ""
    curDebuffs = nil
	curDebuffsOrder = nil
	wipe(optionsDebuffsCache)
	LoadModuleList()
end

local function FormatDebuffName(spellId) 
	local name = GetSpellInfo(spellId)
	local status = curDebuffs[spellId]
	local index = statuses[status]
	if status then
		if index==1 then
			return fmt("  |T%s:0|t%s", ICON_CHECKED, name or spellId)
		else
			return fmt("  |T%s:0|t%s(%d)", ICON_CHECKED, name or spellId, index)
		end		
	else
		return fmt("  |T%s:0|t%s", ICON_UNCHECKED, name or spellId)
	end
end

local GetSpellDescription
do
	local lines = {}
	function GetSpellDescription(spellId)
		local tipDebuff = Grid2Options.Tooltip
		wipe(lines)
		tipDebuff:ClearLines()
		local name = GetSpellInfo(spellId)
		if GSRD.debugging then 
			local link = GetSpellLink(spellId)
			if not link then -- unavailible spellLink may indicate wrong spellId, thus not providing corect tooltip
				if name then -- this may still work due to having the same name
					GSRD:Debug("|cFF00FFFFSpellLink not Availible|r: %s  (%s)", spellId, name)
				else -- this wont work
					GSRD:Debug("|cFFFF0000Invalid spellId|r: %s", spellId) 
				end
			end
		end
		if not name then return "" end --invalid spellIds break the tooltip
		tipDebuff:SetHyperlink("spell:"..spellId) 
		
		for i=2, min(5,tipDebuff:NumLines()) do
			lines[i-1]= tipDebuff[i]:GetText() 
		end
		return table.concat(lines,"\n")
	end
end

local function GetInstances(module)
	local values= {}
	if module and module~="" then
		local instances= RDDB[module]
		if instances then
			for mapid,_ in pairs(instances) do
				values[mapid] = GetMapNameByID(mapid)
			end
		end
	end	
	return values
end

local function SetEnableDebuff(boss, status, spellId, value)
	if not status then return end
	local dbx = status.dbx
	if value then
		if not dbx.debuffs[curInstance] then
			dbx.debuffs[curInstance]= {}
		end
		local debuffs = dbx.debuffs[curInstance]
		debuffs[#debuffs+1] = spellId
		curDebuffs[spellId] = status
		curDebuffsOrder[spellId] = #debuffs
	else
		local debuffs = dbx.debuffs[curInstance]
		local index   = curDebuffsOrder[spellId]
		table.remove( debuffs,  index )
		curDebuffs[spellId] = nil
		curDebuffsOrder[spellId] = nil

		for k,v in pairs(curDebuffs) do
			if status==v and curDebuffsOrder[k]>index then 
				curDebuffsOrder[k] = curDebuffsOrder[k] - 1 
			end
		end
		if not next(debuffs) then
			dbx.debuffs[curInstance] = nil
		end
	end
	UpdateZoneSpells()
	local option = optionDebuffs.args[ tostring(spellId) ]
	option.name  = FormatDebuffName(spellId)
	option.order = GetDebuffOrder(boss, spellId)
end

local function GetDebuffStatus(spellId)
	local status = curDebuffs[spellId]
	if status then
		return status, curDebuffsOrder[spellId]
	end
end

local function SetDebuffSpellIdTracking(spellId, value)
	local spellName = GetSpellInfo(spellId)
	for spell,status in pairs(curDebuffs) do
		if spellName == GetSpellInfo(spell) then
			local index = curDebuffsOrder[spell]
			status.dbx.debuffs[curInstance][index] = value and -spell or spell
		end
	end
	UpdateZoneSpells()
end

local function EnableInstanceAllDebuffs(curModule, curInstance)
	local debuffs = {}
	local status = statuses[1]
	local dbx = status.dbx
	if not dbx.debuffs then dbx.debuffs= {}	end
	local debuffsall = RDDB[curModule][curInstance]
	for instance,values in pairs(debuffsall) do
		for boss,spellId in ipairs(values) do
			debuffs[#debuffs+1]      = spellId
		end
	end
	-- Enable user defined debuffs
	local rddbx = GSRD.db.profile.debuffs
	if rddbx and rddbx[curInstance] then
		for instance,values in pairs(rddbx[curInstance]) do
			for boss,spellId in ipairs(values) do
				debuffs[#debuffs+1]      = spellId
			end
		end
	end	
	dbx.debuffs[curInstance]= debuffs
end

local function DisableInstanceAllDebuffs(curModule, curInstance)
	for index,status in ipairs(statuses) do
		status.dbx.debuffs[curInstance] = nil
	end
end

local function RefreshDebuffsOptions()
	local items= optionDebuffs.args
	for key,value in pairs(items) do
		local spellId = tonumber(key)
		if spellId then
			items[key].name= FormatDebuffName(spellId)
		end
	end
end

local function EnableDisableModule(module, state)
	local rddbx = GSRD.db.profile
	if not rddbx.enabledModules then rddbx.enabledModules= {} end
	local instances = RDDB[module]
	if state then
		for instance in pairs(instances) do
			EnableInstanceAllDebuffs(module,instance)
			optionsDebuffsCache[module..instance] = nil
		end
		rddbx.enabledModules[module]= true
		moduleList[module] = L[module]	
	else
		for instance in pairs(instances) do
			DisableInstanceAllDebuffs(module,instance)
		end
		if rddbx.enabledModules[module] then rddbx.enabledModules[module]= nil end
		if not next(rddbx.enabledModules) then rddbx.enabledModules= nil end
		moduleList[module] = nil
	end
	curModule= ""
	UpdateZoneSpells()
end

local StripEJinfo
do
	local strgsub = string.gsub
	StripEJinfo = function(boss)
		return (strgsub(boss, "%[.-%]", ""))
	end
end

local function CreateStandardDebuff(bossNameKey,spellId,spellName)
	local bossName = StripEJinfo(bossNameKey)
	local baseKey = fmt("debuff-%s>%s", string.match(bossName, "^(.-) .*$") or bossName, spellName):gsub("[ %.\"!']", "")
	if not Grid2:DbGetValue("statuses", baseKey) then
		-- Save status in database
		local dbx = {type = "debuff", spellName = spellId, color1 = {r=1, g=0, b=0, a=1} }
		Grid2:DbSetValue("statuses", baseKey, dbx) 
		--Create status in runtime
		local status = Grid2.setupFunc[dbx.type](baseKey, dbx)
		--Create the status options
		Grid2Options:MakeStatusOptions(status)
	end
end

local function CreateNewRaidDebuff(boss)
	local spellId = newSpellId
	local spellName = GetSpellInfo(newSpellId)
	local bossStrip = StripEJinfo(boss)
	if spellId and spellName then
		local dbx = GSRD.db.profile
		if not dbx.debuffs then	dbx.debuffs= {}	end
		dbx = dbx.debuffs
		if not dbx[curInstance] then dbx[curInstance]= {}	end
		dbx = dbx[curInstance]
		if not dbx[bossStrip] then dbx[bossStrip]= {}	end
		dbx = dbx[bossStrip]
		dbx[#dbx+1] = spellId
		AddBossDebuffOptions( optionDebuffs.args, boss, spellId, true, #dbx)
	end
	newDebuffName = nil
	newSpellId = nil
end

local function DeleteRaidDebuff(boss, spellId)
	local dbx = GSRD.db.profile
	SetEnableDebuff(boss, curDebuffs[spellId], spellId, false)
	for boss, spells in pairs(dbx.debuffs[curInstance]) do
		for i= 1, #spells do
			if spellId == spells[i] then
				optionDebuffs.args[tostring(spellId)]= nil
				table.remove(spells,i)
				if #spells==0 then
					dbx.debuffs[curInstance][boss]= nil
					if not next(dbx.debuffs[curInstance]) then
						dbx.debuffs[curInstance]= nil
						if not next(dbx.debuffs) then
							dbx.debuffs= nil
						end
					end
				end
				return
			end
		end
	end
end

local function MakeDebuffOptions(bossName, spellId, isCustom)
	local spellName,_, spellIcon = GetSpellInfo(spellId)
	local options= {
		spellname={
			type="description",
			order= 10,
			name= fmt ( "%s\n(%d)", spellName or "Unknow", spellId),
			fontSize= "large",
			image= spellIcon,
		},
		header1={
			type= "header",
			order= 12,
			name="",
		},		
		description= {
			type="description",
			order= 50,
			fontSize= "medium",
			name= GetSpellDescription(spellId),
		},
		header2={
			type= "header",
			order= 40,
			name="",
		},
		enableSpell={
			type="toggle",
			order = 30,
			name = L["Enabled"],
			get = function() return curDebuffs[spellId]~=nil end,
			set = function(_, v)    
				SetEnableDebuff(bossName, curDebuffs[spellId] or statuses[1], spellId, v)
			end,
		},	
		header3={
			type= "header",
			order= 140,
			name="",
		},
		assignedStatus = {	
			type = "select",
			order = 144,
			name = L["Assigned to"],
			-- desc = "",
			get = function () 
				return statuses[ curDebuffs[spellId] or statuses[1] ]
			end,
			set = function (_, v) 
				SetEnableDebuff(bossName, curDebuffs[spellId], spellId, false) 
				SetEnableDebuff(bossName, statuses[v]        , spellId, true)
			end,
			values = statusesList,
			hidden = function() return not curDebuffs[spellId] end,
		},
		idTracking={
			type="toggle",
			order = 145,
			-- width = "full",
			name = L["Track by SpellId"],
			desc = L["Track by spellId instead of aura name"],
			get = function()
				local status,index = GetDebuffStatus(spellId)
				if status then 
					return status.dbx.debuffs[curInstance][index] < 0	
				end	
			end,
			set = function(_, v) 
				SetDebuffSpellIdTracking(spellId, v)
			end,
			hidden = function() return not curDebuffs[spellId] end,
		},					
		header4={
			type= "header",
			order= 147,
			name="",
			hidden = function() return not curDebuffs[spellId] end,
		},
		chatLink={
			type = "execute",
			order = 149,
			name = L["Link to Chat"],
			func = function() 
				local link = GetSpellLink(spellId)
				if link then
					local ChatBox = ChatEdit_ChooseBoxForSend()
					if not ChatBox:HasFocus() then
						ChatFrame_OpenChat(link)
					else
						ChatBox:Insert(link) 
					end
				end
			end,
		},
		createDebuff= {
			type = "execute",
			order = 150,
			name = L["Copy to Debuffs"],
			func = function() CreateStandardDebuff(bossName,spellId,spellName) end,
		}
	}
	if isCustom then
		options.removeDebuff= {
			type = "execute",
			order = 155,
			name = L["Delete raid debuff"],
			func = function() DeleteRaidDebuff(bossName, spellId) end,
		}
	end
	return options
end

local function MakeDebuffGroup(bossName, spellId, order, isCustom)
	return {
		type = "group",
		name = FormatDebuffName(spellId),
		desc = fmt("     (%d)", spellId ),
		order = order,
		args = MakeDebuffOptions(bossName,spellId,isCustom)
	}
end

local function AddInstanceOptions(options)
	local EJ_ID
	for k in pairs(RDDB[curModule] and RDDB[curModule][curInstance] or {}) do
		EJ_ID = select(3, find(k, "%[(%d+)%-"))
		if EJ_ID then break end
	end
	options.enableall={
		type ="execute",
		order= 5,
		name = L["Enable All"],
		func= function() 
			EnableInstanceAllDebuffs(curModule,curInstance)
			LoadEnabledDebuffs()
			UpdateZoneSpells()
			RefreshDebuffsOptions()
		end
	}
	options.disableall={
		type ="execute",
		order= 7,
		name = L["Disable All"],
		func= function() 
			DisableInstanceAllDebuffs(curModule,curInstance)
			ClearEnabledDebuffs()
			UpdateZoneSpells()
			RefreshDebuffsOptions()
		end
	}
	options.spacer={
		type = "header",
		order = 11,
		width = "full",
		hidden = EJ_ID == nil,
	}
	options.link={
		type = "execute",
		order = 15,
		width = "full",
		name = L["Show in Encounter Journal"],
		func = function() 
				if not IsAddOnLoaded("Blizzard_EncounterJournal") then LoadAddOn("Blizzard_EncounterJournal") end
				local instanceID, encounterID, sectionID = EJ_HandleLinkPath(1, EJ_ID)
				local difficulty = select(3, GetInstanceInfo())
				if difficulty > 2 and difficulty < 8 then 
					difficulty = difficulty -2 
				else 
					difficulty = GSRD.db.profile.defaultEJ_difficulty or 4 
				end
				if InterfaceOptionsFrame:IsShown() then
					InterfaceOptionsFrameOkay:Click()
					GameMenuButtonContinue:Click()
				end
				EncounterJournal_OpenJournal(difficulty, instanceID)
		end,
		hidden = EJ_ID == nil,
	}
end

local function AddBossOptions(options, name)
	local order    = curBossesOrder[name] * 1000
	local EJ_ID = select(3, find(name, "%[(%d+)%-"))
	EJ_ID = tonumber(EJ_ID)
	local EJ_Order = select(3, find(name, "%-(%d+)%]"))
	EJ_Order = EJ_Order and EJ_Order..") " or ""
	local bossName = EJ_ID and EJ_GetEncounterInfo(EJ_ID) or StripEJinfo(name)
	options[name]= {
		type= "group",
		name=  fmt("|T%s:0|t%s%s", ICON_SKULL, EJ_Order, bossName),
		order= order,
		args= {
			name = {
				type = "input",
				order = 1,
				width = "full",
				name = L["New raid debuff"],
				desc = L["Type the SpellId of the new raid debuff"],
				get = function()  return newDebuffName end,
				set = function(_,v)	
					newSpellId = tonumber(v)
					newDebuffName= newSpellId and GetSpellInfo(newSpellId) or nil
					if not newDebuffName or newDebuffName=="" then newSpellId= nil end
				end,
			},
			exec = {
				type = "execute",
				order = 9,
				name = L["Create raid debuff"],
				func = function(info) CreateNewRaidDebuff( name ) end,
				disabled= function() return not newSpellId or optionDebuffs.args[tostring(newSpellId)] end
			},
			spacer = {
				type = "header",
				order = 10,
				width = "full",
				hidden = EJ_ID == nil,
			},
			link = {
				type = "execute",
				order = 15,
				width = "full",
				name = L["Show in Encounter Journal"],
				func = function() 
						if not IsAddOnLoaded("Blizzard_EncounterJournal") then LoadAddOn("Blizzard_EncounterJournal") end
						local instanceID, encounterID, sectionID = EJ_HandleLinkPath(1, EJ_ID)
						local difficulty = select(3, GetInstanceInfo())
						if difficulty > 2 and difficulty < 8 then 
							difficulty = difficulty -2 
						else 
							difficulty = GSRD.db.profile.defaultEJ_difficulty or 4 
						end
						if InterfaceOptionsFrame:IsShown() then
							InterfaceOptionsFrameOkay:Click()
							GameMenuButtonContinue:Click()
						end
						EncounterJournal_OpenJournal(difficulty, instanceID, encounterID, sectionID)
				end,
				hidden = EJ_ID == nil,
			},
		},
	}
end

-- Forward declared, dont add "local function"
function AddBossDebuffOptions( options, boss, spellId, isCustom, priority )
	local order = GetDebuffOrder(boss, spellId, isCustom, priority)
	options[tostring(spellId)] = MakeDebuffGroup(boss, spellId, order, isCustom)
end

local function AddBossDebuffsOptions( options, boss, debuffs, isCustom)
	if not debuffs then return end
	for index,spellId in ipairs(debuffs) do
		AddBossDebuffOptions( options, boss, spellId, isCustom, index)
	end
end

local function MakeDebuffsOptions()
	LoadBosses()
	LoadEnabledDebuffs()
	local options = GetOptionsFromCache()
	if not options then
		options = {}
		local debuffs = RDDB[curModule][curInstance]
		local custom  = GetCustomDebuffs()
		AddInstanceOptions(options)
		for boss,values in pairs(debuffs) do
			AddBossOptions(options, boss)
			AddBossDebuffsOptions(options, boss, values      , false)
			local bossStrip = StripEJinfo(boss)
			AddBossDebuffsOptions(options, boss, custom[bossStrip], true )
		end
		SetOptionsToCache(options)
	end
	return options
end

local function MakeModulesListOptions(options)
	local modules = {}
	for name in pairs(RDDB) do
		modules[name] = L[name]
	end
	options.modules= {
		type = "multiselect",
		name = L["Enabled raid debuffs modules"],
		order = 150,
		width = "full",
		get= function(info,key)
			return (moduleList[key] ~= nil)
		end,
		set= function(_,key,value)
			EnableDisableModule(key,value)
		end,
		values = modules
	}
end

local function MakeOneStatusStandardOptions(options, status, index)
	local statusOptions = {}
	options[status.name] = { 
		type  = "group", 
		order = index+10, 
		inline = true, 
		name  = "",
		args  = statusOptions,
	}
	Grid2Options:MakeStatusStandardOptions(status, statusOptions, { color1 = GetLocalizedStatusName(status.name), width = "full" } )
end

local function MakeStandardOptions(options)
	for index,status in ipairs(statuses) do
		MakeOneStatusStandardOptions( options, status, index )
	end
	options.add = {
		type = "execute",
		order = 50,
		width = "half",
		name = L["New"],
		desc = L["New Status"],
		func = function(info) 
			local name = fmt("raid-debuffs%d", #statuses+1)
			Grid2:DbSetValue( "statuses", name, {type = "raid-debuffs", debuffs={}, color1 = {r=1,g=.5,b=1,a=1}} )
			local status = Grid2.setupFunc["raid-debuffs"]( name, Grid2:DbGetValue("statuses", name) )
			CalculateAvailableStatuses()
			MakeOneStatusStandardOptions( options, status, #statuses )
		end,
		hidden = function() return #statuses>=10 end
	}
	options.del = {
		type = "execute",
		order = 51,
		width = "half",
		name = L["Delete"],
		desc = L["Delete Status"],
		func = function(info) 
			local status = statuses[#statuses]
			options[status.name] = nil
			Grid2:DbSetValue( "statuses", status.name, nil)
			Grid2:UnregisterStatus( status )
			CalculateAvailableStatuses()
		end,
		disabled = function()
			local status = statuses[#statuses]
			return status.enabled or next(status.dbx.debuffs)
		end,
		hidden = function() 
			return #statuses<=1  
		end,
	}
	options.header3 = { type = "header", order = 52, name = "" }
end

local function MakeDefaultDifficultyEJ_LinkOption(options)
	options.difficulty = {
		type = "select",
		order = 200,
		name = "Encounter Journal difficulty",
		desc = "Default difficulty for Encounter Journal links",
		get = function () return GSRD.db.profile.defaultEJ_difficulty or 4 end,
		set = function (_, v) 
			GSRD.db.profile.defaultEJ_difficulty = v
		end,
		values = {
			[1] = "(10) "..PLAYER_DIFFICULTY1,
			[2] = "(25) "..PLAYER_DIFFICULTY1,
			[3] = "(10) "..PLAYER_DIFFICULTY2,
			[4] = "(25) "..PLAYER_DIFFICULTY2,
		},
	}
end

local function MakeGeneralOptions(self)
	local options = {}
	CalculateAvailableStatuses()
	self:MakeStatusTitleOptions( statuses[1], options)
	MakeStandardOptions(options)	
	MakeModulesListOptions(options)
	MakeDefaultDifficultyEJ_LinkOption(options)
	return options
end

local function MakeAdvancedOptions(self)
	local options = {}
	ResetAdvancedOptions()
	optionModules = {
		type = "select",
		order = 10,
		name = L["Select module"],
		desc = "",
		get = function ()
			if curModule=="" then
				local curZone, curZoneModule = GSRD:GetCurrentZone()
				local lastInst, lastInstModule = GSRD.db.profile.lastSelectedInstance
				for module in next, moduleList do
					if RDDB[module][curZone] then
						curZoneModule = module
					elseif RDDB[module][lastInst] then
						lastInstModule = module
					end
				end
				if curZoneModule or lastInstModule then
					curModule = curZoneModule or lastInstModule
					curInstance = curZoneModule and curZone or lastInstModule and lastInst
					optionInstances.values = GetInstances(curModule)
					optionDebuffs.name = GetMapNameByID(curInstance)
					optionDebuffs.args = MakeDebuffsOptions()
					return curModule
				end
				curModule = next(moduleList) or ""
				curInstance = ""
				optionInstances.values = GetInstances(curModule)
				optionDebuffs.name= ""
				optionDebuffs.args = {}
			end
			return curModule
		end,
		set = function (info, v)
			curModule= v
			curInstance=""
			optionInstances.values = GetInstances(v)
			optionDebuffs.name= ""
			optionDebuffs.args = {}
		end,
		values = moduleList,
	}
	optionInstances= {
		type = "select",
		order = 20,
		name = L["Select instance"],
		desc = "",
		get = function () return curInstance end,
		set = function (_, v)
			curInstance = v
			optionDebuffs.name = GetMapNameByID(v)
			optionDebuffs.args = MakeDebuffsOptions()
			GSRD.db.profile.lastSelectedInstance = v
		end,
		values= {}
	}
	optionDebuffs = {
		type ="group",
		name ="",
		order = 30,
		childGroups = "tree",
		args = {},
	}
	options.modules  = optionModules
	options.instances= optionInstances
	options.debuffs  = optionDebuffs
	return options
end

-- Notify Grid2Options howto create the options for our status
Grid2Options:RegisterStatusOptions("raid-debuffs", "debuff", function(self, status, options)
	options.general= {
			type = "group",
			name = L["General Settings"],
			order = 20,
			args = MakeGeneralOptions(self),
		}
	options.advanced= {
			type = "group",
			name = L["Debuff Configuration"],
			order = 10,
			args = MakeAdvancedOptions(self),
		}

end, {
	hideTitle    = true,
	childGroups  = "tab",
	groupOrder   = 5,
	masterStatus = "raid-debuffs", 
	titleIcon    = "Interface\\Icons\\Spell_Shadow_Skull", -- DemonicEmpathy",
})
