local _, private = ...

-- Lua Globals --
local _G = _G
local min, max, floor = _G.math.min, _G.math.max, _G.math.floor
local tinsert, tsort = _G.table.insert, _G.table.sort
local next, type, select = _G.next, _G.type, _G.select
local print, tonumber = _G.print, _G.tonumber

-- Libs --
local F = _G.Aurora[1]

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local debug = RealUI.GetDebug("Fun")


-- Misc Functions
local spellFinder = _G.CreateFrame("FRAME")
function RealUI:FindSpellID(spellName, affectedUnit, auraType)
    print(("RealUI is now looking for %s %s: %s."):format(affectedUnit, auraType, spellName))
    spellFinder:RegisterUnitEvent("UNIT_AURA", affectedUnit)
    spellFinder:SetScript("OnEvent", function(frame, event, unit)
        local spellID
        if auraType == "debuff" then
            spellID = select(11, _G.UnitDebuff(unit, spellName))
        else
            spellID = select(11, _G.UnitBuff(unit, spellName))
        end
        if spellID then
            print(("The spellID for %s is %d"):format(spellName, spellID));
            frame:UnregisterEvent("UNIT_AURA")
        end
    end)
end

-- Memory Display
local function FormatMem(memory)
    if ( memory > 999 ) then
        return ("%.1f |cff%s%s|r"):format(memory/1024, "ff8030", "MiB")
    else
        return ("%.1f |cff%s%s|r"):format(memory, "80ff30", "KB")
    end
end
function RealUI:MemoryDisplay()
    local addons, total = {}, 0
    _G.UpdateAddOnMemoryUsage()

    for i = 1, _G.GetNumAddOns() do
        if ( _G.IsAddOnLoaded(i) ) then
            local memUsage = _G.GetAddOnMemoryUsage(i)
            tinsert(addons, { _G.GetAddOnInfo(i), memUsage })
            total = total + memUsage
        end
    end

    tsort(addons, (function(a, b) return a[2] > b[2] end))

    local userMem = ("|cff00ffffMemory usage: |r%.1f |cffff8030%s|r"):format(total/1024, "MiB")
    print(userMem)
    print("-------------------------------")
    for key, val in next, addons do
        if ( key <= 20 ) then
            print(FormatMem(val[2]).."  -  "..val[1])
        end
    end
end

-- Display Dialog
_G.StaticPopupDialogs["PUDRUIRELOADUI"] = {
    text = L["DoReloadUI"],
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        _G.ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    notClosableByLogout = false,
}
function RealUI:ReloadUIDialog()
    _G.StaticPopup_Show("PUDRUIRELOADUI")
end

do -- Screen Height + Width
    function RealUI:GetResolutionVals(raw)
        local resolution
        if RealUI.isBeta then
            local windowed, fullscreen = _G.GetCVar("gxwindowedresolution"), _G.GetCVar("gxfullscreenresolution")
            resolution = windowed ~= fullscreen and windowed or fullscreen
        else
            resolution = _G.GetCVar("gxResolution")
        end
        local resWidth, resHeight = resolution:match("(%d+)x(%d+)")
        resWidth, resHeight = tonumber(resWidth), tonumber(resHeight)

        if raw then
            return resWidth, resHeight
        end

        if self.db.global.tags.retinaDisplay.checked and self.db.global.tags.retinaDisplay.set then
            resHeight = resHeight / 2
            resWidth = resWidth / 2
        end

        return resWidth, resHeight
    end
end

-- Deep Copy table
function RealUI:DeepCopy(object)
    local lookup_table = {}
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_table[obj] then
            return lookup_table[obj]
        end
        local new_table = {}
        lookup_table[obj] = new_table
        for index, value in next, obj do
            new_table[_copy(index)] = _copy(value)
        end
        return _G.setmetatable(new_table, _G.getmetatable(obj))
    end
    return _copy(object)
end

