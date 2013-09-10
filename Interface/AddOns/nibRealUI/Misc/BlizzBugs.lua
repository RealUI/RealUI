-- Code from BlizzBugsSuck (http://www.wowace.com/addons/blizzbugssuck/)

local wow_version, wow_build, wow_data, tocversion = GetBuildInfo()
wow_build = tonumber(wow_build)

-- Fix incorrect translations in the German Locale.  For whatever reason
-- Blizzard changed the oneletter time abbreviations to be 3 letter in
-- the German Locale.
if GetLocale() == "deDE" then
	-- This one confirmed still bugged as of Mists of Pandaria build 16030
	DAY_ONELETTER_ABBR = "%d d"
end

-- fixes the issue with InterfaceOptionsFrame_OpenToCategory not actually opening the Category (and not even scrolling to it)
-- Confirmed still broken in Mists of Pandaria as of build 16016 (5.0.4)
do
	local function get_panel_name(panel)
		local tp = type(panel)
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		if tp == "string" then
			for i = 1, #cat do
				local p = cat[i]
				if p.name == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel
					end
				end
			end
		elseif tp == "table" then
			for i = 1, #cat do
				local p = cat[i]
				if p == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel.name
					end
				end
			end
		end
	end

	local function InterfaceOptionsFrame_OpenToCategory_Fix(panel)
		if doNotRun or InCombatLockdown() then return end
		local panelName = get_panel_name(panel)
		if not panelName then return end -- if its not part of our list return early
		local noncollapsedHeaders = {}
		local shownpanels = 0
		local mypanel
		local t = {}
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		for i = 1, #cat do
			local panel = cat[i]
			if not panel.parent or noncollapsedHeaders[panel.parent] then
				if panel.name == panelName then
					panel.collapsed = true
					t.element = panel
					InterfaceOptionsListButton_ToggleSubCategories(t)
					noncollapsedHeaders[panel.name] = true
					mypanel = shownpanels + 1
				end
				if not panel.collapsed then
					noncollapsedHeaders[panel.name] = true
				end
				shownpanels = shownpanels + 1
			end
		end
		local Smin, Smax = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
		if shownpanels > 15 then
			InterfaceOptionsFrameAddOnsListScrollBar:SetValue((Smax/(shownpanels-15))*(mypanel-2))
			doNotRun = true
			InterfaceOptionsFrame_OpenToCategory(panel)
			doNotRun = false
		end
	end

	hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", InterfaceOptionsFrame_OpenToCategory_Fix)
end

-- Fix an issue where the GlyphUI depends on the TalentUI but doesn't
-- always load it.  This issue will manafest with an error like this:
-- attempt to index global "PlayerTalentFrame" (a nil value)
-- More details and the report to Blizzard here:
-- http://us.battle.net/wow/en/forum/topic/6470967787
if wow_build >= 16016 then
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", function(self, event, name)
		if event == "ADDON_LOADED" and name == "Blizzard_GlyphUI" then
			TalentFrame_LoadUI()
		end
	end)
end

-- Fix an issue where the "DEATH" StaticPopup is wrongly shown when reloading the
-- UI.  The cause of the problem is in UIParent.lua around line 889 it seems
-- GetReleaseTimeRemaining is wrongly returning a non-zero value on the first
-- PLAYER_ENTERING_WORLD event.
hooksecurefunc("StaticPopup_Show", function(which)
	if which == "DEATH" and not UnitIsDead("player") then
		StaticPopup_Hide("DEATH")
	end
end)


-- Fix an issue where Blizzard's use of UIFrameFlash will prevent
-- the ability to change talents if a user has a separate chat tab
-- for e.g. whispers and also has a chat mod installed or a mod that
-- filters whispers. More info here:
-- http://forums.wowace.com/showthread.php?p=324936

-- Fixed by embedding LibChatAnims


-- Fix an issue where the PetJournal drag buttons cannot be clicked to link a pet into chat
-- The necessary code is already present, but the buttons are not registered for the correct click
if true then
		local frame = CreateFrame("Frame")
		frame:RegisterEvent("ADDON_LOADED")
		frame:SetScript("OnEvent", function(self, event, name)
			if event == "ADDON_LOADED" and name == "Blizzard_PetJournal" then
				for i=1,3 do
					local d = _G["PetJournalLoadoutPet"..i]
					d = d and d.dragButton
					if d then d:RegisterForClicks("LeftButtonUp") end
				end
			end
		end)
end