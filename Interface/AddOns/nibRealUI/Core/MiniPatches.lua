local _, private = ...

-- Lua Globals --
local _G = _G
local next, type = _G.next, _G.type

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("MiniPatch")

RealUI.minipatches = {
    [1] = function(ver)
        debug("r"..ver)
        _G.SetCVar("countdownForCooldowns", 0)
        if _G.IsAddOnLoaded("Aurora") then
            local AuroraConfig = _G.AuroraConfig
            if AuroraConfig then
                AuroraConfig["useButtonGradientColour"] = false
                AuroraConfig["chatBubbles"] = false
                AuroraConfig["bags"] = false
                AuroraConfig["tooltips"] = false
                AuroraConfig["loot"] = false
                AuroraConfig["useCustomColour"] = false
                AuroraConfig["enableFont"] = false
                AuroraConfig["buttonSolidColour"] = {0.09, 0.09, 0.09, 1}
            end
        end
        if _G.IsAddOnLoaded("DBM-StatusBarTimers") then
            local DBT_AllPersistentOptions = _G.DBT_AllPersistentOptions
            if DBT_AllPersistentOptions and DBT_AllPersistentOptions["DBM"] then
                DBT_AllPersistentOptions["DBM"]["HugeTimerY"] = 300
                DBT_AllPersistentOptions["DBM"]["HugeBarXOffset"] = 0
                DBT_AllPersistentOptions["DBM"]["Scale"] = 1
                DBT_AllPersistentOptions["DBM"]["TimerX"] = 400
                DBT_AllPersistentOptions["DBM"]["TimerPoint"] = "CENTER"
                DBT_AllPersistentOptions["DBM"]["HugeBarYOffset"] = 9
                DBT_AllPersistentOptions["DBM"]["HugeScale"] = 1
                DBT_AllPersistentOptions["DBM"]["HugeTimerPoint"] = "CENTER"
                DBT_AllPersistentOptions["DBM"]["BarYOffset"] = 9
                DBT_AllPersistentOptions["DBM"]["HugeTimerX"] = -400
                DBT_AllPersistentOptions["DBM"]["TimerY"] = 300
                DBT_AllPersistentOptions["DBM"]["BarXOffset"] = 0
            end
        end
        if _G.IsAddOnLoaded("BugSack") then
            if _G.BugSackLDBIconDB then
                _G.BugSackLDBIconDB["hide"] = false
            end
        end
    end,
    [8] = function(ver)
        debug("r"..ver)
        local Bartender4DB = _G.Bartender4DB
        if _G.IsAddOnLoaded("Bartender4") and Bartender4DB then
            if Bartender4DB["namespaces"]["PetBar"]["profiles"]["RealUI-Healing"] then
                Bartender4DB["namespaces"]["PetBar"]["profiles"]["RealUI-Healing"] = Bartender4DB["namespaces"]["PetBar"]["profiles"]["RealUI"]
            end
        end
    end,
    [12] = function(ver)
        debug("r"..ver)
        -- This was supposed to be r11... oops
        local Grid2DB = _G.Grid2DB
        if _G.IsAddOnLoaded("Grid2") and Grid2DB then
            for i, key in next, {"RealUI-Healing", "RealUI"} do
                local profile = Grid2DB["profiles"][key]
                if profile then
                    if profile["indicators"]["health-deficit"] then
                        profile["indicators"]["health-deficit"]["reverseFill"] = true
                    end
                    if profile["indicators"]["text-up"] then
                        profile["indicators"]["text-up"]["shadowDisabled"] = true
                    end
                    if profile["indicators"]["text-down"] then
                        profile["indicators"]["text-down"]["shadowDisabled"] = true
                    end
                end
            end
        end
        local AuroraConfig = _G.AuroraConfig
        if _G.IsAddOnLoaded("Aurora") and AuroraConfig then
            AuroraConfig["buttonSolidColour"] = {0.1, 0.1, 0.1, 1}
        end

        -- r12
        _G.SetCVar("useCompactPartyFrames", 1) -- Raid-style party frames
        local KuiNameplatesGDB = _G.KuiNameplatesGDB
        if _G.IsAddOnLoaded("Kui_Nameplates") and KuiNameplatesGDB then
            KuiNameplatesGDB["profiles"]["RealUI"]["fonts"]["options"]["fontscale"] = 1
        end
    end,
    [13] = function(ver)
        debug("r"..ver)
        local nibRealUIDB = _G.nibRealUIDB
        if nibRealUIDB["namespaces"]["RuneDisplay"]["profiles"] then
            local profile = nibRealUIDB["namespaces"]["RuneDisplay"]["profiles"]["RealUI"]
            if profile then
                profile["combatfader"]["opacity"]["runes"] = profile["combatfader"]["opacity"]["hurt"]
            end
        end
        local defaults = RealUI:GetPointTrackingDefaults().profile
        if nibRealUIDB["namespaces"]["PointTracking"]["profiles"] then
            local defaultDB = defaults["**"].types["**"]
            local profile = nibRealUIDB["namespaces"]["PointTracking"]["profiles"]["RealUI"]
            local function setSettings(classSV, classDB, fallbackDB)
                for setting, value in next, classSV do
                    if type(value) == "table" then
                        setSettings(value, classDB and classDB[setting] or nil, fallbackDB[setting])
                    else
                        classSV[setting] = classDB and classDB[setting] or fallbackDB[setting]
                    end
                end
            end
            for class, classInfo in next, profile do
                if type(classInfo) == "table" and classInfo.types then
                    for pointType, pointInfo in next, classInfo.types do
                        if pointInfo.bars then
                            setSettings(pointInfo.bars, defaults[class].types[pointType].bars, defaultDB.bars)
                        end
                    end
                end
            end
        end
        local RavenDB = _G.RavenDB
        if _G.IsAddOnLoaded("Raven") and RavenDB then
            if RavenDB["profiles"]["RealUI"] then
                if RavenDB["profiles"]["RealUI"]["BarGroups"]["PlayerBuffs"] then
                    RavenDB["profiles"]["RealUI"]["BarGroups"]["PlayerBuffs"]["checkDuration"] = false
                end
                if RavenDB["profiles"]["RealUI"]["BarGroups"]["Buffs"] then
                    RavenDB["profiles"]["RealUI"]["BarGroups"]["Buffs"]["checkDuration"] = false
                end
            end
        end
    end,
    [99] = function(ver) -- test patch
        debug("r"..ver)
    end,
}
