--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved.
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('NameOnly', addon.Prototype, 'AceEvent-3.0')
mod.uiName = "Name-only display"

local _
local len = string.len
local utf8sub = LibStub('Kui-1.0').utf8sub
local orig_SetName

local colour_friendly

local PositionRaidIcon = {
    function(f) return f.icon:SetPoint('RIGHT',f.name,'LEFT',-2,2) end,
    function(f) return f.icon:SetPoint('BOTTOM',f.name,'TOP',0,8) end,
    function(f) return f.icon:SetPoint('LEFT',f.name,'RIGHT',0,2) end,
    function(f) return f.icon:SetPoint('TOP',f.name,'BOTTOM',-1,-8) end,
}

-- mod functions ###############################################################
local function UpdateDisplay(f)
    f:CreateFontString(f.name, {
        reset = true,
        size = f.trivial and 'nameonlytrivial' or 'nameonly',
        shadow = true
    })

    f.name:ClearAllPoints()
    f.name:SetWidth(0)
    f.name:SetWidth(f.name:GetStringWidth())

    local sheight = f.name:GetStringHeight() / 2
    f.name:SetPoint('CENTER', .5,
        (sheight - floor(sheight) > .01) and 0 or .5
    )
end

-- toggle nameonly mode on
local function SwitchOn(f)
    if f.nameonly then return end
    f.nameonly = true

    if not f.player and f.friend then
        -- color NPC names
        f.name:SetTextColor(unpack(colour_friendly))
    end

    if mod.db.profile.display.hidecastbars then
        addon.Castbar:IgnoreFrame(f)
    end

    f.name:SetParent(f)
    f.name:SetJustifyH('CENTER')
    f.name:SetJustifyV('CENTER')

    UpdateDisplay(f)

    f.icon:SetParent(f)
    f.icon:ClearAllPoints()
    PositionRaidIcon[addon.db.profile.general.raidicon_side](f)

    if f.castWarning then
        f.castWarning:SetParent(f)
        f.incWarning:SetParent(f)
    end

    f.health:Hide()
    f.overlay:Hide()
    f.bg:Hide()
end
-- toggle nameonly mode off
local function SwitchOff(f)
    if not f.nameonly then return end
    f.nameonly = nil

    if not f.player then
        f.name:SetTextColor(1,1,1)
    end

    if mod.db.profile.display.hidecastbars then
        addon.Castbar:UnignoreFrame(f)
    end

    f:CreateFontString(f.name, {
        reset = true, size = 'name'
    })
    f.name:SetParent(f.overlay)

    f.health:Show()
    f.overlay:Show()
    f.bg:Show()

    -- reposition name
    addon:UpdateName(f,f.trivial)

    -- reposition raid icon
    addon:UpdateRaidIcon(f)

    if f.castWarning then
        f.castWarning:SetParent(f.overlay)
        f.incWarning:SetParent(f.overlay)
    end

    -- reset name text
    f:SetName()
end
-- SetName hook, to set name's colour based on health
local function nameonly_SetName(f)
    orig_SetName(f)

    if not f.nameonly then return end
    f.name:SetWidth(0)
    f.name:SetWidth(f.name:GetStringWidth())

    if not f.health.curr then return end

    local health_length = len(f.name.text) * (f.health.curr / f.health.max)
    f.name:SetText(
        utf8sub(f.name.text, 0, health_length)..
        '|cff666666'..utf8sub(f.name.text, health_length+1)
    )
end
local function HookSetName(f)
    orig_SetName = f.SetName
    f.SetName = nameonly_SetName
end
-- toggle name-only display mode
local function UpdateNameOnly(f)
    if not mod.db.profile.enabled then return end

    if f.kuiParent then
        -- resolve frame for oldHealth hook
        f = f.kuiParent.kui
    end

    if (f.target or not f.friend) or
       (not mod.db.profile.display.ondamaged and f.health.curr < f.health.max)
    then
        SwitchOff(f)
    else
        SwitchOn(f)
        f:SetName()
    end
end
-- message listeners ###########################################################
function mod:PostShow(msg,f)
    UpdateNameOnly(f)
end
function mod:PostHide(msg,f)
    SwitchOff(f)
end
function mod:PostCreate(msg,f)
    f.oldHealth:HookScript('OnValueChanged',UpdateNameOnly)
    f.nameonly_hooked = true

    if self.db.profile.display.ondamaged and
       f.SetName ~= nameonly_SetName
    then
        HookSetName(f)
    end
