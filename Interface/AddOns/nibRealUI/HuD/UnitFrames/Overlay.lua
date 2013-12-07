local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local RC = LibStub("LibRangeCheck-2.0")
local db, ndb, ndbc

local oUF = oUFembed

local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")

local _
local min = math.min
local max = math.max
local floor = _G.floor
local ceil = _G.ceil
local format = _G.format
local strform = _G.string.format
local tonumber = _G.tonumber
local tostring = _G.tostring
local strlen = _G.strlen
local strsub = _G.strsub

---------------------
------ Overlay ------
---------------------
local layoutSize = 2

local PLAYER_ID = "player"
local PET_ID = "pet"
local VEHICLE_ID = "vehicle"
local FOCUS_ID = "focus"
local FOCUSTARGET_ID = "focustarget"
local TARGET_ID = "target"
local TARGETTARGET_ID = "targettarget"
local BOSS_ID = "boss"

local Textures = {
	[1] = {
		f1 = {
			health = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Bar]],
				step = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Step]],
				warning = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Warning]],
			},
			power = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Bar]],
				step = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Step]],
				warning = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Warning]],
			},
			endbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_EndBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_EndBox_Bar]],
			},
			statusbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_StatusBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_StatusBox_Bar]],
			},
			healthbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_HealthBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_HealthBox_Bar]],
			},
			powerbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_PowerBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_PowerBox_Bar]],
			},
		},
		f2 = {
			health = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Bar]],
				step = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Step]],
			},
			endbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_EndBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_EndBox_Bar]],
			},
			statusbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_StatusBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_StatusBox_Bar]],
			},
			healthbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_HealthBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_HealthBox_Bar]],
			},
		},
		f3 = {
			health = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Bar]],
				step = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Step]],
			},
			endbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_EndBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_EndBox_Bar]],
			},
			statusbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_StatusBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_StatusBox_Bar]],
			},
			healthbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_HealthBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_HealthBox_Bar]],
			},
		},
	},
	[2] = {
		f1 = {
			health = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Bar]],
				step = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Step]],
				warning = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Warning]],
			},
			power = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Bar]],
				step = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Step]],
				warning = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Warning]],
			},
			endbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_EndBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_EndBox_Bar]],
			},
			statusbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_StatusBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_StatusBox_Bar]],
			},
			healthbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_HealthBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_HealthBox_Bar]],
			},
			powerbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_PowerBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_PowerBox_Bar]],
			},
		},
		f2 = {
			health = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Bar]],
				step = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Step]],
			},
			endbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_EndBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_EndBox_Bar]],
			},
			statusbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_StatusBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_StatusBox_Bar]],
			},
			healthbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_HealthBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_HealthBox_Bar]],
			},
		},
		f3 = {
			health = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Bar]],
				step = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Step]],
			},
			endbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_EndBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_EndBox_Bar]],
			},
			statusbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_StatusBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_StatusBox_Bar]],
			},
			healthbox = {
				surround = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_HealthBox_Surround]],
				bar = [[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_HealthBox_Bar]],
			},
		},
	},
}

local UF = {
	[PLAYER_ID] = nil,
	[PET_ID] = nil,
	[TARGET_ID] = nil,
	[FOCUS_ID] = nil,
	[FOCUSTARGET_ID] = nil,
	[TARGETTARGET_ID] = nil,
}

local ParentFrames = {
	[PLAYER_ID] = "oUF_RealUIPlayer",
	[PET_ID] = "oUF_RealUIPet",
	[TARGET_ID] = "oUF_RealUITarget",
	[FOCUS_ID] = "oUF_RealUIFocus",
	[FOCUSTARGET_ID] = "oUF_RealUIFocusTarget",
	[TARGETTARGET_ID] = "oUF_RealUITargetTarget",
}

local FontStringsSmall = {}
local FontStringsRegular = {}
local FontStringsNumbers = {}
local FontStringsY = {}

local HealthWidth = {
	[1] = {
		[PLAYER_ID] = 208,
		[TARGET_ID] = 208,
		[FOCUS_ID] = 112,
		[FOCUSTARGET_ID] = 96,
		[PET_ID] = 96,
		[TARGETTARGET_ID] = 112,
	},
	[2] = {
		[PLAYER_ID] = 243,
		[TARGET_ID] = 243,
		[FOCUS_ID] = 132,
		[FOCUSTARGET_ID] = 116,
		[PET_ID] = 116,
		[TARGETTARGET_ID] = 132,
	},
}
local HealthHeight = {
	[1] = {
		[PLAYER_ID] = 11,
		[TARGET_ID] = 11,
		[FOCUS_ID] = 7,
		[FOCUSTARGET_ID] = 7,
		[PET_ID] = 7,
		[TARGETTARGET_ID] = 7,
	},
	[2] = {
		[PLAYER_ID] = 13,
		[TARGET_ID] = 13,
		[FOCUS_ID] = 8,
		[FOCUSTARGET_ID] = 8,
		[PET_ID] = 8,
		[TARGETTARGET_ID] = 8,
	},
}
local F1_OverlayWidth = {
	[1] = 256,
	[2] = 291,
}
local F1_OverlayHeight = {
	[1] = 32,
	[2] = 34,
}
local F1_HealthTextureWidth = {
	[1] = 256,
	[2] = 512,
}
local F1_HealthTextVertical = {
	[1] = 15,
	[2] = 17,
}
local F1_TargetRightHealthTextOffset = {
	[1] = -44,
	[2] = -265,
}
local F1_PowerTextVertical = {
	[1] = 5,
	[2] = 3,
}

local PowerWidth = {
	[1] = {
		[PLAYER_ID] = 188,
		[TARGET_ID] = 188,
	},
	[2] = {
		[PLAYER_ID] = 219,
		[TARGET_ID] = 219,
	},
}
local PowerHeight = {
	[1] = {
		[PLAYER_ID] = 6,
		[TARGET_ID] = 6,
	},
	[2] = {
		[PLAYER_ID] = 8,
		[TARGET_ID] = 8,
	},
}
local PowerXOffset = {
	[1] = -7,
	[2] = -9,
}

local F1_EndBoxXOffset = {
	[1] = 0,
	[2] = -2,
}
local F1_EndBoxYOffset = {
	[1] = 1,
	[2] = 0,
}


local ReversePowers = {
	["RAGE"] = true,
	["RUNIC_POWER"] = true,
	["POWER_TYPE_SUN_POWER"] = true,
}

local PlayerStepPoints

local HealthStepOffsets = {
	[1] = {
		[PLAYER_ID] = {6, 5},
		[FOCUS_ID] = {17, 17},
		[FOCUSTARGET_ID] = {5, 4},
		[PET_ID] = {5, 4},
		[TARGET_ID] = {-5, -5},
		[TARGETTARGET_ID] = {-16, -17},
	},
	[2] = {
		[PLAYER_ID] = {4, 3},
		[FOCUS_ID] = {16, 15},
		[FOCUSTARGET_ID] = {1, 1},
		[PET_ID] = {5, 4},
		[TARGET_ID] = {-3, -2},
		[TARGETTARGET_ID] = {-15, -15},
	},
}
local HealthStepVerticalOffsets = {
	[1] = {
		[PLAYER_ID] = -4,
		[FOCUS_ID] = -4,
		[FOCUSTARGET_ID] = -4,
		[PET_ID] = -4,
		[TARGET_ID] = -4,
		[TARGETTARGET_ID] = -4,
	},
	[2] = {
		[PLAYER_ID] = -2,
		[FOCUS_ID] = -4,
		[FOCUSTARGET_ID] = -4,
		[PET_ID] = -3,
		[TARGET_ID] = -2,
		[TARGETTARGET_ID] = -4,
	},
}

local HealthWarningOffsets = {
	[1] = {
		[PLAYER_ID] = {-7, -8},
		[TARGET_ID] = {8, 8},
	},
	[2] = {
		[PLAYER_ID] = {-13, -12},
		[TARGET_ID] = {14, 13},
	},
}

local PowerStepOffsets = {
	[1] = {
		[PLAYER_ID] = {9, 8, 8},
		[TARGET_ID] = {-8, -8, -8},
	},
	[2] = {
		[PLAYER_ID] = {5, 5, 5},
		[TARGET_ID] = {-4, -4, -4},
	},
}

local RangeColors = {}

local UnitHealthVal = {
	[PLAYER_ID] = 0,
	[TARGET_ID] = 0,
	[VEHICLE_ID] = 0,
}

-- Seconds to Time
local function ConvertSecondstoTime(value)
	local minutes, seconds
	minutes = floor(value / 60)
	seconds = floor(value - (minutes * 60))
	if ( minutes > 0 ) then
		if ( seconds < 10 ) then seconds = strform("0%d", seconds) end
		return strform("%s:%s", minutes, seconds)
	else
		return strform("%ss", seconds)
	end
end

-- Safe Unit Vals
local function GetSafeVals(vCur, vMax)
	local percent
	if vCur > 0 and vMax == 0 then
		vMax = vCur
		percent = 1
	elseif vCur == 0 and vMax == 0 then
		percent = 1
	elseif (vCur < 0) or (vMax < 0) then
		vCur = abs(vCur)
		vMax = abs(vMax)
		vMax = max(vCur, vMax)
		percent = vCur / vMax
	else
		percent = vCur / vMax
	end
	return vCur, vMax, percent
end

-- Class Color
local classColors
local function GetClassColor(class, darken)
	if not RAID_CLASS_COLORS[class] then return {1, 1, 1} end
	classColors = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]

	if darken then
		local color = nibRealUI:ColorDarken({classColors.r, classColors.g , classColors.b}, 0.2)
		color = nibRealUI:ColorDesaturate(color, 0.4)
		return color
	else
		return {classColors.r, classColors.g , classColors.b}
	end
end

-- Frame Position
local function SetFramePosition(frame, strata, level, width, height, ...)
	frame:ClearAllPoints()
	frame:SetFrameStrata(strata)
	frame:SetFrameLevel(level)
	frame:SetWidth(width)
	frame:SetHeight(height)
	if ... then
		frame:SetPoint(unpack(...))
	end
end

-- Text Position
local function SetTextPosition(frame, p1, p2)
	local cPos = (p1 ~= "CENTER") and p1..p2 or p1
	frame.text:ClearAllPoints()
	frame.text:SetPoint(cPos, frame, cPos, 0.5, 0.5)
	frame.text:SetJustifyH(p2)
	frame.text:SetJustifyV(p1)
end

-- Druid/Monk Power
local DruidNonManaForms = {
	[CAT_FORM] = true,
	[BEAR_FORM] = true,
}
local function HasSecondaryPower()
	if UF[PLAYER_ID].haspet or UF[PLAYER_ID].vehicle or
		not(nibRealUI.class == "DRUID" or nibRealUI.class == "MONK") or
		(UF[PLAYER_ID].powerToken == "MANA") or (UnitPowerMax(PLAYER_ID, 0) <= 0) or
		((nibRealUI.class == "MONK") and (GetSpecialization() ~= SPEC_MONK_MISTWEAVER)) then
			return false
	end

	if not UF[PLAYER_ID].form and (nibRealUI.class == "DRUID") then UF[PLAYER_ID].form = GetShapeshiftFormID() end
	if nibRealUI.class == "DRUID" and not(DruidNonManaForms[UF[PLAYER_ID].form]) then return false end
	
	return true
end

-- Vehicle swap
local function PlayerOrVehicleIDs(UnitID)
	if ((UnitID == PLAYER_ID) or (UnitID == VEHICLE_ID)) then
		if UF[PLAYER_ID].vehicle then
			return VEHICLE_ID, PLAYER_ID
		else
			return PLAYER_ID, PLAYER_ID
		end
	else
		return UnitID, UnitID
	end
end
local function SetPlayerVehicleFlag()
	UF[PLAYER_ID].vehicle = (UnitHasVehicleUI(PLAYER_ID) and UnitExists(VEHICLE_ID))
end

---- UNIT FRAME UPDATES ----
-- Range Display
function UnitFrames:RangeDisplayUpdate()
	if not(UnitExists(TARGET_ID)) then return end
	
	-- Get range
	local section
	local minRange, maxRange = RC:GetRange(TARGET_ID)
	
	-- No change? Skip
	if ((minRange == UF[TARGET_ID].stat1.lastMinRange) and (maxRange == UF[TARGET_ID].stat1.lastMinRange)) then return end
	
	-- Get Range section
	if UnitIsUnit(PLAYER_ID, TARGET_ID) then maxRange = nil end
	if minRange > 80 then maxRange = nil end
	if maxRange then
		if maxRange <= 5 then
			section = 5
		elseif maxRange <= 30 then
			section = 30
		elseif maxRange <= 35 then
			section = 35
		elseif maxRange <= 40 then
			section = 40
		else
			section = 100
		end
		UF[TARGET_ID].stat1.text:SetFormattedText("%d", maxRange)
		UF[TARGET_ID].stat1.text:SetTextColor(RangeColors[section][1], RangeColors[section][2], RangeColors[section][3])
		UF[TARGET_ID].stat1.icon:Show()
	else
		UF[TARGET_ID].stat1.text:SetText("")
		UF[TARGET_ID].stat1.icon:Hide()
	end
end

-- Unit Absorb
local ValidAbsorbUnit = {
	[PLAYER_ID] = true,
	[TARGET_ID] = true,
	[VEHICLE_ID] = true,
}
function UnitFrames:UpdateUnitAbsorb(UnitID)
	local Unit, UFUnit = PlayerOrVehicleIDs(UnitID)

	-- Skip
	if not ValidAbsorbUnit[Unit] then return end
	if not UnitExists(Unit) then return end
	
	-- Vals
	local uHealth, uHealthMax = GetSafeVals(UnitHealth(Unit), UnitHealthMax(Unit))
	local uAbsorb = UnitGetTotalAbsorbs(Unit)
	local PerAbsorb = min(uAbsorb, uHealth) / uHealthMax

	-- Set Bar
	AngleStatusBar:SetValue(UF[UFUnit].absorbBar, 1-PerAbsorb, true)

	-- Reposition
	local xO = (uHealth < uHealthMax) and 0 or 1
	if UFUnit == PLAYER_ID then
		UF[UFUnit].absorbBar:SetPoint("TOPRIGHT", UF[UFUnit].health.bar, "TOPLEFT", -xO, 0)
	else
		UF[UFUnit].absorbBar:SetPoint("TOPLEFT", UF[UFUnit].health.bar, "TOPRIGHT", xO, 0)
	end
end

-- Unit Health
local ValidHealthUnit = {
	[PLAYER_ID] = true,
	[TARGET_ID] = true,
	[PET_ID] = true,
	[VEHICLE_ID] = true,
	[FOCUS_ID] = true,
	[FOCUSTARGET_ID] = true,
	[TARGETTARGET_ID] = true,
}
function UnitFrames:UpdateUnitHealth(UnitID, majorUpdate)
	local Unit, UFUnit = PlayerOrVehicleIDs(UnitID)
	if not UF[UFUnit] then return end
	if not(ValidHealthUnit[Unit]) then return end
	if not UnitExists(Unit) then return end
	
	-- Vals
	local uHealth, uHealthMax, PerHP = GetSafeVals(UnitHealth(Unit), UnitHealthMax(Unit))
	if UnitHealthVal[Unit] then UnitHealthVal[Unit] = uHealth end
	
	-- Health hasn't changed? Skip
	-- if UF[UFUnit].health.position == PerHP and not(majorUpdate) then return end
	UF[UFUnit].health.position = PerHP
	
	if ((UFUnit == PLAYER_ID) or (UFUnit == TARGET_ID)) then
		-- Steps
		local CurStep, NewStep, StepChanged = 0, 0, false
		local HealthStepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
		CurStep = (PerHP < (HealthStepPoints[2] + 0.01)) and 2 or (PerHP < (HealthStepPoints[1] + 0.01)) and 1 or 0
		NewStep = CurStep
		if UF[UFUnit].health.step ~= CurStep then
			UF[UFUnit].health.step = CurStep
			if (UFUnit == PLAYER_ID) or (UFUnit == TARGET_ID) then
				if (CurStep == 0) then
					for i = 1, 2 do
						UF[UFUnit].health.warning[i]:Hide()
						UF[UFUnit].health.steps[i]:Show()
					end
				elseif (CurStep == 1) then
					UF[UFUnit].health.steps[1]:Hide()
					UF[UFUnit].health.steps[2]:Show()
					UF[UFUnit].health.warning[1]:Show()
					UF[UFUnit].health.warning[2]:Hide()
				elseif (CurStep == 2) then
					UF[UFUnit].health.steps[1]:Show()
					UF[UFUnit].health.steps[2]:Hide()
					UF[UFUnit].health.warning[1]:Hide()
					UF[UFUnit].health.warning[2]:Show()
				end
			end
		end
		
		---- Texts
		if PerHP >= 0.91 then
			UF[UFUnit].health.fullval.text:SetText(self:ReadableNumber(uHealth, 1))
		else
			if (UFUnit == TARGET_ID) and (db.misc.alwaysDisplayFullHealth) then
				UF[UFUnit].health.fullval.text:SetText(tostring(floor(PerHP * 100)).."|cff"..self.colorStrings.health.."%|r|cffffffff".." - "..self:ReadableNumber(uHealth, 1))
			else
				UF[UFUnit].health.fullval.text:SetText(tostring(floor(PerHP * 100)).."|cff"..self.colorStrings.health.."%")
			end
		end
	end
	
	-- Set Bar
	AngleStatusBar:SetValue(UF[UFUnit].health.bar, PerHP, majorUpdate)

	-- Absorb Bar Update
	if ValidAbsorbUnit[Unit] then
		AngleStatusBar:SetValue(UF[UFUnit].absorbBar, 1-(min(UnitGetTotalAbsorbs(Unit), uHealth) / uHealthMax))
		local xO = (uHealth < uHealthMax) and 0 or 1
		if UFUnit == PLAYER_ID then
			UF[UFUnit].absorbBar:SetPoint("TOPRIGHT", UF[UFUnit].health.bar, "TOPLEFT", -xO, 0)
		else
			UF[UFUnit].absorbBar:SetPoint("TOPLEFT", UF[UFUnit].health.bar, "TOPRIGHT", xO, 0)
		end
	end
