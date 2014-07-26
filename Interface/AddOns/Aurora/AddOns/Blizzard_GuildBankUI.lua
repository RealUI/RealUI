local F, C = unpack(select(2, ...))

C.modules["Blizzard_GuildBankUI"] = function()
	GuildBankFrame:DisableDrawLayer("BACKGROUND")
	GuildBankFrame:DisableDrawLayer("BORDER")
	GuildBankFrame:DisableDrawLayer("OVERLAY")
	GuildBankTabTitle:SetDrawLayer("ARTWORK")

	GuildBankEmblemFrame:Hide()
	GuildBankPopupFrameTopLeft:Hide()
	GuildBankPopupFrameBottomLeft:Hide()
	GuildBankMoneyFrameBackground:Hide()
	select(2, GuildBankPopupFrame:GetRegions()):Hide()
	select(4, GuildBankPopupFrame:GetRegions()):Hide()
	GuildBankPopupNameLeft:Hide()
	GuildBankPopupNameMiddle:Hide()
	GuildBankPopupNameRight:Hide()
	GuildBankPopupScrollFrame:GetRegions():Hide()
	select(2, GuildBankPopupScrollFrame:GetRegions()):Hide()
	for i = 1, 2 do
		select(i, GuildBankTransactionsScrollFrame:GetRegions()):Hide()
		select(i, GuildBankInfoScrollFrame:GetRegions()):Hide()
	end

	F.SetBD(GuildBankFrame)
	F.Reskin(GuildBankFrameWithdrawButton)
	F.Reskin(GuildBankFrameDepositButton)
	F.Reskin(GuildBankFramePurchaseButton)
	F.Reskin(GuildBankPopupOkayButton)
	F.Reskin(GuildBankPopupCancelButton)
	F.Reskin(GuildBankInfoSaveButton)
	F.ReskinClose(GuildBankFrame.CloseButton)
	F.ReskinScroll(GuildBankTransactionsScrollFrameScrollBar)
	F.ReskinScroll(GuildBankInfoScrollFrameScrollBar)
	F.ReskinScroll(GuildBankPopupScrollFrameScrollBar)
	F.ReskinInput(GuildItemSearchBox)

	for i = 1, 4 do
		local tab = _G["GuildBankFrameTab"..i]
		F.ReskinTab(tab)

		if i ~= 1 then
			tab:SetPoint("LEFT", _G["GuildBankFrameTab"..i-1], "RIGHT", -15, 0)
		end
	end

	local bd = CreateFrame("Frame", nil, GuildBankPopupFrame)
	bd:SetPoint("TOPLEFT")
	bd:SetPoint("BOTTOMRIGHT", -28, 26)
	bd:SetFrameLevel(GuildBankPopupFrame:GetFrameLevel()-1)
	F.CreateBD(bd)
	F.CreateBD(GuildBankPopupEditBox, .25)

	GuildBankPopupFrame:SetPoint("TOPLEFT", GuildBankFrame, "TOPRIGHT", 2, -30)

	GuildBankFrameWithdrawButton:SetPoint("RIGHT", GuildBankFrameDepositButton, "LEFT", -1, 0)

	for i = 1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..i]:GetRegions():Hide()
		for j = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local bu = _G["GuildBankColumn"..i.."Button"..j]

			bu:SetNormalTexture("")
			bu:SetPushedTexture("")

			bu.icon:SetTexCoord(.08, .92, .08, .92)
		end
	end

	local function updateButtons()
		local tab = GetCurrentGuildBankTab()

		for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			local index = math.fmod(i, 14)
			if index == 0 then
				index = 14
			end
			local column = math.ceil((i-0.5)/14)

			local slotLink = GetGuildBankItemLink(tab, i)
			local slotFrame = _G["GuildBankColumn"..column.."Button"..index]

			F.ColourQuality(slotFrame, slotLink)
		end
	end

	hooksecurefunc("GuildBankFrame_UpdateFiltered", updateButtons)
	hooksecurefunc("GuildBankFrame_Update", updateButtons)

	for i = 1, 8 do
		local tb = _G["GuildBankTab"..i]
		local bu = _G["GuildBankTab"..i.."Button"]
		local ic = _G["GuildBankTab"..i.."ButtonIconTexture"]
		local nt = _G["GuildBankTab"..i.."ButtonNormalTexture"]

		bu:SetCheckedTexture(C.media.checked)
		F.CreateBG(bu)

		local a1, p, a2, x, y = bu:GetPoint()
		bu:SetPoint(a1, p, a2, x + 1, y)

		ic:SetTexCoord(.08, .92, .08, .92)
		tb:GetRegions():Hide()
		nt:SetAlpha(0)
	end

	for i = 1, NUM_GUILDBANK_ICONS_PER_ROW * NUM_GUILDBANK_ICON_ROWS do
		local bu = _G["GuildBankPopupButton"..i]

		bu:SetCheckedTexture(C.media.checked)
		select(2, bu:GetRegions()):Hide()

		_G["GuildBankPopupButton"..i.."Icon"]:SetTexCoord(.08, .92, .08, .92)

		F.CreateBG(_G["GuildBankPopupButton"..i.."Icon"])
	end
end