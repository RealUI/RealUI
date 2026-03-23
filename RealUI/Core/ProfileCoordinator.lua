local ADDON_NAME, private = ... -- luacheck: ignore

-- RealUI Profile Coordinator
-- Orchestrates profile operations across all three AceDB scopes:
-- Core (RealUI_ConfigDB), Skins (RealUI_SkinsDB), Bartender4 (Bartender4DB)

-- luacheck: globals next type pairs ipairs tostring

local RealUI = private.RealUI
local L = RealUI.L
local debug = RealUI.GetDebug("ProfileCoordinator")

local ProfileCoordinator = {}
RealUI.ProfileCoordinator = ProfileCoordinator

-- Scope constants
ProfileCoordinator.SCOPE_CORE = "core"
ProfileCoordinator.SCOPE_SKINS = "skins"
ProfileCoordinator.SCOPE_BT4 = "bt4"

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

--- Check whether a profile name exists in Bartender4DB's ActionBars namespace.
local function ProfileExistsInBT4(profileName)
    local bt4db = _G.Bartender4DB
    if type(bt4db) ~= "table" then return false end
    -- BT4 stores profiles at the top level profileKeys and in namespaces
    if bt4db.profiles and bt4db.profiles[profileName] then
        return true
    end
    -- Also check ActionBars namespace profiles
    local ns = bt4db.namespaces
    if type(ns) == "table" and type(ns.ActionBars) == "table"
       and type(ns.ActionBars.profiles) == "table"
       and ns.ActionBars.profiles[profileName] then
        return true
    end
    -- Check profileKeys for any character mapped to this profile
    if type(bt4db.profileKeys) == "table" then
        for _, pName in pairs(bt4db.profileKeys) do
            if pName == profileName then return true end
        end
    end
    return false
end


------------------------------------------------------------
-- Scope Link State (reads/writes from db.profile.scopeLinks)
------------------------------------------------------------

--- Check whether a scope is linked for coordinated switching.
--- @param scope string One of SCOPE_SKINS or SCOPE_BT4
--- @return boolean
function ProfileCoordinator:IsScopeLinked(scope)
    if not RealUI.db then return false end
    local links = RealUI.db.char.scopeLinks
    if not links then return false end

    if scope == self.SCOPE_SKINS then
        return links.skins == true
    elseif scope == self.SCOPE_BT4 then
        return links.bt4 == true
    end
    -- Core is always "linked" (it is the primary scope)
    return false
end

--- Set whether a scope participates in coordinated switching.
--- @param scope string One of SCOPE_SKINS or SCOPE_BT4
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
    elseif scope == self.SCOPE_BT4 then
        links.bt4 = linked and true or false
        debug("BT4 scope link set to:", links.bt4)

        -- When BT4 is linked, sync its LibDualSpec mappings to match Core's
        -- so spec-triggered switches stay coordinated.
        if linked and RealUI.DualSpecSystem and RealUI.DualSpecSystem:IsLibDualSpecReady() then
            local bt4Addon = _G.Bartender4
            if bt4Addon and bt4Addon.db and bt4Addon.db.SetDualSpecProfile then
                for specIndex = 1, #RealUI.charInfo.specs do
                    local profileName = RealUI.DualSpecSystem:GetSpecProfile(specIndex)
                    if profileName then
                        debug("Syncing BT4 LDS on link enable, spec:", specIndex, "->", profileName)
                        bt4Addon.db:SetDualSpecProfile(profileName, specIndex)
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
        bt4   = self:IsScopeLinked(self.SCOPE_BT4),
    }
end

------------------------------------------------------------
-- Scope Profile Queries
------------------------------------------------------------

