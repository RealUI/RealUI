local _, private = ...

-- Lua Globals --
-- luacheck: globals next ipairs type _G

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("DisplayStage") -- luacheck: ignore

-- Aurora --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Color = Aurora.Color

-- DisplayStage module
-- Renders preset cards for the STAGE_DISPLAY wizard step and standalone access.

local DisplayStage = {}
RealUI.DisplayStage = DisplayStage

---------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------
DisplayStage.selectedPresetId = nil   -- currently selected preset id (nil = none)
DisplayStage.suggestedPresetId = nil  -- auto-suggested preset id (set on Show)
DisplayStage.hdrEnabled = false       -- independent HDR toggle (any preset + HDR on/off)

---------------------------------------------------------------------------
-- Internal references (created lazily)
---------------------------------------------------------------------------
local cardContainer       -- the inner frame that holds all cards
local scrollFrame         -- the ScrollFrame wrapping cardContainer
local cards = {}          -- ordered list of card frames, keyed by index
local cardById = {}       -- card frame lookup by preset id
local hdrCheckbox         -- "Enable HDR Colors" checkbox below the card grid

local standaloneFrame     -- standalone window for Open()
local isWizardMode = false

-- Preview frame references (Task 8)
local previewFrame        -- the 320×180 preview container
local chatStrings = {}    -- two FontString lines for chat strip

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------
local CARD_WIDTH  = 480
local CARD_HEIGHT = 80
local CARD_GAP    = 6
local SELECTED_COLOR = {r = 0.3, g = 0.6, b = 1.0}
local NORMAL_BG = {r = 0.15, g = 0.15, b = 0.15, a = 0.8}
local HOVER_BG  = {r = 0.2, g = 0.2, b = 0.2, a = 0.9}

-- Preview frame constants
local PREVIEW_WIDTH  = 320
local PREVIEW_HEIGHT = 180
local BASE_PREVIEW_SCALE = PREVIEW_HEIGHT / 768  -- normalize to preview height

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

