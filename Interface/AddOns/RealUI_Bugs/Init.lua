-- Disable other bug catchers
for i, addon in _G.next, {"!BugGrabber", "!Swatter", "!ImprovedErrorFrame"} do
    local _, _, _, enabled = _G.GetAddOnInfo(addon)
    if enabled then
        _G.DisableAddOn(addon, true)
    end
end

-- Disable !BugGrabber displays
for i = 1, _G.GetNumAddOns() do
    local meta = _G.GetAddOnMetadata(i, "X-BugGrabber-Display")
    if meta then
        local _, _, _, enabled = _G.GetAddOnInfo(i)
        if enabled then
            _G.DisableAddOn(i, true)
        end
    end
end


-- Filter file load warnings
_G.UIParent:UnregisterEvent("LUA_WARNING")
local f = _G.CreateFrame("Frame")
f:SetScript("OnEvent", function(self, ev, warnType, warnMessage)
    if warnMessage:match("^Couldn't open") or warnMessage:match("^Error loading") or warnMessage:match("^%(null%)") then
        return
    end
    _G.geterrorhandler()(warnMessage)
end)
f:RegisterEvent("LUA_WARNING")
