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

function private.ImportFromBartender4(manual)
    local bt4db = _G.Bartender4DB
    if not (bt4db and bt4db.namespaces and bt4db.namespaces.ActionBars) then
        if manual then
            _G.print("|cff30d0ffRealUI ActionBars|r: no Bartender4 saved variables found.")
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
    private.QueueSecure(private.ApplyAllBars)
    _G.print(("|cff30d0ffRealUI ActionBars|r: imported %d bars from Bartender4 profile %q."):format(imported, profileName))
end

-- Auto-offer: first enable with BT4 data present and no prior import.
function private.MaybeImportFromBartender4()
    if AB.db.global.importedBT4 then return end
    if not _G.Bartender4DB then return end
    private.ImportFromBartender4(false)
end
