local ADDON_NAME, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next
local math = _G.math

-- WoW Globals --
local CreateFrame = _G.CreateFrame

-- Libs --
local BT4, BT4DB, BT4Profile
local BT4ActionBars, BT4AB_EnableBar, BT4Stance

-- RealUI --
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = nibRealUI.L
local db, ndb
local RealUIFont_PixelSmall, RealUIFont_PixelCooldown = _G.RealUIFont_PixelSmall, _G.RealUIFont_PixelCooldown

local MODNAME = "ActionBars"
local ActionBars = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0")

local EnteredWorld = false

local Textures = {
    petBar = {
        center = [[Interface\Addons\nibRealUI\Media\Doodads\PetBar_Center]],
        sides = [[Interface\Addons\nibRealUI\Media\Doodads\PetBar_Sides]],
    },
    stanceBar = {
        center = [[Interface\Addons\nibRealUI\Media\Doodads\StanceBar_Center]],
        sides = [[Interface\Addons\nibRealUI\Media\Doodads\StanceBar_Sides]],
    },
}

local Doodads = {}
local buttonSizes = {
    bars = 26,
    petBar = 22,
    stanceBar = 22,
}
local fixedSettings = {
    padding = 1,
    buttons = 12
}
local function IsOdd(val)
    return val % 2 == 1 and true or false
