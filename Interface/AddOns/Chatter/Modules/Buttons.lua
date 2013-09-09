local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Disable Buttons", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)

mod.modName = L["Disable Buttons"]
mod.toggleLabel = L["Disable Buttons"]

local fmt = _G.string.format
local function hide(self)
	if not self.override then
		self:Hide()
	end
	self.override = nil
end

local options = {
	bottomButton = {
		type = "toggle",
		name = L["Show bottom when scrolled"],
		desc = L["Show bottom button when scrolled up"],
		width = "double",
		get = function()
			return mod.db.profile.scrollReminder
		end,
		set = function(info, v)
			mod.db.profile.scrollReminder = v
			if v then
				mod:EnableBottomButton()
			else
				mod:DisableBottomButton()
			end
		end
	}
}

local bottomButtons = {}

local defaults = { profile = {} }
local clickFunc = function(self) self:GetParent():ScrollToBottom() end
function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("Buttons", defaults)
	--for i = 1, NUM_CHAT_WINDOWS do
	--	local f = _G["ChatFrame" .. i]
		--local button = CreateFrame("Button", nil, f)
		--button:SetNormalTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollEnd-Up]])
		--button:SetPushedTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollEnd-Down]])
		--button:SetDisabledTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollEnd-Disabled]])
		--button:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]])
		--button:SetWidth(20)
		--button:SetHeight(20)
		--button:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
		--button:SetScript("OnClick", clickFunc)
		--button:Hide()
		--f.downButton = button
	--end
	self:SecureHook("FCF_RestorePositionAndDimensions")
end

function mod:Decorate(frame)
	local button = CreateFrame("Button", nil, frame)
	button:SetNormalTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollEnd-Up]])
	button:SetPushedTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollEnd-Down]])
	button:SetDisabledTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollEnd-Disabled]])
	button:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]])
	button:SetWidth(20)
	button:SetHeight(20)
	button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	button:SetScript("OnClick", clickFunc)
	button:Hide()
	frame.downButton = button
	-- Adjust the menu buttons
	self:ApplyFrameChanges(frame)
	if(self.db.profile.scrollReminder) then self:ApplyBottomButton(frame) end
end

function mod:FCF_RestorePositionAndDimensions(chatFrame)
	if Chatter.db.profile.modules[mod:GetName()] then
		chatFrame:SetClampRectInsets(0, 0, 0, 0)
	end
end

-- Fix the jump in
for i = 1, NUM_CHAT_WINDOWS do
	local f = _G["ChatFrame" .. i]
	f:SetClampRectInsets(0, 0, 0, 0)
end

function mod:ApplyFrameChanges(f)
	f:SetClampRectInsets(0, 0, 0, 0)
	local ff = _G[f:GetName() .. "ButtonFrame"]
	ff:Hide()
	ff:SetScript("OnShow", hide)
end

function mod:OnEnable()
	ChatFrameMenuButton:Hide()
	ChatFrameMenuButton:SetScript("OnShow", hide)
	FriendsMicroButton:Hide()
	FriendsMicroButton:SetScript("OnShow", hide)
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame" .. i]
		self:Decorate(f)
		--self:ApplyFrameChanges(f)
	end
	if(self.db.profile.scrollReminder) then self:EnableBottomButton() end
	for index,frame in ipairs(self.TempChatFrames) do
		local f = _G[frame]
		self:Decorate(f)
		--self:ApplyFrameChanges(f)
	end
end

function mod:UnDecorate(frame)
	frame:SetClampRectInsets(-35, 35, 26, -50)
	-- Reset the postion so if the buttons were offscreen frame goes to where it should be
	if frame:IsMovable() then
		FCF_RestorePositionAndDimensions(frame)
	end
	local ff = _G[frame:GetName() .. "ButtonFrame"]
	ff:Show()
	ff:SetScript("OnShow", nil)
end

function mod:OnDisable()
	ChatFrameMenuButton:Show()
	ChatFrameMenuButton:SetScript("OnShow", nil)
	FriendsMicroButton:Show()
	FriendsMicroButton:SetScript("OnShow", nil)
	self:DisableBottomButton()
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame" .. i]
		self:UnDecorate(f)
	end
	for index,frame in ipairs(self.TempChatFrames) do
		local f = _G[frame]
		self:UnDecorate(f)
	end
end

function mod:Info()
	return L["Hides the buttons attached to the chat frame"]
end

function mod:ApplyBottomButton(frame)
	if self:IsHooked(frame,"ScrollUp") then
		return nil
	end
	self:Hook(frame, "ScrollUp", true)
	self:Hook(frame, "ScrollToTop", "ScrollUp", true)
	self:Hook(frame, "PageUp", "ScrollUp", true)
	self:Hook(frame, "ScrollDown", true)
	self:Hook(frame, "ScrollToBottom", "ScrollDownForce", true)
	self:Hook(frame, "PageDown", "ScrollDown", true)
	if frame:GetCurrentScroll() ~= 0 then
		frame.downButton:Show()
	end
	if frame ~= COMBATLOG then
		self:Hook(frame, "AddMessage", true)
	end
end

function mod:EnableBottomButton()
	if self.buttonsEnabled then return end
	self.buttonsEnabled = true
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame" .. i]
		if f then
			self:ApplyBottomButton(f)
		end
	end
	for index,frame in ipairs(self.TempChatFrames) do
		local f = _G[frame]
		if f then
			self:ApplyBottomButton(f)
		end
	end
end

function mod:UnApplyBottomButton(f)
	self:Unhook(f, "ScrollUp")
	self:Unhook(f, "ScrollToTop")
	self:Unhook(f, "PageUp")
	self:Unhook(f, "ScrollDown")
	self:Unhook(f, "ScrollToBottom")
	self:Unhook(f, "PageDown")
	if f ~= COMBATLOG then
		self:Unhook(f, "AddMessage")
	end
	f.downButton:Hide()
end

function mod:DisableBottomButton()
	if not self.buttonsEnabled then return end
	self.buttonsEnabled = false
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame" .. i]
		if f then
			self:UnApplyBottomButton(f)
		end
	end
	for index,frame in ipairs(self.TempChatFrames) do
		local f = _G[frame]
		if f then
			self:UnApplyBottomButton(f)
		end
	end
end

function mod:ScrollUp(frame)
	frame.downButton:Show()
	frame.downButton:UnlockHighlight()
end

function mod:ScrollDown(frame)
	if frame:GetCurrentScroll() == 0 then
		frame.downButton:Hide()
		frame.downButton:UnlockHighlight()
	end
end

function mod:ScrollDownForce(frame)
	frame.downButton:Hide()
	frame.downButton:UnlockHighlight()
end

function mod:AddMessage(frame, text, ...)
	if frame:GetCurrentScroll() > 0 then
		frame.downButton:Show()
		frame.downButton:LockHighlight()
	else
		frame.downButton:Hide()
		frame.downButton:UnlockHighlight()
	end
end

function mod:GetOptions()
	return options
end
