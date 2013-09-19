local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")
local db, ndb

local MODNAME = "Chat"
local Chat = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Chat Extras",
		desc = "Extra modifications to the Chat window.",
		arg = MODNAME,
		-- order = 112,
		args = {
			header = {
				type = "header",
				name = "Chat Extras",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Extra modifications to the Chat window.",
				fontSize = "medium",
				order = 11,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Chat Extras module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
				end,
				order = 20,
			},
			desc3 = {
				type = "description",
				name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
				order = 21,
			},
			gap1 = {
				name = " ",
				type = "description",
				order = 22,
			},
			modules = {
				type = "group",
				name = "Modules",
				inline = true,
				disabled = function() return not(nibRealUI:GetModuleEnabled(MODNAME)) end,
				order = 30,
				args = {
					tabs = {
						type = "toggle",
						name = "Chat Tabs",
						desc = "Skins the Chat Tabs.",
						get = function() return db.modules.tabs.enabled end,
						set = function(info, value) 
							db.modules.tabs.enabled = value
						end,
						order = 10,
					},
					opacity = {
						type = "toggle",
						name = "Opacity",
						desc = "Adjusts the opacity of the Chat Frame, and controls how fast the frame and tabs fade in/out.",
						get = function() return db.modules.opacity.enabled end,
						set = function(info, value) 
							db.modules.opacity.enabled = value
						end,
						order = 20,
					},
					strings = {
						type = "toggle",
						name = "Strings",
						desc = "Shortens and modifies general chat messages.",
						get = function() return db.modules.strings.enabled end,
						set = function(info, value) 
							db.modules.strings.enabled = value
						end,
						order = 30,
					},
				},
			},
		},
	}
	end
	
	return options
end


function Chat:PLAYER_LOGIN()
	-- Hide IM selector if BCM is enabled
	if IsAddOnLoaded("BasicChatMods") then
		_G["InterfaceOptionsSocialPanelChatStyle"]:Hide()
	end
end

function Chat:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			modules = {
				["**"] = {
					enabled = true,
				},
				tabs = {
					colors = {
						classcolorhighlight = true,
						["normal"] = {1, 1, 1},
						["highlight"] = {1, 1, 1},
						["flash"] = {1, 1, 0},
					},
				},
				opacity = {},
				strings = {},
				history = {
					[nibRealUI.realm] = {history = {}},
				},
			},
		},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function Chat:OnEnable() 
	self:RegisterEvent("PLAYER_LOGIN")
end