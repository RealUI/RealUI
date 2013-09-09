local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):NewAddon(addon, "AceConsole-3.0", "AceHook-3.0", "AceTimer-3.0") 
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

local optFrame

local options = {
	type = "group",
	args = {
		defaultArgs = {
			type = "group",
			name = L["Chatter"],
			args = {
				aceConfig = {
					type = "execute",
					name = L["Standalone Config"],
					desc = L["Open a standalone config window. You might consider installing |cffffff00BetterBlizzOptions|r to make the Blizzard UI options panel resizable."],
					func = function()
						AceConfigDialog:SetDefaultSize("Chatter", 500, 550)
						AceConfigDialog:Open("Chatter")
					end
				}
			}
		},
		config = {
			type = "execute",
			guiHidden = true,
			name = L["Configure"],
			desc = L["Configure"],
			func = Chatter.OpenConfig
		},
		modules = {
			type = "group",
			name = L["Modules"],
			desc = L["Modules"],
			args = {}
		}		
	}
}

local defaults = {
	profile = {
		modules = {
			["Disable Fading"] = false,
			["Chat Autolog"] = false,
			["Automatic Whisper Windows"] = false,
			["Server Positioning"] = false,
		}
	}
}
--[[
	Creating a prototype for a Decorate/UnDecorate function
	Adding these in so after everything is loaded we can post decorate/undecorate the popup frames
--]]
local proto = {
	Decorate = function(self,chatframe) end,
	Popout = function(self,chatframe,srcChatFrame) end,
	TempChatFrames = {},
	AddTempChat = function(self,name) table.insert(self.TempChatFrames,name) end,
	AlwaysDecorate = function(self,chatframe) end,
}

Chatter:SetDefaultModulePrototype(proto)
Chatter:SetDefaultModuleState(false)

local optionFrames = {}
local ACD3 = LibStub("AceConfigDialog-3.0")

function Chatter:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("ChatterDB", defaults, "Default")

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Chatter", options)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ChatterModules", options.args.modules)
	optFrame = ACD3:AddToBlizOptions("Chatter", nil, nil, "defaultArgs")
	
	for k, v in self:IterateModules() do
		options.args.modules.args[k:gsub(" ", "_")] = {
			type = "group",
			name = (v.modName or k),
			args = nil
		}
		local t
		if v.GetOptions then
			t = v:GetOptions()
			t.settingsHeader = {
				type = "header",
				name = L["Settings"],
				order = 12
			}		
		end
		t = t or {}
		t.toggle = {
			type = "toggle", 
			name = v.toggleLabel or (L["Enable "] .. (v.modName or k)), 
			width = "double",
			desc = v.Info and v:Info() or (L["Enable "] .. (v.modName or k)), 
			order = 11,
			get = function()
				return Chatter.db.profile.modules[k] ~= false or false
			end,
			set = function(info, v)
				Chatter.db.profile.modules[k] = v
				if v then
					Chatter:EnableModule(k)
					-- L["Module"]
					Chatter:Print(L["Enabled"], k, L["Module"])
				else
					Chatter:DisableModule(k)
					Chatter:Print(L["Disabled"], k, L["Module"])
				end
			end
		}
		t.header = {
			type = "header",
			name = v.modName or k,
			order = 9
		}
		if v.Info then
			t.description = {
				type = "description",
				name = v:Info() .. "\n\n",
				order = 10
			}
		end
		options.args.modules.args[k:gsub(" ", "_")].args = t
	end	
	
	local moduleList = {}
	local moduleNames = {}
	for k, v in pairs(options.args.modules.args) do
		moduleList[v.name] = k
		tinsert(moduleNames, v.name)
	end
	table.sort(moduleNames)
	for _, name in ipairs(moduleNames) do
		ACD3:AddToBlizOptions("ChatterModules", name, "Chatter", moduleList[name])
	end
	
	self:RegisterChatCommand("chatter", "OpenConfig")
	
	self.db.RegisterCallback(self, "OnProfileChanged", "SetUpdateConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "SetUpdateConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "SetUpdateConfig")
	
	self:AddMenuHook(self, {
		text = L["Chatter Settings"],
		func = Chatter.OpenConfig,
		notCheckable = 1
	})
	self:RawHook("FCF_Tab_OnClick", true)
	self:RawHook("FCF_OpenTemporaryWindow",true)
end

do
	local info = {}
	local menuHooks = {}
	function Chatter:AddMenuHook(module, hook)
		menuHooks[module] = hook
	end
	
	function Chatter:RemoveMenuHook(module)
		menuHooks[module] = nil
	end
	
	function Chatter:FCF_Tab_OnClick(...)
		self.hooks.FCF_Tab_OnClick(...)
		for module, v in pairs(menuHooks) do
			local menu
			if type(v) == "table" then
				menu = v
			else
				menu = module[v](module, ...)
			end
			UIDropDownMenu_AddButton(menu)
		end
	end
end

function Chatter:FCF_OpenTemporaryWindow(chatType, chatTarget, sourceChatFrame, selectWindow)
	local frame = self.hooks.FCF_OpenTemporaryWindow(chatType, chatTarget, sourceChatFrame, selectWindow)
	if frame then
		for k, v in self:IterateModules() do
			if not frame.isDecorated then
				v:AddTempChat(frame:GetName())
			end
			if v:IsEnabled() and not frame.isDecorated then
				v:Decorate(frame)
			end
			if v:IsEnabled() then
				v:Popout(frame,sourceChatFrame or DEFAULT_CHAT_FRAME)
			end
			v:AlwaysDecorate(frame)
		end
		frame.isDecorated = true
	end
	FCFDock_ForceReanchoring(GENERAL_CHAT_DOCK)
	return frame
end

function Chatter:OpenConfig(input)
	if input == "config" or not InterfaceOptionsFrame:IsResizable() then
		options.args.defaultArgs.guiHidden = true
		InterfaceOptionsFrame:Hide()
		AceConfigDialog:SetDefaultSize("Chatter", 500, 550)
		AceConfigDialog:Open("Chatter")
	else
		InterfaceOptionsFrame_OpenToCategory(Chatter.lastConfig)
		options.args.defaultArgs.guiHidden = false
		InterfaceOptionsFrame_OpenToCategory(optFrame)
	end
end

do
	local timer, t = nil, 0
	local function update(frame, arg1)
		t = t + arg1
		if t > 0.5 then
			timer:SetScript("OnUpdate", nil)
			Chatter:UpdateConfig()
		end
	end
	function Chatter:SetUpdateConfig()
		t = 0
		timer = timer or CreateFrame("Frame", nil, UIParent)
		timer:SetScript("OnUpdate", update)
	end
end

function Chatter:UpdateConfig()
	for k, v in self:IterateModules() do
		if v:IsEnabled() then
			v:Disable()
			v:Enable()
		end
	end
end

function Chatter:OnEnable()
	if not self.db.profile.welcomeMessaged then
		self:Print(L["Welcome to Chatter! Type /chatter to configure."])
		self.db.profile.welcomeMessaged = true
	end
	for k, v in self:IterateModules() do
		if self.db.profile.modules[k] ~= false then
			v:Enable()
		end
	end
	
	if not options.args.Profiles then
 		options.args.Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
		self.lastConfig = ACD3:AddToBlizOptions("Chatter", L["Profiles"], "Chatter", "Profiles")
	end
end

function Chatter:OnDisable()
end
