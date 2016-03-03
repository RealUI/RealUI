local _, mods = ...
local _G = _G

mods["PLAYER_LOGIN"]["Clique"] = function(self, F, C)
    --print("HELLO Clique!!!", F, C)
    local tab = _G.CliqueSpellTab
    F.ReskinTab(tab)

    tab:SetCheckedTexture(C.media.checked)
    local hl = tab:GetHighlightTexture()
    hl:SetPoint("TOPLEFT", 0, 0)
    hl:SetPoint("BOTTOMRIGHT", 0, 0)

    local bg = _G.CreateFrame("Frame", nil, tab)
    bg:SetPoint("TOPLEFT", -1, 1)
    bg:SetPoint("BOTTOMRIGHT", 1, -1)
    bg:SetFrameLevel(tab:GetFrameLevel()-1)
    F.CreateBD(bg)

    select(6, tab:GetRegions()):SetTexCoord(.08, .92, .08, .92)
end
