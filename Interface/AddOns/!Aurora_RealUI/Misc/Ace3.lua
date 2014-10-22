local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local F, C

local _
local MODNAME = "SkinAce3"
local SkinAce3 = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local HiddenFrame = CreateFrame("Frame", nil, UIParent)
HiddenFrame:Hide()

local function Kill(object)
    if object.UnregisterAllEvents then
        object:UnregisterAllEvents()
        object:SetParent(HiddenFrame)
    else
        object.Show = function() end
    end
    object:Hide()
end

local function StripTextures(object, kill)
    for i=1, object:GetNumRegions() do
        local region = select(i, object:GetRegions())
        if region:GetObjectType() == "Texture" then
            if kill then
                region:Kill()
            else
                region:SetTexture(nil)
            end
        end
    end
end

local function skinLSM30(frame)
    frame.DLeft:SetAlpha(0)
    frame.DMiddle:SetAlpha(0)
    frame.DRight:SetAlpha(0)

    local bg = CreateFrame("Frame", nil, frame)
    bg:SetPoint("TOPLEFT", 0, -18)
    bg:SetPoint("BOTTOMRIGHT", 0, 6)
    bg:SetFrameLevel(frame:GetFrameLevel()-1)
    F.CreateBD(bg, 0)
    F.CreateGradient(bg)
    frame.bg = bg

    frame.dropButton:SetParent(frame.bg)
    frame.dropButton:SetSize(20, 20)
    frame.dropButton:ClearAllPoints()
    frame.dropButton:SetPoint("BOTTOMRIGHT", frame.bg, 0, 0)

    F.Reskin(frame.dropButton, true)

    frame.dropButton:SetDisabledTexture(C.media.backdrop)
    local dis = frame.dropButton:GetDisabledTexture()
    dis:SetVertexColor(0, 0, 0, .4)
    dis:SetDrawLayer("OVERLAY")
    dis:SetAllPoints()

    local tex = frame.dropButton:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(C.media.arrowDown)
    tex:SetSize(8, 8)
    tex:SetPoint("CENTER")
    tex:SetVertexColor(1, 1, 1)
    frame.dropButton.tex = tex

    frame.dropButton:HookScript("OnEnter", F.colourArrow)
    frame.dropButton:HookScript("OnLeave", F.clearArrow)

    frame.text:ClearAllPoints()
    frame.text:SetPoint("LEFT", frame.bg, 0, 0)
    frame.text:SetPoint("RIGHT", frame.bg, -25, 0)
end

