local ADDON_NAME, ns = ...

--[[ AuraSetupSpikes.lua — aura-setup-review, phase 1 spikes (tasks 1.1, 1.2, 1.3, 1.6).

     /realdev aurapark on|off|status       1.1  park Blizzard's BuffFrame and DebuffFrame
     /realdev cdmids [all]                 1.2  Cooldown Manager tracked cooldown IDs
     /realdev auraenchant [off]            1.3  temporary weapon enchants on an engine container
     /realdev auratest [refresh|build|off|status]
                                           1.6  engine containers built directly, no oUF

     Dev only: RealUI_Dev is not packaged, and nothing here ships (owner decision X7).
     Rules kept throughout:
       * Nothing is written onto a Blizzard frame or table. Blizzard frames are only
         read (BuffFrame/DebuffFrame geometry, the Cooldown Manager viewers' item list).
       * Test containers are children of RealUI's own unit frames.
       * Every engine and API call is pcall'ed. A missing API prints one line and returns.
       * Values that may be secret are passed through Describe() and never compared,
         concatenated raw or used as a table key.
]]

local RealUI = _G.RealUI
local tostring, tonumber, type, pcall, ipairs = _G.tostring, _G.tonumber, _G.type, _G.pcall, _G.ipairs

local PREFIX = "|cff00ccff[aura spike]|r "
local function Print(fmt, ...)
    _G.print(PREFIX .. fmt:format(...))
end

---------------------------------------------------------------------------
-- Secret-safe description of a value.
-- Returns a plain string: "nil", "secret", or the value as text.
---------------------------------------------------------------------------
local canaccessvalue = _G.canaccessvalue

local function IsAccessible(value)
    if value == nil then return true end
    if not canaccessvalue then return nil end -- unknown: no access check on this client
    local ok, accessible = pcall(canaccessvalue, value)
    if not ok then return false end
    return accessible and true or false
end

local function Describe(value)
    if value == nil then return "nil" end
    if IsAccessible(value) == false then return "secret" end
    local ok, text = pcall(tostring, value)
    if ok and type(text) == "string" then
        return text
    end
    return "?"
end

-- "12345 (ok)", "secret (no)", "12345 (n/a)" when canaccessvalue is missing.
local function DescribeChecked(value)
    if value == nil then return "nil" end
    local accessible = IsAccessible(value)
    local tag = (accessible == nil) and "n/a" or (accessible and "ok" or "no")
    return ("%s (%s)"):format(Describe(value), tag)
end

local function GetField(t, key)
    return t[key]
end

-- Listens for ADDON_ACTION_BLOCKED / _FORBIDDEN against this addon once any
-- spike command has run, so a refused action during a spike is printed.
local blockWatcher
local function WatchBlockedActions()
    if blockWatcher then return end
    blockWatcher = _G.CreateFrame("Frame")
    blockWatcher:RegisterEvent("ADDON_ACTION_BLOCKED")
    blockWatcher:RegisterEvent("ADDON_ACTION_FORBIDDEN")
    blockWatcher:SetScript("OnEvent", function(_, event, addon, func)
        if addon == ADDON_NAME then
            Print("|cffff4040%s|r: %s (in combat: %s)", event, Describe(func),
                _G.InCombatLockdown() and "yes" or "no")
        end
    end)
end

---------------------------------------------------------------------------
-- 1.1  Park spike: /realdev aurapark on|off|status
---------------------------------------------------------------------------
-- Mirrors EditModeTemplates.lua (SYSTEM_AURA_FRAME is not exported until task 2.1).
local SYSTEM_AURA_FRAME = 6
local PARK_INDICES = { 1, 2 }
local INDEX_NAMES = { [1] = "BuffFrame", [2] = "DebuffFrame", [3] = "External Defensives" }
-- Mirrors LAYOUT_NAMES.healing in EditModeManager.lua.
local HEALING_LAYOUT_NAME = "RealUI-Healing"
-- The parked anchor: RealUI's off-screen pattern, as Templates.base writes it
-- for every system RealUI replaces (OFF_SCREEN_Y = -5000, EditModeTemplates.lua).
local PARKED_ANCHOR = {
    point = "BOTTOM", relativeTo = "UIParent", relativePoint = "BOTTOM",
    offsetX = 0, offsetY = -5000,
}

local function CopyAnchor(a)
    return {
        point = a.point, relativeTo = a.relativeTo or "UIParent", relativePoint = a.relativePoint,
        offsetX = a.offsetX or 0, offsetY = a.offsetY or 0,
    }
end

local function AnchorText(a)
    if not a then return "none" end
    return ("%s %s %s %.1f, %.1f"):format(tostring(a.point), tostring(a.relativeTo),
        tostring(a.relativePoint), tonumber(a.offsetX) or 0, tonumber(a.offsetY) or 0)
end

local function GetManager()
    local EMM = RealUI and RealUI.EditModeManager
    if not (EMM and EMM.GetActiveRealUILayoutIndex and EMM.FindSystemInfo and EMM.BuildLayout
        and EMM.BeginUserWrite and EMM.EndUserWrite and EMM.IsUserWriteScopeOpen) then
        return nil, "RealUI's EditModeManager is not loaded"
    end
    if not (_G.C_EditMode and _G.C_EditMode.GetLayouts and _G.C_EditMode.SaveLayouts) then
        return nil, "C_EditMode is not available on this client"
    end
    return EMM
end

-- @return data, savedIndex  or nil, reason
local function ReadActiveRealUILayout(EMM)
    local ok, data = pcall(_G.C_EditMode.GetLayouts)
    if not ok or type(data) ~= "table" or not data.layouts then
        return nil, "C_EditMode.GetLayouts failed"
    end
    local index = EMM:GetActiveRealUILayoutIndex(data)
    if not index then
        return nil, "the active Edit Mode layout is not a RealUI layout (RealUI or RealUI-Healing); "
            .. "select one in Edit Mode first", data
    end
    return data, index
end

-- The template entries for system 6 as the manager builds them for this
-- layout's role and the stored display preset.
local function TemplateEntries(EMM, layoutName)
    local role = (layoutName == HEALING_LAYOUT_NAME) and "healing" or "dpstank"
    local display = RealUI.db and RealUI.db.global and RealUI.db.global.display
    local presetId = (display and type(display.presetId) == "string") and display.presetId or "standard"
    local ok, built = pcall(EMM.BuildLayout, EMM, role, presetId)
    if not ok or type(built) ~= "table" or not built.systems then
        return nil, role, presetId
    end
    local entries = {}
    for _, entry in ipairs(built.systems) do
        if entry.system == SYSTEM_AURA_FRAME and entry.systemIndex then
            entries[entry.systemIndex] = entry
        end
    end
    return entries, role, presetId
end

local function FrameGeometry(name)
    local frame = _G[name]
    if not frame then return ("%s: not present"):format(name) end
    local parts = {}
    for _, method in ipairs({ "IsShown", "GetLeft", "GetRight", "GetTop", "GetBottom" }) do
        local ok, value = pcall(frame[method], frame)
        parts[#parts + 1] = ("%s=%s"):format(method, ok and Describe(value) or "error")
    end
    return ("%s: %s"):format(name, _G.table.concat(parts, " "))
end

local function OnScreenVerdict(name)
    local frame = _G[name]
    if not frame then return "not present" end
    local ok, left, bottom, width, height = pcall(frame.GetRect, frame)
    if not ok or left == nil then return "no position (no anchor or no size)" end
    for _, v in ipairs({ left, bottom, width, height }) do
        if IsAccessible(v) == false then return "position is secret" end
    end
    local okUI, uiWidth, uiHeight = pcall(function()
        return _G.UIParent:GetWidth(), _G.UIParent:GetHeight()
    end)
    if not okUI then return "UIParent size unreadable" end
    local right, top = left + width, bottom + height
    if right <= 0 or left >= uiWidth or top <= 0 or bottom >= uiHeight then
        return "|cff00ff00off screen|r"
    end
    if left >= 0 and right <= uiWidth and bottom >= 0 and top <= uiHeight then
        return "|cffff4040on screen|r (clamped or not parked)"
    end
    return "|cffffaa00partly on screen|r"
end

local function ParkStatus()
    local EMM, reason = GetManager()
    Print("in combat: %s", _G.InCombatLockdown() and "yes" or "no")
    if EMM then
        local data, index = ReadActiveRealUILayout(EMM)
        if data then
            local layout = data.layouts[index]
            Print("active layout: %s (saved index %d, type %s)", tostring(layout.layoutName), index,
                tostring(layout.layoutType))
            for sysIndex = 1, 3 do
                local sysInfo = EMM:FindSystemInfo(layout, SYSTEM_AURA_FRAME, sysIndex)
                Print("  system 6 index %d (%s): %s", sysIndex, INDEX_NAMES[sysIndex],
                    AnchorText(sysInfo and sysInfo.anchorInfo))
            end
        else
            Print("saved layout: %s", tostring(index))
        end
    else
        Print("saved layout: %s", reason)
    end
    for _, name in ipairs({ "BuffFrame", "DebuffFrame" }) do
        Print("  %s", FrameGeometry(name))
        Print("  %s: %s", name, OnScreenVerdict(name))
    end
    local okUI, uiWidth, uiHeight = pcall(function()
        return _G.UIParent:GetWidth(), _G.UIParent:GetHeight()
    end)
    if okUI then
        Print("  UIParent: %.1f x %.1f", uiWidth, uiHeight)
    end
end

local function Park(mode)
    local EMM, reason = GetManager()
    if not EMM then
        Print("aurapark %s refused: %s.", mode, reason)
        return
    end
    if _G.InCombatLockdown() then
        Print("aurapark %s refused: in combat. Leave combat and run it again.", mode)
        return
    end
    local editMode = _G.EditModeManagerFrame
    if editMode and editMode.IsShown and editMode:IsShown() then
        Print("aurapark %s refused: Edit Mode is open. Close it and run it again.", mode)
        return
    end

    local data, index = ReadActiveRealUILayout(EMM)
    if not data then
        Print("aurapark %s refused: %s.", mode, tostring(index))
        return
    end
    local layout = data.layouts[index]
    local template, role, presetId = TemplateEntries(EMM, layout.layoutName)
    if mode == "off" and not template then
        Print("aurapark off refused: the template for role %s, display preset %s could not be built.",
            role, presetId)
        return
    end

    -- Resolve every target before changing anything, so a refusal writes nothing.
    local changes = {}
    for _, sysIndex in ipairs(PARK_INDICES) do
        local sysInfo = EMM:FindSystemInfo(layout, SYSTEM_AURA_FRAME, sysIndex)
        if not (sysInfo and sysInfo.anchorInfo) then
            Print("aurapark %s refused: system 6 index %d (%s) is missing from layout %s.",
                mode, sysIndex, INDEX_NAMES[sysIndex], tostring(layout.layoutName))
            return
        end
        local target, inDefault
        if mode == "on" then
            target, inDefault = CopyAnchor(PARKED_ANCHOR), false
        else
            local entry = template[sysIndex]
            if not (entry and entry.anchorInfo) then
                Print("aurapark off refused: the template has no entry for system 6 index %d.", sysIndex)
                return
            end
            target, inDefault = CopyAnchor(entry.anchorInfo), entry.isInDefaultPosition and true or false
        end
        changes[#changes + 1] = { sysIndex = sysIndex, sysInfo = sysInfo, target = target, inDefault = inDefault }
    end

    for _, change in ipairs(changes) do
        change.before = AnchorText(change.sysInfo.anchorInfo)
        change.sysInfo.anchorInfo = change.target
        change.sysInfo.isInDefaultPosition = change.inDefault
    end

    -- RealUI's write gate. The manager exports no writer for an arbitrary
    -- system entry (its SaveLayouts is file-local), so the save is made here,
    -- only while the gate's scope is open, exactly as the manager's own
    -- writers do: user-initiated, and followed by a reload prompt.
    EMM:BeginUserWrite()
    local wrote, err = false, "write scope did not open"
    if EMM:IsUserWriteScopeOpen() then
        wrote, err = pcall(_G.C_EditMode.SaveLayouts, data)
    end
    EMM:EndUserWrite()

    if not wrote then
        Print("aurapark %s: |cffff4040the layout write failed|r: %s. Nothing changed.", mode, Describe(err))
        return
    end

    Print("aurapark %s: wrote layout %s (role %s, display preset %s).", mode, tostring(layout.layoutName),
        role, presetId)
    for _, change in ipairs(changes) do
        Print("  system 6 index %d (%s): %s  ->  %s", change.sysIndex, INDEX_NAMES[change.sysIndex],
            change.before, AnchorText(change.target))
    end
    Print("  index 3 (External Defensives), the other layout and every setting are unchanged.")
    Print("Reload now: Edit Mode applies the saved layout at login. Type /reload if no prompt shows.")
    if RealUI.ReloadUIDialog then
        RealUI:ReloadUIDialog()
    end
end

function ns.commands:aurapark(arg)
    WatchBlockedActions()
    if arg == "on" or arg == "off" then
        Park(arg)
    elseif arg == "status" then
        ParkStatus()
    else
        Print("usage: /realdev aurapark on | off | status")
    end
end

---------------------------------------------------------------------------
-- 1.2  Tracked spell ID spike: /realdev cdmids [all]
---------------------------------------------------------------------------
local CDM_FIELDS = { "spellID", "overrideSpellID", "linkedSpellIDs", "selfAura", "hasAura", "isKnown", "category" }
-- name of the viewer that shows a category, for the comparison
local CDM_VIEWERS = {
    TrackedBuff = "BuffIconCooldownViewer",
    TrackedBar = "BuffBarCooldownViewer",
}

local function DescribeList(list)
    if list == nil then return "nil" end
    if type(list) ~= "table" then return DescribeChecked(list) end
    if IsAccessible(list) == false then return "secret (no)" end
    local parts, anySecret = {}, false
    local ok = pcall(function()
        for i = 1, #list do
            local text = Describe(list[i])
            if text == "secret" then anySecret = true end
            parts[#parts + 1] = text
        end
    end)
    if not ok then return "unreadable" end
    local tag = anySecret and "no" or (canaccessvalue and "ok" or "n/a")
    return ("{%s} (%s)"):format(_G.table.concat(parts, ","), tag)
end

local function NewOutput(title)
    local lines = {}
    return {
        Add = function(_, fmt, ...)
            lines[#lines + 1] = fmt:format(...)
        end,
        Show = function()
            local LTD = _G.LibStub and _G.LibStub("LibTextDump-1.0", true)
            if LTD then
                local ok = pcall(function()
                    local dump = LTD:New(title, 760, 520)
                    for _, line in ipairs(lines) do dump:AddLine(line) end
                    dump:Display()
                end)
                if ok then
                    Print("%d lines in the text window (Ctrl+A, Ctrl+C to copy).", #lines)
                    return
                end
            end
            for _, line in ipairs(lines) do _G.print(line) end
        end,
    }
end

-- The cooldown IDs a viewer currently holds item frames for. Read only: walks
-- the viewer's active pool and asks each item frame for its ID.
local function ViewerCooldownIDs(viewerName)
    local viewer = _G[viewerName]
    if not viewer then return nil, "not present" end
    local ids, secret = {}, 0
    local ok, err = pcall(function()
        local pool = viewer.itemFramePool
        if not pool then error("no item frame pool") end
        for itemFrame in pool:EnumerateActive() do
            local okID, id = pcall(itemFrame.GetCooldownID, itemFrame)
            if okID and id ~= nil then
                if IsAccessible(id) ~= true then
                    secret = secret + 1
                else
                    local okShown, shown = pcall(itemFrame.IsShown, itemFrame)
                    ids[#ids + 1] = { id = id, shown = okShown and shown and true or false }
                end
            end
        end
    end)
    if not ok then return nil, Describe(err) end
    return ids, nil, secret
end

local function CooldownIDs(out, all)
    local api = _G.C_CooldownViewer
    local categories = _G.Enum and _G.Enum.CooldownViewerCategory
    if not (api and api.GetCooldownViewerCategorySet and api.GetCooldownViewerCooldownInfo and categories) then
        Print("cdmids: C_CooldownViewer or Enum.CooldownViewerCategory is not available on this client.")
        return false
    end

    out:Add("cdmids  in combat: %s  canaccessvalue: %s", _G.InCombatLockdown() and "yes" or "no",
        canaccessvalue and "present" or "missing")
    local okAvail, available, failure = pcall(api.IsCooldownViewerAvailable)
    local failText = okAvail and Describe(failure) or "nil"
    out:Add("IsCooldownViewerAvailable: %s %s", okAvail and Describe(available) or "error",
        (failText ~= "nil" and failText ~= "") and ("(" .. failText .. ")") or "")
    if _G.C_CVar and _G.C_CVar.GetCVarBool then
        local okCVar, enabled = pcall(_G.C_CVar.GetCVarBool, "cooldownViewerEnabled")
        out:Add("CVar cooldownViewerEnabled: %s", okCVar and Describe(enabled) or "error")
    end

    local names = { "TrackedBuff", "TrackedBar" }
    if all then
        names[#names + 1] = "SpecAgnosticTracked"
        names[#names + 1] = "EquipSlotTracked"
    end

    for _, categoryName in ipairs(names) do
        local category = categories[categoryName]
        if category == nil then
            out:Add("== %s: not in Enum.CooldownViewerCategory on this client", categoryName)
        else
            local okSet, ids = pcall(api.GetCooldownViewerCategorySet, category)
            if not okSet then
                out:Add("== %s (%s): GetCooldownViewerCategorySet refused: %s", categoryName, Describe(category),
                    Describe(ids))
            elseif type(ids) ~= "table" then
                out:Add("== %s (%s): GetCooldownViewerCategorySet returned %s", categoryName, Describe(category),
                    Describe(ids))
            else
                local count = "?"
                local okCount, n = pcall(function() return #ids end)
                if okCount then count = tostring(n) end
                out:Add("== %s (%s): %s cooldown IDs in the category set", categoryName, Describe(category), count)

                local inSet = {} -- keyed by accessible IDs only
                local okIter, iterErr = pcall(function()
                    for i = 1, #ids do
                        local cooldownID = ids[i]
                        local idText = Describe(cooldownID)
                        if IsAccessible(cooldownID) == true then
                            inSet[cooldownID] = true
                        end
                        local okInfo, info = pcall(api.GetCooldownViewerCooldownInfo, cooldownID)
                        if not okInfo then
                            out:Add("  %s: GetCooldownViewerCooldownInfo refused: %s", idText, Describe(info))
                        elseif type(info) ~= "table" then
                            out:Add("  %s: no info (%s)", idText, Describe(info))
                        else
                            local parts = {}
                            for _, field in ipairs(CDM_FIELDS) do
                                local okField, value = pcall(GetField, info, field)
                                local text
                                if not okField then
                                    text = "refused"
                                elseif field == "linkedSpellIDs" then
                                    text = DescribeList(value)
                                else
                                    text = DescribeChecked(value)
                                end
                                parts[#parts + 1] = ("%s=%s"):format(field, text)
                            end
                            -- Forever: present only if the client adds it to this structure.
                            local okDisplay, displaySpellID = pcall(GetField, info, "displaySpellID")
                            if okDisplay and displaySpellID ~= nil then
                                parts[#parts + 1] = ("displaySpellID=%s"):format(DescribeChecked(displaySpellID))
                            end
                            out:Add("  %s: %s", idText, _G.table.concat(parts, "  "))
                        end
                    end
                end)
                if not okIter then
                    out:Add("  iteration stopped: %s", Describe(iterErr))
                end

                -- What the viewer that shows this category actually holds.
                local viewerName = CDM_VIEWERS[categoryName]
                if viewerName then
                    local viewerIDs, viewerErr, secretCount = ViewerCooldownIDs(viewerName)
                    if not viewerIDs then
                        out:Add("  viewer %s: %s", viewerName, viewerErr)
                    else
                        local shownList, onlyInViewer, inViewer = {}, {}, {}
                        for _, item in ipairs(viewerIDs) do
                            inViewer[item.id] = true
                            shownList[#shownList + 1] = Describe(item.id) .. (item.shown and "" or "(hidden)")
                            if not inSet[item.id] then onlyInViewer[#onlyInViewer + 1] = Describe(item.id) end
                        end
                        local onlyInSet = {}
                        for id in _G.pairs(inSet) do
                            if not inViewer[id] then onlyInSet[#onlyInSet + 1] = Describe(id) end
                        end
                        out:Add("  viewer %s holds %d: %s%s", viewerName, #viewerIDs,
                            _G.table.concat(shownList, ","),
                            (secretCount and secretCount > 0) and (" + " .. secretCount .. " secret or unchecked, not compared") or "")
                        out:Add("  in the category set, not in the viewer: %s",
                            #onlyInSet > 0 and _G.table.concat(onlyInSet, ",") or "none")
                        out:Add("  in the viewer, not in the category set: %s",
                            #onlyInViewer > 0 and _G.table.concat(onlyInViewer, ",") or "none")
                    end
                end
            end
        end
    end
    return true
end

function ns.commands:cdmids(arg)
    WatchBlockedActions()
    local out = NewOutput("RealUI cdmids")
    local ok, err = pcall(CooldownIDs, out, arg == "all")
    if not ok then
        Print("cdmids stopped with an error: %s", Describe(err))
    end
    out:Show()
end

---------------------------------------------------------------------------
-- Engine containers, shared by 1.3 and 1.6
---------------------------------------------------------------------------
local ICON_SIZE, SPACING, PER_LINE = 28, 2, 8

local function HostFrame(unit)
    if unit == "player" then return _G.RealUIPlayerFrame end
    if unit == "target" then return _G.RealUITargetFrame end
end

-- Minimal look: cropped icon on a black 1px edge, swipe without numbers,
-- count top right, time bottom centre, dispel border on debuffs.
local function MakeInitializer(kind, cancel)
    return function(button)
        button:SetSize(ICON_SIZE, ICON_SIZE)
        button:EnableMouse(true)
        button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", 0, 0)

        local edge = button:CreateTexture(nil, "BACKGROUND")
        edge:SetColorTexture(0, 0, 0)
        edge:SetPoint("TOPLEFT", -1, 1)
        edge:SetPoint("BOTTOMRIGHT", 1, -1)

        local cooldown = _G.CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        cooldown:SetAllPoints()
        cooldown:SetDrawEdge(false)
        cooldown:SetHideCountdownNumbers(true)
        button:SetDurationCooldown(cooldown)

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        button:SetIcon(icon)

        local textParent = _G.CreateFrame("Frame", nil, button)
        textParent:SetAllPoints()
        textParent:SetFrameLevel(cooldown:GetFrameLevel() + 1)

        local count = textParent:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
        count:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, -1)
        button:SetApplicationCount(count, {})

        local time = textParent:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
        time:SetPoint("BOTTOM", button, "BOTTOM", 0, 1)
        button:SetDurationText(time, {})

        if kind == "debuff" then
            local border = button:CreateTexture(nil, "OVERLAY")
            border:SetAllPoints()
            button:AddDispelTypeTexture(border, {
                style = _G.Enum.CustomAuraButtonDispelTypeTextureStyle.Border,
                showWhenHarmful = true,
            })
        end

        if cancel then
            button:SetCancelAuraButtons("RightButtonUp")
        end
    end
end

-- Builds one container step by step and records each step's result.
-- spec: label, unit, filter (nil for enchant-only), kind, cancel, enchants,
--       point, relativePoint, x, y, growX, growY
-- @return container or nil, and the list of step results
local function BuildContainer(host, spec)
    local steps = {}
    local function Step(name, ok, err)
        steps[#steps + 1] = ok and name or ("%s |cffff4040FAILED|r (%s)"):format(name, Describe(err))
        return ok
    end

    local ok, container = pcall(_G.CreateFrame, "AuraContainer", nil, host, "CustomAuraContainerTemplate")
    if not Step("CreateFrame", ok and container ~= nil, container) then
        return nil, steps
    end
    Step("SetSize", pcall(container.SetSize, container, 1, 1))

    if spec.filter then
        Step("AddAuraGroup " .. spec.filter, pcall(container.AddAuraGroup, container, "spike", spec.filter, {
            initializeFrame = MakeInitializer(spec.kind, spec.cancel),
            maxFrameCount = 16,
            layout = { elementSpacing = SPACING, lineSpacing = SPACING },
        }))
    end
    if spec.enchants then
        local slots = _G.AuraContainerItemEnchantmentSlot
        for _, slotName in ipairs(spec.enchants) do
            local slot = slots and slots[slotName]
            if slot == nil then
                Step("AddItemEnchantment " .. slotName, false, "AuraContainerItemEnchantmentSlot." .. slotName .. " missing")
            elseif Step("AddItemEnchantment " .. slotName, pcall(container.AddItemEnchantment, container, slot, {
                initializeFrame = MakeInitializer("buff", spec.cancel),
            })) then
                Step("SetItemEnchantmentEnabled " .. slotName,
                    pcall(container.SetItemEnchantmentEnabled, container, slot, true))
            end
        end
        Step("SetItemEnchantmentLayout", pcall(container.SetItemEnchantmentLayout, container,
            { elementSpacing = SPACING, lineSpacing = SPACING }))
    end

    Step("SetFlowLayoutAnchorPoint", pcall(container.SetFlowLayoutAnchorPoint, container, spec.point))
    Step("SetFlowLayoutGrowthDirection", pcall(container.SetFlowLayoutGrowthDirection, container,
        spec.growX, spec.growY))
    Step("SetFlowLayoutMaximumLineSize", pcall(container.SetFlowLayoutMaximumLineSize, container,
        PER_LINE * (ICON_SIZE + SPACING)))
    Step("ClearAllPoints", pcall(container.ClearAllPoints, container))
    Step("SetPoint", pcall(container.SetPoint, container, spec.point, host, spec.relativePoint, spec.x, spec.y))
    Step("SetUnit " .. spec.unit, pcall(container.SetUnit, container, spec.unit))
    Step("SetEnabled", pcall(container.SetEnabled, container, true))
    Step("Show", pcall(container.Show, container))
    return container, steps
end

-- A label beside a container, on RealUI's host frame. Never anchored to the
-- container itself (the engine restricts what may anchor to it).
local function AddLabel(host, spec)
    local holder = _G.CreateFrame("Frame", nil, host)
    holder:SetSize(1, 1)
    holder:SetPoint(spec.point, host, spec.relativePoint, spec.x, spec.y)
    local text = holder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetText("spike: " .. spec.label)
    local above = spec.growY == -1
    text:SetPoint(above and "BOTTOM" or "TOP", holder, spec.point, 0, above and 2 or -2)
    return holder
end

local function ReportBuild(label, container, steps)
    Print("%s: %s", label, container and "built" or "|cffff4040not built|r")
    Print("  steps: %s", _G.table.concat(steps, ", "))
    if container then
        local okP, isProtected = pcall(container.IsProtected, container)
        Print("  container protected: %s", okP and Describe(isProtected) or "error")
    end
end

local function RetireContainer(entry)
    if not entry.container then return end
    pcall(entry.container.SetEnabled, entry.container, false)
    pcall(entry.container.Hide, entry.container)
    if entry.labelFrame then entry.labelFrame:Hide() end
    entry.off = true
end

local function ReviveContainer(entry)
    if not entry.container then return end
    pcall(entry.container.SetEnabled, entry.container, true)
    pcall(entry.container.Show, entry.container)
    if entry.labelFrame then entry.labelFrame:Show() end
    entry.off = nil
end

local function ContainerStatus(entry)
    local c = entry.container
    if not c then
        Print("  %s: not built", entry.label)
        return
    end
    local function Read(method)
        local ok, value = pcall(c[method], c)
        return ok and Describe(value) or "error"
    end
    Print("  %s: unit=%s enabled=%s shown=%s visible=%s editModePreview=%s protected=%s",
        entry.label, Read("GetUnit"), Read("IsEnabled"), Read("IsShown"), Read("IsVisible"),
        Read("IsEditModePreviewEnabled"), Read("IsProtected"))
end

local function EngineReason()
    if not _G.AuraContainerSortMethod then
        return "Blizzard_AuraContainer is not loaded on this client"
    end
    if not (_G.AnchorUtil and _G.AnchorUtil.FlowDirection) then
        return "AnchorUtil.FlowDirection is missing"
    end
end

---------------------------------------------------------------------------
-- 1.3  Temporary enchant spike: /realdev auraenchant [off]
---------------------------------------------------------------------------
local enchantEntry

local function ReportGameEnchants()
    local api = _G.C_PaperDollInfo and _G.C_PaperDollInfo.GetTemporaryEnchantmentInfo
    if not api then
        Print("  C_PaperDollInfo.GetTemporaryEnchantmentInfo: missing (the engine reads enchants through it)")
        return
    end
    for _, slot in ipairs({ { "main hand", _G.INVSLOT_MAINHAND }, { "off hand", _G.INVSLOT_OFFHAND } }) do
        local ok, info = pcall(api, slot[2])
        Print("  game reports %s enchant: %s", slot[1],
            not ok and ("refused: " .. Describe(info)) or (info ~= nil and "active" or "none"))
    end
end

function ns.commands:auraenchant(arg)
    WatchBlockedActions()
    if arg == "off" then
        if enchantEntry then
            RetireContainer(enchantEntry)
            Print("auraenchant: container disabled and hidden (the engine has no way to destroy it).")
        else
            Print("auraenchant: nothing built.")
        end
        return
    end
    local reason = EngineReason()
    if reason then
        Print("auraenchant: %s.", reason)
        return
    end
    if enchantEntry then
        ReviveContainer(enchantEntry)
        Print("auraenchant: already built; enabled and shown again.")
        ContainerStatus(enchantEntry)
        ReportGameEnchants()
        return
    end
    if _G.InCombatLockdown() then
        Print("auraenchant refused: in combat. Build it out of combat.")
        return
    end
    local host = HostFrame("player")
    if not host then
        Print("auraenchant: RealUIPlayerFrame does not exist (HuD unit frames off?).")
        return
    end
    -- Above the player frame's left edge, growing left and up, clear of the
    -- HuD's own buff row (which grows right from the same corner).
    local spec = {
        label = "enchants", unit = "player", enchants = { "MainHand", "OffHand" }, cancel = true,
        point = "BOTTOMRIGHT", relativePoint = "TOPLEFT", x = -8, y = 8, growX = -1, growY = 1,
    }
    local container, steps = BuildContainer(host, spec)
    enchantEntry = { label = spec.label, container = container }
    if container then enchantEntry.labelFrame = AddLabel(host, spec) end
    ReportBuild("auraenchant", container, steps)
    ReportGameEnchants()
    Print("Right-click the icon to test cancel. /realdev auraenchant off to hide it.")
end

---------------------------------------------------------------------------
-- 1.6  Engine spike: /realdev auratest [refresh|build|off|status]
---------------------------------------------------------------------------
local testEntries = {}   -- the three base containers
local builtInCombat = {} -- extra target containers from "build"

local BASE_SPECS = {
    { label = "player HELPFUL", unit = "player", filter = "HELPFUL", kind = "buff", cancel = true,
      point = "TOPRIGHT", relativePoint = "TOPLEFT", x = -8, y = 0, growX = -1, growY = -1 },
    { label = "player HARMFUL", unit = "player", filter = "HARMFUL", kind = "debuff",
      point = "TOPLEFT", relativePoint = "BOTTOMLEFT", x = 0, y = -20, growX = 1, growY = -1 },
    { label = "target HARMFUL", unit = "target", filter = "HARMFUL", kind = "debuff",
      point = "TOPLEFT", relativePoint = "BOTTOMLEFT", x = 0, y = -20, growX = 1, growY = -1 },
}

local function AllTestEntries()
    local list = {}
    for _, entry in ipairs(testEntries) do list[#list + 1] = entry end
    for _, entry in ipairs(builtInCombat) do list[#list + 1] = entry end
    return list
end

local function BuildBase()
    if _G.InCombatLockdown() then
        Print("auratest refused: build the base containers out of combat; "
            .. "/realdev auratest build is the in-combat test.")
        return
    end
    for _, spec in ipairs(BASE_SPECS) do
        local host = HostFrame(spec.unit)
        if not host then
            Print("auratest %s: host frame for %s does not exist (HuD unit frames off?).", spec.label, spec.unit)
        else
            local container, steps = BuildContainer(host, spec)
            local entry = { label = spec.label, container = container }
            if container then entry.labelFrame = AddLabel(host, spec) end
            testEntries[#testEntries + 1] = entry
            ReportBuild("auratest " .. spec.label, container, steps)
        end
    end
end

local function BuildInCombat()
    local host = HostFrame("target")
    if not host then
        Print("auratest build: RealUITargetFrame does not exist.")
        return
    end
    local n = #builtInCombat + 1
    local spec = {
        label = "target HARMFUL #" .. (n + 1), unit = "target", filter = "HARMFUL", kind = "debuff",
        point = "TOPLEFT", relativePoint = "BOTTOMLEFT", x = 0, y = -20 - n * (2 * (ICON_SIZE + SPACING) + 20),
        growX = 1, growY = -1,
    }
    Print("auratest build: in combat: %s", _G.InCombatLockdown() and "yes" or "no")
    local okHost, hostProtected = pcall(host.IsProtected, host)
    Print("  host RealUITargetFrame protected: %s", okHost and Describe(hostProtected) or "error")
    -- No label here: a second frame creation would muddy what the test measures.
    local container, steps = BuildContainer(host, spec)
    builtInCombat[#builtInCombat + 1] = { label = spec.label, container = container }
    ReportBuild("auratest " .. spec.label, container, steps)
    Print("  watch the chat for ADDON_ACTION_BLOCKED / FORBIDDEN lines and for Blizzard's popup.")
end

function ns.commands:auratest(arg)
    WatchBlockedActions()
    local reason = EngineReason()
    if reason and arg ~= "off" and arg ~= "status" then
        Print("auratest: %s.", reason)
        return
    end

    if arg == "refresh" then
        local n = 0
        for _, entry in ipairs(AllTestEntries()) do
            if entry.container and not entry.off then
                local ok, err = pcall(entry.container.UpdateAllAuras, entry.container)
                if ok then n = n + 1 else Print("  %s: UpdateAllAuras failed: %s", entry.label, Describe(err)) end
            end
        end
        Print("auratest refresh: UpdateAllAuras called on %d container(s).", n)
    elseif arg == "build" then
        BuildInCombat()
    elseif arg == "off" then
        local list = AllTestEntries()
        for _, entry in ipairs(list) do RetireContainer(entry) end
        Print("auratest off: %d container(s) disabled and hidden (the engine has no way to destroy them).", #list)
    elseif arg == "status" then
        Print("auratest status: in combat: %s", _G.InCombatLockdown() and "yes" or "no")
        local list = AllTestEntries()
        if #list == 0 then Print("  nothing built.") end
        for _, entry in ipairs(list) do ContainerStatus(entry) end
    elseif arg == nil or arg == "" then
        if #testEntries > 0 then
            for _, entry in ipairs(AllTestEntries()) do ReviveContainer(entry) end
            Print("auratest: already built; enabled and shown again.")
        else
            BuildBase()
        end
    else
        Print("usage: /realdev auratest [refresh | build | off | status]")
    end
end
