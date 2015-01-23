--[[
	Copyright (c) 2009, CMTitan
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	Based on Nevcairiel's RepXPBar.lua
	All rights to be transferred to Nevcairiel upon inclusion into Bartender4.
	All rights reserved, otherwise.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")

-- fetch upvalues
local Bar = Bartender4.Bar.prototype

local setmetatable = setmetatable

-- GLOBALS: UIParent

local defaults = { profile = Bartender4:Merge({
	enabled = false,
	leftCap = "DWARF",
	rightCap = "DWARF",
	artLayout = "CLASSIC",
	artSkin = "DWARF",
}, Bartender4.Bar.defaults) }

-- register module
local BlizzardArtMod = Bartender4:NewModule("BlizzardArt")

-- create prototype information
local BlizzardArt = setmetatable({}, {__index = Bar})

function BlizzardArtMod:OnInitialize()
	defaults.profile.visibility.possess = false -- Overwrite one of the bar defaults
	self.db = Bartender4.db:RegisterNamespace("BlizzardArt", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function BlizzardArtMod:OnEnable()
	if not self.bar then
		self.bar = setmetatable(Bartender4.Bar:Create("BlizzardArt", self.db.profile, L["Blizzard Art"]), {__index = BlizzardArt})
		self.bar.leftCap = self.bar:CreateTexture("BlizzardArtLeftCap", "ARTWORK")
		self.bar.leftCap:ClearAllPoints()
		self.bar.leftCap:SetHeight(128)
		self.bar.leftCap:SetWidth(128)
		self.bar.leftCap:SetPoint("BOTTOM", self.bar, "TOPLEFT", -32, -48)
		self.bar.rightCap = self.bar:CreateTexture("BlizzardArtRightCap", "ARTWORK")
		self.bar.rightCap:ClearAllPoints()
		self.bar.rightCap:SetHeight(128)
		self.bar.rightCap:SetWidth(128)
		self.bar.rightCap:SetTexCoord(1.0,0.0,0.0,1.0) -- Horizontal mirror
		self.bar.barTex0 = self.bar:CreateTexture("BlizzardArtTex0", "ARTWORK")
		self.bar.barTex0:ClearAllPoints()
		self.bar.barTex0:SetHeight(43)
		self.bar.barTex0:SetWidth(256)
		self.bar.barTex0:SetPoint("BOTTOMLEFT", self.bar, "TOPLEFT", 0, -48)
		self.bar.barTex0:SetTexCoord(0.0,1.0,0.83203125,1.0) -- Left quarter of the classic bar
		self.bar.barTex1 = self.bar:CreateTexture("BlizzardArtTex1", "ARTWORK")
		self.bar.barTex1:ClearAllPoints()
		self.bar.barTex1:SetHeight(43)
		self.bar.barTex1:SetPoint("BOTTOMLEFT", self.bar, "TOPLEFT", 256, -48)
		-- Tex1b complements Tex0 and Tex1 into a complete action bar, without the small buttons next to it
		-- It's actually a small repeat of the rightmost 9 pixels of the classic bar
		self.bar.barTex1b = self.bar:CreateTexture("BlizzardArtTex1b", "ARTWORK")
		self.bar.barTex1b:ClearAllPoints()
		self.bar.barTex1b:SetHeight(43)
		self.bar.barTex1b:SetWidth(9)
		self.bar.barTex1b:SetPoint("BOTTOMLEFT", self.bar, "TOPLEFT", 503, -48)
		self.bar.barTex1b:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf")
		self.bar.barTex1b:SetTexCoord(0.9609375,0.99609375,0.08203125,0.25) -- 9 pixels wide, pixels 246 to 254 of 256, inclusive, to be exact
		self.bar.barTex2 = self.bar:CreateTexture("BlizzardArtTex2", "ARTWORK")
		self.bar.barTex2:ClearAllPoints()
		self.bar.barTex2:SetHeight(43)
		self.bar.barTex2:SetWidth(256)
		self.bar.barTex2:SetPoint("BOTTOMLEFT", self.bar, "TOPLEFT", 512, -48)
		self.bar.barTex3 = self.bar:CreateTexture("BlizzardArtTex3", "ARTWORK")
		self.bar.barTex3:ClearAllPoints()
		self.bar.barTex3:SetHeight(43)
		self.bar.barTex3:SetPoint("BOTTOMLEFT", self.bar, "TOPLEFT", 768, -48)
		self.bar.barTex3b = self.bar:CreateTexture("BlizzardArtTex3b", "ARTWORK")
		-- Tex3b is like Tex1b, but together with Tex2 and Tex3, which would in this case (two action bars) be repeats of Tex0 and Tex1
		self.bar.barTex3b:ClearAllPoints()
		self.bar.barTex3b:SetHeight(43)
		self.bar.barTex3b:SetWidth(9)
		self.bar.barTex3b:SetPoint("BOTTOMLEFT", self.bar, "TOPLEFT", 1015, -48)
		self.bar.barTex3b:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf")
		self.bar.barTex3b:SetTexCoord(0.9609375,0.99609375,0.08203125,0.25) -- 9 pixels wide, pixels 246 to 254 of 256, inclusive, to be exact 
	end
	self.bar:Enable()
	self:ToggleOptions()
	self:ApplyConfig()
end

function BlizzardArtMod:ApplyConfig()
	self.bar:ApplyConfig()
end

function BlizzardArt:ApplyConfig()
	local config = BlizzardArtMod.db.profile
	Bar.ApplyConfig(self, config)

	if not config.position.x then
		self:ClearAllPoints()
		self:SetPoint("BOTTOM", UIParent, "BOTTOM", -512, 48)
	end

	if config.artSkin == "HUMAN" then -- Lions on the background of buttons
		self.barTex0:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Human")
		self.barTex1:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Human")
		if config.artLayout ~= "CLASSIC" then -- Human skin is actually outdated, for classic layout the second half is Dwarf anyway
			self.barTex2:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Human")
			self.barTex3:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Human")
		else
			self.barTex2:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf")
			self.barTex3:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf")
		end
		else -- Or griffins (default)
		self.barTex0:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf")
		self.barTex1:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf")
		self.barTex2:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf")
		self.barTex3:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf")
	end

	if config.leftCap == "NONE" then -- No left cap
		self.leftCap:Hide()
	elseif config.leftCap == "HUMAN" then -- Lion
		self.leftCap:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Human")
		self.leftCap:Show()
	else -- Griffin (default)
		self.leftCap:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Dwarf")
		self.leftCap:Show()
	end
	if config.rightCap == "NONE" then -- No right cap
		self.rightCap:Hide()
	elseif config.rightCap == "HUMAN" then -- Lion
		self.rightCap:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Human")
		self.rightCap:Show()
	else -- Griffin (default)
		self.rightCap:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Dwarf")
		self.rightCap:Show()
	end

	if config.artLayout == "CLASSIC" then -- Classical layout: one bar, micro menu and bags
		self:SetSize(1024,53)
		self.barTex1:SetWidth(256)
		self.barTex1:SetTexCoord(0.0,1.0,0.58203125,0.75) -- Second quarter of classic bar
		self.barTex1b:Hide()
		self.barTex2:Show()
		self.barTex2:SetTexCoord(0.0,1.0,0.33203125,0.5) -- Third quarter of classic bar
		self.barTex3:Show()
		self.barTex3:SetWidth(256)
		self.barTex3:SetTexCoord(0.0,1.0,0.08203125,0.25) -- Last quarter of classic bar
		self.barTex3b:Hide()
		self.rightCap:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 992, -48)
	elseif config.artLayout == "TWOBAR" then -- Two bars next to each other
		self:SetSize(1024,53)
		self.barTex1:SetWidth(247) -- Tex1b will complement the other 9 pixels
		self.barTex1:SetTexCoord(0.0,0.96484375,0.58203125,0.75) -- First 247 pixels of second quarter of classic bar
		self.barTex1b:Show() -- Tex1b is used here
		self.barTex2:Show()
		self.barTex2:SetTexCoord(0.0,1.0,0.83203125,1.0) -- First quarter of classic bar, or: repeat of Tex0
		self.barTex3:Show()
		self.barTex3:SetWidth(247) -- Tex3 will complement the other 9 pixels
		self.barTex3:SetTexCoord(0.0,0.96484375,0.58203125,0.75) -- First 247 pixels of second quarter of classic bar, or: repeat of Tex1
		self.barTex3b:Show() -- Tex3b is used here
		self.rightCap:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 992, -48)
	else -- Only one bar
		self:SetSize(512,53) -- Half size, since it's only one bar wide
		self.barTex1:SetWidth(247) -- Tex1b will complement the other 9 pixels
		self.barTex1:SetTexCoord(0.0,0.96484375,0.58203125,0.75) -- First 247 pixels of second quarter of classic bar
		self.barTex1b:Show() -- Tex1b is used here
		self.barTex2:Hide() -- Hide second half
		self.barTex3:Hide()
		self.barTex3b:Hide()
		self.rightCap:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 480, -48)
	end
end

BlizzardArt.ClickThroughSupport = false
function BlizzardArt:ControlClickThrough()
end
