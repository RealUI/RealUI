local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Hook = Aurora.Hook
local Color = Aurora.Color

local HBD --= _G.LibStub("HereBeDragons-2.0")

do --[[ AddOns\Blizzard_WorldMap.lua ]]
    local colorStr = Color.highlight.colorStr
    local round, ticker = _G.RealUI.Round

    local coordinateFormat = ("|c%s%s"):format(colorStr, "%s: |cffffffff%s, %s|r")
    local coordinateUnavailable = ("|c%s%s: |cffffffff%s|r"):format(colorStr, _G.PLAYER, _G.UNAVAILABLE)
    local function updateCoords(self)
        local coords = self._ruiCoords
        if not HBD then
            if private.isPatch then
                HBD = _G.LibStub("HereBeDragons-2.0")
            else
                HBD = _G.LibStub("HereBeDragons-1.0")
            end
        end

        -- Player
        local playerX, playerY = HBD:GetPlayerZonePosition()
        if playerX and playerY then
            playerX = round(100 * playerX, 1)
            playerY = round(100 * playerY, 1)

            coords.player:SetText(coordinateFormat:format(_G.PLAYER, playerX, playerY))
        else
            coords.player:SetText(coordinateUnavailable)
        end

        -- Mouse
        if private.isPatch then
            if self.ScrollContainer:IsMouseOver() then
                local cursorX, cursorY = self:GetNormalizedCursorPosition()

                cursorX = round(100 * cursorX, 1)
                cursorY = round(100 * cursorY, 1)
                coords.mouse:SetText(coordinateFormat:format(_G.MOUSE_LABEL, cursorX, cursorY))
            else
                coords.mouse:SetText("")
            end
        else
            if _G.WorldMapScrollFrame:IsMouseOver() then
                local scale = _G.WorldMapDetailFrame:GetEffectiveScale()
                local width, height = _G.WorldMapDetailFrame:GetSize()
                local centerX, centerY = _G.WorldMapDetailFrame:GetCenter()
                local cursorX, cursorY = _G.GetCursorPosition()
                local adjustedX = (cursorX / scale - (centerX - width / 2)) / width
                local adjustedY = ((centerY + height / 2) - cursorY / scale) / height

                adjustedX = round(100 * adjustedX, 1)
                adjustedY = round(100 * adjustedY, 1)
                coords.mouse:SetText(coordinateFormat:format(_G.MOUSE_LABEL, adjustedX, adjustedY))
            else
                coords.mouse:SetText("")
            end
        end
    end

    function Hook.WorldMapMixin_OnShow(self)
        ticker = _G.C_Timer.NewTicker(0.1, function(this, elapsed)
            updateCoords(self)
        end)
    end
    function Hook.WorldMapMixin_OnHide(self)
        ticker:Cancel()
    end
end

--[[ do AddOns\Blizzard_WorldMap.xml
end ]]

function private.AddOns.Post.Blizzard_WorldMap()
    local WorldMapFrame = _G.WorldMapFrame
    WorldMapFrame:HookScript("OnShow", Hook.WorldMapMixin_OnShow)
    WorldMapFrame:HookScript("OnHide", Hook.WorldMapMixin_OnHide)

    local player = WorldMapFrame.BorderFrame:CreateFontString(nil, "OVERLAY")
    if private.isPatch then
        player:SetPoint("LEFT", WorldMapFrame.BorderFrame.TitleText, 40, 0)
    else
        player:SetPoint("TOPLEFT", 40.5, -10.5)
    end
    player:SetFontObject(_G.SystemFont_Shadow_Med1)
    player:SetJustifyH("LEFT")
    player:SetText("")

    local mouse = WorldMapFrame.BorderFrame:CreateFontString(nil, "OVERLAY")
    if private.isPatch then
        mouse:SetPoint("LEFT", WorldMapFrame.BorderFrame.TitleText, 160, 0)
    else
        mouse:SetPoint("TOPLEFT", 160.5, -10.5)
    end
    mouse:SetFontObject(_G.SystemFont_Shadow_Med1)
    mouse:SetJustifyH("LEFT")
    mouse:SetText("")

    WorldMapFrame._ruiCoords = {
        player = player,
        mouse = mouse
    }
end

function private.FrameXML.Post.WorldMapFrame()
    if not private.isPatch then
        private.AddOns.Post.Blizzard_WorldMap()
    end
end
