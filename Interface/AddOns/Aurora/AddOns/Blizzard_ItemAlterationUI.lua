local F, C = unpack(select(2, ...))

C.modules["Blizzard_ItemAlterationUI"] = function()
	F.SetBD(TransmogrifyFrame)
	TransmogrifyArtFrame:DisableDrawLayer("BACKGROUND")
	TransmogrifyArtFrame:DisableDrawLayer("BORDER")
	TransmogrifyArtFramePortraitFrame:Hide()
	TransmogrifyArtFramePortrait:Hide()
	TransmogrifyArtFrameTopBorder:Hide()
	TransmogrifyArtFrameTopRightCorner:Hide()
	TransmogrifyModelFrameMarbleBg:Hide()
	select(2, TransmogrifyModelFrame:GetRegions()):Hide()
	TransmogrifyModelFrameLines:Hide()
	TransmogrifyFrameButtonFrame:GetRegions():Hide()
	TransmogrifyFrameButtonFrameButtonBorder:Hide()
	TransmogrifyFrameButtonFrameButtonBottomBorder:Hide()
	TransmogrifyFrameButtonFrameMoneyLeft:Hide()
	TransmogrifyFrameButtonFrameMoneyRight:Hide()
	TransmogrifyFrameButtonFrameMoneyMiddle:Hide()

	local slots = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Back", "MainHand", "SecondaryHand"}

	for i = 1, #slots do
		local slot = _G["TransmogrifyFrame"..slots[i].."Slot"]
		if slot then
			local ic = _G["TransmogrifyFrame"..slots[i].."SlotIconTexture"]
			_G["TransmogrifyFrame"..slots[i].."SlotBorder"]:Hide()
			_G["TransmogrifyFrame"..slots[i].."SlotGrabber"]:Hide()

			ic:SetTexCoord(.08, .92, .08, .92)
			F.CreateBD(slot, 0)
		end
	end

	TransmogrifyConfirmationPopup:SetScale(UIParent:GetScale())

	F.CreateBD(TransmogrifyConfirmationPopup)
	F.CreateSD(TransmogrifyConfirmationPopup)
	F.Reskin(TransmogrifyConfirmationPopup.Button1)
	F.Reskin(TransmogrifyConfirmationPopup.Button2)

	for i = 1, 2 do
		local f = TransmogrifyConfirmationPopup["ItemFrame"..i]

		f:SetNormalTexture("")
		f:SetPushedTexture("")

		f.icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(f)

		select(8, f:GetRegions()):Hide()
	end

	F.Reskin(TransmogrifyApplyButton)
	F.ReskinClose(TransmogrifyArtFrameCloseButton)
end