end

function UnitFrames:Health_OnUpdate(self, elapsed, UnitID)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed >= self.interval then
		UnitFrames:UpdateUnitHealth(UnitID)
		self.elapsed = 0
	end
end

-- Unit Power
local ValidPowerUnit = {
	[PLAYER_ID] = true,
	[TARGET_ID] = true,
	[VEHICLE_ID] = true,
}
function UnitFrames:UpdateUnitPower(UnitID, majorUpdate)
	local Unit, UFUnit = PlayerOrVehicleIDs(UnitID)
	
	-- Skip
	if not(ValidPowerUnit[Unit]) then return end
	if not (UF[UFUnit] and UF[UFUnit].power and UF[UFUnit].power.enabled) then return end
	if (UF[PLAYER_ID].vehicle and (Unit == PET_ID)) then return end
	if not UnitExists(Unit) then return end

	local uPower, uPowerMax, PerMP = GetSafeVals(UnitPower(Unit), UnitPowerMax(Unit))
	
	-- Druid/Monk Mana
	if (UFUnit == PLAYER_ID) then
		-- Update at 1/3rd the regular Power update speed
		UF[UFUnit].power.playerUpdateCnt = UF[UFUnit].power.playerUpdateCnt + 1
		if mod(UF[UFUnit].power.playerUpdateCnt, 3) == 0 then
			UF[UFUnit].power.playerUpdateCnt = 0
			if HasSecondaryPower() then
				local xDMPos = floor(-(1 - (UnitPower(Unit, 0) / UnitPowerMax(Unit, 0))) * (PowerWidth[layoutSize][UFUnit]))
				if xDMPos == 0 then
					UF[UFUnit].power2:Hide()
				else
					UF[UFUnit].power2:Show()
					UF[UFUnit].power2:SetPoint("BOTTOMRIGHT", UF[UFUnit].power.surround, "BOTTOMRIGHT", xDMPos, 9)
				end
			else
				UF[UFUnit].power2:Hide()
			end
		end
	end

	-- Power hasn't changed? Skip
	if UF[UFUnit].power.position == PerMP and not majorUpdate then return end
	UF[UFUnit].power.position = PerMP
	
	-- Step
	if UF[UFUnit].power.hassteps and not UF[UFUnit].power.bar.reverse then
		local CurStep, NewStep, StepChanged, add = 0, 0, false, 0.01
		if UF[UFUnit].power.sinrogue then add = 0 end
		CurStep = 	((PerMP < (UF[UFUnit].power.steppoints[3] + add)) and UF[UFUnit].power.sinrogue) and 3 or 
					(PerMP < (UF[UFUnit].power.steppoints[2] + add)) and 2 or 
					(PerMP < (UF[UFUnit].power.steppoints[1] + add)) and 1 or 0
		
		NewStep = CurStep
		if UF[UFUnit].power.step ~= NewStep then
			UF[UFUnit].power.step = CurStep
			if (UFUnit == PLAYER_ID) or (UFUnit == TARGET_ID) then
				if (CurStep == 0) then
					for i = 1, UF[UFUnit].power.sinrogue and 3 or 2 do
						UF[UFUnit].power.steps[i]:Show()
						UF[UFUnit].power.warning[i]:Hide()
					end
				elseif (CurStep == 1) then
					UF[UFUnit].power.steps[1]:Hide()
					UF[UFUnit].power.steps[2]:Show()
					if UF[UFUnit].power.sinrogue then UF[UFUnit].power.steps[3]:Show() end
					UF[UFUnit].power.warning[1]:Show()
					UF[UFUnit].power.warning[2]:Hide()
					if UF[UFUnit].power.sinrogue then UF[UFUnit].power.warning[3]:Hide() end
				elseif (CurStep == 2) then
					UF[UFUnit].power.steps[1]:Show()
					UF[UFUnit].power.steps[2]:Hide()
					UF[UFUnit].power.warning[1]:Hide()
					UF[UFUnit].power.warning[2]:Show()
					if UF[UFUnit].power.sinrogue then
						UF[UFUnit].power.steps[3]:Show()
						UF[UFUnit].power.warning[3]:Hide()
					end
				elseif (UF[UFUnit].power.sinrogue and CurStep == 3) then
					UF[UFUnit].power.steps[1]:Show()
					UF[UFUnit].power.steps[2]:Show()
					UF[UFUnit].power.steps[3]:Hide()
					UF[UFUnit].power.warning[1]:Hide()
					UF[UFUnit].power.warning[2]:Hide()
					UF[UFUnit].power.warning[3]:Show()
				end
			end
		end
	end
	
	---- Texts
	if UF[UFUnit].powerToken == "MANA" then
		if PerMP >= 0.91 then
			UF[UFUnit].power.fullval.text:SetText(self:ReadableNumber(uPower, 1))
		else
			UF[UFUnit].power.fullval.text:SetText(tostring(floor(PerMP * 100)).."|cff"..self.colorStrings.mana.."%")
		end
	else
		UF[UFUnit].power.fullval.text:SetText(uPower)
	end
	
	-- Set Bar
	AngleStatusBar:SetValue(UF[UFUnit].power.bar, PerMP, majorUpdate)
end

function UnitFrames:Power_OnUpdate(self, elapsed, UnitID)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed >= self.interval then
		UnitFrames:UpdateUnitPower(UnitID)
		self.elapsed = 0
	end
end

-- Unit Health Bar
function UnitFrames:UpdateUnitHealthBarInfo(UnitID, majorUpdate)
	local Unit, UFUnit = PlayerOrVehicleIDs(UnitID)
	if not UF[UFUnit] then return end
	if not(ValidHealthUnit[Unit]) then return end
	if not(UnitExists(Unit)) then return end
	
	-- Find Color type
	local ColorType = "normal"
	if (Unit ~= PLAYER_ID) then
		if UnitIsDeadOrGhost(Unit) then
			ColorType = "dead"
		elseif UnitIsPlayer(Unit) and db.overlay.classColor then
			ColorType = "class"
		else
			ColorType = "normal"
		end
	else
		-- Player
		if UnitIsDeadOrGhost(Unit) then
			ColorType = "dead"
		else
			ColorType = "normal"
		end
	end

	local hColor = {}
	local newColorID = ""
	if ColorType == "normal" or ColorType == "dead" then
		hColor = db.overlay.colors.health.normal
		newColorID = "normal"
	-- elseif ColorType == "dead" then
	-- 	hColor = db.overlay.colors.status.dead
	-- 	newColorID = "dead"
	elseif ColorType == "class" then
		local _, uClass = UnitClass(Unit)
		hColor = GetClassColor(uClass, true)
		newColorID = uClass
	end
	
	-- Apply colors
	if (UF[UFUnit].health.colorID ~= newColorID) or majorUpdate then
		UF[UFUnit].health.colorID = newColorID
		AngleStatusBar:SetBarColor(UF[UFUnit].health.bar, hColor)
	end
	
	-- Steps
	if not majorUpdate then
		UF[UFUnit].health.step = 0
		local HealthStepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
		if (UFUnit == PLAYER_ID) or (UFUnit == FOCUS_ID) or (UFUnit == FOCUSTARGET_ID) or (UFUnit == PET_ID) then
			for i = 1, 2 do
				SetFramePosition(UF[UFUnit].health.steps[i], "MEDIUM", UF[UFUnit].health.surround:GetFrameLevel() + 2, 16, 16, 
					{
						"TOPRIGHT", UF[UFUnit].health.surround, "TOPRIGHT", 
						floor(-(HealthWidth[layoutSize][UFUnit] - (HealthWidth[layoutSize][UFUnit] * PlayerStepPoints[i]))) + HealthStepOffsets[layoutSize][UFUnit][i],  -- x
						HealthStepVerticalOffsets[layoutSize][UFUnit] 	-- y
					})
				UF[UFUnit].health.steps[i]:Show()
				if (UFUnit == PLAYER_ID) then
					SetFramePosition(UF[UFUnit].health.warning[i], "MEDIUM", UF[UFUnit].health.surround:GetFrameLevel() + 2, 16, 16, 
						{
							"BOTTOMLEFT", UF[UFUnit].health.surround, "BOTTOMRIGHT", 
							floor(-((1 - HealthStepPoints[i]) * HealthWidth[layoutSize][UFUnit]) + HealthWarningOffsets[layoutSize][UFUnit][i]), -- x
							1 	-- y
						})
					UF[UFUnit].health.warning[i]:Hide()
				end
			end
		else
			for i = 1, 2 do
				SetFramePosition(UF[UFUnit].health.steps[i], "MEDIUM", UF[UFUnit].health.surround:GetFrameLevel() + 2, 16, 16, 
					{
						"BOTTOMLEFT", UF[UFUnit].health.surround, "BOTTOMLEFT", 
						floor(HealthWidth[layoutSize][UFUnit] - (HealthWidth[layoutSize][UFUnit] * PlayerStepPoints[i])) + HealthStepOffsets[layoutSize][UFUnit][i], 
						HealthStepVerticalOffsets[layoutSize][UFUnit]
					})
				UF[UFUnit].health.steps[i]:Show()
				if (UFUnit == TARGET_ID) then
					SetFramePosition(UF[UFUnit].health.warning[i], "MEDIUM", UF[UFUnit].health.surround:GetFrameLevel() + 2, 16, 16, 
						{
							"BOTTOMRIGHT", UF[UFUnit].health.surround, "BOTTOMLEFT", 
							floor(((1 - HealthStepPoints[i]) * HealthWidth[layoutSize][UFUnit]) + HealthWarningOffsets[layoutSize][UFUnit][i]),	-- x
							1 	-- y
						})
					UF[UFUnit].health.warning[i]:Hide()
				end
			end
		end
		UnitFrames:UpdateUnitHealth(UFUnit, true)
	end
	
end

-- Unit Power Bar Color
function UnitFrames:UpdateUnitPowerBarInfo(UnitID, majorUpdate)
	local Unit, UFUnit = PlayerOrVehicleIDs(UnitID)
	if not(ValidPowerUnit[Unit]) then return end
	if not UF[UFUnit] then return end
	if not UF[UFUnit].power.enabled then return end
	if not(UnitExists(Unit)) then return end

	-- Power info
	local pType, pToken, altR, altG, altB = UnitPowerType(Unit)
	UF[UFUnit].powerToken = pToken

	-- Form info
	if UnitID == PLAYER_ID then UF[UFUnit].form = GetShapeshiftFormID() end

	-- Update Speed
	local pMax = UnitPowerMax(Unit)
	if (UFUnit == PLAYER_ID) or (UFUnit == TARGET_ID and UnitIsUnit(TARGET_ID, PLAYER_ID)) then
		UF[UFUnit].power.interval = db.misc.powerupdatespeed[pToken] or db.misc.powerupdatespeed["default"]
	else
		UF[UFUnit].power.interval = 0.2
	end
	
	-- Set defaults
	UF[UFUnit].power.position = -1
	
	-- Get Color
	local NewColor = ""
	local pColor
	if UnitIsDeadOrGhost(Unit) then
		pColor = db.overlay.colors.status.dead
		NewColor = "DEAD"	
	else
		if self.PowerColors[pToken] then
			pColor = self.PowerColors[pToken]
			NewColor = pToken
		else
			if not(altR) then
				pColor = self.PowerColors["MANA"]
				NewColor = "MANA"
			else
				pColor = {altR, altG, altB}
				NewColor = "ALT"
			end
		end
	end
	
	-- Reverse
	if ReversePowers[pToken] then
		UF[UFUnit].power.bar.reverse = true
	else
		UF[UFUnit].power.bar.reverse = false
	end

	-- Apply colors
	if (UF[UFUnit].power.color ~= NewColor) or majorUpdate then
		UF[UFUnit].power.color = NewColor
		AngleStatusBar:SetBarColor(UF[UFUnit].power.bar, pColor)
	end
	
	---- Steps
	-- Calc step points
	UF[UFUnit].power.step = 0
	UF[UFUnit].power.hassteps = false
	UF[UFUnit].power.steppoints[1] = PlayerStepPoints[1]
	UF[UFUnit].power.steppoints[2] = PlayerStepPoints[2]
	UF[UFUnit].power.steppoints[3] = 0
	if ((pToken == "MANA") or ((pToken ~= "MANA") and (pMax == 100))) then
		UF[UFUnit].power.hassteps = true
	elseif UnitPowerMax(Unit) > 80 then
		local s = 1
		if UF[UFUnit].power.sinrogue then
			UF[UFUnit].power.steppoints[1] = 0.55 * (100 / pMax)
			s = 2
		end
		UF[UFUnit].power.steppoints[s] = PlayerStepPoints[1] * (100 / pMax)
		UF[UFUnit].power.steppoints[s + 1] = PlayerStepPoints[2] * (100 / pMax)
		UF[UFUnit].power.hassteps = true
	end

	-- Position steps
	local stepXMod = (UFUnit == PLAYER_ID) and -1 or 1
	local stepAnchor = (UFUnit == PLAYER_ID) and "BOTTOMRIGHT" or "BOTTOMLEFT"
	for i = 1, 3 do
		UF[UFUnit].power.warning[i]:Hide()
		local xStepPos
		if UF[UFUnit].power.bar.reverse then
			xStepPos = floor(stepXMod * (PowerWidth[layoutSize][UFUnit] - (PowerWidth[layoutSize][UFUnit] * (1 - UF[UFUnit].power.steppoints[i])))) + PowerStepOffsets[layoutSize][UFUnit][i]
		else
			xStepPos = floor(stepXMod * (PowerWidth[layoutSize][UFUnit] - (PowerWidth[layoutSize][UFUnit] * UF[UFUnit].power.steppoints[i]))) + PowerStepOffsets[layoutSize][UFUnit][i]
		end
		if UF[UFUnit].power.sinrogue and i == 1 then
			xStepPos = xStepPos - (layoutSize == 1 and 3 or -17)	-- Position 0.55 Sin Rogue step
		end
		SetFramePosition(UF[UFUnit].power.steps[i], "MEDIUM", UF[UFUnit].power.surround:GetFrameLevel() + 2, 16, 16, {stepAnchor, UF[UFUnit].power.surround, stepAnchor, xStepPos, 15 - PowerHeight[layoutSize][UFUnit]})
		SetFramePosition(UF[UFUnit].power.warning[i], "MEDIUM", UF[UFUnit].power.surround:GetFrameLevel() + 2, 16, 16, {stepAnchor, UF[UFUnit].power.surround, stepAnchor, xStepPos, 15 - PowerHeight[layoutSize][UFUnit]})
		if UF[UFUnit].power.hassteps and (UF[UFUnit].power.steppoints[i] > 0) then
			UF[UFUnit].power.steps[i]:Show()
		else
			UF[UFUnit].power.steps[i]:Hide()
		end
	end
	
	-- AngleStatusBar:SetValue(UF[UFUnit].power.bar, 1, true)
	UnitFrames:UpdateUnitPower(UFUnit, true)
end

