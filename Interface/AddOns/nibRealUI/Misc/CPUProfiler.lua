local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "CPUProfiler"
local CPUProfiler = nibRealUI:NewModule(MODNAME)

local pow, max = math.pow, math.max
local graphFrame
local values, bars, new, old = {}, {}, 0, 0
local tags = {0, 0.1, 1, 10}
local graphHeight = 250

local function GraphUpdate(f, elap)
	UpdateAddOnCPUUsage()

	new = GetAddOnCPUUsage("nibRealUI")
	tinsert(values, 1, new - old)
	old = new

	if (values[400]) then tremove(values, 400) end -- clean up oldest entry

	for i = #(values), 1, -1 do
		if (values[i] > 10) then -- bad usage if more than 10ms a frame (imho)
			bars[i]:SetTexture(1, 0, 0, 1)
		else
			bars[i]:SetTexture(1, 1, 1, 0.5)
		end

		bars[i]:SetHeight(max(pow(values[i] / 100, 0.28) * graphHeight, 1))
	end
end

function CPUProfiler:Start()
	if not graphFrame then
		graphFrame = CreateFrame('Frame', nil, UIParent)
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
				tag:SetPoint('RIGHT', graphFrame, 'BOTTOMLEFT', -1, pow(t / 100, 0.28) * graphHeight)
				tag:SetText(tostring(t) .. ' -')
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
	if GetCVar("scriptProfile") == "1" then
		self:Start()
	end
end
