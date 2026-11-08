local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals next select setmetatable

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin
local Color, Util = Aurora.Color, Aurora.Util

--[[ DBM-GUI options window
    Written against DBM-GUI 12.1.20 (retail and Forever). The options GUI is
    built in Lua from Blizzard templates, so almost everything maps onto an
    Aurora skin that already exists. Only the options window is skinned; the
    timer bars and warnings have DBM's own style settings.

    Two rules, learned from the skin this replaces (B209):
      * Every Aurora skin is looked up through Apply(), never called
        directly. Aurora drops templates as Blizzard does, and the old skin
        died on Skin.OptionsBoxTemplate when that happened. A missing skin
        now leaves one frame unskinned instead of throwing on every panel.
      * Panels are swept when DBM displays them, not hooked at creation. The
        core panels already exist when DBM-GUI's ADDON_LOADED fires, and boss
        panels are built on demand later; DisplayFrame sees both, and DBM's
        builder functions (which call each other and share SetLastObj) are
        left alone.
]]

local function Apply(skinName, frame, ...)
    local skin = Skin[skinName]
    if skin and frame then
        skin(frame, ...)
        return true
    end
end

local skinned = setmetatable({}, {__mode = "k"})

-- DBM's +/- toggles are UIPanelButtonTemplate buttons whose normal texture
-- DBM swaps between the Blizzard plus/minus fileIDs (130838/130821), which
-- Skin.ExpandOrCollapse already understands. Drop the panel-button art first.
local function SkinToggle(Button)
    if not Button or skinned[Button] then return end
    for _, key in next, {"Left", "Middle", "Right"} do
        if Button[key] then Button[key]:SetAlpha(0) end
    end
    Apply("ExpandOrCollapse", Button)
    skinned[Button] = true
end

-- Forever: DBM uses MinimalTabTemplate off retail. Its Left/Middle/Right are
-- re-atlased on every state change; alpha survives that, and the selected tab
-- is carried by the button colour so mouse-leave restores it.
local function SkinMinimalTab(Button)
    for _, key in next, {"Left", "Middle", "Right"} do
        if Button[key] then Button[key]:SetAlpha(0) end
    end
    Skin.FrameTypeButton(Button)
    local function UpdateSelected(self)
        local selected = self.IsSelected and self:IsSelected()
        self:SetButtonColor(selected and Color.highlight or Color.button, nil, Color.buttonDisabled)
    end
    if Button.UpdateAtlas then
        _G.hooksecurefunc(Button, "UpdateAtlas", UpdateSelected)
    end
    UpdateSelected(Button)
end

local function IsPanelButton(frame)
    return frame:IsObjectType("Button") and frame.Left and frame.Middle and frame.Right
end

local controlSkins = {
    button = function(Button)
        Apply("UIPanelButtonTemplate", Button)
    end,
    checkbutton = function(CheckButton)
        Apply("OptionsBaseCheckButtonTemplate", CheckButton)
    end,
    textbox = function(EditBox)
        Apply("InputBoxTemplate", EditBox)
    end,
    slider = function(Slider)
        Apply("HorizontalSliderTemplate", Slider)
        -- InputBoxVisualTemplate: the same Left/Middle/Right art.
        Apply("InputBoxTemplate", Slider.editbox)
    end,
    dropdown2 = function(Dropdown)
        Apply("DropdownButton", Dropdown)
    end,
    -- "area" and "ability" are containers; SkinChildren handles them.
}

local function SkinChildren(frame)
    for i = 1, frame:GetNumChildren() do
        local child = select(i, frame:GetChildren())
        local mytype = child.mytype
        if mytype == "area" or mytype == "ability" then
            -- Containers: their own skin once, their children on every pass
            -- (an area can gain controls after it was first shown).
            if not skinned[child] then
                Apply("TooltipBorderBackdropTemplate", child)
                skinned[child] = true
            end
            SkinChildren(child)
        elseif not skinned[child] then
            local skin = mytype and controlSkins[mytype]
            if skin then
                skin(child)
            elseif child.toggle and not mytype then
                -- An ability's OptionsListButtonTemplate expand button.
                SkinToggle(child.toggle)
            elseif not mytype and IsPanelButton(child) then
                -- Rename / Reset / spell-test buttons carry no mytype.
                Apply("UIPanelButtonTemplate", child)
            end
            skinned[child] = true
        end
    end