-- Toggle Power
function UnitFrames:ToggleUnitPower(UnitID)
	local Unit, UFUnit = PlayerOrVehicleIDs(UnitID)
	if not UF[UFUnit] then return end
	if not UF[UFUnit].power then return end
	
	if UnitExists(Unit) and UnitPowerMax(Unit) > 0 then
		if not UF[UFUnit].power.enabled then
			UF[UFUnit].power.enabled = true
			UF[UFUnit].power.bar:Show()
			UF[UFUnit].power.fullval:Show()
		end
	else
		UF[UFUnit].power.enabled = false
		UF[UFUnit].power.bar:Hide()
		for i = 1, 2 do
			UF[UFUnit].power.steps[i]:Hide()
			UF[UFUnit].power.warning[i]:Hide()
		end
		UF[UFUnit].power.fullval:Hide()
	end
end

-- Unit Info
function UnitFrames:UpdateUnitInfo(UnitID)
	if ((UnitID == PLAYER_ID) or (UnitID == PET_ID)) then return end
	if not(UF[UnitID]) then return end
	if not(UnitExists(UnitID)) then return end
	
	-- Name
	local uName = self:AbrvName(UnitName(UnitID), UnitID)

	-- Class
	_, UF[UnitID].class = UnitClass(UnitID)
	
	-- Level
	local uLevel
	if(UnitIsWildBattlePet(UnitID) or UnitIsBattlePetCompanion(UnitID)) then
		uLevel = UnitBattlePetLevel(UnitID)
	else
		uLevel = UnitLevel(UnitID)
	end
	if uLevel <= 0 then
		uLevel = 99
	end
	local uLevelColor = GetQuestDifficultyColor(uLevel)
	
	-- Set Texts
	local strHealth = ""
	local uColorStr = "ffffff"
	if UnitIsPlayer(UnitID) and db.overlay.classColorNames then uColorStr = nibRealUI:ColorTableToStr(nibRealUI:GetClassColor(UF[UnitID].class)) end
	if uLevel == 99 then uLevel = "??" end
	if ((UnitID == FOCUS_ID) or (UnitID == FOCUSTARGET_ID) or (UnitID == TARGETTARGET_ID)) then
		strHealth = strform("|cff%s%s|r", uColorStr, uName)
	elseif (UnitID == TARGET_ID) then
		strHealth = strform("|cff%02x%02x%02x%s|r |cff%s%s|r", uLevelColor.r * 255, uLevelColor.g * 255, uLevelColor.b * 255, uLevel, uColorStr, uName)
	end
	UF[UnitID].healthtext.text:SetText(strHealth)

	-- Classification
	local uClassificationColor = db.overlay.colors.status[UnitClassification(UnitID)] or {(nibRealUI.media.background[1] * 1.2) + 0.06, (nibRealUI.media.background[2] * 1.2) + 0.06, (nibRealUI.media.background[3] * 1.2) + 0.06}
	UF[UnitID].healthbox[2].bar:SetVertexColor(unpack(uClassificationColor))
end

-- Unit PvP Status
function UnitFrames:UpdateUnitPvPStatus(UnitID)
	local Unit, UFUnit = PlayerOrVehicleIDs(UnitID)
	if not UF[UFUnit] then return end
	if not ValidHealthUnit[UnitID] then return end
	
	if UnitIsPVP(Unit) then
		UF[UFUnit].healthbox[1].bar:Show()
		if UnitIsFriend(Unit, PLAYER_ID) then
			UF[UFUnit].healthbox[1].bar:SetVertexColor(unpack(db.overlay.colors.status.pvpFriendly))
		else
			UF[UFUnit].healthbox[1].bar:SetVertexColor(unpack(db.overlay.colors.status.pvpEnemy))
		end
	else
		UF[UFUnit].healthbox[1].bar:Hide()
	end
end

-- End Box
function UnitFrames:UpdateEndBox(UnitID)
	local cColor, uClass
	UF[UnitID].endbox.bar:Show()
	if UnitIsPlayer(UnitID) then
		_, uClass = UnitClass(UnitID)
		cColor = nibRealUI:GetClassColor(uClass)
	else
		if ( not UnitPlayerControlled(UnitID) and UnitIsTapped(UnitID) and not UnitIsTappedByPlayer(UnitID) and not UnitIsTappedByAllThreatList(UnitID) ) then
			cColor = db.overlay.colors.status.tapped
		elseif UnitIsEnemy("player", UnitID) then
			cColor =db.overlay.colors.status.hostile
		elseif UnitCanAttack("player", UnitID) then
			cColor = db.overlay.colors.status.neutral
		else
			cColor = db.overlay.colors.status.friendly
		end
	end
	UF[UnitID].endbox.bar:SetVertexColor(cColor[1], cColor[2], cColor[3], 1)
end

-- PvP Timer
local PvPTimerFrame = CreateFrame("Frame")
PvPTimerFrame:Hide()
PvPTimerFrame.e = 0
PvPTimerFrame.i = 1
PvPTimerFrame.ticks = 0		-- Wait until one update passes to see if we're now under 301sec PvP timer
PvPTimerFrame.ms = 0
PvPTimerFrame.ts = ""
PvPTimerFrame:SetScript("OnUpdate", function(s, e)
	s.e = s.e + e
	if s.e >= s.i then
		s.ms = GetPVPTimer()
		if s.ticks >= 1 and s.ms < 301000 then
			s.ts = ConvertSecondstoTime(floor(s.ms / 1000))
			UF[PLAYER_ID].healthtext.text:SetText(s.ts)
		elseif s.ticks >= 1 then
			s.e = 0
			s.ticks = 0
			UF[PLAYER_ID].healthtext.text:SetText("")
			s:Hide()
		else
			s.ticks = s.ticks + 1
		end
		s.e = 0
	end
end)
function UnitFrames:UpdatePvPTimer()
	local ms = UnitIsPVP(PLAYER_ID) and GetPVPTimer() or 0
	if ms > 0 then
		PvPTimerFrame:Show()
	else
		PvPTimerFrame:Hide()
		PvPTimerFrame.ticks = 0
		UF[PLAYER_ID].healthtext.text:SetText("")
	end
end

-- Status
function UnitFrames:UpdateStatus(UnitID)
	if not(UF[UnitID]) then return end
	
	local S1, S2
	local S1Status, S2Status

	-- 2
	if UnitIsAFK(UnitID) then
		S2Status = db.overlay.colors.status.afk
		S2 = true
	elseif not(UnitIsConnected(UnitID)) then
		S2Status = db.overlay.colors.status.offline
		S2 = true
	elseif (UnitID == PLAYER_ID) and UnitIsGroupLeader(UnitID) then
		S2Status = db.overlay.colors.status.leader
		S2 = true
	else
		S2 = false
	end
	if S2 then
		UF[UnitID].statusbox[2]:Show()
		UF[UnitID].statusbox[2].bar:SetVertexColor(S2Status[1], S2Status[2], S2Status[3], 1)
	else
		UF[UnitID].statusbox[2]:Hide()
	end
	
	-- 1
	if UnitAffectingCombat(UnitID) then
		S1Status = db.overlay.colors.status.combat
		S1 = true
	elseif IsResting(UnitID) then
		S1Status = db.overlay.colors.status.resting
		S1 = true
	else
		S1 = false
	end
	if S2 and not(S1) then
		UF[UnitID].statusbox[1]:Show()
		UF[UnitID].statusbox[1].bar:SetVertexColor(0, 0, 0, 0)
	elseif S1 then
		UF[UnitID].statusbox[1]:Show()
		UF[UnitID].statusbox[1].bar:SetVertexColor(S1Status[1], S1Status[2], S1Status[3], 1)
	else
		UF[UnitID].statusbox[1]:Hide()
	end
	
	-- Pvp
	if UnitID == PLAYER_ID then
		self:UpdatePvPTimer()
	end
end

