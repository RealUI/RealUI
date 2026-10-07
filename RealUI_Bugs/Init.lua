-- local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata

-- Disable other bug catchers
for _, addon in _G.next, {"!BugGrabber", "!Swatter", "!ImprovedErrorFrame"} do
    local _, _, _, enabled = _G.C_AddOns.GetAddOnInfo(addon)
    if enabled then
        _G.C_AddOns.DisableAddOn(addon)
    end
end

-- Disable !BugGrabber displays
for i = 1, _G.C_AddOns.GetNumAddOns() do
    local meta = _G.C_AddOns.GetAddOnMetadata(i, "X-BugGrabber-Display")
    if meta then
        local name, _, _, loadable = _G.C_AddOns.GetAddOnInfo(i)
        if loadable and name then
            _G.C_AddOns.DisableAddOn(name)
        end
    end
end

_G.ScriptErrorsFrame:SetSize(600, 400)
_G.ScriptErrorsFrame:SetScale(_G.UIParent:GetScale())
_G.ScriptErrorsFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", -26, 38)
_G.ScriptErrorsFrame.ScrollFrame.Text:SetPoint("BOTTOMRIGHT", -26, 38)

-- Grid2 workaround: Grid2's GridLayout:UpdateFrame() calls
-- SetClampedToScreen(p.clamp) — if p.clamp is nil or non-boolean,
-- the WoW API throws.  Patch Grid2DB before Grid2's OnInitialize.
do
    local f = _G.CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, _, addon)
        if addon == "Grid2" then
            self:UnregisterEvent("ADDON_LOADED")
            local db = _G.Grid2DB
            if type(db) == "table" and type(db.namespaces) == "table" then
                local layout = db.namespaces.Grid2Layout
                if type(layout) == "table" and type(layout.profiles) == "table" then
                    for _, profile in _G.next, layout.profiles do
                        if type(profile) == "table" then
                            -- Fix legacy key written by older RealUI
                            if profile.clampToScreen ~= nil then
                                profile.clampToScreen = nil
                            end
                            -- Ensure the correct key is a boolean
                            if type(profile.clamp) ~= "boolean" then
                                profile.clamp = true
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- The Blizzard PrivateAuras workarounds that were here are removed (2026-10-06).
-- They replaced PrivateAuras.PrivateAuraUnitWatcher.HandleUpdateInfo and
-- PrivateAuraAnchorContainerMixin.CheckExistingDispelHasCorrectType with RealUI
-- closures, so every private aura update ran under RealUI taint (tracker taint
-- doctrine: never replace a Blizzard function to guard a Blizzard bug). Both
-- bugs are fixed in 12.1 (the watcher checks `newAura`, assertsafe checks
-- geterrorhandler()), and the dispel wrapper no longer matched 12.1's
-- (privateSource, aura, auraInstanceID) signature: it indexed the boolean
-- privateSource as the aura.
