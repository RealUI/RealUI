-- Containers.lua: aura groups rendered by Blizzard's AuraContainer intrinsic.
--
-- WoW 12: for tainted code the aura LIST of a hostile or target unit is secret
-- in combat, so the Lua scan in Query.lua comes back empty exactly when the
-- groups matter. The AuraContainer intrinsic is the engine-side path: we
-- declare filter strings, candidate filters and sort, hand the engine plain
-- widgets, and it drives them with the secret data. Same architecture as
-- RealUI_Nameplates' Elements/Auras.lua and the HuD aura elements.
--
-- Option mapping (realui-auras tasks.md, "Option mapping, 2026-09-26"):
--   * checkTimeLeft has no engine equivalent. A group with it on stays on the
--     legacy Lua renderer (Groups.Redraw -> Query/Icons), which works whenever
--     the list is readable: always out of combat. Owner decision.
--   * a duration cap (maxDuration) always drops permanent auras too.
--   * spell lists exclude by spell ID only (excludeSpellIDs).
--   * desaturate / desaturateFriend split each kind into a "mine" group and a
--     desaturated "others" group: mine first, then others.

local AurasAddon = LibStub("AceAddon-3.0"):GetAddon("RealUI_Auras")
local Containers = {}
AurasAddon.Containers = Containers

local HUGE_DURATION = 1e9  -- a maxDuration that only drops permanent auras

-- engine[groupName] = { container = AuraContainer, signature = string }
local engine = {}

function Containers.UsesEngine(group)
    return group and not group.checkTimeLeft
end

local function MonitoredUnit(group)
    if group.detectBuffs and group.detectBuffsMonitor then return group.detectBuffsMonitor end
    if group.detectDebuffs and group.detectDebuffsMonitor then return group.detectDebuffsMonitor end
    return group.unit
end

local function ExcludedSpellIDs(listKey)
    local lists = AurasAddon.db and AurasAddon.db.global.SpellLists
    local list = listKey and lists and lists[listKey]
    if not list then return end
    local ids
    for key in pairs(list) do
        if type(key) == "number" then
            ids = ids or {}
            ids[key] = true
        end
    end
    return ids
end

local function CandidateFilters(group, kind)
    local candidates = {}
    if kind == "debuff" and group.detectOtherDebuffs == false then
        candidates.isFromPlayerOrPlayerPet = true
    end
    if group.checkDuration and (group.filterDuration or 0) > 0 then
        candidates.maxDuration = group.filterDuration
    elseif not group.showNoDuration then
        candidates.maxDuration = HUGE_DURATION
    end
    local listKey = (kind == "buff") and group.filterBuffTable or group.filterDebuffTable
    candidates.excludeSpellIDs = ExcludedSpellIDs(listKey)
    if next(candidates) then return candidates end
end

