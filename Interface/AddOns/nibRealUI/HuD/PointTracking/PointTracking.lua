local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "PointTracking"
local PointTracking = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local db, ndb

local floor = math.floor

-- local GreenFire

local Types = {
	["GENERAL"] = {
		name = "General",
		points = {
			[1] = {name = "Combo Points", id = "cp", barcount = 5},
		},
	},
	["MONK"] = {
		name = "Monk",
		points = {
			[1] = {name = "Chi", id = "chi", barcount = 5},
		},
	},
	["PALADIN"] = {
		name = "Paladin",
		points = {
			[1] = {name = "Holy Power", id = "hp", barcount = 5},
		},
	},
	["PRIEST"] = {
		name = "Priest",
		points = {
			[1] = {name = "Shadow Orbs", id = "so", barcount = 3},
		},
	},
	["ROGUE"] = {
		name = "Rogue",
		points = {
			[1] = {name = "Anticipation Points", id = "ap", barcount = 5},
		},
	},
	["WARLOCK"] = {
		name = "Warlock",
		points = {
			[1] = {name = "Soul Shards", id = "ss", barcount = 4},
			[2] = {name = "Burning Embers", id = "be", barcount = 4},
		},
	},
}

-----------------
---- Options ----
-----------------
local table_Orientation = {
	"Horizontal",
	"Vertical",
}

local table_Specs = {
	"None",
	"Primary",
	"Secondary",
}

