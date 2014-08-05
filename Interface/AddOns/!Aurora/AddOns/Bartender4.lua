local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local ndb

local MODNAME = "SkinBar4"
local SkinBar4 = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local textures = {
	vehicle = {
		normal = [[Interface\AddOns\nibRealUI\Media\Icons\vehicle_leave_up]],
		pushed = [[Interface\AddOns\nibRealUI\Media\Icons\vehicle_leave_down]],
	},
}

function SkinBar4:Skin()
	MainMenuBarVehicleLeaveButton:SetNormalTexture(textures.vehicle.normal)
	MainMenuBarVehicleLeaveButton:SetPushedTexture(textures.vehicle.pushed)
	nibRealUI:CreateBD(MainMenuBarVehicleLeaveButton)

	-- Extra Action Button
	if ExtraActionBarFrame then
		ExtraActionBarFrame.button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		ExtraActionBarFrame.button.style:SetAlpha(0)
		nibRealUI:CreateBDFrame(ExtraActionBarFrame.button)
		ExtraActionBarFrame:HookScript("OnShow", function()
			ExtraActionBarFrame.button.style:SetAlpha(0)
		end)
	end
end

function SkinBar4:OnInitialize()
	ndb = nibRealUI.db.profile

	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "Bartender4")
end

function SkinBar4:OnEnable()
	if Bartender4 then
		self:Skin()
	end
end