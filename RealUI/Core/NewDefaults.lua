local _, private = ...

-- Lua Globals --
-- luacheck: globals next ipairs

-- B47: one-time "apply new defaults" nudge. WoW only applies defaults to
-- settings the user has never touched, so testers carrying profiles from
-- earlier 4.0 betas (or 3.4.x) never see changed defaults. This popup lists
-- the defaults that changed since 3.4.0, each selectable, and applies only
-- what the user ticks. Auto-shows once per character when at least one
-- detectable item is off-default; `/realui newdefaults` reopens it anytime.

local RealUI = private.RealUI
local debug = RealUI.GetDebug("NewDefaults")

local NewDefaults = {}
RealUI.NewDefaults = NewDefaults

-- Each item: label, desc, changed (beta tag), needsReload,
-- isApplied() -> true/false/nil, apply() -> nil. Items whose modules/frames are
-- missing are skipped.
--
-- isApplied's three states are distinct and the dialog renders each differently
-- (B126): true = already applied, false = off-default and pre-ticked, nil = the
-- current value could not be read, shown unticked and labelled. nil used to
-- render as a ticked item, indistinguishable from a real finding.
--
-- `installApply = true` marks an item the install wizard applies itself, so a
-- freshly-wizarded character has nothing left to be nudged about.
-- B102: the keys whose calculated defaults used to carry the HuD size offset
-- twice. See Core/Positioners.lua.
local B102_KEYS = { "ActionBarsY", "CastBarPlayerY", "CastBarTargetY" }

