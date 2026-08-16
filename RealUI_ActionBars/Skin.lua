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
-- so hit rect == visual box.
--
-- This previously claimed LAB's resets "stay correct by construction". They do
-- not: LAB hard-codes the state-texture geometry (see ApplyStateTextures), so
-- those two textures must be re-applied after every button update.
-- Aurora is an optional dependency. Use its palette when present so the
-- highlight follows the user's class-colour setting, otherwise fall back to
-- Aurora's own default (HIGHLIGHT_LIGHT_BLUE).
local function GetHighlightColor()
    local Aurora = _G.Aurora
    local color = Aurora and Aurora.Color and Aurora.Color.highlight
    if color and color.GetRGB then
        return color:GetRGB()
    end
    return 0.243, 0.570, 1
end

-- LAB re-sizes and re-anchors HighlightTexture/CheckedTexture to hardcoded
-- 52x51 at (-2.5, 2.5) every time a button's texture changes (its Update, in
-- the `hideElements.border` branch). A one-shot SetAllPoints in SkinButton is
-- therefore undone on the next update, leaving an oversized rounded glow
-- overhanging a 27px button. Re-apply on every OnButtonUpdate instead.
local function ApplyStateTextures(button)
    local r, g, b = GetHighlightColor()

    local highlight = button:GetHighlightTexture()
    if highlight then
        highlight:ClearAllPoints()
        highlight:SetAllPoints(button)
        highlight:SetColorTexture(r, g, b, 0.3)
    end

    local pushed = button:GetPushedTexture()
    if pushed then
        pushed:ClearAllPoints()
        pushed:SetAllPoints(button)
        pushed:SetColorTexture(1, 1, 1, 0.15)
    end

    local checked = button:GetCheckedTexture()
    if checked then
        checked:ClearAllPoints()
        checked:SetAllPoints(button)
        checked:SetColorTexture(r, g, b, 0.45)
    end
end

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

    -- Hiding the Normal texture above removes Blizzard's slot art, which is
    -- what filled an empty button. Without a replacement the slot is fully
    -- transparent and the bar reads as "backdrop doesn't fill the bar".
    -- Sits below the icon (BACKGROUND 0) and above the border (-8).
    local backdrop = button:CreateTexture(nil, "BACKGROUND", nil, -7)
    backdrop:SetAllPoints(button)
    backdrop:SetColorTexture(0, 0, 0, 0.5)
    button._ruiBackdrop = backdrop
    ApplyStateTextures(button)
    if button.SpellHighlightTexture then
        button.SpellHighlightTexture:ClearAllPoints()
        button.SpellHighlightTexture:SetAllPoints(button)
    end
    -- HotKey/Count/Name are LAB-managed text elements: their font and
    -- position come from the config's text section (BuildButtonConfig).
    CreateBorder(button)
end
private.SkinButton = SkinButton

-- Registered once. LAB fires OnButtonUpdate at the end of its Update, after
-- the state-texture resize, so this is where our sizing has to be re-applied.
-- Masque-skinned buttons are left alone: their group owns the look.
local hookedButtonUpdate = false
local function HookButtonUpdate()
    if hookedButtonUpdate then return end
    hookedButtonUpdate = true

    local LAB = _G.LibStub("LibActionButton-1.0", true)
    if not LAB or not LAB.RegisterCallback then return end

    LAB.RegisterCallback(private, "OnButtonUpdate", function(_, button)
        if button and button._ruiSkinned and not button.MasqueSkinned then
            ApplyStateTextures(button)
        end
    end)
end

function private.SetupSkins()
    local Masque = _G.LibStub("Masque", true)
    private.usingMasque = Masque and true or false

    HookButtonUpdate()

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
