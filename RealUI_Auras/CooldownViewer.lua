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
-- Blizzard intentionally omits cooldownFont from CooldownViewerBuffIconItemTemplate,
-- so no countdown text appears on buff tracker icons. We implement a custom
-- FontString overlay because SetUseAuraDisplayTime(true) — permanently set in
-- BuffIcon OnLoad — suppresses the built-in countdown text.
--
-- Timing strategy:
--   expirationTime returned by C_UnitAuras is a "secret" number in tainted
--   addon code while the player is in combat with an enemy target. Polling it
--   from OnUpdate therefore fails in combat.
--
--   Instead, we hook the global CooldownFrame_Set Lua function. Blizzard's own
--   non-tainted code computes start = expirationTime - duration and passes that
--   plain (non-secret) result to CooldownFrame_Set. Our hook stores
--   endTime = start + duration in a table we own. OnUpdate reads only from that
--   table — plain numbers, no restrictions.
--
--   C_UnitAuras is used as a one-shot fallback to prime endTime on items that
--   already existed before the CooldownFrame_Set hook fired (e.g. on login when
--   the aura was applied before our hook was installed). It works then because
--   the player is not yet in combat.
--
-- Taint safety: overlay references and timing data live in module-level tables —
-- nothing is written onto Blizzard CDM item frames.
---------------------------------------------------------------------------
local buffIconHookInstalled = false
local buffIconOverlays = setmetatable({}, {__mode = "k"})  -- item  → overlay
local cdToTiming       = setmetatable({}, {__mode = "k"})  -- item.Cooldown → timing table

local cooldownFrameSetHooked = false

local function EnsureCooldownFrameSetHooked()
    if cooldownFrameSetHooked then return end
    cooldownFrameSetHooked = true

    -- CooldownFrame_Set is called by Blizzard's non-tainted RefreshCooldownInfo.
    -- The start/duration args are the result of (expirationTime - duration) computed
    -- in non-tainted code, so they arrive here as plain numbers even in combat.
    _G.hooksecurefunc("CooldownFrame_Set", function(cooldown, start, duration)
        local timing = cdToTiming[cooldown]
        if not timing then return end
        -- pcall guards the addition in case start/duration are ever secret;
        -- on failure endTime stays unchanged so the last good value drives display
        _G.pcall(function() timing.endTime = start + duration end)
    end)

    _G.hooksecurefunc("CooldownFrame_Clear", function(cooldown)
        local timing = cdToTiming[cooldown]
        if timing then timing.endTime = nil end
    end)
end

-- Formats remaining seconds into a display string.
local function FormatRemain(s)
    if s < 60   then return ("%d"):format(_G.math.ceil(s)) end
    if s < 3600 then return ("%dm"):format(_G.math.floor(s / 60)) end
    return ("%dh"):format(_G.math.floor(s / 3600))
end

local function CreateBuffIconOverlay(item)
    local overlay = _G.CreateFrame("Frame", nil, item.Cooldown)
    overlay:SetAllPoints()

    local timing = {}           -- {endTime=number} owned by us, not the Blizzard frame
    overlay._timing  = timing
    overlay._item    = item     -- overlay is our frame; writing onto it is fine
    cdToTiming[item.Cooldown] = timing

    EnsureCooldownFrameSetHooked()

    local text = overlay:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    text:SetPoint("BOTTOMRIGHT", -2, 2)
    overlay.text = text

    overlay:SetScript("OnUpdate", function(self, elapsed)
        self._t = (self._t or 0) + elapsed
        if self._t < 0.1 then return end
        self._t = 0

        local t = self._timing

        -- Prime endTime via C_UnitAuras when the hook hasn't fired yet.
        -- This works at login / out-of-combat; in combat the hook is the source.
        if not t.endTime then
            local it = self._item
            local aura = _G.C_UnitAuras.GetAuraDataByAuraInstanceID(
                it.auraDataUnit, it.auraInstanceID)
            if aura then
                _G.pcall(function() t.endTime = aura.expirationTime end)
            end
        end

        if not t.endTime then self.text:SetText(""); return end

        local ok, txt = _G.pcall(function()
            local s = t.endTime - _G.GetTime()
            return s > 0 and FormatRemain(s) or ""
        end)
        self.text:SetText((ok and txt) or "")
    end)

    buffIconOverlays[item] = overlay  -- keyed on item, NOT stored on item
    return overlay
end

local function ApplyToBuffIconItem(item, enabled)
    if not item.Cooldown then return end
    if enabled then
        local overlay = buffIconOverlays[item] or CreateBuffIconOverlay(item)
        overlay:Show()
    elseif buffIconOverlays[item] then
        buffIconOverlays[item]:Hide()
    end
end

--- Apply countdown visibility to all currently active BuffIcon items.
--- Call this when the setting changes at runtime.
function CooldownViewer.ApplyBuffIconCountdown(enabled)
    local viewer = _G.BuffIconCooldownViewer
    if not viewer then return end
    -- GetItemFrames() uses GetLayoutChildren() — returns only active (layout-participating)
    -- item frames, matching what Blizzard itself uses to iterate items.
    for _, item in next, {viewer:GetItemFrames()} do
        ApplyToBuffIconItem(item, enabled)
    end
end

--- Install the OnAcquireItemFrame hook so every item frame gets an overlay before
--- RefreshCooldownInfo fires its CooldownFrame_Set call.
--- OnAcquireItemFrame is already Mixin-copied onto BuffIconCooldownViewer at
--- addon-load time, so we hook directly on that frame (not on the mixin table)
--- to guarantee the hook fires regardless of load order.
--- Safe to call multiple times — installs the hook only once.
function CooldownViewer.InitBuffIconCountdown()
    if buffIconHookInstalled then return end
    local viewer = _G.BuffIconCooldownViewer
    if not viewer then return end
    buffIconHookInstalled = true

    -- Fires for every pool acquisition — both new frames and reused ones.
    -- Runs before RefreshCooldownInfo, so cdToTiming is registered before
    -- the first CooldownFrame_Set call for this item.
    _G.hooksecurefunc(viewer, "OnAcquireItemFrame", function(_, itemFrame)
        local db = RealUI_Auras.db
        local enabled = db and db.profile and db.profile.cooldownViewer
                        and db.profile.cooldownViewer.buffIconCountdown
        ApplyToBuffIconItem(itemFrame, enabled)
    end)
end
