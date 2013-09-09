local addonName, addon = ...

function addon:RunTest()
    function CliqueTest_Unit_OnShow(self)
        local unit = SecureButton_GetUnit(self)
        if not unit or not UnitExists(unit) then
            return
        end
        local name = UnitName(unit)
        self.name:SetText(name)
        self.healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
        self.powerBar:SetMinMaxValues(0, UnitPowerMax(unit))
        self.healthBar:SetValue(UnitHealth(unit))
        self.powerBar:SetValue(UnitPower(unit))
    end

    -- Create a fake "group header" to test things properly
    local groupheader = CreateFrame("Button", "MyGroupHeader", UIParent, "SecureGroupHeaderTemplate")
    SecureHandler_OnLoad(groupheader)

    -- Ensure the group header has a reference to the click-cast header
    groupheader:SetFrameRef("clickcast_header", addon.header)

    -- Set header attributes
    groupheader:SetAttribute("showParty", true)
    groupheader:SetAttribute("showRaid", true)
    groupheader:SetAttribute("showPlayer", true)
    groupheader:SetAttribute("showSolo", true)
    groupheader:SetAttribute("maxColumns", 8)
    groupheader:SetAttribute("unitsPerColumn", 5)
    groupheader:SetAttribute("columnAnchorPoint", "TOP")
    groupheader:SetAttribute("point", "LEFT")
    groupheader:SetAttribute("template", "CliqueTest_UnitTemplate")
    groupheader:SetAttribute("templateType", "Button")
    groupheader:SetAttribute("xOffset", -1)
    groupheader:SetAttribute("yOffset", -1)

    -- Set up the group header to display a solo/party/raid frame
    groupheader:SetAttribute("initialConfigFunction", [==[
        -- Register this frame with the global click-cast header
        local header = self:GetParent():GetFrameRef("clickcast_header")
        header:SetAttribute("clickcast_button", self)
        header:RunAttribute("clickcast_register")
    ]==])

    groupheader:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    groupheader:Show()

    -- Now create a pet frame, for testing useparent and other oddities

       -- Create a fake "group header" to test things properly
    local petheader = CreateFrame("Button", "MyGroupPetHeader", UIParent, "SecureGroupPetHeaderTemplate")
    SecureHandler_OnLoad(petheader)

    -- Ensure the group header has a reference to the click-cast header
    petheader:SetFrameRef("clickcast_header", addon.header)

    -- Set header attributes
    petheader:SetAttribute("useOwnerUnit", true)
    petheader:SetAttribute("showParty", true)
    petheader:SetAttribute("showRaid", true)
    petheader:SetAttribute("showPlayer", true)
    petheader:SetAttribute("showSolo", true)
    petheader:SetAttribute("maxColumns", 8)
    petheader:SetAttribute("unitsPerColumn", 5)
    petheader:SetAttribute("columnAnchorPoint", "TOP")
    petheader:SetAttribute("point", "LEFT")
    petheader:SetAttribute("template", "CliqueTest_UnitTemplate")
    petheader:SetAttribute("templateType", "Button")
    petheader:SetAttribute("xOffset", -1)
    petheader:SetAttribute("yOffset", -1)

    -- Set up the group header to display a solo/party/raid frame
    petheader:SetAttribute("initialConfigFunction", [==[
        self:SetAttribute("unitsuffix", "pet")
        -- Register this frame with the global click-cast header
        local header = self:GetParent():GetFrameRef("clickcast_header")
        header:SetAttribute("clickcast_button", self)
        header:RunAttribute("clickcast_register")
    ]==])

    petheader:SetPoint("LEFT", groupheader, "RIGHT", 0, 0)
    petheader:Show() 
end


