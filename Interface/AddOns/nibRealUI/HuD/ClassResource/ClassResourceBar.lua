local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "ClassResourceBar"
local ClassResourceBar = nibRealUI:NewModule(MODNAME)

local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")

local layoutSize

local Textures = {
    short = {
        [1] = {
            bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Bar]],
            endBox = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_End]],
            middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Middle]],
        },
        [2] = {
            bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Bar]],
            endBox = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_End]],
            middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Middle]],
        },
    },
    long = {
        [1] = {
            bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Bar_Long]],
            endBox = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_End]],
            middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Middle]],
        },
        [2] = {
            bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Bar_Long]],
            endBox = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_End]],
            middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Middle]],
        },
    },
}

local BarWidth = {
    short = {
        [1] = 84,
        [2] = 114,
    },
    long = {
        [1] = 118,
        [2] = 128,
    },
}

local FontStringsRegular = {}


function ClassResourceBar:SetValue(side, value)
    AngleStatusBar:SetValue(self.parent[side].bar, value)
end

function ClassResourceBar:SetText(side, text)
    self.parent[side].value:SetText(text)
end

function ClassResourceBar:SetBoxColor(side, colorTbl)
    if side == "middle" then
        self.parent.middle:SetVertexColor(unpack(colorTbl))
    else
        self.parent[side].endBox:SetVertexColor(unpack(colorTbl))
    end
end

function ClassResourceBar:SetBarColor(side, colorTbl)
   AngleStatusBar:SetBarColor(self.parent[side].bar, colorTbl)
end

function ClassResourceBar:ReverseBar(side, reverse)
    if side == "left" then
        if reverse then
            AngleStatusBar:ReverseBarDirection(self.parent.left.bar, true, 2, -1)
        else
            AngleStatusBar:ReverseBarDirection(self.parent.left.bar, false, 5, -1)
        end
    else
        if reverse then
            AngleStatusBar:ReverseBarDirection(self.parent.right.bar, true, -2, -1)
        else
            AngleStatusBar:ReverseBarDirection(self.parent.right.bar, false, 5, -1)
        end
    end
end

function ClassResourceBar:SetEndBoxShown(side, value)
    self.parent[side].endBox:SetShown(value)
end

function ClassResourceBar:SetShown(value)
    self.parent:SetShown(value)
end

function ClassResourceBar:Show()
	self.parent:Show()
end

function ClassResourceBar:Hide()
	self.parent:Hide()
end

function ClassResourceBar:IsShown()
    return self.parent:IsShown()
end

-----------------------
---- Frame Updates ----
-----------------------
function ClassResourceBar:UpdateFonts()
    local font = nibRealUI:Font()
    for k, fontString in pairs(FontStringsRegular) do
        fontString:SetFont(unpack(font))
    end
end

