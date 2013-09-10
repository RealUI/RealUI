local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("URL Copy", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["URL Copy"]
local Dialog = LibStub("LibDialog-1.0")

local gsub = _G.string.gsub
local ipairs = _G.ipairs
local pairs = _G.pairs
local fmt = _G.string.format
local sub = _G.string.sub

local tlds
local style = "|cffffffff|Hurl:%s|h[%s]|h|r"
local function Link(link, ...)
	if link == nil then
		return ""
	end
	return mod:RegisterMatch(fmt(style, link, link))
end
local function Link_TLD(link, tld, ...)
	if link == nil or tld == nil then
		return ""
	end
	if tlds[tld:upper()] then
        return mod:RegisterMatch(fmt(style, link, link))
    else
        return mod:RegisterMatch(link)
    end
end

local patterns = {
		-- X://Y url
	{ pattern = "^(%a[%w%.+-]+://%S+)", matchfunc=Link},
	{ pattern = "%f[%S](%a[%w%.+-]+://%S+)", matchfunc=Link},
		-- www.X.Y url
	{ pattern = "^(www%.[-%w_%%]+%.%S+)", matchfunc=Link},
	{ pattern = "%f[%S](www%.[-%w_%%]+%.%S+)", matchfunc=Link},
		-- "W X"@Y.Z email (this is seriously a valid email)
	--{ pattern = '^(%"[^%"]+%"@[-%w_%%%.]+%.(%a%a+))', matchfunc=Link_TLD},
	--{ pattern = '%f[%S](%"[^%"]+%"@[-%w_%%%.]+%.(%a%a+))', matchfunc=Link_TLD},
		-- X@Y.Z email
	{ pattern = "(%S+@[-%w_%%%.]+%.(%a%a+))", matchfunc=Link_TLD},
		-- XXX.YYY.ZZZ.WWW:VVVV/UUUUU IPv4 address with port and path
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link},
		-- XXX.YYY.ZZZ.WWW:VVVV IPv4 address with port (IP of ts server for example)
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link},
		-- XXX.YYY.ZZZ.WWW/VVVVV IPv4 address with path
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)", matchfunc=Link},
		-- XXX.YYY.ZZZ.WWW IPv4 address
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]", matchfunc=Link},
		-- X.Y.Z:WWWW/VVVVV url with port and path
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link_TLD},
		-- X.Y.Z:WWWW url with port (ts server for example)
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link_TLD},
		-- X.Y.Z/WWWWW url with path
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)", matchfunc=Link_TLD},
		-- X.Y.Z url
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+))", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+))", matchfunc=Link_TLD},
}

local options = {
	mangleMumble = {
		type = "toggle",
		name = L["Parse Mumble links"],
		desc = L["Automatically inject your character's name into Mumble links, so you connect with your username prefilled."],
		get = function() return mod.db.profile.mangleMumble end,
		set = function(info, v) mod.db.profile.mangleMumble = v end
	},
	mangleTeamspeak = {
		type = "toggle",
		name = L["Parse Teamspeak 3 links"],
		desc = L["Automatically inject your character's name into Teamspeak 3 links, so you connect with your username prefilled."],
		get = function() return mod.db.profile.mangleTeamspeak end,
		set = function(info, v) mod.db.profile.mangleTeamspeak = v end
	}	
}

do
	
	local defaults = {
		profile = {
			mangleMumble = true,
			mangleTeamspeak = true
		}
	}
	local events = {
		"CHAT_MSG_CHANNEL",
		"CHAT_MSG_EMOTE",
		"CHAT_MSG_GUILD",
		"CHAT_MSG_OFFICER",
		"CHAT_MSG_PARTY",
		"CHAT_MSG_RAID",
		"CHAT_MSG_RAID_LEADER",
		"CHAT_MSG_RAID_WARNING",
		"CHAT_MSG_PARTY_LEADER",
		"CHAT_MSG_SAY",
		"CHAT_MSG_WHISPER","CHAT_MSG_BN_WHISPER",
		"CHAT_MSG_WHISPER_INFORM",
		"CHAT_MSG_YELL",
		"CHAT_MSG_BN_WHISPER_INFORM",
		"CHAT_MSG_BN_CONVERSATION",
		"CHAT_MSG_BN_INLINE_TOAST_BROADCAST"
	}
	function mod:OnInitialize()
		self.db = Chatter.db:RegisterNamespace("UrlCopy", defaults)
		Dialog:Register("ChatterUrlCopyDialog", {
			text = L["URL Copy"],
			width = 500,
			editboxes = {
				{ width = 484,
				  on_escape_pressed = function(self, data) self:GetParent():Hide() end,
				},
			},
			on_show = function(self, data) 
				self.editboxes[1]:SetText(data.url)
				self.editboxes[1]:HighlightText()
				self.editboxes[1]:SetFocus()
			end,
			buttons = {
				{ text = CLOSE, },
			},
			show_while_dead = true,
			hide_on_escape = true,
		})
	end	
	function mod:OnEnable()
		for _,event in ipairs(events) do
			ChatFrame_AddMessageEventFilter(event, self.filterFunc)
		end
		self:RawHook("SetItemRef", true)
	end
	function mod:OnDisable()
		for _,event in ipairs(events) do
			ChatFrame_RemoveMessageEventFilter(event, self.filterFunc)
		end
	end
