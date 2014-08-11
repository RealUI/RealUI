local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "Map"
local Map = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

local strform = string.format

----------
function Map:SetMapStrata()
    WorldMapFrame:SetFrameStrata("HIGH")
    WorldMapFrame:SetFrameLevel(10)
    WorldMapDetailFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 1)
end

function Map:Event(...)
    print("Map:", ...)
    QuestInfoObjectivesFrame:GetRegions()
    local numObjectives = GetNumQuestLeaderBoards()
    local objective
    local text, type, finished
    local objectivesTable = QuestInfoObjectivesFrame.Objectives
    for i = 1, numObjectives do
        text, type, finished = GetQuestLogLeaderBoard(i)
        objective = objectivesTable[i]
        if ( finished ) then
            objective:SetTextColor(0.5, 0.5, 0.5)
        else
            objective:SetTextColor(1, 1, 1)
        end
    end
    QuestInfoRewardsFrame.Header:SetTextColor(1, 1, 1)
    QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(1, 1, 1)
    QuestInfoXPFrame.ReceiveText:SetTextColor(1, 1, 1)
end

function Map:Skin()
    print("Map:Skin")
    QuestMapFrame_Open()
    if not Aurora then return end
    local F = Aurora[1]
    
    local name = WorldMapFrame:GetName()

    WorldMapPlayerUpper:EnableMouse(false)
    WorldMapPlayerLower:EnableMouse(false)
    --local regions = WorldMapFrame:GetRegions()

    --_G[name.."Portrait"]:Hide()
    --_G[name.."PortraitFrame"]:Hide()
    _G[name.."TopLeftCorner"]:Hide()

    if not WorldMapFrame.skinned then
        --[[_G[name.."Bg"]:Hide()
        _G[name.."TitleBg"]:Hide()
        _G[name.."TopRightCorner"]:Hide()
        _G[name.."TopBorder"]:Hide()
        _G[name.."TopTileStreaks"]:SetTexture("")
        _G[name.."BotLeftCorner"]:Hide()
        _G[name.."BotRightCorner"]:Hide()
        _G[name.."BottomBorder"]:Hide()
        _G[name.."LeftBorder"]:Hide()
        _G[name.."RightBorder"]:Hide()

        F.CreateBD(WorldMapFrame.BorderFrame)
        F.ReskinClose(_G[name.."CloseButton"])

        F.ReskinMinMax(WorldMapFrameSizeUpButton, "Max", "TOPRIGHT", WorldMapFrame.BorderFrame, "TOPRIGHT", -26, -6)
        WorldMapFrame.BorderFrame.ButtonFrameEdge:Hide()
        
        --Map Inset
        WorldMapFrame.BorderFrame.InsetBorderTop:Hide()
        WorldMapFrame.BorderFrame.Inset.Bg:Hide()
        WorldMapFrame.BorderFrame.Inset:DisableDrawLayer("BORDER")]]

        --Buttons
        F.ReskinMinMax(WorldMapFrameSizeDownButton, "Min", "TOPRIGHT", WorldMapFrame.BorderFrame, "TOPRIGHT", -27, -6)
        QuestMapFrame.DetailsFrame.AbandonButton:ClearAllPoints()
        QuestMapFrame.DetailsFrame.AbandonButton:SetPoint("BOTTOMLEFT", -2, -2)
        QuestMapFrame.DetailsFrame.AbandonButton:SetWidth(96)
        QuestMapFrame.DetailsFrame.ShareButton:SetWidth(97)
        QuestMapFrame.DetailsFrame.TrackButton:SetWidth(96)


        --Nav Bar
        WorldMapFrameNavBar:ClearAllPoints()
        WorldMapFrameNavBar:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, "TOPLEFT", 1, 0)

        WorldMapFrame.skinned = true
    end

    if foglightmenu then
        foglightmenu:ClearAllPoints()
        foglightmenu:SetPoint("TOPRIGHT", WorldMapFrame.UIElementsFrame.TrackingOptionsButton.Button, "TOPLEFT", 10, 0)
        F.ReskinDropDown(foglightmenu)
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
function Map:SetMapSize()
    WorldMapFrame:SetParent(UIParent)

    if WorldMapFrame:GetAttribute("UIPanelLayout-area") ~= "center" then
        SetUIPanelAttribute(WorldMapFrame, "area", "center");
    end
    
    if WorldMapFrame:GetAttribute("UIPanelLayout-allowOtherPanels") ~= true then
        SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
    end
end

function Map:SetLargeWorldMap()
    if InCombatLockdown() then return end
    
    self:SetMapSize()
    --self:Skin()
end

function Map:SetQuestWorldMap()
    if InCombatLockdown() then return end
    
    self:SetMapSize()
    --self:Skin()
end

function Map:AdjustMapSize()
    if InCombatLockdown() then return end
    
    if WORLDMAP_SETTINGS.size ~= WORLDMAP_QUESTLIST_SIZE then
        WORLDMAP_SETTINGS.size = WORLDMAP_QUESTLIST_SIZE
    end
    self:SetQuestWorldMap()
    
    WorldMapFrame:SetFrameStrata("HIGH")
    WorldMapFrame:SetFrameLevel(3)
    WorldMapDetailFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 1)
end

function Map:ToggleTinyWorldMapSetting()
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

    -- 5.4.1 Taint fix
    --setfenv(WorldMapFrame_OnShow, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G }))
    
    self:SetMapStrata() 
    self:SetUpCoords()
    self:ToggleTinyWorldMapSetting()
    self:RegisterEvent("WORLD_MAP_UPDATE", "Event")
    self:RegisterEvent("QUEST_COMPLETE", "Event")
    self:RegisterEvent("QUEST_DETAIL", "Event")

    --WorldMapFrame:SetUserPlaced(true)
        
    WorldMapFrame:HookScript("OnShow", function()
        --print("WMF:OnShow", WORLDMAP_SETTINGS.size, GetCVarBool("miniWorldMap"))
        ticker = C_Timer.NewTicker(0.1, updateCoords)
        self:Skin()
        --[[Frame level
        if InCombatLockdown() then return end
        self:SetMapStrata()]]
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
