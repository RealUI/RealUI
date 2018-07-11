-- Lua Globals --
local _G = _G
local assert = _G.assert

local MAJOR, MINOR = "LibIconFonts-1.0", 1 -- Should be manually increased
assert(_G.LibStub, MAJOR .. " requires LibStub")

local lib, oldminor = _G.LibStub:NewLibrary(MAJOR, MINOR) --luacheck: ignore
if not lib then return end -- No upgrade needed

local fonts = {}

-- Retrieve a specific icon font
-- @param fontName The name of the font
function lib:GetIconFont(fontName)
    local font = fonts[fontName]
    assert(font, ("%s has not been registered."):format(fontName))
    return font.icons or font.func(font)
end

-- Register an icon font
-- @param fontName The name of the font
-- @param fontFunc A function that returns a table containing the font icons
-- @param ... A list of supported version for the font
function lib:RegisterIconFont(fontName, fontFunc, ...)
    local font = fonts[fontName] or {}
    font.func = fontFunc
    fonts[fontName] = font
end