--- Build a one-line summary of key settings for a preset.
local function BuildSettingsSummary(preset)
    local parts = {}

    -- Show effective scale: for pixel-perfect presets, compute from screen;
    -- for manual scale, show the stored value. Include HiDPI multiplier.
    local effectiveScale
    if preset.isPixelScale then
        local _, screenH = _G.GetPhysicalScreenSize()
        effectiveScale = 768 / screenH
    else
        effectiveScale = preset.customScale or 1
    end
    if preset.isHighRes then
        parts[#parts + 1] = ("Scale: %.2f (HiDPI)"):format(effectiveScale)
    else
        parts[#parts + 1] = ("Scale: %.2f"):format(effectiveScale)
    end

    if preset.fontScale and preset.fontScale ~= 1.0 then
        parts[#parts + 1] = ("Font: %.2g"):format(preset.fontScale)
    end
    if preset.chatFontSize then
        parts[#parts + 1] = ("Chat: %dpt"):format(preset.chatFontSize)
    end
    return _G.table.concat(parts, "  |  ")
end

--- Unhighlight all cards, then highlight the selected one.
local function RefreshCardHighlights()
    for _, card in ipairs(cards) do
        if card.presetId == DisplayStage.selectedPresetId then
            card.bg:SetColorTexture(SELECTED_COLOR.r, SELECTED_COLOR.g, SELECTED_COLOR.b, 0.35)
            card.border:SetColorTexture(SELECTED_COLOR.r, SELECTED_COLOR.g, SELECTED_COLOR.b, 1)
        else
            card.bg:SetColorTexture(NORMAL_BG.r, NORMAL_BG.g, NORMAL_BG.b, NORMAL_BG.a)
            card.border:SetColorTexture(0.3, 0.3, 0.3, 1)
        end
    end
end

--- Update the "Recommended" badge visibility on all cards.
local function RefreshRecommendedBadge()
    for _, card in ipairs(cards) do
        if card.presetId == DisplayStage.suggestedPresetId then
            card.badge:Show()
        else
            card.badge:Hide()
        end
    end
end

--- Scroll the suggested card into view.
local function ScrollToCard(card)
    if not scrollFrame or not card then return end
    local cardTop = -card:GetTop() + cardContainer:GetTop()
    local scrollMax = scrollFrame:GetVerticalScrollRange()
    local offset = _G.max(0, _G.min(cardTop - 10, scrollMax))
    scrollFrame:SetVerticalScroll(offset)
end

--- Notify the wizard that canAdvance state may have changed.
local function NotifyWizardStateChanged()
    if isWizardMode and RealUI.InstallUI then
        local IW = RealUI.InstallWizard
        if IW then
            RealUI.InstallUI:UpdateStage(IW:GetCurrentStage())
        end
    end
end

---------------------------------------------------------------------------
-- Card creation
---------------------------------------------------------------------------

local function CreateCard(parent, preset)
    local card = _G.CreateFrame("Button", nil, parent)
    card:SetHeight(CARD_HEIGHT)
    card.presetId = preset.id

    -- Background
    local bg = card:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(NORMAL_BG.r, NORMAL_BG.g, NORMAL_BG.b, NORMAL_BG.a)
    card.bg = bg

    -- Left-side border accent (2px)
    local border = card:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT")
    border:SetPoint("BOTTOMLEFT")
    border:SetWidth(3)
    border:SetColorTexture(0.3, 0.3, 0.3, 1)
    card.border = border

    -- Preset name (bold / larger)
    local nameText = card:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    nameText:SetPoint("TOPLEFT", 12, -10)
    nameText:SetPoint("TOPRIGHT", -12, -10)
    nameText:SetJustifyH("LEFT")
    nameText:SetText(preset.name)
    card.nameText = nameText

    -- Description
    local descText = card:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    descText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -3)
    descText:SetPoint("TOPRIGHT", nameText, "BOTTOMRIGHT", 0, -3)
    descText:SetJustifyH("LEFT")
    descText:SetText(preset.description)
    card.descText = descText

    -- Key-settings summary line
    local summaryText = card:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    summaryText:SetPoint("BOTTOMLEFT", 12, 8)
    summaryText:SetPoint("BOTTOMRIGHT", -12, 8)
    summaryText:SetJustifyH("LEFT")
    summaryText:SetText(BuildSettingsSummary(preset))
    card.summaryText = summaryText

    -- "Recommended" badge (top-right corner, hidden by default)
    local badge = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    badge:SetPoint("TOPRIGHT", -8, -6)
    badge:SetText("|cff33cc33Recommended|r")
    badge:Hide()
    card.badge = badge

    -- Hover highlight
    card:SetScript("OnEnter", function(self)
        if self.presetId ~= DisplayStage.selectedPresetId then
            self.bg:SetColorTexture(HOVER_BG.r, HOVER_BG.g, HOVER_BG.b, HOVER_BG.a)
        end
    end)
    card:SetScript("OnLeave", function(self)
        if self.presetId ~= DisplayStage.selectedPresetId then
            self.bg:SetColorTexture(NORMAL_BG.r, NORMAL_BG.g, NORMAL_BG.b, NORMAL_BG.a)
        end
    end)

    -- Click handler
    card:SetScript("OnClick", function(self)
        DisplayStage.selectedPresetId = self.presetId
        RefreshCardHighlights()

        -- Trigger preview update (Task 8 — guarded)
        if DisplayStage.PreviewPreset then
            DisplayStage.PreviewPreset(self.presetId)
        end

        -- Notify wizard that canAdvance changed
        NotifyWizardStateChanged()
    end)

    return card
end

---------------------------------------------------------------------------
-- Build the card grid UI (called once, lazily)
---------------------------------------------------------------------------

local function BuildCardGrid(parent)
    -- ScrollFrame — leave room on the right for the preview frame, and
    -- 30px at the bottom for the HDR checkbox
    scrollFrame = _G.CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", -(PREVIEW_WIDTH + 30), 30)

    -- Inner container — width set after layout via OnSizeChanged
    cardContainer = _G.CreateFrame("Frame", nil, scrollFrame)
    cardContainer:SetWidth(CARD_WIDTH) -- initial; updated by scroll frame
    scrollFrame:SetScrollChild(cardContainer)

    -- Keep card container width in sync with scroll frame
    scrollFrame:SetScript("OnSizeChanged", function(self, w)
        if w and w > 0 then
            cardContainer:SetWidth(w)
        end
    end)

    -- Build one card per preset
    local presets = RealUI.DisplayPresets.GetAll()
    local totalHeight = 0

    for i, preset in ipairs(presets) do
        local card = CreateCard(cardContainer, preset)
        card:SetPoint("TOPLEFT", 0, -(i - 1) * (CARD_HEIGHT + CARD_GAP))
        card:SetPoint("RIGHT", cardContainer, "RIGHT", 0, 0)
        cards[i] = card
        cardById[preset.id] = card
        totalHeight = totalHeight + CARD_HEIGHT + (i < #presets and CARD_GAP or 0)
    end

    cardContainer:SetHeight(totalHeight)

    -- HDR checkbox below the card scroll area
    hdrCheckbox = _G.CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    hdrCheckbox:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 0, -8)
    hdrCheckbox.Text:SetText("Enable HDR Colors")
    hdrCheckbox:SetChecked(DisplayStage.hdrEnabled)
    hdrCheckbox:SetScript("OnClick", function(self)
        DisplayStage.hdrEnabled = self:GetChecked() and true or false
        if DisplayStage.selectedPresetId and DisplayStage.PreviewPreset then
            DisplayStage.PreviewPreset(DisplayStage.selectedPresetId)
        end
    end)
end

---------------------------------------------------------------------------
-- Preview frame (Task 8)
---------------------------------------------------------------------------

--- Build the live preview frame with mock UI elements.
-- Called lazily alongside the card grid. Parented to the same parent.
-- @param parent Frame  The content frame (same parent as the card grid)
local function BuildPreviewFrame(parent)
    -- 8.1: Create the preview container — fixed 320×180, top-right, mouse-passthrough
    previewFrame = _G.CreateFrame("Frame", nil, parent)
    previewFrame:SetSize(PREVIEW_WIDTH, PREVIEW_HEIGHT)
    previewFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    previewFrame:EnableMouse(false)

    -- Dark background for the preview area
    local previewBg = previewFrame:CreateTexture(nil, "BACKGROUND")
    previewBg:SetAllPoints()
    previewBg:SetColorTexture(0.08, 0.08, 0.08, 0.9)

    -- Border around the preview
    local previewBorder = _G.CreateFrame("Frame", nil, previewFrame, "BackdropTemplate")
    previewBorder:SetAllPoints()
    previewBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    })
    previewBorder:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    previewBorder:EnableMouse(false)

    -- "Preview" label at the top
    local previewLabel = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    previewLabel:SetPoint("TOP", 0, -4)
    previewLabel:SetText("|cffaaaaaaPreview|r")

    -- 8.2: Create mock UI contents inside the preview frame

    -- Mock unit frame pair: two StatusBar frames (health + power each)
    local unitStartY = -20
    for i = 1, 2 do
        local unitFrame = _G.CreateFrame("Frame", nil, previewFrame)
        unitFrame:SetSize(120, 24)
        unitFrame:SetPoint("TOPLEFT", 16, unitStartY - (i - 1) * 30)
        unitFrame:EnableMouse(false)

        -- Unit frame background
        local unitBg = unitFrame:CreateTexture(nil, "BACKGROUND")
        unitBg:SetAllPoints()
        unitBg:SetColorTexture(0.12, 0.12, 0.12, 1)

        -- Health bar (StatusBar)
        local healthBar = _G.CreateFrame("StatusBar", nil, unitFrame)
        healthBar:SetPoint("TOPLEFT", 1, -1)
        healthBar:SetPoint("TOPRIGHT", -1, -1)
        healthBar:SetHeight(14)
        healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        healthBar:SetStatusBarColor(0.2, 0.8, 0.2)
        healthBar:SetMinMaxValues(0, 1)
        healthBar:SetValue(i == 1 and 0.85 or 0.6)
        healthBar:EnableMouse(false)

        -- Power bar (StatusBar)
        local powerBar = _G.CreateFrame("StatusBar", nil, unitFrame)
        powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1)
        powerBar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, -1)
        powerBar:SetHeight(7)
        powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        powerBar:SetStatusBarColor(0.2, 0.4, 0.9)
        powerBar:SetMinMaxValues(0, 1)
        powerBar:SetValue(i == 1 and 0.7 or 0.45)
        powerBar:EnableMouse(false)

        -- Border around unit frame
        local unitBorder = unitFrame:CreateTexture(nil, "BORDER")
        unitBorder:SetPoint("TOPLEFT", -1, 1)
        unitBorder:SetPoint("BOTTOMRIGHT", 1, -1)
        unitBorder:SetColorTexture(0.3, 0.3, 0.3, 1)
        unitBorder:SetDrawLayer("BORDER", -1)

        unitFrame.bg = unitBg
        unitFrame.healthBar = healthBar
        unitFrame.powerBar = powerBar
        unitFrame.border = unitBorder

        -- 8.3: Register with Aurora Color system (guarded)
        if Color and Color.RegisterHighlightElement then
            Color.RegisterHighlightElement(unitFrame, "frame")
            Color.RegisterHighlightElement(unitBorder, "border")
        end
    end

    -- Mock action bar row: 6 button-sized frames
    local btnSize = 28
    local btnGap = 4
    local totalBtnWidth = 6 * btnSize + 5 * btnGap
    local btnStartX = (PREVIEW_WIDTH - totalBtnWidth) / 2
    local btnY = -100

    for i = 1, 6 do
        local btn = _G.CreateFrame("Frame", nil, previewFrame)
        btn:SetSize(btnSize, btnSize)
        btn:SetPoint("TOPLEFT", btnStartX + (i - 1) * (btnSize + btnGap), btnY)
        btn:EnableMouse(false)

        -- Button background
        local btnBg = btn:CreateTexture(nil, "BACKGROUND")
        btnBg:SetAllPoints()
        btnBg:SetColorTexture(0.18, 0.18, 0.18, 1)

        -- Button border
        local btnBorder = btn:CreateTexture(nil, "BORDER")
        btnBorder:SetPoint("TOPLEFT", -1, 1)
        btnBorder:SetPoint("BOTTOMRIGHT", 1, -1)
        btnBorder:SetColorTexture(0.35, 0.35, 0.35, 1)
        btnBorder:SetDrawLayer("BORDER", -1)

        -- Simple icon placeholder (slightly lighter square inside)
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 3, -3)
        icon:SetPoint("BOTTOMRIGHT", -3, 3)
        icon:SetColorTexture(0.25, 0.25, 0.3, 1)

        btn.bg = btnBg
        btn.border = btnBorder

        -- 8.3: Register with Aurora Color system (guarded)
        if Color and Color.RegisterHighlightElement then
            Color.RegisterHighlightElement(btn, "button")
        end
    end

    -- Chat strip: two lines of static dummy text
    local chatY = -140
    local chatTexts = {
        "|cffaaaaaa[Guild] Player: Anyone up for a dungeon?|r",
        "|cffcccccc[Party] Tank: Ready when you are!|r",
    }

    for i = 1, 2 do
        local chatLine = previewFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        chatLine:SetPoint("TOPLEFT", 12, chatY - (i - 1) * 14)
        chatLine:SetPoint("RIGHT", previewFrame, "RIGHT", -12, 0)
        chatLine:SetJustifyH("LEFT")
        chatLine:SetText(chatTexts[i])
        chatStrings[i] = chatLine
    end
