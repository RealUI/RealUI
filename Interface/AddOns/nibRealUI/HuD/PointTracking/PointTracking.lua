local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "PointTracking"
local PointTracking = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")
local CombatFader = nibRealUI:GetModule("CombatFader")
local LSM = LibStub("LibSharedMedia-3.0")
local db, ndb

local floor = math.floor

-- local GreenFire

local Types = {
    ["GENERAL"] = {
        name = "General",
        points = {
            [1] = {name = "Combo Points", id = "cp", barcount = 5},
        },
    },
    ["MONK"] = {
        name = "Monk",
        points = {
            [1] = {name = "Chi", id = "chi", barcount = 6},
        },
    },
    ["PALADIN"] = {
        name = "Paladin",
        points = {
            [1] = {name = "Holy Power", id = "hp", barcount = 5},
        },
    },
    ["PRIEST"] = {
        name = "Priest",
        points = {
            [1] = {name = "Shadow Orbs", id = "so", barcount = 5},
        },
    },
    ["ROGUE"] = {
        name = "Rogue",
        points = {
            [1] = {name = "Anticipation Points", id = "ap", barcount = 5},
        },
    },
    ["WARLOCK"] = {
        name = "Warlock",
        points = {
            [1] = {name = "Soul Shards", id = "ss", barcount = 4},
            [2] = {name = "Burning Embers", id = "be", barcount = 4},
        },
    },
}

---- Spell Info table
local SpellInfo = {
    ["ap"] = nil,
}

-- Point Display tables
local Frames = {}
local BG = {}

-- Points
local Points = {}
local PointsChanged = {}
local EBPoints = 0  -- Elusive Brew

local HolyPowerTexture
local SoulShardBG

local PlayerClass
local PlayerSpec
local PlayerTalent = 0
local PlayerInCombat
local PlayerTargetHostile
local PlayerInInstance
local SmartHideConditions
local ValidClasses

local idToPower = {
    cp = SPELL_POWER_COMBO_POINTS,
    chi = SPELL_POWER_CHI,
    hp = SPELL_POWER_HOLY_POWER,
    so = SPELL_POWER_SHADOW_ORBS,
    ss = SPELL_POWER_SOUL_SHARDS,
    be = SPELL_POWER_BURNING_EMBERS
}
function PointTracking:GetResource()
    if PlayerClass == "ROGUE" then
        return {{type = "SPELL_POWER_COMBO_POINTS", id = "cp"}}, "GENERAL"
    elseif PlayerClass == "DRUID" then
        return {{type = "SPELL_POWER_COMBO_POINTS", id = "cp"}}, "GENERAL"
    elseif PlayerClass == "MONK" then
        return {{type = "SPELL_POWER_CHI", id = "chi"}}, PlayerClass
    elseif PlayerClass == "PALADIN" then
        return {{type = "SPELL_POWER_HOLY_POWER", id = "hp"}}, PlayerClass
    elseif PlayerClass == "PRIEST" then
        return {{type = "SPELL_POWER_SHADOW_ORBS", id = "so"}}, PlayerClass
    elseif PlayerClass == "WARLOCK" then
        return {{type = "SPELL_POWER_SOUL_SHARDS", id = "ss"}, {type = "SPELL_POWER_BURNING_EMBERS", id = "be"}}, PlayerClass
    end
end

