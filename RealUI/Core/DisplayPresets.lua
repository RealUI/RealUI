local _, private = ...

-- Lua Globals --
-- luacheck: globals next ipairs

-- RealUI --
local RealUI = private.RealUI

-- DisplayPresets module
-- Single source of truth for all display preset data.
-- The UI, auto-suggest logic, and apply logic all read from this table.

local DisplayPresets = {}
RealUI.DisplayPresets = DisplayPresets

---------------------------------------------------------------------------
-- Preset Data Table (ordered — display order matches table order)
---------------------------------------------------------------------------
local DISPLAY_PRESETS = {
    {
        id              = "laptop",
        name            = "Laptop / Compact",
        description     = "Small screen or high-DPI 1080p. Tight layout, pixel-perfect scale.",
        customScale     = 1,        -- pixel-perfect (recalculated by isPixelScale)
        isHighRes       = false,
        isPixelScale    = true,
        gameCursorScale = 1.0,
        fontScale       = 1.0,
        chatFontSize    = 12,
        uiModScale      = 1,
    },
    {
        id              = "standard",
        name            = "Desktop Standard",
        description     = "24\" monitor, 1080p-1440p. Balanced defaults.",
        customScale     = 1,        -- pixel-perfect (recalculated by isPixelScale)
        isHighRes       = false,
        isPixelScale    = true,
        gameCursorScale = 1.0,
        fontScale       = 1.0,
        chatFontSize    = 14,
        uiModScale      = 1,
    },
    {
        id              = "highres",
        name            = "Desktop High-Res",
        description     = "27\" monitor, 1440p. Slightly larger elements.",
        customScale     = 1,        -- pixel-perfect (recalculated by isPixelScale)
        isHighRes       = true,     -- HiDPI: engineScale = pixelScale * 2
        isPixelScale    = true,
        gameCursorScale = 1.1,
        fontScale       = 1.0,
        chatFontSize    = 14,
        uiModScale      = 1,
    },
    {
        id              = "4k_desk",
        name            = "4K Desk",
        description     = "27-32\" monitor, 2160p. Larger UI scale.",
        customScale     = 1,        -- pixel-perfect (recalculated by isPixelScale)
        isHighRes       = true,     -- HiDPI: engineScale = pixelScale * 2
        isPixelScale    = true,
        gameCursorScale = 1.2,
        fontScale       = 1.0,
        chatFontSize    = 14,
        uiModScale      = 1,
    },
    {
        id              = "4k_theater",
        name            = "4K Theater",
        description     = "38\"+ screen at desk or couch. Compact scale for large displays.",
        customScale     = 0.30,     -- engine = 0.30 * 2 = 0.60 with HiDPI
        isHighRes       = true,     -- HiDPI: crisp 2x rendering
        isPixelScale    = false,    -- manual scale — smaller than pixel-perfect HiDPI
        gameCursorScale = 1.3,
        fontScale       = 1.0,
        chatFontSize    = 15,
        uiModScale      = 1.25,    -- boost infobar/HuD elements via Scale.Value()
    },
    {
        id              = "ultrawide",
        name            = "Ultrawide",
        description     = "21:9 or 32:9 aspect ratio. Aspect-aware layout.",
        customScale     = 1,        -- pixel-perfect (recalculated by isPixelScale)
        isHighRes       = false,
        isPixelScale    = true,
        gameCursorScale = 1.0,
        fontScale       = 1.0,
        chatFontSize    = 14,
        uiModScale      = 1,
        chatAnchor      = "left",
    },
}

---------------------------------------------------------------------------
-- Lookup table (built once from DISPLAY_PRESETS)
---------------------------------------------------------------------------
local presetById = {}
for _, preset in ipairs(DISPLAY_PRESETS) do
    presetById[preset.id] = preset
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

--- Return the preset table for a given id, or nil if not found.
-- @param id string  Preset identifier (e.g. "laptop", "4k_desk")
-- @return table|nil
function DisplayPresets.GetById(id)
    return presetById[id]
end

--- Return the ordered list of all presets.
-- @return table  The DISPLAY_PRESETS array (do not modify)
function DisplayPresets.GetAll()
    return DISPLAY_PRESETS
end

