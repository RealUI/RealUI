local ADDON_NAME, private = ... -- luacheck: ignore

-- RealUI Profile Coordinator
-- Orchestrates profile operations across all three AceDB scopes:
-- Core (RealUI_ConfigDB), Skins (RealUI_SkinsDB), Action Bars
-- (RealUI_ActionBarsDB).
--
-- Bartender4 support was removed in 4.0.0 (2026-08-22) along with the bundled
-- addon; RealUI_ActionBars is the only bar backend. The action-bar scope keeps
-- its ORIGINAL wire value "bt4" on purpose — it is persisted in saved
-- variables (db.char.scopeLinks.bt4, the "action bars change with spec" flag)
-- and appears as a key inside exported profile strings that users have
-- already shared. Renaming the value would silently reset that preference and
-- break importing older exports; only the constant's name changed.

-- luacheck: globals next type pairs ipairs tostring

local RealUI = private.RealUI
local L = RealUI.L
local debug = RealUI.GetDebug("ProfileCoordinator")

local ProfileCoordinator = {}
RealUI.ProfileCoordinator = ProfileCoordinator

-- Scope constants
ProfileCoordinator.SCOPE_CORE = "core"
ProfileCoordinator.SCOPE_SKINS = "skins"
ProfileCoordinator.SCOPE_ACTIONBARS = "bt4"  -- legacy wire value, see header
-- Deprecated alias, kept so any out-of-tree caller keeps working.
ProfileCoordinator.SCOPE_BT4 = ProfileCoordinator.SCOPE_ACTIONBARS

-- Internal state
local switchInProgress = false

-- Combat deferral frame (dedicated frame to avoid conflicts with other PLAYER_REGEN_ENABLED handlers)
local combatDeferFrame = _G.CreateFrame("Frame")
combatDeferFrame:Hide()

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

--- Get the Skins AceDB instance, if available.
local function GetSkinsDB()
    local skinsModule = RealUI:GetModule("Skins", true)
    if skinsModule and skinsModule.db then
        return skinsModule.db
    end
    return nil
end

--- Check whether a profile name exists in an AceDB instance.
local function ProfileExistsInDB(acedb, profileName)
    if not acedb then return false end
    local profiles = acedb:GetProfiles()
    if not profiles then return false end
    for _, name in ipairs(profiles) do
        if name == profileName then
            return true
        end
    end
    return false
end

------------------------------------------------------------
-- Action bars scope (RealUI_ActionBars)
--
-- Gated by the SCOPE_ACTIONBARS link flag ("action bars change with spec",
-- default true). RealUI_ActionBarsDB must follow RealUI/RealUI-Healing so
-- per-layout bar settings apply on layout switches (B44).
------------------------------------------------------------

--- Get the RealUI_ActionBars AceAddon (registered as "RealUIActionBars"), or nil.
local function GetRABAddon()
    local AceAddon = _G.LibStub and _G.LibStub("AceAddon-3.0", true)
    local addon = AceAddon and AceAddon:GetAddon("RealUIActionBars", true)
    if addon and addon.db and addon.db.SetProfile then
        return addon
    end
    return nil
end

--- Check whether a profile name already exists in RealUI_ActionBarsDB.
local function ProfileExistsInRAB(profileName)
    local sv = _G.RealUI_ActionBarsDB
    if type(sv) ~= "table" then return false end
    if type(sv.profiles) == "table" and sv.profiles[profileName] ~= nil then
        return true
    end
    if type(sv.namespaces) == "table" then
        for _, nsData in pairs(sv.namespaces) do
            if type(nsData) == "table" and type(nsData.profiles) == "table"
               and nsData.profiles[profileName] ~= nil then
                return true
            end
        end
    end
    if type(sv.profileKeys) == "table" then
        for _, pName in pairs(sv.profileKeys) do
            if pName == profileName then return true end
        end
    end
    return false
end

--- Switch RealUI_ActionBars to profileName. A brand-new profile is seeded by
--- copying the current one so the user's bar settings carry over instead of
--- resetting to defaults (never write defaults over saved settings).
--- Returns true if the scope was switched.
local function SwitchActionBarsScope(profileName)
    local rab = GetRABAddon()
    if not rab then
        debug("RealUI_ActionBars not loaded, skipping bars scope")
        return false
    end

    local current = rab.db:GetCurrentProfile()
    if current == profileName then
        debug("RealUI_ActionBars already on profile:", profileName)
        return true
    end

    local isNew = not ProfileExistsInRAB(profileName)
    debug("Switching RealUI_ActionBars scope to:", profileName, "isNew:", tostring(isNew))
    rab.db:SetProfile(profileName)

    if isNew and current and current ~= profileName then
        debug("Seeding new RealUI_ActionBars profile from:", current)
        rab.db:CopyProfile(current, true)
    end
    return true
