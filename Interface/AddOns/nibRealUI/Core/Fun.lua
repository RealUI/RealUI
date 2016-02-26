-- Lua Globals --
local _G = _G
local min, max, abs, floor = _G.math.min, _G.math.max, _G.math.abs, _G.math.floor
local tinsert, tsort = _G.table.insert, _G.table.sort
local next, type, select = _G.next, _G.type, _G.select
local print, tonumber = _G.print, _G.tonumber

-- WoW Globals --
local CreateFrame, GameFontHighlight = _G.CreateFrame, _G.GameFontHighlight
local ITEM_QUALITY_COLORS, RAID_CLASS_COLORS = _G.ITEM_QUALITY_COLORS, _G.RAID_CLASS_COLORS

-- Libs --
local LSM = LibStub("LibSharedMedia-3.0")
local F = Aurora[1]

-- RealUI --
local nibRealUI =  LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local RealUIFont_PixelSmall, RealUIFont_PixelLarge = _G.RealUIFont_PixelSmall, _G.RealUIFont_PixelLarge
local RealUIFont_Normal, RealUIFont_Pixel = _G.RealUIFont_Normal, _G.RealUIFont_Pixel
local L = nibRealUI.L


-- Misc Functions
local spellFinder = CreateFrame("FRAME")
function nibRealUI:FindSpellID(spellName, affectedUnit, auraType)
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
function nibRealUI:MemoryDisplay()
    local addons, total = {}, 0
    _G.UpdateAddOnMemoryUsage()
    local memory = _G.gcinfo()

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
StaticPopupDialogs["PUDRUIRELOADUI"] = {
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
function nibRealUI:ReloadUIDialog()
    _G.StaticPopup_Show("PUDRUIRELOADUI")
end

-- Screen Height + Width
function nibRealUI:GetResolutionVals()
    local resStr = _G.GetCVar("gxResolution")
    local resHeight = tonumber(resStr:match("%d+x(%d+)"))
    local resWidth = tonumber(resStr:match("(%d+)x%d+"))

    if self.db.global.tags.retinaDisplay.checked and self.db.global.tags.retinaDisplay.set then
        resHeight = resHeight / 2
        resWidth = resWidth / 2
    end

    return resWidth, resHeight
end

-- Deep Copy table
function nibRealUI:DeepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in next, object do
            new_table[_copy(index)] = _copy(value)
        end
        return _G.setmetatable(new_table, _G.getmetatable(object))
    end
    return _copy(object)
end

-- Loot Spec
function nibRealUI:GetCurrentLootSpecName()
    local lsID = _G.GetLootSpecialization()
    local sID, specName = _G.GetSpecializationInfo(_G.GetSpecialization())

    if (lsID == 0) then
        return specName
    else
        local _, spName = _G.GetSpecializationInfoByID(lsID)
        return spName
    end
end

function nibRealUI:GetLootSpecData()
    local LootSpecIDs = {}
    local LootSpecClass
    local _, _, idClass = _G.UnitClass("player")
    if (idClass == 1) then
        LootSpecIDs[1] = 71
        LootSpecIDs[2] = 72
        LootSpecIDs[3] = 73
        LootSpecIDs[4] = 0
        LootSpecClass = 1
    elseif (idClass == 2) then
        LootSpecIDs[1] = 65
        LootSpecIDs[2] = 66
        LootSpecIDs[3] = 70
        LootSpecIDs[4] = 0
        LootSpecClass = 2
    elseif (idClass == 3) then
        LootSpecIDs[1] = 253
        LootSpecIDs[2] = 254
        LootSpecIDs[3] = 255
        LootSpecIDs[4] = 0
        LootSpecClass = 3
    elseif (idClass == 4) then
        LootSpecIDs[1] = 259
        LootSpecIDs[2] = 260
        LootSpecIDs[3] = 261
        LootSpecIDs[4] = 0
        LootSpecClass = 4
    elseif (idClass == 5) then
        LootSpecIDs[1] = 256
        LootSpecIDs[2] = 257
        LootSpecIDs[3] = 258
        LootSpecIDs[4] = 0
        LootSpecClass = 5
    elseif (idClass == 6) then
        LootSpecIDs[1] = 250
        LootSpecIDs[2] = 251
        LootSpecIDs[3] = 252
        LootSpecIDs[4] = 0
        LootSpecClass = 6
    elseif (idClass == 7) then
        LootSpecIDs[1] = 262
        LootSpecIDs[2] = 263
        LootSpecIDs[3] = 264
        LootSpecIDs[4] = 0
        LootSpecClass = 7
    elseif (idClass == 8) then
        LootSpecIDs[1] = 62
        LootSpecIDs[2] = 63
        LootSpecIDs[3] = 64
        LootSpecIDs[4] = 0
        LootSpecClass = 8
    elseif (idClass == 9) then
        LootSpecIDs[1] = 265
        LootSpecIDs[2] = 266
        LootSpecIDs[3] = 267
        LootSpecIDs[4] = 0
        LootSpecClass = 9
    elseif (idClass == 10) then
        LootSpecIDs[1] = 268
        LootSpecIDs[2] = 270
        LootSpecIDs[3] = 269
        LootSpecIDs[4] = 0
        LootSpecClass = 10
    elseif (idClass == 11) then
        LootSpecIDs[1] = 102
        LootSpecIDs[2] = 103
        LootSpecIDs[3] = 104
        LootSpecIDs[4] = 105
        LootSpecClass = 11
    end
    return LootSpecIDs, LootSpecClass
end

-- Math
function nibRealUI.Lerp(startValue, endValue, amount)
    return (1 - amount) * startValue + amount * endValue;
end

function nibRealUI:Clamp(value, min, max)
    if value < min then
        value = min
    elseif value > max then
        value = max
    elseif value ~= value or not (value >= min and value <= max) then -- check for nan...
        value = min
    end

    return value
end

-- Seconds to Time
function nibRealUI:ConvertSecondstoTime(value, onlyOne)
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
function nibRealUI:HookScript(frame, script, handler)
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
function nibRealUI:MakeFrameDraggable(frame)
    frame:SetMovable(true)
    frame:SetClampedToScreen(false)
    frame:EnableMouse(true)
    self:HookScript(frame, "OnMouseDown", MouseDownHandler)
    self:HookScript(frame, "OnMouseUp", MouseUpHandler)
end

-- Frames
local function ReskinSlider(f)
    f:SetBackdrop(nil)
    local bd = CreateFrame("Frame", nil, f)
    bd:SetPoint("TOPLEFT", -23, 0)
    bd:SetPoint("BOTTOMRIGHT", 23, 0)
    bd:SetFrameStrata("BACKGROUND")
    bd:SetFrameLevel(f:GetFrameLevel()-1)

    nibRealUI:CreateBD(bd, 0)
    f.bg = nibRealUI:CreateInnerBG(bd)
    f.bg:SetVertexColor(1, 1, 1, 0.6)

    local slider = select(4, f:GetRegions())
    slider:SetTexture("Interface\\AddOns\\nibRealUI\\Media\\HuDConfig\\SliderPos")
    slider:SetSize(16, 16)
    slider:SetBlendMode("ADD")

    for i = 1, f:GetNumRegions() do
        local region = select(i, f:GetRegions())
        if region:GetObjectType() == "FontString" then
            region:SetFontObject(RealUIFont_PixelSmall)
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

function nibRealUI:CreateSlider(name, parent, min, max, title, step)
    local f = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    f:SetFrameLevel(parent:GetFrameLevel() + 2)
    f:SetSize(180, 17)
    f:SetMinMaxValues(min, max)
    f:SetValue(0)
    f:SetValueStep(step)
    f.header = nibRealUI:CreateFS(f, "CENTER", "small")
    f.header:SetPoint("BOTTOM", f, "TOP", 0, 4)
    f.header:SetText(title)
    f.value = nibRealUI:CreateFS(f, "CENTER", "small")
    f.value:SetPoint("TOP", f, "BOTTOM", 1, -4)
    f.value:SetText(f:GetValue())

    local sbg = CreateFrame("Frame", nil, f)
    sbg:SetPoint("TOPLEFT", f, "TOPLEFT", 2, 0)
    sbg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 0)
    nibRealUI:CreateBD(sbg)
    sbg:SetBackdropColor(0.8, 0.8, 0.8, 0.15)
    sbg:SetFrameLevel(f:GetFrameLevel() - 1)

    ReskinSlider(f)

    return f
