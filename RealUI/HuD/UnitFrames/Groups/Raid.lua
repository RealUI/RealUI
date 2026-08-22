local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")

-- Default anchor per layout (1 = DPS/Tank, 2 = Healing), mirroring the presets
-- in Modules/GridLayout.lua. Kept in UIParent coordinates: GridLayout scales
-- these by the effective scale because Grid2 stores UI-root-scaled values —
-- our headers are plain UIParent children, so no scaling applies here.
-- B10 reference layout, measured from Arnvid's hand placement via
-- /realdev layoutdump (2026-08-22): left edge, first cell just above vertical
-- centre — the grid grows down/right from there, clear of chat, HuD and bars.
-- Healing keeps the centre-bottom convention pending a healer-layout session.
local DEFAULT_POSITIONS = {
    [1] = { point = "LEFT",   x = 25,   y = 17 },   -- DPS/Tank: left edge, mid-height
    -- Healing: measured from Arnvid's hand-placement 2026-08-22
    -- (/realdev layoutdump), sitting in the gap between bars 1 and 2 where a
    -- healer's eyes already are. Replaces a never-tuned centre-bottom
    -- placeholder that overlapped the bars.
    [2] = { point = "BOTTOM", x = -146, y = 241 },
}

-- B31/B10: party shares the raid REGION by design — the two headers are
-- mutually exclusive ([group:raid] hides party), so the group block stays in
-- one place as the group grows. Per-layout since 2026-08-22: healing wants the
-- block between the bars, and a shared value would have left party on the left
-- edge while raid sat centre — the same job in two different places depending
-- on group size. Each profile still remembers its own position once moved.
local PARTY_DEFAULT_POSITIONS = {
    [1] = { point = "LEFT",   x = 25, y = 17 },  -- DPS/Tank: matches raid
    [2] = { point = "BOTTOM", x = -2, y = 240 }, -- Healing: measured 2026-08-22
}

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

-- B31: party sub-settings. Lazily initialized because the AceDB defaults table
-- lives in UnitFrames.lua (owned elsewhere); once `party = { horizontal = false,
-- framePoint = {} }` is added to the `units.raid` defaults there, this collapses
-- to a plain accessor. `horizontal` = party cells in a row instead of a column.
local function GetPartyDB()
    local rdb = GetRaidDB()
    if not rdb.party then rdb.party = {} end
    if rdb.party.horizontal == nil then rdb.party.horizontal = false end
    if not rdb.party.framePoint then rdb.party.framePoint = {} end
    return rdb.party
end

-- Secure header attributes for the two party orientations. Applied at spawn and
-- from RefreshRaid (via QueueSecure — attribute writes are combat-locked).
local function GetPartyLayoutAttributes(rdb)
    local spacing = rdb.spacing or 2
    if GetPartyDB().horizontal then
        return "LEFT", spacing, 0   -- point, xOffset, yOffset: grow right
    end
    return "TOP", 0, -spacing       -- grow down
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
    local width = rdb.size.x

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

    -- Indicator icons (all built-in oUF elements). B39: Health is a child FRAME
    -- of the cell, so textures created directly on the cell render underneath
    -- the health fill no matter what draw layer they use. Put the indicators on
    -- a dedicated overlay frame parented to the cell (NOT to Health, whose
    -- SetClipsChildren would clip the icons that hang past the cell edge) with
    -- a frame level safely above Health and its heal/absorb child bars.
    local Overlay = _G.CreateFrame("Frame", nil, self)
    Overlay:SetAllPoints(self)
    Overlay:SetFrameLevel(Health:GetFrameLevel() + 5)

    local RaidTargetIndicator = Overlay:CreateTexture(nil, "OVERLAY")
    RaidTargetIndicator:SetSize(12, 12)
    RaidTargetIndicator:SetPoint("RIGHT", self, "RIGHT", -2, 0)
    self.RaidTargetIndicator = RaidTargetIndicator

    local GroupRoleIndicator = Overlay:CreateTexture(nil, "OVERLAY")
    GroupRoleIndicator:SetSize(10, 10)
    GroupRoleIndicator:SetPoint("BOTTOM", self, "BOTTOM", 0, -4)
    self.GroupRoleIndicator = GroupRoleIndicator

    local LeaderIndicator = Overlay:CreateTexture(nil, "OVERLAY")
    LeaderIndicator:SetSize(10, 10)
    LeaderIndicator:SetPoint("TOPRIGHT", self, "TOPRIGHT", 2, 4)
    self.LeaderIndicator = LeaderIndicator

    local AssistantIndicator = Overlay:CreateTexture(nil, "OVERLAY")
    AssistantIndicator:SetSize(10, 10)
    AssistantIndicator:SetPoint("TOPRIGHT", self, "TOPRIGHT", 2, 4)
    self.AssistantIndicator = AssistantIndicator

    local ReadyCheckIndicator = Overlay:CreateTexture(nil, "OVERLAY", nil, 2)
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

