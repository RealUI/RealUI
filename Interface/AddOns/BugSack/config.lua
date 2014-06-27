
local addonName, addon = ...
if not addon.healthCheck then return end
local L = addon.L

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = addonName
frame:Hide()

frame:SetScript("OnShow", function(frame)
	local function newCheckbox(label, description, onClick)
		local check = CreateFrame("CheckButton", "BugSackCheck" .. label, frame, "InterfaceOptionsCheckButtonTemplate")
		check:SetScript("OnClick", function(self)
			PlaySound(self:GetChecked() and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
			onClick(self, self:GetChecked() and true or false)
		end)
		check.label = _G[check:GetName() .. "Text"]
		check.label:SetText(label)
		check.tooltipText = label
		check.tooltipRequirement = description
		return check
	end

	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(addonName)

	local autoPopup = newCheckbox(
		L["Auto popup"],
		L.autoDesc,
		function(self, value) addon.db.auto = value end)
	autoPopup:SetChecked(addon.db.auto)
	autoPopup:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -2, -16)

	local chatFrame = newCheckbox(
		L["Chatframe output"],
		L.chatFrameDesc,
		function(self, value) addon.db.chatframe = value end)
	chatFrame:SetChecked(addon.db.chatframe)
	chatFrame:SetPoint("TOPLEFT", autoPopup, "BOTTOMLEFT", 0, -8)

	local icon = LibStub("LibDBIcon-1.0", true)
	local minimap
	if icon then
		minimap = newCheckbox(
			L["Minimap icon"],
			L.minimapDesc,
			function(self, value)
				BugSackLDBIconDB.hide = not value
				if BugSackLDBIconDB.hide then
					icon:Hide(addonName)
				else
					icon:Show(addonName)
				end
			end)
		minimap:SetPoint("TOPLEFT", chatFrame, "BOTTOMLEFT", 0, -8)
		minimap:SetChecked(not BugSackLDBIconDB.hide)
	end

	local mute = newCheckbox(
		L["Mute"],
		L.muteDesc,
		function(self, value) addon.db.mute = value end)
	mute:SetChecked(addon.db.mute)
	mute:SetPoint("TOPLEFT", minimap or chatFrame, "BOTTOMLEFT", 0, -8)

	local info = {}
	local fontSizeDropdown = CreateFrame("Frame", "BugSackFontSize", frame, "UIDropDownMenuTemplate")
	fontSizeDropdown:SetPoint("TOPLEFT", mute, "BOTTOMLEFT", -15, -10)
	fontSizeDropdown.initialize = function()
		wipe(info)
		local fonts = {"GameFontHighlightSmall", "GameFontHighlight", "GameFontHighlightMedium", "GameFontHighlightLarge"}
		local names = {L["Small"], L["Medium"], L["Large"], L["X-Large"]}
		for i, font in next, fonts do
			info.text = names[i]
			info.value = font
			info.func = function(self)
				addon.db.fontSize = self.value
				if _G.BugSackFrameScrollText then
					_G.BugSackFrameScrollText:SetFontObject(_G[self.value])
				end
				BugSackFontSizeText:SetText(self:GetText())
			end
			info.checked = font == addon.db.fontSize
			UIDropDownMenu_AddButton(info)
		end
	end
	BugSackFontSizeText:SetText(L["Font size"])

	local media = addon:EnsureLSM3()
	if media then
		local dropdown = CreateFrame("Frame", "BugSackSoundDropdown", frame, "UIDropDownMenuTemplate")
		dropdown:SetPoint("LEFT", fontSizeDropdown, "RIGHT", 150, 0)
		dropdown.initialize = function()
			wipe(info)
			for idx, sound in next, media:List("sound") do
				info.text = sound
				info.value = sound
				info.func = function(self)
					addon.db.soundMedia = self.value
					BugSackSoundDropdownText:SetText(self:GetText())
				end
				info.checked = sound == addon.db.soundMedia
				UIDropDownMenu_AddButton(info)
			end
		end
		BugSackSoundDropdownText:SetText(L["Sound"])
	end

	local clear = CreateFrame("Button", "BugSackSaveButton", frame, "UIPanelButtonTemplate")
	clear:SetText(L["Wipe saved bugs"])
	clear:SetWidth(177)
	clear:SetHeight(24)
	clear:SetPoint("TOPLEFT", fontSizeDropdown, "BOTTOMLEFT", 17, -25)
	clear:SetScript("OnClick", function()
		addon:Reset()
	end)
	clear.tooltipText = L["Wipe saved bugs"]
	clear.newbieText = L.wipeDesc

	frame:SetScript("OnShow", nil)
end)
InterfaceOptions_AddCategory(frame)

