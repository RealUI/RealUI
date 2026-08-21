local ADDON_NAME, ns = ... -- luacheck: ignore

-- B47/B12 reference-layout capture: Arnvid positions everything in game by
-- hand, then `/realdev layoutdump` prints every value the defaults need —
-- pinned element positions straight from their DBs, and the small unit
-- frames' offsets RELATIVE to their anchor frames, computed from live rects
-- in exactly the coordinate form the UnitFrames `positions` table uses.
-- Paste the output back; the numbers get baked into the defaults.

local RealUI = _G.RealUI

local function fmt(v)
    if type(v) ~= "number" or _G.issecretvalue(v) then return tostring(v) end
    return ("%.1f"):format(v)
end

local function rect(frame)
    if not frame then return nil end
    local l, b, w, h = frame:GetRect()
    if not l or _G.issecretvalue(l) or _G.issecretvalue(b) then return nil end
    return l, b, w or 0, h or 0
end

-- The positions-table semantics per frame (see UnitFrames.lua RepositionFrames):
--   pet          BOTTOMLEFT  -> player BOTTOMLEFT
--   focus        BOTTOMLEFT  -> player BOTTOMLEFT
--   focustarget  TOPLEFT     -> focus  BOTTOMLEFT
--   targettarget BOTTOMRIGHT -> target BOTTOMRIGHT
local function RelativeOffset(frame, anchor, mode)
    local fl, fb, fw, fh = rect(frame)
    local al, ab, aw, ah = rect(anchor)
    if not fl or not al then return nil end

    if mode == "BOTTOMLEFT" then
        return fl - al, fb - ab
    elseif mode == "BOTTOMRIGHT" then
        return (fl + fw) - (al + aw), fb - ab
    elseif mode == "TOPLEFT_TO_BOTTOMLEFT" then
        return fl - al, (fb + fh) - ab
    end
end

-- Alignment grid overlay for hand-positioning: `/realdev grid [spacing]`
-- toggles it (default 32px). Center lines are red, everything else faint
-- white. Click-through; independent of Edit Mode and config mode.
local gridFrame
local function BuildGrid(spacing)
    if gridFrame then
        gridFrame:Hide()
        gridFrame = nil
    end

    gridFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    gridFrame:SetAllPoints()
    gridFrame:SetFrameStrata("BACKGROUND")
    gridFrame:EnableMouse(false)

    local width = _G.UIParent:GetWidth()
    local height = _G.UIParent:GetHeight()
    local cx, cy = width / 2, height / 2

    local function line(vertical, offset, isCenter)
        local tex = gridFrame:CreateTexture(nil, "BACKGROUND")
        if isCenter then
            tex:SetColorTexture(1, 0.2, 0.2, 0.6)
        else
            tex:SetColorTexture(1, 1, 1, 0.25)
        end
        if vertical then
            tex:SetSize(1, height)
            tex:SetPoint("TOPLEFT", offset, 0)
        else
            tex:SetSize(width, 1)
            tex:SetPoint("TOPLEFT", 0, -offset)
        end
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
end

function ns.commands:grid(arg)
    if gridFrame and gridFrame:IsShown() and not _G.tonumber(arg) then
        gridFrame:Hide()
        gridFrame = nil
        _G.print("|cff00ccff[Grid]|r off")
        return
    end
    local spacing = _G.tonumber(arg) or 32
    BuildGrid(spacing)
    _G.print(("|cff00ccff[Grid]|r on, %dpx (red = screen center). `/realdev grid` again to hide."):format(spacing))
end

function ns.commands:layoutdump()
    local layout = (RealUI.db and RealUI.db.char.layout and RealUI.db.char.layout.current) or 1
    _G.print(("|cff00ccff[LayoutDump]|r layout=%d (1=DPS/Tank, 2=Healing)"):format(layout))

    local CastBars = RealUI:GetModule("CastBars", true)
    if CastBars and CastBars.db then
        for _, unit in _G.ipairs({"player", "target", "focus"}) do
            local pos = CastBars.db.profile[unit] and CastBars.db.profile[unit].position
            if pos then
                _G.print(("  castbar %s: anchorTo=%s point=%s x=%s y=%s"):format(
                    unit, tostring(pos.anchorTo), tostring(pos.point), fmt(pos.x), fmt(pos.y)))
            end
        end
    end

    local ClassResource = RealUI:GetModule("ClassResource", true)
    if ClassResource and ClassResource.db then
        local pos = ClassResource.db.class.points and ClassResource.db.class.points.position
        if pos then
            _G.print(("  classpoints: anchorTo=%s point=%s x=%s y=%s"):format(
                tostring(pos.anchorTo), tostring(pos.point), fmt(pos.x), fmt(pos.y)))
        end
        local barPos = ClassResource.db.class.bar and ClassResource.db.class.bar.position
        if barPos then
            _G.print(("  classbar: anchorTo=%s point=%s x=%s y=%s"):format(
                tostring(barPos.anchorTo), tostring(barPos.point), fmt(barPos.x), fmt(barPos.y)))
        end
    end

    local player = _G.RealUIPlayerFrame
    local target = _G.RealUITargetFrame
    local focus = _G.RealUIFocusFrame
    local sets = {
        {"pet", _G.RealUIPetFrame, player, "BOTTOMLEFT", "player"},
        {"focus", focus, player, "BOTTOMLEFT", "player"},
        {"focustarget", _G.RealUIFocusTargetFrame, focus, "TOPLEFT_TO_BOTTOMLEFT", "focus"},
        {"targettarget", _G.RealUITargetTargetFrame, target, "BOTTOMRIGHT", "target"},
    }
    for _, set in _G.ipairs(sets) do
        local name, frame, anchor, mode, anchorName = set[1], set[2], set[3], set[4], set[5]
        local x, y = RelativeOffset(frame, anchor, mode)
        if x then
            _G.print(("  %s: { x = %d, y = %d } -- vs %s (%s)"):format(
                name, _G.Round and _G.Round(x) or _G.math.floor(x + 0.5),
                _G.Round and _G.Round(y) or _G.math.floor(y + 0.5), anchorName, mode))
        else
            _G.print(("  %s: not measurable (frame hidden or secret rect)"):format(name))
        end
    end

    _G.print("|cff00ccff[LayoutDump]|r position everything first (frames visible: set a target/focus that has a target), then paste this output back.")
end
