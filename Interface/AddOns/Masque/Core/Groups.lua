--[[
	This file is part of 'Masque', an add-on for World of Warcraft. For license information,
	please see the included License.txt file.

	* File.....: Core\Groups.lua
	* Revision.: 384
	* Author...: StormFX, JJSheets

	Group API
]]

local MASQUE, Core = ...
local error, pairs, setmetatable, type, unpack = error, pairs, setmetatable, type, unpack

local Skins, SkinList = Core.Skins, Core.SkinList
local GetColor, SkinButton = Core.GetColor, Core.SkinButton

---------------------------------------------
-- Callbacks
---------------------------------------------

local FireCB

do
	local Callbacks = {}

	-- Notifies an add-on of skin changes.
	function FireCB(Addon, Group, SkinID, Gloss, Backdrop, Colors)
		local args = Callbacks[Addon]
		if args then
			for arg, callback in pairs(args) do
				callback(arg and arg, Group, SkinID, Gloss, Backdrop, Colors)
			end
		end
	end

	-- Registers an add-on to be notified on skin changes.
	function Core.API:Register(Addon, Callback, arg)
		local arg = Callback and arg or false
		Callbacks[Addon] = Callbacks[Addon] or {}
		Callbacks[Addon][arg] = Callback
	end
end

---------------------------------------------
-- Groups
---------------------------------------------

local Groups = {}
local GMT

-- Returns a group's ID.
local function GetID(Addon, Group)
	local id = MASQUE
	if type(Addon) == "string" then
		id = Addon
		if type(Group) == "string" then
			id = id.."_"..Group
		end
	end
	return id
end

-- Creates a new group.
local function NewGroup(Addon, Group)
	local id = GetID(Addon, Group)
	local o = {
		Addon = Addon,
		Group = Group,
		ID = id,
		Buttons = {},
		SubList = (not Group and {}) or nil,
	}
	setmetatable(o, GMT)
	Groups[id] = o
	if Addon then
		local Parent = Groups[MASQUE] or NewGroup()
		o.Parent = Parent
		Parent.SubList[Addon] = Addon
		Core:UpdateOptions()
	end
	if Group then
		local Parent = Groups[Addon] or NewGroup(Addon)
		o.Parent = Parent
		Parent.SubList[id] = Group
		Core:UpdateOptions(Addon)
	end
	o:Update(true, true)
	return o
end

-- Returns a button group.
function Core:Group(Addon, Group)
	return Groups[GetID(Addon, Group)] or NewGroup(Addon, Group)
end

-- Returns a list of registered add-ons.
function Core:ListAddons()
	local Group = self:Group()
	return Group.SubList
end

-- Returns a list of button groups registered to an add-on.
function Core:ListGroups(Addon)
	return Groups[Addon].SubList
end

-- API method that validates and returns a button group.
function Core.API:Group(Addon, Group)
	if type(Addon) ~= "string" or Addon == MASQUE then
		if Core.db.profile.Debug then
			error("Bad argument to method 'Group'. 'Addon' must be a string.", 2)
		end
		return
	end
	return Core:Group(Addon, Group)
end

---------------------------------------------
-- Group Metatable
---------------------------------------------

