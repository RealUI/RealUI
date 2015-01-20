local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local dbc

local _
local MODNAME = "SkinDBM"
local SkinDBM = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local F, C

function SkinDBM:SetOptions(reset)
    --print("SkinDBM:SetOptions", DBM and DBM.Bars)
    if DBM and DBM.Bars and nibRealUICharacter then
        --print("SkinDBM:SetOptions", dbc.settingsApplied)
        if not dbc.settingsApplied or reset then
            nibRealUI:LoadDBMData()

            dbc.settingsApplied = true

            if (nibRealUICharacter.installStage == -1) and (nibRealUI.db.global.tags.tutorialdone) then
                print("|cFFFFFFFFDBM settings loaded.|r |cffFFFFFFReload UI (|r|cFFFF8000/rl|r|cffFFFFFF) for these settings to apply.")
                nibRealUI:Notification("DBM settings loaded.", true, "Reload UI (|cFFFF8000/rl|r) for these settings to apply.")
            end
        end
    end
end

function SkinDBM:styleCore()
    F, C = unpack(Aurora)
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
end

function SkinDBM:styleGUI()
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
        print("DBMSkin: RegisterOnGuiLoadCallback")
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
        print("DBMSkin: ShowMenu", self, values)
        local button = self.buttons[1]
        local _, _, _, x = button:GetPoint()
        for i = 1, MAX_BUTTONS do
            if i + self.offset <= #values then
                if values[i+self.offset].value == self.dropdown.value then
                    local text = self.buttons[i]:GetText()
                    local t, j = text:find("Check:0")
                    text = text:sub(j+3)
                    print("Button "..i.."text:", text)
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

function SkinDBM:ADDON_LOADED(event, addon)
    --print("SkinDBM:", event, addon)
    if addon == "DBM-Core" then
        self:SetOptions()
        self:styleCore()
    elseif addon == "DBM-GUI" then -- GUI can't load before core
        self:styleGUI()

        self:UnregisterEvent("ADDON_LOADED")
    end
end
----------

function SkinDBM:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {},
        char = {
            settingsApplied = false,
        },
    })
    dbc = self.db.char

    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterSkin(MODNAME, "DBM")
end

function SkinDBM:OnEnable()
    if DBM and DBM.Bars then
        self:SetOptions()
        self:styleCore()
    end
    self:RegisterEvent("ADDON_LOADED")
end
