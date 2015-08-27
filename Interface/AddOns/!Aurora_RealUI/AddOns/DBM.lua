local _, mods = ...

mods["PLAYER_LOGIN"]["DBM-Core"] = function(self, F, C)
    --print("DBM-Core", F, C)
    local firstInfo = true
    hooksecurefunc(DBM.InfoFrame, "Show", function()
        if firstInfo then
            DBMInfoFrame:SetBackdrop(nil)
            local bd = CreateFrame("Frame", nil, DBMInfoFrame)
            bd:SetPoint("TOPLEFT")
            bd:SetPoint("BOTTOMRIGHT")
            bd:SetFrameLevel(DBMInfoFrame:GetFrameLevel()-1)
            F.CreateBD(bd)

            firstInfo = false
        end
    end)

    local firstRange = true
    hooksecurefunc(DBM.RangeCheck, "Show", function()
        if firstRange then
            DBMRangeCheck:SetBackdrop(nil)
            local bd = CreateFrame("Frame", nil, DBMRangeCheck)
            bd:SetPoint("TOPLEFT")
            bd:SetPoint("BOTTOMRIGHT")
            bd:SetFrameLevel(DBMRangeCheck:GetFrameLevel()-1)
            F.CreateBD(bd)

            firstRange = false
        end
    end)

    local count = 1

    local styleBar = function()
        local bar = _G["DBM_BossHealth_Bar_"..count]

        while bar do
            if not bar.styled then
                local name = bar:GetName()
                local sb = _G[name.."Bar"]
                local text = _G[name.."BarName"]
                local timer = _G[name.."BarTimer"]

                _G[name.."BarBackground"]:Hide()
                _G[name.."BarBorder"]:SetNormalTexture("")

                sb:SetStatusBarTexture(C.media.backdrop)

                F.CreateBDFrame(sb)

                bar.styled = true
            end

            count = count + 1
            bar = _G["DBM_BossHealth_Bar_"..count]
        end
    end

    hooksecurefunc(DBM.BossHealth, "AddBoss", styleBar)
    hooksecurefunc(DBM.BossHealth, "UpdateSettings", styleBar)

    -- Place this inside Core to ensure it only gets created if we actually want DBM to be skinned.
    mods["DBM-GUI"] = function(F, C)
        --print("DBM-GUI", F, C)
        DBM_GUI_OptionsFrameHeader:SetTexture(nil)
        DBM_GUI_OptionsFramePanelContainer:SetBackdrop(nil)
        DBM_GUI_OptionsFrameBossMods:DisableDrawLayer("BACKGROUND")
        DBM_GUI_OptionsFrameDBMOptions:DisableDrawLayer("BACKGROUND")

        for i = 1, 2 do
            _G["DBM_GUI_OptionsFrameTab"..i.."Left"]:SetAlpha(0)
            _G["DBM_GUI_OptionsFrameTab"..i.."Middle"]:SetAlpha(0)
            _G["DBM_GUI_OptionsFrameTab"..i.."Right"]:SetAlpha(0)
            _G["DBM_GUI_OptionsFrameTab"..i.."LeftDisabled"]:SetAlpha(0)
            _G["DBM_GUI_OptionsFrameTab"..i.."MiddleDisabled"]:SetAlpha(0)
            _G["DBM_GUI_OptionsFrameTab"..i.."RightDisabled"]:SetAlpha(0)
        end

        local count = 1

        local function styleDBM()
            local option = _G["DBM_GUI_Option_"..count]
            while option do
                local objType = option:GetObjectType()
                if objType == "CheckButton" then
                    F.ReskinCheck(option)
                elseif objType == "Slider" then
                    F.ReskinSlider(option)
                elseif objType == "EditBox" then
                    F.ReskinInput(option)
                elseif option:GetName():find("DropDown") then
                    F.ReskinDropDown(option)
                    local name = option:GetName()
                    local button, bg = option:GetChildren()
                    bg:SetPoint("TOPLEFT", _G[name.."Left"], 18, -20)
                    bg:SetPoint("BOTTOMRIGHT", _G[name.."Right"], -16, 24)

                    button:ClearAllPoints()
                    button:SetPoint("RIGHT", bg, 0, 0)
                elseif objType == "Button" then
                    F.Reskin(option)
                elseif objType == "Frame" then
                    option:SetBackdrop(nil)
                end

                count = count + 1
                option = _G["DBM_GUI_Option_"..count]
                if not option then
                    option = _G["DBM_GUI_DropDown"..count]
                end
            end
        end

        DBM:RegisterOnGuiLoadCallback(function()
            --print("DBMSkin: RegisterOnGuiLoadCallback")
            styleDBM()
            hooksecurefunc(DBM_GUI, "UpdateModList", styleDBM)
            DBM_GUI_OptionsFrameBossMods:HookScript("OnShow", styleDBM)
        end)

        hooksecurefunc(DBM_GUI_OptionsFrame, "DisplayButton", function(button, element)
            -- bit of a hack, can't get the API to work
            local pushed = element.toggle:GetPushedTexture():GetTexture()

            if not element.styled then
                F.ReskinExpandOrCollapse(element.toggle)
                element.toggle:GetPushedTexture():SetAlpha(0)

                element.styled = true
            end

            element.toggle.plus:SetShown(pushed and pushed:find("Plus"))
        end)

        local MAX_BUTTONS = 10
        hooksecurefunc(DBM_GUI_DropDown, "ShowMenu", function(self, values)
            --print("DBMSkin: ShowMenu", self, values)
            local button = self.buttons[1]
            local _, _, _, x = button:GetPoint()
            for i = 1, MAX_BUTTONS do
                if i + self.offset <= #values then
                    if values[i+self.offset].value == self.dropdown.value then
                        local text = self.buttons[i]:GetText()
                        local t, j = text:find("Check:0")
                        text = text:sub(j+3)
                        --print("Button "..i.."text:", text)
                    end
                    --button = self.buttons[i]

                    local highlight = _G[self.buttons[i]:GetName().."Highlight"]
                    highlight:SetTexture(C.r, C.g, C.b, .2)
                    highlight:SetPoint("TOPLEFT", -x, 0)
                    highlight:SetPoint("BOTTOMRIGHT", self:GetWidth() - button:GetWidth() - x - 1, 0)
                end
            end

            if self.text:IsShown() then
                self:SetHeight(self:GetHeight() + 5)
                self.text:SetPoint("BOTTOM", self, "BOTTOM", 0, 3)
            end
        end)

        F.CreateBD(DBM_GUI_DropDown)
        F.CreateBD(DBM_GUI_OptionsFrame)
        F.Reskin(DBM_GUI_OptionsFrameWebsiteButton)
        F.Reskin(DBM_GUI_OptionsFrameOkay)
        F.ReskinScroll(DBM_GUI_OptionsFramePanelContainerFOVScrollBar)
    end
end
