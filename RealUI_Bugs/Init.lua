-- local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata

-- Disable other bug catchers
for i, addon in _G.next, {"!BugGrabber", "!Swatter", "!ImprovedErrorFrame"} do
    local _, _, _, enabled = _G.C_AddOns.GetAddOnInfo(addon)
    if enabled then
        _G.C_AddOns.DisableAddOn(addon)
    end
end

-- Disable !BugGrabber displays
for i = 1, _G.C_AddOns.GetNumAddOns() do
    local meta = _G.C_AddOns.GetAddOnMetadata(i, "X-BugGrabber-Display")
    if meta then
        local _, _, _, enabled = _G.C_AddOns.GetAddOnInfo(i)
        if enabled then
            _G.C_AddOns.DisableAddOn(i)
        end
    end
end

_G.ScriptErrorsFrame:SetSize(600, 400)
_G.ScriptErrorsFrame:SetScale(_G.UIParent:GetScale())
_G.ScriptErrorsFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", -26, 38)
_G.ScriptErrorsFrame.ScrollFrame.Text:SetPoint("BOTTOMRIGHT", -26, 38)
