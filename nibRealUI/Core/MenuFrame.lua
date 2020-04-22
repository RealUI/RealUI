local _, private = ...

-- Lua Globals --
-- luacheck: globals ipairs type unpack wipe tinsert next

-- Libs --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin
local Color = Aurora.Color

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "MenuFrame"
local MenuFrame = RealUI:NewModule(MODNAME)


local MENU_HEADER = 15
local MENU_MARGIN = 16
local MENU_ITEM_HEIGHT = 16

local function MenuItemFactory(pool)
    local numActive = pool:GetNumActive()
    local menuItem = _G.CreateFrame("Button", "RealUI_MenuItem"..numActive, _G.UIParent)
    _G.Mixin(menuItem, pool.mixin)

    menuItem:OnLoad()
    return menuItem
end
local function MenuItemReset(pool, menuItem)
    menuItem:Clear()
end

local MenuItemMixin = {}
function MenuItemMixin:OnLoad()
    self:SetHeight(MENU_ITEM_HEIGHT)
    self:SetNormalFontObject("GameFontHighlightSmallLeft")
    self:SetDisabledFontObject("GameFontDisableSmallLeft")
    self:SetScript("OnClick", self.OnClick)

    local highlight = self:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetPoint("LEFT", 1, 0)
    highlight:SetPoint("RIGHT", -1, 0)
    highlight:SetPoint("TOP", 0, 0)
    highlight:SetPoint("BOTTOM", 0, 0)
    highlight:SetColorTexture(Color.highlight.r, Color.highlight.g, Color.highlight.b, 0.2)
    self:SetHighlightTexture(highlight)

    local spacer = self:CreateTexture(nil, "ARTWORK")
    spacer:SetColorTexture(1, 1, 1, 0.2)
    spacer:SetPoint("TOPLEFT", MENU_MARGIN, -7)
    spacer:SetPoint("BOTTOMRIGHT", -MENU_MARGIN, 8)
    self.spacer = spacer

    local arrow = self:CreateTexture(nil, "ARTWORK")
    arrow:SetColorTexture(1, 1, 1)
    arrow:SetSize(5, 10)
    arrow:SetPoint("TOPRIGHT", -11, -3)
    Base.SetTexture(arrow, "arrowRight")
    self.arrow = arrow

    local icon = self:CreateTexture(nil, "ARTWORK")
    icon:SetColorTexture(1, 1, 1)
    icon:SetSize(MENU_ITEM_HEIGHT, MENU_ITEM_HEIGHT)
    icon:SetPoint("TOPRIGHT", -MENU_MARGIN, 0)
    self.icon = icon

    local checkBox = _G.CreateFrame("CheckButton", nil, self)
    checkBox:SetPoint("TOPLEFT", 11, -2)
    checkBox:SetSize(12, 12)
    checkBox:SetScript("OnClick", function(this, button)
        self.OnClick(self, button)
    end)
    Skin.FrameTypeCheckButton(checkBox)

    local bg = checkBox:GetBackdropTexture("bg")
    local check = checkBox:CreateTexture(nil, "ARTWORK")
    check:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
    check:SetPoint("TOPLEFT", bg, -6, 6)
    check:SetPoint("BOTTOMRIGHT", bg, 6, -6)
    check:SetDesaturated(true)
    check:SetVertexColor(Color.highlight:GetRGB())
    checkBox:SetCheckedTexture(check)

    local disabled = checkBox:CreateTexture(nil, "ARTWORK")
    disabled:SetTexture([[Interface\Buttons\UI-CheckBox-Check-Disabled]])
    disabled:SetAllPoints(check)
    checkBox:SetDisabledCheckedTexture(disabled)
    self.checkBox = checkBox
end
function MenuItemMixin:Update(menuItemInfo)
    if menuItemInfo.isSpacer then
        self.spacer:Show()
        self:Disable()
    else
        self:SetText(menuItemInfo.text)

        if menuItemInfo.menuList then
            menuItemInfo.func = self.OpenSubMenu
            menuItemInfo.keepShown = true
            self.arrow:Show()
        end

        if menuItemInfo.icon then
            if _G.C_Texture.GetAtlasInfo(menuItemInfo.icon) then
                self.icon:SetAtlas(menuItemInfo.icon)
            else
                self.icon:SetTexture(menuItemInfo.icon)
            end
            self.icon:Show()

            if menuItemInfo.iconTexCoords then
                self.icon:SetTexCoord(unpack(menuItemInfo.iconTexCoords))
            end
        end


        local isDisabled = menuItemInfo.disabled
        if type(isDisabled) == "function" then
            isDisabled = isDisabled()
        end

        if menuItemInfo.isTitle then
            self:SetDisabledFontObject(_G.GameFontNormalSmallLeft)
            isDisabled = true
        end

        self:SetEnabledState(not isDisabled)
        if self:SetCheckedState(menuItemInfo.checked) ~= nil then
            self:GetFontString():SetPoint("LEFT", self.checkBox, 20, 0)
        else
            self:GetFontString():SetPoint("LEFT", MENU_MARGIN, 0)
        end
    end

    self.info = menuItemInfo
    self:Show()
end
function MenuItemMixin:SetCheckedState(isChecked, isClick)
    if isChecked ~= nil then
        if type(isChecked) == "function" then
            isChecked = isChecked()
        end

        if isClick then
            isChecked = not isChecked
        end

        self.checkBox:SetChecked(isChecked)
        self.checkBox:Show()
        return isChecked
    end
