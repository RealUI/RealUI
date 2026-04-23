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

-- Blizzard PrivateAuras race workaround:
-- HandleUpdateInfo() can receive updatedAuraInstanceIDs where the aura data is
-- already gone. Blizzard then dereferences newAura.isPrivate and errors.
do
    local function PatchPrivateAurasWatcher()
        local privateAuras = _G["PrivateAuras"]
        local privateAurasAPI = _G["C_UnitAurasPrivate"]
        local watcher = privateAuras and privateAuras.PrivateAuraUnitWatcher
        if type(watcher) ~= "table" or watcher._realuiPrivateAuraPatched then
            return
        end
        if type(privateAurasAPI) ~= "table" then
            return
        end

        local originalHandleUpdateInfo = watcher.HandleUpdateInfo
        if type(originalHandleUpdateInfo) ~= "function" then
            return
        end

        watcher.HandleUpdateInfo = function(self, privateAuraSource, updateInfo)
            if type(updateInfo) == "table" and not updateInfo.isFullUpdate and type(updateInfo.updatedAuraInstanceIDs) == "table" and type(self) == "table" and self.auras and self.unit then
                local filteredIDs
                local removedAny = false

                for i = 1, #updateInfo.updatedAuraInstanceIDs do
                    local auraInstanceID = updateInfo.updatedAuraInstanceIDs[i]
                    local keepID = true

                    if self.auras[auraInstanceID] ~= nil then
                        local newAura = privateAurasAPI.GetAuraDataByAuraInstanceIDPrivate(self.unit, auraInstanceID)
                        if newAura == nil then
                            keepID = false
                            removedAny = true
                        end
                    end

                    if keepID then
                        if not filteredIDs then
                            filteredIDs = {}
                        end
                        filteredIDs[#filteredIDs + 1] = auraInstanceID
                    end
                end

                if removedAny then
                    local safeUpdateInfo = {}
                    for k, v in _G.pairs(updateInfo) do
                        safeUpdateInfo[k] = v
                    end
                    safeUpdateInfo.updatedAuraInstanceIDs = filteredIDs or {}
                    updateInfo = safeUpdateInfo
                end
            end

            return originalHandleUpdateInfo(self, privateAuraSource, updateInfo)
        end

        watcher._realuiPrivateAuraPatched = true
    end

    local f = _G.CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, _, addon)
        if addon == "Blizzard_PrivateAurasUI" then
            PatchPrivateAurasWatcher()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)

    if _G.C_AddOns.IsAddOnLoaded("Blizzard_PrivateAurasUI") then
        PatchPrivateAurasWatcher()
        f:UnregisterEvent("ADDON_LOADED")
    end
end