-- In Between
local function InBetween_OnUpdate(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed >= self.interval then
		local Now = GetTime()
		-- Check current status durations
		if self.wound and (self.woundend <= Now) then
			self.wound = false
		end
		if self.heal and (self.healend <= Now) then
			self.heal = false
		end
		
		-- Apply current status
		if self.heal then
			if not self.healset then self.bg:SetVertexColor(db.overlay.colors.status.heal[1], db.overlay.colors.status.heal[2], db.overlay.colors.status.heal[3]) end
			self.healset = true
			self.woundset = false
			self.inchealset = false
		elseif self.wound then
			if not self.woundset then self.bg:SetVertexColor(db.overlay.colors.status.damage[1], db.overlay.colors.status.damage[2], db.overlay.colors.status.damage[3]) end
			self.woundset = true
			self.healset = false
			self.inchealset = false
		elseif self.incheal then
			if not self.inchealset then self.bg:SetVertexColor(db.overlay.colors.status.incomingHeal[1], db.overlay.colors.status.incomingHeal[2], db.overlay.colors.status.incomingHeal[3]) end
			self.inchealset = true
			self.healset = false
			self.woundset = false
		else
			if self.inchealset or self.healset or self.woundset then self.bg:SetVertexColor(1, 1, 1, 0) end
			self.healset = false
			self.woundset = false
			self.inchealset = false
		end
		
		self.elapsed = 0
	end
end

function UnitFrames:SetInBetween(UnitID, Event)
	if Event == "WOUND" then
		UF[UnitID].inbetween.wound = true
		UF[UnitID].inbetween.woundend = GetTime() + 0.5
	elseif Event == "HEAL" then
		UF[UnitID].inbetween.heal = true
		UF[UnitID].inbetween.healend = GetTime() + 0.5
	elseif Event == "INCHEAL" then
		UF[UnitID].inbetween.incheal = true
	elseif Event == "NOINCHEAL" then
		UF[UnitID].inbetween.incheal = false
	elseif Event == "NONE" then
		UF[UnitID].inbetween.wound = false
		UF[UnitID].inbetween.heal = false
		UF[UnitID].inbetween.incheal = false
	end
end

-- End Icons
function UnitFrames:UpdateEndIcons()
	for k,v in pairs(UF) do
		if UF[k].endicon then
			if UnitHasIncomingResurrection(k) then
				UF[k].endicon.bg:SetTexture([[Interface\RaidFrame\Raid-Icon-Rez]])
				UF[k].endicon.bg:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				UF[k].endicon:Show()
			else
				local RIUnit = ((k == PLAYER_ID) and UnitHasVehicleUI(PLAYER_ID)) and VEHICLE_ID or k
				local index = GetRaidTargetIndex(RIUnit)
				if index then
					UF[k].endicon.bg:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
					SetRaidTargetIconTexture(UF[k].endicon.bg, index)
					UF[k].endicon:Show()
				else
					UF[k].endicon:Hide()
				end
			end
		end
	end
end

-- Refresh all units power and health
function UnitFrames:RefreshUnits()
	self:UpdateSpec()
	SetPlayerVehicleFlag()
	for k,v in pairs(UF) do
		if UnitExists(k) then
			if UF[k].health then
				self:UpdateUnitHealthBarInfo(k, true)
				self:UpdateUnitHealth(k)
			end
			if UF[k].absorbBar then
				self:UpdateUnitAbsorb(k)
			end
			if UF[k].power then
				self:ToggleUnitPower(k)
				self:UpdateUnitPowerBarInfo(k, true)
			end
			self:UpdateEndBox(k)
			self:UpdateStatus(k)
			self:UpdateUnitPvPStatus(k)
			self:UpdateUnitInfo(k)
		end
	end
	self:UpdateEndIcons()
end

-- Font Update
function UnitFrames:UpdateFonts()
	local font1 = nibRealUI:Font(false, "small")
	local font2 = nibRealUI:Font()
	for k, fontString in pairs(FontStringsSmall) do
		fontString:SetFont(unpack(font1))
	end
	for k, fontString in pairs(FontStringsRegular) do
		fontString:SetFont(unpack(font2))
	end

	-- Y positions
	for k, tbl in pairs(FontStringsY) do
		local point, parent, rPoint, x, y = tbl[1]:GetPoint()
		if ndb.settings.fontStyle < tbl[2] then y = tbl[3] else y = tbl[3] - 1 end
		tbl[1]:ClearAllPoints()
		tbl[1]:SetPoint(point, parent, rPoint, x, y)
	end
end

-- Texture Update
local USTCExtras = {FOCUS_ID, FOCUSTARGET_ID, PET_ID, TARGETTARGET_ID}
function UnitFrames:UpdateTextures()
	RangeColors = {
		[5] = nibRealUI.media.colors.green,
		[30] = nibRealUI.media.colors.yellow,
		[35] = nibRealUI.media.colors.amber,
		[40] = nibRealUI.media.colors.orange,
		[100] = nibRealUI.media.colors.red,
	}

	---- Player ----
	-- Health
	UF[PLAYER_ID].health.background.bg:SetVertexColor(unpack(nibRealUI.media.background))
	AngleStatusBar:SetBarColor(UF[PLAYER_ID].absorbBar, {1, 1, 1, db.overlay.bar.opacity.absorb})
	for i = 1, 2 do
		UF[PLAYER_ID].health.steps[i].bg:SetVertexColor(1, 1, 1, db.overlay.bar.opacity.steps)
	end
	
	-- Power
	UF[PLAYER_ID].power.background.bg:SetVertexColor(unpack(nibRealUI.media.background))
	for i = 1, 3 do
		UF[PLAYER_ID].power.steps[i].bg:SetVertexColor(1, 1, 1, db.overlay.bar.opacity.steps)
	end
	
	-- End Box
	UF[PLAYER_ID].endbox.background:SetVertexColor(unpack(nibRealUI.media.background))
	
	-- Status Boxes
	for i = 1, 2 do
		UF[PLAYER_ID].statusbox[i].background:SetVertexColor(unpack(nibRealUI.media.background))
	end

	-- Health Boxes
	UF[PLAYER_ID].healthbox[1].background:SetVertexColor((nibRealUI.media.background[1] * 1.2) + 0.1, (nibRealUI.media.background[2] * 1.2) + 0.1, (nibRealUI.media.background[3] * 1.2) + 0.1, 1)

	-- Warning
	for i = 1, 2 do
		UF[PLAYER_ID].health.warning[i].bg:SetVertexColor((nibRealUI.media.background[1] * 1.2) + 0.06, (nibRealUI.media.background[2] * 1.2) + 0.06, (nibRealUI.media.background[3] * 1.2) + 0.06, 1)
	end
	for i = 1, 3 do
		UF[PLAYER_ID].power.warning[i].bg:SetVertexColor((nibRealUI.media.background[1] * 1.2) + 0.06, (nibRealUI.media.background[2] * 1.2) + 0.06, (nibRealUI.media.background[3] * 1.2) + 0.06, 1)
	end
	
	---- Target ----
	-- Health
	UF[TARGET_ID].health.background.bg:SetVertexColor(unpack(nibRealUI.media.background))
	AngleStatusBar:SetBarColor(UF[TARGET_ID].absorbBar, {1, 1, 1, db.overlay.bar.opacity.absorb})
	for i = 1, 2 do
		UF[TARGET_ID].health.steps[i].bg:SetVertexColor(1, 1, 1, db.overlay.bar.opacity.steps)
	end
	
	-- Power
	UF[TARGET_ID].power.background.bg:SetVertexColor(unpack(nibRealUI.media.background))
	for i = 1, 3 do
		UF[TARGET_ID].power.steps[i].bg:SetVertexColor(1, 1, 1, db.overlay.bar.opacity.steps)
	end
	
	-- End Box
	UF[TARGET_ID].endbox.background:SetVertexColor(unpack(nibRealUI.media.background))
	
	-- Status Boxes
	for i = 1, 2 do
		UF[TARGET_ID].statusbox[i].background:SetVertexColor(unpack(nibRealUI.media.background))
	end

	-- Health Boxes
	for i = 1, 2 do
		UF[TARGET_ID].healthbox[i].background:SetVertexColor((nibRealUI.media.background[1] * 1.2) + 0.1, (nibRealUI.media.background[2] * 1.2) + 0.1, (nibRealUI.media.background[3] * 1.2) + 0.1, 1)
	end

	-- Warning
	for i = 1, 2 do
		UF[TARGET_ID].health.warning[i].bg:SetVertexColor((nibRealUI.media.background[1] * 1.2) + 0.06, (nibRealUI.media.background[2] * 1.2) + 0.06, (nibRealUI.media.background[3] * 1.2) + 0.06, 1)
	end
	for i = 1, 2 do
		UF[TARGET_ID].power.warning[i].bg:SetVertexColor((nibRealUI.media.background[1] * 1.2) + 0.06, (nibRealUI.media.background[2] * 1.2) + 0.06, (nibRealUI.media.background[3] * 1.2) + 0.06, 1)
	end

	---- Extras ----
	for k,v in pairs(USTCExtras) do
		UF[v].health.background.bg:SetVertexColor(unpack(nibRealUI.media.background))
		UF[v].endbox.background:SetVertexColor(unpack(nibRealUI.media.background))
		
		-- Status Boxes
		for i = 1, 2 do
			UF[v].statusbox[i].background:SetVertexColor(unpack(nibRealUI.media.background))
		end

		-- Health Boxes
		for i = 1, 2 do
			if UF[v].healthbox[i] then
				UF[v].healthbox[i].background:SetVertexColor((nibRealUI.media.background[1] * 1.2) + 0.1, (nibRealUI.media.background[2] * 1.2) + 0.1, (nibRealUI.media.background[3] * 1.2) + 0.1, 1)
			end
		end
	end
end

---- FRAME CREATION ----
local function CreateStatusBox(parent)
	local NewEndBox
	NewEndBox = CreateFrame("Frame", nil, parent)
	NewEndBox:SetParent(parent)
	NewEndBox.surround = NewEndBox:CreateTexture(nil, "ARTWORK")
	NewEndBox.surround:SetAllPoints()
	NewEndBox.background = NewEndBox:CreateTexture(nil, "BACKGROUND")
	NewEndBox.background:SetAllPoints()
	NewEndBox.bar = NewEndBox:CreateTexture(nil, "OVERLAY")
	NewEndBox.bar:SetAllPoints()
	return NewEndBox
end

local function CreateArtFrame(parent)
	local NewArtFrame
	NewArtFrame = CreateFrame("Frame", nil, parent)
	NewArtFrame:SetParent(parent)
	NewArtFrame.bg = NewArtFrame:CreateTexture(nil, "ARTWORK")
	NewArtFrame.bg:SetAllPoints()
	return NewArtFrame
end

local function CreateTextFrame(parent, position1, position2, size2)
	local NewTextFrame = CreateFrame("Frame", nil, parent)

	NewTextFrame.text = NewTextFrame:CreateFontString(nil, "ARTWORK")
	if size2 then 
		tinsert(FontStringsRegular, NewTextFrame.text)
	else
		tinsert(FontStringsSmall, NewTextFrame.text)
	end
	
	SetTextPosition(NewTextFrame, position1, position2)
	
	return NewTextFrame
end

function UnitFrames:CreateFrames()
	local SimpleBackdrop = {
		bgFile = nibRealUI.media.textures.plain, 
		edgeFile = nibRealUI.media.textures.plain, 
		tile = false, tileSize = 0, edgeSize = 1, 
		insets = { left = 1, right = 1, top = 1, bottom = 1	}
	}
	
	----------------
	---- Player ----
	----------------
	local Parent = _G[ParentFrames[PLAYER_ID]] or UIParent
	UF[PLAYER_ID] = CreateFrame("Frame", ParentFrames[PLAYER_ID].."_Overlay", Parent)
	SetFramePosition(UF[PLAYER_ID], "MEDIUM", 0, F1_OverlayWidth[layoutSize], F1_OverlayHeight[layoutSize], {"BOTTOMRIGHT", Parent, "BOTTOMRIGHT", 0, -5})
	
	-- Health
	UF[PLAYER_ID].health = CreateFrame("Frame", nil, UF[PLAYER_ID])
	UF[PLAYER_ID].health:SetParent(UF[PLAYER_ID])
	SetFramePosition(UF[PLAYER_ID].health, "MEDIUM", UF[PLAYER_ID]:GetFrameLevel(), F1_HealthTextureWidth[layoutSize], 16, {"BOTTOMRIGHT", UF[PLAYER_ID], "BOTTOMRIGHT", -4, 16})
	UF[PLAYER_ID].health.colorID = ""
	UF[PLAYER_ID].health.position = -1
	UF[PLAYER_ID].health.elapsed = 0
	UF[PLAYER_ID].health.interval = 0.1
	UF[PLAYER_ID].health:SetScript("OnUpdate", function(self, elapsed)
		UnitFrames:Health_OnUpdate(self, elapsed, PLAYER_ID)
	end)
	
		-- Surround
		UF[PLAYER_ID].health.surround = CreateArtFrame(UF[PLAYER_ID].health)
		SetFramePosition(UF[PLAYER_ID].health.surround, "MEDIUM", UF[PLAYER_ID].health:GetFrameLevel() + 2, F1_HealthTextureWidth[layoutSize], 16, {"BOTTOMRIGHT", UF[PLAYER_ID].health, "BOTTOMRIGHT", 0, 0})
		UF[PLAYER_ID].health.surround.bg:SetTexture(Textures[layoutSize].f1.health.surround)
		
		-- Background
		UF[PLAYER_ID].health.background = CreateArtFrame(UF[PLAYER_ID].health)
		SetFramePosition(UF[PLAYER_ID].health.background, "MEDIUM", UF[PLAYER_ID].health:GetFrameLevel(), F1_HealthTextureWidth[layoutSize], 16, {"BOTTOMRIGHT", UF[PLAYER_ID].health, "BOTTOMRIGHT", layoutSize == 1 and 0 or -1, 0})
		UF[PLAYER_ID].health.background.bg:SetTexture(Textures[layoutSize].f1.health.bar)
		
		-- Bar
		UF[PLAYER_ID].health.bar = AngleStatusBar:NewBar(UF[PLAYER_ID].health.background, layoutSize == 1 and -2 or -1, -(15 - HealthHeight[layoutSize][PLAYER_ID]), HealthWidth[layoutSize][PLAYER_ID], HealthHeight[layoutSize][PLAYER_ID], "LEFT", "LEFT", "LEFT", true)
		
		-- HealthBar Text
		UF[PLAYER_ID].healthtext = CreateTextFrame(UF[PLAYER_ID].health, "BOTTOM", "LEFT", true)
		SetFramePosition(UF[PLAYER_ID].healthtext, "MEDIUM", UF[PLAYER_ID].health:GetFrameLevel(), 12, 12, {"BOTTOMLEFT", UF[PLAYER_ID].health, "BOTTOMLEFT", 46, 15})

		-- Health Text
		UF[PLAYER_ID].health.fullval = CreateTextFrame(UF[PLAYER_ID].health, "BOTTOM", "RIGHT", true)
		SetFramePosition(UF[PLAYER_ID].health.fullval, "MEDIUM", UF[PLAYER_ID].health:GetFrameLevel(), 12, 12, {"BOTTOMRIGHT", UF[PLAYER_ID].health, "BOTTOMRIGHT", 2, F1_HealthTextVertical[layoutSize]})
		
		-- Steps
		UF[PLAYER_ID].health.steps = {}
		for i = 1, 2 do
			UF[PLAYER_ID].health.steps[i] = CreateArtFrame(UF[PLAYER_ID].health.surround)
			SetFramePosition(UF[PLAYER_ID].health.steps[i], "MEDIUM", UF[PLAYER_ID].health.surround:GetFrameLevel() + 3, 16, 16, {"TOPRIGHT", UF[PLAYER_ID].health.surround, "TOPRIGHT", 0, -2})
			UF[PLAYER_ID].health.steps[i].bg:SetTexture(Textures[layoutSize].f1.health.step)
			UF[PLAYER_ID].health.steps[i]:Hide()
		end

		-- Warning
		UF[PLAYER_ID].health.warning = {}
		for i = 1, 2 do
			UF[PLAYER_ID].health.warning[i] = CreateArtFrame(UF[PLAYER_ID].health.surround)
			SetFramePosition(UF[PLAYER_ID].health.warning[i], "MEDIUM", UF[PLAYER_ID].health.surround:GetFrameLevel() + 4, 16, 16, {"BOTTOMLEFT", UF[PLAYER_ID].health.surround, "BOTTOMLEFT", 0, 2})
			UF[PLAYER_ID].health.warning[i].bg:SetTexture(Textures[layoutSize].f1.health.warning)
			UF[PLAYER_ID].health.warning[i]:Hide()
		end

	-- Absorb Bar
	UF[PLAYER_ID].absorbBar = AngleStatusBar:NewBar(UF[PLAYER_ID].health.background, -2, -4, HealthWidth[layoutSize][PLAYER_ID], HealthHeight[layoutSize][PLAYER_ID], "LEFT", "LEFT", "LEFT", true)
	UF[PLAYER_ID].absorbBar:SetFrameLevel(UF[PLAYER_ID].health.surround:GetFrameLevel() + 2)
	UF[PLAYER_ID].absorbBar:SetPoint("TOPRIGHT", UF[PLAYER_ID].health.bar, "TOPLEFT", -1, 0)
	-- UF[PLAYER_ID].absorbBar:SetPoint("CENTER", UIParent, "CENTER")

	-- Power
	UF[PLAYER_ID].power = CreateFrame("Frame", nil, UF[PLAYER_ID])
	UF[PLAYER_ID].power:SetParent(UF[PLAYER_ID])
	SetFramePosition(UF[PLAYER_ID].power, "MEDIUM", UF[PLAYER_ID]:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[PLAYER_ID], "BOTTOMRIGHT", -9, -3})
	UF[PLAYER_ID].power.color = ""
	UF[PLAYER_ID].power.position = -1
	UF[PLAYER_ID].power.steppoints = {}
	UF[PLAYER_ID].power.elapsed = 0
	UF[PLAYER_ID].power.interval = 0.2
	UF[PLAYER_ID].power.playerUpdateCnt = 0
	UF[PLAYER_ID].power:SetScript("OnUpdate", function(self, elapsed)
		UnitFrames:Power_OnUpdate(self, elapsed, PLAYER_ID)
	end)
	
		-- Surround
		UF[PLAYER_ID].power.surround = CreateArtFrame(UF[PLAYER_ID].power)
		SetFramePosition(UF[PLAYER_ID].power.surround, "MEDIUM", UF[PLAYER_ID].power:GetFrameLevel() + 2, 256, 16, {"BOTTOMRIGHT", UF[PLAYER_ID].power, "BOTTOMRIGHT", 0, 0})
		UF[PLAYER_ID].power.surround.bg:SetTexture(Textures[layoutSize].f1.power.surround)
		
		-- Background
		UF[PLAYER_ID].power.background = CreateArtFrame(UF[PLAYER_ID].power)
		SetFramePosition(UF[PLAYER_ID].power.background, "MEDIUM", UF[PLAYER_ID].power:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[PLAYER_ID].power, "BOTTOMRIGHT", 0, 0})
		UF[PLAYER_ID].power.background.bg:SetTexture(Textures[layoutSize].f1.power.bar)
		
		-- Bar
		UF[PLAYER_ID].power.bar = AngleStatusBar:NewBar(UF[PLAYER_ID].power.background, PowerXOffset[layoutSize], -1, PowerWidth[layoutSize][PLAYER_ID], PowerHeight[layoutSize][PLAYER_ID], "RIGHT", "RIGHT", "LEFT", true)
		
		-- Power Text
		UF[PLAYER_ID].power.fullval = CreateTextFrame(UF[PLAYER_ID].power, "TOP", "RIGHT", true)
		SetFramePosition(UF[PLAYER_ID].power.fullval, "MEDIUM", UF[PLAYER_ID].power:GetFrameLevel(), 12, 12, {"TOPRIGHT", UF[PLAYER_ID].power, "BOTTOMRIGHT", 2, F1_PowerTextVertical[layoutSize]})
		tinsert(FontStringsY, {UF[PLAYER_ID].power.fullval, 2, F1_PowerTextVertical[layoutSize]})

		-- Steps
		UF[PLAYER_ID].power.steps = {}
		for i = 1, 3 do
			UF[PLAYER_ID].power.steps[i] = CreateArtFrame(UF[PLAYER_ID].power.surround)
			SetFramePosition(UF[PLAYER_ID].power.steps[i], "MEDIUM", UF[PLAYER_ID].power.surround:GetFrameLevel() + 2, 16, 16, {"BOTTOMRIGHT", UF[PLAYER_ID].power.surround, "BOTTOMRIGHT", 0, 9})
			UF[PLAYER_ID].power.steps[i].bg:SetTexture(Textures[layoutSize].f1.power.step)
			UF[PLAYER_ID].power.steps[i]:Hide()
		end

		-- Warning
		UF[PLAYER_ID].power.warning = {}
		for i = 1, 3 do
			UF[PLAYER_ID].power.warning[i] = CreateArtFrame(UF[PLAYER_ID].power.surround)
			SetFramePosition(UF[PLAYER_ID].power.warning[i], "MEDIUM", UF[PLAYER_ID].power.surround:GetFrameLevel() + 3, 16, 16, {"BOTTOMLEFT", UF[PLAYER_ID].power.surround, "BOTTOMLEFT", 0, 2})
			UF[PLAYER_ID].power.warning[i].bg:SetTexture(Textures[layoutSize].f1.power.warning)
			UF[PLAYER_ID].power.warning[i]:Hide()
		end

		-- Secondary Power
		UF[PLAYER_ID].power2 = CreateStatusBox(UF[PLAYER_ID].power.surround)
		SetFramePosition(UF[PLAYER_ID].power2, "MEDIUM", UF[PLAYER_ID].power.surround:GetFrameLevel() + 3, 16, 16, {"BOTTOMRIGHT", UF[PLAYER_ID].power.surround, "BOTTOMRIGHT", -20, 9})
		UF[PLAYER_ID].power2.surround:SetTexture(Textures[layoutSize].f1.powerbox.surround)
		UF[PLAYER_ID].power2.background:SetTexture(Textures[layoutSize].f1.powerbox.bar)
		UF[PLAYER_ID].power2.bar:SetTexture(Textures[layoutSize].f1.powerbox.bar)
		UF[PLAYER_ID].power2.bar:SetVertexColor(unpack(db.overlay.colors.power["MANA"]))
		-- UF[PLAYER_ID].power2.:Hide()
	
	-- In Between
	UF[PLAYER_ID].inbetween = CreateArtFrame(UF[PLAYER_ID])
	SetFramePosition(UF[PLAYER_ID].inbetween, "MEDIUM", UF[PLAYER_ID]:GetFrameLevel(), PowerWidth[layoutSize][PLAYER_ID] + 2, 1, {"RIGHT", UF[PLAYER_ID], "RIGHT", 0, -1})
	UF[PLAYER_ID].inbetween.bg:SetTexture(nibRealUI.media.textures.plain)
	UF[PLAYER_ID].inbetween.bg:SetVertexColor(1, 1, 1, 0)
	UF[PLAYER_ID].inbetween.wound = false
	UF[PLAYER_ID].inbetween.woundend = 0
	UF[PLAYER_ID].inbetween.heal = false
	UF[PLAYER_ID].inbetween.healend = 0
	UF[PLAYER_ID].inbetween.incheal = false
	UF[PLAYER_ID].inbetween.elapsed = 0
	UF[PLAYER_ID].inbetween.interval = 0.1
	UF[PLAYER_ID].inbetween:SetScript("OnUpdate", function(self, elapsed)
		InBetween_OnUpdate(self, elapsed)
	end)
	
	-- End Box
	UF[PLAYER_ID].endbox = CreateStatusBox(UF[PLAYER_ID])
	SetFramePosition(UF[PLAYER_ID].endbox, "MEDIUM", UF[PLAYER_ID]:GetFrameLevel(), 32, 32, {"LEFT", UF[PLAYER_ID], "RIGHT", -14 + F1_EndBoxXOffset[layoutSize], F1_EndBoxYOffset[layoutSize]})
	UF[PLAYER_ID].endbox.surround:SetTexture(Textures[layoutSize].f1.endbox.surround)
	UF[PLAYER_ID].endbox.background:SetTexture(Textures[layoutSize].f1.endbox.bar)
	UF[PLAYER_ID].endbox.bar:SetTexture(Textures[layoutSize].f1.endbox.bar)
	UF[PLAYER_ID].endbox.bar:SetVertexColor(0, 0, 0, 0)
	
	-- Status Boxes
	UF[PLAYER_ID].statusbox = {}
	for i = 1, 2 do
		UF[PLAYER_ID].statusbox[i] = CreateStatusBox(UF[PLAYER_ID].power)
		SetFramePosition(UF[PLAYER_ID].statusbox[i], "MEDIUM", UF[PLAYER_ID].power:GetFrameLevel(), 16, 16, {"BOTTOMRIGHT", UF[PLAYER_ID].power, "BOTTOMLEFT", -((i-1)*5+(i)) + (256 - PowerWidth[layoutSize][PLAYER_ID] - 1) - 1, 0})
		UF[PLAYER_ID].statusbox[i].surround:SetTexture(Textures[layoutSize].f1.statusbox.surround)
		UF[PLAYER_ID].statusbox[i].background:SetTexture(Textures[layoutSize].f1.statusbox.bar)
		UF[PLAYER_ID].statusbox[i].bar:SetTexture(Textures[layoutSize].f1.statusbox.bar)
		UF[PLAYER_ID].statusbox[i].bar:SetVertexColor(0, 0, 0, 0)
	end
	
	-- Health Boxes
	UF[PLAYER_ID].healthbox = {}
	UF[PLAYER_ID].healthbox[1] = CreateStatusBox(UF[PLAYER_ID].health)
	SetFramePosition(UF[PLAYER_ID].healthbox[1], "MEDIUM", UF[PLAYER_ID].health.surround:GetFrameLevel() + 3, 16, 16, {"TOPRIGHT", UF[PLAYER_ID].health, "TOPRIGHT", -8, -(15 - HealthHeight[layoutSize][PLAYER_ID])})
	UF[PLAYER_ID].healthbox[1].surround:SetTexture(Textures[layoutSize].f1.healthbox.surround)
	UF[PLAYER_ID].healthbox[1].background:SetTexture(Textures[layoutSize].f1.healthbox.bar)
	UF[PLAYER_ID].healthbox[1].bar:SetTexture(Textures[layoutSize].f1.healthbox.bar)
	
	-- Power Box
	UF[PLAYER_ID].powerbox = CreateStatusBox(UF[PLAYER_ID].power)
	SetFramePosition(UF[PLAYER_ID].powerbox, "MEDIUM", UF[PLAYER_ID].power:GetFrameLevel() + 3, 16, 16, {"BOTTOMRIGHT", UF[PLAYER_ID].power, "BOTTOMRIGHT", 0, 9})
	UF[PLAYER_ID].powerbox.surround:SetTexture(Textures[layoutSize].f1.powerbox.surround)
	UF[PLAYER_ID].powerbox.background:SetTexture(Textures[layoutSize].f1.powerbox.bar)
	UF[PLAYER_ID].powerbox.bar:SetTexture(Textures[layoutSize].f1.powerbox.bar)
	UF[PLAYER_ID].powerbox.bar:SetVertexColor(0, 0, 0, 0)
	UF[PLAYER_ID].powerbox:Hide()
	
	-- End Icon
	UF[PLAYER_ID].endicon = CreateArtFrame(UF[PLAYER_ID])
	UF[PLAYER_ID].endicon:Hide()
	SetFramePosition(UF[PLAYER_ID].endicon, "MEDIUM", UF[PLAYER_ID]:GetFrameLevel(), 24, 24, {"BOTTOMRIGHT", UF[PLAYER_ID], "TOPLEFT", (256 - HealthWidth[layoutSize][PLAYER_ID]) + 22, (layoutSize == 1) and 16 or 20})
	UF[PLAYER_ID].endicon.bg:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])

	-- Stat Fields
	UF[PLAYER_ID].stat1 = CreateTextFrame(UF[PLAYER_ID].endbox, "BOTTOM", "LEFT")
	RealUIPlayerStat1 = UF[PLAYER_ID].stat1
	SetFramePosition(UF[PLAYER_ID].stat1, "MEDIUM", UF[PLAYER_ID]:GetFrameLevel(), 12, 12, {"BOTTOMLEFT", UF[PLAYER_ID].endbox, "BOTTOMRIGHT", layoutSize == 1 and 0 or 2, 18})
	tinsert(FontStringsY, {UF[PLAYER_ID].stat1, 3, 18})
	
	UF[PLAYER_ID].stat2 = CreateTextFrame(UF[PLAYER_ID].endbox, "TOP", "LEFT")
	RealUIPlayerStat2 = UF[PLAYER_ID].stat2
	SetFramePosition(UF[PLAYER_ID].stat2, "MEDIUM", UF[PLAYER_ID]:GetFrameLevel(), 12, 12, {"BOTTOMLEFT", UF[PLAYER_ID].endbox, "BOTTOMRIGHT", layoutSize == 1 and 0 or 2, 1})
	
	UF[PLAYER_ID].stat1.icon = UF[PLAYER_ID].stat1:CreateTexture(nil, "ARTWORK")
	UF[PLAYER_ID].stat1.icon:SetSize(16, 16)
	UF[PLAYER_ID].stat1.icon:SetPoint("BOTTOMRIGHT", UF[PLAYER_ID].stat1, "BOTTOMLEFT", 3, 0)
	UF[PLAYER_ID].stat1.icon:SetTexture(nibRealUI.media.icons.DoubleArrow)

	UF[PLAYER_ID].stat2.icon = UF[PLAYER_ID].stat2:CreateTexture(nil, "ARTWORK")
	UF[PLAYER_ID].stat2.icon:SetSize(16, 16)
	UF[PLAYER_ID].stat2.icon:SetPoint("BOTTOMRIGHT", UF[PLAYER_ID].stat2, "BOTTOMLEFT", 3, 3)
	UF[PLAYER_ID].stat2.icon:SetTexture(nibRealUI.media.icons.Lightning)
	
	
	----------------
	---- Target ----
	----------------
	local Parent = _G[ParentFrames[TARGET_ID]] or UIParent
	UF[TARGET_ID] = CreateFrame("Frame", ParentFrames[TARGET_ID].."_Overlay", Parent)
	UF[TARGET_ID]:Hide()
	SetFramePosition(UF[TARGET_ID], "MEDIUM", 0, F1_OverlayWidth[layoutSize], F1_OverlayHeight[layoutSize], {"BOTTOMLEFT", Parent, "BOTTOMLEFT", 0, -5})
	
	-- Health
	UF[TARGET_ID].health = CreateFrame("Frame", nil, UF[TARGET_ID])
	UF[TARGET_ID].health:SetParent(UF[TARGET_ID])
	SetFramePosition(UF[TARGET_ID].health, "MEDIUM", UF[TARGET_ID]:GetFrameLevel(), F1_HealthTextureWidth[layoutSize], 16, {"BOTTOMLEFT", UF[TARGET_ID], "BOTTOMLEFT", 4, 16})
	UF[TARGET_ID].health.colorID = ""
	UF[TARGET_ID].health.position = -1
	UF[TARGET_ID].health.elapsed = 0
	UF[TARGET_ID].health.interval = 0.2
	UF[TARGET_ID].health:SetScript("OnUpdate", function(self, elapsed)
		UnitFrames:Health_OnUpdate(self, elapsed, TARGET_ID)
	end)
	
		-- Surround
		UF[TARGET_ID].health.surround = CreateArtFrame(UF[TARGET_ID].health)
		SetFramePosition(UF[TARGET_ID].health.surround, "MEDIUM", UF[TARGET_ID].health:GetFrameLevel() + 2, F1_HealthTextureWidth[layoutSize], 16, {"BOTTOMLEFT", UF[TARGET_ID].health, "BOTTOMLEFT", 0, 0})
		UF[TARGET_ID].health.surround.bg:SetTexture(Textures[layoutSize].f1.health.surround)
		UF[TARGET_ID].health.surround.bg:SetTexCoord(1, 0, 0, 1)
		
		-- Background
		UF[TARGET_ID].health.background = CreateArtFrame(UF[TARGET_ID].health)
		SetFramePosition(UF[TARGET_ID].health.background, "MEDIUM", UF[TARGET_ID].health:GetFrameLevel(), F1_HealthTextureWidth[layoutSize], 16, {"BOTTOMLEFT", UF[TARGET_ID].health, "BOTTOMLEFT", layoutSize == 1 and 0 or 1, 0})
		UF[TARGET_ID].health.background.bg:SetTexture(Textures[layoutSize].f1.health.bar)
		UF[TARGET_ID].health.background.bg:SetTexCoord(1, 0, 0, 1)
		
		-- Bar
		UF[TARGET_ID].health.bar = AngleStatusBar:NewBar(UF[TARGET_ID].health.background, layoutSize == 1 and 2 or 1, -(15 - HealthHeight[layoutSize][TARGET_ID]), HealthWidth[layoutSize][TARGET_ID], HealthHeight[layoutSize][TARGET_ID], "RIGHT", "RIGHT", "RIGHT", true)
		
		-- HealthBar Text
		UF[TARGET_ID].healthtext = CreateTextFrame(UF[TARGET_ID].health, "BOTTOM", "RIGHT", true)
		SetFramePosition(UF[TARGET_ID].healthtext, "MEDIUM", UF[TARGET_ID].health:GetFrameLevel() + 3, 12, 12, {"BOTTOMRIGHT", UF[TARGET_ID].health, "BOTTOMRIGHT", F1_TargetRightHealthTextOffset[layoutSize], F1_HealthTextVertical[layoutSize]})

		-- Health Text
		UF[TARGET_ID].health.fullval = CreateTextFrame(UF[TARGET_ID].health, "BOTTOM", "LEFT", true)
		SetFramePosition(UF[TARGET_ID].health.fullval, "MEDIUM", UF[TARGET_ID].health:GetFrameLevel(), 12, 12, {"BOTTOMLEFT", UF[TARGET_ID].health, "BOTTOMLEFT", 0, F1_HealthTextVertical[layoutSize]})
		
		-- Steps
		UF[TARGET_ID].health.steps = {}
		for i = 1, 2 do
			UF[TARGET_ID].health.steps[i] = CreateArtFrame(UF[TARGET_ID].health.surround)
			SetFramePosition(UF[TARGET_ID].health.steps[i], "MEDIUM", UF[TARGET_ID].health.surround:GetFrameLevel() + 3, 16, 16, {"BOTTOMLEFT", UF[TARGET_ID].health.surround, "BOTTOMLEFT", 0, 2})
			UF[TARGET_ID].health.steps[i].bg:SetTexture(Textures[layoutSize].f1.health.step)
			UF[TARGET_ID].health.steps[i].bg:SetTexCoord(1, 0, 0, 1)
			UF[TARGET_ID].health.steps[i]:Hide()
		end

		-- Warning
		UF[TARGET_ID].health.warning = {}
		for i = 1, 2 do
			UF[TARGET_ID].health.warning[i] = CreateArtFrame(UF[TARGET_ID].health.surround)
			SetFramePosition(UF[TARGET_ID].health.warning[i], "MEDIUM", UF[TARGET_ID].health.surround:GetFrameLevel() + 4, 16, 16, {"BOTTOMLEFT", UF[TARGET_ID].health.surround, "BOTTOMLEFT", 0, 2})
			UF[TARGET_ID].health.warning[i].bg:SetTexture(Textures[layoutSize].f1.health.warning)
			UF[TARGET_ID].health.warning[i].bg:SetTexCoord(1, 0, 0, 1)
			UF[TARGET_ID].health.warning[i]:Hide()
		end
		
	-- Absorb Bar
	UF[TARGET_ID].absorbBar = AngleStatusBar:NewBar(UF[TARGET_ID].health.background, 2, -4, HealthWidth[layoutSize][TARGET_ID], HealthHeight[layoutSize][TARGET_ID], "RIGHT", "RIGHT", "RIGHT", false)
	UF[TARGET_ID].absorbBar:SetFrameLevel(UF[TARGET_ID].health.surround:GetFrameLevel() + 2)
	UF[TARGET_ID].absorbBar:SetPoint("TOPLEFT", UF[TARGET_ID].health.bar, "TOPRIGHT", 1, 0)

	-- Power
	UF[TARGET_ID].power = CreateFrame("Frame", nil, UF[TARGET_ID])
	UF[TARGET_ID].power:SetParent(UF[TARGET_ID])
	SetFramePosition(UF[TARGET_ID].power, "MEDIUM", UF[TARGET_ID]:GetFrameLevel(), 256, 16, {"BOTTOMLEFT", UF[TARGET_ID], "BOTTOMLEFT", 9, -3})
	UF[TARGET_ID].power.color = ""
	UF[TARGET_ID].power.position = -1
	UF[TARGET_ID].power.steppoints = {}
	UF[TARGET_ID].power.elapsed = 0
	UF[TARGET_ID].power.interval = 0.2
	UF[TARGET_ID].power:SetScript("OnUpdate", function(self, elapsed)
		UnitFrames:Power_OnUpdate(self, elapsed, TARGET_ID)
	end)
	
		-- Surround
		UF[TARGET_ID].power.surround = CreateArtFrame(UF[TARGET_ID].power)
		SetFramePosition(UF[TARGET_ID].power.surround, "MEDIUM", UF[TARGET_ID].power:GetFrameLevel() + 2, 256, 16, {"BOTTOMLEFT", UF[TARGET_ID].power, "BOTTOMLEFT", 0, 0})
		UF[TARGET_ID].power.surround.bg:SetTexture(Textures[layoutSize].f1.power.surround)
		UF[TARGET_ID].power.surround.bg:SetTexCoord(1, 0, 0, 1)
		
		-- Background
		UF[TARGET_ID].power.background = CreateArtFrame(UF[TARGET_ID].power)
		SetFramePosition(UF[TARGET_ID].power.background, "MEDIUM", UF[TARGET_ID].power:GetFrameLevel(), 256, 16, {"BOTTOMLEFT", UF[TARGET_ID].power, "BOTTOMLEFT", 0, 0})
		UF[TARGET_ID].power.background.bg:SetTexture(Textures[layoutSize].f1.power.bar)
		UF[TARGET_ID].power.background.bg:SetTexCoord(1, 0, 0, 1)
		
		-- Bar
		UF[TARGET_ID].power.bar = AngleStatusBar:NewBar(UF[TARGET_ID].power.background, -PowerXOffset[layoutSize], -1, PowerWidth[layoutSize][TARGET_ID], PowerHeight[layoutSize][TARGET_ID], "LEFT", "LEFT", "RIGHT", true)
		
		-- Power Text
		UF[TARGET_ID].power.fullval = CreateTextFrame(UF[TARGET_ID].power, "TOP", "LEFT", true)
		SetFramePosition(UF[TARGET_ID].power.fullval, "MEDIUM", UF[TARGET_ID].power:GetFrameLevel(), 12, 12, {"TOPLEFT", UF[TARGET_ID].power, "BOTTOMLEFT", 1, F1_PowerTextVertical[layoutSize]})
		tinsert(FontStringsY, {UF[TARGET_ID].power.fullval, 2, F1_PowerTextVertical[layoutSize]})

		-- Steps
		UF[TARGET_ID].power.steps = {}
		for i = 1, 3 do
			UF[TARGET_ID].power.steps[i] = CreateArtFrame(UF[TARGET_ID].power.surround)
			SetFramePosition(UF[TARGET_ID].power.steps[i], "MEDIUM", UF[TARGET_ID].power.surround:GetFrameLevel() + 2, 16, 16, {"BOTTOMLEFT", UF[TARGET_ID].power.surround, "BOTTOMLEFT", 0, 9})
			UF[TARGET_ID].power.steps[i].bg:SetTexture(Textures[layoutSize].f1.power.step)
			UF[TARGET_ID].power.steps[i].bg:SetTexCoord(1, 0, 0, 1)
			UF[TARGET_ID].power.steps[i]:Hide()
		end

		-- Warning
		UF[TARGET_ID].power.warning = {}
		for i = 1, 3 do
			UF[TARGET_ID].power.warning[i] = CreateArtFrame(UF[TARGET_ID].power.surround)
			SetFramePosition(UF[TARGET_ID].power.warning[i], "MEDIUM", UF[TARGET_ID].power.surround:GetFrameLevel() + 3, 16, 16, {"BOTTOMLEFT", UF[TARGET_ID].power.surround, "BOTTOMLEFT", 0, 2})
			UF[TARGET_ID].power.warning[i].bg:SetTexture(Textures[layoutSize].f1.power.warning)
			UF[TARGET_ID].power.warning[i].bg:SetTexCoord(1, 0, 0, 1)
			UF[TARGET_ID].power.warning[i]:Hide()
		end
		
	-- In Between
	UF[TARGET_ID].inbetween = CreateArtFrame(UF[TARGET_ID])
	SetFramePosition(UF[TARGET_ID].inbetween, "MEDIUM", UF[TARGET_ID]:GetFrameLevel(), PowerWidth[layoutSize][TARGET_ID] + 2, 1, {"LEFT", UF[TARGET_ID], "LEFT", 0, -1})
	UF[TARGET_ID].inbetween.bg:SetTexture(nibRealUI.media.textures.plain)
	UF[TARGET_ID].inbetween.bg:SetVertexColor(1, 1, 1, 0)
	UF[TARGET_ID].inbetween.wound = false
	UF[TARGET_ID].inbetween.woundend = 0
	UF[TARGET_ID].inbetween.heal = false
	UF[TARGET_ID].inbetween.healend = 0
	UF[TARGET_ID].inbetween.incheal = false
	UF[TARGET_ID].inbetween.elapsed = 0
	UF[TARGET_ID].inbetween.interval = 0.1
	UF[TARGET_ID].inbetween:SetScript("OnUpdate", function(self, elapsed)
		InBetween_OnUpdate(self, elapsed)
	end)
	
	-- End Box
	UF[TARGET_ID].endbox = CreateStatusBox(UF[TARGET_ID])
	SetFramePosition(UF[TARGET_ID].endbox, "MEDIUM", UF[TARGET_ID]:GetFrameLevel(), 32, 32, {"RIGHT", UF[TARGET_ID], "LEFT", 14 - F1_EndBoxXOffset[layoutSize], F1_EndBoxYOffset[layoutSize]})
	UF[TARGET_ID].endbox.surround:SetTexture(Textures[layoutSize].f1.endbox.surround)
	UF[TARGET_ID].endbox.surround:SetTexCoord(1, 0, 0, 1)
	UF[TARGET_ID].endbox.background:SetTexture(Textures[layoutSize].f1.endbox.bar)
	UF[TARGET_ID].endbox.background:SetTexCoord(1, 0, 0, 1)
	UF[TARGET_ID].endbox.bar:SetTexture(Textures[layoutSize].f1.endbox.bar)
	UF[TARGET_ID].endbox.bar:SetTexCoord(1, 0, 0, 1)
	UF[TARGET_ID].endbox.bar:SetVertexColor(0, 0, 0, 0)
	
	-- Status Boxes
	UF[TARGET_ID].statusbox = {}
	for i = 1, 2 do
		UF[TARGET_ID].statusbox[i] = CreateStatusBox(UF[TARGET_ID].power)
		SetFramePosition(UF[TARGET_ID].statusbox[i], "MEDIUM", UF[TARGET_ID].power:GetFrameLevel(), 16, 16, {"BOTTOMLEFT", UF[TARGET_ID].power, "BOTTOMRIGHT", ((i-1)*5+(i)) - (256 - PowerWidth[layoutSize][TARGET_ID] - 1) + 1, 0})
		UF[TARGET_ID].statusbox[i].surround:SetTexture(Textures[layoutSize].f1.statusbox.surround)
		UF[TARGET_ID].statusbox[i].surround:SetTexCoord(1, 0, 0, 1)
		UF[TARGET_ID].statusbox[i].background:SetTexture(Textures[layoutSize].f1.statusbox.bar)
		UF[TARGET_ID].statusbox[i].background:SetTexCoord(1, 0, 0, 1)
		UF[TARGET_ID].statusbox[i].bar:SetTexture(Textures[layoutSize].f1.statusbox.bar)
		UF[TARGET_ID].statusbox[i].bar:SetTexCoord(1, 0, 0, 1)
		UF[TARGET_ID].statusbox[i].bar:SetVertexColor(0, 0, 0, 0)
	end

	-- Health Boxes
	UF[TARGET_ID].healthbox = {}
	for i = 1, 2 do
		UF[TARGET_ID].healthbox[i] = CreateStatusBox(UF[TARGET_ID].health)
		SetFramePosition(UF[TARGET_ID].healthbox[i], "MEDIUM", UF[TARGET_ID].health.surround:GetFrameLevel() + 3, 16, 16, {"TOPLEFT", UF[TARGET_ID].health, "TOPLEFT", ((i-1)*8+(i)) + 7, -(15 - HealthHeight[layoutSize][TARGET_ID])})
		UF[TARGET_ID].healthbox[i].surround:SetTexture(Textures[layoutSize].f1.healthbox.surround)
		UF[TARGET_ID].healthbox[i].surround:SetTexCoord(1, 0, 0, 1)
		UF[TARGET_ID].healthbox[i].background:SetTexture(Textures[layoutSize].f1.healthbox.bar)
		UF[TARGET_ID].healthbox[i].background:SetTexCoord(1, 0, 0, 1)
		UF[TARGET_ID].healthbox[i].bar:SetTexture(Textures[layoutSize].f1.healthbox.bar)
		UF[TARGET_ID].healthbox[i].bar:SetTexCoord(1, 0, 0, 1)
	end
	
	-- Power Box
	UF[TARGET_ID].powerbox = CreateStatusBox(UF[TARGET_ID].power)
	SetFramePosition(UF[TARGET_ID].powerbox, "MEDIUM", UF[TARGET_ID].power:GetFrameLevel() + 3, 16, 16, {"BOTTOMRIGHT", UF[TARGET_ID].power, "BOTTOMRIGHT", 0, 9})
	UF[TARGET_ID].powerbox.surround:SetTexture(Textures[layoutSize].f1.powerbox.surround)
	UF[TARGET_ID].powerbox.background:SetTexture(Textures[layoutSize].f1.powerbox.bar)
	UF[TARGET_ID].powerbox.bar:SetTexture(Textures[layoutSize].f1.powerbox.bar)
	UF[TARGET_ID].powerbox.bar:SetVertexColor(0, 0, 0, 0)
	UF[TARGET_ID].powerbox:Hide()
	
	-- End Icon
	UF[TARGET_ID].endicon = CreateArtFrame(UF[TARGET_ID])
	UF[TARGET_ID].endicon:Hide()
	SetFramePosition(UF[TARGET_ID].endicon, "MEDIUM", UF[TARGET_ID]:GetFrameLevel(), 24, 24, {"BOTTOMLEFT", UF[TARGET_ID], "TOPRIGHT", -(256 - HealthWidth[layoutSize][TARGET_ID]) - 22, (layoutSize == 1) and 16 or 20})
	UF[TARGET_ID].endicon.bg:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	
	-- Stat Fields
	UF[TARGET_ID].stat1 = CreateTextFrame(UF[TARGET_ID].endbox, "BOTTOM", "RIGHT")
		UF[TARGET_ID].stat1.lastMinRange = -1
	SetFramePosition(UF[TARGET_ID].stat1, "MEDIUM", UF[TARGET_ID]:GetFrameLevel(), 12, 12, {"BOTTOMRIGHT", UF[TARGET_ID].endbox, "BOTTOMLEFT", layoutSize == 1 and 2 or 0, 18})
	tinsert(FontStringsY, {UF[TARGET_ID].stat1, 3, 18})
	
	UF[TARGET_ID].stat2 = CreateTextFrame(UF[TARGET_ID].endbox, "TOP", "RIGHT")
	SetFramePosition(UF[TARGET_ID].stat2, "MEDIUM", UF[TARGET_ID]:GetFrameLevel(), 12, 12, {"BOTTOMRIGHT", UF[TARGET_ID].endbox, "BOTTOMLEFT", layoutSize == 1 and 2 or 0, 1})
	
	UF[TARGET_ID].stat1.icon = UF[TARGET_ID].stat1:CreateTexture(nil, "ARTWORK")
	UF[TARGET_ID].stat1.icon:SetSize(16, 16)
	UF[TARGET_ID].stat1.icon:SetPoint("BOTTOMLEFT", UF[TARGET_ID].stat1, "BOTTOMRIGHT", 0, 0)
	UF[TARGET_ID].stat1.icon:SetTexture(nibRealUI.media.icons.DoubleArrow)

	UF[TARGET_ID].stat2.icon = UF[TARGET_ID].stat2:CreateTexture(nil, "ARTWORK")
	UF[TARGET_ID].stat2.icon:SetSize(16, 16)
	UF[TARGET_ID].stat2.icon:SetPoint("BOTTOMLEFT", UF[TARGET_ID].stat2, "BOTTOMRIGHT", 0, 3)
	UF[TARGET_ID].stat2.icon:SetTexture(nibRealUI.media.icons.Lightning)
	
	---------------
	---- Focus ----
	---------------
	local Parent = _G[ParentFrames[FOCUS_ID]] or UIParent
	UF[FOCUS_ID] = CreateFrame("Frame", ParentFrames[FOCUS_ID].."_Overlay", Parent)
	UF[FOCUS_ID]:Hide()
	SetFramePosition(UF[FOCUS_ID], "MEDIUM", 0, 256, 16, {"BOTTOMRIGHT", Parent, "BOTTOMRIGHT", 0, 0})
	
	-- Health
	UF[FOCUS_ID].health = CreateFrame("Frame", nil, UF[FOCUS_ID])
	UF[FOCUS_ID].health:SetParent(UF[FOCUS_ID])
	SetFramePosition(UF[FOCUS_ID].health, "MEDIUM", UF[FOCUS_ID]:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[FOCUS_ID], "BOTTOMRIGHT", -4, 0})
	UF[FOCUS_ID].health.colorID = ""
	UF[FOCUS_ID].health.position = -1
	UF[FOCUS_ID].health.elapsed = 0
	UF[FOCUS_ID].health.interval = 0.2
	UF[FOCUS_ID].health:SetScript("OnUpdate", function(self, elapsed)
		UnitFrames:Health_OnUpdate(self, elapsed, FOCUS_ID)
	end)
	
		-- Surround
		UF[FOCUS_ID].health.surround = CreateArtFrame(UF[FOCUS_ID].health)
		SetFramePosition(UF[FOCUS_ID].health.surround, "MEDIUM", UF[FOCUS_ID].health:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[FOCUS_ID].health, "BOTTOMRIGHT", 0, 0})
		UF[FOCUS_ID].health.surround.bg:SetTexture(Textures[layoutSize].f2.health.surround)
		
		-- Background
		UF[FOCUS_ID].health.background = CreateArtFrame(UF[FOCUS_ID].health)
		SetFramePosition(UF[FOCUS_ID].health.background, "MEDIUM", UF[FOCUS_ID].health:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[FOCUS_ID].health, "BOTTOMRIGHT", 0, 0})
		UF[FOCUS_ID].health.background.bg:SetTexture(Textures[layoutSize].f2.health.bar)
		
		-- Bar
		UF[FOCUS_ID].health.bar = AngleStatusBar:NewBar(UF[FOCUS_ID].health.background, -2, -(15 - HealthHeight[layoutSize][FOCUS_ID]), HealthWidth[layoutSize][FOCUS_ID], HealthHeight[layoutSize][FOCUS_ID], "LEFT", "RIGHT", "LEFT", true)
		
		-- HealthBar Text
		UF[FOCUS_ID].healthtext = CreateTextFrame(UF[FOCUS_ID].health, "BOTTOM", "LEFT")
		SetFramePosition(UF[FOCUS_ID].healthtext, "MEDIUM", UF[FOCUS_ID].health:GetFrameLevel() + 3, 12, 12, {"BOTTOMLEFT", UF[FOCUS_ID].health, "BOTTOMRIGHT", 9, 0})
		-- tinsert(FontStringsY, {UF[FOCUS_ID].healthtext, 3, 0})

		-- Steps
		UF[FOCUS_ID].health.steps = {}
		for i = 1, 2 do
			UF[FOCUS_ID].health.steps[i] = CreateArtFrame(UF[FOCUS_ID].health.surround)
			SetFramePosition(UF[FOCUS_ID].health.steps[i], "MEDIUM", UF[FOCUS_ID].health.surround:GetFrameLevel() + 3, 16, 16, {"TOPRIGHT", UF[FOCUS_ID].health.surround, "TOPRIGHT", 0, -2})
			UF[FOCUS_ID].health.steps[i].bg:SetTexture(Textures[layoutSize].f2.health.step)
			UF[FOCUS_ID].health.steps[i]:Hide()
		end

	-- End Box
	UF[FOCUS_ID].endbox = CreateStatusBox(UF[FOCUS_ID])
	SetFramePosition(UF[FOCUS_ID].endbox, "MEDIUM", UF[FOCUS_ID]:GetFrameLevel(), 16, 16, {"LEFT", UF[FOCUS_ID], "RIGHT", -10, 0})
	UF[FOCUS_ID].endbox.surround:SetTexture(Textures[layoutSize].f2.endbox.surround)
	UF[FOCUS_ID].endbox.background:SetTexture(Textures[layoutSize].f2.endbox.bar)
	UF[FOCUS_ID].endbox.bar:SetTexture(Textures[layoutSize].f2.endbox.bar)
	UF[FOCUS_ID].endbox.bar:SetVertexColor(0, 0, 0, 0)
	
	-- Status Boxes
	UF[FOCUS_ID].statusbox = {}
	for i = 1, 2 do
		UF[FOCUS_ID].statusbox[i] = CreateStatusBox(UF[FOCUS_ID].health)
		SetFramePosition(UF[FOCUS_ID].statusbox[i], "MEDIUM", UF[FOCUS_ID].health:GetFrameLevel(), 16, 16, {"BOTTOMRIGHT", UF[FOCUS_ID].health, "BOTTOMLEFT", -((i-1)*5+(i)) + (256 - HealthWidth[layoutSize][FOCUS_ID] - 1) + (layoutSize == 1 and 5 or 4), (layoutSize == 1) and -7 or -6})
		UF[FOCUS_ID].statusbox[i].surround:SetTexture(Textures[layoutSize].f2.statusbox.surround)
		UF[FOCUS_ID].statusbox[i].background:SetTexture(Textures[layoutSize].f2.statusbox.bar)
		UF[FOCUS_ID].statusbox[i].bar:SetTexture(Textures[layoutSize].f2.statusbox.bar)
		UF[FOCUS_ID].statusbox[i].bar:SetVertexColor(0, 0, 0, 0)
	end

	-- Health Boxes
	UF[FOCUS_ID].healthbox = {}
	for i = 1, 2 do
		UF[FOCUS_ID].healthbox[i] = CreateStatusBox(UF[FOCUS_ID].health)
		SetFramePosition(UF[FOCUS_ID].healthbox[i], "MEDIUM", UF[FOCUS_ID].health.surround:GetFrameLevel() + 3, 16, 16, {"TOPRIGHT", UF[FOCUS_ID].health, "TOPRIGHT", -((i-1)*6+(i)) - 6, -(15 - HealthHeight[layoutSize][FOCUS_ID])})
		UF[FOCUS_ID].healthbox[i].surround:SetTexture(Textures[layoutSize].f2.healthbox.surround)
		UF[FOCUS_ID].healthbox[i].background:SetTexture(Textures[layoutSize].f2.healthbox.bar)
		UF[FOCUS_ID].healthbox[i].bar:SetTexture(Textures[layoutSize].f2.healthbox.bar)
	end
	
	
	----------------------
	---- Focus Target ----
	----------------------
	local Parent = _G[ParentFrames[FOCUSTARGET_ID]] or UIParent
	UF[FOCUSTARGET_ID] = CreateFrame("Frame", ParentFrames[FOCUSTARGET_ID].."_Overlay", Parent)
	UF[FOCUSTARGET_ID]:Hide()
	SetFramePosition(UF[FOCUSTARGET_ID], "MEDIUM", 0, 256, 16, {"BOTTOMRIGHT", Parent, "BOTTOMRIGHT", 0, (layoutSize == 1) and 0 or -1})
	
	-- Health
	UF[FOCUSTARGET_ID].health = CreateFrame("Frame", nil, UF[FOCUSTARGET_ID])
	UF[FOCUSTARGET_ID].health:SetParent(UF[FOCUSTARGET_ID])
	SetFramePosition(UF[FOCUSTARGET_ID].health, "MEDIUM", UF[FOCUSTARGET_ID]:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[FOCUSTARGET_ID], "BOTTOMRIGHT", -4, 0})
	UF[FOCUSTARGET_ID].health.colorID = ""
	UF[FOCUSTARGET_ID].health.position = -1
	UF[FOCUSTARGET_ID].health.elapsed = 0
	UF[FOCUSTARGET_ID].health.interval = 0.2
	UF[FOCUSTARGET_ID].health:SetScript("OnUpdate", function(self, elapsed)
		UnitFrames:Health_OnUpdate(self, elapsed, FOCUSTARGET_ID)
	end)
	
		-- Surround
		UF[FOCUSTARGET_ID].health.surround = CreateArtFrame(UF[FOCUSTARGET_ID].health)
		SetFramePosition(UF[FOCUSTARGET_ID].health.surround, "MEDIUM", UF[FOCUSTARGET_ID].health:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[FOCUSTARGET_ID].health, "BOTTOMRIGHT", 0, 0})
		UF[FOCUSTARGET_ID].health.surround.bg:SetTexture(Textures[layoutSize].f3.health.surround)
		
		-- Background
		UF[FOCUSTARGET_ID].health.background = CreateArtFrame(UF[FOCUSTARGET_ID].health)
		SetFramePosition(UF[FOCUSTARGET_ID].health.background, "MEDIUM", UF[FOCUSTARGET_ID].health:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[FOCUSTARGET_ID].health, "BOTTOMRIGHT", 0, 0})
		UF[FOCUSTARGET_ID].health.background.bg:SetTexture(Textures[layoutSize].f3.health.bar)
		
		-- Bar
		UF[FOCUSTARGET_ID].health.bar = AngleStatusBar:NewBar(UF[FOCUSTARGET_ID].health.background, layoutSize == 1 and -8 or -9, -(15 - HealthHeight[layoutSize][FOCUSTARGET_ID]), HealthWidth[layoutSize][FOCUSTARGET_ID], HealthHeight[layoutSize][FOCUSTARGET_ID], "RIGHT", "RIGHT", "LEFT", true)
		
		-- HealthBar Text
		UF[FOCUSTARGET_ID].healthtext = CreateTextFrame(UF[FOCUSTARGET_ID].health, "BOTTOM", "LEFT")
		SetFramePosition(UF[FOCUSTARGET_ID].healthtext, "MEDIUM", UF[FOCUSTARGET_ID].health:GetFrameLevel() + 2, 12, 12, {"BOTTOMLEFT", UF[FOCUSTARGET_ID].health, "BOTTOMRIGHT", 9, 0})
		
		-- Steps
		UF[FOCUSTARGET_ID].health.steps = {}
		for i = 1, 2 do
			UF[FOCUSTARGET_ID].health.steps[i] = CreateArtFrame(UF[FOCUSTARGET_ID].health.surround)
			SetFramePosition(UF[FOCUSTARGET_ID].health.steps[i], "MEDIUM", UF[FOCUSTARGET_ID].health.surround:GetFrameLevel() + 2, 16, 16, {"TOPRIGHT", UF[FOCUSTARGET_ID].health.surround, "TOPRIGHT", 0, -2})
			UF[FOCUSTARGET_ID].health.steps[i].bg:SetTexture(Textures[layoutSize].f3.health.step)
			UF[FOCUSTARGET_ID].health.steps[i]:Hide()
		end

	-- End Box
	UF[FOCUSTARGET_ID].endbox = CreateStatusBox(UF[FOCUSTARGET_ID])
	SetFramePosition(UF[FOCUSTARGET_ID].endbox, "MEDIUM", UF[FOCUSTARGET_ID]:GetFrameLevel(), 16, 16, {"LEFT", UF[FOCUSTARGET_ID], "RIGHT", -10, 0})
	UF[FOCUSTARGET_ID].endbox.surround:SetTexture(Textures[layoutSize].f3.endbox.surround)
	UF[FOCUSTARGET_ID].endbox.background:SetTexture(Textures[layoutSize].f3.endbox.bar)
	UF[FOCUSTARGET_ID].endbox.bar:SetTexture(Textures[layoutSize].f3.endbox.bar)
	UF[FOCUSTARGET_ID].endbox.bar:SetVertexColor(0, 0, 0, 0)

	-- Status Boxes
	UF[FOCUSTARGET_ID].statusbox = {}
	for i = 1, 2 do
		UF[FOCUSTARGET_ID].statusbox[i] = CreateStatusBox(UF[FOCUSTARGET_ID].health)
		SetFramePosition(UF[FOCUSTARGET_ID].statusbox[i], "MEDIUM", UF[FOCUSTARGET_ID].health:GetFrameLevel(), 16, 16, {"BOTTOMRIGHT", UF[FOCUSTARGET_ID].health, "BOTTOMLEFT", -((i-1)*5+(i)) + (256 - HealthWidth[layoutSize][FOCUSTARGET_ID] - 1), (layoutSize == 1) and -7 or -6})
		UF[FOCUSTARGET_ID].statusbox[i].surround:SetTexture(Textures[layoutSize].f2.statusbox.surround)
		UF[FOCUSTARGET_ID].statusbox[i].background:SetTexture(Textures[layoutSize].f2.statusbox.bar)
		UF[FOCUSTARGET_ID].statusbox[i].bar:SetTexture(Textures[layoutSize].f2.statusbox.bar)
		UF[FOCUSTARGET_ID].statusbox[i].bar:SetVertexColor(0, 0, 0, 0)
	end

	-- Health Boxes
	UF[FOCUSTARGET_ID].healthbox = {}
	for i = 1, 2 do
		UF[FOCUSTARGET_ID].healthbox[i] = CreateStatusBox(UF[FOCUSTARGET_ID].health)
		SetFramePosition(UF[FOCUSTARGET_ID].healthbox[i], "MEDIUM", UF[FOCUSTARGET_ID].health:GetFrameLevel() + 3, 16, 16, {"BOTTOMRIGHT", UF[FOCUSTARGET_ID].health, "BOTTOMRIGHT", -((i-1)*6+(i)) - 6, -8})
		UF[FOCUSTARGET_ID].healthbox[i].surround:SetTexture(Textures[layoutSize].f3.healthbox.surround)
		UF[FOCUSTARGET_ID].healthbox[i].background:SetTexture(Textures[layoutSize].f3.healthbox.bar)
		UF[FOCUSTARGET_ID].healthbox[i].bar:SetTexture(Textures[layoutSize].f3.healthbox.bar)
	end
	
	
	-------------
	---- Pet ----
	-------------
	local Parent = _G[ParentFrames[PET_ID]] or UIParent
	UF[PET_ID] = CreateFrame("Frame", ParentFrames[PET_ID].."_Overlay", Parent)
	UF[PET_ID]:Hide()
	SetFramePosition(UF[PET_ID], "MEDIUM", 0, 256, 16, {"BOTTOMRIGHT", Parent, "BOTTOMRIGHT", 0, (layoutSize == 1) and 0 or -1})
	
	-- Health
	UF[PET_ID].health = CreateFrame("Frame", nil, UF[PET_ID])
	UF[PET_ID].health:SetParent(UF[PET_ID])
	SetFramePosition(UF[PET_ID].health, "MEDIUM", UF[PET_ID]:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[PET_ID], "BOTTOMRIGHT", -4, 0})
	UF[PET_ID].health.colorID = ""
	UF[PET_ID].health.position = -1
	UF[PET_ID].health.elapsed = 0
	UF[PET_ID].health.interval = 0.2
	UF[PET_ID].health:SetScript("OnUpdate", function(self, elapsed)
		UnitFrames:Health_OnUpdate(self, elapsed, PET_ID)
	end)
	
		-- Surround
		UF[PET_ID].health.surround = CreateArtFrame(UF[PET_ID].health)
		SetFramePosition(UF[PET_ID].health.surround, "MEDIUM", UF[PET_ID].health:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[PET_ID].health, "BOTTOMRIGHT", 0, 0})
		UF[PET_ID].health.surround.bg:SetTexture(Textures[layoutSize].f3.health.surround)
		
		-- Background
		UF[PET_ID].health.background = CreateArtFrame(UF[PET_ID].health)
		SetFramePosition(UF[PET_ID].health.background, "MEDIUM", UF[PET_ID].health:GetFrameLevel(), 256, 16, {"BOTTOMRIGHT", UF[PET_ID].health, "BOTTOMRIGHT", 0, 0})
		UF[PET_ID].health.background.bg:SetTexture(Textures[layoutSize].f3.health.bar)
		
		-- Bar
		UF[PET_ID].health.bar = AngleStatusBar:NewBar(UF[PET_ID].health.background, -8, -8, HealthWidth[layoutSize][PET_ID], HealthHeight[layoutSize][PET_ID], "RIGHT", "RIGHT", "LEFT", true)
		
		-- HealthBar Text
		UF[PET_ID].healthtext = CreateTextFrame(UF[PET_ID].health, "BOTTOM", "LEFT")
		SetFramePosition(UF[PET_ID].healthtext, "MEDIUM", UF[PET_ID].health:GetFrameLevel() + 2, 12, 12, {"BOTTOMLEFT", UF[PET_ID].health, "BOTTOMRIGHT", 9, 0})
		
		-- Steps
		UF[PET_ID].health.steps = {}
		for i = 1, 2 do
			UF[PET_ID].health.steps[i] = CreateArtFrame(UF[PET_ID].health.surround)
			SetFramePosition(UF[PET_ID].health.steps[i], "MEDIUM", UF[PET_ID].health.surround:GetFrameLevel() + 2, 16, 16, {"TOPRIGHT", UF[PET_ID].health.surround, "TOPRIGHT", 0, -2})
			UF[PET_ID].health.steps[i].bg:SetTexture(Textures[layoutSize].f3.health.step)
			UF[PET_ID].health.steps[i]:Hide()
		end

	-- End Box
	UF[PET_ID].endbox = CreateStatusBox(UF[PET_ID])
	SetFramePosition(UF[PET_ID].endbox, "MEDIUM", UF[PET_ID]:GetFrameLevel(), 16, 16, {"LEFT", UF[PET_ID], "RIGHT", -10, 0})
	UF[PET_ID].endbox.surround:SetTexture(Textures[layoutSize].f3.endbox.surround)
	UF[PET_ID].endbox.background:SetTexture(Textures[layoutSize].f3.endbox.bar)
	UF[PET_ID].endbox.bar:SetTexture(Textures[layoutSize].f3.endbox.bar)
	UF[PET_ID].endbox.bar:SetVertexColor(0, 0, 0, 0)

	-- Status Boxes
	UF[PET_ID].statusbox = {}
	for i = 1, 2 do
		UF[PET_ID].statusbox[i] = CreateStatusBox(UF[PET_ID].health)
		SetFramePosition(UF[PET_ID].statusbox[i], "MEDIUM", UF[PET_ID].health:GetFrameLevel(), 16, 16, {"BOTTOMRIGHT", UF[PET_ID].health, "BOTTOMLEFT", -((i-1)*5+(i)) + (256 - HealthWidth[layoutSize][PET_ID] - 1), (layoutSize == 1) and -7 or -6})
		UF[PET_ID].statusbox[i].surround:SetTexture(Textures[layoutSize].f2.statusbox.surround)
		UF[PET_ID].statusbox[i].background:SetTexture(Textures[layoutSize].f2.statusbox.bar)
		UF[PET_ID].statusbox[i].bar:SetTexture(Textures[layoutSize].f2.statusbox.bar)
		UF[PET_ID].statusbox[i].bar:SetVertexColor(0, 0, 0, 0)
	end

	-- Health Boxes
	UF[PET_ID].healthbox = {}
	for i = 1, 1 do
		UF[PET_ID].healthbox[i] = CreateStatusBox(UF[PET_ID].health)
		SetFramePosition(UF[PET_ID].healthbox[i], "MEDIUM", UF[PET_ID].health:GetFrameLevel() + 3, 16, 16, {"BOTTOMRIGHT", UF[PET_ID].health, "BOTTOMRIGHT", -((i-1)*6+(i)) - 6, -8})
		UF[PET_ID].healthbox[i].surround:SetTexture(Textures[layoutSize].f3.healthbox.surround)
		UF[PET_ID].healthbox[i].background:SetTexture(Textures[layoutSize].f3.healthbox.bar)
		UF[PET_ID].healthbox[i].bar:SetTexture(Textures[layoutSize].f3.healthbox.bar)
	end
	
	
	----------------------
	---- TargetTarget ----
	----------------------
	local Parent = _G[ParentFrames[TARGETTARGET_ID]] or UIParent
	UF[TARGETTARGET_ID] = CreateFrame("Frame", ParentFrames[TARGETTARGET_ID].."_Overlay", Parent)
	UF[TARGETTARGET_ID]:Hide()
	SetFramePosition(UF[TARGETTARGET_ID], "MEDIUM", 0, 256, 16, {"BOTTOMLEFT", Parent, "BOTTOMLEFT", 0, 0})
	
	-- Health
	UF[TARGETTARGET_ID].health = CreateFrame("Frame", nil, UF[TARGETTARGET_ID])
	UF[TARGETTARGET_ID].health:SetParent(UF[TARGETTARGET_ID])
	SetFramePosition(UF[TARGETTARGET_ID].health, "MEDIUM", UF[TARGETTARGET_ID]:GetFrameLevel(), 256, 16, {"BOTTOMLEFT", UF[TARGETTARGET_ID], "BOTTOMLEFT", 4, 0})
	UF[TARGETTARGET_ID].health.colorID = ""
	UF[TARGETTARGET_ID].health.position = -1
	UF[TARGETTARGET_ID].health.elapsed = 0
	UF[TARGETTARGET_ID].health.interval = 0.2
	UF[TARGETTARGET_ID].health:SetScript("OnUpdate", function(self, elapsed)
		UnitFrames:Health_OnUpdate(self, elapsed, TARGETTARGET_ID)
	end)
	
		-- Surround
		UF[TARGETTARGET_ID].health.surround = CreateArtFrame(UF[TARGETTARGET_ID].health)
		SetFramePosition(UF[TARGETTARGET_ID].health.surround, "MEDIUM", UF[TARGETTARGET_ID].health:GetFrameLevel(), 256, 16, {"BOTTOMLEFT", UF[TARGETTARGET_ID].health, "BOTTOMLEFT", 0, 0})
		UF[TARGETTARGET_ID].health.surround.bg:SetTexture(Textures[layoutSize].f2.health.surround)
		UF[TARGETTARGET_ID].health.surround.bg:SetTexCoord(1, 0, 0, 1)
		
		-- Background
		UF[TARGETTARGET_ID].health.background = CreateArtFrame(UF[TARGETTARGET_ID].health)
		SetFramePosition(UF[TARGETTARGET_ID].health.background, "MEDIUM", UF[TARGETTARGET_ID].health:GetFrameLevel(), 256, 16, {"BOTTOMLEFT", UF[TARGETTARGET_ID].health, "BOTTOMLEFT", 0, 0})
		UF[TARGETTARGET_ID].health.background.bg:SetTexture(Textures[layoutSize].f2.health.bar)
		UF[TARGETTARGET_ID].health.background.bg:SetTexCoord(1, 0, 0, 1)
		
		-- Bar
		UF[TARGETTARGET_ID].health.bar = AngleStatusBar:NewBar(UF[TARGETTARGET_ID].health.background, 2, -(15 - HealthHeight[layoutSize][TARGETTARGET_ID]), HealthWidth[layoutSize][TARGETTARGET_ID], HealthHeight[layoutSize][TARGETTARGET_ID], "RIGHT", "LEFT", "RIGHT", true)
		
		-- HealthBar Text
		UF[TARGETTARGET_ID].healthtext = CreateTextFrame(UF[TARGETTARGET_ID].health, "BOTTOM", "RIGHT")
		SetFramePosition(UF[TARGETTARGET_ID].healthtext, "MEDIUM", UF[TARGETTARGET_ID].health:GetFrameLevel() + 2, 12, 12, {"BOTTOMRIGHT", UF[TARGETTARGET_ID].health, "BOTTOMLEFT", -7, 0})
		-- tinsert(FontStringsY, {UF[TARGETTARGET_ID].healthtext, 3, 0})

		-- Steps
		UF[TARGETTARGET_ID].health.steps = {}
		for i = 1, 2 do
			UF[TARGETTARGET_ID].health.steps[i] = CreateArtFrame(UF[TARGETTARGET_ID].health.surround)
			SetFramePosition(UF[TARGETTARGET_ID].health.steps[i], "MEDIUM", UF[TARGETTARGET_ID].health.surround:GetFrameLevel() + 2, 16, 16, {"TOPRIGHT", UF[TARGETTARGET_ID].health.surround, "TOPRIGHT", 0, -2})
			UF[TARGETTARGET_ID].health.steps[i].bg:SetTexture(Textures[layoutSize].f2.health.step)
			UF[TARGETTARGET_ID].health.steps[i].bg:SetTexCoord(1, 0, 0, 1)
			UF[TARGETTARGET_ID].health.steps[i]:Hide()
		end

	-- End Box
	UF[TARGETTARGET_ID].endbox = CreateStatusBox(UF[TARGETTARGET_ID])
	SetFramePosition(UF[TARGETTARGET_ID].endbox, "MEDIUM", UF[TARGETTARGET_ID]:GetFrameLevel(), 16, 16, {"RIGHT", UF[TARGETTARGET_ID], "LEFT", 10, 0})
	UF[TARGETTARGET_ID].endbox.surround:SetTexture(Textures[layoutSize].f2.endbox.surround)
	UF[TARGETTARGET_ID].endbox.surround:SetTexCoord(1, 0, 0, 1)
	UF[TARGETTARGET_ID].endbox.background:SetTexture(Textures[layoutSize].f2.endbox.bar)
	UF[TARGETTARGET_ID].endbox.background:SetTexCoord(1, 0, 0, 1)
	UF[TARGETTARGET_ID].endbox.bar:SetTexture(Textures[layoutSize].f2.endbox.bar)
	UF[TARGETTARGET_ID].endbox.bar:SetTexCoord(1, 0, 0, 1)
	UF[TARGETTARGET_ID].endbox.bar:SetVertexColor(0, 0, 0, 0)
	
	-- Status Boxes
	UF[TARGETTARGET_ID].statusbox = {}
	for i = 1, 2 do
		UF[TARGETTARGET_ID].statusbox[i] = CreateStatusBox(UF[TARGETTARGET_ID].health)
		SetFramePosition(UF[TARGETTARGET_ID].statusbox[i], "MEDIUM", UF[TARGETTARGET_ID].health:GetFrameLevel(), 16, 16, {"BOTTOMLEFT", UF[TARGETTARGET_ID].health, "BOTTOMRIGHT", ((i-1)*5+(i)) - (256 - HealthWidth[layoutSize][TARGETTARGET_ID] - 1) - (layoutSize == 1 and 5 or 4), (layoutSize == 1) and -7 or -6})
		UF[TARGETTARGET_ID].statusbox[i].surround:SetTexture(Textures[layoutSize].f2.statusbox.surround)
		UF[TARGETTARGET_ID].statusbox[i].surround:SetTexCoord(1, 0, 0, 1)
		UF[TARGETTARGET_ID].statusbox[i].background:SetTexture(Textures[layoutSize].f2.statusbox.bar)
		UF[TARGETTARGET_ID].statusbox[i].background:SetTexCoord(1, 0, 0, 1)
		UF[TARGETTARGET_ID].statusbox[i].bar:SetTexture(Textures[layoutSize].f2.statusbox.bar)
		UF[TARGETTARGET_ID].statusbox[i].bar:SetTexCoord(1, 0, 0, 1)
		UF[TARGETTARGET_ID].statusbox[i].bar:SetVertexColor(0, 0, 0, 0)
	end

	-- Health Boxes
	UF[TARGETTARGET_ID].healthbox = {}
	for i = 1, 2 do
		UF[TARGETTARGET_ID].healthbox[i] = CreateStatusBox(UF[TARGETTARGET_ID].health)
		SetFramePosition(UF[TARGETTARGET_ID].healthbox[i], "MEDIUM", UF[TARGETTARGET_ID].health:GetFrameLevel() + 3, 16, 16, {"TOPLEFT", UF[TARGETTARGET_ID].health, "TOPLEFT", ((i-1)*6+(i)) + 6, -(15 - HealthHeight[layoutSize][TARGETTARGET_ID])})
		UF[TARGETTARGET_ID].healthbox[i].surround:SetTexture(Textures[layoutSize].f2.healthbox.surround)
		UF[TARGETTARGET_ID].healthbox[i].surround:SetTexCoord(1, 0, 0, 1)
		UF[TARGETTARGET_ID].healthbox[i].background:SetTexture(Textures[layoutSize].f2.healthbox.bar)
		UF[TARGETTARGET_ID].healthbox[i].background:SetTexCoord(1, 0, 0, 1)
		UF[TARGETTARGET_ID].healthbox[i].bar:SetTexture(Textures[layoutSize].f2.healthbox.bar)
		UF[TARGETTARGET_ID].healthbox[i].bar:SetTexCoord(1, 0, 0, 1)
	end
	
	-- End Icon
	UF[TARGETTARGET_ID].endicon = CreateArtFrame(UF[TARGETTARGET_ID])
	UF[TARGETTARGET_ID].endicon:Hide()
	SetFramePosition(UF[TARGETTARGET_ID].endicon, "MEDIUM", UF[TARGETTARGET_ID]:GetFrameLevel(), 12, 12, {"BOTTOMRIGHT", UF[TARGETTARGET_ID], "TOPRIGHT", -(256 - HealthWidth[layoutSize][TARGETTARGET_ID]) + 9, -4})
	UF[TARGETTARGET_ID].endicon.bg:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