local items = {
    {
        id = "auraSize",
        label = "Larger aura icons on unit frames (28px)",
        desc = "Buff/debuff icons on the player and target frames were 20px; timers were unreadable.",
        changed = "beta 4",
        needsReload = true,
        available = function()
            local UnitFrames = RealUI:GetModule("UnitFrames", true)
            return UnitFrames and UnitFrames.db and UnitFrames.db.profile.units
        end,
        isApplied = function()
            local units = RealUI:GetModule("UnitFrames", true).db.profile.units
            return units.player.buffSize == 28
                and units.target.buffSize == 28
                and units.target.debuffSize == 28
        end,
        apply = function()
            local units = RealUI:GetModule("UnitFrames", true).db.profile.units
            units.player.buffSize = 28
            units.target.buffSize = 28
            units.target.debuffSize = 28
        end,
    },
    {
        id = "targetDebuffsMine",
        label = "Target debuffs show only your own",
        desc = "The target debuff row used to show every debuff from every source. It now shows the ones you cast, sorted by time remaining. Change it under HuD \226\134\146 Units \226\134\146 Target.",
        changed = "beta 11",
        available = function()
            local UnitFrames = RealUI:GetModule("UnitFrames", true)
            local units = UnitFrames and UnitFrames.db and UnitFrames.db.profile.units
            return units and units.target and units.target.auraLayout
                and units.target.auraLayout.debuffs
        end,
        isApplied = function()
            local units = RealUI:GetModule("UnitFrames", true).db.profile.units
            return units.target.auraLayout.debuffs.filterPreset == "mine"
        end,
        apply = function()
            local UnitFrames = RealUI:GetModule("UnitFrames", true)
            UnitFrames.db.profile.units.target.auraLayout.debuffs.filterPreset = "mine"
            -- Filter is live-mutable on the container, so no reload is needed —
            -- RefreshUnits re-resolves it through ResolveAuraFilter.
            UnitFrames:RefreshUnits("NewDefaults")
        end,
    },
    {
        id = "statusText",
        label = "Health and power values shown on bars",
        desc = "Status Text now defaults to \"Both\". The old default rendered blank.",
        changed = "beta 4",
        available = function()
            local UnitFrames = RealUI:GetModule("UnitFrames", true)
            return UnitFrames and UnitFrames.db and UnitFrames.db.profile.misc
        end,
        isApplied = function()
            return RealUI:GetModule("UnitFrames", true).db.profile.misc.statusText == "both"
        end,
        apply = function()
            local UnitFrames = RealUI:GetModule("UnitFrames", true)
            UnitFrames.db.profile.misc.statusText = "both"
            UnitFrames:RefreshUnits("NewDefaults")
        end,
    },
    {
        id = "pinned",
        label = "Cast bars and class resource pinned to unit frames",
        desc = "Moves them to the default position and pins them there, so they follow their unit frame from now on.",
        changed = "beta 4",
        available = function()
            local CastBars = RealUI:GetModule("CastBars", true)
            local ClassResource = RealUI:GetModule("ClassResource", true)
            local FramePoint = RealUI:GetModule("FramePoint", true)
            return FramePoint and CastBars and CastBars.db
                and ClassResource and ClassResource.db
        end,
        isApplied = function()
            local CastBars = RealUI:GetModule("CastBars", true)
            local ClassResource = RealUI:GetModule("ClassResource", true)
            -- Drag saves keep 0.1 precision (RealUI.Round(x, 1)); the baked
            -- targets are integers — compare with a 1px tolerance or a real
            -- placement can never read as "applied".
            local function at(live, anchorTo, point, x, y)
                return live.anchorTo == anchorTo and live.point == point
                    and type(live.x) == "number" and _G.math.abs(live.x - x) < 1
                    and type(live.y) == "number" and _G.math.abs(live.y - y) < 1
            end
            return at(CastBars.db.profile.player.position, "player", "TOP", -10, -48)
                and at(CastBars.db.profile.target.position, "target", "TOP", 10, -48)
                and at(CastBars.db.profile.focus.position, "focus", "TOP", -6, -34)
                and at(ClassResource.db.class.points.position, "player", "CENTER", -85, -25)
        end,
        apply = function()
            local FramePoint = RealUI:GetModule("FramePoint", true)
            local CastBars = RealUI:GetModule("CastBars", true)
            local ClassResource = RealUI:GetModule("ClassResource", true)

            -- "Move to the new default position" (Arnvid, 2026-08-21). The DB
            -- defaults are the old SCREEN positions — a pinned default did not
            -- exist. These offsets are Arnvid's hand-tuned reference layout,
            -- measured live via /realdev layoutdump (2026-08-22) and
            -- symmetrized (player/target x mirrored, y averaged to -48).
            -- FramePoint.ApplyAnchor anchors point-to-same-point on the unit
            -- frame; offsets are frame-relative so they hold on both layouts.
            local function pinAt(live, anchorTo, point, x, y)
                live.anchorTo = anchorTo
                live.point = point
                live.x = x
                live.y = y
            end

            pinAt(CastBars.db.profile.player.position, "player", "TOP", -10, -48)
            pinAt(CastBars.db.profile.target.position, "target", "TOP", 10, -48)
            pinAt(CastBars.db.profile.focus.position, "focus", "TOP", -6, -34)
            FramePoint:RestorePosition(CastBars)

            -- Class points left-below the player frame (Arnvid's placement,
            -- re-measured 2026-08-22 AFTER the ClassResource drag-save fix —
            -- the first two readings were LibWindow screen coords masquerading
            -- as player-relative offsets).
            pinAt(ClassResource.db.class.points.position, "player", "CENTER", -85, -25)
            FramePoint:RestorePosition(ClassResource)
        end,
    },
    {
        id = "castbarUninterruptible",
        label = "Purple for casts you cannot interrupt",
        desc = "Nameplate cast bars tinted uninterruptible casts a dull red, next to the bright red for \"interrupt not ready\". Both read as a red bar. Uninterruptible is now purple.",
        changed = "4.0.3",
        -- The tint texture takes its colour when each plate's castbar is built.
        needsReload = true,
        available = function()
            local NP = _G.LibStub("AceAddon-3.0"):GetAddon("RealUI_Nameplates", true)
            local castbar = NP and NP.db and NP.db.profile.enemy and NP.db.profile.enemy.castbar
            return castbar and castbar.colors
        end,
        isApplied = function()
            local NP = _G.LibStub("AceAddon-3.0"):GetAddon("RealUI_Nameplates", true)
            local color = NP.db.profile.enemy.castbar.colors.uninterruptible
            local r, g, b = 0x8C / 255, 0x4D / 255, 0xCC / 255
            return _G.math.abs(color.r - r) < 0.01 and _G.math.abs(color.g - g) < 0.01
                and _G.math.abs(color.b - b) < 0.01
        end,
        apply = function()
            local NP = _G.LibStub("AceAddon-3.0"):GetAddon("RealUI_Nameplates", true)
            NP.db.profile.enemy.castbar.colors.uninterruptible = {
                r = 0x8C / 255, g = 0x4D / 255, b = 0xCC / 255, a = 1,
            }
        end,
    },
    {
        id = "abHeightB102",
        label = "Action bar height at Large HuD",
        desc = "At Large HuD the top action bars sat 20px lower than intended, because the HuD size offset was counted twice. This removes the extra 20px from both layouts' saved heights. Heights you set with the HuD Vertical slider keep their adjustment, and bottom bars stay on the Infobar. Leaving this unticked makes bottom bars sit 20px lower.",
        changed = "4.0.3",
        needsReload = true,
        available = function()
            local settings = RealUI.db and RealUI.db.profile.settings
            return RealUI.LayoutManager and RealUI.defaultPositions
                and settings and settings.hudSize == 2
        end,
        isApplied = function()
            -- One-shot per profile: the saved values cannot tell us whether
            -- they still carry the doubled offset, so a flag records it.
            local settings = RealUI.LayoutManager:GetLayoutSettingsStore(RealUI.cLayout or 1)
            return settings and settings.b102Migrated == true
        end,
        apply = function()
            local offsets = RealUI.hudSizeOffsets[2]
            for layoutId in next, RealUI.defaultPositions do
                local settings = RealUI.LayoutManager:GetLayoutSettingsStore(layoutId)
                local store = RealUI.LayoutManager:GetLayoutPositionsStore(layoutId)
                if settings and store and not settings.b102Migrated then
                    for _, key in ipairs(B102_KEYS) do
                        if store[key] then
                            store[key] = store[key] - (offsets[key] or 0)
                        end
                    end
                    settings.b102Migrated = true
                end
            end
        end,
    },
    {
        id = "bags",
        label = "Bags open bottom-right",
        desc = "The bag cluster now opens above the Infobar at the bottom-right, clear of the minimap.",
        changed = "beta 6",
        -- B126: the install wizard applies this itself. `InventoryBagMixin:Init`
        -- (RealUI_Inventory/Bags.lua:406) writes the same anchor at
        -- OnInitialize, but something later overrides it on upgrading profiles —
        -- measured on a 3.4.0 character after wizard + reload, the frame sat at
        -- CENTER 139,-68 with the relativeTo dropped, which is the shape
        -- `RealUI.SetPixelPoint` leaves behind (Util.lua:326) rather than
        -- anything Init produces. Applying at wizard completion runs after all
        -- of that, and `SetUserPlaced(false)` clears the saved placement too.
        installApply = true,
        available = function()
            return _G.RealUIInventory ~= nil
        end,
        isApplied = function()
            local point, _, relPoint, x, y = _G.RealUIInventory:GetPoint(1)
            if not point or _G.issecretvalue(x) or _G.issecretvalue(y) then return nil end
            return point == "BOTTOMRIGHT" and relPoint == "BOTTOMRIGHT"
                and _G.math.abs((x or 0) + 50) < 1 and _G.math.abs((y or 0) - 100) < 1
        end,
        apply = function()
            local main = _G.RealUIInventory
            main:ClearAllPoints()
            main:SetPoint("BOTTOMRIGHT", _G.UIParent, "BOTTOMRIGHT", -50, 100)
            main:SetUserPlaced(false)
        end,
    },
    {
        id = "chat",
        label = "Chat sits clear of the Infobar",
        desc = "The chat frame moves to the bottom-left default, above the Infobar at any resolution.",
        changed = "beta 6",
        available = function()
            return _G.ChatFrame1 ~= nil
        end,
        isApplied = function()
            local point, _, relPoint, x, y = _G.ChatFrame1:GetPoint(1)
            if not point or _G.issecretvalue(x) or _G.issecretvalue(y) then return nil end
            local layout = RealUI.db.char.layout and RealUI.db.char.layout.current or 1
            local wantY = RealUI.GetChatYOffset(layout)
            -- FCF saves chat positions as screen RATIOS and recomputes pixels
            -- at login, so the restored offsets drift a few px from what we
            -- set (flapped applied/not-applied across reloads at 1px).
            return point == "BOTTOMLEFT" and relPoint == "BOTTOMLEFT"
                and _G.math.abs((x or 0) - 6) < 12 and _G.math.abs((y or 0) - wantY) < 12
        end,
        -- B126: moving the frame alone does not stick. EditMode owns system 8
        -- and re-applies its saved anchor on every login, so ticking this item
        -- used to look like it worked and silently revert next session. The
        -- EditMode entry has to be corrected too, and that needs a reload to
        -- take effect — hence needsReload.
        needsReload = true,
        apply = function()
            local layout = RealUI.db.char.layout and RealUI.db.char.layout.current or 1
            local chatFrame = _G.ChatFrame1
            chatFrame:ClearAllPoints()
            chatFrame:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", 6, RealUI.GetChatYOffset(layout))
            chatFrame:SetUserPlaced(true)
            _G.FCF_SavePositionAndDimensions(chatFrame)

            local EMM = RealUI.EditModeManager
            if EMM and EMM.SetChatAnchor then
                EMM:BeginUserWrite()
                EMM:SetChatAnchor()
                EMM:EndUserWrite()
            end
        end,
    },
}