-- Return the Options table
local options = nil
local function GetOptions()
	if not options then
		options = {
			type = "group",
			name = "Point Display",
			arg = MODNAME,
			order = 1615,
			args = {
				header = {
					type = "header",
					name = "Point Display",
					order = 10,
				},
				enabled = {
					type = "toggle",
					name = "Enabled",
					desc = "Enable/Disable the Point Display module.",
					get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
					set = function(info, value) 
						nibRealUI:SetModuleEnabled(MODNAME, value)
						nibRealUI:ReloadUIDialog()
					end,
					order = 20,
				},
			},
		}
	end
	
	local ClassOpts, TypeOpts, BarOpts = {}, {}, {}
	local Opts_ClassOrderCnt = 40
	local Opts_TypeOrderCnt = 10
	
	for ic,vc in pairs(Types) do
		local ClassID = Types[ic].name
		
		wipe(TypeOpts)
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id			
			local TypeDesc = Types[ic].points[it].name
			
			TypeOpts[tid] = {
				type = "group",
				name = TypeDesc,
				childGroups = "tab",
				order = Opts_TypeOrderCnt,
				args = {
					header = {
						type = "header",
						name = string.format("%s - %s", ClassID, TypeDesc),
						order = 10,
					},
					enabled = {
						type = "toggle",
						name = "Enabled",
						desc = string.format("Enable/Disable the %s display.", TypeDesc),
						get = function() return db[ic].types[tid].enabled end,
						set = function(info, value) 
							db[ic].types[tid].enabled = value
							db[ic].types[tid].configmode.enabled = false
							if not value then
								PointTracking:DisablePointTracking(ic, tid)
							else
								PointTracking:EnablePointTracking(ic, tid)
							end
						end,
						order = 20,					
					},
					sep = {
						type = "description",
						name = " ",
						order = 22,
					},
					config = {
						name = "Configuration",
						type = "group",
						order = 30,
						disabled = function() if db[ic].types[tid].enabled then return false else return true end end,
						args = {
							configmode = {
								type = "toggle",
								name = "Configuration Mode",
								get = function(info) return db[ic].types[tid].configmode.enabled end,
								set = function(info, value) 
									db[ic].types[tid].configmode.enabled = value
									PointTracking:UpdatePoints("ENABLE")
								end,
								order = 10,
							},
							configmodecount = {
								type = "range",
								name = "Config Mode point count",
								min = 0, max = Types[ic].points[it].barcount, step = 1,
								get = function(info) return db[ic].types[tid].configmode.count end,
								set = function(info, value) 
									db[ic].types[tid].configmode.count = value
									PointTracking:UpdatePoints("ENABLE")
								end,
								disabled = function() if db[ic].types[tid].configmode.enabled and db[ic].types[tid].enabled then return false else return true end end,
								order = 20,
							},
						},
					},				
					general = {
						name = "General Settings",
						type = "group",
						order = 70,
						disabled = function() if db[ic].types[tid].enabled then return false else return true end end,
						args = {
							appearance = {
								name = "Appearance",
								type = "group",
								order = 10,
								inline = true,
								args = {
									hideui = {
										type = "toggle",
										name = "Hide default UI display",
										desc = "Note: A UI reload (/reload ui) is required to make the default UI display visible again if you have it hidden.",
										width = "full",
										get = function(info) return db[ic].types[tid].general.hideui end,
										set = function(info, value) 
											db[ic].types[tid].general.hideui = value
											PointTracking:HideUIElements()
										end,
										order = 10,
										disabled = function() if (tid == "cp" or tid == "hp" or tid == "ss") then return false else return true end end,
									},
									hideempty = {
										type = "toggle",
										name = "Hide unused points/stacks",
										desc = "Only show used the number of points/stacks you have. IE. If you have 4 Combo Points, the 5th Combo Point bar will remain hidden.",
										width = "full",
										get = function(info) return db[ic].types[tid].general.hideempty end,
										set = function(info, value) 
											db[ic].types[tid].general.hideempty = value
											PointTracking:UpdatePoints("ENABLE")
										end,
										order = 20,
									},
									smarthide = {
										type = "toggle",
										name = "Smart hide",
										desc = "Hide while solo, ungrouped, not in an instance. Will still show if you have an attackable target selected or are in combat.",
										width = "full",
										get = function(info) return db[ic].types[tid].general.smarthide end,
										set = function(info, value) 
											db[ic].types[tid].general.smarthide = value
											PointTracking:UpdateSmartHideConditions()
											PointTracking:UpdatePointTracking()
										end,
										order = 30,
									},
									hidein = {
										type = "group",
										name = "Hide in",
										inline = true,
										order = 40,
										args = {
											vehicle = {
												type = "toggle",
												name = "Vehicle",
												desc = "Hide when in a Vehicle.",
												width = "full",
												get = function(info) return db[ic].types[tid].general.hidein.vehicle end,
												set = function(info, value) 
													db[ic].types[tid].general.hidein.vehicle = value
													PointTracking:UpdatePoints("ENABLE")
												end,
												order = 10,
											},
											spec = {
												type = "select",
												name = "Spec",
												get = function(info)
													return db[ic].types[tid].general.hidein.spec
												end,
												set = function(info, value)
													db[ic].types[tid].general.hidein.spec = value
													PointTracking:UpdatePoints("ENABLE")
												end,
												style = "dropdown",
												width = nil,
												values = table_Specs,
												order = 30,
											},
										},
									},
									direction = {
										type = "group",
										name = "Direction",
										inline = true,
										order = 40,
										args = {
											reverse = {
												type = "toggle",
												name = "Reverse orientation",
												desc = string.format("Reverse the orientation of the %s display.", TypeDesc),
												width = "full",
												get = function(info) return db[ic].types[tid].general.direction.reverse end,
												set = function(info, value) 
													db[ic].types[tid].general.direction.reverse = value
													PointTracking:UpdatePosition()
												end,
												order = 20,
											},
										},
									},									
								},
							},
						},
					},
					position = {
						type = "group",
						name = "Position",
						order = 80,
						disabled = function() if db[ic].types[tid].enabled then return false else return true end end,
						args = {
							position = {
								name = "Position",
								type = "group",
								inline = true,
								order = 20,
								args = {
									xoffset = {
										type = "input",
										name = "X Offset",
										width = "half",
										order = 10,
										get = function(info) return tostring(db[ic].types[tid].position.x) end,
										set = function(info, value)
											value = nibRealUI:ValidateOffset(value)
											db[ic].types[tid].position.x = value
											PointTracking:UpdatePosition()
										end,
									},
									yoffset = {
										type = "input",
										name = "Y Offset",
										width = "half",
										order = 20,
										get = function(info) return tostring(db[ic].types[tid].position.y) end,
										set = function(info, value)
											value = nibRealUI:ValidateOffset(value)
											db[ic].types[tid].position.y = value
											PointTracking:UpdatePosition()
										end,
									},
								},
							},
							framelevel = {
								type = "group",
								name = "Strata",
								inline = true,
								order = 30,
								args = {
									strata = {
										type = "select",
										name = "Strata",
										get = function(info) 
											for k,v in pairs(nibRealUI.globals.stratas) do
												if v == db[ic].types[tid].position.framelevel.strata then return k end
											end
										end,
										set = function(info, value)
											db[ic].types[tid].position.framelevel.strata = nibRealUI.globals.stratas[value]
											PointTracking:UpdatePosition()
										end,
										style = "dropdown",
										width = nil,
										values = nibRealUI.globals.stratas,
										order = 10,
									},
									level = {
										type = "range",
										name = "Frame Level",
										min = 1, max = 50, step = 1,
										get = function(info) return db[ic].types[tid].position.framelevel.level end,
										set = function(info, value) 
											db[ic].types[tid].position.framelevel.level = value
											PointTracking:UpdatePosition()
										end,
										order = 20,
									},
								},
							},
						},
					},
					bars = {
						name = "Point Bars",
						type = "group",
						childGroups = "tab",
						order = 90,
						disabled = function() if db[ic].types[tid].enabled then return false else return true end end,					
						args = {
							usecustom = {
								type = "toggle",
								name = "Use Custom RealUI Textures",
								width = "double",
								disabled = function() return tid ~= "hp" end,
								get = function(info) return db[ic].types[tid].bars.custom end,
								set = function(info, value) 
									db[ic].types[tid].bars.custom = value
									PointTracking:UpdatePoints("ENABLE")
								end,
								order = 10,
							},
							positionsize = {
								name = "Position/Size",
								type = "group",
								order = 20,
								args = {
									size = {
										type = "group",
										name = "Size",
										inline = true,
										order = 10,
										args = {
											width = {
												type = "input",
												name = "Width",
												width = "half",
												order = 10,
												get = function(info) return tostring(db[ic].types[tid].bars.size.width) end,
												set = function(info, value)
													value = nibRealUI:ValidateOffset(value)
													db[ic].types[tid].bars.size.width = value
													PointTracking:UpdatePosition()
													PointTracking:UpdatePoints("ENABLE")
												end,
											},
											height = {
												type = "input",
												name = "Height",
												width = "half",
												order = 20,
												get = function(info) return tostring(db[ic].types[tid].bars.size.height) end,
												set = function(info, value)
													value = nibRealUI:ValidateOffset(value)
													db[ic].types[tid].bars.size.height = value
													PointTracking:UpdatePosition()
													PointTracking:UpdatePoints("ENABLE")
												end,
											},
										},							
									},
									position = {
										name = "Position",
										type = "group",
										inline = true,
										order = 20,
										args = {
											gap = {
												type = "input",
												name = "Gap",
												desc = "Set the space between each Bar. Negative values bring them closer together. Positive values push them further apart.",
												width = "half",
												order = 30,
												get = function(info) return tostring(db[ic].types[tid].bars.position.gap) end,
												set = function(info, value)
													value = nibRealUI:ValidateOffset(value)
													db[ic].types[tid].bars.position.gap = value
													PointTracking:UpdatePosition()
												end,
											},
										},
									},
								},
							},
							background = {
								name = "Background",
								type = "group",
								-- disabled = function() return db[ic].types[tid].bars.custom end,
								order = 30,
								args = {
									empty = {
										name = "Empty",
										type = "group",
										inline = true,
										order = 10,
										args = {
											texture = {
												type = "select",
												name = "Texture",
												values = AceGUIWidgetLSMlists.background,
												get = function()
													return db[ic].types[tid].bars.bg.empty.texture
												end,
												set = function(info, value)
													db[ic].types[tid].bars.bg.empty.texture = value
													PointTracking:GetTextures()
													PointTracking:UpdatePoints("ENABLE")
												end,
												dialogControl='LSM30_Background',
												order = 10,
											},
											color = {
												type = "color",
												name = "Color",
												hasAlpha = true,
												get = function(info,r,g,b,a)
													return db[ic].types[tid].bars.bg.empty.color.r, db[ic].types[tid].bars.bg.empty.color.g, db[ic].types[tid].bars.bg.empty.color.b, db[ic].types[tid].bars.bg.empty.color.a
												end,
												set = function(info,r,g,b,a)
													db[ic].types[tid].bars.bg.empty.color.r = r
													db[ic].types[tid].bars.bg.empty.color.g = g
													db[ic].types[tid].bars.bg.empty.color.b = b
													db[ic].types[tid].bars.bg.empty.color.a = a
													PointTracking:UpdatePoints("ENABLE")
												end,
												order = 20,
											},
										},
									},
									full = {
										name = "Full",
										type = "group",
										inline = true,
										order = 20,
										args = {
											texture = {
												type = "select",
												name = "Texture",
												values = AceGUIWidgetLSMlists.background,
												get = function()
													return db[ic].types[tid].bars.bg.full.texture
												end,
												set = function(info, value)
													db[ic].types[tid].bars.bg.full.texture = value
													PointTracking:GetTextures()
													PointTracking:UpdatePoints("ENABLE")
												end,
												dialogControl='LSM30_Background',
												order = 10,
											},
											colors = {
												type = "group",
												name = "Colors",
												inline = true,
												order = 20,
												args = {
													color = {
														type = "color",
														name = "Normal",
														hasAlpha = true,
														get = function(info,r,g,b,a)
															return db[ic].types[tid].bars.bg.full.color.r, db[ic].types[tid].bars.bg.full.color.g, db[ic].types[tid].bars.bg.full.color.b, db[ic].types[tid].bars.bg.full.color.a
														end,
														set = function(info,r,g,b,a)
															db[ic].types[tid].bars.bg.full.color.r = r
															db[ic].types[tid].bars.bg.full.color.g = g
															db[ic].types[tid].bars.bg.full.color.b = b
															db[ic].types[tid].bars.bg.full.color.a = a
															PointTracking:UpdatePoints("ENABLE")
														end,
														order = 10,
													},
													maxcolor = {
														type = "color",
														name = "Max Points",
														desc = string.format("%s %s %s", "Set the background color of this Bar when", TypeDesc, "reaches it's maximum stacks."),
														hasAlpha = true,
														get = function(info,r,g,b,a)
															return db[ic].types[tid].bars.bg.full.maxcolor.r, db[ic].types[tid].bars.bg.full.maxcolor.g, db[ic].types[tid].bars.bg.full.maxcolor.b, db[ic].types[tid].bars.bg.full.maxcolor.a
														end,
														set = function(info,r,g,b,a)
															db[ic].types[tid].bars.bg.full.maxcolor.r = r
															db[ic].types[tid].bars.bg.full.maxcolor.g = g
															db[ic].types[tid].bars.bg.full.maxcolor.b = b
															db[ic].types[tid].bars.bg.full.maxcolor.a = a
															PointTracking:UpdatePoints("ENABLE")
														end,
														order = 20,
													},
												},
											},
										},
									},
								},
							},
							surround = {
								name = "Surround",
								type = "group",
								disabled = function() return db[ic].types[tid].bars.custom end,
								order = 40,
								args = {
									texture = {
										type = "select",
										name = "Texture",
										values = AceGUIWidgetLSMlists.background,
										get = function()
											return db[ic].types[tid].bars.surround.texture
										end,
										set = function(info, value)
											db[ic].types[tid].bars.surround.texture = value
											PointTracking:GetTextures()
											PointTracking:UpdatePoints("ENABLE")
										end,
										dialogControl='LSM30_Background',
										order = 10,
									},
									color = {
										type = "color",
										name = "Color",
										hasAlpha = true,
										get = function(info,r,g,b,a)
											return db[ic].types[tid].bars.surround.color.r, db[ic].types[tid].bars.surround.color.g, db[ic].types[tid].bars.surround.color.b, db[ic].types[tid].bars.surround.color.a
										end,
										set = function(info,r,g,b,a)
											db[ic].types[tid].bars.surround.color.r = r
											db[ic].types[tid].bars.surround.color.g = g
											db[ic].types[tid].bars.surround.color.b = b
											db[ic].types[tid].bars.surround.color.a = a
											PointTracking:UpdatePoints("ENABLE")
										end,
										order = 20,
									},
								},
							},
						},
					},
				},
			}
			
			Opts_TypeOrderCnt = Opts_TypeOrderCnt + 10
		end
		
		-- Create new Class table
		ClassOpts[ic] = {
			name = ClassID,
			type = "group",
			order = Opts_ClassOrderCnt,
			args = {},
		}
		-- Fill out new Class table with it's Types
		for key, val in pairs(TypeOpts) do
			ClassOpts[ic].args[key] = (type(val) == "function") and val() or val
		end
		
		Opts_ClassOrderCnt = Opts_ClassOrderCnt + 10
	end
	
	-- Combat Fader
	local Opts_CombatFader = {
		["combatfader"] = {
			type = "group",
			name = "Combat Fader",
			childGroups = "tab",
			order = 5,
			args = {
				header = {
					type = "header",
					name = "Combat Fader",
					order = 10,
				},
				desc = {
					type = "description",
					name = "Controls the fading of the Point Displays based on player status.",
					order = 20,
				},
				enabled = {
					type = "toggle",
					name = "Enabled",
					desc = "Enable/Disable combat fading.",
					get = function() return db.combatfader.enabled end,
					set = function(info, value) 
						db.combatfader.enabled = value
						PointTracking:UpdateCombatFader()
					end,
					order = 30,
				},
				sep = {
					type = "description",
					name = " ",
					order = 40,
				},
				opacity = {
					type = "group",
					name = "Opacity",
					inline = true,
					disabled = function() if db.combatfader.enabled then return false else return true end end,
					order = 60,
					args = {
						incombat = {
							type = "range",
							name = "In-combat",
							min = 0, max = 1, step = 0.05,
							isPercent = true,
							get = function(info) return db.combatfader.opacity.incombat end,
							set = function(info, value) db.combatfader.opacity.incombat = value; PointTracking:UpdateCombatFader(); end,
							order = 10,
						},
						hurt = {
							type = "range",
							name = "Hurt",
							min = 0, max = 1, step = 0.05,
							isPercent = true,
							get = function(info) return db.combatfader.opacity.hurt end,
							set = function(info, value) db.combatfader.opacity.hurt = value; PointTracking:UpdateCombatFader(); end,
							order = 20,
						},
						target = {
							type = "range",
							name = "Target-selected",
							min = 0, max = 1, step = 0.05,
							isPercent = true,
							get = function(info) return db.combatfader.opacity.target end,
							set = function(info, value) db.combatfader.opacity.target = value; PointTracking:UpdateCombatFader(); end,
							order = 30,
						},
						outofcombat = {
							type = "range",
							name = "Out-of-combat",
							min = 0, max = 1, step = 0.05,
							isPercent = true,
							get = function(info) return db.combatfader.opacity.outofcombat end,
							set = function(info, value) db.combatfader.opacity.outofcombat = value; PointTracking:UpdateCombatFader(); end,
							order = 40,
						},
					},
				},
			},
		},
	}
	for k, v in pairs(Opts_CombatFader) do
		ClassOpts[k] = (type(v) == "function") and v() or v
	end
	
	-- Fill out Options table with all Classes
	for key, val in pairs(ClassOpts) do
		options.args[key] = (type(val) == "function") and val() or val
	end
	
	return options
