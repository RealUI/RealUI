--[[ Example for RealUI_Dev/local/ForeverProfile.lua (gitignored, personal).

     Copy this file to RealUI_Dev/local/ForeverProfile.lua and fill it in.
     ForeverBootstrap.lua replays it at every login on the Forever beta, where
     addon SavedVariables do not persist.

     export        The string from RealUI_Config → Profiles → "Export all
                   linked". It only carries the scopes linked at export time;
                   an unlinked Skins scope has its own "Export Skins" button.
                   Give one string, or a list of strings: { [==[...]==],
                   [==[...]==] }. Paste each verbatim inside long brackets.
     displayPreset One of: "laptop", "standard", "highres", "4k_desk",
                   "4k_theater", "ultrawide". Leave nil to keep the default.
     layout        1 = RealUI (DPS/Tank), 2 = RealUI-Healing.
     naga          true to enable bar 6 (the Naga bar), false to leave it off,
                   nil to not touch it. ]]--

-- luacheck: globals RealUI_Dev_ForeverProfile
RealUI_Dev_ForeverProfile = {
    export = [==[
PASTE THE EXPORT STRING HERE
]==],
    displayPreset = nil,
    layout = 1,
    naga = true,
}
