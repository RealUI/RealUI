local _, private = ...

-- Lua Globals --
local abs = _G.math.abs
local tinsert, next, type = _G.table.insert, _G.next, _G.type -- luacheck: ignore

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local MODNAME = "AngleStatusBar"
local AngleStatusBar = RealUI:NewModule(MODNAME)

local bars = {}
local function debug(isDebug, ...) -- luacheck: ignore
    if isDebug then
        -- debug(self:GetName(), ...)
        return AngleStatusBar:debug(isDebug, ...)
    end
end

local Lerp = _G.Lerp
local DEFAULT_STATUSBAR_TEXTURE = [[Interface\TargetingFrame\UI-StatusBar]]
local DEFAULT_PLAIN_TEXTURE = [[Interface\Buttons\WHITE8x8]]
local StatusBar_SetValue, StatusBar_SetMinMaxValues, StatusBar_SetStatusBarTexture, StatusBar_GetStatusBarTexture, StatusBar_GetValue, StatusBar_GetMinMaxValues, StatusBar_SetReverseFill do
    local temp = _G.CreateFrame("StatusBar")
    StatusBar_SetValue = temp.SetValue
    StatusBar_SetMinMaxValues = temp.SetMinMaxValues
    StatusBar_SetStatusBarTexture = temp.SetStatusBarTexture
    StatusBar_GetStatusBarTexture = temp.GetStatusBarTexture
    StatusBar_GetValue = temp.GetValue
    StatusBar_GetMinMaxValues = temp.GetMinMaxValues
    StatusBar_SetReverseFill = temp.SetReverseFill
    temp:Hide()
end

-- 12.0.1: min/max/value can be "secret" (UnitPower etc.); never compare or use in arithmetic.
local function hasSecretRange(meta)
    return meta and (meta.hasSecretRange or RealUI.isSecret(meta.minVal) or RealUI.isSecret(meta.maxVal))
end

local function HideNativeStatusBarTexture(self)
    if not StatusBar_GetStatusBarTexture or not self then return end
    local nativeTex = StatusBar_GetStatusBarTexture(self)
    if nativeTex and self.fill and nativeTex ~= self.fill then
        nativeTex:Hide()
        self.__nativeStatusBarTexture = nativeTex
    end
end

