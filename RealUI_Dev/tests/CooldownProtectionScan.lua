local _, ns = ... -- luacheck: ignore

--[[ CooldownProtectionScan.lua — 12.1.5 diff eval item M3.

     Usage: /realdev cdscan         scan now
            /realdev cdscan 5       scan in 5 seconds (time to pull a mob)

     12.1.5 marks the Cooldown setters (Clear, SetCooldown, SetCooldownDuration,
     SetCooldownFromDurationObject, SetCooldownFromExpirationTime,
     SetCooldownUNIX) IsProtectedFunction. That only bites when the Cooldown
     frame itself is protected and tainted code calls a setter in combat, so
     this lists every RealUI-driven cooldown with Cooldown:IsProtected().
     Run it once out of combat and once in combat; any "PROTECTED" line is a
     frame whose cooldown sweep may now be refused (ADDON_ACTION_BLOCKED).

     Strictly read only: it calls IsProtected and GetDebugName, nothing else. ]]

local results

local function Check(label, cooldown)
    if not cooldown or not cooldown.IsProtected then return end
    local isProtected, explicit = cooldown:IsProtected()
    local key = isProtected and (explicit and "explicit" or "implicit") or "no"
    results[key] = (results[key] or 0) + 1
    if isProtected then
        _G.print(("  |cffff4040PROTECTED|r (%s) %s — %s"):format(
            explicit and "explicit" or "via parent", label, cooldown:GetDebugName() or "?"))
    end
end

local function Scan()
    results = {}
    _G.print(("|cff00ccff[cdscan]|r in combat: %s"):format(_G.InCombatLockdown() and "yes" or "no"))

    -- Reference: Blizzard's own action button, for comparison only
    if _G.ActionButton1 then
        local isProtected = _G.ActionButton1.cooldown and _G.ActionButton1.cooldown:IsProtected()
        _G.print(("  reference ActionButton1.cooldown protected: %s"):format(_G.tostring(isProtected)))
    end

    -- RealUI_ActionBars (LibActionButton)
    local LAB = _G.LibStub and _G.LibStub("LibActionButton-1.0", true)
    local numButtons = 0
    if LAB and LAB.buttonRegistry then
        for button in _G.next, LAB.buttonRegistry do
            numButtons = numButtons + 1
            local name = button:GetName() or "LAB button"
            Check(name .. ".cooldown", button.cooldown)
            Check(name .. ".chargeCooldown", button.chargeCooldown)
            Check(name .. ".lossOfControlCooldown", button.lossOfControlCooldown)
        end
    end
    _G.print(("  action buttons scanned: %d"):format(numButtons))

    -- RealUI_Tracker item button
    local itemButton = _G.RealUI_TrackerItemButton
    if itemButton then
        Check("RealUI_TrackerItemButton.cooldown", itemButton.cooldown)
    end

    -- RealUI_Inventory slots (bags, and bank if it has been opened)
    local numSlots = 0
    for _, parentName in _G.ipairs({ "RealUIInventory", "RealUIBank" }) do
        for i = 1, 400 do
            local slot = _G[parentName .. "_Slot" .. i]
            if not slot then break end
            numSlots = numSlots + 1
            Check(parentName .. "_Slot" .. i .. ".Cooldown", slot.Cooldown)
        end
    end
    _G.print(("  inventory slots scanned: %d"):format(numSlots))

    _G.print(("|cff00ccff[cdscan]|r not protected: %d, protected via parent: %d, explicit: %d"):format(
        results.no or 0, results.implicit or 0, results.explicit or 0))
end

function ns.commands:cdscan(delay)
    delay = _G.tonumber(delay)
    if delay and delay > 0 then
        _G.print(("|cff00ccff[cdscan]|r scanning in %d seconds"):format(delay))
        _G.C_Timer.After(delay, Scan)
    else
        Scan()
    end
end
