local _, private = ...
local NP = private.NP

--[[ Three filtered aura rows on Blizzard's AuraContainer intrinsic.

     WoW 12: nameplate aura lists are SECRET in combat for tainted code —
     C_UnitAuras.GetAuraDataByIndex throws ("Auras cannot be accessed when secret
     while tainted"). The secure AuraContainer intrinsic is the only way to render
     them: we declare filter strings + candidate filters and hand the engine plain
     widgets (icon texture, cooldown, count fontstring, dispel border) that it
     drives with the secret data. We never read aura fields ourselves.

     Filter grammar (verified against Platynator 461 + oUF 14 usage):
     tokens HARMFUL/HELPFUL, PLAYER/!PLAYER, IMPORTANT, CROWD_CONTROL, ...;
     candidate filters: isStealable, includeDispelTypes ([""] = enrage), etc.
     Button size is creation-time only — size changes need a /reload. ]]--

local SPACING = 2

local GROUP_DEFS = {
    myDebuffs = {
        groups = { { filter = "HARMFUL|PLAYER|!CROWD_CONTROL" } },
    },
    buffs = {
        dispelBorder = true,
        groups = {
            { filter = "HELPFUL|IMPORTANT|!PLAYER" },
            { filter = "HELPFUL|!PLAYER", candidates = { isStealable = true } },
            { filter = "HELPFUL|!PLAYER", candidates = { includeDispelTypes = { [""] = true } } }, -- enrage
        },
    },
    crowdControl = {
        groups = { { filter = "HARMFUL|CROWD_CONTROL" } },
    },
}

-- Anchor presets (config-selectable per group; growth direction rides along so
-- rows always grow away from the plate).
local POSITIONS = {
    aboveLeft  = { point = "BOTTOMLEFT",  relPoint = "TOPLEFT",     flowAnchor = "BOTTOMLEFT",  growX = 1  },
    aboveRight = { point = "BOTTOMRIGHT", relPoint = "TOPRIGHT",    flowAnchor = "BOTTOMRIGHT", growX = -1 },
    left       = { point = "RIGHT",       relPoint = "LEFT",        flowAnchor = "BOTTOMRIGHT", growX = -1 },
    right      = { point = "LEFT",        relPoint = "RIGHT",       flowAnchor = "BOTTOMLEFT",  growX = 1  },
    belowLeft  = { point = "TOPLEFT",     relPoint = "BOTTOMLEFT",  flowAnchor = "TOPLEFT",     growX = 1  },
    belowRight = { point = "TOPRIGHT",    relPoint = "BOTTOMRIGHT", flowAnchor = "TOPRIGHT",    growX = -1 },
}
private.auraPositionNames = {
    aboveLeft = "Above, grow right", aboveRight = "Above, grow left",
    left = "Left side", right = "Right side",
    belowLeft = "Below, grow right", belowRight = "Below, grow left",
}

local Auras = {}

local function InitializeButton(dispelBorder, button)
    local size = NP.db.profile.enemy.auras.size
    button:SetSize(size, size)
    button:EnableMouse(false)

    local cooldown = _G.CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetAllPoints(button)
    cooldown:SetReverse(true)
    cooldown:SetHideCountdownNumbers(false)
    cooldown:SetDrawEdge(false)
    button:SetDurationCooldown(cooldown)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(button)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button:SetIcon(icon)

    private.CreateBorder(button)

    local textParent = _G.CreateFrame("Frame", nil, button)
    textParent:SetAllPoints(button)
    textParent:SetFrameLevel(cooldown:GetFrameLevel() + 1)
    local count = textParent:CreateFontString(nil, "OVERLAY")
    private.ApplyFont(count, 9)
    count:SetPoint("TOPRIGHT", button, "TOPRIGHT", 2, 2)
    button:SetApplicationCount(count, {})

    if dispelBorder then
        local border = button:CreateTexture(nil, "OVERLAY")
        border:SetAllPoints(button)
        button:AddDispelTypeTexture(border, {
            style = _G.Enum.CustomAuraButtonDispelTypeTextureStyle.Border,
            showWhenHelpful = true,
        })
    end
end

local function SetupContainer(plate, key, def)
    local ok, container = _G.pcall(_G.CreateFrame,
        "AuraContainer", nil, plate, "CustomAuraContainerTemplate")
    if not ok or not container then return end

    container:SetSize(1, 1)

    local configured = private.Try(function()
        local initializer = function(button) InitializeButton(def.dispelBorder, button) end
        for i, group in _G.ipairs(def.groups) do
            local groupKey = _G.tostring(i)
            container:AddAuraGroup(groupKey, "", { initializeFrame = initializer })
            container:SetAuraGroupFilterString(groupKey, group.filter)
            if group.candidates then
                container:SetAuraGroupCandidateFilters(groupKey, group.candidates)
            end
            container:SetAuraGroupLayout(groupKey, { elementSpacing = SPACING, lineSpacing = SPACING })
        end
    end)
    if not configured then
        container:Hide()
        return
    end
    return container
end

-- Anchoring + growth are live-mutable; applied on every Attach/refresh from db.
local function ApplyPosition(plate, key, container, groupDB)
    local preset = POSITIONS[groupDB.position] or POSITIONS.aboveLeft
    local offset = groupDB.offset or { x = 0, y = 0 }
    container:ClearAllPoints()
    container:SetPoint(preset.point, plate, preset.relPoint, offset.x, offset.y)
    private.Try(function()
        container:SetFlowLayoutAnchorPoint(preset.flowAnchor)
        container:SetFlowLayoutGrowthDirection(preset.growX, 1)
    end)
end

function Auras.Create(plate)
    plate.Auras = { containers = {} }
    for key, def in _G.next, GROUP_DEFS do
        plate.Auras.containers[key] = SetupContainer(plate, key, def)
    end
end

local function ConfigureContainer(container, def, groupDB, size)
    private.Try(function()
        for i in _G.ipairs(def.groups) do
            container:SetAuraGroupMaxFrameCount(_G.tostring(i), groupDB.max)
        end
        container:SetFlowLayoutMaximumLineSize((size + SPACING) * groupDB.max)
    end)
end

function Auras.Attach(plate, unit)
    local db = NP.db.profile.enemy.auras
    for key, container in _G.next, plate.Auras.containers do
        local groupDB = db[key]
        if plate.design == "enemy" and groupDB.enabled then
            ApplyPosition(plate, key, container, groupDB)
            ConfigureContainer(container, GROUP_DEFS[key], groupDB, db.size)
            private.Try(container.SetUnit, container, unit)
            container:Show()
        else
            private.Try(container.SetUnit, container, nil)
            container:Hide()
        end
    end
end

function Auras.Detach(plate)
    for _, container in _G.next, plate.Auras.containers do
        private.Try(container.SetUnit, container, nil)
        container:Hide()
    end
end

private.AddElement("Auras", Auras)
