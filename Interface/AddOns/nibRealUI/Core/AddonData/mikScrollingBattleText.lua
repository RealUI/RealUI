local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

nibRealUI.LoadAddOnData_mikScrollingBattleText = function()
	MSBTProfiles_SavedVars = {
		["profiles"] = {
			["RealUI"] = {
				["critFontName"] = "pixel_crits",
				["stickyCritsDisabled"] = true,
				["animationSpeed"] = 70,
				["normalFontSize"] = 8,
				["textShadowingDisabled"] = true,
				["creationVersion"] = "5.4.78",
				["critFontSize"] = 16,
				["critOutlineIndex"] = 5,
				["events"] = {
					["NOTIFICATION_PC_KILLING_BLOW"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_MONEY"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SHADOW_ORBS_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ITEM_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_LOOT"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SOUL_SHARD_CREATED"] = {
						["alwaysSticky"] = false,
					},
					["INCOMING_HEAL_CRIT"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ALT_POWER_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_POWER_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CHI_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_DEBUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ALT_POWER_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SHADOW_ORBS_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_HOLY_POWER_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_MONSTER_EMOTE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_POWER_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_PET_COOLDOWN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ENEMY_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_EXTRA_ATTACK"] = {
						["alwaysSticky"] = false,
						["disabled"] = true,
					},
					["NOTIFICATION_COOLDOWN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_HOLY_POWER_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CHI_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ITEM_BUFF"] = {
						["disabled"] = true,
					},
				},
				["hideFullOverheals"] = true,
				["scrollAreas"] = {
					["Notification"] = {
						["direction"] = "Up",
						["stickyDirection"] = "Up",
						["scrollWidth"] = 300,
						["offsetX"] = -150,
						["normalFontSize"] = 16,
						["critFontSize"] = 16,
						["offsetY"] = 60,
						["scrollHeight"] = 100,
						["stickyAnimationStyle"] = "Static",
					},
					["Incoming"] = {
						["direction"] = "Up",
						["behavior"] = "MSBT_NORMAL",
						["stickyBehavior"] = "MSBT_NORMAL",
						["stickyDirection"] = "Up",
						["scrollHeight"] = 150,
						["offsetX"] = -295,
						["scrollWidth"] = 130,
						["iconAlign"] = "Right",
						["offsetY"] = 10,
						["animationStyle"] = "Straight",
						["stickyAnimationStyle"] = "Static",
					},
					["Static"] = {
						["disabled"] = true,
						["offsetY"] = -65,
					},
					["Outgoing"] = {
						["direction"] = "Up",
						["stickyBehavior"] = "MSBT_NORMAL",
						["scrollWidth"] = 130,
						["stickyDirection"] = "Up",
						["scrollHeight"] = 150,
						["offsetX"] = 165,
						["behavior"] = "MSBT_NORMAL",
						["iconAlign"] = "Left",
						["offsetY"] = 10,
						["animationStyle"] = "Straight",
						["stickyAnimationStyle"] = "Static",
					},
				},
				["normalFontName"] = "pixel_small",
				["normalOutlineIndex"] = 5,
				["triggers"] = {
					["MSBT_TRIGGER_IMPACT"] = {
						["disabled"] = true,
					},
					["Custom2"] = {
						["message"] = "New Trigger",
						["alwaysSticky"] = true,
						["disabled"] = true,
					},
					["MSBT_TRIGGER_DECIMATION"] = {
						["disabled"] = true,
					},
					["Custom1"] = {
						["message"] = "New Trigger",
						["alwaysSticky"] = true,
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MAELSTROM_WEAPON"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BERSERK"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_OVERPOWER"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SWORD_AND_BOARD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHADOW_ORB"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_RIME"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_THE_ART_OF_WAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_VITAL_MISTS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_RUNE_STRIKE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MANA_TEA"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BLINDSIDE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_TASTE_FOR_BLOOD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_HEALTH"] = {
						["soundFile"] = "Omen: Aoogah!",
						["iconSkill"] = "3273",
						["mainEvents"] = "UNIT_HEALTH{unitID;;eq;;player;;threshold;;lt;;25}",
						["disabled"] = true,
					},
					["MSBT_TRIGGER_KILLING_MACHINE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOCK_AND_LOAD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_TIDAL_WAVES"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_MANA"] = {
						["mainEvents"] = "UNIT_MANA{unitID;;eq;;player;;threshold;;lt;;25}",
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ECLIPSE_LUNAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_FINGERS_OF_FROST"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_HOT_STREAK"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_NIGHTFALL"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LAVA_SURGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SUDDEN_DEATH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_KILL_SHOT"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_OWLKIN_FRENZY"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ELUSIVE_BREW"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHOOTING_STARS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_PET_HEALTH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MOLTEN_CORE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ECLIPSE_SOLAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MISSILE_BARRAGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_VICTORY_RUSH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHADOW_INFUSION"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_CLEARCASTING"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BLOODSURGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_PREDATORS_SWIFTNESS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_EXECUTE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_HAMMER_OF_WRATH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_REVENGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_POWER_GUARD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BRAIN_FREEZE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BACKLASH"] = {
						["disabled"] = true,
					},
				},
			},
			["Default"] = {
				["critFontName"] = "pixel_crits",
				["stickyCritsDisabled"] = true,
				["animationSpeed"] = 70,
				["normalFontSize"] = 8,
				["textShadowingDisabled"] = true,
				["creationVersion"] = "5.4.78",
				["critFontSize"] = 16,
				["critOutlineIndex"] = 5,
				["events"] = {
					["NOTIFICATION_PC_KILLING_BLOW"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_MONEY"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SHADOW_ORBS_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ITEM_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_LOOT"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SOUL_SHARD_CREATED"] = {
						["alwaysSticky"] = false,
					},
					["INCOMING_HEAL_CRIT"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ALT_POWER_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_POWER_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CHI_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_DEBUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ALT_POWER_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SHADOW_ORBS_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_HOLY_POWER_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_MONSTER_EMOTE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_POWER_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_PET_COOLDOWN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ENEMY_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_EXTRA_ATTACK"] = {
						["alwaysSticky"] = false,
						["disabled"] = true,
					},
					["NOTIFICATION_COOLDOWN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_HOLY_POWER_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CHI_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ITEM_BUFF"] = {
						["disabled"] = true,
					},
				},
				["hideFullOverheals"] = true,
				["scrollAreas"] = {
					["Notification"] = {
						["direction"] = "Up",
						["stickyDirection"] = "Up",
						["scrollWidth"] = 300,
						["offsetX"] = -150,
						["normalFontSize"] = 16,
						["critFontSize"] = 16,
						["offsetY"] = 60,
						["scrollHeight"] = 100,
						["stickyAnimationStyle"] = "Static",
					},
					["Incoming"] = {
						["direction"] = "Up",
						["behavior"] = "MSBT_NORMAL",
						["stickyBehavior"] = "MSBT_NORMAL",
						["stickyDirection"] = "Up",
						["scrollHeight"] = 150,
						["offsetX"] = -295,
						["scrollWidth"] = 130,
						["iconAlign"] = "Right",
						["offsetY"] = 10,
						["animationStyle"] = "Straight",
						["stickyAnimationStyle"] = "Static",
					},
					["Static"] = {
						["disabled"] = true,
						["offsetY"] = -65,
					},
					["Outgoing"] = {
						["direction"] = "Up",
						["stickyBehavior"] = "MSBT_NORMAL",
						["scrollWidth"] = 130,
						["stickyDirection"] = "Up",
						["scrollHeight"] = 150,
						["offsetX"] = 165,
						["behavior"] = "MSBT_NORMAL",
						["iconAlign"] = "Left",
						["offsetY"] = 10,
						["animationStyle"] = "Straight",
						["stickyAnimationStyle"] = "Static",
					},
				},
				["normalFontName"] = "pixel_small",
				["normalOutlineIndex"] = 5,
				["triggers"] = {
					["MSBT_TRIGGER_IMPACT"] = {
						["disabled"] = true,
					},
					["Custom2"] = {
						["message"] = "New Trigger",
						["alwaysSticky"] = true,
						["disabled"] = true,
					},
					["MSBT_TRIGGER_DECIMATION"] = {
						["disabled"] = true,
					},
					["Custom1"] = {
						["message"] = "New Trigger",
						["alwaysSticky"] = true,
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MAELSTROM_WEAPON"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BERSERK"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_OVERPOWER"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SWORD_AND_BOARD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHADOW_ORB"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_RIME"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_THE_ART_OF_WAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_VITAL_MISTS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_RUNE_STRIKE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MANA_TEA"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BLINDSIDE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_TASTE_FOR_BLOOD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_HEALTH"] = {
						["soundFile"] = "Omen: Aoogah!",
						["iconSkill"] = "3273",
						["mainEvents"] = "UNIT_HEALTH{unitID;;eq;;player;;threshold;;lt;;25}",
						["disabled"] = true,
					},
					["MSBT_TRIGGER_KILLING_MACHINE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOCK_AND_LOAD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_TIDAL_WAVES"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_MANA"] = {
						["mainEvents"] = "UNIT_MANA{unitID;;eq;;player;;threshold;;lt;;25}",
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ECLIPSE_LUNAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_FINGERS_OF_FROST"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_HOT_STREAK"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_NIGHTFALL"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LAVA_SURGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SUDDEN_DEATH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_KILL_SHOT"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_OWLKIN_FRENZY"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ELUSIVE_BREW"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHOOTING_STARS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_PET_HEALTH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MOLTEN_CORE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ECLIPSE_SOLAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MISSILE_BARRAGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_VICTORY_RUSH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHADOW_INFUSION"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_CLEARCASTING"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BLOODSURGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_PREDATORS_SWIFTNESS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_EXECUTE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_HAMMER_OF_WRATH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_REVENGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_POWER_GUARD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BRAIN_FREEZE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BACKLASH"] = {
						["disabled"] = true,
					},
				},
			},
		},
	}
	MSBT_SavedMedia = {
		["fonts"] = {
		},
		["sounds"] = {
		},
	}
end