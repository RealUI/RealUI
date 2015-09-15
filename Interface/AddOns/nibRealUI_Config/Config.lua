local ADDON_NAME, private = ...
local options = {}
private.options = options

-- Lua Globals --
local _G = _G
local tostring, next = _G.tostring, _G.next

-- RealUI --
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = nibRealUI.L
local ndb, ndbc= nibRealUI.db.profile, nibRealUI.db.char

local hudSize = ndb.settings.hudSize
local round = nibRealUI.Round

-- Libs --
local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local GUI = LibStub("AceGUI-3.0")
local F, C = _G.Aurora[1], _G.Aurora[2]
local r, g, b = C.r, C.g, C.b

local uiWidth, uiHeight = UIParent:GetSize()
local initialized = false
local isHuDShown = false

local function debug(...)
    nibRealUI.Debug("Config", ...)
end
private.debug = debug

local isInTestMode, RavenTimer = false
function nibRealUI:HuDTestMode(doTestMode)
    -- Toggle Test Modes
    -- Raven
    local Raven = _G.Raven
    if Raven then
        if doTestMode then
            Raven:TestBarGroups()
            RavenTimer = _G.C_Timer.NewTicker(51, function()
                Raven:TestBarGroups()
            end)
        else
            if isInTestMode then
                RavenTimer:Cancel()
                RavenTimer = nil
                Raven:TestBarGroups()
            end
        end
    end

    nibRealUI:ToggleGridTestMode(doTestMode)

    -- RealUI Modules
    for k, mod in next, nibRealUI.configModeModules do
        debug("Config Test", mod.moduleName)
        if mod:IsEnabled() then
            debug("Is enabled")
            mod:ToggleConfigMode(doTestMode)
        end
    end

    if not ObjectiveTrackerFrame.collapsed then
        ObjectiveTrackerFrame:SetShown(not doTestMode)
    end
    -- Boss Frames
    _G.RealUIUFBossConfig(doTestMode)

    -- Spell Alerts
    local sAlert = {
        id = 17941,
        texture = "TEXTURES\\SPELLACTIVATIONOVERLAYS\\NIGHTFALL.BLP",
        positions = "Left + Right (Flipped)",
        scale = 1,
        r = 255, g = 255, b = 255,
    }
    if doTestMode then
        _G.SpellActivationOverlay_ShowAllOverlays(_G.SpellActivationOverlayFrame, sAlert.id, sAlert.texture, sAlert.positions, sAlert.scale, sAlert.r, sAlert.g, sAlert.b);
    else
        _G.SpellActivationOverlay_HideOverlays(_G.SpellActivationOverlayFrame, sAlert.id)
    end

    -- Extra Action Button
    local EABFrame = _G.ExtraActionBarFrame
    if not HasExtraActionBar() then
        if doTestMode then
            EABFrame.button:Show()
            EABFrame:Show()
            EABFrame.outro:Stop()
            EABFrame.intro:Play()
            if not EABFrame.button.icon:GetTexture() then
                EABFrame.button.icon:SetTexture("Interface\\ICONS\\ABILITY_SEAL")
                EABFrame.button.icon:Show()
            end
        else
            EABFrame:Hide()
            EABFrame.button:Hide()
            EABFrame.intro:Stop()
            EABFrame.outro:Play()
        end
    end
    isInTestMode = doTestMode
end

StaticPopupDialogs["RUI_ChangeHuDSize"] = {
    text = L["HuD_AlertHuDChangeSize"],
    button1 = OKAY,
    OnAccept = function()
        nibRealUI:ReloadUIDialog()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    notClosableByLogout = false,
}

