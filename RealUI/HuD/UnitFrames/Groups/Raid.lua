local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")

--[[ RealUI raid/party frames (spec: realui-raidframes).

     oUF secure group headers in their own lightweight "RealUI-Raid" style —
     deliberately NOT the HuD `Shared` style, whose angled-bar pipeline and
     unitData model don't fit 70×30 grid cells.

     Mutual exclusion: when Grid2 is loaded, nothing here spawns and Grid2
     keeps working exactly as today (spec req 2.1).

     Secret-value rules apply throughout (steering doc): no naked truth tests
     on combat booleans, no health arithmetic outside pcall (the raidtop tag
     handles that), aura rendering only via the AuraContainer intrinsic
     (UnitFrames.CreateAuraElement). ]]--

local function GetRaidDB()
    return UnitFrames.db.profile.units.raid
end

-- HoT/shield watch-list for the left icons (Grid2-profile parity set + the
-- obvious modern additions). Combined across healer classes: the PLAYER filter
-- already limits it to the player's own casts, so foreign entries never match.
local HOT_SPELLS = {
    139,    -- Renew
    33076,  -- Prayer of Mending
    17,     -- Power Word: Shield
    61295,  -- Riptide
    774,    -- Rejuvenation
    33763,  -- Lifebloom
    8936,   -- Regrowth
    48438,  -- Wild Growth
    119611, -- Renewing Mist
    124682, -- Enveloping Mist
    53563,  -- Beacon of Light
    364343, -- Echo (Evoker)
    355941, -- Dream Breath
}
local HOT_CANDIDATES = { includeSpellIDs = HOT_SPELLS }

local function ApplyHotFilter(element, filtered)
    if not (element and element._ruiGroupKey) then return end
    _G.pcall(element.SetAuraGroupCandidateFilters, element,
        element._ruiGroupKey, filtered and HOT_CANDIDATES or nil)
end

--[[ Blizzard party/raid frame suppression (reversible, spec req 2.3) ]]--

local hider
local suppressed = {}
local function SuppressBlizzard()
    -- PartyFrame is handled by oUF's own DisableBlizzard('party') (triggered by
    -- the showParty attribute at SpawnHeader time); we only cover the raid side.
    hider = hider or _G.CreateFrame("Frame", "RealUIRaidBlizzHider", _G.UIParent)
    hider:Hide()
    for _, name in _G.ipairs({ "CompactRaidFrameManager", "CompactRaidFrameContainer" }) do
        local frame = _G[name]
        if frame and not suppressed[name] then
            local ok, parent = _G.pcall(frame.GetParent, frame)
            if ok and _G.pcall(frame.SetParent, frame, hider) then
                suppressed[name] = parent or _G.UIParent
            end
        end
    end
end

function UnitFrames:RestoreBlizzardGroupFrames()
    for name, parent in _G.next, suppressed do
        local frame = _G[name]
        if frame then
            _G.pcall(frame.SetParent, frame, parent)
        end
        suppressed[name] = nil
    end
end

--[[ Out-of-combat queue for secure header changes (spec req: combat lockdown) ]]--

local pendingApply
local regenWatcher
local function QueueSecure(fn)
    if not _G.InCombatLockdown() then return fn() end
    pendingApply = fn
    if not regenWatcher then
        regenWatcher = _G.CreateFrame("Frame")
        regenWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
        regenWatcher:SetScript("OnEvent", function()
            local apply = pendingApply
            pendingApply = nil
            if apply then apply() end
        end)
    end
end

--[[ Style ]]--

