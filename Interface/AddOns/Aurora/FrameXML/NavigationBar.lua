local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local r, g, b = C.r, C.g, C.b

	local function moveNavButtons(self)
		for i=1, #self.navList do
			local navButton = self.navList[i]
			local lastNav = self.navList[i-1]
			if navButton and lastNav then
				navButton:ClearAllPoints()
				navButton:SetPoint("LEFT", lastNav, "RIGHT", 1, 0)
			end
		end
	end

	hooksecurefunc("NavBar_Initialize", F.ReskinNavBar)

	hooksecurefunc("NavBar_AddButton", function(self, buttonData)
		local navButton = self.navList[#self.navList]

		if not navButton.restyled then
			F.Reskin(navButton)

			navButton.arrowUp:SetAlpha(0)
			navButton.arrowDown:SetAlpha(0)

			navButton.selected:SetDrawLayer("BACKGROUND", 1)
			navButton.selected:SetTexture(r, g, b, .3)

			navButton:HookScript("OnClick", function()
				moveNavButtons(self)
			end)

			-- arrow button

			local arrowButton = navButton.MenuArrowButton

			arrowButton.Art:Hide()

			arrowButton:SetHighlightTexture("")

			local tex = arrowButton:CreateTexture(nil, "ARTWORK")
			tex:SetTexture(C.media.arrowDown)
			tex:SetSize(8, 8)
			tex:SetPoint("CENTER")
			arrowButton.tex = tex

			local colourArrow, clearArrow = F.colourArrow, F.clearArrow
			arrowButton:SetScript("OnEnter", colourArrow)
			arrowButton:SetScript("OnLeave", clearArrow)

			navButton.restyled = true
		end

		moveNavButtons(self)
	end)
end)