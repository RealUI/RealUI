local _, private = ...
local L = private.L

--[[ Lua Globals ]]
-- luacheck: globals tinsert wipe select next

--[[ Core ]]
local Aurora = private.Aurora
local Hook, Skin = Aurora.Hook, Aurora.Skin

local checkboxes = {}
local function RemoveCheckedItem(mailIndex)
    private.debug("RemoveCheckedItem", mailIndex, checkboxes[mailIndex])
    checkboxes[mailIndex]:SetChecked(false)
    checkboxes[mailIndex] = nil
end
local function UpdateCheckedItems()
    private.debug("UpdateCheckedItems")
    local numItems = _G.GetInboxNumItems()
    local index = ((_G.InboxFrame.pageNum - 1) * _G.INBOXITEMS_TO_DISPLAY) + 1

    for i = 1, _G.INBOXITEMS_TO_DISPLAY do
        local mailItem = _G["MailItem"..i]
        if index <= numItems then
            if checkboxes[index] then
                private.debug("checkbox", i, index, checkboxes[index])
                mailItem.checkbox:SetChecked(true)
            else
                mailItem.checkbox:SetChecked(false)
            end
        else
            mailItem.checkbox:SetChecked(false)
        end
        index = index + 1
    end

    private.debug("next", next(checkboxes))
    if next(checkboxes) then
        _G.OpenAllMail:Hide()
        _G.InboxFrameOpenChecked:Show()
    else
        _G.OpenAllMail:Show()
        _G.InboxFrameOpenChecked:Hide()
    end
end
local function ResetCheckedItems()
    wipe(checkboxes)
    UpdateCheckedItems()
end

local OPEN_ALL_MAIL_MIN_DELAY = 0.15
local OpenCheckedMailMixin = _G.Mixin({}, _G.OpenAllMailMixin)
function OpenCheckedMailMixin:StopOpening()
    private.debug("StopOpening")
    ResetCheckedItems()
    self:Reset()
    self:Enable()
    self:SetText(L.MailFrame_OpenChecked)
    self:UnregisterEvent("MAIL_INBOX_UPDATE")
    self:UnregisterEvent("MAIL_FAILED")
end
function OpenCheckedMailMixin:AdvanceToNextItem()
    local foundAttachment = false
    private.debug("AdvanceToNextItem", self.mailIndex, self.attachmentIndex)

    if checkboxes[self.mailIndex] then
        while ( not foundAttachment ) do
            local _, _, _, _, _, CODAmount = _G.GetInboxHeaderInfo(self.mailIndex)
            local itemID = select(2, _G.GetInboxItem(self.mailIndex, self.attachmentIndex))
            local hasBlacklistedItem = self:IsItemBlacklisted(itemID)
            local hasCOD = CODAmount and CODAmount > 0
            local hasMoneyOrItem = _G.C_Mail.HasInboxMoney(self.mailIndex) or _G.HasInboxItem(self.mailIndex, self.attachmentIndex)
            if ( not hasBlacklistedItem and not hasCOD and hasMoneyOrItem ) then
                foundAttachment = true
            else
                self.attachmentIndex = self.attachmentIndex - 1
                if ( self.attachmentIndex == 0 ) then
                    RemoveCheckedItem(self.mailIndex)
                    break
                end
            end
        end
    end

    private.debug("foundAttachment", foundAttachment, self.attachmentIndex)
    if ( not foundAttachment ) then
        self.mailIndex = self.mailIndex + 1
        self.attachmentIndex = _G.ATTACHMENTS_MAX
        if ( self.mailIndex > _G.GetInboxNumItems() ) then
            return false
        end

        return self:AdvanceToNextItem()
    end

    return true