--- Get the currently active profile name for a given scope.
--- @param scope string One of SCOPE_CORE, SCOPE_SKINS, SCOPE_BT4
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
    elseif scope == self.SCOPE_BT4 then
        local bt4db = _G.Bartender4DB
        if type(bt4db) == "table" and type(bt4db.profileKeys) == "table" and RealUI.key then
            return bt4db.profileKeys[RealUI.key]
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
        bt4   = self:GetScopeProfile(self.SCOPE_BT4),
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
    local sourceCoreProfile, sourceSkinsProfile, sourceBT4Profile
    if forceCreate then
        sourceCoreProfile = RealUI.db:GetCurrentProfile()
        local skinsDB = GetSkinsDB()
        if skinsDB then
            sourceSkinsProfile = skinsDB:GetCurrentProfile()
        end
        local bt4Addon = _G.Bartender4
        if bt4Addon and bt4Addon.db then
            sourceBT4Profile = bt4Addon.db:GetCurrentProfile()
        end
    end

    -- 1. Core scope — always switched
    debug("Switching Core scope to:", profileName)
    RealUI.db:SetProfile(profileName)  -- triggers OnProfileUpdate via AceDB callback
    switchedScopes[#switchedScopes + 1] = self.SCOPE_CORE

    -- Copy source data into new Core profile
    if forceCreate and sourceCoreProfile and sourceCoreProfile ~= profileName then
        debug("Copying Core profile data from:", sourceCoreProfile)
        RealUI.db:CopyProfile(sourceCoreProfile, true)
    end

    -- 2. Skins scope
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

    -- 3. Bartender4 scope
    if self:IsScopeLinked(self.SCOPE_BT4) then
        local bt4Addon = _G.Bartender4
        if bt4Addon and bt4Addon.db and bt4Addon.db.SetProfile then
            if forceCreate or ProfileExistsInBT4(profileName) then
                debug("Switching BT4 scope to:", profileName)
                bt4Addon.db:SetProfile(profileName)
                switchedScopes[#switchedScopes + 1] = self.SCOPE_BT4

                -- Copy source data into new BT4 profile
                if forceCreate and sourceBT4Profile and sourceBT4Profile ~= profileName then
                    debug("Copying BT4 profile data from:", sourceBT4Profile)
                    bt4Addon.db:CopyProfile(sourceBT4Profile, true)
                end
            else
                local msg = "Bartender4: profile '" .. profileName .. "' does not exist — skipped."
                debug(msg)
                warnings[#warnings + 1] = msg
            end
        else
            -- Fallback: update profileKeys directly (less ideal but functional)
            local bt4db = _G.Bartender4DB
            if type(bt4db) == "table" and type(bt4db.profileKeys) == "table" and RealUI.key then
                if forceCreate or ProfileExistsInBT4(profileName) then
                    debug("Switching BT4 scope via profileKeys to:", profileName)
                    bt4db.profileKeys[RealUI.key] = profileName
                    switchedScopes[#switchedScopes + 1] = self.SCOPE_BT4
                end
            else
                -- BT4 not loaded — silently skip (Req 7.4)
                debug("Bartender4DB not loaded, skipping BT4 scope")
            end
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
    local linkBT4   = ProfileCoordinator:IsScopeLinked(ProfileCoordinator.SCOPE_BT4)

    if not linkSkins and not linkBT4 then
        debug("OnCoreProfileChanged: no scopes linked, nothing to coordinate")
        return
    end

    debug("OnCoreProfileChanged: coordinating linked scopes, skins =", tostring(linkSkins), "bt4 =", tostring(linkBT4))

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

    -- Switch BT4 scope
    if linkBT4 then
        local bt4Addon = _G.Bartender4
        if bt4Addon and bt4Addon.db and bt4Addon.db.SetProfile then
            local sourceProfile = bt4Addon.db:GetCurrentProfile()
            local isNew = not ProfileExistsInBT4(newProfile)

            debug("OnCoreProfileChanged: switching BT4 to", newProfile, "isNew:", isNew)
            bt4Addon.db:SetProfile(newProfile)

            if isNew and sourceProfile and sourceProfile ~= newProfile then
                debug("OnCoreProfileChanged: copying BT4 data from", sourceProfile)
                bt4Addon.db:CopyProfile(sourceProfile, true)
            end
        else
            local bt4db = _G.Bartender4DB
            if type(bt4db) == "table" and type(bt4db.profileKeys) == "table" and RealUI.key then
                debug("OnCoreProfileChanged: switching BT4 via profileKeys to", newProfile)
                bt4db.profileKeys[RealUI.key] = newProfile
            end
        end
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
