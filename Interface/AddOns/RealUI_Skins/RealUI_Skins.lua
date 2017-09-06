local ADDON_NAME, private = ...

function private.OnLoad()
    print("Aurora_OnLoad")
end

if private.Aurora then
    print("Aurora is embeded")
else
    print("Aurora not embeded")
    _G.Aurora_OnLoad = private.OnLoad
end