-- Update Point Bars
local PBTex = {}
local ebColors = {
    [1] = {1, 1, 1},
    [2] = {1, 1, 0},
    [0] = {1, 0, 0}
}
local function SetPointBarTextures(shown, ic, it, tid, i)
    if tid == "hp" and db[ic].types[tid].bars.custom then
        PBTex.empty = nil
        PBTex.full = HolyPowerTexture[i]
        PBTex.surround = nil
    else
        PBTex.empty = BG[ic][tid].bars.empty
        PBTex.full = BG[ic][tid].bars.full
        PBTex.surround = BG[ic][tid].bars.surround
    end
    
    -- Visible Bar
    if shown then
        -- BG
        Frames[ic][tid].bars[i].bg:SetTexture(PBTex.full)
        
        -- Custom Colors
        if tid == "ap" or tid == "cp" then  -- Anticipation Point stack coloring
            if Points["ap"] > 0 then
                for api = 1, Points["ap"] do
                    if api > Points["cp"] then
                        Frames["ROGUE"]["ap"].bars[api].bg:SetVertexColor(db["ROGUE"].types["ap"].bars.bg.full.color.r, db["ROGUE"].types["ap"].bars.bg.full.color.g, db["ROGUE"].types["ap"].bars.bg.full.color.b, db["ROGUE"].types["ap"].bars.bg.full.color.a)
                    else
                        Frames["ROGUE"]["ap"].bars[api].bg:SetVertexColor(db["ROGUE"].types["ap"].bars.bg.full.maxcolor.r, db["ROGUE"].types["ap"].bars.bg.full.maxcolor.g, db["ROGUE"].types["ap"].bars.bg.full.maxcolor.b, db["ROGUE"].types["ap"].bars.bg.full.maxcolor.a)
                    end
                end
            end

        -- Normal Colors
        else
            if Points[tid] < Types[ic].points[it].barcount then
                Frames[ic][tid].bars[i].bg:SetVertexColor(db[ic].types[tid].bars.bg.full.color.r, db[ic].types[tid].bars.bg.full.color.g, db[ic].types[tid].bars.bg.full.color.b, db[ic].types[tid].bars.bg.full.color.a)
            else
                Frames[ic][tid].bars[i].bg:SetVertexColor(db[ic].types[tid].bars.bg.full.maxcolor.r, db[ic].types[tid].bars.bg.full.maxcolor.g, db[ic].types[tid].bars.bg.full.maxcolor.b, db[ic].types[tid].bars.bg.full.maxcolor.a)
            end
        end
        Frames[ic][tid].bars[i].surround:SetVertexColor(db[ic].types[tid].bars.surround.color.r, db[ic].types[tid].bars.surround.color.g, db[ic].types[tid].bars.surround.color.b, db[ic].types[tid].bars.surround.color.a)
        
    -- Empty Bar
    else
        -- BG
        Frames[ic][tid].bars[i].bg:SetTexture(PBTex.empty)
        Frames[ic][tid].bars[i].bg:SetVertexColor(db[ic].types[tid].bars.bg.empty.color.r, db[ic].types[tid].bars.bg.empty.color.g, db[ic].types[tid].bars.bg.empty.color.b, db[ic].types[tid].bars.bg.empty.color.a)
    end
    Frames[ic][tid].bars[i].surround:SetTexture(PBTex.surround)
end

function PointTracking:UpdatePointTracking(...)
    local UpdateList
    if ... == "ENABLE" then
        -- Update everything
        UpdateList = Types
    else
        UpdateList = ValidClasses
    end
    
    -- Cycle through all Types that need updating
    for ic,vc in pairs(UpdateList) do
        -- Cycle through all Point Displays in current Type
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id
            
            -- Do we hide the Display
            if ((Points[tid] == 0)
                or (ic ~= PlayerClass and ic ~= "GENERAL") 
                or ((PlayerClass ~= "ROGUE") and (PlayerClass ~= "DRUID") and (ic == "GENERAL") and not UnitHasVehicleUI("player"))
                or ((PlayerClass == "WARLOCK") and (PlayerTalent == 1) and (tid == "be")) --
                or ((PlayerClass == "WARLOCK") and (PlayerTalent == 3) and (tid == "ss")) --    
                or (db[ic].types[tid].general.hidein.vehicle and UnitHasVehicleUI("player")) 
                or ((db[ic].types[tid].general.hidein.spec - 1) == PlayerSpec))
                and not db[ic].types[tid].configmode.enabled then
                    -- Hide Display 
                    Frames[ic][tid].bgpanel.frame:Hide()

                    -- Anticipation Points refresh on 0 Combo Points
                    if tid == "cp" and Points["ap"] > 0 then
                        SetPointBarTextures(true, "ROGUE", 1, "ap", Points["ap"])
                    end
            else
            -- Update the Display
                -- Update Bars if their Points have changed
                if PointsChanged[tid] then
                    local max = UnitPowerMax("player", idToPower[tid])
                    for i = 1, Types[ic].points[it].barcount do
                        if Points[tid] == nil then Points[tid] = 0 end
                        if Points[tid] >= i then
                        -- Show bar and set textures to "Full"
                            Frames[ic][tid].bars[i].frame:Show()
                            SetPointBarTextures(true, ic, it, tid, i)
                        elseif i > max then
                            Frames[ic][tid].bars[i].frame:Hide()
                        else
                            if db[ic].types[tid].general.hideempty then
                            -- Hide "empty" bar
                                Frames[ic][tid].bars[i].frame:Hide()
                            else
                            -- Show bar and set textures to "Empty"
                                Frames[ic][tid].bars[i].frame:Show()
                                SetPointBarTextures(false, ic, it, tid, i)
                            end             
                        end
                        
                    end
                    -- Show the Display
                    Frames[ic][tid].bgpanel.frame:Show()
                    
                    -- Flag as having been changed
                    PointsChanged[tid] = false
                end
            end
        end
    end