local function SetBarValue(self, value)
    local meta = bars[self]
    if not meta then return end
    -- Check secrets BEFORE any comparison or arithmetic (avoids "attempt to compare field 'maxVal' (a secret value)").
    if hasSecretRange(meta) or RealUI.isSecret(value) then return end
    meta.value = value
    if not meta.maxVal then return end
    local isMaxed = meta.maxVal == 0
    local isReversePerc, isReverseFill = false, false
    if not RealUI.isMidnight then
        isReversePerc, isReverseFill = self:GetReversePercent(), self:GetReverseFill()
    end
    local minWidth, maxWidth, width = meta.minWidth, meta.maxWidth, meta.maxWidth -- luacheck: ignore
    local left, right, top, bottom = 0, 1, 0, 1

    -- For reverseMissing mode on angled bars, treat incoming values as "current" by default.
    -- oUF's Health/Power elements pass current values, and relying on auto-detection at
    -- value==0/max is ambiguous and can leave bars full-colored on load.
    local displayValue = value
    local percent = value / meta.maxVal
    if meta.reverseMissing and not isMaxed then
        local resolvedSource = meta.reverseMissingSource

        -- If the caller explicitly configured the source ("current" or "missing"), treat it as
        -- authoritative. Auto-detection is ambiguous at value==0/max and can cause the bar to
        -- flip back to showing current health (colored when full) during certain update sequences.
        if resolvedSource ~= "current" and resolvedSource ~= "missing" then
            -- Default to current unless something else explicitly sets a source.
            resolvedSource = "current"
        end

        if resolvedSource == "current" then
            displayValue = meta.maxVal - value
            percent = displayValue / meta.maxVal
        end
        -- We want normal fill behavior (more missing = larger bar)
        isReversePerc = false
    end

    -- Store displayValue so SetStatusBarColor can access it
    meta.displayValue = displayValue

        if isReversePerc then
            if isMaxed then
                width = maxWidth
            else
            width = Lerp(maxWidth, minWidth, percent)
                if isReverseFill then
                left = Lerp(0, 1, percent)
                else
                right = Lerp(1, 0, percent)
                end
            end
        else
            if isMaxed then
                width = minWidth
            else
            width = Lerp(minWidth, maxWidth, percent)
                if isReverseFill then
                left = Lerp(1, 0, percent)
                else
                right = Lerp(0, 1, percent)
            end
        end
    end

    self.fill:SetWidth(width)
    if meta.isTrapezoid then
        if width < (minWidth * 2) then
            local vertexOfs = width / 2
            self.fill:SetPoint(meta.isTrapezoid, 0, (minWidth - vertexOfs) * (meta.isTrapezoid == "TOP" and -1 or 1))
            self.fill:SetVertexOffset(meta.leftVertex, vertexOfs, 0)
            self.fill:SetVertexOffset(meta.rightVertex, -vertexOfs, 0)
            meta.isLess = true
        elseif meta.isLess then
            self.fill:SetPoint(meta.isTrapezoid)
            self.fill:SetVertexOffset(meta.leftVertex, minWidth, 0)
            self.fill:SetVertexOffset(meta.rightVertex, -minWidth, 0)
            meta.isLess = false
        end
    end

    if meta.texture then
        self.fill:SetTexCoord(left, right, top, bottom)
    end
    if meta.reverseMissing then
        -- For reverseMissing, fill represents missing health/power.
        -- Use alpha instead of SetShown: in 12.x the engine can still render the StatusBar
        -- texture even when :Hide() was called.
        local shouldShow = displayValue > 0
        self.fill:Show()
        self.fill:SetAlpha(shouldShow and 1 or 0)
        -- Defensive: never let a native/internal texture show through.
        HideNativeStatusBarTexture(self)
    elseif isReversePerc then
            self.fill:SetShown(value < meta.maxVal)
        else
            self.fill:SetShown(value > meta.minVal)
        end
end

local smoothBars do
    local FrameDeltaLerp, Clamp = _G.FrameDeltaLerp, _G.Clamp
    smoothBars = {}

    local function IsCloseEnough(bar, newValue, targetValue)
        local min, max = bar:GetMinMaxValues()
        local range = max - min
        if range > 0.0 then
            return abs((newValue - targetValue) / range) < .00001
        end
        return true
    end

    local function ProcessSmoothStatusBars()
        for bar, targetValue in next, smoothBars do
            local meta = bars[bar]
            if hasSecretRange(meta) then
                smoothBars[bar] = nil
            else
                local effectiveTargetValue = Clamp(targetValue, bar:GetMinMaxValues())
                local newValue = FrameDeltaLerp(bar:GetValue(), effectiveTargetValue, .25)

                if IsCloseEnough(bar, newValue, effectiveTargetValue) then
                    -- Snap to exact target so reverseMissing can reach true 0 missing (and hide fill).
                    newValue = effectiveTargetValue
                    smoothBars[bar] = nil
                end

                SetBarValue(bar, newValue)
        end
    end
    end
    _G.C_Timer.NewTicker(0, ProcessSmoothStatusBars)
end

