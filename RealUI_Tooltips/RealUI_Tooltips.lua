local _, private = ...

-- Lua Globals --
-- luacheck: globals time next select tonumber tostring tinsert

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

-- RealUI --
local RealUI = _G.RealUI
local FramePoint = RealUI:GetModule("FramePoint")

local Tooltips = RealUI:NewModule("Tooltips", "AceEvent-3.0")
private.Tooltips = Tooltips

local defaults = {
    global = {
        showTitles = true,
        showRealm = false,
        showIDs = false,
        multiTip = true,
        position = {
            x = -100,
            y = 130,
            point = "BOTTOMRIGHT"
        }
    }
}

local normalFont = _G.NORMAL_FONT_COLOR
local function GetUnit(self)
    Tooltips:debug("GetUnit", self and self:GetName())
    local _, unit = _G.GameTooltip:GetUnit()

    if not unit then
        local focus = _G.GetMouseFocus()
        if focus then
            -- focus might somehow be a FontString, which doesn't have GetAttribute
            unit = focus.unit or (focus.GetAttribute and focus:GetAttribute("unit"))
        end
    end

    return unit or "mouseover"
end
-- based on GameTooltip_UnitColor
local function GetUnitColor(unit)
    local r, g, b
    if _G.UnitPlayerControlled(unit) then
        local _, class = _G.UnitClass(unit)
        r, g, b = _G.CUSTOM_CLASS_COLORS[class]:GetRGB()
    elseif _G.UnitIsTapDenied(unit) then
        r, g, b = Color.gray:GetRGB()
    else
        local reaction = _G.UnitReaction(unit, "player")
        if reaction then
            r = _G.FACTION_BAR_COLORS[reaction].r
            g = _G.FACTION_BAR_COLORS[reaction].g
            b = _G.FACTION_BAR_COLORS[reaction].b
        else
            r = 1.0
            g = 1.0
            b = 1.0
        end
    end

    --print("unit color", r, g, b)
    return r, g, b
end

local Hooks = {}
local Scripts = {}
function private.AddHook(name, func, isScript)
    if isScript then
        if not Scripts[name] then
            Scripts[name] = {}
        end
        tinsert(Scripts[name], func)
    else
        if not Hooks[name] then
            Hooks[name] = {}
        end
        tinsert(Hooks[name], func)
    end
end
function private.HookTooltip(tooltip)
    for scriptName, funcs in next, Scripts do
        tooltip:HookScript(scriptName, function(...)
            for i = 1, #funcs do
                funcs[i](tooltip)
            end
        end)
    end

    for hookName, funcs in next, Hooks do
        _G.hooksecurefunc(tooltip, hookName, function(...)
            for i = 1, #funcs do
                funcs[i](...)
            end
        end)
    end
end

local classification = {
    elite = "+",
    rare = " |cff6699ffR|r",
    rareelite = " |cff6699ffR+|r",
    worldboss = (" |cffFF0000%s|r"):format(_G.BOSS)
}
local factionIcon = {
    Alliance = {
        texture = [[Interface\PVPFrame\PVP-Conquest-Misc]],
        coords = {0.693359375, 0.748046875, 0.603515625, 0.732421875}
    },
    Horde = {
        texture = [[Interface\PVPFrame\PVP-Conquest-Misc]],
        coords = {0.638671875, 0.693359375, 0.603515625, 0.732421875},
    },
    Neutral = {
        texture = [[Interface\PVPFrame\TournamentOrganizer]],
        coords = {0.2529296875, 0.3154296875, 0.22265625, 0.298828125},
    },
}

