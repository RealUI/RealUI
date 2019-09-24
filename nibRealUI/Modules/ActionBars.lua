local _, private = ...

-- Lua Globals --
-- luacheck: globals math

-- Libs --
local BT4, BT4DB, BT4Profile
local BT4ActionBars, BT4AB_EnableBar, BT4Stance, BT4Pet

-- RealUI --
local RealUI = private.RealUI
local db, ndb, ndbc

local MODNAME = "ActionBars"
local ActionBars = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0")

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
    bt4Padding = 11,
    buttonPadding = 1,
    buttons = 12,
    petButtons = 10
}
local function IsOdd(val)
    return val % 2 == 1
end
function ActionBars:ApplyABSettings(tag)
    if not ndbc then return end
    if ndbc.init.installStage ~= -1 or not RealUI:DoesAddonMove("Bartender4") then return end

    local prof = RealUI.cLayout == 1 and "RealUI" or "RealUI-Healing"
    if not(BT4 and BT4DB and BT4DB["namespaces"]["ActionBars"]["profiles"][prof]) then return end

    local barSettings = db[RealUI.cLayout]
    local numTopBars = barSettings.centerPositions - 1
    local padding = fixedSettings.buttonPadding

    local sidePositions
    if barSettings.sidePositions == 1 then
        sidePositions = {[4] = "RIGHT", [5] = "RIGHT"}
    elseif barSettings.sidePositions == 2 then
        sidePositions = {[4] = "RIGHT", [5] = "LEFT"}
    else
        sidePositions = {[4] = "LEFT", [5] = "LEFT"}
    end


    local BarSizes = {}
    local centerPadding = padding / 2
    local BarPadding = {top = {}, bottom = {}, sides = {}}
    for id = 1, 5 do
        ActionBars:debug(id, "Calculate points")
        local BTBar = BT4ActionBars.actionbars[id]
        if BTBar and not BTBar.disabled then
            ----
            -- Calculate Width/Height of bars and their corresponding Left/Top points
            ----
            local isVertBar = id > 3
            local isRightBar = isVertBar and sidePositions[id] == "RIGHT"
            local isLeftBar = isVertBar and not(isRightBar)
            local isTopBar = not(isVertBar) and id <= numTopBars
            local isBottomBar = not(isVertBar) and not(isTopBar)
            ActionBars:debug(id, "Stats", isTopBar, isBottomBar, isLeftBar, isRightBar)

            local numButtons = BTBar.numbuttons or BTBar.button_count
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
                ActionBars:debug(id, "barPlace", barPlace)

                -- y Offset
                local topYOfs = ndb.positions[RealUI.cLayout]["HuDY"] + ndb.positions[RealUI.cLayout]["ActionBarsY"] + RealUI.hudSizeOffsets[ndb.settings.hudSize]["ActionBarsY"]
                local bottomYOfs = ndb.positions[RealUI.cLayout]["ActionBarsBotY"] + buttonSizes.bars + fixedSettings.bt4Padding
                ActionBars:debug(id, "Y Offset", topYOfs, bottomYOfs)
                if barPlace == 1 then
                    if isTopBar then
                        y = topYOfs
                    else
                        y = bottomYOfs
                    end
                elseif barPlace == 2 then
                        local pad = math.ceil(centerPadding + centerPadding)
                    if isTopBar then
                        y = -(buttonSizes.bars + pad) + topYOfs
                    else
                        y = buttonSizes.bars + pad + bottomYOfs
                    end
                else
                    local pad = math.ceil(centerPadding + (centerPadding * 2) + centerPadding)
                    if isTopBar then
                        y = -((buttonSizes.bars * 2) + pad) + topYOfs
                    else
                        y = (buttonSizes.bars * 2) + pad + bottomYOfs
                    end
                end

                BarPositions[id] = isTopBar and "TOP" or "BOTTOM"
            end

            local profileActionBars = BT4DB["namespaces"]["ActionBars"]["profiles"][prof]
            local bar, point = profileActionBars["actionbars"][id]
            if isVertBar then
                point = BarPositions[id]
                bar["flyoutDirection"] = sidePositions[id] == "LEFT" and "RIGHT" or "LEFT"
            else
                point = BarPositions[id] == "TOP" and "CENTER" or "BOTTOM"
                bar["flyoutDirection"] = BarPositions[id] == "TOP" and "DOWN" or "UP"
            end

            ActionBars:debug(id, "Points", x, y, point)
            bar["padding"] = fixedSettings.buttonPadding - 10
            bar["position"] = {
                ["x"] = x,
                ["y"] = y,
                ["point"] = point,
                ["scale"] = 1,
                ["growHorizontal"] = "RIGHT",
                ["growVertical"] = "DOWN",
            }

            BTBar:SetButtons()
        else
            BarSizes[id] = 0
        end
    end
    if BT4ActionBars then BT4ActionBars:ApplyConfig() end

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
        -- if RealUI.cLayout == 1 then
            local numPetBarButtons = 10
            local pbX, pbY
            local pbP = fixedSettings.buttonPadding
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

        -- Calculate X, Y
        eabX = _G.max(BarSizes[2], BarSizes[3]) / 2 - 4
        eabY = ndb.positions[RealUI.cLayout]["ActionBarsBotY"] + 61

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

        local profileZAB = BT4DB["namespaces"]["ZoneAbilityBar"]["profiles"][prof]
        if profileZAB then
            profileZAB["position"] = {
                ["y"] = eabY,
                ["x"] = -(eabX + 64),
                ["point"] = "BOTTOM",
                ["scale"] = 0.985,
                ["growHorizontal"] = "RIGHT",
                ["growVertical"] = "DOWN",
            }
        end
        local BT4ZAB = BT4:GetModule("ZoneAbilityBar", true)
        if BT4ZAB then BT4ZAB:ApplyConfig() end
    end

    -- Stance Bar
    if barSettings.moveBars.stance then
        local NumStances = _G.GetNumShapeshiftForms()
        if NumStances > 0 then
            if BT4Stance and not(BT4Stance:IsEnabled()) then BT4Stance:Enable() end

            local sbX = -(_G.max(BarSizes[2], BarSizes[3]) / 2 - 4)
            local sbY = ndb.positions[RealUI.cLayout]["ActionBarsBotY"] + buttonSizes.stanceBar + fixedSettings.bt4Padding

            -- Set Position
            local profileStanceBar = BT4DB["namespaces"]["StanceBar"]["profiles"][prof]
            if profileStanceBar then
                profileStanceBar["position"] = {
                    ["x"] = sbX,
                    ["y"] = sbY,
                    ["point"] = "BOTTOM",
                    ["scale"] = 1,
                    ["growHorizontal"] = "LEFT",
                    ["growVertical"] = "DOWN"
                }
            end
            if BT4Stance then BT4Stance:ApplyConfig() end
        end
    end

    -- ActionBars
    if RealUI:GetModuleEnabled(MODNAME) then
        self:RefreshDoodads()
    end
