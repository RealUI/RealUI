local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local MODNAME = "RuneDisplay"
local RuneDisplay = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn
local EventsRegistered

-- Rune Data
local RUNETYPE_BLOOD = 1
local RUNETYPE_UNHOLY = 2
local RUNETYPE_FROST = 3
local RUNETYPE_DEATH = 4

local gcdNextDuration = 1.0
local gcdEnd = 0

local updateSpeed = 1/25

local layoutSize

-- Combat Fader
local CombatFader = CreateFrame("Frame")
CombatFader.Status = ""

local FadeTime = 0.20

local RuneFull = {
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
}

local RunesAreReady = true

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Rune Display",
		desc = "Rune display for Death Knights.",
		childGroups = "tab",
		disabled = function() if (select(2, UnitClass("player")) ~= "DEATHKNIGHT") then return true end end,
		arg = MODNAME,
		-- order = 1821,
		args = {
			header = {
				type = "header",
				name = "Rune Display",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Rune display for Death Knights.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Rune Display module.",
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
			position = {
				name = "Position",
				type = "group",
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 40,
				args = {
					xoffset = {
						type = "input",
						name = "X Offset",
						width = "half",
						order = 10,
						get = function(info) return tostring(db.position.x) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.position.x = value
							RuneDisplay:UpdateSettings()
						end,
					},
					yoffset = {
						type = "input",
						name = "Y Offset",
						width = "half",
						order = 20,
						get = function(info) return tostring(db.position.y) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.position.y = value
							RuneDisplay:UpdateSettings()
						end,
					},
					anchorto = {
						type = "select",
						name = "Anchor To",
						get = function(info) 
							for k,v in pairs(nibRealUI.globals.anchorPoints) do
								if v == db.position.anchorto then return k end
							end
						end,
						set = function(info, value)
							db.position.anchorto = nibRealUI.globals.anchorPoints[value]
							RuneDisplay:UpdateSettings()
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
							for k,v in pairs(nibRealUI.globals.anchorPoints) do
								if v == db.position.anchorfrom then return k end
							end
						end,
						set = function(info, value)
							db.position.anchorfrom = nibRealUI.globals.anchorPoints[value]
							RuneDisplay:UpdateSettings()
						end,
						style = "dropdown",
						width = nil,
						values = nibRealUI.globals.anchorPoints,
						order = 40,
					},
				},
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 41,
			},
			framelevel = {
				type = "group",
				name = "Strata",
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 50,
				args = {
					strata = {
						type = "select",
						name = "Strata",
						get = function(info) 
							for k_ts,v_ts in pairs(nibRealUI.globals.stratas) do
								if v_ts == db.framelevel.strata then return k_ts end
							end
						end,
						set = function(info, value)
							db.framelevel.strata = nibRealUI.globals.stratas[value]
							RuneDisplay:UpdateSettings()
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
						get = function(info) return db.framelevel.level end,
						set = function(info, value) 
							db.framelevel.level = value
							RuneDisplay:UpdateSettings()
						end,
						order = 20,
					},
				},
			},
			gap3 = {
				name = " ",
				type = "description",
				order = 51,
			},
			appearance = {
				type = "group",
				name = "Appearance",
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 60,
				args = {
					opacity = {
						type = "range",
						name = "Opacity",
						min = 0,
						max = 1,
						step = 0.05,
						isPercent = true,
						get = function(info) return db.appearance.opacity end,
						set = function(info, value) db.appearance.opacity = value; RuneDisplay:UpdateSettings(); end,
						order = 10,
					},
				},
			},
			gap4 = {
				name = " ",
				type = "description",
				order = 61,
			},
			runes = {
				type = "group",
				name = "Runes",
				childGroups = "tab",
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 70,
				args = {
					size = {
						type = "group",
						name = "Size",
						order = 10,
						args = {
							width = {
								type = "input",
								name = "Width",
								width = "half",
								order = 10,
								get = function(info) return tostring(db.runes.size.width) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.runes.size.width = value
									RuneDisplay:UpdateSettings()
								end,
							},
							height = {
								type = "input",
								name = "Height",
								width = "half",
								order = 20,
								get = function(info) return tostring(db.runes.size.height) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.runes.size.height = value
									RuneDisplay:UpdateSettings()
								end,
							},
							padding = {
								type = "input",
								name = "Padding",
								width = "half",
								order = 20,
								get = function(info) return tostring(db.runes.size.padding) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.runes.size.padding = value
									RuneDisplay:UpdateSettings()
								end,
							},
						},							
					},
					border = {
						type = "group",
						name = "Border",
						order = 20,
						args = {
							opacity = {
								type = "range",
								name = "Opacity",
								min = 0,
								max = 1,
								step = 0.05,
								isPercent = true,
								get = function(info) return db.runes.border.opacity end,
								set = function(info, value) db.runes.border.opacity = value; RuneDisplay:UpdateSettings(); end,
								order = 10,
							},
							color = {
								type = "color",
								name = "Color",
								hasAlpha = false,
								get = function(info,r,g,b)
									return db.runes.border.color.r, db.runes.border.color.g, db.runes.border.color.b
								end,
								set = function(info,r,g,b)
									db.runes.border.color.r = r
									db.runes.border.color.g = g
									db.runes.border.color.b = b
									RuneDisplay:UpdateSettings()
								end,
								order = 20,
							},
							size = {
								type = "range",
								name = "Size",
								min = 0, max = 4, step = 1,
								get = function(info) return db.runes.border.size end,
								set = function(info, value) 
									db.runes.border.size = value
									RuneDisplay:UpdateSettings()
								end,
								order = 30,
							},
						},
					},
					colors ={
						type = "group",
						name = "Colors",
						order = 30,
						args = {
							blood = {
								type = "color",
								name = "Blood",
								hasAlpha = false,
								get = function(info,r,g,b)
									return db.runes.colors.bright[RUNETYPE_BLOOD].r, db.runes.colors.bright[RUNETYPE_BLOOD].g, db.runes.colors.bright[RUNETYPE_BLOOD].b
								end,
								set = function(info,r,g,b)
									db.runes.colors.bright[RUNETYPE_BLOOD].r = r
									db.runes.colors.bright[RUNETYPE_BLOOD].g = g
									db.runes.colors.bright[RUNETYPE_BLOOD].b = b
									RuneDisplay:UpdateRuneTextures()
								end,
								order = 10,
							},
							unholy = {
								type = "color",
								name = "Unholy",
								hasAlpha = false,
								get = function(info,r,g,b)
									return db.runes.colors.bright[RUNETYPE_UNHOLY].r, db.runes.colors.bright[RUNETYPE_UNHOLY].g, db.runes.colors.bright[RUNETYPE_UNHOLY].b
								end,
								set = function(info,r,g,b)
									db.runes.colors.bright[RUNETYPE_UNHOLY].r = r
									db.runes.colors.bright[RUNETYPE_UNHOLY].g = g
									db.runes.colors.bright[RUNETYPE_UNHOLY].b = b
									RuneDisplay:UpdateRuneTextures()
								end,
								order = 20,
							},
							frost = {
								type = "color",
								name = "Frost",
								hasAlpha = false,
								get = function(info,r,g,b)
									return db.runes.colors.bright[RUNETYPE_FROST].r, db.runes.colors.bright[RUNETYPE_FROST].g, db.runes.colors.bright[RUNETYPE_FROST].b
								end,
								set = function(info,r,g,b)
									db.runes.colors.bright[RUNETYPE_FROST].r = r
									db.runes.colors.bright[RUNETYPE_FROST].g = g
									db.runes.colors.bright[RUNETYPE_FROST].b = b
									RuneDisplay:UpdateRuneTextures()
								end,
								order = 30,
							},
							death = {
								type = "color",
								name = "Death",
								hasAlpha = false,
								get = function(info,r,g,b)
									return db.runes.colors.bright[RUNETYPE_DEATH].r, db.runes.colors.bright[RUNETYPE_DEATH].g, db.runes.colors.bright[RUNETYPE_DEATH].b
								end,
								set = function(info,r,g,b)
									db.runes.colors.bright[RUNETYPE_DEATH].r = r
									db.runes.colors.bright[RUNETYPE_DEATH].g = g
									db.runes.colors.bright[RUNETYPE_DEATH].b = b
									RuneDisplay:UpdateRuneTextures()
								end,
								order = 40,
							},
							dimfactor = {
								type = "range",
								name = "Dim Factor",
								desc = "How much darker should the dim bars be.",
								min = 0,
								max = 1,
								step = 0.05,
								isPercent = true,
								get = function(info) return db.runes.colors.dimfactor end,
								set = function(info, value) db.runes.colors.dimfactor = value; RuneDisplay:UpdateRuneTextures(); end,
								order = 50,
							},
						},
					},
				},
			},
			gap5 = {
				name = " ",
				type = "description",
				order = 71,
			},
			combatfader = {
				type = "group",
				name = "Combat Fader",
				childGroups = "tab",
				order = 80,
				args = {
					enabled = {
						type = "toggle",
						name = "Enabled",
						get = function() return db.combatfader.enabled end,
						set = function(info, value) 
							db.combatfader.enabled = value
							CombatFader.UpdateEnabled()
						end,
						order = 10,
					},
					sep = {
						type = "description",
						name = " ",
						order = 20,
					},
					opacity = {
						type = "group",
						name = "Opacity",
						inline = true,
						disabled = function() if db.combatfader.enabled then return false else return true end end,
						order = 30,
						args = {
							incombat = {
								type = "range",
								name = "In-combat",
								min = 0, max = 1, step = 0.05,
								isPercent = true,
								get = function(info) return db.combatfader.opacity.incombat end,
								set = function(info, value) db.combatfader.opacity.incombat = value; CombatFader.OptionsRefresh(); end,
								order = 10,
							},
							hurt = {
								type = "range",
								name = "Hurt",
								min = 0, max = 1, step = 0.05,
								isPercent = true,
								get = function(info) return db.combatfader.opacity.hurt end,
								set = function(info, value) db.combatfader.opacity.hurt = value; CombatFader.OptionsRefresh(); end,
								order = 20,
							},
							target = {
								type = "range",
								name = "Target-selected",
								min = 0, max = 1, step = 0.05,
								isPercent = true,
								get = function(info) return db.combatfader.opacity.harmtarget end,
								set = function(info, value) db.combatfader.opacity.harmtarget = value; CombatFader.OptionsRefresh(); end,
								order = 30,
							},
							outofcombat = {
								type = "range",
								name = "Out-of-combat",
								min = 0, max = 1, step = 0.05,
								isPercent = true,
								get = function(info) return db.combatfader.opacity.outofcombat end,
								set = function(info, value) db.combatfader.opacity.outofcombat = value; CombatFader.OptionsRefresh(); end,
								order = 40,
							},
						},
					},
				},
			},
		},
	}
	end
	return options