private.AddHook("OnTooltipSetUnit", function(self)
    Tooltips:debug("--- OnTooltipSetUnit ---")

    local unit = GetUnit(self)
    Tooltips:debug("unit:", unit)
    if _G.UnitExists(unit) then
        if not self.factionIcon then
            self.factionIcon = self:CreateTexture(nil, "BORDER")
            self.factionIcon:SetPoint("CENTER", _G.GameTooltip, "LEFT", 0, 0)
        end

        local faction =  _G.UnitFactionGroup(unit)
        if _G.UnitIsPVP(unit) then
            local icon = factionIcon[faction or "Neutral"]
            self.factionIcon:SetTexture(icon.texture)
            self.factionIcon:SetTexCoord(icon.coords[1], icon.coords[2], icon.coords[3], icon.coords[4])
            self.factionIcon:SetSize(32, 38)
            self.factionIcon:Show()
        else
            self.factionIcon:Hide()
        end

        local isPlayer = _G.UnitIsPlayer(unit)
        do -- Name
            local lineText = _G.GameTooltipTextLeft1:GetText()
            --print("text", lineText, isPlayer)

            if isPlayer then
                local unitName, server = _G.UnitName(unit)
                if Tooltips.db.global.showTitles then
                    unitName = _G.UnitPVPName(unit) or unitName
                    --print("title", unitName)
                end

                if server and server ~= "" then
                    if Tooltips.db.global.showRealm then
                        unitName = unitName.."-"..server
                    else
                        local relationship = _G.UnitRealmRelationship(unit)
                        --print("relationship", relationship)
                        if relationship == _G.LE_REALM_RELATION_VIRTUAL then
                            unitName = unitName.._G.INTERACTIVE_SERVER_LABEL
                        elseif relationship == _G.LE_REALM_RELATION_COALESCED then
                            unitName = unitName.._G.FOREIGN_SERVER_LABEL
                        end
                    end
                end

                --print("name", unitName)
                lineText = unitName
            end

            local iconIndex = _G.GetRaidTargetIndex(unit)
            Tooltips:debug("iconIndex:", iconIndex, _G.ICON_LIST[iconIndex])
            if iconIndex and _G.ICON_LIST[iconIndex] then
                -- iconIndex can be > 8, which is outside ICON_LIST's index
                _G.GameTooltipTextLeft1:SetFormattedText("%s12|t %s", _G.ICON_LIST[iconIndex], lineText)
            else
                _G.GameTooltipTextLeft1:SetText(lineText)
            end
            --print("text", lineText)
            _G.GameTooltipTextLeft1:SetTextColor(GetUnitColor(unit))
        end

        --do return end
        if isPlayer then -- guild
            local unitGuild, unitRank = _G.GetGuildInfo(unit)
            if unitGuild then
                _G.GameTooltipTextLeft2:SetFormattedText("|cffffffb3<%s> |cff00E6A8%s|r", unitGuild, unitRank)
            end
        end

        local level = _G.UnitLevel(unit)

        local previousLine = 1
        local dead = _G.UnitIsDeadOrGhost(unit)
        if level then
            local unitType
            if isPlayer then
                unitType = ("%s |cff%s%s|r"):format(_G.UnitRace(unit), _G.RealUI.GetColorString(GetUnitColor(unit)), _G.UnitClass(unit))
            else
                unitType = _G.UnitCreatureType(unit)
            end

            local diff
            if level == -1 then
                level = "??"
                diff = _G.QuestDifficultyColors.impossible
            else
                diff = _G.GetCreatureDifficultyColor(level)
            end

            local classify = _G.UnitClassification(unit) or ""
            local textLevel = ("|cff%s%s%s|r"):format(RealUI.GetColorString(diff), level, classification[classify] or "")

            for i = previousLine + 1, self:NumLines() do
                local tiptext = _G["GameTooltipTextLeft"..i]
                local linetext = tiptext:GetText()

                if linetext and linetext:find(_G.LEVEL) then
                    tiptext:SetFormattedText(("%s %s %s"), textLevel, unitType or "unitType", (dead and "|cffCCCCCC".._G.DEAD.."|r" or ""))
                    break
                end
            end
        end


        local unittarget = unit.."target"
        if _G.UnitExists(unittarget) then
            local text
            if _G.UnitIsUnit(unittarget, "player") then
                text = ("|cffff0000%s|r"):format("> ".._G.YOU.." <")
            else
                text = _G.UnitName(unittarget)
            end

            local tarRicon = (_G.GetRaidTargetIndex(unittarget))
            if tarRicon and _G.ICON_LIST[tarRicon] then
                text = ("%s %s"):format(_G.ICON_LIST[tarRicon].."10|t", text)
            end

            _G.GameTooltip:AddDoubleLine(_G.TARGET, text, normalFont.r, normalFont.g, normalFont.b, GetUnitColor(unittarget))
        end

        if dead then
            _G.GameTooltipStatusBar:Hide()
        end
    end
end, true)

local frameColor = Aurora.Color.frame
private.AddHook("OnTooltipCleared", function(self)
    if self.factionIcon then
        self.factionIcon:Hide()
    end

    self._id = nil

    self:SetBackdropBorderColor(frameColor.r, frameColor.g, frameColor.b)
end, true)


local tooltipAnchor = _G.CreateFrame("Frame", "RealUI_TooltipsAnchor", _G.UIParent)
tooltipAnchor:SetSize(50, 50)
_G.hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
    tooltip:ClearAllPoints()
    tooltip:SetPoint(Tooltips.db.global.position.point, tooltipAnchor)
end)




function Tooltips:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_TooltipsDB", defaults, true)

    FramePoint:RegisterMod(self)
    FramePoint:PositionFrame(self, tooltipAnchor, {"global", "position"})

    if RealUI.realmInfo.realmNormalized then
        private.SetupCurrency()
    else
        self:RegisterMessage("NormalizedRealmReceived", private.SetupCurrency)
    end

    if Tooltips.db.global.showIDs then
        private.SetupIDTips()
    end
    if Tooltips.db.global.multiTip then
        private.SetupMultiTip()
    end

    for _, tooltip in next, {_G.GameTooltip, _G.ItemRefTooltip} do
        private.HookTooltip(tooltip)
    end
end