--- Auto-suggest the best resolution preset for the current display.
-- Uses GetPhysicalScreenSize() for pixel dimensions and derives effective
-- scale as screenH / 768 (GetScreenDPIScale() is not a reliable WoW API).
-- Rules are evaluated in order — first match wins:
--   1. Width/height ratio > 2.1 → "ultrawide"
--   2. Height ≥ 2160           → "4k_desk"
--   3. Height ≥ 1440           → "highres"
--   4. Height ≥ 1080 and effectiveScale > 1.5 → "laptop"
--   5. Default                 → "standard"
-- "4k_theater" is never auto-suggested (Req 3.3).
-- @return string  Preset id
function DisplayPresets.Suggest()
    local screenW, screenH = GetPhysicalScreenSize()
    local ratio = screenW / screenH
    local effectiveScale = screenH / 768

    if ratio > 2.1 then
        return "ultrawide"
    elseif screenH >= 2160 then
        return "4k_desk"
    elseif screenH >= 1440 then
        return "highres"
    elseif screenH >= 1080 and effectiveScale > 1.5 then
        return "laptop"
    else
        return "standard"
    end
end

---------------------------------------------------------------------------
-- Migration Seed (Task 4.2)
-- On first run (presetId == false), copy the current character's
-- SkinsDB.profile scale values into RealUI.db.global.display as a
-- starting point, then set presetId = nil (configured, no named preset).
---------------------------------------------------------------------------
function DisplayPresets.MigrateSeed()
    local display = RealUI.db and RealUI.db.global and RealUI.db.global.display
    if not display then return end

    -- One-time fix: detect and repair SkinsDB scale values that were
    -- corrupted by an earlier version of DisplayPresets.Apply() which
    -- incorrectly wrote abstract preset values (e.g. customScale = 1.25,
    -- isHighRes = true) into SkinsDB.profile. The Skins module interprets
    -- those differently, causing extreme UI scale on reload.
    local Skins = RealUI:GetModule("Skins", true)
    if Skins and Skins.db then
        local skinsProfile = Skins.db.profile
        local dbg = RealUI.db and RealUI.db.global
        local repaired = dbg and dbg.tags and dbg.tags.skinsScaleRepaired

        if skinsProfile and not repaired then
            -- Detect corruption: customScale should be near pixel-perfect
            -- (768/screenH) when isPixelScale is true, or a small value
            -- when isPixelScale is false. Preset values like 1.25 or 1.5
            -- with isHighRes = true are the telltale sign.
            local _, screenH = _G.GetPhysicalScreenSize()
            local pixelScale = 768 / screenH
            local cs = skinsProfile.customScale or 1

            -- If customScale is far above pixel-perfect AND isHighRes is
            -- true on a display that doesn't need it, reset to defaults.
            -- On a 4K display (pixelScale ~0.36), a customScale of 1.0+
            -- with isHighRes = true is clearly wrong.
            local isSuspicious = (cs > pixelScale * 2) and skinsProfile.isHighRes == true

            if isSuspicious then
                skinsProfile.customScale = 1
                skinsProfile.isHighRes   = false
                skinsProfile.isPixelScale = true
            end

            -- Mark as repaired so we don't re-check every login
            if dbg.tags then
                dbg.tags.skinsScaleRepaired = true
            end
        end
    end

    -- Only run seed when presetId is exactly false (not yet configured)
    if display.presetId ~= false then return end

    -- Read current character's SkinsDB.profile values
    if Skins and Skins.db then
        local skinsProfile = Skins.db.profile
        if skinsProfile then
            if skinsProfile.customScale then
                display.customScale = skinsProfile.customScale
            end
            if skinsProfile.isHighRes ~= nil then
                display.isHighRes = skinsProfile.isHighRes
            end
            if skinsProfile.isPixelScale ~= nil then
                display.isPixelScale = skinsProfile.isPixelScale
            end
        end
    end

    -- Mark as configured (no named preset yet)
    display.presetId = nil
end

---------------------------------------------------------------------------
-- Font Scale (Task 6.2)
-- Apply fontScale multiplier to chat frames, Objective Tracker, and
-- tooltip body font size.
---------------------------------------------------------------------------

