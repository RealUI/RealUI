--[[--------------------------------------------------------------------
	PhanxConfig-Header
	Simple options panel header generator. Requires LibStub.
	https://github.com/Phanx/PhanxConfig-Header
	Copyright (c) 2009-2015 Phanx <addons@phanx.net>. All rights reserved.
	Feel free to include copies of this file WITHOUT CHANGES inside World of
	Warcraft addons that make use of it as a library, and feel free to use code
	from this file in other projects as long as you DO NOT use my name or the
	original name of this file anywhere in your project outside of an optional
	credits line -- any modified versions must be renamed to avoid conflicts.
----------------------------------------------------------------------]]

local MINOR_VERSION = 20150112

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-Header", MINOR_VERSION)
if not lib then return end

function lib:New(parent, titleText, notesText, versionText, noPrefix)
	assert(type(parent) == "table" and type(rawget(parent, 0)) == "userdata", "PhanxConfig-Header: parent must be a frame")
	if type(titleText) ~= "string" then titleText = nil end
	if versionText == true then
		-- backwards compatibility
		versionText, noPrefix = nil, versionText
	end

	if notesText == true then
		local addon = titleText
		titleText   = GetAddOnMetadata(addon, "Title")
		notesText   = GetAddOnMetadata(addon, "Notes")
		versionText = GetAddOnMetadata(addon, "Version")
	else
		if notesText ~= false and type(notesText) ~= "string" then notesText = nil end
		if type(versionText) ~= "string" then versionText = nil end
	end

	if not titleText then
		titleText = parent.name
	end
	if titleText and not noPrefix and parent.parent then
		titleText = format("%s - %s", parent.parent, titleText)
	end

	local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetPoint("TOPRIGHT", -16, -16)
	title:SetJustifyH("LEFT")
	title:SetText(titleText)

	local version
	if versionText then
		version = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
		version:SetPoint("TOPRIGHT", -16, -16)
		version:SetHeight(title:GetHeight())
		version:SetJustifyH("RIGHT")
		version:SetJustifyV("BOTTOM")
		version:SetFormattedText("%s: %s%s|r", GAME_VERSION_LABEL, HIGHLIGHT_FONT_COLOR_CODE, versionText)
		title:SetPoint("RIGHT", version, "LEFT", -8, 0)
	end

	local notes
	if notesText ~= false then
		notes = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		notes:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
		notes:SetPoint("RIGHT", -16, 0)
		notes:SetHeight(32)
		notes:SetJustifyH("LEFT")
		notes:SetJustifyV("TOP")
		notes:SetNonSpaceWrap(true)
		notes:SetText(notesText)
	end

	return title, notes, version
end

function lib.CreateHeader(...) return lib:New(...) end
