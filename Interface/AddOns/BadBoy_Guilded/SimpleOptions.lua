
do
	BadBoyGuildedConfigTitle:SetText("BadBoy_Guilded r247-release") --wowace magic, replaced with tag version

	local guildedWhispers = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
	guildedWhispers:SetPoint("TOPLEFT", BadBoyConfigPopupButton, "BOTTOMLEFT", 0, -67)
	guildedWhispers:SetScript("OnClick", function(frame)
		local tick = frame:GetChecked()
		if tick then
			PlaySound("igMainMenuOptionCheckBoxOn")
			BADBOY_GWHISPER = true
		else
			PlaySound("igMainMenuOptionCheckBoxOff")
			BADBOY_GWHISPER = nil
		end
	end)
	guildedWhispers:SetScript("OnShow", function(frame)
		frame:SetChecked(BADBOY_GWHISPER)
	end)

	local guildedWhispersText = guildedWhispers:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	guildedWhispersText:SetPoint("LEFT", guildedWhispers, "RIGHT", 0, 1)

	guildedWhispersText:SetText("Remove guild invite whispers")
	local L = GetLocale()
	if L == "frFR" then
		guildedWhispersText:SetText("Remove guild invite whispers")
	elseif L == "deDE" then
		guildedWhispersText:SetText("Entferne geflüsterte Gildeneinladungen")
	elseif L == "zhTW" then
		guildedWhispersText:SetText("Remove guild invite whispers")
	elseif L == "zhCN" then
		guildedWhispersText:SetText("移除公会邀请密语")
	elseif L == "esES" then
		guildedWhispersText:SetText("Remove guild invite whispers")
	elseif L == "esMX" then
		guildedWhispersText:SetText("Remove guild invite whispers")
	elseif L == "ruRU" then
		guildedWhispersText:SetText("Блокировать личные сообщения, содержащие приглашения в гильдию")
	elseif L == "koKR" then
		guildedWhispersText:SetText("Remove guild invite whispers")
	elseif L == "ptBR" then
		guildedWhispersText:SetText("Remove sussurros de convites de guilda")
	elseif L == "itIT" then
		guildedWhispersText:SetText("Remove guild invite whispers")
	end

	local guildedInvites = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
	guildedInvites:SetPoint("TOPLEFT", BadBoyConfigPopupButton, "BOTTOMLEFT", 0, -87)
	guildedInvites:SetScript("OnClick", function(frame)
		local tick = frame:GetChecked()
		SetAutoDeclineGuildInvites(tick)
	end)
	guildedInvites:SetScript("OnShow", function(frame)
		frame:SetChecked(GetAutoDeclineGuildInvites())
	end)

	local guildedInvitesText = guildedInvites:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	guildedInvitesText:SetPoint("LEFT", guildedInvites, "RIGHT", 0, 1)
	guildedInvitesText:SetText(BLOCK_GUILD_INVITES)
end

