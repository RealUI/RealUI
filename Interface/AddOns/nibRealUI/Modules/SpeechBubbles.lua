-- Code concepts from FreeUI by Haleth

local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local _
local MODNAME = "SpeechBubbles"
local SpeechBubbles = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Speech Bubbles",
		desc = "Skins the speech bubbles.",
		arg = MODNAME,
		-- order = 1916,
		args = {
			header = {
				type = "header",
				name = "Speech Bubbles",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Skins the speech bubbles.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Speech Bubbles module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
					nibRealUI:ReloadUIDialog()
				end,
				order = 30,
			},
			desc2 = {
				type = "description",
				name = " ",
				order = 31,
			},
			desc3 = {
				type = "description",
				name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
				order = 32,
			},
			gap1 = {
				name = " ",
				type = "description",
				order = 33,
			},
			general = {
				type = "group",
				name = "General",
				inline = true,
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 40,
				args = {
					sendersize = {
						type = "range",
						name = "Sender Name Size",
						min = 6, max = 32, step = 1,
						get = function(info) return db.sendersize end,
						set = function(info, value) 
							db.sendersize = value
						end,
						order = 10,
					},
					hideSender = {
						type = "toggle",
						name = "Hide Sender Name",
						get = function() return db.hideSender end,
						set = function(info, value) 
							db.hideSender = value
						end,
						order = 11,
					},
					messagesize = {
						type = "range",
						name = "Message Size",
						min = 6, max = 32, step = 1,
						get = function(info) return db.messagesize end,
						set = function(info, value) 
							db.messagesize = value
						end,
						order = 20,
					},
					edgesize = {
						type = "range",
						name = "Edge Size",
						min = 0, max = 20, step = 1,
						get = function(info) return db.edgesize end,
						set = function(info, value) 
							db.edgesize = value
						end,
						order = 30,
					},
				},
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 41,
			},
			colors = {
				type = "group",
				name = "Colors",
				inline = true,
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 50,
				args = {
					background = {
						type = "color",
						name = "Background",
						hasAlpha = true,
						get = function(info,r,g,b,a)
							return db.colors.bg[1], db.colors.bg[2], db.colors.bg[3], db.colors.bg[4]
						end,
						set = function(info,r,g,b,a)
							db.colors.bg[1] = r
							db.colors.bg[2] = g
							db.colors.bg[3] = b
							db.colors.bg[4] = a
						end,
						order = 10,
					},
					border = {
						type = "color",
						name = "Border",
						hasAlpha = true,
						get = function(info,r,g,b,a)
							return db.colors.border[1], db.colors.border[2], db.colors.border[3], db.colors.border[4]
						end,
						set = function(info,r,g,b,a)
							db.colors.border[1] = r
							db.colors.border[2] = g
							db.colors.border[3] = b
							db.colors.border[4] = a
						end,
						order = 10,
					},
				},
			},
		},
	}
	end
	return options
end

local events = {
	CHAT_MSG_SAY = "chatBubbles", CHAT_MSG_YELL = "chatBubbles",
	CHAT_MSG_PARTY = "chatBubblesParty", CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
	CHAT_MSG_MONSTER_SAY = "chatBubbles", CHAT_MSG_MONSTER_YELL = "chatBubbles", CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
}

local numWFKids = 0

local function FixedScale(len)
	return GetScreenHeight() * len / 768
end

local function SkinBubble(frame)
	for i= 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
		end
	end
	
	-- Message Font
	frame.text:SetFont(nibRealUI.font.standard, db.messagesize, "OUTLINE")
	frame.text:SetJustifyH("LEFT")
	
	-- Sender Name
	local senderHeight = not(db.hideSender) and FixedScale(db.sendersize) or 0
	if not(db.hideSender) then
		frame.sender = frame:CreateFontString()
		frame.sender:SetPoint("TOP", 0, -db.edgesize)
		frame.sender:SetPoint("LEFT", frame.text)
		frame.sender:SetPoint("RIGHT", frame.text)
		frame.sender:SetFont(nibRealUI.font.standard, db.sendersize, "OUTLINE")
		frame.sender:SetJustifyH("LEFT")
	end

	-- Border
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", frame.text, -db.edgesize, db.edgesize + senderHeight)
	frame:SetPoint("BOTTOMRIGHT", frame.text, db.edgesize, -db.edgesize)
	frame:SetBackdrop({
		bgFile = "",
		edgeFile = nibRealUI.media.textures.plain,
		edgeSize = UIParent:GetScale(),
	})
	frame:SetBackdropBorderColor(unpack(db.colors.border))
	
	-- Background
	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(nibRealUI.media.textures.plain)
	bg:SetVertexColor(unpack(db.colors.bg))
	
	frame:HookScript("OnHide", function() frame.inUse = false end)
end

local function UpdateFrame(frame, guid, name)
	if not frame.text then SkinBubble(frame) end
	frame.inUse = true
	
	if name and not(db.hideSender) then
		local class
		if guid ~= nil and guid ~= "" then
			_, class, _, _, _, _ = GetPlayerInfoByGUID(guid)
		end
	
		local color = nibRealUI:GetClassColor(class)
		frame.sender:SetText(("|cff%2x%2x%2x%s|r"):format(color[1] * 255, color[2] * 255, color[3] * 255, name))
		if frame.text:GetWidth() < frame.sender:GetWidth() then
			frame.text:SetWidth(frame.sender:GetWidth())
		end
	end
end

-- Find chat bubble with given message
local function FindFrame(msg)
	for i = 1, WorldFrame:GetNumChildren() do
		local frame = select(i, WorldFrame:GetChildren())
		if not frame:GetName() and not frame.inUse then
			for i = 1, select("#", frame:GetRegions()) do
				local region = select(i, frame:GetRegions())
				if region:GetObjectType() == "FontString" and region:GetText() == msg then
					return frame
				end
			end

		end
	end
end

local EventTimer = CreateFrame("Frame")
function SpeechBubbles:BubbleEvent(event, msg, sender, _, _, _, _, _, _, _, _, _, guid)
	if GetCVarBool(events[event]) then
		EventTimer.elapsed = 0
		EventTimer:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = self.elapsed + elapsed
			local frame = FindFrame(msg)
			if frame or self.elapsed > 0.3 then
				EventTimer:SetScript("OnUpdate", nil)
				if frame then UpdateFrame(frame, guid, sender) end
			end
		end)
	end
end

function SpeechBubbles:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			sendersize = 12,
			hideSender = true,
			messagesize = 10,
			edgesize = 6,
			colors = {
				bg = {0, 0, 0, .65},
				border = {0, 0, 0, 1},
			},
		},
	})
	db = self.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function SpeechBubbles:OnEnable()
	for k, v in pairs(events) do
		self:RegisterEvent(k, "BubbleEvent")
	end
end

function SpeechBubbles:OnDisable()
	self:UnregisterAllEvents()
end