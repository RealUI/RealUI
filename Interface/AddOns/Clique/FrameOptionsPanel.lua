--[[-------------------------------------------------------------------------
-- FrameOptionsPanel.lua
--
-- This file contains the definitions of the frame blacklist options panel.
--
-- Events registered:
--   None
-------------------------------------------------------------------------]]--

local addonName, addon = ...
local L = addon.L

local panel = CreateFrame("Frame")
panel.name = "Frame Blacklist"
panel.parent = addonName

addon.optpanels["BLACKLIST"] = panel

panel:SetScript("OnShow", function(self)
    if not panel.initialized then
        panel:CreateOptions()
        panel.refresh()
    end
    panel.refresh()
end)

local function make_label(name, template)
    local label = panel:CreateFontString("OVERLAY", "CliqueOptionsBlacklist" .. name, template)
    label:SetWidth(panel:GetWidth())
    label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    label.type = "label"
    return label
end

local function make_checkbox(name, parent, label)
    local frame = CreateFrame("CheckButton", "CliqueOptionsBlacklist" .. name, parent, "UICheckButtonTemplate")
    frame.text = _G[frame:GetName() .. "Text"]
    frame.type = "checkbox"
    frame.text:SetText(label)
    return frame
end


local state = {}

function panel:CreateOptions()
    panel.initialized = true

    self.intro = make_label("Intro", "GameFontHighlightSmall")
    self.intro:SetPoint("TOPLEFT", panel, 5, -5)
    self.intro:SetPoint("RIGHT", panel, -5, 0)
    self.intro:SetHeight(45)
    self.intro:SetText(L["This panel allows you to blacklist certain frames from being included for Clique bindings. Any frames that are selected in this list will not be registered, although you may have to reload your user interface to have them return to their original bindings."])

    self.scrollframe = CreateFrame("ScrollFrame", "CliqueOptionsBlacklistScrollFrame", self, "FauxScrollFrameTemplate")
    self.scrollframe:SetPoint("TOPLEFT", self.intro, "BOTTOMLEFT", 0, -5)
    self.scrollframe:SetPoint("RIGHT", self, "RIGHT", -30, 0)
    self.scrollframe:SetHeight(320)
    self.scrollframe:Show()


    local function row_onclick(row)
        state[row.frameName] = not not row:GetChecked()
    end

    self.rows = {}

    -- Create and anchor some items
    for idx = 1, 10 do
        self.rows[idx] = make_checkbox("Item" .. idx, self.scrollframe, L["Frame name"])
        self.rows[idx]:SetScript("OnClick", row_onclick)

        if idx == 1 then
            self.rows[idx]:SetPoint("TOPLEFT", self.scrollframe, "TOPLEFT", 0, 0)
        else
            self.rows[idx]:SetPoint("TOPLEFT", self.rows[idx-1], "BOTTOMLEFT", 0, 0)
        end
    end

    self.rowheight = self.rows[1]:GetHeight()

    -- Number of items?
    local function update()
        self:UpdateScrollFrame()
    end

    self.scrollframe:SetScript("OnVerticalScroll", function(frame, offset)
        FauxScrollFrame_OnVerticalScroll(frame, offset, self.rowheight, update)
    end)

    self.selectall = CreateFrame("Button", "CliqueOptionsBlacklistSelectAll", self, "UIPanelButtonTemplate")
    self.selectall:SetText(L["Select All"])
    self.selectall:SetPoint("BOTTOMLEFT", 10, 10)
    self.selectall:SetWidth(100)
    self.selectall:SetScript("OnClick", function(button)
        for frame in pairs(addon.ccframes) do
            local name = frame:GetName()
            if name then
                state[name] = true
            end
        end

        for name, frame in pairs(addon.hccframes) do
            state[name] = true
        end

        self:UpdateScrollFrame()
    end)

    self.selectnone = CreateFrame("Button", "CliqueOptionsBlacklistSelectNone", self, "UIPanelButtonTemplate")
    self.selectnone:SetText(L["Select None"])
    self.selectnone:SetPoint("BOTTOMLEFT", self.selectall, "BOTTOMRIGHT", 5, 0)
    self.selectnone:SetWidth(100)
    self.selectnone:SetScript("OnClick", function(button)
        for frame in pairs(addon.ccframes) do
            local name = frame:GetName()
            if name then
                state[name] = false
            end
        end

        for name, frame in pairs(addon.hccframes) do
            state[name] = false
        end

        self:UpdateScrollFrame()
    end)
end

function panel:UpdateScrollFrame()
    local sort = {}
    for frame in pairs(addon.ccframes) do
        local name = frame:GetName()
        if name then
            table.insert(sort, name)
        end
    end

    for name, frame in pairs(addon.hccframes) do
        table.insert(sort, name)
    end

    table.sort(sort)

    local offset = FauxScrollFrame_GetOffset(self.scrollframe)
    FauxScrollFrame_Update(self.scrollframe, #sort, 10, self.rowheight)

    for i=1, 10 do
        local idx = offset + i
        local row = self.rows[i]
        if idx <= #sort then
            row.frameName = sort[idx]
            row.text:SetText(sort[idx])
            row:SetChecked(state[sort[idx]])
            row:Show()
        else
            row:Hide()
        end
    end
end

function panel.okay()
    -- Clear the existing blacklist
    for frame, value in pairs(state) do
        if not not value then
            addon.settings.blacklist[frame] = true
        else
            addon.settings.blacklist[frame] = nil
        end
    end

    addon:FireMessage("BLACKLIST_CHANGED")
end

function panel.refresh()
    for frame in pairs(addon.ccframes) do
        local name = frame:GetName()
        if name then
            state[name] = false
        end
    end

    for name, frame in pairs(addon.hccframes) do
        state[name] = false
    end

    for frame, value in pairs(addon.settings.blacklist) do
        state[frame] = value
    end

    panel:UpdateScrollFrame()
end

InterfaceOptions_AddCategory(panel, addon.optpanels.ABOUT)
