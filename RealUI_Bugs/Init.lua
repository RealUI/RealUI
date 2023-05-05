-- Disable other bug catchers
for i, addon in _G.next, {"!BugGrabber", "!Swatter", "!ImprovedErrorFrame"} do
    local _, _, _, enabled = _G.GetAddOnInfo(addon)
    if enabled then
        _G.DisableAddOn(addon, true)
    end
end

-- Disable !BugGrabber displays
for i = 1, _G.GetNumAddOns() do
    local meta = _G.C_AddOns.GetAddOnMetadata(i, "X-BugGrabber-Display")
    if meta then
        local _, _, _, enabled = _G.GetAddOnInfo(i)
        if enabled then
            _G.DisableAddOn(i, true)
        end
    end
end

_G.ScriptErrorsFrame:SetSize(600, 400)
_G.ScriptErrorsFrame:SetScale(_G.UIParent:GetScale())
_G.ScriptErrorsFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", -26, 38)
_G.ScriptErrorsFrame.ScrollFrame.Text:SetPoint("BOTTOMRIGHT", -26, 38)
