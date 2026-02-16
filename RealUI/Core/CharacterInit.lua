local _, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs _G

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("CharacterInit")

-- Character Initialization System
-- Handles character-specific setup, role-based defaults, and chat frame positioning

local CharacterInit = {}
RealUI.CharacterInit = CharacterInit

-- Get player role based on specialization
local function GetPlayerRole()
    local spec = _G.GetSpecialization()
    if not spec then
        return "DPS" -- Default to DPS if no spec
    end

    local role = _G.GetSpecializationRole(spec)

    if role == "HEALER" then
        return "HEALER"
    elseif role == "TANK" then
        return "TANK"
    else
        return "DPS"
    end
end

-- Initialize character-specific configuration
function CharacterInit:Initialize()
    if not RealUI.db then
        return false
    end

    -- Ensure character data structure exists
    if not RealUI.db.char then
        RealUI.db.char = {}
    end

    local charData = RealUI.db.char

    -- Initialize character init data
    if not charData.init then
        charData.init = {
            installStage = 0,
            initialized = false,
            needchatmoved = true
        }
    end

    -- Initialize layout data
    if not charData.layout then
        charData.layout = {
            current = 1,
            spec = {}
        }
    end

    debug("Character data initialized")
    return true
end

-- Apply default settings based on character role
function CharacterInit:ApplyRoleDefaults()
    if not RealUI.db then
        return
    end

    local role = GetPlayerRole()
    local charData = RealUI.db.char

    if not charData or not charData.layout then
        return
    end

    -- Set default layout based on role
    if role == "HEALER" then
        charData.layout.current = 2 -- Healing layout
        debug("Applied HEALER defaults - Layout 2")
    else
        charData.layout.current = 1 -- DPS/Tank layout
        debug("Applied", role, "defaults - Layout 1")
    end

    -- Store spec-specific layout preferences
    local spec = _G.GetSpecialization()
    if spec then
        charData.layout.spec[spec] = charData.layout.current
    end

    -- Update layout manager if available
    if RealUI.LayoutManager then
        RealUI.LayoutManager:SwitchToLayout(charData.layout.current)
    end
end

-- Setup chat frame positioning
function CharacterInit:SetupChatFrames()
    if not RealUI.db or not RealUI.db.char then
        return
    end

    local charData = RealUI.db.char

    -- Check if chat frames need to be positioned
    if not charData.init or not charData.init.needchatmoved then
        return
    end

    -- Position chat frames based on layout
    local layout = charData.layout and charData.layout.current or 1

    -- Get default chat frame
    local chatFrame = _G.ChatFrame1
    if not chatFrame then
        return
    end

    -- Clear any existing points
    chatFrame:ClearAllPoints()

    -- Position based on layout
    if layout == 1 then
        -- DPS/Tank layout - bottom left
        chatFrame:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", 6, 32)
    else
        -- Healing layout - adjusted for raid frames
        chatFrame:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", 6, 52)
    end

    -- Set chat frame size
    chatFrame:SetFrameLevel(15)
    chatFrame:SetHeight(145)
    chatFrame:SetWidth(400)
    chatFrame:SetUserPlaced(true)
    _G.FCF_SavePositionAndDimensions(chatFrame)

    -- Mark chat as moved
    charData.init.needchatmoved = false

    debug("Chat frames positioned for layout", layout)
end

-- Complete character initialization
function CharacterInit:Complete()
    if not RealUI.db or not RealUI.db.char then
        return
    end

    local charData = RealUI.db.char

    if charData.init then
        charData.init.initialized = true
        charData.init.installStage = -1
    end

    debug("Character initialization completed")
end

-- Check if character is initialized
function CharacterInit:IsInitialized()
    if not RealUI.db or not RealUI.db.char then
        return false
    end

    local charData = RealUI.db.char
    return charData.init and charData.init.initialized
end

-- Reset character initialization
function CharacterInit:Reset()
    if not RealUI.db or not RealUI.db.char then
        return
    end

    local charData = RealUI.db.char

    if charData.init then
        charData.init.initialized = false
        charData.init.installStage = 0
        charData.init.needchatmoved = true
    end

    debug("Character initialization reset")
end

-- Get character information
function CharacterInit:GetCharacterInfo()
    local name = _G.UnitName("player")
    local realm = _G.GetRealmName()
    local class = _G.UnitClass("player")
    local role = GetPlayerRole()
    local level = _G.UnitLevel("player")

    return {
        name = name,
        realm = realm,
        class = class,
        role = role,
        level = level,
        fullName = name .. "-" .. realm
    }
end

-- Register character in profile system
function CharacterInit:RegisterCharacter()
    if not RealUI.db or not RealUI.db.profile then
        return
    end

    local profile = RealUI.db.profile

    if not profile.registeredChars then
        profile.registeredChars = {}
    end

    local charInfo = self:GetCharacterInfo()
    local charKey = charInfo.fullName

    -- Register character if not already registered
    if not profile.registeredChars[charKey] then
        profile.registeredChars[charKey] = {
            name = charInfo.name,
            realm = charInfo.realm,
            class = charInfo.class,
            role = charInfo.role,
            level = charInfo.level,
            lastSeen = _G.time()
        }

        debug("Character registered:", charKey)
    else
        -- Update last seen time
        profile.registeredChars[charKey].lastSeen = _G.time()
    end
end

-- Perform full character setup
function CharacterInit:Setup()
    -- Initialize character data
    self:Initialize()

    -- Apply initial settings (from old setup system)
    self:ApplyInitialSettings()

    -- Apply role-based defaults
    self:ApplyRoleDefaults()

    -- Setup chat frames
    self:SetupChatFrames()

    -- Register character
    self:RegisterCharacter()

    -- Mark as complete
    self:Complete()

    debug("Full character setup completed")
end

-- Apply initial character settings (from old setup system)
function CharacterInit:ApplyInitialSettings()
    debug("Applying initial settings")

    -- Lock chat frames
    for i = 1, 10 do
        local cf = _G["ChatFrame"..i]
        if cf then
            _G.FCF_SetLocked(cf, 1)
        end
    end

    -- Set all chat channels to color player names by class
    for k, v in next, _G.CHAT_CONFIG_CHAT_LEFT do
        _G.ToggleChatColorNamesByClassGroup(true, v.type)
    end
    for iCh = 1, 15 do
        _G.ToggleChatColorNamesByClassGroup(true, "CHANNEL"..iCh)
    end

    -- Make Chat windows transparent
    _G.SetChatWindowAlpha(1, 0)
    _G.SetChatWindowAlpha(2, 0)

    -- Character-specific CVars
    local characterCVars = {
        -- Nameplates
        ["nameplateMotion"] = 1,          -- Stacking Nameplates
        ["nameplateShowAll"] = 1,         -- Always show nameplates
        ["nameplateShowSelf"] = 0,        -- Hide Personal Resource Display

        -- Combat
        ["displaySpellActivationOverlays"] = 1,    -- Turn on Spell Alerts

        -- Raid/Party
        ["useCompactPartyFrames"] = 1,    -- Raid-style party frames

        -- Quality of Life
        ["autoLootDefault"] = 1,          -- Turn on Auto Loot
    }

    for cvar, value in next, characterCVars do
        _G.SetCVar(cvar, value)
    end

    debug("Initial settings applied")
end

