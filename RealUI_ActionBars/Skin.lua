local _, private = ...
local AB = private.AB

--[[ Button skinning (spec req 6): the RealUI look (cropped icon, 1px black
     border, no Blizzard chrome) applied DIRECTLY — no Masque requirement.
     When the user runs their own Masque, its groups win and we stand aside
     (the "RealUI" Masque skin ships in RealUI_Skins as always). ]]--

local function AnchorToRect(region, anchor)
    region:ClearAllPoints()
    region:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, 0)
    region:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
end

local function CreateBorder(button, anchor)
    local border = {}
    for i = 1, 4 do
        border[i] = button:CreateTexture(nil, "BACKGROUND", nil, -8)
        border[i]:SetColorTexture(0, 0, 0, 1)
    end
    border[1]:SetPoint("TOPLEFT", anchor, "TOPLEFT", -1, 1)
    border[1]:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 1, 0)
    border[2]:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -1, 0)
    border[2]:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 1, -1)
    border[3]:SetPoint("TOPLEFT", anchor, "TOPLEFT", -1, 0)
    border[3]:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", 0, 0)
    border[4]:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 0, 0)
    border[4]:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 1, 0)
    return border
end

-- Negative bar padding makes 36px buttons overlap (the shipped RealUI/BT4
-- geometry: -9 padding -> seamless 27px visual cells). The Masque skin
-- achieved that by insetting the visuals inside each button; the direct skin
-- must do the same or icons bleed into their neighbors and the hover
-- highlight reads oversized. The inset frame is the visual cell; icon,
-- border, cooldown, and all state textures anchor to it.
function private.ApplyButtonInset(button, inset)
    local cell = button._ruiCell
    if not cell then return end
    cell:ClearAllPoints()
    cell:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
    cell:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
end

local function SkinButton(button)
    if button._ruiSkinned then return end
    button._ruiSkinned = true

    -- Visual cell: everything the eye sees anchors here, inset from the
    -- (overlapping) button hit rect by ApplyButtonInset.
    local cell = _G.CreateFrame("Frame", nil, button)
    cell:SetAllPoints(button)
    button._ruiCell = cell

    if button.icon then
        button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        AnchorToRect(button.icon, cell)
    end
    if button.cooldown then
        AnchorToRect(button.cooldown, cell)
    end
    local normal = button:GetNormalTexture()
    if normal then
        normal:SetAlpha(0)
    end
    local highlight = button.GetHighlightTexture and button:GetHighlightTexture()
    if highlight then
        AnchorToRect(highlight, cell)
    end
    local pushed = button.GetPushedTexture and button:GetPushedTexture()
    if pushed then
        AnchorToRect(pushed, cell)
    end
    local checked = button.GetCheckedTexture and button:GetCheckedTexture()
    if checked then
        AnchorToRect(checked, cell)
    end
    if button.Flash then
        AnchorToRect(button.Flash, cell)
    end
    if button.Border then
        button.Border:SetAlpha(0)
    end
    -- HotKey/Count/Name are LAB-managed text elements: their font and inset
    -- position come from the config's text section (BuildButtonConfig) —
    -- anchoring them here would be stomped by every UpdateConfig.
    CreateBorder(button, cell)
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
