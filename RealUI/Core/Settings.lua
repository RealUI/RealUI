local _, private = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, dbc, dbg
local debug = RealUI.GetDebug("Settings")

-- Mini Patch
local function ApplyMiniPatches(patches)
    for i = 1, #patches do
        patches[i]()
    end

    -- Set version info
    dbg.verinfo = {}
    for k,v in next, RealUI.verinfo do
        dbg.verinfo[k] = v
    end
end

local function MiniPatchInstallation(newVer)
    local curVer = RealUI.verinfo
    local oldVer = dbg.verinfo
    local minipatches = RealUI.minipatches

    -- Find out which Mini Patches are needed
    local patches = {}

    debug("minipatch", newVer, oldVer[3], curVer[3])
    if newVer then
        if minipatches[0] then
            _G.tinsert(patches, minipatches[0])
        end
        -- Cross-major-version: also run all patch-level minipatches (1..curVer[3])
        -- since the user skipped all intermediate patches during the major version jump
        for i = 1, curVer[3] do
            if minipatches[i] then
                _G.tinsert(patches, minipatches[i])
            end
        end
    else
        if oldVer[3] then
            for i = oldVer[3] + 1, curVer[3] do
                debug("checking", i)
                if minipatches[i] then
                    -- This needs to be an array to ensure patches are applied sequentially.
                    _G.tinsert(patches, minipatches[i])
                end
            end
        end
    end


    debug("TOC minipatch", dbg.patchedTOC, RealUI.TOC)
    if dbg.patchedTOC ~= RealUI.TOC then
        if dbg.patchedTOC > 0 and minipatches[RealUI.TOC] then
            -- Add minipatch for TOC change
            _G.tinsert(patches, minipatches[RealUI.TOC])
        end
        dbg.patchedTOC = RealUI.TOC
    end

    debug("numPatches", #patches)
    if #patches > 0 then
        _G.StaticPopupDialogs["PUDRUIMP"] = {
            text = "|cff85e0ff"..L["Patch_MiniPatch"].."|r\n\n|cffffffff"..L["Patch_DoApply"],
            button1 = _G.OKAY,
            OnAccept = function()
                ApplyMiniPatches(patches)
                _G.ReloadUI()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = false,
            notClosableByLogout = false,
        }
        _G.StaticPopup_Show("PUDRUIMP")
    end
end

-- Install Procedure
function RealUI:InstallProcedure()
    debug("InstallProcedure", RealUI.db.char.init.installStage)
    db = self.db.profile
    dbc = self.db.char
    dbg = self.db.global

    ---- Version checking
    local curVer = RealUI.verinfo
    local oldVer = (dbg.verinfo[1] and dbg.verinfo) or RealUI.verinfo
    local newVer = RealUI:GetVersionChange(oldVer, curVer)
    debug("Version", curVer, oldVer, newVer)

    db.registeredChars[self.key] = true
    dbg.minipatches = nil

    -- Initialize installation wizard if available
    if self.InstallWizard then
        self.InstallWizard:Initialize()
    end

    -- Initialize character initialization system if available
    if self.CharacterInit then
        self.CharacterInit:Initialize()
    end

    -- Initialize tutorial system if available
    if self.TutorialSystem then
        self.TutorialSystem:Initialize()
    end

    -- Primary Stages
    -- Bug 5 fix (7.3): Profile forcing (via the wizard) only runs when
    -- installStage != -1. After setup is complete (installStage == -1),
    -- only minipatches run — no profile forcing occurs here.
    debug("Stage", dbc.init.installStage)
    if dbc.init.installStage > -1 then
        -- Delay showing the wizard to allow UI to fully load
        _G.C_Timer.After(1, function()
            self.InstallWizard:Start()
        end)
    else
        -- Bug 7 fix (9.2): Set setupVersion for existing characters that were
        -- configured before SetupSystem was introduced, preventing NeedsSetup
        -- from re-triggering the wizard on every login.
        local SetupSystem = RealUI.SetupSystem
        if SetupSystem and not dbg[SetupSystem.SETUP_VERSION_KEY] then
            dbg[SetupSystem.SETUP_VERSION_KEY] = SetupSystem.CURRENT_VERSION
        end

        MiniPatchInstallation(newVer)
    end
end
