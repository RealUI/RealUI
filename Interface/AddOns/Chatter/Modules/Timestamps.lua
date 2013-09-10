local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Timestamps", "AceHook-3.0","AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Timestamps"]

local date = _G.date

local SELECTED_FORMAT
local COLOR
local FORMATS = {
	["%I:%M:%S %p"] = L["HH:MM:SS AM (12-hour)"],
	["%I:%M:S"] = L["HH:MM (12-hour)"],
	["%X"] = L["HH:MM:SS (24-hour)"],
	["%I:%M"] = L["HH:MM (12-hour)"],
	["%H:%M"] = L["HH:MM (24-hour)"],
	["%M:%S"] = L["MM:SS"],
}
local CHATFRAMES = {
	["Frame1"] = L["Chat Frame "].."1",
	["Frame3"] = L["Chat Frame "].."3",
	["Frame4"] = L["Chat Frame "].."4",
	["Frame5"] = L["Chat Frame "].."5",
	["Frame6"] = L["Chat Frame "].."6",
	["Frame7"] = L["Chat Frame "].."7",
	["Frame8"] = L["Chat Frame "].."8",
	["Frame9"] = L["Chat Frame "].."9",
	["Frame10"] = L["Chat Frame "].."10",
	["Frame11"] = L["Chat Frame "].."11",
	["Frame12"] = L["Chat Frame "].."12",
	["Frame13"] = L["Chat Frame "].."13",
	["Frame14"] = L["Chat Frame "].."14",
	["Frame15"] = L["Chat Frame "].."15",
	["Frame16"] = L["Chat Frame "].."16",
	["Frame17"] = L["Chat Frame "].."17",
	["Frame18"] = L["Chat Frame "].."18",
	["Frame19"] = L["Chat Frame "].."19",
	["Frame20"] = L["Chat Frame "].."20",
}

local defaults = {
	profile = { format = "%X", color = { r = 0.45, g = 0.45, b = 0.45 }, frames = {["Frame1"] = true, ["Frame3"] = true, ["Frame4"] = true, ["Frame5"] = true, ["Frame6"] = true, ["Frame7"] = true, ["Frame11"]=true,["Frame12"]=true,["Frame13"]=true,["Frame14"]=true,["Frame15"]=true,["Frame16"]=true,["Frame17"]=true,["Frame18"]=true,["Frame19"]=true,["Frame20"]=true,} }
}

local options = {
	format = {
		type = "select",
		name = L["Timestamp format"],
		desc = L["Timestamp format"],
		values = FORMATS,
		get = function() return mod.db.profile.format end,
		set = function(info, v)
			mod.db.profile.format = v
			SELECTED_FORMAT = ("[" .. v .. "]")
		end
	},
	customFormat = {
		type = "input",
		name = L["Custom format (advanced)"],
		desc = L["Enter a custom time format. See http://www.lua.org/pil/22.1.html for a list of valid formatting symbols."],
		get = function() return mod.db.profile.customFormat end,
		set = function(info, v)
			if #v == 0 then v = nil end
			mod.db.profile.customFormat = v
			SELECTED_FORMAT = v
		end,
		order = 101		
	},
	color = {
		type = "color",
		name = L["Timestamp color"],
		desc = L["Timestamp color"],
		get = function()
			local c = mod.db.profile.color
			return c.r, c.g, c.b
		end,
		set = function(info, r, g, b, a)
			local c = mod.db.profile.color
			c.r, c.g, c.b = r, g, b
			COLOR = ("%02x%02x%02x"):format(r * 255, g * 255, b * 255)
		end,
		disabled = function() return mod.db.profile.colorByChannel end
	},
	useChannelColor = {
		type = "toggle",
		name = L["Use channel color"],
		desc = L["Color timestamps the same as the channel they appear in."],
		get = function()
			return mod.db.profile.colorByChannel
		end,
		set = function(info, v)
			mod.db.profile.colorByChannel = v
		end
	},
	frames = {
		type = "multiselect",
		name = L["Per chat frame settings"],
		desc = L["Choose which chat frames display timestamps"],
		values = CHATFRAMES,
		get = function(info, k) return mod.db.profile.frames[k] end,
		set = function(info, k, v) mod.db.profile.frames[k] = v end,
	},
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("Timestamps", defaults)
end

function mod:Decorate(frame)
	self:RawHook(frame, "AddMessage", true)
end

function mod:OnEnable()
	SELECTED_FORMAT = mod.db.profile.customFormat or ("[" .. self.db.profile.format .. "]")
	local c = self.db.profile.color	
	COLOR = ("%02x%02x%02x"):format(c.r * 255, c.g * 255, c.b * 255)
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
end

function mod:AddMessage(frame, text, ...)
	local id = frame:GetID()
	if id and self.db.profile.frames["Frame"..id] and not(CHAT_TIMESTAMP_FORMAT) then
		if not Chatter.loading then
			if not text then 
				return self.hooks[frame].AddMessage(frame, text, ...)
			end
			if self.db.profile.colorByChannel then
				text = date(SELECTED_FORMAT) .. text
			else
				text = "|cff"..COLOR..date(SELECTED_FORMAT).."|r".. text
			end
		end
		return self.hooks[frame].AddMessage(frame, text, ...)
	end
	return self.hooks[frame].AddMessage(frame, text, ...)
end

function mod:Info()
	return L["Adds timestamps to chat."]
end

function mod:GetOptions()
	return options
end