-- Loot Spec
function RealUI:GetCurrentLootSpecName()
    local lsID = _G.GetLootSpecialization()

    if (lsID == 0) then
        local _, specName = _G.GetSpecializationInfo(_G.GetSpecialization())
        return specName
    else
        local _, specName = _G.GetSpecializationInfoByID(lsID)
        return specName
    end
end

function RealUI:GetLootSpecData(LootSpecIDs)
    for i = 1, _G.GetNumSpecializations() do
        LootSpecIDs[i] = _G.GetSpecializationInfo(i)
    end
    return LootSpecIDs
end

-- Math
local Lerp, Clamp
if RealUI.isBeta then
    Lerp, Clamp = _G.Lerp, _G.Clamp
else
    function Lerp(startValue, endValue, amount)
        return (1 - amount) * startValue + amount * endValue;
    end

    function Clamp(value, minVal, maxVal)
        if value < minVal then
            value = minVal
        elseif value > maxVal then
            value = maxVal
        elseif value ~= value or not (value >= minVal and value <= maxVal) then -- check for nan...
            value = minVal
        end

        return value
    end
end
RealUI.Lerp, RealUI.Clamp = Lerp, Clamp

-- Seconds to Time
function RealUI:ConvertSecondstoTime(value, onlyOne)
    local hours, minutes, seconds
    hours = floor(value / 3600)
    minutes = floor((value - (hours * 3600)) / 60)
    seconds = floor(value - ((hours * 3600) + (minutes * 60)))

    if ( hours > 0 ) then
        if onlyOne then
            return ("%dh"):format(hours)
        else
            return ("%dh %dm"):format(hours, minutes)
        end
    elseif ( minutes > 0 ) then
        if ( minutes >= 10 ) or onlyOne then
            return ("%dm"):format(minutes)
        else
            return ("%dm %ds"):format(minutes, seconds)
        end
    else
        return ("%ds"):format(seconds)
    end
end

-- Draggable Window
local function MouseDownHandler(frame, button)
    if frame and button == "LeftButton" then
        frame:StartMoving()
        frame:SetUserPlaced(false)
    end
end
local function MouseUpHandler(frame, button)
    if frame and button == "LeftButton" then
        frame:StopMovingOrSizing()
    end
end
function RealUI:HookScript(frame, script, handler)
    if not frame.GetScript then return end
    local oldHandler = frame:GetScript(script)
    if oldHandler then
        frame:SetScript(script, function(...)
            handler(...)
            oldHandler(...)
        end)
    else
        frame:SetScript(script, handler)
    end
end
function RealUI:MakeFrameDraggable(frame)
    frame:SetMovable(true)
    frame:SetClampedToScreen(false)
    frame:EnableMouse(true)
    self:HookScript(frame, "OnMouseDown", MouseDownHandler)
    self:HookScript(frame, "OnMouseUp", MouseUpHandler)
end

-- Frames
local function ReskinSlider(f)
    f:SetBackdrop(nil)
    local bd = _G.CreateFrame("Frame", nil, f)
    bd:SetPoint("TOPLEFT", -23, 0)
    bd:SetPoint("BOTTOMRIGHT", 23, 0)
    bd:SetFrameStrata("BACKGROUND")
    bd:SetFrameLevel(f:GetFrameLevel()-1)

    RealUI:CreateBD(bd, 0)
    f.bg = RealUI:CreateInnerBG(bd)
    f.bg:SetVertexColor(1, 1, 1, 0.6)

    local slider = select(4, f:GetRegions())
    slider:SetTexture([[Interface\AddOns\nibRealUI\Media\HuDConfig\SliderPos]])
    slider:SetSize(16, 16)
    slider:SetBlendMode("ADD")

    for i = 1, f:GetNumRegions() do
        local region = select(i, f:GetRegions())
        if region:GetObjectType() == "FontString" then
            region:SetFontObject(_G.RealUIFont_PixelSmall)
            if region:GetText() == _G.LOW then
                region:ClearAllPoints()
                region:SetPoint("BOTTOMLEFT", bd, "BOTTOMLEFT", 3.5, 4.5)
                region:SetTextColor(0.75, 0.75, 0.75)
                region:SetShadowColor(0, 0, 0, 0)
            elseif region:GetText() == _G.HIGH then
                region:ClearAllPoints()
                region:SetPoint("BOTTOMRIGHT", bd, "BOTTOMRIGHT", 1.5, 4.5)
                region:SetTextColor(0.75, 0.75, 0.75)
                region:SetShadowColor(0, 0, 0, 0)
            else
                region:SetTextColor(0.9, 0.9, 0.9)
            end
        end
    end
