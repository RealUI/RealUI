-- Code from Haleth's Notifications addon
-- http://www.wowinterface.com/downloads/info21365-Notifications.html
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local bannerWidth = 450
local interval = 0.1

local hasInitialized
local f, icon, sep, title, text = CreateFrame("Frame", "RealUIUINotifications", UIParent)

-- Banner show/hide animations

local bannerShown = false
local timeShown = 6

local function hideBanner()
	local scale
	f:SetScript("OnUpdate", function(self)
		scale = self:GetScale() - interval
		if scale <= 0.1 then
			self:SetScript("OnUpdate", nil)
			self:Hide()
			bannerShown = false
			return
		end
		self:SetScale(scale)
		self:SetAlpha(scale)
	end)
end

local function fadeTimer()
	local last = 0
	f:SetScript("OnUpdate", function(self, elapsed)
		local width = f:GetWidth()
		if width > bannerWidth then
			self:SetWidth(width - (interval*100))
		end
		last = last + elapsed
		if last >= timeShown then
			self:SetWidth(bannerWidth)
			self:SetScript("OnUpdate", nil)
			hideBanner()
		end
	end)
end

local function showBanner()
	bannerShown = true
	f:Show()
	
	local scale
	f:SetScript("OnUpdate", function(self)
		scale = self:GetScale() + interval
		self:SetScale(scale)
		self:SetAlpha(scale)
		if scale >= 1 then
			self:SetScale(1)
			self:SetScript("OnUpdate", nil)
			fadeTimer()
		end
	end)
end

-- Display a notification

local function display(name, message, clickFunc, texture, ...)
	if type(clickFunc) == "function" then
		f.clickFunc = clickFunc
	else
		f.clickFunc = nil
	end

	if type(texture) == "string" then
		icon:SetTexture(texture)

		if ... then
			icon:SetTexCoord(...)
		else
			icon:SetTexCoord(.08, .92, .08, .92)
		end
	else
		icon:SetTexture("Interface\\Icons\\achievement_general")
		icon:SetTexCoord(.08, .92, .08, .92)
	end

	title:SetText(name)
	text:SetText(message)

	showBanner()
end

-- Handle incoming notifications

local handler = CreateFrame("Frame")
local incoming = {}
local processing = false

local function handleIncoming()
	processing = true
	local i = 1

	handler:SetScript("OnUpdate", function(self)
		if incoming[i] == nil then
			self:SetScript("OnUpdate", nil)
			incoming = {}
			processing = false
			return
		else
			if not bannerShown then
				display(unpack(incoming[i]))
				i = i + 1
			end
		end
	end)
end

handler:SetScript("OnEvent", function(self, _, unit)
	if unit == "player" and not UnitIsAFK("player") then
		handleIncoming()
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
	end
end)

-- The API show function

function nibRealUI:Notification(name, showWhileAFK, message, clickFunc, texture, ...)
	if not hasInitialized then self:InitNotifications() end
	if UnitIsAFK("player") and not showWhileAFK then
		tinsert(incoming, {name, message, clickFunc, texture, ...})
		handler:RegisterEvent("PLAYER_FLAGS_CHANGED")
	elseif bannerShown or #incoming ~= 0 then
		if (#incoming < 2) then
			tinsert(incoming, {name, message, clickFunc, texture, ...})
			if not processing then
				handleIncoming()
			end
		end
	else
		display(name, message, clickFunc, texture, ...)
	end
end

-- Mouse events

local function expand(self)
	local width = self:GetWidth()

	if text:IsTruncated() and width < (GetScreenWidth() / 1.5) then
		self:SetWidth(width+(interval*100))
	else
		self:SetScript("OnUpdate", nil)
	end
end

f:SetScript("OnEnter", function(self)
	self:SetScript("OnUpdate", nil)
	self:SetScale(1)
	self:SetAlpha(1)
	self:SetScript("OnUpdate", expand)
end)

f:SetScript("OnLeave", fadeTimer)

f:SetScript("OnMouseUp", function(self, button)
	self:SetScript("OnUpdate", nil)
	self:Hide()
	self:SetScale(0.1)
	self:SetAlpha(0.1)
	bannerShown = false
	-- right click just hides the banner
	if button ~= "RightButton" and f.clickFunc then
		f.clickFunc()
	end

	-- dismiss all
	if IsShiftKeyDown() then
		handler:SetScript("OnUpdate", nil)
		incoming = {}
		processing = false
	end
end)

-- Initialize
function nibRealUI:InitNotifications()
	f:SetFrameStrata("FULLSCREEN_DIALOG")
	f:SetSize(bannerWidth, 50)
	f:SetPoint("TOP", UIParent, "TOP")
	f:Hide()
	f:SetAlpha(0.1)
	f:SetScale(0.1)
	nibRealUI:CreateBD(f)

	icon = f:CreateTexture(nil, "OVERLAY")
	icon:SetSize(32, 32)
	icon:SetPoint("LEFT", f, "LEFT", 9, 0)

	sep = f:CreateTexture(nil, "BACKGROUND")
	sep:SetSize(1, 50)
	sep:SetPoint("LEFT", icon, "RIGHT", 9, 0)
	sep:SetTexture(0, 0, 0)

	title = f:CreateFontString(nil, "OVERLAY")
	title:SetFont(nibRealUI.font.standard, 14)
	title:SetShadowOffset(1, -1)
	title:SetPoint("TOPLEFT", sep, "TOPRIGHT", 9, -9)
	title:SetPoint("RIGHT", f, -9, 0)
	title:SetJustifyH("LEFT")

	text = f:CreateFontString(nil, "OVERLAY")
	text:SetFont(nibRealUI.font.standard, 12)
	text:SetShadowOffset(1, -1)
	text:SetPoint("BOTTOMLEFT", sep, "BOTTOMRIGHT", 9, 9)
	text:SetPoint("RIGHT", f, -9, 0)
	text:SetJustifyH("LEFT")
	
	hasInitialized = true
end