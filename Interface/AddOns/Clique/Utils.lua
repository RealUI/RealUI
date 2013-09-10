--[[-------------------------------------------------------------------------
-- Utils.lua
--
-- This file contains a series of general utility functions that could be
-- used throughout the addon, although in practice they are mostly used in
-- the GUI.
--
-- Events registered:
--   None
-------------------------------------------------------------------------]]--

local addonName, addon = ...
local L = addon.L

-- Returns the prefix string for the current keyboard state.
--
-- Arguments:
--   split - Whether or not to split the modifier keys into left and right components

function addon:GetPrefixString(split)
    local shift, lshift, rshift = IsShiftKeyDown(), IsLeftShiftKeyDown(), IsRightShiftKeyDown()
    local ctrl, lctrl, rctrl = IsControlKeyDown(), IsLeftControlKeyDown(), IsRightControlKeyDown()
    local alt, lalt, ralt = IsAltKeyDown(), IsLeftAltKeyDown() IsRightAltKeyDown()

    if not extended then
        shift = shift or lshift or rshift
        ctrl = ctrl or lctrl or rctrl
        alt = alt or lalt or ralt

        lshift, rshift = false, false
        lctrl, rctrl = false, false
        lalt, ralt = false, false
    end

    local prefix = ""
    if shift then
        prefix = ((lshift and "LSHIFT-") or (rshift and "RSHIFT-") or "SHIFT-") .. prefix
    end
    if ctrl then
        prefix = ((lctrl and "LCTRL-") or (rctrl and "RCTRL-") or "CTRL-") .. prefix
    end
    if alt then
        prefix = ((lalt and "LALT-") or (ralt and "RALT-") or "ALT-") .. prefix
    end

    return prefix
end

-- This function can return a substring of a UTF-8 string, properly handling
-- UTF-8 codepoints.  Rather than taking a start index and optionally an end
-- index, it takes the string, the start index and the number of characters
-- to select from the string.
--
-- UTF-8 Reference:
-- 0xxxxxx - ASCII character
-- 110yyyxx - 2 byte UTF codepoint
-- 1110yyyy - 3 byte UTF codepoint
-- 11110zzz - 4 byte UTF codepoint

local function utf8sub(str, start, numChars)
    local currentIndex = start
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        if char >= 240 then
            currentIndex = currentIndex + 4
        elseif char >= 225 then
            currentIndex = currentIndex + 3
        elseif char >= 192 then
            currentIndex = currentIndex + 2
        else
            currentIndex = currentIndex + 1
        end
        numChars = numChars - 1
    end
    return str:sub(start, currentIndex - 1)
end

local convertMap = setmetatable({
    LSHIFT = L["LShift"],
    RSHIFT = L["RShift"],
    SHIFT = L["Shift"],
    LCTRL = L["LCtrl"],
    RCTRL = L["RCtrl"],
    CTRL = L["Ctrl"],
    LALT = L["LAlt"],
    RALT = L["RAlt"],
    ALT = L["Alt"],
    BUTTON1 = L["LeftButton"],
    BUTTON2 = L["RightButton"],
    BUTTON3 = L["MiddleButton"],
    MOUSEWHEELUP = L["MousewheelUp"],
    MOUSEWHEELDOWN = L["MousewheelDown"],
}, {
    __index = function(t, k, v)
        if k:match("^BUTTON(%d+)$") then
            return k:gsub("^BUTTON(%d+)$", "Button%1")
        else
            if utf8sub(k, 1, 1) ~= k:sub(1, 1) then
                -- If the first character is a multi-byte UTF-8 character
                return k
            else
                -- Make the first character upper-case, lower the rest
                return tostring(k:sub(1, 1):upper()) .. tostring(k:sub(2, -1):lower())
            end
        end
    end,
})

local function convert(item, ...)
    if not item then
        return ""
    else
        local mapItem = convertMap[item]
        item = mapItem and mapItem or item

        if select("#", ...) > 0 then
            return item, "-", convert(...)
        else
            return item, convert(...)
        end
    end
end

function addon:GetBindingIcon(binding)
    if type(binding) ~= "table" or not binding.type then
        return "Interface\\Icons\\INV_Misc_QuestionMark"
    end

    local btype = binding.type
    if btype == "menu" then
        --return "Interface\\Icons\\Trade_Engineering"
        return nil
    elseif btype == "target" then
        --return "Interface\\Icons\\Ability_Mage_IncantersAbsorbtion"
        return nil
    else
        return binding.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    end
end

function addon:GetBindingKeyComboText(binding)
    if type(binding) == "table" and binding.key then
        return strconcat(convert(strsplit("-", binding.key)))
    elseif type(binding) == "string" then
        return strconcat(convert(strsplit("-", binding)))
    else
        return L["Unknown"]
    end