end

function RealUI:CreateSlider(name, parent, minVal, maxVal, title, step)
    local f = _G.CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    f:SetFrameLevel(parent:GetFrameLevel() + 2)
    f:SetSize(180, 17)
    f:SetMinMaxValues(minVal, maxVal)
    f:SetValue(0)
    f:SetValueStep(step)
    f.header = RealUI:CreateFS(f, "CENTER", "small")
    f.header:SetPoint("BOTTOM", f, "TOP", 0, 4)
    f.header:SetText(title)
    f.value = RealUI:CreateFS(f, "CENTER", "small")
    f.value:SetPoint("TOP", f, "BOTTOM", 1, -4)
    f.value:SetText(f:GetValue())

    local sbg = _G.CreateFrame("Frame", nil, f)
    sbg:SetPoint("TOPLEFT", f, "TOPLEFT", 2, 0)
    sbg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 0)
    RealUI:CreateBD(sbg)
    sbg:SetBackdropColor(0.8, 0.8, 0.8, 0.15)
    sbg:SetFrameLevel(f:GetFrameLevel() - 1)

    ReskinSlider(f)

    return f
end

function RealUI:CreateCheckbox(name, parent, label, side, size)
    local f = _G.CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
    f:SetSize(size, size)
    f:SetHitRectInsets(0,0,0,0)
    f:SetFrameLevel(parent:GetFrameLevel() + 2)
    f.type = "checkbox"

    f.text = _G[f:GetName() .. "Text"]
    f.text:SetFontObject(_G.RealUIFont_Normal)
    f.text:SetTextColor(1, 1, 1)
    f.text:SetText(label)
    f.text:ClearAllPoints()
    if side == "LEFT" then
        f.text:SetPoint("RIGHT", f, "LEFT", -4, 0)
        f.text:SetJustifyH("RIGHT")
    else
        f.text:SetPoint("LEFT", f, "RIGHT", 4, 0)
        f.text:SetJustifyH("LEFT")
    end

    local cbg = _G.CreateFrame("Frame", nil, f)
    cbg:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
    cbg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
    RealUI:CreateBD(cbg)
    cbg:SetBackdropColor(0.8, 0.8, 0.8, 0.15)
    cbg:SetFrameLevel(f:GetFrameLevel() - 1)

    if F and F.ReskinCheck then
        F.ReskinCheck(f)
    end

    return f
end

function RealUI:CreateTextButton(text, parent, template, width, height, small)
    if not template then template = "UIPanelButtonTemplate" end
    if (type(template) ~= "string") then
        template, width, height, small = "UIPanelButtonTemplate", template, width, height
    end
    local f = _G.CreateFrame("Button", nil, parent, template)

    f:SetFrameLevel(parent:GetFrameLevel() + 2)
    if small then
        f:SetNormalFontObject(_G.RealUIFont_Normal)
        f:SetHighlightFontObject(_G.RealUIFont_Normal)
    else
        f:SetNormalFontObject(_G.GameFontHighlight)
        f:SetHighlightFontObject(_G.GameFontHighlight)
    end
    if width then
        f:SetSize(width, height)
    end
    f:SetText(text)

    if F and F.Reskin then
        F.Reskin(f)
    end

    return f
end