end

---------------------------------------------------------------------------
-- 8.4: PreviewPreset — update preview frame for a given preset
---------------------------------------------------------------------------

--- Update the live preview frame to reflect a preset's settings.
-- Sets preview scale, applies color mode to registered elements, and
-- updates chat strip font sizes. Does NOT affect the live UI.
-- @param presetId string  Preset identifier
function DisplayStage.PreviewPreset(presetId)
    if not previewFrame then return end

    local preset = RealUI.DisplayPresets.GetById(presetId)
    if not preset then return end

    -- 1. Set preview frame scale
    previewFrame:SetScale((preset.customScale or 1.0) * BASE_PREVIEW_SCALE)

    -- 2. Derive color mode from the independent HDR toggle
    local colorMode = DisplayStage.hdrEnabled and "HDR" or "Normal"
    if Color and Color.PreviewMode then
        Color.PreviewMode(colorMode)
    end

    -- 3. Update mock font sizes
    local baseFontSize = 12
    for _, fontString in ipairs(chatStrings) do
        local fontFile = fontString:GetFont()
        if fontFile then
            fontString:SetFont(fontFile, baseFontSize * (preset.fontScale or 1.0))
        end
    end

    previewFrame:Show()
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

--- Show the display stage content inside a parent frame (wizard mode).
-- @param parentFrame Frame  The content frame to parent cards into
function DisplayStage.Show(parentFrame)
    isWizardMode = true

    -- If already showing on the same parent, don't reset state.
    -- UpdateStage re-calls onShow every time canAdvance is checked;
    -- resetting here would wipe the user's card selection.
    if scrollFrame and scrollFrame:IsShown() and scrollFrame:GetParent() == parentFrame then
        return
    end

    -- Build UI lazily on first show
    if not scrollFrame then
        BuildCardGrid(parentFrame)
        BuildPreviewFrame(parentFrame)
    else
        -- Re-parent to the new parent frame
        scrollFrame:SetParent(parentFrame)
        scrollFrame:ClearAllPoints()
        scrollFrame:SetPoint("TOPLEFT", 0, 0)
        scrollFrame:SetPoint("BOTTOMRIGHT", -(PREVIEW_WIDTH + 30), 30)

        if hdrCheckbox then
            hdrCheckbox:SetParent(parentFrame)
            hdrCheckbox:ClearAllPoints()
            hdrCheckbox:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 0, -8)
        end

        if previewFrame then
            previewFrame:SetParent(parentFrame)
            previewFrame:ClearAllPoints()
            previewFrame:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", 0, 0)
        end
    end

    -- Reset selection state
    DisplayStage.selectedPresetId = nil

    -- Reset HDR toggle to current stored value or false
    local display = RealUI.db and RealUI.db.global and RealUI.db.global.display
    DisplayStage.hdrEnabled = display and display.hdrEnabled or false
    if hdrCheckbox then
        hdrCheckbox:SetChecked(DisplayStage.hdrEnabled)
    end

    -- Auto-suggest
    DisplayStage.suggestedPresetId = RealUI.DisplayPresets.Suggest()
    RefreshRecommendedBadge()
    RefreshCardHighlights()

    -- Scroll suggested card into view
    local suggestedCard = cardById[DisplayStage.suggestedPresetId]
    if suggestedCard then
        -- Defer scroll slightly so layout has settled
        _G.C_Timer.After(0.05, function()
            ScrollToCard(suggestedCard)
        end)
    end

    scrollFrame:Show()
    if hdrCheckbox then
        hdrCheckbox:Show()
    end
    if previewFrame then
        previewFrame:Show()
    end
