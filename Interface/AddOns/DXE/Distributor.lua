----------------------------------
-- DISTRIBUTOR
----------------------------------

-- Credits to Bazaar (by Shadowed) for this idea

local defaults = {
	profile = {
		AutoAccept = true,
	},
}

local addon = DXE
local L = addon.L

local Colors = addon.Media.Colors

local ipairs, pairs = ipairs, pairs
local remove,wipe = table.remove,table.wipe
local match,len,format,split,find = string.match,string.len,string.format,string.split,string.find

local db,pfl

----------------------------------
-- CONSTANTS
----------------------------------

local MAIN_PREFIX = "DXE_D"
local TRANSFER_PREFIX = "DXE_T"
local UL_WAIT = 5

----------------------------------
-- INITIALIZATION
----------------------------------

local module = addon:NewModule("Distributor","AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
addon.Distributor = module

function module:RefreshProfile() pfl = self.db.profile end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("Distributor", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
	--self:RegisterMessage("M_TEST")
	--self:SendMessage("M_TEST")
end

function module:OnEnable()
	self:RegisterComm(MAIN_PREFIX)
end

--function module:M_TEST()
--    print("teste")
--end

----------------------------------
-- INITIAL DISTRIBUTE
----------------------------------
-- The active downloads
local Downloads = {}

-- The active uploads
local Uploads = {}

-- Used to start uploads
function module:Distribute(key,target)
	wipe(Uploads)

	local data = addon.EDB[key]

	if not data or key == "default" or GetNumGroupMembers() == 0 then
		return
	end

	local serialData = self:Serialize(data)
	local length = len(serialData)

	local message = format("UPDATE:%s:%d:%d:%s",key,data.version,length,data.name) -- ex. UPDATE:sartharion:150:800:Sartharion

	Uploads[key] = {
		serialData = serialData,
		length = length,
		name = data.name,
		target = target,
	}

	if target then
		self:SendCommMessage(MAIN_PREFIX, message, "WHISPER", target)
	else
		self:SendCommMessage(MAIN_PREFIX, message, "RAID")
	end

	self:RegisterComm(TRANSFER_PREFIX)
	self:ScheduleTimer("StartUpload",UL_WAIT,key)
	--self:StartUpload(key)
end

----------------------------------
-- MAIN
----------------------------------
function module:Main(msg, dist, sender)
	local type,args = match(msg,"(%w+):(.+)")

	-- Someone wants to send an encounter
	if type == "UPDATE" then
		local key,version,length,name = split(":",args)
		version = tonumber(version)

		local data = addon.EDB[key]

		-- Version check
		if data and data.version < version then
			self:StartReceiving(key,sender,length,name)
		end
	end
end

----------------------------------
-- UPLOAD/DOWNLOAD HANDLERS
----------------------------------
function module:StartUpload(key)
	local ul = Uploads[key]
	local message = format("%s~~%s~~%s","UPLOAD",key,ul.serialData)
--print("a",addon.EDB[key].version)
	if ul.target then
		self:SendCommMessage(TRANSFER_PREFIX, message, "WHISPER",ul.target)
	else
		self:SendCommMessage(TRANSFER_PREFIX, message, "RAID")
	end
	self:ULCompleted(key)
end

function module:StartReceiving(key,sender,length,name)
	Downloads[key] = {
		key = key,
		sender = sender,
		length = length,
		name = name,
	}

	self:RegisterComm(TRANSFER_PREFIX)
end

----------------------------------
-- TRANSFERS
----------------------------------
function module:Transfer(msg, dist, sender)
	local type,key,serialData = match(msg,"(%w+)~~(.+)~~(.+)")

	-- Receiving an upload
	if type == "UPLOAD" then
		local length = len(serialData)

		local dl = Downloads[key]
		if not dl then
			return
		end

		local success, data = self:Deserialize(serialData)
		-- Failed to deserialize
		if not success then
			addon:Print(format(L["Failed to load %s after downloading! Request another distribute from %s"],dl.name,dl.sender))
			return
		end
		-- Do popup if autoaccept disabled
		if not pfl.AutoAccept then
			local popupkey = format("DXE_Confirm_%s",key)
			if not StaticPopupDialogs[popupkey] then
				local STATIC_CONFIRM = {
					text = format(L["%s is sharing an update for %s"],sender,dl.name),
					OnAccept = function()
						self:DLCompleted(key,dl.sender,data)
					end,
					OnCancel = function()
						self:DLRejected()
					end,
					button1 = L["Accept"],
					button2 = L["Reject"],
					timeout = 15,
					whileDead = 1,
					hideOnEscape = 1,
				}
				StaticPopupDialogs[popupkey] = STATIC_CONFIRM
			end
			StaticPopup_Show(popupkey)
		else
			self:DLCompleted(key,dl.sender,data)
		end
	end
end


----------------------------------
-- COMPLETIONS
----------------------------------
function module:ULCompleted(key)
	addon:Print(format(L["%s upload complete"],Uploads[key].name))
end

function module:DLCompleted(key,sender,data)
	addon:UnregisterEncounter(key)
	addon:RegisterEncounter(data)
	addon.RDB[key] = data
	addon:SendWhisperComm(sender,"VersionBroadcast",key,data.version)
	--addon:Print(format(L["%s download from %s complete"],Downloads[key].name,sender))
	self:UnregisterComm(TRANSFER_PREFIX)
	wipe(Downloads[key])
end

function module:DLRejected()
	self:UnregisterComm(TRANSFER_PREFIX)
	wipe(Downloads[key])
end

----------------------------------
-- COMM RECEIVED
----------------------------------

function module:OnCommReceived(prefix, msg, dist, sender)
	if sender == addon.PNAME then
		return
	end
--print("A",prefix, dist, sender) --DXE_T
	if prefix == MAIN_PREFIX then
		self:Main(msg, dist, sender)
	elseif prefix == TRANSFER_PREFIX then
		self:Transfer(msg, dist, sender)
	end
end

