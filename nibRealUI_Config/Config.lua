local ADDON_NAME, private = ...
local options = {}
private.options = options

-- Lua Globals --
-- luacheck: globals next tonumber max min

-- Libs --
local ACR = _G.LibStub("AceConfigRegistry-3.0")
local ACD = _G.LibStub("AceConfigDialog-3.0")
local Aurora = _G.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin
local Color = Aurora.Color

local fa = _G.LibStub("LibIconFonts-1.0"):GetIconFont("FontAwesome-4.7")
fa.path = _G.LibStub("LibSharedMedia-3.0"):Fetch("font", "Font Awesome")

-- RealUI --
local RealUI = _G.RealUI
local L = RealUI.L
local Scale = RealUI.Scale
--local round = RealUI.Round

local FramePoint = RealUI:GetModule("FramePoint")

local _, MOD_NAME = _G.strsplit("_", ADDON_NAME)
local initialized = false
local isHuDShown = false

local debug = RealUI.GetDebug(MOD_NAME)
private.debug = debug

local RavenTimer
_G.hooksecurefunc(_G.ZoneAbilityFrame, "Hide", function(self)
    if self._show then
        self:Show()
    end
end)
function RealUI:HuDTestMode(isConfigMode)
    FramePoint:ToggleAll(not isConfigMode)

    -- Toggle Test Modes
    -- Raven
    local Raven = _G.Raven
    if Raven then
        if isConfigMode then
            Raven:TestBarGroups()
            RavenTimer = _G.C_Timer.NewTicker(51, function()
                Raven:TestBarGroups()
            end)
        else
            if self.isConfigMode then
                RavenTimer:Cancel()
                RavenTimer = nil
                Raven:TestBarGroups()
            end
        end
    end

    RealUI:ToggleGridTestMode(isConfigMode)

    -- RealUI Modules
    for k, mod in next, RealUI.configModeModules do
        debug("Config Test", mod.moduleName)
        if mod:IsEnabled() then
            debug("Is enabled")
            mod:ToggleConfigMode(isConfigMode)
        end
    end

    if not _G.ObjectiveTrackerFrame.collapsed then
        _G.ObjectiveTrackerFrame:SetShown(not isConfigMode)
    end

    -- Boss Frames
    RealUI:BossConfig(isConfigMode)

    -- Spell Alerts
    local sAlert = {
        id = 17941,
        texture = [[TEXTURES\SPELLACTIVATIONOVERLAYS\NIGHTFALL]],
        positions = "Left + Right (Flipped)",
        scale = 1,
        r = 255, g = 255, b = 255,
    }
    if isConfigMode then
        _G.SpellActivationOverlay_ShowAllOverlays(_G.SpellActivationOverlayFrame, sAlert.id, sAlert.texture, sAlert.positions, sAlert.scale, sAlert.r, sAlert.g, sAlert.b);
    else
        _G.SpellActivationOverlay_HideOverlays(_G.SpellActivationOverlayFrame, sAlert.id)
    end

    -- Extra Action Button
    local EABFrame = _G.ExtraActionBarFrame
    if not _G.HasExtraActionBar() then
        if isConfigMode then
            EABFrame.button:Show()
            EABFrame:Show()
            EABFrame.outro:Stop()
            EABFrame.intro:Play()
            if not EABFrame.button.icon:GetTexture() then
                EABFrame.button.icon:SetTexture([[Interface\ICONS\ABILITY_SEAL]])
                EABFrame.button.icon:Show()
            end
        else
            EABFrame:Hide()
            EABFrame.button:Hide()
            EABFrame.intro:Stop()
            EABFrame.outro:Play()
        end
    end

    -- Zone Ability Button
    local ZAFFrame = _G.ZoneAbilityFrame
    local hasZoneAbility
    if RealUI.isPatch then
        local zoneAbilities = _G.C_ZoneAbility.GetActiveAbilities()
        hasZoneAbility = #zoneAbilities > 0
        for i, spellButton in ZAFFrame.SpellButtonContainer.contentFramePool:EnumerateInactive() do
            if isConfigMode then
                spellButton:Disable()
                spellButton.Icon:SetTexture([[Interface\ICONS\ABILITY_SEAL]])
            else
                spellButton:Enable()
            end
        end

        if not hasZoneAbility then
            ZAFFrame:SetShown(isConfigMode)
        end
    else
        if not _G.HasZoneAbility() then
            if isConfigMode then
                ZAFFrame:Show()
                ZAFFrame.SpellButton:Disable()
                ZAFFrame._show = true
                ZAFFrame.SpellButton.Icon:SetTexture([[Interface\ICONS\ABILITY_SEAL]])
            else
                ZAFFrame._show = false
                ZAFFrame.SpellButton:Enable()
                ZAFFrame:Hide()
            end
        end
    end
    self.isConfigMode = isConfigMode