end
function ActionBars:ApplyABSettings(tag)
    if not _G.nibRealUICharacter then return end
    if _G.nibRealUICharacter.installStage ~= -1 then return end

    local prof = nibRealUI.cLayout == 1 and "RealUI" or "RealUI-Healing"
    if not(BT4 and BT4DB and BT4DB["namespaces"]["ActionBars"]["profiles"][prof]) then return end

    local barSettings = db[nibRealUI.cLayout]

    local topBars, numTopBars, bottomBars, sidePositions
    -- Convert settings to tables
    if barSettings.centerPositions == 1 then
        topBars = {false, false, false}
        bottomBars = {true, true, true}
        numTopBars = 0
    elseif barSettings.centerPositions == 2 then
        topBars = {true, false, false}
        bottomBars = {false, true, true}
        numTopBars = 1
    elseif barSettings.centerPositions == 3 then
        topBars = {true, true, false}
        bottomBars = {false, false, true}
        numTopBars = 2
    else
        topBars = {true, true, true}
        bottomBars = {false, false, false}
        numTopBars = 3
    end
    if barSettings.sidePositions == 1 then
        sidePositions = {[4] = "RIGHT", [5] = "RIGHT"}
    elseif barSettings.sidePositions == 2 then
        sidePositions = {[4] = "RIGHT", [5] = "LEFT"}
    else
        sidePositions = {[4] = "LEFT", [5] = "LEFT"}
    end

    local HuDY = ndb.positions[nibRealUI.cLayout]["HuDY"]
    local ABY = ndb.positions[nibRealUI.cLayout]["ActionBarsY"] + (nibRealUI.hudSizeOffsets[ndb.settings.hudSize]["ActionBarsY"] or 0)

    local BarSizes = {}
    local padding = fixedSettings.padding
    local centerPadding = padding / 2
    local BarPadding = {top = {}, bottom = {}, sides = {}}
    for id = 1, 5 do
        ActionBars:debug("Calculate points", id)
        local BTBar = BT4ActionBars.actionbars[id]
        if BTBar and not BTBar.disabled then
            ----
            -- Calculate Width/Height of bars and their corresponding Left/Top points
            ----
            local isVertBar = id > 3
            local isRightBar = isVertBar and sidePositions[id] == "RIGHT"
            local isLeftBar = isVertBar and not(isRightBar)
            local isTopBar = not(isVertBar) and topBars[id] == true
            local isBottomBar = not(isVertBar) and not(isTopBar)
            ActionBars:debug("Stats", isVertBar, isRightBar, isLeftBar, isTopBar, isBottomBar)

            local numButtons = BTBar.numbuttons
            BarSizes[id] = (buttonSizes.bars * numButtons) + (padding * (numButtons - 1))

            -- Create Padding table
            if isTopBar then
                BarPadding.top[id] = padding
            elseif isBottomBar then
                BarPadding.bottom[id] = padding
            else
                BarPadding.sides[id] = padding
            end

            ----
            -- Calculate bars X and Y positions
            ----
            local x, y

            -- Side Bars
            local BarPositions = {}
            if isVertBar then
                x = isRightBar and -36 or -8

                if sidePositions[4] == sidePositions[5] then
                    -- Link Side Bar settings
                    if id == 4 then
                        y = BarSizes[4] + BarPadding.sides[4] + 10.5
                    else
                        y = 10.5
                    end
                else
                    y = (BarSizes[id] / 2) + 10
                    if not(IsOdd(BarPadding.sides[id])) or IsOdd(numButtons) then y = y + 0.5 end
                end

                BarPositions[id] = sidePositions[id]

            -- Top/Bottom Bars
            else
                x = -((BarSizes[id] / 2) + 10)
                -- if IsOdd(numButtons) then x = x + 0.5 end

                -- Extra on X for pixel perfection
                if isTopBar then
                    if not(IsOdd(BarPadding.top[id])) or IsOdd(numButtons) then x = x + 0.5 end
                else
                    if not(IsOdd(BarPadding.bottom[id])) or IsOdd(numButtons) then x = x + 0.5 end
                end

                -- Bar Place
                local barPlace
                if id == 1 then
                    if numTopBars > 0 then
                        barPlace = 1
                    else
                        barPlace = 3 - numTopBars   -- Want Bottom Bars stacking Top->Down
                    end

                elseif id == 2 then
                    barPlace = 2

                elseif id == 3 then
                    if isTopBar then
                        barPlace = 3
                    else
                        barPlace = 1
                    end
                end

                -- y Offset
                if barPlace == 1 then
                    if isTopBar then
                        y = HuDY + ABY
                    else
                        y = 37
                    end
                elseif barPlace == 2 then
                    if isTopBar then
                        local padding = math.ceil(centerPadding + centerPadding)
                        y = -(buttonSizes.bars + padding) + HuDY + ABY
                    else
                        local padding = math.ceil(centerPadding + centerPadding)
                        y = buttonSizes.bars + padding + 37
                    end
                else
                    local padding = math.ceil(centerPadding + (centerPadding * 2) + centerPadding)
                    if isTopBar then
                        y = -((buttonSizes.bars * 2) + padding) + HuDY + ABY
                    else
                        y = (buttonSizes.bars * 2) + padding + 37
                    end
                end

                BarPositions[id] = isTopBar and "TOP" or "BOTTOM"
            end

            ActionBars:debug("Setup profile", id)
            local profileActionBars = BT4DB["namespaces"]["ActionBars"]["profiles"][prof]
            local bar, point = profileActionBars["actionbars"][id]
            if id <= 3 then
                point = BarPositions[id] == "TOP" and "CENTER" or "BOTTOM"
            else
                point = BarPositions[id]
            end

            bar["position"] = {
                ["x"] = x,
                ["y"] = y,
                ["point"] = point,
                ["scale"] = 1,
                ["growHorizontal"] = "RIGHT",
                ["growVertical"] = "DOWN",
            }
            bar["padding"] = fixedSettings.padding - 10

            if id < 4 then
                bar["flyoutDirection"] = sidePositions[id] == "UP"
            else
                bar["flyoutDirection"] = sidePositions[id] == "LEFT" and "RIGHT" or "LEFT"
            end
            BTBar:SetButtons()
        end
    end

    ----
    -- Vehicle Bar
    ----
    local vbX, vbY = -36, -59.5

    -- Set Position
    local profileVehicle = BT4DB["namespaces"]["Vehicle"]["profiles"][prof]
    if profileVehicle then
        profileVehicle["position"] = {
            ["x"] = vbX,
            ["y"] = vbY,
            ["point"] = "TOPRIGHT",
            ["scale"] = 0.84,
            ["growHorizontal"] = "RIGHT",
            ["growVertical"] = "DOWN",
        }
    end
    local BT4Vehicle = BT4:GetModule("Vehicle", true)
    if BT4Vehicle then BT4Vehicle:ApplyConfig() end

    ----
    -- Pet Bar
    ----
    if barSettings.moveBars.pet then
        -- if nibRealUI.cLayout == 1 then
            local numPetBarButtons = 10
            local pbX, pbY, pbPoint
            local pbP = fixedSettings.padding
            local pbH = (numPetBarButtons * buttonSizes.petBar) + ((numPetBarButtons - 1) * pbP)

            -- Calculate X
            if (sidePositions[4] == "LEFT") and (sidePositions[5] == "LEFT") then
                pbX = buttonSizes.bars + math.ceil((BarPadding.sides[4] * 2) + (pbP / 2)) - 9
            elseif (sidePositions[5] == "LEFT") then
                pbX = buttonSizes.bars + math.ceil((BarPadding.sides[5] * 2) + (pbP / 2)) - 9
            else
                pbX = math.ceil(pbP / 2) - 9
            end

            -- Calculate Y
            pbY = (pbH / 2) + 10

            -- Set Position
            local profilePetBar = BT4DB["namespaces"]["PetBar"]["profiles"][prof]
            if profilePetBar then
                profilePetBar["position"] = {
                    ["x"] = pbX,
                    ["y"] = pbY,
                    ["point"] = "LEFT",
                    ["scale"] = 1,
                    ["growHorizontal"] = "RIGHT",
                    ["growVertical"] = "DOWN",
                }
                profilePetBar["padding"] = pbP - 8
            end
            local BT4PetBar = BT4:GetModule("PetBar", true)
            if BT4PetBar then BT4PetBar:ApplyConfig() end
        -- end
    end

    ----
    -- Extra Action Bar
    ----
    if barSettings.moveBars.eab then
        local eabX, eabY

        -- Calculate Y
        eabY = 61

        -- Calculate X
        if numTopBars == 3 then
            eabX = -32
        elseif numTopBars == 2 then
            eabX = BarSizes[3] / 2 - 4
        else
            eabX = _G.max(BarSizes[2], BarSizes[3]) / 2 - 4
        end

        local profileEAB = BT4DB["namespaces"]["ExtraActionBar"]["profiles"][prof]
        if profileEAB then
            profileEAB["position"] = {
                ["y"] = eabY,
                ["x"] = eabX,
                ["point"] = "BOTTOM",
                ["scale"] = 0.985,
                ["growHorizontal"] = "RIGHT",
                ["growVertical"] = "DOWN",
            }
        end
        local BT4EAB = BT4:GetModule("ExtraActionBar", true)
        if BT4EAB then BT4EAB:ApplyConfig() end
    end

    -- Stance Bar
    if barSettings.moveBars.stance then
        local NumStances = _G.GetNumShapeshiftForms()
        if NumStances > 0 then
            if BT4Stance and not(BT4Stance:IsEnabled()) then BT4Stance:Enable() end

            local sbX, sbY

            if ndb.settings.fontStyle == 3 then
                sbX = -286
                sbY = 28
            else
                sbX = -264
                sbY = 27
            end

            -- Set Position
            local profileStanceBar = BT4DB["namespaces"]["StanceBar"]["profiles"][prof]
            if profileStanceBar then
                profileStanceBar["position"] = {
                    ["x"] = sbX,
                    ["y"] = sbY,
                    ["scale"] = 1,
                    ["growHorizontal"] = "LEFT",
                    ["growVertical"] = "DOWN",
                    ["point"] = "BOTTOMRIGHT"
                }
            end
            if BT4Stance then BT4Stance:ApplyConfig() end
        end
    end

    -- ActionBars
    if nibRealUI:GetModuleEnabled(MODNAME) then
        self:RefreshDoodads()
    end