--- Apply font scale multiplier to chat frames, Objective Tracker, and tooltips.
-- @param scale number  The font scale multiplier (e.g. 1.0, 1.1, 1.3)
function DisplayPresets.RefreshFontScale(scale)
    if not scale then return end

    -- Chat frames: adjust font size for all chat windows
    for i = 1, _G.NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            local _, size = chatFrame:GetFont()
            if size then
                -- Undo previous fontScale before applying new one
                local prevScale = chatFrame._realuiFontScale or 1
                local baseSize = size / prevScale
                _G.FCF_SetChatWindowFontSize(nil, chatFrame, baseSize * scale)
                chatFrame._realuiFontScale = scale
            end
        end
    end

    -- Objective Tracker: scale the whole frame
    if _G.ObjectiveTrackerFrame then
        _G.ObjectiveTrackerFrame:SetScale(scale)
    end

    -- Tooltip body font size: adjust GameTooltip font objects
    for i = 1, 30 do
        local fontString = _G["GameTooltipTextLeft" .. i]
        if fontString then
            local fontFile, fontSize, fontFlags = fontString:GetFont()
            if fontFile and fontSize then
                local prevScale = fontString._realuiFontScale or 1
                local baseSize = fontSize / prevScale
                fontString:SetFont(fontFile, baseSize * scale, fontFlags)
                fontString._realuiFontScale = scale
            end
        end
        local fontStringRight = _G["GameTooltipTextRight" .. i]
        if fontStringRight then
            local fontFile, fontSize, fontFlags = fontStringRight:GetFont()
            if fontFile and fontSize then
                local prevScale = fontStringRight._realuiFontScale or 1
                local baseSize = fontSize / prevScale
                fontStringRight:SetFont(fontFile, baseSize * scale, fontFlags)
                fontStringRight._realuiFontScale = scale
            end
        end
    end
end

---------------------------------------------------------------------------
-- Apply (Task 4.3)
-- Reset Skins scale settings to optimized defaults for the selected
-- display preset, apply cursor scale, chat font size, font scale, and
-- color mode. Prompts reload since engine scale can only change at login.
---------------------------------------------------------------------------

--- Apply a display preset by id with an independent HDR toggle.
-- Resets Skins scale settings to the preset's optimized defaults, writes
-- to global storage, applies cursor/font/color settings, and prompts
-- reload for the engine scale change to take effect.
-- @param id string  Preset identifier (e.g. "laptop", "4k_desk")
-- @param hdrEnabled boolean  Whether HDR color mode is enabled
function DisplayPresets.Apply(id, hdrEnabled)
    local preset = DisplayPresets.GetById(id)
    if not preset then return end

    -- Derive color mode from the independent HDR toggle
    local colorMode = hdrEnabled and "HDR" or "Normal"

    -- Write to global storage
    local display = RealUI.db.global.display
    display.presetId     = id
    display.customScale  = preset.customScale
    -- Compute the actual customScale to write. When isPixelScale is true,
    -- UpdateUIScale will recalculate it as 768/screenH, but we need to
    -- store that value now so ResetScale doesn't use a stale value (like 1)
    -- before UpdateUIScale runs on reload.
    local actualCustomScale = preset.customScale
    if preset.isPixelScale then
        local _, screenH = _G.GetPhysicalScreenSize()
        actualCustomScale = RealUI.Scale and RealUI.Scale.Round(768 / screenH, 2) or (768 / screenH)
    end

    display.customScale  = actualCustomScale
    display.isHighRes    = preset.isHighRes
    display.isPixelScale = preset.isPixelScale
    display.fontScale    = preset.fontScale
    display.hdrEnabled   = hdrEnabled

    -- Write scale settings to SkinsDB.profile — this is the "reset to
    -- optimized defaults" action. The Skins module reads these on reload.
    local Skins = RealUI:GetModule("Skins", true)
    if Skins and Skins.db then
        local skinsProfile = Skins.db.profile
        if skinsProfile then
            skinsProfile.customScale  = actualCustomScale
            skinsProfile.isHighRes    = preset.isHighRes
            skinsProfile.isPixelScale = preset.isPixelScale
            skinsProfile.uiModScale   = preset.uiModScale or 1
        end
    end

    -- Fallback: also write directly to the saved variable in case the
    -- Skins module hasn't created its AceDB yet (e.g. during wizard)
    if _G.RealUI_SkinsDB and _G.RealUI_SkinsDB.profiles then
        local currentProfile = Skins and Skins.db and Skins.db:GetCurrentProfile() or "RealUI"
        local svProfile = _G.RealUI_SkinsDB.profiles[currentProfile]
        if svProfile then
            svProfile.customScale  = actualCustomScale
            svProfile.isHighRes    = preset.isHighRes
            svProfile.isPixelScale = preset.isPixelScale
            svProfile.uiModScale   = preset.uiModScale or 1
        end
    end

    -- Apply cursor scale CVar
    _G.SetCVar("gameCursorScale", preset.gameCursorScale)

    -- Apply chat font size
    if preset.chatFontSize then
        for i = 1, _G.NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame then
                _G.FCF_SetChatWindowFontSize(nil, chatFrame, preset.chatFontSize)
            end
        end
    end

    -- Apply font scale from preset (user can override later via config panel)
    if DisplayPresets.RefreshFontScale then
        DisplayPresets.RefreshFontScale(preset.fontScale)
    end

    -- Apply color mode via Aurora
    local Aurora = _G.Aurora
    if Aurora and Aurora.Color and Aurora.Color.SetMode then
        Aurora.Color.SetMode(colorMode)
    end

    -- Engine scale changes require a reload to take effect.
    -- Suppress during the install wizard — the wizard will handle reload
    -- at the end of the full setup flow.
    local IW = RealUI.InstallWizard
    local wizardActive = IW and IW:GetCurrentStage() and IW:GetCurrentStage() >= 0
    if not wizardActive and RealUI.ReloadUIDialog then
        RealUI:ReloadUIDialog()
    end
