local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Export header contains required metadata
-- Feature: 2026-03-22-realui-profiles-2, Property 22: Export header contains required metadata
-- **Validates: Requirements 11.8**
--
-- For any export string produced by ExportScope or ExportAllLinked,
-- parsing the header shall yield:
-- 1. The prefix "REALUI_EXPORT"
-- 2. A valid version string (non-empty)
-- 3. A valid numeric timestamp
-- 4. At least one scope name

local NUM_ITERATIONS = 100

------------------------------------------------------------
-- Simple RNG (xorshift32)
------------------------------------------------------------
local rngState = 556677
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function randomBool()
    return nextRandom(2) == 1
end

local function randomString(minLen, maxLen)
    local len = nextRandom(maxLen - minLen + 1) + minLen - 1
    local chars = {}
    for i = 1, len do
        -- printable ASCII 32-126
        chars[i] = _G.string.char(nextRandom(95) + 31)
    end
    return _G.table.concat(chars)
end

------------------------------------------------------------
-- Base64 Encode (replicated from ProfileExporter)
------------------------------------------------------------
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function Base64Encode(data)
    local out = {}
    local len = #data
    for i = 1, len, 3 do
        local a = _G.string.byte(data, i)
        local b = i + 1 <= len and _G.string.byte(data, i + 1) or 0
        local c = i + 2 <= len and _G.string.byte(data, i + 2) or 0

        local n = a * 65536 + b * 256 + c

        local c1 = _G.math.floor(n / 262144) % 64
        local c2 = _G.math.floor(n / 4096) % 64
        local c3 = _G.math.floor(n / 64) % 64
        local c4 = n % 64

        out[#out + 1] = _G.string.sub(b64chars, c1 + 1, c1 + 1)
        out[#out + 1] = _G.string.sub(b64chars, c2 + 1, c2 + 1)

        if i + 1 <= len then
            out[#out + 1] = _G.string.sub(b64chars, c3 + 1, c3 + 1)
        else
            out[#out + 1] = "="
        end

        if i + 2 <= len then
            out[#out + 1] = _G.string.sub(b64chars, c4 + 1, c4 + 1)
        else
            out[#out + 1] = "="
        end
    end
    return _G.table.concat(out)
end

------------------------------------------------------------
-- Minimal AceSerializer replica
------------------------------------------------------------
local AceSerializerReplica = {}

local function serializeValue(val, parts)
    local t = type(val)
    if t == "string" then
        parts[#parts + 1] = "s"
        parts[#parts + 1] = _G.tostring(#val)
        parts[#parts + 1] = ":"
        parts[#parts + 1] = val
    elseif t == "number" then
        parts[#parts + 1] = "n"
        parts[#parts + 1] = _G.tostring(val)
        parts[#parts + 1] = ";"
    elseif t == "boolean" then
        parts[#parts + 1] = val and "T" or "F"
    elseif t == "nil" then
        parts[#parts + 1] = "N"
    elseif t == "table" then
        parts[#parts + 1] = "{"
        for k, v in _G.pairs(val) do
            serializeValue(k, parts)
            serializeValue(v, parts)
        end
        parts[#parts + 1] = "}"
    end
end

function AceSerializerReplica:Serialize(data)
    local parts = {}
    serializeValue(data, parts)
    return true, _G.table.concat(parts)
end

------------------------------------------------------------
-- Header constants
------------------------------------------------------------
local HEADER_PREFIX = "REALUI_EXPORT"
local HEADER_SEPARATOR = ":"
local HEADER_SCOPE_SEPARATOR = ","

------------------------------------------------------------
-- Scope constants
------------------------------------------------------------
local SCOPE_CORE = "core"
local SCOPE_SKINS = "skins"
local SCOPE_BT4 = "bt4"
local ALL_SCOPES = { SCOPE_CORE, SCOPE_SKINS, SCOPE_BT4 }

------------------------------------------------------------
-- Deep copy utility
------------------------------------------------------------
local function DeepCopy(original)
    if type(original) ~= "table" then return original end
    local copy = {}
    for k, v in _G.pairs(original) do
        copy[DeepCopy(k)] = DeepCopy(v)
    end
    return copy
end

------------------------------------------------------------
-- Random profile data generator
------------------------------------------------------------
local function generateRandomValue(depth)
    depth = depth or 0
    local kind = nextRandom(5)
    if kind == 1 then
        return randomString(1, 20)
    elseif kind == 2 then
        return nextRandom(10000) - 5000
    elseif kind == 3 then
        return randomBool()
    elseif kind == 4 and depth < 3 then
        local tbl = {}
        local numKeys = nextRandom(4)
        for _ = 1, numKeys do
            local key
            if randomBool() then
                key = randomString(1, 10)
            else
                key = nextRandom(20)
            end
            tbl[key] = generateRandomValue(depth + 1)
        end
        return tbl
    else
        return nextRandom(10000) - 5000
    end
end

local function generateRandomProfileData()
    local data = {}
    local numKeys = nextRandom(6) + 2 -- 3-8 keys
    for _ = 1, numKeys do
        local key = randomString(2, 12)
        data[key] = generateRandomValue(0)
    end
    data.scopeLinks = { skins = randomBool(), bt4 = randomBool() }
    return data
end

------------------------------------------------------------
-- BuildHeader (replicated from ProfileExporter)
------------------------------------------------------------
local function BuildHeader(version, timestamp, scopeNames)
    local scopes = _G.table.concat(scopeNames, HEADER_SCOPE_SEPARATOR)
    return HEADER_PREFIX .. HEADER_SEPARATOR
        .. version .. HEADER_SEPARATOR
        .. _G.tostring(timestamp) .. HEADER_SEPARATOR
        .. scopes
end

------------------------------------------------------------
-- Export pipeline replicas
------------------------------------------------------------

--- Simulate ExportScope
local function ExportScope(scope, profileData, version)
    version = version or "3.0.0"
    local timestamp = 1700000000 + nextRandom(1000000)

    local payload = { [scope] = DeepCopy(profileData) }
    local header = BuildHeader(version, timestamp, { scope })

    local ok, serialized = AceSerializerReplica:Serialize(payload)
    if not ok then
        return nil, "Serialization failed"
    end

    local encoded = Base64Encode(serialized)
    return header .. "\n" .. encoded
end

--- Simulate ExportAllLinked
local function ExportAllLinked(scopeDataMap, linkedScopes, version)
    version = version or "3.0.0"
    local timestamp = 1700000000 + nextRandom(1000000)

    local payload = {}
    local scopeNames = {}

    for _, scope in _G.ipairs(linkedScopes) do
        if scopeDataMap[scope] then
            payload[scope] = DeepCopy(scopeDataMap[scope])
            scopeNames[#scopeNames + 1] = scope
        end
    end

    if #scopeNames == 0 then
        return nil, "No scope data"
    end

    local header = BuildHeader(version, timestamp, scopeNames)

    local ok, serialized = AceSerializerReplica:Serialize(payload)
    if not ok then
        return nil, "Serialization failed"
    end

    local encoded = Base64Encode(serialized)
    return header .. "\n" .. encoded
end

------------------------------------------------------------
-- Header parser (for validation)
------------------------------------------------------------
local function ParseHeader(header)
    if type(header) ~= "string" then return nil, "Not a string" end
    local parts = { _G.strsplit(HEADER_SEPARATOR, header) }
    if #parts < 4 then return nil, "Too few fields" end
    if parts[1] ~= HEADER_PREFIX then return nil, "Bad prefix" end
    local version = parts[2]
    if not version or version == "" then return nil, "Missing version" end
    local timestamp = _G.tonumber(parts[3])
    if not timestamp then return nil, "Bad timestamp" end
    local scopeStr = parts[4]
    if not scopeStr or scopeStr == "" then return nil, "No scopes" end
    local scopes = { _G.strsplit(HEADER_SCOPE_SEPARATOR, scopeStr) }
    return { version = version, timestamp = timestamp, scopes = scopes }
end

------------------------------------------------------------
-- Random version string generator
------------------------------------------------------------
local function generateRandomVersion()
    return _G.tostring(nextRandom(10)) .. "." .. _G.tostring(nextRandom(10)) .. "." .. _G.tostring(nextRandom(10))
end

------------------------------------------------------------
-- Main test
------------------------------------------------------------
local function RunExportHeaderTest()
    _G.print("|cff00ccff[PBT]|r Property 22: Export header contains required metadata")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local version = generateRandomVersion()
        local useAllLinked = randomBool()
        local exportStr, exportErr

        if useAllLinked then
            -- ExportAllLinked: pick 1-3 random linked scopes with data
            local scopeDataMap = {}
            local linkedScopes = {}
            local numLinked = nextRandom(3)
            for j = 1, numLinked do
                local scope = ALL_SCOPES[j]
                scopeDataMap[scope] = generateRandomProfileData()
                linkedScopes[#linkedScopes + 1] = scope
            end

            exportStr, exportErr = ExportAllLinked(scopeDataMap, linkedScopes, version)
        else
            -- ExportScope: single scope
            local scope = ALL_SCOPES[nextRandom(#ALL_SCOPES)]
            local profileData = generateRandomProfileData()
            exportStr, exportErr = ExportScope(scope, profileData, version)
        end

        if not exportStr then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: export failed: %s"):format(i, _G.tostring(exportErr)))
            break
        end

        -- Extract header line (everything before first newline)
        local newlinePos = exportStr:find("\n")
        if not newlinePos then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: export string has no newline separator"):format(i))
            break
        end

        local headerStr = exportStr:sub(1, newlinePos - 1)

        -- Parse header
        local headerInfo, headerErr = ParseHeader(headerStr)
        if not headerInfo then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: header parse failed: %s"):format(i, _G.tostring(headerErr)))
            break
        end

        -- Check 1: prefix is REALUI_EXPORT (verified by ParseHeader, but double-check)
        local rawParts = { _G.strsplit(HEADER_SEPARATOR, headerStr) }
        if rawParts[1] ~= HEADER_PREFIX then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: header prefix is '%s', expected '%s'"):format(
                i, _G.tostring(rawParts[1]), HEADER_PREFIX))
            break
        end

        -- Check 2: version is non-empty
        if not headerInfo.version or headerInfo.version == "" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: header version is empty"):format(i))
            break
        end

        -- Check 3: timestamp is a valid number
        if type(headerInfo.timestamp) ~= "number" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: header timestamp is not a number: %s"):format(
                i, _G.tostring(headerInfo.timestamp)))
            break
        end

        -- Check 4: at least one scope name
        if not headerInfo.scopes or #headerInfo.scopes == 0 then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: header has no scope names"):format(i))
            break
        end

        -- Check 4b: all scope names are non-empty strings
        local scopesFailed = false
        for _, scopeName in _G.ipairs(headerInfo.scopes) do
            if type(scopeName) ~= "string" or scopeName == "" then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: header contains empty scope name"):format(i))
                scopesFailed = true
                break
            end
        end
        if scopesFailed then break end

        -- Check 5: version matches what we passed in
        if headerInfo.version ~= version then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: header version '%s' does not match input '%s'"):format(
                i, headerInfo.version, version))
            break
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 22: Export header contains required metadata — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 22: Export header contains required metadata — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:exportheader()
    return RunExportHeaderTest()
end