end

---- COMBAT FADER
-- Fade frame
function CombatFader.FadeIt(Frame, NewOpacity)
	local CurrentOpacity = Frame:GetAlpha();
	if NewOpacity > CurrentOpacity then
		UIFrameFadeIn(Frame, FadeTime, CurrentOpacity, NewOpacity);
	elseif NewOpacity < CurrentOpacity then
		UIFrameFadeOut(Frame, FadeTime, CurrentOpacity, NewOpacity);
	end
end

-- Determine new opacity values for frames
function CombatFader.FadeFrames()
	local NewOpacity

	-- Retrieve Element's opacity/visibility for current status
	NewOpacity = 1
	if not RuneDisplay.configMode then
		if CombatFader.Status == "INCOMBAT" then
			NewOpacity = db.combatfader.opacity.incombat
		elseif CombatFader.Status == "HARMTARGET" then
			NewOpacity = db.combatfader.opacity.harmtarget
		elseif CombatFader.Status == "HURT" then
			NewOpacity = db.combatfader.opacity.hurt
		elseif CombatFader.Status == "OUTOFCOMBAT" then
			NewOpacity = db.combatfader.opacity.outofcombat
		end
	end
	CombatFader.FadeIt(RuneDisplay.Frames.Parent, NewOpacity)