end

---- Spell Info table
local SpellInfo = {
	["ap"] = nil,
}

-- Point Display tables
local Frames = {}
local BG = {}

-- Points
local Points = {}
local PointsChanged = {}
local EBPoints = 0	-- Elusive Brew

local HolyPowerTexture
local SoulShardBG

local PlayerClass
local PlayerSpec
local PlayerTalent = 0
local PlayerInCombat
local PlayerTargetHostile
local PlayerInInstance
local SmartHideConditions
local ValidClasses

-- Combat Fader
local CFFrame = CreateFrame("Frame")
local FadeTime = 0.25
local CFStatus = nil

-- Power 'Full' check
local power_check = {
	MANA = function()
		return UnitMana("player") < UnitManaMax("player")
	end,
	RAGE = function()
		return UnitMana("player") > 0
	end,
	ENERGY = function()
		return UnitMana("player") < UnitManaMax("player")
	end,
	RUNICPOWER = function()
		return UnitMana("player") > 0
	end,
}

-- Fade frame
local function FadeIt(self, NewOpacity)
	local CurrentOpacity = self:GetAlpha()
	if NewOpacity > CurrentOpacity then
		UIFrameFadeIn(self, FadeTime, CurrentOpacity, NewOpacity)
	elseif NewOpacity < CurrentOpacity then
		UIFrameFadeOut(self, FadeTime, CurrentOpacity, NewOpacity)
	end
