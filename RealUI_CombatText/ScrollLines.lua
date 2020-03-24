local _, private = ...

-- Libs --
local Aurora = _G.Aurora
local Base = Aurora.Base

local CombatText = private.CombatText

local function ScrollLineFactory(pool)
    local scrollLine = _G.CreateFrame("Frame", nil, _G.UIParent)
    _G.Mixin(scrollLine, pool.mixin)
    scrollLine.pool = pool
    scrollLine:OnLoad()

    return scrollLine
end
local function ScrollLineReset(scrollLinePool, scrollLine)
    scrollLine:Clear()
end


local animDuration = 2
local ScrollLineMixin = {}
function ScrollLineMixin:OnLoad()
    self:SetSize(100, 16)

    local font = CombatText.db.global.fontNormal
    local text = self:CreateFontString(nil, "BACKGROUND", nil, 0)
    text:SetFont(font.path, font.size, font.flags)
    self.text = text

    local icon = self:CreateTexture(nil, "BACKGROUND", nil, 0)
    icon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]])
    icon:SetSize(16, 16)
    Base.CropIcon(icon, self)
    self.icon = icon

    local scrollAnim = self:CreateAnimationGroup()
    scrollAnim:SetScript("OnFinished", function(anim, requested)
        self.pool:Release(self)
    end)
    self.scrollAnim = scrollAnim

    local alphaIn = scrollAnim:CreateAnimation("Alpha")
    alphaIn:SetDuration(animDuration * 0.2)
    alphaIn:SetFromAlpha(0)
    alphaIn:SetToAlpha(1)
    self.alphaIn = alphaIn

    local alphaOut = scrollAnim:CreateAnimation("Alpha")
    alphaOut:SetDuration(animDuration * 0.2)
    alphaOut:SetStartDelay(animDuration * 0.8)
    alphaOut:SetFromAlpha(1)
    alphaOut:SetToAlpha(0)
    self.alphaOut = alphaOut

    local translate = scrollAnim:CreateAnimation("Translation")
    translate:SetDuration(animDuration)
    translate:SetScript("OnPlay", function(trans)
        translate:SetOffset(0, translate.offset)
    end)
    self.translate = translate
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
        self.icon:SetPoint("LEFT", self.text, "RIGHT")
    else
        self.icon:SetPoint("RIGHT", self.text, "LEFT")
    end
end
function ScrollLineMixin:DisplayText(text, icon)
    self.text:SetText(text)
    self.icon:SetTexture(icon)
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
    ScrollLineMixin.OnLoad(self)

    local font = CombatText.db.global.fontSticky
    self.text:SetFont(font.path, font.size, font.flags)

    local scale = self.scrollAnim:CreateAnimation("Scale")
    scale:SetDuration(animDuration * 0.2)
    scale:SetFromScale(3, 3)
    scale:SetToScale(1, 1)
    self.scale = scale

    local translate = self.translate
    translate:SetDuration(animDuration * 0.8)
    translate:SetStartDelay(animDuration * 0.4)
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

function private.GetScrollLine(scrollType, isSticky)
    if scrollType == "notification" or isSticky then
        return stickyLines:Acquire()
    end

    return normalLines:Acquire()
end