local UpdateAngle do
    local function SetVertexOffset(tex, meta)
        for i = 1, 4 do
            tex:SetVertexOffset(i, 0, 0)
        end
        tex:SetVertexOffset(meta.leftVertex, meta.minWidth, 0)
        tex:SetVertexOffset(meta.rightVertex, -meta.minWidth, 0)
    end

    function UpdateAngle(self)
        if bars[self].minWidth <= 0 then
            -- We don't have a proper offset, bail early.
            return
        end

        local meta = bars[self]
        local minWidth = meta.minWidth
        if meta.regions then
            for index = 1, #meta.regions do
                SetVertexOffset(meta.regions[index], meta)
            end
        else
            SetVertexOffset(self, meta)
        end

        if meta.hasBG then
            if meta.leftVertex == 1 then
                self.top:SetPoint("TOPLEFT", minWidth, 0)
                self.bottom:SetPoint("BOTTOMLEFT", 0, 0)

                self.left:SetStartPoint("TOPLEFT", minWidth, 0)
                _G.C_Timer.After(0, function()
                    -- The line points don't seem to update properly if done together, so we separate them by one frame.
                    self.left:SetEndPoint("BOTTOMLEFT", 0, 0)
                end)
            else
                self.top:SetPoint("TOPLEFT", 0, 0)
                self.bottom:SetPoint("BOTTOMLEFT", minWidth, 0)

                self.left:SetStartPoint("TOPLEFT", 0, 0)
                _G.C_Timer.After(0, function()
                    self.left:SetEndPoint("BOTTOMLEFT", minWidth, 0)
                end)
            end

            if meta.rightVertex == 4 then
                self.top:SetPoint("TOPRIGHT", 0, 0)
                self.bottom:SetPoint("BOTTOMRIGHT", -minWidth, 0)

                self.right:SetStartPoint("TOPRIGHT", 0, 0)
                _G.C_Timer.After(0, function()
                    self.right:SetEndPoint("BOTTOMRIGHT", -minWidth, 0)
                end)
            else
                self.top:SetPoint("TOPRIGHT", -minWidth, 0)
                self.bottom:SetPoint("BOTTOMRIGHT", 0, 0)

                self.right:SetStartPoint("TOPRIGHT", -minWidth, 0)
                _G.C_Timer.After(0, function()
                    self.right:SetEndPoint("BOTTOMRIGHT", 0, 0)
                end)
            end
        end

        if meta.value then
            SetBarValue(self, meta.value)
        end
    end
end

local function OnSizeChanged(self, width, height)
    local meta = bars[self]
    meta.maxWidth = width
    meta.minWidth = height
    UpdateAngle(self)
end

local Frame_SetWidth = _G.getmetatable(_G.UIParent).__index.SetWidth
local Frame_SetSize = _G.getmetatable(_G.UIParent).__index.SetSize
local BaseAngleMixin = {}
function BaseAngleMixin:SetWidth(width)
    Frame_SetWidth(self, bars[self].minWidth + width)
    if bars[self].isTex then
        OnSizeChanged(self, width, self:GetHeight())
    end
end
function BaseAngleMixin:SetSize(width, height)
    Frame_SetSize(self, height + width, height)
    if bars[self].isTex then
        OnSizeChanged(self, width, height)
    end
end
function BaseAngleMixin:SetAngleVertex(leftVertex, rightVertex)
    local meta = bars[self]
    meta.leftVertex = leftVertex
    meta.rightVertex = rightVertex

    local leftMod, rightMod = leftVertex % 2, rightVertex % 2
    if leftMod == 1 and rightMod == 1 then
        meta.isTrapezoid = "TOP"
    elseif leftMod == 0 and rightMod == 0 then
        meta.isTrapezoid = "BOTTOM"
    end
    UpdateAngle(self)

    if meta.children and #meta.children > 0 then
        -- If we have any children, update them too.
        for i = 1, #meta.children do
            meta.children[i]:SetAngleVertex(leftVertex, rightVertex)
        end
    end
end

local AngleFrameMixin = _G.Mixin({}, BaseAngleMixin)
function AngleFrameMixin:SetBackgroundColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end
    local color = bars[self].bgColor
    color.r, color.g, color.b, color.a = r, g, b, a
    ---FIXBETA
    if (color.r) and (color.g) and (color.b) then
        self.bg:SetColorTexture(r, g, b, a)
    end
end
function AngleFrameMixin:GetBackgroundColor()
    return self.bg:GetColorTexture()
end
function AngleFrameMixin:SetBackgroundBorderColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end
    local color = bars[self].borderColor
    color.r, color.g, color.b, color.a = r, g, b, a
    self.top:SetColorTexture(r, g, b, a)
    self.bottom:SetColorTexture(r, g, b, a)
    self.left:SetColorTexture(r, g, b, a)
    self.right:SetColorTexture(r, g, b, a)
