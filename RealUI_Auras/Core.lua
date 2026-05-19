local AurasAddon = LibStub("AceAddon-3.0"):NewAddon("RealUI_Auras", "AceEvent-3.0")
RealUI_Auras = AurasAddon

local Groups -- forward ref, resolved in OnEnable
local Icons -- forward ref, resolved in OnEnable

---------------------------------------------------------------------------
-- 6.2  UNIT_AURA debounce state
---------------------------------------------------------------------------
local dirtyGroups = {}

function AurasAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("RealUI_AurasDB", self.defaults or {}, "RealUI")

    -- Register with the install wizard (API defined by realui-display-wizard spec)
    if RealUI and RealUI.InstallWizard and RealUI.InstallWizard.RegisterStage then
        RealUI.InstallWizard:RegisterStage("STAGE_COOLDOWNS", {
            title       = "Cooldown Layouts",
            description = "Apply RealUI's recommended cooldown tracker layouts for your specialization.",
            available   = function() return C_CooldownViewer.IsCooldownViewerAvailable() end,
            OnApply     = function()
                -- Merge presets for ALL specs of the player's class at once.
                -- Doing it up-front avoids per-spec-swap merges (which have
                -- historically been unreliable) and ensures the picker shows
                -- every spec's layout immediately after the next reload.
                local added, _, err = RealUI_Auras.CooldownViewer.MergeAllSpecsForClass()
                if err then
                    print(("|cffff4444[RealUI_Auras]|r Cooldown preset apply failed: %s"):format(err))
                end
                if added and added > 0 then
                    StaticPopup_Show("REALUI_AURAS_RELOAD")
                end
                self.db.char.cooldownPresetOffered = true
            end,
        })
    end
end

function AurasAddon:OnEnable()
    Groups = self.Groups
    Icons = self.Icons

    -- Determine if any aura group is enabled (i.e. the replacement system is active)
    local anyGroupEnabled = false
    for _, group in ipairs(Groups.All()) do
        if not group.disabled then
            anyGroupEnabled = true
            break
        end
    end

    -- 10.1: Detect Masque and create a skinning group before any icons are created.
    -- Must happen before Groups.InitAll() since that triggers container creation
    -- which may trigger icon creation.
    if anyGroupEnabled then
        local MSQ = LibStub and LibStub("Masque", true)
        if MSQ then
            Icons.MasqueGroup = MSQ:Group("RealUI", "Auras")

            -- 10.4: Register Masque reskin callback for skin changes.
            -- Note: SetCallback is deprecated in modern Masque; use RegisterCallback.
            Icons.MasqueGroup:RegisterCallback(function()
                Icons.MasqueGroup:ReSkin()
            end)
        end
    end

    -- Only hide Blizzard buff frames and register aura events when the
    -- replacement aura system is active. When all groups are disabled
    -- (the new default), Blizzard's native frames remain untouched and
    -- no aura queries are made — eliminating the taint surface.
    if anyGroupEnabled then
        BuffFrame:Hide()
        DebuffFrame:Hide()

        -- 11.1: Permanently re-hide BuffFrame whenever Blizzard code shows it
        if not self._buffFrameHooked then
            BuffFrame:HookScript("OnShow", function(f) f:Hide() end)
            self._buffFrameHooked = true
        end

        -- 11.2: Same for DebuffFrame
        if not self._debuffFrameHooked then
            DebuffFrame:HookScript("OnShow", function(f) f:Hide() end)
            self._debuffFrameHooked = true
        end

        -- 6.2: UNIT_AURA (debounced redraw)
        self:RegisterEvent("UNIT_AURA")

        -- 6.3: PLAYER_TARGET_CHANGED → TargetBuffs, TargetDebuffs
        self:RegisterEvent("PLAYER_TARGET_CHANGED")

        -- 6.4: PLAYER_FOCUS_CHANGED → FocusBuffs, FocusDebuffs
        self:RegisterEvent("PLAYER_FOCUS_CHANGED")

        -- 6.5: UNIT_TARGET → ToTDebuffs (when target changes their target)
        self:RegisterEvent("UNIT_TARGET")

        -- 6.6: PLAYER_ENTERING_WORLD → full refresh after load screens
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")

        Groups.InitAll()
    else
        -- When all aura groups are disabled, ensure the oUF unit frame aura
        -- elements are enabled so users still see auras on their frames.
        -- This covers the case where a user previously had RealUI_Auras groups
        -- active (which disabled the oUF elements) and now has them off.
        self:EnableOufAuraElements()
    end

    -- 4.1: PLAYER_LOGIN → first-login CooldownViewer preset check and
    -- MergeAllSpecsForClass on subsequent logins (covers new specs/specs
    -- that failed to apply previously). CDM merging is intentionally
    -- NOT tied to PLAYER_SPECIALIZATION_CHANGED — merging during the
    -- spec-switch cascade destabilised BT4 bar positioning.
    self:RegisterEvent("PLAYER_LOGIN")
