local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb, ndbc

local _
local MODNAME = "FrameMover"
local FrameMover = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0", "AceTimer-3.0")

local EnteredWorld

local GarbageTimerInt = 1
local GarbageTimerFrame

local FramesMoving

local FrameList = {
	addons = {
		grid2 = {
			name = "Grid2",
			addon = "Grid2",
			hashealing = true,
			frames = {[1] = {name = "Grid2LayoutFrame"},},
			frameshealing = {[1] = {name = "Grid2LayoutFrame"},},
		},
		raven = {
			name = "Raven",
			addon = "Raven",
			frames = {
				[1] = {name = "RavenBarGroupPlayerBuffs"},
				[2] = {name = "RavenBarGroupPlayerDebuffs"},
				[3] = {name = "RavenBarGroupTargetBuffs"},
				[4] = {name = "RavenBarGroupTargetDebuffs"},
				[5] = {name = "RavenBarGroupFocusBuffs"},
				[6] = {name = "RavenBarGroupFocusDebuffs"},
				[7] = {name = "RavenBarGroupToTDebuffs"},
				-- [8] = {name = "RavenBarGroupBuffs"},
			},
		},
	},
	uiframes = {
		zonetext = {
			name = "Zoning Text",
			frames = {[1] = {name = "ZoneTextFrame"},},
		},
		raidmessages = {
			name = "Raid Alerts",
			frames = {[1] = {name = "RaidWarningFrame"},},
		},
		-- bossemote = {
		-- 	name = "Boss Emotes",
		-- 	frames = {[1] = {name = "RaidBossEmoteFrame"},},
		-- },
		ticketstatus = {
			name = "Ticket Status",
			frames = {[1] = {name = "TicketStatusFrame"},},
		},
		worldstate = {
			name = "World State",
			frames = {[1] = {name = "WorldStateAlwaysUpFrame"},},
		},
		errorframe = {
			name = "Errors",
			frames = {[1] = {name = "UIErrorsFrame"},},
		},
		vsi = {
			name = "Vehicle Seat",
			frames = {[1] = {name = "VehicleSeatIndicator"},},
		},
		playerpowerbaralt = {
			name = "Alternate Power Bar",
			frames = {[1] = {name = "PlayerPowerBarAlt"},},
		},
	},
	hide = {
		durabilityframe = {
			name = "Durability Frame",
			frames = {[1] = {name = "DurabilityFrame"},},
		},
		raid = {
			name = "Raid",
			frames = {},
		},
		party = {
			name = "Party",
			frames = {},
		},
	},
}

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Frame Mover",
		desc = "Automatically Move/Hide certain AddOns/Frames.",
		arg = MODNAME,
		order = 618,
		args = {
			header = {
				type = "header",
				name = "Frame Mover/Hider",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Automatically Move/Hide certain AddOns/Frames.",
				fontSize = "medium",
				order = 20,
			},
		},
	}
	end
	
	-- Create Addons options table
	local addonOpts = {
		name = "Addons",
		type = "group",
		disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
		order = 50,
		args = {},
	}
	local addonOrderCnt = 10	
	for k_a,v_a in pairs(FrameList.addons) do
		-- Create base options for Addons
		addonOpts.args[k_a] = {
			type = "group",
			name = FrameList.addons[k_a].name,
			childGroups = "tab",
			order = addonOrderCnt,
			disabled = function() return not(IsAddOnLoaded(FrameList.addons[k_a].addon) and nibRealUI:GetModuleEnabled(MODNAME)) end,
			args = {
				header = {
					type = "header",
					name = string.format("Frame Mover - Addons - %s", FrameList.addons[k_a].name),
					order = 10,
				},
				enabled = {
					type = "toggle",
					name = string.format("Move %s", FrameList.addons[k_a].name),
					get = function(info)
						if k_a == "grid2" then
							return nibRealUI:DoesAddonMove("Grid2")
						else
							return db.addons[k_a].move
						end
					end,
					set = function(info, value) 
						if k_a == "grid2" then
							if nibRealUI:DoesAddonMove("Grid2") then
								FrameMover:MoveAddons()
							end
						else
							db.addons[k_a].move = value
							if db.addons[k_a].move then
								FrameMover:MoveAddons()
							end
						end
					end,
					order = 20,
				},
				normal = {
					type = "group",
					name = " ",
					order = 50,
					args = {},
				},
			},
		}
		
		-- Healing Enable option
		if FrameList.addons[k_a].hashealing then
			addonOpts.args[k_a].args.healingenabled = {
				type = "toggle",
				name = "Enable Healing Layout",
				get = function(info) return db.addons[k_a].healing end,
				set = function(info, value) 
					db.addons[k_a].healing = value 
					if db.addons[k_a].move then
						FrameMover:MoveAddons()
					end
				end,
				order = 30,
			}
		end
		
		-- Normal / Low Res
		-- Create options table for Frames
		local normalFrameOpts = {
			name = "Frames",
			type = "group",
			inline = true,
			disabled = function() if db.addons[k_a].move then return false else return true end end,
			order = 10,
			args = {},
		}
		local normalFrameOrderCnt = 10		
		for k_f,v_f in ipairs(FrameList.addons[k_a].frames) do	
			normalFrameOpts.args[tostring(k_f)] = {
				type = "group",
				name = FrameList.addons[k_a].frames[k_f].name,
				inline = true,
				order = normalFrameOrderCnt,
				args = {
					x = {
						type = "input",
						name = "X Offset",
						width = "half",
						order = 10,
						get = function(info) return tostring(db.addons[k_a].frames[k_f].x) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.addons[k_a].frames[k_f].x = value
							FrameMover:MoveAddons()
						end,
					},
					yoffset = {
						type = "input",
						name = "Y Offset",
						width = "half",
						order = 20,
						get = function(info) return tostring(db.addons[k_a].frames[k_f].y) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.addons[k_a].frames[k_f].y = value
							FrameMover:MoveAddons()
						end,
					},
					anchorto = {
						type = "select",
						name = "Anchor To",
						get = function(info) 
							for k_ta,v_ta in pairs(nibRealUI.globals.anchorPoints) do
								if v_ta == db.addons[k_a].frames[k_f].rpoint then return k_ta end
							end
						end,
						set = function(info, value)
							db.addons[k_a].frames[k_f].rpoint = nibRealUI.globals.anchorPoints[value]
							FrameMover:MoveAddons()
						end,
						style = "dropdown",
						width = nil,
						values = nibRealUI.globals.anchorPoints,
						order = 30,
					},
					anchorfrom = {
						type = "select",
						name = "Anchor From",
						get = function(info) 
							for k_ta,v_ta in pairs(nibRealUI.globals.anchorPoints) do
								if v_ta == db.addons[k_a].frames[k_f].point then return k_ta end
							end
						end,
						set = function(info, value)
							db.addons[k_a].frames[k_f].point = nibRealUI.globals.anchorPoints[value]
							FrameMover:MoveAddons()
						end,
						style = "dropdown",
						width = nil,
						values = nibRealUI.globals.anchorPoints,
						order = 40,
					},
					parent = {
						type = "input",
						name = "Parent",
						width = "double",
						order = 50,
						get = function(info) return db.addons[k_a].frames[k_f].parent end,
						set = function(info, value)
							if not _G[value] then value = "UIParent" end
							db.addons[k_a].frames[k_f].parent = value
							FrameMover:MoveAddons()
						end,
					},
				},
			}
			normalFrameOrderCnt = normalFrameOrderCnt + 10
		end
		
		-- Create options table for Healing Frames
		local normalHealingFrameOpts = nil
		if FrameList.addons[k_a].hashealing then
			normalHealingFrameOpts = {
				name = "Healing Layout Frames",
				type = "group",
				inline = true,
				disabled = function() return not ( db.addons[k_a].move and db.addons[k_a].healing ) end,
				order = 50,
				args = {},
			}
			local normalHealingFrameOrderCnt = 10		
			for k_f,v_f in ipairs(FrameList.addons[k_a].frameshealing) do	
				normalHealingFrameOpts.args[tostring(k_f)] = {
					type = "group",
					name = FrameList.addons[k_a].frameshealing[k_f].name,
					inline = true,
					order = normalHealingFrameOrderCnt,
					args = {
						x = {
							type = "input",
							name = "X Offset",
							width = "half",
							order = 10,
							get = function(info) return tostring(db.addons[k_a].frameshealing[k_f].x) end,
							set = function(info, value)
								value = nibRealUI:ValidateOffset(value)
								db.addons[k_a].frameshealing[k_f].x = value
								FrameMover:MoveAddons()
							end,
						},
						yoffset = {
							type = "input",
							name = "Y Offset",
							width = "half",
							order = 20,
							get = function(info) return tostring(db.addons[k_a].frameshealing[k_f].y) end,
							set = function(info, value)
								value = nibRealUI:ValidateOffset(value)
								db.addons[k_a].frameshealing[k_f].y = value
								FrameMover:MoveAddons()
							end,
						},
						anchorto = {
							type = "select",
							name = "Anchor To",
							get = function(info) 
								for k_ta,v_ta in pairs(nibRealUI.globals.anchorPoints) do
									if v_ta == db.addons[k_a].frameshealing[k_f].rpoint then return k_ta end
								end
							end,
							set = function(info, value)
								db.addons[k_a].frameshealing[k_f].rpoint = nibRealUI.globals.anchorPoints[value]
								FrameMover:MoveAddons()
							end,
							style = "dropdown",
							width = nil,
							values = nibRealUI.globals.anchorPoints,
							order = 30,
						},
						anchorfrom = {
							type = "select",
							name = "Anchor From",
							get = function(info) 
								for k_ta,v_ta in pairs(nibRealUI.globals.anchorPoints) do
									if v_ta == db.addons[k_a].frameshealing[k_f].point then return k_ta end
								end
							end,
							set = function(info, value)
								db.addons[k_a].frameshealing[k_f].point = nibRealUI.globals.anchorPoints[value]
								FrameMover:MoveAddons()
							end,
							style = "dropdown",
							width = nil,
							values = nibRealUI.globals.anchorPoints,
							order = 40,
						},
						parent = {
							type = "input",
							name = "Parent",
							width = "double",
							order = 50,
							get = function(info) return db.addons[k_a].frameshealing[k_f].parent end,
							set = function(info, value)
								if not _G[value] then value = "UIParent" end
								db.addons[k_a].frameshealing[k_f].parent = value
								FrameMover:MoveAddons()
							end,
						},
					},
				}
				normalHealingFrameOrderCnt = normalHealingFrameOrderCnt + 10
			end
		end

		-- Add Frames to Addons options
		addonOpts.args[k_a].args.normal.args.frames = normalFrameOpts
		if normalHealingFrameOpts ~= nil then addonOpts.args[k_a].args.normal.args.healingframes = normalHealingFrameOpts end
		
		addonOrderCnt = addonOrderCnt + 10	
	end
	
	-- Create UIFrames options table
	local uiframesopts = {
		name = "UI Frames",
		type = "group",
		disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
		order = 60,
		args = {},
	}
	local uiframesordercnt = 10	
	for k_u,v_u in pairs(FrameList.uiframes) do
		-- Create base options for UIFrames
		uiframesopts.args[k_u] = {
			type = "group",
			name = FrameList.uiframes[k_u].name,
			order = uiframesordercnt,
			args = {
				header = {
					type = "header",
					name = string.format("Frame Mover - UI Frames - %s", FrameList.uiframes[k_u].name),
					order = 10,
				},
				enabled = {
					type = "toggle",
					name = string.format("Move %s", FrameList.uiframes[k_u].name),
					get = function(info) return db.uiframes[k_u].move end,
					set = function(info, value) 
						db.uiframes[k_u].move = value 
						if db.uiframes[k_u].move and FrameList.uiframes[k_u].frames then FrameMover:MoveIndividualFrameGroup(FrameList.uiframes[k_u].frames, db.uiframes[k_u].frames) end
					end,
					order = 20,
				},
			},
		}
		
		-- Create options table for Frames
		if FrameList.uiframes[k_u].frames then
			local frameopts = {
				name = "Frames",
				type = "group",
				inline = true,
				disabled = function() if db.uiframes[k_u].move then return false else return true end end,
				order = 30,
				args = {},
			}
			local FrameOrderCnt = 10		
			for k_f,v_f in ipairs(FrameList.uiframes[k_u].frames) do	
				frameopts.args[tostring(k_f)] = {
					type = "group",
					name = FrameList.uiframes[k_u].frames[k_f].name,
					inline = true,
					order = FrameOrderCnt,
					args = {
						x = {
							type = "input",
							name = "X Offset",
							width = "half",
							order = 10,
							get = function(info) return tostring(db.uiframes[k_u].frames[k_f].x) end,
							set = function(info, value)
								value = nibRealUI:ValidateOffset(value)
								db.uiframes[k_u].frames[k_f].x = value
								FrameMover:MoveIndividualFrameGroup(FrameList.uiframes[k_u].frames, db.uiframes[k_u].frames)
							end,
						},
						yoffset = {
							type = "input",
							name = "Y Offset",
							width = "half",
							order = 20,
							get = function(info) return tostring(db.uiframes[k_u].frames[k_f].y) end,
							set = function(info, value)
								value = nibRealUI:ValidateOffset(value)
								db.uiframes[k_u].frames[k_f].y = value
								FrameMover:MoveIndividualFrameGroup(FrameList.uiframes[k_u].frames, db.uiframes[k_u].frames)
							end,
						},
						anchorto = {
							type = "select",
							name = "Anchor To",
							get = function(info) 
								for k_ta,v_ta in pairs(nibRealUI.globals.anchorPoints) do
									if v_ta == db.uiframes[k_u].frames[k_f].rpoint then return k_ta end
								end
							end,
							set = function(info, value)
								db.uiframes[k_u].frames[k_f].rpoint = nibRealUI.globals.anchorPoints[value]
								FrameMover:MoveIndividualFrameGroup(FrameList.uiframes[k_u].frames, db.uiframes[k_u].frames)
							end,
							style = "dropdown",
							width = nil,
							values = nibRealUI.globals.anchorPoints,
							order = 30,
						},
						anchorfrom = {
							type = "select",
							name = "Anchor From",
							get = function(info) 
								for k_ta,v_ta in pairs(nibRealUI.globals.anchorPoints) do
									if v_ta == db.uiframes[k_u].frames[k_f].point then return k_ta end
								end
							end,
							set = function(info, value)
								db.uiframes[k_u].frames[k_f].point = nibRealUI.globals.anchorPoints[value]
								FrameMover:MoveIndividualFrameGroup(FrameList.uiframes[k_u].frames, db.uiframes[k_u].frames)
							end,
							style = "dropdown",
							width = nil,
							values = nibRealUI.globals.anchorPoints,
							order = 40,
						},
					},
				}
				FrameOrderCnt = FrameOrderCnt + 10
			end
			
			-- Add Frames to UI Frames options
			uiframesopts.args[k_u].args.frames = frameopts
			uiframesordercnt = uiframesordercnt + 10
		end
	end
	
	-- Create Hide options table
	local hideopts = {
		name = "Hide Frames",
		type = "group",
		disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
		order = 70,
		args = {
			header = {
				type = "header",
				name = string.format("Frame Mover - Hide Frames"),
				order = 10,
			},
			sep = {
				type = "description",
				name = " ",
				order = 20,
			},
			note = {
				type = "description",
				name = "Note: To make a frame visible again after it has been hidden, you will need to reload the UI (type: /rl).",
				order = 30,
			},
			hideframes = {
				type = "group",
				name = "Hide",
				inline = true,
				order = 40,
				args = {},
			},
		},
	}
	-- Add all frames to Hide Frames options
	local hideordercnt = 10	
	for k_u,v_u in pairs(FrameList.hide) do
		-- Create base options for Hide
		hideopts.args.hideframes.args[k_u] = {
			type = "toggle",
			name = FrameList.hide[k_u].name,
			get = function(info) return db.hide[k_u].hide end,
			set = function(info, value) 
				db.hide[k_u].hide = value 
				if db.hide[k_u].hide then
					FrameMover:HideFrames()
				else
					nibRealUI:ReloadUIDialog()
				end
			end,
			order = hideordercnt,
		}

		hideordercnt = hideordercnt + 10		
	end

	-- Add extra options to Options table
	options.args.addons = addonOpts
	options.args.uiframes = uiframesopts
	options.args.hide = hideopts
	return options
