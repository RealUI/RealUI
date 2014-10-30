local _, mods = ...
mods["Aurora"] = {}

-- RealUI skin hook
REALUI_STRIPE_TEXTURES = REALUI_STRIPE_TEXTURES or {}
REALUI_WINDOW_FRAMES = REALUI_WINDOW_FRAMES or {}
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db = nibRealUI.db.profile

-- Aurora API
local F, C
local style = {}
style.apiVersion = "6.0"

style.functions = {
    ["CreateBD"] = function(f, a)
        --print("Override CreateBD", f:GetName(), a)
        f:SetBackdrop({
            bgFile = C.media.backdrop,
            edgeFile = C.media.backdrop,
            edgeSize = 1,
        })
        f:SetBackdropBorderColor(0, 0, 0)
        if not a then
	        --print("CreateSD")
	        f:SetBackdropColor(unpack(nibRealUI.media.window))
	        f.tex = f.tex or f:CreateTexture(nil, "BACKGROUND", nil, 1)
	        f.tex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true)
	        f.tex:SetAlpha(db.settings.stripeOpacity)
	        f.tex:SetAllPoints()
	        f.tex:SetHorizTile(true)
	        f.tex:SetVertTile(true)
	        f.tex:SetBlendMode("ADD")
	        tinsert(REALUI_WINDOW_FRAMES, f)
	        tinsert(REALUI_STRIPE_TEXTURES, f.tex)
	    else
	    	--print("CreateBD: alpha", a)
	    	f:SetBackdropColor(0, 0, 0, a)
        end
    end,
}

style.skipSplashScreen = true

--style.highlightColor = {r = 0, g = 1, b = 0}
style.classcolors = {
    ["DEATHKNIGHT"] = { r = 0.77, g = 0.12, b = 0.23 },
    ["DRUID"]       = { r = 1.00, g = 0.49, b = 0.04 },
    ["HUNTER"]      = { r = 0.67, g = 0.83, b = 0.45 },
    ["MAGE"]        = { r = 0.41, g = 0.80, b = 0.94 },
    ["MONK"]        = { r = 0.00, g = 1.00, b = 0.59 },
    ["PALADIN"]     = { r = 0.96, g = 0.55, b = 0.73 },
    ["PRIEST"]      = { r = 0.80, g = 0.80, b = 0.80 },
    ["ROGUE"]       = { r = 1.00, g = 0.96, b = 0.41 },
    ["SHAMAN"]      = { r = 0.00, g = 0.44, b = 0.87 },
    ["WARLOCK"]     = { r = 0.58, g = 0.51, b = 0.79 },
    ["WARRIOR"]     = { r = 0.78, g = 0.61, b = 0.43 },
}

AURORA_CUSTOM_STYLE = style

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
    if addon == "Aurora" then
        F, C = unpack(Aurora)

        F.ReskinAtlas = function(f, atlas, is8Point)
            --print("ReskinAtlas")
            if not atlas then atlas = f:GetAtlas() end
            local file, _, _, left, right, top, bottom = GetAtlasInfo(atlas)
            file = file:sub(10) -- cut off "Interface"
            f:SetTexture([[Interface\AddOns\!Aurora_RealUI\Media]]..file)
            if is8Point then
                return left, right, top, bottom
            else
                f:SetTexCoord(left, right, top, bottom)
            end
        end
    end

    -- mod logic by Haleth from Aurora
    local addonModule = mods[addon]
    if addonModule then
        if type(addonModule) == "function" then
            addonModule(F, C)
        else
            -- Aurora
            for _, moduleFunc in pairs(addonModule) do
                F.AddPlugin(function()
                    moduleFunc(F, C)
                end)
            end
        end
    end
end)