end

--- Hide the display stage content.
function DisplayStage.Hide()
    if scrollFrame then
        scrollFrame:Hide()
    end
    if hdrCheckbox then
        hdrCheckbox:Hide()
    end
    if previewFrame then
        previewFrame:Hide()
    end
end

--- Open the display stage as a standalone frame (outside the wizard).
function DisplayStage.Open()
    isWizardMode = false

    if standaloneFrame then
        -- Already open — bring to front
        standaloneFrame:SetFrameStrata("DIALOG")
        standaloneFrame:Raise()
        standaloneFrame:Show()

        -- Refresh suggestion and reset selection
        DisplayStage.selectedPresetId = nil
        DisplayStage.suggestedPresetId = RealUI.DisplayPresets.Suggest()
        RefreshRecommendedBadge()
        RefreshCardHighlights()

        -- Reset HDR toggle to current stored value or false
        local display = RealUI.db and RealUI.db.global and RealUI.db.global.display
        DisplayStage.hdrEnabled = display and display.hdrEnabled or false
        if hdrCheckbox then
            hdrCheckbox:SetChecked(DisplayStage.hdrEnabled)
        end

        -- Update confirm button state
        if standaloneFrame.confirmButton then
            standaloneFrame.confirmButton:SetEnabled(false)
        end
        return
    end

    -- Create standalone frame
    standaloneFrame = _G.CreateFrame("Frame", "RealUIDisplayStage", _G.UIParent)
    standaloneFrame:SetSize(860, 480)
    standaloneFrame:SetPoint("CENTER")
    standaloneFrame:SetFrameStrata("DIALOG")
    standaloneFrame:SetMovable(true)
    standaloneFrame:EnableMouse(true)
    standaloneFrame:RegisterForDrag("LeftButton")
    standaloneFrame:SetScript("OnDragStart", standaloneFrame.StartMoving)
    standaloneFrame:SetScript("OnDragStop", standaloneFrame.StopMovingOrSizing)

    -- Backdrop
    Base.SetBackdrop(standaloneFrame, Color.frame, 0.95)

    -- Title
    local titleText = standaloneFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleText:SetPoint("TOP", 0, -14)
    titleText:SetText("Display Setup")

    -- Close button
    local closeBtn = _G.CreateFrame("Button", nil, standaloneFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        standaloneFrame:Hide()
    end)

    -- Content area for cards
    local contentArea = _G.CreateFrame("Frame", nil, standaloneFrame)
    contentArea:SetPoint("TOPLEFT", 20, -40)
    contentArea:SetPoint("BOTTOMRIGHT", -20, 50)

    -- Confirm button
    local confirmBtn = _G.CreateFrame("Button", nil, standaloneFrame, "UIPanelButtonTemplate")
    confirmBtn:SetSize(120, 25)
    confirmBtn:SetPoint("BOTTOMRIGHT", -20, 14)
    confirmBtn:SetText("Apply")
    confirmBtn:SetEnabled(false)
    confirmBtn:SetScript("OnClick", function()
        if DisplayStage.selectedPresetId then
            RealUI.DisplayPresets.Apply(DisplayStage.selectedPresetId, DisplayStage.hdrEnabled)
            standaloneFrame:Hide()
        end
    end)
    standaloneFrame.confirmButton = confirmBtn

    -- Cancel button
    local cancelBtn = _G.CreateFrame("Button", nil, standaloneFrame, "UIPanelButtonTemplate")
    cancelBtn:SetSize(100, 25)
    cancelBtn:SetPoint("BOTTOMLEFT", 20, 14)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", function()
        standaloneFrame:Hide()
    end)

    -- Show the card grid inside the standalone content area
    DisplayStage.Show(contentArea)

    -- Override isWizardMode since Show sets it to true
    isWizardMode = false

    -- Hook card clicks to also update the confirm button
    for _, card in ipairs(cards) do
        local origOnClick = card:GetScript("OnClick")
        card:SetScript("OnClick", function(self)
            origOnClick(self)
            confirmBtn:SetEnabled(DisplayStage.selectedPresetId ~= nil)
        end)
    end

    standaloneFrame:Show()
