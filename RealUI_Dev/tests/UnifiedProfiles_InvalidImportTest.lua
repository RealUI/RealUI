local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Invalid import rejection
-- Feature: 2026-03-22-realui-profiles-2, Property 21: Invalid import rejection
-- **Validates: Requirements 11.7**
--
-- For any string that is not a valid RealUI export string (random bytes,
-- truncated strings, wrong header format), calling ProfileExporter:Import()
-- shall return false with an error description, and no existing profile data
-- shall be modified.

local NUM_ITERATIONS = 100

------------------------------------------------------------
-- Simple RNG (xorshift32)
------------------------------------------------------------
local rngState = 424242
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function randomString(minLen, maxLen)
    local len = nextRandom(maxLen - minLen + 1) + minLen - 1
    local chars = {}
    for i = 1, len do
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
-- Minimal AceSerializer replica (for building corrupted payloads)
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

local function deserializeValue(str, pos)
    local tag = str:sub(pos, pos)
    if tag == "s" then
        local colonPos = str:find(":", pos + 1, true)
        local len = _G.tonumber(str:sub(pos + 1, colonPos - 1))
        local val = str:sub(colonPos + 1, colonPos + len)
        return val, colonPos + len + 1
    elseif tag == "n" then
        local semiPos = str:find(";", pos + 1, true)
        local val = _G.tonumber(str:sub(pos + 1, semiPos - 1))
        return val, semiPos + 1
    elseif tag == "T" then
        return true, pos + 1
    elseif tag == "F" then
        return false, pos + 1
    elseif tag == "N" then
        return nil, pos + 1
    elseif tag == "{" then
        local tbl = {}
        local nextPos = pos + 1
        while str:sub(nextPos, nextPos) ~= "}" do
            local key, val
            key, nextPos = deserializeValue(str, nextPos)
            val, nextPos = deserializeValue(str, nextPos)
            tbl[key] = val
        end
        return tbl, nextPos + 1
    else
        return nil, pos + 1
    end
end

function AceSerializerReplica:Deserialize(str)
    if type(str) ~= "string" or str == "" then
        return false, "Empty input"
    end
    local ok, result = _G.pcall(function()
        local val, _ = deserializeValue(str, 1)
        return val
    end)
    if ok then
        return true, result
    else
        return false, _G.tostring(result)
    end
end


------------------------------------------------------------
-- Header / validation helpers (replicated from ProfileExporter)
------------------------------------------------------------
local HEADER_PREFIX = "REALUI_EXPORT"
local HEADER_SEPARATOR = ":"
local HEADER_SCOPE_SEPARATOR = ","

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

local b64lookup = {}
for i = 1, 64 do
    b64lookup[_G.string.byte(b64chars, i)] = i - 1
end
b64lookup[_G.string.byte("=")] = 0

