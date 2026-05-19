-- CooldownViewer.lua
-- Preset codec and merge logic for the native CooldownViewer system.
-- Graduated from RealUI_Dev/tests/CooldownViewer_MergeTest.lua.
-- Exports: Decode, Encode, MergePreset, IsPresetApplied

local CooldownViewer = {}
RealUI_Auras.CooldownViewer = CooldownViewer

-- Factory-default sentinel: CBOR-encoded empty layout [4, []]
local EMPTY_PAYLOAD = "a2JpAAA="

---------------------------------------------------------------------------
-- Codec
---------------------------------------------------------------------------

--- Decode a CooldownViewer import string into a Lua table.
--- @param importStr string  "1|<base64>"
--- @return table  {[1]=version, [2]=activeLayouts, [3]=specLayouts, [4]=layoutNames}
function CooldownViewer.Decode(importStr)
    local payload = importStr:match("^%d+|(.+)$")
    if not payload then error("bad import string format") end
    local compressed = C_EncodingUtil.DecodeBase64(payload)
    if not compressed then error("DecodeBase64 failed") end
    local raw = C_EncodingUtil.DecompressString(compressed, Enum.CompressionMethod.Deflate)
    if not raw then error("DecompressString failed") end
    local data = C_EncodingUtil.DeserializeCBOR(raw)
    if not data then error("DeserializeCBOR failed") end
    return data
end

--- Encode a layout table back into a CooldownViewer import string.
--- @param data table  {[1]=version, [2]=activeLayouts, [3]=specLayouts, [4]=layoutNames}
--- @return string  "1|<base64>"
function CooldownViewer.Encode(data)
    local raw = C_EncodingUtil.SerializeCBOR(data)
    if not raw then error("SerializeCBOR failed") end
    local compressed = C_EncodingUtil.CompressString(raw, Enum.CompressionMethod.Deflate)
    if not compressed then error("CompressString failed") end
    local encoded = C_EncodingUtil.EncodeBase64(compressed)
    if not encoded then error("EncodeBase64 failed") end
    return "1|" .. encoded
end

---------------------------------------------------------------------------
-- Merge
---------------------------------------------------------------------------

--- Merge a preset import string into the current live layout.
--- Existing layouts named "RealUI - <x>" are skipped (idempotent).
--- New layout IDs are assigned as max(existing IDs) + 1 (collision-safe).
--- @param presetStr string  The preset import string to merge
--- @return number added   Number of layouts added
--- @return number skipped Number of layouts skipped (already present)
--- @return string|nil err  Error message, or nil on success
function CooldownViewer.MergePreset(presetStr)
    if not C_CooldownViewer.IsCooldownViewerAvailable() then
        return 0, 0, "CooldownViewer unavailable"
    end

    local currentStr = C_CooldownViewer.GetLayoutData()
    local currentPayload = currentStr and currentStr:match("^%d+|(.+)$") or ""

    -- Fast path: factory default sentinel or empty — nothing to merge into, just apply preset
    if currentPayload == EMPTY_PAYLOAD or currentStr == "" or currentStr == nil then
        local ok, err = pcall(C_CooldownViewer.SetLayoutData, presetStr)
        if not ok then return 0, 0, err end
        SetCVar("cooldownViewerEnabled", 1)
        return 1, 0
    end

    local decOk, current = pcall(CooldownViewer.Decode, currentStr)
    if not decOk then
        return 0, 0, "Decode(current) failed: " .. tostring(current)
    end
    local decOk2, preset = pcall(CooldownViewer.Decode, presetStr)
    if not decOk2 then
        return 0, 0, "Decode(preset) failed: " .. tostring(preset)
    end

    -- data[1]=version, data[2]=activeLayouts, data[3]=specLayouts, data[4]=layoutNames
    local activeLayouts = current[2] or {}
    local specLayouts = current[3] or {}
    local layoutNames = current[4] or {}
    local presetSpecs = preset[3]  or {}
    local presetNames = preset[4]  or {}

    -- Find highest layoutID in use. Walk both specLayouts (values are
    -- maps keyed by layoutID) and layoutNames (also keyed by layoutID).
    -- Blizzard's CBOR roundtrip has in some cases returned stringified
    -- numeric keys, so we coerce via tonumber and fall back safely.
    local function toLayoutID(k)
        if type(k) == "number" then return k end
        if type(k) == "string" then return tonumber(k) end
        return nil
    end

    local maxID = 0
    for _, layouts in next, specLayouts do
        for id in next, layouts do
            local n = toLayoutID(id)
            if n and n > maxID then maxID = n end
        end
    end
    for id in next, layoutNames do
        local n = toLayoutID(id)
        if n and n > maxID then maxID = n end
    end

    local added, skipped = 0, 0

    for specTag, presetLayouts in next, presetSpecs do
        if not specLayouts[specTag] then specLayouts[specTag] = {} end
        for layoutID, layoutData in next, presetLayouts do
            local srcName = presetNames[layoutID]
            local dstName = "RealUI - " .. srcName

            -- Skip if a layout with this name already exists for this spec
            local exists = false
            for existingID in next, specLayouts[specTag] do
                if layoutNames[existingID] == dstName then exists = true; break end
            end

            if exists then
                skipped = skipped + 1
            else
                maxID = maxID + 1
                specLayouts[specTag][maxID] = layoutData
                layoutNames[maxID] = dstName
                -- Set as active layout for this spec
                activeLayouts[specTag] = maxID
                added = added + 1
            end
        end
    end

    current[2] = activeLayouts
    current[3] = specLayouts
    current[4] = layoutNames

    local ok, err = pcall(C_CooldownViewer.SetLayoutData, CooldownViewer.Encode(current))
    if not ok then return 0, 0, err end
    if added > 0 then
        SetCVar("cooldownViewerEnabled", 1)
    end
    return added, skipped