end

----
-- StanceBar functions
----
function ActionBars:ToggleStanceBar()
    if not Doodads.stance then return end
    ActionBars:debug("ToggleStanceBar")

    if ( BT4Stance and BT4Stance:IsEnabled() and nibRealUI:DoesAddonMove("Bartender4") and db[nibRealUI.cLayout].moveBars.stance and db.showDoodads and not _G.UnitInVehicle("player")) then
        Doodads.stance:Show()
    else
        Doodads.stance:Hide()
    end
end

function ActionBars:UpdateStanceBar()
    ActionBars:debug("UpdatePetBar Check", Doodads.pet, nibRealUI:DoesAddonMove("Bartender4"), db[nibRealUI.cLayout].moveBars.pet)
    if not (Doodads.stance and BT4Stance and nibRealUI:DoesAddonMove("Bartender4") and db[nibRealUI.cLayout].moveBars.stance) then return end
    ActionBars:debug("UpdateStanceBar")

    -- Color
    -- Doodads.stance.sides:SetVertexColor(unpack(nibRealUI.classColor))
    Doodads.stance.sides:SetVertexColor(0.5, 0.5, 0.5)
    
    -- Size/Position
    local NumStances = _G.GetNumShapeshiftForms()
    local sbP = 1--db[nibRealUI.cLayout].stanceBar.padding
    local sbW = (NumStances * 22) + ((NumStances - 1) * sbP)
    local sbX = BT4DB["namespaces"]["StanceBar"]["profiles"][BT4Profile]["position"]["x"] - math.floor((sbW / 2)) + 11.5

    Doodads.stance:ClearAllPoints()
    Doodads.stance:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", math.floor(sbX) - 2, -6)
