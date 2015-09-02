--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]
local addon = LibStub('AceAddon-3.0'):NewAddon('KuiNameplates', 'AceEvent-3.0', 'AceTimer-3.0')
local kui = LibStub('Kui-1.0')
local LSM = LibStub('LibSharedMedia-3.0')

addon.font = ''
addon.uiscale = nil

addon.frameList = {}
addon.numFrames = 0

-- sizes of frame elements
-- some populated by UpdateSizesTable & ScaleFontSizes
addon.sizes = {
    frame = {
        bgOffset = 8   -- inset of the frame glow
    },
    tex = {
        raidicon = 23,
        targetGlowH = 7,
        targetArrow = 33,
    },
    font = {}
}

-- as these are scaled with the user option we need to store the default
addon.defaultFontSizes = {
    large     = 12,
    spellname = 11,
    name      = 11,
    small     = 9
}

-- add latin-only fonts to LSM
LSM:Register(LSM.MediaType.FONT, 'Yanone Kaffesatz Bold', kui.m.f.yanone)
LSM:Register(LSM.MediaType.FONT, 'FrancoisOne', kui.m.f.francois)
local DEFAULT_FONT = 'FrancoisOne'

-- add my status bar textures too..
LSM:Register(LSM.MediaType.STATUSBAR, 'Kui status bar', kui.m.t.bar)
LSM:Register(LSM.MediaType.STATUSBAR, 'Kui shaded bar', kui.m.t.oldbar)
local DEFAULT_BAR = 'Kui status bar'

local locale = GetLocale()
local latin  = (locale ~= 'zhCN' and locale ~= 'zhTW' and locale ~= 'koKR' and locale ~= 'ruRU')

-------------------------------------------------------------- Default config --
local defaults = {
    profile = {
        general = {
            combat      = false, -- automatically show hostile plates upon entering combat
            highlight   = true, -- highlight plates on mouse-over
            highlight_target = false,
            fixaa       = true, -- attempt to make plates appear sharper
            compatibility = false,
            bartexture  = DEFAULT_BAR,
            targetglow  = true,
            targetglowcolour = { .3, .7, 1, 1 },
            targetarrows = false,
            hheight     = 13,
            thheight    = 9,
            width       = 130,
            twidth      = 72,
            leftie      = false,
            glowshadow  = true,
            strata      = 'BACKGROUND',
            lowhealthval = 20,
        },
        fade = {
            smooth      = true, -- smoothy fade plates
            fadespeed   = .5, -- fade animation speed modifier
            fademouse   = false, -- fade in plates on mouse-over
            fadeall     = false, -- fade all plates by default
            fadedalpha  = .5, -- the alpha value to fade plates out to
            rules = {
                avoidhostilehp = false,
                avoidfriendhp  = false,
                avoidcast   = false,
                avoidraidicon = true,
            },
        },
        text = {
            level        = false, -- display levels
            healthoffset = 2.5,
        },
        hp = {
            reactioncolours = {
                hatedcol    = { .7, .2, .1 },
                neutralcol  = {  1, .8,  0 },
                friendlycol = { .2, .6, .1 },
                tappedcol   = { .5, .5, .5 },
                playercol   = { .2, .5, .9 }
            },
            friendly  = '<:d;', -- health display pattern for friendly units
            hostile   = '<:p;', -- health display pattern for enemy units
            showalt   = false, -- show alternate health values
            mouseover = false, -- hide health values until mouseover/target
            smooth    = true -- smoothly animate health bar changes
        },
        fonts = {
            options = {
                font       = (latin and DEFAULT_FONT or LSM:GetDefault(LSM.MediaType.FONT)),
                fontscale  = 1,
                outline    = true,
                monochrome = false,
                noalpha    = false,
            },
            sizes = {
                combopoints = 13,
                large       = 10,
                spellname   = 9,
                name        = 9,
                small       = 8
            },
        }
    }
}
------------------------------------------ GUID/name storage functions --
do
    local loadedGUIDs, loadedNames = {}, {}
    local knownGUIDs = {} -- GUIDs that we can relate to names (i.e. players)
    local knownIndex = {}

    function addon:StoreNameWithGUID(name,guid)
        -- used to provide aggressive name -> guid matching
        -- should only be used for players
        if not name or not guid then return end
        knownGUIDs[name] = guid
        tinsert(knownIndex, name)

        -- purging index > 100 names
        if #knownIndex > 100 then
            knownGUIDs[tremove(knownIndex, 1)] = nil
        end
    end

    function addon:GetGUID(f)
        -- give this frame a guid if we think we already know it
        if f.player and knownGUIDs[f.name.text] then
            f.guid = knownGUIDs[f.name.text]
            loadedGUIDs[f.guid] = f
        end
    end
    function addon:StoreGUID(f, unit)
        if not unit then return end
        local guid = UnitGUID(unit)
        if not guid then return end

        if f.guid and loadedGUIDs[f.guid] then
            if f.guid ~= guid then
                -- the currently stored guid is incorrect
                loadedGUIDs[f.guid] = nil
            else
                return
            end
        end

        f.guid = guid
        loadedGUIDs[guid] = f

        if UnitIsPlayer(unit) then
            -- we can probably assume this unit has a unique name
            -- nevertheless, overwrite this each time. just in case.
            self:StoreNameWithGUID(f.name.text, guid)
        elseif loadedNames[f.name.text] == f then
            -- force the registered f for this name to change
            loadedNames[f.name.text] = nil
        end

        --print('got GUID for: '..f.name.text.. '; '..f.guid)
        addon:SendMessage('KuiNameplates_GUIDStored', f, unit)
    end
    function addon:StoreName(f)
        if not f.name.text or f.guid then return end
        if not loadedNames[f.name.text] then
            loadedNames[f.name.text] = f
        end
    end
    function addon:FrameHasName(f)
        return loadedNames[f.name.text] == f
    end
    function addon:FrameHasGUID(f)
        return loadedGUIDs[f.guid] == f
    end
    function addon:ClearName(f)
        if self:FrameHasName(f) then
            loadedNames[f.name.text] = nil
        end
    end
    function addon:ClearGUID(f)
        if self:FrameHasGUID(f) then
            loadedGUIDs[f.guid] = nil
        end
        f.guid = nil
    end
    function addon:GetNameplate(guid, name)
        local gf, nf = loadedGUIDs[guid], loadedNames[name]

        if gf then
            return gf
        elseif nf then
            return nf
        else
            return nil
        end
    end

    -- return the given unit's nameplate
    function addon:GetUnitPlate(unit)
        local name,realm = UnitName(unit)

        if realm and UnitRealmRelationship(unit) == LE_REALM_RELATION_COALESCED then
            name = name .. ' (*)'
        end

        return self:GetNameplate(UnitGUID(unit), name)
    end

    function addon:UPDATE_MOUSEOVER_UNIT(event)
        if not UnitIsPlayer('mouseover') then return end
        -- if mouseover is a player, we can -probably- assign its' GUID
        local f = self:GetUnitPlate('mouseover')
        if f and f.player then
            self:StoreGUID(f, 'mouseover')
        end
    end
