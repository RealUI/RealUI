local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "ACP"
local ACP = nibRealUI:NewModule(MODNAME)

function ACP:Skin()
	if not ACP_AddonList then return end
	local F = Aurora[1]

	ACP_AddonList:SetScale(0.75)
	ACP_AddonListCloseButton:ClearAllPoints()
	ACP_AddonListCloseButton:SetPoint("TOPRIGHT", ACP_AddonList, "TOPRIGHT", -53, -12)
	ACP_AddonListCloseButton.SetPoint = function() end

	F.ReskinDropDown(ACP_AddonListSortDropDown)
	F.Reskin(ACP_AddonListSetButton)
	F.Reskin(ACP_AddonListDisableAll)
	F.Reskin(ACP_AddonListEnableAll)
	F.Reskin(ACP_AddonList_ReloadUI)
	F.Reskin(ACP_AddonListBottomClose)
	F.ReskinClose(ACP_AddonListCloseButton)
	F.ReskinCheck(ACP_AddonList_NoRecurse)
	F.ReskinScroll(ACP_AddonList_ScrollFrameScrollBar)

	for i = 1, 100 do
		local check = _G["ACP_AddonListEntry"..i.."Enabled"]
		if check then F.ReskinCheck(check) end

		local loadNow = _G["ACP_AddonListEntry"..i.."LoadNow"]
		if loadNow then F.Reskin(loadNow) end
	end
end
----------

function ACP:OnInitialize()
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "AddonControlPanel")
end

function ACP:OnEnable()
	if Aurora then
		self:Skin()
	end
end