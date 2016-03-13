local _, private = ...

-- Lua Globals --
local _G = _G
local next, ipairs = _G.next, _G.ipairs
local tinsert = _G.table.insert

-- Libs --
local LSM = _G.LibStub("LibSharedMedia-3.0")

-- RealUI --
local RealUI = private.RealUI
local db, ndb

local CombatFader = RealUI:GetModule("CombatFader")

local MODNAME = "PointTracking"
local PointTracking = RealUI:GetModule(MODNAME)

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

local HolyPowerTexture

local PlayerClass
local PlayerSpec
local PlayerTalent = 0
local PlayerInCombat
local PlayerTargetHostile
local PlayerInInstance
local SmartHideConditions -- luacheck: ignore
local ValidClasses

local idToPower = {
    cp = _G.SPELL_POWER_COMBO_POINTS,
    chi = _G.SPELL_POWER_CHI,
    hp = _G.SPELL_POWER_HOLY_POWER,
    so = _G.SPELL_POWER_SHADOW_ORBS,
    ss = _G.SPELL_POWER_SOUL_SHARDS,
    be = _G.SPELL_POWER_BURNING_EMBERS
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
local function SetPointBarTextures(shown, ic, it, tid, i)
    PointTracking:debug("SetPointBarTextures", shown, ic, it, tid, i)
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
        local bars, color = db[ic].types[tid].bars
        if tid == "ap" or tid == "cp" then  -- Anticipation Point stack coloring
            if Points["ap"] > 0 then
                for api = 1, Points["ap"] do
                    bars = db["ROGUE"].types["ap"].bars
                    if api <= Points["cp"] then
                        color = bars.bg.full.color
                    else
                        color = bars.bg.full.maxcolor
                    end
                    Frames["ROGUE"]["ap"].bars[api].bg:SetVertexColor(color.r, color.g, color.b, color.a)
                end
            end
        else -- Normal Colors
            if Points[tid] < Types[ic].points[it].barcount then
                color = bars.bg.full.color
            else
                color = bars.bg.full.maxcolor
            end
            Frames[ic][tid].bars[i].bg:SetVertexColor(color.r, color.g, color.b, color.a)
        end
        Frames[ic][tid].bars[i].surround:SetVertexColor(bars.surround.color.r, bars.surround.color.g, bars.surround.color.b, bars.surround.color.a)
        
    -- Empty Bar
    else
        -- BG
        Frames[ic][tid].bars[i].bg:SetTexture(PBTex.empty)
        Frames[ic][tid].bars[i].bg:SetVertexColor(db[ic].types[tid].bars.bg.empty.color.r, db[ic].types[tid].bars.bg.empty.color.g, db[ic].types[tid].bars.bg.empty.color.b, db[ic].types[tid].bars.bg.empty.color.a)
    end
    Frames[ic][tid].bars[i].surround:SetTexture(PBTex.surround)
end

function PointTracking:UpdatePointTracking(...)
    PointTracking:debug("UpdatePointTracking", ...)
    local UpdateList
    if ... == "ENABLE" then
        -- Update everything
        UpdateList = Types
    else
        UpdateList = ValidClasses
    end
    
    -- Cycle through all Types that need updating
    for ic,vc in next, UpdateList do
        -- Cycle through all Point Displays in current Type
        for it, vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id
            PointTracking:debug("Type", tid, Points[tid])

            -- Do we hide the Display
            if ((Points[tid] == 0)
                or (ic ~= PlayerClass and ic ~= "GENERAL") 
                or ((PlayerClass ~= "ROGUE") and (PlayerClass ~= "DRUID") and (ic == "GENERAL") and not _G.UnitHasVehicleUI("player"))
                or ((PlayerClass == "WARLOCK") and (tid == "ss") and not (PlayerTalent == 1))
                or ((PlayerClass == "WARLOCK") and (tid == "be") and not (PlayerTalent == 3))
                or (db[ic].types[tid].general.hidein.vehicle and _G.UnitHasVehicleUI("player")) 
                or ((db[ic].types[tid].general.hidein.spec - 1) == PlayerSpec))
                and not db[ic].types[tid].configmode.enabled then
                    PointTracking:debug("Hide Display")
                    Frames[ic][tid].bgpanel.frame:Hide()
                    Frames[ic][tid].bgpanel.frame.realUIHidden = true

                    -- Anticipation Points refresh on 0 Combo Points
                    if tid == "cp" and Points["ap"] > 0 then
                        SetPointBarTextures(true, "ROGUE", 1, "ap", Points["ap"])
                    end
            else
                -- Update Bars if their Points have changed
                if PointsChanged[tid] then
                    local max = _G.UnitPowerMax("player", idToPower[tid])
                    PointTracking:debug("Update Display", max)
                    for i = 1, Types[ic].points[it].barcount do
                        PointTracking:debug("Update point", i)
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
                    Frames[ic][tid].bgpanel.frame.realUIHidden = false
                    
                    -- Flag as having been changed
                    PointsChanged[tid] = false
                end
            end
        end
    end
end

-- Point retrieval
local function GetBuffCount(SpellID, ...)
    PointTracking:debug("GetBuffCount", SpellID, ...)
    if not SpellID then return end
    local unit = ... or "player"
    local _,_,_,count = _G.UnitAura(unit, SpellID)
    if count == nil then count = 0 end
    return count
end

function PointTracking:GetPoints(CurClass, CurType)
    PointTracking:debug("GetPoints", CurClass, CurType)
    local NewPoints
    if CurType == "ap" then
        -- Anticipation Points
        NewPoints = GetBuffCount(SpellInfo[CurType])
    else
        NewPoints = _G.UnitPower("player", idToPower[CurType])
    end
    Points[CurType] = NewPoints
end

-- Update all valid Point Displays
function PointTracking:UpdatePoints(...)
    PointTracking:debug("UpdatePoints", ...)
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
        for ic,vc in next, Types do
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
    for ic,vc in next, UpdateList do
        -- Cycle through point types for current class
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id
            PointTracking:debug("Type", tid)
            if ( db[ic].types[tid].enabled and not db[ic].types[tid].configmode.enabled ) then
                -- Retrieve new point count
                local OldPoints = Points[tid]
                PointTracking:GetPoints(ic, tid)
                local NewPoints = Points[tid]
                PointTracking:debug("HasChanged", NewPoints, OldPoints)
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
    for ic,vc in next, Types do
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id

            if tid == "ap" then
                db[ic].types[tid].bars.position.side = db["GENERAL"].types["cp"].bars.position.side
                db[ic].types[tid].bars.position.x = db["GENERAL"].types["cp"].bars.position.x
                db[ic].types[tid].bars.position.y = db["GENERAL"].types["cp"].bars.position.y
                db[ic].types[tid].bars.position.gap = db["GENERAL"].types["cp"].bars.position.gap
            end

            ---- BG Panel
            local Parent = _G.RealUIPositionersCTPoints
            
            Frames[ic][tid].bgpanel.frame:SetParent(Parent)
            Frames[ic][tid].bgpanel.frame:ClearAllPoints()
            Frames[ic][tid].bgpanel.frame:SetPoint(db[ic].types[tid].position.side, Parent, db[ic].types[tid].position.side, db[ic].types[tid].position.x, db[ic].types[tid].position.y)
            Frames[ic][tid].bgpanel.frame:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
            Frames[ic][tid].bgpanel.frame:SetFrameLevel(db[ic].types[tid].position.framelevel.level)
            Frames[ic][tid].bgpanel.frame:SetWidth(10)
            Frames[ic][tid].bgpanel.frame:SetHeight(10)
            
            ---- Point Bars
            local IsRev = db[ic].types[tid].general.direction.reverse
            local XPos, YPos, TWidth
            local Positions = {}
            local CPSize = {}
            
            -- Get total Width and Height of Point Display, and the size of each Bar
            TWidth = 0
            for i = 1, Types[ic].points[it].barcount do
                CPSize[i] = db[ic].types[tid].bars.size.width + db[ic].types[tid].bars.position.gap
                TWidth = TWidth + db[ic].types[tid].bars.size.width + db[ic].types[tid].bars.position.gap
            end
            
            -- Calculate position of each Bar
            for i = 1, Types[ic].points[it].barcount do
                local CurPos = 0
                
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
    if RealUI:GetModuleEnabled(MODNAME) and power then
        for i = 1, #power do
            local tid = power[i].id
            db[class].types[tid].configmode.enabled = val
            db[class].types[tid].configmode.count = _G.UnitPowerMax("player", idToPower[tid])
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
    if background and background:len() > 0 then 
        newbackground = RetrieveBackground(background)
        if background ~= "None" then
            if not newbackground then
                _G.print("Background "..background.." was not found in SharedMedia.")
                newbackground = ""
            end
        end
    end 
    return newbackground
end

-- Retrieve Background textures and store in tables
function PointTracking:GetTextures()
    for ic,vc in next, Types do
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
    for ic,vc in next, Types do
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id
            
            -- BG Panel
            local FrameName = "PointTracking_Frames_"..tid
            Frames[ic][tid].bgpanel.frame = _G.CreateFrame("Frame", FrameName, _G.UIParent)
            CombatFader:RegisterFrameForFade(MODNAME, Frames[ic][tid].bgpanel.frame)
            
            Frames[ic][tid].bgpanel.bg = Frames[ic][tid].bgpanel.frame:CreateTexture(nil, "ARTWORK")
            Frames[ic][tid].bgpanel.bg:SetAllPoints(Frames[ic][tid].bgpanel.frame)
            
            Frames[ic][tid].bgpanel.frame:Hide()
            
            -- Point bars
            for i = 1, Types[ic].points[it].barcount do
                local BarFrameName = "PointTracking_Frames_"..tid.."_bar".._G.tostring(i)
                Frames[ic][tid].bars[i].frame = _G.CreateFrame("Frame", BarFrameName, _G.UIParent)
                
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
    _G.wipe(Frames)
    _G.wipe(BG)
    _G.wipe(Points)
    _G.wipe(PointsChanged)
    
    for ic,vc in next, Types do
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
            _G["ComboPoint"..i]:SetScript("OnShow", function(point) point:Hide() end)
        end
    end
    
    if db["PALADIN"].types["hp"].enabled and db["PALADIN"].types["hp"].general.hideui then
        local HPF = _G["PaladinPowerBar"]
        if HPF then
            HPF:Hide()
            HPF:SetScript("OnShow", function(point) point:Hide() end)
        end
    end
    
    if db["WARLOCK"].types["ss"].enabled and db["WARLOCK"].types["ss"].general.hideui then
        local SSF = _G["ShardBarFrame"]
        if SSF then
            SSF:Hide()
            SSF:SetScript("OnShow", function(point) point:Hide() end)
        end
    end
end

function PointTracking:UpdateSpec()
    local oldSpec, oldTalent = PlayerSpec, PlayerTalent
    PlayerSpec, PlayerTalent = _G.GetActiveSpecGroup(), _G.GetSpecialization()
    return oldSpec ~= PlayerSpec or oldTalent ~= PlayerTalent
end

function PointTracking:PLAYER_TALENT_UPDATE(...)
    PointTracking:debug("------", ...)
    local hasChanged = PointTracking:UpdateSpec()
    if hasChanged then
        self:UpdatePoints("ENABLE")
    end
end

function PointTracking:UpdateSmartHideConditions()
    if PlayerInCombat or PlayerTargetHostile or PlayerInInstance then
        SmartHideConditions = false
    else
        SmartHideConditions = true
    end
    self:UpdatePoints("ENABLE")
end

function PointTracking:PLAYER_TARGET_CHANGED(...)
    PointTracking:debug("------", ...)
    PlayerTargetHostile = (_G.UnitIsEnemy("player", "target") or _G.UnitCanAttack("player", "target"))
    self:UpdateSmartHideConditions()
end

function PointTracking:PLAYER_REGEN_DISABLED(...)
    PointTracking:debug("------", ...)
    PlayerInCombat = true
    self:UpdateSmartHideConditions()
end

function PointTracking:PLAYER_REGEN_ENABLED(...)
    PointTracking:debug("------", ...)
    PlayerInCombat = false
    self:UpdateSmartHideConditions()
end

function PointTracking:PLAYER_ENTERING_WORLD(...)
    PointTracking:debug("------", ...)
    -- GreenFire = IsSpellKnown(WARLOCK_GREEN_FIRE)
    PlayerInInstance = _G.IsInInstance()
    self:UpdateSpec()
    self:UpdatePosition()
    self:UpdateSmartHideConditions()
end

function PointTracking:PLAYER_LOGIN()
    
    -- Build Class list to run updates on
    ValidClasses = {
        ["GENERAL"] = true,
        [PlayerClass] = Types[PlayerClass],
    }
    
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
    SpellInfo["bs"] = _G.GetSpellInfo(49222)       -- Bone Shield
    -- Druid
    -- Hunter
    -- Mage
    -- Monk
    -- Priest
    -- Rogue    
    SpellInfo["ap"] = _G.GetSpellInfo(114015)      -- Anticipation Points
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
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults(PointTracking.defaults)
    
    db = self.db.profile
    ndb = RealUI.db.profile
    PlayerClass = RealUI.class
    
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    CombatFader:RegisterModForFade(MODNAME, db.combatfade)
    RealUI:RegisterConfigModeModule(self)
end

function PointTracking:OnEnable()
    CreateTables()
    CreateFrames()
    
    -- Turn off Config Mode
    for ic,vc in next, Types do
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id
            db[ic].types[tid].configmode.enabled = false
        end
    end
    
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
end
