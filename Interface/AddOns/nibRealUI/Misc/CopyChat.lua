local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "CopyChat"
local CopyChat = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local select = select
local tostring = tostring
local concat = table.concat

local copyFrame

function CopyChat:CreateFrames()
	copyFrame = CreateFrame('Frame', nil, UIParent)
	copyFrame:SetHeight(220)
	copyFrame:SetBackdropColor(0, 0, 0, 1)
	copyFrame:SetPoint('BOTTOMLEFT', ChatFrame1EditBox, 'TOPLEFT', 3, 10)
	copyFrame:SetPoint('BOTTOMRIGHT', ChatFrame1EditBox, 'TOPRIGHT', -3, 10)
	copyFrame:SetFrameStrata('DIALOG')
	nibRealUI:CreateBD(copyFrame, nil, true, true)

	copyFrame:Hide()

	copyFrame.t = copyFrame:CreateFontString(nil, 'OVERLAY')
	copyFrame.t:SetFont('Fonts\\ARIALN.ttf', 18)
	copyFrame.t:SetPoint('TOPLEFT', copyFrame, 8, -8)
	copyFrame.t:SetTextColor(1, 1, 0)
	copyFrame.t:SetShadowOffset(1, -1)
	copyFrame.t:SetJustifyH('LEFT')

	copyFrame.b = CreateFrame('EditBox', nil, copyFrame)
	copyFrame.b:SetMultiLine(true)
	copyFrame.b:SetMaxLetters(20000)
	copyFrame.b:SetSize(450, 270)
	copyFrame.b:SetScript('OnEscapePressed', function()
		copyFrame:Hide() 
	end)

	copyFrame.s = CreateFrame('ScrollFrame', '$parentScrollBar', copyFrame, 'UIPanelScrollFrameTemplate')
	copyFrame.s:SetPoint('TOPLEFT', copyFrame, 'TOPLEFT', 8, -30)
	copyFrame.s:SetPoint('BOTTOMRIGHT', copyFrame, 'BOTTOMRIGHT', -30, 8)
	copyFrame.s:SetScrollChild(copyFrame.b)

	copyFrame.c = CreateFrame('Button', nil, copyFrame, 'UIPanelCloseButton')
	copyFrame.c:SetPoint('TOPRIGHT', copyFrame, 'TOPRIGHT', 0, -1)
	if Aurora then
        Aurora[1].ReskinClose(copyFrame.c)
    end
end

local lines = {}
local function GetChatLines(...)
	local count = 1
	for i = select('#', ...), 1, -1 do
		local region = select(i, ...)
		if (region:GetObjectType() == 'FontString') then
			lines[count] = tostring(region:GetText())
			count = count + 1
		end
	end
	
	return count - 1
end

local function copyChat(self)
	local chat = _G[self:GetName()]
	local _, fontSize = chat:GetFont()
	
	FCF_SetChatWindowFontSize(self, chat, 0.1)
	local lineCount = GetChatLines(chat:GetRegions())
	FCF_SetChatWindowFontSize(self, chat, fontSize)
	
	if (lineCount > 0) then
		ToggleFrame(copyFrame)
		copyFrame.t:SetText(chat:GetName())
		
		local f1, f2, f3 = ChatFrame1:GetFont()
		copyFrame.b:SetFont(f1, f2, f3)
		
		local text = concat(lines, '\n', 1, lineCount)
		copyFrame.b:SetText(text)
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