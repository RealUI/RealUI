local ADDON_NAME, ns = ... -- luacheck: ignore

--[[ B137 probe — are nameplate aura containers refusing frame ops during aura secrecy?

     Two questions, one command.

     (1) Is combat the right predicate for aura secrecy? RealUI_Nameplates assumes it is:
         RealUI_Nameplates.lua:349-350 refreshes on PLAYER_REGEN_ENABLED/DISABLED, and
         Texts.lua:127 states "health values stop being secret when combat drops". The
         WoWUIDev thread (EonWorm/p3lim, 2026-08-27) contradicts that — an
         InCombatLockdown() gate did NOT stop a secrecy error, and the real query is
         C_Secrets.ShouldAurasBeSecret(). `watch` mode logs both edges so the
         correlation is visible rather than assumed.

     (2) Are our container frame ops being refused? Auras.lua renders through Blizzard's
         secure AuraContainer intrinsic, so the containers are access-restricted Blizzard
         objects, not our own frames. Three call sites are UNGUARDED:
             Auras.lua:146  container:SetSize(1, 1)
             Auras.lua:171  container:ClearAllPoints()
             Auras.lua:172  container:SetPoint(...)
         EonWorm's error was exactly this shape:
             calling 'SetSize' on bad self (Attempt to access forbidden object
             from code tainted by an AddOn)
         ApplyPosition runs on every Auras.Attach, so a refusal there leaves the
         container unpositioned and the debuffs invisible — the reported symptom.

     Run it twice: out of combat, then in an instance while auras are secret. A row that
     reads ok/ok/ok in the first and REFUSED in the second is the answer.

     This probe is non-destructive: every op re-applies the value already in place, and
     ClearAllPoints only runs when the existing anchor was readable and can be restored. ]]

local CONTAINER_KEYS = { "myDebuffs", "buffs", "crowdControl" }

-- pcall wrapper that reports refusals rather than swallowing them.
local function Attempt(fn, ...)
    local ok, err = _G.pcall(fn, ...)
    if ok then return true, "ok" end
    -- Trim the file/line prefix; the refusal reason is the readable part.
    err = _G.tostring(err or "?"):gsub("^.-:%d+:%s*", "")
    return false, err
end

local function SecrecyState()
    local secret = "n/a"
    if _G.C_Secrets and _G.C_Secrets.ShouldAurasBeSecret then
        local ok, value = _G.pcall(_G.C_Secrets.ShouldAurasBeSecret)
        secret = ok and _G.tostring(value) or "ERR"
    end
    return secret
end

local function CombatState()
    local lockdown = _G.InCombatLockdown() and true or false
    local affecting = false
    local ok, value = _G.pcall(_G.UnitAffectingCombat, "player")
    if ok then affecting = value and true or false end
    return lockdown, affecting
end

local function PrintPredicates()
    local secret = SecrecyState()
    local lockdown, affecting = CombatState()
    local okI, _, iType = _G.pcall(_G.GetInstanceInfo)
    local instanceType = okI and iType or "?"

    _G.print(("|cff00ccff[B137]|r ShouldAurasBeSecret=|cffffff00%s|r  InCombatLockdown=%s  UnitAffectingCombat=%s  instance=%s")
        :format(secret, _G.tostring(lockdown), _G.tostring(affecting), _G.tostring(instanceType)))

    -- The whole point of finding (1): these can disagree.
    if secret ~= "n/a" and secret ~= "ERR" then
        local secretBool = (secret == "true")
        if secretBool ~= lockdown then
            _G.print("|cffffaa00[B137]|r  secrecy and combat DISAGREE — combat is not a valid proxy here")
        end
    end
end

-- Walk Blizzard's nameplates and find our plate, which AttachPlate parents to the base
-- (RealUI_Nameplates.lua:174). Avoids reaching into the addon's file-locals.
local function EachPlate(fn)
    local count = 0
    for _, base in _G.next, _G.C_NamePlate.GetNamePlates() do
        local okC, children = _G.pcall(function() return { base:GetChildren() } end)
        if okC then
            for _, child in _G.next, children do
                if _G.type(child) == "table" and _G.rawget(child, "Auras") and _G.rawget(child, "unit") then
                    count = count + 1
                    fn(child)
                end
            end
        end
    end
    return count
end

