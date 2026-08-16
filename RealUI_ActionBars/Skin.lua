local _, private = ...
local AB = private.AB

--[[ Button skinning (spec req 6): the RealUI look (cropped icon, 1px black
     border, no Blizzard chrome) applied DIRECTLY — no Masque requirement.
     When the user runs their own Masque, its groups win and we stand aside
     (the "RealUI" Masque skin ships in RealUI_Skins as always). ]]--

local function CreateBorder(button)
    local border = {}
    for i = 1, 4 do
        border[i] = button:CreateTexture(nil, "BACKGROUND", nil, -8)
        border[i]:SetColorTexture(0, 0, 0, 1)
    end
    border[1]:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
    border[1]:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 1, 0)
    border[2]:SetPoint("TOPLEFT", button, "BOTTOMLEFT", -1, 0)
    border[2]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    border[3]:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 0)
    border[3]:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", 0, 0)
    border[4]:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
    border[4]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 0)
    return border
end

-- Buttons are sized to their VISUAL cell (no overlap trick — 27px at 0
-- padding renders identically to BT4's 36px at -9, with shared 1px borders),
-- so hit rect == visual box and no texture re-anchoring is needed; whatever
-- LAB resets stays correct by construction.
local function SkinButton(button)
    if button._ruiSkinned then return end
    button._ruiSkinned = true

    if button.icon then
        button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    local normal = button:GetNormalTexture()
    if normal then
        normal:SetAlpha(0)
    end
    if button.Border then
        button.Border:SetAlpha(0)
    end
    -- Blizzard's template pins these state textures at their ATLAS size
    -- (46x45, CENTER) instead of to the button — on a 27px button the
    -- checked/hover art draws humongous. Pin them to the button rect.
    for _, getter in _G.next, { "GetHighlightTexture", "GetPushedTexture", "GetCheckedTexture" } do
        local texture = button[getter] and button[getter](button)
        if texture then
            texture:ClearAllPoints()
            texture:SetAllPoints(button)
        end
    end
    if button.SpellHighlightTexture then
        button.SpellHighlightTexture:ClearAllPoints()
        button.SpellHighlightTexture:SetAllPoints(button)
    end
    -- HotKey/Count/Name are LAB-managed text elements: their font and
    -- position come from the config's text section (BuildButtonConfig).
    CreateBorder(button)
end
private.SkinButton = SkinButton

function private.SetupSkins()
    local Masque = _G.LibStub("Masque", true)
    private.usingMasque = Masque and true or false

    for id = 1, 6 do
        local bar = AB.bars[id]
        if bar then
            local group = Masque and Masque:Group("RealUI ActionBars", "Bar " .. id)
            for i = 1, 12 do
                local button = bar.buttons[i]
                if group then
                    button:AddToMasque(group)  -- LAB's own Masque hookup
                else
                    SkinButton(button)
                end
            end
        end
    end
end
