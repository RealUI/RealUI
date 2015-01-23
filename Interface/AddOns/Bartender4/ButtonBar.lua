--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
--[[ Generic Template for a Bar which contains Buttons ]]
local _, Bartender4 = ...
local Bar = Bartender4.Bar.prototype

local setmetatable, tostring, pairs = setmetatable, tostring, pairs

local ButtonBar = setmetatable({}, {__index = Bar})
local ButtonBar_MT = {__index = ButtonBar}

local defaults = Bartender4:Merge({
	padding = 2,
	rows = 1,
	hidemacrotext = false,
	hidehotkey = false,
	hideequipped = false,
	skin = {
		ID = "DreamLayout",
		Backdrop = true,
		Gloss = 0,
		Zoom = false,
		Colors = {},
	},
}, Bartender4.Bar.defaults)

Bartender4.ButtonBar = {}
Bartender4.ButtonBar.prototype = ButtonBar
Bartender4.ButtonBar.defaults = defaults

local LBF = LibStub("LibButtonFacade", true)
local Masque = LibStub("Masque", true)

function Bartender4.ButtonBar:Create(id, config, name)
	local bar = setmetatable(Bartender4.Bar:Create(id, config, name), ButtonBar_MT)

	if Masque then
		bar.MasqueGroup = Masque:Group("Bartender4", tostring(id))
	elseif LBF then
		bar.LBFGroup = LBF:Group("Bartender4", tostring(id))
		bar.LBFGroup.SkinID = config.skin.ID or "Blizzard"
		bar.LBFGroup.Backdrop = config.skin.Backdrop
		bar.LBFGroup.Gloss = config.skin.Gloss
		bar.LBFGroup.Colors = config.skin.Colors

		LBF:RegisterSkinCallback("Bartender4", self.SkinChanged, self)
	end

	return bar
end

local barregistry = Bartender4.Bar.barregistry
function Bartender4.ButtonBar:SkinChanged(SkinID, Gloss, Backdrop, Group, Button, Colors)
	local bar = barregistry[tostring(Group)]
	if not bar then return end

	bar:SkinChanged(SkinID, Gloss, Backdrop, Colors, Button)
end

ButtonBar.BT4BarType = "ButtonBar"

function ButtonBar:UpdateSkin()
	if not self.LBFGroup then return end
	local config = self.config
	self.LBFGroup:Skin(config.skin.ID, config.skin.Gloss, config.skin.Backdrop, config.skin.Colors)
end

function ButtonBar:ApplyConfig(config)
	Bar.ApplyConfig(self, config)
	ButtonBar.UpdateSkin(self)
	-- any module inherting this template should call UpdateButtonLayout after setting up its buttons, we cannot call it here
	--self:UpdateButtonLayout()
end

function ButtonBar:UpdateButtonConfig()

end

-- get the current padding
function ButtonBar:GetPadding()
	return self.config.padding
end

-- set the padding and refresh layout
function ButtonBar:SetPadding(pad)
	if pad ~= nil then
		self.config.padding = pad
	end
	self:UpdateButtonLayout()
end


-- get the current number of rows
function ButtonBar:GetRows()
	return self.config.rows
end

-- set the number of rows and refresh layout
function ButtonBar:SetRows(rows)
	if rows ~= nil then
		self.config.rows = rows
	end
	self:UpdateButtonLayout()
end

function ButtonBar:GetZoom()
	return self.config.skin.Zoom
end

function ButtonBar:SetZoom(zoom)
	self.config.skin.Zoom = zoom
	self:UpdateButtonLayout()
end

function ButtonBar:SetHideMacroText(state)
	if state ~= nil then
		self.config.hidemacrotext = state
	end
	self:UpdateButtonConfig()
end

function ButtonBar:GetHideMacroText()
	return self.config.hidemacrotext
end

function ButtonBar:SetHideHotkey(state)
	if state ~= nil then
		self.config.hidehotkey = state
	end
	self:UpdateButtonConfig()
end

function ButtonBar:GetHideHotkey()
	return self.config.hidehotkey
end

function ButtonBar:SetHideEquipped(state)
	if state ~= nil then
		self.config.hideequipped = state
	end
	self:UpdateButtonConfig()
