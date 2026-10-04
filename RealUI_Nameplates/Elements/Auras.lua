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

-- SPACING is the gap the user sees. Each button carries a 1px black border 1px
-- OUTSIDE its own rect (private.CreateBorder), and the flow layout spaces the
-- button rects, not the borders — so the engine has to be told SPACING plus the
-- pair of borders between any two neighbours, or the icons render touching.
local SPACING = 2
local ELEMENT_SPACING = SPACING + 2

-- B163: My debuffs is two groups whose filter and candidates come from the
-- profile (ResolveMyDebuffs), so they are set on every config change rather
-- than once here. Group 1 is the "Show" rule; group 2 is the always-show list.
-- INCLUDE_NAME_PLATE_ONLY: without it the engine drops auras Blizzard flags
-- as nameplate-only, which is the one place they are meant to appear.
local MY_DEBUFF_FILTER = "HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY|!CROWD_CONTROL"

local GROUP_DEFS = {
    myDebuffs = {
        groups = { { filter = MY_DEBUFF_FILTER }, { filter = MY_DEBUFF_FILTER } },
        resolve = true,
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
        groups = { { filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY|CROWD_CONTROL" } },
    },
}

-- Anchor presets (config-selectable per group; growth direction rides along so
-- rows always grow away from the plate).
--
-- The centred presets work because CustomAuraContainerFlowLayoutMixin's
-- OnLayoutComplete resizes the container to the laid-out row (Blizzard_Custom-
-- AuraContainer.lua:679). Anchoring the container's own BOTTOM/TOP to the plate
-- therefore centres the whole row on the plate, while the row itself still
-- flows from its left edge. The width is a secret value, but we never read it —
-- only the engine and SetPoint do.
local POSITIONS = {
    aboveCenter = { point = "BOTTOM",      relPoint = "TOP",         flowAnchor = "BOTTOMLEFT",  growX = 1  },
    aboveLeft  = { point = "BOTTOMLEFT",  relPoint = "TOPLEFT",     flowAnchor = "BOTTOMLEFT",  growX = 1  },
    aboveRight = { point = "BOTTOMRIGHT", relPoint = "TOPRIGHT",    flowAnchor = "BOTTOMRIGHT", growX = -1 },
    left       = { point = "RIGHT",       relPoint = "LEFT",        flowAnchor = "BOTTOMRIGHT", growX = -1 },
    right      = { point = "LEFT",        relPoint = "RIGHT",       flowAnchor = "BOTTOMLEFT",  growX = 1  },
    belowCenter = { point = "TOP",         relPoint = "BOTTOM",      flowAnchor = "TOPLEFT",     growX = 1  },
    belowLeft  = { point = "TOPLEFT",     relPoint = "BOTTOMLEFT",  flowAnchor = "TOPLEFT",     growX = 1  },
    belowRight = { point = "TOPRIGHT",    relPoint = "BOTTOMRIGHT", flowAnchor = "TOPRIGHT",    growX = -1 },
}
private.auraPositionNames = {
    aboveCenter = "Above, centered", aboveLeft = "Above, grow right", aboveRight = "Above, grow left",
    left = "Left side", right = "Right side",
    belowCenter = "Below, centered", belowLeft = "Below, grow right", belowRight = "Below, grow left",
}

local Auras = {}

-- B163 sort choices. Values are AuraContainerSortMethod keys.
private.auraSortNames = { default = "Default", expiration = "Time remaining" }
local SORT_METHODS = { default = "Default", expiration = "Expiration" }

-- Spell lists are stored as { [spellID] = true }; a removed spell may linger as
-- false in a saved profile. Returns only the live entries, nil when empty.
local function CopyList(list)
    local copy
    for spellID, enabled in _G.next, list or {} do
        if enabled then
            copy = copy or {}
            copy[spellID] = true
        end
    end
    return copy
end

--[[ B163: what My debuffs shows.

     "important" is Blizzard's own nameplate rule (Blizzard_NamePlateAuras.lua
     AddAura): a debuff shows only if its spell carries `nameplateShowPersonal`,
     the per-class flag Blizzard curates for the debuffs a player should track.
     "all" is every debuff the player or their pet cast (the 4.1 behaviour).

     The always/never lists are spell-ID ("identity") candidate filters. The
     engine applies those only to harmful auras on units the player cannot
     assist (AuraContainerUtil.CanApplyIdentityCandidateFilters), which is every
     enemy plate — the only design this row attaches to. Group 2 takes the
     always-show spells that group 1 rejected (nameplateShowPersonal = false),
     so nothing is shown twice. Never-show wins over always-show. ]]
local function ResolveMyDebuffs(groupDB)
    local never = CopyList(groupDB.neverShow)
    local main = { excludeSpellIDs = never }
    if groupDB.show ~= "all" then
        main.nameplateShowPersonal = true
    end
    local extra = {
        -- An empty include list matches nothing, which is what "no always-show
        -- spells" (or "all" mode, where group 1 already has them) should do.
        includeSpellIDs = (groupDB.show ~= "all" and CopyList(groupDB.alwaysShow)) or {},
        excludeSpellIDs = never,
        nameplateShowPersonal = false,
    }
    return { main, extra }
end

-- B23: the native countdown text overlapped the icon and used the tiny default
-- font. Move it above the icon and size it to match the nameplate name font.
-- The Cooldown widget creates its countdown FontString natively (possibly
-- lazily), so we hunt for it at creation AND on every OnShow until found; the
-- anchor is re-asserted each show in case the engine repositions it. Font size
-- is read at button creation — like button size, changes need a /reload.
-- Widget-only access: we never read the (engine-driven, possibly secret) text.
-- The cooldown sits under an access-restricted aura button, where script
-- assignment is blocked ("blocked by secret aspects") — so the lazily created
-- countdown FontString cannot be caught with an OnShow hook. Cooldowns whose
-- FontString hasn't appeared yet are retried from Attach, which runs in our
-- own execution context on every plate attach.
local pendingTimers = _G.setmetatable({}, { __mode = "k" })
local function StyleTimerText(cooldown)
    local text = cooldown.realUITimerText
    if not text then
        for _, region in _G.next, { cooldown:GetRegions() } do
            if region:GetObjectType() == "FontString" then
                text = region
                cooldown.realUITimerText = text
                private.ApplyFont(text, NP.db.profile.enemy.texts.name.size)
                break
            end
        end
    end
    if text then
        pendingTimers[cooldown] = nil
        text:ClearAllPoints()
        text:SetPoint("BOTTOM", cooldown:GetParent(), "TOP", 0, 1)
    else
        pendingTimers[cooldown] = true
    end
end

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
    StyleTimerText(cooldown)

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
            container:SetAuraGroupLayout(groupKey, { elementSpacing = ELEMENT_SPACING, lineSpacing = ELEMENT_SPACING })
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

-- Bumped by the config on every change; a container re-applies its filters
-- only when it is behind, not on every plate attach.
private.auraConfigGeneration = 0

local function ConfigureFilters(container, def, groupDB)
    if not def.resolve or container.realUIGeneration == private.auraConfigGeneration then return end
    container.realUIGeneration = private.auraConfigGeneration

    local candidates = ResolveMyDebuffs(groupDB)
    local methods, directions = _G.AuraContainerSortMethod, _G.AuraContainerSortDirection
    local sortMethod = methods and methods[SORT_METHODS[groupDB.sort] or "Default"]
    for i in _G.ipairs(def.groups) do
        local groupKey = _G.tostring(i)
        private.Try(container.SetAuraGroupCandidateFilters, container, groupKey, candidates[i])
        if sortMethod and directions then
            private.Try(container.SetAuraGroupSortMethod, container, groupKey, sortMethod, directions.Normal)
        end
    end
end

local function ConfigureContainer(container, def, groupDB, size)
    private.Try(function()
        for i in _G.ipairs(def.groups) do
            container:SetAuraGroupMaxFrameCount(_G.tostring(i), groupDB.max)
        end
        container:SetFlowLayoutMaximumLineSize((size + ELEMENT_SPACING) * groupDB.max)
    end)
    ConfigureFilters(container, def, groupDB)
end

function Auras.Attach(plate, unit)
    private.Try(function()
        for cooldown in _G.next, pendingTimers do
            StyleTimerText(cooldown)
        end
    end)
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