function ClassResourceBar:CreateResourceBar()
    self.parent = CreateFrame("Frame", nil, RealUIPositionersClassResource)
    local rBar = self.parent
        rBar:SetSize((BarWidth[layoutSize] * 2) + 1, 6)
        rBar:SetPoint("BOTTOM")
        -- rBar:Hide()
    
    -- Left
    rBar.left = CreateFrame("Frame", nil, rBar)
        rBar.left:SetPoint("BOTTOMRIGHT", rBar, "BOTTOM", -1, 0)
        rBar.left:SetSize(BarWidth[layoutSize], 6)

        rBar.left.bg = rBar.left:CreateTexture(nil, "BACKGROUND")
            rBar.left.bg:SetPoint("BOTTOMRIGHT")
            rBar.left.bg:SetSize(128, 16)
            rBar.left.bg:SetTexture(Textures[layoutSize].bar)
            rBar.left.bg:SetVertexColor(unpack(nibRealUI.media.background))

        rBar.left.endBox = rBar.left:CreateTexture(nil, "BACKGROUND")
            rBar.left.endBox:SetPoint("BOTTOMRIGHT", rBar.left, "BOTTOMLEFT", 4, 0)
            rBar.left.endBox:SetSize(16, 16)
            rBar.left.endBox:SetTexture(Textures[layoutSize].endBox)
            rBar.left.endBox:SetVertexColor(unpack(nibRealUI.media.colors.blue))

        rBar.left.bar = AngleStatusBar:NewBar(rBar.left, -5, -1, BarWidth[layoutSize] - 7, 4, "RIGHT", "RIGHT", "LEFT")
            AngleStatusBar:SetBarColor(rBar.left.bar, nibRealUI.media.colors.blue)
            rBar.left.bar.reverse = true

        rBar.left.value = rBar.left:CreateFontString()
            rBar.left.value:SetPoint("BOTTOMLEFT", rBar.left, "TOPLEFT", -6.5, 1.5)
            rBar.left.value:SetFont(unpack(nibRealUI:Font()))
            rBar.left.value:SetJustifyH("LEFT")
            tinsert(FontStringsRegular, rBar.left.value)
    
    -- Right
    rBar.right = CreateFrame("Frame", nil, rBar)
        rBar.right:SetPoint("BOTTOMLEFT", rBar, "BOTTOM", 0, 0)
        rBar.right:SetSize(BarWidth[layoutSize], 6)

        rBar.right.bg = rBar.right:CreateTexture(nil, "BACKGROUND")
            rBar.right.bg:SetPoint("BOTTOMLEFT")
            rBar.right.bg:SetSize(128, 16)
            rBar.right.bg:SetTexture(Textures[layoutSize].bar)
            rBar.right.bg:SetTexCoord(1, 0, 0, 1)
            rBar.right.bg:SetVertexColor(unpack(nibRealUI.media.background))

        rBar.right.endBox = rBar.right:CreateTexture(nil, "BACKGROUND")
            rBar.right.endBox:SetPoint("BOTTOMLEFT", rBar.right, "BOTTOMRIGHT", -4, 0)
            rBar.right.endBox:SetSize(16, 16)
            rBar.right.endBox:SetTexture(Textures[layoutSize].endBox)
            rBar.right.endBox:SetTexCoord(1, 0, 0, 1)
            rBar.right.endBox:SetVertexColor(unpack(nibRealUI.media.colors.orange))

        rBar.right.bar = AngleStatusBar:NewBar(rBar.right, 5, -1, BarWidth[layoutSize] - 7, 4, "LEFT", "LEFT", "RIGHT")
            AngleStatusBar:SetBarColor(rBar.right.bar, nibRealUI.media.colors.orange)
            rBar.right.bar.reverse = true

        rBar.right.value = rBar.right:CreateFontString()
            rBar.right.value:SetPoint("BOTTOMRIGHT", rBar.right, "TOPRIGHT", 9.5, 1.5)
            rBar.right.value:SetFont(unpack(nibRealUI:Font()))
            rBar.right.value:SetJustifyH("RIGHT")
            tinsert(FontStringsRegular, rBar.right.value)

    -- Middle
    rBar.middle = rBar:CreateTexture(nil, "BACKGROUND")
        rBar.middle:SetPoint("BOTTOM")
        rBar.middle:SetSize(16, 16)
        rBar.middle:SetTexture(Textures[layoutSize].middle)

    rBar.middle.value = rBar:CreateFontString()
        rBar.middle.value:SetPoint("BOTTOM", rBar, "TOP", 0, 3)
        rBar.middle.value:SetFont(unpack(nibRealUI:Font()))
        rBar.middle.value:SetJustifyH("CENTER")
        tinsert(FontStringsRegular, rBar.middle.value)
end

function ClassResourceBar:New()
    local ResourceBar = {}
    setmetatable(ResourceBar, {__index = self})

    ResourceBar:CreateResourceBar()

    return ResourceBar
end

------------
function ClassResourceBar:OnInitialize()
    ndb = nibRealUI.db.profile
    layoutSize = ndb.settings.hudSize
end