end

function ActionBars:UPDATE_SHAPESHIFT_FORMS()
    self:UpdateStanceBar()
    self:ToggleStanceBar()
end

----
-- PetBar functions
----
function ActionBars:TogglePetBar()
    if not Doodads.pet then return end
    ActionBars:debug("TogglePetBar")
    
    if ( nibRealUI:DoesAddonMove("Bartender4") and db[nibRealUI.cLayout].moveBars.pet and db.showDoodads and (_G.UnitExists("pet") and not _G.UnitInVehicle("player")) ) then
        Doodads.pet:Show()
    else
        Doodads.pet:Hide()
    end
end

function ActionBars:UpdatePetBar()
    ActionBars:debug("UpdatePetBar Check", Doodads.pet, nibRealUI:DoesAddonMove("Bartender4"), db[nibRealUI.cLayout].moveBars.pet)
    if not (Doodads.pet and nibRealUI:DoesAddonMove("Bartender4") and db[nibRealUI.cLayout].moveBars.pet) then return end
    ActionBars:debug("UpdatePetBar")
    
    -- Color
    Doodads.pet.sides:SetVertexColor(_G.unpack(nibRealUI.classColor))
    
    -- Size/Position
    local pbX = BT4DB["namespaces"]["PetBar"]["profiles"][BT4Profile]["position"]["x"]
    local pbA = BT4DB["namespaces"]["PetBar"]["profiles"][BT4Profile]["position"]["point"]
    Doodads.pet:ClearAllPoints()
    Doodads.pet:SetPoint(pbA, "UIParent", pbA, math.floor(pbX) + 3, 3)

    Doodads.pet:Show()
end

function ActionBars:UNIT_PET()
    self:UpdatePetBar()
    self:TogglePetBar()
end

----
-- Frame Creation
----
function ActionBars:CreateDoodads()
    ActionBars:debug("CreateDoodads")

    -- PetBar
    Doodads.pet = CreateFrame("Frame", "RealUIActionBarDoodadsPet", _G.UIParent)
    local dP = Doodads.pet
    
    dP:SetFrameStrata("BACKGROUND")
    dP:SetFrameLevel(1)
    dP:SetHeight(32)
    dP:SetWidth(32)
    
    dP.sides = dP:CreateTexture(nil, "ARTWORK")
    dP.sides:SetAllPoints(dP)
    dP.sides:SetTexture(Textures.petBar.sides)
    
    dP.center = dP:CreateTexture(nil, "ARTWORK")
    dP.center:SetAllPoints(dP)
    dP.center:SetTexture(Textures.petBar.center)

    dP:Hide()

    -- Stance Bar
    Doodads.stance = CreateFrame("Frame", "RealUIActionBarDoodadsStance", _G.UIParent)
    local dS = Doodads.stance
    
    dS:SetFrameStrata("LOW")
    dS:SetFrameLevel(2)
    dS:SetHeight(32)
    dS:SetWidth(32)
    
    dS.sides = dS:CreateTexture(nil, "ARTWORK")
    dS.sides:SetAllPoints(dS)
    dS.sides:SetTexture(Textures.stanceBar.sides)
    
    dS.center = dS:CreateTexture(nil, "ARTWORK")
    dS.center:SetAllPoints(dS)
    dS.center:SetTexture(Textures.stanceBar.center)
