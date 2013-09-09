-- Strip icons like |TInterface\\FriendsFrame\\UI-Toast-ToastIcons.tga:16:16:0:0:128:64:2:29:34:61
local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("BNet", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["RealID Polish"]

local defaults = {
	profile = {
		toastx = 0,
		toasty = 0,
		showToast = false
	}
}

local options
function mod:GetOptions()
	options = options or {
		showToastIcons = {
			order=100,
			type = "toggle",
			name = L["Show Toast Icons"],
			desc = L["Show toast icons in the chat frames"],
			get = function()
				return mod.db.profile.showToast
			end,
			set = function(info, v)
				mod.db.profile.showToast = v
			end,
		},
		toastWindowXoffset = {
			order=101,
			type = "range",
			min = -4000,
			max = 4000,
			name = L["Toast X offset"],
			desc = L["Move the Toast X offset to ChatFrame1"],
			step = 1,
			bigStep = 1,
			get = function()
				return mod.db.profile.toastx
			end,
			set = function(info, v)
				mod.db.profile.toastx = v
				mod:UpdateToastOffsets()
			end,
		},
		toastWindowYoffset = {
			order=102,
			type = "range",
			min = -4000,
			max = 4000,
			name = L["Toast Y offset"],
			desc = L["Move the Toast Y offset, relative to ChatFrame1"],
			step = 1,
			bigStep = 1,
			get = function()
				return mod.db.profile.toasty
			end,
			set = function(info, v)
				mod.db.profile.toasty = v
				mod:UpdateToastOffsets()
			end,
		},
		testToast = {
			order=103,
			name = L["Test"],
			type = "execute",
			func = function() BNToastFrame_AddToast(BN_TOAST_TYPE_NEW_INVITE) end,
		}
	}
	return options
end


function mod:UpdateToastOffsets()
	if self:IsEnabled() then
		local cf = DEFAULT_CHAT_FRAME
		local bside = cf.buttonSide
		local cfTop = cf.buttonFrame:GetTop() or 0
		local bnH = BNToastFrame:GetHeight() or 0
		local offscreen = cfTop + bnH + BN_TOAST_TOP_OFFSET + BN_TOAST_TOP_BUFFER > GetScreenHeight();
		BN_TOAST_LEFT_OFFSET = 1 + self.db.profile.toastx
		if bside == "right" then
			BN_TOAST_RIGHT_OFFSET = -1 + self.db.profile.toastx
		end
		BN_TOAST_TOP_OFFSET = 40 + self.db.profile.toasty
		if offscreen then
			BN_TOAST_BOTTOM_OFFSET = -12 + self.db.profile.toasty
		end
		BNToastFrame_UpdateAnchor(true)
	end
end

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("RealIdPolish", defaults)
end

function mod:OnDisable()
	self:UnhookAll()
	BN_TOAST_TOP_OFFSET = 40
	BN_TOAST_BOTTOM_OFFSET = -12
	BN_TOAST_RIGHT_OFFSET = -1
	BN_TOAST_LEFT_OFFSET = 1
	BN_TOAST_TOP_BUFFER = 20
	BN_TOAST_MAX_LINE_WIDTH = 196
end

function mod:OnEnable()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		if cf ~= COMBATLOG then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	self:Hook("BNToastFrame_Close",true)
	self:UpdateToastOffsets()
end

function mod:BNToastFrame_Close()
	self:UpdateToastOffsets()
end

function mod:ParseLinks(text)
	if not text then return nil end
	if mod.db.profile.showToast then return text end
	text = gsub(text, "(|TInterface(.*)ToastIcons.tga([:%d]*)|t)", "")
	return text
end

function mod:AddMessage(frame, text, ...)
	return self.hooks[frame].AddMessage(frame, mod:ParseLinks(text), ...)
end
