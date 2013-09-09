local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb

local MODNAME = "Pitch"
local Pitch = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false

local updateSpeed

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Pitch Display",
		desc = "Graphical display of Flight/Swimming pitch.",
		arg = MODNAME,
		childGroups = "tab",
		-- order = 1609,
		args = {
			header = {
				type = "header",
				name = "Pitch Display",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Graphical display of Flight/Swimming pitch.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Pitch Display module.",
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
			visibility = {
				name = "Visibility",
				type = "group",
				inline = true,
				order = 40,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				args = {
					flying = {
						type = "toggle",
						name = "Flying",
						desc = "Show the Pitch display while flying.",
						get = function() return db.visibility.flying end,
						set = function(info, value) 
							db.visibility.flying = value
						end,
						order = 10,
					},
					swimming = {
						type = "toggle",
						name = "Swimming",
						desc = "Show the Pitch display while swimming.",
						get = function() return db.visibility.swimming end,
						set = function(info, value) 
							db.visibility.swimming = value
						end,
						order = 20,
					},
					combat = {
						type = "toggle",
						name = "Combat",
						desc = "Show the Pitch display while in combat.",
						get = function() return db.visibility.combat end,
						set = function(info, value) 
							db.visibility.combat = value
						end,
						order = 30,
					},
				},
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 41,
			},
			position = {
				name = "Position",
				type = "group",
				inline = true,
				order = 50,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				args = {
					x = {
						type = "input",
						name = "X Offset",
						width = "half",
						order = 10,
						get = function(info) return tostring(db.position.x) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.position.x = value
							Pitch:UpdatePosition()
						end,
					},
					y = {
						type = "input",
						name = "Y Offset",
						width = "half",
						order = 20,
						get = function(info) return tostring(db.position.y) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.position.y = value
							Pitch:UpdatePosition()
						end,
					},
				},
			},
			gap3 = {
				name = " ",
				type = "description",
				order = 51,
			},
			animation = {
				name = "Animation",
				type = "group",
				inline = true,
				order = 60,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				args = {
					fadetime = {
						type = "range",
						name = "Fade-Out Time",
						desc = "Time to wait until fading out the Pitch display.",
						order = 10,
						min = 0, max = 10, step = 0.25,
						get = function(info) return db.animation.fadetime end,
						set = function(info, value) 
							db.animation.fadetime = value
						end,
					},
				},
			},
			gap4 = {
				name = " ",
				type = "description",
				order = 61,
			},
			appearance = {
				name = "Appearance",
				type = "group",
				inline = true,
				order = 70,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				args = {
					oapcity = {
						name = "Opacity",
						type = "group",
						inline = true,
						order = 10,
						args = {
							surround = {
								type = "range",
								name = "Surround",
								order = 10,
								min = 0, max = 1, step = 0.05,
								isPercent = true,
								get = function(info) return db.appearance.opacity.surround end,
								set = function(info, value) 
									db.appearance.opacity.surround = value
									Pitch:UpdateColors()
								end,
							},
							background = {
								type = "range",
								name = "Background",
								order = 20,
								min = 0, max = 1, step = 0.05,
								isPercent = true,
								get = function(info) return db.appearance.opacity.background end,
								set = function(info, value) 
									db.appearance.opacity.background = value
									Pitch:UpdateColors()
								end,
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

-- Vars
local PitchHeight = 120

local PitchElements = {
	[1] = "Center",
	[2] = "Mover",
	[3] = "Limit",
}

local PitchTextures = {
	Center = {
		M = {
			surround = [[Interface\AddOns\nibRealUI\Media\Pitch\Center_M_Surround]],
			bg = [[Interface\AddOns\nibRealUI\Media\Pitch\Center_M_BG]],
		},
		U = {
			surround = [[Interface\AddOns\nibRealUI\Media\Pitch\Center_U_Surround]],
			bg = [[Interface\AddOns\nibRealUI\Media\Pitch\Center_U_BG]],
		},
	},
	Mover = {
		M = {
			surround = [[Interface\AddOns\nibRealUI\Media\Pitch\Mover_M_Surround]],
			bg = [[Interface\AddOns\nibRealUI\Media\Pitch\Mover_M_BG]],
		},
		U = {
			surround = [[Interface\AddOns\nibRealUI\Media\Pitch\Mover_U_Surround]],
			bg = [[Interface\AddOns\nibRealUI\Media\Pitch\Mover_U_BG]],
		},
	},
	Limit = {
		surround = [[Interface\AddOns\nibRealUI\Media\Pitch\Limit_Surround]],
		bg = [[Interface\AddOns\nibRealUI\Media\Pitch\Limit_BG]],
	},
}

local PitchFrame = nil
local PitchVisible = false
local PitchFaded = false

local PitchDirection = 0	-- 0 = Center, 1 = Up, -1 = Down
local CurPitch = 0
local ElapsedSinceChange = 0

local PitchLimit = 88		-- Maximum flight pitch in Degrees (88 is WoW's default)
local PitchCenterPoint = 1	-- When to change the Pitch display to Center style

---- PITCH UPDATE
-- Timer
local PitchTimer = CreateFrame("FRAME")
PitchTimer.int = 0.5
PitchTimer:Hide()
PitchTimer:SetScript("OnUpdate", function(self, elapsed)
	PitchTimer.int = PitchTimer.int - elapsed
	ElapsedSinceChange = ElapsedSinceChange + elapsed
	if (PitchTimer.int <= 0) then
		if ( ((db.visibility.flying and IsFlying()) or (db.visibility.swimming and IsSwimming() and not UnitOnTaxi("player"))) and (db.visibility.combat or not UnitAffectingCombat("player")) ) then
			-- Show Pitch display, update pitch and increase update rate
			if not PitchVisible then
				ElapsedSinceChange = 0
				Pitch:UpdateShown(true)
			end
			Pitch:UpdatePitch()
			PitchTimer.int = updateSpeed
		else
			-- Hide Pitch display and decrease update rate
			if PitchVisible then
				Pitch:UpdateShown(false)
			end
			PitchTimer.int = 0.5
			ElapsedSinceChange = 0
		end		
	end
end)

-- Update Pitch display to current pitch
function Pitch:UpdatePitch()
	local OldPitch = CurPitch
	CurPitch = GetUnitPitch("player") * 360 / (2 * math.pi)
	
	-- Limit Pitch to normal max limits (incase people activate Barrel Rolls on their flyers)
	if CurPitch > PitchLimit then CurPitch = PitchLimit end
	if CurPitch < -PitchLimit then CurPitch = -PitchLimit end
	
	-- Fader
	if OldPitch ~= CurPitch then
		ElapsedSinceChange = 0
		if PitchFaded then self:Fade(true) end
	else
		if ElapsedSinceChange > db.animation.fadetime and not PitchFaded then
			self:Fade(false)
		end
	end	
	
	-- Move Mover
	local yPos = floor(CurPitch * ((PitchHeight / 2) / PitchLimit) + 0.5)
	PitchFrame["Mover"]:SetPoint("CENTER", PitchFrame, "CENTER", 0, yPos)
	
	-- Update textures if changing between Up/Down/Center 
	if ((CurPitch < PitchCenterPoint and CurPitch > -PitchCenterPoint) and (PitchDirection ~= 0)) then
		-- Center
		PitchFrame["Center"].bg:SetTexture(PitchTextures.Center.M.bg)
		PitchFrame["Center"].surround:SetTexture(PitchTextures.Center.M.surround)
		PitchFrame["Center"]:SetPoint("CENTER", PitchFrame, "CENTER", 0, 0)
		PitchFrame["Mover"].bg:SetTexture(PitchTextures.Mover.M.bg)
		PitchFrame["Mover"].surround:SetTexture(PitchTextures.Mover.M.surround)
		PitchFrame["Limit"]:Hide()
		
		PitchDirection = 0
	elseif ((CurPitch >= PitchCenterPoint) and (PitchDirection ~= 1)) then
		-- Up
		PitchFrame["Center"].bg:SetTexture(PitchTextures.Center.U.bg)
		PitchFrame["Center"].surround:SetTexture(PitchTextures.Center.U.surround)
		PitchFrame["Center"].bg:SetTexCoord(0, 1, 0, 1)
		PitchFrame["Center"].surround:SetTexCoord(0, 1, 0, 1)
		PitchFrame["Center"]:SetPoint("CENTER", PitchFrame, "CENTER", 0, 1)
		PitchFrame["Mover"].bg:SetTexture(PitchTextures.Mover.U.bg)
		PitchFrame["Mover"].surround:SetTexture(PitchTextures.Mover.U.surround)
		PitchFrame["Mover"].bg:SetTexCoord(0, 1, 0, 1)
		PitchFrame["Mover"].surround:SetTexCoord(0, 1, 0, 1)
		PitchFrame["Limit"].bg:SetTexture(PitchTextures.Limit.bg)
		PitchFrame["Limit"].surround:SetTexture(PitchTextures.Limit.surround)
		PitchFrame["Limit"].bg:SetTexCoord(0, 1, 0, 1)
		PitchFrame["Limit"].surround:SetTexCoord(0, 1, 0, 1)
		PitchFrame["Limit"]:SetPoint("CENTER", PitchFrame, "CENTER", 0, floor((PitchHeight / 2) + 12))
		PitchFrame["Limit"]:Show()
		
		PitchDirection = 1
	elseif ((CurPitch <= -PitchCenterPoint) and (PitchDirection ~= -1)) then
		-- Down
		PitchFrame["Center"].bg:SetTexture(PitchTextures.Center.U.bg)
		PitchFrame["Center"].surround:SetTexture(PitchTextures.Center.U.surround)
		PitchFrame["Center"].bg:SetTexCoord(0, 1, 1, 0)
		PitchFrame["Center"].surround:SetTexCoord(0, 1, 1, 0)
		PitchFrame["Center"]:SetPoint("CENTER", PitchFrame, "CENTER", 0, -1)
		PitchFrame["Mover"].bg:SetTexture(PitchTextures.Mover.U.bg)
		PitchFrame["Mover"].surround:SetTexture(PitchTextures.Mover.U.surround)
		PitchFrame["Mover"].bg:SetTexCoord(0, 1, 1, 0)
		PitchFrame["Mover"].surround:SetTexCoord(0, 1, 1, 0)
		PitchFrame["Limit"].bg:SetTexture(PitchTextures.Limit.bg)
		PitchFrame["Limit"].surround:SetTexture(PitchTextures.Limit.surround)
		PitchFrame["Limit"].bg:SetTexCoord(0, 1, 1, 0)
		PitchFrame["Limit"].surround:SetTexCoord(0, 1, 1, 0)
		PitchFrame["Limit"]:SetPoint("CENTER", PitchFrame, "CENTER", 0, floor(-(PitchHeight / 2) - 12))
		PitchFrame["Limit"]:Show()
		
		PitchDirection = -1
	end
end

---- VISIBILITY
-- Fade In/Out the Pitch display
function Pitch:Fade(val)
	if val then
		UIFrameFadeIn(PitchFrame, 0, 1, 1)
		PitchFaded = false
	else
		UIFrameFadeOut(PitchFrame, 0.5, 1, 0)
		PitchFaded = true
	end
end

-- Show/Hide the Pitch display
function Pitch:UpdateShown(shown)
	if shown then
		PitchFrame:Show()
		PitchVisible = true
	else
		PitchFrame:Hide()
		PitchVisible = false
	end
end

---- FRAME UPDATES
-- Set Colors
function Pitch:UpdateColors()
	for i, v in pairs(PitchElements) do
		PitchFrame[v].bg:SetVertexColor(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], db.appearance.opacity.background)
		PitchFrame[v].surround:SetVertexColor(1, 1, 1, db.appearance.opacity.surround)
	end
end

-- Set Position
function Pitch:UpdatePosition()
	PitchFrame:ClearAllPoints()
	PitchFrame:SetPoint("CENTER", RealUIPositionersCenter, "CENTER", db.position.x, db.position.y)
end

-- Frame Creation
local function CreateArtFrame(parent)
	local NewArtFrame
	NewArtFrame = CreateFrame("Frame", nil, parent)
	NewArtFrame:SetParent(parent)
	NewArtFrame.surround = NewArtFrame:CreateTexture(nil, "ARTWORK")
	NewArtFrame.surround:SetAllPoints()
	NewArtFrame.bg = NewArtFrame:CreateTexture(nil, "ARTWORK")
	NewArtFrame.bg:SetAllPoints(NewArtFrame)
	return NewArtFrame
end

local function CreateFrames()
	if not PitchFrame then
		-- Main
		PitchFrame = CreateFrame("Frame", "RealUIPitch", RealUIPositionersCenter)
		PitchFrame:SetParent(RealUIPositionersCenter)
		PitchFrame:SetFrameStrata("MEDIUM")
		PitchFrame:SetFrameLevel(0)
		PitchFrame:SetHeight(PitchHeight)
		PitchFrame:SetWidth(100)
		PitchFrame:Hide()
		
		-- Elements
		for i, v in pairs(PitchElements) do
			PitchFrame[v] = CreateArtFrame(PitchFrame)
			PitchFrame[v]:ClearAllPoints()
			PitchFrame[v]:SetPoint("CENTER", PitchFrame, "CENTER", 0, 0)
			PitchFrame[v]:SetFrameStrata("MEDIUM")
			PitchFrame[v]:SetFrameLevel(0)
			PitchFrame[v]:SetWidth(64)
			PitchFrame[v]:SetHeight(64)
		end
		PitchFrame["Mover"]:SetFrameLevel(1)
		PitchFrame["Limit"].bg:SetTexture(ArrowLarge)
	end
end

---- UPDATES
local function ClassColorsUpdate()
	if PitchFrame then
		self:UpdateColors()
	end
end

function Pitch:RefreshMod()
	if not PitchFrame then
		CreateFrames()
	end
	PitchTimer:Show()
	self:UpdatePosition()
	self:UpdateColors()
end

function Pitch:PLAYER_LOGIN()
	self:RefreshMod()
end

function Pitch:SetUpdateSpeed()
	if ndb.settings.powerMode == 1 then		-- Normal
		updateSpeed = 1/40
	elseif ndb.settings.powerMode == 2 then	-- Economy
		updateSpeed = 1/30
	else 							-- Turbo
		updateSpeed = 1/60
	end
end

---- INITIALIZE
function Pitch:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			visibility = {
				flying = true,
				swimming = true,
				combat = false,			
			},
			position = {
				x = -1,
				y = 0,
			},
			animation = {
				fadetime = 0.5,
			},
			appearance = {
				opacity = {
					surround = 1,
					background = 0.8,
				},
			},
		},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function Pitch:OnEnable()
	self:SetUpdateSpeed()
	self:RegisterEvent("PLAYER_LOGIN")
	
	if LoggedIn then
		self:RefreshMod()
	end
	
	---- ClassColors support
	if CUSTOM_CLASS_COLORS then
		CUSTOM_CLASS_COLORS:RegisterCallback(ClassColorsUpdate)
	end
end

function Pitch:OnDisable()
	if PitchFrame then
		PitchFrame:Hide()
		PitchTimer:Hide()
	end
end