end

---- EVENTS ----
function UnitFrames:UpdateSpec()
	UF[PLAYER_ID].power.sinrogue = (nibRealUI.class == "ROGUE") and (GetSpecialization() == 1)
end

-- End Icon
function UnitFrames:EndIconEvent()
	self:UpdateEndIcons()
end

-- Death Event
function UnitFrames:PlayerDeathEvent()
	self:UpdateUnitHealthBarInfo(PLAYER_ID)
	self:UpdateUnitPowerBarInfo(PLAYER_ID)
	self:UpdateEndIcons()
end

function UnitFrames:ThreatUpdate(event, UnitID)
	if not UnitExists(TARGET_ID) then return end

	local isTanking, _, _, rawPercentage = UnitDetailedThreatSituation(PLAYER_ID, TARGET_ID)
	local display = rawPercentage
	if ( isTanking ) then
		display = UnitThreatPercentageOfLead(PLAYER_ID, TARGET_ID)
	end
	if not(UnitIsDeadOrGhost("target")) and (display and (display ~= 0)) then
		UF[TARGET_ID].stat2.icon:Show()
		UF[TARGET_ID].stat2.text:SetFormattedText("%d%%", display)
		if isTanking then
			UF[TARGET_ID].stat2.text:SetTextColor(unpack(nibRealUI.media.colors.red))
		elseif display < 80 then
			UF[TARGET_ID].stat2.text:SetTextColor(1, 1, 1, 1)
		else
			UF[TARGET_ID].stat2.text:SetTextColor(unpack(nibRealUI.media.colors.orange))
		end
	else
		UF[TARGET_ID].stat2.icon:Hide()
		UF[TARGET_ID].stat2.text:SetText()
	end
