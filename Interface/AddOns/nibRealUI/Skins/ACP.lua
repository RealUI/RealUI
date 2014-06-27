local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "ACP"
local ACP = nibRealUI:NewModule(MODNAME)

function ACP:Skin()
	if not ACP_AddonList then return end
	local F = Aurora[1]

	ACP_AddonList:SetScale(0.75)
	ACP_AddonList:SetSize(600, 490)
	for i = 1, 6 do
		select(i, ACP_AddonList:GetRegions()):Hide()
	end
	F.CreateBD(ACP_AddonList)
	F.CreateSD(ACP_AddonList)

	ACP_AddonListHeader:ClearAllPoints()
	ACP_AddonListHeader:SetPoint("TOP", ACP_AddonList, "TOP", -10, 5)
	ACP_AddonListHeader.SetPoint = function() end

	ACP_AddonListSortDropDown:SetSize(170, 22)
	ACP_AddonListSortDropDown:ClearAllPoints()
	ACP_AddonListSortDropDown:SetPoint("RIGHT", ACP_AddonListCloseButton, "LEFT", -25, -2)

	ACP_AddonList_ScrollFrame:ClearAllPoints()
	ACP_AddonList_ScrollFrame:SetPoint("TOPLEFT", ACP_AddonList, "TOPLEFT", 18, -33)
	ACP_AddonList_ScrollFrame:SetPoint("BOTTOMRIGHT", ACP_AddonList, "BOTTOMRIGHT", -29, 36)
	ACP_AddonListEntry1:ClearAllPoints()
	ACP_AddonListEntry1:SetPoint("TOPLEFT", ACP_AddonList_ScrollFrame, "TOPLEFT", 35, -20)

	ACP_AddonListSetButton:ClearAllPoints()
	ACP_AddonListSetButton:SetPoint("BOTTOMLEFT", ACP_AddonList, "BOTTOMLEFT", 6, 6)
	ACP_AddonListDisableAll:ClearAllPoints()
	ACP_AddonListDisableAll:SetPoint("LEFT", ACP_AddonListSetButton, "RIGHT", 30, 0)
	ACP_AddonListEnableAll:ClearAllPoints()
	ACP_AddonListEnableAll:SetPoint("LEFT", ACP_AddonListDisableAll, "RIGHT", 6, 0)

	ACP_AddonListBottomClose:ClearAllPoints()
	ACP_AddonListBottomClose:SetPoint("BOTTOMRIGHT", ACP_AddonList, "BOTTOMRIGHT", -6, 6)
	ACP_AddonList_ReloadUI:ClearAllPoints()
	ACP_AddonList_ReloadUI:SetPoint("RIGHT", ACP_AddonListBottomClose, "LEFT", -6, 0)

	F.ReskinDropDown(ACP_AddonListSortDropDown)
	F.ReskinClose(ACP_AddonListCloseButton, "TOPRIGHT", ACP_AddonList, "TOPRIGHT", -6, -6)
	F.Reskin(ACP_AddonListSetButton)
	F.Reskin(ACP_AddonListDisableAll)
	F.Reskin(ACP_AddonListEnableAll)
	F.Reskin(ACP_AddonList_ReloadUI)
	F.Reskin(ACP_AddonListBottomClose)
	F.ReskinCheck(ACP_AddonList_NoRecurse)
	F.ReskinScroll(ACP_AddonList_ScrollFrameScrollBar)

	for i = 1, 100 do
		local check = _G["ACP_AddonListEntry"..i.."Enabled"]
		if check then 
            check:SetWidth(24)
            check.SetWidth = function() end
            check:SetHeight(24)
            check.SetHeight = function() end
			F.ReskinCheck(check)
		end

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
