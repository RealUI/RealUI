local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = nibRealUI.L
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
function nibRealUI:ReInstall()
	StaticPopupDialogs["PUDRUIRESETUI"] = {
		text = L["Reset_Confirm"] .. L["Reset_SettingsLost"],
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
	LibStub("AceConfigDialog-3.0"):Close("nibRealUI")
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
		},
	}
	end

	-- Plain Options
	for key, val in pairs(Options.modules) do
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
	for key, val in pairs(ModuleOptions.modules) do
		ModuleOptions.settings.args[key] = (type(val) == "function") and val() or val
	end

	-- Skins
	if not SkinsOptions.settings then SkinsOptions.settings = {
		name = "Skins",
		desc = "Toggle skinning of UI frames.",
		type = "group",
		args = {
            windowOpacity = {
                name = L["Appearance_WinOpacity"],
                type = "range",
                isPercent = true,
                min = 0, max = 1, step = 0.05,
                get = function(info) return nibRealUI.media.window[4] end,
                set = function(info, value)
                    nibRealUI.media.window[4] = value
                end,
                order = 10,
            },
            stripeOpacity = {
                name = L["Appearance_StripeOpacity"],
                type = "range",
                isPercent = true,
                min = 0, max = 1, step = 0.05,
                get = function(info) return RealUI_InitDB.stripeOpacity end,
                set = function(info, value)
                    RealUI_InitDB.stripeOpacity = value
                end,
                order = 20,
            },
			header = {
				type = "header",
				name = "Skins",
				order = 30,
			},
		},
	}
	end
	for i = 1, #SkinsOptions.modules do
		local name = SkinsOptions.modules[i]
		SkinsOptions.settings.args[name] = {
			type = "toggle",
			name = name,
			get = function() return nibRealUI:GetModuleEnabled(name) end,
			set = function(info, value)
				nibRealUI:SetModuleEnabled(name, value)
				nibRealUI:ReloadUIDialog()
			end,
			order = 40,
		}
	end
end

function nibRealUI:SetUpOptions()
	if Options.settings then return end
	db = self.db.profile
	dbc = self.db.char
	dbg = self.db.global
	self.media = db.media

	-- Fill out Options table
	GetOptions()

	Options.settings.args.modules = ModuleOptions.settings
	Options.settings.args.modules.order = 9001

	Options.settings.args.skins = SkinsOptions.settings
	Options.settings.args.skins.order = 9002

	Options.settings.args.core = CoreOptions.settings
	Options.settings.args.core.order = 9500

	Options.settings.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	Options.settings.args.profiles.order = -1

	-- Create RealUI Options window
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("nibRealUI", Options.settings)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("nibRealUI", 870, 600)
end

function nibRealUI:RegisterPlainOptions(name, optionTbl)
	Options.modules[name] = optionTbl
end

function nibRealUI:RegisterModuleOptions(name, optionTbl)
	ModuleOptions.modules[name] = optionTbl
end

function nibRealUI:RegisterSkin(name)
	local skin = self:CreateModule(name, "AceEvent-3.0")
	skin:SetEnabledState(self:GetModuleEnabled(name))
	tinsert(SkinsOptions.modules, name)
	return skin
end