end
function AngleFrameMixin:GetBackgroundBorderColor()
    local color = bars[self].bgColor
    return color.r, color.g, color.b, color.a
end

local AngleStatusBarMixin = _G.Mixin({}, BaseAngleMixin)
function AngleStatusBarMixin:SetStatusBarColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end

    local meta = bars[self]
    local color = meta.fillColor
    if r == nil then
        r = color.r or 1
        g = color.g or 1
        b = color.b or 1
        a = color.a or 1
    else
        a = a or color.a or 1
    end
    color.r, color.g, color.b, color.a = r, g, b, a

    if meta.reverseMissing then
        -- Reverse missing mode: fill shows missing portion in color
        -- SetBarValue controls visibility via alpha, we just set the color

        -- Apply the color to the fill (which represents missing health/power).
        if not meta.texture or meta.texture == "" then
            self.fill:SetColorTexture(r, g, b, a)
        else
            self.fill:SetVertexColor(r, g, b, a)
        end

        -- Force the background to stay pure black (not colored).
        -- oUF may try to color it via this function; we override that here.
        if meta.hasBG and self.bg then
            self.bg:SetColorTexture(0, 0, 0, 1)
        end

        -- visibility is controlled by SetBarValue via alpha
    elseif meta.invertFill then
        if meta.hasBG and self.bg then
            self.bg:SetColorTexture(r, g, b, a)
        end
    if not meta.texture or meta.texture == "" then
            self.fill:SetColorTexture(0, 0, 0, 0)
        else
            self.fill:SetVertexColor(1, 1, 1, 0)
        end
    elseif not meta.texture or meta.texture == "" then
        self.fill:SetColorTexture(r, g, b, a)
    else
        self.fill:SetVertexColor(r, g, b, a)
    end
end
function AngleStatusBarMixin:GetStatusBarColor()
    local color = bars[self].fillColor
    return color.r, color.g, color.b, color.a
end

function AngleStatusBarMixin:SetStatusBarTexture(texture, layer)
    if not texture then return end
    local meta = bars[self]
    if meta and meta.forcePlain then
        texture = DEFAULT_PLAIN_TEXTURE
    end
    local texType = type(texture)
    if texType == "string" or texType == "number" then
        bars[self].texture = texture
        if self.fill then
            self.fill:SetTexture(texture)
            if StatusBar_SetStatusBarTexture then
                StatusBar_SetStatusBarTexture(self, self.fill, layer)
            end
            HideNativeStatusBarTexture(self)
        elseif StatusBar_SetStatusBarTexture then
            -- Fallback: keep the native StatusBar usable even if fill isn't constructed.
            StatusBar_SetStatusBarTexture(self, texture, layer)
        end

        if layer then
            self.fill:SetDrawLayer(layer)
        end
    else
        self.fill = texture
        if StatusBar_SetStatusBarTexture then
            StatusBar_SetStatusBarTexture(self, self.fill, layer)
        end
        HideNativeStatusBarTexture(self)
    end

end
function AngleStatusBarMixin:GetStatusBarTexture()
    -- Always return our managed fill texture.
    -- oUF directly colors the result of GetStatusBarTexture(); if the native StatusBar has
    -- a separate internal texture, oUF can end up coloring that while our code shows/hides
    -- `self.fill`, which looks like a permanently full colored bar.
    if self.fill then
        return self.fill
    end
    if StatusBar_GetStatusBarTexture then
        return StatusBar_GetStatusBarTexture(self)
    end
    return nil
end

