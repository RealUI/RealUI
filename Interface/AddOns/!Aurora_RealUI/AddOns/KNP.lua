local _, mods = ...

mods["PLAYER_LOGIN"]["Kui_Nameplates"] = function(self, F, C)
    --print("Kui_Nameplates", F, C)
    local kuiNP = LibStub("AceAddon-3.0"):GetAddon("KuiNameplates", true)

    kuiNP.db.profile.fonts.options.font = RealUI:Font(true)
    kuiNP.font = RealUI:Font()[1]
    if kuiNP.db.profile then
        for _, frame in pairs(kuiNP.frameList) do
            if frame.kui then
                -- Kui_Nameplates\core.lua
                kuiNP.configChangedFuncs.runOnce.font(kuiNP.db.profile.fonts.options.font)
            end
        end
    end

    local knUpdateScheduled
    function self:UI_SCALE_CHANGED()
        -- Update KN font scale
        if (nibRealUICharacter and nibRealUICharacter.installStage == -1) then
            if not knUpdateScheduled then
                knUpdateScheduled = true
                C_Timer.After(2, function()
                    if IsAddOnLoaded("Kui_Nameplates") then
                        if kuiNP.db.profile then
                            local screenHeight = string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
                            local scale = ceil(((768 * (RealUI.font.pixel1[2] / kuiNP.defaultSizes.font.name)) / screenHeight) * 100) / 100

                            kuiNP.db.profile.fonts.options.fontscale = scale
                            kuiNP:ScaleSizes("font")
                            for _, frame in pairs(kuiNP.frameList) do
                                -- Kui_Nameplates\core.lua
                                kuiNP.configChangedFuncs.fontscale(frame.kui, kuiNP.db.profile.fonts.options.fontscale)
                            end
                        end
                    end
                    knUpdateScheduled = false
                end)
            end
        end
    end
    self:RegisterEvent("UI_SCALE_CHANGED")
end
