local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")
local db, ndb

local Chat = nibRealUI:GetModule("Chat")
local MODNAME = "Chat_Tabs"
local Chat_Tabs = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Tab Style update
local TStyleColors = {}
local function UpdateTabStyle(self, style)
	-- Retrieve FontString of tab
	if self.GetFontString then
		self = self:GetFontString()
	else
		self = self:GetParent():GetFontString()
	end
	
	self:SetFont(unpack(nibRealUI:Font(false, "small")))
	self:SetShadowColor(0, 0, 0, 0)

	-- Color
	if style == "selected" then style = "highlight" end
	if ((style == "highlight") and db.colors.classcolorhighlight) then
		self:SetTextColor(unpack(nibRealUI.classColor))
	else
		self:SetTextColor(unpack(db.colors[style]))
	end
end

-- Chat Window creation
local function ChatWindowCreated()
	Chat_Tabs:UpdateTabs(false)
end

-- Chat Tab mouse-events
local function ChatTab_OnLeave(self)
	Chat_Tabs:UpdateTabs(true)
end

local function ChatTab_OnEnter(self)
	UpdateTabStyle(self, "highlight")
end

local function ChatTabFlash_OnHide(self)
	UpdateTabStyle(self, "normal")
end

local function ChatTabFlash_OnShow(self)
	UpdateTabStyle(self, "flash")
	UIFrameFlashStop(self.glow)
end

-- Tab update
function Chat_Tabs:UpdateTabs(SimpleUpdate)
	local chat, tab, flash
	local maxTabs = ChatFrame11Tab and 11 or NUM_CHAT_WINDOWS
	for i = 1, maxTabs do
		chat = _G["ChatFrame"..i]
		tab = _G["ChatFrame"..i.."Tab"]
		flash = _G["ChatFrame"..i.."TabFlash"]
		
		if not SimpleUpdate then
			-- Hide regular Chat Tab textures
			_G["ChatFrame"..i.."TabLeft"]:Hide()
			_G["ChatFrame"..i.."TabMiddle"]:Hide()
			_G["ChatFrame"..i.."TabRight"]:Hide()
			_G["ChatFrame"..i.."TabHighlightLeft"]:Hide()
			_G["ChatFrame"..i.."TabHighlightMiddle"]:Hide()
			_G["ChatFrame"..i.."TabHighlightRight"]:Hide()

			-- Hook Tab
			tab:SetScript("OnEnter", ChatTab_OnEnter)
			tab:SetScript("OnLeave", ChatTab_OnLeave)
		end
		
		-- Update Selected
		_G["ChatFrame"..i.."TabSelectedLeft"]:Hide()
		_G["ChatFrame"..i.."TabSelectedMiddle"]:Hide()
		_G["ChatFrame"..i.."TabSelectedRight"]:Hide()		
		
		-- Update Tab Appearance
		if chat == SELECTED_CHAT_FRAME then
			UpdateTabStyle(tab, "selected")
		elseif tab.alerting then
			UpdateTabStyle(tab, "flash")
		else
			UpdateTabStyle(tab, "normal")
		end
		
		chat:SetSpacing(1)
	end
end

-- Hook FCF
function Chat_Tabs:HookFCF()
	-- Tab Click
	local Orig_FCF_Tab_OnClick = FCF_Tab_OnClick
	FCF_Tab_OnClick = function(...)
		-- Click the Tab
		Orig_FCF_Tab_OnClick(...)
		-- Update Tabs
		Chat_Tabs:UpdateTabs(true)
	end

	-- New Window
	hooksecurefunc("FCF_OpenNewWindow", ChatWindowCreated)
	
	-- Window Close
	hooksecurefunc("FCF_Close", function(self, fallback)
		local frame = fallback or self
		UIParent.Hide(_G[frame:GetName().."Tab"])
		FCF_Tab_OnClick(_G["ChatFrame1Tab"], "LeftButton")
	end)
	
	-- Flash
	-- Start
	hooksecurefunc("FCF_StartAlertFlash", function(chatFrame)
		ChatTabFlash_OnShow(_G[chatFrame:GetName().."Tab"])
	end)
	-- Stop
	hooksecurefunc("FCF_StopAlertFlash", function(chatFrame)
		ChatTabFlash_OnHide(_G[chatFrame:GetName().."Tab"])
	end)
	
	-- New UpdateColors function, stop it!
	FCFTab_UpdateColors = function(...) end
end

-- Style Pet Tab when it appears
function Chat_Tabs:PET_BATTLE_OPENING_START()
	self:UpdateTabs(false)
end

function Chat_Tabs:PLAYER_LOGIN()
	self:HookFCF()
	self:UpdateTabs(false)
end

------------
function Chat_Tabs:UpdateFonts()
	self:UpdateTabs(true)
end

function Chat_Tabs:OnInitialize()
	db = Chat.db.profile.modules.tabs
	ndb = nibRealUI.db.profile
	
	self:SetEnabledState(db.enabled and nibRealUI:GetModuleEnabled("Chat"))
end

function Chat_Tabs:OnEnable() 
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PET_BATTLE_OPENING_START")
end