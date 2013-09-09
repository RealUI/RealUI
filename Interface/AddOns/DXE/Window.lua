local addon = DXE
local L = addon.L

local windows = {}
local buttonSize = 10
local titleHeight = 12
local titleBarInset = 2
local handlers = {}

---------------------------------------
-- SETTINGS
---------------------------------------

local pfl

local function SkinWindow(window)
	local r,g,b,a = unpack(pfl.Windows.TitleBarColor)
	window.gradient:SetTexture(r,g,b,a)
	window.gradient:SetGradient("HORIZONTAL",r,g,b,0,0,0)
end

function addon:UpdateWindowSettings()
	for window in pairs(windows) do SkinWindow(window) end
end

local function RefreshProfile(db) 
	pfl = db.profile 
	addon:UpdateWindowSettings()
end
addon:AddToRefreshProfile(RefreshProfile)

---------------------------------------
-- PROTOTYPE
---------------------------------------

local prototype = {}

function prototype:AddTitleButton(texture,OnClick,text)
	--[===[@debug@
	assert(type(texture) == "string")
	assert(type(OnClick) == "function")
	assert(type(text) == "string")
	--@end-debug@]===]

	local button = CreateFrame("Button",nil,self.faux_window)
	button:SetWidth(buttonSize)
	button:SetHeight(buttonSize)
	button:SetPoint("RIGHT",self.lastbutton,"LEFT")
	button:SetScript("OnClick",OnClick)
	button:SetScript("OnEnter",handlers.Button_OnEnter)
	button:SetScript("OnLeave",handlers.Button_OnLeave)
	button:SetFrameLevel(button:GetFrameLevel()+5)
	button.t = button:CreateTexture(nil,"ARTWORK")
	button.t:SetVertexColor(0.33,0.33,0.33)
	button.t:SetAllPoints(true)
	button.t:SetTexture(texture)
	addon:AddTooltipText(button,text)
	self.lastbutton = button
end

function prototype:SetContentInset(inset)
	self.content:ClearAllPoints()
	self.content:SetPoint("TOPLEFT",self.container,"TOPLEFT",inset,-inset)
	self.content:SetPoint("BOTTOMRIGHT",self.container,"BOTTOMRIGHT",-inset,inset)
end

function prototype:SetTitle(text)
	self.titletext:SetText(text)
end

function prototype:RegisterCallback(event,func)
	self.callbacks[event] = func
end

function prototype:Fire(event)
	if self.callbacks[event] then
		self.callbacks[event]()
	end
end

function prototype:DisableResizing()
	self.__noresizing = true
end

---------------------------------------
-- HANDLERS
---------------------------------------
local handlers

handlers = {
	Anchor_OnSizeChanged = function(self, width, height)
		if self._sizing then
			if not self.__noresizing and IsShiftKeyDown() then
				self.ratio = height / width

				self.faux_window:SetWidth((width * self:GetEffectiveScale()) / self.faux_window:GetEffectiveScale())
				self.faux_window:SetHeight((height * self:GetEffectiveScale()) / self.faux_window:GetEffectiveScale())

				self:Fire("OnSizeChanged")
			else
				local h = width * self.ratio
				self:SetHeight(h)
				-- self.faux_window:GetEffectiveScale() doesn't work because this 
				-- handler is called again by SetHeight, which then causes the 
				-- calculated scale to become 1
				local scale = (width * self:GetEffectiveScale()) / (self.faux_window:GetWidth() * UIParent:GetEffectiveScale())
				self.faux_window:SetScale(scale)

				self:Fire("OnScaleChanged")
			end
		end
	end,

	Corner_OnMouseDown = function(self)
		self.window._sizing = true
		self.window:StartSizing("BOTTOMRIGHT")
	end,

	Corner_OnMouseUp = function(self)
		self.window:StopMovingOrSizing()
		self.window._sizing = nil
		addon:SaveDimensions(self.window.faux_window)
		addon:SaveScale(self.window.faux_window)
		addon:SaveDimensions(self.window)
		addon:SavePosition(self.window)
	end,

	Button_OnLeave = function(self)
		self.t:SetVertexColor(0.33,0.33,0.33)
	end,

	Button_OnEnter = function(self)
		self.t:SetVertexColor(0,1,0)
	end,
}

---------------------------------------
-- WINDOW CREATION
---------------------------------------

