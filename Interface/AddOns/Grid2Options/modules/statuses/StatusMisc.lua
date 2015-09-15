-- statuses with very simple options has been grouped in this file

local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("name", "hidden")

Grid2Options:RegisterStatusOptions("afk", "misc", nil, {
	titleIcon = "Interface\\ICONS\\Spell_nature_sleep"
})

Grid2Options:RegisterStatusOptions("voice", "misc", nil, {
	titleIcon = "Interface\\COMMON\\VOICECHAT-SPEAKER"
})

Grid2Options:RegisterStatusOptions("offline", "misc", nil, {
	titleIcon = "Interface\\CharacterFrame\\Disconnect-Icon",
	titleIconCoords = {0.3,0.7,0.2,0.8},
})

Grid2Options:RegisterStatusOptions("vehicle", "misc", nil, {
	titleIcon = "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up",
	titleIconCoords = {0.2,0.8,0.2,0.8},
})

Grid2Options:RegisterStatusOptions("target", "target", nil, {
	title = L["highlights your target"],
	titleIcon = "Interface\\Icons\\Ability_hunter_mastermarksman",
})

Grid2Options:RegisterStatusOptions("pvp", "combat", nil, {
	titleIcon = UnitFactionGroup("player") == "Horde" and  "Interface\\PVPFrame\\PVP-Currency-Horde" or "Interface\\PVPFrame\\PVP-Currency-Alliance"
})	

Grid2Options:RegisterStatusOptions("self", "target", nil, {
	titleIcon = "Interface\\Icons\\Inv_wand_12",
})

Grid2Options:RegisterStatusOptions("resurrection", "combat", nil, {
	color1 = L["Casting resurrection"],
	colorDesc1 = L["A resurrection spell is being casted on the unit"],
	color2 = L["Resurrected"],
	colorDesc2 = L["A resurrection spell has been casted on the unit"],
	width = "full",
	titleIcon = "Interface\\RaidFrame\\Raid-Icon-Rez",
})

