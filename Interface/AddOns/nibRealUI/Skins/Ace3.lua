local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local F, C = unpack(Aurora)

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

local function CreateBackdropTexture(f, anchor)
	local tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetDrawLayer("BACKGROUND", 0)
	tex:SetPoint("TOPLEFT", anchor or f, "TOPLEFT", 1, -1)
	tex:SetPoint("BOTTOMRIGHT", anchor or f, "BOTTOMRIGHT", -1, 1)
	tex:SetTexture(nibRealUI.media.textures.plain)
	tex:SetVertexColor(0.09, 0.09, 0.09, 1)
	f.backdropTexture = tex
end

local function skinLSM30(frame)
	frame.DLeft:SetAlpha(0)
	frame.DMiddle:SetAlpha(0)
	frame.DRight:SetAlpha(0)

	frame.dropButton:SetSize(20, 20)
	frame.dropButton:ClearAllPoints()
	frame.dropButton:SetPoint("TOPRIGHT", frame, -1, -18)

	F.Reskin(frame.dropButton, true)

	frame.dropButton:SetDisabledTexture(C.media.backdrop)
	local dis = frame.dropButton:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .4)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	local tex = frame.dropButton:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(C.media.arrowDown)
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	tex:SetVertexColor(1, 1, 1)
	frame.dropButton.tex = tex

	frame.dropButton:HookScript("OnEnter", F.colourArrow)
	frame.dropButton:HookScript("OnLeave", F.clearArrow)

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("LEFT", frame, 0, 0)
	bg:SetPoint("RIGHT", frame, -1, 0)
	bg:SetPoint("TOP", frame.dropButton, 0, 0)
	bg:SetPoint("BOTTOM", frame.dropButton, 0, 0)
	bg:SetFrameLevel(frame:GetFrameLevel()-1)
	nibRealUI:CreateBD(bg, 0)
	CreateBackdropTexture(frame, bg)
	frame.bg = bg

	frame.text:ClearAllPoints()
	frame.text:SetPoint("LEFT", frame.bg, 0, 0)
	frame.text:SetPoint("RIGHT", frame.bg, -25, 0)
end