end

-- Hide a Frame	
local function HideFrame(FrameName)
	local frame = _G[FrameName]
	if not frame then return end
	
	frame:UnregisterAllEvents()
	frame:Hide()	
	frame:SetScript("OnShow", function(self) self:Hide() end)
end

function FrameMover:HideIndividualFrameGroup(FramesTable)
	for k,v in pairs(FramesTable) do
		local FrameName = FramesTable[k].name
		HideFrame(FrameName)
	end
end

-- Move a Frame
local function MoveFrame(FrameName, point, rframe, rpoint, x, y, ...)
	FramesMoving = true

	local frame = _G[FrameName]
	if not frame then return end
	
	frame:ClearAllPoints()
	frame:SetPoint(point, rframe, rpoint, x, y)
	-- frame:SetParent(rframe)
	
	local scale = ...
	if scale ~= nil then frame:SetScale(scale) end
	FramesMoving = false
end

-- Move a single Addon/UIFrame group from saved variables
function FrameMover:MoveIndividualFrameGroup(FramesTable, DBTable)
	local FrameDB = {}
	for k,v in pairs(FramesTable) do
		local FrameName = FramesTable[k].name
		FrameDB = DBTable[k]
		local scale = nil
		if FrameDB.scale then scale = FrameDB.scale end
		local parent = _G[FrameDB.parent] or UIParent
		MoveFrame(FrameName, FrameDB.point, parent, FrameDB.rpoint, FrameDB.x, FrameDB.y, scale)
	end
