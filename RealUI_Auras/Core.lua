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
                local specTag = select(3, UnitClass("player")) * 10 + GetSpecialization()
                local preset = RealUI_Auras.Presets and RealUI_Auras.Presets[specTag]
                if preset then
                    local added = RealUI_Auras.CooldownViewer.MergePreset(preset)
                    if added and added > 0 then
                        StaticPopup_Show("REALUI_AURAS_RELOAD")
                    end
                end
                self.db.char.cooldownPresetOffered = true
            end,
        })
    end
end

function AurasAddon:OnEnable()
    Groups = self.Groups
    Icons = self.Icons

    -- 10.1: Detect Masque and create a skinning group before any icons are created.
    -- Must happen before Groups.InitAll() since that triggers container creation
    -- which may trigger icon creation.
    local MSQ = LibStub and LibStub("Masque", true)
    if MSQ then
        Icons.MasqueGroup = MSQ:Group("RealUI", "Auras")

        -- 10.4: Register Masque reskin callback for skin changes.
        -- Note: SetCallback is deprecated in modern Masque; use RegisterCallback.
        Icons.MasqueGroup:RegisterCallback(function()
            Icons.MasqueGroup:ReSkin()
        end)
    end

    BuffFrame:Hide()
    DebuffFrame:Hide()

    -- 11.1: Permanently re-hide BuffFrame whenever Blizzard code shows it
    -- (e.g. Character panel open/close, combat transitions). HookScript is
    -- permanent and cannot be removed, so guard against double-hooking if
    -- OnEnable is called more than once.
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

    -- 4.1: PLAYER_LOGIN → first-login CooldownViewer preset check
    self:RegisterEvent("PLAYER_LOGIN")

    -- 8.1: PLAYER_SPECIALIZATION_CHANGED → auto-apply preset for new spec
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    Groups.InitAll()
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

    -- Already offered — nothing to do
    if self.db.char.cooldownPresetOffered then return end

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
-- 8.1  PLAYER_SPECIALIZATION_CHANGED — auto-apply preset for new spec
-- When the user switches spec, silently merge the new spec's preset if:
--   • The preset popup has already been offered (user accepted or skipped)
--   • CooldownViewer is available
--   • A preset exists for the new spec
-- MergePreset is idempotent — it skips if "RealUI - <name>" already exists.
---------------------------------------------------------------------------
function AurasAddon:PLAYER_SPECIALIZATION_CHANGED()
    -- Don't auto-apply before the user has been asked via popup or wizard
    if not self.db.char.cooldownPresetOffered then return end

    local CooldownViewer = self.CooldownViewer
    if not C_CooldownViewer.IsCooldownViewerAvailable() then return end

    local classID = select(3, UnitClass("player"))
    local specIndex = GetSpecialization()
    if not specIndex then return end

    local specTag = classID * 10 + specIndex
    local presetStr = RealUI_Auras.Presets and RealUI_Auras.Presets[specTag]
    if not presetStr then return end

    -- MergePreset is idempotent: skips layouts that already exist
    local added = CooldownViewer.MergePreset(presetStr)
    if added and added > 0 then
        StaticPopup_Show("REALUI_AURAS_RELOAD")
    end
end

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
        local classID = select(3, UnitClass("player"))
        local specIndex = GetSpecialization()
        local presetStr = RealUI_Auras.Presets
            and RealUI_Auras.Presets[classID * 10 + specIndex]
        if presetStr then
            local added, _, err = RealUI_Auras.CooldownViewer.MergePreset(presetStr)
            if err then
                print("[RealUI_Auras] Preset apply failed:", err)
            elseif added > 0 then
                StaticPopup_Show("REALUI_AURAS_RELOAD")
            end
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
