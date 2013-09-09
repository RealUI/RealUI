local F, C = unpack(select(2, ...))

tinsert(C.modules["Aurora"], function()
	FlexRaidFrameBottomInset.Bg:Hide()
	FlexRaidFrameBottomInset:DisableDrawLayer("BORDER")

	FlexRaidFrameScrollFrameScrollBackground:Hide()
	FlexRaidFrameScrollFrameBackground:Hide()
	FlexRaidFrameScrollFrameBackgroundCover:Hide()
	FlexRaidFrameScrollFrameScrollBackgroundTopLeft:Hide()
	FlexRaidFrameScrollFrameScrollBackgroundBottomRight:Hide()

	F.Reskin(FlexRaidFrame.StartButton)
	F.ReskinDropDown(FlexRaidFrameSelectionDropDown)
end)