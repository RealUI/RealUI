local _, private = ...

-- Lua Globals --
-- luacheck: globals next type _G

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("InstallUI") -- luacheck: ignore

-- Aurora --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Color = Aurora.Color

-- Installation UI
-- Provides visual interface for the installation wizard

local InstallUI = _G.CreateFrame("Frame", "RealUIInstallWizard", _G.UIParent)
RealUI.InstallUI = InstallUI

local function GetWizardDisplayScale()
    local uiParentScale = (_G.UIParent and _G.UIParent:GetScale()) or 1
    if uiParentScale <= 0 then
        return 1
    end

    local targetScale = 1 / uiParentScale
    local _, screenHeight = _G.GetPhysicalScreenSize()

    if screenHeight and screenHeight >= 2160 then
        targetScale = _G.max(targetScale, 1.15)
    end

    targetScale = _G.min(_G.max(targetScale, 1), 1.6)
    return RealUI.Scale.Round(targetScale, 2)
end

InstallUI:SetPoint("CENTER")
InstallUI:SetSize(550, 500)
InstallUI:SetFrameStrata("DIALOG")
InstallUI:Hide()

-- Add backdrop with texture
Base.SetBackdrop(InstallUI, Color.frame, 0.95)
InstallUI:SetBackdropBorderColor(1, 1, 1, 1)

-- Title
local title = InstallUI:CreateFontString(nil, "ARTWORK", "GameFont_Gigantic")
title:SetPoint("TOP", 0, -20)
title:SetText("RealUI Installation")
InstallUI.title = title

-- Logo
local logo = InstallUI:CreateTexture(nil, "ARTWORK")
logo:SetTexture([[Interface\AddOns\RealUI\Media\Logo]])
logo:SetSize(120, 120)
logo:SetPoint("TOP", 0, -55)
InstallUI.logo = logo

-- Version string
local versionText = InstallUI:CreateFontString(nil, "ARTWORK", "GameFontNormal")
versionText:SetPoint("TOP", logo, "BOTTOM", 0, -3)
versionText:SetText("Version " .. (RealUI.verinfo and RealUI.verinfo.string or ""))
InstallUI.versionText = versionText

-- Stage content frame
local content = _G.CreateFrame("Frame", nil, InstallUI)
content:SetPoint("TOPLEFT", 20, -200)
content:SetPoint("BOTTOMRIGHT", -20, 60)
InstallUI.content = content

-- Stage text
local stageText = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
stageText:SetPoint("TOP", 0, -10)
stageText:SetWidth(500)
stageText:SetJustifyH("LEFT")
InstallUI.stageText = stageText

-- Progress indicator
local progressText = InstallUI:CreateFontString(nil, "ARTWORK", "GameFontNormal")
progressText:SetPoint("BOTTOM", 0, 35)
InstallUI.progressText = progressText

-- Navigation buttons
local prevButton = _G.CreateFrame("Button", nil, InstallUI, "UIPanelButtonTemplate")
prevButton:SetSize(100, 25)
prevButton:SetPoint("BOTTOMLEFT", 20, 10)
prevButton:SetText("Previous")
prevButton:SetScript("OnClick", function()
    if RealUI.InstallWizard then
        RealUI.InstallWizard:PreviousStage()
    end
end)
InstallUI.prevButton = prevButton

local nextButton = _G.CreateFrame("Button", nil, InstallUI, "UIPanelButtonTemplate")
nextButton:SetSize(100, 25)
nextButton:SetPoint("BOTTOMRIGHT", -20, 10)
nextButton:SetText("Next")
nextButton:SetScript("OnClick", function()
    if RealUI.InstallWizard then
        RealUI.InstallWizard:NextStage()
    end
end)
InstallUI.nextButton = nextButton

local skipButton = _G.CreateFrame("Button", nil, InstallUI, "UIPanelButtonTemplate")
skipButton:SetSize(100, 25)
skipButton:SetPoint("BOTTOM", 0, 10)
skipButton:SetText("Skip")
skipButton:SetScript("OnClick", function()
    if RealUI.InstallWizard then
        RealUI.InstallWizard:Complete()
    end
end)
InstallUI.skipButton = skipButton

-- Close button
local closeButton = _G.CreateFrame("Button", nil, InstallUI, "UIPanelCloseButton")
closeButton:SetScript("OnClick", function()
    InstallUI:Hide()
end)
InstallUI.closeButton = closeButton

