local _, private = ...

-- Lua Globals --
local next = _G.next
local type = _G.type

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, dbc, dbg
local debug = RealUI.GetDebug("Settings")

local function IsVersionTable(ver)
    return type(ver) == "table" and type(ver[1]) == "number" and type(ver[2]) == "number" and type(ver[3]) == "number"
end

local function IsPatchVersionInRange(patchVersion, oldVer, curVer)
    if not (IsVersionTable(patchVersion) and IsVersionTable(oldVer) and IsVersionTable(curVer)) then
        return false
    end
    return RealUI:CompareVersions(patchVersion, oldVer) == 1 and RealUI:CompareVersions(patchVersion, curVer) <= 0
end

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
    local patchVersions = RealUI.minipatchVersions or {}

    -- Find out which Mini Patches are needed
    local patches = {}
    local queuedPatchIds = {}

    local function QueuePatch(index)
        if queuedPatchIds[index] or type(minipatches[index]) ~= "function" then
            return
        end
        queuedPatchIds[index] = true
        _G.tinsert(patches, minipatches[index])
    end

    local patchIds = {}
    for patchId, patchFunc in next, minipatches do
        if type(patchId) == "number" and patchId > 0 and type(patchFunc) == "function" then
            local patchVersion = patchVersions[patchId]
            if IsPatchVersionInRange(patchVersion, oldVer, curVer) then
                _G.tinsert(patchIds, patchId)
            elseif not IsVersionTable(patchVersion) then
                -- Legacy fallback for unmapped minipatches: only apply within same major.minor stream.
                if oldVer[1] == curVer[1] and oldVer[2] == curVer[2] and oldVer[3] then
                    if patchId > oldVer[3] and patchId <= curVer[3] then
                        _G.tinsert(patchIds, patchId)
                    end
                end
            end
        end
    end

    _G.table.sort(patchIds, function(a, b)
        local aVer = patchVersions[a]
        local bVer = patchVersions[b]
        if IsVersionTable(aVer) and IsVersionTable(bVer) then
            local cmp = RealUI:CompareVersions(aVer, bVer)
            if cmp ~= 0 then
                return cmp < 0
            end
        elseif IsVersionTable(aVer) then
            return true
        elseif IsVersionTable(bVer) then
            return false
        end
        return a < b
    end)

    debug("minipatch", newVer, oldVer[3], curVer[3])
    if newVer then
        if minipatches[0] then
            QueuePatch(0)
        end
    end

    for i = 1, #patchIds do
        debug("queueing", patchIds[i])
        QueuePatch(patchIds[i])
    end


    debug("TOC minipatch", dbg.patchedTOC, RealUI.TOC)
    if dbg.patchedTOC ~= RealUI.TOC then
        if dbg.patchedTOC > 0 and minipatches[RealUI.TOC] then
            -- Add minipatch for TOC change
            QueuePatch(RealUI.TOC)
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
