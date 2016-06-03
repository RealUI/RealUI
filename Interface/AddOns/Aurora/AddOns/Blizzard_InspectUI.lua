local F, C = unpack(select(2, ...))

C.themes["Blizzard_InspectUI"] = function()
	InspectModelFrame:DisableDrawLayer("OVERLAY")

	InspectTalentFrame:GetRegions():Hide()
	select(2, InspectTalentFrame:GetRegions()):Hide()
	InspectGuildFrameBG:Hide()
	for i = 1, 5 do
		select(i, InspectModelFrame:GetRegions()):Hide()
	end

	-- Character

	select(10, InspectMainHandSlot:GetRegions()):Hide()

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Inspect"..slots[i].."Slot"]
		local border = slot.IconBorder

		_G["Inspect"..slots[i].."SlotFrame"]:Hide()

		slot:SetNormalTexture("")
		slot:SetPushedTexture("")

		border:SetTexture(C.media.backdrop)
		border:SetPoint("TOPLEFT", -1, 1)
		border:SetPoint("BOTTOMRIGHT", 1, -1)
		border:SetDrawLayer("BACKGROUND")

		slot.icon:SetTexCoord(.08, .92, .08, .92)
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		button.icon:SetShown(button.hasItem)
	end)

	-- PvP

	InspectPVPFrame.BG:Hide()

	for i = 1, 3 do
		local div = InspectPVPFrame["Div"..i]

		if C.isBetaClient then
			div:SetColorTexture(1, 1, 1, .2)
		else
			div:SetTexture(1, 1, 1, .2)
		end
		div:SetHeight(1)
	end

	-- Talents

	local inspectSpec = InspectTalentFrame.InspectSpec

	inspectSpec.ring:Hide()

	for i = 1, 7 do
		local row = InspectTalentFrame.InspectTalents["tier"..i]
		for j = 1, 3 do
			local bu = row["talent"..j]

			bu.Slot:Hide()
			bu.border:SetTexture("")

			bu.icon:SetDrawLayer("ARTWORK")
			bu.icon:SetTexCoord(.08, .92, .08, .92)

			F.CreateBG(bu.icon)
		end
	end

	inspectSpec.specIcon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBG(inspectSpec.specIcon)

	local function updateIcon(self)
		local spec = nil
		if INSPECTED_UNIT ~= nil then
			spec = GetInspectSpecialization(INSPECTED_UNIT)
		end
		if spec ~= nil and spec > 0 then
			local role1 = GetSpecializationRoleByID(spec)
			if role1 ~= nil then
				local _, _, _, icon = GetSpecializationInfoByID(spec)
				self.specIcon:SetTexture(icon)
			end
		end
	end

	inspectSpec:HookScript("OnShow", updateIcon)
	InspectTalentFrame:HookScript("OnEvent", function(self, event, unit)
		if not InspectFrame:IsShown() then return end
		if event == "INSPECT_READY" and InspectFrame.unit and UnitGUID(InspectFrame.unit) == unit then
			updateIcon(self.InspectSpec)
		end
	end)

	local roleIcon = inspectSpec.roleIcon

	roleIcon:SetTexture(C.media.roleIcons)

	do
		local left = inspectSpec:CreateTexture(nil, "OVERLAY")
		left:SetWidth(1)
		left:SetTexture(C.media.backdrop)
		left:SetVertexColor(0, 0, 0)
		left:SetPoint("TOPLEFT", roleIcon, 2, -2)
		left:SetPoint("BOTTOMLEFT", roleIcon, 2, 2)

		local right = inspectSpec:CreateTexture(nil, "OVERLAY")
		right:SetWidth(1)
		right:SetTexture(C.media.backdrop)
		right:SetVertexColor(0, 0, 0)
		right:SetPoint("TOPRIGHT", roleIcon, -2, -2)
		right:SetPoint("BOTTOMRIGHT", roleIcon, -2, 2)

		local top = inspectSpec:CreateTexture(nil, "OVERLAY")
		top:SetHeight(1)
		top:SetTexture(C.media.backdrop)
		top:SetVertexColor(0, 0, 0)
		top:SetPoint("TOPLEFT", roleIcon, 2, -2)
		top:SetPoint("TOPRIGHT", roleIcon, -2, -2)

		local bottom = inspectSpec:CreateTexture(nil, "OVERLAY")
		bottom:SetHeight(1)
		bottom:SetTexture(C.media.backdrop)
		bottom:SetVertexColor(0, 0, 0)
		bottom:SetPoint("BOTTOMLEFT", roleIcon, 2, 2)
		bottom:SetPoint("BOTTOMRIGHT", roleIcon, -2, 2)
	end

	if not C.isBetaClient then
		local function updateGlyph(self, clear)
			local id = self:GetID()
			local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup
			local enabled, glyphType, glyphTooltipIndex, glyphSpell, iconFilename = GetGlyphSocketInfo(id, talentGroup, true, INSPECTED_UNIT);

			if not glyphType then return end

			if enabled and glyphSpell and not clear then
				if iconFilename then
					self.glyph:SetTexture(iconFilename)
				else
					self.glyph:SetTexture("Interface\\Spellbook\\UI-Glyph-Rune1")
				end
			end
		end

		hooksecurefunc("InspectGlyphFrameGlyph_UpdateSlot", updateGlyph)

		for i = 1, 6 do
			local glyph = InspectTalentFrame.InspectGlyphs["Glyph"..i]

			glyph:HookScript("OnShow", updateGlyph)

			glyph.ring:Hide()

			glyph.glyph:SetDrawLayer("ARTWORK")
			glyph.glyph:SetTexCoord(.08, .92, .08, .92)
			F.CreateBDFrame(glyph.glyph, .25)
		end
	end

	for i = 1, 4 do
		local tab = _G["InspectFrameTab"..i]
		F.ReskinTab(tab)
		if i ~= 1 then
			tab:SetPoint("LEFT", _G["InspectFrameTab"..i-1], "RIGHT", -15, 0)
		end
	end

	F.ReskinPortraitFrame(InspectFrame, true)
end
