local _, private = ...

-- Lua Globals --
-- luacheck: globals floor next type tonumber max

-- Libs --
local LSM = _G.LibStub("LibSharedMedia-3.0")
local fonts = {}
for fontType, fontName in next, private.fontNames do
    fonts[fontType] = {
        name = fontName,
        path = LSM:Fetch("font", fontName)
    }
end

-- RealUI --
local RealUI = _G.RealUI
local Aurora = private.Aurora
private.isDev = RealUI.isDev

local debug = RealUI.GetDebug("Skins")
private.debug = debug

local scaleMessagePrinted = false

local defaults = {
    profile = {
        stripeAlpha = 0.5,
        buttonColor = {
        },
        frameColor = {
            a = 0.7
        },
        classColors = {
        },
        uiModScale = 1,
        customScale = 1,
        isHighRes = false,
        isPixelScale = true,
        fonts = fonts,
        addons = {
            ["**"] = true
        }
    }
}

RealUI.textures = private.textures

local moddedFrames, pixelScale = {}, 768 / (select(2, _G.GetPhysicalScreenSize()))
local function ResetScale(frame)
    if _G.InCombatLockdown() then
        -- Never touch frame scale during combat; any SetScale call from addon
        -- code can propagate taint to the action bar secure execution path.
        return
    end
    if frame.IsProtected and frame:IsProtected() then
        return
    end
    -- Frames that are sized via ModValue become HUGE with retina scale.
    if private.skinsDB.isHighRes then
        frame:SetScale(private.skinsDB.customScale)
    elseif private.skinsDB.customScale > pixelScale then
        frame:SetScale(pixelScale)
    end
end
local function UpdateModScale()
    private.uiScale = private.skinsDB.uiModScale
    for frame, func in next, moddedFrames do
        ResetScale(frame)
        if func then
            func(frame)
        end
    end
end

function RealUI.RegisterModdedFrame(frame, updateFunc)
    ResetScale(frame)
    moddedFrames[frame] = updateFunc or false
end

--[[ UI Scale Strategy
    The engine scale (SetCVar / UIParent:SetScale) is applied ONCE at login
    inside the deferred C_Timer.After(0) call from Aurora's ADDON_LOADED.
    This is the safest window — no combat, no protected frames active yet.

    Runtime changes from the config panel (toggling Pixel Perfect, changing
    Custom Scale, re-optimizing) save the new values and prompt a /reload.
    This avoids all taint issues while giving the optimizer full control.

    WoW CVar "uiScale" has a minimum of 0.64. For scales below that
    (e.g. pixel-perfect on 4K = 0.3556), we use UIParent:SetScale() as
    a fallback since it has no floor. This only happens at login.
]]

local uiMod = (select(2, _G.GetPhysicalScreenSize()) / 768)
local uiScaleChanging
local isStartupScaleApplied = false

