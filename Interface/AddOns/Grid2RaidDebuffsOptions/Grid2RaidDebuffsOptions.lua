-- Grid2RaidDebuffsOptions, Created by Michael
local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local GSRD = Grid2:GetModule("Grid2RaidDebuffs")

Grid2Options:RegisterStatusOptions("raid-debuffs", "debuff", function(self, status, options)
	self.RDO:Init()
	local empty = not (next(GSRD.db.profile.enabledModules) or next(GSRD.db.profile.debuffs))
	options.general= {
			type = "group",
			name = L["General Settings"],
			order = empty and 10 or 20,
			args = self.RDO.OPTIONS_GENERAL,
		}
	options.advanced= {
			type = "group",
			name = L["Debuff Configuration"],
			order = empty and 20 or 10,
			args = self.RDO.OPTIONS_ADVANCED,
		}
end, {
	hideTitle    = true,
	childGroups  = "tab",
	groupOrder   = 5,
	titleIcon    = "Interface\\Icons\\Spell_Shadow_Skull", 
	-- To avoid creating options for raid-debuffs(2), raid-debuffs(3), etc.
	masterStatus = "raid-debuffs",
})

--===================================================================

Grid2Options.RDO = {
	-- Grid2RaidDebuffs status acedb database
	db = GSRD.db,
	-- Static raid debuffs database modules
	RDDB = {},
	-- raid-debuffs statuses
	statuses = {},
	statusesIndexes = {},
	statusesNames = {},
	-- debuffs autodetection
	auto_enabled = nil,
}
local RDO  = Grid2Options.RDO
local RDDB = RDO.RDDB

--===================================================================

-- Called from debuffs database modules (see: RaidDebuffsWoW.lua)
function Grid2Options:GetRaidDebuffsTable()
	return RDDB
end

-- Initialization (Called on first run or when acedb profile change)
function RDO:Init()
	self:FixWrongInstances()
	self:LoadStatuses()
	self:InitAutodetect()
	self:InitAdvancedOptions()
	self:InitGeneralOptions()
end

-- Trying to fix or delete instances in old database formats, now the 
-- instance keys must be integers, we don't allow strings.
function RDO:FixWrongInstances()
	local saved = {}
	for mapid, data in pairs(RDO.db.profile.debuffs) do
		if type(mapid)~="number" then
			if tonumber(mapid) then saved[tonumber(mapid)] = data end
			RDO.db.profile.debuffs[mapid] = nil
		end
	end
	for k,v in pairs(saved) do
		RDO.db.profile.debuffs[k] = v
	end
end

-- Methods shared by different configuration modules
function RDO:LoadStatuses()
	wipe(self.statuses)
	wipe(self.statusesIndexes)
	wipe(self.statusesNames)
	for _,status in Grid2:IterateStatuses() do
		if status.dbx and status.dbx.type == "raid-debuffs" then
			self.statuses[#self.statuses+1] = status
		end
	end
	table.sort( self.statuses, function(a,b) return (tonumber(strmatch(a.name,"(%d+)")) or 1) < (tonumber(strmatch(b.name,"(%d+)")) or 1) end )
	local text = L["raid-debuffs"]
	for index,status in ipairs(self.statuses) do
		self.statusesIndexes[status] = index
		self.statusesNames[index] = string.format( "%s(%d)", text, index )
	end	
	self.statusesNames[1] = text
end

function RDO:EnableInstanceAllDebuffs(curModule, curInstance)
	local debuffs = {}
	for instance,values in pairs(RDDB[curModule][curInstance]) do
		for boss,spellId in ipairs(values) do
			debuffs[#debuffs+1] = spellId
		end
	end
	local rddbx = RDO.db.profile.debuffs
	if rddbx and rddbx[curInstance] then
		for instance,boss in pairs(rddbx[curInstance]) do
			for _,spellId in ipairs(boss) do
				debuffs[#debuffs+1] = spellId
			end
		end
	end	
	self.statuses[1].dbx.debuffs[curInstance]= debuffs
	self:UpdateZoneSpells(curInstance)
end

function RDO:DisableInstanceAllDebuffs(curInstance)
	for index,status in ipairs(self.statuses) do
		status.dbx.debuffs[curInstance] = nil
	end
	self:UpdateZoneSpells(curInstance)
end

function RDO:UpdateZoneSpells(instance)
	if (not instance) or instance == GSRD:GetCurrentZone() then
		GSRD:UpdateZoneSpells()
	end
end

function RDO:ExportData(data)
	local AceGUI = LibStub("AceGUI-3.0")
	local frame = AceGUI:Create("Frame")
	frame:SetTitle("LUA CODE Export")
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget); collectgarbage() end)
	frame:SetWidth(350)
	frame:SetHeight(150)
	local edit = AceGUI:Create("MultiLineEditBox")
	edit:SetFullWidth(true)
	edit:SetFullHeight(true)
	frame:AddChild(edit)
	edit:SetLabel("Press CTRL-C to copy data to Clipboard")
	edit:DisableButton(true)
	edit:SetText(data)
	edit.editBox:SetFocus()
	edit.editBox:HighlightText()
end

-- Util functions to access nested tables values
function RDO.DbGetValue(db, ...)
   local count = select("#",...)
   for i = 1, count do
      local field = select(i,...)
      if not (field and db[field]) then return end
      db = db[field]
   end
   return db
end

function RDO.DbSetValue(value, db, ...)
   local count = select("#",...)
   for i = 1, count-1 do
      local field = select(i,...)
      if not db[field] then db[field] = {} end
      db = db[field]
   end
   db[select(count,...)] = value
   return #db
end

function RDO.DbAddTableValue(value, db, ...)
	local count = select("#",...)
	for i = 1, count do
		local field = select(i,...)
		if db[field]==nil then db[field] = {} end	
		db = db[field]
	end
	db[#db+1] = value
	return #db
end

function RDO.DbDelTableValue(value, db, ...)
   local count = select("#",...)
   local function Remove(dbi, index, ...)
		if index<=count then
			local field = select(index, ...)
			local data = dbi[field]
			if data then
				Remove(data, index+1, ...)
				if not next(data) then dbi[field] = nil end
			end    
		else
			local i = 1
			while i<=#dbi do
				if dbi[i] == value then
					table.remove(dbi,i)
				else
					i = i + 1
				end
			end
			if #dbi==0 then wipe(dbi) end
		end
   end
   Remove(db, 1, ...)
end

--===================================================================