end
------------------------------------------------------------ helper functions --
-- cycle all frames' fontstrings and reset the font
local function UpdateAllFonts()
    local _,frame
    for _,frame in pairs(addon.frameList) do
        local _,fs
        for _,fs in pairs(frame.kui.fontObjects) do
            local _, size, flags = fs:GetFont()
            fs:SetFont(addon.font, size, flags)
        end
    end
end

-- cycle all frames and reset the health and castbar status bar textures
local function UpdateAllBars()
    local _,frame
    for _,frame in pairs(addon.frameList) do
        if frame.kui.health then
            frame.kui.health:SetStatusBarTexture(addon.bartexture)
        end

        if frame.kui.highlight then
            frame.kui.highlight:SetTexture(addon.bartexture)
        end

        if frame.kui.castbar then
            frame.kui.castbar.bar:SetStatusBarTexture(addon.bartexture)
        end
    end
end

local function SetFontSize(fs, size)
    if addon.db.profile.fonts.options.onesize then
        size = 'name'
    end

    if type(size) == 'string' and fs.size and addon.sizes.font[size] then
        -- if fontsize is a key of the font sizes table, store it so that
        -- we can scale this font correctly
        fs.size = size
        size = addon.sizes.font[size]
    end

    local font, _, flags = fs:GetFont()
    fs:SetFont(font, size, flags)
end

local function CreateFontString(self, parent, obj)
    -- store size as a key of addon.fontSizes so that it can be recalled & scaled
    -- correctly. Used by SetFontSize.
    local sizeKey

    obj = obj or {}
    obj.mono = addon.db.profile.fonts.options.monochrome
    obj.outline = addon.db.profile.fonts.options.outline
    obj.size = (addon.db.profile.fonts.options.onesize and 'name') or obj.size or 'name'

    if type(obj.size) == 'string' then
        sizeKey = obj.size
        obj.size = addon.sizes.font[sizeKey]
    end

    if not obj.font then
        obj.font = addon.font
    end

    if obj.alpha and addon.db.profile.fonts.options.noalpha then
        obj.alpha = nil
    end

    local fs = kui.CreateFontString(parent, obj)
    fs.size = sizeKey
    fs.SetFontSize = SetFontSize
    fs:SetWordWrap(false)

    tinsert(self.fontObjects, fs)
    return fs