end

-- Determine new opacity values for frames
function PointTracking:FadeFrames()
	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local NewOpacity
			local tid = Types[ic].points[it].id
			-- Retrieve opacity/visibility for current status
			NewOpacity = 1
			if db.combatfader.enabled then
				if CFStatus == "DISABLED" then
					NewOpacity = 1
				elseif CFStatus == "INCOMBAT" then
					NewOpacity = db.combatfader.opacity.incombat
				elseif CFStatus == "TARGET" then
					NewOpacity = db.combatfader.opacity.target
				elseif CFStatus == "HURT" then
					NewOpacity = db.combatfader.opacity.hurt
				elseif CFStatus == "OUTOFCOMBAT" then
					NewOpacity = db.combatfader.opacity.outofcombat
				end

				-- Fade Frame
				FadeIt(Frames[ic][tid].bgpanel.frame, NewOpacity)
			else
				-- Combat Fader disabled for this frame
				if Frames[ic][tid].bgpanel.frame:GetAlpha() < 1 then
					FadeIt(Frames[ic][tid].bgpanel.frame, NewOpacity)
				end
			end
		end
	end
	PointTracking:UpdatePointTracking("ENABLE")
end

function PointTracking:UpdateCFStatus()
	local OldStatus = CFStatus
	
	-- Combat Fader based on status
	if UnitAffectingCombat("player") then
		CFStatus = "INCOMBAT"
	elseif UnitExists("target") then
		CFStatus = "TARGET"
	elseif UnitHealth("player") < UnitHealthMax("player") then
		CFStatus = "HURT"
	else
		local _, power_token = UnitPowerType("player")
		local func = power_check[power_token]
		if func and func() then
			CFStatus = "HURT"
		else
			CFStatus = "OUTOFCOMBAT"
		end
	end
	if CFStatus ~= OldStatus then PointTracking:FadeFrames() end
end

function PointTracking:UpdateCombatFader()
	CFStatus = nil
	PointTracking:UpdateCFStatus()
end

-- On combat state change
function PointTracking:CombatFaderCombatState()
	-- If in combat, then don't worry about health/power events
	if UnitAffectingCombat("player") then
		CFFrame:UnregisterEvent("UNIT_HEALTH")
		CFFrame:UnregisterEvent("UNIT_POWER")
		CFFrame:UnregisterEvent("UNIT_DISPLAYPOWER")
	else
		CFFrame:RegisterEvent("UNIT_HEALTH")
		CFFrame:RegisterEvent("UNIT_POWER")
		CFFrame:RegisterEvent("UNIT_DISPLAYPOWER")
	end