end

-- Point retrieval
local function GetDebuffCount(SpellID, ...)
    if not SpellID then return end
    local unit = ... or "target"
    local _,_,_,count,_,_,_,caster = UnitDebuff(unit, SpellID)
    if count == nil then count = 0 end
    if caster ~= "player" then count = 0 end    -- Only show Debuffs cast by me
    return count
end

local function GetBuffCount(SpellID, ...)
    if not SpellID then return end
    local unit = ... or "player"
    local _,_,_,count = UnitAura(unit, SpellID)
    if count == nil then count = 0 end
    return count
end

function PointTracking:GetPoints(CurClass, CurType)
    local NewPoints
    if CurType == "ap" then
        -- Anticipation Points
        NewPoints = GetBuffCount(SpellInfo[CurType])
    else
        NewPoints = UnitPower("player", idToPower[CurType])
    end
    Points[CurType] = NewPoints
end

-- Update all valid Point Displays
function PointTracking:UpdatePoints(...)    
    local HasChanged = false
    local Enable = ...
    
    local UpdateList
    if ... == "ENABLE" then
        -- Update everything
        UpdateList = Types
    else
        UpdateList = ValidClasses
    end
    
    -- ENABLE update: Config Mode / Reset displays
    if Enable == "ENABLE" then
        HasChanged = true
        for ic,vc in pairs(Types) do
            for it,vt in ipairs(Types[ic].points) do
                local tid = Types[ic].points[it].id
                PointsChanged[tid] = true
                if ( db[ic].types[tid].enabled and db[ic].types[tid].configmode.enabled ) then
                    -- If Enabled and Config Mode is on, then set points
                    Points[tid] = db[ic].types[tid].configmode.count
                else
                    Points[tid] = 0
                end
            end
        end
    end
    
    -- Normal update: Cycle through valid classes
    for ic,vc in pairs(UpdateList) do
        -- Cycle through point types for current class
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id
            if ( db[ic].types[tid].enabled and not db[ic].types[tid].configmode.enabled ) then
                -- Retrieve new point count
                local OldPoints = (tid == "eb") and EBPoints or Points[tid]
                PointTracking:GetPoints(ic, tid)
                local NewPoints = (tid == "eb") and EBPoints or Points[tid]
                if NewPoints ~= OldPoints then
                    -- Points have changed, flag for updating
                    HasChanged = true
                    PointsChanged[tid] = true
                end
            end
        end
    end
    
    -- Update Point Displays
    if HasChanged then PointTracking:UpdatePointTracking(Enable) end
end

-- Enable a Point Display
function PointTracking:EnablePointTracking(c, t)
    PointTracking:UpdatePoints("ENABLE")
end

-- Disable a Point Display
function PointTracking:DisablePointTracking(c, t)
    -- Set to 0 points
    Points[t] = 0
    PointsChanged[t] = true
    
    -- Update Point Displays
    PointTracking:UpdatePointTracking("ENABLE")
end

