local _, ns = ...

--[[ RealUI Forever beta bootstrap — TEMPORARY, gated on the Forever client.

     The Forever beta discards addon SavedVariables (writes and reads), so
     every login starts from defaults and the install wizard runs again. This
     replays a chosen configuration from CODE at each login instead:

       1. imports "Export all linked" profile string(s) (core + skins + action
          bars — RealUI_Config → Profiles → Export all linked),
       2. sets the display preset, layout and Naga choice,
       3. runs InstallWizard:Complete(), the exact routine the wizard's last
          page runs, so RealUI's login gate sees an initialised character.

     The configuration lives in Profile.lua next to this file, which each
     tester writes from Profile.example.lua and which is never shipped. With
     no Profile.lua, step 3 still runs: stock settings, no wizard.

     Delete this addon once Blizzard fixes SavedVariables on the beta. ]]--

local interface = select(4, _G.GetBuildInfo())
if not (interface >= 16000 and interface < 20000) then return end

local prefix = "|cffff8800RealUI Forever bootstrap|r: "
local function Say(msg) _G.print(prefix .. msg) end

local function Bootstrap()
    local RealUI = _G.RealUI
    if not (RealUI and RealUI.db and RealUI.InstallWizard and RealUI.ProfileExporter) then
        Say("RealUI is not initialised; nothing applied.")
        return
    end

    local cfg = ns.profile
    if type(cfg) ~= "table" then
        Say("no Profile.lua found; completing the install with stock settings. See Profile.example.lua to bring your own.")
        cfg = {}
    end

    -- 1. Profiles from the export string(s). `export` is one string or a
    -- list of them: "Export all linked" only carries the scopes that were
    -- linked at the time, so an unlinked Skins scope comes as its own export.
    local exports = cfg.export
    if type(exports) == "string" then exports = { exports } end
    for _, raw in _G.ipairs(type(exports) == "table" and exports or {}) do
        if type(raw) == "string" then
            -- Long-bracket pastes carry CRs and surrounding blank lines; the
            -- exporter wants "HEADER\nBODY" with the header on the first line.
            local export = raw:gsub("\r", ""):gsub("^%s+", ""):gsub("%s+$", "")
            local ok, result = RealUI.ProfileExporter:Import(export)
            if ok then
                Say("imported profile scopes: " .. _G.table.concat(result, ", "))
            else
                local header = export:match("^[^\n]*") or ""
                local body = export:match("\n(.*)$") or ""
                local bodyLen = #(body:gsub("%s", ""))
                Say(("profile import failed: %s (header %q, body %d chars)"):format(
                    _G.tostring(result), header:sub(1, 60), bodyLen))
            end
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
        -- Complete() reads this flat off the wizard state, the way the wizard
        -- UI writes it; SetStageData files it under the current stage instead.
        local state = RealUI.InstallWizard.GetState and RealUI.InstallWizard:GetState()
        if state and state.stageData then
            state.stageData.enableNagaBar = cfg.naga and true or false
        end
        -- Complete() only reaches bar 6 through an enabled RealUI_ActionBars;
        -- otherwise it skips it silently, so say so here.
        local AB = _G.LibStub("AceAddon-3.0"):GetAddon("RealUIActionBars", true)
        if not (AB and AB:IsEnabled()) then
            Say("RealUI_ActionBars is not enabled; the Naga setting cannot be applied.")
        end
    end

    -- 3. Complete the install exactly as the wizard's last page does.
    local ok, err = _G.pcall(RealUI.InstallWizard.Complete, RealUI.InstallWizard)
    if ok then
        Say("install marked complete; the wizard is bypassed for this session.")
    else
        Say("InstallWizard:Complete() failed: " .. _G.tostring(err))
    end

    -- RealUI's login gate already scheduled InstallWizard:Start() on a 1 s
    -- timer, and Start decides from the isFirstTime snapshot Initialize() took
    -- before Complete ran. Refresh the snapshot, and hide the frame if the
    -- timer still shows it.
    RealUI.InstallWizard:Initialize()
    _G.C_Timer.After(1.5, function()
        if RealUI.InstallUI and RealUI.InstallUI:IsShown() then
            RealUI.InstallUI:Hide()
        end
    end)
end

local frame = _G.CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    -- Run on the next frame, after every PLAYER_LOGIN handler. AceAddon
    -- enables all addons from its own PLAYER_LOGIN handler, and handler order
    -- is not ours to rely on: run before it and RealUI.db exists (that is
    -- OnInitialize) but RealUI_ActionBars is not enabled yet, so the Naga
    -- choice in Complete() is dropped without a word. RealUI's wizard start
    -- is on a 1 s timer, so the next frame still wins that race.
    _G.C_Timer.After(0, Bootstrap)
end)