end

-- Register events for Combat Fader status
function PointTracking:UpdateCombatFaderEnabled()
	CFFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	CFFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	CFFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	CFFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	CFFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
			PointTracking:CombatFaderCombatState()
			PointTracking:UpdateCFStatus()
		elseif event == "UNIT_HEALTH" or event == "UNIT_POWER" or event == "UNIT_DISPLAYPOWER" then
			local unit = ...
			if unit == "player" then
				PointTracking:UpdateCFStatus()
			end
		elseif event == "PLAYER_TARGET_CHANGED" then
			PointTracking:UpdateCFStatus()
		elseif event == "PLAYER_ENTERING_WORLD" then
			PointTracking:CombatFaderCombatState()
			PointTracking:UpdateCombatFader()
		end
	end)
	
	PointTracking:UpdateCombatFader()
	PointTracking:FadeFrames()
end

-- Update Point Bars
local PBTex = {}
local ebColors = {
	[1] = {1, 1, 1},
	[2] = {1, 1, 0},
	[0] = {1, 0, 0}
}
local function SetPointBarTextures(shown, ic, it, tid, i)
	if tid == "hp" and db[ic].types[tid].bars.custom then
		PBTex.empty = nil
		PBTex.full = HolyPowerTexture[i]
		PBTex.surround = nil
	else
		PBTex.empty = BG[ic][tid].bars.empty
		PBTex.full = BG[ic][tid].bars.full
		PBTex.surround = BG[ic][tid].bars.surround
	end
	
	-- Visible Bar
	if shown then
		-- BG
		Frames[ic][tid].bars[i].bg:SetTexture(PBTex.full)
		
		-- Custom Colors
		if tid == "ap" or tid == "cp" then	-- Anticipation Point stack coloring
			if Points["ap"] > 0 then
				for api = 1, Points["ap"] do
					if api > Points["cp"] then
						Frames["ROGUE"]["ap"].bars[api].bg:SetVertexColor(db["ROGUE"].types["ap"].bars.bg.full.color.r, db["ROGUE"].types["ap"].bars.bg.full.color.g, db["ROGUE"].types["ap"].bars.bg.full.color.b, db["ROGUE"].types["ap"].bars.bg.full.color.a)
					else
						Frames["ROGUE"]["ap"].bars[api].bg:SetVertexColor(db["ROGUE"].types["ap"].bars.bg.full.maxcolor.r, db["ROGUE"].types["ap"].bars.bg.full.maxcolor.g, db["ROGUE"].types["ap"].bars.bg.full.maxcolor.b, db["ROGUE"].types["ap"].bars.bg.full.maxcolor.a)
					end
				end
			end

		-- Normal Colors
		else
			if Points[tid] < Types[ic].points[it].barcount then
				Frames[ic][tid].bars[i].bg:SetVertexColor(db[ic].types[tid].bars.bg.full.color.r, db[ic].types[tid].bars.bg.full.color.g, db[ic].types[tid].bars.bg.full.color.b, db[ic].types[tid].bars.bg.full.color.a)
			else
				Frames[ic][tid].bars[i].bg:SetVertexColor(db[ic].types[tid].bars.bg.full.maxcolor.r, db[ic].types[tid].bars.bg.full.maxcolor.g, db[ic].types[tid].bars.bg.full.maxcolor.b, db[ic].types[tid].bars.bg.full.maxcolor.a)
			end
		end
		Frames[ic][tid].bars[i].surround:SetVertexColor(db[ic].types[tid].bars.surround.color.r, db[ic].types[tid].bars.surround.color.g, db[ic].types[tid].bars.surround.color.b, db[ic].types[tid].bars.surround.color.a)
		
	-- Empty Bar
	else
		-- BG
		Frames[ic][tid].bars[i].bg:SetTexture(PBTex.empty)
		Frames[ic][tid].bars[i].bg:SetVertexColor(db[ic].types[tid].bars.bg.empty.color.r, db[ic].types[tid].bars.bg.empty.color.g, db[ic].types[tid].bars.bg.empty.color.b, db[ic].types[tid].bars.bg.empty.color.a)
	end
	Frames[ic][tid].bars[i].surround:SetTexture(PBTex.surround)
end

function PointTracking:UpdatePointTracking(...)
	local UpdateList
	if ... == "ENABLE" then
		-- Update everything
		UpdateList = Types
	else
		UpdateList = ValidClasses
	end
	
	-- Cycle through all Types that need updating
	for ic,vc in pairs(UpdateList) do
		-- Cycle through all Point Displays in current Type
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id
			
			-- Do we hide the Display
			if ((Points[tid] == 0)
				or (ic ~= PlayerClass and ic ~= "GENERAL") 
				or ((PlayerClass ~= "ROGUE") and (PlayerClass ~= "DRUID") and (ic == "GENERAL") and not UnitHasVehicleUI("player"))
				or ((PlayerClass == "WARLOCK") and (PlayerTalent == 1) and (tid == "be")) --
				or ((PlayerClass == "WARLOCK") and (PlayerTalent == 3) and (tid == "ss")) --	
				or (db[ic].types[tid].general.hidein.vehicle and UnitHasVehicleUI("player")) 
				or ((db[ic].types[tid].general.hidein.spec - 1) == PlayerSpec)
				or (db[ic].types[tid].general.smarthide and SmartHideConditions))
				and not db[ic].types[tid].configmode.enabled then
					-- Hide Display	
					Frames[ic][tid].bgpanel.frame:Hide()

					-- Anticipation Points refresh on 0 Combo Points
					if tid == "cp" and Points["ap"] > 0 then
						SetPointBarTextures(true, "ROGUE", 1, "ap", Points["ap"])
					end
			else
			-- Update the Display
				-- Update Bars if their Points have changed
				if PointsChanged[tid] then
					for i = 1, Types[ic].points[it].barcount do
						if Points[tid] == nil then Points[tid] = 0 end
						if Points[tid] >= i then
						-- Show bar and set textures to "Full"
							Frames[ic][tid].bars[i].frame:Show()
							SetPointBarTextures(true, ic, it, tid, i)
						else
							if db[ic].types[tid].general.hideempty then
							-- Hide "empty" bar
								Frames[ic][tid].bars[i].frame:Hide()
							else
							-- Show bar and set textures to "Empty"
								Frames[ic][tid].bars[i].frame:Show()
								SetPointBarTextures(false, ic, it, tid, i)
							end				
						end
						
					end
					-- Show the Display
					Frames[ic][tid].bgpanel.frame:Show()
					
					-- Flag as having been changed
					PointsChanged[tid] = false
				end
			end
		end
	end