end
function mod:PostTarget(msg,f)
    UpdateNameOnly(f)
end
-- post db change functions ####################################################
local function UpdateFontSize()
    addon:RegisterFontSize('nameonly',tonumber(mod.db.profile.display.fontsize))
    addon:RegisterFontSize('nameonlytrivial',tonumber(mod.db.profile.display.fontsizetrivial))
end

mod:AddConfigChanged('enabled', function(v)
    mod:Toggle(v)
end)

mod:AddConfigChanged({'display','ondamaged'}, nil,
    function(f)
        if not mod.db.profile.enabled then return end
        mod.configChangedFuncs.enabled.pf(f,true)
    end
)
mod:AddConfigChanged({{'display','fontsize'},{'display','fontsizetrivial'}},
    UpdateFontSize,
    function(f)
        if f.nameonly then
            UpdateDisplay(f)
        end
    end
)
mod:AddGlobalConfigChanged('addon', {'fonts','fontscale'}, nil, function(f)
    if f.nameonly then
        UpdateDisplay(f)
    end
end)
-- initialise ##################################################################
function mod:GetOptions()
    return {
        enabled = {
            name = 'Only show name of friendly units',
            desc = 'Change the layout of friendly nameplates so as to only show their names.',
            type = 'toggle',
            width = 'full',
            order = 10
        },
        display = {
            name = 'Display',
            type = 'group',
            inline = true,
            order = 20,
            disabled = function()
                return not mod.db.profile.enabled
            end,
            args = {
                ondamaged = {
                    name = 'Even when damaged',
                    desc = 'Only show the name of damaged nameplates, too. Their name will be coloured as a percentage of health remaining.',
                    type = 'toggle',
                    order = 10,
                },
                hidecastbars = {
                    name = 'Hide castbars',
                    desc = 'Hide castbars when in name-only display.',
                    type = 'toggle',
                    order = 20,
                },
                fontsize = {
                    name = 'Font size',
                    desc = 'Font size used when in name-only display. This is affected by the standard "Font scale" option under "Fonts".',
                    type = 'range',
                    order = 30,
                    step = 1,
                    min = 1,
                    softMin = 1,
                    softMax = 30,
                    disabled = function()
                        return addon.db.profile.fonts.options.onesize
                    end,
                },
                fontsizetrivial = {
                    name = 'Trivial font size',
                    type = 'range',
                    order = 40,
                    step = 1,
                    min = 1,
                    softMin = 1,
                    softMax = 30,
                    disabled = function()
                        return addon.db.profile.fonts.options.onesize
                    end,
                }
            }
        },
        colours = {
            name = 'NPC name colours',
            type = 'group',
            inline = true,
            order = 30,
            disabled = function()
                return not mod.db.profile.enabled
            end,
            args = {
                friendly = {
                    name = 'Friendly',
                    type = 'color',
                    order = 1
                },
            }
        }
    }
end
function mod:configChangedListener()
    colour_friendly = self.db.profile.colours.friendly
end
function mod:OnInitialize()
    self.db = addon.db:RegisterNamespace(self.moduleName, {
        profile = {
            enabled = true,
            display = {
                ondamaged = false,
                hidecastbars = true,
                fontsize = 11,
                fontsizetrivial = 9,
            },
            colours = {
                friendly = {.6,1,.6}
            },
        }
    })

    addon:InitModuleOptions(self)
    self:SetEnabledState(self.db.profile.enabled)
end
function mod:OnEnable()
    UpdateFontSize()

    self:RegisterMessage('KuiNameplates_PostHide','PostHide')
    self:RegisterMessage('KuiNameplates_PostShow','PostShow')
    self:RegisterMessage('KuiNameplates_PostTarget','PostTarget')
    self:RegisterMessage('KuiNameplates_PostCreate','PostCreate')

    for _,frame in pairs(addon.frameList) do
        if frame.kui then
            if not frame.kui.nameonly_hooked then
                self:PostCreate(nil,frame.kui)
            end

            UpdateNameOnly(frame.kui)
        end
    end
end
function mod:OnDisable()
    self:UnregisterMessage('KuiNameplates_PostHide','PostHide')
    self:UnregisterMessage('KuiNameplates_PostShow','PostShow')
    self:UnregisterMessage('KuiNameplates_PostTarget','PostTarget')
    self:UnregisterMessage('KuiNameplates_PostCreate','PostCreate')

    for _,frame in pairs(addon.frameList) do
        SwitchOff(frame.kui)
    end
end
