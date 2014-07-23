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
addon.sizes = { frame = {}, font = {}, tex = {} }
addon.defaultSizes = { frame = {}, font = {}, tex = {} }

addon.frameList = {}
addon.numFrames = 0

-- sizes of frame elements
-- TODO these should be set in create.lua
addon.defaultSizes = {
    frame = {
        width    = 100,
        height   = 10,
        twidth   = 55, -- trivial unit width
        theight  = 7,  -- "            height
        bgOffset = 4   -- inset of the frame glow
    },
    font = {
        large     = 9,
        spellname = 8,
        name      = 8,
        small     = 7
    },
    tex = {
        raidicon = 20,
        targetGlowW = 106,
        ttargetGlowW = 50, -- target glow width on trivial units
        targetGlowH = 5
    }
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
            fixaa       = true, -- attempt to make plates appear sharper
            targetglow  = true,
            bartexture  = DEFAULT_BAR,
            targetglowcolour = { .3, .7, 1, 1 },
            hheight     = 10,
            thheight    = 7,
            width       = 100,
            twidth      = 55, 
            leftie      = false,
            glowshadow  = true,
            strata      = 'BACKGROUND',
			reactioncolours = {
				hatedcol    = { .7, .2, .1 },
				neutralcol  = {  1, .8,  0 },
				friendlycol = { .2, .6, .1 },
				tappedcol   = { .5, .5, .5 },
				playercol   = { .2, .5, .9 }
			},
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
                avoidhpval  = 20,
                avoidcast   = false,
            },
        },
        text = {
            level        = true, -- display levels
            healthoffset = 2.5,
        },
        hp = {
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

    function addon:GetGUID(f)
        -- give this frame a guid if we think we already know it
        if knownGUIDs[f.name.text] then
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
            knownGUIDs[f.name.text] = guid
            tinsert(knownIndex, f.name.text)

            -- and start purging > 100 names
            if #knownIndex > 100 then
                knownGUIDs[tremove(knownIndex, 1)] = nil
            end
        elseif loadedNames[f.name.text] == f then
            -- force the registered f for this name to change
            loadedNames[f.name.text] = nil
        end
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

    tinsert(self.fontObjects, fs)
    return fs
end

addon.CreateFontString = CreateFontString
----------------------------------------------------------- scaling functions --
-- scale a frame/font size to keep it relatively the same with any uiscale
local function ScaleFrameSize(key)
    local size = addon.defaultSizes.frame[key]
    addon.sizes.frame[key] = (addon.uiscale and floor(size/addon.uiscale) or size)
end

local function ScaleTextureSize(key)
    -- texture sizes don't need to be rounded
    local size = addon.defaultSizes.tex[key]
    addon.sizes.tex[key] = (addon.uiscale and size/addon.uiscale or size)
end

local function ScaleFontSize(key)
    -- neither do fonts, but they need to be scaled with the fontscale option
    local size = addon.defaultSizes.font[key]
    addon.sizes.font[key] = size * addon.db.profile.fonts.options.fontscale
        
    if addon.uiscale then
        addon.sizes.font[key] = addon.sizes.font[key] / addon.uiscale
    end
end

local scaleFuncs = {
    frame = ScaleFrameSize,
    tex   = ScaleTextureSize,
    font  = ScaleFontSize
}

function addon:ScaleSizes(type)
    local key,_
    for key,_ in pairs(addon.defaultSizes[type]) do
        scaleFuncs[type](key)
    end
end

function addon:ScaleAllSizes()
    local type,_
    for type,_ in pairs(addon.defaultSizes) do
        self:ScaleSizes(type)
    end
end

-- modules must use this to add correctly scaled sizes
-- scaled sizes are stored in addon.sizes
-- font sizes can then be called as a key in addon.CreateFontString
function addon:RegisterSize(type, key, size)
    if not addon.defaultSizes[type] then return end
    addon.defaultSizes[type][key] = size
    scaleFuncs[type](key)
end
---------------------------------------------------- Post db change functions --
-- n.b. this is absolutely terrible and horrible and i hate it
addon.configChangedFuncs = { runOnce = {} }
addon.configChangedFuncs.runOnce.fontscale = function(val)
    addon:ScaleSizes('font')
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
    addon:RegisterSize('tex', 'healthOffset', val)
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
    frame.targetGlow:SetVertexColor(unpack(val))
end

addon.configChangedFuncs.strata = function(frame,val)
    frame:SetFrameStrata(val)
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
-------------------------------------------------- Listen for profile changes --
function addon:ProfileChanged()
end
------------------------------------------------------------------------ init --
function addon:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New('KuiNameplatesGDB', defaults)

    -- enable ace3 profiles
    LibStub('AceConfig-3.0'):RegisterOptionsTable('kuinameplates-profiles', LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db))
    LibStub('AceConfigDialog-3.0'):AddToBlizOptions('kuinameplates-profiles', 'Profiles', 'Kui Nameplates')
    
    self.db.RegisterCallback(self, 'OnProfileChanged', 'ProfileChanged')
    LSM.RegisterCallback(self, 'LibSharedMedia_Registered', 'LSMMediaRegistered')

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

    if self.db.profile.general.fixaa then
        addon.uiscale = UIParent:GetEffectiveScale()
    end

    self.defaultSizes.frame.height = self.db.profile.general.hheight
    self.defaultSizes.frame.theight = self.db.profile.general.thheight
    self.defaultSizes.frame.width = self.db.profile.general.width
    self.defaultSizes.frame.twidth = self.db.profile.general.twidth

    self.defaultSizes.tex.healthOffset = self.db.profile.text.healthoffset
    self.defaultSizes.tex.targetGlowW = self.defaultSizes.frame.width - 5
    self.defaultSizes.tex.ttargetGlowW = self.defaultSizes.frame.twidth - 5

    self:ScaleAllSizes()

    -------------------------------------- Health bar smooth update functions --
    -- (spoon-fed by oUF_Smooth)
    if self.db.profile.hp.smooth then
        local f, smoothing, GetFramerate, min, max, abs
            = CreateFrame('Frame'), {}, GetFramerate, math.min, math.max, math.abs

        function addon.SetValueSmooth(self, value)
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

    self:ToggleCombatEvents(self.db.profile.general.combat)
    addon:ScheduleRepeatingTimer('OnUpdate', .1)
end
