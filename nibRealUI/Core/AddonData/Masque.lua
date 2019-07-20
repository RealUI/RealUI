local _, private = ...

-- RealUI --
local RealUI = private.RealUI

function RealUI.AddOns.Masque()
    local profiles = _G.MasqueDB.profiles
    profiles["RealUI"] = {
        ["Groups"] = {
            ["Masque"] = {
                ["SkinID"] = "RealUI",
                ["Backdrop"] = true,
                ["Fonts"] = true,
            },
        }
    }
end

function RealUI.Profiles.Masque()
    local Masque = _G.LibStub("AceAddon-3.0"):GetAddon("Masque", true)
    if not Masque then return end

    Masque:SetProfile("RealUI")
end