end

-- Classification Event
function UnitFrames:ClassificationEvent(event, UnitID)
	if not UF[UnitID] then return end
	self:UpdateUnitInfo(UnitID)
end

-- Status Event
local SEOtherUnitsTimer = CreateFrame("Frame")
SEOtherUnitsTimer:Hide()
SEOtherUnitsTimer.e = 0
SEOtherUnitsTimer.i = 0.25
SEOtherUnitsTimer.updateHealthInfo = false
SEOtherUnitsTimer:SetScript("OnUpdate", function(s, e)
	s.e = s.e + e
	if s.e >= s.i then
		UnitFrames:UpdateStatus(TARGETTARGET_ID)
		UnitFrames:UpdateUnitPvPStatus(TARGETTARGET_ID)
		UnitFrames:UpdateStatus(FOCUSTARGET_ID)
		UnitFrames:UpdateUnitPvPStatus(FOCUSTARGET_ID)
		if s.updateHealthInfo then
			UnitFrames:UpdateUnitHealthBarInfo(TARGETTARGET_ID, true)
			UnitFrames:UpdateUnitHealthBarInfo(FOCUSTARGET_ID, true)
		end
		s.e = 0
		s:Hide()
	end
end)
function UnitFrames:StatusEvent(event, ...)
	local UnitID = ... or PLAYER_ID
	if UF[UnitID] then
		-- Update Status of unit
		self:UpdateStatus(UnitID)
		self:UpdateUnitPvPStatus(UnitID)
		self:UpdateUnitInfo(UnitID)
		-- Target/Focus hostility change
		if (event == "UNIT_FACTION") then
			self:UpdateUnitHealthBarInfo(UnitID, true)
			SEOtherUnitsTimer.updateHealthInfo = true
		end
		-- Update Other units
		SEOtherUnitsTimer:Show()
	end
