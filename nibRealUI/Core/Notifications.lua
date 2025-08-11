-- Code from Haleth's Notifications addon
-- http://www.wowinterface.com/downloads/info21365-Notifications.html
local _, private = ...

-- RealUI --
local RealUI = private.RealUI

local bannerWidth = 450
local interval = 0.1

local hasInitialized
local f, icon, sep, title, text = _G.CreateFrame("Frame", "RealUIUINotifications", _G.UIParent)

-- Banner show/hide animations

local bannerShown = false
local timeShown = 6

local function hideBanner()
    local scale
    f:SetScript("OnUpdate", function(dialog)
        scale = dialog:GetScale() - interval
        if scale <= 0.1 then
            dialog:SetScript("OnUpdate", nil)
            dialog:Hide()
            bannerShown = false
            return
        end
        dialog:SetScale(scale)
        dialog:SetAlpha(scale)
    end)
end

local function fadeTimer()
    local last = 0
    f:SetScript("OnUpdate", function(dialog, elapsed)
        local width = f:GetWidth()
        if width > bannerWidth then
            dialog:SetWidth(width - (interval*100))
        end
        last = last + elapsed
        if last >= timeShown then
            dialog:SetWidth(bannerWidth)
            dialog:SetScript("OnUpdate", nil)
            hideBanner()
        end
    end)
end

local function showBanner()
    bannerShown = true
    f:Show()

    local scale
    f:SetScript("OnUpdate", function(dialog)
        scale = dialog:GetScale() + interval
        if scale >= 1 then
            dialog:SetScale(1)
            dialog:SetScript("OnUpdate", nil)
            fadeTimer()
        else
            dialog:SetScale(scale)
            dialog:SetAlpha(scale)
        end
    end)
end

-- Display a notification

local function display(name, message, clickFunc, texture, ...)
    if _G.type(clickFunc) == "function" then
        f.clickFunc = clickFunc
    else
        f.clickFunc = nil
    end

    if texture then
        local info = _G.C_Texture.GetAtlasInfo(texture)
        local file
        if info then
            file = info.filename or info.file
        end

        if file then
            icon:SetAtlas(texture)
        else
            icon:SetTexture(texture)

            if ... then
                icon:SetTexCoord(...)
            else
                icon:SetTexCoord(.08, .92, .08, .92)
            end
        end
    else
        icon:SetTexture("Interface\\Icons\\achievement_general")
        icon:SetTexCoord(.08, .92, .08, .92)
    end

    title:SetText(name)
    text:SetText(message)

    showBanner()
end

-- Handle incoming notifications

local handler = _G.CreateFrame("Frame")
local incoming = {}
local processing = false

local function handleIncoming()
    processing = true
    local i = 1

    handler:SetScript("OnUpdate", function(dialog)
        if incoming[i] == nil then
            dialog:SetScript("OnUpdate", nil)
            incoming = {}
            processing = false
            return
        else
            if not bannerShown then
                display(_G.unpack(incoming[i]))
                i = i + 1
            end
        end
    end)
end

handler:SetScript("OnEvent", function(dialog, _, unit)
    if unit == "player" and not _G.UnitIsAFK("player") then
        handleIncoming()
        dialog:UnregisterEvent("PLAYER_FLAGS_CHANGED")
    end
end)

-- The API show function

function RealUI:Notification(name, showWhileAFK, message, clickFunc, texture, ...)
    if not hasInitialized then self:InitNotifications() end
    if _G.UnitIsAFK("player") and not showWhileAFK then
        _G.tinsert(incoming, {name, message, clickFunc, texture, ...})
        handler:RegisterEvent("PLAYER_FLAGS_CHANGED")
    elseif bannerShown or #incoming ~= 0 then
        if (#incoming < 2) then
            _G.tinsert(incoming, {name, message, clickFunc, texture, ...})
            if not processing then
                handleIncoming()
            end
        end
    else
        display(name, message, clickFunc, texture, ...)
    end
end

-- Mouse events

local function expand(dialog)
    local width = dialog:GetWidth()

    if text:IsTruncated() and width < (_G.GetScreenWidth() / 1.5) then
        dialog:SetWidth(width+(interval*100))
    else
        dialog:SetScript("OnUpdate", nil)
    end
end

f:SetScript("OnEnter", function(dialog)
    dialog:SetScript("OnUpdate", nil)
    dialog:SetScale(1)
    self:SetAlpha(1)
    self:SetScript("OnUpdate", expand)
end)

f:SetScript("OnLeave", fadeTimer)

f:SetScript("OnMouseUp", function(dialog, button)
    dialog:SetScript("OnUpdate", nil)
    dialog:Hide()
    dialog:SetScale(0.1)
    dialog:SetAlpha(0.1)
    bannerShown = false
    -- right click just hides the banner
    if button ~= "RightButton" and f.clickFunc then
        f.clickFunc()
    end

    -- dismiss all
    if _G.IsShiftKeyDown() then
        handler:SetScript("OnUpdate", nil)
        incoming = {}
        processing = false
    end
end)

-- Initialize
function RealUI:InitNotifications()
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetSize(bannerWidth, 50)
    f:SetPoint("TOP", _G.UIParent, "TOP")
    f:Hide()
    f:SetAlpha(0.1)
    f:SetScale(0.1)
    _G.Aurora.Skin.FrameTypeFrame(f)

    icon = f:CreateTexture(nil, "OVERLAY")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", f, "LEFT", 5, 0)

    sep = f:CreateTexture(nil, "BACKGROUND")
    sep:SetSize(1, 50)
    sep:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    sep:SetColorTexture(0, 0, 0)

    title = f:CreateFontString(nil, "OVERLAY")
    title:SetFontObject("Fancy16Font")
    title:SetPoint("TOPLEFT", sep, "TOPRIGHT", 5, -5)
    title:SetPoint("BOTTOMRIGHT", f, -5, 30)
    title:SetJustifyH("LEFT")

    text = f:CreateFontString(nil, "OVERLAY")
    text:SetFontObject("SystemFont_Shadow_Med1")
    text:SetPoint("TOPLEFT", sep, "BOTTOMRIGHT", 5, 30)
    text:SetPoint("BOTTOMRIGHT", f, -5, 5)
    text:SetJustifyH("LEFT")

    hasInitialized = true
end
