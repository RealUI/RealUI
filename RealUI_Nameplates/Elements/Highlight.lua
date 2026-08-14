local _, private = ...
local NP = private.NP

--[[ Target highlight. Enemy: the health border flips to the highlight color (clean
     KUI look, no extra textures). Friendly: soft glow behind the name. ]]--

local Highlight = {}

function Highlight.Create(plate)
    local glow = plate:CreateTexture(nil, "BACKGROUND")
    glow:SetColorTexture(1, 1, 1, 0.25)
    glow:Hide()

    plate.Highlight = { glow = glow }
end

local function Update(plate)
    local isTarget = _G.UnitExists("target") and _G.UnitIsUnit(plate.unit, "target")
    local color = NP.db.profile.target.highlight

    if plate.design == "enemy" then
        if isTarget then
            plate.Health.border:SetColor(color.r, color.g, color.b)
        else
            plate.Health.border:SetColor(0, 0, 0)
        end
    else
        local glow = plate.Highlight.glow
        if isTarget and NP.db.profile.friendly.targetGlow then
            glow:ClearAllPoints()
            glow:SetPoint("TOPLEFT", plate.Texts.name, "TOPLEFT", -4, 2)
            glow:SetPoint("BOTTOMRIGHT", plate.Texts.name, "BOTTOMRIGHT", 4, -2)
            glow:SetColorTexture(color.r, color.g, color.b, 0.3)
            glow:Show()
        else
            glow:Hide()
        end
    end
end

function Highlight.Attach(plate, unit)
    Update(plate)
end

function Highlight.Detach(plate)
    plate.Highlight.glow:Hide()
end

function Highlight.OnTargetChanged(plate)
    Update(plate)
end

private.AddElement("Highlight", Highlight)
