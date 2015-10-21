local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local ndb, db

local MODNAME = "ActionBars"
local ActionBars = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0")

local EnteredWorld = false
local Bar4, Bar4Stance, Bar4Profile

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
    if not IsAddOnLoaded("Bartender4") then return end
    if not nibRealUICharacter then return end
    if nibRealUICharacter.installStage ~= -1 then return end



    -- Bar Settings
    if not(nibRealUI:DoesAddonMove("Bartender4")) then return end
    if InCombatLockdown() then return end


    local prof = nibRealUI.cLayout == 1 and "RealUI" or "RealUI-Healing"
    if not(Bar4 and Bartender4DB and Bartender4DB["namespaces"]["ActionBars"]["profiles"][prof]) then return end

    local barSettings = db[nibRealUI.cLayout]

    local topBars, numTopBars, bottomBars, sidePositions
    if not tag then
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
        local BarPoints = {}
        local BarPositions = {}
        local padding = fixedSettings.padding
        local centerPadding = padding / 2
        local BarPadding = {top = {}, bottom = {}, sides = {}}
        for i = 1, 5 do
            local BTBar = _G["BT4Bar"..i]
            if BTBar and not BTBar.disabled then
                ----
                -- Calculate Width/Height of bars and their corresponding Left/Top points
                ----
                local isVertBar = i > 3
                local isRightBar = isVertBar and sidePositions[i] == "RIGHT"
                local isLeftBar = isVertBar and not(isRightBar)
                local isTopBar = not(isVertBar) and topBars[i] == true
                local isBottomBar = not(isVertBar) and not(isTopBar)
                ActionBars:debug("Stats", isVertBar, isRightBar, isLeftBar, isTopBar, isBottomBar)

                local numButtons = BTBar.numbuttons
                BarSizes[i] = (buttonSizes.bars * numButtons) + (padding * (numButtons - 1))

                -- Create Padding table
                if isTopBar then
                    BarPadding.top[i] = padding
                elseif isBottomBar then
                    BarPadding.bottom[i] = padding
                else
                    BarPadding.sides[i] = padding
                end

                ----
                -- Calculate bars X and Y positions
                ----
                local x, y

                -- Side Bars
                if isVertBar then
                    x = isRightBar and -36 or -8

                    if sidePositions[4] == sidePositions[5] then
                        -- Link Side Bar settings
                        if i == 4 then
                            y = BarSizes[4] + BarPadding.sides[4] + 10.5
                        else
                            y = 10.5
                        end
                    else
                        y = (BarSizes[i] / 2) + 10
                        if not(IsOdd(BarPadding.sides[i])) or IsOdd(numButtons) then y = y + 0.5 end
                    end

                    BarPositions[i] = sidePositions[i]

                -- Top/Bottom Bars
                else
                    x = -((BarSizes[i] / 2) + 10)
                    -- if IsOdd(numButtons) then x = x + 0.5 end

                    -- Extra on X for pixel perfection
                    if isTopBar then
                        if not(IsOdd(BarPadding.top[i])) or IsOdd(numButtons) then x = x + 0.5 end
                    else
                        if not(IsOdd(BarPadding.bottom[i])) or IsOdd(numButtons) then x = x + 0.5 end
                    end

                    -- Bar Place
                    local barPlace
                    if i == 1 then
                        if numTopBars > 0 then
                            barPlace = 1
                        else
                            barPlace = 3 - numTopBars   -- Want Bottom Bars stacking Top->Down
                        end

                    elseif i == 2 then
                        barPlace = 2

                    elseif i == 3 then
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
                            local padding = ceil(centerPadding + centerPadding)
                            y = -(buttonSizes.bars + padding) + HuDY + ABY
                        else
                            local padding = ceil(centerPadding + centerPadding)
                            y = buttonSizes.bars + padding + 37
                        end
                    else
                        local padding = ceil(centerPadding + (centerPadding * 2) + centerPadding)
                        if isTopBar then
                            y = -((buttonSizes.bars * 2) + padding) + HuDY + ABY
                        else
                            y = (buttonSizes.bars * 2) + padding + 37
                        end
                    end

                    BarPositions[i] = isTopBar and "TOP" or "BOTTOM"
                end

                BarPoints[i] = {
                    x = x,
                    y = y
                }
            end
        end

        -- Profile Data
        local profileActionBars = Bartender4DB["namespaces"]["ActionBars"]["profiles"][prof]
        if profileActionBars["actionbars"] then
            for i = 1, 5 do
                local bar, point = profileActionBars["actionbars"][i]
                if i <= 3 then
                    point = BarPositions[i] == "TOP" and "CENTER" or "BOTTOM"
                else
                    point = BarPositions[i]
                end

                bar["position"] = {
                    ["x"] = BarPoints[i].x,
                    ["y"] = BarPoints[i].y,
                    ["point"] = point,
                    ["scale"] = 1,
                    ["growHorizontal"] = "RIGHT",
                    ["growVertical"] = "DOWN",
                }
                bar["padding"] = fixedSettings.padding - 10

                if i < 4 then
                    bar["flyoutDirection"] = sidePositions[i] == "UP"
                else
                    bar["flyoutDirection"] = sidePositions[i] == "LEFT" and "RIGHT" or "LEFT"
                end
            end
        end
        local B4Bars = Bar4:GetModule("ActionBars", true)
        if B4Bars then B4Bars:ApplyConfig() end
        for i = 1, 5 do
            if B4Bars.actionbars[i] then
                B4Bars.actionbars[i].SetButtons(B4Bars.actionbars[i])
            end
        end

        ----
        -- Vehicle Bar
        ----
        local vbX, vbY = -36, -59.5

        -- Set Position
        local profileVehicle = Bartender4DB["namespaces"]["Vehicle"]["profiles"][prof]
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
        local B4Vehicle = Bar4:GetModule("Vehicle", true)
        if B4Vehicle then B4Vehicle:ApplyConfig() end

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
                    pbX = buttonSizes.bars + ceil((BarPadding.sides[4] * 2) + (pbP / 2)) - 9
                elseif (sidePositions[5] == "LEFT") then
                    pbX = buttonSizes.bars + ceil((BarPadding.sides[5] * 2) + (pbP / 2)) - 9
                else
                    pbX = ceil(pbP / 2) - 9
                end

                -- Calculate Y
                pbY = (pbH / 2) + 10

                -- Set Position
                local profilePetBar = Bartender4DB["namespaces"]["PetBar"]["profiles"][prof]
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
                local B4PetBar = Bar4:GetModule("PetBar", true)
                if B4PetBar then B4PetBar:ApplyConfig() end
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
                eabX = max(BarSizes[2], BarSizes[3]) / 2 - 4
            end

            local profileEAB = Bartender4DB["namespaces"]["ExtraActionBar"]["profiles"][prof]
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
            local B4EAB = Bar4:GetModule("ExtraActionBar", true)
            if B4EAB then B4EAB:ApplyConfig() end
        end
    end

    -- Stance Bar
    if barSettings.moveBars.stance then
        local B4Stance = Bar4:GetModule("StanceBar", true)
        local NumStances = GetNumShapeshiftForms()
        if NumStances > 0 then
            if B4Stance and not(B4Stance:IsEnabled()) then B4Stance:Enable() end

            local sbX, sbY

            if ndb.settings.fontStyle == 3 then
                sbX = -286
                sbY = 28
            else
                sbX = -264
                sbY = 27
            end

            -- Set Position
            local profileStanceBar = Bartender4DB["namespaces"]["StanceBar"]["profiles"][prof]
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
            if B4Stance then B4Stance:ApplyConfig() end
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

    if ( Bar4Stance and Bar4Stance:IsEnabled() and nibRealUI:DoesAddonMove("Bartender4") and db[nibRealUI.cLayout].moveBars.stance and db.showDoodads and not UnitInVehicle("player")) then
        Doodads.stance:Show()
    else
        Doodads.stance:Hide()
    end