function RealUI:CreateWindow(name, width, height, closeOnEsc, draggable, hideCloseButton)
    local f = _G.CreateFrame("Frame", name, _G.UIParent)
        f:SetPoint("CENTER", _G.UIParent, "CENTER", 0, 0)
        f:SetSize(width, height)
        f:SetFrameStrata("DIALOG")
        if draggable then
            RealUI:MakeFrameDraggable(f)
            f:SetClampedToScreen(true)
            f:SetFrameLevel(10)
        else
            f:SetFrameLevel(5)
        end

    if closeOnEsc then
        tinsert(_G.UISpecialFrames, name)
        if not hideCloseButton then
            f.close = _G.CreateFrame("Button", nil, f, "UIPanelCloseButton")
            f.close:SetPoint("TOPRIGHT", 6, 4)
            f.close:SetScript("OnClick", function(button) button:GetParent():Hide() end)
            if F and F.ReskinClose then
                F.ReskinClose(f.close)
            end
        end
    end

    RealUI:CreateBD(f, nil, true, true)

    return f
end

function RealUI:AddButtonHighlight(button)
    -- Button Highlight
    local highlight = _G.CreateFrame("Frame", nil, button)
    highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
    highlight:SetWidth(button:GetWidth() - 2)
    highlight:SetHeight(button:GetHeight() - 2)
    highlight:SetBackdrop({
        bgFile = RealUI.media.textures.plain,
        edgeFile = RealUI.media.textures.plain,
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    highlight:SetBackdropColor(0,0,0,0)
    highlight:SetBackdropBorderColor(self.classColor[1], self.classColor[2], self.classColor[3], self.classColor[4])
end

function RealUI:SkinButton(button, icon, border)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetPoint("TOPLEFT", 3, -3)
    icon:SetPoint("BOTTOMRIGHT", -3, 3)

    border:SetTexture(nil)

    local bd1 = _G.CreateFrame("Frame", nil, button)
    bd1:SetPoint("TOPLEFT", button, 2, -2)
    bd1:SetPoint("BOTTOMRIGHT", button, -2, 2)
    bd1:SetFrameLevel(1)
    RealUI:CreateBD(bd1, 0)

    local bd2 = _G.CreateFrame("Frame", nil, button)
    bd2:SetPoint("TOPLEFT", button, 0, 0)
    bd2:SetPoint("BOTTOMRIGHT", button, 0, 0)
    bd2:SetFrameLevel(1)
    RealUI:CreateBD(bd2)
end

function RealUI:CreateBD(frame, alpha, stripes, windowColor)
    local bdColor
    frame:SetBackdrop({
        bgFile = RealUI.media.textures.plain,
        edgeFile = RealUI.media.textures.plain,
        edgeSize = 1,
    })
    if windowColor then
        bdColor = RealUI.media.window
        tinsert(_G.REALUI_WINDOW_FRAMES, frame)
    else
        bdColor = RealUI.media.background
    end
    frame:SetBackdropColor(bdColor[1], bdColor[2], bdColor[3], bdColor[4])
    frame:SetBackdropBorderColor(0, 0, 0)

    if stripes then
        self:AddStripeTex(frame)
    end
end

function RealUI:CreateBDFrame(frame, alpha, stripes, windowColor)
    local f
    if frame:GetObjectType() == "Texture" then
        f = frame:GetParent()
    else
        f = frame
    end

    local lvl = f:GetFrameLevel()

    local bg = _G.CreateFrame("Frame", nil, f)
    bg:SetParent(f)
    bg:SetPoint("TOPLEFT", f, -1, 1)
    bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
    bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

    RealUI:CreateBD(bg, alpha, stripes, windowColor)

    return bg
end

function RealUI:CreateBG(frame, alpha)
    local f = frame
    if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", frame, -1, 1)
    bg:SetPoint("BOTTOMRIGHT", frame, 1, -1)
    bg:SetTexture(RealUI.media.textures.plain)
    bg:SetVertexColor(0, 0, 0, alpha)

    return bg
end

function RealUI:CreateBGSection(parent, f1, f2, ...)
    -- Button Backgrounds
    local x1, y1, x2, y2 = -2, 2, 2, -2
    if ... then
        x1, y1, x2, y2 = ...
    end
    local Sect1 = _G.CreateFrame("Frame", nil, parent)
    Sect1:SetPoint("TOPLEFT", f1, "TOPLEFT", x1, y1)
    Sect1:SetPoint("BOTTOMRIGHT", f2, "BOTTOMRIGHT", x2, y2)
    RealUI:CreateBD(Sect1)
    Sect1:SetBackdropColor(0.8, 0.8, 0.8, 0.15)
    Sect1:SetFrameLevel(parent:GetFrameLevel() + 1)

    return Sect1
end

function RealUI:CreateInnerBG(frame)
    local f = frame
    if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", frame, 1, -1)
    bg:SetPoint("BOTTOMRIGHT", frame, -1, 1)
    bg:SetTexture(RealUI.media.textures.plain)
    bg:SetVertexColor(0, 0, 0, 0)

    return bg
end

function RealUI:AddStripeTex(parent)
    local stripeTex = parent:CreateTexture(nil, "BACKGROUND", nil, 1)
        stripeTex:SetAllPoints()
        stripeTex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true)
        stripeTex:SetAlpha(_G.RealUI_InitDB.stripeOpacity)
        stripeTex:SetHorizTile(true)
        stripeTex:SetVertTile(true)
        stripeTex:SetBlendMode("ADD")

    tinsert(_G.REALUI_STRIPE_TEXTURES, stripeTex)

    return stripeTex
end

function RealUI:CreateFS(parent, justify, size)
    local f = parent:CreateFontString(nil, "OVERLAY")

    if size == "small" then
        f:SetFontObject(_G.RealUIFont_PixelSmall)
    elseif size == "large" then
        f:SetFontObject(_G.RealUIFont_PixelLarge)
    else
        f:SetFontObject(_G.RealUIFont_Pixel)
    end
    f:SetShadowColor(0, 0, 0, 0)
    if justify then f:SetJustifyH(justify) end

    return f
end

-- Formatting
function RealUI:AbbreviateName(name, maxLength)
    if not name then return "" end

    local maxNameLength = maxLength or 12
    local newName = (name:utf8len() > maxNameLength) and name:gsub("%s?(..[\128-\191]*)%S+%s", "%1. ") or name

    if (newName:utf8len() > maxNameLength) then
        newName = newName:utf8sub(1, maxNameLength)
        newName = newName..".."
    end
    return newName
end

local function FormatToDecimalPlaces(num, places)
    local placeValue = ("%%.%df"):format(places)
    return placeValue:format(num)
end
function RealUI:ReadableNumber(num, places)
    local ret
    if not num then
        return 0
    elseif num >= 100000000 then
        ret = FormatToDecimalPlaces(num / 1000000, places or 0) .. "m" -- hundred million
    elseif num >= 10000000 then
        ret = FormatToDecimalPlaces(num / 1000000, places or 1) .. "m" -- ten million
    elseif num >= 1000000 then
        ret = FormatToDecimalPlaces(num / 1000000, places or 2) .. "m" -- million
    elseif num >= 100000 then
        ret = FormatToDecimalPlaces(num / 1000, places or 0) .. "k" -- hundred thousand
    elseif num >= 10000 then
        ret = FormatToDecimalPlaces(num / 1000, places or 1) .. "k" -- ten thousand
    elseif num >= 1000 then
        ret = FormatToDecimalPlaces(num / 1000, places or 2) .. "k" -- thousand
    else
        ret = FormatToDecimalPlaces(num, places or 0) -- hundreds
    end
    return ret
end

-- Opposite Faction
function RealUI:OtherFaction(f)
    if (f == "Horde") then
        return "Alliance"
    else
        return "Horde"
    end
end

-- Validate Offset
function RealUI:ValidateOffset(value, ...)
    local val = tonumber(value)
    local vmin, vmax = -5000, 5000
    if ... then vmin, vmax = ... end
    if val == nil then val = 0 end
    val = max(val, vmin)
    val = min(val, vmax)
    return val
end

-- Colors
local ilvlLimits = 385
function RealUI:GetILVLColor(lvl, ilvl)
    if lvl > 90 then
        ilvlLimits = (lvl - 91) * 9 + 510
    end
    if ilvl >= ilvlLimits + 28 then
        return _G.ITEM_QUALITY_COLORS[4] -- epic
    elseif ilvl >= ilvlLimits + 14 then
        return _G.ITEM_QUALITY_COLORS[3] -- rare
    elseif ilvl >= ilvlLimits then
        return _G.ITEM_QUALITY_COLORS[2] -- uncommon
    else
        return _G.ITEM_QUALITY_COLORS[1] -- common
    end
end

function RealUI:GetClassColor(class, ...)
    if not _G.RAID_CLASS_COLORS[class] then return {1, 1, 1} end
    local classColors = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)[class]
    if ... then
        return {r = classColors.r, g = classColors.g, b = classColors.b}
    else
        return {classColors.r, classColors.g, classColors.b}
    end