end

---------------------------------------------------------------------------
-- ApplyStored (Task 4.4)
-- On PLAYER_ENTERING_WORLD, read RealUI.db.global.display and re-apply
-- stored settings if presetId is not false.
---------------------------------------------------------------------------

--- Re-apply stored display settings from global storage.
-- Called on PLAYER_ENTERING_WORLD so that alts benefit from the same
-- display configuration without running the wizard again.
-- Applies cursor scale, chat font size, font scale, and HDR/color mode.
-- Does NOT write to SkinsDB — Apply() already saved those values and
-- they persist across sessions. Writing here would trigger a spurious
-- reload dialog from UpdateUIScale.
function DisplayPresets.ApplyStored()
    local display = RealUI.db and RealUI.db.global and RealUI.db.global.display
    if not display then return end

    -- Only re-apply if a preset has been configured (presetId is not false)
    if display.presetId == false then return end

    -- Ensure modded frames use the correct scale immediately.
    -- UpdateUIScale recalculates customScale for pixel-perfect mode and
    -- calls UpdateModScale which fixes infobar/modded frame sizes.
    -- Called without fromConfig so it does NOT trigger a reload dialog.
    if RealUI.UpdateUIScale then
        RealUI.UpdateUIScale()
    end

    -- Apply cursor scale CVar
    if display.presetId then
        local preset = DisplayPresets.GetById(display.presetId)
        if preset then
            if preset.gameCursorScale then
                _G.SetCVar("gameCursorScale", preset.gameCursorScale)
            end
            -- Apply chat font size
            if preset.chatFontSize then
                _G.C_Timer.After(1, function()
                    for i = 1, _G.NUM_CHAT_WINDOWS do
                        local chatFrame = _G["ChatFrame" .. i]
                        if chatFrame then
                            _G.FCF_SetChatWindowFontSize(nil, chatFrame, preset.chatFontSize)
                        end
                    end
                end)
            end
        end
    end

    -- Apply stored font scale
    if DisplayPresets.RefreshFontScale and display.fontScale and display.fontScale ~= 1.0 then
        DisplayPresets.RefreshFontScale(display.fontScale)
    end

    -- Apply HDR / color mode via Aurora (guarded — Integration may not be ready)
    local colorMode = display.hdrEnabled and "HDR" or "Normal"
    local Aurora = _G.Aurora
    if Aurora and Aurora.Color and Aurora.Color.SetMode then
        Aurora.Color.SetMode(colorMode)
    end
end

---------------------------------------------------------------------------
-- Event Registration
-- Register PLAYER_ENTERING_WORLD to run migration seed and ApplyStored.
---------------------------------------------------------------------------
local eventFrame = _G.CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Run one-time migration seed first
        DisplayPresets.MigrateSeed()
        -- Then re-apply stored settings
        DisplayPresets.ApplyStored()
        -- Unregister after first run — settings are applied once at login
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