end

-- Point retrieval
local function GetDebuffCount(SpellID, ...)
	if not SpellID then return end
	local unit = ... or "target"
	local _,_,_,count,_,_,_,caster = UnitDebuff(unit, SpellID)
	if count == nil then count = 0 end
	if caster ~= "player" then count = 0 end	-- Only show Debuffs cast by me
	return count
end

local function GetBuffCount(SpellID, ...)
	if not SpellID then return end
	local unit = ... or "player"
	local _,_,_,count = UnitAura(unit, SpellID)
	if count == nil then count = 0 end
	return count
end

function PointTracking:GetPoints(CurClass, CurType)
	local NewPoints
	-- General
	if CurClass == "GENERAL" then
		-- Combo Points
		if CurType == "cp" then
			NewPoints = GetComboPoints(UnitHasVehicleUI("player") and "vehicle" or "player", "target")
		end
	-- Monk
	elseif CurClass == "MONK" then
		-- Chi
		if CurType == "chi" then
			NewPoints = UnitPower("player", SPELL_POWER_CHI)
		end
	-- Priest
	elseif CurClass == "PALADIN" then
		-- Holy Power
		if CurType == "hp" then
			NewPoints = UnitPower("player", SPELL_POWER_HOLY_POWER)
		end
	-- Priest
	elseif CurClass == "PRIEST" then
		if CurType == "so" then
			NewPoints = UnitPower("player", SPELL_POWER_SHADOW_ORBS)
		end
	-- Rogue
	elseif CurClass == "ROGUE" then
		-- Anticipation Points
		if CurType == "ap" then
			NewPoints = GetBuffCount(SpellInfo[CurType])
		end
	-- Warlock
	elseif CurClass == "WARLOCK" then
		-- Soul Shards
		if CurType == "ss" and PlayerTalent == 1 then
			NewPoints = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
		-- Burning Embers
		elseif CurType == "be" and PlayerTalent == 3 then
			NewPoints = UnitPower("player", SPELL_POWER_BURNING_EMBERS)
		end
	end
	Points[CurType] = NewPoints
end

-- Update all valid Point Displays
function PointTracking:UpdatePoints(...)	
	local HasChanged = false
	local Enable = ...
	
	local UpdateList
	if ... == "ENABLE" then
		-- Update everything
		UpdateList = Types
	else
		UpdateList = ValidClasses
	end
	
	-- ENABLE update: Config Mode / Reset displays
	if Enable == "ENABLE" then
		HasChanged = true
		for ic,vc in pairs(Types) do
			for it,vt in ipairs(Types[ic].points) do
				local tid = Types[ic].points[it].id
				PointsChanged[tid] = true
				if ( db[ic].types[tid].enabled and db[ic].types[tid].configmode.enabled ) then
					-- If Enabled and Config Mode is on, then set points
					Points[tid] = db[ic].types[tid].configmode.count
				else
					Points[tid] = 0
				end
			end
		end
	end
	
	-- Normal update: Cycle through valid classes
	for ic,vc in pairs(UpdateList) do
		-- Cycle through point types for current class
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id
			if ( db[ic].types[tid].enabled and not db[ic].types[tid].configmode.enabled ) then
				-- Retrieve new point count
				local OldPoints = (tid == "eb") and EBPoints or Points[tid]
				PointTracking:GetPoints(ic, tid)
				local NewPoints = (tid == "eb") and EBPoints or Points[tid]
				if NewPoints ~= OldPoints then
					-- Points have changed, flag for updating
					HasChanged = true
					PointsChanged[tid] = true
				end
			end
		end
	end
	
	-- Update Point Displays
	if HasChanged then PointTracking:UpdatePointTracking(Enable) end
end

-- Enable a Point Display
function PointTracking:EnablePointTracking(c, t)
	PointTracking:UpdatePoints("ENABLE")
end

-- Disable a Point Display
function PointTracking:DisablePointTracking(c, t)
	-- Set to 0 points
	Points[t] = 0
	PointsChanged[t] = true
	
	-- Update Point Displays
	PointTracking:UpdatePointTracking("ENABLE")
end