end

-- Update current status
function CombatFader.UpdateStatus()
	if RuneDisplay.configMode then
		CombatFader.FadeFrames()
	else
		local OldStatus = CombatFader.Status
		if UnitAffectingCombat("player") then
			CombatFader.Status = "INCOMBAT";				-- InCombat - Priority 1
		elseif UnitExists("target") and UnitCanAttack("player", "target") then
			CombatFader.Status = "HARMTARGET";			-- HarmTarget - Priority 2
		elseif not RunesAreReady then
			CombatFader.Status = "HURT";					-- Not Full - Priority 4
		else
			CombatFader.Status = "OUTOFCOMBAT";			-- OutOfCombat - Priority 5
		end
		if CombatFader.Status ~= OldStatus then CombatFader.FadeFrames() end
	end
end

function CombatFader.PLAYER_ENTERING_WORLD()
	CombatFader.Status = nil
	CombatFader.UpdateStatus()
	CombatFader.FadeFrames()
end

function CombatFader.UpdateRuneStatus()
	if db.combatfader.enabled then
		if ( RuneFull[1] and RuneFull[2] and RuneFull[3] and RuneFull[4] and RuneFull[5] and RuneFull[6] ) then
			RunesAreReady = true
		else
			RunesAreReady = false
		end
		CombatFader.UpdateStatus()
		CombatFader.FadeFrames()
	end