function RealUI.UpdateUIScale(newScale, fromConfig)
    if uiScaleChanging then return end

    -- Ensure Aurora's standalone scale message is always suppressed when
    -- RealUI_Skins is the host addon, even if we early-return below.
    private.scaleReported = true
    _G.AURORA_SCALE_REPORTED = true

    -- Force-disable WoW's built-in "Use UI Scale" CVar so the Blizzard
    -- slider never overrides RealUI's scale management.
    if _G.GetCVar("useUiScale") == "1" then
        _G.SetCVar("useUiScale", 0)
        -- Defer notification until RealUI is fully loaded (PLAYER_LOGIN)
        _G.C_Timer.After(2, function()
            if RealUI.NotificationWithDuration then
                RealUI:NotificationWithDuration(15,
                    "UI Scale Conflict",
                    true,
                    "WoW's 'Use UI Scale' was enabled and has been disabled. "
                        .. "RealUI manages UI scaling — adjust scale in /realui > Skins instead.",
                    nil,
                    [[Interface\AddOns\RealUI\Media\Notification_Alert]]
                )
            end
        end)
    end

    -- Guard against the user re-enabling it via the Settings panel.
    -- Hook SetCVar to revert any attempt to turn useUiScale back on.
    if not private._uiScaleGuardInstalled then
        private._uiScaleGuardInstalled = true
        _G.hooksecurefunc("SetCVar", function(cvar, value)
            if cvar:lower() == "useuiscale" and tostring(value) == "1" then
                _G.C_Timer.After(0, function()
                    _G.SetCVar("useUiScale", 0)
                    RealUI.UpdateUIScale()
                    if RealUI.NotificationWithDuration then
                        RealUI:NotificationWithDuration(15,
                            "UI Scale Conflict",
                            true,
                            "WoW's 'Use UI Scale' was re-disabled. "
                                .. "RealUI manages UI scaling — adjust scale in /realui > Skins instead.",
                            nil,
                            [[Interface\AddOns\RealUI\Media\Notification_Alert]]
                        )
                    end
                end)
            end
        end)
    end

    local _, pysHeight = _G.GetPhysicalScreenSize()
    uiMod = (pysHeight / 768) * (private.uiScale or 1)
    pixelScale = 768 / pysHeight
    private.debug("pixel scale", pixelScale, uiMod)

    local oldScale = private.skinsDB.customScale
    local cvarScale = tonumber(RealUI.Scale.Round(_G.GetCVar("uiscale"), 2))
    local parentScale = RealUI.Scale.Round(_G.UIParent:GetScale(), 2)
    private.debug("current scale", oldScale, cvarScale, parentScale)

    if parentScale == 1 then
        return
    end

    -- Determine the desired customScale
    if private.skinsDB.isPixelScale then
        newScale = RealUI.Scale.Round(pixelScale, 2)
    end
    if not newScale then
        newScale = oldScale
    end
    private.debug("newScale", newScale)

    -- Compute the engine-level scale (what UIParent should be)
    local engineScale = newScale
    if private.skinsDB.isHighRes then
        engineScale = RealUI.Scale.Round(engineScale * 2, 2)
    end

    uiScaleChanging = true
    private.debug("update engineScale", engineScale)

    -- Apply engine scale ONLY at login (first call)
    if not isStartupScaleApplied then
        isStartupScaleApplied = true

        if parentScale ~= engineScale then
            -- At login (deferred C_Timer.After(0) context), apply the scale
            -- directly via UIParent:SetScale(). SetCVar("uiScale") from addon
            -- code may not take effect reliably and has a 0.64 floor.
            private.debug("Setting UIParent:SetScale to", engineScale)
            _G.UIParent:SetScale(engineScale)
        end
    end

    private.skinsDB.customScale = newScale
    UpdateModScale()
    uiScaleChanging = false

    -- Report effective scale on first run (login)
    if not scaleMessagePrinted then
        scaleMessagePrinted = true
        -- Also ensure Aurora's standalone message is suppressed
        private.scaleReported = true
        local phyWidth, phyHeight = _G.GetPhysicalScreenSize()
        local mode = private.skinsDB.isHighRes and "HiDPI" or (private.skinsDB.isPixelScale and "Pixel" or "Custom")
        _G.print(("Running on %sx%s - Effective Scale: %.2f (%s)"):format(phyWidth, phyHeight, newScale, mode))
    end

    -- Only prompt reload when explicitly triggered from config panel / optimizer
    if fromConfig and parentScale ~= engineScale then
        RealUI:ReloadUIDialog()
    end
end

function RealUI.GetInterfaceSize()
    local width, height = _G.GetPhysicalScreenSize()
    if private.skinsDB.isHighRes then
        return width, height, width / 2, height / 2
    end
    return width, height
end

local ScaleAPI = {}

local skinnedFrames = {}
function RealUI:IsFrameSkinned(frame)
    return not not skinnedFrames[frame]
end
function RealUI:RegisterSkinnedFrame(frame, color)
    skinnedFrames[frame] = color
end
function RealUI:UpdateFrameStyle()
    for frame, color in next, skinnedFrames do
        if frame._stripes then
            Aurora.Base.SetBackdropColor(frame, color, private.skinsDB.frameColor.a)
            frame._stripes:SetAlpha(private.skinsDB.stripeAlpha)
        else
            Aurora.Base.SetBackdropColor(frame, color)
        end
    end
end
function RealUI:AddFrameStripes(Frame)
    local bg = Frame:GetBackdropTexture("bg")
    local stripes = bg:GetParent():CreateTexture(nil, "BACKGROUND", nil, -6)
    stripes:SetTexture([[Interface\AddOns\RealUI\Media\StripesThin]], true, true)
    stripes:SetAlpha(private.skinsDB.stripeAlpha)
    stripes:SetAllPoints(bg)
    stripes:SetHorizTile(true)
    stripes:SetVertTile(true)
    stripes:SetBlendMode("ADD")
    Frame._stripes = stripes
end

