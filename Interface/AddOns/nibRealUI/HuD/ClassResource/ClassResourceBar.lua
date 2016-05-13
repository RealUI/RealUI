local _, private = ...


-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local ndb

local currentResource
function RealUI:GetResourceBar()
    return currentResource
end

if RealUI.isBeta then return end

local MODNAME = "ClassResourceBar"
local ClassResourceBar = RealUI:NewModule(MODNAME)

local AngleStatusBar = RealUI:GetModule("AngleStatusBar")

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

function ClassResourceBar:SetValue(side, value)
    AngleStatusBar:SetValue(self.parent[side].bar, value)
end

function ClassResourceBar:SetText(side, text)
    self.parent[side].value:SetText(text)
end

function ClassResourceBar:SetBoxColor(side, color)
    if side == "middle" then
        self.parent.middle:SetVertexColor(color[1], color[2], color[3], color[4])
    else
        self.parent[side].endBox:SetVertexColor(color[1], color[2], color[3], color[4])
    end
end

function ClassResourceBar:SetBarColor(side, color)
   AngleStatusBar:SetBarColor(self.parent[side].bar, color)
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
function ClassResourceBar:CreateResourceBar(size)
    self.parent = _G.CreateFrame("Frame", nil, _G.RealUIPositionersClassResource)
    local rBar = self.parent
        rBar:SetSize((BarWidth[size][layoutSize] * 2) + 1, 6)
        rBar:SetPoint("BOTTOM")
        -- rBar:Hide()

    -- Left
    rBar.left = _G.CreateFrame("Frame", nil, rBar)
        rBar.left:SetPoint("BOTTOMRIGHT", rBar, "BOTTOM", -1, 0)
        rBar.left:SetSize(BarWidth[size][layoutSize], 6)

        local color = RealUI.media.background
        rBar.left.bg = rBar.left:CreateTexture(nil, "BACKGROUND")
            rBar.left.bg:SetPoint("BOTTOMRIGHT")
            rBar.left.bg:SetSize(128, 16)
            rBar.left.bg:SetTexture(Textures[size][layoutSize].bar)
            rBar.left.bg:SetVertexColor(color[1], color[2], color[3], color[4])

        color = RealUI.media.colors.blue
        rBar.left.endBox = rBar.left:CreateTexture(nil, "BACKGROUND")
            rBar.left.endBox:SetPoint("BOTTOMRIGHT", rBar.left, "BOTTOMLEFT", 4, 0)
            rBar.left.endBox:SetSize(16, 16)
            rBar.left.endBox:SetTexture(Textures[size][layoutSize].endBox)
            rBar.left.endBox:SetVertexColor(color[1], color[2], color[3], color[4])

        rBar.left.bar = AngleStatusBar:NewBar(rBar.left, -5, -1, BarWidth[size][layoutSize] - 7, 4, "RIGHT", "RIGHT", "LEFT")
            AngleStatusBar:SetBarColor(rBar.left.bar, color)
            rBar.left.bar.reverse = true

        rBar.left.value = rBar.left:CreateFontString()
            rBar.left.value:SetPoint("BOTTOMLEFT", rBar.left, "TOPLEFT", -6.5, 1.5)
            rBar.left.value:SetFontObject(_G.RealUIFont_Pixel)
            rBar.left.value:SetJustifyH("LEFT")

    -- Right
    rBar.right = _G.CreateFrame("Frame", nil, rBar)
        rBar.right:SetPoint("BOTTOMLEFT", rBar, "BOTTOM", 0, 0)
        rBar.right:SetSize(BarWidth[size][layoutSize], 6)

        color = RealUI.media.background
        rBar.right.bg = rBar.right:CreateTexture(nil, "BACKGROUND")
            rBar.right.bg:SetPoint("BOTTOMLEFT")
            rBar.right.bg:SetSize(128, 16)
            rBar.right.bg:SetTexture(Textures[size][layoutSize].bar)
            rBar.right.bg:SetTexCoord(1, 0, 0, 1)
            rBar.right.bg:SetVertexColor(color[1], color[2], color[3], color[4])

        color = RealUI.media.colors.orange
        rBar.right.endBox = rBar.right:CreateTexture(nil, "BACKGROUND")
            rBar.right.endBox:SetPoint("BOTTOMLEFT", rBar.right, "BOTTOMRIGHT", -4, 0)
            rBar.right.endBox:SetSize(16, 16)
            rBar.right.endBox:SetTexture(Textures[size][layoutSize].endBox)
            rBar.right.endBox:SetTexCoord(1, 0, 0, 1)
            rBar.right.endBox:SetVertexColor(color[1], color[2], color[3], color[4])

        rBar.right.bar = AngleStatusBar:NewBar(rBar.right, 5, -1, BarWidth[size][layoutSize] - 7, 4, "LEFT", "LEFT", "RIGHT")
            AngleStatusBar:SetBarColor(rBar.right.bar, color)
            rBar.right.bar.reverse = true

        rBar.right.value = rBar.right:CreateFontString()
            rBar.right.value:SetPoint("BOTTOMRIGHT", rBar.right, "TOPRIGHT", 9.5, 1.5)
            rBar.right.value:SetFontObject(_G.RealUIFont_Pixel)
            rBar.right.value:SetJustifyH("RIGHT")

    -- Middle
    rBar.middle = rBar:CreateTexture(nil, "BACKGROUND")
        rBar.middle:SetPoint("BOTTOM")
        rBar.middle:SetSize(16, 16)
        rBar.middle:SetTexture(Textures[size][layoutSize].middle)

    rBar.middle.value = rBar:CreateFontString()
        rBar.middle.value:SetPoint("BOTTOM", rBar, "TOP", 1.5, 3.5)
        rBar.middle.value:SetFontObject(_G.RealUIFont_Pixel)
        rBar.middle.value:SetJustifyH("CENTER")
end

function ClassResourceBar:New(size, name)
    local ResourceBar = {}
    _G.setmetatable(ResourceBar, {__index = self})

    ResourceBar:CreateResourceBar(size)
    currentResource = name

    return ResourceBar
end

------------
function ClassResourceBar:OnInitialize()
    ndb = RealUI.db.profile
    layoutSize = ndb.settings.hudSize
end