end

function addon:GetBindingActionText(btype, binding)
    if btype == "menu" then
        return L["Show unit menu"]
    elseif btype == "target" then
        return L["Target clicked unit"]
    elseif btype == "spell" then
        return L["Cast %s"]:format(tostring(binding.spell))
    elseif btype == "macro" and type(binding) == "table" then
        return L["Run macro '%s'"]:format(tostring(binding.macrotext))
    elseif btype == "macro" then
        return L["Run macro"]:format(tostring(binding.macrotext))
    else
        return L["Unknown binding type '%s'"]:format(tostring(btype))
    end
end

function addon:GetBindingKey(binding)
    if type(binding) ~= "table" or not binding.key then
        return "UNKNOWN"
    end

    local key = binding.key:match("[^%-]+$")
    return key
end

local binMap = {
    ALT = 1,
    LALT = 2,
    RALT = 3,
    CTRL = 4,
    LCTRL = 5,
    LCTRL = 6,
    SHIFT = 7,
    LSHIFT = 8,
    RSHIFT = 9,
}

function addon:GetBinaryBindingKey(binding)
    if type(binding) ~= "table" or not binding.key then
        return "000000000"
    end

    local ret = {"0", "0", "0", "0", "0", "0", "0", "0", "0"}
    local splits = {strsplit("-", binding.key)}
    for idx, modifier in ipairs(splits) do
        local bit = binMap[modifier]
        if bit then
            ret[bit] = "1"
        else
            ret[10] = modifier
        end
    end
    return table.concat(ret)
end

local invalidKeys = {
    ["UNKNOWN"] = true,
    ["LSHIFT"] = true,
    ["RSHIFT"] = true,
    ["LCTRL"] = true,
    ["RCTRL"] = true,
    ["LALT"] = true,
    ["RALT"] = true,
    ["ESCAPE"] = true,
}

function addon:GetCapturedKey(key)
    -- We can't bind modifiers or invalid keys
    if invalidKeys[key] then
        return
    end

    -- Remap any mouse buttons
    if key == "LeftButton" then
        key = "BUTTON1"
    elseif key == "RightButton" then
        key = "BUTTON2"
    elseif key == "MiddleButton" then
        key = "BUTTON3"
    elseif key == "-" then
        key = "DASH"
    elseif key == "\\" then
        key = "BACKSLASH"
    elseif key == "\"" then
        key = "DOUBLEQUOTE"
    else
        local buttonNum = key:match("Button(%d+)")
        if buttonNum and tonumber(buttonNum) <= 31 then
            key = "BUTTON" .. buttonNum
        end
    end

    -- TODO: Support NOT splitting the modifier keys
    local prefix = addon:GetPrefixString(true)
    return tostring(prefix) .. tostring(key)
end

function addon:GetBindingInfoText(binding)
    if type(binding) ~= "table" or not binding.sets then
        return L["This binding is invalid, please delete"]
    end

    local sets = binding.sets
    if not sets then
        return ""
    elseif not next(sets) then
        -- No bindings set, so display a message
        return L["This binding is DISABLED"]
    else
        local bits = {}
        for k,v in pairs(sets) do
            table.insert(bits, k)
        end
        table.sort(bits)
        return table.concat(bits, ", ")
    end
end

function addon:ConvertSpecialKeys(binding)
    if type(binding) ~= "table" or not binding.key then
        return "UNKNOWN"
    end

    local mods, key = binding.key:match("^(.-)([^%-]+)$")
    if key == "DASH" then
        key = "-"
    elseif key == "BACKSLASH" then
        key = "\\"
    elseif key == "DOUBLEQUOTE" then
        key = "\""
    end

    return tostring(mods) .. tostring(key)
end

function addon:GetBindingPrefixSuffix(binding, global)
    if type(binding) ~= "table" or not binding.key then
        return "UNKNOWN", "UNKNOWN"
    end

    local prefix, suffix = binding.key:match("^(.-)([^%-]+)$")
    if prefix:sub(-1, -1) == "-" then
        prefix = prefix:sub(1, -2)
    end

    prefix = prefix:lower()

    local prefixKey = prefix:gsub("[%A]", "")
    local buttonNum = suffix:match("^BUTTON(%d+)$")

    if buttonNum and global then
        suffix = "cliquemouse" .. tostring(prefixKey) .. tostring(buttonNum)
        prefix = ""
    elseif buttonNum then
        suffix = buttonNum
    else
        suffix = "cliquebutton" .. tostring(prefixKey) .. tostring(suffix)
        prefix = ""
    end

    return prefix, suffix
end
