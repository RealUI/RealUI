Read this if adding/making changes to RealUI.

AddOn modifications
-------------------

  - FreebTip
    - All changes outside the config are tagged with xRUI

  - EasyMail
    - Added Postmaster



Git
---

RealUI uses the [GitFlow](http://danielkummer.github.io/git-flow-cheatsheet/) workflow, please be familiar with this before making changes.

The goal for this setup is to ensure that `master` is always representative of what is up on WoW Interface. It allows for "hotfixes" to `master` without having to maneuver around buggy/unfinished features.

For Mac and Windows users, [SourceTree](http://www.sourcetreeapp.com/) has built-in support for GitFlow.



SavedVariables data
-------------------

All SV data is stored in `nibRealUI\Core\AddonData\`
This data gets loaded upon first time install of RealUI

If you need to make changes to SV data (ie You need to change a Grid2 setting), then use the MiniPatch system outlined below



Mini Patches
------------

If changes are made straight to the nibRealUI code and no SV data needs to be changed, then a Mini Patch will not be required.

Mini Patches allow the modification of SV data without the user needing to update/replace any SV files.

Try to avoid SV changes / Mini Patches if possible. However, sometimes it needs to be done.


To create a new Mini Patch:
  1. Add a new function to `nibRealUI\Core\MiniPatches.lua`
  2. Update addon versions (see Version Changes)
  3. Log in to WoW and test changes - you should get a Mini Patch prompt



Version Changes
---------------

Every release needs to have the version updated.

If you're on Windows Vista or newer, run update.ps1 and follow the prompt. Otherwise follow these steps:
  1. Open update.ps1 in an editor, and look for `$addons = @(...`
  2. Find each file and update the old version to the new version for each one.
