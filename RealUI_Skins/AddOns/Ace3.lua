local _, private = ...

-- Lua Globals --
-- luacheck: globals select next

-- [[ Core ]]
local Aurora = private.Aurora
local Base, Skin = Aurora.Base, Aurora.Skin
local Color = Aurora.Color

-- LibStub("AceConfigDialog-3.0").popup:Show()
local function SkinAceConfig()
    local AceCD = _G.LibStub("AceConfigDialog-3.0", true)
    if not AceCD then return end

    if AceCD.tooltip then
        Skin.GameTooltipTemplate(AceCD.tooltip)
    end
    if AceCD.popup then
        local popup = AceCD.popup
        Skin.DialogBorderDarkTemplate(popup:GetChildren())

        popup.accept:SetNormalTexture("")
        popup.accept:SetPushedTexture("")
        popup.accept:SetHighlightTexture("")
        Base.SetBackdrop(popup.accept, Color.button)
        Base.SetHighlight(popup.accept, "backdrop")

        popup.cancel:SetNormalTexture("")
        popup.cancel:SetPushedTexture("")
        popup.cancel:SetHighlightTexture("")
        Base.SetBackdrop(popup.cancel, Color.button)
        Base.SetHighlight(popup.cancel, "backdrop")
    end
end
local function SkinAceGUI()
    local AceGUI = _G.LibStub("AceGUI-3.0", true)
    if not AceGUI then return end

    local frameColor = Color.frame
    local highlightColor = Color.highlight

    if AceGUI.tooltip then
        Skin.GameTooltipTemplate(AceGUI.tooltip)
    end

    local containters = {
        BlizOptionsGroup = function(widget)
        end,
        DropdownGroup = function(widget)
            Base.SetBackdrop(widget.border, frameColor)
        end,
        Frame = function(widget)
            Base.SetBackdrop(widget.frame)

            -- Regions
            local regions = {widget.frame:GetRegions()}
            regions[1]:SetTexture("") -- titlebg
            regions[2]:SetTexture("") -- titlebg_l
            regions[3]:SetTexture("") -- titlebg_r

            -- Children
            local children = {widget.frame:GetChildren()}
            Skin.UIPanelButtonTemplate(children[1]) -- closebutton
            children[2]:SetBackdrop(nil) -- statusbg

            -- Sizer
            local line1, line2 = widget.sizer_se:GetRegions()
            line1:SetSize(2, 2)
            line1:SetColorTexture(highlightColor.r, highlightColor.g, highlightColor.b, .8)

            line2:SetSize(2, 2)
            line2:SetPoint("BOTTOMRIGHT", line1, "TOPRIGHT", 0, 4)
            line2:SetColorTexture(highlightColor.r, highlightColor.g, highlightColor.b, .8)

            local line3 = widget.sizer_se:CreateTexture(nil, "BACKGROUND")
            line3:SetSize(2, 2)
            line3:SetPoint("BOTTOMRIGHT", line1, "BOTTOMLEFT", -4, 0)
            line3:SetColorTexture(highlightColor.r, highlightColor.g, highlightColor.b, .8)
        end,
        InlineGroup = function(widget)
            Base.SetBackdrop(widget.content:GetParent(), frameColor)
        end,
        ScrollFrame = function(widget)
            Skin.UIPanelScrollBarTemplate(widget.scrollbar)
        end,
        SimpleGroup = function(widget)
        end,
        TabGroup = function(widget)
            local _CreateTab = widget.CreateTab
            function widget:CreateTab(id)
                local tab = _CreateTab(self, id)
                Skin.OptionsFrameTabButtonTemplate(tab)
                return tab
            end

            Base.SetBackdrop(widget.border, frameColor)
        end,
        TreeGroup = function(widget)
            local _CreateButton = widget.CreateButton
            function widget:CreateButton(...)
                local button = _CreateButton(self, ...)
                Skin.OptionsListButtonTemplate(button)
                return button
            end

            local options = widget.dragger:GetBackdrop()
            options.insets.top, options.insets.bottom = 0, 0
            widget.dragger:SetBackdrop(options)
            widget.dragger:SetBackdropColor(1, 1, 1, 0)
            widget.dragger:SetScript("OnEnter", function(self)
                self:SetBackdropColor(highlightColor.r, highlightColor.g, highlightColor.b, 0.8)
            end)

            Base.SetBackdrop(widget.treeframe, frameColor)
            Skin.UIPanelScrollBarTemplate(widget.scrollbar)
            Base.SetBackdrop(widget.border, frameColor)
            widget.border:SetPoint("TOPLEFT", widget.treeframe, "TOPRIGHT", 1, 0)
        end,
        Window = function(widget)
            -- /run LibStub("AceGUI-3.0"):Create("Window")
            Base.SetBackdrop(widget.frame)

            -- Regions
            local regions = {widget.frame:GetRegions()}
            regions[1]:SetTexture("") -- titlebg
            regions[2]:SetTexture("") -- dialogbg
            regions[3]:SetTexture("") -- topleft
            regions[4]:SetTexture("") -- topright
            regions[5]:SetTexture("") -- top
            regions[6]:SetTexture("") -- bottomleft
            regions[7]:SetTexture("") -- bottomright
            regions[8]:SetTexture("") -- bottom
            regions[9]:SetTexture("") -- left
            regions[10]:SetTexture("") -- right

            Skin.UIPanelCloseButton(widget.closebutton)
            widget.closebutton:SetPoint("TOPRIGHT", -3, -3)

            -- Sizer
            local line1, line2 = widget.sizer_se:GetRegions()
            line1:SetSize(2, 2)
            line1:SetColorTexture(highlightColor.r, highlightColor.g, highlightColor.b, .8)

            line2:SetSize(2, 2)
            line2:SetPoint("BOTTOMRIGHT", line1, "TOPRIGHT", 0, 4)
            line2:SetColorTexture(highlightColor.r, highlightColor.g, highlightColor.b, .8)

            local line3 = widget.sizer_se:CreateTexture(nil, "BACKGROUND")
            line3:SetSize(2, 2)
            line3:SetPoint("BOTTOMRIGHT", line1, "BOTTOMLEFT", -4, 0)
            line3:SetColorTexture(highlightColor.r, highlightColor.g, highlightColor.b, .8)
        end,
    }
    local oldRegisterAsContainer = AceGUI.RegisterAsContainer
    AceGUI.RegisterAsContainer = function(gui, widget)
        if not widget.skinned then
            if containters[widget.type] then
                containters[widget.type](widget)
            else
                private.debug("Missing Ace3 containter:", widget.type)
            end
            widget.skinned = true
        end
        return oldRegisterAsContainer(gui, widget)
    end


    local widgets
    widgets = {
        -- AceGUI
            Button = function(widget)
                Skin.UIPanelButtonTemplate(widget.frame)
            end,
            CheckBox = function(widget)
                local bg = _G.CreateFrame("Button", nil, widget.frame)
                bg.obj = widget

                function widget:SetDisabled(disabled)
                    self.disabled = disabled
                    if disabled then
                        bg:Disable()
                        self.frame:Disable()
                        self.text:SetTextColor(0.5, 0.5, 0.5)
                        self.check:SetVertexColor(1, 1, 1)
                        if self.desc then
                            self.desc:SetTextColor(0.5, 0.5, 0.5)
                        end
                    else
                        bg:Enable()
                        self.frame:Enable()
                        self.text:SetTextColor(1, 1, 1)
                        if self.tristate and self.checked == nil then
                            self.check:SetVertexColor(1, 1, 1)
                        else
                            self.check:SetVertexColor(highlightColor:GetRGB())
                        end
                        if self.desc then
                            self.desc:SetTextColor(1, 1, 1)
                        end
                    end
                end
                function widget:SetValue(value)
                    local check = self.check
                    self.checked = value
                    check:SetDesaturated(true)
                    if value then
                        check:SetVertexColor(highlightColor:GetRGB())
                        check:Show()
                    else
                        --Nil is the unknown tristate value
                        if self.tristate and value == nil then
                            check:SetVertexColor(1, 1, 1)
                            check:Show()
                        else
                            check:SetVertexColor(highlightColor:GetRGB())
                            check:Hide()
                        end
                    end
                    self:SetDisabled(self.disabled)
                end
                function widget:SetType(type)
                    local check = self.check
                    if type == "radio" then
                        bg:SetSize(18, 18)
                        bg:SetPoint("TOPLEFT", 3, -3)

                        check:SetSize(18, 18)
                        check:SetTexture(private.textures.plain)
                        check:SetBlendMode("ADD")
                    else
                        bg:SetSize(18, 18)
                        bg:SetPoint("TOPLEFT", 3, -3)

                        check:SetSize(32, 32)
                        check:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
                        check:SetBlendMode("BLEND")
                    end
                end

                bg:SetScript("OnEnter", function(self, ...) end)
                bg:SetScript("OnLeave", function(self, ...) end)
                bg:SetScript("OnMouseDown", widget.frame:GetScript("OnMouseDown"))
                bg:SetScript("OnMouseUp", widget.frame:GetScript("OnMouseUp"))
                Base.SetBackdrop(bg, Color.button, 0.3)
                Base.SetHighlight(bg, "backdrop")

                widget.checkbg:SetTexture("")
                widget.highlight:SetTexture("")

                local check = widget.check
                check:SetParent(bg)
                check:ClearAllPoints()
                check:SetPoint("CENTER")
                check:SetDesaturated(true)
                check:SetVertexColor(highlightColor:GetRGB())
            end,
            ColorPicker = function(widget)
                local bg = _G.CreateFrame("Button", nil, widget.frame)
                bg.obj = widget

                function widget:SetColor(r, g, b, a)
                    self.r = r
                    self.g = g
                    self.b = b
                    self.a = a or 1
                    bg:SetBackdropColor(r, g, b, a)
                end
                function widget:SetDisabled(disabled)
                    self.disabled = disabled
                    if disabled then
                        bg:Disable()
                        self.frame:Disable()
                        self.text:SetTextColor(0.5, 0.5, 0.5)
                    else
                        bg:Enable()
                        self.frame:Enable()
                        self.text:SetTextColor(1, 1, 1)
                    end
                end

                bg:SetSize(18, 18)
                bg:SetPoint("TOPLEFT", 1, -3)
                bg:SetScript("OnClick", widget.frame:GetScript("OnClick"))
                Base.SetBackdrop(bg, frameColor)

                widget.colorSwatch:Hide()
                widget.colorSwatch.background:Hide()
                widget.colorSwatch.checkers:SetAllPoints(bg)
                widget.colorSwatch.checkers:SetDrawLayer("BACKGROUND")
            end,
            ["Dropdown-Item"] = function(widget)
                local highlight = widget.highlight
                highlight:SetColorTexture(highlightColor.r, highlightColor.g, highlightColor.b, .2)
                highlight:ClearAllPoints()
                highlight:SetPoint("TOPLEFT", -6, 0)
                highlight:SetPoint("BOTTOMRIGHT", 0, 0)
            end,
            ["Dropdown-Item-Header"] = function(widget)
                widgets["Dropdown-Item"](widget)
            end,
            ["Dropdown-Item-Execute"] = function(widget)
                widgets["Dropdown-Item"](widget)
            end,
            ["Dropdown-Item-Toggle"] = function(widget)
                widgets["Dropdown-Item"](widget)

                local check = widget.check
                check:SetDesaturated(true)
                check:SetVertexColor(highlightColor.r, highlightColor.g, highlightColor.b, .8)
                check:SetPoint("LEFT", 0, 0)
            end,
            ["Dropdown-Item-Menu"] = function(widget)
                widgets["Dropdown-Item"](widget)
            end,
            ["Dropdown-Item-Separator"] = function(widget)
                widgets["Dropdown-Item"](widget)
            end,
            ["Dropdown-Pullout"] = function(widget)
                Base.SetBackdrop(widget.frame)

                local scrollFrame = widget.scrollFrame
                scrollFrame:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 1, -12)
                scrollFrame:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -1, 12)

                local itemFrame = widget.itemFrame
                itemFrame:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 6, 0)
                itemFrame:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -12, 0)

                Skin.OptionsSliderTemplate(widget.slider)
                widget.slider:GetThumbTexture():SetSize(16, 16)
            end,
            Dropdown = function(widget)
                Skin.UIDropDownMenuTemplate(widget.dropdown)
                widget.dropdown:SetBackdropOption("offsets", {
                    left = 21,
                    right = 20,
                    top = 5,
                    bottom = 3,
                })
            end,
            EditBox = function(widget)
                Skin.InputBoxTemplate(widget.editbox)
                Skin.UIPanelButtonTemplate(widget.button)
            end,
            Heading = function(widget)
                local left = widget.left
                left:SetHeight(1)
                left:SetColorTexture(highlightColor.r, highlightColor.g, highlightColor.b, .4)

                local right = widget.right
                right:SetHeight(1)
                right:SetColorTexture(highlightColor.r, highlightColor.g, highlightColor.b, .4)
            end,
            Icon = function(widget)
                function widget:SetImage(path, ...)
                    local image = self.image
                    image:SetTexture(path)

                    if image:GetTexture() then
                        local n = select("#", ...)
                        if n == 4 or n == 8 then
                            image:SetTexCoord(...)
                        else
                            image:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                        end
                    end
                end
            end,
            InteractiveLabel = function(widget)
            end,
            Keybinding = function(widget)
                Skin.UIPanelButtonTemplate(widget.button)
            end,
            Label = function(widget)
            end,
            MultiLineEditBox = function(widget)
                Skin.UIPanelButtonTemplate(widget.button)
                Skin.UIPanelScrollBarTemplate(widget.scrollBar)
                Base.SetBackdrop(widget.scrollBG, frameColor)
                widget.scrollBG:SetPoint("TOPRIGHT", widget.scrollBar, "TOPLEFT", -3, 19)
            end,
            Slider = function(widget)
                Skin.OptionsSliderTemplate(widget.slider)
            end,

        -- Custom
            NumberEditBox = function(widget)
                Skin.InputBoxTemplate(widget.editbox)
                Skin.UIPanelButtonTemplate(widget.button)
                Skin.UIPanelButtonTemplate(widget.minus)
                Skin.UIPanelButtonTemplate(widget.plus)
            end,
            SearchEditBox = function(widget)
                Skin.InputBoxTemplate(widget.editbox)
                Skin.UIPanelButtonTemplate(widget.button)
                Base.SetBackdrop(widget.predictor, frameColor)
            end,

        -- LibSharedMedia
            LSM30 = function(widget)
                local frame = widget.frame

                frame.DLeft:SetAlpha(0)
                frame.DRight:SetAlpha(0)
                frame.DMiddle:SetAlpha(0)

                local button = frame.dropButton
                button:SetSize(18, 18)
                button:ClearAllPoints()
                button:SetPoint("TOPRIGHT", frame.DRight, -19, -21)

                button:SetNormalTexture("")
                button:SetPushedTexture("")
                button:SetHighlightTexture("")

                local disabled = button:GetDisabledTexture()
                disabled:SetColorTexture(0, 0, 0, .3)
                disabled:SetDrawLayer("OVERLAY")
                Base.SetBackdrop(button, Aurora.Color.button)

                local arrow = button:CreateTexture(nil, "ARTWORK")
                arrow:SetPoint("TOPLEFT", 4, -7)
                arrow:SetPoint("BOTTOMRIGHT", -5, 6)
                Base.SetTexture(arrow, "arrowDown")

                button._auroraHighlight = {arrow}
                Base.SetHighlight(button, "texture")

                local bg = _G.CreateFrame("Frame", nil, frame)
                bg:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", 1, 0)
                bg:SetFrameLevel(frame:GetFrameLevel())
                Base.SetBackdrop(bg, Aurora.Color.button)

                if frame.displayButton then
                    bg:SetPoint("TOPLEFT", frame.displayButton, "TOPRIGHT", 3, -19)
                else
                    bg:SetPoint("TOPLEFT", 5, -22)
                end
            end,
            LSM30_Background = function(widget)
                widgets.LSM30(widget)
            end,
            LSM30_Border = function(widget)
                widgets.LSM30(widget)
            end,
            LSM30_Font = function(widget)
                widgets.LSM30(widget)
            end,
            LSM30_Sound = function(widget)
                widgets.LSM30(widget)
            end,
            LSM30_Statusbar = function(widget)
                widgets.LSM30(widget)
            end,

        -- WeakAuras
            WeakAuras = function(widget)
                local bg = widget.background or widget.frame.background -- adjust for BS
                bg:SetColorTexture(1, 1, 1, 0.4)
                widget.frame.highlight:SetColorTexture(highlightColor.r, highlightColor.g, highlightColor.b, frameColor.a)
            end,
            WeakAurasDisplayButton = function(widget)
                widgets.WeakAuras(widget)
                Skin.InputBoxTemplate(widget.renamebox)
                Skin.ExpandOrCollapse(widget.expand)
            end,
            WeakAurasIconButton = function(widget)
            end,
            WeakAurasImportButton = function(widget)
            end,
            WeakAurasLoadedHeaderButton = function(widget)
                widgets.WeakAuras(widget)
                Skin.ExpandOrCollapse(widget.expand)
            end,
            WeakAurasMultiLineEditBox = function(widget)
            end,
            WeakAurasNewButton = function(widget)
                widgets.WeakAuras(widget)
            end,
            WeakAurasNewHeaderButton = function(widget)
                widgets.WeakAuras(widget)
            end,
            WeakAurasSortedDropdown = function(widget)
            end,
            WeakAurasTextureButton = function(widget)
            end,
    }
    local oldRegisterAsWidget = AceGUI.RegisterAsWidget
    AceGUI.RegisterAsWidget = function(gui, widget)
        if not widget.skinned then
            if widgets[widget.type] then
                widgets[widget.type](widget)
            else
                private.debug("Missing Ace3 widget:", widget.type)
            end
            widget.skinned = true
        end
        return oldRegisterAsWidget(gui, widget)
    end
end

function private.AddOns.Ace3()
    SkinAceConfig()
    SkinAceGUI()
end
