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
    alphaIn:SetOrder(1)
    alphaIn:SetFromAlpha(0)
    alphaIn:SetToAlpha(1)
    scrollLine.alphaIn = alphaIn

    local translate = scrollAnim:CreateAnimation("Translation")
    translate:SetOrder(2)
    translate:SetScript("OnPlay", function(trans)
        trans:SetOffset(0, trans.offset)
    end)
    scrollLine.translate = translate

    local alphaOut = scrollAnim:CreateAnimation("Alpha")
    alphaOut:SetOrder(3)
    alphaOut:SetFromAlpha(1)
    alphaOut:SetToAlpha(0)
    scrollLine.alphaOut = alphaOut

    scrollLine:OnLoad()
    return scrollLine
end
local function ScrollLineReset(scrollLinePool, scrollLine)
    scrollLine:Clear()
end


local ScrollLineMixin = {}
function ScrollLineMixin:OnLoad()
    self.type = "normal"
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
end
function ScrollLineMixin:AddToScrollArea(scrollArea, scrollDirection)
    self.scrollArea = scrollArea

    local prevLine = scrollArea.prevLine
    if prevLine and prevLine.type == self.type then
        if not prevLine.translate:IsPlaying() then
            prevLine.translate:Play()
        end
    end

    self.translate.offset = scrollArea:GetHeight()
    if scrollDirection == "up" then
        self:SetPoint("BOTTOM", scrollArea)
    elseif scrollDirection == "down" then
        self:SetPoint("TOP", scrollArea)
        self.translate.offset = -self.translate.offset
    end

    local scrollSettings = CombatText.db.global[scrollArea.scrollType]
    self.text:SetPoint(scrollSettings.justify)
    if scrollSettings.justify == "RIGHT" then
        self.icon:SetPoint("LEFT", self.text, "RIGHT", 2, 0)
    else
        self.icon:SetPoint("RIGHT", self.text, "LEFT", -2, 0)
    end

    scrollArea.prevLine = self
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
    self.type = "sticky"

    local scale = self.scrollAnim:CreateAnimation("Scale")
    scale:SetOrder(1)
    scale:SetScaleFrom(3, 3)
    scale:SetScaleTo(1, 1)
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
end
function StickyLineMixin:AddToScrollArea(scrollArea, scrollDirection)
    ScrollLineMixin.AddToScrollArea(self, scrollArea, scrollDirection)

    self:ClearAllPoints()
    self:SetPoint("CENTER", scrollArea)
    if scrollDirection then
        self.translate.offset = self.translate.offset / 2
    end
end

local normalLines = _G.CreateObjectPool(ScrollLineFactory, ScrollLineReset)
normalLines.mixin = ScrollLineMixin

local stickyLines = _G.CreateObjectPool(ScrollLineFactory, ScrollLineReset)
stickyLines.mixin = StickyLineMixin

function CombatText:UpdateLineOptions()
    -- FIXLATER
    for _, line in normalLines:EnumerateActive() do
        line:SetOptions()
    end
    for _, line in stickyLines:EnumerateActive() do
        line:SetOptions()
    end
end
function private.GetScrollLine(scrollType, isSticky)
    if scrollType == "notification" or isSticky then
        return stickyLines:Acquire()
    end

    return normalLines:Acquire()
end
