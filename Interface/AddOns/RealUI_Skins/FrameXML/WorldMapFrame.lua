local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Hook = Aurora.Hook
local Color = Aurora.Color

do --[[ FrameXML\WorldMapFrame.lua ]]
    local colorStr = Color.highlight.colorStr
    local round, ticker = _G.RealUI.Round

    local coordinateFormat = ("|c%s%s"):format(colorStr, "%s: |cffffffff%s, %s|r")
    local coordinateUnavailable = ("|c%s%s: |cffffffff%s|r"):format(colorStr, _G.PLAYER, _G.UNAVAILABLE)
    local function updateCoords(self)
        local coords = self._ruiCoords

        -- Player
        local playerX, playerY = _G.GetPlayerMapPosition("player")
        if (playerX and playerX > 0) and (playerY and playerY > 0) then
            playerX = round(100 * playerX, 1)
            playerY = round(100 * playerY, 1)

            coords.player:SetText(coordinateFormat:format(_G.PLAYER, playerX, playerY))
        else
            coords.player:SetText(coordinateUnavailable)
        end

        -- Mouse
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

    function Hook.WorldMapFrame_OnShow(self)
        ticker = _G.C_Timer.NewTicker(0.1, function(this, elapsed)
            updateCoords(self)
        end)
    end
    function Hook.WorldMapFrame_OnHide(self)
        ticker:Cancel()
    end
end

--[[ do FrameXML\WorldMapFrame.xml
end ]]

function private.FrameXML.Post.WorldMapFrame()
    _G.WorldMapFrame:HookScript("OnShow", Hook.WorldMapFrame_OnShow)
    _G.WorldMapFrame:HookScript("OnHide", Hook.WorldMapFrame_OnHide)

    local player = _G.WorldMapFrame:CreateFontString(nil, "OVERLAY")
    player:SetPoint("TOPLEFT", _G.WorldMapFrame, 40.5, -10.5)
    player:SetFontObject(_G.SystemFont_Shadow_Med1)
    player:SetJustifyH("LEFT")
    player:SetText("")

    local mouse = _G.WorldMapFrame:CreateFontString(nil, "OVERLAY")
    mouse:SetPoint("TOPLEFT", _G.WorldMapFrame, 160.5, -10.5)
    mouse:SetFontObject(_G.SystemFont_Shadow_Med1)
    mouse:SetJustifyH("LEFT")
    mouse:SetText("")

    _G.WorldMapFrame._ruiCoords = {
        player = player,
        mouse = mouse
    }
end
