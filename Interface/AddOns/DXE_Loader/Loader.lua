--[[
	Metadata
		X-DXE-Boot [NUMBER] - 1/0
		X-DXE-Zone: [STRING] - A zone or a comma separated list of zones
		X-DXE-LoadWithZone:  [NUMBER] - A ID or a comma separated list of IDs
		X-DXE-Category: [STRING] - The category of the module. Only needed if X-DXE-Zone is a list.
]]

local addon
local module = CreateFrame("Frame")
local L = LibStub("AceLocale-3.0"):GetLocale("DXE")

local CORE_ADDON = "DXE"
local Z_MODS = {} -- Zone modules
local Z_MODS_LIST = {}
local ID_MODS = {} -- ID modules
local ID_MODS_LIST = {}
local BossMods = {}
local B_MODS = {} -- Boot modules
local saved_command

module.Z_MODS_LIST = Z_MODS_LIST
module.ID_MODS_LIST = ID_MODS_LIST

function module:Load(name) if not select(4,GetAddOnInfo(name)) then EnableAddOn(name) end LoadAddOn(name) end

function module:CleanZoneModules(name)
	for zone,list in pairs(Z_MODS) do
		for k in pairs(list) do
			if k == name then Z_MODS[zone][name] = nil break end
		end
		Z_MODS[zone] = next(Z_MODS[zone]) and Z_MODS[zone]
	end
	Z_MODS = next(Z_MODS) and Z_MODS
	Z_MODS_LIST[name] = nil
	if not Z_MODS then 
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		self.CleanZoneModules, self.ZONE_CHANGED_NEW_AREA = nil,nil 
	end
end--[[
function module:CleanIDModules(name)
	for zone,list in pairs (ID_MODS) do
		for k in pairs(list) do
			if k == name then ID_MODS[zone][name] = nil break end
		end
		ID_MODS[zone] = next(ID_MODS[zone]) and ID_MODS[zone]
	end
	ID_MODS = next(ID_MODS) and ID_MODS
	ID_MODS_LIST[name] = nil
	if not ID_MODS then 
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		self.CleanIDModules, self.ZONE_CHANGED_NEW_AREA = nil,nil 
	end
end--]]
function module:ZONE_CHANGED_NEW_AREA()
	SetMapToCurrentZone()
	local zoneid = GetCurrentMapAreaID()
	local zone = GetRealZoneText()
	if not zone or zone == "" then return end
	--print("teste",zone,zoneid)
	if Z_MODS[zone] then for name in pairs(Z_MODS[zone]) do self:Load(name) end --end
	else
		if ID_MODS[zoneid] then
			for name, data in pairs(ID_MODS[zoneid]) do
				--print("DSFDS",ID_MODS[zoneid],data,data.name)
				self:Load(data.name)
			end
		end
	end
end

function module:ADDON_LOADED(name)
	if name == "DXE_Loader" then
		self:SetupBroker()
	elseif name == CORE_ADDON then
		addon = DXE
		addon.Loader = module
		for name in pairs(B_MODS) do self:Load(name) end
		B_MODS = nil
		if saved_command then
			DXE_SLASH_HANDLER(saved_command)
			saved_command = nil
		end
	end
	local zmeta = GetAddOnMetadata(name,"X-DXE-Zone")
	local raidname
	if ID_MODS_LIST[name] then
		--self:CleanIDModules(name)
		self:CleanZoneModules(name)
		addon.callbacks:Fire("OnLoadZoneModule")
		if zmeta then raidname = zmeta
		else raidname = name end
	else
		if Z_MODS_LIST[name] then
			self:CleanZoneModules(name)
			--self:CleanIDModules(name)
			addon.callbacks:Fire("OnLoadZoneModule")
			if zmeta then	raidname = zmeta
			else raidname = name end
		end
	end
	if raidname then print("|cff99ff33DXE|r: Loaded Raid|cff99ff33",raidname) end
	if not B_MODS and not Z_MODS and not ID_MODS then self:UnregisterEvent("ADDON_LOADED"); self.ADDON_LOADED = nil end
end

local function AddZoneModule(name,zone,...)
	if not zone then return end
	zone = L.zone[zone:trim()]
	Z_MODS[zone] = Z_MODS[zone] or {}
	Z_MODS[zone][name] = true
	return AddZoneModule(name,...)
end

