local _, mods = ...

mods["PLAYER_LOGIN"]["Kui_Nameplates"] = function(self, F, C)
    mods.debug("Kui_Nameplates", F, C)
    local kuiNP = LibStub("AceAddon-3.0"):GetAddon("KuiNameplates")

    -- When the onesize option is on, all fonts use the "name" size.
    kuiNP:RegisterFontSize("name", 8)

    local pixelFont = RealUI.media.font.pixel.large[1]
    kuiNP.db.profile.fonts.options.font = pixelFont
    kuiNP:LSMMediaRegistered(msg, "font", pixelFont)
end
