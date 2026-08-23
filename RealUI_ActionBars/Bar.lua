local _, private = ...
local AB = private.AB

local LAB = _G.LibStub("LibActionButton-1.0")

--[[ Bar object: a SecureHandlerStateTemplate frame owning 12 LAB action
     buttons. Layout math (rows/padding/grow, negative padding legal) and the
     hookable Layout() live here; per-button behavior is all LAB's. ]]--

-- The skin draws a 1px black border OUTSIDE each button frame (Skin.lua
-- CreateBorder), so a button's on-screen cell is buttonSize + 2. All layout
-- math counts it: db.padding is the ACTUAL visible gap between neighbouring
-- buttons' border art (B28 box model), not the frame-to-frame distance.
private.BUTTON_BORDER = 1

-- Task 7.1 (final piece): RealUI fonts on the LAB-managed button text.
-- LAB only takes a font through the config's text section
-- (UpdateTextElement: `config.font.font or defaultFont`), so it belongs here
-- rather than in Skin.lua — the skin can't reach these without fighting
-- LAB's every-update reset.
--
-- Font source mirrors Modules/CooldownCount.lua: RealUI_Skins owns the media
-- and is a SEPARATE addon, so read its saved variables defensively and fall
-- back to the stock font. `chat` is the condensed number face (Aurora maps
-- every NumberFont to it); `normal` is the text face used for macro names.
local function GetSkinFont(fontType, fallback)
    if _G.C_AddOns.IsAddOnLoaded("RealUI_Skins") then
        local skinsDB = _G.RealUI_SkinsDB
        local fonts = skinsDB and skinsDB.profile and skinsDB.profile.fonts
        local font = fonts and fonts[fontType]
        if font and font.path then
            return font.path
        end
    end
    return fallback
end
-- Skin.lua needs the same faces for the adopted stance/pet buttons, which get
-- their text from Blizzard rather than from a LAB config.
private.GetSkinFont = GetSkinFont

local function BuildButtonConfig(barDB, keyBoundTarget)
    local numberFont = GetSkinFont("chat", [[Fonts\ARIALN.TTF]])
    local nameFont = GetSkinFont("normal", [[Fonts\FRIZQT__.TTF]])
    return {
        outOfRangeColoring = "button",
        tooltip = "enabled",
        showGrid = barDB.showgrid,
        flyoutDirection = barDB.flyoutDirection or "UP",
        hideElements = {
            macro = barDB.hidemacrotext,
            hotkey = false,
            -- B64 (real cause): LAB draws a green border on any button holding
            -- an EQUIPPED item — `Border:SetVertexColor(0, 1.0, 0, 0.35)` at
            -- LibActionButton-1.0.lua:1817. That is the green box: it only
            -- appears on equipped gear, which is why it came and went between
            -- sessions and sat alone at the end of a bar. Skin.lua already
            -- alpha-0'd Border, but only once at skin time; LAB re-Shows it on
            -- every Update. Setting this takes LAB's `else` branch instead,
            -- which calls Border:Hide() — durable, and matches the intent the
            -- one-shot SetAlpha(0) already expressed.
            equipped = true,
            -- B64: left unset, LAB paints every *empty* slot with Blizzard's
            -- "UI-HUD-ActionBar-IconFrame-AddRow" atlas — the green box
            -- reported at the end of a bar (/fstack named it exactly:
            -- RealUI_AB_Bar6B11NormalTexture, that atlas). Setting this makes
            -- LAB clear the texture instead, on every Update rather than once.
            borderIfEmpty = true,
        },
        keyBoundTarget = keyBoundTarget,
        colors = {
            range = { 0.8, 0.1, 0.1 },
            mana = { 0.5, 0.5, 1 },
        },
        text = {
            hotkey = {
                font = { font = numberFont, size = 11, flags = "OUTLINE" },
                position = {
                    anchor = "TOPRIGHT", relAnchor = "TOPRIGHT",
                    offsetX = -1, offsetY = -1,
                },
            },
            count = {
                font = { font = numberFont, size = 12, flags = "OUTLINE" },
                position = {
                    anchor = "BOTTOMRIGHT", relAnchor = "BOTTOMRIGHT",
                    offsetX = -1, offsetY = 1,
                },
            },
            -- Macro names sit on the button face, so they get the text face at
            -- a small size; LAB's default position (BOTTOM, +2) is kept.
            macro = {
                font = { font = nameFont, size = 10, flags = "OUTLINE" },
                position = {
                    anchor = "BOTTOM", relAnchor = "BOTTOM",
                    offsetX = 0, offsetY = 1,
                },
            },
        },
    }
end

local barMixin = {}

function barMixin:GetDB()
    return AB.dbActionBars.profile.actionbars[self.id]
end

-- Grid layout from the bar's config. Insecure sizing/anchoring on our own
-- frame + LAB buttons: legal out of combat; callers queue via QueueSecure.
function barMixin:Layout()
    local db = self:GetDB()
    local shown = db.buttons or 12
    local rows = _G.math.max(1, _G.math.min(db.rows or 1, shown))
    local perRow = _G.math.ceil(shown / rows)
    local size, pad = db.buttonSize or 26, db.padding or 2
    -- Border-aware spacing (B28): neighbouring buttons put both of their
    -- 1px outside borders between the frames before any padding, so the
    -- frame-to-frame gap is padding + 2*border. padding 0 = borders
    -- touching; padding 2 = a true 2px visible gap.
    local gap = pad + private.BUTTON_BORDER * 2

    local dirH = (db.growHorizontal == "LEFT") and -1 or 1
    local dirV = (db.growVertical == "UP") and 1 or -1
    local corner = ((dirV == -1) and "TOP" or "BOTTOM") .. ((dirH == 1) and "LEFT" or "RIGHT")

    self:SetSize(perRow * (size + gap) - gap, rows * (size + gap) - gap)

    for i = 1, 12 do
        local button = self.buttons[i]
        button:ClearAllPoints()
        if i > shown then
            button:Hide()
        else
            local col = (i - 1) % perRow
            local row = _G.math.floor((i - 1) / perRow)
            button:SetSize(size, size)
            button:SetPoint(corner, self, corner,
                col * (size + gap) * dirH,
                row * (size + gap) * dirV)
            button:Show()
        end
    end
end

function barMixin:ApplyConfig()
    local db = self:GetDB()

    self._ruiConfig = db
    self._ruiAlpha = db.alpha or 1
    self:SetAlpha(db.alpha or 1)

    -- Scale BEFORE anchoring: SetPoint offsets live in the frame's scaled
    -- space, so setting scale afterwards would shift the bar.
    self:SetScale(db.scale or 1)
    -- BT4-semantics anchoring (what the RealUI geometry was written for): the
    -- bar's GROW-ORIGIN CORNER anchors to the named UIParent point at (x, y) —
    -- not the frame's own matching point.
    local cornerV = (db.growVertical == "UP") and "BOTTOM" or "TOP"
    local cornerH = (db.growHorizontal == "LEFT") and "RIGHT" or "LEFT"
    self:ClearAllPoints()
    self:SetPoint(cornerV .. cornerH, _G.UIParent, db.position.point,
        db.position.x, db.position.y)

    for i = 1, 12 do
        local button = self.buttons[i]
        button.config = BuildButtonConfig(db, button.config and button.config.keyBoundTarget)
        button:UpdateConfig(button.config)
    end

    self:Layout()
    private.ApplyVisibility(self, db.enabled and db.visibility or nil)
    if not db.enabled then
        _G.UnregisterStateDriver(self, "vis")
        self:Hide()
    end
end

-- LAB abbreviates hotkey text only through LibKeyBound, which failed our
-- license gate and is not shipped — without it LAB renders the RAW binding
-- string ("SHIFT-2"), which clips on 27px buttons (part of B05: side bars
-- showed "SHIF…" while bar 1's plain "1".."=" keys looked fine). Replace
-- per-button: same Blizzard-abbreviated text (GetBindingText's abbreviated
-- form, exactly what Blizzard's own UpdateHotkeys uses) on EVERY bar, and
-- fold in our own /rab bind captures so they ride the same pipeline.
local function GetHotkeyText(self)
    local key
    local target = self.config and self.config.keyBoundTarget
    if target then
        key = _G.GetBindingKey(target)
    end
    if not key then
        key = _G.GetBindingKey(("CLICK %s:LeftButton"):format(self:GetName()))
    end
    if not key then
        local bindings = AB.db and AB.db.profile and AB.db.profile.bindings
        key = bindings and bindings[self:GetName()]
    end
    if key and key ~= "" then
        local text = _G.GetBindingText(key, 1)
        if text and text ~= "" then
            return text
        end
    end
end

function private.CreateBar(id)
    local bar = _G.CreateFrame("Frame", "RealUI_AB_Bar" .. id, _G.UIParent,
        "SecureHandlerStateTemplate")
    _G.Mixin(bar, barMixin)
    bar.id = id
    bar.buttons = {}

    private.SetupVisibility(bar)

    -- Bars occupying Blizzard action pages mirror the matching Blizzard
    -- binding commands — pressed via override bindings (Bindings.lua) and
    -- displayed via LAB's keyBoundTarget. Bar 2 (page 2) has no Blizzard
    -- binding set; it uses custom captures only.
    local KEYBOUND_TARGETS = {
        [1] = "ACTIONBUTTON%d",
        [3] = "MULTIACTIONBAR3BUTTON%d",
        [4] = "MULTIACTIONBAR4BUTTON%d",
        [5] = "MULTIACTIONBAR2BUTTON%d",
        [6] = "MULTIACTIONBAR1BUTTON%d",
    }

    local db = AB.dbActionBars.profile.actionbars[id]
    for i = 1, 12 do
        local keyBoundTarget = KEYBOUND_TARGETS[id] and KEYBOUND_TARGETS[id]:format(i) or nil
        local button = LAB:CreateButton(i, bar:GetName() .. "B" .. i, bar,
            BuildButtonConfig(db, keyBoundTarget))
        -- Instance override beats LAB's Generic:GetHotkey (metatable) — this
        -- is the only hook point LAB offers for hotkey text; UpdateHotkeys
        -- always routes through self:GetHotkey().
        button.GetHotkey = GetHotkeyText

        if id == 1 then
            -- Paged: state N = action page N (the state driver in ActionBars.lua
            -- flips the header state; LAB routes it to the buttons).
            for page = 1, 18 do
                button:SetState(page, "action", (page - 1) * 12 + i)
            end
            button:SetState(0, "action", i)
        else
            button:SetState(0, "action", (id - 1) * 12 + i)
        end

        bar.buttons[i] = button
    end

    return bar
end
