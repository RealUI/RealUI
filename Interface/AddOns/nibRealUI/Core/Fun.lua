local _, private = ...

-- Lua Globals --
local min, max, floor = _G.math.min, _G.math.max, _G.math.floor
local tinsert, tsort = _G.table.insert, _G.table.sort
local next, type = _G.next, _G.type
local print, tonumber = _G.print, _G.tonumber
local Clamp = _G.Clamp

-- Libs --
local F = _G.Aurora[1]

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local debug = RealUI.GetDebug("Fun")


-- Misc Functions
private.addonDB = {}
function RealUI:RegisterAddOnDB(addon, db)
    if not private.addonDB[addon] then
        private.addonDB[addon] = db
    end
end
function RealUI:GetAddOnDB(addon)
    return private.addonDB[addon]
end

local spellFinder, numRun = _G.CreateFrame("FRAME"), 0
function RealUI:FindSpellID(spellName, affectedUnit, auraType)
    print(("RealUI is now looking for %s %s: %s."):format(affectedUnit, auraType, spellName))
    spellFinder:RegisterUnitEvent("UNIT_AURA", affectedUnit)
    spellFinder:SetScript("OnEvent", function(frame, event, unit)
        local filter = (auraType == "buff" and "HELPFUL PLAYER" or "HARMFUL PLAYER")
        for auraIndex = 1, 40 do
            local name, _, _, _, _, _, _, _, _, _, spellID = _G.UnitAura(unit, auraIndex, filter)
            debug("FindSpellID", auraIndex, name, spellID)
            if spellName == name then
                print(("spellID for %s is %d"):format(spellName, spellID))
                numRun = numRun + 1
            end

            if name == nil then
                if numRun > 3 then
                    numRun = 0
                    frame:UnregisterEvent("UNIT_AURA")
                end
                break
            end
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

function RealUI:GetResolutionVals(raw)
    local resolution
    if _G.GetCVarBool("gxWindow") and not _G.GetCVarBool("gxMaximize") then
        resolution = _G.GetCVar("gxwindowedresolution")
    else
        resolution = _G.GetCVar("gxfullscreenresolution")
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

-- Deep Copy table
function RealUI:DeepCopy(object, seen)
    -- Handle non-tables and previously-seen tables.
    if type(object) ~= "table" then
        return object
    elseif seen and seen[object] then
        return seen[object]
    end

    -- New table; mark it as having seen the copy, recursively.
    local s = seen or {}
    local copy = _G.setmetatable({}, _G.getmetatable(object))
    s[object] = copy
    for key, value in next, object do
        copy[self:DeepCopy(key, s)] = self:DeepCopy(value, s)
    end
    return copy
end

-- Loot Spec
function RealUI:GetCurrentLootSpecName()
    local lsID = _G.GetLootSpecialization()
    debug("GetCurrentLootSpecName", lsID)

    if (lsID == 0) then
        local specIndex = _G.GetSpecialization()
        local _, specName = _G.GetSpecializationInfo(specIndex)
        debug("GetSpecializationInfo", _, specName, specIndex)
        if RealUI.isDev and not specName then
            print("GetCurrentLootSpecName failed")
        end
        return specName or _G.UNKNOWN
    else
        local _, specName = _G.GetSpecializationInfoByID(lsID)
        debug("GetSpecializationInfoByID", _, specName)
        return specName
    end
end

function RealUI:GetLootSpecData(LootSpecIDs)
    for i = 1, _G.GetNumSpecializations() do
        LootSpecIDs[i] = _G.GetSpecializationInfo(i)
    end
    return LootSpecIDs
end

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
    _G.AuroraBase.SetBackdrop(highlight, _G.Aurora.highlightColor:GetRGBA())
end

function RealUI:CreateBD(frame, alpha, stripes, windowColor)
    if stripes then
        _G.Aurora.Base.SetBackdrop(frame)
    else
        _G.Aurora.Base.SetBackdrop(frame, _G.Aurora.frameColor:GetRGBA())
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

function RealUI:CreateFS(parent, justify, size)
    local f = parent:CreateFontString(nil, "OVERLAY")

    if size == "large" then
        f:SetFontObject("Fancy16Font")
    else
        f:SetFontObject("SystemFont_Shadow_Med1")
    end

    f:SetShadowColor(0, 0, 0, 0)
    if justify then f:SetJustifyH(justify) end

    return f
end

-- Formatting
local utf8len, utf8sub = _G.string.utf8len, _G.string.utf8sub
function RealUI:AbbreviateName(name, maxLength)
    if not name then return "" end
    local maxNameLength = maxLength or 12

    local words, newName = {_G.strsplit(" ", name)}
    if #words > 2 and utf8len(name) > maxNameLength then
        local i = 1
        repeat
            words[i] = utf8sub(words[i], 1, 1) .. "."
            i = i + 1
        until i == #words

        newName = _G.strjoin(" ", _G.unpack(words))
    else
        newName = name
    end

    if utf8len(newName) > maxNameLength then
        newName = utf8sub(newName, 1, maxNameLength)..".."
    end
    return newName
end

function RealUI:ReadableNumber(value)
    local retString = _G.tostring(value)
	local strLen = retString:len()
	if strLen > 8 then
        retString = _G.BreakUpLargeNumbers(retString:sub(1, -7)).._G.SECOND_NUMBER_CAP
    elseif strLen > 6 then
		retString = ("%.2f"):format(value / 1000000).._G.SECOND_NUMBER_CAP
    elseif strLen > 5 then
        retString = retString:sub(1, -4).._G.FIRST_NUMBER_CAP
	elseif strLen > 4 then
		retString = ("%.1f"):format(value / 1000).._G.FIRST_NUMBER_CAP
	elseif strLen > 3 then
		retString = _G.BreakUpLargeNumbers(value)
	end
	return retString
end

-- Opposite Faction
function RealUI:OtherFaction(faction)
    if faction == "Horde" then
        return "Alliance"
    elseif faction == "Alliance" then
        return "Horde"
    else
        -- "Neutral" low level pandaren
        return
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
