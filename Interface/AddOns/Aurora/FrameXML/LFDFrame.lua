local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	LFDParentFrame:DisableDrawLayer("BACKGROUND")
	LFDParentFrameInset:DisableDrawLayer("BACKGROUND")
	LFDParentFrame:DisableDrawLayer("BORDER")
	LFDParentFrameInset:DisableDrawLayer("BORDER")
	LFDParentFrame:DisableDrawLayer("OVERLAY")

	LFDQueueFrameRandomScrollFrameScrollBackgroundTopLeft:Hide()
	LFDQueueFrameRandomScrollFrameScrollBackgroundBottomRight:Hide()

	-- this fixes right border of second reward being cut off
	LFDQueueFrameRandomScrollFrame:SetWidth(LFDQueueFrameRandomScrollFrame:GetWidth()+1)

	hooksecurefunc("LFGDungeonListButton_SetDungeon", function(button, dungeonID)
		if not button.expandOrCollapseButton.plus then
			F.ReskinCheck(button.enableButton)
			F.ReskinExpandOrCollapse(button.expandOrCollapseButton)
		end
		if LFGCollapseList[dungeonID] then
			button.expandOrCollapseButton.plus:Show()
		else
			button.expandOrCollapseButton.plus:Hide()
		end

		button.enableButton:GetCheckedTexture():SetDesaturated(true)
	end)

	local bonusValor = LFDQueueFrameRandomScrollFrameChildFrameBonusValor
	bonusValor.Border:Hide()
	bonusValor.Icon:SetTexCoord(.08, .92, .08, .92)
	bonusValor.Icon:SetPoint("CENTER", bonusValor.Border, -3, 0)
	bonusValor.Icon:SetSize(24, 24)
	bonusValor.BonusText:SetPoint("LEFT", bonusValor.Border, "RIGHT", -5, -1)
	F.CreateBG(bonusValor.Icon)

	F.CreateBD(LFDRoleCheckPopup)
	F.Reskin(LFDRoleCheckPopupAcceptButton)
	F.Reskin(LFDRoleCheckPopupDeclineButton)
	F.Reskin(LFDQueueFrameRandomScrollFrameChildFrame.bonusRepFrame.ChooseButton)
end)