function AngleStatusBarMixin:SetMinMaxValues(minVal, maxVal)
    local meta = bars[self]
    -- 12.0.1: never store secret min/max; keeps hasSecretRange(meta) false so we can still update with percent.
    if RealUI.isSecret(minVal) or RealUI.isSecret(maxVal) then
        if StatusBar_SetMinMaxValues then
            StatusBar_SetMinMaxValues(self, minVal, maxVal)
        end
        meta.minVal = nil
        meta.maxVal = nil
        meta.hasSecretRange = true
        meta.skipSmoothOnce = true
        return
    end

    local oldMaxVal = meta.maxVal
    if StatusBar_SetMinMaxValues then
        StatusBar_SetMinMaxValues(self, minVal, maxVal)
    end
    meta.hasSecretRange = false
    meta.minVal = minVal
    meta.maxVal = maxVal

    if oldMaxVal ~= maxVal then
        -- Avoid smoothing the first update after a range change.
        -- On reload, the bar starts at 0 (initialization) and smoothing would animate to full,
        -- which looks like a full-color bar in reverseMissing mode.
        meta.skipSmoothOnce = true
    end

    local targetValue = smoothBars[self]
    if targetValue then
        local ratio = 1
        if oldMaxVal and oldMaxVal ~= 0 and maxVal ~= 0 then
            ratio = maxVal / oldMaxVal
        end
        smoothBars[self] = targetValue * ratio
    end
end
function AngleStatusBarMixin:GetMinMaxValues()
    local meta = bars[self]
    return meta.minVal, meta.maxVal
end

-- This should accept a percentage or discrete value.
function AngleStatusBarMixin:SetValue(value, ignoreSmooth)
    local meta = bars[self]
    if hasSecretRange(meta) or RealUI.isSecret(value) then
        if smoothBars[self] then
            smoothBars[self] = nil
        end
        if StatusBar_SetValue then
            -- Use the native StatusBar for secret values, then correct the visuals below.
            StatusBar_SetValue(self, value)
        end
        meta.value = value

        -- Keep any native/internal texture hidden; oUF can still color it.
        HideNativeStatusBarTexture(self)

        local width = self.fill:GetWidth()
        if meta.isTrapezoid and not RealUI.isSecret(width) then
            if width < (meta.minWidth * 2) then
                local vertexOfs = width / 2
                self.fill:SetPoint(meta.isTrapezoid, 0, (meta.minWidth - vertexOfs) * (meta.isTrapezoid == "TOP" and -1 or 1))
                self.fill:SetVertexOffset(meta.leftVertex, vertexOfs, 0)
                self.fill:SetVertexOffset(meta.rightVertex, -vertexOfs, 0)
                meta.isLess = true
            elseif meta.isLess then
                self.fill:SetPoint(meta.isTrapezoid)
                self.fill:SetVertexOffset(meta.leftVertex, meta.minWidth, 0)
                self.fill:SetVertexOffset(meta.rightVertex, -meta.minWidth, 0)
                meta.isLess = false
            end
        end
        if RealUI.isSecret(width) then -- luacheck: ignore
        -- For secret values, let the native StatusBar control visibility
            -- Don't manually show/hide
        else
            if meta.reverseMissing and meta.minWidth and meta.maxWidth and (meta.maxWidth - meta.minWidth) > 0 then
                -- With secret values we can't safely do arithmetic on value/max, but the native
                -- StatusBar will still size the texture. Invert the visual fill to represent
                -- missing health/power.
                local currentPercent = (width - meta.minWidth) / (meta.maxWidth - meta.minWidth)
                currentPercent = _G.max(0, _G.min(1, currentPercent))
                local missingPercent = 1 - currentPercent
                local desiredWidth = Lerp(meta.minWidth, meta.maxWidth, missingPercent)
                self.fill:SetWidth(desiredWidth)
                self.fill:Show()
                self.fill:SetAlpha((missingPercent > 0) and 1 or 0)
            else
                self.fill:SetShown(width > 0)
            end
    end
        return
    end
    if type(meta.maxVal) == "number" then
        local ok, isGreater = pcall(function()
            return value > meta.maxVal
        end)
        if ok and isGreater then
            value = meta.maxVal
        end
    end

    if meta.skipSmoothOnce then
        meta.skipSmoothOnce = nil
        ignoreSmooth = true
    end
    if meta.smooth and not ignoreSmooth then
        smoothBars[self] = value
    else
        SetBarValue(self, value)
    end

    HideNativeStatusBarTexture(self)
