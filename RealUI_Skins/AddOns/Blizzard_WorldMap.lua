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
            HBD = _G.LibStub("HereBeDragons-2.0")
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
        if self.ScrollContainer:IsMouseOver() then
            local cursorX, cursorY = self:GetNormalizedCursorPosition()

            cursorX = round(100 * cursorX, 1)
            cursorY = round(100 * cursorY, 1)
            coords.mouse:SetText(coordinateFormat:format(_G.MOUSE_LABEL, cursorX, cursorY))
        else
            coords.mouse:SetText("")
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

_G.hooksecurefunc(private.AddOns, "Blizzard_WorldMap", function()
    local WorldMapFrame = _G.WorldMapFrame
    WorldMapFrame:HookScript("OnShow", Hook.WorldMapMixin_OnShow)
    WorldMapFrame:HookScript("OnHide", Hook.WorldMapMixin_OnHide)

    local player = WorldMapFrame.BorderFrame:CreateFontString(nil, "OVERLAY")
    player:SetPoint("LEFT", WorldMapFrame.BorderFrame.TitleText, 40, 0)
    player:SetFontObject(_G.SystemFont_Shadow_Med1)
    player:SetJustifyH("LEFT")
    player:SetText("")

    local mouse = WorldMapFrame.BorderFrame:CreateFontString(nil, "OVERLAY")
    mouse:SetPoint("LEFT", WorldMapFrame.BorderFrame.TitleText, 160, 0)
    mouse:SetFontObject(_G.SystemFont_Shadow_Med1)
    mouse:SetJustifyH("LEFT")
    mouse:SetText("")

    WorldMapFrame._ruiCoords = {
        player = player,
        mouse = mouse
    }
end)
