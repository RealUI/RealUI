local _, private = ...
local AB = private.AB

--[[ Button skinning (spec req 6): the RealUI look (cropped icon, 1px black
     border, no Blizzard chrome) applied DIRECTLY — no Masque requirement.
     When the user runs their own Masque, its groups win and we stand aside
     (the "RealUI" Masque skin ships in RealUI_Skins as always). ]]--

-- Border width is part of the layout box model: Bar.lua counts
-- private.BUTTON_BORDER on every side when spacing buttons (B28).
local function CreateBorder(button)
    local w = private.BUTTON_BORDER or 1
    local border = {}
    for i = 1, 4 do
        border[i] = button:CreateTexture(nil, "BACKGROUND", nil, -8)
        border[i]:SetColorTexture(0, 0, 0, 1)
    end
    border[1]:SetPoint("TOPLEFT", button, "TOPLEFT", -w, w)
    border[1]:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", w, 0)
    border[2]:SetPoint("TOPLEFT", button, "BOTTOMLEFT", -w, 0)
    border[2]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", w, -w)
    border[3]:SetPoint("TOPLEFT", button, "TOPLEFT", -w, 0)
    border[3]:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", 0, 0)
    border[4]:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
    border[4]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", w, 0)
    return border
end

-- Buttons are sized to their icon (no overlap trick), with the 1px border
-- drawn outside the frame and counted by the layout box model (B28:
-- db.padding == the visible gap between borders), so hit rect == icon box.
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