end

function ActionBars:UpdateStanceBar()
    ActionBars:debug("UpdatePetBar Check", Doodads.pet, nibRealUI:DoesAddonMove("Bartender4"), db[nibRealUI.cLayout].moveBars.pet)
    if not (Doodads.stance and Bar4Stance and nibRealUI:DoesAddonMove("Bartender4") and db[nibRealUI.cLayout].moveBars.stance) then return end
    ActionBars:debug("UpdateStanceBar")

    -- Color
    -- Doodads.stance.sides:SetVertexColor(unpack(nibRealUI.classColor))
    Doodads.stance.sides:SetVertexColor(0.5, 0.5, 0.5)
    
    -- Size/Position
    local Bar4Profile = Bartender4DB["profileKeys"][nibRealUI.key]
    local NumStances = GetNumShapeshiftForms()
    local sbP = 1--db[nibRealUI.cLayout].stanceBar.padding
    local sbW = (NumStances * 22) + ((NumStances - 1) * sbP)
    local sbX = Bartender4DB["namespaces"]["StanceBar"]["profiles"][Bar4Profile]["position"]["x"] - floor((sbW / 2)) + 11.5

    Doodads.stance:ClearAllPoints()
    Doodads.stance:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", floor(sbX) - 2, -6)
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
    
    if ( nibRealUI:DoesAddonMove("Bartender4") and db[nibRealUI.cLayout].moveBars.pet and db.showDoodads and (UnitExists("pet") and not UnitInVehicle("player")) ) then
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
    Doodads.pet.sides:SetVertexColor(unpack(nibRealUI.classColor))
    
    -- Size/Position
    local Bar4Profile = Bartender4DB["profileKeys"][nibRealUI.key]
    local pbX = Bartender4DB["namespaces"]["PetBar"]["profiles"][Bar4Profile]["position"]["x"]
    local pbA = Bartender4DB["namespaces"]["PetBar"]["profiles"][Bar4Profile]["position"]["point"]
    Doodads.pet:ClearAllPoints()
    Doodads.pet:SetPoint(pbA, "UIParent", pbA, floor(pbX) + 3, 3)

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
    Doodads.pet = CreateFrame("Frame", "RealUIActionBarDoodadsPet", UIParent)
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
    Doodads.stance = CreateFrame("Frame", "RealUIActionBarDoodadsStance", UIParent)
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
    if not (nibRealUI:GetModuleEnabled(MODNAME) and Bar4) then return end
    ActionBars:debug("RefreshDoodads")
    db = self.db.profile
    
    if not Doodads.pet then self:CreateDoodads() end

    self:UpdatePetBar()
    self:TogglePetBar()

    self:UpdateStanceBar()
    self:ToggleStanceBar()
