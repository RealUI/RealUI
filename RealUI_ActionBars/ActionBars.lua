local _, private = ...
local AB = private.AB

--[[ The six bars + bar 1's paging state driver.

     PAGE_MAP is data (spec req 3.1). The generic map covers Blizzard's
     bonusbar mechanics for every class (Druid forms, Rogue stealth, etc. all
     surface as bonusbar pages); per-class entries exist for the cases where a
     distinct page beyond the bonusbar default is wanted. Verified per class
     in-game (task 4 checkpoint). ]]--

local COMMON = "[possessbar]16;[overridebar]18;[shapeshift]17;[vehicleui]16;"
    .. "[bonusbar:1]7;[bonusbar:2]8;[bonusbar:3]9;[bonusbar:4]10;[bonusbar:5]11;"
    .. "[bar:2]2;[bar:3]3;[bar:4]4;[bar:5]5;[bar:6]6;1"

local PAGE_MAP = {
    DEFAULT = COMMON,
    -- Druid prowl gets its own page on top of cat form (classic RealUI/KUI
    -- muscle memory); everything else rides the generic bonusbar map.
    DRUID = "[bonusbar:1,stealth]8;" .. COMMON,
}

local function GetPageMap()
    local _, class = _G.UnitClass("player")
    return PAGE_MAP[class] or PAGE_MAP.DEFAULT
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

-- Naga bar (bar 6) toggle — behavior parity with the RealUI /naga command.
_G.SLASH_REALUIABNAGA1 = "/naga"
_G.SlashCmdList.REALUIABNAGA = function()
    local db = AB.dbActionBars and AB.dbActionBars.profile.actionbars[6]
    if not db then return end
    db.enabled = not db.enabled
    private.RefreshBar(6)
    _G.print(("|cff30d0ffRealUI ActionBars|r: Naga bar %s."):format(db.enabled and "enabled" or "disabled"))
end
