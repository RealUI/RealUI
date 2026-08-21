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
-- isApplied() -> true/false/nil (nil = not detectable, always offered),
-- apply() -> nil. Items whose modules/frames are missing are skipped.
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
            local function at(live, anchorTo, point, x, y)
                return live.anchorTo == anchorTo and live.point == point
                    and live.x == x and live.y == y
            end
            return at(CastBars.db.profile.player.position, "player", "TOP", 0, -40)
                and at(CastBars.db.profile.target.position, "target", "TOP", 0, -40)
                and at(ClassResource.db.class.points.position, "player", "BOTTOM", 0, -20)
        end,
        apply = function()
            local FramePoint = RealUI:GetModule("FramePoint", true)
            local CastBars = RealUI:GetModule("CastBars", true)
            local ClassResource = RealUI:GetModule("ClassResource", true)

            -- "Move to the new default position" (Arnvid, 2026-08-21). The DB
            -- defaults are the old SCREEN positions — a pinned default did not
            -- exist, so the offsets are defined here (FramePoint.ApplyAnchor
            -- anchors point-to-same-point on the unit frame): cast bars hang
            -- centered just below their unit frame; the class resource row
            -- hangs under the player frame.
            local function pinAt(live, anchorTo, point, x, y)
                live.anchorTo = anchorTo
                live.point = point
                live.x = x
                live.y = y
            end

            pinAt(CastBars.db.profile.player.position, "player", "TOP", 0, -40)
            pinAt(CastBars.db.profile.target.position, "target", "TOP", 0, -40)
            FramePoint:RestorePosition(CastBars)

            pinAt(ClassResource.db.class.points.position, "player", "BOTTOM", 0, -20)
            FramePoint:RestorePosition(ClassResource)
        end,
    },
    {
        id = "bags",
        label = "Bags open bottom-right",
        desc = "The bag cluster now opens above the Infobar at the bottom-right, clear of the minimap.",
        changed = "beta 6",
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
            return point == "BOTTOMLEFT" and relPoint == "BOTTOMLEFT"
                and _G.math.abs((x or 0) - 6) < 1 and _G.math.abs((y or 0) - wantY) < 1
        end,
        apply = function()
            local layout = RealUI.db.char.layout and RealUI.db.char.layout.current or 1
            local chatFrame = _G.ChatFrame1
            chatFrame:ClearAllPoints()
            chatFrame:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", 6, RealUI.GetChatYOffset(layout))
            chatFrame:SetUserPlaced(true)
            _G.FCF_SavePositionAndDimensions(chatFrame)
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

    local apply = _G.CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    apply:SetSize(140, 24)
    apply:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -28, -14)
    apply:SetText("Apply selected")
    apply:SetScript("OnClick", function()
        NewDefaults:ApplySelected()
    end)
    dialog.apply = apply

    local later = _G.CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    later:SetSize(140, 24)
    later:SetPoint("LEFT", apply, "RIGHT", 10, 0)
    later:SetText("Keep my settings")
    later:SetScript("OnClick", function()
        dialog:Hide()
    end)

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

            local applied = item.isApplied()
            if applied == true then
                check:SetChecked(false)
                check.label:SetText(item.label .. " |cff00ff00(already applied)|r")
            else
                check:SetChecked(true)
                if applied == false then
                    anyDetectableOff = true
                end
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
