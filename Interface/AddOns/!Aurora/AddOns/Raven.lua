local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local ndb

local MODNAME = "SkinRaven"
local SkinRaven = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

-- Set font
function SkinRaven:UpdateFonts()
	if not(nibRealUI:DoesAddonStyle("Raven") and IsAddOnLoaded("Raven")) then return end
	if not(Raven and Raven.db) then return end
	Raven.db.global.Defaults.timeFont = nibRealUI:Font(true)
	Raven.db.global.Defaults.labelFont = nibRealUI:Font(true)
	Raven.db.global.Defaults.iconFont = nibRealUI:Font(true)
	Raven:UpdateAllBarGroups()
end

function SkinRaven:OnInitialize()
	ndb = nibRealUI.db.profile

	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "Raven")
end

function SkinRaven:OnEnable()
	if nibRealUI:DoesAddonStyle("Raven") and IsAddOnLoaded("Raven") then
		self:UpdateFonts()
	end
end