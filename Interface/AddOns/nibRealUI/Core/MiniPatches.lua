local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

function nibRealUI:MiniPatch(ver)
    if ver == "81r1" then
        SetCVar("countdownForCooldowns", 0)
        if IsAddOnLoaded("Aurora") then
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
    elseif ver == "81r8" then
        if IsAddOnLoaded("Bartender4") and Bartender4DB then
            if Bartender4DB["namespaces"]["PetBar"]["profiles"]["RealUI-Healing"] then
                Bartender4DB["namespaces"]["PetBar"]["profiles"]["RealUI-Healing"] = Bartender4DB["namespaces"]["PetBar"]["profiles"]["RealUI"]
            end
        end
    elseif ver == "81r11" then
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
        if IsAddOnLoaded("Aurora") and AuroraConfig then
            AuroraConfig["buttonSolidColour"] = {0.1, 0.1, 0.1, 1}
        end
    end
end