end


------------------------------------------------------------
-- Scope Link State (reads/writes from db.profile.scopeLinks)
------------------------------------------------------------

--- Check whether a scope is linked for coordinated switching.
--- @param scope string One of SCOPE_SKINS or SCOPE_ACTIONBARS
--- @return boolean
function ProfileCoordinator:IsScopeLinked(scope)
    if not RealUI.db then return false end
    -- nil falls back to the documented default (skins unlinked, bt4 linked):
    -- characters whose saved variables predate char-scoped scopeLinks have no
    -- stored table, and requiring an explicit true silently unlinked the bars
    -- scope for them (same nil-tolerant reading /systemstatus already uses).
    local links = RealUI.db.char.scopeLinks
    if scope == self.SCOPE_SKINS then
        return (links and links.skins) == true
    elseif scope == self.SCOPE_ACTIONBARS then
        return not links or links.bt4 ~= false
    end
    -- Core is always "linked" (it is the primary scope)
    return false
end

--- Set whether a scope participates in coordinated switching.
--- @param scope string One of SCOPE_SKINS or SCOPE_ACTIONBARS
--- @param linked boolean
function ProfileCoordinator:SetScopeLinked(scope, linked)
    if not RealUI.db then return end
    local links = RealUI.db.char.scopeLinks
    if not links then
        RealUI.db.char.scopeLinks = {}
        links = RealUI.db.char.scopeLinks
    end

    if scope == self.SCOPE_SKINS then
        links.skins = linked and true or false
        debug("Skins scope link set to:", links.skins)
    elseif scope == self.SCOPE_ACTIONBARS then
        -- Storage key stays `bt4` (persisted + inside exported strings).
        links.bt4 = linked and true or false
        debug("Action bars scope link set to:", links.bt4)

        -- Sync RealUI_ActionBars' LibDualSpec mappings to match Core's so
        -- spec-triggered switches stay coordinated.
        if linked and RealUI.DualSpecSystem and RealUI.DualSpecSystem:IsLibDualSpecReady() then
            local rab = GetRABAddon()
            if rab and rab.db.SetDualSpecProfile then
                for specIndex = 1, #RealUI.charInfo.specs do
                    local profileName = RealUI.DualSpecSystem:GetSpecProfile(specIndex)
                    if profileName then
                        debug("Syncing action bars LDS on link enable, spec:", specIndex, "->", profileName)
                        rab.db:SetDualSpecProfile(profileName, specIndex)
                    end
                end
            end
        end
    end
end

--- Return a table of linked scopes (excluding Core, which is always switched).
--- @return table  e.g. { skins = true, bt4 = false }
function ProfileCoordinator:GetLinkedScopes()
    return {
        skins = self:IsScopeLinked(self.SCOPE_SKINS),
        bt4   = self:IsScopeLinked(self.SCOPE_ACTIONBARS),
    }
end

------------------------------------------------------------
-- Scope Profile Queries
------------------------------------------------------------

--- Get the currently active profile name for a given scope.
--- @param scope string One of SCOPE_CORE, SCOPE_SKINS, SCOPE_ACTIONBARS
--- @return string|nil
function ProfileCoordinator:GetScopeProfile(scope)
    if scope == self.SCOPE_CORE then
        if RealUI.db then
            return RealUI.db:GetCurrentProfile()
        end
    elseif scope == self.SCOPE_SKINS then
        local skinsDB = GetSkinsDB()
        if skinsDB then
            return skinsDB:GetCurrentProfile()
        end
    elseif scope == self.SCOPE_ACTIONBARS then
        local rab = GetRABAddon()
        if rab then
            return rab.db:GetCurrentProfile()
        end
        -- Addon not loaded: fall back to the saved profileKeys mapping.
        local sv = _G.RealUI_ActionBarsDB
        if type(sv) == "table" and type(sv.profileKeys) == "table" and RealUI.key then
            return sv.profileKeys[RealUI.key]
        end
    end
    return nil
end

