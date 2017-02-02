local _, private = ...

-- RealUI --
local RealUI = private.RealUI

local Textures = {
    Retina = [[Interface\AddOns\nibRealUI\Media\Install\Retina.tga]],
    Tick = [[Interface\AddOns\nibRealUI\Media\Install\Tick.tga]],
    Cross = [[Interface\AddOns\nibRealUI\Media\Install\Cross.tga]],
    RetinaText = [[Interface\AddOns\nibRealUI\Media\Install\RetinaText.tga]],
    NormalText = [[Interface\AddOns\nibRealUI\Media\Install\NormalText.tga]],
}
local RDF

local function CreateIWTextureFrame(texture, width, height, position, color)
    local frame = _G.CreateFrame("Frame", nil, RDF)
    frame:SetParent(RDF)
    frame:SetPoint(_G.unpack(position))
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(RDF:GetFrameLevel() + 1)
    frame:SetWidth(width)
    frame:SetHeight(height)

    frame.bg = frame:CreateTexture()
    frame.bg:SetAllPoints(frame)
    frame.bg:SetTexture(texture)
    frame.bg:SetVertexColor(_G.unpack(color))

    return frame
end

local function CreateRDOptions()
    if RDF then return end

    local db, dbg = RealUI.db.profile, RealUI.db.global

    RDF = _G.CreateFrame("Frame", nil, _G.UIParent)
    RDF:SetParent(_G.UIParent)
    RDF:SetAllPoints(_G.UIParent)
    RDF:SetFrameStrata("DIALOG")
    RDF:SetFrameLevel(0)
    RDF:SetBackdrop({
        bgFile = RealUI.media.textures.plain,
    })
    RDF:SetBackdropColor(0, 0, 0, 0.9)

    RDF.logo = CreateIWTextureFrame(Textures.Retina, 512, 512, {"LEFT", RDF, "CENTER", -542, -52}, {1, 1, 1, 1})

    RDF.accept = _G.CreateFrame("Button", "RealUIRDOptionsAccept", RDF, "SecureActionButtonTemplate")
    RDF.accept.icon = CreateIWTextureFrame(Textures.Tick, 128, 128, {"LEFT", RDF.accept, "LEFT", 32, 0}, {1, 1, 1, 1})
    RDF.accept.header = CreateIWTextureFrame(Textures.RetinaText, 512, 64, {"TOP", RDF.accept, "TOP", 52, -33}, {1, 1, 1, 1})
    RDF.accept.text = RDF.accept:CreateFontString(nil, "OVERLAY")
        RDF.accept.text:SetPoint("TOPLEFT", RDF.accept.header, "BOTTOMLEFT", 2, -18)
        RDF.accept.text:SetFont(_G.RealUIFont_Normal:GetFont(), 24)
        RDF.accept.text:SetText("Set up RealUI using 2x UI Scaling so that\nUI elements are easier to see on a Retina Display.")
        RDF.accept.text:SetJustifyH("LEFT")
    RDF.accept:SetPoint("TOPLEFT", RDF.logo, "TOPLEFT", 284, 0)
    RDF.accept:SetWidth(800)
    RDF.accept:SetHeight(196)
    RDF.accept:SetNormalFontObject(_G.NumberFontNormal)
    RDF.accept:RegisterForClicks("LeftButtonUp")
    RDF.accept:SetScript("OnClick", function()
        db.positions = RealUI:DeepCopy(RealUI.defaultPositions)

        RealUI.db.global.tags.retinaDisplay.set = true
        RealUI.db.global.tags.retinaDisplay.checked = true
        _G.ReloadUI()
    end)

    RDF.cancel = _G.CreateFrame("Button", "RealUIRDOptionsCancel", RDF, "SecureActionButtonTemplate")
    RDF.cancel.icon = CreateIWTextureFrame(Textures.Cross, 128, 128, {"LEFT", RDF.cancel, "LEFT", 32, 0}, {1, 1, 1, 1})
    RDF.cancel.header = CreateIWTextureFrame(Textures.NormalText, 512, 64, {"TOP", RDF.cancel, "TOP", 52, -33}, {1, 1, 1, 1})
    RDF.cancel.text = RDF.cancel:CreateFontString(nil, "OVERLAY")
        RDF.cancel.text:SetPoint("TOPLEFT", RDF.cancel.header, "BOTTOMLEFT", 2, -18)
        RDF.cancel.text:SetFont(_G.RealUIFont_Normal:GetFont(), 24)
        RDF.cancel.text:SetText("Set up RealUI using normal UI Scaling.\nUI elements may be hard to see on a Retina Display.")
        RDF.cancel.text:SetJustifyH("LEFT")
    RDF.cancel:SetPoint("BOTTOMLEFT", RDF.logo, "BOTTOMLEFT", 284, 105)
    RDF.cancel:SetWidth(800)
    RDF.cancel:SetHeight(196)
    RDF.cancel:SetNormalFontObject(_G.NumberFontNormal)
    RDF.cancel:RegisterForClicks("LeftButtonUp")
    RDF.cancel:SetScript("OnClick", function()
        dbg.tags.retinaDisplay.set = false
        dbg.tags.retinaDisplay.checked = true
        _G.ReloadUI()
    end)

    if _G.Aurora then
        local F = _G.Aurora[1]
        F.Reskin(RDF.accept)
        F.Reskin(RDF.cancel)
    end
end

function RealUI:InitRetinaDisplayOptions()
    CreateRDOptions()
end
