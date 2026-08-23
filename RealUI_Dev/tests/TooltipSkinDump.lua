local ADDON_NAME, ns = ... -- luacheck: ignore

--[[ B94: why do the AH comparison tooltips render with no backdrop?

     `/fstack` is the wrong tool here — moving the mouse toward a tooltip takes
     it off the item and the tooltip goes away. It is also unnecessary: these
     frames are permanent globals, and their backdrop state survives being
     hidden. Hover an AH item once so Blizzard has laid the comparison tooltips
     out, move away, then run `/realdev tooltipdump`.

     Prints, per tooltip, the things that separate the candidate causes:
       - is there a NineSlice child at all (12.x may have restructured it)
       - did Aurora mark it (`_auroraNineSlice`) — i.e. did the skin reach it
       - what layout name Blizzard gave it, which is the key
         `Hook.NineSliceUtil.ApplyLayout` looks up. A name with no entry in
         Aurora's `layouts` table falls into the else branch, which blanks the
         nine-slice pieces and leaves the transparent result being reported
       - the resulting backdrop and its colour/alpha, on both the tooltip and
         its NineSlice, since `BasicFrame` backdrops the NineSlice, not the
         tooltip
]]

local function fmt(v)
    if v == nil then return "nil" end
    if type(v) == "boolean" then return v and "yes" or "no" end
    if type(v) == "number" and _G.issecretvalue(v) then return "<secret>" end
    return tostring(v)
end

local function DescribeBackdrop(frame, label)
    if not frame then
        _G.print(("    %s: MISSING"):format(label))
        return
    end

    local hasBackdrop = frame.GetBackdrop and frame:GetBackdrop() ~= nil
    local line = ("    %s: backdrop=%s"):format(label, fmt(hasBackdrop))

    if hasBackdrop and frame.GetBackdropColor then
        local r, g, b, a = frame:GetBackdropColor()
        if r and not _G.issecretvalue(r) then
            line = line .. (" colour=%.2f,%.2f,%.2f a=%.2f"):format(r, g, b, a or 1)
        end
    end

    if frame.GetAlpha then
        line = line .. (" alpha=%.2f"):format(frame:GetAlpha())
    end
    if frame.GetEffectiveAlpha then
        line = line .. (" effAlpha=%.2f"):format(frame:GetEffectiveAlpha())
    end
    if frame.IsShown then
        line = line .. (" shown=%s vis=%s"):format(fmt(frame:IsShown()), fmt(frame:IsVisible()))
    end
    _G.print(line)

    -- The rect is the field that separates "no backdrop" from "a backdrop on a
    -- frame with no size". A NineSlice that never got sized to its tooltip
    -- renders nothing while reporting a perfectly healthy backdrop.
    if frame.GetRect then
        local l, b, w, h = frame:GetRect()
        if l and not _G.issecretvalue(l) then
            _G.print(("      rect: %.0f,%.0f  %.0fx%.0f  strata=%s level=%d"):format(
                l, b, w or 0, h or 0,
                frame.GetFrameStrata and frame:GetFrameStrata() or "?",
                frame.GetFrameLevel and frame:GetFrameLevel() or -1))
        else
            _G.print("      rect: none (never laid out)")
        end
    end
end

local NINE_SLICE_PIECES = {
    "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner",
    "TopEdge", "BottomEdge", "LeftEdge", "RightEdge", "Center",
}

local function DescribeTooltip(name)
    local tooltip = _G[name]
    _G.print(("|cff00ccff%s|r"):format(name))
    if not tooltip then
        _G.print("    does not exist")
        return
    end

    DescribeBackdrop(tooltip, "tooltip")

    local nineSlice = tooltip.NineSlice
    if not nineSlice then
        -- If this is nil, Skin.SharedTooltipTemplate has been skinning nothing
        -- and the template changed under us.
        _G.print("    NineSlice: ABSENT")
        return
    end

    _G.print(("    NineSlice: present  _auroraNineSlice=%s  layoutType=%s"):format(
        fmt(nineSlice._auroraNineSlice), fmt(nineSlice.layoutType)))
    DescribeBackdrop(nineSlice, "NineSlice")

    -- Blank pieces are the signature of ApplyLayout's else branch.
    local blank, present, missing, hidden = 0, 0, 0, 0
    for _, key in _G.ipairs(NINE_SLICE_PIECES) do
        local piece = nineSlice[key]
        if not piece then
            missing = missing + 1
        elseif piece.GetTexture and (piece:GetTexture() == nil or piece:GetTexture() == "") then
            blank = blank + 1
        else
            present = present + 1
            if piece.IsShown and not piece:IsShown() then hidden = hidden + 1 end
        end
    end
    _G.print(("    pieces: %d textured (%d of them hidden), %d blanked, %d absent"):format(
        present, hidden, blank, missing))

    -- Border tint and alpha: this is what separated the shopping tooltips from
    -- GameTooltip once the backdrop stacking was fixed, and it is invisible in
    -- every other field here. RealUI_Tooltips re-tints these on
    -- OnTooltipCleared, but only for tooltips it has hooked.
    local edge = nineSlice.TopEdge
    if edge and edge.GetVertexColor then
        local r, g, b = edge:GetVertexColor()
        if r and not _G.issecretvalue(r) then
            _G.print(("    border: tint=%.2f,%.2f,%.2f alpha=%.2f"):format(
                r, g, b, edge:GetAlpha()))
        end
    end
end

function ns.commands:tooltipdump()
    _G.print("|cff00ccff[TooltipSkinDump]|r hover an AH item first so the comparison tooltips get laid out, then run this.")

    for _, name in _G.ipairs({
        "GameTooltip",          -- the control: this one IS skinned correctly
        "ShoppingTooltip1",
        "ShoppingTooltip2",
        "ItemRefShoppingTooltip1",
    }) do
        DescribeTooltip(name)
    end

    -- `private.disabled` is per-addon and not reachable from here; the config
    -- value it is derived from is a global, and is the part worth seeing.
    _G.print(("|cff00ccff[TooltipSkinDump]|r AuroraConfig.tooltips=%s"):format(
        fmt(_G.AuroraConfig and _G.AuroraConfig.tooltips)))
    _G.print("Compare GameTooltip's rows against ShoppingTooltip1's — the first row that differs is the fault.")
end