end

--- Diagnostic: dump the current live CooldownViewer layout data
--- to help diagnose merge failures. Prints names, specs, and active layout
--- assignments. Handy when /reloading doesn't bring in an expected layout.
function CooldownViewer.Dump()
    if not C_CooldownViewer or not C_CooldownViewer.IsCooldownViewerAvailable() then
        print("[CDV.Dump] CooldownViewer not available")
        return
    end

    local data = C_CooldownViewer.GetLayoutData()
    if not data or data == "" then
        print("[CDV.Dump] GetLayoutData returned empty")
        return
    end

    local payload = data:match("^%d+|(.+)$") or ""
    if payload == EMPTY_PAYLOAD then
        print("[CDV.Dump] Layout data is factory-default (empty)")
        return
    end

    local ok, decoded = pcall(CooldownViewer.Decode, data)
    if not ok then
        print(("[CDV.Dump] Decode failed: %s"):format(tostring(decoded)))
        return
    end

    local version      = decoded[1]
    local activeByTag  = decoded[2] or {}
    local layoutsByTag = decoded[3] or {}
    local names        = decoded[4] or {}

    print(("[CDV.Dump] version=%s"):format(tostring(version)))

    -- Names
    local nameCount = 0
    for _ in next, names do nameCount = nameCount + 1 end
    print(("[CDV.Dump] layoutNames (%d entries):"):format(nameCount))
    for id, name in next, names do
        print(("  [%s] (%s) = %s"):format(tostring(id), type(id), tostring(name)))
    end

    -- Specs
    local specCount = 0
    for _ in next, layoutsByTag do specCount = specCount + 1 end
    print(("[CDV.Dump] specLayouts (%d spec tags):"):format(specCount))
    for specTag, layouts in next, layoutsByTag do
        local ids = {}
        for id in next, layouts do ids[#ids + 1] = tostring(id) .. "(" .. type(id) .. ")" end
        local active = activeByTag[specTag]
        print(("  specTag %s(%s) active=%s layouts=[%s]"):format(
            tostring(specTag), type(specTag),
            tostring(active),
            table.concat(ids, ",")))
    end
end

-- Register slash command for quick dump
if not _G.SLASH_REALUICDVDUMP1 then
    _G.SLASH_REALUICDVDUMP1 = "/cdvdump"
    _G.SlashCmdList["REALUICDVDUMP"] = CooldownViewer.Dump
end

---------------------------------------------------------------------------
-- MergeAllSpecsForClass — merge presets for every spec of the player's
-- class in one call. Avoids timing/per-spec issues by applying the full
-- set on a single event (PLAYER_LOGIN or STAGE_COOLDOWNS), so every spec
-- has its layout immediately after the next reload and spec swaps do not
-- need to mutate layout data.
--
-- @return number added  total layouts added across all specs
-- @return number skipped number of layouts already present
-- @return string|nil err first error encountered (if any)
---------------------------------------------------------------------------
function CooldownViewer.MergeAllSpecsForClass(classID)
    if not C_CooldownViewer or not C_CooldownViewer.IsCooldownViewerAvailable() then
        return 0, 0, "CooldownViewer unavailable"
    end
    classID = classID or select(3, UnitClass("player"))
    if not classID then
        return 0, 0, "unknown classID"
    end

    local Presets = RealUI_Auras and RealUI_Auras.Presets
    if not Presets then
        return 0, 0, "Presets table missing"
    end

    local totalAdded, totalSkipped = 0, 0
    local firstErr
    -- Specs are 1..4 in practice; iterate a small range to cover all
    for specIndex = 1, 4 do
        local specTag = classID * 10 + specIndex
        local presetStr = Presets[specTag]
        if presetStr then
            local added, skipped, err = CooldownViewer.MergePreset(presetStr)
            if err and not firstErr then
                firstErr = ("specTag %d: %s"):format(specTag, tostring(err))
            end
            totalAdded = totalAdded + (added or 0)
            totalSkipped = totalSkipped + (skipped or 0)
        end
    end
    return totalAdded, totalSkipped, firstErr
end

--- Check whether any RealUI preset is already applied.
--- @return boolean
function CooldownViewer.IsPresetApplied()
    if not C_CooldownViewer.IsCooldownViewerAvailable() then return false end
    local data = C_CooldownViewer.GetLayoutData()
    if not data or data == "" then return false end
    local payload = data:match("^%d+|(.+)$") or ""
    if payload == EMPTY_PAYLOAD then return false end
    local ok, decoded = pcall(CooldownViewer.Decode, data)
    if not ok then return false end
    local layoutNames = decoded[4] or {}
    for _, name in next, layoutNames do
        if type(name) == "string" and name:sub(1, 9) == "RealUI - " then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------------
-- BuffIconCooldownViewer countdown numbers
-- BuffIconCooldownViewer countdown timer
--
-- Blizzard intentionally omits cooldownFont from CooldownViewerBuffIconItemTemplate
-- (compare CooldownViewerEssentialItemTemplate which has cooldownFont=GameFontHighlightHugeOutline).
-- Without a font, the built-in C-side countdown text is invisible even though the
-- CooldownFrame is driven correctly by RefreshCooldownInfo → CooldownFrame_Set.
--
-- Strategy: hook CooldownFrame_Set (global Lua function, fires AFTER CDM's
-- non-tainted RefreshCooldownInfo). Call SetCountdownFont + SetHideCountdownNumbers(false)
-- on the cooldown frame. Blizzard's own C code drives the display from there —
-- no custom timer, no OnUpdate, no C_UnitAuras, no secret-number exposure.
--
-- CDM calls SetTimerShown(false) → SetHideCountdownNumbers(true) in OnAcquireItemFrame,
-- which fires BEFORE CooldownFrame_Set in the RefreshLayout chain. Our hook therefore
-- always wins in the same refresh cycle without hooking OnAcquireItemFrame (which would
-- taint CDM's subsequent RefreshCooldownInfo call).
---------------------------------------------------------------------------
local buffIconCdEnabled     = false
local buffIconCdFont        = "GameFontHighlightHugeOutline"
local cooldownFrameSetHooked = false

local function ApplyToBuffIconCooldown(cooldown, enabled)
    if enabled then
        cooldown:SetCountdownFont(buffIconCdFont)
        cooldown:SetHideCountdownNumbers(false)
    else
        cooldown:SetHideCountdownNumbers(true)
    end
end

local function EnsureCooldownFrameSetHooked()
    if cooldownFrameSetHooked then return end
    cooldownFrameSetHooked = true

    _G.hooksecurefunc("CooldownFrame_Set", function(cooldown)
        if not buffIconCdEnabled then return end
        -- Reading a field from a Blizzard frame is taint-safe (no write).
        local item = cooldown:GetParent()
        if not (item and item.viewerFrame == _G.BuffIconCooldownViewer) then return end
        ApplyToBuffIconCooldown(cooldown, true)
    end)
end

--- Apply or remove countdown font on all currently active BuffIcon items.
--- Call this when the setting changes at runtime, or at login.
function CooldownViewer.ApplyBuffIconCountdown(enabled)
    buffIconCdEnabled = enabled
    local viewer = _G.BuffIconCooldownViewer
    if not viewer then return end
    for _, item in next, {viewer:GetItemFrames()} do
        if item.Cooldown then
            ApplyToBuffIconCooldown(item.Cooldown, enabled)
        end
    end
end

--- Install the global CooldownFrame_Set hook. Safe to call multiple times.
function CooldownViewer.InitBuffIconCountdown()
    EnsureCooldownFrameSetHooked()
end
