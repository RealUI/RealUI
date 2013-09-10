local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Borders/Background")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Borders/Background"]

local Media = LibStub("LibSharedMedia-3.0")
local CreateFrame = _G.CreateFrame
local pairs = _G.pairs
local tinsert = _G.tinsert
local type = _G.type

local options = {
}

local defaults = {
	profile = {
		frames = {}
	}
}

local frame_defaults = {
	enable = true,
	combatLogFix = false,
	background = "Blizzard Tooltip",
	border = "Blizzard Tooltip",
	inset = 3,
	edgeSize = 12,
	backgroundColor = { r = 0, g = 0, b = 0, a = 1 },
	borderColor = { r = 1, g = 1, b = 1, a = 1 },
}

local function deepcopy(tbl)
   local new = {}
   for key,value in pairs(tbl) do
      new[key] = type(value) == "table" and deepcopy(value) or value -- if it's a table, run deepCopy on it too, so we get a copy and not the original
   end
   return new
end

local frames = {}
function mod:OnInitialize()
	for i = 1, NUM_CHAT_WINDOWS do
		defaults.profile.frames["FRAME_" .. i] = deepcopy(frame_defaults)
		if _G["ChatFrame" .. i] == COMBATLOG then
			defaults.profile.frames["FRAME_" .. i].enable = false
		end
	end
	defaults.profile.frames.FRAME_2.combatLogFix = true
	
	self.db = Chatter.db:RegisterNamespace("ChatFrameBorders", defaults)
	
	Media.RegisterCallback(mod, "LibSharedMedia_Registered")
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		local frame = CreateFrame("Frame", nil, cf, "ChatFrameBorderTemplate")
		frame:EnableMouse(false)
		cf:SetFrameStrata("LOW")
		frame:SetFrameStrata("BACKGROUND")
		frame:SetFrameLevel(1)
		frame:Hide()
		frame.id = "FRAME_" .. i
		tinsert(frames, frame)
		local t = {
			type = "group",
			name = L["Chat Frame "] .. i,
			desc = L["Chat Frame "] .. i,
			args = {
				enable = {
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable borders on this frame"],
					order = 1,
					get = function()
						return mod.db.profile.frames[frame.id].enable
					end,
					set = function(info, v)
						mod.db.profile.frames[frame.id].enable = v
						if v then
							frame:Show()
						else
							frame:Hide()
						end
					end
				},
				combatLogFix = {
					type = "toggle",
					name = L["Combat Log Fix"],
					desc = L["Resize this border to fit the new combat log"],
					get = function() return mod.db.profile.frames[frame.id].combatLogFix end,
					set = function(info, v)
						mod.db.profile.frames[frame.id].combatLogFix = v
						mod:SetAnchors(frame, v)
					end
				},
				background = {
					type = "select",
					name = L["Background texture"],
					desc = L["Background texture"],
					dialogControl = "LSM30_Background",
					values = Media:HashTable("background"),
					get = function() return mod.db.profile.frames[frame.id].background end,
					set = function(info, v)
						mod.db.profile.frames[frame.id].background = v
						mod:SetBackdrop(frame)
					end
				},
				border = {
					type = "select",
					name = L["Border texture"],
					desc = L["Border texture"],
					dialogControl = "LSM30_Border",
					values = Media:HashTable("border"),
					get = function() return mod.db.profile.frames[frame.id].border end,
					set = function(info, v)
						mod.db.profile.frames[frame.id].border = v
						mod:SetBackdrop(frame)
					end
				},
				backgroundColor = {
					type = "color",
					name = L["Background color"],
					desc = L["Background color"],
					hasAlpha = true,
					get = function()
						local c = mod.db.profile.frames[frame.id].backgroundColor
						return c.r, c.g, c.b, c.a
					end,
					set = function(info, r, g, b, a)
						local c = mod.db.profile.frames[frame.id].backgroundColor
						c.r, c.g, c.b, c.a = r, g, b, a
						mod:SetBackdrop(frame)
					end
				},
				borderColor = {
					type = "color",
					name = L["Border color"],
					desc = L["Border color"],
					hasAlpha = true,
					get = function()
						local c = mod.db.profile.frames[frame.id].borderColor
						return c.r, c.g, c.b, c.a
					end,
					set = function(info, r, g, b, a)
						local c = mod.db.profile.frames[frame.id].borderColor
						c.r, c.g, c.b, c.a = r, g, b, a
						mod:SetBackdrop(frame)
					end
				},
				inset = {
					type = "range",
					name = L["Background Inset"],
					desc = L["Background Inset"],
					min = 1,
					max = 64,
					step = 1,
					bigStep = 1,
					get = function() return mod.db.profile.frames[frame.id].inset end,
					set = function(info, v)
						mod.db.profile.frames[frame.id].inset = v
						mod:SetBackdrop(frame)
					end
				},
				tileSize = {
					type = "range",
					name = L["Tile Size"],
					desc = L["Tile Size"],
					min = 1,
					max = 64,
					step = 1,
					bigStep = 1,
					get = function() return mod.db.profile.frames[frame.id].tileSize end,
					set = function(info, v)
						mod.db.profile.frames[frame.id].tileSize = v
						mod:SetBackdrop(frame)
					end
				},
				edgeSize = {
					type = "range",
					name = L["Edge Size"],
					desc = L["Edge Size"],
					min = 1,
					max = 64,
					step = 1,
					bigStep = 1,
					get = function() return mod.db.profile.frames[frame.id].edgeSize end,
					set = function(info, v)
						mod.db.profile.frames[frame.id].edgeSize = v
						mod:SetBackdrop(frame)
					end
				}
			}
		}
		options[frame.id] = t
	end
