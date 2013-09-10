----------------------------------
-- Pull timers
----------------------------------

local addon = DXE
local L = addon.L

local ipairs, pairs = ipairs, pairs
local remove,wipe = table.remove,table.wipe
local match,len,format,split,find = string.match,string.len,string.format,string.split,string.find

local pfl,gb

----------------------------------
-- INITIALIZATION
----------------------------------

local module = addon:NewModule("Pull","AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
addon.Pull = module
local Alerts = addon.Alerts

function module:RefreshProfile() pfl = self.db.profile end

function module:OnInitialize()
	self.db = addon.db:GetNamespace("Alerts", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
end

function module:OnEnable()
	self:RegisterComm("D4")
	self:RegisterComm("BigWigs")
end

----------------------------------
-- COMM RECEIVED
----------------------------------
--RaidBossEmoteFrame:UnregisterAllEvents()
function module:OnCommReceived(prefix, msg, dist, sender)
	if sender == addon.PNAME then
		return
	end
	--print("A",prefix, dist, sender)
	if prefix == "D4" then
		--	print(msg:gsub("\t", "__"))
		local handler, time, name = ("\t"):split(msg)
		
		if handler == "PT" then
			time = tonumber(time)
			if not sender then sender = "unknown" end
			--print("teste pull PULL plugin",time,sender)
			--addon:FireStuff(sender,time)
			fire(sender..L.alert[": Pulling"],time,pfl.CustomRaidClr,"Interface\\Icons\\INV_Misc_PocketWatch_01")
		end
	--[[elseif prefix == "BigWigs" then
		local time, text = string.match(msg, "BWCustomBar%s*(%d+)%s*(.+)")
		local handler, time2, name = ("T:"):split(msg)
		local sync, rest = msg:match("(%S+)%s*(.*)$")
		
		time = tonumber(time)
		print("Bigwigs",msg,time,text,sender,name,sync,handler,time2)
		if handler == "BWPull" then
			print("BWPull found",rest)
		end--]]
	end
end

---------------------------------------------
-- CUSTOM BARS
---------------------------------------------

do
	local L_ICON = "Interface\\Icons\\INV_Misc_PocketWatch_02"
	local R_ICON = "Interface\\Icons\\INV_Misc_PocketWatch_01"
	local YOU_PREFIX = L["YOU"]..": "
	local ID_PREFIX = "custom"
	local MSG_PTN = "^([%d:]+)%s+(.*)"
	local MSG_PTN2 = "^([%d:]+)(.*)"
	local TIME_PTN = "^(%d+):(%d+)$"
	local DROPDOWN_THRES = 15
	local FORMAT_ERROR = L["Invalid input. Usage: |cffffd200%s time text|r"]
	local TIME_ERROR = L["Invalid time. The format must be |cffffd200minutes:seconds|r or |cffffd200seconds|r (e.g. 1:30 or 90)"]
	local OFFICER_ERROR = L["You need to have raid assist"]
	local COMMTYPE = "AlertsRaidBar"

	function fire(text,time,color,icon,audiotime)
		local id = ID_PREFIX..text
		Alerts:QuashByPattern(id)
		if time > DROPDOWN_THRES then
			Alerts:Dropdown(id,text,time,DROPDOWN_THRES,pfl.CustomSound,color,nil,nil,icon,true)
		else
			Alerts:CenterPopup(id,text,time,nil,pfl.CustomSound,color,nil,nil,icon,true)
		end
	end

	local helpers = {
		function() return UnitExists("target") and UnitName("target") or "<<"..L["None"]..">>" end,
	}

	local function replace(text)
		text = gsub(text,"%%t",helpers[1]())
		return text
	end

	local function parse(msg,slash)
		if type(msg) ~= "string" then addon:Print(format(FORMAT_ERROR,slash)) return end
		local time,text = msg:match(MSG_PTN)
		if not time then
			time = msg:match(MSG_PTN2)
			if not time then
				addon:Print(format(FORMAT_ERROR,slash)) 
				return
			end
		end
		if not text then text = L.alert["Pulling"] end
		local secs = tonumber(time)
		if not secs then
			local m,s = time:trim():match(TIME_PTN)
			if m then secs = (tonumber(m)*60) + tonumber(s)
			else addon:Print(TIME_ERROR) return end
		end
		return true,secs,replace(text)
	end

	local function LocalBarHandler(msg)
		local success,time,text = parse(msg,"/lpull")
		if success then fire(YOU_PREFIX..text,time + 1,pfl.CustomLocalClr,L_ICON) end
	end

	local function RaidBarHandler(msg)
		if UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") then
			local success,time,text = parse(msg,"/pull")
			if success then
				fire(YOU_PREFIX..text,time + 1,pfl.CustomRaidClr,R_ICON)
				addon:SendRaidComm(COMMTYPE,time,UnitName("player")..": "..text)
				SendAddonMessage("D4", "PT\t".. time, IsPartyLFG() and "INSTANCE_CHAT" or "RAID")
				--addon:SendRaidComm("D4","PT\t".. time, UnitName("player"))
			end
		else
			addon:Print(OFFICER_ERROR)
		end
	end

	module["OnComm"..COMMTYPE] = function(self,event,commType,sender,time,text)
		--if not UnitIsGroupAssistant(sender) then return end --UnitIsRaidOfficer
		if UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") then
			fire(text,time,pfl.CustomRaidClr,R_ICON)
		end
	end

	addon.RegisterCallback(module,"OnComm"..COMMTYPE)

	SlashCmdList.DXEALERTLOCALBAR = LocalBarHandler
	SlashCmdList.DXEALERTRAIDBAR = RaidBarHandler

	--SLASH_DXEALERTLOCALBAR1 = "/dxelb"
	--SLASH_DXEALERTRAIDBAR1 = "/dxerb"
	SLASH_DXEALERTLOCALBAR1 = "/lpull"
	SLASH_DXEALERTRAIDBAR1 = "/pull"
end

--SendAddonMessage("D4", "PT\t".. time, IsPartyLFG() and "INSTANCE_CHAT" or "RAID")
--BIGWIGS
--SendAddonMessage("BigWigs", "T:"..msg, IsPartyLFG() and "INSTANCE_CHAT" or "RAID")