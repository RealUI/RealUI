local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")
local db, dbc, dbg

local Textures = {
	Retina = [[Interface\AddOns\nibRealUI\Media\Install\Retina.tga]],
	Tick = [[Interface\AddOns\nibRealUI\Media\Install\Tick.tga]],
	Cross = [[Interface\AddOns\nibRealUI\Media\Install\Cross.tga]],
	RetinaText = [[Interface\AddOns\nibRealUI\Media\Install\RetinaText.tga]],
	NormalText = [[Interface\AddOns\nibRealUI\Media\Install\NormalText.tga]],
}
local RDF

local function CreateIWTextureFrame(texture, width, height, position, color)
	local frame = CreateFrame("Frame", nil, RDF)
	frame:SetParent(RDF)
	frame:SetPoint(unpack(position))
	frame:SetFrameStrata("DIALOG")
	frame:SetFrameLevel(RDF:GetFrameLevel() + 1)
	frame:SetWidth(width)
	frame:SetHeight(height)
	
	frame.bg = frame:CreateTexture()
	frame.bg:SetAllPoints(frame)
	frame.bg:SetTexture(texture)
	frame.bg:SetVertexColor(unpack(color))
	
	return frame
end

local function CreateRDOptions()
	if RDF then return end

	local db, dbc, dbg = nibRealUI.db.profile, nibRealUI.db.char, nibRealUI.db.global

	RDF = CreateFrame("Frame", nil, UIParent)
	RDF:SetParent(UIParent)
	RDF:SetAllPoints(UIParent)
	RDF:SetFrameStrata("DIALOG")
	RDF:SetFrameLevel(0)
	RDF:SetBackdrop({
		bgFile = nibRealUI.media.textures.plain,
	})
	RDF:SetBackdropColor(0, 0, 0, 0.9)

	RDF.logo = CreateIWTextureFrame(Textures.Retina, 512, 512, {"LEFT", RDF, "CENTER", -542, -52}, {1, 1, 1, 1})

	RDF.accept = CreateFrame("Button", "RealUIRDOptionsAccept", RDF, "SecureActionButtonTemplate")
	RDF.accept.icon = CreateIWTextureFrame(Textures.Tick, 128, 128, {"LEFT", RDF.accept, "LEFT", 32, 0}, {1, 1, 1, 1})
	RDF.accept.header = CreateIWTextureFrame(Textures.RetinaText, 512, 64, {"TOP", RDF.accept, "TOP", 52, -33}, {1, 1, 1, 1})
	RDF.accept.text = RDF.accept:CreateFontString(nil, "OVERLAY")
		RDF.accept.text:SetPoint("TOPLEFT", RDF.accept.header, "BOTTOMLEFT", 2, -18)
		RDF.accept.text:SetFont(nibRealUI.font.standard, 24)
		RDF.accept.text:SetText("Set up RealUI using 2x UI Scaling so that\nUI elements are easier to see on a Retina Display.")
		RDF.accept.text:SetJustifyH("LEFT")
	RDF.accept:SetPoint("TOPLEFT", RDF.logo, "TOPLEFT", 284, 0)
	RDF.accept:SetWidth(800)
	RDF.accept:SetHeight(196)
	RDF.accept:SetNormalFontObject(NumberFontNormal)
	RDF.accept:RegisterForClicks("LeftButtonUp")
	RDF.accept:SetScript("OnClick", function()
		db.positions = nibRealUI:DeepCopy(nibRealUI.defaultPositions)

		nibRealUI.db.global.tags.retinaDisplay.set = true
		nibRealUI.db.global.tags.retinaDisplay.checked = true
		ReloadUI()
	end)

	RDF.cancel = CreateFrame("Button", "RealUIRDOptionsCancel", RDF, "SecureActionButtonTemplate")
	RDF.cancel.icon = CreateIWTextureFrame(Textures.Cross, 128, 128, {"LEFT", RDF.cancel, "LEFT", 32, 0}, {1, 1, 1, 1})
	RDF.cancel.header = CreateIWTextureFrame(Textures.NormalText, 512, 64, {"TOP", RDF.cancel, "TOP", 52, -33}, {1, 1, 1, 1})
	RDF.cancel.text = RDF.cancel:CreateFontString(nil, "OVERLAY")
		RDF.cancel.text:SetPoint("TOPLEFT", RDF.cancel.header, "BOTTOMLEFT", 2, -18)
		RDF.cancel.text:SetFont(nibRealUI.font.standard, 24)
		RDF.cancel.text:SetText("Set up RealUI using normal UI Scaling.\nUI elements may be hard to see on a Retina Display.")
		RDF.cancel.text:SetJustifyH("LEFT")
	RDF.cancel:SetPoint("BOTTOMLEFT", RDF.logo, "BOTTOMLEFT", 284, 105)
	RDF.cancel:SetWidth(800)
	RDF.cancel:SetHeight(196)
	RDF.cancel:SetNormalFontObject(NumberFontNormal)
	RDF.cancel:RegisterForClicks("LeftButtonUp")
	RDF.cancel:SetScript("OnClick", function()
		dbg.tags.retinaDisplay.set = false
		dbg.tags.retinaDisplay.checked = true
		ReloadUI()
	end)
	
	if Aurora then
		local F = unpack(Aurora)
		F.Reskin(RDF.accept)
		F.Reskin(RDF.cancel)
	end
end

function nibRealUI:InitRetinaDisplayOptions()
	CreateRDOptions()
end