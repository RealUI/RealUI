local F, C = unpack(select(2, ...))

C.themes["Blizzard_BarbershopUI"] = function()
	BarberShopFrame:GetRegions():Hide()
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

	for i = 1, 5 do
		F.ReskinArrow(_G["BarberShopFrameSelector"..i.."Prev"], "left")
		F.ReskinArrow(_G["BarberShopFrameSelector"..i.."Next"], "right")
	end

	-- [[ Banner frame ]]

	BarberShopBannerFrameBGTexture:Hide()

	F.SetBD(BarberShopBannerFrame, 25, -80, -20, 75)
end