local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, dbc, dbg

-- Global tables
nibRealUI.globals = {}
nibRealUI.globals.anchorPoints = {
	"BOTTOM",
	"BOTTOMLEFT",
	"BOTTOMRIGHT",
	"CENTER",
	"LEFT",
	"RIGHT",
	"TOP",
	"TOPLEFT",
	"TOPRIGHT"
}

nibRealUI.globals.stratas = {
	"BACKGROUND",
	"LOW",
	"MEDIUM",
	"HIGH",
	"DIALOG",
	"TOOLTIP"
}

nibRealUI.globals.outlines = {
	"NONE",
	"OUTLINE",
	"THICKOUTLINE",
	"MONOCHROMEOUTLINE"
}

-- Primary Options table
local Options = {
	settings = nil,
	modules = {},
}
-- HuD
local HuDOptions = {
	settings = nil,
	modules = {},
	ClassResource = {},
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
function nibRealUI:ReInstall()
	StaticPopupDialogs["PUDRUIRESETUI"] = {
		text = L["Confirm reset RealUI?\n\nAll user settings will be lost."],
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			nibRealUICharacter = nil
			nibRealUI.db:ResetDB("RealUI")
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		notClosableByLogout = false,
	}
	StaticPopup_Show("PUDRUIRESETUI")
end

-- Re-initialize Character
local function ResetChar()
	-- Set all Char settings to default
	nibRealUICharacter = nil
	dbc.layout.current = 1
	
	-- Run Install Procedure
	nibRealUI:CloseOptions()
	nibRealUI:InstallProcedure()
end

-- Options
local function GetOptions()
	-- Primary Options
	if not Options.settings then
		Options.settings = {
			type = "group",
			name = "|cffffffffRealUI|r "..nibRealUI:GetVerString(true),
			childGroups = "tree",
			args = {},
		}
	end
	
	-- Core
	if not CoreOptions.settings then CoreOptions.settings = {
		name = "RealUI Core",
		desc = "Core RealUI functions.",
		type = "group",
		args = {
			header = {
				type = "header",
				name = "RealUI Core",
				order = 10,
			},
			corenote = {
				type = "description",
				name = "Note: Only use these features if you need to. They may change or revert settings.",
				fontSize = "medium",
				order = 20,
			},
			sep1 = {
				type = "description",
				name = " ",
				order = 30,
			},
			reinstall = {
				type = "execute",
				name = "Reset RealUI",
				func = function() nibRealUI:ReInstall() end,
				order = 40,
			},
			sep2 = {
				type = "description",
				name = " ",
				order = 41,
			},
			resetnote = {
				type = "description",
				name = "This will erase all user changes and install a fresh copy of RealUI.",
				fontSize = "medium",
				order = 42,
			},
			gap1 = {
				name = " ",
				type = "description",
				order = 43,
			},
			character = {
				type = "group",
				name = "Character",
				inline = true,
				order = 50,
				args = {
					resetchar = {
						type = "execute",
						name = "Re-initialize Character",
						func = ResetChar,
						order = 10,
					},
					sep = {
						type = "description",
						name = " ",
						order = 20,
					},
					resetnote = {
						type = "description",
						name = "This will flag the current Character as being new to RealUI, and RealUI will run through the initial installation procedure for this Character. Use only if you experienced a faulty installation for this character. Not guaranteed to actually fix anything.",
						fontSize = "medium",
						order = 30,
					},
				},
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 51,
			},
			uiscaler = {
				type = "group",
				name = "UI Scaling",
				inline = true,
				order = 50,
				args = {
					enabled = {
						type = "toggle",
						name = "Enable UI Scaler",
						desc = "Enable/Disable the UI Scaler. The UI Scaler automatically adjusts the UI scale for Pixel Perfect interface elements.",
						get = function() return db.other.uiscaler end,
						set = function(info, value) 
							db.other.uiscaler = value
							nibRealUI:ReloadUIDialog()
						end,
						order = 10,
					},
					retinaDisplay = {
						type = "toggle",
						name = "Retina Display",
						desc = "Double UI scaling so that UI elements are easier to see on a Retina Display.",
						disabled = function() return not(db.other.uiscaler) end,
						get = function() return dbg.tags.retinaDisplay.set end,
						set = function(info, value) 
							dbg.tags.retinaDisplay.set = value
							nibRealUI:ReloadUIDialog()
						end,
						order = 20,
					},
				},
			},
		},
	}
	end
	
	-- Plain Options
	for key, val in pairs(Options.modules) do
		Options.settings.args[key] = (type(val) == "function") and val() or val
	end
	
	-- HuD
	if not HuDOptions.settings then HuDOptions.settings = {
		type = "group",
		name = "HuD",
		desc = "Unit Frames, Class Tracking, Combat Information",
		childGroups = "tree",
		args = {
			ClassResource = {
				type = "group",
				name = "Class Resource",
				args = {},
			},
		},
	}
	end
	for key, val in pairs(HuDOptions.modules) do
		HuDOptions.settings.args[key] = (type(val) == "function") and val() or val
	end
	for key, val in pairs(HuDOptions.ClassResource) do
		HuDOptions.settings.args.ClassResource.args[key] = (type(val) == "function") and val() or val
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
	for key, val in pairs(ModuleOptions.modules) do
		ModuleOptions.settings.args[key] = (type(val) == "function") and val() or val
	end
	
	-- Skins
	if not SkinsOptions.settings then SkinsOptions.settings = {
		name = "Skins",
		desc = "Toggle skinning of UI frames.",
		type = "group",
		args = {
			header = {
				type = "header",
				name = "Skins",
				order = 10,
			},
		},
	}
	end
	for key, val in pairs(SkinsOptions.modules) do
		SkinsOptions.settings.args[key] = {
			type = "toggle",
			name = val,
			get = function() return nibRealUI:GetModuleEnabled(key) end,
			set = function(info, value) 
				nibRealUI:SetModuleEnabled(key, value)
				nibRealUI:ReloadUIDialog()
			end,
			order = 20,
		}
	end
end

-- Add a small panel to the Interface - Addons options
local intoptions = nil
local function GetIntOptions()
	if not intoptions then
		intoptions = {
			name = "RealUI",
			handler = nibRealUI,
			type = "group",
			args = {
				openoptions = {
					type = "execute",
					name = "Open RealUI Config",
					func = function() 
						nibRealUI:ShowConfigBar()
					end,
					order = 10,
				},
			},
		}
	end
	return intoptions
end

function nibRealUI:CloseOptions()
	LibStub("AceConfigDialog-3.0"):Close("nibRealUI")
end

function nibRealUI:OpenOptions(...)
	if not Options.settings then nibRealUI:SetUpOptions() end
	LibStub("AceConfigDialog-3.0"):Open("nibRealUI", ...)
end

function nibRealUI:ConfigRefresh()
	db = self.db.profile
	dbc = self.db.char
	dbg = self.db.global
	self.media = db.media
end

function nibRealUI:SetUpInitialOptions()
	-- Create Interface - Addons panel
	LibStub("AceConfig-3.0"):RegisterOptionsTable("nibRealUI-Int", GetIntOptions)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("nibRealUI-Int", "RealUI")
	
	nibRealUI:ConfigRefresh()
end

function nibRealUI:SetUpOptions()
	db = self.db.profile
	dbc = self.db.char
	dbg = self.db.global
	self.media = db.media
	
	-- Fill out Options table
	GetOptions()
	
	Options.settings.args.hud = HuDOptions.settings
	Options.settings.args.hud.order = 9000
	
	Options.settings.args.modules = ModuleOptions.settings
	Options.settings.args.modules.order = 9001
	
	Options.settings.args.skins = SkinsOptions.settings
	Options.settings.args.skins.order = 9002
	
	Options.settings.args.core = CoreOptions.settings
	Options.settings.args.core.order = 9500
	
	Options.settings.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	Options.settings.args.profiles.order = -1
	
	-- Create RealUI Options window
	LibStub("AceConfig-3.0"):RegisterOptionsTable("nibRealUI", Options.settings)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("nibRealUI", 870, 600)
end

function nibRealUI:RegisterPlainOptions(name, optionTbl)
	Options.modules[name] = optionTbl
end

function nibRealUI:RegisterHuDOptions(name, optionTbl, group)
	if group and HuDOptions[group] then
		HuDOptions[group][name] = optionTbl
	else
		HuDOptions.modules[name] = optionTbl
	end
end

function nibRealUI:RegisterModuleOptions(name, optionTbl)
	ModuleOptions.modules[name] = optionTbl
end

function nibRealUI:RegisterSkin(name, desc)
	SkinsOptions.modules[name] = desc
end