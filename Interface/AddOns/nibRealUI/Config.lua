local ADDON_NAME, private = ...

-- Lua Globals --
local _G = _G
local next, type = _G.next, _G.type

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db

-- Primary Options table
local Options = {
	settings = nil,
	modules = {},
}
-- Modules
local ModuleOptions = {
	settings = nil,
	modules = {},
}
-- Skins
local SkinsOptions = {
	settings = nil,
	modules = {},
}
-- RealUI Core
local CoreOptions = {
	settings = nil,
}

-- Re-install RealUI
function RealUI:ReInstall()
	_G.StaticPopupDialogs["PUDRUIRESETUI"] = {
		text = L["Reset_Confirm"] .. L["Reset_SettingsLost"],
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			_G.nibRealUICharacter = nil
			RealUI.db:ResetDB("RealUI")
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		notClosableByLogout = false,
	}
	_G.StaticPopup_Show("PUDRUIRESETUI")
end

-- Options
local function GetOptions()
	-- Primary Options
	if not Options.settings then
		Options.settings = {
			type = "group",
			name = "|cffffffffRealUI|r "..RealUI:GetVerString(true),
			childGroups = "tree",
			args = {},
		}
	end

	-- Plain Options
	for key, val in next, Options.modules do
		Options.settings.args[key] = (type(val) == "function") and val() or val
	end

	-- Modules
	if not ModuleOptions.settings then ModuleOptions.settings = {
		type = "group",
		name = "Modules",
		desc = "RealUI Modules",
		childGroups = "tree",
		args = {},
	}
	end
	for key, val in next, ModuleOptions.modules do
		ModuleOptions.settings.args[key] = (type(val) == "function") and val() or val
	end
end

function RealUI:SetUpOptions()
	if Options.settings then return end
	db = self.db.profile
	self.media = db.media

	-- Fill out Options table
	GetOptions()

	Options.settings.args.modules = ModuleOptions.settings
	Options.settings.args.modules.order = 9001

	Options.settings.args.skins = SkinsOptions.settings
	Options.settings.args.skins.order = 9002

	Options.settings.args.core = CoreOptions.settings
	Options.settings.args.core.order = 9500

	Options.settings.args.profiles = _G.LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	Options.settings.args.profiles.order = -1

	-- Create RealUI Options window
	_G.LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(ADDON_NAME, Options.settings)
	_G.LibStub("AceConfigDialog-3.0"):SetDefaultSize(ADDON_NAME, 870, 600)
end

function RealUI:RegisterPlainOptions(name, optionTbl)
	Options.modules[name] = optionTbl
end

function RealUI:RegisterModuleOptions(name, optionTbl)
	ModuleOptions.modules[name] = optionTbl
end