end

function CombatFader.OptionsRefresh()
	CombatFader.Status = nil
	CombatFader.UpdateStatus()
end

function CombatFader.UpdateEnabled()
	if db.combatfader.enabled then
		CombatFader:RegisterEvent("PLAYER_ENTERING_WORLD")
		CombatFader:RegisterEvent("PLAYER_TARGET_CHANGED")
		CombatFader:RegisterEvent("PLAYER_REGEN_ENABLED")
		CombatFader:RegisterEvent("PLAYER_REGEN_DISABLED")
		CombatFader:SetScript("OnEvent", CombatFader.UpdateStatus)
		
		CombatFader.Status = nil
		CombatFader.UpdateRuneStatus()
	else
		CombatFader:UnregisterEvent("PLAYER_ENTERING_WORLD")
		CombatFader:UnregisterEvent("PLAYER_TARGET_CHANGED")
		CombatFader:UnregisterEvent("PLAYER_REGEN_ENABLED")
		CombatFader:UnregisterEvent("PLAYER_REGEN_DISABLED")
		
		RuneDisplay.Frames.Parent:SetAlpha(1)
	end
end

---- RUNES
-- Events
function RuneDisplay.OnUpdate()
	local time = GetTime()
	
	if time > RuneDisplay.LastTime + updateSpeed then	-- Update 25 times a second
		-- Update Rune Bars
		local RuneBar
		local start, duration, runeReady
		for rune = 1, 6 do
			RuneBar = RuneDisplay.Frames.RuneBars[rune]
			start, duration, runeReady = GetRuneCooldown(rune)

			if RuneBar ~= nil then
				if runeReady or UnitIsDead("player") or UnitIsGhost("player") then
					if ( db.combatfader.enabled and (not RuneFull[rune]) and (not RunesAreReady) ) then
						RuneFull[rune] = runeReady
						CombatFader.UpdateRuneStatus()
					end
					
					RuneBar.StatusBarBG:SetHeight((db.runes.size.height + (layoutSize == 1 and 0 or 3)) + db.runes.border.size * 2)
					RuneBar.BottomStatusBar:SetValue(1)
					RuneBar.TopStatusBar:SetValue(1)
				else
					if ( db.combatfader.enabled and (RuneFull[rune] or RunesAreReady) ) then
						RuneFull[rune] = runeReady
						CombatFader.UpdateRuneStatus()
					end
					
					RuneBar.StatusBarBG:SetHeight((((db.runes.size.height + (layoutSize == 1 and 0 or 3))) * ((time - start) / duration)) + db.runes.border.size * 2)
					RuneBar.BottomStatusBar:SetValue((time - start) / duration)
					RuneBar.TopStatusBar:SetValue(math.max((time - (start + duration - gcdNextDuration)) / gcdNextDuration, 0.0))
				end
			end
		end

		RuneDisplay.LastTime = time
	end
end

