local _, private = ...

-- Lua Globals --
-- luacheck: globals next type _G

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("InstallUI")

-- Aurora --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Color = Aurora.Color

-- Installation UI
-- Provides visual interface for the installation wizard

local InstallUI = _G.CreateFrame("Frame", "RealUIInstallWizard", _G.UIParent)
RealUI.InstallUI = InstallUI

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

Based on your current role, we recommend:
]]
                local extraText = ("\n\nYour role: %s\nRecommended layout: Layout %d (%s)"):format(
                    charInfo.role, recommendedLayout, layoutName)
                self.stageText:SetText(baseText .. extraText)
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
    [RealUI.InstallWizard and RealUI.InstallWizard.STAGE_FINISH or 3] = {
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

    -- Check if this is an upgrade
    local isUpgrade = false
    local oldVersion = nil
    if RealUI.InstallWizard then
        local state = RealUI.InstallWizard:GetState()
        isUpgrade = state.isUpgrade
        oldVersion = state.oldVersion
    end

    -- Update title
    local title = stageInfo.title
    if isUpgrade and stage == 0 then
        title = "Welcome to RealUI 3.0.0!"
    end
    self.title:SetText(title)

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
    _G.FrameUtil.RegisterFrameForEvents(self, {"PLAYER_REGEN_DISABLED"})

    local stage = RealUI.InstallWizard and RealUI.InstallWizard:GetCurrentStage() or 0
    self:UpdateStage(stage)

    _G.getmetatable(self).__index.Show(self)
end

-- Hide installation UI
function InstallUI:Hide()
    _G.FrameUtil.UnregisterFrameForEvents(self, {"PLAYER_REGEN_DISABLED"})
    _G.getmetatable(self).__index.Hide(self)
end

-- Event handler
InstallUI:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        -- Hide during combat
        self:Hide()
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
