--local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals

-- Libs --
local LDD = _G.LibStub("LibDropDown")
local LibContainer = _G.LibContainer

local function PostUpdate(Slot)
    if Slot.QuestIcon:IsShown() then
        Slot._auroraIconBorder:SetBackdropBorderColor(1, 1, 0)
    end
end
local function PostCreateSlot(Slot)
    local bagID = Slot:GetBagAndSlot()
    if bagID == _G.BANK_CONTAINER then
        _G.Aurora.Skin.BankItemButtonGenericTemplate(Slot)
    elseif bagID == _G.REAGENTBANK_CONTAINER then
        _G.Aurora.Skin.ReagentBankItemButtonGenericTemplate(Slot)
    else
        _G.Aurora.Skin.ContainerFrameItemButtonTemplate(Slot)
    end

    Slot:On("PostUpdate", PostUpdate)
end
local function PostCreateContainer(Container)
    local isBank = Container:GetParent():GetType() == "bank"

    if isBank then
        Container:SetRelPoint('TOPLEFT')
        Container:SetGrowDirection('RIGHT', 'DOWN')
    else
        Container:SetRelPoint('BOTTOMRIGHT')
        Container:SetGrowDirection('LEFT', 'UP')
    end
end
-- /tinspect Item:CreateFromBagAndSlot(0, 99)
-- /tinspect Item:CreateFromBagAndSlot(0, 1)
-- /dump C_Item.GetItemID(ItemLocation:CreateFromBagAndSlot(0, 99))
-- /dump C_Item.GetItemID(ItemLocation:CreateFromBagAndSlot(0, 1))
local Bags = LibContainer:New("bags", "RealUI_Bags", _G.UIParent)
Bags:SetPoint("BOTTOMRIGHT", -500, 50)
Bags:On("PostCreateSlot", PostCreateSlot)
Bags:On("PostCreateContainer", PostCreateContainer)
Bags:AddFreeSlot()
Bags:OverrideToggles()

local Bank = LibContainer:New("bank", "RealUI_Bank", _G.UIParent)
Bank:SetPoint("TOPLEFT", 50, -50)
Bank:On("PostCreateSlot", PostCreateSlot)
Bank:On("PostCreateContainer", PostCreateContainer)
Bank:AddFreeSlot()

local Dropdown = LDD:NewMenu(Bags)
Dropdown:SetStyle("REALUI")