-- Update frame positions/sizes
function PointTracking:UpdatePosition()
	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id

			---- BG Panel
			local Parent = RealUIPositionersCTPoints
			
			Frames[ic][tid].bgpanel.frame:SetParent(Parent)
			Frames[ic][tid].bgpanel.frame:ClearAllPoints()
			Frames[ic][tid].bgpanel.frame:SetPoint(db[ic].types[tid].position.side, Parent, db[ic].types[tid].position.side, db[ic].types[tid].position.x, db[ic].types[tid].position.y)
			Frames[ic][tid].bgpanel.frame:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
			Frames[ic][tid].bgpanel.frame:SetFrameLevel(db[ic].types[tid].position.framelevel.level)
			Frames[ic][tid].bgpanel.frame:SetWidth(10)
			Frames[ic][tid].bgpanel.frame:SetHeight(10)
			
			---- Point Bars
			local IsRev = db[ic].types[tid].general.direction.reverse
			local XPos, YPos, CPRatio, TWidth, THeight
			local Positions = {}
			local CPSize = {}
			
			-- Get total Width and Height of Point Display, and the size of each Bar
			TWidth = 0
			THeight = 0
			for i = 1, Types[ic].points[it].barcount do
				CPSize[i] = db[ic].types[tid].bars.size.width + db[ic].types[tid].bars.position.gap
				TWidth = TWidth + db[ic].types[tid].bars.size.width + db[ic].types[tid].bars.position.gap
			end
			
			-- Calculate position of each Bar
			for i = 1, Types[ic].points[it].barcount do
				local CurPos = 0
				local TVal = TWidth
				
				-- Add up position of each Bar in sequence
				if i == 1 then
					CurPos = 0
				else
					for j = 1, i-1 do
						CurPos = CurPos + CPSize[j]
					end
				end					
				
				-- Found Position of Bar
				Positions[i] = CurPos
			end
			
			-- Position each Bar
			for i = 1, Types[ic].points[it].barcount do
				local RevMult = 1
				if IsRev then RevMult = -1 end			
				
				Frames[ic][tid].bars[i].frame:SetParent(Frames[ic][tid].bgpanel.frame)
				Frames[ic][tid].bars[i].frame:ClearAllPoints()
				
				XPos = Positions[i] * RevMult
				YPos = 0
				
				Frames[ic][tid].bars[i].frame:SetPoint(db[ic].types[tid].position.side, Frames[ic][tid].bgpanel.frame, db[ic].types[tid].position.side, XPos, YPos)
				
				Frames[ic][tid].bars[i].frame:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
				Frames[ic][tid].bars[i].frame:SetFrameLevel(db[ic].types[tid].position.framelevel.level + i + 2)
				Frames[ic][tid].bars[i].frame:SetWidth(db[ic].types[tid].bars.size.width)
				Frames[ic][tid].bars[i].frame:SetHeight(db[ic].types[tid].bars.size.height)
			end
			
			Frames[ic][tid].bgpanel.frame:SetWidth(Positions[Types[ic].points[it].barcount] + db[ic].types[tid].bars.size.width)
		end
	end
end

function PointTracking:ToggleConfigMode(val)
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	for ic,vc in pairs(ValidClasses) do
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id
			db[ic].types[tid].configmode.enabled = val
			if val then
				db[ic].types[tid].configmode.count = Types[ic].points[it].barcount
			else
				db[ic].types[tid].configmode.count = 2
			end
		end
	end
	self:UpdatePoints("ENABLE")
end

-- Retrieve SharedMedia backgound
local function RetrieveBackground(background)
	background = LSM:Fetch("background", background, true)
	return background
end

local function VerifyBackground(background)
	local newbackground = ""
	if background and strlen(background) > 0 then 
		newbackground = RetrieveBackground(background)
		if background ~= "None" then
			if not newbackground then
				print("Background "..background.." was not found in SharedMedia.")
				newbackground = ""
			end
		end
	end	
	return newbackground
end

-- Retrieve Background textures and store in tables
function PointTracking:GetTextures()
	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id
			BG[ic][tid].bars.empty = VerifyBackground(db[ic].types[tid].bars.bg.empty.texture)
			BG[ic][tid].bars.full = VerifyBackground(db[ic].types[tid].bars.bg.full.texture)
			BG[ic][tid].bars.surround = VerifyBackground(db[ic].types[tid].bars.surround.texture)
		end
	end
end

-- Frame Creation
local function CreateFrames(config)
	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id
			
			-- BG Panel
			local FrameName = "PointTracking_Frames_"..tid
			Frames[ic][tid].bgpanel.frame = CreateFrame("Frame", FrameName, UIParent)
			
			Frames[ic][tid].bgpanel.bg = Frames[ic][tid].bgpanel.frame:CreateTexture(nil, "ARTWORK")
			Frames[ic][tid].bgpanel.bg:SetAllPoints(Frames[ic][tid].bgpanel.frame)
			
			Frames[ic][tid].bgpanel.frame:Hide()
			
			-- Point bars
			for i = 1, Types[ic].points[it].barcount do
				local BarFrameName = "PointTracking_Frames_"..tid.."_bar"..tostring(i)
				Frames[ic][tid].bars[i].frame = CreateFrame("Frame", BarFrameName, UIParent)
				
				Frames[ic][tid].bars[i].bg = Frames[ic][tid].bars[i].frame:CreateTexture(nil, "ARTWORK")
				Frames[ic][tid].bars[i].bg:SetAllPoints(Frames[ic][tid].bars[i].frame)
				
				Frames[ic][tid].bars[i].surround = Frames[ic][tid].bars[i].frame:CreateTexture(nil, "ARTWORK")
				Frames[ic][tid].bars[i].surround:SetAllPoints(Frames[ic][tid].bars[i].frame)
				
				Frames[ic][tid].bars[i].frame:Show()
			end
		end
	end
end

-- Table creation
local function CreateTables(config)
	-- Frames
	wipe(Frames)
	wipe(BG)
	wipe(Points)
	wipe(PointsChanged)
	
	for ic,vc in pairs(Types) do
		-- Insert Class header
		tinsert(Frames, ic)
		Frames[ic] = {}
		tinsert(BG, ic)
		BG[ic] = {}
		
		for it,vt in ipairs(Types[ic].points) do	-- Iterate through Types table
			local tid = Types[ic].points[it].id
			
			-- Insert point type (ie "cp") into table and fill out table
			-- Frames
			tinsert(Frames[ic], tid)
			tinsert(BG[ic], tid)
			
			Frames[ic][tid] = {
				bgpanel = {frame = nil, bg = nil},
				bars = {},				
			}
			BG[ic][tid] = {
				bars = {},
			}
			for i = 1, Types[ic].points[it].barcount do
				Frames[ic][tid].bars[i] = {frame = nil, bg = nil, surround = nil}
				BG[ic][tid].bars[i] = {empty = "", full = "", surround = ""}
			end
			
			-- Points			
			Points[tid] = 0
			
			-- Set up Points Changed table
			PointsChanged[tid] = false
		end
	end