end

_G.StaticPopupDialogs["RUI_ChangeHuDSize"] = {
    text = L["HuD_AlertHuDChangeSize"],
    button1 = _G.OKAY,
    OnAccept = function()
        RealUI:ReloadUIDialog()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    notClosableByLogout = false,
}

local width, height = 65, 50
local hudConfig, hudToggle do
    -- The HuD Config bar
    hudConfig = _G.CreateFrame("Frame", "RealUIHuDConfig", _G.UIParent)
    Scale.Point(hudConfig, "BOTTOM", _G.UIParent, "TOP", 0, 1)
    hudConfig:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            hudToggle(true)
        end
    end)

    local slideAnim = hudConfig:CreateAnimationGroup()
    slideAnim:SetScript("OnFinished", function(self)
        local _, y = self.slide:GetOffset()
        hudConfig:ClearAllPoints()
        if y < 0 then
            Scale.Point(hudConfig, "TOP", _G.UIParent, "TOP", 0, 0)
        else
            Scale.Point(hudConfig, "BOTTOM", _G.UIParent, "TOP", 0, 1)
        end
    end)
    hudConfig.slideAnim = slideAnim

    local slide = slideAnim:CreateAnimation("Translation")
    slide:SetDuration(1)
    slide:SetSmoothing("OUT")
    slideAnim.slide = slide

    -- Highlight frame
    local highlight = _G.CreateFrame("Frame", "RealUIHuDConfig", hudConfig)
    Base.SetBackdrop(highlight, Color.highlight)
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
                Scale.Point(hudConfig, "BOTTOM", _G.UIParent, "TOP", 0, 0)
            else
                slide:SetOffset(0, Scale.Value(height))
                slideAnim:Play()
            end
            RealUI:HuDTestMode(false)
            hudConfig:UnregisterEvent("PLAYER_REGEN_DISABLED")
            isHuDShown = false
        else
            -- slide in
            if skipAnim then
                hudConfig:ClearAllPoints()
                Scale.Point(hudConfig, "TOP", _G.UIParent, "TOP", 0, 0)
            else
                slide:SetOffset(0, Scale.Value(-height))
                slideAnim:Play()
            end
            hudConfig:RegisterEvent("PLAYER_REGEN_DISABLED")
            isHuDShown = true
        end
    end

    Base.SetBackdrop(hudConfig)
    Scale.Point(_G.RealUIUINotifications, "TOP", hudConfig, "BOTTOM")
    RealUI.RegisterModdedFrame(hudConfig)
end

