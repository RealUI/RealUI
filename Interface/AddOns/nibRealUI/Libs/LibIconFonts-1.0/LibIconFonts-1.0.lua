-- Lua Globals --
local _G = _G
local assert, select = _G.assert, _G.select

local MAJOR, MINOR = "LibIconFonts-1.0", 1 -- Should be manually increased
assert(LibStub, MAJOR .. " requires LibStub")

local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- No upgrade needed

local fonts = {}

-- Retrieve a specific icon font
-- @param fontName The name of the font
-- @param version The requested version of the font
function lib:GetIconFont(fontName, version)
    local font = fonts[fontName]
    assert(font, ("%s has not been registered."):format(fontName))
    assert(font.versions[version], ("%s does not support version %s."):format(fontName, version))
    return font.func(version)
end

-- Register an icon font
-- @param fontName The name of the font
-- @param fontFunc A function that returns a table containing the font icons
-- @param ... A list of supported version for the font
function lib:RegisterIconFont(fontName, fontFunc, ...)
    local font = fonts[fontName] or {}
    font.func = fontFunc
    font.versions = {}
    for i = 1, select("#", ...) do
        font.versions[select(i, ...)] = true
    end
    fonts[fontName] = font
end

function IconFontTest()
    print("IconFontTest")
    local octicons = {}
    octicons[2] = lib:GetIconFont("octicons", "v2.x")
    octicons[2].path = [[Interface\AddOns\nibRealUI\Fonts\octicons-local-v2.4.1.ttf]]

    octicons[3] = lib:GetIconFont("octicons", "v3.x")
    octicons[3].path = [[Interface\AddOns\nibRealUI\Fonts\octicons-local.ttf]]

    local frame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplate")
    frame:SetSize(600, 400)
    frame:SetPoint("CENTER")
    frame:Show()

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetTexture(1, 1, 1, 1)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 0, -200)
    line:SetPoint("TOPRIGHT", 0, -200)

    local line2 = frame:CreateTexture(nil, "ARTWORK")
    line2:SetTexture(1, 1, 1, 1)
    line2:SetHeight(1)
    line2:SetPoint("TOPLEFT", line, 0, 32)
    line2:SetPoint("TOPRIGHT", line, 0, 32)

    local previous = line
    for i = 1, 10 do
        local size = 32 * i
        local textOcticons, font = frame:CreateFontString(nil, "ARTWORK"), octicons[(i % 2) + 2]
        textOcticons:SetFont(font.path, size, "OUTLINE")
        textOcticons:SetText(font.microscope)
        if i == 1 then
            textOcticons:SetPoint("BOTTOMLEFT", previous, "TOPLEFT", 3, 1)
        else
            textOcticons:SetPoint("BOTTOMLEFT", previous, "BOTTOMRIGHT", 10, 0)
        end
        if (size > 32) then
            --textOcticons:SetWidth(size)
            --textOcticons:SetTextHeight(size)
        end

        local textNormal = frame:CreateFontString(nil, "ARTWORK")
        textNormal:SetFont([[Fonts\FRIZQT__.TTF]], size, "OUTLINE")
        textNormal:SetText(size)
        textNormal:SetPoint("TOP", textOcticons, "BOTTOM", 0, -10)
        if (size > 32) then
            --textOcticons:SetWidth(size)
            --textNormal:SetTextHeight(size)
        end
        previous = textOcticons
    end
end