local anchorHolder, partyAnchor
_G.tinsert(UnitFrames.units, function()
    local rdb = GetRaidDB()
    if not rdb or rdb.enabled == false then return end

    -- Grid2 mutual exclusion: Grid2 owns group frames when present.
    if _G.C_AddOns.IsAddOnLoaded("Grid2") then
        UnitFrames:debug("Raid: Grid2 detected, skipping spawn")
        return
    end

    -- B31: extend the registered AceDB defaults with the party sub-table so
    -- every profile activated after this point (switch / new / reset) resolves
    -- units.raid.party.framePoint BEFORE FramePoint:RefreshMod re-reads the
    -- option path on profile-change (AceDB copies defaults into the new
    -- profile before firing its callbacks). The proper home for this is the
    -- defaults table in UnitFrames.lua — this is runtime-equivalent and keeps
    -- the change local to this file; GetPartyDB() covers the active profile.
    local defaults = UnitFrames.db.defaults
    local defRaid = defaults and defaults.profile and defaults.profile.units
        and defaults.profile.units.raid
    if defRaid and not defRaid.party then
        defRaid.party = { horizontal = false, framePoint = {} }
    end

    oUF:RegisterStyle("RealUI-Raid", RaidStyle)
    oUF:SetActiveStyle("RealUI-Raid")

    local spacing = rdb.spacing or 2

    -- Separate movable anchors per header (B31): party and raid live in
    -- different screen regions, so sharing one anchor forced a compromise
    -- position on both. Saved FramePoint positions are per-profile, so the
    -- DPS and Healing layouts remember their own spots once moved; these are
    -- only the defaults.
    --
    -- Raid defaults come from GridLayout.lua's presets, which the raidframes
    -- spec names as the source of truth (req 3.2). The previous default hung
    -- 150px below the HuD centre positioner, which put the frames on top of
    -- the action bars on a fresh install.
    local layout = RealUI.cLayout or 1
    local default = DEFAULT_POSITIONS[layout] or DEFAULT_POSITIONS[1]

    anchorHolder = _G.CreateFrame("Frame", "RealUIRaidAnchor", _G.UIParent)
    anchorHolder:SetSize(rdb.size.x, rdb.size.y)
    anchorHolder:SetPoint(default.point, _G.UIParent, default.point, default.x, default.y)

    partyAnchor = _G.CreateFrame("Frame", "RealUIPartyAnchor", _G.UIParent)
    partyAnchor:SetSize(rdb.size.x, rdb.size.y)
    local partyDefault = PARTY_DEFAULT_POSITIONS[layout] or PARTY_DEFAULT_POSITIONS[1]
    partyAnchor:SetPoint(partyDefault.point, _G.UIParent,
        partyDefault.point, partyDefault.x, partyDefault.y)

    -- oUF 14: SpawnHeader takes (name, template, ...attribute pairs) — NO
    -- visibility parameter (removed from oUF 13); visibility is driven below
    -- with RegisterStateDriver. A stray string in the vararg list shifts every
    -- attribute pair by one and ends in SetAttribute(true, ...) → blocked.
    local pPoint, pXOff, pYOff = GetPartyLayoutAttributes(rdb)
    local party = oUF:SpawnHeader("RealUIParty", nil,
        "showParty", true,
        "showPlayer", true,
        "showSolo", false,
        "point", pPoint,
        "xOffset", pXOff,
        "yOffset", pYOff,
        "oUF-initialConfigFunction", BuildInitialConfig(rdb))
    party:SetPoint("TOPLEFT", partyAnchor, "TOPLEFT", 0, 0)
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

    -- Register the movers AFTER the headers exist (Boss.lua order), then raise
    -- their strata: header CHILDREN are created later still (roster processing),
    -- so creation order alone leaves the mover buried under the cells when in
    -- a group. FramePoint re-anchors our holders onto their dragFrames, so the
    -- dragFrame is recoverable from the holder's anchor point.
    GetPartyDB()  -- ensure the party.framePoint table exists before FramePoint reads it
    for holder, path in _G.next, {
        [anchorHolder] = {"profile", "units", "raid", "framePoint"},
        [partyAnchor]  = {"profile", "units", "raid", "party", "framePoint"},
    } do
        FramePoint:PositionFrame(UnitFrames, holder, path)
        local _, dragFrame = holder:GetPoint(1)
        if dragFrame and dragFrame ~= _G.UIParent then
            dragFrame:SetFrameStrata("HIGH")
        end
    end

    -- Hand the style token back for anything spawned later.
    oUF:SetActiveStyle("RealUI")

    QueueSecure(SuppressBlizzard)
end)