-- Update frame positions/sizes
function PointTracking:UpdatePosition()
    for ic,vc in pairs(Types) do
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id

            ---- BG Panel
            local Parent = RealUIPositionersCTPoints
            
            Frames[ic][tid].bgpanel.frame:SetParent(Parent)
            Frames[ic][tid].bgpanel.frame:ClearAllPoints()
            Frames[ic][tid].bgpanel.frame:SetPoint(db[ic].types[tid].position.side, Parent, db[ic].types[tid].position.side, db[ic].types[tid].position.x, db[ic].types[tid].position.y)
            Frames[ic][tid].bgpanel.frame:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
            Frames[ic][tid].bgpanel.frame:SetFrameLevel(db[ic].types[tid].position.framelevel.level)
            Frames[ic][tid].bgpanel.frame:SetWidth(10)
            Frames[ic][tid].bgpanel.frame:SetHeight(10)
            
            ---- Point Bars
            local IsRev = db[ic].types[tid].general.direction.reverse
            local XPos, YPos, CPRatio, TWidth, THeight
            local Positions = {}
            local CPSize = {}
            
            -- Get total Width and Height of Point Display, and the size of each Bar
            TWidth = 0
            THeight = 0
            for i = 1, Types[ic].points[it].barcount do
                CPSize[i] = db[ic].types[tid].bars.size.width + db[ic].types[tid].bars.position.gap
                TWidth = TWidth + db[ic].types[tid].bars.size.width + db[ic].types[tid].bars.position.gap
            end
            
            -- Calculate position of each Bar
            for i = 1, Types[ic].points[it].barcount do
                local CurPos = 0
                local TVal = TWidth
                
                -- Add up position of each Bar in sequence
                if i == 1 then
                    CurPos = 0
                else
                    for j = 1, i-1 do
                        CurPos = CurPos + CPSize[j]
                    end
                end                 
                
                -- Found Position of Bar
                Positions[i] = CurPos
            end
            
            -- Position each Bar
            for i = 1, Types[ic].points[it].barcount do
                local RevMult = 1
                if IsRev then RevMult = -1 end          
                
                Frames[ic][tid].bars[i].frame:SetParent(Frames[ic][tid].bgpanel.frame)
                Frames[ic][tid].bars[i].frame:ClearAllPoints()
                
                XPos = Positions[i] * RevMult
                YPos = 0
                
                Frames[ic][tid].bars[i].frame:SetPoint(db[ic].types[tid].position.side, Frames[ic][tid].bgpanel.frame, db[ic].types[tid].position.side, XPos, YPos)
                
                Frames[ic][tid].bars[i].frame:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
                Frames[ic][tid].bars[i].frame:SetFrameLevel(db[ic].types[tid].position.framelevel.level + i + 2)
                Frames[ic][tid].bars[i].frame:SetWidth(db[ic].types[tid].bars.size.width)
                Frames[ic][tid].bars[i].frame:SetHeight(db[ic].types[tid].bars.size.height)
            end
            
            Frames[ic][tid].bgpanel.frame:SetWidth(Positions[Types[ic].points[it].barcount] + db[ic].types[tid].bars.size.width)
        end
    end
end

function PointTracking:ToggleConfigMode(val)
    local power, class = self:GetResource()
    if nibRealUI:GetModuleEnabled(MODNAME) and power then
        for i = 1, #power do
            local tid = power[i].id
            db[class].types[tid].configmode.enabled = val
            if val then
                db[class].types[tid].configmode.count = Types[class].points[i].barcount
            else
                db[class].types[tid].configmode.count = 2
            end
        end
        self:UpdatePoints("ENABLE")
    end
end

-- Retrieve SharedMedia backgound
local function RetrieveBackground(background)
    background = LSM:Fetch("background", background, true)
    return background
end

local function VerifyBackground(background)
    local newbackground = ""
    if background and strlen(background) > 0 then 
        newbackground = RetrieveBackground(background)
        if background ~= "None" then
            if not newbackground then
                print("Background "..background.." was not found in SharedMedia.")
                newbackground = ""
            end
        end
    end 
    return newbackground
end

-- Retrieve Background textures and store in tables
function PointTracking:GetTextures()
    for ic,vc in pairs(Types) do
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id
            BG[ic][tid].bars.empty = VerifyBackground(db[ic].types[tid].bars.bg.empty.texture)
            BG[ic][tid].bars.full = VerifyBackground(db[ic].types[tid].bars.bg.full.texture)
            BG[ic][tid].bars.surround = VerifyBackground(db[ic].types[tid].bars.surround.texture)
        end
    end
end

