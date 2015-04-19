
local knownIcons = { --list of all known raid icon chat shortcuts
	"{%a%a%d}",
	"{[Xx]}",
	"{[Ss][Tt][Aa][Rr]}",
	"{[Cc][Ii][Rr][Cc][Ll][Ee]}",
	"{[Dd][Ii][Aa][Mm][Oo][Nn][Dd]}",
	"{[Tt][Rr][Ii][Aa][Nn][Gg][Ll][Ee]}",
	"{[Mm][Oo][Oo][Nn]}",
	"{[Ss][Qq][Uu][Aa][Rr][Ee]}",
	"{[Cc][Rr][Oo][Ss][Ss]}",
	"{[Ss][Kk][Uu][Ll][Ll]}",
	--deDE
	"{[Ss][Tt][Ee][Rr][Nn]}",
	"{[Kk][Rr][Ee][Ii][Ss]}",
	"{[Dd][Ii][Aa][Mm][Aa][Nn][Tt]}",
	"{[Dd][Rr][Ee][Ii][Ee][Cc][Kk]}",
	"{[Mm][Oo][Nn][Dd]}",
	"{[Vv][Ii][Ee][Rr][Ee][Cc][Kk]}",
	"{[Kk][Rr][Ee][Uu][Zz]}",
	"{[Tt][Oo][Tt][Ee][Nn][Ss][Cc][Hh][Ää]+[Dd][Ee][Ll]}",
	--frFR
	"{[Éé]+[Tt][Oo][Ii][Ll][Ee]}",
	"{[Cc][Ee][Rr][Cc][Ll][Ee]}",
	"{[Ll][Oo][Ss][Aa][Nn][Gg][Ee]}",
	--"{[Tt][Rr][Ii][Aa][Nn][Gg][Ll][Ee]}",
	"{[Ll][Uu][Nn][Ee]}",
	"{[Cc][Aa][Rr][Rr][Éé]+}",
	"{[Cc][Rr][Oo][Ii][Xx]}",
	"{[Cc][Rr][Ââ]+[Nn][Ee]}",
	-- Feel free to add translated icons
}

BadBoyConfig:RegisterEvent("ADDON_LOADED")
BadBoyConfig:SetScript("OnEvent", function(frame, evt, addon)
	if addon ~= "BadBoy_CCleaner" then return end
	if type(BADBOY_CCLEANER) ~= "table" then
		BADBOY_CCLEANER = {
			"anal",
			"rape",
		}
	end

	local Ambiguate, gsub, prevLineId, result, modify, BADBOY_CCLEANER = Ambiguate, gsub, 0, nil, nil, BADBOY_CCLEANER

	table.sort(BADBOY_CCLEANER)
	local text
	for i=1, #BADBOY_CCLEANER do
		if not text then
			text = BADBOY_CCLEANER[i]
		else
			text = text.."\n"..BADBOY_CCLEANER[i]
		end
	end
	BadBoyCCleanerEditBox:SetText(text or "")

	--main filtering function
	local filter = function(_,event,msg,player,lang,chan,tar,flag,chanid,chanNum,chanName,u,lineId,...)
		if lineId == prevLineId then
			if modify then
				return false,modify,player,lang,chan,tar,flag,chanid,chanNum,chanName,u,lineId,...
			elseif result then
				return true
			else
				return
			end
		else
			prevLineId, modify, result = lineId, nil, nil
			local trimmedPlayer = Ambiguate(player, "none")
			if event == "CHAT_MSG_CHANNEL" and (chanid == 0 or type(chanid) ~= "number") then return end --Only scan official custom channels (gen/trade)
			if not CanComplainChat(lineId) or UnitIsInMyGuild(trimmedPlayer) then return end --Don't filter ourself/friends/guild
			local lowMsg = msg:lower() --lower all text
			for i=1, #BADBOY_CCLEANER do --scan DB for matches
				if lowMsg:find(BADBOY_CCLEANER[i], nil, true) then
					if BadBoyLog then BadBoyLog("CCleaner", event, trimmedPlayer, msg) end
					result = true
					return true --found a trigger, filter
				end
			end
			if BADBOY_NOICONS and msg:find("{", nil, true) then
				local found = 0
				for i = 1, #knownIcons do
					msg, found = gsub(msg, knownIcons[i], "")
					if found > 0 then modify = msg end --Set to true if we remove a raid icon from this message
				end
				if modify then --only modify message if we removed an icon
					return false,modify,player,lang,chan,tar,flag,chanid,chanNum,chanName,u,lineId,...
				end
			end
		end
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)

	frame:SetScript("OnEvent", nil)
	frame:UnregisterEvent("ADDON_LOADED")
end)