--[[ Config-mode placeholder cells: secure headers can't show fake units, so
     positioning while solo gets styled dummy textures anchored exactly where
     the raid and party headers render (one preview per anchor since B31 split
     them). Toggled by RealUI:HuDTestMode. ]]--

local testFrame
local TEST_CLASSES = {
    "SHAMAN", "MAGE", "DRUID", "PALADIN", "WARRIOR",
    "PRIEST", "HUNTER", "WARLOCK", "ROGUE", "MONK",
    "DEATHKNIGHT", "DEMONHUNTER", "EVOKER",
}
local TEST_GROUPS, TEST_PER_GROUP = 4, 5  -- 20-man preview, like Grid2's test mode

-- B31: party preview — 5 cells on the party anchor, re-flowed on every show so
-- the column ↔ row orientation setting is previewed live.
local partyTestFrame, partyTestCells
local function LayoutPartyTest(rdb)
    local spacing = rdb.spacing or 2
    local horizontal = GetPartyDB().horizontal
    local cellW, cellH = rdb.size.x, rdb.size.y
    if horizontal then
        partyTestFrame:SetSize((cellW + spacing) * TEST_PER_GROUP, cellH)
    else
        partyTestFrame:SetSize(cellW, (cellH + spacing) * TEST_PER_GROUP)
    end
    for i, cell in _G.ipairs(partyTestCells) do
        cell:ClearAllPoints()
        if horizontal then
            cell:SetPoint("TOPLEFT", partyTestFrame, "TOPLEFT", (i - 1) * (cellW + spacing), 0)
        else
            cell:SetPoint("TOPLEFT", partyTestFrame, "TOPLEFT", 0, -((i - 1) * (cellH + spacing)))
        end
    end
end

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

        if partyAnchor then
            if not partyTestFrame then
                partyTestFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
                partyTestFrame:SetPoint("TOPLEFT", partyAnchor, "TOPLEFT", 0, 0)
                partyTestCells = {}
                for i = 1, TEST_PER_GROUP do
                    local cell = partyTestFrame:CreateTexture(nil, "ARTWORK")
                    cell:SetSize(rdb.size.x, rdb.size.y)
                    local color = _G.RAID_CLASS_COLORS[TEST_CLASSES[i]]
                    cell:SetColorTexture(color.r, color.g, color.b, 0.7)

                    local label = partyTestFrame:CreateFontString(nil, "OVERLAY")
                    label:SetFontObject("SystemFont_Shadow_Small")
                    label:SetTextColor(1, 1, 1)
                    label:SetPoint("BOTTOM", cell, "BOTTOM", 0, 2)
                    label:SetFormattedText("%s %d", _G.PARTY, i)
                    partyTestCells[i] = cell
                end
            end
            LayoutPartyTest(rdb)
            partyTestFrame:Show()
        end
    else
        if testFrame then testFrame:Hide() end
        if partyTestFrame then partyTestFrame:Hide() end
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
    -- Keep the config-mode preview in sync with the orientation setting.
    if partyTestFrame and partyTestFrame:IsShown() then
        LayoutPartyTest(rdb)
    end

    QueueSecure(function()
        if rdb.enabled == false then
            _G.UnregisterStateDriver(self.partyHeader, "visibility")
            _G.UnregisterStateDriver(self.raidHeader, "visibility")
            self.partyHeader:Hide()
            self.raidHeader:Hide()
            UnitFrames:RestoreBlizzardGroupFrames()
        else
            -- B31: party orientation is deliberately NOT written here. The
            -- attributes are spawn-time: writing them to a live header updates
            -- the stored values without re-flowing the children, leaving the
            -- cells anchored diagonally (verified in game 2026-08-19 — the
            -- attributes read back as LEFT/2/0 on a visible header while the
            -- layout stayed stale). Forcing a re-flow means calling Blizzard's
            -- SecureGroupHeader_Update from an addon, which is exactly the
            -- secure-frame meddling that caused the delve tracker taint, so the
            -- orientation toggle prompts a reload instead (RealUI_Config).
            _G.RegisterStateDriver(self.partyHeader, "visibility",
                "[group:raid] hide; [group:party] show; hide")
            _G.RegisterStateDriver(self.raidHeader, "visibility", "[group:raid] show; hide")
            SuppressBlizzard()
        end
    end)
end
