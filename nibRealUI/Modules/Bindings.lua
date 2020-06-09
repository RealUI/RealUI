local _, private = ...

-- Lua Globals --
-- luacheck: globals wipe tinsert

-- RealUI --
local RealUI = private.RealUI

local Aurora = _G.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin

local fa = _G.LibStub("LibIconFonts-1.0"):GetIconFont("FontAwesome-4.7")
fa.path = _G.LibStub("LibSharedMedia-3.0"):Fetch("font", "Font Awesome")

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
    "ESCAPE|Esc", "F1","F2","F3","F4", "F5","F6","F7","F8", "F9","F10","F11","F12", "PRINTSCREEN|Prt","SCROLLLOCK|SL","PAUSE|Pau",
    "`","1","2","3","4","5","6","7","8","9","0","-","=","BACKSPACE|long-arrow-left", "INSERT|Ins", "HOME|HM", "PAGEUP|UP", "NUMLOCK|NL", "NUMPADDIVIDE|/", "NUMPADMULTIPLY|*", "NUMPADMINUS|-",
    "TAB","Q","W","E","R","T","Y","U","I","O","P","[","]","\\","DELETE|Del","END","PAGEDOWN|DN","NUMPAD7|7","NUMPAD8|8","NUMPAD9|9","NUMPADPLUS|+",
    _G.CAPSLOCK_KEY_TEXT,"A","S","D","F","G","H","J","K","L",";","'","ENTER","NUMPAD4|4","NUMPAD5|5","NUMPAD6|6",
    _G.SHIFT_KEY_TEXT,"Z","X","C","V","B","N","M",",",".","/",_G.SHIFT_KEY_TEXT,"UP|arrow-up","NUMPAD1|1","NUMPAD2|2","NUMPAD3|3","ENTER|↵",
    _G.CTRL_KEY_TEXT,"OS",_G.ALT_KEY_TEXT,"SPACE",_G.ALT_KEY_TEXT,"OS","App",_G.CTRL_KEY_TEXT,"LEFT|arrow-left","DOWN|arrow-down","RIGHT|arrow-right","NUMPAD0|0","NUMPADDECIMAL|.",
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

    local binding, fontStr = bindings[index]
    if binding.text == "OS" then
        if _G.IsWindowsClient() then
            binding.text = "windows"
        elseif _G.IsMacClient() then
            binding.text = "apple"
        else
            binding.text = "linux"
        end
    end

    if fa[binding.text] then
        fontStr = button:CreateFontString(nil, "ARTWORK")
        fontStr:SetFont(fa.path, 12)
        binding.text = fa[binding.text]
    else
        fontStr = button:CreateFontString(nil, "ARTWORK", "SystemFont_Shadow_Med1")
    end

    fontStr:SetAllPoints()
    button:SetFontString(fontStr)
    button:SetText(binding.text)

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

local actionFormat = "|cFFFFFFFF%s:|r %s"
local function UpdateBindings()
    wipe(bindings)
    for index = 1, #keys do
        local key, text = ("|"):split(qwerty[index])
        local bindText = _G.GetBindingText(key)

        local binding = {
            key = key,
            text = text or bindText,
            bindText = bindText
        }


        local hasAction = false
        local action = _G.GetBindingAction(key)
        if action and action ~= "" then
            binding.primary = actionFormat:format(bindText, _G["BINDING_NAME_"..action])
            hasAction =  true
        else
            binding.primary = actionFormat:format(bindText, _G.NOT_BOUND)
        end
        for i = 1, #modKeys do
            local modKey = modKeys[i].."-"..key
            action = _G.GetBindingAction(modKey)
            if (action and action ~= "") then
                bindText = _G.GetBindingText(modKey)
                binding[modKeys[i]] = actionFormat:format(bindText, _G["BINDING_NAME_"..action])
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
