local _, private = ...

local animDuration = 1
local function FontFactory(pool)
    local fontString = pool.parent:CreateFontString(nil, pool.layer, pool.fontStringTemplate, pool.subLayer)
    fontString:SetSize(100, 10)
    fontString:SetJustifyH("CENTER")

    local scrollAnim = fontString:CreateAnimationGroup()
    fontString.scrollAnim = scrollAnim

    local scale, translate
    if pool.isSticky then
        scale = scrollAnim:CreateAnimation("Scale")
        scale:SetDuration(animDuration * 0.2)
        scale:SetFromScale(4, 4)
        scale:SetToScale(1, 1)
    else
        translate = scrollAnim:CreateAnimation("Translation")
        translate:SetDuration(animDuration)
        translate:SetScript("OnPlay", function(self)
            translate:SetOffset(0, fontString.scrollArea:GetHeight())
        end)
    end

    local alphaIn = scrollAnim:CreateAnimation("Alpha")
    alphaIn:SetDuration(animDuration * 0.2)
    alphaIn:SetFromAlpha(0)
    alphaIn:SetToAlpha(1)

    local alphaOut = scrollAnim:CreateAnimation("Alpha")
    alphaOut:SetDuration(animDuration * 0.2)
    alphaOut:SetStartDelay(animDuration * 0.8)
    alphaOut:SetFromAlpha(1)
    alphaOut:SetToAlpha(0)

    scrollAnim:SetScript("OnFinished", function(self, requested)
        pool:Release(fontString)
    end)

    return fontString
end
local function FontReset(pool, fontString)
    fontString:ClearAllPoints()
    fontString:Hide()
end

local function CreateFontStringPool(parent, layer, subLayer, fontStringTemplate, isSticky)
    local pool = _G.CreateObjectPool(FontFactory, FontReset)
    pool.parent = parent
    pool.layer = layer
    pool.subLayer = subLayer
    pool.fontStringTemplate = fontStringTemplate
    pool.isSticky = isSticky

    return pool
end

local frame = _G.CreateFrame("Frame", nil, _G.UIParent)
local scrollLines = {}
scrollLines.normal = CreateFontStringPool(frame, "BACKGROUND", 0, "GameFontHighlight")
scrollLines.sticky = CreateFontStringPool(frame, "BACKGROUND", 0, "GameFontHighlight", true)

private.scrollLines = scrollLines
