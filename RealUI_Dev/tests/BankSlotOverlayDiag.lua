local ADDON_NAME, ns = ... -- luacheck: ignore

-- Diagnostic: Dump every visible texture/region on the first bank slot button
-- Run: /realdev bankdiag
-- Must have bank open at a banker.

function ns.commands:bankdiag()
    local RealUI = _G.RealUI
    local Inventory = RealUI and RealUI:GetModule("Inventory")
    if not Inventory or not Inventory.bank then
        _G.print("|cffff0000[DIAG]|r Open bank first.")
        return
    end

    -- Find the first active bank slot
    local slot
    for i = 1, Inventory.bank:GetNumChildren() do
        local child = select(i, Inventory.bank:GetChildren())
        if child and child.location and child:IsShown() and child.icon then
            slot = child
            break
        end
    end

    if not slot then
        for i = 0, 200 do
            local f = _G["RealUIBank_Slot" .. i]
            if f and f:IsShown() and f.icon then
                slot = f
                break
            end
        end
    end

    if not slot then
        _G.print("|cffff0000[DIAG]|r No visible bank slot found.")
        return
    end

    _G.print("|cff00ccff[DIAG]|r Inspecting: " .. (slot:GetName() or "unnamed"))

    local keys = {
        "ItemContextOverlay", "searchOverlay", "IconBorder", "IconOverlay",
        "IconOverlay2", "NewItemTexture", "BattlepayItemTexture", "JunkIcon",
        "UpgradeIcon", "flash", "IconQuestTexture", "ProfessionQualityOverlay",
        "AugmentBorderAnimTexture",
    }
    for _, key in ipairs(keys) do
        local tex = slot[key]
        if tex then
            local shown = tex:IsShown()
            local visible = tex:IsVisible()
            local alpha = tex:GetAlpha()
            local parent = tex:GetParent() and tex:GetParent():GetName() or "?"
            _G.print(("  %s: shown=%s visible=%s alpha=%.2f parent=%s"):format(
                key, tostring(shown), tostring(visible), alpha, parent))
            if visible and alpha > 0 then
                local ok, r, g, b, a = pcall(tex.GetVertexColor, tex)
                if ok and r then
                    _G.print(("    vertexColor: %.2f, %.2f, %.2f, %.2f"):format(r, g, b, a or 1))
                end
            end
        else
            _G.print(("  %s: nil"):format(key))
        end
    end

    local normalTex = slot:GetNormalTexture()
    if normalTex then
        _G.print(("  NormalTexture: shown=%s visible=%s alpha=%.2f tex=%s"):format(
            tostring(normalTex:IsShown()), tostring(normalTex:IsVisible()),
            normalTex:GetAlpha(), tostring(normalTex:GetTexture())))
    else
        _G.print("  NormalTexture: nil")
    end

    local icon = slot.icon
    if icon then
        local r, g, b, a = icon:GetVertexColor()
        _G.print(("  icon vertexColor: %.2f, %.2f, %.2f, %.2f"):format(r, g, b, a or 1))
        _G.print(("  icon shown=%s visible=%s alpha=%.2f"):format(
            tostring(icon:IsShown()), tostring(icon:IsVisible()), icon:GetAlpha()))
    end

    if slot._auroraIconBorder then
        local ok, r, g, b, a = pcall(slot.GetBackdropColor, slot)
        if ok and r then
            _G.print(("  backdropColor: %.2f, %.2f, %.2f, %.2f"):format(r, g, b, a or 1))
        end
        local ok2, r2, g2, b2, a2 = pcall(slot.GetBackdropBorderColor, slot)
        if ok2 and r2 then
            _G.print(("  backdropBorderColor: %.2f, %.2f, %.2f, %.2f"):format(r2, g2, b2, a2 or 1))
        end
    end

    _G.print("|cff00ccff[DIAG]|r All visible regions:")
    local regions = {slot:GetRegions()}
    for i, region in ipairs(regions) do
        if region:IsVisible() and region:GetAlpha() > 0 then
            local rtype = region:GetObjectType()
            local name = region:GetName() or "anon"
            local alpha = region:GetAlpha()
            local layer, sublayer = region:GetDrawLayer()
            local w, h = region:GetSize()
            _G.print(("  [%d] %s '%s' layer=%s/%s alpha=%.2f size=%.0fx%.0f"):format(
                i, rtype, name, tostring(layer), tostring(sublayer), alpha, w or 0, h or 0))
            if rtype == "Texture" then
                local ok, r, g, b, a = pcall(region.GetVertexColor, region)
                if ok and r then
                    _G.print(("       vertexColor: %.2f, %.2f, %.2f, %.2f"):format(r, g, b, a or 1))
                end
                local tex = region:GetTexture()
                if tex then
                    _G.print(("       texture: %s"):format(tostring(tex)))
                end
            end
        end
    end

    _G.print(("  itemContextMatchResult: %s"):format(tostring(slot.itemContextMatchResult)))
    _G.print(("  matchesSearch: %s"):format(tostring(slot.matchesSearch)))
end
