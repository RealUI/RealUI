-- Fix incorrect translations in the German localization
if GetLocale() == "deDE" then
	-- Day one-letter abbreviation is using a whole word instead of one letter.
	DAY_ONELETTER_ABBR = "%d d"
end

-- Fix an issue where the PetJournal drag buttons (the pet icons in the ACTIVE team on the right
-- pane of the PetJournal) cannot be clicked to link a pet into chat.
-- The necessary code is already present, but the buttons are only registered for RightButtonUp.
do
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", function(self, event, name)
		if name == "Blizzard_Collections" then
			for i = 1, 3 do
				local button = _G["PetJournalLoadoutPet"..i]
				if button and button.dragButton then
					button.dragButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
				end
			end
			self:UnregisterAllEvents()
		end
	end)
end

