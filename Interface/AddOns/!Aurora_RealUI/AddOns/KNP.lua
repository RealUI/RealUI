local _, mods = ...

-- Lua Globals --
local _G = _G

mods["PLAYER_LOGIN"]["Kui_Nameplates"] = function(self, F, C)
    mods.debug("Kui_Nameplates", F, C)
    local kuiNP = _G.LibStub("AceAddon-3.0"):GetAddon("KuiNameplates", true)
    if not kuiNP then return end

    -- When the onesize option is on, all fonts use the "name" size.
    kuiNP:RegisterFontSize("name", 8)

    local pixelFont = _G.RealUI.media.font.pixel.large[1]
    kuiNP.db.profile.fonts.options.font = pixelFont
    kuiNP:LSMMediaRegistered(nil, "font", pixelFont)
end