end

-- Move all Addons
function FrameMover:MoveAddons(addon)
	local FrameDB = {}
	for k,v in pairs(FrameList.addons) do
		if (addon and k == addon) or (addon == nil) then
			if ((k ~= "grid2") and db.addons[k].move) or ((k == "grid2") and nibRealUI:DoesAddonMove("Grid2")) then
				local IsHealing = ( FrameList.addons[k].hashealing and db.addons[k].healing and nibRealUI.cLayout == 2 )
				
				if IsHealing then
					-- Healing Layout
					for k2,v2 in ipairs(FrameList.addons[k].frameshealing) do
						local FrameName = FrameList.addons[k].frameshealing[k2].name
						FrameDB = db.addons[k].frameshealing[k2]
						local scale = nil
						if FrameDB.scale then scale = FrameDB.scale end
						local parent = _G[FrameDB.parent] or UIParent
						MoveFrame(FrameName, FrameDB.point, parent, FrameDB.rpoint, FrameDB.x, FrameDB.y, scale)
					end
				else
					-- Normal Layout
					for k2,v2 in ipairs(FrameList.addons[k].frames) do
						local FrameName = FrameList.addons[k].frames[k2].name
						FrameDB = db.addons[k].frames[k2]
						local scale = nil
						if FrameDB.scale then scale = FrameDB.scale end
						local parent = _G[FrameDB.parent] or UIParent
						MoveFrame(FrameName, FrameDB.point, parent, FrameDB.rpoint, FrameDB.x, FrameDB.y, scale)
					end
				end
			end
		end
	end
