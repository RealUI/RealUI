local ADDON_NAME, private = ... -- luacheck: ignore

-- RealUI Profile Exporter
-- Handles serialization and deserialization of profile data for export/import.
-- Uses AceSerializer-3.0 for payload serialization and a built-in base64
-- encoder/decoder for paste-safe string encoding.

-- luacheck: globals next type pairs ipairs tostring tonumber table string math

local RealUI = private.RealUI
local debug = RealUI.GetDebug("ProfileExporter")

local ProfileExporter = {}
RealUI.ProfileExporter = ProfileExporter

-- AceSerializer-3.0 (loaded via Libs.xml / LibStub)
local AceSerializer = _G.LibStub("AceSerializer-3.0")

------------------------------------------------------------
-- Base64 Encode / Decode
------------------------------------------------------------

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function Base64Encode(data)
    local out = {}
    local len = #data
    for i = 1, len, 3 do
        local a = string.byte(data, i)
        local b = i + 1 <= len and string.byte(data, i + 1) or 0
        local c = i + 2 <= len and string.byte(data, i + 2) or 0

        local n = a * 65536 + b * 256 + c

        local c1 = math.floor(n / 262144) % 64
        local c2 = math.floor(n / 4096) % 64
        local c3 = math.floor(n / 64) % 64
        local c4 = n % 64

        out[#out + 1] = string.sub(b64chars, c1 + 1, c1 + 1)
        out[#out + 1] = string.sub(b64chars, c2 + 1, c2 + 1)

        if i + 1 <= len then
            out[#out + 1] = string.sub(b64chars, c3 + 1, c3 + 1)
        else
            out[#out + 1] = "="
        end

        if i + 2 <= len then
            out[#out + 1] = string.sub(b64chars, c4 + 1, c4 + 1)
        else
            out[#out + 1] = "="
        end
    end
    return table.concat(out)
end

-- Build reverse lookup table for base64 decoding
local b64lookup = {}
for i = 1, 64 do
    b64lookup[string.byte(b64chars, i)] = i - 1
end
b64lookup[string.byte("=")] = 0

local function Base64Decode(data)
    -- Strip any whitespace
    data = data:gsub("%s", "")

    local out = {}
    local len = #data
    for i = 1, len, 4 do
        local a = b64lookup[string.byte(data, i)] or 0
        local b = b64lookup[string.byte(data, i + 1)] or 0
        local c = b64lookup[string.byte(data, i + 2)] or 0
        local d = b64lookup[string.byte(data, i + 3)] or 0

        local n = a * 262144 + b * 4096 + c * 64 + d

        out[#out + 1] = string.char(math.floor(n / 65536) % 256)

        if i + 2 <= len and string.sub(data, i + 2, i + 2) ~= "=" then
            out[#out + 1] = string.char(math.floor(n / 256) % 256)
        end
        if i + 3 <= len and string.sub(data, i + 3, i + 3) ~= "=" then
            out[#out + 1] = string.char(n % 256)
        end
    end
    return table.concat(out)
end

------------------------------------------------------------
-- Header Constants
------------------------------------------------------------

local HEADER_PREFIX = "REALUI_EXPORT"
local HEADER_SEPARATOR = ":"
local HEADER_SCOPE_SEPARATOR = ","

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

--- Deep-copy a table (reuse ProfileSystem's utility if available).
local function DeepCopy(original)
    if type(original) ~= "table" then return original end
    local copy = {}
    for k, v in pairs(original) do
        copy[DeepCopy(k)] = DeepCopy(v)
    end
    return copy
end

--- Get the Skins AceDB instance, if available.
local function GetSkinsDB()
    local skinsModule = RealUI:GetModule("Skins", true)
    if skinsModule and skinsModule.db then
        return skinsModule.db
    end
    return nil
end

--- Get the current RealUI version string.
local function GetVersion()
    if RealUI.verinfo and RealUI.verinfo.string then
        return RealUI.verinfo.string
    end
    return _G.C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "0.0.0"
end

--- Read the active profile data table for a given scope.
--- Returns the raw profile data table (not a copy).
local function GetScopeProfileData(scope)
    local PC = RealUI.ProfileCoordinator
    if scope == PC.SCOPE_CORE then
        if RealUI.db then
            return RealUI.db.profile
        end
    elseif scope == PC.SCOPE_SKINS then
        local skinsDB = GetSkinsDB()
        if skinsDB then
            return skinsDB.profile
        end
    elseif scope == PC.SCOPE_BT4 then
        local bt4Addon = _G.Bartender4
        if bt4Addon and bt4Addon.db then
            return bt4Addon.db.profile
        end
        -- Fallback: read from raw saved variable
        local bt4db = _G.Bartender4DB
        if type(bt4db) == "table" and type(bt4db.profileKeys) == "table" and RealUI.key then
            local profileName = bt4db.profileKeys[RealUI.key]
            if profileName and bt4db.profiles and bt4db.profiles[profileName] then
                return bt4db.profiles[profileName]
            end
        end
    end
    return nil
end

--- Build the header string for an export.
local function BuildHeader(scopeNames)
    local version = GetVersion()
    local timestamp = tostring(_G.time())
    local scopes = table.concat(scopeNames, HEADER_SCOPE_SEPARATOR)
    return HEADER_PREFIX .. HEADER_SEPARATOR
        .. version .. HEADER_SEPARATOR
        .. timestamp .. HEADER_SEPARATOR
        .. scopes
end

--- Parse a header string. Returns a table with version, timestamp, scopes
--- or nil + error message on failure.
local function ParseHeader(header)
    if type(header) ~= "string" then
        return nil, "Header is not a string."
    end

    local parts = {_G.strsplit(HEADER_SEPARATOR, header)}
    if #parts < 4 then
        return nil, "Header has too few fields."
    end

    local prefix = parts[1]
    if prefix ~= HEADER_PREFIX then
        return nil, "Invalid header prefix: expected '" .. HEADER_PREFIX .. "'."
    end

    local version = parts[2]
    if not version or version == "" then
        return nil, "Missing version in header."
    end

    local timestamp = tonumber(parts[3])
    if not timestamp then
        return nil, "Invalid timestamp in header."
    end

    local scopeStr = parts[4]
    if not scopeStr or scopeStr == "" then
        return nil, "Missing scopes in header."
    end

    local scopes = {_G.strsplit(HEADER_SCOPE_SEPARATOR, scopeStr)}
    if #scopes == 0 then
        return nil, "No scopes found in header."
    end

    return {
        version = version,
        timestamp = timestamp,
        scopes = scopes,
    }
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------

--- Export a single scope's active profile data.
--- @param scope string  One of ProfileCoordinator.SCOPE_CORE / SCOPE_SKINS / SCOPE_BT4
--- @return string|nil  Encoded export string, or nil on failure
--- @return string|nil  Error message on failure
function ProfileExporter:ExportScope(scope)
    debug("ExportScope:", scope)

    local data = GetScopeProfileData(scope)
    if not data then
        return nil, "No profile data available for scope: " .. tostring(scope)
    end

    -- Deep-copy so serialization doesn't reference live tables
    local payload = {
        [scope] = DeepCopy(data),
    }

    local header = BuildHeader({scope})

    local serialized = AceSerializer:Serialize(payload)
    if not serialized then
        return nil, "Serialization failed."
    end

    local encoded = Base64Encode(serialized)
    return header .. "\n" .. encoded
end

--- Export all linked scopes into a single string.
--- @return string|nil  Encoded export string, or nil on failure
--- @return string|nil  Error message on failure
function ProfileExporter:ExportAllLinked()
    debug("ExportAllLinked")

    local PC = RealUI.ProfileCoordinator
    local payload = {}
    local scopeNames = {}

    -- Core is always included
    local coreData = GetScopeProfileData(PC.SCOPE_CORE)
    if coreData then
        payload[PC.SCOPE_CORE] = DeepCopy(coreData)
        scopeNames[#scopeNames + 1] = PC.SCOPE_CORE
    end

    -- Skins if linked
    if PC:IsScopeLinked(PC.SCOPE_SKINS) then
        local skinsData = GetScopeProfileData(PC.SCOPE_SKINS)
        if skinsData then
            payload[PC.SCOPE_SKINS] = DeepCopy(skinsData)
            scopeNames[#scopeNames + 1] = PC.SCOPE_SKINS
        end
    end

    -- BT4 if linked
    if PC:IsScopeLinked(PC.SCOPE_BT4) then
        local bt4Data = GetScopeProfileData(PC.SCOPE_BT4)
        if bt4Data then
            payload[PC.SCOPE_BT4] = DeepCopy(bt4Data)
            scopeNames[#scopeNames + 1] = PC.SCOPE_BT4
        end
    end

    if #scopeNames == 0 then
        return nil, "No profile data available for any scope."
    end

    local header = BuildHeader(scopeNames)

    local serialized = AceSerializer:Serialize(payload)
    if not serialized then
        return nil, "Serialization failed."
    end

    local encoded = Base64Encode(serialized)
    return header .. "\n" .. encoded
end

--- Validate an import string without applying any changes.
--- @param str string  The encoded export string
--- @return boolean  true if valid
--- @return table|string  Parsed header info on success, or error message on failure
function ProfileExporter:ValidateImportString(str)
    debug("ValidateImportString")

    if type(str) ~= "string" or str == "" then
        return false, "Import string is empty or not a string."
    end

    -- Split header from body at the first newline
    local newlinePos = str:find("\n")
    if not newlinePos then
        return false, "Import string is missing body (no newline separator)."
    end

    local headerStr = str:sub(1, newlinePos - 1)
    local body = str:sub(newlinePos + 1)

    if body == "" then
        return false, "Import string body is empty."
    end

    -- Parse header
    local headerInfo, headerErr = ParseHeader(headerStr)
    if not headerInfo then
        return false, headerErr
    end

    -- Decode base64
    local decoded = Base64Decode(body)
    if not decoded or decoded == "" then
        return false, "Base64 decoding failed."
    end

    -- Deserialize
    local ok, payload = AceSerializer:Deserialize(decoded)
    if not ok then
        return false, "Deserialization failed: " .. tostring(payload)
    end

    if type(payload) ~= "table" then
        return false, "Deserialized payload is not a table."
    end

    -- Verify at least one scope is present
    local hasScope = false
    for _, scope in ipairs(headerInfo.scopes) do
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

--- Import an encoded export string, creating or overwriting profile data.
--- @param encodedString string  The full export string (header + body)
--- @param profileName string|nil  Optional target profile name; defaults to current profile
--- @return boolean  true on success
--- @return table|string  Imported scope list on success, or error message on failure
function ProfileExporter:Import(encodedString, profileName)
    debug("Import:", profileName)

    -- Validate first
    local valid, headerOrErr = self:ValidateImportString(encodedString)
    if not valid then
        return false, headerOrErr
    end

    local headerInfo = headerOrErr

    -- Version warning (newer version)
    local currentVersion = GetVersion()
    if headerInfo.version ~= currentVersion then
        -- Parse both versions for comparison
        local impParts = {_G.strsplit(".", headerInfo.version)}
        local curParts = {_G.strsplit(".", currentVersion)}
        local isNewer = false
        for i = 1, 3 do
            local imp = tonumber(impParts[i]) or 0
            local cur = tonumber(curParts[i]) or 0
            if imp > cur then
                isNewer = true
                break
            elseif imp < cur then
                break
            end
        end
        if isNewer then
            debug("Import from newer version:", headerInfo.version, "current:", currentVersion)
            -- Warn but allow (Req 11.9)
        end
    end

    -- Decode body
    local newlinePos = encodedString:find("\n")
    local body = encodedString:sub(newlinePos + 1)
    local decoded = Base64Decode(body)
    local deserOk, payload = AceSerializer:Deserialize(decoded)
    if not deserOk then
        return false, "Deserialization failed: " .. tostring(payload)
    end

    local PC = RealUI.ProfileCoordinator
    local importedScopes = {}

    for _, scope in ipairs(headerInfo.scopes) do
        local scopeData = payload[scope]
        if scopeData and type(scopeData) == "table" then
            if scope == PC.SCOPE_CORE then
                if RealUI.db then
                    -- Switch to target profile (creates it if needed)
                    local target = profileName or RealUI.db:GetCurrentProfile()
                    RealUI.db:SetProfile(target)
                    -- Overwrite profile data
                    for k, v in pairs(scopeData) do
                        RealUI.db.profile[k] = DeepCopy(v)
                    end
                    importedScopes[#importedScopes + 1] = scope
                end
            elseif scope == PC.SCOPE_SKINS then
                local skinsDB = GetSkinsDB()
                if skinsDB then
                    local target = profileName or skinsDB:GetCurrentProfile()
                    skinsDB:SetProfile(target)
                    for k, v in pairs(scopeData) do
                        skinsDB.profile[k] = DeepCopy(v)
                    end
                    importedScopes[#importedScopes + 1] = scope
                end
            elseif scope == PC.SCOPE_BT4 then
                local bt4Addon = _G.Bartender4
                if bt4Addon and bt4Addon.db then
                    local target = profileName or bt4Addon.db:GetCurrentProfile()
                    bt4Addon.db:SetProfile(target)
                    for k, v in pairs(scopeData) do
                        bt4Addon.db.profile[k] = DeepCopy(v)
                    end
                    importedScopes[#importedScopes + 1] = scope
                end
            end
        end
    end

    if #importedScopes == 0 then
        return false, "No scopes were imported (databases not available)."
    end

    debug("Import complete. Scopes imported:", table.concat(importedScopes, ", "))
    return true, importedScopes
end
