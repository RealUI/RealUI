local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI

_G.L_POPUP_ARMORY = "Armory"

----------------------------------------------------------------------------------------
--  Armory link on right click player name in chat
----------------------------------------------------------------------------------------
local function urlencode(str)
    if (str) then
        str = str:gsub("\n", "\r\n")
        str = str:gsub("([^%w %-%_%.%~])", function (c)
            return ("%%%02X"):format(c:byte())
        end)
        str = str:gsub(" ", "+")
    end
    return str    
end

-- Find the Realm and Region
local realmName = RealUI.realm:lower()
realmName = realmName:gsub("'", "")
realmName = realmName:gsub("-", "")
realmName = realmName:gsub(" ", "-")
local myserver = realmName:gsub("-", "")

local region = _G.GetCVar("portal"):lower()
if region == "ru" then region = "eu" end

_G.StaticPopupDialogs.LINK_COPY_DIALOG = {
    text = _G.L_POPUP_ARMORY,
    button1 = _G.OKAY,
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
_G.hooksecurefunc("UnitPopup_OnClick", function(self)
    local dropdownFrame = _G.UIDROPDOWNMENU_INIT_MENU
    local name = dropdownFrame.name
    local server = dropdownFrame.server

    if not server then
        server = myserver
    else
        server = server:gsub("'", ""):lower()
        server = server:gsub(" ", "-")
    end
    
    if name and self.value == "ARMORYLINK" then
        local inputBox = _G.StaticPopup_Show("LINK_COPY_DIALOG")
        if region == "us" or region == "eu" or region == "tw" or region == "kr" then
            local locale = RealUI.locale:sub(0, 2)
            if server == myserver then
                linkurl = "http://"..region..".battle.net/wow/"..locale.."/character/"..realmName.."/"..name.."/advanced"
            else
                linkurl = "http://"..region..".battle.net/wow/"..locale.."/search?q="..name.."&f=wowcharacter"
            end
            inputBox.editBox:SetText(linkurl)
            inputBox.editBox:HighlightText()
            return
        elseif region == "cn" then
            local n, r = name:match("(.*)-(.*)")
            n = n or name
            r = r or RealUI.realm
            
            linkurl = "http://www.battlenet.com.cn/wow/zh/character/"..urlencode(r).."/"..urlencode(n).."/advanced"
            inputBox.editBox:SetText(linkurl)
            inputBox.editBox:HighlightText()
            return
        else
            _G.print("|cFFFFFF00Unsupported realm location:|r" .. region)
            _G.StaticPopup_Hide("LINK_COPY_DIALOG")
            return
        end
    end
end)

_G.UnitPopupButtons["ARMORYLINK"] = {text = _G.L_POPUP_ARMORY, dist = 0, func = _G.UnitPopup_OnClick}
_G.tinsert(_G.UnitPopupMenus["FRIEND"], #_G.UnitPopupMenus["FRIEND"] - 1, "ARMORYLINK")
_G.tinsert(_G.UnitPopupMenus["PARTY"], #_G.UnitPopupMenus["PARTY"] - 1, "ARMORYLINK")
_G.tinsert(_G.UnitPopupMenus["RAID"], #_G.UnitPopupMenus["RAID"] - 1, "ARMORYLINK")
_G.tinsert(_G.UnitPopupMenus["PLAYER"], #_G.UnitPopupMenus["PLAYER"] - 1, "ARMORYLINK")