local function RaidStyle(self, unit)
    local rdb = GetRaidDB()
    local width, height = rdb.size.x, rdb.size.y

    self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", function(frame, ...)
        frame.unit = frame.__unit  -- Blizzard tooltip compat (same as Shared style)
        return _G.UnitFrame_OnEnter(frame, ...)
    end)
    self:SetScript("OnLeave", _G.UnitFrame_OnLeave)

    local bg = self:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(self)
    bg:SetColorTexture(0, 0, 0, 0.6)

    -- Health: class-colored fill over a dark background — the growing dark
    -- region IS the deficit indicator (Grid2 health-deficit parity).
    local Health = _G.CreateFrame("StatusBar", nil, self)
    Health:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
    Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
    Health:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
    Health:SetClipsChildren(true)
    Health.colorClass = true
    Health.colorReaction = true
    Health.colorDisconnected = true
    self.Health = Health

    -- Incoming heals + absorbs ride the health fill edge; values are driven
    -- secret-safe by the oUF 14 health element (StatusBar:SetValue is
    -- secret-capable), anchoring is ours.
    local HealingAll = _G.CreateFrame("StatusBar", nil, Health)
    HealingAll:SetPoint("TOPLEFT", Health:GetStatusBarTexture(), "TOPRIGHT")
    HealingAll:SetPoint("BOTTOMLEFT", Health:GetStatusBarTexture(), "BOTTOMRIGHT")
    HealingAll:SetWidth(width)
    HealingAll:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
    HealingAll:SetStatusBarColor(0.2, 0.8, 0.2, 0.25)
    Health.HealingAll = HealingAll

    local DamageAbsorb = _G.CreateFrame("StatusBar", nil, Health)
    DamageAbsorb:SetPoint("TOPLEFT", HealingAll:GetStatusBarTexture(), "TOPRIGHT")
    DamageAbsorb:SetPoint("BOTTOMLEFT", HealingAll:GetStatusBarTexture(), "BOTTOMRIGHT")
    DamageAbsorb:SetWidth(width)
    DamageAbsorb:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
    DamageAbsorb:SetStatusBarColor(1, 1, 1, 0.25)
    Health.DamageAbsorb = DamageAbsorb

    -- Threat border: single ring texture oUF shows/colors by threat status.
    local ThreatIndicator = self:CreateTexture(nil, "BACKGROUND", nil, -1)
    ThreatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -1, 1)
    ThreatIndicator:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1)
    ThreatIndicator:SetColorTexture(1, 1, 1, 0.9)
    self.ThreatIndicator = ThreatIndicator

    -- Texts (tags are event-driven and secret-guarded in Tags.lua). White +
    -- outline for contrast on class-colored fills; the raidname tag deliberately
    -- skips class coloring for the same reason.
    local function ApplyCellFont(fontString)
        fontString:SetFontObject("SystemFont_Shadow_Small")
        local font, size = fontString:GetFont()
        if font and size then
            fontString:SetFont(font, size, "OUTLINE")
        end
        fontString:SetTextColor(1, 1, 1)
    end

    local topText = Health:CreateFontString(nil, "OVERLAY")
    ApplyCellFont(topText)
    topText:SetPoint("TOP", self, "TOP", 0, -2)
    self:Tag(topText, "[realui:raidtop]")

    local nameText = Health:CreateFontString(nil, "OVERLAY")
    ApplyCellFont(nameText)
    nameText:SetPoint("BOTTOM", self, "BOTTOM", 0, 2)
    nameText:SetWidth(width - 4)
    nameText:SetWordWrap(false)
    self:Tag(nameText, "[realui:raidname]")

    -- Indicator icons (all built-in oUF elements).
    local RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
    RaidTargetIndicator:SetSize(12, 12)
    RaidTargetIndicator:SetPoint("RIGHT", self, "RIGHT", -2, 0)
    self.RaidTargetIndicator = RaidTargetIndicator

    local GroupRoleIndicator = self:CreateTexture(nil, "OVERLAY")
    GroupRoleIndicator:SetSize(10, 10)
    GroupRoleIndicator:SetPoint("BOTTOM", self, "BOTTOM", 0, -4)
    self.GroupRoleIndicator = GroupRoleIndicator

    local LeaderIndicator = self:CreateTexture(nil, "OVERLAY")
    LeaderIndicator:SetSize(10, 10)
    LeaderIndicator:SetPoint("TOPRIGHT", self, "TOPRIGHT", 2, 4)
    self.LeaderIndicator = LeaderIndicator

    local AssistantIndicator = self:CreateTexture(nil, "OVERLAY")
    AssistantIndicator:SetSize(10, 10)
    AssistantIndicator:SetPoint("TOPRIGHT", self, "TOPRIGHT", 2, 4)
    self.AssistantIndicator = AssistantIndicator

    local ReadyCheckIndicator = self:CreateTexture(nil, "OVERLAY", nil, 2)
    ReadyCheckIndicator:SetSize(16, 16)
    ReadyCheckIndicator:SetPoint("CENTER", self)
    self.ReadyCheckIndicator = ReadyCheckIndicator

    -- Range fading.
    self.Range = { insideAlpha = 1, outsideAlpha = rdb.rangeAlpha or 0.4 }

    -- Center debuff: dispellable-by-me debuffs via the AuraContainer intrinsic
    -- ("RAID" filter token = auras the player can dispel). Curated boss-debuff
    -- lists are explicitly out of scope (spec overview).
    if rdb.icons.centerDebuff then
        local Debuffs = UnitFrames.CreateAuraElement(self, {
            filter = "HARMFUL|RAID",
            count = 1,
            size = 14,
            spacing = 0,
            growthX = "RIGHT",
            growthY = "UP",
            showDebuffBorder = true,
            -- Mini icons: no cooldown swipe/countdown — the engine countdown
            -- text dwarfs a 14px icon.
            disableCooldown = true,
        })
        Debuffs:SetPoint("CENTER", self, "CENTER", 0, 0)
        self.Debuffs = Debuffs
    end

    -- Left icons: my HoTs/shields on the unit (HELPFUL|PLAYER), growing right.
    -- Count is live-configurable (SetAuraGroupMaxFrameCount in RefreshRaid).
    -- Per-spell watch-list refinement pending candidate-filter verification.
    if rdb.icons.hots then
        local Buffs = UnitFrames.CreateAuraElement(self, {
            filter = "HELPFUL|PLAYER",
            count = rdb.icons.hotsCount or 2,
            size = 10,
            spacing = 1,
            growthX = "RIGHT",
            growthY = "UP",
            disableCooldown = true,
        })
        ApplyHotFilter(Buffs, rdb.icons.hotsFilter ~= false)
        Buffs:SetPoint("LEFT", self, "LEFT", 2, 0)
        self.Buffs = Buffs
    end