function RuneDisplay:RuneTextureUpdate(rune)
	RuneBar = RuneDisplay.Frames.RuneBars[rune]
	if not RuneBar then return end
	
	local RuneType = GetRuneType(rune)
	if RuneType then
		RuneBar.BottomStatusBar.bg:SetTexture(db.runes.colors.bright[RuneType].r * db.runes.colors.dimfactor, db.runes.colors.bright[RuneType].g * db.runes.colors.dimfactor, db.runes.colors.bright[RuneType].b * db.runes.colors.dimfactor)
		RuneBar.TopStatusBar.bg:SetTexture(db.runes.colors.bright[RuneType].r, db.runes.colors.bright[RuneType].g, db.runes.colors.bright[RuneType].b)
	end
end

function RuneDisplay:UpdateRuneTextures()
	for rune = 1, 6 do
		RuneDisplay:RuneTextureUpdate(rune)
	end
end

function RuneDisplay:PLAYER_ENTERING_WORLD()
	-- Update rune colors
	RuneDisplay:UpdateRuneTextures()

	-- Update GCD info
	RuneDisplay:ACTIONBAR_UPDATE_COOLDOWN()
end

function RuneDisplay:RUNE_TYPE_UPDATE(event, rune)
	if not rune or tonumber(rune) ~= rune or rune < 1 or rune > 6 then
		return
	end

	-- Update Rune colors
	local _,_,runeReady = GetRuneCooldown(rune)
	RuneDisplay:RuneTextureUpdate(rune, runeReady)
end

function RuneDisplay:ACTIONBAR_UPDATE_COOLDOWN()
	-- Update Global Cooldown
	local gcdStart, gcdDuration, gcdIsEnabled = GetShapeshiftFormCooldown(1)
	gcdEnd = gcdIsEnabled and gcdDuration > 0 and gcdStart + gcdDuration or gcdEnd
end

function RuneDisplay:SetupEvents()
	if ( (not nibRealUI:GetModuleEnabled(MODNAME)) and EventsRegistered) then
		self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
		self:UnregisterEvent("RUNE_TYPE_UPDATE")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		
		RuneDisplay.Frames.Main:SetScript("OnUpdate", nil)
		
		EventsRegistered = false
	else
		self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
		self:RegisterEvent("RUNE_TYPE_UPDATE")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		
		-- Enable OnUpdate handler
		RuneDisplay.LastTime = 0
		RuneDisplay.Frames.Main:SetScript("OnUpdate", RuneDisplay.OnUpdate)
		
		EventsRegistered = true
	end
end

