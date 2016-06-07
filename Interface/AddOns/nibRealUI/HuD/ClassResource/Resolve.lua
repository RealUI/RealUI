local _, private = ...
if private.RealUI.isBeta then return end

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "ClassResource_Resolve"
local Resolve = RealUI:NewModule(MODNAME)

Resolve.base = 0
------------------------
---- Resolve Scan ----
------------------------
-- Scan the tooltip and extract the Resolve value
do
    local regions = {}
    local tooltipBufferResolve = _G.CreateFrame("GameTooltip","RealUIBufferTooltip_Resolve",nil,"GameTooltipTemplate")
    tooltipBufferResolve:SetOwner(_G.WorldFrame, "ANCHOR_NONE")

    local function makeTable(t, ...)
        _G.wipe(t)
        for i = 1, _G.select("#", ...) do
            t[i] = _G.select(i, ...)
        end
    end

    function Resolve:UpdateCurrent()
        local name = _G.UnitAura("player", self.name)
        if name then
            -- Buff found, copy it into the buffer for scanning
            tooltipBufferResolve:ClearLines()
            tooltipBufferResolve:SetUnitBuff("player", name)

            -- Grab all regions, stuff em into our table
            makeTable(regions, tooltipBufferResolve:GetRegions())

            -- Convert FontStrings to strings, replace anything else with ""
            for i=1, #regions do
                local region = regions[i]
                regions[i] = region:GetObjectType() == "FontString" and region:GetText() or ""
            end

            -- Find the number, save it
            self.current = _G.tonumber(_G.table.concat(regions):match("%d+")) or 0
            self:UpdateMax()
        else
            self.current = 0
            self.percent = 0
        end
        --print("Current Resolve:", Resolve.current)
    end
end

---------------------------
---- Resolve Updates ------
---------------------------
function Resolve:UpdateMax()
    --print("UpdateMax")
    if self.current > self.max then
        self.max = self.max + 100
    elseif (self.max > 100) and (self.current < (self.max / 4)) then
        self.max = self.max - 100
    end

    self.percent = RealUI.Clamp(self.current / self.max, 0, 1)
    --print("Resolve:", self.percent, self.max)
end

------------
function Resolve:OnInitialize()
    self.name = _G.GetSpellInfo(158300)
    self.max = 100
end
