local NAME, RealUI = ...

-- Lua Globals --
local _G = _G
local max, abs, floor = _G.math.max, _G.math.abs, _G.math.floor
local next, print, select = _G.next, _G.print, _G.select
local tostring, date = _G.tostring, _G.date

-- Libs --
local LTD = _G.LibStub("RealUI_LibTextDump-1.0")

-- RealUI --
_G.RealUI = RealUI


RealUI.media = {
    window =        {0.03, 0.03, 0.03, 0.9},
    background =    {0.085, 0.085, 0.085, 0.9},
    colors = {
        red =       {0.85, 0.14, 0.14, 1},
        orange =    {1.00, 0.38, 0.08, 1},
        amber =     {1.00, 0.64, 0.00, 1},
        yellow =    {1.00, 1.00, 0.15, 1},
        green =     {0.13, 0.90, 0.13, 1},
        cyan =      {0.11, 0.92, 0.72, 1},
        blue =      {0.15, 0.61, 1.00, 1},
        purple =    {0.70, 0.28, 1.00, 1},
    },
    textures = {
        plain =     [[Interface\AddOns\nibRealUI\Media\Plain.tga]],
        plain80 =   [[Interface\AddOns\nibRealUI\Media\Plain80.tga]],
        plain90 =   [[Interface\AddOns\nibRealUI\Media\Plain90.tga]],
        border =    [[Interface\AddOns\nibRealUI\Media\Plain.tga]],
    },
    icons = {
        DoubleArrow =   [[Interface\AddOns\nibRealUI\Media\Icons\DoubleArrow]],
        DoubleArrow2 =  [[Interface\AddOns\nibRealUI\Media\Icons\DoubleArrow2]],
        Lightning =     [[Interface\AddOns\nibRealUI\Media\Icons\Lightning]],
        Cross =         [[Interface\AddOns\nibRealUI\Media\Icons\Cross]],
        Flame =         [[Interface\AddOns\nibRealUI\Media\Icons\Flame]],
        Heart =         [[Interface\AddOns\nibRealUI\Media\Icons\Heart]],
        PersonPlus =    [[Interface\AddOns\nibRealUI\Media\Icons\PersonPlus]],
        Shield =        [[Interface\AddOns\nibRealUI\Media\Icons\Shield]],
        Sword =         [[Interface\AddOns\nibRealUI\Media\Icons\Sword]],
    },
}

local defaults = {
    stripeOpacity = 0.5,
}

local debugger = {}
local function CreateDebugFrame(mod)
    if debugger[mod] then
        return
    end
    local function save(buffer)
        _G.RealUI_Debug[mod] = buffer
    end
    debugger[mod] = LTD:New(("%s Debug Output"):format(mod), 640, 473, save)
    debugger[mod].numDuped = 1
    debugger[mod].prevLine = ""
    return debugger[mod]
end

local function Debug(mod, ...)
    local modDebug = debugger[mod]
    if not modDebug then
        modDebug = CreateDebugFrame(mod)
    end
    local text = mod
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        text = text .. "     " .. tostring(arg)
    end
    if modDebug.prevLine == text then
        modDebug.numDuped = modDebug.numDuped + 1
    else
        if modDebug.numDuped > 1 then
            modDebug:AddLine(("^^ Repeated %d times ^^"):format(modDebug.numDuped))
            modDebug.numDuped = 1
        end
        local time = date("%H:%M:%S")
        modDebug:AddLine(("[%s] %s"):format(time, text))
        modDebug.prevLine = text
    end
end
RealUI.Debug = Debug
function RealUI.GetDebug(mod)
    return function (...)
        Debug(mod, ...)
    end
end
local function debug(...)
    Debug("Init", ...)
end

-- Slash Commands
_G.SLASH_REALUIINIT1 = "/realdebug"
function _G.SlashCmdList.REALUIINIT(mod, editBox)
    print("/realdebug", mod, editBox)
    if mod == "" then
        -- TODO: Make this show a frame w/ buttons to specific debugs
        for k, v in next, debugger do
            print(k, debugger[k]:Lines())
        end
    else
        local modDebug = debugger[mod]
        if not modDebug then
            modDebug = CreateDebugFrame(mod)
        end
        if mod == "test" then
            print("Generating test...")
            for i = 1, 100 do
                modDebug:AddLine("Test line "..i.." WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW")
                --modDebug:AddLine("Test line "..i)
            end
        end
        if modDebug:Lines() == 0 then
            modDebug:AddLine("Nothing to report.")
            modDebug:Display()
            modDebug:Clear()
            return
        end
        modDebug:Display()
    end
end