end

---------------------------------------------------------------------------
-- Task 10: Display-size change event handling
---------------------------------------------------------------------------

-- 10.2: Session-local suppress flag — resets on next login (not saved)
local displayChangedSuppressed = false

-- 10.2: Define the StaticPopup dialog for display-change notification
_G.StaticPopupDialogs["REALUI_DISPLAY_CHANGED"] = {
    text         = "Your display configuration changed. Update display settings?",
    button1      = "Reconfigure",
    button2      = "Dismiss",
    OnAccept     = function() DisplayStage.Open() end,
    OnCancel     = function() displayChangedSuppressed = true end,
    timeout      = 0,
    whileDead    = true,
    hideOnEscape = true,
}

-- 10.1 / 10.3: Handler for DISPLAY_SIZE_CHANGED and UI_SCALE_CHANGED
local function OnDisplayChanged()
    -- Guard: don't show popups during combat
    if _G.InCombatLockdown() then return end

    -- 10.3: If the display stage is currently open, recalculate auto-suggest
    -- and update the Recommended badge without closing the stage
    if scrollFrame and scrollFrame:IsShown() then
        DisplayStage.suggestedPresetId = RealUI.DisplayPresets.Suggest()
        RefreshRecommendedBadge()
        return
    end

    -- 10.2: Show the popup (unless suppressed for this session)
    if displayChangedSuppressed then return end
    _G.StaticPopup_Show("REALUI_DISPLAY_CHANGED")
end

-- 10.1: Register event handlers post-load (after PLAYER_ENTERING_WORLD)
-- Uses its own event frame so registration happens after initial setup is
-- complete, outside of InCombatLockdown.
local displayEventFrame = _G.CreateFrame("Frame")
displayEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
displayEventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Initial setup is complete — now register the display-change events
        self:RegisterEvent("DISPLAY_SIZE_CHANGED")
        self:RegisterEvent("UI_SCALE_CHANGED")
        -- Unregister PLAYER_ENTERING_WORLD; we only needed it once
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
        OnDisplayChanged()
    end
end)
