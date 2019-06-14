local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local db

local Chat = RealUI:GetModule("Chat")

local MODNAME = "Chat_Tabs"
local Chat_Tabs = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local maxTabs = _G.NUM_CHAT_WINDOWS

-- Tab Style update
local function UpdateTabStyle(self, style)
    Chat_Tabs:debug("UpdateTabStyle", self, self:GetName(), self.UpdateTabs, style)
    local text = _G[self:GetName().."Text"]

    -- Update Tab Appearance
    if not style then
        if self.alerting then
            style = "flash"
        else
            style = "normal"
        end
    end

    -- Color
    if style == "highlight" or style == "selected" then
        text:SetTextColor(RealUI.charInfo.class.color:GetRGB())
    else
        local color = db.colors[style]
        text:SetTextColor(color[1], color[2], color[3], color[4])
    end
end

-- Chat Tab mouse-events
local function ChatTab_OnLeave(self)
    Chat_Tabs:debug("ChatTab_OnLeave", self)
    Chat_Tabs:UpdateTab("ChatFrame"..self:GetID())
end
local function ChatTab_OnEnter(self)
    Chat_Tabs:debug("ChatTab_OnEnter", self)
    UpdateTabStyle(self, "highlight")
end

function Chat_Tabs:UpdateTab(chatName, chatTabText)
    Chat_Tabs:debug("UpdateTab", chatName, chatTabText)
    local chat = _G[chatName]
    local tab = _G[chatName.."Tab"]

    if not tab.skinned then
        -- Hide Chat Tab textures
        tab.leftTexture:Hide()
        tab.middleTexture:Hide()
        tab.rightTexture:Hide()

        tab.leftSelectedTexture:Hide()
        tab.middleSelectedTexture:Hide()
        tab.rightSelectedTexture:Hide()

        tab.leftHighlightTexture:Hide()
        tab.middleHighlightTexture:Hide()
        tab.rightHighlightTexture:Hide()

        -- Hook Tab
        tab:SetScript("OnEnter", ChatTab_OnEnter)
        tab:SetScript("OnLeave", ChatTab_OnLeave)

        if chatTabText then
            _G.FCF_SetWindowName(chat, chatTabText)
        end

        tab.skinned = true
    end

    -- Update Tab Appearance
    UpdateTabStyle(tab, chat == _G.SELECTED_CHAT_FRAME and "selected")

    chat:SetSpacing(1)
end

-- Tab update
function Chat_Tabs:UpdateTabs()
    Chat_Tabs:debug("UpdateTabs")
    for i = 1, maxTabs do
        local chatName = "ChatFrame"..i

        self:UpdateTab(chatName)
    end
end

-- Hook FCF
function Chat_Tabs:HookFCF()
    _G.hooksecurefunc("FCF_Tab_OnClick", function(chatFrame, button)
        Chat_Tabs:debug("FCF_Tab_OnClick", chatFrame, button)
        Chat_Tabs:UpdateTabs()
    end)

    _G.hooksecurefunc("FCF_OpenNewWindow", function(chatTabText)
        Chat_Tabs:debug("FCF_OpenNewWindow", chatTabText)
        Chat_Tabs:UpdateTabs()
    end)
    _G.hooksecurefunc("FCF_OpenTemporaryWindow", function(chatType, chatTarget, sourceChatFrame, selectWindow)
        Chat_Tabs:debug("FCF_OpenTemporaryWindow", chatType, chatTarget, sourceChatFrame, selectWindow)
        local chatName = "ChatFrame"..(maxTabs + 1)
        if _G[chatName] then
            Chat_Tabs:debug("bump maxTabs", maxTabs)
            maxTabs = maxTabs + 1
            if chatType == "WHISPER" then
                chatTarget = _G.Ambiguate(chatTarget, "none")
            end
            Chat_Tabs:UpdateTab(chatName, chatTarget)
        end
    end)

    _G.hooksecurefunc("FCF_Close", function(chatFrame, fallback)
        Chat_Tabs:debug("FCF_Close", chatFrame, chatFrame:GetName(), fallback)
        if chatFrame.isTemporary then
            maxTabs = maxTabs - 1
        end
        local frame = fallback or chatFrame
        _G.UIParent.Hide(_G[frame:GetName().."Tab"])
        _G.FCF_Tab_OnClick(_G["ChatFrame1Tab"], "LeftButton")
    end)

    _G.hooksecurefunc("FCF_StartAlertFlash", function(chatFrame)
        Chat_Tabs:debug("FCF_StartAlertFlash", chatFrame, chatFrame:GetName())
        UpdateTabStyle(_G[chatFrame:GetName().."Tab"], "flash")
    end)
    _G.hooksecurefunc("FCF_StopAlertFlash", function(chatFrame)
        Chat_Tabs:debug("FCF_StopAlertFlash", chatFrame, chatFrame:GetName())
        UpdateTabStyle(_G[chatFrame:GetName().."Tab"], "normal")
    end)

    -- New UpdateColors function, stop it!
    _G.FCFTab_UpdateColors = function(...) end
end

-- Style Pet Tab when it appears
function Chat_Tabs:PET_BATTLE_OPENING_START()
    self:UpdateTabs()
end

function Chat_Tabs:PLAYER_LOGIN()
    self:HookFCF()
    self:UpdateTabs()
end

------------
function Chat_Tabs:RefreshMod()
    db = Chat.db.profile.modules.tabs
    self:UpdateTabs()
end

function Chat_Tabs:OnInitialize()
    db = Chat.db.profile.modules.tabs

    self:SetEnabledState(db.enabled and RealUI:GetModuleEnabled("Chat"))
end

function Chat_Tabs:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PET_BATTLE_OPENING_START")
end
