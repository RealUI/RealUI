
do
	BadBoyGuildedConfigTitle:SetText("BadBoy_Guilded v7.1.1") -- Packager magic, replaced with tag version

	local guildedWhispers = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
	guildedWhispers:SetPoint("TOPLEFT", BadBoyGuildedConfigTitle, "BOTTOMLEFT")
	guildedWhispers:SetScript("OnClick", function(frame)
		local tick = frame:GetChecked()
		BADBOY_GWHISPER = tick
		PlaySound(tick and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
	end)
	guildedWhispers:SetScript("OnShow", function(frame)
		frame:SetChecked(BADBOY_GWHISPER)
	end)

	local guildedWhispersText = guildedWhispers:CreateFontString(nil, nil, "GameFontHighlight")
	guildedWhispersText:SetPoint("LEFT", guildedWhispers, "RIGHT", 0, 1)

	guildedWhispersText:SetText("Remove guild invite whispers")
	local L = GetLocale()
	if L == "frFR" then
		--guildedWhispersText:SetText("Remove guild invite whispers")
	elseif L == "deDE" then
		guildedWhispersText:SetText("Entferne geflüsterte Gildeneinladungen")
	elseif L == "zhTW" then
		--guildedWhispersText:SetText("Remove guild invite whispers")
	elseif L == "zhCN" then
		guildedWhispersText:SetText("移除公会邀请密语")
	elseif L == "esES" then
		--guildedWhispersText:SetText("Remove guild invite whispers")
	elseif L == "esMX" then
		--guildedWhispersText:SetText("Remove guild invite whispers")
	elseif L == "ruRU" then
		guildedWhispersText:SetText("Блокировать личные сообщения, содержащие приглашения в гильдию")
	elseif L == "koKR" then
		--guildedWhispersText:SetText("Remove guild invite whispers")
	elseif L == "ptBR" then
		guildedWhispersText:SetText("Remove sussurros de convites de guilda")
	elseif L == "itIT" then
		--guildedWhispersText:SetText("Remove guild invite whispers")
	end

	local guildedInvites = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
	guildedInvites:SetPoint("TOPLEFT", guildedWhispers, "BOTTOMLEFT")
	guildedInvites:SetScript("OnClick", function(frame)
		local tick = frame:GetChecked()
		SetAutoDeclineGuildInvites(tick)
		PlaySound(tick and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
	end)
	guildedInvites:SetScript("OnShow", function(frame)
		frame:SetChecked(GetAutoDeclineGuildInvites())
	end)

	local guildedInvitesText = guildedInvites:CreateFontString(nil, nil, "GameFontHighlight")
	guildedInvitesText:SetPoint("LEFT", guildedInvites, "RIGHT", 0, 1)
	guildedInvitesText:SetText(BLOCK_GUILD_INVITES)
end