end

---------------------------------------------------------------------------
-- EnableOufAuraElements
-- When RealUI_Auras groups are all disabled, re-enable the oUF aura
-- elements on unit frames so target/focus/boss auras still display.
-- Deferred to after UnitFrames has spawned its frames.
---------------------------------------------------------------------------
function AurasAddon:EnableOufAuraElements()
    C_Timer.After(0, function()
        local UnitFrames = RealUI and RealUI:GetModule("UnitFrames", true)
        if not UnitFrames or not UnitFrames.db then return end

        local db = UnitFrames.db.profile
        local changed = false

        -- Target debuffs/buffs
        if db.units and db.units.target then
            if db.units.target.showTargetDebuffs == false then
                db.units.target.showTargetDebuffs = true
                changed = true
            end
            if db.units.target.showTargetBuffs == false then
                db.units.target.showTargetBuffs = true
                changed = true
            end
        end

        -- Boss debuffs/buffs
        if db.boss then
            if db.boss.showBossDebuffs == false then
                db.boss.showBossDebuffs = true
                changed = true
            end
            if db.boss.showBossBuffs == false then
                db.boss.showBossBuffs = true
                changed = true
            end
        end

        if changed then
            UnitFrames:RefreshUnits("AurasGroupsDisabled")
        end
    end)
end

---------------------------------------------------------------------------
-- 6.2  UNIT_AURA — debounced handler
-- Marks affected groups dirty, then schedules a single end-of-frame
-- flush that redraws only the groups whose monitored unit changed.
---------------------------------------------------------------------------
function AurasAddon:UNIT_AURA(_, unit)
    for _, group in ipairs(Groups.All()) do
        if Groups.MonitorsUnit(group, unit) then
            dirtyGroups[group.name] = true
        end
    end
    if not self._updatePending then
        self._updatePending = true
        C_Timer.After(0, function()
            self._updatePending = false
            for name in pairs(dirtyGroups) do
                Groups.Redraw(Groups.Get(name))
            end
            wipe(dirtyGroups)
        end)
    end
end

---------------------------------------------------------------------------
-- 6.3  PLAYER_TARGET_CHANGED
---------------------------------------------------------------------------
function AurasAddon:PLAYER_TARGET_CHANGED()
    local tb = Groups.Get("TargetBuffs")
    if tb then Groups.Redraw(tb) end

    local td = Groups.Get("TargetDebuffs")
    if td then Groups.Redraw(td) end
end

---------------------------------------------------------------------------
-- 6.4  PLAYER_FOCUS_CHANGED
---------------------------------------------------------------------------
function AurasAddon:PLAYER_FOCUS_CHANGED()
    local fb = Groups.Get("FocusBuffs")
    if fb then Groups.Redraw(fb) end

    local fd = Groups.Get("FocusDebuffs")
    if fd then Groups.Redraw(fd) end
end

---------------------------------------------------------------------------
-- 6.5  UNIT_TARGET — only care when the *target* changes their target
---------------------------------------------------------------------------
function AurasAddon:UNIT_TARGET(_, unit)
    if unit == "target" then
        local tot = Groups.Get("ToTDebuffs")
        if tot then Groups.Redraw(tot) end
    end
end

---------------------------------------------------------------------------
-- 6.6  PLAYER_ENTERING_WORLD
-- Re-hides Blizzard frames (they re-show after load screens) and does a
-- full refresh of all groups.
---------------------------------------------------------------------------
function AurasAddon:OnPlayerEnteringWorld()
    -- Only act when the replacement aura system is active
    BuffFrame:Hide()
    DebuffFrame:Hide()
    Groups.RefreshAll()
