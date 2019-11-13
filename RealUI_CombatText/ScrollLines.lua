local _, private = ...

local animDuration = 1
local ScrollLineMixin = {}
function ScrollLineMixin:OnLoad()
    self:SetJustifyH("CENTER")

    local scrollAnim = self:CreateAnimationGroup()
    self.scrollAnim = scrollAnim

    local alphaIn = scrollAnim:CreateAnimation("Alpha")
    alphaIn:SetDuration(animDuration * 0.2)
    alphaIn:SetFromAlpha(0)
    alphaIn:SetToAlpha(1)

    local alphaOut = scrollAnim:CreateAnimation("Alpha")
    alphaOut:SetDuration(animDuration * 0.2)
    alphaOut:SetStartDelay(animDuration * 0.8)
    alphaOut:SetFromAlpha(1)
    alphaOut:SetToAlpha(0)

    if self:GetParent().isSticky then
        local scale = scrollAnim:CreateAnimation("Scale")
        scale:SetDuration(animDuration * 0.2)
        scale:SetFromScale(4, 4)
        scale:SetToScale(1, 1)
    else
        local translate = scrollAnim:CreateAnimation("Translation")
        translate:SetDuration(animDuration)
        translate:SetScript("OnPlay", function(trans)
            translate:SetOffset(0, self.scrollArea:GetHeight())
        end)
    end

    scrollAnim:SetScript("OnFinished", function(anim, requested)
        self:GetParent():Release(self)
    end)
end
function ScrollLineMixin:AddToScrollArea(scrollArea)
    if self:GetParent().isSticky then
        self:SetPoint("CENTER", scrollArea)
    else
        self:SetPoint("BOTTOM", scrollArea)
    end

    self.scrollArea = scrollArea
end
function ScrollLineMixin:DisplayText(text)
    self:SetText(text)
    self:Show()
    self.scrollAnim:Play()
end
function ScrollLineMixin:Clear()
    self:ClearAllPoints()
    self:Hide()
end


local ScrollLinePoolMixin = _G.CreateFromMixins(_G.FontStringPoolMixin)
local function ScrollLinePoolFactory(scrollLinePool)
    local scrollLine = scrollLinePool:CreateFontString(nil, scrollLinePool.layer, scrollLinePool.fontStringTemplate, scrollLinePool.subLayer)
    _G.Mixin(scrollLine, ScrollLineMixin)
    scrollLine:OnLoad()

    return scrollLine
end
function ScrollLinePoolMixin:OnLoad(parent, layer, subLayer, fontStringTemplate, resetterFunc)
    _G.ObjectPoolMixin.OnLoad(self, ScrollLinePoolFactory, resetterFunc)
    self.parent = parent
    self.layer = layer
    self.subLayer = subLayer
    self.fontStringTemplate = fontStringTemplate
end
function ScrollLinePoolMixin:SetSticky(isSticky)
    self.isSticky = isSticky
end
function ScrollLinePoolMixin:GetLine(scrollArea)
    local scrollLine = self:Acquire()
    scrollLine.scrollArea = scrollArea

    if self.isSticky then
        scrollLine:SetPoint("CENTER", scrollArea)
    else
        scrollLine:SetPoint("BOTTOM", scrollArea)
    end
end


local function ScrollLinePool_Reset(scrollLinePool, scrollLine)
    scrollLine:Clear()
end
local function CreateScrollLinePool(parent, layer, subLayer, fontStringTemplate)
    local scrollLinePool = _G.Mixin(parent, ScrollLinePoolMixin)
    scrollLinePool:OnLoad(parent, layer, subLayer, fontStringTemplate, ScrollLinePool_Reset)

    return scrollLinePool
end

local scrollLines = {}
scrollLines.normal = CreateScrollLinePool(_G.CreateFrame("Frame", nil, _G.UIParent), "BACKGROUND", 0, "NumberFont_Outline_Med")
scrollLines.sticky = CreateScrollLinePool(_G.CreateFrame("Frame", nil, _G.UIParent), "BACKGROUND", 0, "NumberFont_Outline_Huge")
scrollLines.sticky:SetSticky(true)

private.scrollLines = scrollLines