end

----
-- Doodad functions
----
local function CreateDoodad(doodad, parent)
    ActionBars:debug("CreateDoodad", doodad)
    local bar = _G.CreateFrame("Frame", "RealUIActionBarDoodads"..doodad, _G.UIParent)
    Doodads[doodad] = bar

    bar:SetFrameStrata("LOW")
    bar:SetHeight(32)
    bar:SetWidth(32)

    bar.texture = bar:CreateTexture(nil, "ARTWORK")
    bar.texture:SetAllPoints(bar)
    bar.texture:SetTexture(Textures.stanceBar.center)

    bar.parent = parent

    bar:Hide()
end

function ActionBars:UpdateDoodadVisibility(doodadType)
    if not Doodads[doodadType] then return end
    ActionBars:debug("UpdateDoodadVisibility", doodadType)

    local doodad = Doodads[doodadType]
    if db.showDoodads and doodad:ShouldShow() then
        ActionBars:debug("Show doodad")
        doodad:Show()
    else
        ActionBars:debug("Hide doodad")
        doodad:Hide()
    end
end

function ActionBars:UpdateDoodadPosition(doodadType)
    if not db.showDoodads then return end
    ActionBars:debug("UpdateDoodadPosition", doodadType)

    local barName = doodadType.."Bar"
    local bar = _G["BT4Bar"..barName]
    local numbuttons = #bar.buttons
    local numRows = bar:GetRows()
    local buttonsPerRow = math.ceil(numbuttons / numRows) -- just a precaution
    numRows = math.ceil(numbuttons / buttonsPerRow)
    if numRows > numbuttons then
        numRows = numbuttons
        buttonsPerRow = 1
    end

    local barWidth = buttonsPerRow * buttonSizes.petBar + (buttonsPerRow - 1)
    local barHeight = numRows * buttonSizes.petBar + (numRows - 1)
    local barX = RealUI.Round((barWidth + fixedSettings.bt4Padding) / 2) - 0.5
    local barY = RealUI.Round((barHeight + fixedSettings.bt4Padding) / 2) - 0.5

    local growH = BT4DB.namespaces[barName].profiles[BT4Profile].position.growHorizontal
    if growH == "LEFT" then
        barX = -barX
    end

    local growV = BT4DB.namespaces[barName].profiles[BT4Profile].position.growVertical
    if growV == "DOWN" then
        barY = -barY
    end

    local doodad = Doodads[doodadType]
    doodad:ClearAllPoints()
    doodad:SetPoint("CENTER", doodad.parent, barX, barY)
