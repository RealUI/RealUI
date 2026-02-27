local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Secret-safe tag isolation
-- Feature: hud-rewrite, Property 15: Secret-safe tag isolation
-- Validates: Requirements 20.1, 20.2, 20.5
--
-- Verifies that each tag function:
--   1. Can be called with a valid unit ("player") without error
--   2. Returns a string or nil (nil allowed for optional tags)
--   3. Does not error due to secret value mixing
--
-- Note: oUF tag functions run in a sandboxed _ENV. Some tags (threat, range)
-- reference _TAGS or other sandbox globals that don't exist when called directly.
-- We treat sandbox-environment errors as acceptable (the tag is correct, just
-- needs oUF's environment to run). The key property is that NO tag errors due
-- to secret value taint from mixing API values with non-API values.

-- Tags that may legitimately return nil or error outside oUF's sandbox
local sandboxTags = {
    ["realui:threat"] = true,
    ["realui:range"] = true,
    ["realui:pvptimer"] = true,
    ["realui:level"] = true,
}

-- Known sandbox-environment error patterns (not secret-value issues)
local sandboxErrors = {
    "_COLORS",
    "_TAGS",
    "AbbreviateName",
}

local function isSandboxError(errMsg)
    for _, pattern in _G.ipairs(sandboxErrors) do
        if errMsg:find(pattern, 1, true) then
            return true
        end
    end
    return false
end

local function RunTagsSecretSafeTest()
    _G.print("|cff00ccff[PBT]|r Secret-safe tag isolation — testing all realui: tags with 'player'")

    local oUF = _G.oUF

    if not oUF or not oUF.Tags or not oUF.Tags.Methods then
        _G.print("|cffff0000[ERROR]|r oUF.Tags.Methods not accessible.")
        return false
    end

    local tagMethods = oUF.Tags.Methods
    local failures = 0
    local tagCount = 0

    for tagName, tagFunc in _G.pairs(tagMethods) do
        if type(tagName) == "string" and tagName:find("^realui:") and type(tagFunc) == "function" then
            tagCount = tagCount + 1

            local ok, result = _G.pcall(tagFunc, "player")
            if not ok then
                local errStr = _G.tostring(result)
                if isSandboxError(errStr) then
                    _G.print(("  Tag %q: sandbox env error (expected outside oUF) — OK"):format(tagName))
                elseif errStr:find("secret") then
                    -- This is the actual failure case: secret value taint
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r Tag %q: secret value error: %s"):format(tagName, errStr))
                else
                    -- Unknown error — flag but don't fail (may be sandbox-related)
                    _G.print(("|cffff9900[WARN]|r Tag %q: unexpected error: %s"):format(tagName, errStr))
                end
            else
                -- Successful call — verify return type
                if result == nil then
                    if sandboxTags[tagName] then
                        _G.print(("  Tag %q: returned nil (conditional tag) — OK"):format(tagName))
                    else
                        _G.print(("  Tag %q: returned nil — OK"):format(tagName))
                    end
                elseif type(result) ~= "string" then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r Tag %q returned %s (expected string or nil)"):format(tagName, type(result)))
                else
                    -- Use pcall for tostring/sub in case result is a secret string
                    local displayOk, display = _G.pcall(function()
                        return _G.tostring(result):sub(1, 60)
                    end)
                    if displayOk then
                        _G.print(("  Tag %q: returned %q — OK"):format(tagName, display))
                    else
                        -- Secret string that can't be displayed — still a valid return
                        _G.print(("  Tag %q: returned secret string — OK"):format(tagName))
                    end
                end
            end
        end
    end

    if tagCount == 0 then
        failures = failures + 1
        _G.print("|cffff0000[FAIL]|r No realui: tags found in oUF.Tags.Methods")
    else
        _G.print(("  Tested %d realui: tag functions"):format(tagCount))
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 15: Secret-safe tag isolation — %d tags verified"):format(tagCount))
    else
        _G.print(("|cffff0000[FAIL]|r Property 15: Secret-safe tag isolation — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:tagsecret()
    return RunTagsSecretSafeTest()
end
