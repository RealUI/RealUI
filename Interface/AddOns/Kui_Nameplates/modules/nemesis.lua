--[[
-- Kui_Nameplates
-- By Kesava at curse.com
--
-- Displays a race icon on enemy nameplates if they are the target of your
-- nemesis quest.
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('NemesisHelper', addon.Prototype, 'AceEvent-3.0')
local kui = LibStub('Kui-1.0')
local _

mod.uiName = 'Nemesis helper'

local RACE_ICON_TEXTURE = 'Interface\\Glues\\CHARACTERCREATE\\UI-CHARACTERCREATE-RACES'
local RACE_ICON_OFFSETS = {
    ['Human']    = { .0097, .1152, .0195, .2304 },
    ['Dwarf']    = { .1367, .2382, .0195, .2304 },
    ['Gnome']    = { .2597, .3652, .0195, .2304 },
    ['NightElf'] = { .3867, .4902, .0195, .2304 },
    ['Draenei']  = { .5117, .6171, .0195, .2304 },
    ['Worgen']   = { .6386, .7441, .0195, .2304 },
    ['Pandaren'] = { .7656, .8710, .0195, .2304 },
    ['Tauren']   = { .0097, .1152, .2695, .4804 },
    ['Scourge']  = { .1367, .2382, .2695, .4804 },
    ['Troll']    = { .2597, .3652, .2695, .4804 },
    ['Orc']      = { .3867, .4902, .2695, .4804 },
    ['BloodElf'] = { .5117, .6171, .2695, .4804 },
    ['Goblin']   = { .6386, .7441, .2695, .4804 },
}

local NEMESIS_QUEST_IDS = {
    ['Human']    = { 36921, 36897 },
    ['Dwarf']    = { 36924, 36923 },
    ['Gnome']    = { 36925, 36926 },
    ['Worgen']   = { 36927, 36928 },
    ['Draenei']  = { 36929, 36930 },
    ['NightElf'] = { 36931, 36932 },
    ['BloodElf'] = { 36957, 36958 },
    ['Scourge']  = { 36959, 36960 },
    ['Tauren']   = { 36961, 36962 },
    ['Orc']      = { 36963, 36964 },
    ['Troll']    = { 36965, 36966 },
    ['Pandaren'] = { 36967, 36933, 36968, 36934 },
    ['Goblin']   = { 36969, 36970 }
}

local CONTINENT_ID
local DRAENOR_CONTINENT_ID = 7

local raceStore = {}
local storeIndex = {}
local activeNemesis = {}
local sizes = {}

-- helper functions ############################################################
local function GetGUIDInfo(guid)
    if not guid or guid == "" or not strmatch(guid, "^Player%-") then return end

    local raceName,raceID,_,name = select(3, GetPlayerInfoByGUID(guid))
    if not raceID or not name then return end
    if not activeNemesis[raceID] then return end

    if not raceStore[name] then
        -- don't increment with overwrites
        tinsert(storeIndex, name)

        if #storeIndex > 100 then
            -- purge index
            raceStore[tremove(storeIndex, 1)] = nil
        end
    end

    raceStore[name] = raceID

    -- update nameplate if it is visible
    local frame = addon:GetNameplate(guid, name)
    if frame then
        mod:PostShow(nil, frame)
    end
end

-- message listeners ###########################################################
function mod:PostCreate(msg, frame)
    -- create race icon
    frame.raceIcon = CreateFrame('Frame')
    local ri = frame.raceIcon

    frame.raceIcon.bg = ri:CreateTexture(nil, 'ARTWORK', nil, 4)
    frame.raceIcon.icon = ri:CreateTexture(nil, 'ARTWORK', nil, 3)
    frame.raceIcon.glow = ri:CreateTexture(nil, 'ARTWORK', nil, 2)

    local ribg = frame.raceIcon.bg
    local rii = frame.raceIcon.icon
    local rig = frame.raceIcon.glow

    ri:SetPoint('LEFT', frame.health, 'RIGHT', 3, 0)
    ri:SetSize(sizes.icon, sizes.icon)
    ri:Hide()

    rii:SetTexture(RACE_ICON_TEXTURE)
    rii:SetPoint('TOPLEFT', ri, 1, -1)
    rii:SetPoint('BOTTOMRIGHT', ri, -1, 1)

    ribg:SetTexture('Interface\\AddOns\\Kui_Media\\t\\CheckButtonHilightWhite')
    ribg:SetPoint('TOPLEFT', ri)
    ribg:SetPoint('BOTTOMRIGHT', ri)
    ribg:SetVertexColor(0,0,0)

    rig:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\combopoint-glow')
    rig:SetPoint('TOPLEFT', ri, -sizes.glow, sizes.glow)
    rig:SetPoint('BOTTOMRIGHT', ri, sizes.glow+1, -sizes.glow-1)
    rig:SetVertexColor(1,0,0)
end
function mod:PostShow(msg, frame)
    -- show icon on frames we know the race for
    if not frame.player or frame.friend then return end
    if not frame.name.text then return end
    local name = gsub(frame.name.text, ' %(%*%)', '')

    local race = raceStore[name]
    if race then
        assert(RACE_ICON_OFFSETS[race], 'No offset for race ID: '..race)
        frame.raceIcon.icon:SetTexCoord(unpack(RACE_ICON_OFFSETS[race]))
        frame.raceIcon:Show()
    end
end

function mod:PostHide(msg, frame)
    frame.raceIcon:Hide()
end

function mod:GUIDStored(msg, frame)
    GetGUIDInfo(frame.guid)
    self:PostShow(nil, frame)
end

-- events ######################################################################
function mod:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    -- watch for GUIDs in the combat log
    local sourceGUID = select(4,...)

    if sourceGUID then
        GetGUIDInfo(sourceGUID)

        local destGUID = select(8,...)
        if destGUID and destGUID ~= sourceGUID then
            GetGUIDInfo(destGUID)
        end
    end
end

function mod:PLAYER_ENTERING_WORLD(event,...)
    -- check that we're in draenor
    SetMapToCurrentZone()
    CONTINENT_ID = GetCurrentMapContinent()

    if CONTINENT_ID ~= DRAENOR_CONTINENT_ID then
        self:SoftDisable()
    else
        self:SoftEnable()
    end
end

function mod:QuestUpdate(event,...)
    -- search for active nemesis quests
    wipe(activeNemesis)
    local nemeses = 0

    for race,ids in pairs(NEMESIS_QUEST_IDS) do
        for _,id in pairs(ids) do
            if GetQuestLogIndexByID(id) ~= 0 then
                activeNemesis[race] = true
                nemeses = nemeses + 1
            end
        end
    end

    if nemeses > 0 then
        -- only watch combat log/quest updates when a nemesis quest is active
        self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
        self:RegisterEvent('QUEST_LOG_UPDATE', 'QuestUpdate')
    else
        self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
        self:UnregisterEvent('QUEST_LOG_UPDATE')
    end
end

-- mod functions ###############################################################
function mod:SoftDisable()
    -- stop watching combat/quest log but still create elements
    -- still watch PLAYER_ENTERING_WORLD to reactivate upon entering draenor
    self:UnregisterMessage('KuiNameplates_GUIDStored')
    self:UnregisterMessage('KuiNameplates_GUIDAssumed')
    self:UnregisterMessage('KuiNameplates_PostShow')
    self:UnregisterMessage('KuiNameplates_PostHide')

    self:UnregisterEvent('QUEST_ACCEPTED')
    self:UnregisterEvent('QUEST_LOG_UPDATE')
    self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
end
function mod:SoftEnable()
    self:RegisterMessage('KuiNameplates_GUIDStored', 'GUIDStored')
    self:RegisterMessage('KuiNameplates_GUIDAssumed', 'GUIDStored')
    self:RegisterMessage('KuiNameplates_PostShow', 'PostShow')
    self:RegisterMessage('KuiNameplates_PostHide', 'PostHide')

    self:RegisterEvent('QUEST_ACCEPTED', 'QuestUpdate')

    self:QuestUpdate()
end

-- post db change functions ####################################################
mod:AddConfigChanged('enabled', function(v)
    mod:Toggle(v)
end)

-- initialise ##################################################################
function mod:GetOptions()
    return {
        enabled = {
            name = 'Show race icons on nemesis targets',
            desc = 'Show race icons besides the nameplates of your current nemesis targets. This is only active while in the open world of Draenor and while you have an active nemesis quest (kill 500...).',
            width = 'full',
            type = 'toggle',
            order = 1,
            disabled = false
        }
    }
end

function mod:OnInitialize()
    self.db = addon.db:RegisterNamespace(self.moduleName, {
        profile = {
            enabled = true,
        }
    })

    sizes.icon = 18
    sizes.glow = 5

    addon:InitModuleOptions(self)
    self:SetEnabledState(self.db.profile.enabled)
end

function mod:OnEnable()
    self:RegisterMessage('KuiNameplates_PostCreate', 'PostCreate')
    self:RegisterEvent('PLAYER_ENTERING_WORLD')

    local _, frame
    for _, frame in pairs(addon.frameList) do
        if not frame.kui.raceIcon then
            self:PostCreate(nil, frame.kui)
        end
    end

    self:SoftEnable()
end
function mod:OnDisable()
    self:UnregisterMessage('KuiNameplates_PostCreate', 'PostCreate')
    self:UnregisterEvent('PLAYER_ENTERING_WORLD', 'QuestUpdate')

    self:SoftDisable()

    wipe(raceStore)
    wipe(storeIndex)
    wipe(activeNemesis)

    local _, frame
    for _, frame in pairs(addon.frameList) do
        if frame.kui.raceIcon then
            self:PostHide(nil, frame.kui)
        end
    end
end
