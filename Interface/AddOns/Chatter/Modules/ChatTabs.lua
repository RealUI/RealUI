local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("ChatTabs", "AceHook-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
local font = GameFontNormalSmall
mod.modName = L["Chat Tabs"]

local defaults = {
	profile = {
		height = 29,
		tabFlash = true,
		alpha = 0,
	}
}

local options = {
	height = {
		order = 101,
		type = "range",
		max = 60,
		min = 16,
		name = L["Button Height"],
		desc = L["Button's height, and text offset from the frame"],
		step = 1,
		bigStep = 1,
		get = function() return mod.db.profile.height end,
		set = function(info, v)
			mod.db.profile.height = v
			for i = 1, NUM_CHAT_WINDOWS do
				local tab = _G["ChatFrame"..i.."Tab"]
				tab:SetHeight(v)
			end
		end,
		disabled = function() return not mod:IsEnabled() end
	},
	hidetabs = {
		order = 102,
		type = "toggle",
		name = L["Hide Tabs"],
		desc = L["Hides chat frame tabs"],
		get = function() return mod.db.profile.chattabs end,
		set = function(info, v) mod.db.profile.chattabs = not mod.db.profile.chattabs; mod:ToggleTabShow() end,
		disabled = function() return not mod:IsEnabled() end
	},
	hideflash = {
		order = 103,
		type = "toggle",
		name = L["Enable Tab Flashing"],
		desc = L["Enables the Tab to flash when you miss a message"],
		get = function() return mod.db.profile.tabFlash end,
		set = function(info, v) mod.db.profile.tabFlash = not mod.db.profile.tabFlash; mod:DecorateTabs() end,
		disabled = function() return not mod:IsEnabled() end
	},
	tabalpha = {
		order = 104,
		type = "range",
		name = L["Tab Alpha"],
		min = 0,
		max = 1,
		step = 0.1,
		desc = L["Sets the alpha value for your chat tabs"],
		get = function() return mod.db.profile.alpha end,
		set = function(info,v) mod.db.profile.alpha = v; mod:DecorateTabs();  FCFDock_UpdateTabs(GeneralDockManager, true) end,
		disabled = function() return not mod:IsEnabled() end
	}
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace(self:GetName(), defaults)
end

local function SetFontSizes()
	for i = 1, NUM_CHAT_WINDOWS do
		local tab = _G["ChatFrame"..i.."Tab"]
		mod:OnLeave(tab)
	end
	for index,name in ipairs(mod.TempChatFrames) do
		local tab = _G[name.."Tab"]
		mod:OnLeave(tab)
	end
end

function mod:Decorate(frame)
	local name = frame:GetName()
	local tab = _G[name.."Tab"]
	tab:SetHeight(mod.db.profile.height)
	_G[name.."TabLeft"]:Hide()
	_G[name.."TabMiddle"]:Hide()
	_G[name.."TabRight"]:Hide()
	tab.leftSelectedTexture:SetAlpha(0)
	tab.rightSelectedTexture:SetAlpha(0)
	tab.middleSelectedTexture:SetAlpha(0)
	tab.leftHighlightTexture:SetTexture(nil)
	tab.rightHighlightTexture:SetTexture(nil)
	tab.middleHighlightTexture:SetTexture([[Interface\BUTTONS\CheckButtonGlow]])
	tab.middleHighlightTexture:SetWidth(76)
	tab.middleHighlightTexture:SetTexCoord(0, 0, 1, 0.5)
	tab.leftSelectedTexture:SetAlpha(0)
	tab.rightSelectedTexture:SetAlpha(0)
	tab.middleSelectedTexture:SetAlpha(0)
	tab:EnableMouseWheel(true)
	self:HookScript(tab, "OnMouseWheel")
	tab:Show()
	if (mod.db.profile.chattabs) then
		mod:HideTab(tab)
	end
end

function mod:DecorateTabs()
	CHAT_FRAME_FADE_OUT_TIME = 0.5
	CHAT_TAB_HIDE_DELAY = 0
	CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = mod.db.profile.alpha
	CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
	if self.db.profile.tabFlash then
		CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1
	else
		CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = mod.db.profile.alpha
	end
	CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = mod.db.profile.alpha
	for i = 1, NUM_CHAT_WINDOWS do
		local tab = _G["ChatFrame"..i.."Tab"]
		local chat = _G["ChatFrame"..i]
		if not chat.dock then
			tab.mouseOverAlpha = 1
			tab.noMouseAlpha = mod.db.profile.alpha
			tab:SetAlpha(mod.db.profile.alpha)
		end
	end
	for index,name in ipairs(self.TempChatFrames) do
		local chat = _G[name]
		local tab = _G[name.."Tab"]
		if not chat.dock then
			tab.mouseOverAlpha = 1
			tab.noMouseAlpha = mod.db.profile.alpha
			tab:SetAlpha(mod.db.profile.alpha)
		end		
	end
end

function mod:UndecorateTabs()
	CHAT_FRAME_FADE_OUT_TIME = 2
	CHAT_TAB_HIDE_DELAY = 1
	CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0.4
	CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1
	CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.6
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0.2
	for i = 1, NUM_CHAT_WINDOWS do
		local tab = _G["ChatFrame"..i.."Tab"]
		local chat = _G["ChatFrame"..i]
		if not chat.dock then
			tab.mouseOverAlpha = 1
			tab.noMouseAlpha = 0.2
			tab:SetAlpha(0.2)
		end
	end
	for index,name in ipairs(self.TempChatFrames) do
		local chat = _G[name]
		local tab = _G[name.."Tab"]
		if not chat.dock then
			tab.mouseOverAlpha = 1
			tab.noMouseAlpha = 0.2
			tab:SetAlpha(0.2)
		end		
	end
end

function mod:OnEnable()
	-- self:Hook("FCF_Close", true)
	self:DecorateTabs()
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G["ChatFrame"..i]
		local tab = _G["ChatFrame"..i.."Tab"]
		tab:SetHeight(mod.db.profile.height)
		_G["ChatFrame"..i.."TabLeft"]:Hide()
		_G["ChatFrame"..i.."TabMiddle"]:Hide()
		_G["ChatFrame"..i.."TabRight"]:Hide()
		tab.leftSelectedTexture:SetAlpha(0)
		tab.rightSelectedTexture:SetAlpha(0)
		tab.middleSelectedTexture:SetAlpha(0)
		tab.leftHighlightTexture:SetTexture(nil)
		tab.rightHighlightTexture:SetTexture(nil)
		tab.middleHighlightTexture:SetTexture([[Interface\BUTTONS\CheckButtonGlow]])
		tab.middleHighlightTexture:SetWidth(76)
		tab.middleHighlightTexture:SetTexCoord(0, 0, 1, 0.5)
		tab.leftSelectedTexture:SetAlpha(0)
		tab.rightSelectedTexture:SetAlpha(0)
		tab.middleSelectedTexture:SetAlpha(0)
		--[[ TODO: Grum @ 18/10/2008
		    There seems to be a bug with certain fonts/fontObjects which prevents
		    tab:GetNormalFontObject() to return anything sensible
		    The buttons now have font objects. If you change the size on one it will change on
		    the other tabs as well. However assigning a new font object seems to go wrong with
		    the default ChatFrame$Tab font-object. This will need further investigation
		
		    For now I just disabled all the font-changing mechanics.
		--]]
		tab:EnableMouseWheel(true)
		self:HookScript(tab, "OnMouseWheel")
		if (mod.db.profile.chattabs) then
			mod:HideTab(tab)
		end
		tab.noMouseAlpha=mod.db.profile.alpha
		tab:SetAlpha(mod.db.profile.alpha)
	end
	for index,name in ipairs(self.TempChatFrames) do
		local chat = _G[name]
		local tab = _G[name.."Tab"]
		tab:SetHeight(mod.db.profile.height)
		_G[name.."TabLeft"]:Hide()
		_G[name.."TabMiddle"]:Hide()
		_G[name.."TabRight"]:Hide()
		tab.leftSelectedTexture:SetAlpha(0)
		tab.rightSelectedTexture:SetAlpha(0)
		tab.middleSelectedTexture:SetAlpha(0)
		tab.leftHighlightTexture:SetTexture(nil)
		tab.rightHighlightTexture:SetTexture(nil)
		tab.middleHighlightTexture:SetTexture([[Interface\BUTTONS\CheckButtonGlow]])
		tab.middleHighlightTexture:SetWidth(76)
		tab.middleHighlightTexture:SetTexCoord(0, 0, 1, 0.5)
		tab.leftSelectedTexture:SetAlpha(0)
		tab.rightSelectedTexture:SetAlpha(0)
		tab.middleSelectedTexture:SetAlpha(0)
		tab:EnableMouseWheel(true)
		if not self:IsHooked(tab,"OnMouseWheel") then
			self:HookScript(tab, "OnMouseWheel")
		end
		if (mod.db.profile.chattabs) then
			mod:HideTab(tab)
		end
		tab.noMouseAlpha=mod.db.profile.alpha
		tab:SetAlpha(mod.db.profile.alpha)
	end
	self:DecorateTabs()
end

function mod:OnDisable()
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G["ChatFrame"..i]
		local tab = _G["ChatFrame"..i.."Tab"]
		tab:SetHeight(32)
		_G["ChatFrame"..i.."TabLeft"]:Show()
		_G["ChatFrame"..i.."TabMiddle"]:Show()
		_G["ChatFrame"..i.."TabRight"]:Show()
		tab:EnableMouseWheel(false)
		tab:Hide()
		tab.noMousealpha=0.2
		tab:SetAlpha(0.2)
	end
	for index,name in ipairs(self.TempChatFrames) do
		local chat = _G[name]
		local tab = _G[name.."Tab"]
		tab:SetHeight(32)
		_G[name.."TabLeft"]:Show()
		_G[name.."TabMiddle"]:Show()
		_G[name.."TabRight"]:Show()
		tab:EnableMouseWheel(false)
		tab:Hide()
		tab.noMousealpha=0.2
		tab:SetAlpha(0.2)
	end
	self:UndecorateTabs()
end

function mod:FCF_Close(f)
	_G[f:GetName() .. "Tab"]:Hide()
end

function mod:OnClick(f, button, ...)
	if button == "LeftButton" then
		SetFontSizes(f)		
	end
end

function mod:ToggleTabShow()
	for i = 1, NUM_CHAT_WINDOWS do
		local tab = _G["ChatFrame"..i.."Tab"]
		local chat = _G["ChatFrame"..i]
		if (mod.db.profile.chattabs) then
			tab:SetScript("OnShow", function(...) tab:Hide() end)
		else
			tab:SetScript("OnShow", function(...) tab:Show() end)
		end
		tab:Show()
		tab:Hide()
		if chat.isDocked or chat:IsVisible() then
			tab:Show()
		end
	end
	for index,name in ipairs(self.TempChatFrames) do
		local tab = _G[name.."Tab"]
		local chat = _G[name]
		if (mod.db.profile.chattabs) then
			tab:SetScript("OnShow", function(...) tab:Hide() end)
		else
			tab:SetScript("OnShow", function(...) tab:Show() end)
		end
		tab:Show()
		tab:Hide()
		if chat.isDocked or chat:IsVisible() then
			tab:Show()
		end
	end
end

function mod:HideTab(tab)
	tab:SetScript("OnShow", function(...) tab:Hide() end)
	tab:Show()
	if tab:IsVisible() then
		tab:Hide()
	end
end

function mod:OnMouseWheel(frame, dir)
	local chat = _G["ChatFrame" .. frame:GetID()]
	if not chat.isDocked then return end
	
	local t
	for i = 1, #GENERAL_CHAT_DOCK.DOCKED_CHAT_FRAMES do
		if GENERAL_CHAT_DOCK.DOCKED_CHAT_FRAMES[i]:IsVisible() then
			t = i
			break
		end
	end
	
	if t == 1 and dir > 0 then
		t = #GENERAL_CHAT_DOCK.DOCKED_CHAT_FRAMES
	elseif t == #GENERAL_CHAT_DOCK.DOCKED_CHAT_FRAMES and dir < 0 then
		t = 1
	elseif t then
		t = t + (dir < 0 and 1 or -1)
	end
	if t then
		_G[GENERAL_CHAT_DOCK.DOCKED_CHAT_FRAMES[t]:GetName() .. "Tab"]:Click()
	end
	--SetFontSizes()
end

function mod:OnEnter(frame)
	local f, s = font:GetFont()
	frame:SetFont(f, s + 2)
end

function mod:OnLeave(frame)
	local f, s = font:GetFont()
	if(_G["ChatFrame" .. frame:GetID()]:IsVisible()) then
		frame:SetFont(f, s + 2)
	else
		frame:SetFont(f, s - 1)
	end
end

function mod:GetOptions()
	return options
end
