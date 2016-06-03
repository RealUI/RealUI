local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	CharacterFrameInsetRight:DisableDrawLayer("BACKGROUND")
	CharacterFrameInsetRight:DisableDrawLayer("BORDER")

	F.ReskinPortraitFrame(CharacterFrame, true)

	local i = 1
	while _G["CharacterFrameTab"..i] do
		F.ReskinTab(_G["CharacterFrameTab"..i])
		i = i + 1
	end

	-- [[ Expand button ]]
	if not C.isBetaClient then
		CharacterFrameExpandButton:GetNormalTexture():SetAlpha(0)
		CharacterFrameExpandButton:GetPushedTexture():SetAlpha(0)

		F.ReskinArrow(CharacterFrameExpandButton, "left")

		CharacterFrameExpandButton:SetPoint("BOTTOMRIGHT", CharacterFrameInset, "BOTTOMRIGHT", -14, 6)

		hooksecurefunc("CharacterFrame_Expand", function()
			CharacterFrameExpandButton.tex:SetTexture(C.media.arrowLeft)
		end)

		hooksecurefunc("CharacterFrame_Collapse", function()
			CharacterFrameExpandButton.tex:SetTexture(C.media.arrowRight)
		end)
	end
end)