end

-- Refresh PointTracking
function PointTracking:Refresh()
	self:UpdateSpec()
	self:UpdateCombatFaderEnabled()
	self:GetTextures()
	self:UpdatePosition()
	self:UpdatePoints("ENABLE")
end

-- Hide default UI frames
function PointTracking:HideUIElements()
	if db["GENERAL"].types["cp"].enabled and db["GENERAL"].types["cp"].general.hideui then
		for i = 1,5 do
			_G["ComboPoint"..i]:Hide()
			_G["ComboPoint"..i]:SetScript("OnShow", function(self) self:Hide() end)
		end
	end
	
	if db["PALADIN"].types["hp"].enabled and db["PALADIN"].types["hp"].general.hideui then
		local HPF = _G["PaladinPowerBar"]
		if HPF then
			HPF:Hide()
			HPF:SetScript("OnShow", function(self) self:Hide() end)
		end
	end
	
	if db["WARLOCK"].types["ss"].enabled and db["WARLOCK"].types["ss"].general.hideui then
		local SSF = _G["ShardBarFrame"]
		if SSF then
			SSF:Hide()
			SSF:SetScript("OnShow", function(self) self:Hide() end)
		end
	end
end

function PointTracking:UpdateSpec()
	PlayerSpec = GetActiveSpecGroup()
	PlayerTalent = GetSpecialization()
end

function PointTracking:UpdateSmartHideConditions()
	if PlayerInCombat or PlayerTargetHostile or PlayerInInstance then
		SmartHideConditions = false
	else
		SmartHideConditions = true
	end
	self:UpdatePoints("ENABLE")
end

function PointTracking:PLAYER_TARGET_CHANGED()
	PlayerTargetHostile = (UnitIsEnemy("player", "target") or UnitCanAttack("player", "target"))
	self:UpdateSmartHideConditions()
	self:UpdatePoints()
end

function PointTracking:PLAYER_REGEN_DISABLED()
	PlayerInCombat = true
	self:UpdateSmartHideConditions()
end

function PointTracking:PLAYER_REGEN_ENABLED()
	PlayerInCombat = false
	self:UpdateSmartHideConditions()
end

function PointTracking:PLAYER_ENTERING_WORLD()
	-- GreenFire = IsSpellKnown(WARLOCK_GREEN_FIRE)
	PlayerInInstance = IsInInstance()
	self:UpdateSpec()
	self:UpdatePosition()
	self:UpdateSmartHideConditions()
end

function PointTracking:PLAYER_LOGIN()
	PlayerClass = nibRealUI.class
	
	-- Build Class list to run updates on
	ValidClasses = {
		["GENERAL"] = true,
		[PlayerClass] = Types[PlayerClass],
	},
	
	-- Register Media
	LSM:Register("background", "Round_Large_BG", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Large_BG]])
	LSM:Register("background", "Round_Large_Surround", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Large_Surround]])
	LSM:Register("background", "Round_Small_BG", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Small_BG]])
	LSM:Register("background", "Round_Small_Surround", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Small_Surround]])
	LSM:Register("background", "Round_Larger_BG", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Larger_BG]])
	LSM:Register("background", "Round_Larger_Surround", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Larger_Surround]])
	LSM:Register("background", "Soul_Shard_BG", [[Interface\Addons\nibRealUI\Media\PointTracking\SoulShard_BG]])
	LSM:Register("background", "Soul_Shard_Surround", [[Interface\Addons\nibRealUI\Media\PointTracking\SoulShard_Surround]])
	
	HolyPowerTexture = {[[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower1]], [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower2]], [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower3]], [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower4]], [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower5]]}
	
	-- Get Spell Info
	-- Death Knight
	SpellInfo["bs"] = GetSpellInfo(49222)		-- Bone Shield
	-- Druid
	-- Hunter
	-- Mage
	-- Monk
	-- Priest
	-- Rogue	
	SpellInfo["ap"] = GetSpellInfo(114015)		-- Anticipation Points
	-- Shaman
	-- Warlock
	-- Warrior
		
	-- Hide Elements
	PointTracking:HideUIElements()
	
	-- Register Events
	-- Throttled Events
	local EventList = {
		"UNIT_COMBO_POINTS",
		"VEHICLE_UPDATE",
		"UNIT_AURA",
	}
	if (PlayerClass == "MONK") or (PlayerClass == "PRIEST") or (PlayerClass == "PALADIN") then
		tinsert(EventList, "UNIT_POWER")
	elseif (PlayerClass == "WARLOCK") then
		tinsert(EventList, "UNIT_POWER")
		tinsert(EventList, "UNIT_DISPLAYPOWER")
	end	

	local UpdateSpeed
	if ndb.powerMode == 1 then		-- Normal
		UpdateSpeed = 1/8
	elseif ndb.powerMode == 2 then	-- Economy
		UpdateSpeed = 1/6
	else 							-- Turbo
		UpdateSpeed = 1/10
	end
	self:RegisterBucketEvent(EventList, UpdateSpeed, "UpdatePoints")
	
	-- Refresh Addon
	PointTracking:Refresh()
end

function PointTracking:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults(nibRealUI:GetPointTrackingDefaults())
	
	db = self.db.profile
	ndb = nibRealUI.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterHuDOptions(MODNAME, GetOptions)
	nibRealUI:RegisterConfigModeModule(self)
end

function PointTracking:OnEnable()
	CreateTables()
	CreateFrames()
	
	-- Turn off Config Mode
	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id
			db[ic].types[tid].configmode.enabled = false
		end
	end
	
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "UpdateSpec")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
end