local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Invite Links", "AceHook-3.0","AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Invite Links"]

local gsub = _G.string.gsub
local ipairs = _G.ipairs
local fmt = _G.string.format
local sub = _G.string.sub
local InviteUnit = _G.InviteUnit
local next = _G.next
local type = _G.type
local IsAltKeyDown = _G.IsAltKeyDown
local match = _G.string.match

local options = {
	addWord = {
		type = "input",
		name = L["Add Word"],
		desc = L["Add word to your invite trigger list"],
		get = function() end,
		set = function(info, v)
			mod.db.profile.words[v:lower()] = v
		end
	},
	removeWord = {
		type = "select",
		name = L["Remove Word"],
		desc = L["Remove a word from your invite trigger list"],
		get = function() end,
		set = function(info, v)
			mod.db.profile.words[v:lower()] = nil
		end,
		values = function() return mod.db.profile.words end,
		confirm = function(info, v) return (L["Remove this word from your trigger list?"]) end
	},
	altClick = {
		type = "toggle",
		name = L["Alt-click name to invite"],
		width = "double",
		desc = L["Lets you alt-click player names to invite them to your party."],
		get = function() return mod.db.profile.altClickToinvite end,
		set = function(i, v) mod.db.profile.altClickToinvite = v end
	}
}

local defaults = {
	profile = {
		words = {},
		altClickToInvite = true
	}
}

local words

local valid_events = {
	CHAT_MSG_SAY = true,
	CHAT_MSG_CHANNEL = true,
	CHAT_MSG_WHISPER = true,
	CHAT_MSG_OFFICER = true,
	CHAT_MSG_GUILD = true
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace(self:GetName(), defaults)
end

function mod:Decorate(frame)
	self:RawHook(frame, "AddMessage", true)
end

local chatEvent, chatEventTarget

function mod:ChatFrame_MessageEventHandler(frame, event, ...)
	chatEvent = event
	local arg1,chatEventTarget = ...
	return self.hooks["ChatFrame_MessageEventHandler"](frame, event, ...)
end

function mod:OnEnable()
	words = self.db.profile.words
	if not next(words) then
		words[L["invite"]] = L["invite"]
		words[L["inv"]] = L["inv"]
	end
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		if cf ~= COMBATLOG then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	self:RawHook(nil, "SetItemRef", true)
	self:RawHook("ChatFrame_MessageEventHandler", true)
end

local style = "|cffffffff|Hinvite:%s|h[%s]|h|r"

local function addLinks(m, t, p)
	if words[t:lower()] and p ~= "_" then
		t = fmt(style, chatEventTarget, t)
		return t .. p
	end
	return m
end

function mod:AddMessage(frame, text, ...)
	if not text then 
		return self.hooks[frame].AddMessage(frame, text, ...)
	end
	if valid_events[chatEvent] and type(chatEventTarget) == "string" then
		text = gsub(text, "((%w+)(.?))", addLinks)
	end
		
	return self.hooks[frame].AddMessage(frame, text, ...)
end

function mod:SetItemRef(link, text, button)
	local linkType = sub(link, 1, 6)
	-- Chatter:Print(IsAltKeyDown(), linkType, self.db.profile.altClickToInvite)
	if IsAltKeyDown() and linkType == "player" and self.db.profile.altClickToInvite then
		local name = match(link, "player:([^:]+)")
		InviteUnit(name)
		return nil
	elseif linkType == "invite" then
		local name = sub(link, 8)
		InviteUnit(name)
		return nil
	end
	return self.hooks.SetItemRef(link, text, button)
end

function mod:Info()
	return L["Gives you more flexibility in how you invite people to your group."]
end

function mod:GetOptions()
	return options
end
