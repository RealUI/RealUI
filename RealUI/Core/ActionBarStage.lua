local _, private = ...

-- Lua Globals --
-- luacheck: globals next ipairs type _G

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("ActionBarStage") -- luacheck: ignore

--[[ B04: "choose your action bar layout" wizard stage.

     The install wizard never offered a bar-layout choice, so every fresh
     install landed on the shipped default and testers had to find
     HuD config → Other → Action Bars afterwards.

     Two INDEPENDENT axes drive the layout (`RealUI:GetModule("ActionBars")`
     db, read by RealUI_ActionBars/Integration.lua):
       centerPositions 1..4 = "%d Center - %d Bottom"  (0/3, 1/2, 2/1, 3/0)
       sidePositions   1..3 = "%d Left - %d Right"     (0/2, 1/1, 2/0)
     Naming combinations of those as "presets" would invent meaning that
     isn't in the data, so this stage offers one row of choices per axis and
     a live schematic showing the result — the DisplayStage card idioms
     (selection highlight, recommended badge) without pretending the two
     axes are one. ]]--

local ActionBarStage = {}
RealUI.ActionBarStage = ActionBarStage

---------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------
ActionBarStage.centerPositions = 2  -- shipped default: 1 center, 2 bottom
ActionBarStage.sidePositions = 1    -- shipped default: 0 left, 2 right

local container          -- the frame holding everything (built lazily)
local schematic          -- the preview box
local centerButtons = {}
local sideButtons = {}

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------
local SELECTED_COLOR = {r = 0.3, g = 0.6, b = 1.0}
local NORMAL_BG = {r = 0.15, g = 0.15, b = 0.15, a = 0.8}
local HOVER_BG  = {r = 0.2, g = 0.2, b = 0.2, a = 0.9}

-- The wizard's content frame is only 510x240 (InstallUI: 550x500 window,
-- content inset TOPLEFT 20,-200 / BOTTOMRIGHT -20,60), so everything here is
-- budgeted against that: a 262px left column of single-line options and a
-- 230px schematic beside it, totalling ~220px of height.
local LEFT_WIDTH = 262
local OPTION_HEIGHT = 26
local OPTION_GAP = 4
local SIDE_OPTION_WIDTH = 82
local SIDE_OPTION_GAP = 8

local SCHEMATIC_WIDTH = 230
local SCHEMATIC_HEIGHT = 180

-- (centerPositions) -> centre bars above the HuD, bars along the bottom
local CENTER_OPTIONS = {
    {value = 1, top = 0, bottom = 3},
    {value = 2, top = 1, bottom = 2},
    {value = 3, top = 2, bottom = 1},
    {value = 4, top = 3, bottom = 0},
}
-- (sidePositions) -> vertical bars on each edge
local SIDE_OPTIONS = {
    {value = 1, left = 0, right = 2},
    {value = 2, left = 1, right = 1},
    {value = 3, left = 2, right = 0},
}

local DEFAULT_CENTER = 2
local DEFAULT_SIDE = 1

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function GetOption(list, value)
    for _, option in ipairs(list) do
        if option.value == value then return option end
    end
    return list[1]
end

--- Notify the wizard that stage state changed (mirrors DisplayStage).
local function NotifyWizardStateChanged()
    if RealUI.InstallUI and RealUI.InstallWizard then
        RealUI.InstallUI:UpdateStage(RealUI.InstallWizard:GetCurrentStage())
    end
end

---------------------------------------------------------------------------
-- Schematic preview
---------------------------------------------------------------------------

local function BuildSchematic(parent)
    schematic = _G.CreateFrame("Frame", nil, parent)
    schematic:SetSize(SCHEMATIC_WIDTH, SCHEMATIC_HEIGHT)
    schematic:EnableMouse(false)

    local bg = schematic:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.08, 0.08, 0.9)

    local border = schematic:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(0.3, 0.3, 0.3, 1)
    border:SetDrawLayer("BORDER", -1)

    local label = schematic:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOP", 0, -4)
    label:SetText("|cffaaaaaaPreview|r")

    -- A dot marking where the character/HuD sits, for orientation
    local hud = schematic:CreateTexture(nil, "ARTWORK")
    hud:SetSize(30, 30)
    hud:SetPoint("CENTER", 0, 10)
    hud:SetColorTexture(0.2, 0.25, 0.32, 0.9)

    -- Pool of bar rectangles, positioned by RefreshSchematic
    schematic.bars = {}
    for i = 1, 10 do
        local bar = schematic:CreateTexture(nil, "OVERLAY")
        bar:SetColorTexture(SELECTED_COLOR.r, SELECTED_COLOR.g, SELECTED_COLOR.b, 0.85)
        bar:Hide()
        schematic.bars[i] = bar
    end
end

