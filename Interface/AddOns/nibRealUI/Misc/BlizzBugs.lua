-- Code from BlizzBugsSuck (http://www.wowace.com/addons/blizzbugssuck/)

local wow_version, wow_build, wow_data, tocversion = GetBuildInfo()
wow_build = tonumber(wow_build)

-- Fix incorrect translations in the German localization
if GetLocale() == "deDE" then
	-- Day one-letter abbreviation is using a whole word instead of one letter.
	-- Confirmed still bugged in 6.0.3.19243
	DAY_ONELETTER_ABBR = "%d d"

	-- Quality 2 (Uncommon) is incorrectly using the same translation as Quality 3 (Rare).
	-- Previously 2/3 were Selten/Rar; it looks like they meant to update these to match the
	-- equivalent battle pet quality strings (Ungewöhnlich/Selten) but forgot to finish the job.
	-- Confirmed still bugged in 6.0.3.19243
	-- A simple global override breaks unit frame dropdowns -_-
	-- ITEM_QUALITY2_DESC = BATTLE_PET_BREED_QUALITY3
	-- ...so we have to do all this nonsense instead:
	-- Fix it in the sub-menu
	UnitPopupButtons["ITEM_QUALITY2_DESC"].text = BATTLE_PET_BREED_QUALITY3
	-- Fix it in the top-level menu
	hooksecurefunc("UnitPopup_ShowMenu", function(menu, which, unit)
		local lootThreshold = GetLootThreshold()
		if UIDROPDOWNMENU_MENU_VALUE == "LOOT_THRESHOLD" then
			for index = 1, 2 do
				local match = (index + 1) == lootThreshold
				local buttonName = "DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..index
				_G[buttonName.."Check"]:SetShown(match)
				_G[buttonName.."UnCheck"]:SetShown(not match)
			end
		elseif lootThreshold == 2 and which == "SELF" and UIDROPDOWNMENU_MENU_VALUE == nil then
			for index = 1, 20 do -- arbitrary upper bound
				local button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..index]
				if button and button.value == "LOOT_THRESHOLD" then
					return button:SetText(ITEM_QUALITY_COLORS[2].hex .. BATTLE_PET_BREED_QUALITY3)
				end
			end
		end
	end)
	-- Fix it in chat frame system messages
	local pattern = gsub(ERR_SET_LOOT_THRESHOLD_S, "%%s", ".+")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message, ...)
		if GetLootThreshold() == 2 and strmatch(message, pattern) then
			return false, format(ERR_SET_LOOT_THRESHOLD_S, BATTLE_PET_BREED_QUALITY3), ...
		end
	end)
end

-- Fix an error in the Traditional Chinese client when the Blizzard_GuildUI loads
-- Blizzard_GuildUI\Localization.lua:30: attempt to index global 'GuildMainFrameMembersCountLabel' (a nil value)
-- The error is caused by Blizzard using the wrong global object name.
-- New bug in 6.0, reported by EKE on WoWInterface.
if GetLocale() == "zhTW" then
	-- Create a dummy object to prevent the error:
	GuildMainFrameMembersCountLabel = { SetPoint = function() end }
	-- Wait for the Guild UI to load:
	hooksecurefunc("LoadAddOn", function(name)
		if name == "Blizzard_GuildUI" then
			-- Make the intended change using the correct object name:
			GuildFrameMembersCountLabel:SetPoint("BOTTOMRIGHT", GuildFrameMembersCount, "TOPRIGHT")
			-- Delete the dummy object:
			GuildMainFrameMembersCountLabel = nil
		end
	end)
end

-- Fix InterfaceOptionsFrame_OpenToCategory not actually opening the category (and not even scrolling to it)
-- Confirmed still broken in 6.0.3.19243
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
		if shownpanels > 15 and Smin < Smax then
			local val = (Smax/(shownpanels-15))*(mypanel-2)
			InterfaceOptionsFrameAddOnsListScrollBar:SetValue(val)
		end
		doNotRun = true
		InterfaceOptionsFrame_OpenToCategory(panel)
		doNotRun = false
	end

	hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", InterfaceOptionsFrame_OpenToCategory_Fix)
end

-- Avoid taint from the UIFrameFlash usage of the chat frames.  More info here:
-- http://forums.wowace.com/showthread.php?p=324936
-- Fixed by embedding LibChatAnims

-- Fix an issue where the PetJournal drag buttons cannot be clicked to link a pet into chat
-- The necessary code is already present, but the buttons are not registered for the correct click
-- Confirmed still bugged in 6.0.3.19243
do
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", function(self, event, name)
		if name == "Blizzard_PetJournal" then
			for i = 1, 3 do
				local button = _G["PetJournalLoadoutPet"..i]
				if button and button.dragButton then
					button.dragButton:RegisterForClicks("LeftButtonUp")
				end
			end
			self:UnregisterAllEvents()
		end
	end)
end
