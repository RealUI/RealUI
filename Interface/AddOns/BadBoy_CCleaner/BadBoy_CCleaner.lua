
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(frame, _, addon)
	if addon ~= "BadBoy_CCleaner" then return end
	if type(BADBOY_CCLEANER) ~= "table" then
		BADBOY_CCLEANER = {
			"anal",
			"rape",
		}
	end

	local Ambiguate, prevLineId, result, BADBOY_CCLEANER = Ambiguate, 0, nil, BADBOY_CCLEANER
	local BadBoyIsFriendly = BadBoyIsFriendly

	--main filtering function
	local filter = function(_,event,msg,player,_,_,_,flag,chanid,_,_,_,lineId,guid)
		if lineId == prevLineId then
			return result
		else
			prevLineId, result = lineId, nil
			local trimmedPlayer = Ambiguate(player, "none")
			if event == "CHAT_MSG_CHANNEL" and (chanid == 0 or type(chanid) ~= "number") then return end --Only scan official custom channels (gen/trade)
			if BadBoyIsFriendly(trimmedPlayer, flag, lineId, guid) then return end
			local lowMsg = msg:lower() --lower all text
			for i=1, #BADBOY_CCLEANER do --scan DB for matches
				if lowMsg:find(BADBOY_CCLEANER[i], nil, true) then
					if BadBoyLog then BadBoyLog("CCleaner", event, trimmedPlayer, msg) end
					result = true
					return true --found a trigger, filter
				end
			end
		end
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)

	frame:SetScript("OnEvent", nil)
	frame:UnregisterEvent("ADDON_LOADED")
end)

