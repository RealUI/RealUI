local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals next type select math ipairs
-- luacheck: globals getmetatable setmetatable tinsert

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color, Util = Aurora.Color, Aurora.Util


do --[[ AddOns\DBM-GUI.lua ]]
    local frameTitle = "DBM_GUI_Option_"
    local PanelPrototype, prottypemetatable = {}
    function PanelPrototype:CreateText(text, width, autoplaced, style, justify)
        --local textblock = self:GetLastObj()
    end
    function PanelPrototype:CreateButton(title, width, height, onclick, FontObject)
        local button = self:GetLastObj()
        Skin.UIPanelButtonTemplate(button)
    end
    function PanelPrototype:CreateSlider(text, low, high, step, framewidth)
        local slider = self:GetLastObj()
        Skin.OptionsSliderTemplate(slider)
    end
    function PanelPrototype:CreateEditBox(text, value, width, height)
        local textbox = self:GetLastObj()
        Skin.InputBoxTemplate(textbox)
    end
    function PanelPrototype:CreateLine(text)
        --local line = self:GetLastObj()
    end
    function PanelPrototype:CreateCheckButton(name, autoplace, textleft, dbmvar, dbtvar, mod, modvar, globalvar, isTimer)
        local button = self:GetLastObj()
        Skin.OptionsBaseCheckButtonTemplate(button)

        if modvar then
            if not isTimer then
                local noteButton = _G[frameTitle.._G.DBM_GUI:GetCurrentID()]
                Skin.UIPanelButtonTemplate(noteButton)
            end
        end
    end
    function PanelPrototype:CreateArea(name, width, height, autoplace)
        local area = self:GetLastObj()
        Skin.OptionsBoxTemplate(area)
    end

    Hook.DBM_GUI_OptionsFrame = {}
    function Hook.DBM_GUI_OptionsFrame:DisplayButton(button, element)
        if element.haschilds then
            --button.toggle:SetNormalTexture("")
            button.toggle:SetPushedTexture("")
        end
    end
    function Hook.DBM_GUI_OptionsFrame:ShowTab(tab)
        local tabPrefix = self:GetName().."Tab"
        if tab == 1 then
            _G[tabPrefix..1]:SetNormalFontObject("GameFontHighlightSmall")
            _G[tabPrefix..2]:SetNormalFontObject("GameFontNormalSmall")
        else
            _G[tabPrefix..1]:SetNormalFontObject("GameFontNormalSmall")
            _G[tabPrefix..2]:SetNormalFontObject("GameFontHighlightSmall")
        end
    end

    Hook.DBM_GUI = {}
    function Hook.DBM_GUI:CreateNewPanel(FrameName, FrameTyp, showsub, sortID, DisplayName)
        if not prottypemetatable then
            prottypemetatable = getmetatable(self.panels[#self.panels])
            Util.Mixin(prottypemetatable.__index, PanelPrototype)
        end
    end

    local dropdownTitle = "DBM_GUI_DropDown"
    function Hook.DBM_GUI:CreateDropdown(title, values, vartype, var, callfunc, width, height, parent)
        local dropdown = _G[dropdownTitle..self:GetCurrentID()]
        dropdown._height = height
        Skin.DBM_UIDropDownMenuTemplate(dropdown)
    end
end

do --[[ AddOns\DBM-GUI.xml ]]
    function Skin.DBM_ExpandOrCollapse(Button)
        Button.Left:SetAlpha(0)
        Button.Right:SetAlpha(0)
        Button.Middle:SetAlpha(0)

        Skin.ExpandOrCollapse(Button)
    end
    function Skin.DBM_UIDropDownMenuTemplate(Frame)
        Skin.UIDropDownMenuTemplate(Frame)
        local name = Frame:GetName()
        local topOffset, bottomOffset = 5, 9
        if Frame._height then
            topOffset = 6
            bottomOffset = 1
        end

        Frame:SetBackdropOption("offsets", {
            left = 21,
            right = -13,
            top = topOffset,
            bottom = bottomOffset,
        })

        local Button = _G[name.."Button"]
        topOffset, bottomOffset = 4, 2
        if Frame._height then
            topOffset = 5
            bottomOffset = 1
        end
        Button:SetBackdropOption("offsets", {
            left = 2,
            right = 4,
            top = topOffset,
            bottom = bottomOffset,
        })
    end
end

private.AddOns["DBM-GUI"] = function()
    Util.Mixin(_G.DBM_GUI, Hook.DBM_GUI)

    ----====####$$$$%%%%$$$$####====----
    --             DBM-GUI            --
    ----====####$$$$%%%%$$$$####====----
    Util.Mixin(_G.DBM_GUI_OptionsFrame, Hook.DBM_GUI_OptionsFrame)

    Base.SetBackdrop(_G.DBM_GUI_OptionsFrame)
    _G.DBM_GUI_OptionsFrameHeader:SetTexture("")

    Skin.UIPanelButtonTemplate(_G.DBM_GUI_OptionsFrameOkay)
    Skin.UIPanelButtonTemplate(_G.DBM_GUI_OptionsFrameWebsiteButton)
    Skin.OptionsFrameTabButtonTemplate(_G.DBM_GUI_OptionsFrameTab1)
    Skin.OptionsFrameTabButtonTemplate(_G.DBM_GUI_OptionsFrameTab2)

    Skin.OptionsFrameListTemplate(_G.DBM_GUI_OptionsFrameList)
    for index, button in next, _G.DBM_GUI_OptionsFrameList.buttons do
        Skin.DBM_ExpandOrCollapse(button.toggle)
    end

    Base.SetBackdrop(_G.DBM_GUI_OptionsFramePanelContainer, Color.frame)
    Skin.FauxScrollFrameTemplate(_G.DBM_GUI_OptionsFramePanelContainerFOV)
    select(3, _G.DBM_GUI_OptionsFramePanelContainerFOVScrollBar:GetChildren()):Hide() --frameContainerScrollBarBackdrop

    local typeToTemplate = {
        --modelframe = "",
        --textblock = "",
        button = "UIPanelButtonTemplate",
        --colorselect = "",
        slider = "OptionsSliderTemplate",
        textbox = "InputBoxTemplate",
        --line = "",
        checkbutton = "OptionsBaseCheckButtonTemplate",
        area = "OptionsBoxTemplate",
    }
    local function CheckChildren(frame)
        for i = 1, frame:GetNumChildren() do
            local child = select(i, frame:GetChildren())
            if typeToTemplate[child.mytype] then
                Skin[typeToTemplate[child.mytype]](child)
            elseif child.values then
                Skin.DBM_UIDropDownMenuTemplate(child)
            end

            if child.mytype == "area" then
                CheckChildren(child)
            end
        end
    end

    for index, panel in next, _G.DBM_GUI.panels do
        CheckChildren(panel.frame)
    end

    ----====####$$$$%%%%$$$$####====----
    --        DBM-GUI_DropDown        --
    ----====####$$$$%%%%$$$$####====----
    Skin.OptionsFrameListTemplate(_G.DBM_GUI_DropDown)

    for index, button in next, _G.DBM_GUI_DropDown.buttons do
        Skin.UIDropDownMenuButtonTemplate(button)
    end
end