end

----
function ActionBars:RefreshDoodads()
    if not (nibRealUI:GetModuleEnabled(MODNAME) and BT4) then return end
    ActionBars:debug("RefreshDoodads")
    db = self.db.profile
    
    if not Doodads.pet then self:CreateDoodads() end

    self:UpdatePetBar()
    self:TogglePetBar()

    self:UpdateStanceBar()
    self:ToggleStanceBar()
end

function ActionBars:PLAYER_ENTERING_WORLD()
    self:debug("PLAYER_ENTERING_WORLD")
    if not BT4 then return end
    
    self:TogglePetBar()
    self:ToggleStanceBar()
    self:ApplyABSettings()
    
    if EnteredWorld then return end
    
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    self:RefreshDoodads()
    
    ---[[
    BT4AB_EnableBar = function(self, id)
        self:debug("BT4AB_EnableBar", id)
        id = _G.tonumber(id)
        if id <= 5 and not _G.InCombatLockdown() then
            ActionBars:ApplyABSettings(id)
        end
    end
    --_G.hooksecurefunc(BT4ActionBars, "EnableBar", BT4AB_EnableBar)
    --]]
    
    EnteredWorld = true
end

function ActionBars:PLAYER_LOGIN()
    self:debug("PLAYER_LOGIN")
    if _G.IsAddOnLoaded("Bartender4") and BT4 then
        BT4 = _G.LibStub("AceAddon-3.0"):GetAddon("Bartender4", true)
        BT4Stance = BT4:GetModule("StanceBar", true)

        -- Font
        for i = 1, 120 do
            local button = _G["BT4Button"..i];
            if button then
                local name = button:GetName();
                local count = _G[name.."Count"];
                local hotkey = _G[name.."HotKey"];
                local macro = _G[name.."Name"];

                if count then
                    count:SetFont(RealUIFont_PixelSmall:GetFont())
                end
                hotkey:SetFont(RealUIFont_PixelSmall:GetFont())
                macro:SetFont(RealUIFont_PixelSmall:GetFont())
                macro:SetShadowColor(0, 0, 0, 0)
            end
        end
        local ExtraActionButton1 = _G.ExtraActionButton1
        if ExtraActionButton1 then
            _G.ExtraActionButton1HotKey:SetFont(RealUIFont_PixelSmall:GetFont())
            _G.ExtraActionButton1HotKey:SetPoint("TOPLEFT", ExtraActionButton1, "TOPLEFT", 1.5, -1.5)
            _G.ExtraActionButton1Count:SetFont(RealUIFont_PixelCooldown:GetFont())
            _G.ExtraActionButton1Count:SetPoint("BOTTOMRIGHT", ExtraActionButton1, "BOTTOMRIGHT", -2.5, 1.5)
        end
    end
end

function ActionBars:BarChatCommand()
    if not (BT4) then return end
    if not _G.InCombatLockdown() then
        nibRealUI:LoadConfig("HuD", "other", "actionbars")
    end
end

function ActionBars:OnInitialize()
    self:debug("OnInitialize")
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            showDoodads = true,
            [1] = {     -- DPS/Tank
                centerPositions = 2,    -- 1 top, 2 bottom
                sidePositions = 1,      -- 2 Right, 0 Left
                moveBars = {
                    stance = true,
                    pet = true,
                    eab = true,
                },
            },
            [2] = {     -- Healing
                centerPositions = 2,    -- 1 top, 2 bottom
                sidePositions = 1,      -- 2 Right, 0 Left
                moveBars = {
                    stance = true,
                    pet = true,
                    eab = true,
                },
            },
        },
    })
    db = self.db.profile
    ndb = nibRealUI.db.profile

    -- Migratre settings from ndb
    local abSettings = _G.nibRealUIDB.profiles.RealUI.actionBarSettings
    if abSettings then
        local function setSettings(newDB, oldDB)
            for setting, value in next, newDB do
                if _G.type(value) == "table" then
                    setSettings(value, oldDB and oldDB[setting])
                else
                    if oldDB and oldDB[setting] ~= nil then
                        newDB[setting] = oldDB[setting]
                    end
                end
            end
        end

        for i = 1, 2 do
            setSettings(db[i], abSettings[i])
        end
        abSettings = nil
    end

    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME) and (nibRealUI:DoesAddonMove("Bartender4") or nibRealUI:DoesAddonLayout("Bartender4")))
