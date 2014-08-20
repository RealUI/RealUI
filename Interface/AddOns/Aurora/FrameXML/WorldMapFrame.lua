local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local r, g, b = C.r, C.g, C.b

	local WorldMapFrame = WorldMapFrame
	local BorderFrame = WorldMapFrame.BorderFrame

	WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:GetRegions():Hide()
	WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:GetRegions():Hide()
	BorderFrame.Bg:Hide()
	select(2, BorderFrame:GetRegions()):Hide()
	BorderFrame.portrait:SetTexture("")
	BorderFrame.portraitFrame:SetTexture("")
	for i = 5, 7 do
		select(i, BorderFrame:GetRegions()):Hide()
	end
	BorderFrame.TopTileStreaks:SetTexture("")
	for i = 10, 14 do
		select(i, BorderFrame:GetRegions()):Hide()
	end
	BorderFrame.ButtonFrameEdge:Hide()
	BorderFrame.InsetBorderTop:Hide()
	BorderFrame.Inset.Bg:Hide()
	BorderFrame.Inset:DisableDrawLayer("BORDER")

	F.SetBD(BorderFrame, 1, 0, -3, 2)
	F.ReskinClose(BorderFrame.CloseButton)
	F.Reskin(WorldMapFrameSizeUpButton)
	F.ReskinArrow(WorldMapFrame.UIElementsFrame.CloseQuestPanelButton, "left")
	F.ReskinArrow(WorldMapFrame.UIElementsFrame.OpenQuestPanelButton, "right")
	F.ReskinDropDown(WorldMapLevelDropDown)
	F.ReskinNavBar(WorldMapFrameNavBar)

	BorderFrame.CloseButton:SetPoint("TOPRIGHT", -9, -6)

	local WorldMapFrameSizeUpButton = WorldMapFrameSizeUpButton
	WorldMapFrameSizeUpButton:SetSize(17, 17)
	WorldMapFrameSizeUpButton:ClearAllPoints()
	WorldMapFrameSizeUpButton:SetPoint("RIGHT", BorderFrame.CloseButton, "LEFT", -1, 0)

	do
		local function colourClose(f)
			if f:IsEnabled() then
				for _, pixel in pairs(f.pixels) do
					pixel:SetVertexColor(r, g, b)
				end
			end
		end

		local function clearClose(f)
			for _, pixel in pairs(f.pixels) do
				pixel:SetVertexColor(1, 1, 1)
			end
		end

		WorldMapFrameSizeUpButton.pixels = {}

		for i = 1, 8 do
			local tex = WorldMapFrameSizeUpButton:CreateTexture()
			tex:SetTexture(1, 1, 1)
			tex:SetSize(1, 1)
			tex:SetPoint("BOTTOMLEFT", 3+i, 3+i)
			tinsert(WorldMapFrameSizeUpButton.pixels, tex)
		end

		local topLine = WorldMapFrameSizeUpButton:CreateTexture()
		topLine:SetTexture(1, 1, 1)
		topLine:SetSize(7, 1)
		topLine:SetPoint("TOP", 1, -4)
		tinsert(WorldMapFrameSizeUpButton.pixels, topLine)

		local rightLine = WorldMapFrameSizeUpButton:CreateTexture()
		rightLine:SetTexture(1, 1, 1)
		rightLine:SetSize(1, 7)
		rightLine:SetPoint("RIGHT", -4, 1)
		tinsert(WorldMapFrameSizeUpButton.pixels, rightLine)

		WorldMapFrameSizeUpButton:SetScript("OnEnter", colourClose)
		WorldMapFrameSizeUpButton:SetScript("OnLeave", clearClose)
	end

	WorldMapFrameTutorialButton.Ring:Hide()
	WorldMapFrameTutorialButton:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", -12, 12)

	do
		local topLine = WorldMapFrame.UIElementsFrame:CreateTexture()
		topLine:SetTexture(0, 0, 0)
		topLine:SetHeight(1)
		topLine:SetPoint("TOPLEFT", 0, 1)
		topLine:SetPoint("TOPRIGHT", 1, 1)

		local rightLine = WorldMapFrame.UIElementsFrame:CreateTexture()
		rightLine:SetTexture(0, 0, 0)
		rightLine:SetWidth(1)
		rightLine:SetPoint("BOTTOMRIGHT", 1, 0)
		rightLine:SetPoint("TOPRIGHT", 1, 1)
	end

	local TrackingOptions = WorldMapFrame.UIElementsFrame.TrackingOptionsButton

	TrackingOptions:GetRegions():Hide()
	TrackingOptions.Background:Hide()
	TrackingOptions.IconOverlay:SetTexture("")
	TrackingOptions.Button.Border:Hide()
end)