-- Settings Update
function RuneDisplay:UpdateSettings()
	RuneDisplay.Frames.Parent:SetFrameStrata(db.framelevel.strata)
	RuneDisplay.Frames.Parent:SetFrameLevel(db.framelevel.level)
	RuneDisplay.Frames.Parent:SetPoint(db.position.anchorfrom, RealUIPositionersRunes, db.position.anchorto, db.position.x, db.position.y)
	RuneDisplay.Frames.Parent:SetHeight((db.runes.size.height + (layoutSize == 1 and 0 or 3)) + db.runes.size.padding * 2)
	RuneDisplay.Frames.Parent:SetWidth((db.runes.size.width + (layoutSize == 1 and 0 or 1)) * 6 + db.runes.size.padding * 7)
	
	RuneDisplay.Frames.Main:SetAllPoints(RuneDisplay.Frames.Parent)
	RuneDisplay.Frames.Main:SetAlpha(db.appearance.opacity)
	
	local RuneBar
	for i = 1, 6 do
		RuneBar = RuneDisplay.Frames.RuneBars[i]

		-- Create Rune Bar
		RuneBar.frame:SetFrameStrata(db.framelevel.strata)
		RuneBar.frame:SetFrameLevel(db.framelevel.level + 1)
		RuneBar.frame:SetHeight((db.runes.size.height + (layoutSize == 1 and 0 or 3)))
		RuneBar.frame:SetWidth((db.runes.size.width + (layoutSize == 1 and 0 or 1)))
		RuneBar.frame:SetPoint("TOPLEFT", RuneDisplay.Frames.Main, "TOPLEFT", db.runes.size.padding + (i - 1) * ((db.runes.size.width + (layoutSize == 1 and 0 or 1)) + db.runes.size.padding), -db.runes.size.padding)
		
		-- Status Bar BG (Border)
		RuneBar.StatusBarBG:SetPoint("BOTTOM", RuneBar.frame, "BOTTOM", 0, -db.runes.border.size)
		RuneBar.StatusBarBG:SetHeight(RuneBar.frame:GetHeight() + db.runes.border.size * 2)
		RuneBar.StatusBarBG:SetWidth(RuneBar.frame:GetWidth() + db.runes.border.size * 2)
		RuneBar.StatusBarBG:SetTexture(db.runes.border.color.r, db.runes.border.color.g, db.runes.border.color.b, db.runes.border.opacity)

		-- Bottom Status Bar
		RuneBar.BottomStatusBar:SetFrameStrata(db.framelevel.strata)
		RuneBar.BottomStatusBar:SetFrameLevel(RuneBar.frame:GetFrameLevel() + 1)
		RuneBar.BottomStatusBar.bg:SetTexture(db.runes.colors.bright[RUNETYPE_BLOOD].r * db.runes.colors.dimfactor, db.runes.colors.bright[RUNETYPE_BLOOD].g * db.runes.colors.dimfactor, db.runes.colors.bright[RUNETYPE_BLOOD].b * db.runes.colors.dimfactor)

		-- Top Status Bar
		RuneBar.TopStatusBar:SetFrameStrata(db.framelevel.strata)
		RuneBar.TopStatusBar:SetFrameLevel(RuneBar.BottomStatusBar:GetFrameLevel() + 1)
		RuneBar.TopStatusBar.bg:SetTexture(db.runes.colors.bright[RUNETYPE_BLOOD].r, db.runes.colors.bright[RUNETYPE_BLOOD].g, db.runes.colors.bright[RUNETYPE_BLOOD].b)
	end
	
	RuneDisplay:UpdateRuneTextures()
end

-- Frame Creation
function RuneDisplay:CreateFrames()
	if RuneDisplay.Frames then return end
	
	RuneDisplay.Frames = {}
	
	-- Parent frame
	RuneDisplay.Frames.Parent = CreateFrame("Frame", "RealUI_RuneDisplay", RealUIPositionersRunes)
	
	-- Create main frame
	RuneDisplay.Frames.Main = CreateFrame("Frame", nil, RuneDisplay.Frames.Parent)
	RuneDisplay.Frames.Main:SetParent(RuneDisplay.Frames.Parent)
	
	-- Rune Bars
	RuneDisplay.Frames.RuneBars = {}
	local RuneBar
	for i = 1, 6 do
		RuneDisplay.Frames.RuneBars[i] = {}
		RuneBar = RuneDisplay.Frames.RuneBars[i]

		-- Create Rune Bar
		RuneBar.frame = CreateFrame("Frame", nil, RuneDisplay.Frames.Main)
		
		-- Status Bar BG (Border)
		RuneBar.StatusBarBG = RuneBar.frame:CreateTexture()

		-- Bottom Status Bar
		RuneBar.BottomStatusBar = CreateFrame("StatusBar", nil, RuneBar.frame)
			RuneBar.BottomStatusBar:SetOrientation("VERTICAL")
			RuneBar.BottomStatusBar:SetMinMaxValues(0, 1)
			RuneBar.BottomStatusBar:SetValue(1)
			RuneBar.BottomStatusBar:SetAllPoints(RuneBar.frame)

		RuneBar.BottomStatusBar.bg = RuneBar.BottomStatusBar:CreateTexture()
			RuneBar.BottomStatusBar.bg:SetAllPoints()
			RuneBar.BottomStatusBar.bg:SetTexture(db.runes.colors.bright[RUNETYPE_BLOOD].r * db.runes.colors.dimfactor, db.runes.colors.bright[RUNETYPE_BLOOD].g * db.runes.colors.dimfactor, db.runes.colors.bright[RUNETYPE_BLOOD].b * db.runes.colors.dimfactor)
			RuneBar.BottomStatusBar:SetStatusBarTexture(RuneBar.BottomStatusBar.bg)

		-- Top Status Bar
		RuneBar.TopStatusBar = CreateFrame("StatusBar", nil, RuneBar.frame)
			RuneBar.TopStatusBar:SetOrientation("VERTICAL")
			RuneBar.TopStatusBar:SetMinMaxValues(0, 1)
			RuneBar.TopStatusBar:SetValue(1)
			RuneBar.TopStatusBar:SetAllPoints(RuneBar.frame)

		RuneBar.TopStatusBar.bg = RuneBar.TopStatusBar:CreateTexture()
			RuneBar.TopStatusBar.bg:SetAllPoints()
			RuneBar.TopStatusBar.bg:SetTexture(db.runes.colors.bright[RUNETYPE_BLOOD].r, db.runes.colors.bright[RUNETYPE_BLOOD].g, db.runes.colors.bright[RUNETYPE_BLOOD].b)
			RuneBar.TopStatusBar:SetStatusBarTexture(RuneBar.TopStatusBar.bg)
	end