end

addon.CreateFontString = CreateFontString
----------------------------------------------------------- scaling functions --
-- scale font sizes with the fontscale option
local function ScaleFontSize(key)
    local size = addon.defaultFontSizes[key]
    addon.sizes.font[key] = size * addon.db.profile.fonts.options.fontscale
end

local function ScaleFontSizes()
    local key,_
    for key,_ in pairs(addon.defaultFontSizes) do
        ScaleFontSize(key)
    end
end

-- modules should use this to add font sizes which scale correctly with the
-- fontscale option
-- keys must be unique
function addon:RegisterFontSize(key, size)
    addon.defaultFontSizes[key] = size
    ScaleFontSize(key)
end

-- once upon a time, equivalent logic was necessary for all frame sizes
function addon:RegisterSize(type, key, size)
    error('deprecated function call: RegisterSize '..(type or 'nil')..' '..(key or 'nil')..' '..(size or 'nil'))
end

local function UpdateSizesTable()
    -- populate sizes table with profile values
    addon.sizes.frame.height = addon.db.profile.general.hheight
    addon.sizes.frame.theight = addon.db.profile.general.thheight
    addon.sizes.frame.width = addon.db.profile.general.width
    addon.sizes.frame.twidth = addon.db.profile.general.twidth

    addon.sizes.tex.healthOffset = addon.db.profile.text.healthoffset
    addon.sizes.tex.targetGlowW = addon.sizes.frame.width - 5
    addon.sizes.tex.ttargetGlowW = addon.sizes.frame.twidth - 5
end
---------------------------------------------------- Post db change functions --
-- n.b. this is absolutely terrible and horrible and i hate it
addon.configChangedFuncs = { runOnce = {} }
addon.configChangedFuncs.runOnce.fontscale = function(val)
    ScaleFontSizes()
end
addon.configChangedFuncs.fontscale = function(frame, val)
    local _, fontObject
    for _, fontObject in pairs(frame.fontObjects) do
        if type(fontObject.size) == 'string' then
            fontObject:SetFontSize(addon.sizes.font[fontObject.size])
        end
    end
end

addon.configChangedFuncs.outline = function(frame, val)
    local _, fontObject
    for _, fontObject in pairs(frame.fontObjects) do
        kui.ModifyFontFlags(fontObject, val, 'OUTLINE')
    end
end

addon.configChangedFuncs.monochrome = function(frame, val)
    local _, fontObject
    for _, fontObject in pairs(frame.fontObjects) do
        kui.ModifyFontFlags(fontObject, val, 'MONOCHROME')
    end
end

addon.configChangedFuncs.fontscale = function(frame, val)
    local _, fontObject
    for _, fontObject in pairs(frame.fontObjects) do
        if fontObject.size then
            fontObject:SetFontSize(fontObject.size)
        end
    end
end
addon.configChangedFuncs.onesize = addon.configChangedFuncs.fontscale

addon.configChangedFuncs.runOnce.healthoffset = function(val)
    addon.sizes.tex.healthOffset = addon.db.profile.text.healthoffset
end
addon.configChangedFuncs.healthoffset = function(frame, val)
    addon:UpdateHealthText(frame, frame.trivial)
    addon:UpdateAltHealthText(frame, frame.trivial)
    addon:UpdateLevel(frame, frame.trivial)
    addon:UpdateName(frame, frame.trivial)
end

addon.configChangedFuncs.Health = function(frame)
    if frame:IsShown() then
        -- update health display
        frame:OnHealthValueChanged()
    end
end
addon.configChangedFuncs.friendly = addon.configChangedFuncs.Health
addon.configChangedFuncs.hostile = addon.configChangedFuncs.Health

addon.configChangedFuncs.runOnce.bartexture = function(val)
    addon.bartexture = LSM:Fetch(LSM.MediaType.STATUSBAR, val)
    UpdateAllBars()
end

addon.configChangedFuncs.runOnce.font = function(val)
    addon.font = LSM:Fetch(LSM.MediaType.FONT, val)
    UpdateAllFonts()
end

addon.configChangedFuncs.targetglowcolour = function(frame, val)
    if frame.targetGlow then
        frame.targetGlow:SetVertexColor(unpack(val))
    end

    if frame.targetArrows then
        frame.targetArrows.left:SetVertexColor(unpack(val))
        frame.targetArrows.right:SetVertexColor(unpack(val))
    end
end

addon.configChangedFuncs.strata = function(frame,val)
    frame:SetFrameStrata(val)
end

