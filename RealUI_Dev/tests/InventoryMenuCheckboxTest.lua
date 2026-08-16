local ADDON_NAME, ns = ... -- luacheck: ignore

-- Diagnostic: RealUI_Inventory "Choose bag" menu — per-row checkbox state.
--
-- Tester report (RealUI-4): one row in the Choose bag menu renders without a
-- checkbox. The filter definitions are provably uniform (every row gets its
-- `checked` closure from menu:AddFilter, and the profession rows are
-- loop-generated), so this reports what the widgets actually did.
--
-- Two failure shapes are distinguishable:
--   * checkbox NOT shown          -> genuinely absent; cause still unknown
--   * checkbox shown, label not
--     anchored to it              -> MenuFrame:SetCheckedState resolved the
--                                    `checked` callback to nil, so the label
--                                    anchors at MENU_MARGIN and overdraws the
--                                    checkbox. Fixed 2026-08-16; if this shape
--                                    still appears, there is another path in.
--
-- Usage: /realdev bagmenu   then right-click a bag item to open Choose bag.
-- The inspection is armed once and fires on the next menu open, so there is no
-- timer race to lose.

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

--- The menu frames are pool-created with a name derived from GetNumActive at
--- creation time, so the exact index is not knowable up front. Enumerate.
local function FindShownMenuFrames()
    local found = {}

    local frame = _G.EnumerateFrames()
    while frame do
        -- This walks every frame in the game, including other addons'. A
        -- parentKey can shadow a widget method (seen live: a frame whose
        -- .GetName was a FontString), so nothing here may be trusted to be
        -- callable or to return the expected type.
        local ok, name = _G.pcall(frame.GetName, frame)
        if ok and type(name) == "string" and name:find("RealUI_MenuFrame", 1, true) then
            local shownOk, shown = _G.pcall(frame.IsShown, frame)
            if shownOk and shown then
                _G.tinsert(found, frame)
            end
        end
        frame = _G.EnumerateFrames(frame)
    end

    return found
end

--- The label carries a default anchor from SetNormalFontObject, and Update
--- adds the checkbox-relative one on top. Check every point, not just the
--- first, or a correctly anchored label reads as misanchored.
local function IsAnchoredTo(label, target)
    if not label then return false end

    for i = 1, label:GetNumPoints() do
        local _, relativeTo = label:GetPoint(i)
        if relativeTo == target then
            return true
        end
    end

    return false
end

local function ReportMenu(menu)
    local rows, missing, overdrawn = 0, 0, 0

    for _, child in _G.ipairs({ menu:GetChildren() }) do
        local checkBox = child.checkBox
        -- Only rows that are supposed to have a checkbox. Titles and spacers
        -- carry no `checked` value and correctly render without one.
        local info = child.info
        if checkBox and info and info.checked ~= nil then
            rows = rows + 1

            local label = child.GetFontString and child:GetFontString()

            local shown = checkBox:IsShown()
            local anchored = IsAnchoredTo(label, checkBox)

            if not shown then
                missing = missing + 1
            elseif not anchored then
                overdrawn = overdrawn + 1
            end

            if not shown or not anchored then
                _G.print(("  |cffff0000%-38s|r shown=%s anchoredToCheckBox=%s"):format(
                    _G.tostring(child:GetText()), _G.tostring(shown), _G.tostring(anchored)))
            end
        end
    end

    return rows, missing, overdrawn
end

---------------------------------------------------------------------------
-- Slash command entry point: /realdev bagmenu
---------------------------------------------------------------------------
local armed = false

function ns.commands:bagmenu()
    if armed then
        _G.print("|cff00ccff[Bag Menu Checkboxes]|r Already armed — open the Choose bag menu.")
        return true
    end

    local MenuFrame = _G.RealUI and _G.RealUI.GetModule and _G.RealUI:GetModule("MenuFrame", true)
    if not MenuFrame then
        _G.print("|cffff0000[ERROR]|r MenuFrame module not found.")
        return false
    end

    armed = true
    _G.print("|cff00ccff[Bag Menu Checkboxes]|r Armed. Right-click a bag item to open Choose bag.")

    -- Inspect on the frame after Open returns, so the rows are populated.
    _G.hooksecurefunc(MenuFrame, "Open", function()
        _G.C_Timer.After(0, function()
            local menus = FindShownMenuFrames()
            if #menus == 0 then
                _G.print("|cffff0000[FAIL]|r No shown RealUI_MenuFrame found after Open.")
                return
            end

            local rows, missing, overdrawn = 0, 0, 0
            for _, menu in _G.ipairs(menus) do
                local r, m, o = ReportMenu(menu)
                rows, missing, overdrawn = rows + r, missing + m, overdrawn + o
            end

            _G.print(("  Rows: %d, missing checkbox: %d, label overdrawing checkbox: %d")
                :format(rows, missing, overdrawn))

            if missing > 0 then
                _G.print("|cffff0000[FAIL]|r Checkbox genuinely absent — not the SetCheckedState fix.")
            elseif overdrawn > 0 then
                _G.print("|cffff0000[FAIL]|r Label overdrawing checkbox — SetCheckedState path.")
            else
                _G.print("|cff00ff00[PASS]|r Every row has a shown checkbox with the label anchored to it.")
            end
        end)
    end)

    return true
end
