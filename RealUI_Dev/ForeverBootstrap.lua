local _, ns = ...

--[[ WoW Forever dev bootstrap — TEMPORARY, gated on the Forever client.

     The Forever beta discards addon SavedVariables (writes and reads), so
     every login starts from defaults and the install wizard runs again. This
     replays a chosen configuration from CODE at each login instead:

       1. imports an "Export all linked" profile string (core + skins + action
          bars — RealUI_Config → Profiles → Export all linked),
       2. sets the display preset, layout and Naga choice,
       3. runs InstallWizard:Complete(), the exact routine the wizard's last
          page runs, so RealUI's login gate sees an initialised character.

     The configuration lives in RealUI_Dev/local/ForeverProfile.lua, which is
     gitignored (it is personal). See ForeverProfile.example.lua for the shape.
     Remove this file and its TOC line once Blizzard fixes SavedVariables on
     the beta. ]]--

local interface = select(4, _G.GetBuildInfo())
if not (interface >= 16000 and interface < 20000) then return end

local prefix = "|cffff8800RealUI Forever bootstrap|r: "
local function Say(msg) _G.print(prefix .. msg) end

local function Bootstrap()
    local cfg = _G.RealUI_Dev_ForeverProfile
    if type(cfg) ~= "table" then
        Say("no RealUI_Dev/local/ForeverProfile.lua found; the wizard will run. See ForeverProfile.example.lua.")
        return
    end

    local RealUI = _G.RealUI
    if not (RealUI and RealUI.db and RealUI.InstallWizard and RealUI.ProfileExporter) then
        Say("RealUI is not initialised; nothing applied.")
        return
    end

    -- 1. Profiles (core, skins, action bars) from the export string.
    if type(cfg.export) == "string" and cfg.export ~= "" then
        local ok, result = RealUI.ProfileExporter:Import(cfg.export)
        if ok then
            Say("imported profile scopes: " .. _G.table.concat(result, ", "))
        else
            Say("profile import failed: " .. _G.tostring(result))
        end
    end

    -- 2. Choices the wizard would have collected.
    local dbg = RealUI.db.global
    if cfg.displayPreset and dbg.display then
        dbg.display.presetId = cfg.displayPreset
        if RealUI.DisplayPresets and RealUI.DisplayPresets.ApplyStored then
            _G.pcall(RealUI.DisplayPresets.ApplyStored)
        end
    end
    if cfg.layout and RealUI.db.char.layout then
        RealUI.db.char.layout.current = cfg.layout
        RealUI.cLayout = cfg.layout
    end
    if cfg.naga ~= nil then
        RealUI.InstallWizard:SetStageData("enableNagaBar", cfg.naga and true or false)
    end

    -- 3. Complete the install exactly as the wizard's last page does.
    local ok, err = _G.pcall(RealUI.InstallWizard.Complete, RealUI.InstallWizard)
    if ok then
        Say("install marked complete; the wizard is bypassed for this session.")
    else
        Say("InstallWizard:Complete() failed: " .. _G.tostring(err))
    end
end

local frame = _G.CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    -- RealUI's own login work runs from AceAddon's PLAYER_LOGIN handler, which
    -- was registered before this frame, so RealUI.db is ready here; its wizard
    -- start is on a 1 s timer, so completing now wins the race.
    Bootstrap()
end)

ns.ForeverBootstrap = Bootstrap