end

-- Move all UI Frames
function FrameMover:MoveUIFrames()
	local FrameDB = {}
	for k,v in pairs(FrameList.uiframes) do
		if db.uiframes[k].move and FrameList.uiframes[k].frames then
			for k2,v2 in ipairs(FrameList.uiframes[k].frames) do
				local FrameName = FrameList.uiframes[k].frames[k2].name
				FrameDB = db.uiframes[k].frames[k2]
				local scale = nil
				if FrameDB.scale then scale = FrameDB.scale end
				MoveFrame(FrameName, FrameDB.point, FrameDB.parent, FrameDB.rpoint, FrameDB.x, FrameDB.y, scale)
			end
		end
	end
end

-- Hide Party/Raid Frames
local function RaidFramesCheck()
	if not InCombatLockdown() then
		if db.hide.raid.hide then
			CompactRaidFrameManager_SetSetting("IsShown","0")
		else
			CompactRaidFrameManager_SetSetting("IsShown","1")
		end
	end
end

function FrameMover:HidePartyRaid()
	if db.hide.raid.hide then
		RaidFramesCheck()
	end
	
	if not InCombatLockdown() then
		if not FrameMover.partyhidden and EnteredWorld and db.hide.party.hide then
			FrameMover.partyhidden = true
			for i = 1, 4 do
				local frame = _G["PartyMemberFrame"..i]
				frame:UnregisterAllEvents()
				frame:Hide()
				frame.Show = function() end
			end
		end
	end