end

-- Combat Event
local ValidCombatEventUnits = {
	[PLAYER_ID] = true,
	[VEHICLE_ID] = true,
	[TARGET_ID] = true,
}
function UnitFrames:CombatEvent(event, ...)
	local UnitID = ...
	if not ValidCombatEventUnits[UnitID] then return end
	
	local Unit, UFUnit = PlayerOrVehicleIDs(UnitID)
	if not UnitExists(Unit) then return end
	
	if (event == "UNIT_COMBAT") then
		local _, ceEvent = ...
		if ((ceEvent == "WOUND") or (ceEvent == "HEAL")) then
			self:SetInBetween(UFUnit, ceEvent)
		end
	elseif (event == "UNIT_HEAL_PREDICTION") then
		local ceMIH = UnitGetIncomingHeals(Unit, PLAYER_ID) or 0
		local ceAIH = UnitGetIncomingHeals(Unit) or 0
		
		if (ceAIH < ceMIH) then
			ceAIH = 0
		else
			ceAIH = ceAIH - ceMIH
		end
		
		if (ceAIH >= (UnitHealthVal[Unit] * 0.05)) then
			self:SetInBetween(UFUnit, "INCHEAL")
		else
			self:SetInBetween(UFUnit, "NOINCHEAL")
		end
	end