end
function MenuItemMixin:GetCheckedState()
    if self.checkBox:IsShown() then
        return self.checkBox:GetChecked()
    end
end
function MenuItemMixin:SetEnabledState(isEnabled)
    self:SetEnabled(isEnabled)
    self.checkBox:SetEnabled(isEnabled)
    return isEnabled
end
function MenuItemMixin:GetEnabledState()
    return self:IsEnabled()
end
function MenuItemMixin:GetButtonWidth()
    local menuItemInfo = self.info
    local width = self:GetTextWidth()

    if menuItemInfo.checked ~= nil then
        width = width + self.checkBox:GetWidth() + 20
    end

    if menuItemInfo.icon then
        width = width + 10
    end

    if menuItemInfo.menuList then
        width = width + 10
    end

    return width
end
function MenuItemMixin:OpenSubMenu()
    local newLevel = self.menu.level + 1
    MenuFrame:CloseAll(newLevel)
    MenuFrame:Open(self, "TOPRIGHT", self.info.menuList, newLevel)
end
function MenuItemMixin:OnClick(mouseButton, ...)
    local menuItemInfo = self.info
    local isChecked = self:SetCheckedState(menuItemInfo.checked, true)

    if menuItemInfo.func then
        menuItemInfo.func(self, menuItemInfo.arg1, menuItemInfo.arg2, isChecked)
    end

    if not menuItemInfo.keepShown then
        MenuFrame:CloseAll()
    end
end
function MenuItemMixin:Clear()
    self:SetDisabledFontObject("GameFontDisableSmallLeft")

    self:SetText("")
    self.arrow:Hide()
    self.spacer:Hide()
    self.icon:Hide()
    self.icon:SetTexCoord(0, 1, 0, 1)
    self.checkBox:Hide()
    self:SetEnabledState(true)

    self.info = nil
    self.menu = nil
    self:Hide()
end
local menuItems = _G.CreateObjectPool(MenuItemFactory, MenuItemReset)
menuItems.mixin = MenuItemMixin


local function MenuFactory(pool)
    local numActive = pool:GetNumActive()
    local menu = _G.CreateFrame("Frame", "RealUI_MenuFrame"..numActive, _G.UIParent, "TooltipBorderedFrameTemplate")
    Skin.TooltipBorderedFrameTemplate(menu)

    _G.Mixin(menu, pool.mixin)
    menu:OnLoad()
    return menu
end
local function MenuReset(pool, menu)
    menu:Clear()
end

local MenuFrameMixin = {}
function MenuFrameMixin:OnLoad()
    self:SetFrameStrata("TOOLTIP")
    self.items = {}
end
function MenuFrameMixin:Update(menuList)
    local width = 0
    for index, menuItemInfo in ipairs(menuList) do
        print("Update", index, menuItemInfo.text)
        local menuItem = menuItems:Acquire()
        menuItem:SetParent(self)
        menuItem:Update(menuItemInfo)

        local itemWidth = menuItem:GetButtonWidth()
        if width < itemWidth then
            width = itemWidth
        end

        if index == 1 then
            menuItem:SetPoint("TOPLEFT", self, 0, -MENU_HEADER)
        else
            menuItem:SetPoint("TOPLEFT", self.items[index - 1], "BOTTOMLEFT")
        end
        menuItem:SetPoint("RIGHT", self)
        menuItem.menu = self

        tinsert(self.items, menuItem)
    end

    self:SetSize(width + (MENU_MARGIN * 2), (MENU_ITEM_HEIGHT * #self.items) + (MENU_HEADER * 2))
end
function MenuFrameMixin:Clear()
    for index, menuItem in ipairs(self.items) do
        menuItems:Release(menuItem)
    end
    wipe(self.items)
    self.level = nil
    self:ClearAllPoints()
    self:Hide()
end
local menuFrames = _G.CreateObjectPool(MenuFactory, MenuReset)
menuFrames.mixin = MenuFrameMixin


local function GetMenuAnchor(button, menu)
    local point
    local rx, ry = button:GetCenter()
    local ux, uy = _G.UIParent:GetCenter()

    if ry >= uy then
        point = "TOP"
    else
        point = "BOTTOM"
    end

    if rx >= ux then
        point = point .. "RIGHT"
    else
        point = point .. "LEFT"
    end

    return point
end

local openMenus = {}
function MenuFrame:IsMenuOpen(button)
    return not not openMenus[button]
end
function MenuFrame:Open(button, point, menuList, level)
    if openMenus[button] then return end
    print("Open", menuList and #menuList)

    local menu = menuFrames:Acquire()
    menu.level = level or 1

    menu:Update(menuList)
    menu:SetPoint(GetMenuAnchor(button, menu), button, point)
    menu:Show()

    openMenus[button] = menu
end

function MenuFrame:Close(button)
    local menu = openMenus[button]
    openMenus[button] = nil
    menuFrames:Release(menu)
end

local function ContainsMouse()
    for button, menu in next, openMenus do
        if menu:IsShown() and menu:IsMouseOver() then
            return true
        end
    end
end
function MenuFrame:CloseAll(level)
    if not level then
        level = 1
    end

    for button, menu in next, openMenus do
        if menu.level >= level then
            MenuFrame:Close(button)
        end
    end
end

_G.hooksecurefunc("CloseDropDownMenus", function(level)
    if not ContainsMouse() then
        MenuFrame:CloseAll(level)
    end
end)