end
function OpenCheckedMailMixin:ProcessNextItem()
    private.debug("ProcessNextItem")
    local _, _, _, _, money, CODAmount, _, itemCount, _, _, _, _, isGM = _G.GetInboxHeaderInfo(self.mailIndex)
    if ( isGM or (CODAmount and CODAmount > 0) ) then
        self:AdvanceAndProcessNextItem()
        return
    end

    private.debug("NextItem", money, itemCount)
    if ( money > 0 ) then
        if not itemCount then
            RemoveCheckedItem(self.mailIndex)
        end
        self.timeUntilNextRetrieval = OPEN_ALL_MAIL_MIN_DELAY
        _G.TakeInboxMoney(self.mailIndex)
    elseif ( itemCount and itemCount > 0 ) then
        if itemCount == 1 then
            RemoveCheckedItem(self.mailIndex)
        end
        self.timeUntilNextRetrieval = OPEN_ALL_MAIL_MIN_DELAY
        _G.TakeInboxItem(self.mailIndex, self.attachmentIndex)
    else
        RemoveCheckedItem(self.mailIndex)
        self:AdvanceAndProcessNextItem()
    end
    private.debug("timeUntilNextRetrieval", self.timeUntilNextRetrieval)
end

do --[[ FrameXML\MailFrame.lua ]]
    local numItems
    _G.hooksecurefunc(Hook, "InboxFrame_Update", function()
        local newNumItems = _G.GetInboxNumItems()
        private.debug("InboxFrame_Update", numItems, newNumItems)

        if numItems ~= newNumItems then
            numItems = newNumItems
            local index = ((_G.InboxFrame.pageNum - 1) * _G.INBOXITEMS_TO_DISPLAY) + 1

            for i = 1, _G.INBOXITEMS_TO_DISPLAY do
                local mailItem = _G["MailItem"..i]
                if index <= numItems then
                    private.debug("checkbox", i, index, checkboxes[index])
                    if checkboxes[index + 1] then
                        -- mailIndexes changed, we need to increment down the checkboxes
                        -- to ensure that the correct mail items get taken.
                        checkboxes[index + 1] = nil
                        checkboxes[index] = mailItem.checkbox
                    end
                end
                index = index + 1
            end
        end

        UpdateCheckedItems()
    end)
end

do --[[ FrameXML\MailFrame.xml ]]
    local function OnClick(self)
        local mailItem = self:GetParent()
        if self:GetChecked() then
            _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            checkboxes[mailItem.Button.index] = mailItem.checkbox
        else
            _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            checkboxes[mailItem.Button.index] = nil
        end
        UpdateCheckedItems()
    end
    _G.hooksecurefunc(Skin, "MailItemTemplate", function(Frame)
        Frame:SetSize(295, 45)

        local check = _G.CreateFrame("CheckButton", "$parentCheck", Frame, "UICheckButtonTemplate")
        Skin.UICheckButtonTemplate(check)
        check:SetPoint("RIGHT", Frame.Button, "LEFT", -3, 0)
        check:SetScript("OnClick", OnClick)
        Frame.checkbox = check
    end)
end

_G.hooksecurefunc(private.FrameXML, "MailFrame", function()
    _G.MailItem1:SetPoint("TOPLEFT", 33, -(private.FRAME_TITLE_HEIGHT + 5))

    local openChecked = _G.CreateFrame("Button", "$parentOpenChecked", _G.InboxFrame, "UIPanelButtonTemplate")
    Skin.UIPanelButtonTemplate(openChecked)
    openChecked:SetText(L.MailFrame_OpenChecked)
    openChecked:SetPoint("BOTTOM", 0, 14)
    openChecked:SetSize(120, 24)
    openChecked:Hide()

    _G.Mixin(openChecked, OpenCheckedMailMixin)
    openChecked:SetScript("OnEvent", openChecked.OnEvent)
    openChecked:SetScript("OnClick", openChecked.OnClick)
    openChecked:SetScript("OnUpdate", openChecked.OnUpdate)
    openChecked:SetScript("OnHide", openChecked.OnHide)
    openChecked:OnLoad()

    -------------
    -- Section --
    -------------

    --[[ Scale ]]--
end)