end

function ActionBars:OnEnable()
    BT4 = _G.LibStub("AceAddon-3.0"):GetAddon("Bartender4", true)
    self:debug("OnEnable", BT4)

    if EnteredWorld then
        self:debug("Post EnteredWorld")
        self:RefreshDoodads()
    elseif BT4 then
        self:debug("Pre EnteredWorld")
        BT4DB = _G.Bartender4DB
        BT4Profile = BT4DB["profileKeys"][nibRealUI.key]

        BT4Stance = BT4:GetModule("StanceBar", true)
        BT4ActionBars = BT4:GetModule("ActionBars", true)

        --self:RegisterEvent("PLAYER_LOGIN")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")

        
        BT4:UnregisterChatCommand("bar")
        BT4:UnregisterChatCommand("bt")
        BT4:UnregisterChatCommand("bt4")
        BT4:UnregisterChatCommand("bartender")
        BT4:UnregisterChatCommand("bartender4")

        self:RegisterChatCommand("bar", "BarChatCommand")
        self:RegisterChatCommand("bt", "BarChatCommand")
        self:RegisterChatCommand("bt4", "BarChatCommand")
        self:RegisterChatCommand("bartender", "BarChatCommand")
        self:RegisterChatCommand("bartender4", "BarChatCommand")

        -- Font
        for i = 1, 120 do
            local button = _G["BT4Button"..i];
            if button then
                local name = button:GetName();
                local count = _G[name.."Count"];
                local hotkey = _G[name.."HotKey"];
                local macro = _G[name.."Name"];

                if count then
                    count:SetFont(RealUIFont_PixelSmall:GetFont())
                end
                hotkey:SetFont(RealUIFont_PixelSmall:GetFont())
                macro:SetFont(RealUIFont_PixelSmall:GetFont())
                macro:SetShadowColor(0, 0, 0, 0)
            end
        end
        local ExtraActionButton1 = _G.ExtraActionButton1
        if ExtraActionButton1 then
            _G.ExtraActionButton1HotKey:SetFont(RealUIFont_PixelSmall:GetFont())
            _G.ExtraActionButton1HotKey:SetPoint("TOPLEFT", ExtraActionButton1, "TOPLEFT", 1.5, -1.5)
            _G.ExtraActionButton1Count:SetFont(RealUIFont_PixelCooldown:GetFont())
            _G.ExtraActionButton1Count:SetPoint("BOTTOMRIGHT", ExtraActionButton1, "BOTTOMRIGHT", -2.5, 1.5)
        end
    end
end

function ActionBars:OnDisable()
    self:debug("OnDisable")
    self:TogglePetBar()

    if BT4 then
        if BT4AB_EnableBar then
            BT4AB_EnableBar = _G.nop
        end

        self:UnregisterEvent("PLAYER_ENTERING_WORLD")

        self:UnregisterChatCommand("bar")
        self:UnregisterChatCommand("bt")
        self:UnregisterChatCommand("bt4")
        self:UnregisterChatCommand("bartender")
        self:UnregisterChatCommand("bartender4")

        BT4:RegisterChatCommand("bar", "ChatCommand")
        BT4:RegisterChatCommand("bt", "ChatCommand")
        BT4:RegisterChatCommand("bt4", "ChatCommand")
        BT4:RegisterChatCommand("bartender", "ChatCommand")
        BT4:RegisterChatCommand("bartender4", "ChatCommand")
    end
end