function SkinAce3:Skin()
	local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
	if not AceGUI then return end

	local r, g, b = nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3]

	local oldRegisterAsWidget = AceGUI.RegisterAsWidget
	AceGUI.RegisterAsWidget = function(self, widget)
		local TYPE = widget.type
		--print(TYPE)
		if TYPE == "CheckBox" then
			if not widget.skinned then
				widget["SetType"] = function(self, type)
					local checkbg = self.checkbg
					local check = self.check
					local highlight = self.highlight

					local size
					if type == "radio" then
						size = 16
						checkbg:SetTexture("Interface\\Buttons\\UI-RadioButton")
						checkbg:SetTexCoord(0, 0.25, 0, 1)
						check:SetTexture("Interface\\Buttons\\UI-RadioButton")
						check:SetTexCoord(0.25, 0.5, 0, 1)
						check:SetBlendMode("ADD")
						highlight:SetTexture(nibRealUI.media.textures.plain)
						--highlight:SetTexCoord(0.5, 0.75, 0, 1)
					else
						size = 24
						checkbg:SetTexture("")
						checkbg:SetTexCoord(0, 1, 0, 1)
						check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
						check:SetTexCoord(0, 1, 0, 1)
						check:SetBlendMode("BLEND")
						highlight:SetTexture(nibRealUI.media.textures.plain)
						--highlight:SetTexCoord(0, 1, 0, 1)
					end
					checkbg:SetHeight(size)
					checkbg:SetWidth(size)
					highlight:SetPoint("TOPLEFT", checkbg, 5, -5)
					highlight:SetPoint("BOTTOMRIGHT", checkbg, -5, 5)
					highlight:SetVertexColor(r, g, b, .2)
				end
				widget["SetDisabled"] = function(self, disabled)
					self.disabled = disabled
					if disabled then
						self.frame:Disable()
						self.text:SetTextColor(0.5, 0.5, 0.5)
						--SetDesaturation(self.check, true)
						if self.desc then
							self.desc:SetTextColor(0.5, 0.5, 0.5)
						end
					else
						self.frame:Enable()
						self.text:SetTextColor(1, 1, 1)
						--[[if self.tristate and self.checked == nil then
							SetDesaturation(self.check, true)
						else
							SetDesaturation(self.check, false)
						end]]
						if self.desc then
							self.desc:SetTextColor(1, 1, 1)
						end
					end
				end
				widget["SetValue"] = function(self,value)
					local check = self.check
					self.checked = value
					if value then
						--SetDesaturation(self.check, false)
						self.check:Show()
					else
						--Nil is the unknown tristate value
						if self.tristate and value == nil then
							--SetDesaturation(self.check, true)
							self.check:Show()
						else
							--SetDesaturation(self.check, false)
							self.check:Hide()
						end
					end
					self:SetDisabled(self.disabled)
				end
				--[[Kill(widget.checkbg)
				Kill(widget.highlight)

				widget.frame:SetHighlightTexture(nibRealUI.media.textures.plain)
				local hl = widget.frame:GetHighlightTexture()
				hl:ClearAllPoints()
				hl:SetPoint("TOPLEFT", widget.checkbg, 5, -5)
				hl:SetPoint("BOTTOMRIGHT", widget.checkbg, -5, 5)
				hl:SetVertexColor(r, g, b, .2)]]

				if not widget.skinnedCheckBG then
					widget.skinnedCheckBG = CreateFrame('Frame', nil, widget.frame)
					widget.skinnedCheckBG:SetPoint('TOPLEFT', widget.checkbg, 'TOPLEFT', 4, -4)
					widget.skinnedCheckBG:SetPoint('BOTTOMRIGHT', widget.checkbg, 'BOTTOMRIGHT', -4, 4)
					nibRealUI:CreateBD(widget.skinnedCheckBG, 0)
					CreateBackdropTexture(widget.frame, widget.skinnedCheckBG)
				end

				if widget.skinnedCheckBG.oborder then
					widget.check:SetParent(widget.skinnedCheckBG.oborder)
				else
					widget.check:SetParent(widget.skinnedCheckBG)
				end--[[]]
				widget.check:SetDesaturated(true)
				widget.check:SetVertexColor(r, g, b)

				widget.skinned = true
			end

		elseif TYPE == "Dropdown" then
			if not widget.skinned then
				F.ReskinDropDown(widget.dropdown)
				widget.button:ClearAllPoints()
				widget.button:SetPoint("TOPRIGHT", widget.frame, -1, -18)
				widget.dropdown:ClearAllPoints()
				widget.dropdown:SetPoint("LEFT", widget.frame, -15, 0)
				widget.dropdown:SetPoint("RIGHT", widget.frame, 17, 0)
				widget.dropdown:SetPoint("TOP", widget.button, 0, 0)
				widget.dropdown:SetPoint("BOTTOM", widget.button, 0, -8)
				widget.text:ClearAllPoints()
				widget.text:SetPoint("LEFT", widget.dropdown, 0, 0)
				widget.text:SetPoint("RIGHT", widget.dropdown, -40, 0)
				widget.skinned = true
			end

		elseif TYPE == "LSM30_Statusbar" then
			if not widget.skinned then
				skinLSM30(widget.frame)
				widget.bar:ClearAllPoints()
				widget.bar:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 2, -22)
				widget.bar:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -24, 8)
				widget.skinned = true
			end

		elseif TYPE == "LSM30_Background" then
			if not widget.skinned then
				skinLSM30(widget.frame)
				widget.frame.bg:SetPoint("LEFT", widget.frame.displayButton, "RIGHT", 0, 0)
				widget.skinned = true
			end

		elseif TYPE == "LSM30_Border" then
			if not widget.skinned then
				skinLSM30(widget.frame)
				widget.frame.bg:SetPoint("LEFT", widget.frame.displayButton, "RIGHT", 0, 0)
				widget.skinned = true
			end

		elseif TYPE == "LSM30_Font" then
			if not widget.skinned then
				skinLSM30(widget.frame)
				widget.skinned = true
			end

		elseif TYPE == "LSM30_Sound" then
			if not widget.skinned then
				skinLSM30(widget.frame)
				widget.soundbutton:SetPoint("LEFT", widget.frame.bg, 2, 0)
				widget.frame.text:SetPoint("LEFT", widget.soundbutton, "RIGHT", 2, 0)
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
