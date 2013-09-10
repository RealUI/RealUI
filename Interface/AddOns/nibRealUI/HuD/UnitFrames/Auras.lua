local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local Auras = {}
UnitFrames.Auras = Auras

local oUF = oUFembed

local strsub = _G.strsub
local tonumber = _G.tonumber
local bitBand = _G.bit.band

local PLAYER_ID = "player"
local PET_ID = "pet"
local VEHICLE_ID = "vehicle"
local FOCUS_ID = "focus"
local FOCUSTARGET_ID = "focustarget"
local TARGET_ID = "target"
local TARGETTARGET_ID = "targettarget"
local MAINTANK_ID = "maintank"
local BOSS_ID = "boss"

local function TimeFormat(t)
	local h, m, hplus, mplus, s, ts, f

	h = math.floor(t / 3600)
	m = math.floor((t - (h * 3600)) / 60)
	s = math.floor(t - (h * 3600) - (m * 60))

	hplus = math.floor((t + 3599.99) / 3600)
	mplus = math.floor((t - (h * 3600) + 59.99) / 60) -- provides compatibility with tooltips

	if t >= 3600 then
		f = string.format("%.0fh", hplus)
	elseif t >= 60 then
		f = string.format("%.0fm", mplus)
	else
		f = string.format("%.0fs", s)
	end

	return f
end

---------------------
------ Sorting ------
---------------------

local SortAuras = function(a, b)
	if (a:IsShown() and b:IsShown()) then
		return a.timeLeft < b.timeLeft
	elseif (a:IsShown()) then
		return true
	end
end

Auras.PreSetPosition = function(auras)
	table.sort(auras, SortAuras)
	return 1, auras.createdIcons
end

-----------------------
------ Cooldowns ------
-----------------------
local function AttachStatusBar(icon, unit)
	local sBar = CreateFrame("StatusBar", nil, icon)
		sBar:SetValue(0)
		sBar:SetMinMaxValues(0, 1)
		sBar:SetStatusBarTexture(nibRealUI.media.textures.plain)
		sBar:SetStatusBarColor(0,0,0,0)

		sBar:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", 1, 1)
		sBar:SetPoint("TOPRIGHT", icon, "BOTTOMRIGHT", -1, 3)
		sBar:SetFrameLevel(icon:GetFrameLevel() + 2)

	local sBarBG = CreateFrame("Frame", nil, sBar)
		sBarBG:SetPoint("TOPLEFT", sBar, -1, 1)
		sBarBG:SetPoint("BOTTOMRIGHT", sBar, 1, -1)
		sBarBG:SetFrameLevel(icon:GetFrameLevel() + 1)
		nibRealUI:CreateBD(sBarBG)

	local timeStr = icon:CreateFontString(nil, "OVERLAY")
		timeStr:SetFont(unpack(nibRealUI.font.pixel1))
		timeStr:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", (unit == "pet") and 0.5 or 1.5, (unit == "pet") and 5 or 4)
		timeStr:SetJustifyH("LEFT")

	return sBar, timeStr
end

Auras.PostUpdateIcon = function(self, unit, icon, index)
	if not icon.sCooldown then
		icon.sCooldown, icon.timeStr = AttachStatusBar(icon, unit)

		icon.elapsed = 0
		icon.interval = 1/4
		icon:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = self.elapsed + elapsed
			if self.elapsed >= self.interval then
				self.elapsed = 0
				if self.startTime and self.endTime then
					if self.needsUpdate then
						self.sCooldown:Show()
						self.sCooldown:SetMinMaxValues(0, self.endTime - self.startTime)
					end
					
					local now = GetTime()
					self.sCooldown:SetValue(self.endTime - now)
					self.timeStr:SetText(TimeFormat(ceil(self.endTime - now)))

					local per = (self.endTime - now) / (self.endTime - self.startTime)
					if per > 0.5 then
						self.sCooldown:SetStatusBarColor(1 - ((per*2)-1), 1, 0)
					else
						self.sCooldown:SetStatusBarColor(1, (per*2), 0)
					end
				else
					self.sCooldown:Hide()
					self.timeStr:SetText()
				end
			end
		end)
	end
end

---------------------
------ Filters ------
---------------------

Auras.FilterPetBuffs = function(...)
	local _,_,_,_,_,_,_,_,_,_,caster = ...
	if (caster == "pet") and not(UnitHasVehicleUI("player") and UnitExists("vehicle")) then return true end
end

-- Auras.FilterPetDebuffs = function(...)
-- 	local _,unit,_,_,_,_,_,_,_,_,caster,_,_,_,canApplyAura = ...
-- 	if unit ~= "pet" then return end
-- end

Auras.FilterBossAuras = function(...)
	local _,_,_,_,_,_,_,_,_,_,caster,_,_,_,canApplyAura = ...
	if not caster then return false end
	
	-- Cast by Player
	if ((caster == PLAYER_ID) or (caster == VEHICLE_ID)) and canApplyAura and UnitFrames.db.profile.boss.showPlayerAuras then return true end

	-- Cast by NPC
	if UnitFrames.db.profile.boss.showNPCAuras then
		local guid, isNPC = UnitGUID(caster), false
		if guid then
			local first3 = tonumber("0x" .. strsub(guid, 3,5))
			local unitType = bit.band(first3, 0x00f)
			isNPC = (unitType == 0x003)
		end
		return isNPC
	end
end