end

function ActionBars:PLAYER_ENTERING_WORLD()
    if not Bar4 then return end
    
    self:TogglePetBar()
    self:ToggleStanceBar()
    self:ApplyABSettings()
    
    if EnteredWorld then return end
    
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    self:RefreshDoodads()
    
    EnteredWorld = true
end

function ActionBars:PLAYER_LOGIN()
    if IsAddOnLoaded("Bartender4") and Bartender4 then
        Bar4 = LibStub("AceAddon-3.0"):GetAddon("Bartender4", true)
        Bar4Stance = Bar4:GetModule("StanceBar", true)

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
        if ExtraActionButton1 then
            ExtraActionButton1HotKey:SetFont(RealUIFont_PixelSmall:GetFont())
            ExtraActionButton1HotKey:SetPoint("TOPLEFT", ExtraActionButton1, "TOPLEFT", 1.5, -1.5)
            ExtraActionButton1Count:SetFont(RealUIFont_PixelCooldown:GetFont())
            ExtraActionButton1Count:SetPoint("BOTTOMRIGHT", ExtraActionButton1, "BOTTOMRIGHT", -2.5, 1.5)
        end
    end
end

function ActionBars:BarChatCommand()
    if not (Bartender4) then return end
    if not InCombatLockdown() then
        nibRealUI:LoadConfig("HuD", "other", "actionbars")
    end
end

function ActionBars:OnInitialize()
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
    local abSettings = nibRealUIDB.profiles.RealUI.actionBarSettings
    if abSettings then
        local function setSettings(newDB, oldDB)
            for setting, value in next, newDB do
                if type(value) == "table" then
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

    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
end

local BT4_EnableBar
function ActionBars:OnEnable()
    if not (Bartender4) then return end
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    BT4_EnableBar = BT4ActionBars.EnableBar
    BT4ActionBars.EnableBar = function(id)
        id = tonumber(id)
        BT4_EnableBar(id)
        if id <= 5 then
            ActionBars:ApplyABSettings()
        end
    end
    
    Bartender4:UnregisterChatCommand("bar")
    Bartender4:UnregisterChatCommand("bt")
    Bartender4:UnregisterChatCommand("bt4")
    Bartender4:UnregisterChatCommand("bartender")
    Bartender4:UnregisterChatCommand("bartender4")

    self:RegisterChatCommand("bar", "BarChatCommand")
    self:RegisterChatCommand("bt", "BarChatCommand")
    self:RegisterChatCommand("bt4", "BarChatCommand")
    self:RegisterChatCommand("bartender", "BarChatCommand")
    self:RegisterChatCommand("bartender4", "BarChatCommand")

    if EnteredWorld then
        self:RefreshDoodads()
    end
end

function ActionBars:OnDisable()
    self:TogglePetBar()

    if BT4_EnableBar then
        BT4ActionBars.EnableBar = BT4_EnableBar
    end

    self:UnregisterChatCommand("bar")
    self:UnregisterChatCommand("bt")
    self:UnregisterChatCommand("bt4")
    self:UnregisterChatCommand("bartender")
    self:UnregisterChatCommand("bartender4")

    Bartender4:RegisterChatCommand("bar", "ChatCommand")
    Bartender4:RegisterChatCommand("bt", "ChatCommand")
    Bartender4:RegisterChatCommand("bt4", "ChatCommand")
    Bartender4:RegisterChatCommand("bartender", "ChatCommand")
    Bartender4:RegisterChatCommand("bartender4", "ChatCommand")
end
