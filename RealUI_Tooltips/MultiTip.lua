local _, private = ...

-- Lua Globals --
-- luacheck: globals select tonumber ipairs

local Aurora = _G.Aurora
local Hook, Skin = Aurora.Hook, Aurora.Skin

local types = {
    item = true,
    spell = true,
    quest = true,
    talent = true,
    enchant = true,
    achievement = true,
    instancelock = true,
}

function Skin.RealUIMultiTipTemplate(GameTooltip)
    Skin.GameTooltipTemplate(GameTooltip)
    Skin.UIPanelCloseButton(GameTooltip.Close)
end

local function TooltipFactory(framePool)
    local numActive = framePool:GetNumActive()
    return _G.CreateFrame("GameTooltip", "MultiTip"..numActive, _G.UIParent, framePool.frameTemplate)
end
local function TooltipReset(framePool, tooltip)
    tooltip:Hide()
end

local shownLinks = {}
function private.SetupMultiTip()
    local tooltipPool = _G.CreateObjectPool(TooltipFactory, TooltipReset)
    tooltipPool.frameTemplate = "RealUIMultiTipTemplate"
    _G.hooksecurefunc(tooltipPool, "Acquire", Hook.ObjectPoolMixin_Acquire)

    local oldSetItemRef = _G.SetItemRef
    function _G.SetItemRef(link, text, button, ...)
        local linkType = link:match('(.-):(.*)')

        if types[linkType] and not _G.IsModifiedClick() then
            local tooltip = tooltipPool:Acquire()

            if shownLinks[link] then
                tooltipPool:Release(shownLinks[link])
                shownLinks[link] = nil
            else
                tooltip:Show()
                if not tooltip:IsShown() then
                    tooltip:SetOwner(_G.UIParent, "ANCHOR_PRESERVE")
                end
                tooltip:SetHyperlink(link)
                shownLinks[link] = tooltip
            end
        else
            return oldSetItemRef(link, text, button, ...)
        end
    end
end