local f = _G.CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UI_SCALE_CHANGED")
f:SetScript("OnEvent", function(self, event, addon)
    if event == "PLAYER_LOGIN" then
        -- Do stuff at login
        f:UnregisterEvent("PLAYER_LOGIN")
        --f:UnregisterEvent("ADDON_LOADED")
    elseif event == "UI_SCALE_CHANGED" then
        local scrHeight = _G.GetScreenHeight()
        scrHeight = floor(scrHeight + 0.5)
        debug("scrHeight", scrHeight)
        local EM = scrHeight * 0.0125
        debug("EM", EM, RealUI.EM)

        if not RealUI.EM then
            debug("Set EM")
            RealUI.EM = EM
        elseif EM ~= RealUI.EM then
            debug("Recalc EM")
        end
    elseif event == "ADDON_LOADED" then
        if addon == NAME then
            _G.RealUI_InitDB = _G.RealUI_InitDB or defaults
            _G.RealUI_Debug = {}
        elseif addon == "!Aurora_RealUI" then
            -- Create Aurora namespace incase Aurora is disabled
            local Aurora = {{},{}}
            _G.Aurora = Aurora
            local F = Aurora[1] -- F, functions
            local C = Aurora[2] -- C, constants/config

            -- Setup __index to catch other addons using functions if Aurora is disabled.
            -- This way I don't have to add the entire API.
            _G.setmetatable(F, {__index = function(table, key)
                debug("Aurora: __index", key, table)
                if not _G.rawget(table, key) then
                    table[key] = function(...)
                        debug("Aurora: function:", key, "args:", ...)
                    end
                    return table[key]
                end
            end})

            F.dummy = function() end

            -- load RealUI overrides into Aurora namespace
            local auroraStyle = _G.AURORA_CUSTOM_STYLE

            for name, func in next, auroraStyle.functions do
                if auroraStyle.copy[name] then
                    F[name] = func
                --else
                    --F[name] = F.dummy
                end
            end

            if auroraStyle.classcolors then
                C.classcolours = auroraStyle.classcolors
                local _, class = _G.UnitClass("player")

                local r, g, b = C.classcolours[class].r, C.classcolours[class].g, C.classcolours[class].b
                C.r, C.g, C.b = r, g, b
            end

            auroraStyle.initVars()
        --elseif addon == "nibRealUI" then
        end
    end
end)

-- Modified from Blizzard's DrawRouteLine
--local lineFactor = _G.TAXIROUTE_LINEFACTOR_2 --(32/20) / 2

function RealUI:DrawLine(T, C, sx, sy, ex, ey, w, relPoint)
    if (not relPoint) then relPoint = "BOTTOMLEFT" end

    T:SetTexture([[Interface\AddOns\nibRealUI_Init\textures\line]])

    -- Determine dimensions and center point of line
    local dx, dy = ex - sx, ey - sy
    --debug("Init", DrawLine: dx, ", dx, ", dy, ", dy)
    local cx, cy = (sx + ex) / 2, (sy + ey) / 2
    --debug("Init", "DrawLine: cx, ", cx, ", cy, ", cy)

    -- Normalize direction if necessary
    if (dx < 0) then
        dx,dy = -dx,-dy
    end

    -- Calculate actual length of line
    local l = _G.sqrt((dx * dx) + (dy * dy))

    -- Quick escape if it's zero length
    if (l == 0) then
        T:SetTexCoord(0,0,0,0,0,0,0,0)
        T:SetPoint("BOTTOMLEFT", C, relPoint, cx,cy)
        T:SetPoint("TOPRIGHT",   C, relPoint, cx,cy)
        return
    end

    -- Sin and Cosine of rotation, and combination (for later)
    local s,c = -dy / l, dx / l
    local sc = s * c

    -- Calculate bounding box size and texture coordinates
    local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy
    if (dy >= 0) then
        Bwid = cx - sx --((l * c) - (w * s)) * lineFactor
        Bhgt = cy - sy --((w * c) - (l * s)) * lineFactor
        BLx, BLy, BRy = (w / l) * sc, s * s, (l / w) * sc
        BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx
        TRy = BRx
    else
        Bwid = cx - sx --((l * c) + (w * s)) * lineFactor
        Bhgt = -(cy - sy) --((w * c) + (l * s)) * lineFactor
        BLx, BLy, BRx = s * s, -(l / w) * sc, 1 + (w / l) * sc
        BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy
        TRx = TLy
    end
    --debug("Init", "DrawLine: Bwid, ", Bwid, ", Bhgt, ", Bhgt)
    --debug("Init", "DrawLine: TOPRIGHT", cx + Bwid, cy + Bhgt)
    --debug("Init", "DrawLine: BOTTOMLEFT", cx - Bwid, cy - Bhgt)

    -- Set texture coordinates and anchors
    T:ClearAllPoints()
    T:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy)
    T:SetPoint("TOPRIGHT",   C, relPoint, cx + Bwid, cy + Bhgt)
    T:SetPoint("BOTTOMLEFT", C, relPoint, cx - Bwid, cy - Bhgt)
end

-- Math
RealUI.Round = function(value, places)
    local mult = 10 ^ (places or 0)
    return floor(value * mult + 0.5) / mult
end

function RealUI:GetSafeVals(vCur, vMax)
    local percent
    if vCur > 0 and vMax == 0 then
        vMax = vCur
        percent = 0.00000000000001
    elseif vCur == 0 and vMax == 0 then
        percent = 0.00000000000001
    elseif (vCur < 0) or (vMax < 0) then
        vCur = abs(vCur)
        vMax = abs(vMax)
        vMax = max(vCur, vMax)
        percent = vCur / vMax
    else
        percent = vCur / vMax
    end
    return percent, vCur, vMax
end

-- Colors
function RealUI:ColorTableToStr(vals)
    return _G.format("%02x%02x%02x", vals[1] * 255, vals[2] * 255, vals[3] * 255)
end

function RealUI:GetDurabilityColor(percent)
    if percent < 0 then
        return 1, 0, 0
    elseif percent <= 0.5 then
        return 1, percent * 2, 0
    elseif percent >= 1 then
        return 0, 1, 0
    else
        return 2 - percent * 2, 1, 0
    end
end