end

function nibRealUI:CreateCheckbox(name, parent, label, side, size)
    local f = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
    f:SetSize(size, size)
    f:SetHitRectInsets(0,0,0,0)
    f:SetFrameLevel(parent:GetFrameLevel() + 2)
    f.type = "checkbox"

    f.text = _G[f:GetName() .. "Text"]
    f.text:SetFontObject(RealUIFont_Normal)
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

    local cbg = CreateFrame("Frame", nil, f)
    cbg:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
    cbg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
    nibRealUI:CreateBD(cbg)
    cbg:SetBackdropColor(0.8, 0.8, 0.8, 0.15)
    cbg:SetFrameLevel(f:GetFrameLevel() - 1)

    if F and F.ReskinCheck then
        F.ReskinCheck(f)
    end

    return f
end

function nibRealUI:CreateTextButton(text, parent, template, width, height, small)
    if not template then template = "UIPanelButtonTemplate" end
    if (type(template) ~= "string") then
        template, width, height, small = "UIPanelButtonTemplate", template, width, height
    end
    local f = CreateFrame("Button", nil, parent, template)

    f:SetFrameLevel(parent:GetFrameLevel() + 2)
    if small then
        f:SetNormalFontObject(RealUIFont_Normal)
        f:SetHighlightFontObject(RealUIFont_Normal)
    else
        f:SetNormalFontObject(GameFontHighlight)
        f:SetHighlightFontObject(GameFontHighlight)
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