function private.OnLoad()
    -- Bug 9 fix: Suppress Aurora's standalone "UI Scale" message immediately.
    -- This must be the FIRST thing in OnLoad, before any code that could error,
    -- so the deferred C_Timer.After(0) callback in init.lua always sees it.
    private.scaleReported = true
    -- Also set a global flag for dev mode where Aurora may load as a separate
    -- addon with its own private table that can't see our private.scaleReported.
    _G.AURORA_SCALE_REPORTED = true

    local skinsDB = _G.LibStub("AceDB-3.0"):New("RealUI_SkinsDB", defaults, true)
    skinsDB:RegisterCallback("OnProfileChanged", function(db, newProfile)
        RealUI:ReloadUIDialog()
    end)
    skinsDB:RegisterCallback("OnProfileCopied", function(db, sourceProfile)
        RealUI:ReloadUIDialog()
    end)
    skinsDB:RegisterCallback("OnProfileReset", function(db)
        RealUI:ReloadUIDialog()
    end)
    private.skinsDB = skinsDB.profile

    -- Set flags
    private.disabled.bags = true
    private.disabled.banks = true
    private.disabled.mainmenubar = true
    private.disabled.pixelScale = not private.skinsDB.isPixelScale

    private.uiScale = private.skinsDB.uiModScale
    private.UpdateUIScale = RealUI.UpdateUIScale

    for fontType, font in next, private.skinsDB.fonts do
        private.font[fontType] = font.path or LSM:Fetch("font", font.name)
    end

    local Skin = Aurora.Skin
    local Color, Util = Aurora.Color, Aurora.Util

    -- Initialize custom colors
    local frameColor = private.skinsDB.frameColor
    if not frameColor.r then
        frameColor.r, frameColor.g, frameColor.b = Color.frame:GetRGB()
    else
        Color.frame:SetRGBA(frameColor.r, frameColor.g, frameColor.b, Color.frame.a)
    end
    Util.SetFrameAlpha(frameColor.a)

    local buttonColor = private.skinsDB.buttonColor
    if not buttonColor.r then
        buttonColor.r, buttonColor.g, buttonColor.b = Color.button:GetRGB()
    else
        Color.button:SetRGB(buttonColor.r, buttonColor.g, buttonColor.b)
    end

    local classColors = private.skinsDB.classColors
    if not classColors[private.charClass.token] then
        private.classColorsReset(classColors, _G.RAID_CLASS_COLORS)
    end
    private.setColorCache(classColors)

    -- Set overrides and hooks
    local C = Aurora[2]
    C.media.arrowDown = [[Interface\AddOns\RealUI_Skins\Aurora\media\arrow-down-active]]
    C.media.arrowRight = [[Interface\AddOns\RealUI_Skins\Aurora\media\arrow-right-active]]
    C.media.checked = [[Interface\AddOns\RealUI_Skins\Aurora\media\CheckButtonHilight]]
    C.media.roleIcons = [[Interface\AddOns\RealUI_Skins\Aurora\media\UI-LFG-ICON-ROLES]]

    _G.hooksecurefunc(Skin, "AzeriteEmpoweredItemUITemplate", function(Frame)
        Frame.BorderFrame.NineSlice._stripes:SetParent(Frame)
    end)

    _G.hooksecurefunc(Skin, "FrameTypeFrame", function(Frame)
        if not Frame._stripes then
            RealUI:AddFrameStripes(Frame)
        end
    end)

    _G.hooksecurefunc(Skin, "PanelTabButtonTemplate", function(Button)
        if not Button.isTopTab then
            Button:SetButtonColor(Color.frame, frameColor.a, false)
            RealUI:AddFrameStripes(Button)
        end
    end)

    _G.hooksecurefunc(private.AddOns, "Blizzard_BarbershopUI", function()
        local BarberShopFrame = _G.BarberShopFrame
        local CharCustomizeFrame = _G.CharCustomizeFrame

        BarberShopFrame.BodyTypes:SetPoint("TOP", CharCustomizeFrame, 0, -27)
        BarberShopFrame.CancelButton:SetPoint("BOTTOMLEFT", CharCustomizeFrame, 30, 15)
        -- BarberShopFrame.ResetButton - Anchored to CancelButton
        BarberShopFrame.AcceptButton:SetPoint("BOTTOMRIGHT", CharCustomizeFrame, -30, 15)
        -- BarberShopFrame.PriceFrame - Anchored to AcceptButton

        CharCustomizeFrame.Categories:ClearAllPoints()
        CharCustomizeFrame.Categories:SetPoint("RIGHT", -21, 0)
        CharCustomizeFrame.Categories:SetPoint("BOTTOM", CharCustomizeFrame.Options, "TOP", 0, 40)

        CharCustomizeFrame.Options:ClearAllPoints()
        CharCustomizeFrame.Options:SetPoint("RIGHT")
    end)

    -- Disable user selected addon skins
    for name, enabled in next, private.skinsDB.addons do
        if not name:find("RealUI") and not enabled then
            private.AddOns[name] = private.nop
        end
    end


    function private.AddOns.RealUI()
        local Skins = RealUI:NewModule("Skins")
        Skins.db = skinsDB

        if not _G.C_AddOns.IsAddOnLoaded("Ace3") then
            private.AddOns.Ace3()
        end

        -- NavBar skinning for the WorldMap is now handled entirely by the
        -- taint-safe Skin.WorldMapNavBarTemplate in Aurora's Blizzard_WorldMap
        -- skin.  Skin.NavBarTemplate uses FrameTypeButton which writes Lua
        -- functions directly onto button tables and calls HookScript, creating
        -- addon-owned state that propagates taint into the secure pin path
        -- (AcquirePin → SetPassThroughButtons).  Do NOT call it here.

        --f.f = "f" -- error for testing RealUI_Bugs
    end

    function private.AddOns.RealUI_Bugs()
        local errorFrame = _G.RealUI_ErrorFrame
        Skin.UIPanelDialogTemplate(errorFrame)
        Skin.ScrollFrameTemplate(errorFrame.ScrollFrame)
        Skin.UIPanelButtonTemplate(errorFrame.Reload)
        Skin.NavButtonPrevious(errorFrame.PreviousError)
        Skin.NavButtonNext(errorFrame.NextError)
    end