--- Draw the currently selected arrangement into the schematic.
local function RefreshSchematic()
    if not schematic then return end

    local center = GetOption(CENTER_OPTIONS, ActionBarStage.centerPositions)
    local side = GetOption(SIDE_OPTIONS, ActionBarStage.sidePositions)

    for _, bar in ipairs(schematic.bars) do
        bar:Hide()
    end

    local index = 0
    local function NextBar()
        index = index + 1
        local bar = schematic.bars[index]
        if bar then
            bar:ClearAllPoints()
            bar:Show()
        end
        return bar
    end

    local barW, barH = 78, 6
    local gap = 3

    -- Centre bars: stacked upward from just under the HuD dot
    for i = 1, center.top do
        local bar = NextBar()
        if bar then
            bar:SetSize(barW, barH)
            bar:SetPoint("CENTER", schematic, "CENTER", 0, -8 - (i - 1) * (barH + gap))
        end
    end

    -- Bottom bars: stacked upward from the bottom edge
    for i = 1, center.bottom do
        local bar = NextBar()
        if bar then
            bar:SetSize(barW, barH)
            bar:SetPoint("BOTTOM", schematic, "BOTTOM", 0, 8 + (i - 1) * (barH + gap))
        end
    end

    -- Side bars: vertical, hugging their edge
    for i = 1, side.left do
        local bar = NextBar()
        if bar then
            bar:SetSize(barH, 56)
            bar:SetPoint("LEFT", schematic, "LEFT", 8 + (i - 1) * (barH + gap), 6)
        end
    end
    for i = 1, side.right do
        local bar = NextBar()
        if bar then
            bar:SetSize(barH, 56)
            bar:SetPoint("RIGHT", schematic, "RIGHT", -8 - (i - 1) * (barH + gap), 6)
        end
    end
end

---------------------------------------------------------------------------
-- Option buttons
---------------------------------------------------------------------------

local function RefreshHighlights()
    for _, btn in ipairs(centerButtons) do
        local selected = btn.value == ActionBarStage.centerPositions
        btn.bg:SetColorTexture(
            selected and SELECTED_COLOR.r or NORMAL_BG.r,
            selected and SELECTED_COLOR.g or NORMAL_BG.g,
            selected and SELECTED_COLOR.b or NORMAL_BG.b,
            selected and 0.35 or NORMAL_BG.a)
        btn.border:SetColorTexture(
            selected and SELECTED_COLOR.r or 0.3,
            selected and SELECTED_COLOR.g or 0.3,
            selected and SELECTED_COLOR.b or 0.3, 1)
    end
    for _, btn in ipairs(sideButtons) do
        local selected = btn.value == ActionBarStage.sidePositions
        btn.bg:SetColorTexture(
            selected and SELECTED_COLOR.r or NORMAL_BG.r,
            selected and SELECTED_COLOR.g or NORMAL_BG.g,
            selected and SELECTED_COLOR.b or NORMAL_BG.b,
            selected and 0.35 or NORMAL_BG.a)
        btn.border:SetColorTexture(
            selected and SELECTED_COLOR.r or 0.3,
            selected and SELECTED_COLOR.g or 0.3,
            selected and SELECTED_COLOR.b or 0.3, 1)
    end
end

local function CreateOptionButton(parent, width, labelText, value, isDefault, onClick)
    local btn = _G.CreateFrame("Button", nil, parent)
    btn:SetSize(width, OPTION_HEIGHT)
    btn.value = value

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(NORMAL_BG.r, NORMAL_BG.g, NORMAL_BG.b, NORMAL_BG.a)
    btn.bg = bg

    local border = btn:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT")
    border:SetPoint("BOTTOMLEFT")
    border:SetWidth(3)
    border:SetColorTexture(0.3, 0.3, 0.3, 1)
    btn.border = border

    -- Single line: at 26px there is no room for a heading plus a subtitle,
    -- and the descriptive line ("1 centre, 2 bottom") is the useful half.
    local name = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    name:SetPoint("LEFT", 9, 0)
    name:SetPoint("RIGHT", isDefault and -16 or -6, 0)
    name:SetJustifyH("LEFT")
    name:SetText(labelText)

    if isDefault then
        local badge = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        badge:SetPoint("RIGHT", -5, 0)
        badge:SetText("|cff33cc33*|r")
    end

    btn:SetScript("OnEnter", function(self)
        if self.value ~= (self.axis == "center" and ActionBarStage.centerPositions
            or ActionBarStage.sidePositions) then
            self.bg:SetColorTexture(HOVER_BG.r, HOVER_BG.g, HOVER_BG.b, HOVER_BG.a)
        end
    end)
    btn:SetScript("OnLeave", function()
        RefreshHighlights()
    end)
    btn:SetScript("OnClick", function(self)
        onClick(self.value)
        RefreshHighlights()
        RefreshSchematic()
        NotifyWizardStateChanged()
    end)

    return btn