local tabs = {}
local function InitializeOptions()
    debug("InitializeOptions", options.RealUI, options.HuD)
    if not (options.RealUI and options.HuD) then
        -- Not sure how people are getting this....
        return _G.print("Options initialization failed. Please notify the developer.")
    end
    local slideAnim = hudConfig.slideAnim
    local highlight = hudConfig.highlight
    local hlAnim = highlight.hlAnim
    local hl = hlAnim.hl

    ACR:RegisterOptionsTable("RealUI", options.RealUI)
    ACD:SetDefaultSize("RealUI", 800, 600)

    ACR:RegisterOptionsTable("HuD", options.HuD)
    ACD:SetDefaultSize("HuD", 620, 480)
    initialized = true

    -- Buttons
    for slug, tab in next, options.HuD.args do
        debug("init tabs", slug, tab.order)
        _G.tinsert(tabs, tab.order + 2, {
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
    _G.tinsert(tabs, _G.tremove(tabs, 1)) -- Move close to the end
    local function tabOnClick(self, ...)
        debug("OnClick", self.slug, ...)
        if highlight.clicked and tabs[highlight.clicked].frame then
            tabs[highlight.clicked].frame:Hide()
        end
        local widget = ACD.OpenFrames["HuD"]
        if widget and highlight.clicked == self.ID then
            highlight.clicked = nil
            Scale.Point(widget.titlebg, "TOP", 0, 12)
            ACD:Close("HuD")
        else
            highlight.clicked = self.ID
            ACD:Open("HuD", self.slug)
            widget = ACD.OpenFrames["HuD"]
            widget:ClearAllPoints()
            Scale.Point(widget, "TOP", hudConfig, "BOTTOM")
            widget:SetTitle(self.text:GetText())
            Scale.Point(widget.titlebg, "TOP", 0, 0)
            -- the position will get reset via SetStatusTable, so we need to set our new positions there too.
            local status = widget.status or widget.localstatus
            status.top = widget.frame:GetTop()
            status.left = widget.frame:GetLeft()
        end
    end
    local prevFrame
    debug("size", width, height)
    for i = 1, #tabs do
        local tab = tabs[i]
        debug("iter tabs", i, tab.slug)
        hudConfig[tab.slug] = _G.CreateFrame("Button", "$parentBtn"..i, hudConfig)
        local btn = hudConfig[tab.slug]
        btn.ID = i
        btn.slug = tab.slug
        Scale.Size(btn, width, height)
        btn:SetScript("OnEnter", function(self, ...)
            if slideAnim:IsPlaying() then return end
            debug("OnEnter", tab.slug)
            if highlight:IsShown() then
                debug(highlight.hover, highlight.clicked)
                if highlight.hover ~= self.ID then
                    hl:SetOffset(Scale.Value(width) * (self.ID - highlight.hover), 0)
                    hlAnim:SetScript("OnFinished", function(anim)
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
                    hl:SetOffset(Scale.Value(width) * (highlight.clicked - highlight.hover), 0)
                    hlAnim:SetScript("OnFinished", function(anim)
                        highlight.hover = highlight.clicked
                        highlight:SetAllPoints(tabs[highlight.clicked].button)
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
            Scale.Point(btn, "TOPLEFT")
            local check = _G.CreateFrame("CheckButton", nil, btn, "SecureActionButtonTemplate, UICheckButtonTemplate")
            Skin.UICheckButtonTemplate(check)
            Scale.Point(check, "CENTER", 0, 10)
            check:SetHitRectInsets(-10, -10, -1, -21)

            check:SetAttribute("type1", "macro")
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
            Scale.Point(btn, "TOPLEFT", prevFrame, "TOPRIGHT")
            btn:SetScript("OnClick", tab.onclick or tabOnClick)

            local icon = btn:CreateFontString(nil, "ARTWORK")
            icon:SetFont(fa.path, 40)
            icon:SetText(fa[tab.icon])
            Scale.Point(icon, "TOPLEFT", 0, 0)
            Scale.Point(icon, "BOTTOMRIGHT", 0, 20)
        end

        local text = btn:CreateFontString(nil, "ARTWORK")
        text:SetFontObject(_G.Game16Font)
        text:SetSpacing(-1)
        text:SetText(tab.name)
        Scale.Point(text, "TOPLEFT", btn, "BOTTOMLEFT", 0, 23)
        Scale.Point(text, "BOTTOMRIGHT", 0, 0)
        btn.text = text

        tab.button = btn
        prevFrame = btn
    end
    hudConfig.tabs = tabs
    Scale.Size(hudConfig, #tabs * width, height)
end

function RealUI.ToggleConfig(app, ...)
    debug("Toggle", app, ...)
    if not initialized then InitializeOptions() end

    if ACD.OpenFrames[app] then
        ACD:Close(app)
    elseif app == "HuD" then
        if not isHuDShown then
            hudToggle(...)
        end

        if ... then
            debug("Highlight", #tabs, ...)
            for i = 1, #tabs do
                local tab = tabs[i]
                if tab.slug == ... then
                    tab.button:GetScript("OnClick")(tab.button)
                    hudConfig.highlight.hover = i
                    hudConfig.highlight:SetAllPoints(tab.button)
                    hudConfig.highlight:Show()
                end
            end

            ACD:Open(app, ...)
            ACD:SelectGroup(app, ...)
        end
    else
        ACD:Open(app)
        if ... then
            ACD:SelectGroup(app, ...)
        end
    end
end

function private.ValidateOffset(value, ...)
    local val = tonumber(value)
    local vmin, vmax = -5000, 5000
    if ... then vmin, vmax = ... end
    if val == nil then val = 0 end
    val = max(val, vmin)
    val = min(val, vmax)
    return val
end
