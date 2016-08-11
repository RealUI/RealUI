local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- Libs --
local textDump = _G.LibStub("RealUI_LibTextDump-1.0")

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "CopyChat"
local CopyChat = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local dump

function CopyChat:CreateFrames()
    dump = textDump:New("Copy Frame")
    dump.frame = textDump.frames[dump]
    --dump.frame:SetPoint('BOTTOMLEFT', ChatFrame1EditBox, 'TOPLEFT', 3, 0)
    --dump.frame:SetPoint('BOTTOMRIGHT', ChatFrame1EditBox, 'TOPRIGHT', -3, 0)

    --dump:Hide()
end

local function GetChatLines(...)
    dump:Clear()
    for i = _G.select('#', ...), 1, -1 do
        local region = _G.select(i, ...)
        if (region:GetObjectType() == 'FontString') then
            CopyChat:debug("GetChatLines", i, region:GetText())
            dump:AddLine(region:GetText())
        end
    end
    
    return dump:Lines()
end

local function copyChat(self)
    local chat = _G[self:GetName()]
    local _, fontSize = chat:GetFont()
    
    _G.FCF_SetChatWindowFontSize(self, chat, 0.1)
    local lineCount = GetChatLines(chat:GetRegions())
    _G.FCF_SetChatWindowFontSize(self, chat, fontSize)
    
    if (lineCount > 0) then
        dump.frame.TitleText:SetText(chat:GetName() .. " Copy Frame")
        
        dump:Display()
    end
end

local function CreateCopyButton(self)
    self.Copy = _G.CreateFrame('Button', nil, _G[self:GetName()])
    self.Copy:SetSize(16, 16)
    self.Copy:SetPoint('TOPRIGHT', self, -5, -5)
    
    self.Copy:SetNormalTexture('Interface\\AddOns\\nibRealUI\\Media\\Chat\\CopyPaste')
    self.Copy:GetNormalTexture():SetSize(16, 16)
    
    self.Copy:SetHighlightTexture('Interface\\AddOns\\nibRealUI\\Media\\Chat\\CopyPaste')
    self.Copy:GetHighlightTexture():SetAllPoints(self.Copy:GetNormalTexture())
    
    local tab = _G[self:GetName()..'Tab']
    _G.hooksecurefunc(tab, 'SetAlpha', function()
        self.Copy:SetAlpha(tab:GetAlpha()*0.55)
    end)
    
    self.Copy:SetScript('OnMouseDown', function(button)
        button:GetNormalTexture():ClearAllPoints()
        button:GetNormalTexture():SetPoint('CENTER', 1, -1)
    end)
    
    self.Copy:SetScript('OnMouseUp', function(button)
        button:GetNormalTexture():ClearAllPoints()
        button:GetNormalTexture():SetPoint('CENTER')
        
        if (button:IsMouseOver()) then
            copyChat(self)
        end
    end)
end

local function EnableCopyButton()
    for _, v in next, _G.CHAT_FRAMES do
        local chat = _G[v]
        if (chat and not chat.Copy) then
            CreateCopyButton(chat)
        end
    end
end

function CopyChat:OnInitialize()

end

function CopyChat:OnEnable()
    self:CreateFrames()
    
    _G.hooksecurefunc('FCF_OpenTemporaryWindow', EnableCopyButton)
    EnableCopyButton()
end