end
function AngleStatusBarMixin:GetValue()
    return bars[self].value
end

-- Get visual percentage from bar width (useful for secret values)
function AngleStatusBarMixin:GetVisualPercent()
    local meta = bars[self]
    if not meta then return 0 end

    -- Try to get values from native StatusBar first
    local min, max = StatusBar_GetMinMaxValues and StatusBar_GetMinMaxValues(self) or 0, 100
    local value = StatusBar_GetValue and StatusBar_GetValue(self) or 0

    -- Check if we can use the native values
    local canUseNative = true
    if RealUI.isSecret(min) or RealUI.isSecret(max) or RealUI.isSecret(value) then
        canUseNative = false
    end

    if canUseNative then
        local ok, percent = pcall(function()
            if not max or max <= 0 then
                return nil
            end

            local p = value / max
            if meta.reverseMissing then
                p = 1 - p
            end

            return p
        end)

        if ok and percent ~= nil and not RealUI.isSecret(percent) then
            return percent
        end
    end

    -- Fallback: Try to calculate from visual width
    -- For reverseMissing mode, if fill is invisible, we're at 100% (no missing health)
    if meta.reverseMissing and self.fill then
        local ok, isHidden = pcall(function()
            return (not self.fill:IsShown()) or (self.fill.GetAlpha and self.fill:GetAlpha() == 0)
        end)
        if ok and isHidden then
            return 1 -- 100% health
        end
    end

    local currentWidth = self.fill:GetWidth()
    if RealUI.isSecret(currentWidth) or not currentWidth then
        -- Can't calculate if width is secret or nil
        return nil
    end

    local minWidth = meta.minWidth
    local maxWidth = meta.maxWidth

    -- Check if minWidth or maxWidth are secret/tainted
    if RealUI.isSecret(minWidth) or RealUI.isSecret(maxWidth) then
        return nil
    end

    if not minWidth or not maxWidth then return 0 end
    if maxWidth == minWidth then return 1 end -- Avoid division by zero

    -- Calculate percent based on width
    local percent = (currentWidth - minWidth) / (maxWidth - minWidth)
    percent = math.max(0, math.min(1, percent)) -- Clamp to 0-1

    -- For reverseMissing mode, invert the percentage
    if meta.reverseMissing then
        percent = 1 - percent
    end

    return percent
end

function AngleStatusBarMixin:SetSmooth(isSmooth)
    bars[self].smooth = isSmooth
end
function AngleStatusBarMixin:GetSmooth()
    return bars[self].smooth
end

function AngleStatusBarMixin:SetInvertFill(isInvert)
    bars[self].invertFill = isInvert
end
function AngleStatusBarMixin:GetInvertFill()
    return bars[self].invertFill
end

function AngleStatusBarMixin:SetReverseMissing(isReverseMissing)
    local meta = bars[self]
    meta.reverseMissing = isReverseMissing
    meta.reverseMissingResolved = nil
    meta.skipSmoothOnce = true
    if smoothBars[self] then
        smoothBars[self] = nil
    end
    if isReverseMissing then
        if self.bg then
            self.bg:Show()
        end
    end

    HideNativeStatusBarTexture(self)
end
function AngleStatusBarMixin:GetReverseMissing()
    return bars[self].reverseMissing
end

function AngleStatusBarMixin:SetReverseMissingSource(source)
    local meta = bars[self]
    meta.reverseMissingSource = source
    if source == "current" or source == "missing" then
        meta.reverseMissingResolved = source
    else
        meta.reverseMissingResolved = nil
    end
end

function AngleStatusBarMixin:SetFlatTexture(isFlat)
    bars[self].forcePlain = isFlat
    local texture = bars[self].texture or DEFAULT_STATUSBAR_TEXTURE
    self:SetStatusBarTexture(texture)
end
function AngleStatusBarMixin:GetFlatTexture()
    return bars[self].forcePlain
