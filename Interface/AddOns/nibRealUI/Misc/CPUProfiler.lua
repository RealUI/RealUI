local _, private = ...

-- Lua Globals --
local _G = _G
local ipairs = _G.ipairs

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "CPUProfiler"
local CPUProfiler = RealUI:NewModule(MODNAME)

local graphFrame
local values, bars, new, old = {}, {}, 0, 0
local tags = {0, 0.1, 1, 10}
local graphHeight = 250

local function GraphUpdate(f, elap)
    _G.UpdateAddOnCPUUsage()

    new = _G.GetAddOnCPUUsage("nibRealUI")
    _G.tinsert(values, 1, new - old)
    old = new

    if (values[400]) then _G.tremove(values, 400) end -- clean up oldest entry

    for i = #(values), 1, -1 do
        if (values[i] > 10) then -- bad usage if more than 10ms a frame (imho)
            bars[i]:SetTexture(1, 0, 0, 1)
        else
            bars[i]:SetTexture(1, 1, 1, 0.5)
        end

        bars[i]:SetHeight(_G.max((values[i] / 100) ^ 0.28 * graphHeight, 1))
    end
end

function CPUProfiler:Start()
    if not graphFrame then
        graphFrame = _G.CreateFrame('Frame', nil, _G.UIParent)
            graphFrame:SetHeight(100)
            graphFrame:SetWidth(400)
            graphFrame:SetPoint('BOTTOMRIGHT', 0, 26)

        for x = 1, 400 do
            bars[x] = graphFrame:CreateTexture(nil, 'OVERLAY')
                bars[x]:SetTexture(1, 1, 1, 0.5)
                bars[x]:SetWidth(1)
                bars[x]:SetHeight(1)
                bars[x]:SetPoint('BOTTOMLEFT', x - 1, -1)
        end

        for i, t in ipairs(tags) do
            local tag = graphFrame:CreateFontString(nil, 'OVERLAY', 'NumberFont_Outline_Med')
                tag:SetPoint('RIGHT', graphFrame, 'BOTTOMLEFT', -1, (t / 100) ^ 0.28 * graphHeight)
                tag:SetText(_G.tostring(t) .. ' -')
        end

        local disableNote = graphFrame:CreateFontString(nil, 'OVERLAY', 'NumberFont_Outline_Med')
            disableNote:SetPoint('RIGHT', graphFrame, 'BOTTOMRIGHT', -2, 6)
            disableNote:SetText("|cffff0000To disable, type |r|cffffffff/cpuProfiling|r")
    end

    graphFrame:SetScript('OnUpdate', GraphUpdate)
end

--------------------
-- Initialization --
--------------------
function CPUProfiler:OnInitialize()

end

function CPUProfiler:OnEnable()
    if _G.GetCVar("scriptProfile") == "1" then
        self:Start()
    end
end
