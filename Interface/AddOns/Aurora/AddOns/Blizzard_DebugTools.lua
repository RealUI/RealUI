local F, C = unpack(select(2, ...))

C.themes["Blizzard_DebugTools"] = function()
	ScriptErrorsFrame:SetScale(UIParent:GetScale())
	ScriptErrorsFrame:SetSize(386, 274)
	ScriptErrorsFrame:DisableDrawLayer("OVERLAY")
	ScriptErrorsFrameTitleBG:Hide()
	ScriptErrorsFrameDialogBG:Hide()
	F.CreateBD(ScriptErrorsFrame)

	FrameStackTooltip:SetScale(UIParent:GetScale())
	FrameStackTooltip:SetBackdrop(nil)

	local bg = CreateFrame("Frame", nil, FrameStackTooltip)
	bg:SetPoint("TOPLEFT")
	bg:SetPoint("BOTTOMRIGHT")
	bg:SetFrameLevel(FrameStackTooltip:GetFrameLevel()-1)
	F.CreateBD(bg, .6)

	F.ReskinClose(ScriptErrorsFrameClose)
	F.ReskinScroll(ScriptErrorsFrameScrollFrameScrollBar)
	F.Reskin(select(4, ScriptErrorsFrame:GetChildren()))
	F.Reskin(select(5, ScriptErrorsFrame:GetChildren()))
	F.Reskin(select(6, ScriptErrorsFrame:GetChildren()))
end