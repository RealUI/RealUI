-- EditMode Layout Dump Utility
-- Usage: /editmodedump
-- Dumps the current "RealUI" EditMode layout to chat (or LibTextDump if available)
-- Use this to identify which systems/indices exist in the live game
-- and compare against our EditModeTemplates.base

local _, private = ...
local RealUI = private.RealUI

local SYSTEM_NAMES = {
    [0] = "ActionBar",
    [1] = "CastBar",
    [2] = "Minimap",
    [3] = "UnitFrame",
    [4] = "EncounterBar",
    [5] = "ExtraAbilities",
    [6] = "AuraFrame",
    [7] = "TalkingHeadFrame",
    [8] = "ChatFrame",
    [9] = "VehicleLeaveButton",
    [10] = "LootFrame",
    [11] = "HudTooltip",
    [12] = "ObjectiveTracker",
    [13] = "MicroMenu",
    [14] = "Bags",
    [15] = "StatusTrackingBar",
    [16] = "DurabilityFrame",
    [17] = "TimerBars",
    [18] = "VehicleSeatIndicator",
    [19] = "ArchaeologyBar",
    [20] = "CooldownViewer",
    [21] = "PersonalResourceDisplay",
    [22] = "EncounterEvents",
    [23] = "DamageMeter",
    -- New systems added in 12.0.x (not yet in wiki)
    [24] = "BossWarnings",
    [25] = "ExternalDefensives",
}

