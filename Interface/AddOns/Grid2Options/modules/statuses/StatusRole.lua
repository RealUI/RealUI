local L  = Grid2Options.L
local LG = Grid2Options.LG

local function MakeStatusRoleOptions(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 30)
	options.hideInCombat = {
		type = "toggle",
		name = L["Hide in combat"],
		desc = L["Hide in combat"],
		width = "full",
		order = 40,
		get = function () return status.dbx.hideInCombat end,
		set = function (_, v) 
			status.dbx.hideInCombat = v or nil 
			status:SetHideInCombat(v)
			status:UpdateAllUnits()
		end,
	}
end

local function MakeStatusDungeonRoleOptions(self, status, options, optionParams)
	MakeStatusRoleOptions(self, status, options, optionParams)
	options.hideDamagers = {
		type = "toggle",
		name = L["Hide Damagers"],
		desc = L["Hide Damagers"],
		width = "full",
		order = 50,
		get = function () return status.dbx.hideDamagers end,
		set = function (_, v) 
			status.dbx.hideDamagers = v or nil 
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
	}
	options.useAlternateIcons = {
		type = "toggle",
		name = L["Use alternate icons"],
		desc = L["Use alternate icons"],
		width = "full",
		order = 60,
		get = function () return status.dbx.useAlternateIcons end,
		set = function (_, v) 
			status.dbx.useAlternateIcons = v or nil 
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
	}
end

Grid2Options:RegisterStatusOptions("leader",    	 "role", MakeStatusRoleOptions, {
	titleIcon = "Interface\\GroupFrame\\UI-Group-LeaderIcon",
})
Grid2Options:RegisterStatusOptions("raid-assistant", "role", MakeStatusRoleOptions, {
	titleIcon = "Interface\\GroupFrame\\UI-Group-AssistantIcon",
} )
Grid2Options:RegisterStatusOptions("master-looter",  "role", MakeStatusRoleOptions, {
	titleIcon = "Interface\\GroupFrame\\UI-Group-MasterLooter"
})
Grid2Options:RegisterStatusOptions("role",           "role", MakeStatusRoleOptions, { 
	color1 = MAIN_ASSIST, 
	color2 = MAIN_TANK,
	width = "full",
	titleIcon = "Interface\\GroupFrame\\UI-Group-MainTankIcon",
})
Grid2Options:RegisterStatusOptions("dungeon-role",   "role", MakeStatusDungeonRoleOptions, { 
	color1 = LG["DAMAGER"], 
	color2 = LG["HEALER"], 
	color3 = LG["TANK"],
	width = "full",
	titleIcon = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
	titleIconCoords = {0,0.65,0,0.65},
})