end

-- Setting this to true will make the bars fill from right to left
function AngleStatusBarMixin:SetReverseFill(isReverseFill)
    bars[self].isReverseFill = isReverseFill
    if StatusBar_SetReverseFill then
        StatusBar_SetReverseFill(self, isReverseFill)
    end
    self.fill:ClearAllPoints()
    self.fill:SetPoint("TOP")
    self.fill:SetPoint("BOTTOM")
    if isReverseFill then
        self.fill:SetPoint("RIGHT")
    else
        self.fill:SetPoint("LEFT")
    end
end
function AngleStatusBarMixin:GetReverseFill()
    return bars[self].isReverseFill
end

-- Setting this to true will make the bars show full when at 0%.
function AngleStatusBarMixin:SetReversePercent(isReversePerc)
    local meta = bars[self]
    meta.isReversePerc = isReversePerc
    SetBarValue(self, meta.value)
end
function AngleStatusBarMixin:GetReversePercent()
    return bars[self].isReversePerc
end

function AngleStatusBarMixin:SetOrientation(orientaion)
end
function AngleStatusBarMixin:GetOrientation()
    return "HORIZONTAL"
end

--[[ Frame Construction ]]--
local function SetPixels(texture)
    texture:SetTexelSnappingBias(0.0)
    texture:SetSnapToPixelGrid(false)
end

local function SetAngleFrameDefaults(frame)
    frame:SetScript("OnSizeChanged", OnSizeChanged)
    --[[
    local test = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    test:SetTexture(1, 1, 1, 0.5)
    test:SetAllPoints(frame)
    --]]
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(0, 0, 0, 0.5)
    bg:SetAllPoints()
    SetPixels(bg)
    frame.bg = bg

    local top = frame:CreateTexture(nil, "BORDER")
    top:SetColorTexture(0, 0, 0)
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(1)
    SetPixels(top)
    frame.top = top

    local bottom = frame:CreateTexture(nil, "BORDER")
    bottom:SetColorTexture(0, 0, 0)
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(1)
    SetPixels(bottom)
    frame.bottom = bottom

    local left = frame:CreateLine(nil, "BORDER")
    left:SetColorTexture(0, 0, 0)
    left:SetThickness(0.5)
    left:SetStartPoint("TOPLEFT")
    left:SetEndPoint("BOTTOMLEFT")
    SetPixels(left)
    frame.left = left

    local right = frame:CreateLine(nil, "BORDER")
    right:SetColorTexture(0, 0, 0)
    right:SetThickness(0.5)
    right:SetStartPoint("TOPRIGHT")
    right:SetEndPoint("BOTTOMRIGHT")
    SetPixels(right)
    frame.right = right
end

local function CreateAngleFrame(name, parent)
    local frame = _G.CreateFrame("Frame", name, parent)
    SetAngleFrameDefaults(frame)
    return frame
end

local function CreateAngleStatusBar(name, parent)
    local bar = _G.CreateFrame("StatusBar", name, parent)
    SetAngleFrameDefaults(bar)
    bar.top:SetDrawLayer("OVERLAY")
    bar.bottom:SetDrawLayer("OVERLAY")
    bar.left:SetDrawLayer("OVERLAY")
    bar.right:SetDrawLayer("OVERLAY")
    bar:SetScript("OnSizeChanged", OnSizeChanged)
    _G.Mixin(bar, AngleFrameMixin)

    -- --[[
    -- local test = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
    -- test:SetColorTexture(1, 1, 1, 0.2)
    -- test:SetAllPoints(bar)
    -- --]]
    local fill = bar:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("TOP")
    fill:SetPoint("BOTTOM")
    fill:SetPoint("LEFT")
    bar.fill = fill

    -- Make sure the StatusBar's native texture is our managed `fill` texture.
    -- This prevents creation/use of an internal StatusBar texture region that oUF might
    -- color (and that we would not be hiding in reverseMissing mode).
    if StatusBar_SetStatusBarTexture then
        StatusBar_SetStatusBarTexture(bar, fill)
    end

    -- Hide any native/internal texture region if one was created anyway.
    HideNativeStatusBarTexture(bar)
    return bar