function addon:CreateWindow(name,width,height)
	--[===[@debug@
	assert(type(name) == "string")
	assert(type(width) == "number")
	assert(type(height) == "number")
	--@end-debug@]===]

	local properName = name:gsub(" ","")

	local window = CreateFrame("Frame","DXEWindow"..properName,UIParent)
	window:SetWidth(width)
	window:SetHeight(height)
	window:SetMovable(true)
	window:SetClampedToScreen(true)
	window:SetResizable(true)
	window:SetMinResize(50,50)

	-- Inside
	-- Important: Make sure faux_window:GetEffectiveScale() == UIParent:GetEffectiveScale() on creation
	local faux_window = CreateFrame("Frame","DXEWindow"..properName.."Frame",window)
	faux_window:SetWidth(width)
	faux_window:SetHeight(height)
	addon:RegisterBackground(faux_window)
	faux_window:SetPoint("TOPLEFT")
	window.faux_window = faux_window

	local corner = CreateFrame("Frame", nil, faux_window)
	corner:SetFrameLevel(faux_window:GetFrameLevel() + 9)
	corner:EnableMouse(true)
	corner:SetScript("OnMouseDown", handlers.Corner_OnMouseDown)
	corner:SetScript("OnMouseUp", handlers.Corner_OnMouseUp)
	corner:SetHeight(12)
	corner:SetWidth(12)
	corner:SetPoint("BOTTOMRIGHT")
	corner.t = corner:CreateTexture(nil,"ARTWORK")
	corner.t:SetAllPoints(true)
	corner.t:SetTexture("Interface\\Addons\\DXE\\Textures\\ResizeGrip.tga")
	addon:AddTooltipText(corner,L["|cffffff00Click|r to scale"].."\n"..L["|cffffff00Shift + Click|r to resize"])
	corner.window = window

	-- Border
	local border = CreateFrame("Frame",nil,faux_window)
	border:SetAllPoints(true)
	border:SetFrameLevel(border:GetFrameLevel()+10)
	addon:RegisterBorder(border)

	-- Title Bar
	local titlebar = CreateFrame("Frame",nil,faux_window)
	titlebar:SetPoint("TOPLEFT",faux_window,"TOPLEFT",titleBarInset,-titleBarInset)
	titlebar:SetPoint("BOTTOMRIGHT",faux_window,"TOPRIGHT",-titleBarInset, -(titleHeight+titleBarInset))
	titlebar:EnableMouse(true)
	titlebar:SetMovable(true)
	addon:AddTooltipText(titlebar,L["|cffffff00Shift + Click|r to move"])
	self:RegisterMoveSaving(titlebar,"CENTER","UIParent","CENTER",0,0,true,window)

	local gradient = titlebar:CreateTexture(nil,"ARTWORK")
	gradient:SetAllPoints(true)
	window.gradient = gradient

	local titletext = titlebar:CreateFontString(nil,"OVERLAY")
	titletext:SetFont(GameFontNormal:GetFont(),8)
	titletext:SetPoint("LEFT",titlebar,"LEFT",5,0)
	titletext:SetText(name)
	titletext:SetShadowOffset(1,-1)
	titletext:SetShadowColor(0,0,0)
	window.titletext = titletext

	local close = CreateFrame("Button",nil,faux_window)
	close:SetFrameLevel(close:GetFrameLevel()+5)
	close:SetScript("OnClick",function() window:Hide() end)
	close.t = close:CreateTexture(nil,"ARTWORK")
	close.t:SetAllPoints(true)
	close.t:SetTexture("Interface\\Addons\\DXE\\Textures\\Window\\X.tga")
	close.t:SetVertexColor(0.33,0.33,0.33)
	close:SetScript("OnEnter",handlers.Button_OnEnter)
	close:SetScript("OnLeave",handlers.Button_OnLeave)
	addon:AddTooltipText(close,L["Close"])
	close:SetWidth(buttonSize)
	close:SetHeight(buttonSize)
	close:SetPoint("RIGHT",titlebar,"RIGHT")

	window.lastbutton = close

	-- Container
	local container = CreateFrame("Frame",nil,faux_window)
	container:SetPoint("TOPLEFT",faux_window,"TOPLEFT",1,-titleHeight-titleBarInset)
	container:SetPoint("BOTTOMRIGHT",faux_window,"BOTTOMRIGHT",-1,1)
	window.container = container

	-- Content
	local content = CreateFrame("Frame",nil,container)
	content:SetPoint("TOPLEFT",container,"TOPLEFT")
	content:SetPoint("BOTTOMRIGHT",container,"BOTTOMRIGHT")
	window.content = content

	for k,v in pairs(prototype) do window[k] = v end

	windows[window] = true

	self:RegisterDefaultScale(faux_window)
	self:RegisterDefaultDimensions(window)
	self:RegisterDefaultDimensions(faux_window)

	self:LoadScale(faux_window:GetName())
	self:LoadPosition(window:GetName())
	self:LoadDimensions(window:GetName())
	self:LoadDimensions(faux_window:GetName())

	window.ratio = window:GetHeight() / window:GetWidth()
	window:SetScript("OnSizeChanged", handlers.Anchor_OnSizeChanged)

	SkinWindow(window)

	window.callbacks = {}

	return window
end

function addon:CloseAllWindows()
	for w in pairs(windows) do w:Hide() end
end

---------------------------------------
-- REGISTRY
---------------------------------------
local registry = {}

function addon:RegisterWindow(name,openFunc)
	--[===[@debug@
	assert(type(name) == "string")
	assert(type(openFunc) == "function")
	--@end-debug@]===]
	registry[name] = openFunc
end

---------------------------------------
-- DROPDOWN MENU
---------------------------------------

do
	local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
	local info

	local function Initialize(self,level)
		level = 1
		if level == 1 then
			info = UIDropDownMenu_CreateInfo()
			info.isTitle = true 
			info.text = L["Windows"]
			info.notCheckable = true 
			info.justifyH = "LEFT"
			UIDropDownMenu_AddButton(info,1)

			for name,openFunc in pairs(registry) do
				info = UIDropDownMenu_CreateInfo()
				info.text = name
				info.notCheckable = true
				info.func = openFunc
				info.owner = self
				UIDropDownMenu_AddButton(info,1)
			end
		end
	end

	function addon:CreateWindowsDropDown()
		local windows = CreateFrame("Frame", "DXEPaneWindows", UIParent, "UIDropDownMenuTemplate") 
		UIDropDownMenu_Initialize(windows, Initialize, "MENU")
		return windows
	end
end
