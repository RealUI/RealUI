local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	F.ReskinPortraitFrame(AddonList, true)
	F.Reskin(AddonListEnableAllButton)
	F.Reskin(AddonListDisableAllButton)
	F.Reskin(AddonListCancelButton)
	F.Reskin(AddonListOkayButton)
	F.ReskinCheck(AddonListForceLoad)
	F.ReskinDropDown(AddonCharacterDropDown)
	F.ReskinScroll(AddonListScrollFrameScrollBar)

	AddonCharacterDropDown:SetWidth(170)

	for i = 1, MAX_ADDONS_DISPLAYED do
		F.ReskinCheck(_G["AddonListEntry"..i.."Enabled"])
		F.Reskin(_G["AddonListEntry"..i.."Load"])
	end
end)