do
    local function UpdateFrameSize(frame)
        addon:UpdateBackground(frame, frame.trivial)
        addon:UpdateHealthBar(frame, frame.trivial)
        addon:UpdateName(frame, frame.trivial)
        frame:SetCentre()
    end

    addon.configChangedFuncs.runOnce.width    = UpdateSizesTable
    addon.configChangedFuncs.runOnce.twidth   = UpdateSizesTable
    addon.configChangedFuncs.runOnce.hheight  = UpdateSizesTable
    addon.configChangedFuncs.runOnce.thheight = UpdateSizesTable

    addon.configChangedFuncs.width    = UpdateFrameSize
    addon.configChangedFuncs.twidth   = UpdateFrameSize
    addon.configChangedFuncs.hheight  = UpdateFrameSize
    addon.configChangedFuncs.thheight = UpdateFrameSize
end
------------------------------------------- Listen for LibSharedMedia changes --
function addon:LSMMediaRegistered(msg, mediatype, key)
    if mediatype == LSM.MediaType.FONT then
        if key == self.db.profile.fonts.options.font then
            self.font = LSM:Fetch(mediatype, key)
            UpdateAllFonts()
        end
    elseif mediatype == LSM.MediaType.STATUSBAR then
        if key == self.db.profile.general.bartexture then
            self.bartexture = LSM:Fetch(mediatype, key)
            UpdateAllFonts()
        end
    end
end
------------------------------------------------------------------------ init --
function addon:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New('KuiNameplatesGDB', defaults)

    -- enable ace3 profiles
    LibStub('AceConfig-3.0'):RegisterOptionsTable('kuinameplates-profiles', LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db))
    LibStub('AceConfigDialog-3.0'):AddToBlizOptions('kuinameplates-profiles', 'Profiles', 'Kui Nameplates')

    self.db.RegisterCallback(self, 'OnProfileChanged', 'ProfileChanged')
    LSM.RegisterCallback(self, 'LibSharedMedia_Registered', 'LSMMediaRegistered')

    -- move old reactioncolours config
    if self.db.profile.general.reactioncolours then
        local rc = self.db.profile.general.reactioncolours
        local nrc = self.db.profile.hp.reactioncolours

        if rc.hatedcol then nrc.hatedcol = rc.hatedcol end
        if rc.neutralcol then nrc.neutralcol = rc.neutralcol end
        if rc.friendlycol then nrc.friendlycol = rc.friendlycol end
        if rc.tappedcol then nrc.tappedcol = rc.tappedcol end
        if rc.playercol then nrc.playercol = rc.playercol end

        self.db.profile.general.reactioncolours = nil
    end

    addon:CreateConfigChangedListener(addon)
end
---------------------------------------------------------------------- enable --
function addon:OnEnable()
    -- get font and status bar texture from LSM
    self.font = LSM:Fetch(LSM.MediaType.FONT, self.db.profile.fonts.options.font)
    self.bartexture = LSM:Fetch(LSM.MediaType.STATUSBAR, self.db.profile.general.bartexture)

    -- handle deleted or invalid files
    if not self.font then
        self.font = LSM:Fetch(LSM.MediaType.FONT, DEFAULT_FONT)
    end
    if not self.bartexture then
        self.bartexture = LSM:Fetch(LSM.MediaType.STATUSBAR, DEFAULT_BAR)
    end

    self.uiscale = UIParent:GetEffectiveScale()

    UpdateSizesTable()
    ScaleFontSizes()

    -------------------------------------- Health bar smooth update functions --
    -- (spoon-fed by oUF_Smooth)
    if self.db.profile.hp.smooth then
        local f, smoothing, GetFramerate, min, max, abs
            = CreateFrame('Frame'), {}, GetFramerate, math.min, math.max, math.abs

        function self.SetValueSmooth(self, value)
            local _, maxv = self:GetMinMaxValues()

            if value == self:GetValue() or (self.prevMax and self.prevMax ~= maxv) then
                -- finished smoothing/max health updated
                smoothing[self] = nil
                self:OrigSetValue(value)
            else
                smoothing[self] = value
            end

            self.prevMax = maxv
        end

        f:SetScript('OnUpdate', function()
            local limit = 30/GetFramerate()

            for bar, value in pairs(smoothing) do
                local cur = bar:GetValue()
                local new = cur + min((value-cur)/3, max(value-cur, limit))

                if new ~= new then
                    new = value
                end

                bar:OrigSetValue(new)

                if cur == value or abs(new - value) < 2 then
                    bar:OrigSetValue(value)
                    smoothing[bar] = nil
                end
            end
        end)
    end

    -- FIXME this may/may not fix #34
    self:configChangedListener()

    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')

    self:ToggleCombatEvents(self.db.profile.general.combat)
    self:ScheduleRepeatingTimer('OnUpdate', .1)
end
