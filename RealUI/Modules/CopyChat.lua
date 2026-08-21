local _, private = ...

-- Lua Globals --
local next = _G.next
local type = _G.type

-- Libs --
local textDump = _G.LibStub("LibTextDump-1.0")

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

-- Chat lines can carry secret strings (common in raids and delves).
-- LibTextDump's InsertLine does `text == ""`, which throws on a secret string,
-- so lines have to be checked before they reach the library.
-- See .kiro/steering/secret-values-canaccessvalue.md.
local function SafeString(value)
    if type(value) ~= "string" then return nil end
    if _G.canaccessvalue then
        return _G.canaccessvalue(value) and value or nil
    end
    local ok = _G.pcall(function() return _G.strsub(value, 1, 0) end)
    return ok and value or nil
end

-- Stands in for a line we cannot read, so the copy stays line-for-line with the
-- chat frame instead of silently losing rows.
local PROTECTED_LINE = "|cff9f9f9f<protected value - line cannot be copied>|r"

local function copyChat(self)
    local chat = _G[self:GetName()]
    local lineCount = chat:GetNumMessages()

    dump:Clear()

    local added = 0
    for i = 1, lineCount do
        local msg = chat:GetMessageInfo(i)
        local safe = SafeString(msg)
        if safe then
            -- InsertLine also rejects an empty string; chat frames do hand
            -- those out, and the error aborts the whole copy.
            if safe ~= "" then
                dump:AddLine(safe)
                added = added + 1
            end
        elseif type(msg) == "string" then
            dump:AddLine(PROTECTED_LINE)
            added = added + 1
        end
    end

    -- Count what actually made it into the buffer, not what chat reported:
    -- Display errors on an empty buffer.
    if added > 0 then
        dump.frame.title:SetText(chat:GetName() .. " Copy Frame")

        dump:Display()

        -- B69: the scroll frame keeps its scroll offset across copies. A big
        -- copy scrolled down, followed by a short one, leaves the viewport
        -- past the end of the new content — window opens looking blank while
        -- the text sits above the view. LibTextDump is read-only reference,
        -- so reset on our side of the boundary.
        local scrollArea = dump.frame.scrollArea
        if scrollArea and scrollArea.SetVerticalScroll then
            scrollArea:SetVerticalScroll(0)
        end
    end
end

local function CreateCopyButton(self)
    self.Copy = _G.CreateFrame('Button', nil, _G[self:GetName()])
    self.Copy:SetSize(16, 16)
    self.Copy:SetPoint('TOPRIGHT', self, -5, -5)

    self.Copy:SetNormalTexture([[Interface\AddOns\RealUI\Media\CopyPaste]])
    self.Copy:GetNormalTexture():SetSize(16, 16)

    self.Copy:SetHighlightTexture([[Interface\AddOns\RealUI\Media\CopyPaste]])
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