end

function AngleStatusBar:CreateAngle(frameType, name, parent)
    if frameType == "Texture" then
        local texture = parent:CreateTexture(name, "ARTWORK")
        _G.Mixin(texture, BaseAngleMixin)

        bars[texture] = {
            minWidth = 0,
            maxWidth = 0,
            leftVertex = 1,
            rightVertex = 4,
            isTex = true
        }

        local parentMeta = bars[parent]
        if parentMeta then
            _G.tinsert(parentMeta.regions, texture)
            texture:SetAngleVertex(parentMeta.leftVertex, parentMeta.rightVertex)
        end

        return texture
    elseif frameType == "Frame" then
        local frame = CreateAngleFrame(name, parent)
        _G.Mixin(frame, AngleFrameMixin)

        bars[frame] = {
            regions = {},
            children = {},
            bgColor = {},
            borderColor = {},
            minWidth = 0,
            maxWidth = 0,
            leftVertex = 1,
            rightVertex = 4,
            hasBG = true
        }
        _G.tinsert(bars[frame].regions, frame.bg)

        local parentMeta = bars[parent]
        if parentMeta then
            _G.tinsert(parentMeta.children, frame)
            frame:SetAngleVertex(parentMeta.leftVertex, parentMeta.rightVertex)
        end

        return frame
    elseif frameType == "CastBar" then
        local bar = CreateAngleStatusBar(name, parent)
        _G.Mixin(bar, AngleStatusBarMixin)

        bars[bar] = {
            regions = {},
            children = {},
            fillColor = {},
            bgColor = {},
            borderColor = {},
            minWidth = 0,
            maxWidth = 0,
            leftVertex = 1,
            rightVertex = 4,
            smooth = true,
            value = 0,
            hasBG = true
        }
        _G.tinsert(bars[bar].regions, bar.bg)
        _G.tinsert(bars[bar].regions, bar.fill)
        bar:SetMinMaxValues(0, 0)

        local parentMeta = bars[parent]
        if parentMeta then
            _G.tinsert(parentMeta.children, bar)
            bar:SetAngleVertex(parentMeta.leftVertex, parentMeta.rightVertex)
        end

        return bar
    elseif frameType == "StatusBar" then
        local bar = CreateAngleStatusBar(name, parent)
        _G.Mixin(bar, AngleStatusBarMixin)

        bars[bar] = {
            regions = {},
            children = {},
            fillColor = {},
            bgColor = {},
            borderColor = {},
            minWidth = 0,
            maxWidth = 0,
            leftVertex = 1,
            rightVertex = 4,
            smooth = true,
            value = 0,
            hasBG = true
        }
        _G.tinsert(bars[bar].regions, bar.bg)
        _G.tinsert(bars[bar].regions, bar.fill)
        bar:SetMinMaxValues(0, 0)

        local parentMeta = bars[parent]
        if parentMeta then
            _G.tinsert(parentMeta.children, bar)
            bar:SetAngleVertex(parentMeta.leftVertex, parentMeta.rightVertex)
        end

        return bar
    end
end
oUF:RegisterMetaFunction("CreateAngle", AngleStatusBar.CreateAngle) -- oUF magic

local pointToVertex = {
    ["TOPLEFT"] = 1,
    ["BOTTOMLEFT"] = 2,
    ["TOPRIGHT"] = 3,
    ["BOTTOMRIGHT"] = 4,
}
function AngleStatusBar:AttachFrame(frame, point, bar, relPoint, xOffset, yOffset)
    local meta = bars[bar]

    local vertex = pointToVertex[relPoint]
    if vertex then
        if meta.leftVertex == vertex then
            xOffset = meta.minWidth
        end
        if meta.rightVertex == vertex then
            xOffset = -meta.minWidth
        end
    end

    frame:SetPoint(point, bar, relPoint, xOffset, yOffset)
end
