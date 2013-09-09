local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("All Edge resizing","AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["All Edge resizing"]

function mod:Info()
	return L["Allows you to use the edge for resizing, instead of just the lower right corner."]
end

local anchorPoints = { "TopLeft", "TopRight", "BottomLeft", "BottomRight", "Top", "Right", "Left", "Bottom" }

function mod:OnInitialize()

end

local function ChatFrame_StartResizing(self)
	local chatFrame = self:GetParent()
	if chatFrame.isLocked then return end
	if chatFrame.isDocked and chatFrame ~= DEFAULT_CHAT_FRAME then return end
	chatFrame.resizing = 1
	chatFrame:StartSizing(self.anchorPoint)
end

local function ChatFrame_StopResizing(self)
	local chatFrame = self:GetParent()
	chatFrame:StopMovingOrSizing()
	if chatFrame == DEFAULT_CHAT_FRAME then
		FCF_DockUpdate()
	end
	chatFrame.resizing = nil
	FCF_SavePositionAndDimensions(chatFrame);
end

function mod:SetChatWindowLocked(index, locked, ...)
	local f = _G["ChatFrame" .. index]
	for _, v in ipairs(anchorPoints) do
		local k = "resize" .. v
		if f[k] then
			f[k]:EnableMouse(not locked)
		end
	end
	return self.hooks.SetChatWindowLocked(index, locked, ...)
end

function mod:MakeResizers(frame)
	local f = frame
	if not f.resizeTopLeft then
		f.background = _G[("ChatFrame%dBackground"):format(frame:GetID())]
		for _, v in ipairs(anchorPoints) do
			local k = "resize" .. v
			f[k] = CreateFrame("Button", "ChatFrame" .. frame:GetID() .. "Resize" .. v, f)
			f[k].anchorPoint = v:upper()
			f[k]:SetWidth(16)
			f[k]:SetHeight(16)
			f[k]:SetScript("OnMouseDown", ChatFrame_StartResizing)
			f[k]:SetScript("OnMouseUp", ChatFrame_StopResizing)
			LowerFrameLevel(f[k])
		end
		f.resizeTopLeft:SetPoint("TOPLEFT", f.background, -2, 2)
		f.resizeTopRight:SetPoint("TOPRIGHT", f.background, 2, 2)
		f.resizeBottomLeft:SetPoint("BOTTOMLEFT", f.background, -2, -3)
		f.resizeBottomRight:SetPoint("BOTTOMRIGHT", f.background, 2, -3)
		f.resizeTop:SetPoint("LEFT", f.resizeTopLeft, "RIGHT", 0, 0)
		f.resizeTop:SetPoint("RIGHT", f.resizeTopRight, "LEFT", 0, 0)
		f.resizeRight:SetPoint("TOP", f.resizeTopRight, "BOTTOM", 0, 0)
		f.resizeRight:SetPoint("BOTTOM", f.resizeBottomRight, "TOP", 0, 0)
		f.resizeBottom:SetPoint("LEFT", f.resizeBottomLeft, "RIGHT", 0, 0)
		f.resizeBottom:SetPoint("RIGHT", f.resizeBottomRight, "LEFT", 0, 0)
		f.resizeLeft:SetPoint("TOP", f.resizeTopLeft, "BOTTOM", 0, 0)
		f.resizeLeft:SetPoint("BOTTOM", f.resizeBottomLeft, "TOP", 0, 0)
	else
		f.resizeTopLeft:Show()
		f.resizeTopRight:Show()
		f.resizeBottomLeft:Show()
		f.resizeBottomRight:Show()
		f.resizeTop:Show()
		f.resizeTop:Show()
		f.resizeRight:Show()
		f.resizeRight:Show()
		f.resizeBottom:Show()
		f.resizeBottom:Show()
		f.resizeLeft:Show()
		f.resizeLeft:Show()
	end
end

function mod:HideResizers(f)
	-- check that we made resizers before tryign to hide it
	if not f.resizeTopLeft then
		return
	end
	f.resizeTopLeft:Hide()
	f.resizeTopRight:Hide()
	f.resizeBottomLeft:Hide()
	f.resizeBottomRight:Hide()
	f.resizeTop:Hide()
	f.resizeTop:Hide()
	f.resizeRight:Hide()
	f.resizeRight:Hide()
	f.resizeBottom:Hide()
	f.resizeBottom:Hide()
	f.resizeLeft:Hide()
	f.resizeLeft:Hide()
end
--[[
	Decorate new popuut windows with resizers
--]]
function mod:Decorate(frame)
	self:MakeResizers(frame)
	local b = _G[("ChatFrame%dResizeButton"):format(frame:GetID())]
	b:SetScript("OnShow", b.Hide)
	b:Hide()	
end

function mod:OnEnable()
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G[("ChatFrame%d"):format(i)]
		self:MakeResizers(f)
		local b = _G[("ChatFrame%dResizeButton"):format(i)]
		b:SetScript("OnShow", b.Hide)
		b:Hide()
	end
	for index,name in ipairs(self.TempChatFrames) do
		local f = _G[name]
		self:MakeResizers(f)
		local b = _G[("ChatFrame%dResizeButton"):format(f:GetID())]
		b:SetScript("OnShow", b.Hide)
		b:Hide()
	end
	self:RawHook("SetChatWindowLocked",true)
end

function mod:OnDisable()
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame"..i]
		self:HideResizers(f)
		local b = _G[("ChatFrame%dResizeButton"):format(f:GetID())]
		b:SetScript("OnShow", b.Show)
		b:Show()
	end
	for index,name in ipairs(self.TempChatFrames) do
		local f = _G[name]
		self:HideResizers(f)
		local b = _G[("ChatFrame%dResizeButton"):format(f:GetID())]
		b:SetScript("OnShow", b.Show)
		b:Show()
	end
	self:UnhookAll()
end
