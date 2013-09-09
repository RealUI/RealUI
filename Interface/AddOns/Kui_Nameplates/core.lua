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
local loadedGUIDs, loadedNames = {}, {}

-- sizes of frame elements
-- TODO these should be set in create.lua
addon.defaultSizes = {
	frame = {
		width    = 110,
		height   = 11,
		twidth   = 55, -- trivial unit width
		theight  = 7,  -- "            height
		bgOffset = 4   -- inset of the frame glow
	},
	font = {
		large     = 10,
		spellname = 9,
		name      = 9,
		small     = 8
	},
	tex = {
		raidicon = 20,
		targetGlowW = 106,
		ttargetGlowW = 50, -- target glow width on trivial units
		targetGlowH = 5
	}
}

-- Custom reaction colours
addon.r = {
    { .7, .2, .1 }, -- hated
    {  1, .8,  0 }, -- neutral
    { .2, .6, .1 }, -- friendly
	{ .5, .5, .5 }, -- tapped
	{  0, .3, .6 }, -- friendly player
}

-- add yanone kaffesatz and accidental presidency to LSM (only supports latin)
LSM:Register(LSM.MediaType.FONT, 'Yanone Kaffesatz', kui.m.f.yanone)
LSM:Register(LSM.MediaType.FONT, 'Accidental Presidency', kui.m.f.accid)
-- TODO should probably move LSM stuff into Kui, and replace the table there

local locale = GetLocale()
local latin  = (locale ~= 'zhCN' and locale ~= 'zhTW' and locale ~= 'koKR' and locale ~= 'ruRU')

-------------------------------------------------------------- Default config --
local defaults = {
	profile = {
		general = {
			combat      = false, -- automatically show hostile plates upon entering combat
			highlight   = true, -- highlight plates on mouse-over
			fixaa       = true, -- attempt to make plates appear sharper (with some drawbacks)
			targetglow  = true,
			targetglowcolour = { .3, .7, 1, 1 },
			hheight     = 11,
			thheight    = 7
		},
		fade = {
			smooth      = true, -- smoothy fade plates (fading is instant if disabled)
			fadespeed   = .5, -- fade animation speed modifier
			fademouse   = false, -- fade in plates on mouse-over
			fadeall     = false, -- fade all plates by default
			fadedalpha  = .5, -- the alpha value to fade plates out to
		},
		tank = {
			enabled    = false, -- recolour a plate's bar and glow colour when you have threat
			barcolour  = { .2, .9, .1, 1 }, -- the bar colour to use when you have threat
			glowcolour = { 1, 0, 0, 1 } -- the glow colour to use when you have threat
		},
		text = {
			level        = true, -- display levels
			friendlyname = { 1, 1, 1 }, -- friendly name text colour
			enemyname    = { 1, 1, 1 }  -- enemy name text colour
		},
		hp = {
			friendly  = '=:m;<:d;', -- health display pattern for friendly units
			hostile   = '<:p;', -- health display pattern for hostile/neutral units
			showalt   = false, -- show alternate (contextual) health values as well as main values
			mouseover = false, -- hide health values until you mouse over or target the plate
			smooth    = true -- smoothly animate health bar changes
		},
		fonts = {
			options = {
				font       = (latin and 'Yanone Kaffesatz' or LSM:GetDefault(LSM.MediaType.FONT)),
				fontscale  = 1.0,
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
		if type(fontObject.size) == 'string' then
			fontObject:SetFontSize(addon.sizes.font[fontObject.size])
		end
	end
end
addon.configChangedFuncs.onesize = addon.configChangedFuncs.fontscale

addon.configChangedFuncs.Health = function(frame)
	if frame:IsShown() then
		-- update health display
		OnHealthValueChanged(frame.oldHealth, frame.oldHealth:GetValue())
	end
end
addon.configChangedFuncs.friendly = addon.configChangedFuncs.Health
addon.configChangedFuncs.hostile = addon.configChangedFuncs.Health

addon.configChangedFuncs.runOnce.font = function(val)
	addon.font = LSM:Fetch(LSM.MediaType.FONT, val)
end
addon.configChangedFuncs.font = function(frame, val)
	local _, fontObject
	for _, fontObject in pairs(frame.fontObjects) do
		local _, size, flags = fontObject:GetFont()
		fontObject:SetFont(addon.font, size, flags)
	end
end

addon.configChangedFuncs.targetglowcolour = function(frame, val)
	frame.targetGlow:SetVertexColor(unpack(val))
end
------------------------------------------------- GUID/name storage functions --
function addon:StoreGUID(f, guid)
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

	if loadedNames[f.name.text] == f then
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
------------------------------------------------------------ helper functions --
-- TEMPORARY bug fix ugliness
function addon:UpdateAllFonts()
	local _,frame
	for _,frame in pairs(self.frameList) do
		local _,fs
		for _,fs in pairs(frame.fontObjects) do
			local _, size, flags = fs:GetFont()
			fs:SetFont(self.font, size, flags)
		end
	end
end

local function SetFontSize(fs, size)
	if addon.db.profile.fonts.options.onesize then
		size = addon.sizes.font['name']
	end

	if type(size) == 'string' and fs.size and addon.sizes.font[size] then
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
	obj.size = obj.size or 'name'

	if type(obj.size) == 'string' then
		sizeKey = obj.size
		obj.size = addon.sizes.font[sizeKey]
	end

	if addon.db.profile.fonts.options.onesize then
		obj.size = addon.sizes.font['name']
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
------------------------------------------- Listen for LibSharedMedia changes --
-- TODO support for globals etc
function addon:LSMFontRegistered(msg, mediatype, key)
	if mediatype ~= LSM.MediaType.FONT then return end
	if key == self.db.profile.fonts.options.font then
		self.font = LSM:Fetch(mediatype, key)
		self:UpdateAllFonts()
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
	LSM.RegisterCallback(self, 'LibSharedMedia_Registered', 'LSMFontRegistered')

	addon:CreateConfigChangedListener(addon)
end
---------------------------------------------------------------------- enable --
function addon:OnEnable()
	-- get font from LSM
	self.font = LSM:Fetch(LSM.MediaType.FONT, self.db.profile.fonts.options.font)
	
	if not self.font then
		-- or fallback to default
		self.font = LSM:Fetch(LSM.MediaType.FONT, 'Yanone Kaffeesatz')
	end

	if self.db.profile.general.fixaa then
		addon.uiscale = UIParent:GetEffectiveScale()
	end

	self.defaultSizes.frame.height = self.db.profile.general.hheight
	self.defaultSizes.frame.theight = self.db.profile.general.thheight

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

	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:ToggleCombatEvents(self.db.profile.general.combat)

	addon:ScheduleRepeatingTimer('OnUpdate', .1)
end
