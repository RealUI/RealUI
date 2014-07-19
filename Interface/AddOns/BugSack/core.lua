
local addonName, addon = ...

-----------------------------------------------------------------------
-- Make sure we are prepared
--

local function print(...) _G.print("|cff259054BugSack:|r", ...) end
if not LibStub then
	print("BugSack requires LibStub.")
	return
end

local L = addon.L
local BugGrabber = BugGrabber
if not BugGrabber then
	local msg = L["|cffff4411BugSack requires the |r|cff44ff44!BugGrabber|r|cffff4411 addon, which you can download from the same place you got BugSack. Happy bug hunting!|r"]
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", function()
		RaidNotice_AddMessage(RaidWarningFrame, msg, {r=1, g=0.3, b=0.1})
		print(msg)
		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", nil)
		f = nil
	end)
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	return
end

-- We seem fine, let the world access us.
_G[addonName] = addon
addon.healthCheck = true

-----------------------------------------------------------------------
-- Utility
--

do
	-- bah this should be local but we need it in config.lua
	local media = nil
	function addon:EnsureLSM3()
		if media then return media end
		media = LibStub("LibSharedMedia-3.0", true)
		if media then
			media:Register("sound", "BugSack: Fatality", "Interface\\AddOns\\BugSack\\Media\\error.ogg")
		end
		return media
	end
end

local onError
do
	local lastError = nil
	function onError(event, errorObject)
		if not lastError or GetTime() > (lastError + 2) then
			if not addon.db.mute then
				local media = addon:EnsureLSM3()
				if media then
					local sound = media:Fetch("sound", addon.db.soundMedia) or "Interface\\AddOns\\BugSack\\Media\\error.ogg"
					PlaySoundFile(sound)
				else
					PlaySoundFile("Interface\\AddOns\\BugSack\\Media\\error.ogg")
				end
			end
			if addon.db.chatframe then
				print(L["There's a bug in your soup!"])
			end
			lastError = GetTime()
		end
		-- If the frame is shown, we need to update it.
		if (addon.db.auto and not InCombatLockdown()) or (BugSackFrame and BugSackFrame:IsShown()) then
			addon:OpenSack(errorObject)
		end
		addon:UpdateDisplay()
	end
end

-----------------------------------------------------------------------
-- Event handling
--

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

function eventFrame:ADDON_LOADED(loadedAddon)
	if loadedAddon ~= addonName then return end
	self:UnregisterEvent("ADDON_LOADED")

	local ac = LibStub("AceComm-3.0", true)
	if ac then ac:Embed(addon) end
	local as = LibStub("AceSerializer-3.0", true)
	if as then as:Embed(addon) end

	local popup = _G.StaticPopupDialogs
	if type(popup) ~= "table" then popup = {} end
	if type(popup.BugSackSendBugs) ~= "table" then
		popup.BugSackSendBugs = {
			text = L["Send all bugs from the currently viewed session (%d) in the sack to the player specified below."],
			button1 = L["Send"],
			button2 = CLOSE,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			hasEditBox = true,
			OnAccept = function(self, data)
				local recipient = self.editBox:GetText()
				addon:SendBugsToUser(recipient, data)
			end,
			OnShow = function(self)
				self.button1:Disable()
			end,
			EditBoxOnTextChanged = function(self, data)
				local t = self:GetText()
				if t:len() > 2 and not t:find("%s") then
					self:GetParent().button1:Enable()
				else
					self:GetParent().button1:Disable()
				end
			end,
			enterClicksFirstButton = true,
			--OnCancel = function() show() end, -- Need to wrap it so we don't pass |self| as an error argument to show().
			preferredIndex = STATICPOPUP_NUMDIALOGS,
		}
	end

	if type(BugSackDB) ~= "table" then BugSackDB = {} end
	local sv = BugSackDB
	sv.profileKeys = nil
	sv.profiles = nil
	if type(sv.mute) ~= "boolean" then sv.mute = false end
	if type(sv.auto) ~= "boolean" then sv.auto = false end
	if type(sv.chatframe) ~= "boolean" then sv.chatframe = false end
	if type(sv.soundMedia) ~= "string" then sv.soundMedia = "BugSack: Fatality" end
	if type(sv.fontSize) ~= "string" then sv.fontSize = "GameFontHighlight" end
	addon.db = sv

	addon:EnsureLSM3()

	self.ADDON_LOADED = nil