local dialog

local function BuildDialog()
    dialog = _G.CreateFrame("Frame", "RealUINewDefaultsFrame", _G.UIParent)
    dialog:SetSize(420, 100) -- height set after rows are laid out
    dialog:SetPoint("CENTER", 0, 100)
    dialog:SetFrameStrata("DIALOG")
    dialog:EnableMouse(true)
    dialog:SetMovable(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:Hide()

    if _G.Aurora then
        _G.Aurora.Base.SetBackdrop(dialog, _G.Aurora.Color.black, 0.85)
    else
        local bg = dialog:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.9)
    end

    local title = dialog:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Large")
    title:SetPoint("TOPLEFT", 16, -14)
    title:SetText("|cff0099ffRealUI|r — new defaults available")
    dialog.title = title

    local body = dialog:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
    body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    body:SetPoint("RIGHT", dialog, -16, 0)
    body:SetJustifyH("LEFT")
    body:SetText("These defaults changed since 3.4.0, but your saved settings kept their old values. Tick what you want and press Apply — everything else stays exactly as you have it.")
    dialog.body = body

    dialog.rows = {}
    local anchor = body
    for index, item in ipairs(items) do
        local check = _G.CreateFrame("CheckButton", nil, dialog, "UICheckButtonTemplate")
        do -- B121 family: the skin exists, it was simply never called.
            local Skin = _G.Aurora and _G.Aurora.Skin
            if Skin and Skin.UICheckButtonTemplate then
                Skin.UICheckButtonTemplate(check)
            end
        end
        check:SetSize(24, 24)
        -- Rows 2+ anchor to the previous row's description, which is indented
        -- 28px from the checkbox column — compensate to keep the column flush.
        if index == 1 then
            check:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
        else
            check:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -28, -8)
        end

        local label = dialog:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
        label:SetPoint("LEFT", check, "RIGHT", 4, 0)
        label:SetPoint("RIGHT", dialog, -16, 0)
        label:SetJustifyH("LEFT")
        check.label = label

        local desc = dialog:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Small")
        desc:SetPoint("TOPLEFT", check, "BOTTOMLEFT", 28, 2)
        desc:SetPoint("RIGHT", dialog, -16, 0)
        desc:SetJustifyH("LEFT")
        desc:SetTextColor(0.7, 0.7, 0.7)
        check.desc = desc

        check.item = item
        dialog.rows[index] = check
        anchor = desc
    end

    --[[ Centred as a pair, and Aurora-skinned.

         The buttons used to hang off the last description's BOTTOMLEFT, which
         left them flush left under a centred dialog. Centring on that anchor
         directly would still be ~14px off, because the description column is
         inset 44px from the dialog's left edge but only 16px from its right.

         So the row spans the dialog (LEFT/RIGHT) and takes its Y from the last
         row (TOP) — the same mixed-point idiom `body`, `label` and `desc` above
         already use — and the buttons sit either side of its centre.

         The vertical chain anchor -> row -> apply -> hint has to stay intact:
         AdjustHeight sizes the dialog by measuring from its top to hint's
         bottom, so a break here silently collapses the dialog. ]]
    local row = _G.CreateFrame("Frame", nil, dialog)
    row:SetHeight(24)
    row:SetPoint("TOP", anchor, "BOTTOM", 0, -14)
    row:SetPoint("LEFT", dialog, "LEFT")
    row:SetPoint("RIGHT", dialog, "RIGHT")

    local apply = _G.CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    apply:SetSize(140, 24)
    apply:SetPoint("RIGHT", row, "CENTER", -5, 0)
    apply:SetText("Apply selected")
    apply:SetScript("OnClick", function()
        NewDefaults:ApplySelected()
    end)
    dialog.apply = apply

    local later = _G.CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    later:SetSize(140, 24)
    later:SetPoint("LEFT", row, "CENTER", 5, 0)
    later:SetText("Keep my settings")
    later:SetScript("OnClick", function()
        dialog:Hide()
    end)

    -- Same omission as B121 in the install wizard: the skins existed and were
    -- never called, so the one dialog that greets an upgrading user was the one
    -- window that did not look like RealUI.
    local Skin = _G.Aurora and _G.Aurora.Skin
    if Skin and Skin.UIPanelButtonTemplate then
        Skin.UIPanelButtonTemplate(apply)
        Skin.UIPanelButtonTemplate(later)
    end

    local hint = dialog:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Small")
    hint:SetPoint("TOPLEFT", apply, "BOTTOMLEFT", 0, -8)
    hint:SetTextColor(0.5, 0.5, 0.5)
    hint:SetText("Reopen anytime with /realui newdefaults")
    dialog.hint = hint
