-- Icons.lua: Icon pool, per-icon update, Cooldown frame, Masque registration
-- Creates, acquires, releases, updates, and lays out aura icon buttons.

local AurasAddon = LibStub("AceAddon-3.0"):GetAddon("RealUI_Auras")
local Groups = AurasAddon.Groups
local Icons = {}
AurasAddon.Icons = Icons

---------------------------------------------------------------------------
-- 5.1  Icons.Create(group)
-- Creates a new icon Button with child regions: Icon (Texture),
-- Count (FontString), Cooldown (CooldownFrameTemplate), DebuffBorder (Texture).
---------------------------------------------------------------------------
function Icons.Create(group)
    local state = Groups.GetState(group.name)
    local btn = CreateFrame("Button", nil, state.container)
    btn:SetSize(group.iconSize, group.iconSize)
    btn:EnableMouse(true)

    btn.Icon = btn:CreateTexture(nil, "ARTWORK")
    btn.Icon:SetAllPoints()
    btn.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    btn.Count = btn:CreateFontString(nil, "OVERLAY")
    btn.Count:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    btn.Count:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 1)

    btn.Cooldown = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
    btn.Cooldown:SetAllPoints()
    btn.Cooldown:SetDrawEdge(false)
    btn.Cooldown:SetHideCountdownNumbers(true)

    btn.DebuffBorder = btn:CreateTexture(nil, "OVERLAY")
    btn.DebuffBorder:SetAllPoints()

    btn:RegisterForClicks("RightButtonUp")
    btn:SetScript("OnEnter", Icons.OnEnter)
    btn:SetScript("OnLeave", Icons.OnLeave)
    btn:SetScript("OnClick", Icons.OnClick)

    -- Masque registration (Icons.MasqueGroup is set in Task 10)
    if Icons.MasqueGroup then
        Icons.MasqueGroup:AddButton(btn, {
            Icon     = btn.Icon,
            Count    = btn.Count,
            Cooldown = btn.Cooldown,
            Border   = btn.DebuffBorder,
        })
    end

    return btn
end

---------------------------------------------------------------------------
-- 5.2  Icons.Acquire(group)
-- Pops a recycled button from the pool, or creates a new one.
-- Pushes the button into the active icons list and returns it.
---------------------------------------------------------------------------
function Icons.Acquire(group)
    local state = Groups.GetState(group.name)
    local btn = tremove(state.pool) or Icons.Create(group)
    tinsert(state.icons, btn)
    return btn
end

---------------------------------------------------------------------------
-- 5.3  Icons.ReleaseAll(group)
-- Hides every active icon and returns it to the pool.
---------------------------------------------------------------------------
function Icons.ReleaseAll(group)
    local state = Groups.GetState(group.name)
    for _, btn in ipairs(state.icons) do
        btn:Hide()
        tinsert(state.pool, btn)
    end
    wipe(state.icons)
end

---------------------------------------------------------------------------
-- 5.4  Icons.Update(btn, auraData, group)
-- Applies aura data to an icon button: texture, desaturation, stack count,
-- cooldown, debuff border, and tooltip metadata.
---------------------------------------------------------------------------
function Icons.Update(btn, auraData, group)
    btn:SetSize(group.iconSize, group.iconSize)

    -- Spell icon texture
    btn.Icon:SetTexture(auraData.icon)

    -- Desaturation: desaturate auras not cast by the player
    local shouldDesaturate = false
    if group.desaturate and not auraData.isFromPlayer then
        shouldDesaturate = true
    end
    if group.desaturateFriend and not auraData.isFromPlayer
       and auraData.sourceUnit and UnitIsFriend("player", auraData.sourceUnit) then
        shouldDesaturate = true
    end
    btn.Icon:SetDesaturated(shouldDesaturate)

    -- Stack count (hide when 0 or 1)
    if auraData.applications and auraData.applications > 1 then
        btn.Count:SetText(auraData.applications)
        btn.Count:Show()
    else
        btn.Count:Hide()
    end

    -- Cooldown timer
    if auraData.duration and auraData.duration > 0 then
        btn.Cooldown:SetCooldown(
            auraData.expirationTime - auraData.duration,
            auraData.duration,
            auraData.timeMod or 1
        )
        btn.Cooldown:Show()
    else
        btn.Cooldown:Clear()
        btn.Cooldown:Hide()
    end

    -- Debuff border (skip when Masque owns the border)
    if not Icons.MasqueGroup and auraData.dispelName then
        AuraUtil.SetAuraBorderAtlas(btn.DebuffBorder, auraData.dispelName, false)
        btn.DebuffBorder:Show()
    else
        btn.DebuffBorder:Hide()
    end

    -- Store metadata for tooltip and right-click cancellation
    btn._unit = group.detectBuffsMonitor or group.detectDebuffsMonitor or group.unit
    btn._name = auraData.name
    btn._auraInstanceID = auraData.auraInstanceID
    btn.auraInstanceID  = auraData.auraInstanceID  -- CooldownCount ShouldHaveTimer check
    btn._isDebuff = auraData.isDebuff
    btn._isEnchant = auraData._isEnchant
    btn._enchantSlot = auraData._enchantSlot

    btn:Show()
