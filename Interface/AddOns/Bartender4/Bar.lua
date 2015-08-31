--[[
	Copyright (c) 2009, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
--[[
	Generic Bar Frame Template
]]
local _, Bartender4 = ...
local Bar = CreateFrame("Button")
local Bar_MT = {__index = Bar}

local table_concat, table_insert, tostring, assert, pairs, min, max = table.concat, table.insert, tostring, assert, pairs, min, max
local setmetatable, tonumber = setmetatable, tonumber

-- GLOBALS: SpellFlyout, UIParent, GameFontNormal
-- GLOBALS: CreateFrame, MouseIsOver, RegisterStateDriver, UnregisterStateDriver

--[[===================================================================================
	Universal Bar Contructor
===================================================================================]]--

local defaults = {
	alpha = 1,
	fadeout = false,
	fadeoutalpha = 0.1,
	fadeoutdelay = 0.2,
	visibility = {
		vehicleui = true,
		overridebar = true,
		stance = {},
	},
	position = {
		scale = 1,
		growVertical = "DOWN",
		growHorizontal = "RIGHT",
	},
	clickthrough = false,
}

local Sticky = LibStub("LibSimpleSticky-1.0")
local LibWin = LibStub("LibWindow-1.1")
local snapBars = { WorldFrame, UIParent }

local barOnEnter, barOnLeave, barOnDragStart, barOnDragStop, barOnClick, barOnUpdateFunc, barOnAttributeChanged
do
	function barOnEnter(self)
		if not self:GetParent().isMoving then
			self:SetBackdropBorderColor(0.5, 0.5, 0, 1)
		end
	end

	function barOnLeave(self)
		self:SetBackdropBorderColor(0, 0, 0, 0)
	end

	local function barReAnchorForSnap(self)
		local x,y,anchor = nil, nil, self:GetAnchor()
		x = (self.config.position.growHorizontal == "RIGHT") and self:GetLeft() or self:GetRight()
		y = (self.config.position.growVertical == "DOWN") and self:GetTop() or self:GetBottom()
		self:ClearSetPoint(anchor, UIParent, "BOTTOMLEFT", x, y)
		self:SetWidth(self.overlay:GetWidth())
		self:SetHeight(self.overlay:GetHeight())
	end

	local function barReAnchorNormal(self)
		local x,y,anchor = nil, nil, self:GetAnchor()
		x = (self.config.position.growHorizontal == "RIGHT") and self:GetLeft() or self:GetRight()
		y = (self.config.position.growVertical == "DOWN") and self:GetTop() or self:GetBottom()
		self:ClearSetPoint(anchor, UIParent, "BOTTOMLEFT", x, y)
		self:SetWidth(1)
		self:SetHeight(1)
	end

	function barOnDragStart(self)
		local parent = self:GetParent()
		if Bartender4.db.profile.snapping then
			local offset = 8 - (parent.config.padding or 0)
			-- we need to re-anchor the bar and set its proper width for snaping to work properly
			barReAnchorForSnap(parent)
			Sticky:StartMoving(parent, snapBars, offset, offset, offset, offset)
		else
			parent:StartMoving()
		end
		self:SetBackdropBorderColor(0, 0, 0, 0)
		parent.isMoving = true
	end

	function barOnDragStop(self)
		local parent = self:GetParent()
		if parent.isMoving then
			if Bartender4.db.profile.snapping then
				local sticky, stickTo = Sticky:StopMoving(parent)
				barReAnchorNormal(parent)
				--Bartender4:Print(sticky, stickTo and stickTo:GetName() or nil)
			else
				parent:StopMovingOrSizing()
			end
			parent:SavePosition()
			parent.isMoving = nil
		end
	end

	function barOnClick(self)
		-- TODO: Hide/Show bar on Click
		-- TODO: Once dropdown config is stable, show dropdown on rightclick
	end

	function barOnUpdateFunc(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > self.config.fadeoutdelay then
			self:ControlFadeOut(self.elapsed)
			self.elapsed = 0
		end
	end

	function barOnAttributeChanged(self, attribute, value)
		if attribute == "fade" then
			if value then
				self:SetScript("OnUpdate", barOnUpdateFunc)
				self:ControlFadeOut()
			else
				self:SetScript("OnUpdate", nil)
				self.faded = nil
				self:SetConfigAlpha()
			end
		end
	end
end

local barregistry = {}
Bartender4.Bar = {}
Bartender4.Bar.defaults = defaults
Bartender4.Bar.prototype = Bar
Bartender4.Bar.barregistry = barregistry
function Bartender4.Bar:Create(id, config, name)
	id = tostring(id)
	assert(not barregistry[id], "duplicated entry in barregistry.")

	local bar = setmetatable(CreateFrame("Frame", ("BT4Bar%s"):format(id), UIParent, "SecureHandlerStateTemplate"), Bar_MT)
	barregistry[id] = bar

	bar.id = id
	bar.name = name or id
	bar.config = config
	bar:SetMovable(true)
	bar:HookScript("OnAttributeChanged", barOnAttributeChanged)

	bar:SetWidth(1)
	bar:SetHeight(1)

	local overlay = CreateFrame("Button", bar:GetName() .. "Overlay", bar)
	bar.overlay = overlay
	overlay.bar = bar
	table_insert(snapBars, overlay)
	overlay:EnableMouse(true)
	overlay:RegisterForDrag("LeftButton")
	overlay:RegisterForClicks("LeftButtonUp")
	overlay:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tile = true,
		tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = {left = 5, right = 3, top = 3, bottom = 5}
	})
	overlay:SetBackdropColor(0, 1, 0, 0.5)
	overlay:SetBackdropBorderColor(0.5, 0.5, 0, 0)
	overlay.Text = overlay:CreateFontString(nil, "ARTWORK")
	overlay.Text:SetFontObject(GameFontNormal)
	overlay.Text:SetText(name)
	overlay.Text:Show()
	overlay.Text:ClearAllPoints()
	overlay.Text:SetPoint("CENTER", overlay, "CENTER")

	overlay:SetScript("OnEnter", barOnEnter)
	overlay:SetScript("OnLeave", barOnLeave)
	overlay:SetScript("OnDragStart", barOnDragStart)
	overlay:SetScript("OnDragStop", barOnDragStop)
	overlay:SetScript("OnClick", barOnClick)

	overlay:SetFrameLevel(bar:GetFrameLevel() + 10)
	bar:AnchorOverlay()
	overlay:Hide()

	bar.elapsed = 0
	bar.hidedriver = {}

	return bar
end

function Bartender4.Bar:GetAll()
	return pairs(barregistry)
end

function Bartender4.Bar:ForAll(method, ...)
	for _,bar in self:GetAll() do
		local func = bar[method]
		if func then
			func(bar, ...)
		end
	end
end

--[[===================================================================================
	Universal Bar Prototype
===================================================================================]]--

Bar.BT4BarType = "Bar"

function Bar:ApplyConfig(config)
	if config then
		self.config = config
	end
	LibWin.RegisterConfig(self, self.config.position)

	self:UpgradeConfig()
	if self.disabled then return end

	if Bartender4.Locked then
		self:Lock()
	else
		self:Unlock()
	end
	self:LoadPosition()
	self:SetConfigScale()
	self:SetConfigAlpha()
	self:SetClickThrough()
	self:InitVisibilityDriver()
end

function Bar:GetAnchor()
	return ((self.config.position.growVertical == "DOWN") and "TOP" or "BOTTOM") .. ((self.config.position.growHorizontal == "RIGHT") and "LEFT" or "RIGHT")
end

function Bar:AnchorOverlay()
	self.overlay:ClearAllPoints()
	local anchor = self:GetAnchor()
	self.overlay:SetPoint(anchor, self, anchor)
end

function Bar:UpgradeConfig()
	local version = self.config.version or 1
	if version < 2 then
		-- LibWindow migration, move scale into position
		if self.config.scale then
			self.config.position.scale = self.config.scale
			self.config.scale = nil
		end
		-- LibWindow migration, update position data
		do
			local pos = self.config.position
			self:SetScale(pos.scale)
			local x, y, s = pos.x, pos.y, self:GetEffectiveScale()
			local point, relPoint = pos.point, pos.relPoint
			if x and y and point and relPoint then
				x, y = x/s, y/s
				self:ClearSetPoint(point, UIParent, relPoint, x, y)
				self:SavePosition()
				pos.relPoint = nil
			end
		end
	end
	if version < 3 then
		-- Size adjustment is done in first SetSize
		self.needSizeFix = true
	end
	self.config.version = Bartender4.CONFIG_VERSION
end

function Bar:Unlock()
	if self.disabled or self.unlocked then return end
	self.unlocked = true
	self:DisableVisibilityDriver()
	self:Show()
	self.overlay:Show()
end

function Bar:Lock()
	if self.disabled or not self.unlocked then return end
	self.unlocked = nil
	self:StopDragging()

	self:ApplyVisibilityDriver()

	self.overlay:Hide()
end

function Bar:StopDragging()
	barOnDragStop(self.overlay)
end

function Bar:LoadPosition()
	LibWin.RestorePosition(self)
end

function Bar:SavePosition()
	LibWin.SavePosition(self)
end

function Bar:SetSize(width, height)
	self.overlay:SetWidth(width)
	self.overlay:SetHeight(height or width)
	if self.needSizeFix then
		self:SetWidth(width)
		self:SetHeight(height or width)
		local x, y = self:GetLeft(), self:GetTop()
		self:ClearSetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
		self:SetWidth(1)
		self:SetHeight(1)
		self:SavePosition()
		self.needSizeFix = nil
	end
end

function Bar:GetConfigAlpha()
	return self.config.alpha
end

function Bar:SetConfigAlpha(alpha)
	if alpha then
		self.config.alpha = alpha
	end
	if not self.faded then
		self:SetAlpha(self.config.alpha)
		if self.ForAll then
			self:ForAll("UpdateAlpha")
		end
	end
end

function Bar:GetConfigScale()
	return self.config.position.scale
end

function Bar:SetConfigScale(scale)
	if scale then
		LibWin.SetScale(self, scale)
	end
end

function Bar:GetClickThrough()
	return self.config.clickthrough
end

function Bar:SetClickThrough(click)
	if click ~= nil then
		self.config.clickthrough = click
	end
	if self.ControlClickThrough then
		self:ControlClickThrough()
	end
end

function Bar:GetFadeOut()
	return self.config.fadeout
end

function Bar:SetFadeOut(fadeout)
	if fadeout ~= nil then
		self.config.fadeout = fadeout
		self:InitVisibilityDriver()
	end
end

function Bar:GetFadeOutAlpha()
	return self.config.fadeoutalpha
end

function Bar:SetFadeOutAlpha(fadealpha)
	if fadealpha ~= nil then
		self.config.fadeoutalpha = fadealpha
	end
	if self.faded then
		self:SetAlpha(self.config.fadeoutalpha)
		if self.ForAll then
			self:ForAll("UpdateAlpha")
		end
	end
end

function Bar:GetFadeOutDelay()
	return self.config.fadeoutdelay
end

function Bar:SetFadeOutDelay(delay)
	if delay ~= nil then
		self.config.fadeoutdelay = delay
	end
end

local function MouseIsOverBar(bar)
	if MouseIsOver(bar.overlay)
	or (SpellFlyout:IsShown() and SpellFlyout:GetParent() and SpellFlyout:GetParent():GetParent() == bar and MouseIsOver(SpellFlyout)) then
		return true
	end
	return false
end

function Bar:ControlFadeOut()
	if self.faded and MouseIsOverBar(self) then
		self:SetAlpha(self.config.alpha)
		self.faded = nil
	elseif not self.faded and not MouseIsOverBar(self) then
		local fade = self:GetAttribute("fade")
		if tonumber(fade) then
			fade = min(max(fade, 0), 100) / 100
			self:SetAlpha(fade)
		else
			self:SetAlpha(self.config.fadeoutalpha or 0)
		end
		self.faded = true
	end
	if self.ForAll then
		self:ForAll("UpdateAlpha")
	end
end

local directVisCond = {
	pet = true,
	nopet = true,
	combat = true,
	nocombat = true,
	mounted = true,
}
function Bar:InitVisibilityDriver(returnOnly)
	local tmpDriver
	if returnOnly then
		tmpDriver = self.hidedriver
	else
		UnregisterStateDriver(self, 'vis')
	end
	self.hidedriver = {}

	self:SetAttribute("_onstate-vis", [[
		if not newstate then return end
		if newstate == "show" then
			self:Show()
			self:SetAttribute("fade", false)
		elseif strsub(newstate, 1, 4) == "fade" then
			self:Show()
			self:SetAttribute("fade", (newstate == "fade") and true or strsub(newstate, 6))
		elseif newstate == "hide" then
			self:Hide()
		end
	]])

	if self.config.visibility.custom and not returnOnly then
		table_insert(self.hidedriver, self.config.visibility.customdata or "")
	else
		for key, value in pairs(self.config.visibility) do
			if value then
				if key == "always" then
					table_insert(self.hidedriver, "hide")
				elseif key == "possess" then
					table_insert(self.hidedriver, "[possessbar]hide")
				elseif key == "overridebar" then
					table_insert(self.hidedriver, "[overridebar]hide")
				elseif key == "vehicleui" then
					table_insert(self.hidedriver, "[vehicleui]hide")
				elseif key == "vehicle" then
					table_insert(self.hidedriver, "[target=vehicle,exists]hide")
				elseif directVisCond[key] then
					table_insert(self.hidedriver, ("[%s]hide"):format(key))
				elseif key == "stance" then
					for k,v in pairs(value) do
						if v then
							table_insert(self.hidedriver, ("[stance:%d]hide"):format(k))
						end
					end
				elseif key == "custom" or key == "customdata" then
					-- do nothing
				else
					Bartender4:Print("Invalid visibility state: "..key)
				end
			end
		end
	end
	-- always hide in petbattles
	table_insert(self.hidedriver, 1, "[petbattle]hide")
	-- add fallback at the end
	table_insert(self.hidedriver, self.config.fadeout and "fade" or "show")

	if not returnOnly then
		self:ApplyVisibilityDriver()
	else
		self.hidedriver, tmpDriver = tmpDriver, self.hidedriver
		return table_concat(tmpDriver, ";")
	end
end

function Bar:ApplyVisibilityDriver()
	if self.unlocked then return end
	-- default state is shown
	local driver = table_concat(self.hidedriver, ";")
	RegisterStateDriver(self, "vis", driver)
end

function Bar:DisableVisibilityDriver()
	UnregisterStateDriver(self, "vis")
	self:SetAttribute("state-vis", "show")
	self:Show()
end

function Bar:GetVisibilityOption(option, index)
	if option == "stance" then
		return self.config.visibility.stance[index]
	else
		return self.config.visibility[option]
	end
end

function Bar:SetVisibilityOption(option, value, arg)
	if option == "stance" then
		self.config.visibility.stance[value] = arg
	else
		self.config.visibility[option] = value
	end
	self:InitVisibilityDriver()
end

function Bar:CopyCustomConditionals()
	self.config.visibility.customdata = self:InitVisibilityDriver(true)
	self:InitVisibilityDriver()
end

function Bar:Enable()
	if not self.disabled then return end
	self.disabled = nil
end

function Bar:Disable()
	if self.disabled then return end
	self:Lock()
	self.disabled = true
	self:UnregisterAllEvents()
	self:DisableVisibilityDriver()
	self:SetAttribute("state-vis", nil)
	self:Hide()
end

--[[
	Lazyness functions
]]
function Bar:ClearSetPoint(...)
	self:ClearAllPoints()
	self:SetPoint(...)
end