local height = round(uiHeight * 0.05)
local width = round(height * 1.3)
local hudConfig, hudToggle do
    local tinsert = _G.table.insert
    local UIParent, CreateFrame = _G.UIParent, _G.CreateFrame

    -- The HuD Config bar
    hudConfig = CreateFrame("Frame", "RealUIHuDConfig", UIParent)
    hudConfig:SetPoint("BOTTOM", UIParent, "TOP", 0, 0)
    _G.RealUIUINotifications:SetPoint("TOP", hudConfig, "BOTTOM")
    F.CreateBD(hudConfig)
    hudConfig:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            hudToggle(true)
        end
    end)

    local slideAnim = hudConfig:CreateAnimationGroup()
    slideAnim:SetScript("OnFinished", function(self)
        local x, y = self.slide:GetOffset()
        hudConfig:ClearAllPoints()
        if y < 0 then
            hudConfig:SetPoint("TOP", UIParent, "TOP", 0, 0)
        else
            hudConfig:SetPoint("BOTTOM", UIParent, "TOP", 0, 1)
        end
    end)
    hudConfig.slideAnim = slideAnim

    local slide = slideAnim:CreateAnimation("Translation")
    slide:SetDuration(1)
    slide:SetSmoothing("OUT")
    slideAnim.slide = slide

    -- Highlight frame
    local highlight = CreateFrame("Frame", "RealUIHuDConfig", hudConfig)
    F.CreateBD(highlight, 0.0)
    highlight:SetBackdropColor(r, g, b, 0.3)
    highlight:SetBackdropBorderColor(r, g, b)
    highlight:Hide()
    hudConfig.highlight = highlight

    local hlAnim = highlight:CreateAnimationGroup()
    highlight.hlAnim = hlAnim
    local hl = hlAnim:CreateAnimation("Translation")
    hl:SetDuration(0.2)
    hl:SetSmoothing("OUT")
    hlAnim.hl = hl

    local CloseHuDWindow = function()
        -- hide highlight
        highlight:Hide()
        highlight.hover = nil
        highlight.clicked = nil

        ACD:Close("HuD")
    end
    private.CloseHuDWindow = CloseHuDWindow
    hudToggle = function(skipAnim)
        if isHuDShown then
            CloseHuDWindow()

            -- slide out
            if skipAnim then
                hudConfig:ClearAllPoints()
                hudConfig:SetPoint("BOTTOM", UIParent, "TOP", 0, 0)
            else
                slide:SetOffset(0, height)
                slideAnim:Play()
            end
            nibRealUI:HuDTestMode(false)
            hudConfig:UnregisterEvent("PLAYER_REGEN_DISABLED")
            isHuDShown = false
        else
            -- slide in
            if skipAnim then
                hudConfig:ClearAllPoints()
                hudConfig:SetPoint("TOP", UIParent, "TOP", 0, 0)
            else
                slide:SetOffset(0, -height)
                slideAnim:Play()
            end
            hudConfig:RegisterEvent("PLAYER_REGEN_DISABLED")
            isHuDShown = true
        end
    end
end

