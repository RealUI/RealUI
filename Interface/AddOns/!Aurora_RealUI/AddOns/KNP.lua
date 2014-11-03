local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "KNP"
local KNP = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
local kuiNP
local knUpdateScheduled = false

function KNP:UpdateKNPFontScale()
	if IsAddOnLoaded("Kui_Nameplates") and nibRealUI:GetModuleEnabled(MODNAME) then
		if kuiNP.db.profile then
			local screenHeight = string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
			local scale = ceil(((768 * (nibRealUI.font.pixel1[2] / kuiNP.defaultSizes.font.name)) / screenHeight) * 100) / 100

			kuiNP.db.profile.fonts.options.fontscale = scale
			kuiNP:ScaleSizes("font")
			for _, frame in pairs(kuiNP.frameList) do
				-- Kui_Nameplates\core.lua
				kuiNP.configChangedFuncs.fontscale(frame.kui, kuiNP.db.profile.fonts.options.fontscale)
			end
		end
	end
	knUpdateScheduled = false
end

function KNP:UI_SCALE_CHANGED()
	-- Update KN font scale
	if (nibRealUICharacter and nibRealUICharacter.installStage == -1) then
		if not knUpdateScheduled then
			knUpdateScheduled = true
			self:ScheduleTimer("UpdateKNPFontScale", 2)
		end
	end
end

function KNP:PLAYER_LOGIN()
	self:UI_SCALE_CHANGED()
	self:UpdateFonts()
end

function KNP:UpdateFonts()
	if not kuiNP then return end
	
	kuiNP.db.profile.fonts.options.font = nibRealUI:Font(true)
	kuiNP.font = nibRealUI:Font()[1]
	if kuiNP.db.profile then
		for _, frame in pairs(kuiNP.frameList) do
			if frame.kui then
				-- Kui_Nameplates\core.lua
				kuiNP.configChangedFuncs.runOnce.font(kuiNP.db.profile.fonts.options.font)
			end
		end
	end
end

function KNP:OnInitialize()
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "KuiNameplates")
end

function KNP:OnEnable()
	if nibRealUI:DoesAddonStyle("KuiNameplates") and IsAddOnLoaded("Kui_Nameplates") then
		kuiNP = LibStub("AceAddon-3.0"):GetAddon("KuiNameplates", true)
		if kuiNP then
			self:RegisterEvent("UI_SCALE_CHANGED")
			self:RegisterEvent("PLAYER_LOGIN")
		end
	end
end