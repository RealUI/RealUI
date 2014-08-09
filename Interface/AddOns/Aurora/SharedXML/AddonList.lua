local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	F.ReskinPortraitFrame(AddonList, true)
	F.Reskin(AddonListEnableAllButton)
	F.Reskin(AddonListDisableAllButton)
	F.Reskin(AddonListCancelButton)
	F.Reskin(AddonListOkayButton)
	F.ReskinCheck(AddonListForceLoad)
	F.ReskinDropDown(AddonCharacterDropDown)

	AddonCharacterDropDown:SetWidth(170)

	for i = 1, MAX_ADDONS_DISPLAYED do
		F.ReskinCheck(_G["AddonListEntry"..i.."Enabled"])
	end
end)