local function InitializeOptions()
    debug("Init")
    local tinsert = _G.table.insert
    local UIParent, CreateFrame = _G.UIParent, _G.CreateFrame

    local slideAnim = hudConfig.slideAnim
    local highlight = hudConfig.highlight
    local hlAnim = highlight.hlAnim
    local hl = hlAnim.hl

    nibRealUI:SetUpOptions() -- Old
    ACR:RegisterOptionsTable("HuD", options.HuD)
    ACD:SetDefaultSize("HuD", 620, 480)
    ACR:RegisterOptionsTable("RealUI", options.RealUI)
    initialized = true

    -- Buttons
    local tabs = {}
    for slug, tab in next, options.HuD.args do
        tinsert(tabs, tab.order + 2, {
            slug = slug,
            name = tab.name,
            icon = tab.icon,
            onclick = tab.order == -1 and function(self, ...)
                debug("OnClick", self.slug, ...)
                highlight:Hide()
                hudToggle()
            end or nil,
        })
    end
    tinsert(tabs, _G.tremove(tabs, 1)) -- Move close to the end
    local function tabOnClick(self, ...)
        debug("OnClick", self.slug, ...)
        if highlight.clicked and tabs[highlight.clicked].frame then
            tabs[highlight.clicked].frame:Hide()
        end
        local widget = ACD.OpenFrames["HuD"]
        if widget and highlight.clicked == self.ID then
            highlight.clicked = nil
            widget.titlebg:SetPoint("TOP", 0, 12)
            ACD:Close("HuD")
        else
            highlight.clicked = self.ID
            ACD:Open("HuD", self.slug)
            widget = ACD.OpenFrames["HuD"]
            widget:ClearAllPoints()
            widget:SetPoint("TOP", hudConfig, "BOTTOM")
            widget:SetTitle(self.text:GetText())
            widget.titlebg:SetPoint("TOP", 0, 0)
            -- the position will get reset via SetStatusTable, so we need to set our new positions there too.
            local status = widget.status or widget.localstatus
            status.top = widget.frame:GetTop()
            status.left = widget.frame:GetLeft()
        end
    end
    local prevFrame, container
    debug("size", width, height)
    for i = 1, #tabs do
        local tab = tabs[i]
        debug("iter tabs", i, tab.slug)
        local btn = CreateFrame("Button", "$parentBtn"..i, hudConfig)
        btn.ID = i
        btn.slug = tab.slug
        btn:SetSize(width, height)
        btn:SetScript("OnEnter", function(self, ...)
            if slideAnim:IsPlaying() then return end
            debug("OnEnter", tab.slug)
            if highlight:IsShown() then
                debug(highlight.hover, highlight.clicked)
                if highlight.hover ~= self.ID then
                    hl:SetOffset(width * (self.ID - highlight.hover), 0)
                    hlAnim:SetScript("OnFinished", function(hlAnim)
                        highlight.hover = i
                        highlight:SetAllPoints(self)
                    end)
                    hlAnim:Play()
                elseif hlAnim:IsPlaying() then
                    debug("Stop Playing")
                    hlAnim:Stop()
                end
            else
                highlight.hover = i
                highlight:SetAllPoints(self)
                highlight:Show()
            end
        end)
        btn:SetScript("OnLeave", function(self, ...)
            if hudConfig:IsMouseOver() then return end
            debug("OnLeave hudConfig", ...)
            if highlight.clicked then
                debug(highlight.hover, highlight.clicked)
                if highlight.hover ~= highlight.clicked then
                    hl:SetOffset(width * (highlight.clicked - highlight.hover), 0)
                    hlAnim:SetScript("OnFinished", function(hlAnim)
                        highlight.hover = highlight.clicked
                        highlight:SetAllPoints(hudConfig[highlight.clicked])
                    end)
                    hlAnim:Play()
                elseif hlAnim:IsPlaying() then
                    debug("Stop Playing")
                    hlAnim:Stop()
                end
            else
                highlight:Hide()
            end
        end)

        if i == 1 then
            btn:SetPoint("TOPLEFT")
            local check = CreateFrame("CheckButton", nil, btn, "SecureActionButtonTemplate, UICheckButtonTemplate")
            check:SetHitRectInsets(-10, -10, -1, -21)
            check:SetPoint("CENTER", 0, 10)
            check:SetAttribute("type1", "macro")
            F.ReskinCheck(check)
            _G.SecureHandlerWrapScript(check, "OnClick", check, [[
                if self:GetID() == 1 then
                    self:SetAttribute("macrotext", format("/cleartarget\n/focus\n/run RealUI:HuDTestMode(false)"))
                    self:SetID(0)
                else
                    self:SetAttribute("macrotext", format("/target player\n/focus\n/run RealUI:HuDTestMode(true)"))
                    self:SetID(1)
                end
            ]])
        else
            btn:SetPoint("TOPLEFT", prevFrame, "TOPRIGHT")
            btn:SetScript("OnClick", tab.onclick or tabOnClick)

            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetTexture(tab.icon)
            icon:SetSize(height * 0.5, height * 0.5)
            icon:SetPoint("TOP", 0, -(height * 0.15))
        end

        local text = btn:CreateFontString()
        text:SetFontObject(_G.GameFontHighlightSmall)
        text:SetWidth(width * 0.9)
        text:SetPoint("BOTTOM", 0, width * 0.08)
        text:SetText(tab.name)
        btn.text = text

        tinsert(hudConfig, btn)
        prevFrame = btn
    end
    hudConfig:SetSize(#hudConfig * width, height)
end

function nibRealUI:ToggleConfig(app, section, ...)
    debug("Toggle", app, section, ...)
    if _G.InCombatLockdown() then
        nibRealUI:Notification(L["Alert_CombatLockdown"], true, L["Alert_CantOpenInCombat"], nil, [[Interface\AddOns\nibRealUI\Media\Icons\Notification_Alert]])
        return
    end
    if not initialized then InitializeOptions() end
    if app == "HuD" then
        if not isHuDShown then
            hudToggle(section)
        end
        if section then
            debug("Highlight", section, #hudConfig)
            for i = 1, #hudConfig do
                local tab = hudConfig[i]
                if tab.slug == section then
                    tab:GetScript("OnClick")(tab)
                    hudConfig.highlight.hover = i
                    hudConfig.highlight:SetAllPoints(tab)
                    hudConfig.highlight:Show()
                end
            end
        end
    end
    --if not app:match("RealUI") then app = "RealUI" end
    if ACD.OpenFrames[app] and not section then
        ACD:Close(app)
    elseif section or app ~= "HuD" then
        ACD:Open(app, section)
    end

    if ... then
        ACD:SelectGroup(app, section, ...)
    end
end
