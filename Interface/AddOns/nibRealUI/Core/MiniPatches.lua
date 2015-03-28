local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local function debug(...)
    nibRealUI.Debug("MiniPatch", ...)
end

nibRealUI.minipatches = {
    [1] = function(ver)
        debug("r"..ver)
        SetCVar("countdownForCooldowns", 0)
        if IsAddOnLoaded("Aurora") then
            local AuroraConfig = AuroraConfig
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
        if IsAddOnLoaded("DBM-StatusBarTimers") then
            local DBT_AllPersistentOptions = DBT_AllPersistentOptions
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
        if IsAddOnLoaded("BugSack") then
            if BugSackLDBIconDB then
                BugSackLDBIconDB["hide"] = false
            end
        end
    end,
    [8] = function(ver)
        debug("r"..ver)
        local Bartender4DB = Bartender4DB
        if IsAddOnLoaded("Bartender4") and Bartender4DB then
            if Bartender4DB["namespaces"]["PetBar"]["profiles"]["RealUI-Healing"] then
                Bartender4DB["namespaces"]["PetBar"]["profiles"]["RealUI-Healing"] = Bartender4DB["namespaces"]["PetBar"]["profiles"]["RealUI"]
            end
        end
    end,
    [12] = function(ver)
        debug("r"..ver)
        --[[ was supposed to be r11... oops
        local Grid2DB = Grid2DB
        if IsAddOnLoaded("Grid2") and Grid2DB then
            if Grid2DB["profiles"]["RealUI-Healing"] then
                Grid2DB["profiles"]["RealUI-Healing"]["indicators"]["health-deficit"]["reverseFill"] = true
                Grid2DB["profiles"]["RealUI-Healing"]["indicators"]["text-up"]["shadowDisabled"] = true
                Grid2DB["profiles"]["RealUI-Healing"]["indicators"]["text-down"]["shadowDisabled"] = true
            end
            if Grid2DB["profiles"]["RealUI"] then
                Grid2DB["profiles"]["RealUI"]["indicators"]["health-deficit"]["reverseFill"] = true
                Grid2DB["profiles"]["RealUI"]["indicators"]["text-up"]["shadowDisabled"] = true
                Grid2DB["profiles"]["RealUI"]["indicators"]["text-down"]["shadowDisabled"] = true
            end
        end
        local AuroraConfig = AuroraConfig
        if IsAddOnLoaded("Aurora") and AuroraConfig then
            AuroraConfig["buttonSolidColour"] = {0.1, 0.1, 0.1, 1}
        end

        -- r12
        SetCVar("useCompactPartyFrames", 1)]]
    end,
    [13] = function(ver)
        debug("r"..ver)
    end,
    [14] = function(ver)
        debug("r"..ver)
    end,
}