end

private.AddOns["DBM-GUI"] = function()
    local OptionsFrame = _G.DBM_GUI_OptionsFrame
    if not OptionsFrame then return end

    ----====####################====----
    --          Options window         --
    ----====####################====----
    -- A NineSlicePanelTemplate frame with ButtonFrameTemplateNoPortrait
    -- applied by name; FrameTypeFrame reuses those pieces, the same thing
    -- Aurora's BasicFrame layout does.
    Apply("FrameTypeFrame", OptionsFrame)
    if _G.DBM_GUI_OptionsFrameBg then _G.DBM_GUI_OptionsFrameBg:Hide() end
    if _G.DBM_GUI_OptionsFrameTitleBga then _G.DBM_GUI_OptionsFrameTitleBga:Hide() end

    Apply("UIPanelCloseButtonDefaultAnchors", _G.DBM_GUI_OptionsFrameClosePanelButton)
    Apply("UIPanelButtonTemplate", _G.DBM_GUI_OptionsFrameCollapseButton)
    Apply("UIPanelButtonTemplate", _G.DBM_GUI_OptionsFrameOkay)
    Apply("UIPanelButtonTemplate", _G.DBM_GUI_OptionsFrameWebsiteButton)
    Apply("UIPanelButtonTemplate", _G.DBM_GUI_OptionsFrameSearchClear)
    Apply("InputBoxTemplate", _G.DBM_GUI_OptionsFrameSearchBox)

    -- Tabs: PanelTopTabButtonTemplate on retail, MinimalTabTemplate elsewhere.
    local i = 1
    local tab = _G.DBM_GUI_OptionsFrameTab1
    while tab do
        if tab.upLeftTexture then -- MinimalTabTemplate's atlas KeyValues
            SkinMinimalTab(tab)
        else
            Apply("PanelTopTabButtonTemplate", tab)
        end
        i = i + 1
        tab = _G["DBM_GUI_OptionsFrameTab" .. i]
    end

    ----====####################====----
    --       Category list + body      --
    ----====####################====----
    local List = _G.DBM_GUI_OptionsFrameList
    if List then
        -- The wrapper draws a tooltip-border box around list and body, and a
        -- tooltip-border strip between them anchored to the list's right
        -- edge. Find the strip before the wrapper's own backdrop is replaced
        -- (both use the same file).
        local Wrapper = List:GetParent()
        for _, region in next, {Wrapper:GetRegions()} do
            if region:IsObjectType("Texture") then
                local _, relativeTo = region:GetPoint(1)
                if relativeTo == List then
                    region:SetTexture(nil)
                    region:SetColorTexture(Color.button:GetRGB())
                    region:SetWidth(1)
                end
            end
        end
        Base.SetBackdrop(Wrapper, Color.frame, 0)

        Apply("UIPanelScrollFrameTemplate", List)

        if List.buttons then
            for _, button in next, List.buttons do
                local highlight = button:GetHighlightTexture()
                if highlight then
                    -- DBM tints it blue with a vertex colour; clear that or
                    -- it multiplies into the theme colour.
                    highlight:SetVertexColor(1, 1, 1)
                    Util.SetHighlightColor(highlight, 0.2)
                    highlight:SetBlendMode("BLEND")
                end
                SkinToggle(button.toggle)
            end
        end
    end

    local FOV = _G.DBM_GUI_OptionsFramePanelContainerFOV
    if FOV then
        local ScrollBar = _G.DBM_GUI_OptionsFramePanelContainerFOVScrollBar
        if ScrollBar then
            -- The tooltip-border box DBM draws around this scroll bar.
            for _, child in next, {ScrollBar:GetChildren()} do
                local info = child.backdropInfo
                if info and info.edgeFile == [[Interface\Tooltips\UI-Tooltip-Border]] then
                    child:Hide()
                end
            end
        end
        Apply("FauxScrollFrameTemplate", FOV)
    end

    ----====####################====----
    --             Panels              --
    ----====####################====----
    if OptionsFrame.DisplayFrame then
        _G.hooksecurefunc(OptionsFrame, "DisplayFrame", function(_, targetFrame)
            if targetFrame then
                SkinChildren(targetFrame)
            end
        end)
    end
    if _G.DBM_GUI and _G.DBM_GUI.currentViewing then
        SkinChildren(_G.DBM_GUI.currentViewing)
    end
end
