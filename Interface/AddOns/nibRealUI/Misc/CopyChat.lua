local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "CopyChat"
local CopyChat = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0")
local textDump = LibStub("RealUI_LibTextDump-1.0")

local select = select
local tostring = tostring
local dump

function CopyChat:CreateFrames()
    dump = textDump:New("Copy Frame")
    dump.frame = textDump.frames[dump]
    --dump.frame:SetPoint('BOTTOMLEFT', ChatFrame1EditBox, 'TOPLEFT', 3, 0)
    --dump.frame:SetPoint('BOTTOMRIGHT', ChatFrame1EditBox, 'TOPRIGHT', -3, 0)

    --dump:Hide()
end

local lines = {}
local function GetChatLines(...)
    dump:Clear()
    for i = select('#', ...), 1, -1 do
        local region = select(i, ...)
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
    
    FCF_SetChatWindowFontSize(self, chat, 0.1)
    local lineCount = GetChatLines(chat:GetRegions())
    FCF_SetChatWindowFontSize(self, chat, fontSize)
    
    if (lineCount > 0) then
        dump.frame.title:SetText(chat:GetName() .. " Copy Frame")
        
        dump:Display()
    end
end

local function CreateCopyButton(self)
    self.Copy = CreateFrame('Button', nil, _G[self:GetName()])
    self.Copy:SetSize(16, 16)
    self.Copy:SetPoint('TOPRIGHT', self, -10, 18)
    
    self.Copy:SetNormalTexture('Interface\\AddOns\\nibRealUI\\Media\\Chat\\CopyPaste')
    self.Copy:GetNormalTexture():SetSize(16, 16)
    
    self.Copy:SetHighlightTexture('Interface\\AddOns\\nibRealUI\\Media\\Chat\\CopyPaste')
    self.Copy:GetHighlightTexture():SetAllPoints(self.Copy:GetNormalTexture())
    
    local tab = _G[self:GetName()..'Tab']
    hooksecurefunc(tab, 'SetAlpha', function()
        self.Copy:SetAlpha(tab:GetAlpha()*0.55)
    end)
    
    self.Copy:SetScript('OnMouseDown', function(self)
        self:GetNormalTexture():ClearAllPoints()
        self:GetNormalTexture():SetPoint('CENTER', 1, -1)
    end)
    
    self.Copy:SetScript('OnMouseUp', function()
        self.Copy:GetNormalTexture():ClearAllPoints()
        self.Copy:GetNormalTexture():SetPoint('CENTER')
        
        if (self.Copy:IsMouseOver()) then
            copyChat(self)
        end
    end)
end

local function EnableCopyButton()
    for _, v in pairs(CHAT_FRAMES) do
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
    
    hooksecurefunc('FCF_OpenTemporaryWindow', EnableCopyButton)
    EnableCopyButton()
end