end

---------------------------------------------------------------------------
-- 4.1  PLAYER_LOGIN — first-login CooldownViewer preset check
-- Offers a one-time popup to apply RealUI cooldown presets if:
--   • The popup has not been offered before (db.char.cooldownPresetOffered)
--   • The RealUI install wizard has been completed
--   • No RealUI preset is already applied
---------------------------------------------------------------------------
function AurasAddon:PLAYER_LOGIN()
    local CooldownViewer = self.CooldownViewer

    -- BuffIcon countdown: install hook for future items, apply to any already created.
    CooldownViewer.InitBuffIconCountdown()
    local cdvDB = self.db.profile.cooldownViewer
    CooldownViewer.ApplyBuffIconCountdown(cdvDB and cdvDB.buffIconCountdown)

    -- If the preset popup was already offered, also re-attempt merging
    -- any missing per-spec layouts on login (covers new specs added in
    -- game updates, and recovers from any earlier merge failures that
    -- left specs without their preset).
    if self.db.char.cooldownPresetOffered then
        local added, _, err = CooldownViewer.MergeAllSpecsForClass()
        if err then
            print(("|cffff4444[RealUI_Auras]|r Cooldown merge-all-specs error: %s"):format(err))
        end
        if added and added > 0 then
            -- A spec that was missing got added — nudge a reload so it
            -- actually appears in the CDV picker.
            StaticPopup_Show("REALUI_AURAS_RELOAD")
        end
        return
    end

    -- Install wizard not yet completed — don't interrupt the user
    if not RealUI or not RealUI.db or not RealUI.db.char
       or not RealUI.db.char.init or not RealUI.db.char.init.initialized then return end

    -- A RealUI preset is already present (e.g. applied via wizard)
    if CooldownViewer.IsPresetApplied() then
        self.db.char.cooldownPresetOffered = true
        return
    end

    self:ShowPresetPopup()
end

---------------------------------------------------------------------------
-- NOTE: PLAYER_SPECIALIZATION_CHANGED is intentionally NOT registered.
-- All cooldown layout presets are merged up-front on PLAYER_LOGIN via
-- MergeAllSpecsForClass. Running MergePreset on spec change was
-- historically unreliable (individual specs could fail to serialize,
-- and SetCVar/SetLayoutData side effects during the spec-switch cascade
-- visibly moved Bartender4 bars around until a reload).
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Reload prompt — shown after a preset is applied so CooldownViewer picks
-- up the new layout data without requiring a manual /reload.
---------------------------------------------------------------------------
StaticPopupDialogs["REALUI_AURAS_RELOAD"] = {
    text = "Cooldown layouts applied. Reload UI now to activate them?",
    button1 = "Reload",
    button2 = "Later",
    OnAccept = function() ReloadUI() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

---------------------------------------------------------------------------
-- 4.2 / 4.3  ShowPresetPopup — StaticPopup for preset application
-- Accept = look up the preset for the current class/spec, merge it, set flag.
-- Cancel = set flag only (suppress future popups).
---------------------------------------------------------------------------
StaticPopupDialogs["REALUI_AURAS_PRESET"] = {
    text = "RealUI has cooldown layout presets for your specialization. Apply them now?",
    button1 = "Apply",
    button2 = "Skip",
    OnAccept = function()
        -- Merge every spec's preset up-front so the CDV picker has all
        -- layouts immediately — spec-change merging has proven unreliable
        -- when the data-store roundtrip corrupts or drops individual specs.
        local added, _, err = RealUI_Auras.CooldownViewer.MergeAllSpecsForClass()
        if err then
            print("[RealUI_Auras] Preset apply failed:", err)
        elseif added and added > 0 then
            StaticPopup_Show("REALUI_AURAS_RELOAD")
        end
        AurasAddon.db.char.cooldownPresetOffered = true
    end,
    OnCancel = function()
        AurasAddon.db.char.cooldownPresetOffered = true
    end,
    timeout = 0,
    whileDead = false,
    hideOnEscape = true,
}

function AurasAddon:ShowPresetPopup()
    StaticPopup_Show("REALUI_AURAS_PRESET")
end