end

-- Wrapped description text makes row heights variable, so the dialog height
-- is measured off the laid-out content rather than computed up front.
local function AdjustHeight()
    if not (dialog and dialog:IsShown()) then return end
    local top, bottom = dialog:GetTop(), dialog.hint:GetBottom()
    if top and bottom then
        dialog:SetHeight((top - bottom) + 16)
    end
end

function NewDefaults:ApplySelected()
    local appliedLabels, needsReload = {}, false
    for _, check in ipairs(dialog.rows) do
        if check:IsShown() and check:GetChecked() then
            local ok, err = _G.pcall(check.item.apply)
            if ok then
                appliedLabels[#appliedLabels + 1] = check.item.label
                needsReload = needsReload or check.item.needsReload
            else
                debug("apply failed", check.item.id, err)
                _G.print("|cff0099ffRealUI|r: could not apply \"" .. check.item.label .. "\"")
            end
        end
    end
    dialog:Hide()

    if #appliedLabels > 0 then
        _G.print("|cff0099ffRealUI|r: applied " .. #appliedLabels .. " new default(s).")
        if needsReload then
            RealUI:ReloadUIDialog()
        end
    end
end

--- B126: apply the defaults the install wizard owns.
--
-- Finishing the wizard should leave the character on current defaults, so the
-- nudge that runs eight seconds later has nothing to offer. Items tagged
-- `installApply` are the ones no other install-path code reliably lands.
--
-- Called from InstallWizard:Complete, which is user-initiated and ends in a
-- reload — the same contract the rest of that function's writes use. Each apply
-- is pcall'd: a component that is loaded but not ready must not take the tail of
-- the wizard down with it.
-- @return number  how many items were applied
function NewDefaults:ApplyInstallDefaults()
    local applied = 0
    for _, item in ipairs(items) do
        if item.installApply and item.available() then
            local ok, err = _G.pcall(item.apply)
            if ok then
                applied = applied + 1
                debug("install-applied default", item.id)
            else
                debug("install-apply failed", item.id, err)
            end
        end
    end
    return applied
end

--- Show the popup. When `auto` is set, only detectably off-default items make
--- it worth interrupting; a fully up-to-date profile skips the popup entirely.
function NewDefaults:Show(auto)
    if not dialog then
        BuildDialog()
    end

    local anyDetectableOff = false
    for index, check in ipairs(dialog.rows) do
        local item = check.item
        if item.available() then
            check:Show()
            check.label:SetText(item.label .. " |cff808080(" .. item.changed .. ")|r")
            check.desc:SetText(item.desc)

            -- B126: three states, not two. `isApplied` returns nil when it
            -- cannot read the current value (frame not positioned yet, secret
            -- coordinates), and an indeterminate item used to render as a
            -- ticked one — visually identical to "this is off-default, fix it".
            -- That is a false positive with consequences: the user applies a
            -- change they may not have needed, and a nudge that fires with one
            -- genuine item plus one unreadable one reads as two faults.
            -- Indeterminate items are now shown unticked and labelled as such.
            local applied = item.isApplied()
            if applied == true then
                check:SetChecked(false)
                check.label:SetText(item.label .. " |cff00ff00(already applied)|r")
            elseif applied == false then
                check:SetChecked(true)
                anyDetectableOff = true
            else
                check:SetChecked(false)
                check.label:SetText(item.label
                    .. " |cff808080(can't tell — tick to apply anyway)|r")
            end
        else
            check:Show()
            check:SetChecked(false)
            check:Disable()
            check.label:SetText(item.label .. " |cff808080(component not loaded)|r")
            check.desc:SetText(item.desc)
        end
    end

    if auto and not anyDetectableOff then
        debug("auto-show skipped: nothing detectably off-default")
        return
    end

    dialog:Show()
    _G.C_Timer.After(0, AdjustHeight)
end

-- Auto-show once per character, after login has settled and only for
-- characters that finished the install wizard (fresh installs get the new
-- defaults natively and are skipped by the detectable-items guard anyway).
local eventFrame = _G.CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    _G.C_Timer.After(8, function()
        local dbc = RealUI.db and RealUI.db.char
        if not dbc or not dbc.init or not dbc.init.initialized then return end
        if dbc.shownNewDefaults40 then return end
        dbc.shownNewDefaults40 = true
        NewDefaults:Show(true)
    end)
end)