-- The sub-groups a group renders as, in layout order.
local function SubGroups(group)
    local result = {}
    local desaturate = group.desaturate or group.desaturateFriend
    for _, kind in ipairs({ "buff", "debuff" }) do
        local wanted = (kind == "buff") and group.detectBuffs or group.detectDebuffs
        if wanted then
            local base = AurasAddon.Query.BuildFilter(group, kind)
            local castByPlayer = base:find("|PLAYER", 1, true)
            if desaturate and not castByPlayer then
                result[#result + 1] = { kind = kind, filter = base .. "|PLAYER" }
                result[#result + 1] = { kind = kind, filter = base .. "|!PLAYER", desaturated = true }
            else
                result[#result + 1] = { kind = kind, filter = base }
            end
        end
    end
    return result
end

-- Anything that changes the set of groups or the buttons themselves needs a
-- fresh container; everything else is live-mutable.
local function Signature(group, subGroups)
    local parts = { group.iconSize, MonitoredUnit(group), group.anchorFrame or group.parentFrame or "" }
    for _, sub in ipairs(subGroups) do
        parts[#parts + 1] = sub.filter
    end
    return table.concat(parts, ";")
end

local function InitializeButton(group, sub, unit, button)
    button:SetSize(group.iconSize, group.iconSize)
    button:EnableMouse(true)
    button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", 0, 0)

    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    cooldown:SetDrawEdge(false)
    cooldown:SetHideCountdownNumbers(true)
    button:SetDurationCooldown(cooldown)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetDesaturated(sub.desaturated and true or false)
    button:SetIcon(icon)

    local textParent = CreateFrame("Frame", nil, button)
    textParent:SetAllPoints()
    textParent:SetFrameLevel(cooldown:GetFrameLevel() + 1)
    local count = textParent:CreateFontString(nil, "OVERLAY")
    count:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    button:SetApplicationCount(count, {})

    local border
    if sub.kind == "debuff" then
        border = button:CreateTexture(nil, "OVERLAY")
        border:SetAllPoints()
        button:AddDispelTypeTexture(border, {
            style = Enum.CustomAuraButtonDispelTypeTextureStyle.Border,
            showWhenHarmful = true,
        })
    end

    -- Right-click cancel, combat-legal through the intrinsic (the legacy
    -- CancelUnitBuff path is not).
    if sub.kind == "buff" and unit == "player" then
        button:SetCancelAuraButtons("RightButtonUp")
    end

    local MasqueGroup = AurasAddon.Icons and AurasAddon.Icons.MasqueGroup
    if MasqueGroup then
        pcall(MasqueGroup.AddButton, MasqueGroup, button, {
            Icon = icon, Count = count, Cooldown = cooldown, Border = border,
        })
    end
end

local function Anchor(container, group)
    local parentName = group.anchorFrame or group.parentFrame
    local parent = parentName and _G[parentName]
    if not parent then return false end

    -- Same anchoring rules as Groups.CreateContainer (legacy renderer).
    local isPositioner = (group.anchorFrame ~= nil)
    local isRight = (group.iconAlign ~= "LEFT")
    local myPoint, parentPoint
    if isRight then
        myPoint = "TOPRIGHT"
        parentPoint = isPositioner and "TOPRIGHT" or "BOTTOMRIGHT"
    else
        myPoint = "TOPLEFT"
        parentPoint = isPositioner and "TOPLEFT" or "BOTTOMLEFT"
    end
    container:ClearAllPoints()
    container:SetPoint(myPoint, parent, parentPoint, group.anchorX or 0, group.anchorY or 0)
    container:SetFlowLayoutAnchorPoint(myPoint)
    container:SetFlowLayoutGrowthDirection(isRight and -1 or 1, -1)
    return true
end

local function Configure(container, group, subGroups)
    -- Always set, so turning "Sort by Time" off restores the default order.
    local sortMethod = group.timeSort and AuraContainerSortMethod.ExpirationOnly
        or AuraContainerSortMethod.Default
    local sortDirection = group.reverseSort and AuraContainerSortDirection.Reverse
        or AuraContainerSortDirection.Normal
    for i, sub in ipairs(subGroups) do
        local key = tostring(i)
        container:SetAuraGroupFilterString(key, sub.filter)
        container:SetAuraGroupCandidateFilters(key, CandidateFilters(group, sub.kind))
        container:SetAuraGroupMaxFrameCount(key, group.maxBars or 40)
        container:SetAuraGroupSortMethod(key, sortMethod, sortDirection)
    end
    local step = group.iconSize + (group.spacingX or 0)
    container:SetFlowLayoutMaximumLineSize(step * math.max(group.wrap or 1, 1))
end

local function Build(group, subGroups)
    local parentName = group.anchorFrame or group.parentFrame
    local parent = parentName and _G[parentName]
    if not parent then return end

    local ok, container = pcall(CreateFrame, "AuraContainer", nil, parent, "CustomAuraContainerTemplate")
    if not ok or not container then return end
    container:SetSize(1, 1)

    local unit = MonitoredUnit(group)
    local layout = {
        elementSpacing = group.spacingX or 0,
        lineSpacing = math.abs(group.spacingY or 0),
    }
    local built = pcall(function()
        for i, sub in ipairs(subGroups) do
            local initializer = function(button) InitializeButton(group, sub, unit, button) end
            container:AddAuraGroup(tostring(i), "", { initializeFrame = initializer })
            container:SetAuraGroupLayout(tostring(i), layout)
        end
    end)
    if not built then
        container:Hide()
        return
    end
    return container
end

local function Retire(state)
    if state and state.container then
        pcall(state.container.SetUnit, state.container, nil)
        state.container:Hide()
        state.container = nil
    end
end

--- Render (or re-render) a group on the engine. Called from Groups.Redraw.
function Containers.Refresh(group)
    local state = engine[group.name]
    if group.disabled or not Containers.UsesEngine(group) then
        Retire(state)
        return
    end

    local subGroups = SubGroups(group)
    local signature = Signature(group, subGroups)
    if not state or state.signature ~= signature or not state.container then
        Retire(state)
        state = { container = Build(group, subGroups), signature = signature }
        engine[group.name] = state
    end
    local container = state.container
    if not container then return end  -- parent frame not there yet; retried later

    local ok = pcall(function()
        Anchor(container, group)
        Configure(container, group, subGroups)
    end)
    local unit = MonitoredUnit(group)
    if not ok or #subGroups == 0 or not UnitExists(unit) then
        pcall(container.SetUnit, container, nil)
        container:Hide()
        return
    end
    -- Re-binding also refreshes after the unit behind a token changed
    -- (target, focus, targettarget).
    pcall(container.SetUnit, container, unit)
    container:Show()
end

--- Spell lists accept IDs only now; convert names saved before the engine
--- migration where the client can resolve them. Unresolvable names are kept
--- (they still apply to groups on the legacy renderer).
function Containers.ConvertSpellListNames()
    local lists = AurasAddon.db and AurasAddon.db.global.SpellLists
    if not lists then return end
    for _, list in pairs(lists) do
        local converted = {}
        for key in pairs(list) do
            if type(key) == "string" then
                local info = C_Spell.GetSpellInfo(key)
                if info and info.spellID then
                    converted[key] = info.spellID
                end
            end
        end
        for name, spellID in pairs(converted) do
            list[name] = nil
            list[spellID] = true
        end
    end
end
