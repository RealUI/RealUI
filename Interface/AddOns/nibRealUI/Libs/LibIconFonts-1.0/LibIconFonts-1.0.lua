local MAJOR = "LibIconFonts-1.0"
print("lib", MAJOR)
local MINOR = 1 -- Should be manually increased
assert(LibStub, MAJOR .. " requires LibStub")

local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- No upgrade needed
local _, addon = ...

-- This was found on the Lua list archive, writen by Stuart Bentley.
-- http://lua-users.org/lists/lua-l/2011-12/msg00072.html
local function utf8(num)
    print("utf8", num)
    num = tonumber(num,16)
    local char = string.char
    local floor = math.floor
    local highbits = 7
    local sparebytes = 0
    while num >= 2^(highbits + sparebytes * 6) do
        highbits = highbits - 1
        if highbits < 1 then error "utf-8 sequence out of range" end
        sparebytes = sparebytes + 1
    end
    if sparebytes == 0 then
        return char(num)
    else
        local bytes = {}
        for i=1, sparebytes do
            local byte = floor((num / 2^((i-1)*6)) % 2^6)
            bytes[sparebytes+2-i] = char(byte + 2^7)
        end
        local byte = floor(num / 2^(sparebytes*6))
        bytes[1] = char(byte + 2^8 - 2^(highbits))
        return table.concat(bytes)
    end
end
addon.utf8 = utf8

function lib:RegisterPath(path)
    addon.path = path
end

function IconFontTest()
    print("IconFontTest")
    local octicons = lib:octicons()
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
        textOcticons:SetFont(octicons.font, min(size, 32), "OUTLINE")
        textOcticons:SetText(octicons.alert)
        if i == 1 then
            textOcticons:SetPoint("BOTTOMLEFT", previous, "TOPLEFT", 3, 1)
        else
            textOcticons:SetPoint("BOTTOMLEFT", previous, "BOTTOMRIGHT", 10, 0)
        end
        if (size > 32) then
            --textOcticons:SetWidth(size)
            textOcticons:SetTextHeight(size)
        end

        local textNormal = frame:CreateFontString(nil, "ARTWORK")
        textNormal:SetFont([[Fonts\FRIZQT__.TTF]], min(size, 32), "OUTLINE")
        textNormal:SetText(size)
        textNormal:SetPoint("TOP", textOcticons, "BOTTOM", 0, -10)
        if (size > 32) then
            --textOcticons:SetWidth(size)
            textNormal:SetTextHeight(size)
        end
        previous = textOcticons
    end
end