-- Blizzard's assisted-combat rotation/highlight templates carry fixed-size
-- artwork authored for 45px action buttons (a 128px gold ring frame, a 66px
-- ants flipbook) anchored CENTER with no relation to the parent's size. LAB
-- spawns them as-is, so on a 27px button the spinner dwarfs the button
-- (B18). Scale the whole overlay by buttonSize/45 — proportionally identical
-- to the default UI — and re-center it (the template's CENTER (-2, 1) offset
-- matches Blizzard's off-center slot art, not our full-bleed square).
local ASSIST_ART_BUTTON_SIZE = 45
local function ConstrainAssistOverlay(button, overlay)
    if not overlay then return end
    local size = button:GetWidth()
    if not size or size <= 0 then return end
    local scale = size / ASSIST_ART_BUTTON_SIZE
    if overlay._ruiAssistScale == scale then return end
    overlay._ruiAssistScale = scale
    overlay:SetScale(scale)
    overlay:ClearAllPoints()
    overlay:SetPoint("CENTER", button, "CENTER")
end

-- LAB re-sizes and re-anchors HighlightTexture/CheckedTexture to hardcoded
-- 52x51 at (-2.5, 2.5) every time a button's texture changes (its Update, in
-- the `hideElements.border` branch). A one-shot SetAllPoints in SkinButton is
-- therefore undone on the next update, leaving an oversized rounded glow
-- overhanging a 27px button. Re-apply on every OnButtonUpdate instead.
local function ApplyStateTextures(button)
    local r, g, b = GetHighlightColor()

    -- B64: the same class of one-shot loss. For a button that *holds* an
    -- action LAB calls SetNormalAtlas("UI-HUD-ActionBar-IconFrame-AddRow") on
    -- every Update, and that creates NormalTexture if the region did not
    -- exist yet — so SkinButton's single SetAlpha(0) is missed entirely on any
    -- button whose NormalTexture LAB created after we skinned it. Re-assert.
    local normal = button:GetNormalTexture()
    if normal then
        normal:SetAlpha(0)
    end

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

    -- B16: LAB re-anchors the cooldown swipe to Blizzard's 45px-button
    -- insets (TOPLEFT 3,-2 / BOTTOMRIGHT -3,3) on every Update — on a 27px
    -- button the swipe covers barely half the face. Full-face, every update
    -- (this runs after LAB's re-anchor, same as the state textures above).
    local cooldown = button.cooldown
    if cooldown then
        cooldown:ClearAllPoints()
        cooldown:SetAllPoints(button)
    end
    local charge = button.chargeCooldown
    if charge then
        charge:ClearAllPoints()
        charge:SetAllPoints(button)
    end

    -- The auto-attack / auto-repeat flash. Blizzard's template declares it
    -- `atlas="UI-HUD-ActionBar-IconFrame-Flash" useAtlasSize="true"` with a
    -- single TOPLEFT anchor, so it draws at the atlas's native (45px-button)
    -- size and overhangs a 27px button to the right and bottom — the oversized
    -- red box seen on the auto-attack button in combat. SetAllPoints overrides
    -- the atlas sizing; keep the atlas art itself.
    local flash = button.Flash
    if flash then
        flash:ClearAllPoints()
        flash:SetAllPoints(button)
    end

    -- B18: assisted-combat overlays (created lazily by LAB from Blizzard
    -- templates).
    ConstrainAssistOverlay(button, button.AssistedCombatRotationFrame)
    ConstrainAssistOverlay(button, button.AssistedCombatHighlightFrame)
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

    -- B16: LAB creates the charge cooldown lazily, anchored 2px inside the
    -- icon (45px-button geometry), and only re-skins it when Masque is
    -- present. Pre-create it full-face — LAB adopts an existing
    -- button.chargeCooldown — so the first charge sweep is already sized
    -- right instead of waiting for the next OnButtonUpdate.
    if not button.chargeCooldown then
        local charge = _G.CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        charge:SetHideCountdownNumbers(true)
        charge:SetDrawSwipe(false)
        charge:SetAllPoints(button)
        charge:SetFrameLevel(button:GetFrameLevel())
        button.chargeCooldown = charge
    end

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

--[[ Adopted Blizzard buttons — stance and pet.

     StancePetBar.lua adopts Blizzard's own StanceButton/PetActionButton frames
     instead of reimplementing the secure shapeshift/pet behavior, so those
     buttons never pass through the LAB path above: SetupSkins only walks bars
     1-6. Nothing else picked them up either — Aurora's StanceButtonTemplate
     skin is gated behind `private.isClassic and not private.disabled.mainmenubar`
     and RealUI_Skins sets that disable flag — so once Bartender4 (which used to
     own these bars) was out of the picture, the stance and pet bars kept full
     Blizzard chrome, with or without Masque: no group ever registered them.

     Same look as SkinButton, reached differently. These are Blizzard's
     SmallActionButtons: their artwork is authored at fixed atlas sizes for a
     30px button and overhangs ours, and BaseActionButtonMixin:UpdateButtonArt
     re-asserts the normal/pushed art — so the reset re-applies on a per-button
     hook of that method as well as on every re-adopt. Only the buttons' own
     regions are touched: no reparenting, no secure attributes (B51/B55). ]]--

-- Blizzard's small-button overlay FRAMES (the pet autocast ring) carry a fixed
-- size that can only be corrected by scaling — same trick as the assist art.
local SMALL_ART_BUTTON_SIZE = 30

-- Chrome with no equivalent in the RealUI look. SetAlpha, not Hide:
-- UpdateButtonArt Show()s SlotArt/SlotBackground and would undo a Hide.
local ADOPTED_CHROME = { "SlotArt", "SlotBackground", "Border", "NewActionTexture" }

-- Overlay textures Blizzard gives a fixed size (31.6x30.9, for a 30px button).
local ADOPTED_FULL_FACE = { "SpellHighlightTexture", "QuickKeybindHighlightTexture" }

local function ApplyAdoptedTextures(button)
    -- Everything the LAB buttons need is needed here too: normal art hidden,
    -- state textures full-face, cooldown swipe full-face.
    ApplyStateTextures(button)

    if button.icon then
        button.icon:SetAllPoints(button)
        button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        -- The rounded-corner mask is what makes a button read as Blizzard's.
        -- LAB drops it on our own bars (hideElements.border), so drop it here
        -- too, or the adopted icons keep soft corners inside a square border.
        if button.IconMask and button.icon.RemoveMaskTexture then
            button.icon:RemoveMaskTexture(button.IconMask)
        end
    end

    for _, key in _G.next, ADOPTED_CHROME do
        local region = button[key]
        if region then
            region:SetAlpha(0)
        end
    end

    for _, key in _G.next, ADOPTED_FULL_FACE do
        local region = button[key]
        if region then
            region:ClearAllPoints()
            region:SetAllPoints(button)
        end
    end

    -- Pet autocast ring: a frame sized 31x31 at CENTER (0.5, -0.5) by
    -- SmallActionButtonMixin, which overhangs a 26px pet button.
    local autoCast = button.AutoCastOverlay
    if autoCast then
        local size = button:GetWidth()
        if size and size > 0 then
            local scale = size / SMALL_ART_BUTTON_SIZE
            if autoCast._ruiAutoCastScale ~= scale then
                autoCast._ruiAutoCastScale = scale
                autoCast:SetScale(scale)
            end
        end
    end
end

local masqueGroups = {}
local function GetMasqueGroup(kind)
    local Masque = _G.LibStub("Masque", true)
    if not Masque then return end
    if masqueGroups[kind] == nil then
        masqueGroups[kind] = Masque:Group("RealUI ActionBars", kind .. " Bar") or false
    end
    return masqueGroups[kind] or nil
end

--- Skin one adopted Blizzard button. Idempotent: the one-shot pieces are
--- guarded, the resets re-run on every call (button size can have changed).
-- `kind` is both the Masque button type and the group label: "Stance" or "Pet".
function private.SkinAdoptedButton(button, kind)
    if button._ruiMasqued then return end

    if not button._ruiAdoptSkinned then
        local group = GetMasqueGroup(kind)
        if group then
            -- The user's Masque skin wins, exactly as it does on the LAB bars.
            button._ruiMasqued = true
            group:AddButton(button, nil, kind)
            return
        end

        button._ruiAdoptSkinned = true

        -- Hiding the Normal texture removes what filled an empty slot; same
        -- replacement backdrop the LAB buttons get.
        local backdrop = button:CreateTexture(nil, "BACKGROUND", nil, -7)
        backdrop:SetAllPoints(button)
        backdrop:SetColorTexture(0, 0, 0, 0.5)
        button._ruiBackdrop = backdrop

        CreateBorder(button)

        -- B20 (one button style): Blizzard's stock hotkey/count faces sitting
        -- next to the LAB bars' condensed numbers read as two different UIs.
        -- Same faces and sizes as BuildButtonConfig's text section.
        local numberFont = private.GetSkinFont and private.GetSkinFont("chat", [[Fonts\ARIALN.TTF]])
        if numberFont then
            if button.HotKey then button.HotKey:SetFont(numberFont, 11, "OUTLINE") end
            if button.Count then button.Count:SetFont(numberFont, 12, "OUTLINE") end
        end

        if _G.type(button.UpdateButtonArt) == "function" then
            _G.hooksecurefunc(button, "UpdateButtonArt", ApplyAdoptedTextures)
        end
    end

    ApplyAdoptedTextures(button)
end

--- Re-scale a Masque-owned stance/pet bar after its buttons were resized.
-- Masque sizes its skin art from the button at skin time, so a buttonSize
-- change would otherwise keep the old art scale until the next reload. No-op
-- without Masque (our own skin re-derives size on every SkinAdoptedButton).
function private.ReSkinAdoptedBar(kind)
    local group = GetMasqueGroup(kind)
    if group and group.ReSkin then
        group:ReSkin(true)
    end
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
