local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local MODNAME = "ErrorHider"
local ErrorHider = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Blacklist filter.
local FilterList = {
	INTERRUPTED,
	ERR_ABILITY_COOLDOWN,
	ERR_ATTACK_CHANNEL,
	ERR_ATTACK_CHARMED,
	ERR_ATTACK_CONFUSED,
	ERR_ATTACK_DEAD,
	ERR_ATTACK_FLEEING,
	ERR_ATTACK_MOUNTED,
	ERR_ATTACK_PACIFIED,
	ERR_ATTACK_STUNNED,
	ERR_AUTOFOLLOW_TOO_FAR,
	ERR_BADATTACKFACING,
	ERR_BADATTACKPOS,
	ERR_CLIENT_LOCKED_OUT,
	ERR_GENERIC_NO_TARGET,
	ERR_GENERIC_NO_VALID_TARGETS,
	ERR_GENERIC_STUNNED,
	ERR_INVALID_ATTACK_TARGET,
	ERR_ITEM_COOLDOWN,
	ERR_NOEMOTEWHILERUNNING,
	ERR_NOT_IN_COMBAT,
	ERR_NOT_WHILE_DISARMED,
	ERR_NOT_WHILE_FALLING,
	ERR_NOT_WHILE_MOUNTED,
	ERR_NO_ATTACK_TARGET,
	ERR_OUT_OF_ENERGY,
	ERR_OUT_OF_FOCUS,
	ERR_OUT_OF_MANA,
	ERR_OUT_OF_RAGE,
	ERR_OUT_OF_RANGE,
	ERR_OUT_OF_RUNES,
	ERR_OUT_OF_RUNIC_POWER,
	ERR_OUT_OF_HOLY_POWER,
	SPELL_FAILED_CUSTOM_ERROR_153,
	ERR_SPELL_COOLDOWN,
	ERR_SPELL_OUT_OF_RANGE,
	ERR_TOO_FAR_TO_INTERACT,
	ERR_USE_BAD_ANGLE,
	ERR_USE_CANT_IMMUNE,
	ERR_USE_TOO_FAR,
	SPELL_FAILED_BAD_IMPLICIT_TARGETS,
	SPELL_FAILED_BAD_TARGETS,
	SPELL_FAILED_CASTER_AURASTATE,
	SPELL_FAILED_NO_COMBO_POINTS,
	SPELL_FAILED_SPELL_IN_PROGRESS,
	SPELL_FAILED_TARGET_AURASTATE,
	SPELL_FAILED_MOVING,
	SPELL_FAILED_UNIT_NOT_INFRONT,
}

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Error Hider",
		desc = "Hide specific error messages.",
		arg = MODNAME,
		-- order = 518,
		args = {
			header = {
				type = "header",
				name = "Error Hider",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Hide specific error messages.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Error Hider module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
				end,
				order = 30,
			},
			gap1 = {
				name = " ",
				type = "description",
				order = 31,
			},
		},
	}
	end
	
	-- Create Filter List options table
	local filteropts = {
		name = "Filter List",
		type = "group",
		inline = true,
		disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
		order = 40,
		args = {
			note = {
				type = "description",
				name = "Ticked = Hidden",
				fontSize = "medium",
				order = 10,
			},
			hideall = {
				type = "toggle",
				name = "Hide All",
				desc = "Hide all error messages.",
				get = function() return db.hideall end,
				set = function(info, value) 
					db.hideall = value
				end,
				order = 20,
			},
			sep = {
				type = "description",
				name = " ",
				fontSize = "medium",
				order = 30,
			},
		},
	}
	local filterordercnt = 40	
	for k_f,v_f in pairs(FilterList) do
		-- Create base options for Addons
		filteropts.args[v_f] = {
			type = "toggle",
			name = v_f,
			width = "full",
			get = function(info) return db.filterlist[v_f] end,
			set = function(info, value)
				db.filterlist[v_f] = value
			end,
			order = filterordercnt,
			disabled = function() return db.hideall or (not nibRealUI:GetModuleEnabled(MODNAME)) end,
		}
		filterordercnt = filterordercnt + 10
	end
	
	options.args.filterlist = filteropts
	return options
end

function ErrorHider:UI_ERROR_MESSAGE(event, err)
	if err == "" then return end
	if not db.filterlist[err] and not db.hideall then
		UIErrorsFrame:AddMessage(err, 1, 0, 0)
	end
end

----
function ErrorHider:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			hideall = false,
			filterlist = {
				[INTERRUPTED] = false,
				[ERR_ABILITY_COOLDOWN] = true,
				[ERR_ATTACK_CHANNEL] = false,
				[ERR_ATTACK_CHARMED] = false,
				[ERR_ATTACK_CONFUSED] = false,
				[ERR_ATTACK_DEAD] = false,
				[ERR_ATTACK_FLEEING] = false,
				[ERR_ATTACK_MOUNTED] = true,
				[ERR_ATTACK_PACIFIED] = false,
				[ERR_ATTACK_STUNNED] = false,
				[ERR_AUTOFOLLOW_TOO_FAR] = false,
				[ERR_BADATTACKFACING] = false,
				[ERR_BADATTACKPOS] = true,
				[ERR_CLIENT_LOCKED_OUT] = false,
				[ERR_GENERIC_NO_TARGET] = true,
				[ERR_GENERIC_NO_VALID_TARGETS] = true,
				[ERR_GENERIC_STUNNED] = false,
				[ERR_INVALID_ATTACK_TARGET] = true,
				[ERR_ITEM_COOLDOWN] = true,
				[ERR_NOEMOTEWHILERUNNING] = false,
				[ERR_NOT_IN_COMBAT] = false,
				[ERR_NOT_WHILE_DISARMED] = false,
				[ERR_NOT_WHILE_FALLING] = false,
				[ERR_NOT_WHILE_MOUNTED] = false,
				[ERR_NO_ATTACK_TARGET] = true,
				[ERR_OUT_OF_ENERGY] = true,
				[ERR_OUT_OF_FOCUS] = true,
				[ERR_OUT_OF_MANA] = true,
				[ERR_OUT_OF_RAGE] = true,
				[ERR_OUT_OF_RANGE] = true,
				[ERR_OUT_OF_RUNES] = true,
				[ERR_OUT_OF_RUNIC_POWER] = true,
				[ERR_OUT_OF_HOLY_POWER] = true,
				[SPELL_FAILED_CUSTOM_ERROR_153] = true,
				[ERR_SPELL_COOLDOWN] = true,
				[ERR_SPELL_OUT_OF_RANGE] = false,
				[ERR_TOO_FAR_TO_INTERACT] = false,
				[ERR_USE_BAD_ANGLE] = false,
				[ERR_USE_CANT_IMMUNE] = false,
				[ERR_USE_TOO_FAR] = false,
				[SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true,
				[SPELL_FAILED_BAD_TARGETS] = true,
				[SPELL_FAILED_CASTER_AURASTATE] = false,
				[SPELL_FAILED_NO_COMBO_POINTS] = true,
				[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
				[SPELL_FAILED_TARGET_AURASTATE] = true,
				[SPELL_FAILED_MOVING] = false,
				[SPELL_FAILED_UNIT_NOT_INFRONT] = false,
			},
		},
	})
	db = self.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function ErrorHider:OnEnable()
	self:RegisterEvent("UI_ERROR_MESSAGE")
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
end

function ErrorHider:OnDisable()
	self:UnregisterEvent("UI_ERROR_MESSAGE")
	UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
end