end


--[[
All color functions assume arguments are within the range 0.0 - 1.0

Conversion functions based on code from
https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
]]
do -- RealUI:HSLToRGB
    local function HueToRBG(p, q, t)
        if t < 0   then t = t + 1 end
        if t > 1   then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end
    function RealUI:HSLToRGB(h, s, l, a)
        debug("HSLToRGB", h, s, l, a)
        local r, g, b

        if s <= 0 then
            return l, l, l, a -- achromatic
        else
            local q
            q = l < 0.5 and l * (1 + s) or l + s - l * s
            local p = 2 * l - q

            r = HueToRBG(p, q, h + 1/3)
            g = HueToRBG(p, q, h)
            b = HueToRBG(p, q, h - 1/3)
        end

        return r, g, b, a
    end
end

function RealUI:RGBToHSL(r, g, b)
    if type(r) == "table" then
        r, g, b = r.r or r[1], r.g or r[2], r.b or r[3]
    end
    debug("RGBToHSL", r, g, b)
    local minVal, maxVal = min(r, g, b), max(r, g, b)
    local h, s, l

    l = (maxVal + minVal) / 2
    if maxVal == minVal then
        h, s = 0, 0 -- achromatic
    else
        local d = maxVal - minVal
        s = l > 0.5 and d / (2 - maxVal - minVal) or d / (maxVal + minVal)
        if maxVal == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif maxVal == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, l