end

--[[ Spawn ]]--

local function BuildInitialConfig(rdb)
    return ([[self:SetWidth(%d) self:SetHeight(%d)]]):format(rdb.size.x, rdb.size.y)
end

local anchorHolder
_G.tinsert(UnitFrames.units, function()
    local rdb = GetRaidDB()
    if not rdb or rdb.enabled == false then return end

    -- Grid2 mutual exclusion: Grid2 owns group frames when present.
    if _G.C_AddOns.IsAddOnLoaded("Grid2") then
        UnitFrames:debug("Raid: Grid2 detected, skipping spawn")
        return
    end

    oUF:RegisterStyle("RealUI-Raid", RaidStyle)
    oUF:SetActiveStyle("RealUI-Raid")

    local spacing = rdb.spacing or 2

    -- One movable anchor for both headers. Default hangs below the HuD center
    -- positioner (tracks HuD position/scale like boss frames do), group 1
    -- centered under it; saved FramePoint positions are per-profile, so the
    -- DPS and Healing layouts remember their own spots once moved.
    anchorHolder = _G.CreateFrame("Frame", "RealUIRaidAnchor", _G.UIParent)
    anchorHolder:SetSize(rdb.size.x, rdb.size.y)
    local anchored = _G.pcall(anchorHolder.SetPoint, anchorHolder,
        "TOP", "RealUIPositionersUnitFrames", "BOTTOM",
        -_G.math.floor(rdb.size.x / 2), -150)
    if not anchored then
        anchorHolder:SetPoint("BOTTOM", _G.UIParent, "BOTTOM", 0, 300)
    end

    -- oUF 14: SpawnHeader takes (name, template, ...attribute pairs) — NO
    -- visibility parameter (removed from oUF 13); visibility is driven below
    -- with RegisterStateDriver. A stray string in the vararg list shifts every
    -- attribute pair by one and ends in SetAttribute(true, ...) → blocked.
    local party = oUF:SpawnHeader("RealUIParty", nil,
        "showParty", true,
        "showPlayer", true,
        "showSolo", false,
        "point", "TOP",
        "yOffset", -spacing,
        "oUF-initialConfigFunction", BuildInitialConfig(rdb))
    party:SetPoint("TOPLEFT", anchorHolder, "TOPLEFT", 0, 0)
    _G.RegisterStateDriver(party, "visibility", "[group:raid] hide; [group:party] show; hide")

    local raid = oUF:SpawnHeader("RealUIRaid", nil,
        "showRaid", true,
        "showSolo", false,
        "groupBy", "GROUP",
        "groupingOrder", "1,2,3,4,5,6,7,8",
        "unitsPerColumn", 5,
        "maxColumns", 8,
        "point", "TOP",
        "yOffset", -spacing,
        "columnAnchorPoint", "LEFT",
        "columnSpacing", spacing,
        "oUF-initialConfigFunction", BuildInitialConfig(rdb))
    raid:SetPoint("TOPLEFT", anchorHolder, "TOPLEFT", 0, 0)
    _G.RegisterStateDriver(raid, "visibility", "[group:raid] show; hide")

    UnitFrames.partyHeader = party
    UnitFrames.raidHeader = raid

    -- Register the mover AFTER the headers exist (Boss.lua order), then raise
    -- its strata: header CHILDREN are created later still (roster processing),
    -- so creation order alone leaves the mover buried under the cells when in
    -- a group. FramePoint re-anchors our holder onto its dragFrame, so the
    -- dragFrame is recoverable from the holder's anchor point.
    FramePoint:PositionFrame(UnitFrames, anchorHolder, {"profile", "units", "raid", "framePoint"})
    local _, dragFrame = anchorHolder:GetPoint(1)
    if dragFrame and dragFrame ~= _G.UIParent then
        dragFrame:SetFrameStrata("HIGH")
    end

    -- Hand the style token back for anything spawned later.
    oUF:SetActiveStyle("RealUI")

    QueueSecure(SuppressBlizzard)
end)