-- Frame Creation
local function CreateFrames(config)
    for ic,vc in pairs(Types) do
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id
            
            -- BG Panel
            local FrameName = "PointTracking_Frames_"..tid
            Frames[ic][tid].bgpanel.frame = CreateFrame("Frame", FrameName, UIParent)
            CombatFader:RegisterFrameForFade(MODNAME, Frames[ic][tid].bgpanel.frame)
            
            Frames[ic][tid].bgpanel.bg = Frames[ic][tid].bgpanel.frame:CreateTexture(nil, "ARTWORK")
            Frames[ic][tid].bgpanel.bg:SetAllPoints(Frames[ic][tid].bgpanel.frame)
            
            Frames[ic][tid].bgpanel.frame:Hide()
            
            -- Point bars
            for i = 1, Types[ic].points[it].barcount do
                local BarFrameName = "PointTracking_Frames_"..tid.."_bar"..tostring(i)
                Frames[ic][tid].bars[i].frame = CreateFrame("Frame", BarFrameName, UIParent)
                
                Frames[ic][tid].bars[i].bg = Frames[ic][tid].bars[i].frame:CreateTexture(nil, "ARTWORK")
                Frames[ic][tid].bars[i].bg:SetAllPoints(Frames[ic][tid].bars[i].frame)
                
                Frames[ic][tid].bars[i].surround = Frames[ic][tid].bars[i].frame:CreateTexture(nil, "ARTWORK")
                Frames[ic][tid].bars[i].surround:SetAllPoints(Frames[ic][tid].bars[i].frame)
                
                Frames[ic][tid].bars[i].frame:Show()
            end
        end
    end
end

-- Table creation
local function CreateTables(config)
    -- Frames
    wipe(Frames)
    wipe(BG)
    wipe(Points)
    wipe(PointsChanged)
    
    for ic,vc in pairs(Types) do
        -- Insert Class header
        tinsert(Frames, ic)
        Frames[ic] = {}
        tinsert(BG, ic)
        BG[ic] = {}
        
        for it,vt in ipairs(Types[ic].points) do    -- Iterate through Types table
            local tid = Types[ic].points[it].id
            
            -- Insert point type (ie "cp") into table and fill out table
            -- Frames
            tinsert(Frames[ic], tid)
            tinsert(BG[ic], tid)
            
            Frames[ic][tid] = {
                bgpanel = {frame = nil, bg = nil},
                bars = {},              
            }
            BG[ic][tid] = {
                bars = {},
            }
            for i = 1, Types[ic].points[it].barcount do
                Frames[ic][tid].bars[i] = {frame = nil, bg = nil, surround = nil}
                BG[ic][tid].bars[i] = {empty = "", full = "", surround = ""}
            end
            
            -- Points           
            Points[tid] = 0
            
            -- Set up Points Changed table
            PointsChanged[tid] = false
        end
    end
end

-- Refresh PointTracking
function PointTracking:Refresh()
    self:UpdateSpec()
    self:GetTextures()
    self:UpdatePosition()
    self:UpdatePoints("ENABLE")
end

-- Hide default UI frames
function PointTracking:HideUIElements()
    if db["GENERAL"].types["cp"].enabled and db["GENERAL"].types["cp"].general.hideui then
        for i = 1,5 do
            _G["ComboPoint"..i]:Hide()
            _G["ComboPoint"..i]:SetScript("OnShow", function(self) self:Hide() end)
        end
    end
    
    if db["PALADIN"].types["hp"].enabled and db["PALADIN"].types["hp"].general.hideui then
        local HPF = _G["PaladinPowerBar"]
        if HPF then
            HPF:Hide()
            HPF:SetScript("OnShow", function(self) self:Hide() end)
        end
    end
    
    if db["WARLOCK"].types["ss"].enabled and db["WARLOCK"].types["ss"].general.hideui then
        local SSF = _G["ShardBarFrame"]
        if SSF then
            SSF:Hide()
            SSF:SetScript("OnShow", function(self) self:Hide() end)
        end
    end
end

function PointTracking:UpdateSpec()
    PlayerSpec = GetActiveSpecGroup()
    PlayerTalent = GetSpecialization()
end