local function DumpLayout(layoutName)
    layoutName = layoutName or "RealUI"

    if not C_EditMode or not C_EditMode.GetLayouts then
        print("|cffff4444EditMode API not available yet.|r")
        return
    end

    local data = C_EditMode.GetLayouts()
    if not data or not data.layouts then
        print("|cffff4444No layout data returned.|r")
        return
    end

    -- Find the target layout
    local targetLayout
    for _, layout in ipairs(data.layouts) do
        if layout.layoutName == layoutName then
            targetLayout = layout
            break
        end
    end

    if not targetLayout then
        -- List available layouts
        print("|cffff4444Layout '" .. layoutName .. "' not found. Available:|r")
        for i, layout in ipairs(data.layouts) do
            print(("  [%d] %s (type=%d)"):format(i, layout.layoutName, layout.layoutType))
        end
        print(("  Active layout index: %d"):format(data.activeLayout))
        return
    end

    -- Try to use LibTextDump for large output
    local dump
    local LTD = LibStub and LibStub("LibTextDump-1.0", true)
    if LTD then
        dump = LTD:New("EditMode: " .. layoutName, 700, 500)
    end

    local function Output(text)
        if not text or text == "" then text = " " end
        if dump then
            dump:AddLine(text)
        else
            print(text)
        end
    end

    Output(("=== EditMode Layout: %s (type=%d) ==="):format(
        targetLayout.layoutName, targetLayout.layoutType))
    Output(("Total system entries: %d"):format(#targetLayout.systems))
    Output("")

    -- Track which systems we see
    local seenSystems = {}

    for i, sys in ipairs(targetLayout.systems) do
        local sysName = SYSTEM_NAMES[sys.system] or ("UNKNOWN_" .. sys.system)
        local idxStr = sys.systemIndex and tostring(sys.systemIndex) or "nil"
        local key = sys.system .. "_" .. idxStr

        seenSystems[key] = true

        local anchor = sys.anchorInfo
        local settingsStr = ""
        if sys.settings and #sys.settings > 0 then
            local parts = {}
            for _, s in ipairs(sys.settings) do
                parts[#parts + 1] = ("[%d]=%d"):format(s.setting, s.value)
            end
            settingsStr = " settings={" .. table.concat(parts, ",") .. "}"
        end

        Output(("[%2d] system=%d(%s) idx=%-4s | %s->%s(%s) oX=%.0f oY=%.0f def=%s%s"):format(
            i,
            sys.system, sysName,
            idxStr,
            anchor.point,
            anchor.relativePoint,
            anchor.relativeTo,
            anchor.offsetX,
            anchor.offsetY,
            tostring(sys.isInDefaultPosition),
            settingsStr
        ))
    end

    Output("")
    Output("=== Systems NOT in our template (system > 23 or unexpected indices) ===")

    -- Our template covers these keys:
    local templateKeys = {
        -- ActionBars 1-8, 11-13
        ["0_1"]=true, ["0_2"]=true, ["0_3"]=true, ["0_4"]=true,
        ["0_5"]=true, ["0_6"]=true, ["0_7"]=true, ["0_8"]=true,
        ["0_11"]=true, ["0_12"]=true, ["0_13"]=true,
        -- CastBar
        ["1_nil"]=true,
        -- Minimap
        ["2_nil"]=true,
        -- UnitFrames 1-8
        ["3_1"]=true, ["3_2"]=true, ["3_3"]=true, ["3_4"]=true,
        ["3_5"]=true, ["3_6"]=true, ["3_7"]=true, ["3_8"]=true,
        -- EncounterBar
        ["4_nil"]=true,
        -- ExtraAbilities
        ["5_nil"]=true,
        -- AuraFrame 1-3
        ["6_1"]=true, ["6_2"]=true, ["6_3"]=true,
        -- TalkingHead
        ["7_nil"]=true,
        -- ChatFrame
        ["8_nil"]=true,
        -- VehicleLeave
        ["9_nil"]=true,
        -- LootFrame
        ["10_nil"]=true,
        -- HudTooltip
        ["11_nil"]=true,
        -- ObjectiveTracker
        ["12_nil"]=true,
        -- MicroMenu
        ["13_nil"]=true,
        -- Bags
        ["14_nil"]=true,
        -- StatusTrackingBar 1-2
        ["15_1"]=true, ["15_2"]=true,
        -- DurabilityFrame
        ["16_nil"]=true,
        -- TimerBars
        ["17_nil"]=true,
        -- VehicleSeatIndicator
        ["18_nil"]=true,
        -- ArchaeologyBar
        ["19_nil"]=true,
        -- CooldownViewer 1-4
        ["20_1"]=true, ["20_2"]=true, ["20_3"]=true, ["20_4"]=true,
        -- PersonalResourceDisplay
        ["21_nil"]=true,
        -- EncounterEvents 1-4
        ["22_1"]=true, ["22_2"]=true, ["22_3"]=true, ["22_4"]=true,
        -- DamageMeter
        ["23_nil"]=true,
    }

    local missing = {}
    for key in pairs(seenSystems) do
        if not templateKeys[key] then
            missing[#missing + 1] = key
        end
    end

    table.sort(missing)
    if #missing == 0 then
        Output("  (none — all systems accounted for)")
    else
        for _, key in ipairs(missing) do
            local sys, idx = key:match("^(%d+)_(.+)$")
            local sysName = SYSTEM_NAMES[tonumber(sys)] or ("UNKNOWN_" .. sys)
            Output(("  MISSING: system=%s(%s) systemIndex=%s"):format(sys, sysName, idx))
        end
    end

    Output("")
    Output("=== Template keys NOT found in live layout ===")
    local extra = {}
    for key in pairs(templateKeys) do
        if not seenSystems[key] then
            extra[#extra + 1] = key
        end
    end
    table.sort(extra)
    if #extra == 0 then
        Output("  (none — all template entries exist in live data)")
    else
        for _, key in ipairs(extra) do
            local sys, idx = key:match("^(%d+)_(.+)$")
            local sysName = SYSTEM_NAMES[tonumber(sys)] or ("UNKNOWN_" .. sys)
            Output(("  EXTRA in template: system=%s(%s) systemIndex=%s"):format(sys, sysName, idx))
        end
    end

    if dump then
        dump:Display()
    end
end

-- Also dump the Blizzard default (active) layout for comparison
local function DumpActiveLayout()
    if not C_EditMode or not C_EditMode.GetLayouts then
        print("|cffff4444EditMode API not available yet.|r")
        return
    end

    local data = C_EditMode.GetLayouts()
    print(("Active layout index: %d (built-in count: 2, so custom start at 3)"):format(data.activeLayout))
    print(("Custom layouts: %d"):format(#data.layouts))
    for i, layout in ipairs(data.layouts) do
        print(("  [%d] '%s' type=%d systems=%d"):format(
            i, layout.layoutName, layout.layoutType, #layout.systems))
    end
end

-- Export a layout as Lua code ready to paste into EditModeTemplates.lua
local function ExportLayout(layoutName)
    layoutName = layoutName or "RealUI"

    if not C_EditMode or not C_EditMode.GetLayouts then
        print("|cffff4444EditMode API not available yet.|r")
        return
    end

    local data = C_EditMode.GetLayouts()
    local targetLayout
    for _, layout in ipairs(data.layouts) do
        if layout.layoutName == layoutName then
            targetLayout = layout
            break
        end
    end

    if not targetLayout then
        print("|cffff4444Layout '" .. layoutName .. "' not found.|r")
        return
    end

    local LTD = LibStub and LibStub("LibTextDump-1.0", true)
    if not LTD then
        print("|cffff4444LibTextDump-1.0 required for export.|r")
        return
    end

    local dump = LTD:New("EditMode Export: " .. layoutName, 800, 600)

    dump:AddLine("-- EditMode Template Export")
    dump:AddLine("-- Layout: " .. layoutName .. " (type=" .. targetLayout.layoutType .. ")")
    dump:AddLine("-- Exported: " .. date("%Y-%m-%d %H:%M:%S"))
    dump:AddLine("-- Paste this into EditModeTemplates.lua as Templates.base")
    dump:AddLine("--")
    dump:AddLine("-- SYSTEM ENUM: 0=ActionBar, 1=CastBar, 2=Minimap, 3=UnitFrame,")
    dump:AddLine("-- 4=EncounterBar, 5=ExtraAbilities, 6=AuraFrame, 7=TalkingHead,")
    dump:AddLine("-- 8=ChatFrame, 9=VehicleLeave, 10=LootFrame, 11=HudTooltip,")
    dump:AddLine("-- 12=ObjectiveTracker, 13=MicroMenu, 14=Bags, 15=StatusTrackingBar,")
    dump:AddLine("-- 16=DurabilityFrame, 17=TimerBars, 18=VehicleSeat, 19=ArchaeologyBar,")
    dump:AddLine("-- 20=CooldownViewer, 21=PersonalResourceDisplay, 22=EncounterEvents,")
    dump:AddLine("-- 23=DamageMeter")
    dump:AddLine(" ")
    dump:AddLine("Templates.base = {")

    for i, sys in ipairs(targetLayout.systems) do
        local sysName = SYSTEM_NAMES[sys.system] or ("UNKNOWN_" .. sys.system)
        local idxStr = sys.systemIndex and tostring(sys.systemIndex) or "nil"
        local anchor = sys.anchorInfo

        -- Build settings string
        local settingsStr = "{}"
        if sys.settings and #sys.settings > 0 then
            local parts = {}
            for _, s in ipairs(sys.settings) do
                parts[#parts + 1] = ("{ setting = %d, value = %d }"):format(s.setting, s.value)
            end
            settingsStr = "{\n            " .. table.concat(parts, ",\n            ") .. ",\n        }"
        end

        -- Build the entry
        dump:AddLine(("    -- [%d] %s (idx=%s)"):format(i, sysName, idxStr))
        dump:AddLine(("    Entry(%d, %s,"):format(sys.system, sys.systemIndex and tostring(sys.systemIndex) or "nil"))
        dump:AddLine(("        Anchor(%q, %q, %q, %s, %s),"):format(
            anchor.point,
            anchor.relativeTo,
            anchor.relativePoint,
            tostring(anchor.offsetX),
            tostring(anchor.offsetY)
        ))
        dump:AddLine(("        %s),"):format(settingsStr))
    end

    dump:AddLine("}")
    dump:Display()
end

-- Register slash commands
if RealUI and RealUI.RegisterChatCommand then
    RealUI:RegisterChatCommand("editmodedump", function(input)
        if input == "active" then
            DumpActiveLayout()
        elseif input == "compare" then
            -- Dump the first layout that has 50 entries for comparison
            local data = C_EditMode.GetLayouts()
            for _, layout in ipairs(data.layouts) do
                if #layout.systems > 39 then
                    DumpLayout(layout.layoutName)
                    return
                end
            end
            print("No layout with >39 entries found. Dumping RealUI instead.")
            DumpLayout("RealUI")
        elseif input and input ~= "" then
            DumpLayout(input)
        else
            DumpLayout("RealUI")
        end
    end)
    RealUI:RegisterChatCommand("editmodeexport", function(input)
        if input and input ~= "" then
            ExportLayout(input)
        else
            ExportLayout("RealUI")
        end
    end)
    RealUI:RegisterChatCommand("editmodelist", DumpActiveLayout)
else
    -- Fallback: register via global slash command
    SLASH_EDITMODEDUMP1 = "/editmodedump"
    SlashCmdList["EDITMODEDUMP"] = function(input)
        if input == "active" then
            DumpActiveLayout()
        elseif input == "compare" then
            local data = C_EditMode.GetLayouts()
            for _, layout in ipairs(data.layouts) do
                if #layout.systems > 39 then
                    DumpLayout(layout.layoutName)
                    return
                end
            end
            print("No layout with >39 entries found. Dumping RealUI instead.")
            DumpLayout("RealUI")
        elseif input and input ~= "" then
            DumpLayout(input)
        else
            DumpLayout("RealUI")
        end
    end
    SLASH_EDITMODEEXPORT1 = "/editmodeexport"
    SlashCmdList["EDITMODEEXPORT"] = function(input)
        if input and input ~= "" then
            ExportLayout(input)
        else
            ExportLayout("RealUI")
        end
    end
    SLASH_EDITMODELIST1 = "/editmodelist"
    SlashCmdList["EDITMODELIST"] = DumpActiveLayout
end
