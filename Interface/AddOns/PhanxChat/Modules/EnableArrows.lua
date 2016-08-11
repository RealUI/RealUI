--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
	https://github.com/Phanx/PhanxChat
----------------------------------------------------------------------]]

local _, PhanxChat = ...

local history = {}
local index = {}

local function AddHistoryLine(frame, text)
	if not text or strlen(text) == 0 then
		return
	end
	local command = strmatch(text, "^(/%S+)")
	if command and IsSecureCmd(command) then
		-- SetText with a secure command will cause a blocked action error
		return
	end
	--print("AddHistoryLine", text)
	for i = 1, #history[frame] do
		if history[frame][i] == text then
			index[frame] = i + 1
			return
		end
	end
	tinsert(history[frame], text)
	while #history[frame] > frame:GetHistoryLines() do
		tremove(history[frame], 1)
	end
	index[frame] = #history[frame] + 1
end

local function IncrementHistorySelection(frame, increment)
	--print("IncrementHistorySelection", increment)
	if #history[frame] == 0 then
		return
	end
	local target = index[frame] + increment
	if target < 1 then
		target = #history[frame]
	elseif target > #history[frame] then
		target = 1
	end
	index[frame] = target

	local prev = frame:GetText()
	local text = history[frame][target]
	if text ~= prev then
		frame:SetText(strtrim(text)) -- FUCK OFF SPACES
		frame:SetCursorPosition(strlen(text))
	end

end

local function OnArrowPressed(self, key)
	--print("OnArrowPressed", key)
	if PhanxChat.db.EnableArrows and not AutoCompleteBox:IsShown() then
		if key == "UP" then
			return IncrementHistorySelection(self, -1)
		elseif key == "DOWN" then
			return IncrementHistorySelection(self, 1)
		end
	end
end

------------------------------------------------------------------------

function PhanxChat:EnableArrows(frame)
	local editBox = _G[frame:GetName() .. "EditBox"]
	if editBox then
		editBox:SetAltArrowKeyMode(not self.db.EnableArrows)
		if not history[editBox] then
			hooksecurefunc(editBox, "AddHistoryLine", AddHistoryLine)
			editBox:HookScript("OnArrowPressed", OnArrowPressed)
			history[editBox] = {}
			index[editBox] = 1
		end
	end
end

function PhanxChat:SetEnableArrows(v)
	if self.debug then print("PhanxChat: SetEnableArrows", v) end
	if type(v) == "boolean" then
		self.db.EnableArrows = v
	end

	for frame in pairs(self.frames) do
		self:EnableArrows(frame)
	end
end

table.insert(PhanxChat.RunOnLoad, PhanxChat.SetEnableArrows)
table.insert(PhanxChat.RunOnProcessFrame, PhanxChat.EnableArrows)