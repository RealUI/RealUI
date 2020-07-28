local _, private = ...

-- Lua Globals --
-- luacheck: globals wipe tinsert

-- RealUI --
local RealUI = private.RealUI

local Aurora = _G.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin

local fa = _G.LibStub("LibIconFonts-1.0"):GetIconFont("FontAwesome-4.7")
local icons = _G.LibStub("LibSharedMedia-3.0"):Fetch("font", "Font Awesome")
local arrows = _G.LibStub("LibSharedMedia-3.0"):Fetch("font", "DejaVu Sans")
local normal = _G.LibStub("LibSharedMedia-3.0"):Fetch("font", "Roboto")

local keySize = 24
local gapSmall = RealUI.Round(keySize * 0.1)
local gapMed = RealUI.Round(keySize * 0.6)
local gapLarge = RealUI.Round(keySize * 1.2)

local bindings = {}
local keys = {
    -- Row 1
        {
            x = 10,
            y = -10
        },

        {
            x = gapLarge,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },

        {
            x = gapMed,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },

        {
            x = gapMed,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },

        {
            x = gapMed,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },


    -- Row 2
        {
            newRow = true,
            x = 0,
            y = -gapMed
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 2.1
        },

        {
            x = gapMed,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },

        {
            x = gapMed,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },


    -- Row 3
        {
            newRow = true,
            x = 0,
            y = -gapSmall,
            widthMult = 1.55
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 1.55
        },


        {
            x = gapMed,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },


        {
            x = gapMed,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0,
            heightMult = 2.1
        },


    -- Row 4
        {
            newRow = true,
            x = 0,
            y = -gapSmall,
            widthMult = 1.85
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 2.35
        },


        {
            x = RealUI.Round(keySize * 4.35),
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },


    -- Row 5
        {
            newRow = true,
            x = 0,
            y = -gapSmall,
            widthMult = 2.39
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 2.89
        },

        {
            x = RealUI.Round(keySize * 1.65),
            y = 0
        },

        {
            x = RealUI.Round(keySize * 1.65),
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },

        {
            x = gapSmall,
            y = 0,
            heightMult = 2.1
        },


    -- Row 6
        {
            newRow = true,
            x = 0,
            y = -gapSmall,
            widthMult = 1.3
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 1.3
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 1.3
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 6.55
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 1.3
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 1.3
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 1.3
        },
        {
            x = gapSmall,
            y = 0,
            widthMult = 1.3
        },

        {
            x = gapMed,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },
        {
            x = gapSmall,
            y = 0
        },

        {
            x = gapMed,
            y = 0,
            widthMult = 2.1
        },
        {
            x = gapSmall,
            y = 0
        },
}
local modKeys = {"ALT","CTRL","SHIFT","ALT-CTRL","ALT-SHIFT","CTRL-SHIFT","ALT-CTRL-SHIFT"}
local qwerty = {
    "ESCAPE|Esc", "F1","F2","F3","F4", "F5","F6","F7","F8", "F9","F10","F11","F12", "PRINTSCREEN|print","SCROLLLOCK|⇳","PAUSE|pause",
    "`","1","2","3","4","5","6","7","8","9","0","-","=","BACKSPACE|←", "INSERT|terminal", "HOME|⇤", "PAGEUP|↑", "NUMLOCK|⇫", "NUMPADDIVIDE|/", "NUMPADMULTIPLY|*", "NUMPADMINUS|-",
    "TAB|↹","Q","W","E","R","T","Y","U","I","O","P","[","]","\\","DELETE|→","END|⇥","PAGEDOWN|↓","NUMPAD7|7","NUMPAD8|8","NUMPAD9|9","NUMPADPLUS|+",
    "CAPSLOCK_KEY_TEXT|⇪","A","S","D","F","G","H","J","K","L",";","'","ENTER|↵","NUMPAD4|4","NUMPAD5|5","NUMPAD6|6",
    "hidden|SHIFT","Z","X","C","V","B","N","M",",",".","/","hidden|SHIFT","UP|▴","NUMPAD1|1","NUMPAD2|2","NUMPAD3|3","ENTER|↲",
    "hidden|CTRL","hidden|OS","hidden|ALT","SPACE","hidden|ALT","hidden|OS","hidden|App","hidden|CTRL","LEFT|◂","DOWN|▾","RIGHT|▸","NUMPAD0|0","NUMPADDECIMAL|.",
}

local keyIcons = {
    PRINTSCREEN = 12,
    SCROLLLOCK = 16,
    PAUSE = 12,

    BACKSPACE = 20,
    INSERT = 12,
    HOME = 20,
    PAGEUP = 20,
    NUMLOCK = 18,

    TAB = 16,
    DELETE = 20,
    END = 20,
    PAGEDOWN = 20,

    CAPSLOCK_KEY_TEXT = 20,
    UP = 16,
    ENTER = 20,

    LEFT = 16,
    DOWN = 16,
    RIGHT = 16,
}