end

---------------------------------------------------------------------------
-- 5.5  Icons.Layout(group)
-- Positions each active icon in a wrapping grid inside the group container.
-- Resizes the container to fit the actual number of icons.
---------------------------------------------------------------------------
function Icons.Layout(group)
    local state = Groups.GetState(group.name)
    local iconSize = group.iconSize
    local spacingX = group.spacingX
    local spacingY = group.spacingY
    local wrap     = group.wrap
    local growLeft = (group.iconAlign == "LEFT")

    local stepX = iconSize + spacingX
    local stepY = iconSize + math.abs(spacingY)

    for i, btn in ipairs(state.icons) do
        local col = (i - 1) % wrap
        local row = math.floor((i - 1) / wrap)

        local x = growLeft and (col * stepX) or (-(col * stepX))
        local y = -(row * stepY)

        btn:ClearAllPoints()
        if growLeft then
            btn:SetPoint("TOPLEFT", state.container, "TOPLEFT", x, y)
        else
            btn:SetPoint("TOPRIGHT", state.container, "TOPRIGHT", x, y)
        end
    end

    -- Resize container to fit actual icons
    local cols = math.min(#state.icons, wrap)
    local rows = math.ceil(#state.icons / math.max(wrap, 1))
    if cols > 0 and rows > 0 then
        state.container:SetSize(
            cols * iconSize + math.max(cols - 1, 0) * math.abs(spacingX),
            rows * iconSize + math.max(rows - 1, 0) * math.abs(spacingY)
        )
        state.container:Show()
    else
        state.container:Hide()
    end
end

---------------------------------------------------------------------------
-- 5.6  Icons.OnEnter / Icons.OnLeave
-- Tooltip scripts. Uses the modern auraInstanceID-based tooltip APIs.
-- GameTooltip:SetUnitAura is deprecated; use SetUnitBuffByAuraInstanceID /
-- SetUnitDebuffByAuraInstanceID instead. Weapon enchants use SetInventoryItem.
---------------------------------------------------------------------------
function Icons.OnEnter(btn)
    GameTooltip:SetOwner(btn, "ANCHOR_BOTTOMLEFT")
    if btn._isEnchant then
        -- Weapon enchant: slot 1 = main hand (invSlot 16), slot 2 = off hand (invSlot 17)
        local slotID = (btn._enchantSlot == 1) and 16 or 17
        GameTooltip:SetInventoryItem("player", slotID)
    elseif btn._isDebuff then
        GameTooltip:SetUnitDebuffByAuraInstanceID(btn._unit, btn._auraInstanceID)
    else
        GameTooltip:SetUnitBuffByAuraInstanceID(btn._unit, btn._auraInstanceID)
    end
    GameTooltip:Show()
end

function Icons.OnLeave()
    GameTooltip:Hide()
end

function Icons.OnClick(btn, button)
    if button ~= "RightButton" then return end
    if btn._isEnchant then
        _G.CancelItemTempEnchantment(btn._enchantSlot)
    elseif not btn._isDebuff and btn._unit == "player" and btn._name then
        _G.CancelUnitBuff("player", btn._name)
    end
end
