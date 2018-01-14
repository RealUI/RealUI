local loaded, finished = _G.IsAddOnLoaded("nibRealUI_Dev")
if loaded and finished then
    _G.print("RealUI_Init loaded via Dev")
    return
end

local _, RealUI = ...

-- Lua Globals --
local max, abs, floor = _G.math.max, _G.math.abs, _G.math.floor
local next, print, select = _G.next, _G.print, _G.select
local tostring = _G.tostring

-- Libs --
local LTD = _G.LibStub("LibTextDump-1.0")

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
    uiModScale = 1,
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
    debugger[mod].numDuped = 0
    debugger[mod].prevLine = ""
    return debugger[mod]
end

local function Debug(mod, ...)
    local modDebug = debugger[mod]
    if not modDebug then
        modDebug = CreateDebugFrame(mod)
    end
    local text = ""
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        text = text .. tostring(arg) .. "     "
    end
    if modDebug.prevLine == text then
        modDebug.numDuped = modDebug.numDuped + 1
    else
        if modDebug.numDuped > 0 then
            modDebug:AddLine(("^^ Repeated %d times ^^"):format(modDebug.numDuped))
            modDebug.numDuped = 0
        end
        modDebug:AddLine(text, "%H:%M:%S")
        modDebug.prevLine = text
    end
end
RealUI.Debug = Debug
function RealUI.GetDebug(mod)
    return function (...)
        return Debug(mod, ...)
    end
end
local function debug(...)
    return Debug("Init", ...)
end

local uiMod, pixelScale
local function UpdateUIScale()
    local pysWidth, pysHeight = _G.GetPhysicalScreenSize()
    debug("physical size", pysWidth, pysHeight)

    pixelScale = 768 / pysHeight
    uiMod = (pysHeight / 768) * _G.RealUI_InitDB.uiModScale
    debug("uiMod", uiMod)
end

function RealUI.ModValue(value, getFloat)
    return RealUI.Round(value * uiMod, getFloat and 2 or 0)
end

local previewFrames = {}
function RealUI.RegisterModdedFrame(frame, updateFunc)
    -- Frames that are sized via ModValue become HUGE with retina scale.
    local customScale, isRetina = RealUI:GetUIScale()
    if isRetina then
        return frame:SetScale(customScale)
    elseif customScale > pixelScale then
        return frame:SetScale(pixelScale)
    end

    if updateFunc then
        previewFrames[frame] = updateFunc
    end
end
function RealUI.PreviewModScale()
    UpdateUIScale()
    for frame, func in next, previewFrames do
        func(frame)
    end
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
    elseif event == "ADDON_LOADED" then
        if addon == "nibRealUI_Init" then
            debug("nibRealUI_Init: loaded", uiMod)
            _G.RealUI_InitDB = _G.RealUI_InitDB or {}
            _G.RealUI_Debug = {}

            -- load or init variables
            for key, value in next, defaults do
                if _G.RealUI_InitDB[key] == nil then
                    if _G.type(value) == "table" then
                        _G.RealUI_InitDB[key] = {}
                        for k, v in next, value do
                            _G.RealUI_InitDB[key][k] = value[k]
                        end
                    else
                        _G.RealUI_InitDB[key] = value
                    end
                end
            end

            UpdateUIScale()
        elseif addon == "!Aurora_RealUI" then
            local F, C = _G.Aurora[1], _G.Aurora[2]
            if not (F and C) then
                -- Create Aurora namespace since Aurora is disabled
                local Aurora = {{},{}}
                _G.Aurora = Aurora
                F = Aurora[1] -- F, functions
                C = Aurora[2] -- C, constants/config

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
            end

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

function RealUI.GetDurabilityColor(a, b)
    if a and b then
        debug("RGBColorGradient", a, b)
        return _G.oUFembed.RGBColorGradient(a, b, 0.9,0.1,0.1, 0.9,0.9,0.1, 0.1,0.9,0.1)
    else
        debug("GetDurabilityColor", a)
        if a < 0 then
            return 1, 0, 0
        elseif a <= 0.5 then
            return 1, a * 2, 0
        elseif a >= 1 then
            return 0, 1, 0
        else
            return 2 - a * 2, 1, 0
        end
    end
end