end
function FrameMover_HidePartyRaid()
	FrameMover:HidePartyRaid()
end

-- Hide all UI Frames
function FrameMover:HideFrames()
	for k,v in pairs(FrameList.hide) do
		if db.hide[k].hide then
			for k2,v2 in ipairs(FrameList.hide[k].frames) do
				local FrameName = FrameList.hide[k].frames[k2].name
				HideFrame(FrameName)
			end
		end
	end
end

---- Hook into addons to display PopUpMessage and reposition frames
-- VSI
local function Hook_VSI()
	hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(_, _, parent)
		if nibRealUI:GetModuleEnabled(MODNAME) and db.uiframes.vsi.move then
			if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
				FrameMover:MoveIndividualFrameGroup(FrameList.uiframes.vsi.frames, db.uiframes.vsi.frames)
			end
		end
	end)
end

-- Raven - To stop bars repositioning themselves
local function Hook_Raven()
	if not IsAddOnLoaded("Raven") then return end
	
	local t = CreateFrame("Frame")
	t:Hide()
	t.e = 0
	t:SetScript("OnUpdate", function(s, e)
		t.e = t.e + e
		if t.e >= 0.5 then
			FrameMover:MoveIndividualFrameGroup(FrameList.addons.raven.frames, db.addons.raven.frames)
			t.e = 0
			t:Hide()
		end
	end) 
	
	hooksecurefunc(Raven, "Nest_SetAnchorPoint", function()
		t:Show()
	end)

	if RavenBarGroupBuffs then RavenBarGroupBuffs:SetClampedToScreen(false) end
