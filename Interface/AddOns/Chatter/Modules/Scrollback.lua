local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Scrollback")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Scrollback"]
mod.toggleLabel = L["Enable Scrollback length modification"]

local defaults = {
	profile = {}
}

local options = {}

local cache = setmetatable({}, {__mode='k'})

local function acquire()
	local t = next(cache) or {}
	cache[t] = nil
	return t
end

local function reclaim(t)
	for k in pairs(t) do
		t[k] = nil
	end
	cache[t] = true
end

local function setlines(frame, lines)
	if frame:GetMaxLines() ~= lines then 
		local history = acquire()
		for regions = frame:GetNumRegions(),1,-1 do
			local region = select(regions, frame:GetRegions())
			if region:GetObjectType() == "FontString" then
				table.insert(history, {region:GetText(), region:GetTextColor() })
			end
		end

		frame:SetMaxLines(lines or 250)

		Chatter.loading = true

		for k,v in pairs(history) do
			frame:AddMessage(unpack(v))
		end

		Chatter.loading = false

		reclaim(history)
	end
end

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("Scrollback", defaults)
	for i = 1, NUM_CHAT_WINDOWS do
		local s = "FRAME_" .. i
		local frame = _G["ChatFrame" .. i]
		options[s] = {
			type = "range",
			name = L["Chat Frame "] .. i,
			desc = L["Chat Frame "] .. i,
			min = 250,
			max = 2500,
			step = 10,
			get = function() return self.db.profile[s] or 250 end,
			set = function(info, value)
				self.db.profile[s] = value
				setlines(frame, value)
			end
		}
	end
end

function mod:OnEnable()
	for i = 1, NUM_CHAT_WINDOWS do
		setlines(_G["ChatFrame"..i], self.db.profile["FRAME_"..i])
	end
end

function mod:OnDisable()
	for i = 1, NUM_CHAT_WINDOWS do
		setlines(_G["ChatFrame"..i], 250)
	end
end

function mod:GetOptions()
	return options
end

function mod:Info()
	return L["Lets you set the scrollback length of your chat frames."]
end
