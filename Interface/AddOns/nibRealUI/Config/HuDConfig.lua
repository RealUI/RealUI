local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb, ndbc

local _
local MODNAME = "HuDConfig"
local HuDConfig = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

-- local HuDConfig_Positions = nibRealUI:GetModule("HuDConfig_Positions")
local HuDConfig_ActionBars = nibRealUI:GetModule("HuDConfig_ActionBars")
local HuDConfig_MSBT = nibRealUI:GetModule("HuDConfig_MSBT")

local WFCollapsed
local EABShown

function HuDConfig:ResetDefaults()
	if ndb.positionsLink then
		ndb.positions = nibRealUI:DeepCopy(nibRealUI.defaultPositions)
	else
		ndb.positions[nibRealUI.cLayout] = nibRealUI:DeepCopy(nibRealUI.defaultPositions[nibRealUI.cLayout])
	end

	nibRealUI:UpdatePositioners()
	nibRealUI:GetModule("HuDConfig_Positions"):Refresh()

	if nibRealUI:DoesAddonMove("mikScrollingBattleText") then HuDConfig:RegisterForUpdate("MSBT") end
	if nibRealUI:DoesAddonMove("Bartender4") then HuDConfig:RegisterForUpdate("AB") end
end

local RavenInTestMode = false
local RavenTestModeTimer
function RealUIHuDTestMode(toggle)
	-- Toggle Test Modes
	-- Raven
	if Raven then
		if toggle then
			if RavenInTestMode then
				Raven:TestBarGroups()
				Raven:TestBarGroups()
			else
				Raven:TestBarGroups()
			end
		else
			if RavenInTestMode then
				Raven:TestBarGroups()
			end
		end
	end

	nibRealUI:ToggleGridTestMode(toggle)

	-- RealUI Modules
	for k, mod in pairs(nibRealUI.configModeModules) do
		mod.ToggleConfigMode(mod, toggle)
	end

	-- Boss Frames
	RealUIUFBossConfig(toggle, "player")

	-- Spell Alerts
	local sAlert = {
		id = 17941,
		texture = "TEXTURES\\SPELLACTIVATIONOVERLAYS\\NIGHTFALL.BLP",
		positions = "Left + Right (Flipped)",
		scale = 1,
		r = 255, g = 255, b = 255,
	}
	if toggle then
		SpellActivationOverlay_ShowAllOverlays(SpellActivationOverlayFrame, sAlert.id, sAlert.texture, sAlert.positions, sAlert.scale, sAlert.r, sAlert.g, sAlert.b);
	else
		SpellActivationOverlay_HideOverlays(SpellActivationOverlayFrame, sAlert.id)
	end

	-- Extra Action Button
	if not EABShown then
		if toggle then
			ExtraActionBarFrame.button:Show()
			ExtraActionBarFrame:Show()
			ExtraActionBarFrame.outro:Stop()
			ExtraActionBarFrame.intro:Play()
			if not ExtraActionBarFrame.button.icon:GetTexture() then
				ExtraActionBarFrame.button.icon:SetTexture("Interface\\ICONS\\ABILITY_SEAL")
				ExtraActionBarFrame.button.icon:Show()
			end
		else
			ExtraActionBarFrame:Hide()
			ExtraActionBarFrame.button:Hide()
			ExtraActionBarFrame.intro:Stop()
			ExtraActionBarFrame.outro:Play()
		end
	end
end

function RealUIHuDCloseConfig()
	-- Watch Frames
	if not WFCollapsed then
		WatchFrame:Show()
	end

	-- HuDConfig_Positions:ToggleMovers(false)
	RealUIHuDTestMode(false)
end

function HuDConfig:InitHuDConfig()
	-- WatchFrame
	WFCollapsed = WatchFrame.userCollapsed or not(WatchFrame:IsShown())
	if not WFCollapsed then WatchFrame:Hide() end

	-- EAB
	EABShown = ExtraActionBarFrame:IsShown()
end

-- Apply MSBT positions
function HuDConfig:ApplyMSBTConfig()
	if not self.registeredUpdates["MSBT"] then return end
	self.registeredUpdates["MSBT"] = false
	self.lastUpdateTimes["MSBT"] = GetTime()

	HuDConfig_MSBT:ApplySettings()
end

-- Apply AB positions
function HuDConfig:ApplyABConfig(tag)
	if not self.registeredUpdates["AB"] then return end
	self.registeredUpdates["AB"] = false
	self.lastUpdateTimes["AB"] = GetTime()

	HuDConfig_ActionBars:ApplySettings(tag)
end

function HuDConfig:ApplyAddOnConfig(addon, tag)
	if addon == "MSBT" then
		self:ApplyMSBTConfig()
	elseif addon == "AB" then
		self:ApplyABConfig(tag)
	end
end

function HuDConfig:RegisterForUpdate(addon, tag)
	if not self.lastUpdateTimes[addon] then
		self.lastUpdateTimes[addon] = 0
	end
	if not(InCombatLockdown()) and (self.lastUpdateTimes[addon] <= (GetTime() - 0.25)) then
		self.registeredUpdates[addon] = true
		self:ApplyAddOnConfig(addon, tag)
	else
		if not self.registeredUpdates[addon] then
			self.registeredUpdates[addon] = true
			self:ScheduleTimer("Apply"..addon.."Config", 0.25)
		end
	end
end

function HuDConfig:RavenTestEnd()
	RavenInTestMode = false
	RavenTestModeTimer = nil
end

----------
function HuDConfig:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	self.registeredUpdates = {}
	self.lastUpdateTimes = {}
end

function HuDConfig:OnEnable()
	if nibRealUI:DoesAddonMove("mikScrollingBattleText") then self:RegisterForUpdate("MSBT") end

	-- if nibRealUI:DoesAddonMove("Bartender4") then
		self:RegisterForUpdate("AB")
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", function()
			self:RegisterForUpdate("AB", "stance")
		end)
	-- end

	-- Raven Test Mode
	if Raven then
		hooksecurefunc(Raven, "TestBarGroups", function()
			RavenInTestMode = not(RavenInTestMode)
			if RavenInTestMode then
				if RavenTestModeTimer then
					HuDConfig:CancelTimer(RavenTestModeTimer)
					RavenTestModeTimer = nil
				end
				RavenTestModeTimer = HuDConfig:ScheduleTimer("RavenTestEnd", 51)
			else
				if RavenTestModeTimer then
					HuDConfig:CancelTimer(RavenTestModeTimer)
					RavenTestModeTimer = nil
				end
			end
		end)
	end
end