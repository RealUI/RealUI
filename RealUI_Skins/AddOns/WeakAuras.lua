local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Skin = Aurora.Skin

--do --[[ AddOns\WeakAuras.lua ]]
--end

--do --[[ AddOns\WeakAuras.xml ]]
--end

function private.AddOns.WeakAuras()
    local WeakAurasTooltipAnchor = _G.WeakAurasTooltipAnchor
    local _, import, showCode = WeakAurasTooltipAnchor:GetChildren()

    Skin.UIPanelButtonTemplate(import)
    Skin.UIPanelButtonTemplate(showCode)
end
