local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals next type select math ipairs
-- luacheck: globals getmetatable setmetatable tinsert

--[[ Core ]]
local Aurora = private.Aurora
local Base, Scale = Aurora.Base, Aurora.Scale
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color = Aurora.Color

do --[[ AddOns\DBM-GUI\DBM-GUI.lua ]]
    local PanelPrototype, backup, prottypemetatable = {}, {}
    local FrameTitle = "DBM_GUI_Option_"
    function Hook.DBM_GUI_CreateNewPanel(self, FrameName, FrameTyp, showsub, sortID, DisplayName)
        local panel = _G[FrameTitle..self:GetCurrentID()]
        Scale.RawSetWidth(panel, _G.DBM_GUI_OptionsFramePanelContainerFOV:GetWidth())
        Scale.RawSetHeight(panel, _G.DBM_GUI_OptionsFramePanelContainerFOV:GetHeight())

        if not prottypemetatable then
            prottypemetatable = getmetatable(self.panels[#self.panels])
            for name, func in next, PanelPrototype do
                backup[name] = prottypemetatable.__index[name]
                prottypemetatable.__index[name] = func
            end
        end
    end
    function PanelPrototype:CreateArea(name, width, height, autoplace)
        local area = _G.CreateFrame("Frame", FrameTitle..self:GetNewID(), self.frame, "OptionsBoxTemplate")
        Skin.OptionsBoxTemplate(area)
        area.mytype = "area"
        _G[FrameTitle..self:GetCurrentID().."Title"]:SetText(name)
        if width then
            if width < 0 then
                Scale.RawSetWidth(area, self.frame:GetWidth() - Scale.Value(12) + Scale.Value(width))
            else
                area:SetWidth(width)
            end
        else
            Scale.RawSetWidth(area, self.frame:GetWidth() - Scale.Value(12))
        end

        if height then
            area:SetHeight(height)
        else
            Scale.RawSetHeight(area, self.frame:GetHeight() - Scale.Value(10))
        end

        if autoplace then
            if select("#", self.frame:GetChildren()) == 1 then
                area:SetPoint("TOPLEFT", self.frame, 5, -20)
            else
                area:SetPoint("TOPLEFT", select(-2, self.frame:GetChildren()) or self.frame, "BOTTOMLEFT", 0, -20)
            end
        end

        self:SetLastObj(area)
        self.areas = self.areas or {}
        tinsert(self.areas, {frame = area, parent = self, framename = FrameTitle..self:GetCurrentID()})
        return setmetatable(self.areas[#self.areas], prottypemetatable)
    end
    function PanelPrototype:CreateCheckButton(name, autoplace, textleft, dbmvar, dbtvar, mod, modvar, globalvar, isTimer)
        local button = backup.CreateCheckButton(self, name, autoplace, textleft, dbmvar, dbtvar, mod, modvar, globalvar, isTimer)
        Skin.DBMOptionsCheckButtonTemplate(button)
        button.myheight = Scale.Value(25)

        local dropdown, noteButton
        if modvar then
            dropdown = button:GetChildren()
            if not isTimer then
                noteButton = _G[FrameTitle.._G.DBM_GUI:GetCurrentID()]
                Skin.DBM_GUI_OptionsFramePanelButtonTemplate(noteButton)
            end
        end

        local textpad = 0
        local widthAdjust = 0
        local textbeside = button
        if dropdown then
            --dropdown:SetPoint("LEFT", button, "RIGHT", -20, 8)

            if noteButton then
                --noteButton:SetPoint("LEFT", dropdown, "RIGHT", 35, -8)
                textbeside = noteButton
                textpad = 2
                widthAdjust = widthAdjust + dropdown:GetWidth() + noteButton:GetWidth()
            else
                textbeside = dropdown
                textpad = 35
                widthAdjust = widthAdjust + dropdown:GetWidth()
            end
        end

        local html = _G[button:GetName() .. "Text"]
        Scale.RawSetWidth(html, self.frame:GetWidth() - Scale.Value(57) - widthAdjust)
        html:SetText(html:GetRegions():GetText())

        if html and not textleft then
            html:SetHeight(1) -- oscarucb: hack to discover wrapped height, so we can space multi-line options
            html:SetPoint("TOPLEFT", _G.UIParent)

            local ht = select(4, html:GetBoundsRect()) or Scale.Value(25)
            html:ClearAllPoints()
            html:SetPoint("TOPLEFT", textbeside, "TOPRIGHT", textpad, -4)
            Scale.RawSetHeight(html, ht)
            button.myheight = math.max(ht + Scale.Value(12), button.myheight)
        end

        if autoplace then
            local _, x = button:GetPoint()
            if x.mytype == "checkbutton" or x.mytype == "line" then
                button:ClearAllPoints()
                Scale.RawSetPoint(button, "TOPLEFT", x, "TOPLEFT", 0, -x.myheight)
            else
                button:ClearAllPoints()
                button:SetPoint("TOPLEFT", 10, -12)
            end
        end

        return button
    end
    function PanelPrototype:CreateLine(text)
        local line = backup.CreateLine(self, text)
        Scale.RawSetSize(line, self.frame:GetWidth() - Scale.Value(20), Scale.Value(20))
        line.myheight = Scale.Value(20)

        local linetext, linebg = line:GetRegions()
        linebg:SetPoint("LEFT", linetext, "RIGHT", 2, 0)

        local _, x = line:GetPoint()
        if x.mytype == "checkbutton" or x.mytype == "line" then
            line:ClearAllPoints()
            Scale.RawSetPoint(line, "TOPLEFT", x, "TOPLEFT", 0, -x.myheight)
        else
            line:ClearAllPoints()
            line:SetPoint("TOPLEFT", 10, -12)
        end

        return line
    end
    function PanelPrototype:CreateEditBox(text, value, width, height)
        local textbox = backup.CreateEditBox(self, text, value, width, height)
        Skin.DBM_GUI_FrameEditBoxTemplate(textbox)

        return textbox
    end
    function PanelPrototype:CreateSlider(text, low, high, step, framewidth)
        local slider = backup.CreateSlider(self, text, low, high, step, framewidth)
        Skin.OptionsSliderTemplate(slider)
        slider.myheight = Scale.Value(50)
        slider:SetWidth(framewidth or 180)

        return slider
    end
    function PanelPrototype:CreateButton(title, width, height, onclick, FontObject)
        local button = backup.CreateButton(self, title, width, height, onclick, FontObject)
        Skin.DBM_GUI_OptionsFramePanelButtonTemplate(button)
        button:SetWidth(width or 100)
        button:SetHeight(height or 20)

        local buttonName = button:GetName()
        if _G[buttonName.."Text"]:GetStringWidth() > button:GetWidth() then
            Scale.RawSetWidth(button, _G[buttonName.."Text"]:GetStringWidth() + Scale.Value(25))
        end

        return button
    end
    function PanelPrototype:CreateText(text, width, autoplaced, style, justify)
        local textblock = backup.CreateText(self, text, width, autoplaced, style, justify)

        if width then
            textblock:SetWidth(width or 100)
        else
            Scale.RawSetWidth(textblock, self.frame:GetWidth())
        end

        return textblock
    end
    function PanelPrototype:AutoSetDimension()
        if not self.frame.mytype == "area" then return end
        local need_height = Scale.Value(25)

        local kids = {self.frame:GetChildren()}
        for _, child in next, kids do
            if child.myheight and type(child.myheight) == "number" then
                need_height = need_height + child.myheight
            else
                need_height = need_height + child:GetHeight()
            end
        end

        self.frame.myheight = need_height + Scale.Value(20)
        Scale.RawSetHeight(self.frame, need_height)
    end
    function PanelPrototype:SetMyOwnHeight()
        if not self.frame.mytype == "panel" then return end

        local need_height = Scale.Value(self.initheight or 20)

        local kids = { self.frame:GetChildren() }
        for _, child in next, kids do
            if child.mytype == "area" and child.myheight then
                need_height = need_height + child.myheight
            elseif child.mytype == "area" then
                need_height = need_height + child:GetHeight() + Scale.Value(20)
            elseif child.myheight then
                need_height = need_height + child.myheight
            end
        end

        --[[
            HACK: work-around for some strange bug, panels that are overriden (e.g. stats panels when
            the mod is loaded) are behaving strange since 4.1. GetHeight() will always return the
            height of the old panel and not of the new...
        ]]
        self.frame.actualHeight = need_height
        Scale.RawSetHeight(self.frame, need_height)
    end
    function Hook.DBM_GUI_OptionsFrame_ShowTab(self, tab) -- Defined in XML... smh
        local tabPrefix = self:GetName().."Tab"
        if tab == 1 then
            _G[tabPrefix..1]:SetNormalFontObject("GameFontHighlightSmall")
            _G[tabPrefix..2]:SetNormalFontObject("GameFontNormalSmall")
        else
            _G[tabPrefix..1]:SetNormalFontObject("GameFontNormalSmall")
            _G[tabPrefix..2]:SetNormalFontObject("GameFontHighlightSmall")
        end
    end
    function Hook.DBM_GUI_OptionsFrame_DisplayButton(self, button, element)
        if not button._auroraSkinned then
            Skin.DBM_GUI_FrameButtonTemplate(button)

            if element.haschilds then
                if not element.showsub then
                    button.toggle._auroraBG.plus:Show()
                else
                    button.toggle._auroraBG.plus:Hide()
                end
            end
            button._auroraSkinned = true
        end
    end
    function Hook.DBM_GUI_OptionsFrame_DisplayFrame(self, frame, forcechange)
        local container = _G[self:GetName().."PanelContainer"]
        local changed = forcechange or (container.displayedFrame ~= frame)

        --Hook.PanelPrototype_SetMyOwnHeight(self, frame)
        local mymax = (frame.actualHeight or frame:GetHeight()) - container:GetHeight()

        local frameName = container:GetName()
        if mymax <= 0 then
            _G[frameName.."FOV"]:Hide()
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", container ,"TOPLEFT", 5, -5)
            frame:SetPoint("BOTTOMRIGHT", container ,"BOTTOMRIGHT", -5, 5)

            for i=1, select("#", frame:GetChildren()), 1 do
                local child = select(i, frame:GetChildren())
                if child.mytype == "area" then
                    child:SetPoint("RIGHT", frame, -5, 0)
                end
            end
        else
            _G[frameName.."FOV"]:Show()
            _G[frameName.."FOV"]:SetScrollChild(frame)
            _G[frameName.."FOVScrollBar"]:SetMinMaxValues(0, mymax)
            if changed then
                _G[frameName.."FOVScrollBar"]:SetValue(0) -- scroll to top, and ensure widget appears
            end

            for i=1, select("#", frame:GetChildren()), 1 do
                local child = select(i, frame:GetChildren())
                if child.mytype == "area" then
                    child:SetPoint("RIGHT", _G[frameName.."FOVScrollBar"], "LEFT", -5, 0)
                end
            end
        end
    end
end
do --[[ AddOns\DBM-GUI\DBM-GUI_Dropdown.lua ]]
    local MAX_BUTTONS = 10
    local FrameTitle = "DBM_GUI_DropDown"
    local check = _G.CreateAtlasMarkup("Tracker-Check", 16, 16, -2, 0)
    function Hook.DBM_GUI_DropDown_ShowMenu(self, values)
        local buttons = values[1].font and self.fontbuttons or self.buttons

        if #values > MAX_BUTTONS then
            Scale.RawSetHeight(self, MAX_BUTTONS * buttons[1]:GetHeight() + Scale.Value(24))
            self.text:Show()
        elseif #values == MAX_BUTTONS then
            Scale.RawSetHeight(self, MAX_BUTTONS * buttons[1]:GetHeight() + Scale.Value(24))
            self.text:Hide()
        elseif #values < MAX_BUTTONS then
            Scale.RawSetHeight(self, #values * buttons[1]:GetHeight() + Scale.Value(24))
            self.text:Hide()
        end

        for i=1, MAX_BUTTONS, 1 do
            local button = buttons[i]
            if i + self.offset <= #values then
                local entry = values[i+self.offset]
                local fontStr = _G[button:GetName().."NormalText"]

                local text = entry.text
                if entry.value == self.dropdown.value then
                    text = check..text
                    fontStr:SetPoint("LEFT", 0, 0)
                else
                    fontStr:SetPoint("LEFT", 13, 0)
                end

                button:SetText(text)
                button.entry = entry
                button:Show()
            else
                button:Hide()
            end
        end

        local width, bwidth = 0
        for k, button in next, buttons do
            bwidth = button:GetTextWidth()
            if bwidth > width then
                Scale.RawSetWidth(self, bwidth + Scale.Value(32))
                width = bwidth
            end
        end
        for k, button in next, buttons do
            Scale.RawSetWidth(button, width)
        end
    end
    function Hook.DBM_GUI_CreateDropdown(self, title, values, vartype, var, callfunc, width, height, parent)
        local dropdown = _G[FrameTitle..self:GetCurrentID()]
        Skin.DBM_GUI_DropDownMenuTemplate(dropdown)

        local text = _G[dropdown:GetName().."Text"]
        if not width then
            width = Scale.Value(120) -- minimum size
            if title ~= _G.DBM_GUI_Translations.Warn_FontType then --Force font menus to always be fixed 120 width
                for i, v in ipairs(values) do
                    text:SetText(v.text)
                    width = math.max(width, text:GetStringWidth())
                end
            end
        else
            width = Scale.Value(width)
        end

        Scale.RawSetWidth(dropdown, width + Scale.Value(30))   -- required to fix some setpoint problems
        dropdown:SetHeight(height or 32)

        Scale.RawSetWidth(text, width + Scale.Value(30))   -- required to fix some setpoint problems
        Scale.RawSetWidth(_G[dropdown:GetName().."Middle"], width + Scale.Value(30))   -- required to fix some setpoint problems
    end
    function Hook.DBM_GUI_DropDownMenuButton_SetText(self, text)
        if not self._settingText then
            self._settingText = true
            local parent = self:GetParent()
            local values = parent.dropdown.values
            local entry = values[self:GetID()+parent.offset]
            local ind = "     "
            if entry.value == parent.dropdown.value then
                ind = _G.CreateAtlasMarkup("Tracker-Check", 16, 16, -2, 0)
            end
            self:SetText(ind..entry.text)
            self._settingText = false
        end
    end
end

do --[[ AddOns\DBM-GUI\DBM-GUI_Templates.xml ]]
    function Skin.DBMOptionsBaseCheckButtonTemplate(checkbutton)
        local bd = _G.CreateFrame("Frame", nil, checkbutton)
        bd:SetPoint("TOPLEFT", 6, -6)
        bd:SetPoint("BOTTOMRIGHT", -6, 6)
        bd:SetFrameLevel(checkbutton:GetFrameLevel())
        Base.SetBackdrop(bd, Color.frame)

        checkbutton:SetNormalTexture("")
        checkbutton:SetPushedTexture("")
        checkbutton:SetHighlightTexture("")

        local check = checkbutton:GetCheckedTexture()
        check:ClearAllPoints()
        check:SetPoint("TOPLEFT", bd, -7, 7)
        check:SetPoint("BOTTOMRIGHT", bd, 7, -7)
        check:SetDesaturated(true)
        check:SetVertexColor(Color.highlight:GetRGB())

        local disabled = checkbutton:GetDisabledCheckedTexture()
        disabled:ClearAllPoints()
        disabled:SetPoint("TOPLEFT", -7, 7)
        disabled:SetPoint("BOTTOMRIGHT", 7, -7)

        checkbutton._auroraBDFrame = bd
        Base.SetHighlight(checkbutton, "backdrop")

        --[[ Scale ]]--
        checkbutton:SetSize(checkbutton:GetSize())
    end
    function Skin.DBMOptionsCheckButtonTemplate(button)
        Skin.DBMOptionsBaseCheckButtonTemplate(button)
    end
    function Skin.DBM_GUI_OptionsFramePanelButtonTemplate(button)
        button.Left:SetAlpha(0)
        button.Right:SetAlpha(0)
        button.Middle:SetAlpha(0)
        button:SetHighlightTexture("")

        Base.SetBackdrop(button, Color.button)
        Base.SetHighlight(button, "backdrop")
    end
    function Skin.DBM_GUI_OptionsFrameTabButtonTemplate(button)
        local name = button:GetName()
        _G[name.."LeftDisabled"]:SetAlpha(0)
        _G[name.."MiddleDisabled"]:SetAlpha(0)
        _G[name.."RightDisabled"]:SetAlpha(0)
        _G[name.."Left"]:SetAlpha(0)
        _G[name.."Middle"]:SetAlpha(0)
        _G[name.."Right"]:SetAlpha(0)

        --[[ Scale ]]--
        button:SetSize(button:GetSize())
    end
    function Skin.DBM_GUI_PanelScrollBarTemplate(slider)
        local name = slider:GetName()
        Skin.UIPanelScrollUpButtonTemplate(_G[name.."ScrollUpButton"])
        Skin.UIPanelScrollUpButtonTemplate(_G[name.."ScrollDownButton"])

        local ThumbTexture = _G[name.."ThumbTexture"]
        ThumbTexture:SetAlpha(0)
        ThumbTexture:SetSize(17, 24)

        local thumb = _G.CreateFrame("Frame", nil, slider)
        thumb:SetPoint("TOPLEFT", ThumbTexture, 0, -2)
        thumb:SetPoint("BOTTOMRIGHT", ThumbTexture, 0, 2)
        Base.SetBackdrop(thumb, Color.button)
        slider._auroraThumb = thumb

        --[[ Scale ]]--
        slider:SetWidth(slider:GetWidth())
    end
    function Skin.DBM_GUI_OptionsFrameListTemplate(frame)
        local name = frame:GetName()
        _G[name.."TopLeft"]:Hide()
        _G[name.."TopRight"]:Hide()

        _G[name.."BottomLeft"]:Hide()
        _G[name.."BottomRight"]:Hide()

        _G[name.."Top"]:Hide()
        _G[name.."Bottom"]:Hide()
        _G[name.."Left"]:Hide()
        _G[name.."Right"]:Hide()

        _G[name.."List"]:SetBackdrop(nil)
        Skin.DBM_GUI_PanelScrollBarTemplate(_G[name.."ListScrollBar"])
    end
    function Skin.DBM_GUI_FrameButtonTemplate(button)
        button.toggle.Left:SetAlpha(0)
        button.toggle.Right:SetAlpha(0)
        button.toggle.Middle:SetAlpha(0)
        button.toggle:GetPushedTexture():SetAlpha(0)
        button.toggle:SetNormalTexture("")

        Skin.ExpandOrCollapse(button.toggle)

        --[[ Scale ]]--
        button:SetSize(185, 18)
        button.toggle:SetSize(button.toggle:GetSize())
    end
    function Skin.DBM_GUI_FrameEditBoxTemplate(editbox)
        local name = editbox:GetName()
        local left = _G[name.."Left"]
        local middle = _G[name.."Middle"]
        local right = _G[name.."Right"]
        left:Hide()
        middle:Hide()
        right:Hide()

        local bg = _G.CreateFrame("Frame", nil, editbox)
        bg:SetPoint("TOPLEFT", left)
        bg:SetPoint("BOTTOMRIGHT", right)
        bg:SetFrameLevel(editbox:GetFrameLevel() - 1)
        Base.SetBackdrop(bg, Color.frame)
    end
end
do --[[ AddOns\DBM-GUI\DBM-GUI_Dropdown.xml ]]
    function Skin.DBM_GUI_DropDownMenuTemplate(frame)
        local name = frame:GetName()

        local left = _G[name.."Left"]
        local middle = _G[name.."Middle"]
        local right = _G[name.."Right"]
        left:SetAlpha(0)
        middle:SetAlpha(0)
        right:SetAlpha(0)

        local button = _G[name.."Button"]
        button:SetSize(20, 20)
        button:ClearAllPoints()
        button:SetPoint("TOPRIGHT", right, -19, -21)

        button:SetNormalTexture("")
        button:SetPushedTexture("")
        button:SetHighlightTexture("")

        local disabled = button:GetDisabledTexture()
        disabled:SetAllPoints(button)
        disabled:SetColorTexture(0, 0, 0, .3)
        disabled:SetDrawLayer("OVERLAY")
        Base.SetBackdrop(button, Color.button)

        local arrow = button:CreateTexture(nil, "ARTWORK")
        arrow:SetPoint("TOPLEFT", 4, -7)
        arrow:SetPoint("BOTTOMRIGHT", -4, 7)
        Base.SetTexture(arrow, "arrowDown")

        button._auroraHighlight = {arrow}
        Base.SetHighlight(button, "texture")

        local bg = _G.CreateFrame("Frame", nil, frame)
        bg:SetPoint("TOPLEFT", left, 20, -21)
        bg:SetPoint("BOTTOMRIGHT", right, -19, 23)
        bg:SetFrameLevel(frame:GetFrameLevel())
        Base.SetBackdrop(bg, Color.button)

        --[[ Scale ]]--
        frame:SetSize(160, 32)

        left:SetSize(25, 64)
        left:SetPoint("TOPLEFT", 0, 17)
        middle:SetSize(155, 64)
        right:SetSize(25, 64)

        _G[name.."Text"]:SetPoint("LEFT", left, 30, 2)
    end
    function Skin.DBM_GUI_DropDownMenuButtonTemplate(button)
        local listFrame = button:GetParent()
        local menuButtonName = button:GetName()

        local highlight = _G[menuButtonName.."Highlight"]
        highlight:ClearAllPoints()
        highlight:SetPoint("LEFT", listFrame, 1, 0)
        highlight:SetPoint("RIGHT", listFrame, -1, 0)
        highlight:SetPoint("TOP", 0, 0)
        highlight:SetPoint("BOTTOM", 0, 0)
        highlight:SetColorTexture(Color.highlight.r, Color.highlight.g, Color.highlight.b, .2)

        --_G.hooksecurefunc(button, "SetText", Hook.DBM_GUI_DropDownMenuButton_SetText)

        --[[ Scale ]]--
        button:SetSize(100, 16)
        _G[menuButtonName.."NormalText"]:SetPoint("LEFT", 5, 0)
    end
end

private.AddOns["DBM-GUI"] = function()
    ----====####$$$$%%%%$$$$####====----
    --             DBM-GUI            --
    ----====####$$$$%%%%$$$$####====----
    _G.hooksecurefunc(_G.DBM_GUI, "CreateNewPanel", Hook.DBM_GUI_CreateNewPanel)
    _G.hooksecurefunc(_G.DBM_GUI_OptionsFrame, "ShowTab", Hook.DBM_GUI_OptionsFrame_ShowTab)
    _G.hooksecurefunc(_G.DBM_GUI_OptionsFrame, "DisplayButton", Hook.DBM_GUI_OptionsFrame_DisplayButton)
    _G.hooksecurefunc(_G.DBM_GUI_OptionsFrame, "DisplayFrame", Hook.DBM_GUI_OptionsFrame_DisplayFrame)

    Base.SetBackdrop(_G.DBM_GUI_OptionsFrame)
    _G.DBM_GUI_OptionsFrameHeader:SetTexture("")

    Skin.UIPanelButtonTemplate(_G.DBM_GUI_OptionsFrameOkay)
    Skin.UIPanelButtonTemplate(_G.DBM_GUI_OptionsFrameWebsiteButton)
    Skin.DBM_GUI_OptionsFrameListTemplate(_G.DBM_GUI_OptionsFrameBossMods)
    Skin.DBM_GUI_OptionsFrameListTemplate(_G.DBM_GUI_OptionsFrameDBMOptions)
    Base.SetBackdrop(_G.DBM_GUI_OptionsFramePanelContainer, Color.frame)
    Skin.DBM_GUI_PanelScrollBarTemplate(_G.DBM_GUI_OptionsFramePanelContainerFOVScrollBar)
    Skin.DBM_GUI_OptionsFrameTabButtonTemplate(_G.DBM_GUI_OptionsFrameTab1)
    Skin.DBM_GUI_OptionsFrameTabButtonTemplate(_G.DBM_GUI_OptionsFrameTab2)

    --[[ Scale ]]--
    _G.DBM_GUI_OptionsFrame:SetSize(800, 510)

    _G.DBM_GUI_OptionsFrameHeaderText:SetPoint("TOP", 0, -2)
    _G.DBM_GUI_OptionsFrameRevision:SetPoint("BOTTOMLEFT", 20, 18)
    _G.DBM_GUI_OptionsFrameTranslation:SetPoint("LEFT", _G.DBM_GUI_OptionsFrameRevision, "RIGHT", 20, 0)
    _G.DBM_GUI_OptionsFrameWebsite:SetPoint("BOTTOMLEFT", _G.DBM_GUI_OptionsFrameRevision, "TOPLEFT", 0, 15)

    _G.DBM_GUI_OptionsFrameOkay:SetPoint("BOTTOMRIGHT", -16, 14)
    _G.DBM_GUI_OptionsFrameWebsiteButton:SetPoint("BOTTOMRIGHT", _G.DBM_GUI_OptionsFrameOkay, "BOTTOMLEFT", -20, 0)
    _G.DBM_GUI_OptionsFrameBossMods:SetSize(205, 409)
    _G.DBM_GUI_OptionsFrameBossMods:SetPoint("TOPLEFT", 22, -40)
    _G.DBM_GUI_OptionsFrameDBMOptions:SetSize(205, 409)
    _G.DBM_GUI_OptionsFrameDBMOptions:SetPoint("TOPLEFT", 22, -40)

    _G.DBM_GUI_OptionsFramePanelContainer:SetPoint("TOPLEFT", _G.DBM_GUI_OptionsFrameDBMOptions, "TOPRIGHT", 16, 0)
    _G.DBM_GUI_OptionsFramePanelContainer:SetPoint("BOTTOMLEFT", _G.DBM_GUI_OptionsFrameDBMOptions, "BOTTOMRIGHT", 16, 0)
    _G.DBM_GUI_OptionsFramePanelContainer:SetPoint("RIGHT", -22, 0)
    _G.DBM_GUI_OptionsFramePanelContainerFOV:SetPoint("TOPLEFT", 5, -5)
    _G.DBM_GUI_OptionsFramePanelContainerFOV:SetPoint("BOTTOMRIGHT", -20, 7)
    _G.DBM_GUI_OptionsFramePanelContainerFOVScrollBar:SetPoint("TOPRIGHT", 15, -15)
    _G.DBM_GUI_OptionsFramePanelContainerFOVScrollBar:SetPoint("BOTTOMRIGHT", 15, 13)

    _G.DBM_GUI_OptionsFrameTab1:SetPoint("BOTTOMLEFT", _G.DBM_GUI_OptionsFrameBossMods, "TOPLEFT", 6, -3)
    _G.DBM_GUI_OptionsFrameTab2:SetPoint("TOPLEFT", _G.DBM_GUI_OptionsFrameTab1, "TOPRIGHT", -16, 0)

    ----====####$$$$%%%%$$$$####====----
    --        DBM-GUI_DropDown        --
    ----====####$$$$%%%%$$$$####====----
    _G.hooksecurefunc(_G.DBM_GUI_DropDown, "ShowMenu", Hook.DBM_GUI_DropDown_ShowMenu)
    _G.hooksecurefunc(_G.DBM_GUI_DropDown, "ShowFontMenu", Hook.DBM_GUI_DropDown_ShowMenu)
    _G.hooksecurefunc(_G.DBM_GUI, "CreateDropdown", Hook.DBM_GUI_CreateDropdown)

    Base.SetBackdrop(_G.DBM_GUI_DropDown)
    local MAX_BUTTONS = 10
    local buttonTable = {"buttons", "fontbuttons"}
    for i = 1, MAX_BUTTONS do
        for _, name in next, buttonTable do
            _G.DBM_GUI_DropDown[name][i]:SetID(i)
            Skin.DBM_GUI_DropDownMenuButtonTemplate(_G.DBM_GUI_DropDown[name][i])
        end
    end
end