--- Get the active profile for every scope.
--- @return table  { core = "...", skins = "...", bt4 = "..." }
function ProfileCoordinator:GetAllScopeProfiles()
    return {
        core  = self:GetScopeProfile(self.SCOPE_CORE),
        skins = self:GetScopeProfile(self.SCOPE_SKINS),
        bt4   = self:GetScopeProfile(self.SCOPE_ACTIONBARS),
    }
end

------------------------------------------------------------
-- Reentrancy Guard
------------------------------------------------------------

--- @return boolean  true while a coordinated switch is executing
function ProfileCoordinator:IsSwitchInProgress()
    return switchInProgress
end


------------------------------------------------------------
-- Coordinated Switch
------------------------------------------------------------

--- Switch all linked scopes to the given profile name.
---
--- Returns:
---   success (boolean) – true if the switch completed (even with warnings)
---   warnings (table)  – array of warning strings for skipped scopes
---
--- If called during combat lockdown the switch is deferred to
--- PLAYER_REGEN_ENABLED and the function returns false immediately
--- with a "pending" warning.
---
--- If a switch is already in progress (reentrancy), returns false.
---
--- @param profileName string  Target profile name
--- @param forceCreate boolean|nil  If true, create profiles in linked scopes even if they don't exist yet
--- @return boolean, string[]
function ProfileCoordinator:CoordinatedSwitch(profileName, forceCreate)
    debug("CoordinatedSwitch requested:", profileName)

    -- Reentrancy guard
    if switchInProgress then
        debug("Switch already in progress, rejecting")
        return false, {"A profile switch is already in progress."}
    end

    -- Combat lockdown check — defer until combat ends
    if _G.InCombatLockdown() then
        debug("In combat lockdown, deferring switch")
        RealUI:Notification(
            L["Alert_CombatLockdown"],
            true,
            "Profile switch to '" .. profileName .. "' will apply after combat.",
            nil,
            [[Interface\AddOns\RealUI\Media\Notification_Alert]]
        )
        combatDeferFrame:SetScript("OnEvent", function(frame)
            frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
            frame:SetScript("OnEvent", nil)
            self:CoordinatedSwitch(profileName, forceCreate)
        end)
        combatDeferFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return false, {"Switch deferred until combat ends."}
    end

    -- Begin switch
    switchInProgress = true

    local warnings = {}
    local switchedScopes = {}

    -- When forceCreate is true (new profile), snapshot source profile names
    -- so we can CopyProfile after switching to seed the new profile with data.
    local sourceCoreProfile, sourceSkinsProfile
    if forceCreate then
        sourceCoreProfile = RealUI.db:GetCurrentProfile()
        local skinsDB = GetSkinsDB()
        if skinsDB then
            sourceSkinsProfile = skinsDB:GetCurrentProfile()
        end
    end

    -- 1. Action bars scope — switch FIRST so the bars DB is already on the
    -- new profile when Core's OnProfileUpdate cascade fires. RealUI's
    -- ActionBars module applies positioning during that cascade and reads
    -- live bar state to reposition bars. If the bars DB is still on the old
    -- profile when the cascade runs, the bars are written/read to the wrong
    -- profile and need a reload to self-correct.
    if self:IsScopeLinked(self.SCOPE_ACTIONBARS) then
        if SwitchActionBarsScope(profileName) then
            switchedScopes[#switchedScopes + 1] = self.SCOPE_ACTIONBARS
        end
    end

    -- 2. Core scope — fires the OnProfileUpdate cascade (modules, positioners, etc.)
    debug("Switching Core scope to:", profileName)
    RealUI.db:SetProfile(profileName)  -- triggers OnProfileUpdate via AceDB callback
    switchedScopes[#switchedScopes + 1] = self.SCOPE_CORE

    -- Copy source data into new Core profile
    if forceCreate and sourceCoreProfile and sourceCoreProfile ~= profileName then
        debug("Copying Core profile data from:", sourceCoreProfile)
        RealUI.db:CopyProfile(sourceCoreProfile, true)
    end

    -- 3. Skins scope
    if self:IsScopeLinked(self.SCOPE_SKINS) then
        local skinsDB = GetSkinsDB()
        if skinsDB then
            if forceCreate or ProfileExistsInDB(skinsDB, profileName) then
                debug("Switching Skins scope to:", profileName)
                skinsDB:SetProfile(profileName)
                switchedScopes[#switchedScopes + 1] = self.SCOPE_SKINS

                -- Copy source data into new Skins profile
                if forceCreate and sourceSkinsProfile and sourceSkinsProfile ~= profileName then
                    debug("Copying Skins profile data from:", sourceSkinsProfile)
                    skinsDB:CopyProfile(sourceSkinsProfile, true)
                end
            else
                local msg = "Skins: profile '" .. profileName .. "' does not exist — skipped."
                debug(msg)
                warnings[#warnings + 1] = msg
            end
        else
            local msg = "Skins: database not available — skipped."
            debug(msg)
            warnings[#warnings + 1] = msg
        end
    end

    -- Switch complete
    switchInProgress = false

    -- Fire completion message (Req 7.3)
    debug("Coordinated switch complete. Scopes switched:", table.concat(switchedScopes, ", "))
    RealUI:SendMessage("REALUI_PROFILES_SWITCHED", profileName, switchedScopes)

    -- Show warnings to user if any
    if #warnings > 0 then
        for _, w in ipairs(warnings) do
            RealUI:Notification(
                "Profile Switch",
                false,
                w,
                nil,
                [[Interface\AddOns\RealUI\Media\Notification_Alert]]
            )
        end
    end

    return true, warnings
end

------------------------------------------------------------
-- OnProfileChanged Hook
-- Catches ANY Core profile switch (LibDualSpec, manual, etc.)
-- and coordinates linked scopes to follow.
------------------------------------------------------------

--- Called by AceDB whenever Core's profile changes.
--- If the switch was NOT initiated by CoordinatedSwitch (i.e. switchInProgress
--- is false), we coordinate Skins and BT4 to follow.
--- This catches LibDualSpec-triggered switches and any other external callers.
local function OnCoreProfileChanged(_, _, newProfile)
    -- If CoordinatedSwitch is running, it already handles Skins/BT4
    if switchInProgress then
        debug("OnCoreProfileChanged: switchInProgress, skipping (CoordinatedSwitch handles it)")
        return
    end

    debug("OnCoreProfileChanged: external switch detected, profile =", newProfile)

    -- Read link state (stored in db.char, persists across profile switches)
    local linkSkins = ProfileCoordinator:IsScopeLinked(ProfileCoordinator.SCOPE_SKINS)
    local linkActionBars   = ProfileCoordinator:IsScopeLinked(ProfileCoordinator.SCOPE_ACTIONBARS)

    if not linkSkins and not linkActionBars then
        debug("OnCoreProfileChanged: no scopes linked, nothing to coordinate")
        return
    end

    debug("OnCoreProfileChanged: coordinating linked scopes, skins =", tostring(linkSkins), "actionbars =", tostring(linkActionBars))

    -- Switch Skins scope
    if linkSkins then
        local skinsDB = GetSkinsDB()
        if skinsDB then
            -- Snapshot source profile before switching so we can seed new profiles
            local sourceProfile = skinsDB:GetCurrentProfile()
            local isNew = not ProfileExistsInDB(skinsDB, newProfile)

            debug("OnCoreProfileChanged: switching Skins to", newProfile, "isNew:", isNew)
            skinsDB:SetProfile(newProfile)

            -- If the profile was just created, copy source data so settings
            -- (UI scale, colors, etc.) carry over instead of being empty defaults.
            if isNew and sourceProfile and sourceProfile ~= newProfile then
                debug("OnCoreProfileChanged: copying Skins data from", sourceProfile)
                skinsDB:CopyProfile(sourceProfile, true)
            end
        end
    end

    -- Switch the action bars scope. This callback registers BEFORE RealUI's
    -- own OnProfileUpdate, so the bars DB is on the new profile before the
    -- Core cascade reads it — the same bars-before-Core invariant
    -- CoordinatedSwitch enforces.
    if linkActionBars then
        SwitchActionBarsScope(newProfile)
    end
end

--- Register the callback once RealUI.db is available.
--- Called from outside after Core.lua sets up the database.
function ProfileCoordinator:RegisterProfileCallback()
    if RealUI.db then
        RealUI.db.RegisterCallback(self, "OnProfileChanged", OnCoreProfileChanged)
        RealUI.db.RegisterCallback(self, "OnProfileReset", OnCoreProfileChanged)
        debug("Registered OnProfileChanged callback for coordinated scope switching")
    end
end

------------------------------------------------------------
-- Register with RealUI namespace
------------------------------------------------------------
RealUI:RegisterNamespace("ProfileCoordinator", ProfileCoordinator)
