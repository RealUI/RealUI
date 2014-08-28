local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	if not AuroraConfig.loot then return end

	LootFramePortraitOverlay:Hide()

	select(19, LootFrame:GetRegions()):SetPoint("TOP", LootFrame, "TOP", 0, -7)

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local ic = _G["LootButton"..index.."IconTexture"]

		if not ic.bg then
			local bu = _G["LootButton"..index]

			_G["LootButton"..index.."IconQuestTexture"]:SetAlpha(0)
			_G["LootButton"..index.."NameFrame"]:Hide()

			bu:SetNormalTexture("")
			bu:SetPushedTexture("")

			local bd = CreateFrame("Frame", nil, bu)
			bd:SetPoint("TOPLEFT")
			bd:SetPoint("BOTTOMRIGHT", 114, 0)
			bd:SetFrameLevel(bu:GetFrameLevel()-1)
			F.CreateBD(bd, .25)

			ic:SetTexCoord(.08, .92, .08, .92)
			ic.bg = F.CreateBG(ic)
		end

		if select(6, GetLootSlotInfo(index)) then
			ic.bg:SetVertexColor(1, 1, 0)
		else
			ic.bg:SetVertexColor(0, 0, 0)
		end
	end)

	LootFrameDownButton:ClearAllPoints()
	LootFrameDownButton:SetPoint("BOTTOMRIGHT", -8, 6)
	LootFramePrev:ClearAllPoints()
	LootFramePrev:SetPoint("LEFT", LootFrameUpButton, "RIGHT", 4, 0)
	LootFrameNext:ClearAllPoints()
	LootFrameNext:SetPoint("RIGHT", LootFrameDownButton, "LEFT", -4, 0)

	F.ReskinPortraitFrame(LootFrame, true)
	F.ReskinArrow(LootFrameUpButton, "up")
	F.ReskinArrow(LootFrameDownButton, "down")
end)