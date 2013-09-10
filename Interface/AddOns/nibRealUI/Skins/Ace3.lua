local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "SkinAce3"
local SkinAce3 = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local HiddenFrame = CreateFrame("Frame", nil, UIParent)
HiddenFrame:Hide()

local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(HiddenFrame)
	else
		object.Show = function() end
	end
	object:Hide()
end

local function StripTextures(object, kill)
	for i=1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region:GetObjectType() == "Texture" then
			if kill then
				region:Kill()
			else
				region:SetTexture(nil)
			end
		end
	end
end

local function CreateBackdropTexture(f)
	local tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetDrawLayer("BACKGROUND", 1)
	tex:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
	tex:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
	tex:SetTexture(nibRealUI.media.textures.plain)
	tex:SetVertexColor(0.09, 0.09, 0.09, 1)
	f.backdropTexture = tex
end

function SkinAce3:Skin()
	local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
	if not AceGUI then return end

	local F = Aurora[1]
	local r, g, b = nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3]

	local oldRegisterAsWidget = AceGUI.RegisterAsWidget
	AceGUI.RegisterAsWidget = function(self, widget)
		local TYPE = widget.type
		--print(TYPE)
		if TYPE == "CheckBox" then
			if not widget.skinned then
				Kill(widget.checkbg)
				Kill(widget.highlight)

				widget.frame:SetHighlightTexture(nibRealUI.media.textures.plain)
				local hl = widget.frame:GetHighlightTexture()
				hl:ClearAllPoints()
				hl:SetPoint("TOPLEFT", widget.checkbg, 5, -5)
				hl:SetPoint("BOTTOMRIGHT", widget.checkbg, -5, 5)
				hl:SetVertexColor(r, g, b, .2)

				if not widget.skinnedCheckBG then
					widget.skinnedCheckBG = CreateFrame('Frame', nil, widget.frame)
					widget.skinnedCheckBG:SetPoint('TOPLEFT', widget.checkbg, 'TOPLEFT', 4, -4)
					widget.skinnedCheckBG:SetPoint('BOTTOMRIGHT', widget.checkbg, 'BOTTOMRIGHT', -4, 4)
					nibRealUI:CreateBD(widget.skinnedCheckBG, 0)
					CreateBackdropTexture(widget.skinnedCheckBG)
				end

				if widget.skinnedCheckBG.oborder then
					widget.check:SetParent(widget.skinnedCheckBG.oborder)
				else
					widget.check:SetParent(widget.skinnedCheckBG)
				end
				widget.check:SetDesaturated(true)
				widget.check:SetVertexColor(r, g, b)

				widget.skinned = true
			end

		elseif TYPE == "Dropdown" then
			if not widget.skinned then
				F.ReskinDropDown(widget.dropdown)
				widget.skinned = true
			end

		elseif TYPE == "EditBox" then
			if not widget.skinned then
				F.ReskinInput(widget.editbox)
				F.Reskin(widget.button)
				widget.skinned = true
			end

		elseif TYPE == "Button" then
			if not widget.skinned then
				F.Reskin(widget.frame)
				widget.skinned = true
			end

		elseif TYPE == "Slider" then
			if not widget.skinned then
				local frame = widget.slider
				local editbox = widget.editbox
				local lowtext = widget.lowtext
				local hightext = widget.hightext
				local HEIGHT = 12

				StripTextures(frame)
				nibRealUI:CreateBD(frame, 0)
				frame:SetHeight(HEIGHT)
				CreateBackdropTexture(frame)

				local slider = frame:GetThumbTexture()
				slider:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
				slider:SetBlendMode("ADD")

				nibRealUI:CreateBD(editbox, 0)
				editbox.SetBackdropColor = function() end
				editbox.SetBackdropBorderColor = function() end
				editbox:SetHeight(15)
				editbox:SetPoint("TOP", frame, "BOTTOM", 0, -1)
				CreateBackdropTexture(editbox)

				lowtext:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 2, -2)
				hightext:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -2, -2)

				widget.skinned = true
			end

		end
		return oldRegisterAsWidget(self, widget)
	end

	local oldRegisterAsContainer = AceGUI.RegisterAsContainer

	AceGUI.RegisterAsContainer = function(self, widget)
		local TYPE = widget.type
		if TYPE == "ScrollFrame" then
			local frame = widget.scrollbar
			F.ReskinScroll(frame)

		elseif TYPE == "InlineGroup" or TYPE == "TreeGroup" or TYPE == "TabGroup" or TYPE == "SimpleGroup" or TYPE == "Frame" or TYPE == "DropdownGroup" then
			local frame = widget.content:GetParent()
			nibRealUI:CreateBD(frame, .4)
			if TYPE == "Frame" then
				StripTextures(frame)
				for i=1, frame:GetNumChildren() do
					local child = select(i, frame:GetChildren())
					if child:GetObjectType() == "Button" and child:GetText() then
						F.Reskin(child)
					else
						StripTextures(child)
					end
				end
				F.CreateSD(frame)
				nibRealUI:CreateBD(frame)
				frame:SetBackdropColor(unpack(nibRealUI.media.window))
			end

			if widget.treeframe then
				nibRealUI:CreateBD(widget.treeframe, .3)
				frame:SetPoint("TOPLEFT", widget.treeframe, "TOPRIGHT", 1, 0)
			end

			if TYPE == "TabGroup" then
				local oldCreateTab = widget.CreateTab
				widget.CreateTab = function(self, id)
					local tab = oldCreateTab(self, id)
					StripTextures(tab)
					return tab
				end
			end
		end
		return oldRegisterAsContainer(self, widget)
	end
end
----------
function SkinAce3:PLAYER_LOGIN()
	if Aurora then
		self:Skin()
	end
end

function SkinAce3:OnInitialize()
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "Ace3")
end

function SkinAce3:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
end