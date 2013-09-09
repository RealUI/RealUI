local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Chat Font", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Chat Font"]

local Media = LibStub("LibSharedMedia-3.0")
local pairs = _G.pairs
local player_entered_world = false

local defaults = {
	profile = {
		frames = {}
	}
}

local outlines = {[""] = "None", ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline", ["OUTLINEMONOCHROME"] = "Monochrome"}

local options = {
	font = {
		type = "select",
		name = L["Font"],
		desc = L["Font"],
		dialogControl = 'LSM30_Font',
		values = Media:HashTable("font"),
		get = function() return mod.db.profile.font end,
		set = function(info, v) 
			mod.db.profile.font = v
			mod:SetFont(nil, v)
		end
	},
	fontsize = {
		type = "range",
		name = L["Font size"],
		desc = L["Font size"],
		min = 4,
		max = 30,
		step = 1,
		bigStep = 1,
		get = function() return mod.db.profile.fontsize end,
		set = function(info, v)
			mod.db.profile.fontsize = v
			mod:SetFont(nil, nil, v)
		end
	},
	outline = {
		type = "select",
		name = L["Font Outline"],
		desc = L["Font outlining"],
		values = outlines,
		get = function() return mod.db.profile.outline or "" end,
		set = function(info, v) 
			mod.db.profile.outline = v
			mod:SetFont(nil, nil, nil, v)
		end
	}
}

function mod:OnInitialize()
	for i = 1, NUM_CHAT_WINDOWS do
		defaults.profile.frames["FRAME_" .. i] = {}
	end
	self.db = Chatter.db:RegisterNamespace("ChatFont", defaults)
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		local t = {
			type = "group",
			name = L["Chat Frame "] .. i,
			desc = L["Chat Frame "] .. i,
			args = {
				fontsize = {
					type = "range",
					name = L["Font size"],
					desc = L["Font size"],
					min = 4,
					max = 30,
					step = 1,
					bigStep = 1,
					get = function() return mod.db.profile.frames["FRAME_" .. i].fontsize or mod.db.profile.fontsize end,
					set = function(info, v)
						mod.db.profile.frames["FRAME_" .. i].fontsize = v
						mod:SetFont(cf, nil, v)
					end
				},
				font = {
					type = "select",
					name = L["Font"],
					desc = L["Font"],
					dialogControl = 'LSM30_Font',
					values = Media:HashTable("font"),
					get = function() return mod.db.profile.frames["FRAME_" .. i].font or mod.db.profile.font end,
					set = function(info, v) 
						mod.db.profile.frames["FRAME_" .. i].font = v
						mod:SetFont(cf, v)
					end
				},
				outline = {
					type = "select",
					name = L["Font Outline"],
					desc = L["Font outlining"],
					values = outlines,
					get = function() return mod.db.profile.frames["FRAME_" .. i].outline or "" end,
					set = function(info, v) 
						mod.db.profile.frames["FRAME_" .. i].outline = v
						mod:SetFont(cf, nil, nil, v)
					end
				}
			}
		}
		options["frame" .. i] = t
	end	
end

function mod:LibSharedMedia_Registered()
	self:SetFont()
end

function mod:Popout(frame,src)
	local fontName, fontHeight, fontFlags = src:GetFont()
	frame:SetFont(fontName,fontHeight,fontFlags)
end

function mod:OnEnable()
	Media.RegisterCallback(mod, "LibSharedMedia_Registered")
	self:LibSharedMedia_Registered()
	if not player_entered_world then
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end

function mod:PLAYER_ENTERING_WORLD()
	self:SetFont()
	self:UnregisterAllEvents()
	player_entered_world = true
end

function mod:OnDisable()
	Media.UnregisterCallback(mod, "LibSharedMedia_Registered")
	self:SetFont(nil, "Arial Narrow", 12, "")
end

function mod:SetFont(cf, font, size, outline)
	if cf then		
		self:SetFrameFont(cf, font, size, outline)
	else
		for i = 1, NUM_CHAT_WINDOWS do
			cf = _G["ChatFrame" .. i]
			self:SetFrameFont(cf, font, size, outline)
		end
		for index,name in ipairs(self.TempChatFrames) do
			local cf = _G[name]
			if cf then
				self:SetFrameFont(cf, font, size, outline)
			end
		end
	end
end

function mod:SetFrameFont(cf, font, size, outline)
	local f = "FRAME_" .. cf:GetName():match("%d+")
	local prof = self.db.profile.frames[f]
	local profFont = nil
	if prof then
		profFont = prof.font
	else
		prof = {}
	end
	if profFont == "Default" then
		profFont = nil
	end
	local f, s, m = cf:GetFont() 
	font = Media:Fetch("font", font or profFont or self.db.profile.font or f)
	size = size or prof.fontsize or self.db.profile.fontsize or s
	outline = outline or prof.outline or self.db.profile.outline or m
	cf:SetFont(font, size, outline)
end

function mod:GetOptions()
	return options
end

function mod:Info()
	return L["Enables you to set a custom font and font size for your chat frames"]
end