end

--[[ Copy Scale API from Aurora until the entire UI is upgraded. ]]--
function ScaleAPI.GetUIScale()
    return uiMod or 1
end

function ScaleAPI.Round(value, places)
    local mult = 10 ^ (places or 0)
    return floor(value * mult + 0.5) / mult
end

function ScaleAPI.Value(value, getFloat)
    local mult = getFloat and 100 or 1
    return floor((value * uiMod) * mult + 0.5) / mult
end

function ScaleAPI.Size(self, width, height)
    if _G.InCombatLockdown() and self.IsProtected and self:IsProtected() then
        return
    end
    if not (width and height) then
        width, height = self:GetSize()
    end
    return self:SetSize(ScaleAPI.Value(width), ScaleAPI.Value(height))
end

function ScaleAPI.Height(self, height)
    if not (height) then
        height = self:GetHeight()
    end
    return self:SetHeight(ScaleAPI.Value(height))
end

function ScaleAPI.Width(self, width)
    if not (width) then
        width = self:GetWidth()
    end
    return self:SetWidth(ScaleAPI.Value(width))
end

function ScaleAPI.Thickness(self, thickness)
    if not (thickness) then
        thickness = self:GetThickness()
    end
    return self:SetThickness(ScaleAPI.Value(thickness))
end

local ScaleArgs do
    local function pack(t, ...)
        for i = 1, _G.select("#", ...) do
            t[i] = _G.select(i, ...)
        end
    end

    local args = {}
    function ScaleArgs(self, method, ...)
        if self.debug then
            private.debug("raw args", method, ...)
        end
        _G.wipe(args)
        --[[ This function gets called A LOT, so we recycle this table
            to reduce needless garbage creation.]]
        if ... then
            pack(args, ...)
        else
            pack(args, self["Get"..method](self))
        end

        for i = 1, #args do
            if _G.type(args[i]) == "number" then
                args[i] = ScaleAPI.Value(args[i])
            end
        end
        if self.debug then
            private.debug("final args", method, _G.unpack(args))
        end
        return args
    end
end

function ScaleAPI.Point(self, ...)
    self:SetPoint(_G.unpack(ScaleArgs(self, "Point", ...)))
end

function ScaleAPI.EndPoint(self, ...)
    self:SetEndPoint(_G.unpack(ScaleArgs(self, "EndPoint", ...)))
end
function ScaleAPI.StartPoint(self, ...)
    self:SetStartPoint(_G.unpack(ScaleArgs(self, "StartPoint", ...)))
end

-- Raw methods --
local positionMethods = {
    "Size",
    "Height",
    "Width",
    "Point",
}
local mt = _G.getmetatable(_G.UIParent).__index
for _, method in next, positionMethods do
    ScaleAPI["RawSet"..method] = mt["Set"..method]
end
RealUI.Scale = ScaleAPI
