local _, mods = ...

-- Lua Globals --
local _G = _G

mods["Blizzard_DebugTools"] = function(F, C)
    mods.debug("Blizzard_DebugTools", F, C)

    -- Fix ErrorFrame
    _G.ScriptErrorsFrameTitleButton:ClearAllPoints()
    _G.ScriptErrorsFrameTitleButton:SetPoint("TOPLEFT")
    _G.ScriptErrorsFrameTitleButton:SetPoint("BOTTOMRIGHT", _G.ScriptErrorsFrame, "TOPRIGHT", 0, -24)

    _G.ScriptErrorsFrame:HookScript("OnShow", function()
        _G.ScriptErrorsFrame:SetScale(_G.tonumber(_G.GetCVar("uiScale")))
        _G.ScriptErrorsFrame:SetSize(384, 260)
    end)

    -- EventTrace
    for i = 1, _G.EventTraceFrame:GetNumRegions() do
        local region = _G.select(i, _G.EventTraceFrame:GetRegions())
        if region:GetObjectType() == "Texture" then
            region:SetTexture(nil)
        end
    end
    _G.EventTraceFrame:SetHeight(600)
    F.CreateBD(_G.EventTraceFrame)

    _G.EventTraceFrameScrollBG:Hide()
    local thumb = _G.EventTraceFrameScroll.thumb
    thumb:SetAlpha(0)
    thumb:SetWidth(17)
    thumb.bg = _G.CreateFrame("Frame", nil, _G.EventTraceFrameScroll)
    thumb.bg:SetPoint("TOPLEFT", thumb, 0, 0)
    thumb.bg:SetPoint("BOTTOMRIGHT", thumb, 0, 0)
    F.CreateBD(thumb.bg, 0)
    thumb.tex = F.CreateGradient(thumb.bg)
    thumb.tex:SetPoint("TOPLEFT", thumb.bg, 1, -1)
    thumb.tex:SetPoint("BOTTOMRIGHT", thumb.bg, -1, 1)

    F.ReskinClose(_G.EventTraceFrameCloseButton)
end