end

function mod:LibSharedMedia_Registered()
	mod:SetBackdrops()
end

function mod:Decorate(cf)
	local frame = CreateFrame("Frame", nil, cf, "ChatFrameBorderTemplate")
	frame:EnableMouse(false)
	cf:SetFrameStrata("LOW")
	frame:SetFrameStrata("BACKGROUND")
	frame:SetFrameLevel(1)
	frame:Hide()
	frame.id = "FRAME_1"
	tinsert(frames, frame)
	self:SetBackdrops()
	frame:Show()
	mod:SetAnchors(frame, self.db.profile.frames["FRAME_1"].combatLogFix)
end

function mod:OnEnable()
	self:LibSharedMedia_Registered()
	self:SetBackdrops()
	for i = 1, #frames do
		if self.db.profile.frames and self.db.profile.frames["FRAME_" .. i].enable then
			frames[i]:Show()
		end
		mod:SetAnchors(frames[i], self.db.profile.frames["FRAME_" .. i].combatLogFix)
	end
	Media.RegisterCallback(mod, "LibSharedMedia_Registered")
end

function mod:OnDisable()
	for i = 1, #frames do
		frames[i]:Hide()
	end
end

function mod:SetBackdrops()
	for i = 1, #frames do
		self:SetBackdrop(frames[i])
	end
end

do
	function mod:SetBackdrop(frame)
		local profile = self.db.profile.frames[frame.id]
		local doTile = false
		if profile and profile.tileSize and profile.tileSize > 1 then
			doTile = true
		end
		frame:SetBackdrop({
			bgFile = Media:Fetch("background", profile.background),
			edgeFile = Media:Fetch("border", profile.border),
			tile = doTile,
			tileSize = profile.tileSize,
			edgeSize = profile.edgeSize,
			insets = {left = profile.inset, right = profile.inset, top = profile.inset, bottom = profile.inset}
		})
		local c = profile.backgroundColor
		frame:SetBackdropColor(c.r, c.g, c.b, c.a)
		
		local c = profile.borderColor
		frame:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
	end
end

function mod:GetOptions()
	return options
end

function mod:SetAnchors(frame, fix)
	local p = frame:GetParent()
	frame:ClearAllPoints()
	if fix then
		frame:SetPoint("TOPLEFT", p, "TOPLEFT", -5, 30)
		frame:SetPoint("TOPRIGHT", p, "TOPRIGHT", 5, 30)
		frame:SetPoint("BOTTOMLEFT", p, "BOTTOMLEFT", -5, -10)
		frame:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", 5, -10)
	else
		frame:SetPoint("TOPLEFT", p, "TOPLEFT", -5, 5)
		frame:SetPoint("TOPRIGHT", p, "TOPRIGHT", 5, 5)
		frame:SetPoint("BOTTOMLEFT", p, "BOTTOMLEFT", -5, -10)
		frame:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", 5, -10)
	end
end

function mod:Info()
	return L["Gives you finer control over the chat frame's background and border colors"]
end
