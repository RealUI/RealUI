local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Tell Target (/tt)", "AceHook-3.0", "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Tell Target (/tt)"]

local UnitIsPlayer = _G.UnitIsPlayer
local UnitCanAssist = _G.UnitCanAssist
local UnitIsCharmed = _G.UnitIsCharmed
local SendChatMessage = _G.SendChatMessage
local UnitIsSameServer = _G.UnitIsSameServer
local UnitName = _G.UnitName

local gsub = _G.string.gsub

function mod:OnEnable()
	-- self:SecureHook("ChatEdit_ParseText")
	for i = 1, NUM_CHAT_WINDOWS do
		self:HookScript(_G["ChatFrame" .. i .. "EditBox"], "OnTextChanged")
	end
	if not self.slashCommandRegistered then
		self:RegisterChatCommand("tt", "SendChatMessage")
		self.slashCommandRegistered = true
	end
end

function mod:OnTextChanged(obj)
	local text = obj:GetText()
	if text:sub(1, 4) == "/tt " then
		self:TellTarget(obj.chatFrame, text:sub(5))
	end
	self.hooks[obj].OnTextChanged(obj)
end
	
function mod:TellTarget(frame, msg)	
	local unitname, realm
	if UnitIsPlayer("target") and (UnitIsFriend("player", "target") or UnitIsCharmed("target"))  then
		unitname, realm = UnitName("target")
		if unitname then unitname = gsub(unitname, " ", "") end
		if unitname and not UnitIsSameServer("player", "target") then
			unitname = unitname .. "-" .. gsub(realm, " ", "")
		end
	end
	ChatFrame_SendTell((unitname or "InvalidTarget"), frame)
	_G[frame:GetName() .. "EditBox"]:SetText(msg)
end

function mod:Info()
	return L["Enables the /tt command to send a tell to your target."]
end

function mod:SendChatMessage(input)
	if UnitIsPlayer("target") and (UnitCanAssist("player", "target") or UnitIsCharmed("target"))then
		SendChatMessage(input, "WHISPER", nil, UnitName("target"))
	end
end