end

do
	local tokennum, matchTable = 1, {}
	mod.filterFunc = function(frame, event, msg, ...)
		if not msg then return false, msg, ... end
		for i, v in ipairs(patterns) do
			msg = gsub(msg, v.pattern, v.matchfunc)
		end
		for k,v in pairs(matchTable) do
			msg = gsub(msg, k, v)
			matchTable[k] = nil
		end
		return false, msg, ...
	end
	function mod:RegisterMatch(text)
		local token = "\255\254\253"..tokennum.."\253\254\255"
		matchTable[token] = gsub(text, "%%", "%%%%")
		tokennum = tokennum + 1
		return token
	end
end

local mangleLinkForVoiceChat
do
	--[[
	mumble://192.168.1.102:50008?version=1.2.0
	mumble://foo:bar@192.168.1.102:50008?version=1.2.0
	mumble://:bar@192.168.1.102:50008?version=1.2.0
	]]--
	
	-- Messes with Mumble links to inject our own username. Nifty magical!
	local function injectCharacterNameForMumble(scheme, connstr)
		local pre, post = strsplit("@", connstr, 2)
		local new
		if post then
			local user, password = strsplit(":", pre, 2)
			if password then
				new = UnitName("player") .. ":" .. password
			else
				new = UnitName("player")
			end
			new = new .. "@" .. post
		else
			new = UnitName("player") .. "@" .. pre
		end
		return scheme .. new
	end
	
	local buff = {}
	local function addTS3Nickname(...)
		wipe(buff)
		local gotName = false
		for i = 1, select("#", ...) do
			local chunk = select(i, ...)
			local key, val = strsplit("=", chunk, 2)
			if val then
				if strlower(key) ~= "nickname" then
					tinsert(buff, chunk)
					gotName = true
				end
			end
		end
		if not gotName then
			local nick = "nickname=" .. UnitName("player")
			tinsert(buff, nick)
		end
		return table.concat(buff, "&")
	end
	
	--[[
		ts3server://ts3.hoster.com
		ts3server://ts3.hoster.com?
		ts3server://ts3.hoster.com?port=9987&
		ts3server://ts3.hoster.com?port=9987&nickname=UserNickname&password=serverPassword
	]]--
	
	local function injectCharacterNameForTeamspeak(scheme, connstr)
		local url, query = strsplit("?", connstr, 2)
		if query then
			query = addTS3Nickname(strsplit("&", query))
		else
			query = "nickname=" .. UnitName("player")
		end
		return scheme .. url .. "?" .. query
	end
	
	function mangleLinkForVoiceChat(text)
		if mod.db.profile.mangleMumble then
			text = text:gsub("^(mumble://)([^/?]+)", injectCharacterNameForMumble)
		end
		if mod.db.profile.mangleTeamspeak then
			text = text:gsub("^(ts3server://)(.+)", injectCharacterNameForTeamspeak)
		end
		return text
	end
end


function mod:SetItemRef(link, text, button,...)
	if sub(link, 1, 3) == "url" then
		local currentLink = sub(link, 5)
		currentLink = mangleLinkForVoiceChat(currentLink)
		if Dialog:ActiveDialog("ChatterUrlCopyDialog") then
			Dialog:Dismiss("ChatterUrlCopyDialog")
		end
		Dialog:Spawn("ChatterUrlCopyDialog", {url=currentLink})
		return ...
	end
	return self.hooks.SetItemRef(link, text, button, ...)
end

function mod:Info()
	return L["Lets you copy URLs out of chat."]
end

function mod:GetOptions()
	return options
