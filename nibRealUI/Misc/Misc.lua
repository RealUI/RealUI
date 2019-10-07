----------------------------------------------------------------------------------------
--  Force readycheck warning
----------------------------------------------------------------------------------------
local ShowReadyCheckHook = function(self, initiator)
    if initiator ~= "player" then
        _G.PlaySound(_G.SOUNDKIT.READY_CHECK, "Master")
    end
end
_G.hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)

----------------------------------------------------------------------------------------
--  Force other warning
----------------------------------------------------------------------------------------
local ForceWarning = _G.CreateFrame("Frame")
ForceWarning:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
ForceWarning:RegisterEvent("RESURRECT_REQUEST")
ForceWarning:SetScript("OnEvent", function(self, event)
    if event == "UPDATE_BATTLEFIELD_STATUS" then
        for i = 1, _G.GetMaxBattlefieldID() do
            local status = _G.GetBattlefieldStatus(i)
            if status == "confirm" then
                _G.PlaySound(_G.SOUNDKIT.PVP_THROUGH_QUEUE, "Master")
                break
            end
        end
    elseif event == "RESURRECT_REQUEST" then
        _G.PlaySound(568667, "Master") -- sound/spells/resurrection.ogg
    end
end)

----------------------------------------------------------------------------------------
--  Misclicks for some popups
----------------------------------------------------------------------------------------
_G.StaticPopupDialogs.RESURRECT.hideOnEscape = nil
_G.StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
_G.StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
_G.StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
_G.StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
_G.StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil

----------------------------------------------------------------------------------------
--  Remove Boss Emote spam during BG(ArathiBasin SpamFix by Partha)
----------------------------------------------------------------------------------------
local Fixer = _G.CreateFrame("Frame")
local RaidBossEmoteFrame, spamDisabled = _G.RaidBossEmoteFrame

local function DisableSpam()
    if _G.GetZoneText() == _G.L_ZONE_ARATHIBASIN or _G.GetZoneText() == _G.L_ZONE_GILNEAS then
        RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_EMOTE")
        spamDisabled = true
    elseif spamDisabled then
        RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
        spamDisabled = false
    end
end

Fixer:RegisterEvent("PLAYER_ENTERING_WORLD")
Fixer:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Fixer:SetScript("OnEvent", DisableSpam)
