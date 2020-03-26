local _, private = ...

-- Libs --
local LSM = _G.LibStub("LibSharedMedia-3.0")
local Aurora = _G.Aurora
local Base = Aurora.Base

local CombatText = private.CombatText

local function ScrollLineFactory(pool)
    local scrollLine = _G.CreateFrame("Frame", nil, _G.UIParent)
    _G.Mixin(scrollLine, pool.mixin)
    scrollLine:SetSize(100, 16)

    local text = scrollLine:CreateFontString(nil, "BACKGROUND", nil, 0)
    scrollLine.text = text

    local icon = scrollLine:CreateTexture(nil, "BACKGROUND", nil, 0)
    icon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]])
    icon.bg = Base.CropIcon(icon, scrollLine)
    scrollLine.icon = icon

    local scrollAnim = scrollLine:CreateAnimationGroup()
    scrollAnim:SetScript("OnFinished", function(anim, requested)
        pool:Release(scrollLine)
    end)
    scrollLine.scrollAnim = scrollAnim

    local alphaIn = scrollAnim:CreateAnimation("Alpha")
    alphaIn:SetFromAlpha(0)
    alphaIn:SetToAlpha(1)
    scrollLine.alphaIn = alphaIn

    local alphaOut = scrollAnim:CreateAnimation("Alpha")
    alphaOut:SetFromAlpha(1)
    alphaOut:SetToAlpha(0)
    scrollLine.alphaOut = alphaOut

    local translate = scrollAnim:CreateAnimation("Translation")
    translate:SetScript("OnPlay", function(trans)
        translate:SetOffset(0, translate.offset)
    end)
    scrollLine.translate = translate

    scrollLine:OnLoad()
    return scrollLine
end
local function ScrollLineReset(scrollLinePool, scrollLine)
    scrollLine:Clear()
end


local ScrollLineMixin = {}
function ScrollLineMixin:OnLoad()
    self:SetOptions()
end
function ScrollLineMixin:SetOptions()
    local font = CombatText.db.global.fonts.normal
    self.text:SetFont(LSM:Fetch("font", font.name), font.size, font.flags)
    self.icon:SetSize(font.size, font.size)

    local animDuration = CombatText.db.global.scrollDuration
    self.alphaIn:SetDuration(animDuration * 0.2)

    self.translate:SetDuration(animDuration)

    self.alphaOut:SetDuration(animDuration * 0.2)
    self.alphaOut:SetStartDelay(animDuration * 0.8)
end
function ScrollLineMixin:AddToScrollArea(scrollArea)
    self.scrollArea = scrollArea

    if scrollArea.direction == "up" then
        self:SetPoint("BOTTOM", scrollArea)
        self.translate.offset = scrollArea:GetHeight()
    elseif scrollArea.direction == "down" then
        self:SetPoint("TOP", scrollArea)
        self.translate.offset = -scrollArea:GetHeight()
    end

    local scrollSettings = CombatText.db.global[scrollArea.scrollType]
    self.text:SetPoint(scrollSettings.justify)
    if scrollSettings.justify == "RIGHT" then
        self.icon:SetPoint("LEFT", self.text, "RIGHT", 2, 0)
    else
        self.icon:SetPoint("RIGHT", self.text, "LEFT", -2, 0)
    end
end
function ScrollLineMixin:DisplayText(text, icon)
    self.text:SetText(text)
    self.icon:SetTexture(icon)
    self.icon.bg:SetShown(icon)

    self:Show()
    self.scrollAnim:Play()
end
function ScrollLineMixin:Clear()
    self:ClearAllPoints()
    self.text:ClearAllPoints()
    self.icon:ClearAllPoints()

    self:Hide()
end

local StickyLineMixin = _G.CreateFromMixins(ScrollLineMixin)
function StickyLineMixin:OnLoad()
    local scale = self.scrollAnim:CreateAnimation("Scale")
    scale:SetFromScale(3, 3)
    scale:SetToScale(1, 1)
    self.scale = scale

    self:SetOptions()
end
function StickyLineMixin:SetOptions()
    local font = CombatText.db.global.fonts.sticky
    self.text:SetFont(LSM:Fetch("font", font.name), font.size, font.flags)
    self.icon:SetSize(font.size, font.size)

    local animDuration = CombatText.db.global.scrollDuration
    self.alphaIn:SetDuration(animDuration * 0.2)
    self.scale:SetDuration(animDuration * 0.2)

    self.translate:SetDuration(animDuration * 0.5)
    self.translate:SetStartDelay(animDuration * 0.4)

    self.alphaOut:SetDuration(animDuration * 0.2)
    self.alphaOut:SetStartDelay(animDuration * 0.8)
end
function StickyLineMixin:AddToScrollArea(scrollArea)
    ScrollLineMixin.AddToScrollArea(self, scrollArea)

    self:ClearAllPoints()
    self:SetPoint("CENTER", scrollArea)
    if scrollArea.direction then
        self.translate.offset = self.translate.offset / 2
    else
        self.translate.offset = 0
    end
end

local normalLines = _G.CreateObjectPool(ScrollLineFactory, ScrollLineReset)
normalLines.mixin = ScrollLineMixin

local stickyLines = _G.CreateObjectPool(ScrollLineFactory, ScrollLineReset)
stickyLines.mixin = StickyLineMixin

function CombatText:UpdateLineOptions()
    for _, line in normalLines:EnumerateInactive() do
        line:SetOptions()
    end

    for _, line in stickyLines:EnumerateInactive() do
        line:SetOptions()
    end
end
function private.GetScrollLine(scrollType, isSticky)
    if scrollType == "notification" or isSticky then
        return stickyLines:Acquire()
    end

    return normalLines:Acquire()
end