end

---- CORE
function RuneDisplay:ToggleConfigMode(val)
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if nibRealUI.class ~= "DEATHKNIGHT" then return end
	if self.configMode == val then return end

	self.configMode = val
	CombatFader.FadeFrames()
end

function RuneDisplay:RefreshMod()
	if ( (not nibRealUI:GetModuleEnabled(MODNAME)) or (select(2, UnitClass("player")) ~= "DEATHKNIGHT") ) then return end
	
	db = self.db.profile
	
	RuneDisplay:UpdateSettings()
	CombatFader.UpdateEnabled()
end

----
function RuneDisplay:PLAYER_LOGIN()
	LoggedIn = true;
	
	RuneDisplay:RefreshMod()
end

----
function RuneDisplay:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			position = {
				x = 0,
				y = 0,
				anchorto = "BOTTOM",
				anchorfrom = "BOTTOM",
			},
			framelevel = {strata = "LOW", level = 6},
			appearance = {
				opacity = 0.8,
			},
			runes = {
				size = {
					height = 38,
					width = 9,
					padding = 3,
				},
				border = {
					opacity = 1,
					color = {r = 0, g = 0, b = 0},
					size = 1,
				},
				colors = {
					bright = {
						[RUNETYPE_BLOOD] = {r = 0.9, g = 0.15, b = 0.15},
						[RUNETYPE_UNHOLY] = {r = 0.40, g = 0.9, b = 0.30},
						[RUNETYPE_FROST] = {r = 0, g = 0.7, b = 0.9},
						[RUNETYPE_DEATH] = {r = 0.50, g = 0.27, b = 0.68},
					},
					dimfactor = 0.7,
				},
			},
			combatfader = {
				enabled = true,
				opacity = {
					incombat = 1,
					harmtarget = 0.8,
					hurt = 0.5,
					outofcombat = 0,
				},
			},
		},
	})
	db = self.db.profile

	layoutSize = nibRealUI.db.profile.settings.hudSize
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	
	if nibRealUI.class == "DEATHKNIGHT" then
		nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
		nibRealUI:RegisterConfigModeModule(self)
		
		self:CreateFrames()
		
		self:RegisterEvent("PLAYER_LOGIN")
	end		
end

function RuneDisplay:OnEnable()
	if (nibRealUI.class ~= "DEATHKNIGHT") then return end

	self.configMode = false
	
	if nibRealUI.db.profile.settings.powerMode == 1 then
		updateSpeed = 1/25
	elseif nibRealUI.db.profile.settings.powerMode == 2 then
		updateSpeed = 1/20
	else
		updateSpeed = 1/30
	end

	-- Refresh
	if LoggedIn then
		self:RefreshMod()
	end
	
	-- Setup Events
	if not EventsRegistered then
		self:SetupEvents()
	end
	
	-- Disable default rune frame
	RuneFrame:UnregisterAllEvents()
	RuneFrame:Hide()
	RuneFrame.Show = function() end
	
	-- Show RuneDisplay
	self.Frames.Parent:Show()
end

function RuneDisplay:OnDisable()
	if RuneDisplay.Frames then 
		-- Hide RuneDisplay
		RuneDisplay.Frames.Parent:Hide()
	end
	
	-- Setup Events
	if EventsRegistered then
		RuneDisplay:SetupEvents()
	end
end