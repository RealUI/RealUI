local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local ticker, _
local MODNAME = "Map"
local Map = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

----------
function Map:Skin()
    --print("Map:Skin")
    WorldMapPlayerUpper:EnableMouse(false)
    WorldMapPlayerLower:EnableMouse(false)

    if not WorldMapFrame.skinned then
        WorldMapFrame:SetUserPlaced(true)
        local trackingBtn = WorldMapFrame.UIElementsFrame.TrackingOptionsButton

        --Buttons
        WorldMapLevelDropDown:ClearAllPoints()
        WorldMapLevelDropDown:SetPoint("TOPLEFT", WorldMapFrame.UIElementsFrame, -15, 3)
        trackingBtn:ClearAllPoints()
        trackingBtn:SetPoint("TOPRIGHT", WorldMapFrame.UIElementsFrame, 3, 3)

        --Foglight
        if foglightmenu and Aurora then
            local F = Aurora[1]
            foglightmenu:ClearAllPoints()
            foglightmenu:SetPoint("TOPRIGHT", trackingBtn, "TOPLEFT", 20, 0)
            F.ReskinDropDown(foglightmenu)
        end
        WorldMapFrame.skinned = true
    end
end

-- Coordinate Display --
local classColorStr
local function updateCoords(self, elapsed)
    --print("Map:UpdateCoords")
    if not classColorStr then classColorStr = nibRealUI:ColorTableToStr(nibRealUI.classColor) end
    
    -- Player
    local x, y = GetPlayerMapPosition("player")
    x = nibRealUI:Round(100 * x, 1)
    y = nibRealUI:Round(100 * y, 1)
    
    if x ~= 0 and y ~= 0 then
        Map.coords.player:SetText(string.format("|cff%s%s: |cffffffff%s, %s|r", classColorStr, PLAYER, x, y))
    else
        Map.coords.player:SetText("")
    end
    
    -- Mouse
    local scale = WorldMapDetailFrame:GetEffectiveScale()
    local width = WorldMapDetailFrame:GetWidth()
    local height = WorldMapDetailFrame:GetHeight()
    local centerX, centerY = WorldMapDetailFrame:GetCenter()
    local x, y = GetCursorPosition()
    local adjustedX = (x / scale - (centerX - (width/2))) / width
    local adjustedY = (centerY + (height/2) - y / scale) / height   

    if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
        adjustedX = nibRealUI:Round(100 * adjustedX, 1)
        adjustedY = nibRealUI:Round(100 * adjustedY, 1)
        Map.coords.mouse:SetText(string.format("|cff%s%s: |cffffffff%s, %s|r", classColorStr, MOUSE_LABEL, adjustedX, adjustedY))
    else
        Map.coords.mouse:SetText("")
    end
end

function Map:SetUpCoords()
    self.coords = CreateFrame("Frame", nil, WorldMapFrame)
    
    self.coords:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1)
    self.coords:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())
    
    self.coords.player = self.coords:CreateFontString(nil, "OVERLAY")
    self.coords.player:SetPoint("BOTTOMLEFT", WorldMapFrame.UIElementsFrame, "BOTTOMLEFT", 4.5, 4.5)
    self.coords.player:SetFont(unpack(nibRealUI.font.pixel1))
    self.coords.player:SetText("")
    
    self.coords.mouse = self.coords:CreateFontString(nil, "OVERLAY")
    self.coords.mouse:SetPoint("BOTTOMLEFT", WorldMapFrame.UIElementsFrame, "BOTTOMLEFT", 120.5, 4.5)
    self.coords.mouse:SetFont(unpack(nibRealUI.font.pixel1))
    self.coords.mouse:SetText("")
end

-- Size Adjust --
function Map:SetLargeWorldMap()
    print("Map:SetLargeWorldMap")
    if InCombatLockdown() then return end
    
    -- reparent
    WorldMapFrame:SetParent(UIParent)
    WorldMapFrame:SetFrameStrata("HIGH")
    WorldMapFrame:EnableKeyboard(true)

    --reposition
    WorldMapFrame:ClearAllPoints()
    WorldMapFrame:SetPoint("CENTER", 0, 0)
    SetUIPanelAttribute(WorldMapFrame, "area", "center")
    SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
    WorldMapFrame:SetSize(1022, 766)
end

function Map:SetQuestWorldMap()
    if InCombatLockdown() then return end
    
    WorldMapFrameNavBar:SetPoint("TOPLEFT", WorldMapFrame.BorderFrame, 3, -33)
    WorldMapFrameNavBar:SetWidth(700)
end

function Map:SetUpSizes()
    if InCombatLockdown() then return end
    
    BlackoutWorld:SetTexture(nil)
    
    QuestMapFrame_Hide()
    if GetCVar("questLogOpen") == 1 then
        QuestMapFrame_Show()
    end

    self:SecureHook("WorldMap_ToggleSizeUp", "SetLargeWorldMap")
    self:SecureHook("WorldMap_ToggleSizeDown", "SetQuestWorldMap")
    
    if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
        WorldMap_ToggleSizeUp()
    elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
        WorldMap_ToggleSizeDown()
    end
end

----------

function Map:OnInitialize()
    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterSkin(MODNAME, "World Map")
end

function Map:OnEnable()
    if IsAddOnLoaded("Mapster") or IsAddOnLoaded("m_Map") or IsAddOnLoaded("MetaMap") then return end
    
    self:SetUpCoords()
    self:SetUpSizes()

    --WorldMapFrame:SetUserPlaced(true)
        
    WorldMapFrame:HookScript("OnShow", function()
        --print("WMF:OnShow", WORLDMAP_SETTINGS.size, GetCVarBool("miniWorldMap"))
        ticker = C_Timer.NewTicker(0.1, updateCoords)
        self:Skin(WORLDMAP_SETTINGS.size)
    end)
    WorldMapFrame:HookScript("OnHide", function()
        --print("WMF:OnHide")
        ticker:Cancel()
    end)

    DropDownList1:HookScript("OnShow", function(self)
        if DropDownList1:GetScale() ~= UIParent:GetScale() then
            DropDownList1:SetScale(UIParent:GetScale())
        end     
    end)
    
end