-- Stage content definitions
local stageContent = {
    [RealUI.InstallWizard and RealUI.InstallWizard.STAGE_WELCOME or 0] = {
        title = "Welcome to RealUI!",
        text = [[
Thank you for installing RealUI!

This wizard will guide you through the initial setup process.

RealUI is a comprehensive UI replacement that provides:
• Minimalistic and functional interface design
• Role-specific layouts (DPS/Tank and Healing)
• Modular components you can enable or disable
• Automatic specialization-based layout switching

Click "Next" to begin the setup process, or "Skip" to use default settings.
]],
        upgradeText = [[
Welcome to RealUI 3.0.0!

You're upgrading from a previous version. This wizard will help you configure the new version.

What's new in 3.0.0:
• Enhanced setup system with better upgrade detection
• Improved configuration migration
• New modular architecture
• Better performance and stability

Your previous settings have been migrated where possible. Click "Next" to review and complete the setup.
]],
        showPrev = false,
        showNext = true,
        showSkip = true
    },
    [RealUI.InstallWizard and RealUI.InstallWizard.STAGE_LAYOUT or 1] = {
        title = "Layout Configuration",
        text = [[
RealUI provides two different layouts optimized for different roles:

Layout 1 (DPS/Tank): Optimized for damage dealing and tanking
Layout 2 (Healing): Optimized for healing with better raid frame visibility

The system can automatically switch layouts based on your specialization.

Based on your current role, we recommend:
]],
        showPrev = true,
        showNext = true,
        showSkip = true,
        onShow = function(self)
            -- Add role-specific recommendation
            if RealUI.CharacterInit then
                local charInfo = RealUI.CharacterInit:GetCharacterInfo()
                local recommendedLayout = charInfo.role == "HEALER" and 2 or 1
                local layoutName = recommendedLayout == 2 and "Healing" or "DPS/Tank"

                local baseText = [[
RealUI provides two different layouts optimized for different roles:

Layout 1 (DPS/Tank): Optimized for damage dealing and tanking
Layout 2 (Healing): Optimized for healing with better raid frame visibility

The system can automatically switch layouts based on your specialization.
]]
                local extraText = ("\nYour role: %s\nRecommended layout: Layout %d (%s)"):format(
                    charInfo.role, recommendedLayout, layoutName)
                self.stageText:SetText(baseText .. extraText)
            end

            -- Show Naga checkbox
            if not self.nagaCheck then
                local nagaCheck = _G.CreateFrame("CheckButton", nil, self.content, "UICheckButtonTemplate")
                nagaCheck:SetSize(26, 26)
                nagaCheck:SetPoint("BOTTOMLEFT", self.content, "BOTTOMLEFT", 10, 10)
                nagaCheck:SetChecked(false)
                nagaCheck.text = nagaCheck:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                nagaCheck.text:SetPoint("LEFT", nagaCheck, "RIGHT", 4, 0)
                nagaCheck.text:SetText("Enable Razer Naga action bar (4x3 grid)")
                nagaCheck:SetScript("OnClick", function(btn)
                    if RealUI.InstallWizard then
                        local state = RealUI.InstallWizard:GetState()
                        state.stageData.enableNagaBar = btn:GetChecked()
                    end
                end)
                self.nagaCheck = nagaCheck
            end
            self.nagaCheck:Show()

            -- Restore previous state
            if RealUI.InstallWizard then
                local state = RealUI.InstallWizard:GetState()
                self.nagaCheck:SetChecked(state.stageData.enableNagaBar or false)
            end
        end,
        onHide = function(self)
            if self.nagaCheck then
                self.nagaCheck:Hide()
            end
        end
    },
    [RealUI.InstallWizard and RealUI.InstallWizard.STAGE_CHAT or 2] = {
        title = "Chat Configuration",
        text = [[
RealUI includes enhanced chat features:

• Improved chat frame positioning and styling
• Chat copying and text manipulation
• Enhanced chat bubble display

The chat frames will be positioned automatically based on your chosen layout.

You can customize chat settings later through the RealUI configuration.
]],
        showPrev = true,
        showNext = true,
        showSkip = true
    },
    [RealUI.InstallWizard and RealUI.InstallWizard.STAGE_QOL or 3] = {
        title = "Quality of Life",
        text = [[
Configure optional quality of life features:
]],
        showPrev = true,
        showNext = true,
        showSkip = true,
        onShow = function(self)
            -- Build repair mount dropdown
            if not self.repairMountLabel then
                local label = self.content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                label:SetPoint("TOPLEFT", self.content, "TOPLEFT", 10, -50)
                label:SetText("Default repair mount (if owned):")
                self.repairMountLabel = label
            end
            self.repairMountLabel:Show()

            if not self.repairMountDropdown then
                -- Known repair mounts: mountID, name
                local repairMounts = {
                    {id = 280, name = "Traveler's Tundra Mammoth"},
                    {id = 460, name = "Grand Expedition Yak"},
                    {id = 1039, name = "Mighty Caravan Brutosaur"},
                }

                local dropdown = _G.CreateFrame("Frame", "RealUIWizardRepairMount", self.content, "UIDropDownMenuTemplate")
                dropdown:SetPoint("TOPLEFT", self.repairMountLabel, "BOTTOMLEFT", -16, -4)

                local selectedMount = 0
                local ownedMounts = {}

                -- Check which repair mounts the player owns
                for _, mount in _G.ipairs(repairMounts) do
                    local name, _, _, _, isUsable, _, _, _, _, _, isCollected = _G.C_MountJournal.GetMountInfoByID(mount.id)
                    if isCollected then
                        ownedMounts[#ownedMounts + 1] = {id = mount.id, name = name or mount.name, isUsable = isUsable}
                    end
                end

                -- Restore previous selection
                if RealUI.InstallWizard then
                    local state = RealUI.InstallWizard:GetState()
                    if state.stageData.repairMountID then
                        selectedMount = state.stageData.repairMountID
                    end
                end

                local function GetSelectedName()
                    for _, m in _G.ipairs(ownedMounts) do
                        if m.id == selectedMount then return m.name end
                    end
                    return "None"
                end

                _G.UIDropDownMenu_SetWidth(dropdown, 220)
                _G.UIDropDownMenu_SetText(dropdown, GetSelectedName())

                _G.UIDropDownMenu_Initialize(dropdown, function(frame, level)
                    local info = _G.UIDropDownMenu_CreateInfo()

                    -- None option
                    info.text = "None"
                    info.value = 0
                    info.checked = (selectedMount == 0)
                    info.func = function()
                        selectedMount = 0
                        _G.UIDropDownMenu_SetText(dropdown, "None")
                        if RealUI.InstallWizard then
                            local state = RealUI.InstallWizard:GetState()
                            state.stageData.repairMountID = 0
                        end
                        _G.CloseDropDownMenus()
                    end
                    _G.UIDropDownMenu_AddButton(info, level)

                    for _, mount in _G.ipairs(ownedMounts) do
                        info = _G.UIDropDownMenu_CreateInfo()
                        info.text = mount.name
                        info.value = mount.id
                        info.checked = (selectedMount == mount.id)
                        info.func = function()
                            selectedMount = mount.id
                            _G.UIDropDownMenu_SetText(dropdown, mount.name)
                            if RealUI.InstallWizard then
                                local state = RealUI.InstallWizard:GetState()
                                state.stageData.repairMountID = mount.id
                            end
                            _G.CloseDropDownMenus()
                        end
                        _G.UIDropDownMenu_AddButton(info, level)
                    end
                end)

                self.repairMountDropdown = dropdown

                -- Show a note if no repair mounts are owned
                if #ownedMounts == 0 then
                    if not self.noMountText then
                        local noMount = self.content:CreateFontString(nil, "ARTWORK", "GameFontDisable")
                        noMount:SetPoint("TOPLEFT", self.repairMountLabel, "BOTTOMLEFT", 0, -8)
                        noMount:SetText("No repair mounts found in your collection.")
                        self.noMountText = noMount
                    end
                    self.noMountText:Show()
                    dropdown:Hide()
                end
            else
                self.repairMountDropdown:Show()
                if self.noMountText then
                    -- Re-evaluate visibility based on whether dropdown is useful
                    -- (noMountText was only created if no mounts were found)
                    self.noMountText:Show()
                end
            end
        end,
        onHide = function(self)
            if self.repairMountLabel then self.repairMountLabel:Hide() end
            if self.repairMountDropdown then self.repairMountDropdown:Hide() end
            if self.noMountText then self.noMountText:Hide() end
        end
    },
    [RealUI.InstallWizard and RealUI.InstallWizard.STAGE_FINISH or 4] = {
        title = "Installation Complete!",
        text = [[
RealUI has been successfully configured!

You can access RealUI settings at any time by typing:
• /realui - Main configuration
• /real - Quick access
• /realadv - Advanced options

To reposition UI elements, use Config Mode from the settings menu.

Enjoy your new interface!
]],
        showPrev = true,
        showNext = false,
        showSkip = false
    }
}

-- Update stage display
function InstallUI:UpdateStage(stage)
    local stageInfo = stageContent[stage]

    if not stageInfo then
        return
    end

    -- Hide elements from previous stage
    for stageKey, info in next, stageContent do
        if stageKey ~= stage and info.onHide then
            info.onHide(self)
        end
    end

    -- Check if this is an upgrade
    local isUpgrade = false
    local oldVersion = nil
    if RealUI.InstallWizard then
        local state = RealUI.InstallWizard:GetState()
        isUpgrade = state.isUpgrade
        oldVersion = state.oldVersion
    end

    -- Update title
    local stageTitle = stageInfo.title
    if isUpgrade and stage == 0 then
        stageTitle = "Welcome to RealUI 3.0.0!"
    end
    self.title:SetText(stageTitle)

    -- Update text based on upgrade status
    local text = stageInfo.text
    if isUpgrade and stageInfo.upgradeText then
        text = stageInfo.upgradeText
        if oldVersion then
            text = text:gsub("previous version", oldVersion)
        end
    end
    self.stageText:SetText(text)

    -- Call onShow handler if available
    if stageInfo.onShow then
        stageInfo.onShow(self)
    end

    -- Update progress
    local totalStages = RealUI.InstallWizard and RealUI.InstallWizard.STAGE_FINISH or 3
    self.progressText:SetFormattedText("Step %d of %d", stage + 1, totalStages + 1)

    -- Update button visibility
    self.prevButton:SetShown(stageInfo.showPrev)
    self.nextButton:SetShown(stageInfo.showNext)
    self.skipButton:SetShown(stageInfo.showSkip)

    -- Update next button text for final stage
    local finishStage = RealUI.InstallWizard and RealUI.InstallWizard.STAGE_FINISH or 3
    if stage == finishStage then
        self.nextButton:SetText("Finish")
        self.nextButton:SetShown(true)
        self.nextButton:SetScript("OnClick", function()
            if RealUI.InstallWizard then
                RealUI.InstallWizard:Complete()
            end
        end)
    else
        self.nextButton:SetText("Next")
        self.nextButton:SetScript("OnClick", function()
            if RealUI.InstallWizard then
                RealUI.InstallWizard:NextStage()
            end
        end)
    end
end

-- Show installation UI
function InstallUI:Show()
    _G.FrameUtil.RegisterFrameForEvents(self, {
        "PLAYER_REGEN_DISABLED",
        "UI_SCALE_CHANGED",
        "DISPLAY_SIZE_CHANGED",
    })

    self:SetScale(GetWizardDisplayScale())

    local stage = RealUI.InstallWizard and RealUI.InstallWizard:GetCurrentStage() or 0
    self:UpdateStage(stage)

    _G.getmetatable(self).__index.Show(self)
end

-- Hide installation UI
function InstallUI:Hide()
    _G.FrameUtil.UnregisterFrameForEvents(self, {
        "PLAYER_REGEN_DISABLED",
        "UI_SCALE_CHANGED",
        "DISPLAY_SIZE_CHANGED",
    })
    _G.getmetatable(self).__index.Hide(self)
end

-- Event handler
InstallUI:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        -- Hide during combat
        self:Hide()
    elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
        self:SetScale(GetWizardDisplayScale())
    end
end)

-- Initialize UI styling
function InstallUI:InitializeStyle()
    -- Apply RealUI styling if available
    if RealUI.Skins then
        RealUI.Skins:Reskin(self)
        RealUI.Skins:Reskin(self.prevButton)
        RealUI.Skins:Reskin(self.nextButton)
        RealUI.Skins:Reskin(self.skipButton)
        RealUI.Skins:Reskin(self.closeButton)
    end
end