end

----
-- Frame Creation
----
function ActionBars:RefreshDoodads(doodadType)
    if not (RealUI:GetModuleEnabled(MODNAME) and BT4) then return end
    ActionBars:debug("RefreshDoodads", doodadType)
    db = self.db.profile

    if (BT4Pet and BT4Pet:IsEnabled()) or doodadType == "Pet" then
        ActionBars:debug("RefreshPet")
        if not Doodads.Pet then
            CreateDoodad("Pet", _G.BT4BarPetBar)
            function Doodads.Pet:ShouldShow()
                return _G.UnitExists("pet") and not _G.UnitInVehicle("player")
            end
        end
        self:UpdateDoodadPosition("Pet")
        self:UpdateDoodadVisibility("Pet")
    end

    if (BT4Stance and BT4Stance:IsEnabled()) or doodadType == "Stance" then
        ActionBars:debug("RefreshStance")
        if not Doodads.Stance then
            CreateDoodad("Stance", _G.BT4BarStanceBar)
            function Doodads.Stance:ShouldShow()
                return not _G.UnitInVehicle("player")
            end
        end
        self:UpdateDoodadPosition("Stance")
        self:UpdateDoodadVisibility("Stance")
    end
end

function ActionBars:PLAYER_ENTERING_WORLD()
    self:debug("PLAYER_ENTERING_WORLD")
    if not BT4 then return end

    self:ApplyABSettings()

    if EnteredWorld then return end

    self:RegisterEvent("UNIT_PET", function()
        self:RefreshDoodads("Pet")
    end)
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", function()
        self:RefreshDoodads("Stance")
    end)

    ---[[
    BT4AB_EnableBar = function(BT4AB, id)
        self:debug("BT4AB_EnableBar", id)
        id = _G.tonumber(id)
        if id <= 5 and not _G.InCombatLockdown() then
            ActionBars:ApplyABSettings(id)
        end
    end
    --_G.hooksecurefunc(BT4ActionBars, "EnableBar", BT4AB_EnableBar)
    --]]
    _G.hooksecurefunc(_G.BT4BarStanceBar, "UpdateButtonLayout", function()
        self:UpdateDoodadVisibility("Stance")
    end)
    _G.hooksecurefunc(_G.BT4BarPetBar, "UpdateButtonLayout", function()
        self:UpdateDoodadVisibility("Pet")
    end)

    EnteredWorld = true
end

function ActionBars:BarChatCommand()
    if not (BT4) then return end
    if not _G.InCombatLockdown() then
        RealUI.Debug("Config", "/bt")
        RealUI.LoadConfig("HuD", "other", "actionbars")
    end
end

function ActionBars:RefreshMod()
    db = self.db.profile
    ndb = RealUI.db.profile
    ndbc = RealUI.db.char

    self:RefreshDoodads()
    self:ApplyABSettings()
end

function ActionBars:OnProfileUpdate(...)
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME) and RealUI:DoesAddonMove("Bartender4"))
    self:RefreshMod()
end

function ActionBars:OnInitialize()
    self:debug("OnInitialize")
    self.db = RealUI.db:RegisterNamespace(MODNAME)
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
    ndb = RealUI.db.profile
    ndbc = RealUI.db.char

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME) and RealUI:DoesAddonMove("Bartender4"))
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
        BT4Profile = BT4DB["profileKeys"][RealUI.key]

        BT4Stance = BT4:GetModule("StanceBar", true)
        BT4Pet = BT4:GetModule("PetBar", true)
        BT4ActionBars = BT4:GetModule("ActionBars", true)

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