end

---------------------------------------------------------------------------
-- Build
---------------------------------------------------------------------------

local function Build(parent)
    container = _G.CreateFrame("Frame", nil, parent)
    container:SetAllPoints()

    -- Plain ASCII only: the wizard's font rendered the UTF-8 arrow escapes as
    -- replacement glyphs on first run.
    local intro = container:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", 0, 0)
    intro:SetPoint("TOPRIGHT", 0, 0)
    intro:SetJustifyH("LEFT")
    intro:SetText("Choose how your action bars are arranged. Changeable later in HuD config > Other > Action Bars.")

    BuildSchematic(container)
    schematic:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, -30)

    -- Main-bar options: single column down the left
    local centerLabel = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    centerLabel:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -30)
    centerLabel:SetText("Main bars")

    for i, option in ipairs(CENTER_OPTIONS) do
        local btn = CreateOptionButton(container, LEFT_WIDTH,
            ("%d centre, %d bottom"):format(option.top, option.bottom),
            option.value, option.value == DEFAULT_CENTER,
            function(value) ActionBarStage.centerPositions = value end)
        btn.axis = "center"
        if i == 1 then
            btn:SetPoint("TOPLEFT", centerLabel, "BOTTOMLEFT", 0, -4)
        else
            btn:SetPoint("TOPLEFT", centerButtons[i - 1], "BOTTOMLEFT", 0, -OPTION_GAP)
        end
        centerButtons[i] = btn
    end

    -- Side-bar options: one row underneath
    local sideLabel = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    sideLabel:SetPoint("TOPLEFT", centerButtons[#CENTER_OPTIONS], "BOTTOMLEFT", 0, -8)
    sideLabel:SetText("Side bars")

    for i, option in ipairs(SIDE_OPTIONS) do
        local btn = CreateOptionButton(container, SIDE_OPTION_WIDTH,
            ("%dL / %dR"):format(option.left, option.right),
            option.value, option.value == DEFAULT_SIDE,
            function(value) ActionBarStage.sidePositions = value end)
        btn.axis = "side"
        if i == 1 then
            btn:SetPoint("TOPLEFT", sideLabel, "BOTTOMLEFT", 0, -4)
        else
            btn:SetPoint("LEFT", sideButtons[i - 1], "RIGHT", SIDE_OPTION_GAP, 0)
        end
        sideButtons[i] = btn
    end
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

--- Show the stage content inside the wizard's content frame.
function ActionBarStage.Show(parentFrame)
    if container and container:IsShown() and container:GetParent() == parentFrame then
        return
    end

    if not container then
        Build(parentFrame)
    else
        container:SetParent(parentFrame)
        container:SetAllPoints()
    end

    -- Seed from the live settings so the stage reflects reality (re-entry,
    -- or a re-run of the wizard on a configured character).
    local abModule = RealUI.GetModule and RealUI:GetModule("ActionBars", true)
    local layout = RealUI.cLayout or 1
    local settings = abModule and abModule.db and abModule.db.profile[layout]
    ActionBarStage.centerPositions = (settings and settings.centerPositions) or DEFAULT_CENTER
    ActionBarStage.sidePositions = (settings and settings.sidePositions) or DEFAULT_SIDE

    RefreshHighlights()
    RefreshSchematic()
    container:Show()
end

function ActionBarStage.Hide()
    if container then
        container:Hide()
    end
end

--- Write the chosen arrangement into RealUI's ActionBars module DB and
--- re-apply. Both layouts get the choice: the wizard is initial setup, and a
--- fresh character has customised neither. Per-layout tuning stays available
--- in HuD config afterwards.
function ActionBarStage.Apply()
    local abModule = RealUI.GetModule and RealUI:GetModule("ActionBars", true)
    if not (abModule and abModule.db and abModule.db.profile) then
        debug("Apply: ActionBars module db not available")
        return false
    end

    for _, layout in ipairs({1, 2}) do
        local settings = abModule.db.profile[layout]
        if settings then
            settings.centerPositions = ActionBarStage.centerPositions
            settings.sidePositions = ActionBarStage.sidePositions
        end
    end

    -- Same refresh pair the config sliders use (ConfigBar center/side setters).
    if abModule.ApplyABSettings then
        _G.pcall(abModule.ApplyABSettings, abModule)
    end
    if RealUI.UpdatePositioners then
        _G.pcall(RealUI.UpdatePositioners, RealUI)
    end

    debug("Applied centerPositions", ActionBarStage.centerPositions,
        "sidePositions", ActionBarStage.sidePositions)
    return true
end

RealUI:RegisterNamespace("ActionBarStage", ActionBarStage)