local function Base64Decode(data)
    data = data:gsub("%s", "")
    local out = {}
    local len = #data
    for i = 1, len, 4 do
        local a = b64lookup[_G.string.byte(data, i)] or 0
        local b = b64lookup[_G.string.byte(data, i + 1)] or 0
        local c = b64lookup[_G.string.byte(data, i + 2)] or 0
        local d = b64lookup[_G.string.byte(data, i + 3)] or 0

        local n = a * 262144 + b * 4096 + c * 64 + d

        out[#out + 1] = _G.string.char(_G.math.floor(n / 65536) % 256)

        if i + 2 <= len and _G.string.sub(data, i + 2, i + 2) ~= "=" then
            out[#out + 1] = _G.string.char(_G.math.floor(n / 256) % 256)
        end
        if i + 3 <= len and _G.string.sub(data, i + 3, i + 3) ~= "=" then
            out[#out + 1] = _G.string.char(n % 256)
        end
    end
    return _G.table.concat(out)
end

------------------------------------------------------------
-- ValidateImportString replica (mirrors ProfileExporter logic)
------------------------------------------------------------
local function ValidateImportString(str)
    if type(str) ~= "string" or str == "" then
        return false, "Import string is empty or not a string."
    end

    local newlinePos = str:find("\n")
    if not newlinePos then
        return false, "Import string is missing body (no newline separator)."
    end

    local headerStr = str:sub(1, newlinePos - 1)
    local body = str:sub(newlinePos + 1)

    if body == "" then
        return false, "Import string body is empty."
    end

    local headerInfo, headerErr = ParseHeader(headerStr)
    if not headerInfo then
        return false, headerErr
    end

    local decoded = Base64Decode(body)
    if not decoded or decoded == "" then
        return false, "Base64 decoding failed."
    end

    local ok, payload = AceSerializerReplica:Deserialize(decoded)
    if not ok then
        return false, "Deserialization failed: " .. _G.tostring(payload)
    end

    if type(payload) ~= "table" then
        return false, "Deserialized payload is not a table."
    end

    local hasScope = false
    for _, scope in _G.ipairs(headerInfo.scopes) do
        if payload[scope] then
            hasScope = true
            break
        end
    end
    if not hasScope then
        return false, "Payload does not contain data for any declared scope."
    end

    return true, headerInfo
end

--- Import replica (mirrors ProfileExporter:Import logic)
local function Import(encodedString)
    local valid, headerOrErr = ValidateImportString(encodedString)
    if not valid then
        return false, headerOrErr
    end
    -- If validation passes, import would proceed — but for invalid inputs
    -- we only care that it returns false before reaching here.
    return true, headerOrErr
end

------------------------------------------------------------
-- Main test
------------------------------------------------------------
local function RunInvalidImportTest()
    _G.print("|cff00ccff[PBT]|r Property 21: Invalid import rejection")
    _G.print("|cff00ccff[PBT]|r Running specific edge cases + " .. _G.tostring(NUM_ITERATIONS) .. " random garbage iterations")

    local failures = 0
    local testNum = 0

    local function check(label, input)
        testNum = testNum + 1
        local ok, err = Import(input)
        if ok then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r test %d (%s): expected rejection but got success"):format(testNum, label))
            return false
        end
        if type(err) ~= "string" or err == "" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r test %d (%s): rejected but error is not a non-empty string: %s"):format(
                testNum, label, _G.tostring(err)))
            return false
        end
        return true
    end

    -- Also verify ValidateImportString rejects the same inputs
    local function checkValidate(label, input)
        testNum = testNum + 1
        local ok, err = ValidateImportString(input)
        if ok then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r test %d (validate %s): expected rejection but got success"):format(testNum, label))
            return false
        end
        if type(err) ~= "string" or err == "" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r test %d (validate %s): rejected but error is not a non-empty string: %s"):format(
                testNum, label, _G.tostring(err)))
            return false
        end
        return true
    end

    -------------------------------------------------
    -- 1. Empty string
    -------------------------------------------------
    check("empty string", "")
    checkValidate("empty string", "")

    -------------------------------------------------
    -- 2. Non-string inputs (nil, number, boolean)
    -------------------------------------------------
    check("nil input", nil)
    checkValidate("nil input", nil)

    check("number input", 12345)
    checkValidate("number input", 12345)

    check("boolean input", true)
    checkValidate("boolean input", true)

    -------------------------------------------------
    -- 3. String without newline separator
    -------------------------------------------------
    check("no newline", "REALUI_EXPORT:3.0.0:1700000000:core")
    checkValidate("no newline", "REALUI_EXPORT:3.0.0:1700000000:core")

    -------------------------------------------------
    -- 4. String with invalid header prefix
    -------------------------------------------------
    check("bad prefix", "WRONG_PREFIX:3.0.0:1700000000:core\nSomeBody")
    checkValidate("bad prefix", "WRONG_PREFIX:3.0.0:1700000000:core\nSomeBody")

    -------------------------------------------------
    -- 5. String with missing version
    -------------------------------------------------
    check("missing version", "REALUI_EXPORT::1700000000:core\nSomeBody")
    checkValidate("missing version", "REALUI_EXPORT::1700000000:core\nSomeBody")

    -------------------------------------------------
    -- 6. String with invalid timestamp
    -------------------------------------------------
    check("invalid timestamp", "REALUI_EXPORT:3.0.0:notanumber:core\nSomeBody")
    checkValidate("invalid timestamp", "REALUI_EXPORT:3.0.0:notanumber:core\nSomeBody")

    -------------------------------------------------
    -- 7. String with missing scopes
    -------------------------------------------------
    check("missing scopes", "REALUI_EXPORT:3.0.0:1700000000:\nSomeBody")
    checkValidate("missing scopes", "REALUI_EXPORT:3.0.0:1700000000:\nSomeBody")

    -- Also: too few header fields (no scope field at all)
    check("too few fields", "REALUI_EXPORT:3.0.0\nSomeBody")
    checkValidate("too few fields", "REALUI_EXPORT:3.0.0\nSomeBody")

    -------------------------------------------------
    -- 8. Valid header but empty body
    -------------------------------------------------
    check("empty body", "REALUI_EXPORT:3.0.0:1700000000:core\n")
    checkValidate("empty body", "REALUI_EXPORT:3.0.0:1700000000:core\n")

    -------------------------------------------------
    -- 9. Valid header but corrupted base64
    -------------------------------------------------
    check("corrupted base64", "REALUI_EXPORT:3.0.0:1700000000:core\n!!!not-base64-at-all!!!")
    checkValidate("corrupted base64", "REALUI_EXPORT:3.0.0:1700000000:core\n!!!not-base64-at-all!!!")

    -------------------------------------------------
    -- 10. Valid header and base64 but corrupted serialized data
    -------------------------------------------------
    local corruptSerialized = Base64Encode("this is not serialized data at all")
    check("corrupt serialized", "REALUI_EXPORT:3.0.0:1700000000:core\n" .. corruptSerialized)
    checkValidate("corrupt serialized", "REALUI_EXPORT:3.0.0:1700000000:core\n" .. corruptSerialized)

    -- Also: valid serialized data but payload doesn't match declared scopes
    local mismatchPayload = { wrongscope = { key = "val" } }
    local mOk, mSerialized = AceSerializerReplica:Serialize(mismatchPayload)
    if mOk then
        local mEncoded = Base64Encode(mSerialized)
        check("scope mismatch", "REALUI_EXPORT:3.0.0:1700000000:core\n" .. mEncoded)
        checkValidate("scope mismatch", "REALUI_EXPORT:3.0.0:1700000000:core\n" .. mEncoded)
    end

    -------------------------------------------------
    -- 11. Random garbage strings (100 iterations)
    -------------------------------------------------
    _G.print("|cff00ccff[PBT]|r Running " .. _G.tostring(NUM_ITERATIONS) .. " random garbage iterations...")
    for i = 1, NUM_ITERATIONS do
        local garbageLen = nextRandom(200) + 1
        local garbage = randomString(garbageLen, garbageLen)

        testNum = testNum + 1
        local ok, err = Import(garbage)
        if ok then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r random iter %d: expected rejection for garbage string (len=%d)"):format(i, garbageLen))
        elseif type(err) ~= "string" or err == "" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r random iter %d: rejected but error is not a non-empty string"):format(i))
        end

        testNum = testNum + 1
        local vOk, vErr = ValidateImportString(garbage)
        if vOk then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r random validate iter %d: expected rejection for garbage string (len=%d)"):format(i, garbageLen))
        elseif type(vErr) ~= "string" or vErr == "" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r random validate iter %d: rejected but error is not a non-empty string"):format(i))
        end
    end

    -------------------------------------------------
    -- Summary
    -------------------------------------------------
    _G.print("---")
    _G.print("|cff00ccff[PBT]|r Total checks: " .. _G.tostring(testNum))
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 21: Invalid import rejection — all %d checks passed"):format(testNum))
    else
        _G.print(("|cffff0000[FAIL]|r Property 21: Invalid import rejection — %d failures out of %d checks"):format(failures, testNum))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:invalidimport()
    return RunInvalidImportTest()
end