end

function eventFrame:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")

	-- Make sure we grab any errors fired before bugsack loaded.
	local session = addon:GetErrors(BugGrabber:GetSessionId())
	if #session > 0 then onError() end

	if addon.RegisterComm then
		addon:RegisterComm("BugSack", "OnBugComm")
	end

	-- Set up our error event handler
	BugGrabber.RegisterCallback(addon, "BugGrabber_BugGrabbed", onError)

	SlashCmdList.BugSack = function()
		InterfaceOptionsFrame_OpenToCategory(addonName)
		InterfaceOptionsFrame_OpenToCategory(addonName)
	end
	SLASH_BugSack1 = "/bugsack"

	self.PLAYER_LOGIN = nil
end

-----------------------------------------------------------------------
-- API
--

function addon:UpdateDisplay()
	-- noop, hooked by displays
end

do
	local errors = {}
	function addon:GetErrors(sessionId)
		-- XXX I've never liked this function, maybe a BugGrabber redesign is in order,
		-- XXX where we have one subtable in the DB per session ID.
		if sessionId then
			wipe(errors)
			local db = BugGrabber:GetDB()
			for i, e in next, db do
				if sessionId == e.session then
					errors[#errors + 1] = e
				end
			end
			return errors
		else
			return BugGrabber:GetDB()
		end
	end
end

do
	local function colorStack(ret)
		ret = tostring(ret) or "" -- Yes, it gets called with nonstring from somewhere /mikk
		ret = ret:gsub("[%.I][%.n][%.t][%.e][%.r]face\\", "")
		ret = ret:gsub("%.?%.?%.?\\?AddOns\\", "")
		ret = ret:gsub("|([^chHr])", "||%1"):gsub("|$", "||") -- Pipes
		ret = ret:gsub("<(.-)>", "|cffffea00<%1>|r") -- Things wrapped in <>
		ret = ret:gsub("%[(.-)%]", "|cffffea00[%1]|r") -- Things wrapped in []
		ret = ret:gsub("([\"`'])(.-)([\"`'])", "|cff8888ff%1%2%3|r") -- Quotes
		ret = ret:gsub(":(%d+)([%S\n])", ":|cff00ff00%1|r%2") -- Line numbers
		ret = ret:gsub("([^\\]+%.lua)", "|cffffffff%1|r") -- Lua files
		return ret
	end
	addon.ColorStack = colorStack

	local function colorLocals(ret)
		ret = tostring(ret) or "" -- Yes, it gets called with nonstring from somewhere /mikk
		ret = ret:gsub("[%.I][%.n][%.t][%.e][%.r]face\\", "")
		ret = ret:gsub("%.?%.?%.?\\?AddOns\\", "")
		ret = ret:gsub("|(%a)", "||%1"):gsub("|$", "||") -- Pipes
		ret = ret:gsub("> %@(.-):(%d+)", "> @|cffeda55f%1|r:|cff00ff00%2|r") -- Files/Line Numbers of locals
		ret = ret:gsub("(%s-)([%a_%(][%a_%d%*%)]+) = ", "%1|cffffff80%2|r = ") -- Table keys
		ret = ret:gsub("= (%-?[%d%p]+)\n", "= |cffff7fff%1|r\n") -- locals: number
		ret = ret:gsub("= nil\n", "= |cffff7f7fnil|r\n") -- locals: nil
		ret = ret:gsub("= true\n", "= |cffff9100true|r\n") -- locals: true
		ret = ret:gsub("= false\n", "= |cffff9100false|r\n") -- locals: false
		ret = ret:gsub("= <(.-)>", "= |cffffea00<%1>|r") -- Things wrapped in <>
		return ret
	end
	addon.ColorLocals = colorLocals

	local errorFormat = "%dx %s\n\nLocals:\n%s"
	function addon:FormatError(err)
		local s = colorStack(tostring(err.message) .. "\n" .. tostring(err.stack))
		local l = colorLocals(tostring(err.locals))
		return errorFormat:format(err.counter or -1, s, l)
	end
end

function addon:Reset()
	BugGrabber:Reset()
	self:UpdateDisplay()
	print(L["All stored bugs have been exterminated painfully."])
end

-- Sends the current session errors to another player using AceComm-3.0
function addon:SendBugsToUser(player, session)
	if type(player) ~= "string" or player:trim():len() < 2 then
		error(L["Player needs to be a valid name."])
	end
	if not self.Serialize then return end

	local errors = self:GetErrors(session)
	if not errors or #errors == 0 then return end
	local sz = self:Serialize(errors)
	self:SendCommMessage("BugSack", sz, "WHISPER", player, "BULK")

	print(L["%d bugs have been sent to %s. He must have BugSack to be able to examine them."]:format(#errors, player))
end

function addon:OnBugComm(prefix, message, distribution, sender)
	if prefix ~= "BugSack" or not self.Deserialize then return end

	local good, deSz = self:Deserialize(message)
	if not good then
		print(L["Failure to deserialize incoming data from %s."]:format(sender))
		return
	end

	-- Store recieved errors in the current session database with a source set to the sender
	local s = BugGrabber:GetSessionId()
	for i, err in next, deSz do
		err.source = sender
		err.session = s
		BugGrabber:StoreError(err)
	end

	print(L["You've received %d bugs from %s."]:format(#deSz, sender))

	wipe(deSz)
	deSz = nil
end

--[[

do
	local commFormat = "1#%s#%s"
	local function transmit(command, target, argument)
		SendAddonMessage("BugGrabber", commFormat:format(command, argument), "WHISPER", target)
	end

	local retrievedErrors = {}
	function addon:GetErrorByPlayerAndID(player, id)
		if player == playerName then return self:GetErrorByID(id) end
		-- This error was linked by someone else, we need to retrieve it from them
		-- using the addon communication channel.
		if retrievedErrors[id] then return retrievedErrors[id] end
		transmit("FETCH", player, id)
		print(L.ERROR_INCOMING:format(id, player))
	end

	local fakeAddon, comm, serializer = nil, nil, nil
	local function commBugCatcher(prefix, message, distribution, sender)
		local good, deSz = fakeAddon:Deserialize(message)
		if not good then
			print("damnit")
			return
		end
		retrievedErrors[deSz.originalId] = deSz
		
	end
	local function hasTransmitFacilities()
		if fakeAddon then return true end
		if not serializer then serializer = LibStub("AceSerializer-3.0", true) end
		if not comm then comm = LibStub("AceComm-3.0", true) end
		if comm and serializer then
			fakeAddon = {}
			comm:Embed(fakeAddon)
			serializer:Embed(fakeAddon)
			fakeAddon:RegisterComm("BGBug", commBugCatcher)
			return true
		end
	end

	function frame:CHAT_MSG_ADDON(event, prefix, message, distribution, sender)
		if prefix ~= "BugGrabber" then return end
		local version, command, argument = strsplit("#", message)
		if tonumber(version) ~= 1 or not command then return end
		if command == "FETCH" then
			local errorObject = addon:GetErrorByID(argument)
			if errorObject then
				if hasTransmitFacilities() then
					errorObject.originalId = argument
					local sz = fakeAddon:Serialize(errorObject)
					fakeAddon:SendCommMessage("BGBug", sz, "WHISPER", sender, "BULK")
				else
					-- We can only transmit a gimped and sanitized message
					transmit("BUG", sender, errorObject.message:sub(1, 240):gsub("#", ""))
				end
			else
				transmit("FAIL", sender, argument)
			end
		elseif command == "FAIL" then
			print(L.ERROR_FAILED_FETCH:format(argument, sender))
		elseif command == "BUG" then
			print(L.CRIPPLED_ERROR:format(sender, argument))
		end
	end
end]]