local function ProbeContainer(plate, key, container, tally)
    if not container then
        _G.print(("   %-13s |cffff5555MISSING|r — SetupContainer failed at creation"):format(key))
        tally.missing = tally.missing + 1
        return
    end

    local forbidden = "?"
    local okF, value = _G.pcall(container.IsForbidden, container)
    if okF then forbidden = _G.tostring(value) end

    local results = {}

    -- Auras.lua:146 — idempotent, this is the exact value the addon sets.
    local ok1, r1 = Attempt(container.SetSize, container, 1, 1)
    results[#results + 1] = "SetSize=" .. (ok1 and "ok" or ("|cffff5555" .. r1 .. "|r"))
    if not ok1 then tally.refused = tally.refused + 1 end

    -- Auras.lua:171-172 — only exercised when the current anchor can be read back, so a
    -- refusal mid-way cannot leave the container unanchored.
    local okP, point, rel, relPoint, x, y = _G.pcall(container.GetPoint, container, 1)
    if okP and point then
        local ok2, r2 = Attempt(container.ClearAllPoints, container)
        results[#results + 1] = "ClearAllPoints=" .. (ok2 and "ok" or ("|cffff5555" .. r2 .. "|r"))
        if not ok2 then tally.refused = tally.refused + 1 end

        local ok3, r3 = Attempt(container.SetPoint, container, point, rel, relPoint, x, y)
        results[#results + 1] = "SetPoint=" .. (ok3 and "ok" or ("|cffff5555" .. r3 .. "|r"))
        if not ok3 then
            tally.refused = tally.refused + 1
            _G.print("|cffff5555[B137]|r  SetPoint refused AFTER ClearAllPoints — container is now unanchored until the next Attach")
        end
    else
        results[#results + 1] = "SetPoint=|cffaaaaaaSKIP (anchor unreadable)|r"
    end

    -- Auras.lua:208/211-212 — re-assert whatever it already is.
    local okS, shown = _G.pcall(container.IsShown, container)
    if okS then
        local ok4, r4 = Attempt(container.SetShown, container, shown)
        results[#results + 1] = "SetShown=" .. (ok4 and "ok" or ("|cffff5555" .. r4 .. "|r"))
        if not ok4 then tally.refused = tally.refused + 1 end
    end

    _G.print(("   %-13s forbidden=%s shown=%s  %s")
        :format(key, forbidden, okS and _G.tostring(shown) or "?", _G.table.concat(results, "  ")))
end

local function RunSnapshot()
    _G.print("|cff00ccff[B137]|r ---- nameplate aura container probe ----")
    PrintPredicates()

    local tally = { missing = 0, refused = 0 }
    local plates = EachPlate(function(plate)
        local unit = _G.rawget(plate, "unit")
        local design = _G.rawget(plate, "design")
        _G.print((" plate |cff22dd22%s|r design=%s"):format(_G.tostring(unit), _G.tostring(design)))

        local containers = plate.Auras and plate.Auras.containers
        if not containers then
            _G.print("   |cffff5555no Auras.containers table|r")
            return
        end
        for _, key in _G.ipairs(CONTAINER_KEYS) do
            ProbeContainer(plate, key, containers[key], tally)
        end
    end)

    if plates == 0 then
        _G.print("|cffffaa00[B137]|r no RealUI plates found — target something, or Platynator may have disabled the module")
        return false
    end

    _G.print(("|cff00ccff[B137]|r %d plate(s); %d container(s) missing, %d op(s) refused")
        :format(plates, tally.missing, tally.refused))
    if tally.refused > 0 then
        _G.print("|cffff5555[B137]|r REFUSALS PRESENT — Auras.lua:146/171/172 need guarding; this matches the reported symptom")
    end
    return tally.refused == 0 and tally.missing == 0
end

--[[ watch mode — does secrecy actually track combat? ]]--

local watcher, watchFrame
local last = {}

local function WatchTick()
    local secret = SecrecyState()
    local lockdown, affecting = CombatState()
    if secret ~= last.secret or lockdown ~= last.lockdown or affecting ~= last.affecting then
        _G.print(("|cff00ccff[B137 watch]|r %.1f  secret=|cffffff00%s|r lockdown=%s affecting=%s")
            :format(_G.GetTime() % 1000, secret, _G.tostring(lockdown), _G.tostring(affecting)))
        if last.secret and secret ~= last.secret and lockdown == last.lockdown then
            _G.print("|cffffaa00[B137 watch]|r  secrecy changed WITHOUT a combat edge — the combat proxy is wrong")
        end
        last.secret, last.lockdown, last.affecting = secret, lockdown, affecting
    end
end

local function ToggleWatch()
    if watcher then
        watcher:Cancel()
        watcher = nil
        if watchFrame then watchFrame:UnregisterAllEvents() end
        _G.print("|cff00ccff[B137]|r watch stopped")
        return
    end

    last = {}
    if not watchFrame then
        watchFrame = _G.CreateFrame("Frame")
        watchFrame:SetScript("OnEvent", function(_, event)
            _G.print(("|cff00ccff[B137 watch]|r %.1f  event=%s secret=%s")
                :format(_G.GetTime() % 1000, event, SecrecyState()))
        end)
    end
    watchFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    watchFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

    watcher = _G.C_Timer.NewTicker(0.25, WatchTick)
    _G.print("|cff00ccff[B137]|r watch started — logs every secrecy/combat edge. Run again to stop.")
    WatchTick()
end

function ns.commands:aurasecrecy(arg)
    if arg == "watch" then
        return ToggleWatch()
    end
    return RunSnapshot()
end