function module:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")
	if select(6,GetAddOnInfo(CORE_ADDON)) == "MISSING" then error(("DXE requires %s to be installed"):format(CORE_ADDON)) end

	for i=1,GetNumAddOns() do
		local name = GetAddOnInfo(i)
		if IsAddOnLoadOnDemand(name) and not IsAddOnLoaded(name) then
			-- Backwards Compability
			local zmeta = GetAddOnMetadata(i,"X-DXE-Zone")
			local bmeta = GetAddOnMetadata(i,"X-DXE-Boot")
			if zmeta then
				local cmeta = GetAddOnMetadata(i,"X-DXE-Category")
				Z_MODS_LIST[name] = L.zone[cmeta or zmeta]
				AddZoneModule(name,strsplit(",",zmeta))
			elseif tonumber(bmeta) == 1 then
				B_MODS[name] = true
			end
			---------New Loader--------------------
			if GetAddOnMetadata(i, "X-DXE-LoadWithZone") then
				local zones = {strsplit(",", GetAddOnMetadata(i, "X-DXE-LoadWithZone") or "")}
				for i, zone in pairs(zones) do
					local zoneNumber = tonumber(zone)
					if not zoneNumber then zoneNumber = zone end
					ID_MODS_LIST[name] = name
					ID_MODS[zoneNumber] = ID_MODS[zoneNumber] or {}
					ID_MODS[zoneNumber][name] = {
						name = name,
					}				
					--ID_MODS[zoneNumber] = true
					--print("x-Dxe",zmeta,zoneNumber,ID_MODS_LIST[name])
				end
			end

		end
	end
	if next(Z_MODS) or next(ID_MODS) then self:RegisterEvent("ZONE_CHANGED_NEW_AREA") end
	self:ZONE_CHANGED_NEW_AREA()

	self.PLAYER_LOGIN = nil
end

function module:SetupBroker()
	local LDB = LibStub("LibDataBroker-1.1",true)
	if not LDB then return end

	local function refresh()
		-- Refreshes Text
		if GameTooltipTextLeft2:GetText() == L.loader["|cffffff00Click|r to load"] then
			GameTooltip:ClearLines()
			GameTooltip:AddLine(L.loader["Deus Vox Encounters"])
			GameTooltip:AddLine(L.loader["|cffffff00Click|r to toggle the settings window"],1,1,1)
			GameTooltip:Show()
		end
	end

	local launcher = LDB:NewDataObject("DXE", {
		type = "launcher",
		icon = "Interface\\Addons\\DXE_Loader\\Icon",
		OnClick = function(_, button)
			if addon then
				addon:ToggleConfig() 
			else
				module:Load(CORE_ADDON)
				refresh(); refresh = nil
			end
		end,
		OnTooltipShow = function(tooltip)
			if addon then
				tooltip:AddLine(L.loader["Deus Vox Encounters"])
				tooltip:AddLine(L.loader["|cffffff00Click|r to toggle the settings window"],1,1,1)
			else
				tooltip:AddLine(L.loader["Deus Vox Encounters"])
				tooltip:AddLine(L.loader["|cffffff00Click|r to load"],1,1,1)
			end
		end,
	})

	local LDBIcon = LibStub("LibDBIcon-1.0",true)
	if not LDBIcon then return end
	DXEIconDB = DXEIconDB or {}
	LDBIcon:Register("DXE",launcher,DXEIconDB)

	self.SetupBroker = nil
end

SLASH_DXE1 = "/dxe"
function DXE_SLASH_HANDLER(msg)
	if not addon then
		saved_command = msg
		module:Load(CORE_ADDON)
	end
end
SlashCmdList.DXE = function(msg) DXE_SLASH_HANDLER(msg) end
--[[
function module:UPDATE_MOUSEOVER_UNIT()
	if IsInInstance() ~= nil then 
		return 
	end 
	local guid = UnitGUID("mouseover")

	if guid and (bit.band(guid:sub(1, 5), 0x00F) == 3 or bit.band(guid:sub(1, 5), 0x00F) == 5) then
		local cId = tonumber(guid:sub(6, 10), 16)

		if (cId == 62346 or cId == 60491 or cId == 69161) and not IsAddOnLoaded("DXE_WorldBosses") then--Mists of Pandaria World Bosses: Anger, Salyis
			module:Load("DXE_WorldBosses")
		end
	end

	
end
--]]
module:SetScript("OnEvent",function(self,event,...) self[event](self,...) end)
module:RegisterEvent("PLAYER_LOGIN")
module:RegisterEvent("ADDON_LOADED")
--module:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
--module:RegisterEvent("PLAYER_TARGET_CHANGED")
