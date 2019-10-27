local _, private = ...

-- Lua Globals --
-- luacheck: globals select tonumber ipairs

local Aurora = _G.Aurora
local Skin = Aurora.Skin

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

local shownLinks, tooltipPool = {}
local function Release(self)
    shownLinks[self._link] = nil
    tooltipPool:Release(self)
end
local function TooltipFactory(framePool)
    local numActive = framePool:GetNumActive()
    local tooltip = _G.CreateFrame("GameTooltip", "MultiTip"..numActive, _G.UIParent, framePool.frameTemplate)
    private.HookTooltip(tooltip)
    tooltip.Release = Release
    return tooltip
end
local function TooltipReset(framePool, tooltip)
    tooltip:Hide()
    tooltip._link = nil
end

function private.SetupMultiTip()
    tooltipPool = _G.CreateObjectPool(TooltipFactory, TooltipReset)
    tooltipPool.frameTemplate = "RealUIMultiTipTemplate"

    local oldSetItemRef = _G.SetItemRef
    function _G.SetItemRef(link, text, button, ...)
        local linkType = link:match('(.-):(.*)')

        if types[linkType] and not _G.IsModifiedClick() then
            if shownLinks[link] then
                shownLinks[link]:Release()
            else
                local tooltip = tooltipPool:Acquire()

                tooltip:Show()
                tooltip._link = link
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
