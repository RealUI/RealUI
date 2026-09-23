--[[ Example for Profile.lua — your own settings for the Forever bootstrap.

     The WoW Forever beta does not keep addon settings between logins, so
     RealUI would run its install wizard every time. The bootstrap skips it
     and, if you give it a Profile.lua, re-applies your settings instead.

     Setting it up:
       1. Set RealUI up the way you like it in one session.
       2. /realui → Profiles → "Export all linked", copy the string.
       3. Copy this file to Profile.lua in the same folder and paste the
          string between the [==[ and ]==] below.
       4. /reload. The chat shows what was imported.

     Profile.lua is not in the zip, so updating the bootstrap keeps it.
     Without a Profile.lua you get RealUI's stock settings, wizard skipped.

     export        The "Export all linked" string. It only carries the scopes
                   linked at export time; an unlinked Skins scope has its own
                   "Export Skins" button. Give one string, or a list of them:
                   { [==[...]==], [==[...]==] }. Paste each one verbatim.
     displayPreset One of: "laptop", "standard", "highres", "4k_desk",
                   "4k_theater", "ultrawide". Leave nil to keep the default.
     layout        1 = RealUI (DPS/Tank), 2 = RealUI-Healing.
     naga          true to enable bar 6 (the Naga bar), false to leave it off,
                   nil to not touch it. ]]--

local _, ns = ...
ns.profile = {
    export = [==[
PASTE THE EXPORT STRING HERE
]==],
    displayPreset = nil,
    layout = 1,
    naga = nil,
}
