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

    local current = CooldownViewer.Decode(currentStr)
    local preset  = CooldownViewer.Decode(presetStr)

    -- data[1]=version, data[2]=activeLayouts, data[3]=specLayouts, data[4]=layoutNames
    local activeLayouts = current[2] or {}
    local specLayouts = current[3] or {}
    local layoutNames = current[4] or {}
    local presetSpecs = preset[3]  or {}
    local presetNames = preset[4]  or {}

    -- Find highest layoutID in use
    local maxID = 0
    for _, layouts in next, specLayouts do
        for id in next, layouts do
            if type(id) == "number" and id > maxID then maxID = id end
        end
    end
    for id in next, layoutNames do
        if type(id) == "number" and id > maxID then maxID = id end
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

---------------------------------------------------------------------------
-- Query
---------------------------------------------------------------------------

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
