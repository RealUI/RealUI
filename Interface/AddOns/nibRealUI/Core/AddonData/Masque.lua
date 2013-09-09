local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

nibRealUI.LoadAddOnData_Masque = function()
	MasqueDB = {
		["namespaces"] = {
			["LibDualSpec-1.0"] = {
			},
		},
		["profileKeys"] = {
			["Real - Zul'jin"] = "RealUI",
		},
		["profiles"] = {
			["Default"] = {
				["Groups"] = {
					["Bartender4_StanceBar"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4_Vehicle"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4_1"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4_3"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Raven_NestIcons"] = {
						["Fonts"] = true,
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Bartender4_2"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4_BagBar"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["Bartender4_4"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Raven"] = {
						["Fonts"] = true,
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Bartender4_10"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["Bartender4_9"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["Bartender4_5"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4_MicroMenu"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["Masque"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4_PetBar"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4_8"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["Bartender4_7"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["Bartender4_6"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
				},
			},
			["RealUI"] = {
				["Groups"] = {
					["Raven_FocusBuffs"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Raven_PlayerBuffsExtra"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Bartender4_StanceBar"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Raven_TargetBuffsExtraPvP"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Raven_TargetBuffsExtra2"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Bartender4_1"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Backdrop"] = true,
					},
					["Bartender4_3"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Backdrop"] = true,
					},
					["Raven_TargetBuffsExtra"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["SBF"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Raven_FocusBuffsExtra"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Raven_Buffs"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Bartender4_5"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Backdrop"] = true,
					},
					["Bartender4_MicroMenu"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["SBF_TargetDebuffs"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["SBF_PlayerDebuffs"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["SBF_Buffs"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4_6"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Backdrop"] = true,
					},
					["SBF_ToTDebuffs"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Raven_TargetBuffs"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Bartender4_Vehicle"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Backdrop"] = true,
					},
					["SBF_PlayerBuffs"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["SBF_PetBuffs"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Raven_PlayerDebuffs"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Raven_ToTDebuffs"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["SBF_TargetBuffsMy"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4_BagBar"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["SBF_Debuffs"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["Raven"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["Raven_TargetDebuffs"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Raven_TargetDebuffsExtra"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Bartender4_PetBar"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Backdrop"] = true,
					},
					["Bartender4"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Backdrop"] = true,
					},
					["Raven_FocusDebuffs"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["SBF_FocusDebuffs"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Bartender4_4"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Backdrop"] = true,
					},
					["Raven_PlayerBuffs"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Raven_NestIcons"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Inherit"] = false,
					},
					["Bartender4_2"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Backdrop"] = true,
					},
					["SBF_FocusBuffs"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
					},
					["Raven_ToTDebuffsExtra"] = {
						["Inherit"] = false,
						["SkinID"] = "RealUI",
					},
					["Masque"] = {
						["Fonts"] = true,
						["SkinID"] = "RealUI",
						["Backdrop"] = true,
					},
				},
			},
		},
	}
end