do
	local Group = {}
	local Layers = {
		FloatingBG = "Texture",
		Icon = "Texture",
		Cooldown = "Frame",
		Flash = "Texture",
		Pushed = "Special",
		Disabled = "Special",
		Checked = "Special",
		Border = "Texture",
		AutoCastable = "Texture",
		Highlight = "Special",
		Name = "Text",
		Count = "Text",
		HotKey = "Text",
		Duration = "Text",
		AutoCast = "Frame",
	}

	local __MTF = function() end

	-- Gets a button region.
	local function GetRegion(Button, Layer, Type)
		local Region
		if Type == "Special" then
			local f = Button["Get"..Layer.."Texture"]
			Region = (f and f(Button)) or false
		else
			local n = Button:GetName()
			if Layer == "AutoCast" then
				Layer = "Shine"
			end
			Region = (n and _G[n..Layer]) or false
		end
		return Region
	end

	GMT = {
		__index = {

			-- Adds or reassigns a button to the group.
			AddButton = function(self, Button, ButtonData)
				if type(Button) ~= "table" then
					if Core.db.profile.Debug then
						error("Bad argument to method 'AddButton'. 'Button' must be a button object.", 2)
					end
					return
				end
				if Group[Button] == self then
					return
				end
				if Group[Button] then
					Group[Button]:RemoveButton(Button, true)
				end
				Group[Button] = self
				if type(ButtonData) ~= "table" then
					ButtonData = {}
				end
				for Layer, Type in pairs(Layers) do
					if ButtonData[Layer] == nil then
						ButtonData[Layer] = GetRegion(Button, Layer, Type)
					end
				end
				self.Buttons[Button] = ButtonData
				if not self.db.Disabled then
					local db = self.db
					SkinButton(Button, ButtonData, db.SkinID, db.Gloss, db.Backdrop, db.Colors)
				end
			end,

			-- Removes a button from the group and optionally applies the default skin.
			RemoveButton = function(self, Button, Static)
				if Button then
					local ButtonData = self.Buttons[Button]
					Group[Button] = nil
					if ButtonData and not Static then
						SkinButton(Button, ButtonData, "Blizzard")
					end
					self.Buttons[Button] = nil
				end
			end,

			-- Deletes the current group and optionally applies the default skin.
			Delete = function(self, Static)
				local Subs = self.SubList
				if Subs then
					for Sub in pairs(Subs) do
						Groups[Sub]:Delete(Static)
					end
				end
				for Button in pairs(self.Buttons) do
					Group[Button] = nil
					if not Static then
						SkinButton(Button, self.Buttons[Button], "Blizzard")
					end
					self.Buttons[Button] = nil
				end
				if self.Parent then
					self.Parent.SubList[self.ID] = nil
				end
				Core:UpdateOptions(self.Addon)
				Groups[self.ID] = nil
			end,

			-- Reskins the group with its current settings.
			ReSkin = function(self)
				if not self.db.Disabled then
					local db = self.db
					for Button in pairs(self.Buttons) do
						SkinButton(Button, self.Buttons[Button], db.SkinID, db.Gloss, db.Backdrop, db.Colors)
					end
					if self.Addon then
						FireCB(self.Addon, self.Group, db.SkinID, db.Gloss, db.Backdrop, db.Colors)
					end
				end
			end,

			-- Returns a button layer.
			GetLayer = function(self, Button, Layer)
				if Button and Layer then
					local ButtonData = self.Buttons[Button]
					if ButtonData then
						return ButtonData[Layer]
					end
				end
			end,

			-- Returns a layer color.
			GetColor = function(self, Layer)
				local Skin = Skins[self.db.SkinID] or Skins["Blizzard"]
				return GetColor(self.db.Colors[Layer] or Skin[Layer].Color)
			end,

			-- [ Private Methods ] --

			-- These methods are for internal use only. Don't use them.

			-- Disables the group.
			Disable = function(self)
				self.db.Disabled = true
				for Button in pairs(self.Buttons) do
					SkinButton(Button, self.Buttons[Button], "Blizzard")
				end
				local Subs = self.SubList
				if Subs then
					for Sub in pairs(Subs) do
						Groups[Sub]:Disable()
					end
				end
			end,

			-- Enables the group.
			Enable = function(self)
				self.db.Disabled = false
				self:ReSkin()
				local Subs = self.SubList
				if Subs then
					for Sub in pairs(Subs) do
						Groups[Sub]:Enable()
					end
				end
			end,

			-- Validates and sets a skin option.
			SetOption = function(self, Option, Value)
				if Option == "SkinID" then
					if Value and SkinList[Value] then
						self.db.SkinID = Value
					end
				elseif Option == "Gloss" then
					if type(Value) ~= "number" then
						Value = (Value and 1) or 0
					end
					self.db.Gloss = Value
				elseif Option == "Backdrop" then
					self.db.Backdrop = (Value and true) or false
				else
					return
				end
				self:ReSkin()
				local Subs = self.SubList
				if Subs then
					for Sub in pairs(Subs) do
						Groups[Sub]:SetOption(Option, Value)
					end
				end
			end,

			-- Sets the specified layer color.
			SetColor = function(self, Layer, r, g, b, a)
				if not Layer then return end
				if r then
					self.db.Colors[Layer] = {r, g, b, a}
				else
					self.db.Colors[Layer] = nil
				end
				self:ReSkin()
				local Subs = self.SubList
				if Subs then
					for Sub in pairs(Subs) do
						Groups[Sub]:SetColor(Layer, r, g, b, a)
					end
				end
			end,

			-- Resets the group's skin back to its defaults.
			Reset = function(self, Static)
				self.db.Gloss = 0
				self.db.Backdrop = false
				self.db.Fonts = nil -- Clean up on the old "Fonts" entry.
				for Layer in pairs(self.db.Colors) do
					self.db.Colors[Layer] = nil
				end
				if not Static then
					self:ReSkin()
				end
				local Subs = self.SubList
				if Subs then
					for Sub in pairs(Subs) do
						Groups[Sub]:Reset(Static)
					end
				end
			end,

			-- Updates the group on profile activity, etc.
			Update = function(self, Static, Limit)
				self.db = Core.db.profile.Groups[self.ID]
				if self.Parent then
					local db = self.Parent.db
					if self.db.Inherit and self.db.SkinID ~= db.SkinID then
						self.db.SkinID = db.SkinID
						self.db.Gloss = db.Gloss
						self.db.Backdrop = db.Backdrop
						for Layer in pairs(self.db.Colors) do
							self.db.Colors[Layer] = nil
						end
						for Layer in pairs(db.Colors) do
							if type(db.Colors[Layer]) == "table" then
								local r, g, b, a = unpack(db.Colors[Layer])
								self.db.Colors[Layer] = {r, g, b, a}
							end
						end
						self.db.Inherit = false
					end
				end
				if not Static then
					if self.db.Disabled then
						for Button in pairs(self.Buttons) do
							SkinButton(Button, self.Buttons[Button], "Blizzard")
						end
					else
						self:ReSkin()
					end
				end
				if not Limit then
					local Subs = self.SubList
					if Subs then
						for Sub in pairs(Subs) do
							Groups[Sub]:Update(Static)
						end
					end
				end
			end,

			-- Returns an Ace3 options table for the group.
			GetOptions = function(self)
				return Core:GetOptions(self.Addon, self.Group)
			end,

			-- [ Temporary Methods ] --

			-- These methods are deprecated and will be removed.

			-- Returns a layer color.
			GetLayerColor = function(self, Layer)
				return self:GetColor(Layer)
			end,

			-- Deprecated
			AddSubGroup = __MTF,
			RemoveSubGroup = __MTF,
			SetLayerColor = __MTF,
			Skin = __MTF,
			ResetColors = __MTF,
		}
	}
end
