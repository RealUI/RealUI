local _, private = ...

-- RealUI --
local RealUI = private.RealUI

--[[ Screen alignment grid: `/realui grid [spacing]`.

     Lines every `spacing` units (default 32), counted outward from the
     screen centre, so the two red centre lines always exist and the grid is
     symmetric. Drawn on a click-through BACKGROUND-strata frame, so it sits
     behind every UI element and never eats a click. Independent of Edit
     Mode and config mode — use it alongside either.

     Started life as `/realdev grid` for the reference-layout work; RealUI_Dev
     now delegates here. ]]--

local DEFAULT_SPACING = 32
local MIN_SPACING = 8

local gridFrame
local lines = {}
local spacing = DEFAULT_SPACING

local function Draw()
    local width, height = _G.UIParent:GetWidth(), _G.UIParent:GetHeight()
    local cx, cy = width / 2, height / 2
    -- One physical pixel at the current UI scale, so lines stay crisp.
    local thickness = _G.PixelUtil.GetNearestPixelSize(1, gridFrame:GetEffectiveScale(), 1)

    local count = 0
    local function line(vertical, offset, isCenter)
        count = count + 1
        local tex = lines[count]
        if not tex then
            tex = gridFrame:CreateTexture(nil, "BACKGROUND")
            lines[count] = tex
        end
        if isCenter then
            tex:SetColorTexture(1, 0.2, 0.2, 0.6)
        else
            tex:SetColorTexture(1, 1, 1, 0.25)
        end
        tex:ClearAllPoints()
        if vertical then
            tex:SetSize(thickness, height)
            tex:SetPoint("TOPLEFT", offset, 0)
        else
            tex:SetSize(width, thickness)
            tex:SetPoint("TOPLEFT", 0, -offset)
        end
        tex:Show()
    end

    line(true, cx, true)
    line(false, cy, true)
    local i = spacing
    while cx + i < width do
        line(true, cx - i)
        line(true, cx + i)
        i = i + spacing
    end
    i = spacing
    while cy + i < height do
        line(false, cy - i)
        line(false, cy + i)
        i = i + spacing
    end

    for n = count + 1, #lines do
        lines[n]:Hide()
    end
end

local function CreateGrid()
    gridFrame = _G.CreateFrame("Frame", "RealUI_AlignGrid", _G.UIParent)
    gridFrame:SetAllPoints()
    gridFrame:SetFrameStrata("BACKGROUND")
    gridFrame:EnableMouse(false)
    gridFrame:Hide()

    -- The grid is laid out in UIParent units; redraw when they change.
    gridFrame:RegisterEvent("UI_SCALE_CHANGED")
    gridFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
    gridFrame:SetScript("OnEvent", function(self)
        if self:IsShown() then Draw() end
    end)
end

--- Toggle the alignment grid. A numeric `arg` (re)shows it at that spacing;
--- no number toggles it at the last spacing used.
function RealUI:ToggleAlignGrid(arg)
    local newSpacing = _G.tonumber(arg)
    if not gridFrame then CreateGrid() end

    if gridFrame:IsShown() and not newSpacing then
        gridFrame:Hide()
        _G.print("|cff0099ffRealUI|r: alignment grid off.")
        return
    end

    if newSpacing then
        spacing = _G.math.max(MIN_SPACING, _G.math.floor(newSpacing))
    end
    gridFrame:Show()
    Draw()
    _G.print(("|cff0099ffRealUI|r: alignment grid on, %d units (red = screen centre). |cffffff00/realui grid|r again to hide, |cffffff00/realui grid <n>|r for another spacing.")
        :format(spacing))
end