--[[ Config-mode placeholder cells: secure headers can't show fake units, so
     positioning while solo gets styled dummy textures anchored exactly where
     the party header renders. Toggled by RealUI:HuDTestMode. ]]--

local testFrame
local TEST_CLASSES = {
    "SHAMAN", "MAGE", "DRUID", "PALADIN", "WARRIOR",
    "PRIEST", "HUNTER", "WARLOCK", "ROGUE", "MONK",
    "DEATHKNIGHT", "DEMONHUNTER", "EVOKER",
}
local TEST_GROUPS, TEST_PER_GROUP = 4, 5  -- 20-man preview, like Grid2's test mode
function UnitFrames:ToggleRaidTestMode(show)
    local rdb = GetRaidDB()
    if show then
        if rdb.enabled == false or _G.C_AddOns.IsAddOnLoaded("Grid2") then return end
        if not anchorHolder then return end
        if not testFrame then
            local spacing = rdb.spacing or 2
            local cellW, cellH = rdb.size.x, rdb.size.y
            testFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
            testFrame:SetPoint("TOPLEFT", anchorHolder, "TOPLEFT", 0, 0)
            testFrame:SetSize((cellW + spacing) * TEST_GROUPS, (cellH + spacing) * TEST_PER_GROUP)
            -- Columns mirror the live raid header: cells stack downward, groups
            -- extend rightward (point TOP / columnAnchorPoint LEFT). In a real
            -- group the live cells simply cover preview column 1.
            local n = 0
            for col = 0, TEST_GROUPS - 1 do
                for row = 0, TEST_PER_GROUP - 1 do
                    n = n + 1
                    local cell = testFrame:CreateTexture(nil, "ARTWORK")
                    cell:SetSize(cellW, cellH)
                    cell:SetPoint("TOPLEFT", testFrame, "TOPLEFT",
                        col * (cellW + spacing), -(row * (cellH + spacing)))
                    local color = _G.RAID_CLASS_COLORS[TEST_CLASSES[(n - 1) % #TEST_CLASSES + 1]]
                    cell:SetColorTexture(color.r, color.g, color.b, 0.7)

                    local label = testFrame:CreateFontString(nil, "OVERLAY")
                    label:SetFontObject("SystemFont_Shadow_Small")
                    label:SetTextColor(1, 1, 1)
                    label:SetPoint("BOTTOM", cell, "BOTTOM", 0, 2)
                    if row == 0 then
                        label:SetFormattedText("%s %d", _G.GROUP, col + 1)
                    else
                        label:SetFormattedText("%s %d", _G.RAID, n)
                    end
                end
            end
        end
        testFrame:Show()
    elseif testFrame then
        testFrame:Hide()
    end
end

--[[ Runtime toggle support (config lands in a later task; the plumbing is
     here so enabling/disabling is already reversible). ]]--

function UnitFrames:RefreshRaid()
    local rdb = GetRaidDB()
    if not (self.partyHeader and self.raidHeader) then return end

    -- Live-updatable bits on existing cells (insecure reads only).
    for _, header in _G.ipairs({ self.partyHeader, self.raidHeader }) do
        for i = 1, header:GetNumChildren() do
            local cell = _G.select(i, header:GetChildren())
            if cell and cell.Range then
                cell.Range.outsideAlpha = rdb.rangeAlpha or 0.4
            end
            if cell and cell.Buffs and cell.Buffs._ruiGroupKey then
                _G.pcall(cell.Buffs.SetAuraGroupMaxFrameCount, cell.Buffs,
                    cell.Buffs._ruiGroupKey, rdb.icons.hotsCount or 2)
                ApplyHotFilter(cell.Buffs, rdb.icons.hotsFilter ~= false)
            end
        end
    end
    QueueSecure(function()
        if rdb.enabled == false then
            _G.UnregisterStateDriver(self.partyHeader, "visibility")
            _G.UnregisterStateDriver(self.raidHeader, "visibility")
            self.partyHeader:Hide()
            self.raidHeader:Hide()
            UnitFrames:RestoreBlizzardGroupFrames()
        else
            _G.RegisterStateDriver(self.partyHeader, "visibility",
                "[group:raid] hide; [group:party] show; hide")
            _G.RegisterStateDriver(self.raidHeader, "visibility", "[group:raid] show; hide")
            SuppressBlizzard()
        end
    end)
end