end

-- Grid2 - Top stop LayoutFrame re-anchoring itself to UIParent
local function Hook_Grid2()
	if not Grid2LayoutFrame then return end
	hooksecurefunc(Grid2LayoutFrame, "SetPoint", function()
		if FramesMoving then return end
		FrameMover:MoveAddons("grid2")
	end)
end

function RealUI_MoveAll()
	FrameMover:MoveUIFrames()
	FrameMover:MoveAddons()
end

function FrameMover:RefreshMod()
	db = self.db.profile
	RealUI_MoveAll()
end

function FrameMover:PLAYER_ENTERING_WORLD()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	
	if not EnteredWorld then
		Hook_Grid2()
		Hook_Raven()
		Hook_VSI()
		
		self:MoveUIFrames()
		self:MoveAddons()
		self:HideFrames()
	end
	EnteredWorld = true
	
	FrameMover_HidePartyRaid()
end

----
function FrameMover:UpdateLockdown(...)
	nibRealUI:RegisterLockdownUpdate("FrameMover_HidePartyRaid", FrameMover_HidePartyRaid)
end

function FrameMover:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			addons = {
				["**"] = {
					move = true,
					healing = false,
				},
				grid2 = {
					healing = true,
					frames = {
						[1] = {name = "Grid2LayoutFrame", parent = "RealUIPositionersGridBottom", point = "BOTTOM", rpoint = "BOTTOM", x = -0.5, y = 0},
					},
					frameshealing = {
						[1] = {name = "Grid2LayoutFrame", parent = "RealUIPositionersGridTop", point = "TOP", rpoint = "TOP", x = -0.5, y = 0},
					},
				},
				raven = {
					frames = {
						[1] = {name = "RavenBarGroupPlayerBuffs", 		parent = "oUF_RealUIPlayer", 		point = "LEFT", 		rpoint = "LEFT", 		x = -40,	y = 0.5},
						[2] = {name = "RavenBarGroupPlayerDebuffs", 	parent = "RealUIPlayerShields",	 	point = "BOTTOMRIGHT", 	rpoint = "TOPRIGHT",	x = 6,		y = -3},
						[3] = {name = "RavenBarGroupTargetBuffs", 		parent = "oUF_RealUITarget", 		point = "RIGHT", 		rpoint = "RIGHT", 		x = 40,		y = 0.5},
						[4] = {name = "RavenBarGroupTargetDebuffs", 	parent = "RealUIRaidDebuffs", 		point = "BOTTOMLEFT", 	rpoint = "TOPLEFT",		x = -5,		y = -3},
						[5] = {name = "RavenBarGroupFocusBuffs", 		parent = "oUF_RealUIFocus", 		point = "LEFT", 		rpoint = "LEFT", 		x = -40,	y = -5.5},
						[6] = {name = "RavenBarGroupFocusDebuffs", 		parent = "oUF_RealUIFocus", 		point = "LEFT", 		rpoint = "LEFT", 		x = -40, 	y = -31.5},
						[7] = {name = "RavenBarGroupToTDebuffs", 		parent = "oUF_RealUITargetTarget", point = "RIGHT",			rpoint = "RIGHT", 		x = 40, 	y = -5.5},
					},
				},
			},
			uiframes = {
				["**"] = {
					move = true,
				},
				zonetext = {
					frames = {
						[1] = {name = "ZoneTextFrame", parent = "UIParent", point = "TOP", rpoint = "TOP", x = 0, y = -85},
					},
				},
				raidmessages = {
					frames = {
						[1] = {name = "RaidWarningFrame", parent = "UIParent", point = "CENTER", rpoint = "CENTER", x = 0, y = 214},
					},
				},
				-- bossemote = {
				-- 	frames = {
				-- 		[1] = {name = "RaidBossEmoteFrame", parent = "UIParent", point = "CENTER", rpoint = "CENTER", x = 0, y = 128},
				-- 	},
				-- },
				errorframe = {
					frames = {
						[1] = {name = "UIErrorsFrame", parent = "RealUIPositionersCenter", point = "BOTTOM", rpoint = "CENTER", x = 0, y = 138},
					},
				},
				ticketstatus = {
					frames = {
						[1] = {name = "TicketStatusFrame", parent = "UIParent", point = "TOP", rpoint = "TOP", x = -220, y = -8},
					},
				},
				worldstate = {
					frames = {
						[1] = {name = "WorldStateAlwaysUpFrame", parent = "UIParent", point = "TOP", rpoint = "TOP", x = -5, y = -20},
					},
				},
				vsi = {
					frames = {
						[1] = {name = "VehicleSeatIndicator", parent = "UIParent", point = "TOPRIGHT", rpoint = "TOPRIGHT", x = -10, y = -72},
					},
				},
				playerpowerbaralt = {
					frames = {
						[1] = {name = "PlayerPowerBarAlt", parent = "UIParent", point = "CENTER", rpoint = "CENTER", x = 295, y = -275},
					},
				},
			},
			hide = {
				["**"] = {
					hide = true,
				},
				raid = {
					hide = true,
				},
			},
		},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterPlainOptions(MODNAME, GetOptions)
end

function FrameMover:OnEnable()
	if db.hide.raid.hide then
		CompactUnitFrameProfiles:UnregisterAllEvents()
		
		if not IsAddOnLoaded("Blizzard_CompactRaidFrames") then
			LoadAddOn("Blizzard_CompactRaidFrames")
			-- compactRaid = CompactRaidFrameManager_GetSetting("IsShown")
		end
		CompactRaidFrameManager:UnregisterAllEvents()
		CompactRaidFrameContainer:UnregisterAllEvents()
		InterfaceOptionsFrameCategoriesButton11:SetScale(0.0001)
	end
	if db.hide.party.hide then
		InterfaceOptionsFrameCategoriesButton10:SetScale(0.0001)
	end
	if db.hide.raid.hide and db.hide.part.hide then
		InterfaceOptionsFrameCategoriesButton9:SetScale(0.0001)
	end
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "HidePartyRaid")
	self:RegisterEvent("PLAYER_ALIVE", "HidePartyRaid")
	self:RegisterEvent("PLAYER_DEAD", "HidePartyRaid")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLockdown")
end

function FrameMover:OnDisable()
	self:UnregisterAllEvents()
end