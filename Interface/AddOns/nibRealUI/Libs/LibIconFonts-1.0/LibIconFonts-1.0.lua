local MAJOR = "LibIconFonts-1.0"
print("lib", MAJOR)
local MINOR = 1 -- Should be manually increased
assert(LibStub, MAJOR .. " requires LibStub")

local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- No upgrade needed

local fonts = {}

-- Retrieve a specific icon font
-- @param font The name of the font
-- @param version The requested version of the font
function lib:GetIconFont(fontName, fontPath, version)
    local font = fonts[fontName][version]
    font.path = fontPath
    return font
end

function lib:RegisterIconFont(fontName, font, version)
    fonts[fontName] = fonts[fontName] or {}
    fonts[fontName][version] = font
end

function IconFontTest()
    print("IconFontTest")
    local octicons = lib:GetIconFont("octicons", "3.3.0")
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
        local textOcticons = frame:CreateFontString(nil, "ARTWORK")
        textOcticons:SetFont([[Interface\AddOns\nibRealUI\Fonts\octicons-local.ttf]], size, "OUTLINE")
        textOcticons:SetText(octicons.alert)
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
