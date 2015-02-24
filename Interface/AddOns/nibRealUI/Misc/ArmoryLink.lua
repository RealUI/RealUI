L_POPUP_ARMORY = "Armory"

----------------------------------------------------------------------------------------
--  Armory link on right click player name in chat
----------------------------------------------------------------------------------------
local function urlencode(obj)
    local currentIndex = 1
    local charArray = {}
    while currentIndex <= #obj do
        local char = string.byte(obj, currentIndex)
        charArray[currentIndex] = char
        currentIndex = currentIndex + 1
    end
    local converchar = ""
    for _, char in ipairs(charArray) do
        converchar = converchar..string.format("%%%X", char)
    end
    return converchar
end

-- Find the Realm and Region
local realmName = string.lower(GetRealmName())
realmName = realmName:gsub("'", "")
realmName = realmName:gsub("-", "")
realmName = realmName:gsub(" ", "-")
local myserver = realmName:gsub("-", "")

local region = string.lower(GetCVar("portal"))
if region == "ru" then region = "eu" end

StaticPopupDialogs.LINK_COPY_DIALOG = {
    text = L_POPUP_ARMORY,
    button1 = OKAY,
    timeout = 0,
    whileDead = true,
    hasEditBox = true,
    editBoxWidth = 350,
    OnShow = function(self, ...) self.editBox:SetFocus() end,
    EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    preferredIndex = 5,
}

-- Dropdown menu link
local linkurl
hooksecurefunc("UnitPopup_OnClick", function(self)
    local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
    local name = dropdownFrame.name
    local server = dropdownFrame.server

    if not server then
        server = myserver
    else
        server = string.lower(server:gsub("'", ""))
        server = server:gsub(" ", "-")
    end
    
    if name and self.value == "ARMORYLINK" then
        local inputBox = StaticPopup_Show("LINK_COPY_DIALOG")
        if region == "us" or region == "eu" or region == "tw" or region == "kr" then
            local locale = GetLocale():sub(0, 2)
            if server == myserver then
                linkurl = "http://"..region..".battle.net/wow/"..locale.."/character/"..realmName.."/"..name.."/advanced"
            else
                linkurl = "http://"..region..".battle.net/wow/"..locale.."/search?q="..name.."&f=wowcharacter"
            end
            inputBox.editBox:SetText(linkurl)
            inputBox.editBox:HighlightText()
            return
        elseif region == "cn" then
            local n, r = name:match"(.*)-(.*)"
            n = n or name
            r = r or GetRealmName()
            
            linkurl = "http://www.battlenet.com.cn/wow/character/"..urlencode(r).."/"..urlencode(n).."/advanced"
            inputBox.editBox:SetText(linkurl)
            inputBox.editBox:HighlightText()
            return
        else
            print("|cFFFFFF00Unsupported realm location:|r" .. region)
            StaticPopup_Hide("LINK_COPY_DIALOG")
            return
        end
    end
end)

UnitPopupButtons["ARMORYLINK"] = {text = L_POPUP_ARMORY, dist = 0, func = UnitPopup_OnClick}
tinsert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["PARTY"], #UnitPopupMenus["PARTY"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["RAID"], #UnitPopupMenus["RAID"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["PLAYER"] - 1, "ARMORYLINK")