function nibRealUI:CreateWindow(name, width, height, closeOnEsc, draggable, hideCloseButton)
    local f = CreateFrame("Frame", name, _G.UIParent)
        f:SetPoint("CENTER", _G.UIParent, "CENTER", 0, 0)
        f:SetSize(width, height)
        f:SetFrameStrata("DIALOG")
        if draggable then
            nibRealUI:MakeFrameDraggable(f)
            f:SetClampedToScreen(true)
            f:SetFrameLevel(10)
        else
            f:SetFrameLevel(5)
        end

    if closeOnEsc then
        tinsert(_G.UISpecialFrames, name)
        if not hideCloseButton then
            f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
            f.close:SetPoint("TOPRIGHT", 6, 4)
            f.close:SetScript("OnClick", function(self) self:GetParent():Hide() end)
            if F and F.ReskinClose then
                F.ReskinClose(f.close)
            end
        end
    end

    nibRealUI:CreateBD(f, nil, true, true)

    return f
end

function nibRealUI:AddButtonHighlight(button)
    -- Button Highlight
    local highlight = CreateFrame("Frame", nil, button)
    highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
    highlight:SetWidth(button:GetWidth() - 2)
    highlight:SetHeight(button:GetHeight() - 2)
    highlight:SetBackdrop({
        bgFile = nibRealUI.media.textures.plain,
        edgeFile = nibRealUI.media.textures.plain,
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    highlight:SetBackdropColor(0,0,0,0)
    highlight:SetBackdropBorderColor(self.classColor[1], self.classColor[2], self.classColor[3], self.classColor[4])
end

function nibRealUI:SkinButton(button, icon, border)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetPoint("TOPLEFT", 3, -3)
    icon:SetPoint("BOTTOMRIGHT", -3, 3)

    border:SetTexture(nil)

    local bd1 = CreateFrame("Frame", nil, button)
    bd1:SetPoint("TOPLEFT", button, 2, -2)
    bd1:SetPoint("BOTTOMRIGHT", button, -2, 2)
    bd1:SetFrameLevel(1)
    nibRealUI:CreateBD(bd1, 0)

    local bd2 = CreateFrame("Frame", nil, button)
    bd2:SetPoint("TOPLEFT", button, 0, 0)
    bd2:SetPoint("BOTTOMRIGHT", button, 0, 0)
    bd2:SetFrameLevel(1)
    nibRealUI:CreateBD(bd2)
end

function nibRealUI:CreateBD(frame, alpha, stripes, windowColor)
    local bdColor
    frame:SetBackdrop({
        bgFile = nibRealUI.media.textures.plain,
        edgeFile = nibRealUI.media.textures.plain,
        edgeSize = 1,
    })
    if windowColor then
        bdColor = nibRealUI.media.window
        tinsert(_G.REALUI_WINDOW_FRAMES, frame)
    else
        bdColor = nibRealUI.media.background
    end
    frame:SetBackdropColor(bdColor[1], bdColor[2], bdColor[3], bdColor[4])
    frame:SetBackdropBorderColor(0, 0, 0)

    if stripes then
        self:AddStripeTex(frame)
    end
end

function nibRealUI:CreateBDFrame(frame, alpha, stripes, windowColor)
    local f
    if frame:GetObjectType() == "Texture" then
        f = frame:GetParent()
    else
        f = frame
    end

    local lvl = f:GetFrameLevel()

    local bg = CreateFrame("Frame", nil, f)
    bg:SetParent(f)
    bg:SetPoint("TOPLEFT", f, -1, 1)
    bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
    bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

    nibRealUI:CreateBD(bg, alpha, stripes, windowColor)

    return bg
end

function nibRealUI:CreateBG(frame, alpha)
    local f = frame
    if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", frame, -1, 1)
    bg:SetPoint("BOTTOMRIGHT", frame, 1, -1)
    bg:SetTexture(nibRealUI.media.textures.plain)
    bg:SetVertexColor(0, 0, 0, alpha)

    return bg
end

function nibRealUI:CreateBGSection(parent, f1, f2, ...)
    -- Button Backgrounds
    local x1, y1, x2, y2 = -2, 2, 2, -2
    if ... then
        x1, y1, x2, y2 = ...
    end
    local Sect1 = CreateFrame("Frame", nil, parent)
    Sect1:SetPoint("TOPLEFT", f1, "TOPLEFT", x1, y1)
    Sect1:SetPoint("BOTTOMRIGHT", f2, "BOTTOMRIGHT", x2, y2)
    nibRealUI:CreateBD(Sect1)
    Sect1:SetBackdropColor(0.8, 0.8, 0.8, 0.15)
    Sect1:SetFrameLevel(parent:GetFrameLevel() + 1)

    return Sect1
end

function nibRealUI:CreateInnerBG(frame)
    local f = frame
    if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", frame, 1, -1)
    bg:SetPoint("BOTTOMRIGHT", frame, -1, 1)
    bg:SetTexture(nibRealUI.media.textures.plain)
    bg:SetVertexColor(0, 0, 0, 0)

    return bg
end

function nibRealUI:AddStripeTex(parent)
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

function nibRealUI:CreateFS(parent, justify, size)
    local f = parent:CreateFontString(nil, "OVERLAY")

    if size == "small" then
        f:SetFontObject(_G.RealUIFont_PixelSmall)
    elseif size == "large" then
        f:SetFontObject(RealUIFont_PixelLarge)
    else
        f:SetFontObject(RealUIFont_Pixel)
    end
    f:SetShadowColor(0, 0, 0, 0)
    if justify then f:SetJustifyH(justify) end

    return f
end

-- Formatting
function nibRealUI:AbbreviateName(name, maxLength)
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
function nibRealUI:ReadableNumber(num, places)
    local ret = 0
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
function nibRealUI:OtherFaction(f)
    if (f == "Horde") then
        return "Alliance"
    else
        return "Horde"
    end
end

-- Validate Offset
function nibRealUI:ValidateOffset(value, ...)
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
function nibRealUI:GetILVLColor(lvl, ilvl)
    if lvl > 90 then
        ilvlLimits = (lvl - 91) * 9 + 510
    end
    if ilvl >= ilvlLimits + 28 then
        return ITEM_QUALITY_COLORS[4] -- epic
    elseif ilvl >= ilvlLimits + 14 then
        return ITEM_QUALITY_COLORS[3] -- rare
    elseif ilvl >= ilvlLimits then
        return ITEM_QUALITY_COLORS[2] -- uncommon
    else
        return ITEM_QUALITY_COLORS[1] -- common
    end
end

function nibRealUI:GetClassColor(class, ...)
    if not RAID_CLASS_COLORS[class] then return {1, 1, 1} end
    local classColors = (_G.CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
    if ... then
        return {r = classColors.r, g = classColors.g, b = classColors.b}
    else
        return {classColors.r, classColors.g, classColors.b}
    end
end

function nibRealUI:HSLToRGB(h, s, l, a)
    if s<=0 then return l,l,l,a end
    h, s, l = h*6, s, l
    local c = (1-abs(2*l-1))*s
    local x = (1-abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m),(g+m),(b+m),a
end

function nibRealUI:RGBToHSL(r, g, b)
    if type(r) == "table" then
        r, g, b = r.r or r[1], r.g or r[2], r.b or r[3]
    end
    local min, max = min(r, g, b), max(r, g, b)
    local h, s, l = 0, 0, (max + min) / 2
    if max ~= min then
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)
        if max == r then
            local mod = 6
            if g > b then mod = 0 end
            h = (g - b) / d + mod
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
    end
    h = h / 6
    return h, s, l
end

function nibRealUI:ColorShift(delta, r, g, b)
    local h, s, l = self:RGBToHSL(r, g, b)
    local r2, g2, b2 = self:HSLToRGB((((h + delta) * 255) % 255), s, l)
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

function nibRealUI:ColorLighten(delta, r, g, b)
    local h, s, l = self:RGBToHSL(r, g, b)
    local r2, g2, b2, a = self:HSLToRGB(h, s, self:Clamp(l + delta, 0, 1))
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

function nibRealUI:ColorSaturate(delta, r, g, b)
    local h, s, l = self:RGBToHSL(r, g, b)
    local r2, g2, b2, a = self:HSLToRGB(h, self:Clamp(s + delta, 0, 1), l)
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

function nibRealUI:ColorDarken(delta, r, g, b)
    return self:ColorLighten(-delta, r, g, b)
end

function nibRealUI:ColorDesaturate(delta, r, g, b)
    return self:ColorSaturate(-delta, r, g, b)
end
