-- Code concepts from FreeUI by Haleth
local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "SpeechBubbles"
local SpeechBubbles = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local events = {
    CHAT_MSG_SAY = "chatBubbles", CHAT_MSG_YELL = "chatBubbles",
    CHAT_MSG_PARTY = "chatBubblesParty", CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
    CHAT_MSG_MONSTER_SAY = "chatBubbles", CHAT_MSG_MONSTER_YELL = "chatBubbles", CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
}

local function FixedScale(len)
    return _G.GetScreenHeight() * len / 768
end

local function SkinBubble(frame)
    for i= 1, frame:GetNumRegions() do
        local region = _G.select(i, frame:GetRegions())
        if region:GetObjectType() == "Texture" then
            region:SetTexture(nil)
        elseif region:GetObjectType() == "FontString" then
            frame.text = region
        end
    end

    local font, _, outline = _G.RealUIFont_Chat:GetFont()
    -- Message Font
    frame.text:SetFont(font, db.messagesize, outline)
    frame.text:SetJustifyH("LEFT")

    -- Sender Name
    local senderHeight = not(db.hideSender) and FixedScale(db.sendersize) or 0
    if not(db.hideSender) then
        frame.sender = frame:CreateFontString()
        frame.sender:SetPoint("TOP", 0, -db.edgesize)
        frame.sender:SetPoint("LEFT", frame.text)
        frame.sender:SetPoint("RIGHT", frame.text)
        frame.sender:SetFont(font, db.sendersize, outline)
        frame.sender:SetJustifyH("LEFT")
    end

    -- Border
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", frame.text, -db.edgesize, db.edgesize + senderHeight)
    frame:SetPoint("BOTTOMRIGHT", frame.text, db.edgesize, -db.edgesize)
    frame:SetBackdrop({
        bgFile = "",
        edgeFile = RealUI.media.textures.plain,
        edgeSize = _G.UIParent:GetScale(),
    })
    frame:SetBackdropBorderColor(db.colors.border[1], db.colors.border[2], db.colors.border[3])

    -- Background
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(RealUI.media.textures.plain)
    bg:SetVertexColor(db.colors.bg[1], db.colors.bg[2], db.colors.bg[3], db.colors.bg[4])

    frame:HookScript("OnHide", function() frame.inUse = false end)
end

local function UpdateFrame(frame, guid, name)
    if not frame.text then SkinBubble(frame) end
    frame.inUse = true

    if name and not(db.hideSender) then
        local class
        if guid ~= nil and guid ~= "" then
            _, class, _, _, _, _ = _G.GetPlayerInfoByGUID(guid)
        end

        local color = RealUI:GetClassColor(class)
        frame.sender:SetText(("|cff%2x%2x%2x%s|r"):format(color[1] * 255, color[2] * 255, color[3] * 255, name))
        if frame.text:GetWidth() < frame.sender:GetWidth() then
            frame.text:SetWidth(frame.sender:GetWidth())
        end
    end
end

-- Find chat bubble with given message
local function FindFrame(msg)
    for idx = 1, _G.WorldFrame:GetNumChildren() do
        local frame = _G.select(idx, _G.WorldFrame:GetChildren())
        if not frame:GetName() and not frame.inUse then
            for i = 1, _G.select("#", frame:GetRegions()) do
                local region = _G.select(i, frame:GetRegions())
                if region:GetObjectType() == "FontString" and region:GetText() == msg then
                    return frame
                end
            end

        end
    end
end

local EventTimer = _G.CreateFrame("Frame")
function SpeechBubbles:BubbleEvent(event, msg, sender, _, _, _, _, _, _, _, _, _, guid)
    if _G.GetCVarBool(events[event]) then
        EventTimer.elapsed = 0
        EventTimer:SetScript("OnUpdate", function(timer, elapsed)
            timer.elapsed = timer.elapsed + elapsed
            local frame = FindFrame(msg)
            if frame or timer.elapsed > 0.3 then
                EventTimer:SetScript("OnUpdate", nil)
                if frame then UpdateFrame(frame, guid, sender) end
            end
        end)
    end
end

function SpeechBubbles:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            sendersize = 12,
            hideSender = true,
            messagesize = 10,
            edgesize = 6,
            colors = {
                bg = {0, 0, 0, .65},
                border = {0, 0, 0, 1},
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function SpeechBubbles:OnEnable()
    for k, v in next, events do
        self:RegisterEvent(k, "BubbleEvent")
    end
end

function SpeechBubbles:OnDisable()
    self:UnregisterAllEvents()
end