function SkinAce3:Skin()
    local AceGUI = LibStub("AceGUI-3.0", true)
    if not AceGUI then return end
    F, C = unpack(Aurora)

    local r, g, b = nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3]

    local oldRegisterAsWidget = AceGUI.RegisterAsWidget
    AceGUI.RegisterAsWidget = function(self, widget)
        local TYPE = widget.type
        local _, TYPE2, TYPE3 = strsplit("-", TYPE)
        local _, LSMTYPE = strsplit("_", TYPE)
        --print("Widget:", TYPE)
        --print("Subtype", TYPE2 or LSMTYPE, TYPE3)

        if TYPE == "Button" then
            if not widget.skinned then
                F.Reskin(widget.frame)
                widget.skinned = true
            end

        elseif TYPE == "CheckBox" then
            if not widget.skinned then
                widget["SetType"] = function(self, type)
                    local checkbg = self.checkbg
                    local check = self.check
                    local highlight = self.highlight

                    local size
                    if type == "radio" then
                        size = 18
                        checkbg:SetTexture("")
                        check:SetTexture(nibRealUI.media.textures.plain)
                        check:SetBlendMode("ADD")
                        check:SetAllPoints(self.bg)
                        highlight:SetTexture(nibRealUI.media.textures.plain)
                    else
                        size = 24
                        checkbg:SetTexture("")
                        check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                        check:SetBlendMode("BLEND")
                        check:SetAllPoints(checkbg)
                        highlight:SetTexture(nibRealUI.media.textures.plain)
                    end
                    checkbg:SetHeight(size)
                    checkbg:SetWidth(size)
                    highlight:SetPoint("TOPLEFT", self.bg, 1, -1)
                    highlight:SetPoint("BOTTOMRIGHT", self.bg, -1, 1)
                    highlight:SetVertexColor(r, g, b, .2)
                end
                widget["SetDisabled"] = function(self, disabled)
                    self.disabled = disabled
                    if disabled then
                        self.frame:Disable()
                        self.text:SetTextColor(0.5, 0.5, 0.5)
                        --SetDesaturation(self.check, true)
                        if self.desc then
                            self.desc:SetTextColor(0.5, 0.5, 0.5)
                        end
                    else
                        self.frame:Enable()
                        self.text:SetTextColor(1, 1, 1)
                        --[[if self.tristate and self.checked == nil then
                            SetDesaturation(self.check, true)
                        else
                            SetDesaturation(self.check, false)
                        end]]
                        if self.desc then
                            self.desc:SetTextColor(1, 1, 1)
                        end
                    end
                end
                widget["SetValue"] = function(self,value)
                    local check = self.check
                    self.checked = value
                    if value then
                        --SetDesaturation(self.check, false)
                        self.check:Show()
                    else
                        --Nil is the unknown tristate value
                        if self.tristate and value == nil then
                            --SetDesaturation(self.check, true)
                            self.check:Show()
                        else
                            --SetDesaturation(self.check, false)
                            self.check:Hide()
                        end
                    end
                    self:SetDisabled(self.disabled)
                end

                if not widget.bg then
                    widget.bg = F.CreateBDFrame(widget.checkbg)
                    widget.bg:SetPoint('TOPLEFT', widget.checkbg, 4, -4)
                    widget.bg:SetPoint('BOTTOMRIGHT', widget.checkbg, -4, 4)
                    local tex = F.CreateGradient(widget.bg)
                    widget.check:SetParent(widget.bg)
                end

                widget.check:SetDesaturated(true)
                widget.check:SetVertexColor(r, g, b)

                widget.skinned = true
            end

        elseif TYPE == "ColorPicker" then
            if not widget.skinned then
                F.CreateBDFrame(widget.colorSwatch)
                widget.colorSwatch:SetTexture(C.media.backdrop)
                widget.colorSwatch:SetSize(14, 14)
                local texture = select(2, widget.frame:GetRegions())
                texture:Hide()
                local checkers = select(3, widget.frame:GetRegions())
                checkers:SetDrawLayer("BORDER")
                widget.skinned = true
            end

        elseif TYPE == "Dropdown" then
            if not widget.skinned then
                F.ReskinDropDown(widget.dropdown)
                widget.dropdown:SetPoint("BOTTOMRIGHT", widget.frame, -2, -6)
                widget.button:ClearAllPoints()
                widget.button:SetPoint("TOPRIGHT", widget.dropdown, 1, -4)
                widget.text:ClearAllPoints()
                widget.text:SetPoint("LEFT", widget.dropdown, 0, 0)
                widget.text:SetPoint("RIGHT", widget.dropdown, -20, 0)
                widget.skinned = true
            end

        elseif TYPE2 == "Pullout" then
            if not widget.skinned then
                F.CreateBD(widget.frame)
                widget.skinned = true
            end

        elseif TYPE2 == "Item" then
            if not widget.skinned then
                widget.highlight:SetTexture(r, g, b, .2)
                widget.highlight:ClearAllPoints()
                widget.highlight:SetPoint("TOPLEFT", 0, 0)
                widget.highlight:SetPoint("BOTTOMRIGHT", 0, 0)

                if TYPE3 == "Toggle" then

                elseif TYPE3 == "Menu" then
                    --
                end
                widget.skinned = true
            end

        elseif TYPE == "EditBox" then
            if not widget.skinned then
                F.ReskinInput(widget.editbox)
                F.Reskin(widget.button)
                widget.skinned = true
            end

        elseif TYPE == "Slider" then
            if not widget.skinned then
                local frame = widget.slider
                local editbox = widget.editbox
                local lowtext = widget.lowtext
                local hightext = widget.hightext
                local HEIGHT = 12

                StripTextures(frame)
                F.CreateBD(frame, 0)
                frame:SetHeight(HEIGHT)
                F.CreateGradient(frame)

                local slider = frame:GetThumbTexture()
                slider:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
                slider:SetBlendMode("ADD")

                F.CreateBD(editbox, 0)
                editbox.SetBackdropColor = function() end
                editbox.SetBackdropBorderColor = function() end
                editbox:SetHeight(15)
                editbox:SetPoint("TOP", frame, "BOTTOM", 0, -1)
                F.CreateGradient(editbox)

                lowtext:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 2, -2)
                hightext:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -2, -2)

                widget.skinned = true
            end

        elseif LSMTYPE then
            if not widget.skinned then
                skinLSM30(widget.frame)

                if LSMTYPE == "Statusbar" then
                    widget.bar:ClearAllPoints()
                    widget.bar:SetPoint("TOPLEFT", widget.frame.bg, 2, -2)
                    widget.bar:SetPoint("BOTTOMRIGHT", widget.frame.bg, -21, 2)

                elseif LSMTYPE == "Background" then
                    widget.frame.bg:ClearAllPoints()
                    widget.frame.bg:SetPoint("BOTTOMLEFT", widget.frame.displayButton, "BOTTOMRIGHT", 2, 0)
                    widget.frame.bg:SetPoint("TOPRIGHT", -4, -24)

                elseif LSMTYPE == "Border" then
                    widget.frame.bg:ClearAllPoints()
                    widget.frame.bg:SetPoint("BOTTOMLEFT", widget.frame.displayButton, "BOTTOMRIGHT", 2, 0)
                    widget.frame.bg:SetPoint("TOPRIGHT", -4, -24)

                elseif LSMTYPE == "Font" then
                    --

                elseif LSMTYPE == "Sound" then
                    widget.soundbutton:ClearAllPoints()
                    widget.soundbutton:SetPoint("TOPLEFT", widget.frame.bg, 4, -2)
                end
                widget.skinned = true
            end
        end
        return oldRegisterAsWidget(self, widget)
    end

    local oldRegisterAsContainer = AceGUI.RegisterAsContainer
    AceGUI.RegisterAsContainer = function(self, widget)
        local TYPE = widget.type
        --print("Container:", TYPE)

        local frame = widget.content:GetParent()
        if TYPE == "DropdownGroup" then
            if not widget.skinned then
                F.CreateBD(frame, 0.4)
            end

        elseif TYPE == "Frame" then
            if not widget.skinned then
                -- Sizer
                local line1, line2 = widget.sizer_se:GetRegions()
                line1:SetSize(2, 2)
                line1:SetTexture(C.media.backdrop)
                line1:SetVertexColor(r, g, b, .8)

                line2:SetSize(2, 2)
                line2:SetPoint("BOTTOMRIGHT", line1, "TOPRIGHT", 0, 4)
                line2:SetTexture(C.media.backdrop)
                line2:SetVertexColor(r, g, b, .8)

                local line3 = widget.sizer_se:CreateTexture(nil, "BACKGROUND")
                line3:SetSize(2, 2)
                line3:SetPoint("BOTTOMRIGHT", line1, "BOTTOMLEFT", -4, 0)
                line3:SetTexture(C.media.backdrop)
                line3:SetVertexColor(r, g, b, .8)

                -- Skin Children
                local children = {frame:GetChildren()}
                F.Reskin(children[1]) -- Close button
                StripTextures(children[2]) -- Status bar

                -- Remove Title BG
                StripTextures(frame)

                -- StripTextures will actually remove the backdrop too, so we need to put that back
                F.CreateBD(frame)
            end

        elseif TYPE == "InlineGroup" then
            if not widget.skinned then
                F.CreateBD(frame, 0.4)
            end

        elseif TYPE == "TabGroup" then
            if not widget.skinned then
                local oldCreateTab = widget.CreateTab
                widget.CreateTab = function(self, id)
                    local tab = oldCreateTab(self, id)
                    StripTextures(tab)
                    return tab
                end
                F.CreateBD(frame, 0.4)
            end

        elseif TYPE == "TreeGroup" then
            if not widget.skinned then
                --print("TreeFrame!!!")
                hooksecurefunc(widget, "RefreshTree", function(self, ...)
                    --print("RefreshTree", self)
                    local buttons = self.buttons 
                    for i, v in next, buttons do
                        if not v.skinned then
                            local toggle = _G[v:GetName().."Toggle"]
                            F.ReskinExpandOrCollapse(toggle)
                            toggle.SetPushedTexture = F.dummy
                            v.skinned = true
                        end
                    end
                    if not self.skinned then
                        --print("Skin Tree!!!!")
                        F.ReskinScroll(self.scrollbar)
                        self.dragger:SetAlpha(0)
                        self.dragger:SetScript("OnEnter", function(dragger) dragger:SetAlpha(1) end)
                        self.dragger:SetScript("OnLeave", function(dragger) dragger:SetAlpha(0) end)
                        local tex = self.dragger:CreateTexture(nil, "OVERLAY")
                        tex:SetWidth(1)
                        tex:SetPoint("TOP", self.treeframe, "TOPRIGHT", 1, -1)
                        tex:SetPoint("BOTTOM", self.treeframe, "BOTTOMRIGHT", 1, 1)
                        tex:SetTexture(C.media.backdrop)
                        tex:SetVertexColor(r, g, b, .8)
                        self.skinned = true
                    end
                end)
                F.CreateBD(widget.treeframe, .3)
                F.CreateBD(frame)
                frame:SetPoint("TOPLEFT", widget.treeframe, "TOPRIGHT", 1, 0)
            end

        elseif TYPE == "ScrollFrame" then
            if not widget.skinned then
                F.ReskinScroll(widget.scrollbar)
            end

        elseif TYPE == "SimpleGroup" then
            if not widget.skinned then
                --
            end

        elseif TYPE == "Window" then
            if not widget.skinned then
                -- Sizer
                local line1, line2 = widget.sizer_se:GetRegions()
                line1:SetSize(2, 2)
                line1:SetTexture(C.media.backdrop)
                line1:SetVertexColor(r, g, b, .8)

                line2:SetSize(2, 2)
                line2:SetPoint("BOTTOMRIGHT", line1, "TOPRIGHT", 0, 4)
                line2:SetTexture(C.media.backdrop)
                line2:SetVertexColor(r, g, b, .8)

                local line3 = widget.sizer_se:CreateTexture(nil, "BACKGROUND")
                line3:SetSize(2, 2)
                line3:SetPoint("BOTTOMRIGHT", line1, "BOTTOMLEFT", -4, 0)
                line3:SetTexture(C.media.backdrop)
                line3:SetVertexColor(r, g, b, .8)

                F.ReskinClose(widget.closebutton)

                -- Remove Borders
                StripTextures(frame)

                -- StripTextures will actually remove the backdrop too, so we need to put that back
                F.CreateBD(frame)
            end
        end
        return oldRegisterAsContainer(self, widget)
    end
end
----------
function SkinAce3:PLAYER_LOGIN()
    if Aurora then
        self:Skin()
    end
end

function SkinAce3:OnInitialize()
    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterSkin(MODNAME, "Ace3")
end

function SkinAce3:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
end
