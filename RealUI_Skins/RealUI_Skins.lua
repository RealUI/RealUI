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

local moddedFrames, pixelScale = {}
local function ResetScale(frame)
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

function RealUI.GetInterfaceSize()
    return _G.GetPhysicalScreenSize()
end

local uiMod, uiScaleChanging
function RealUI.UpdateUIScale(newScale)
    if uiScaleChanging then return end

    -- https://www.reddit.com/r/wow/comments/95o2qn/how_to_pixel_perfect_ui/
    local _, pysHeight = _G.GetPhysicalScreenSize()
    uiMod = (pysHeight / 768) * (private.uiScale or 1)
    pixelScale = 768 / pysHeight
    private.debug("pixel scale", pixelScale, uiMod)

    local oldScale = private.skinsDB.customScale
    local cvarScale, parentScale = tonumber(_G.GetCVar("uiscale")), RealUI.Round(_G.UIParent:GetScale(), 2)
    private.debug("current scale", oldScale, cvarScale, parentScale)

    -- Get Scale
    if private.skinsDB.isPixelScale then
        newScale = pixelScale
    end

    if not newScale then
        newScale = oldScale
    end
    private.debug("newScale", newScale)


    local uiScale = newScale
    if private.skinsDB.isHighRes then
        uiScale = uiScale * 2
    end

    uiScaleChanging = true
    private.debug("update uiScale", uiScale)
    if cvarScale ~= uiScale then
        --[[ Setting the `uiScale` cvar will taint the ObjectiveTracker, and by extention the
            WorldMap and map action button. As such, we only use that if we absolutly have to.

            WoW CVar can't go below .64
        ]]
        _G.SetCVar("uiScale", max(uiScale, 0.64))
    end
    if parentScale ~= uiScale then
        _G.UIParent:SetScale(uiScale)
    end

    private.skinsDB.customScale = newScale
    UpdateModScale()
    uiScaleChanging = false
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
    stripes:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true, true)
    stripes:SetAlpha(private.skinsDB.stripeAlpha)
    stripes:SetAllPoints(bg)
    stripes:SetHorizTile(true)
    stripes:SetVertTile(true)
    stripes:SetBlendMode("ADD")
    Frame._stripes = stripes
end

function private.OnLoad()
    --print("OnLoad Aurora", Aurora, private.Aurora)
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
    _G.hooksecurefunc(Skin, "CharacterFrameTabButtonTemplate", function(Button)
        Button:SetButtonColor(Color.frame, frameColor.a, false)
        RealUI:AddFrameStripes(Button)
    end)

    _G.hooksecurefunc(private.AddOns, "Blizzard_BarbershopUI", function()
        local BarberShopFrame = _G.BarberShopFrame
        local CharCustomizeFrame = _G.CharCustomizeFrame

        BarberShopFrame.Sexes:SetPoint("TOP", CharCustomizeFrame, 0, -27)
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


    -- Hide default UI Scale slider and replace with RealUI button
    _G.Display_UseUIScale:Hide()
    _G.Display_UIScaleSlider:Hide()

    local scaleBtn = _G.CreateFrame("Button", "RealUIScaleBtn", _G.Display_, "UIPanelButtonTemplate")
    scaleBtn:SetSize(150, 24)
    scaleBtn:SetText("RealUI UI Scaler")
    scaleBtn:SetPoint("TOPLEFT", _G.Display_UIScaleSlider, -35, 4)
    scaleBtn:SetScript("OnClick", function()
        private.debug("UI Scale from Blizz")
        RealUI.LoadConfig("RealUI", "skins")
    end)

    function private.AddOns.nibRealUI()
        local Skins = RealUI:NewModule("Skins")
        Skins.db = skinsDB

        Skin.UIPanelButtonTemplate(scaleBtn)

        if not _G.IsAddOnLoaded("Ace3") then
            private.AddOns.Ace3()
        end

        -- Since we load Blizzard_WorldMap before RealUI_Skins, this frame is created before we
        -- get to hook the creation functions. As such, we need to run this to finish it's skin.
        Skin.NavBarTemplate(_G.WorldMapFrame.NavBar)

        --f.f = "f" -- error for testing RealUI_Bugs
    end

    function private.AddOns.RealUI_Bugs()
        local errorFrame = _G.RealUI_ErrorFrame
        Skin.UIPanelDialogTemplate(errorFrame)
        Skin.UIPanelScrollFrameTemplate(errorFrame.ScrollFrame)
        Skin.UIPanelButtonTemplate(errorFrame.Reload)
        Skin.NavButtonPrevious(errorFrame.PreviousError)
        Skin.NavButtonNext(errorFrame.NextError)
    end
end

--[[ Copy Scale API from Aurora until the entire UI is upgraded. ]]--
function ScaleAPI.GetUIScale()
    return uiMod or 1
end

function ScaleAPI.Value(value, getFloat)
    local mult = getFloat and 100 or 1
    return floor((value * uiMod) * mult + 0.5) / mult
end

function ScaleAPI.Size(self, width, height)
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
