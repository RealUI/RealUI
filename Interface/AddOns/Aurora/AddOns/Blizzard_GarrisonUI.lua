local F, C = unpack(select(2, ...))

C.themes["Blizzard_GarrisonUI"] = function()
	-- [[ Capacitive display frame ]]

	local GarrisonCapacitiveDisplayFrame = GarrisonCapacitiveDisplayFrame

	F.ReskinPortraitFrame(GarrisonCapacitiveDisplayFrame, true)
	F.Reskin(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton, true)

	-- Capacitive display

	local CapacitiveDisplay = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay

	CapacitiveDisplay.IconBG:SetAlpha(0)

	do
		local icon = CapacitiveDisplay.ShipmentIconFrame.Icon

		icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(icon)
	end

	do
		local reagentIndex = 1

		hooksecurefunc("GarrisonCapacitiveDisplayFrame_Update", function(self)
			local reagents = CapacitiveDisplay.Reagents

			local reagent = reagents[reagentIndex]
			while reagent do
				reagent.NameFrame:SetAlpha(0)

				reagent.Icon:SetTexCoord(.08, .92, .08, .92)
				reagent.Icon:SetDrawLayer("BORDER")
				F.CreateBG(reagent.Icon)

				local bg = CreateFrame("Frame", nil, reagent)
				bg:SetPoint("TOPLEFT")
				bg:SetPoint("BOTTOMRIGHT", 0, 2)
				bg:SetFrameLevel(reagent:GetFrameLevel() - 1)
				F.CreateBD(bg, .25)

				reagentIndex = reagentIndex + 1
				reagent = reagents[reagentIndex]
			end
		end)
	end
end