end

-- Power
function UnitFrames:PowerUpdateMajor(event, UnitID)
	if not(ValidPowerUnit[UnitID]) then return end
	self:ToggleUnitPower(UnitID)
	self:UpdateUnitPowerBarInfo(UnitID)
end

-- Absorb
function UnitFrames:AbsorbUpdate(event, UnitID)
	if not ValidAbsorbUnit[UnitID] then return end
	self:UpdateUnitAbsorb(UnitID)
end

-- Health
function UnitFrames:HealthUpdate(event, UnitID)
	if not(ValidHealthUnit[Unit]) then return end
	self:UpdateUnitHealth(UnitID, true)
end

-- Unit Target
function UnitFrames:UnitTargetUpdate(event, UnitID)
	if (UnitID == PLAYER_ID) then return end
	
	local UnitTargetID = UnitID.."target"
	if not UF[UnitTargetID] then return end
	
	if UnitExists(UnitTargetID) then
		if not UF[UnitTargetID]:IsVisible() then UF[UnitTargetID]:Show() end
		self:UpdateUnitHealthBarInfo(UnitTargetID)
		self:UpdateUnitHealth(UnitTargetID, true)
		self:UpdateEndBox(UnitTargetID)
		self:UpdateStatus(UnitTargetID)
		self:UpdateUnitPvPStatus(UnitTargetID)
		self:UpdateUnitInfo(UnitTargetID)
		self:UpdateEndIcons()
	else
		if UF[UnitTargetID]:IsVisible() then UF[UnitTargetID]:Hide() end
	end
end

-- Focus
function UnitFrames:FocusUpdate()
	if UnitExists(FOCUS_ID) then
		if not UF[FOCUS_ID]:IsVisible() then UF[FOCUS_ID]:Show() end
		self:UpdateUnitHealthBarInfo(FOCUS_ID)
		self:UpdateUnitHealth(FOCUS_ID, true)
		self:UpdateEndBox(FOCUS_ID)
		self:UpdateStatus(FOCUS_ID)
		self:UpdateUnitPvPStatus(FOCUS_ID)
		self:UpdateUnitInfo(FOCUS_ID)
		self:UpdateEndIcons()
		self:UnitTargetUpdate("fu", FOCUS_ID)
	else
		if UF[FOCUS_ID]:IsVisible() then UF[FOCUS_ID]:Hide() end
	end
end

-- Vehicle
function UnitFrames:VehicleEvent()
	-- Vehicle flag
	SetPlayerVehicleFlag()
	
	-- Update
	self:UpdateEndBox(PLAYER_ID)
	self:SetInBetween(PLAYER_ID, "NONE")
	self:ToggleUnitPower(VEHICLE_ID)
	self:UpdateUnitPowerBarInfo(VEHICLE_ID)
	self:UpdateUnitHealthBarInfo(VEHICLE_ID)
	self:UpdateUnitPvPStatus(VEHICLE_ID)
	self:UpdateEndIcons()
end

-- Pet
function UnitFrames:PetEvent()
	if UnitExists(PET_ID) then
		if not UF[PET_ID]:IsVisible() then UF[PET_ID]:Show() end
		self:UpdateUnitHealthBarInfo(PET_ID)
		self:UpdateUnitHealth(PET_ID, true)
		self:UpdateEndBox(PET_ID)
		self:UpdateStatus(PET_ID)
		self:UpdateUnitPvPStatus(PET_ID)
		self:UpdateUnitInfo(PET_ID)
		self:UpdateEndIcons()
	else
		if UF[PET_ID]:IsVisible() then UF[PET_ID]:Hide() end
	end
end

-- Player Target
function UnitFrames:PlayerTargetUpdate()
	if UnitExists(TARGET_ID) then
		if not UF[TARGET_ID]:IsVisible() then UF[TARGET_ID]:Show() end
		self:ToggleUnitPower(TARGET_ID)
		self:UpdateUnitPowerBarInfo(TARGET_ID)
		self:UpdateUnitHealthBarInfo(TARGET_ID)
		self:UpdateUnitAbsorb(TARGET_ID)
		self:UpdateEndBox(TARGET_ID)
		self:UpdateStatus(TARGET_ID)
		self:UpdateUnitPvPStatus(TARGET_ID)
		self:UpdateUnitInfo(TARGET_ID)
		self:RangeDisplayUpdate(TARGET_ID)
		self:SetInBetween(TARGET_ID, "NONE")
		self:ThreatUpdate()
		self:UpdateEndIcons()
	else
		if UF[TARGET_ID]:IsVisible() then UF[TARGET_ID]:Hide() end
		AngleStatusBar:SetValue(UF[TARGET_ID].health.bar, 1, true)
		UF[TARGET_ID].health.position = 0
		AngleStatusBar:SetValue(UF[TARGET_ID].power.bar, 1, true)
		UF[TARGET_ID].power.position = 0
	end
	self:UnitTargetUpdate("ptu", FOCUS_ID)	-- Update FocusTarget
	self:UnitTargetUpdate("ptu", TARGET_ID)	-- Update TargetTarget
end

-- Entering World
function UnitFrames:PLAYER_ENTERING_WORLD()
	self:RefreshUnits()
	UnitFrames:UpdateUnitHealthBarInfo(PLAYER_ID)
end

---- INITIALIZATION ----
function UnitFrames:Refresh()
	-- Update Unit Frames
	self:UpdateTextures()
	self:UpdateFonts()
	self:RefreshUnits()
end

function UnitFrames:UpdateGlobalColors()
	self:Refresh()
end

local function ClassColorsUpdate()
	for k,v in pairs(UF) do
		UnitFrames:UpdateUnitHealthBarInfo(k, true)
		UnitFrames:UpdateEndBox(k)
	end
end

function UnitFrames:InitializeOverlay()
	db = self.db.profile
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	layoutSize = ndb.settings.hudSize

	RangeColors = {
		[5] = nibRealUI.media.colors.green,
		[30] = nibRealUI.media.colors.yellow,
		[35] = nibRealUI.media.colors.amber,
		[40] = nibRealUI.media.colors.orange,
		[100] = nibRealUI.media.colors.red,
	}

	---- Player info
	PlayerStepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
	
	self:CreateFrames()
	self:Refresh()
	
	---- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	-- Target update 
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "PlayerTargetUpdate")
	self:RegisterEvent("UNIT_TARGET", "UnitTargetUpdate")
	
	-- Focus update
	self:RegisterEvent("PLAYER_FOCUS_CHANGED", "FocusUpdate")
	
	-- Health update
	self:RegisterEvent("UNIT_MAXHEALTH", "HealthUpdate")

	-- Absorb update
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "AbsorbUpdate")
	
	-- Power update
	self:RegisterEvent("UNIT_MAXPOWER", "PowerUpdateMajor")
	self:RegisterEvent("UNIT_DISPLAYPOWER", "PowerUpdateMajor")
	
	-- Pet update 
	self:RegisterEvent("UNIT_PET", "PetEvent")
	
	-- Vehicle update
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "VehicleEvent")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "VehicleEvent")
	
	-- Combat Event
	self:RegisterEvent("UNIT_COMBAT", "CombatEvent")
	self:RegisterEvent("UNIT_HEAL_PREDICTION", "CombatEvent")
	
	-- Status
	self:RegisterEvent("PLAYER_FLAGS_CHANGED", "StatusEvent")
	self:RegisterEvent("UNIT_FLAGS", "StatusEvent")
	self:RegisterEvent("UPDATE_FACTION", "StatusEvent")
	self:RegisterEvent("UNIT_FACTION", "StatusEvent")
	
	-- Classification
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", "ClassificationEvent")

	-- Threat
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", "ThreatUpdate")
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", "ThreatUpdate")
	self:ScheduleRepeatingTimer("ThreatUpdate", 0.25)
	
	-- Death
	self:RegisterEvent("PLAYER_DEAD", "PlayerDeathEvent")
	self:RegisterEvent("PLAYER_UNGHOST", "PlayerDeathEvent")
	self:RegisterEvent("PLAYER_ALIVE", "PlayerDeathEvent")
	
	-- End Icon
	self:RegisterEvent("RAID_TARGET_UPDATE", "EndIconEvent")
	self:RegisterEvent("INCOMING_RESURRECT_CHANGED", "EndIconEvent")

	-- Spec
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "UpdateSpec")
	
	-- Range Display
	self:ScheduleRepeatingTimer("RangeDisplayUpdate", 0.25)
	
	---- ClassColors support
	if CUSTOM_CLASS_COLORS then
		CUSTOM_CLASS_COLORS:RegisterCallback(ClassColorsUpdate)
	end
	
	---- Combat Fader
	local CF = nibRealUI:GetModule("CombatFader", true)
	if CF then CF:FadeFrames() end
end