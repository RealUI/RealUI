local _, ns = ...

-- [[ Lua Globals ]]
-- luacheck: globals ipairs

if ns.cfg.multiTip == false then return end

local tips = {_G.ItemRefTooltip}

local types = {
    item = true,
    spell = true,
    quest = true,
    talent = true,
    enchant = true,
    achievement = true,
    instancelock = true,
}

local function CreateTip(link)
    -- Use existing tip
    for k, v in ipairs(tips) do
        -- Hide if tip is already shown
        for i, tip in ipairs(tips) do
            if tip:IsShown() and tip.link == link then
                tip.link = nil
                _G.HideUIPanel(tip)
                return
            end
        end

        if not v:IsShown() then
            v.link = link
            return v
        end
    end

    -- Create new tip
    local num = #tips + 1
    local tip = _G.CreateFrame("GameTooltip", "ItemRefTooltip"..num, _G.UIParent, "FreebTip_Multi_Template")
    tip:SetScript("OnShow", function(self) ns.style(self) end)
    _G.Aurora.Skin.GameTooltipTemplate(tip)
    _G.Aurora.Skin.UIPanelCloseButton(tip.CloseButton)
    tip.CloseButton:SetPoint("TOPRIGHT", -3, -3)

    _G.tinsert(_G.UISpecialFrames, tip:GetName())

    tip.link = link
    tips[num] = tip

    return tip
end

function ns:ShowTip(tip, link)
    _G.ShowUIPanel(tip)
    if not tip:IsShown() then
        tip:SetOwner(_G.UIParent, "ANCHOR_PRESERVE")
    end

    tip:SetHyperlink(link)
end

local _SetItemRef = _G.SetItemRef
function _G.SetItemRef(link, text, button, ...)
    --print("link - "..link.. " - text "..text.." - button "..button)

    local handled = _G.strsplit(":", link)
    --print(handled)

    if not _G.IsModifiedClick() and (handled and types[handled]) then
        local tip = CreateTip(link)

        if tip then
            ns:ShowTip(tip, link)
        end
    else
        return _SetItemRef(link, text, button, ...)
    end
end
