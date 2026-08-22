local _, private = ...
local AB = private.AB

--[[ One-time Bartender4 layout import (spec req 10.2). Pure data copy from the
     user's own SavedVariables — no BT4 code involved. RealUI historically wrote
     computed positions INTO Bartender4DB, so importing them reproduces the
     exact layout the user had.

     Coordinate note: BT4 stores screen-space offsets and divides by bar scale
     at apply time; our SetPoint offsets live in the bar's scaled space, so the
     same division happens here at import time instead. ]]--

local function ImportBar(target, source)
    if not source then return false end

    if source.enabled ~= nil then target.enabled = source.enabled end
    if source.buttons then target.buttons = source.buttons end
    if source.rows then target.rows = source.rows end
    if source.padding then target.padding = source.padding end
    if source.hidemacrotext ~= nil then target.hidemacrotext = source.hidemacrotext end
    if source.showgrid ~= nil then target.showgrid = source.showgrid end
    if source.flyoutDirection then target.flyoutDirection = source.flyoutDirection end
    if source.fadeoutalpha then target.fadeoutalpha = source.fadeoutalpha end

    local pos = source.position
    if pos and pos.point then
        local scale = pos.scale or 1
        target.scale = scale
        -- BT4 buttons are 36px base; size parity comes from base * scale.
        target.buttonSize = 36
        target.position.point = pos.point
        target.position.x = (pos.x or 0) / scale
        target.position.y = (pos.y or 0) / scale
        if pos.growHorizontal then target.growHorizontal = pos.growHorizontal end
        if pos.growVertical then target.growVertical = pos.growVertical end
    end

    local vis = source.visibility
    if vis and vis.custom and vis.customdata and vis.customdata ~= "" then
        -- BT4's custom strings end in show/hide; our grammar adds fade — a
        -- trailing "…show;fade" pattern survives as-is.
        target.visibility = vis.customdata
    end

    return true
end

--[[ Keybind conversion. Unlike Bartender4DB (addon SavedVariables, only in
     memory while BT4 loads), keybinds live in the CLIENT's binding system as
     plain command->key maps — "CLICK BT4Button1:Keybind" survives with the
     addon gone, and GetBindingKey answers from the saved bindings any time.
     Bar 1 note: BT4 preferred the Blizzard ACTIONBUTTON bindings there, which
     our mirror already honors; the CLICK binds converted here are the extras
     users bound directly to BT4 buttons. Stance/pet used SHAPESHIFTBUTTON /
     BONUSACTIONBUTTON (still live on our adopted Blizzard buttons) with CLICK
     fallbacks, converted here to the adopted buttons' names. ]]--

function private.ImportBartender4Keybinds()
    local bindings = AB.db.profile.bindings
    local claimed = {}
    for _, key in _G.next, bindings do claimed[key] = true end

    local imported = 0
    local function convert(command, targetButton)
        local keys = { _G.GetBindingKey(command) }
        for k = 1, #keys do
            local key = keys[k]
            if key and not claimed[key] and not bindings[targetButton] then
                bindings[targetButton] = key
                claimed[key] = true
                imported = imported + 1
            end
        end
    end

    for id = 1, 72 do  -- bars 1-6
        local bar = _G.math.ceil(id / 12)
        local btn = (id - 1) % 12 + 1
        convert(("CLICK BT4Button%d:Keybind"):format(id),
            ("RealUI_AB_Bar%dB%d"):format(bar, btn))
    end
    for i = 1, 10 do
        convert(("CLICK BT4StanceButton%d:LeftButton"):format(i), "StanceButton" .. i)
        convert(("CLICK BT4PetButton%d:LeftButton"):format(i), "PetActionButton" .. i)
    end

    return imported
end

--- @param manual boolean     user typed /rab import (chattier on no-ops)
--- @param deferApply boolean called before the bars exist (OnInitialize) —
---        write the DB only; the normal build path reads it moments later.
function private.ImportFromBartender4(manual, deferApply)
    -- Keybinds first: they need no Bartender4 data at all.
    local importedKeys = private.ImportBartender4Keybinds()
    if importedKeys > 0 then
        if not deferApply then
            private.QueueSecure(private.ApplyBindings)
        end
        _G.print(("|cff30d0ffRealUI ActionBars|r: converted %d Bartender4 keybinds."):format(importedKeys))
    end

    local bt4db = _G.Bartender4DB
    if not (bt4db and bt4db.namespaces and bt4db.namespaces.ActionBars) then
        if manual then
            _G.print("|cff30d0ffRealUI ActionBars|r: no Bartender4 profile data in memory (layout import needs BT4 installed once)."
                .. (importedKeys > 0 and "" or " No BT4 keybinds found either."))
        end
        return
    end

    -- Prefer this character's BT4 profile; fall back to the RealUI defaults.
    local charKey = _G.UnitName("player") .. " - " .. _G.GetRealmName()
    local profileName = (bt4db.profileKeys and bt4db.profileKeys[charKey])
        or "RealUI"
    local profiles = bt4db.namespaces.ActionBars.profiles
    local source = profiles and (profiles[profileName] or profiles["RealUI"])
    if not (source and source.actionbars) then
        if manual then
            _G.print(("|cff30d0ffRealUI ActionBars|r: Bartender4 profile %q has no action bar data."):format(profileName))
        end
        return
    end

    local imported = 0
    for id = 1, 6 do
        if ImportBar(AB.dbActionBars.profile.actionbars[id], source.actionbars[id]) then
            imported = imported + 1
        end
    end

    AB.db.global.importedBT4 = true
    if not deferApply then
        private.QueueSecure(private.ApplyAllBars)
    end
    _G.print(("|cff30d0ffRealUI ActionBars|r: imported %d bars from Bartender4 profile %q."):format(imported, profileName))
end

--[[ One-shot automatic conversion, run from OnInitialize.

     Timing is the whole point. `Bartender4DB` only exists in memory while the
     Bartender4 addon is installed and enabled, and RealUI_ActionBars stands
     DOWN (disables itself) whenever BT4 is loaded — so OnEnable is far too
     late: by the time RAB runs for real, the user has removed BT4 and their
     layout is unreachable. Initialize always runs, before that decision, so
     this is the one moment both DBs are visible at once.

     Bars do not exist yet at init, hence deferApply: the values land in the
     DB and the normal build path picks them up moments later.

     `/rab import` stays for manual re-runs (and is registered at file scope,
     so it still works while RAB is stood down). ]]--
function private.MaybeImportFromBartender4()
    if AB.db.global.importedBT4 then return end
    if not _G.Bartender4DB then return end
    private.ImportFromBartender4(false, true)
end
