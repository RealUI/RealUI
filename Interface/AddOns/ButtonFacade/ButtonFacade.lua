--[[
	This file is part of 'Masque', an add-on for World of Warcraft. For license information,
	please see the included License.txt file.

	* File.....: ButtonFacade\ButtonFacade.lua
	* Revision.: 381
	* Author...: StormFX

	ButtonFacade Support

	[ Notes ]

	This package will create a 'ButtonFacade' add-on to ensure compability for older add-ons and skins.
	The directory that this file is located in MUST be installed as a separate add-on in order for it to work correctly.
]]

local LibStub = assert(LibStub, "Masque requires LibStub.")
local MSQ = LibStub("Masque", true)

if not MSQ then return end

local LBF = LibStub:NewLibrary("LibButtonFacade", 40300)

function LBF:GetNormalVertexColor(Button)
	local Region = self:GetNormal(Button)
	if Region then
		return Region:GetVertexColor()
	end
end

function LBF:SetNormalVertexColor(Button, r, g, b, a)
	local Region = self:GetNormal(Button)
	if Region then
		Region:SetVertexColor(r, g, b, a)
	end
end

function LBF:GetNormalTexture(Button)
	return self:GetNormal(Button)
end

function LBF:GetGlossLayer(Button)
	return self:GetGloss(Button)
end

function LBF:GetBackdropLayer(Button)
	return self:GetBackdrop(Button)
end

local __MTT = {}
local __MTF = function() end
local __MTR = function() return __MTT end

-- Deprecated
LBF.RegisterSkinCallback = __MTF
LBF.RegisterGuiCallback = __MTF
LBF.ListAddons = __MTR
LBF.ListGroups = __MTR
LBF.ListButtons = __MTR
LBF.ListSkins = __MTR

setmetatable(LBF, {__index = MSQ})
