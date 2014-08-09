local F, C = unpack(select(2, ...))

C.themes["Blizzard_ItemAlterationUI"] = function()
	local r, g, b = C.r, C.g, C.b

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

	local function colourPopout(self)
		self.arrow:SetVertexColor(r, g, b)
	end

	local function clearPopout(self)
		self.arrow:SetVertexColor(1, 1, 1)
	end

	local slots = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Back", "MainHand", "SecondaryHand"}

	for i = 1, #slots do
		local slot = _G["TransmogrifyFrame"..slots[i].."Slot"]
		if slot then
			slot.altTexture:SetTexture("")
			_G["TransmogrifyFrame"..slots[i].."SlotBorder"]:Hide()
			_G["TransmogrifyFrame"..slots[i].."SlotGrabber"]:Hide()

			slot.icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBD(slot, 0)

			local popout = slot.popoutButton

			popout:SetNormalTexture("")
			popout:SetHighlightTexture("")

			local arrow = popout:CreateTexture(nil, "OVERLAY")

			if slot.verticalFlyout then
				arrow:SetSize(13, 8)
				arrow:SetTexture(C.media.arrowDown)
				arrow:SetPoint("TOP", slot, "BOTTOM", 0, 1)
			else
				arrow:SetSize(8, 14)
				arrow:SetTexture(C.media.arrowRight)
				arrow:SetPoint("LEFT", slot, "RIGHT", -1, 0)
			end

			popout.arrow = arrow

			colourPopout(popout)

			popout:HookScript("OnEnter", clearPopout)
			popout:HookScript("OnLeave", colourPopout)
		end
	end

	hooksecurefunc("TransmogrifyFrame_UpdateSlotButton", function(button)
		if button.altTexture:IsShown() then
			button:SetBackdropBorderColor(.87, .5, 1)
		else
			button:SetBackdropBorderColor(0, 0, 0)
		end

		local pendingFrame = button.pendingFrame

		if pendingFrame then
			local glow = pendingFrame:GetRegions()

			glow:SetTexture("")

			if glow:IsShown() then
				button:SetBackdropBorderColor(.87, .5, 1)
			elseif not button.altTexture:IsShown() then
				button:SetBackdropBorderColor(0, 0, 0)
			end

			pendingFrame.ants:ClearAllPoints()
			pendingFrame.ants:SetPoint("TOPLEFT", -7, 7)
			pendingFrame.ants:SetPoint("BOTTOMRIGHT", 7, -7)
		end
	end)

	F.CreateBD(TransmogrifyConfirmationPopup)
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