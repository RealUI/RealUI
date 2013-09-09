local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Editbox History", "AceHook-3.0" )
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Edit Box History"]

local history, enabled
local defaults = { realm = { history = { } } }
local editbox = DEFAULT_CHAT_FRAME.editBox

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("Editbox History", defaults)
	history = self.db.realm.history

	-- Hook adding lines
	self:SecureHook( editbox, "AddHistoryLine" )
end

function mod:OnEnable()
	-- Keeping state if we're enabled or not
	enabled = false
	for _, line in ipairs( history ) do
		editbox:AddHistoryLine( line )
	end
	enabled = true
end

function mod:AddHistoryLine( object, line )
	-- While in 'OnEnable' this code just returns
	if not self:IsEnabled() or not enabled then return end

	local history = history
	tinsert( history, line )

	-- clear out the excess values
	for i=1, #history - object:GetHistoryLines() do
		tremove( history, 1 )
	end
end

function mod:Info()
	return L["Remembers the history of the editbox across sessions."]
end