end

function RealUI:ColorShift(delta, r, g, b)
    debug("ColorShift", delta, r, g, b)
    local h, s, l = self:RGBToHSL(r, g, b)
    local r2, g2, b2 = self:HSLToRGB(h + delta, s, l)
    if type(r) == "table" then
        if r.r then
            r.r, r.g, r.b = r2, g2, b2
        else
            r[1], r[2], r[3] = r2, g2, b2
        end
        return r
    else
        return r2, g2, b2
    end
end

function RealUI:ColorLighten(delta, r, g, b)
    debug("ColorLighten", delta, r, g, b)
    local h, s, l = self:RGBToHSL(r, g, b)
    local r2, g2, b2 = self:HSLToRGB(h, s, Clamp(l + delta, 0, 1))
    if type(r) == "table" then
        if r.r then
            r.r, r.g, r.b = r2, g2, b2
        else
            r[1], r[2], r[3] = r2, g2, b2
        end
        return r
    else
        return r2, g2, b2
    end
end

function RealUI:ColorSaturate(delta, r, g, b)
    debug("ColorSaturate", delta, r, g, b)
    local h, s, l = self:RGBToHSL(r, g, b)
    local r2, g2, b2 = self:HSLToRGB(h, Clamp(s + delta, 0, 1), l)
    if type(r) == "table" then
        if r.r then
            r.r, r.g, r.b = r2, g2, b2
        else
            r[1], r[2], r[3] = r2, g2, b2
        end
        return r
    else
        return r2, g2, b2
    end
end

function RealUI:ColorDarken(delta, r, g, b)
    debug("ColorDarken", delta, r, g, b)
    return self:ColorLighten(-delta, r, g, b)
end

function RealUI:ColorDesaturate(delta, r, g, b)
    debug("ColorDesaturate", delta, r, g, b)
    return self:ColorSaturate(-delta, r, g, b)
end
