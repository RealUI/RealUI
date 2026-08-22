local _, private = ...
local AB = private.AB

--[[ The six bars + bar 1's paging state driver.

     PAGE_MAP is data (spec req 3.1). The generic map covers Blizzard's
     bonusbar mechanics for every class (Druid forms, Rogue stealth, etc. all
     surface as bonusbar pages); per-class entries exist for the cases where a
     distinct page beyond the bonusbar default is wanted. Verified per class
     in-game (task 4 checkpoint). ]]--

-- Special pages come from the client, not folklore: our buttons map page N
-- straight to action slots (N-1)*12+i, so the conditionals MUST resolve to
-- the real special pages — vehicle/possess 12, override 14, temp-shapeshift
-- 17 (skyriding is bonusbar 5 -> page 11). Wrong numbers here leave the bar
-- stuck on page 1 with empty special slots (the "flight bar doesn't swap"
-- symptom).
local function BuildCommonMap()
    local vehicle = (_G.GetVehicleBarIndex and _G.GetVehicleBarIndex()) or 12
    local override = (_G.GetOverrideBarIndex and _G.GetOverrideBarIndex()) or 14
    local tempShapeshift = (_G.GetTempShapeshiftBarIndex and _G.GetTempShapeshiftBarIndex()) or 17
    return ("[overridebar]%d;[possessbar]%d;[vehicleui]%d;[shapeshift]%d;"):format(
            override, vehicle, vehicle, tempShapeshift)
        .. "[bonusbar:5]11;[bonusbar:1]7;[bonusbar:2]8;[bonusbar:3]9;[bonusbar:4]10;"
        .. "[bar:2]2;[bar:3]3;[bar:4]4;[bar:5]5;[bar:6]6;1"
end

local function GetPageMap()
    local common = BuildCommonMap()
    local _, class = _G.UnitClass("player")
    if class == "DRUID" then
        -- Prowl gets its own page on top of cat form (classic RealUI/KUI
        -- muscle memory); everything else rides the generic bonusbar map.
        return "[bonusbar:1,stealth]8;" .. common
    end
    return common
end

function private.BuildBars()
    for id = 1, 6 do
        if not AB.bars[id] then
            AB.bars[id] = private.CreateBar(id)
        end
    end

    -- Bar 1 paging: canonical LAB header pattern — the driver flips the
    -- header's state, the snippet pushes it to the children.
    local bar1 = AB.bars[1]
    bar1:SetAttribute("_onstate-page", [[
        self:SetAttribute("state", newstate)
        control:ChildUpdate("state", newstate)
    ]])
    _G.RegisterStateDriver(bar1, "page", GetPageMap())
end

function private.ApplyAllBars()
    for id = 1, 6 do
        if AB.bars[id] then
            AB.bars[id]:ApplyConfig()
        end
    end
end

function private.RefreshBar(id)
    private.QueueSecure(function()
        if AB.bars[id] then
            AB.bars[id]:ApplyConfig()
        end
    end)
end

--- Public wrapper: RealUI's ActionBars module delegates its wizard-driven
--- Naga toggle through this (it has no access to `private`).
function AB:RefreshBar(id)
    private.RefreshBar(id)
end

--[[ ExtraActionButton / ZoneAbility: anchored to the left of bar 1, stacked
     outward (parity with the old RealUI arrangement, which anchored them to
     BT4Bar1 — a path that died with Bartender4). The EditMode-managed
     CONTAINER stays wherever the template put it; we re-anchor the child
     buttons, exactly as the old module did. ]]--

function private.ApplyExtraButtons()
    if not AB.db.profile.moveExtraButton then return end
    local bar1 = AB.bars[1]
    if not bar1 then return end
    local pad = 4

    local eab = _G.ExtraActionButton1
    if eab then
        _G.pcall(function()
            eab:ClearAllPoints()
            eab:SetPoint("BOTTOMRIGHT", bar1, "BOTTOMLEFT", -pad, 0)
        end)
    end
    local zone = _G.ZoneAbilityFrame and _G.ZoneAbilityFrame.SpellButtonContainer
    if zone then
        _G.pcall(function()
            zone:ClearAllPoints()
            if eab then
                zone:SetPoint("TOPRIGHT", eab, "TOPLEFT", -pad, 0)
            else
                zone:SetPoint("BOTTOMRIGHT", bar1, "BOTTOMLEFT", -pad, 0)
            end
        end)
    end
end

--[[ Task 4.2: vehicle-exit button with independent position/scale.

     `MainMenuBarVehicleLeaveButton` is an EditMode SYSTEM frame (parented to
     MainActionBar, EditModeVehicleLeaveButtonSystemTemplate), so EditMode
     re-anchors it on every layout apply — the same stomp that took the
     Omnium Folio button (B68) and the LFG eye (B29). Cure is the same:
     re-assert our placement from a hooksecurefunc on the frame's own
     position updater, plus the layout/login events.

     Visibility stays Blizzard's (UpdateShownState / CanExitVehicle) — we only
     own where it sits and how big it is. Position/scale come from the
     `Vehicle` namespace that Defaults.lua has carried unused until now. ]]--

local vehicleHooked = false

function private.ApplyVehicleButton()
    local button = _G.MainMenuBarVehicleLeaveButton
    if not button then return end

    local db = AB.dbVehicle and AB.dbVehicle.profile
    if not db or not db.enabled then return end

    local pos = db.position or {}
    _G.pcall(function()
        button:ClearAllPoints()
        button:SetPoint(pos.point or "TOPRIGHT", _G.UIParent,
            pos.point or "TOPRIGHT", pos.x or -36, pos.y or -59.5)
        button:SetScale(db.scale or 0.84)
    end)

    if not vehicleHooked then
        vehicleHooked = true
        -- EditMode calls UpdateSystemSettingFrameposition/UpdateMagnetismRegistration
        -- on its system frames; hook whichever exists so our anchor wins the
        -- last write without us fighting the frame every OnUpdate.
        for _, method in _G.next, {"UpdateSystemSettingFramePosition", "ApplySystemAnchor", "UpdateShownState"} do
            if type(button[method]) == "function" then
                _G.hooksecurefunc(button, method, function()
                    private.QueueSecure(private.ApplyVehicleButton)
                end)
            end
        end
    end
end

-- Naga bar (bar 6) toggle — behavior parity with the RealUI /naga command.
_G.SLASH_REALUIABNAGA1 = "/naga"
_G.SlashCmdList.REALUIABNAGA = function()
    local db = AB.dbActionBars and AB.dbActionBars.profile.actionbars[6]
    if not db then return end
    db.enabled = not db.enabled
    private.RefreshBar(6)
    _G.print(("|cff30d0ffRealUI ActionBars|r: Naga bar %s."):format(db.enabled and "enabled" or "disabled"))
end