end

tlds = {
ONION = true,
-- Copied from http://data.iana.org/TLD/tlds-alpha-by-domain.txt
-- Version 2008041301, Last Updated Mon Apr 21 08:07:00 2008 UTC
AC = true,
AD = true,
AE = true,
AERO = true,
AF = true,
AG = true,
AI = true,
AL = true,
AM = true,
AN = true,
AO = true,
AQ = true,
AR = true,
ARPA = true,
AS = true,
ASIA = true,
AT = true,
AU = true,
AW = true,
AX = true,
AZ = true,
BA = true,
BB = true,
BD = true,
BE = true,
BF = true,
BG = true,
BH = true,
BI = true,
BIZ = true,
BJ = true,
BM = true,
BN = true,
BO = true,
BR = true,
BS = true,
BT = true,
BV = true,
BW = true,
BY = true,
BZ = true,
CA = true,
CAT = true,
CC = true,
CD = true,
CF = true,
CG = true,
CH = true,
CI = true,
CK = true,
CL = true,
CM = true,
CN = true,
CO = true,
COM = true,
COOP = true,
CR = true,
CU = true,
CV = true,
CX = true,
CY = true,
CZ = true,
DE = true,
DJ = true,
DK = true,
DM = true,
DO = true,
DZ = true,
EC = true,
EDU = true,
EE = true,
EG = true,
ER = true,
ES = true,
ET = true,
EU = true,
FI = true,
FJ = true,
FK = true,
FM = true,
FO = true,
FR = true,
GA = true,
GB = true,
GD = true,
GE = true,
GF = true,
GG = true,
GH = true,
GI = true,
GL = true,
GM = true,
GN = true,
GOV = true,
GP = true,
GQ = true,
GR = true,
GS = true,
GT = true,
GU = true,
GW = true,
GY = true,
HK = true,
HM = true,
HN = true,
HR = true,
HT = true,
HU = true,
ID = true,
IE = true,
IL = true,
IM = true,
IN = true,
INFO = true,
INT = true,
IO = true,
IQ = true,
IR = true,
IS = true,
IT = true,
JE = true,
JM = true,
JO = true,
JOBS = true,
JP = true,
KE = true,
KG = true,
KH = true,
KI = true,
KM = true,
KN = true,
KP = true,
KR = true,
KW = true,
KY = true,
KZ = true,
LA = true,
LB = true,
LC = true,
LI = true,
LK = true,
LR = true,
LS = true,
LT = true,
LU = true,
LV = true,
LY = true,
MA = true,
MC = true,
MD = true,
ME = true,
MG = true,
MH = true,
MIL = true,
MK = true,
ML = true,
MM = true,
MN = true,
MO = true,
MOBI = true,
MP = true,
MQ = true,
MR = true,
MS = true,
MT = true,
MU = true,
MUSEUM = true,
MV = true,
MW = true,
MX = true,
MY = true,
MZ = true,
NA = true,
NAME = true,
NC = true,
NE = true,
NET = true,
NF = true,
NG = true,
NI = true,
NL = true,
NO = true,
NP = true,
NR = true,
NU = true,
NZ = true,
OM = true,
ORG = true,
PA = true,
PE = true,
PF = true,
PG = true,
PH = true,
PK = true,
PL = true,
PM = true,
PN = true,
PR = true,
PRO = true,
PS = true,
PT = true,
PW = true,
PY = true,
QA = true,
RE = true,
RO = true,
RS = true,
RU = true,
RW = true,
SA = true,
SB = true,
SC = true,
SD = true,
SE = true,
SG = true,
SH = true,
SI = true,
SJ = true,
SK = true,
SL = true,
SM = true,
SN = true,
SO = true,
SR = true,
ST = true,
SU = true,
SV = true,
SY = true,
SZ = true,
TC = true,
TD = true,
TEL = true,
TF = true,
TG = true,
TH = true,
TJ = true,
TK = true,
TL = true,
TM = true,
TN = true,
TO = true,
TP = true,
TR = true,
TRAVEL = true,
TT = true,
TV = true,
TW = true,
TZ = true,
UA = true,
UG = true,
UK = true,
UM = true,
US = true,
UY = true,
UZ = true,
VA = true,
VC = true,
VE = true,
VG = true,
VI = true,
VN = true,
VU = true,
WF = true,
WS = true,
YE = true,
YT = true,
YU = true,
ZA = true,
ZM = true,
ZW = true,
}