-- GetBindingKey("BONUSACTIONBUTTON1")
-- GetBindingText("CTRL-1", true)
local function KeyOnEnter(self)
    local binding = bindings[self.index]

    _G.GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    _G.GameTooltip_SetTitle(_G.GameTooltip, binding.primary)
    for i = 1, #modKeys do
        if binding[modKeys[i]] then
            _G.GameTooltip_AddNormalLine(_G.GameTooltip, binding[modKeys[i]])
        end
    end

    _G.GameTooltip:Show()
end
local function KeyOnLeave(self)
    _G.GameTooltip:Hide()
end
local bindingsFrame
local function CreateKeyButton(index, info)
    local widthMult = info.widthMult or 1
    local heightMult = info.heightMult or 1

    local button = _G.CreateFrame("Button", nil, bindingsFrame)
    Skin.FrameTypeButton(button)

    button:SetSize(RealUI.Round(keySize * widthMult), RealUI.Round(keySize * heightMult))
    button:SetScript("OnEnter", KeyOnEnter)
    button:SetScript("OnLeave", KeyOnLeave)

    local font, size = normal, 12
    local binding, fontStr = bindings[index]
    if keyIcons[binding.key] then
        if fa[binding.text] then
            font = icons
            binding.text = fa[binding.text]
        else
            font = arrows
        end

        size = keyIcons[binding.key]
    end

    fontStr = button:CreateFontString(nil, "ARTWORK")
    fontStr:SetFont(font, size)
    fontStr:SetShadowColor(0, 0, 0)
    fontStr:SetShadowOffset(1, -1)
    fontStr:SetAllPoints()
    button.text = fontStr

    _G.C_Timer.After(0, function()
        fontStr:SetText(binding.text)
    end)

    if binding.key == "hidden" then
        button:Hide()
    end

    button.index = index
    bindingsFrame[index] = button
    return button
end

local function UpdateFrame()
    for index = 1, #keys do
        local button = bindingsFrame[index]

        if bindings[index].hasAction then
            button:LockHighlight()
        else
            button:UnlockHighlight()
        end
    end
end

local function CreateKeys()
    bindingsFrame = _G.CreateFrame("Frame", nil, _G.KeyBindingFrame)
    bindingsFrame:SetPoint("TOPLEFT", _G.KeyBindingFrame, "BOTTOMLEFT", 100, 0)
    bindingsFrame:SetSize(614, 186)
    Base.SetBackdrop(bindingsFrame)

    local lastRow = 1
    for index = 1, #keys do
        local info = keys[index]
        local button = CreateKeyButton(index, info)

        if index == 1 then
            button:SetPoint("TOPLEFT", info.x, info.y)
        else
            if info.newRow then
                button:SetPoint("TOPLEFT", bindingsFrame[lastRow], "BOTTOMLEFT", info.x, info.y)
                lastRow = index
            else
                button:SetPoint("TOPLEFT", bindingsFrame[index - 1], "TOPRIGHT", info.x, info.y)
            end
        end
    end

    UpdateFrame()
end

local function GetKeyText(key)
    local bindText = _G.GetBindingText(key)
    if bindText == key and _G[key] then
        bindText = _G[key]
    end

    return bindText
end

local actionFormat = "|cFFFFFFFF%s:|r %s"
local function UpdateBindings()
    wipe(bindings)
    for index = 1, #keys do
        local key, text = ("|"):split(qwerty[index])
        local bindText = GetKeyText(key)

        local binding = {
            key = key,
            text = text or bindText,
            bindText = bindText
        }


        local hasAction = false
        local action = _G.GetBindingAction(key)
        if action and action ~= "" then
            binding.primary = actionFormat:format(bindText, _G.GetBindingName(action))
            hasAction =  true
        else
            binding.primary = actionFormat:format(bindText, _G.NOT_BOUND)
        end
        for i = 1, #modKeys do
            local modKey = modKeys[i].."-"..key
            action = _G.GetBindingAction(modKey)
            if (action and action ~= "") then
                bindText = GetKeyText(modKey)
                binding[modKeys[i]] = actionFormat:format(bindText, _G.GetBindingName(action))
                hasAction =  true
            end
        end
        binding.hasAction = hasAction

        tinsert(bindings, binding)
    end

    if bindingsFrame then
        UpdateFrame()
    end
end


RealUI:GetModule("InterfaceTweaks"):AddTweak("bindings", {
    name = "BindingsReminder",
    addon = "Blizzard_BindingUI",
    onLoad = function( ... )
        UpdateBindings()
        CreateKeys()
    end,
    event = "UPDATE_BINDINGS",
    func = UpdateBindings
}, true)