function PointTracking:UpdateSmartHideConditions()
    if PlayerInCombat or PlayerTargetHostile or PlayerInInstance then
        SmartHideConditions = false
    else
        SmartHideConditions = true
    end
    self:UpdatePoints("ENABLE")
end

function PointTracking:PLAYER_TARGET_CHANGED()
    PlayerTargetHostile = (UnitIsEnemy("player", "target") or UnitCanAttack("player", "target"))
    self:UpdateSmartHideConditions()
    self:UpdatePoints()
end

function PointTracking:PLAYER_REGEN_DISABLED()
    PlayerInCombat = true
    self:UpdateSmartHideConditions()
end

function PointTracking:PLAYER_REGEN_ENABLED()
    PlayerInCombat = false
    self:UpdateSmartHideConditions()
end

function PointTracking:PLAYER_ENTERING_WORLD()
    -- GreenFire = IsSpellKnown(WARLOCK_GREEN_FIRE)
    PlayerInInstance = IsInInstance()
    self:UpdateSpec()
    self:UpdatePosition()
    self:UpdateSmartHideConditions()
end

function PointTracking:PLAYER_LOGIN()
    PlayerClass = nibRealUI.class
    
    -- Build Class list to run updates on
    ValidClasses = {
        ["GENERAL"] = true,
        [PlayerClass] = Types[PlayerClass],
    },
    
    -- Register Media
    LSM:Register("background", "Round_Large_BG", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Large_BG]])
    LSM:Register("background", "Round_Large_Surround", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Large_Surround]])
    LSM:Register("background", "Round_Small_BG", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Small_BG]])
    LSM:Register("background", "Round_Small_Surround", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Small_Surround]])
    LSM:Register("background", "Round_Larger_BG", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Larger_BG]])
    LSM:Register("background", "Round_Larger_Surround", [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Larger_Surround]])
    LSM:Register("background", "Soul_Shard_BG", [[Interface\Addons\nibRealUI\Media\PointTracking\SoulShard_BG]])
    LSM:Register("background", "Soul_Shard_Surround", [[Interface\Addons\nibRealUI\Media\PointTracking\SoulShard_Surround]])
    
    HolyPowerTexture = {
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower1]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower2]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower3]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower4]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower5]]
    }
    
    -- Get Spell Info
    -- Death Knight
    SpellInfo["bs"] = GetSpellInfo(49222)       -- Bone Shield
    -- Druid
    -- Hunter
    -- Mage
    -- Monk
    -- Priest
    -- Rogue    
    SpellInfo["ap"] = GetSpellInfo(114015)      -- Anticipation Points
    -- Shaman
    -- Warlock
    -- Warrior
        
    -- Hide Elements
    PointTracking:HideUIElements()
    
    -- Register Events
    -- Throttled Events
    local EventList = {
        "UNIT_COMBO_POINTS",
        "VEHICLE_UPDATE",
        "UNIT_AURA",
    }
    if (PlayerClass == "MONK") or (PlayerClass == "PRIEST") or (PlayerClass == "PALADIN") then
        tinsert(EventList, "UNIT_POWER")
    elseif (PlayerClass == "WARLOCK") then
        tinsert(EventList, "UNIT_POWER")
        tinsert(EventList, "UNIT_DISPLAYPOWER")
    end 

    local UpdateSpeed
    if ndb.powerMode == 1 then      -- Normal
        UpdateSpeed = 1/8
    elseif ndb.powerMode == 2 then  -- Economy
        UpdateSpeed = 1/6
    else                            -- Turbo
        UpdateSpeed = 1/10
    end
    self:RegisterBucketEvent(EventList, UpdateSpeed, "UpdatePoints")
    
    -- Refresh Addon
    PointTracking:Refresh()
end

function PointTracking:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults(nibRealUI:GetPointTrackingDefaults())
    
    db = self.db.profile
    ndb = nibRealUI.db.profile
    
    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    CombatFader:RegisterModForFade(MODNAME, db.combatfade)
    nibRealUI:RegisterConfigModeModule(self)
end

function PointTracking:OnEnable()
    CreateTables()
    CreateFrames()
    
    -- Turn off Config Mode
    for ic,vc in pairs(Types) do
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id
            db[ic].types[tid].configmode.enabled = false
        end
    end
    
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "UpdateSpec")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
end