end

function ButtonBar:GetHideEquipped()
	return self.config.hideequipped
end

function ButtonBar:SetHGrowth(value)
	self.config.position.growHorizontal = value
	self:AnchorOverlay()
	self:UpdateButtonLayout()
end

function ButtonBar:GetHGrowth()
	return self.config.position.growHorizontal
end

function ButtonBar:SetVGrowth(value)
	self.config.position.growVertical = value
	self:AnchorOverlay()
	self:UpdateButtonLayout()
end

function ButtonBar:GetVGrowth()
	return self.config.position.growVertical
end


ButtonBar.ClickThroughSupport = true
function ButtonBar:SetClickThrough(click)
	if click ~= nil then
		self.config.clickthrough = click
	end
	self:ForAll("EnableMouse", not self.config.clickthrough)
end

local math_floor = math.floor
local math_ceil = math.ceil
-- align the buttons and correct the size of the bar overlay frame
ButtonBar.button_width = 36
ButtonBar.button_height = 36
function ButtonBar:UpdateButtonLayout()
	local buttons = self.buttons
	local pad = self:GetPadding()

	local numbuttons = self.numbuttons or #buttons

	-- bail out if the bar has no buttons, for whatever reason
	-- (eg. stanceless class, or no stances learned yet, etc.)
	if numbuttons == 0 then return end

	local Rows = self:GetRows()
	local ButtonPerRow = math_ceil(numbuttons / Rows) -- just a precaution
	Rows = math_ceil(numbuttons / ButtonPerRow)
	if Rows > numbuttons then
		Rows = numbuttons
		ButtonPerRow = 1
	end

	local hpad = pad + (self.hpad_offset or 0)
	local vpad = pad + (self.vpad_offset or 0)

	self:SetSize((self.button_width + hpad) * ButtonPerRow - pad + 10, (self.button_height + vpad) * Rows - pad + 10)

	local h1, h2, v1, v2
	local xOff, yOff
	if self.config.position.growHorizontal == "RIGHT" then
		h1, h2 = "LEFT", "RIGHT"
		xOff = 5
	else
		h1, h2 = "RIGHT", "LEFT"
		xOff = -3

		hpad = -hpad
	end

	if self.config.position.growVertical == "DOWN" then
		v1, v2 = "TOP", "BOTTOM"
		yOff = -3
	else
		v1, v2 = "BOTTOM", "TOP"
		yOff = 5

		vpad = -vpad
	end

	-- anchor button 1
	local anchor = self:GetAnchor()
	buttons[1]:ClearSetPoint(anchor, self, anchor, xOff - (self.hpad_offset or 0), yOff - (self.vpad_offset or 0))

	-- and anchor all other buttons relative to our button 1
	for i = 2, numbuttons do
		-- jump into a new row
		if ((i-1) % ButtonPerRow) == 0 then
			buttons[i]:ClearSetPoint(v1 .. h1, buttons[i-ButtonPerRow], v2 .. h1, 0, -vpad)
		-- align to the previous button
		else
			buttons[i]:ClearSetPoint("TOP" .. h1, buttons[i-1], "TOP" .. h2, hpad, 0)
		end
	end

	if not LBF and not Masque then
		for i = 1, #buttons do
			local button = buttons[i]
			if button.icon and self.config.skin.Zoom then
				button.icon:SetTexCoord(0.07,0.93,0.07,0.93)
			elseif button.icon then
				button.icon:SetTexCoord(0,1,0,1)
			end
		end
	end
end

function ButtonBar:SkinChanged(SkinID, Gloss, Backdrop, Colors)
	self.config.skin.ID = SkinID
	self.config.skin.Gloss = Gloss
	self.config.skin.Backdrop = Backdrop
	self.config.skin.Colors = Colors
end

--[[===================================================================================
	Utility function
===================================================================================]]--

-- get a iterator over all buttons
function ButtonBar:GetAll()
	return pairs(self.buttons)
end

-- execute a member function on all buttons
function ButtonBar:ForAll(method, ...)
	if not self.buttons then return end
	for _, button in self:GetAll() do
		local func = button[method]
		if func then
			func(button, ...)
		end
	end
end
