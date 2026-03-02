local _, private = ...

function private.AddOns.Masque()
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

function private.Profiles.Masque()
    local Masque = _G.LibStub("AceAddon-3.0"):GetAddon("Masque", true)
    if not Masque then return end

    Masque:SetProfile("RealUI")
end
