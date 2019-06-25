local _, private = ...

-- Lua Globals --
-- luacheck: globals next

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("MiniPatch")

RealUI.minipatches = {
    [0] = function()
        debug("patch 0")
        for profileName, profile in next, _G.nibRealUIDB.profiles do
            if profile.media and profile.media.font then
                profile.media.font = nil
            end
        end

        if _G.nibRealUIDB.global.retinaDisplay then
            _G.nibRealUIDB.global.retinaDisplay = nil
        end

        if _G.nibRealUIDB.namespaces.UIScaler then
            _G.nibRealUIDB.namespaces.UIScaler = nil
        end
    end,
    [12] = function()
        debug("patch 12")
        for profileName, profile in next, _G.nibRealUIDB.profiles do
            local CastBarsDB = _G.nibRealUIDB.namespaces.CastBars.profiles and _G.nibRealUIDB.namespaces.CastBars.profiles[profileName]
            if CastBarsDB then
                local hudSize = profile.settings and profile.settings.hudSize or 2
                CastBarsDB.player = CastBarsDB.player or {}
                CastBarsDB.player = CastBarsDB.player or {}

                local layout = private.profileToLayout[profileName] or 1
                local positions = profile.positions and profile.positions[layout]
                local defaultPositions = RealUI.defaultPositions[layout]

                if positions then
                    local positionerX, positionerY
                    local castbarX, castbarY

                    -- Player
                    positionerX = -2 + (positions.CastBarPlayerX or defaultPositions.CastBarPlayerX)
                    castbarX = positionerX - (230 / 2)

                    positionerY = -130 + (positions.CastBarPlayerY or defaultPositions.CastBarPlayerY) + RealUI.hudSizeOffsets[hudSize].CastBarPlayerY
                    positionerY = positionerY + (positions.HuDY or defaultPositions.HuDY)
                    castbarY = positionerY - (8 / 2)

                    CastBarsDB.player.position.x = castbarX
                    CastBarsDB.player.position.y = castbarY
                    CastBarsDB.player.position.point = "CENTER"

                    -- Target
                    positionerX = -2 + (positions.CastBarTargetX or defaultPositions.CastBarTargetX)
                    castbarX = positionerX - (230 / 2)

                    positionerY = -130 + (positions.CastBarTargetY or defaultPositions.CastBarTargetY) + RealUI.hudSizeOffsets[hudSize].CastBarTargetY
                    positionerY = positionerY + (positions.HuDY or defaultPositions.HuDY)
                    castbarY = positionerY - (8 / 2)

                    CastBarsDB.target.position.x = castbarX
                    CastBarsDB.target.position.y = castbarY
                    CastBarsDB.target.position.point = "CENTER"
                end

                if CastBarsDB.reverse then
                    CastBarsDB.player.reverse = CastBarsDB.reverse.player
                    CastBarsDB.target.reverse = CastBarsDB.reverse.target
                    CastBarsDB.reverse = nil
                end

                if CastBarsDB.text then
                    local point
                    if CastBarsDB.text.textOnBottom == false then
                        point = "TOP"
                    else
                        point = "BOTTOM"
                    end

                    if CastBarsDB.text.textInside == false then
                        CastBarsDB.player.text = point .. "LEFT"
                        CastBarsDB.target.text = point .. "RIGHT"
                    else
                        CastBarsDB.player.text = point .. "RIGHT"
                        CastBarsDB.target.text = point .. "LEFT"
                    end
                    CastBarsDB.text = nil
                end
            end
        end
        --F()
    end,
    [99] = function() -- test patch
        debug("patch 99")
    end,
}
