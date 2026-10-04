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

--[[ B151: page numbering. Which action page each bar shows is a per-profile
     choice (`AB.db.profile.pageLayout`):

       bartender — bar N shows page N. Bartender4's numbering, which RealUI
                   inherited with the layout; every 4.x profile and every BT4
                   import has its spells in these slots, so it stays default.
       blizzard  — bars 1-6 show the pages of Blizzard's Action Bars 1-6
                   (Blizzard_ActionBar/Shared/MultiActionBars.xml `actionpage`:
                   MultiBarBottomLeft 6, BottomRight 5, Right 3, Left 4,
                   MultiBar5 13).

     Bar 1 is page 1 plus the bonusbar pages under either layout; its paging
     driver (ActionBars.lua) does not change. Switching moves no spells — it
     changes which slots each bar shows. Bars 7/8 (pages 14/15) do not exist
     yet; PAGE_BINDINGS already covers them. ]]--
local PAGE_LAYOUTS = {
    bartender = { 1, 2, 3, 4, 5, 6 },
    blizzard  = { 1, 6, 5, 3, 4, 13 },
}
local DEFAULT_PAGE_LAYOUT = "bartender"

-- Blizzard binding command per action PAGE, not per bar: a bar mirrors the
-- command of whichever Blizzard bar shows the same page. In Bartender mode
-- this gives exactly the old per-bar table (1, 3-6 mirrored, bar 2 = page 2
-- capture-only), because bar and page coincide on bars 1 and 3-6.
local PAGE_BINDINGS = {
    [1]  = "ACTIONBUTTON%d",
    [6]  = "MULTIACTIONBAR1BUTTON%d",  -- MultiBarBottomLeft  (Blizzard bar 2)
    [5]  = "MULTIACTIONBAR2BUTTON%d",  -- MultiBarBottomRight (Blizzard bar 3)
    [3]  = "MULTIACTIONBAR3BUTTON%d",  -- MultiBarRight       (Blizzard bar 4)
    [4]  = "MULTIACTIONBAR4BUTTON%d",  -- MultiBarLeft        (Blizzard bar 5)
    [13] = "MULTIACTIONBAR5BUTTON%d",  -- MultiBar5           (Blizzard bar 6)
    [14] = "MULTIACTIONBAR6BUTTON%d",  -- MultiBar6           (Blizzard bar 7)
    [15] = "MULTIACTIONBAR7BUTTON%d",  -- MultiBar7           (Blizzard bar 8)
}

--- The active page layout name; anything unknown reads as the default.
function private.GetPageLayout()
    local layout = AB.db and AB.db.profile.pageLayout
    if PAGE_LAYOUTS[layout] then return layout end
    return DEFAULT_PAGE_LAYOUT
end

--- Action page shown by bar `id` (layout optional: defaults to the profile's).
function private.GetBarPage(id, layout)
    local pages = PAGE_LAYOUTS[layout or private.GetPageLayout()] or PAGE_LAYOUTS[DEFAULT_PAGE_LAYOUT]
    return pages[id] or id
end

--- Blizzard binding command format mirrored by bar `id`, or nil (capture-only).
function private.GetBindingFormat(id, layout)
    return PAGE_BINDINGS[private.GetBarPage(id, layout)]
end

local function GetKeyBoundTarget(id, i)
    local commandFormat = private.GetBindingFormat(id)
    return commandFormat and commandFormat:format(i) or nil
end

--- Switch the profile's page layout and re-apply slots + bindings. SetState
--- writes secure attributes, so the re-apply goes through QueueSecure: live
--- out of combat, deferred to PLAYER_REGEN_ENABLED in it. `noApply` = DB write
--- only (called before the bars exist).
function private.SetPageLayout(layout, noApply)
    if not PAGE_LAYOUTS[layout] then return false end
    AB.db.profile.pageLayout = layout
    if noApply then return true end
    if _G.InCombatLockdown() then
        _G.print("|cff30d0ffRealUI ActionBars|r: page numbering changes when combat ends.")
    end
    private.QueueSecure(function()
        private.ApplyAllBars()
        private.ApplyBindings()
    end)
    return true
end

-- Public: read-only accessors for RealUI_Dev's page-layout test.
function AB:GetPageLayout() return private.GetPageLayout() end
function AB:GetBarPage(id, layout) return private.GetBarPage(id, layout) end
function AB:GetBindingFormat(id, layout) return private.GetBindingFormat(id, layout) end

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

-- B151: point bars 2-6 at their layout page. Idempotent — SetState runs only
-- when the slot actually differs, so the frequent ApplyConfig callers (HuD
-- recompute, option sliders) cost nothing, and Bartender mode never touches
-- a button after CreateBar. Secure attributes: out of combat only (callers
-- of ApplyConfig already queue). Bar 1 is paged and the same in both layouts.
function barMixin:ApplySlots()
    if self.id == 1 then return end
    local base = (private.GetBarPage(self.id) - 1) * 12
    for i = 1, 12 do
        local button = self.buttons[i]
        local kind, action = button:GetAction(0)
        if kind ~= "action" or action ~= base + i then
            button:SetState(0, "action", base + i)
        end
    end
end

function barMixin:ApplyConfig()
    local db = self:GetDB()

    -- Slots before the config pass: UpdateConfig refreshes the button from
    -- whatever action it holds.
    self:ApplySlots()

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

    local locked = private.IsActionBarLocked()
    for i = 1, 12 do
        local button = self.buttons[i]
        -- Recomputed rather than carried over: the page layout decides it.
        button.config = BuildButtonConfig(db, GetKeyBoundTarget(self.id, i))
        button:UpdateConfig(button.config)
        button:SetAttribute("buttonlock", locked)
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

    -- Bars showing a Blizzard bar's action page mirror that bar's binding
    -- commands — pressed via override bindings (Bindings.lua) and displayed
    -- via LAB's keyBoundTarget. A bar on page 2 (bar 2 in Bartender mode) has
    -- no Blizzard binding set; it uses custom captures only. PAGE_BINDINGS.
    local db = AB.dbActionBars.profile.actionbars[id]
    local base = (private.GetBarPage(id) - 1) * 12
    for i = 1, 12 do
        local button = LAB:CreateButton(i, bar:GetName() .. "B" .. i, bar,
            BuildButtonConfig(db, GetKeyBoundTarget(id, i)))
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
            -- B151: the layout's page, not `id` (barMixin:ApplySlots re-runs
            -- this on a layout switch).
            button:SetState(0, "action", base + i)
        end

        bar.buttons[i] = button
    end

    return bar
end
