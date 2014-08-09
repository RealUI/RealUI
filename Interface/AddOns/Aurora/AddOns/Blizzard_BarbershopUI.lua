local F, C = unpack(select(2, ...))

C.themes["Blizzard_BarbershopUI"] = function()
	BarberShopFrameBackground:Hide()
	BarberShopFrameMoneyFrame:GetRegions():Hide()
	BarberShopAltFormFrameBackground:Hide()
	BarberShopAltFormFrameBorder:Hide()

	BarberShopAltFormFrame:ClearAllPoints()
	BarberShopAltFormFrame:SetPoint("BOTTOM", BarberShopFrame, "TOP", 0, -74)

	F.SetBD(BarberShopFrame, 44, -75, -40, 44)
	F.SetBD(BarberShopAltFormFrame, 0, 0, 2, -2)

	F.Reskin(BarberShopFrameOkayButton)
	F.Reskin(BarberShopFrameCancelButton)
	F.Reskin(BarberShopFrameResetButton)

	F.ReskinArrow(BarberShopFrameSelector1Prev, "left")
	F.ReskinArrow(BarberShopFrameSelector1Next, "right")
	F.ReskinArrow(BarberShopFrameSelector2Prev, "left")
	F.ReskinArrow(BarberShopFrameSelector2Next, "right")
	F.ReskinArrow(BarberShopFrameSelector3Prev, "left")
	F.ReskinArrow(BarberShopFrameSelector3Next, "right")
	F.ReskinArrow(BarberShopFrameSelector4Prev, "left")
	F.ReskinArrow(BarberShopFrameSelector4Next, "right")
end