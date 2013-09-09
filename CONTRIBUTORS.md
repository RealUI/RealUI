Read this if adding/making changes to RealUI.

AddOn modifications
--------

  - Aurora
    - Avoid making changes to this addon if possible. Quite a few modifications have been made already to make it compatible with RealUI.

  - Grid2\Modules\IndicatorText.lua (added code to hide Text shadow)
    - function Text_Create
      - Text:SetShadowOffset(0,0)



SavedVariables data
--------

All SV data is stored in nibRealUI\Core\AddonData\
This data gets loaded upon first time install of RealUI

If you need to make changes to SV data (ie You need to change a Grid2 setting), then use the MiniPatch system outlined below



Mini Patches
--------

If changes are made straight to the nibRealUI code and no SV data needs to be changed, then a Mini Patch will not be required.

Mini Patches allow the modification of SV data without the user needing to update/replace any SV files.

Try to avoid SV changes / Mini Patches if possible. However, sometimes it needs to be done.



To create a new Mini Patch:
  1. nibRealUI\Core\Settings.lua
    - add revision number to - local MiniPatches = {#,#,#,etc} 

  2. nibRealUI\Core\MiniPatches.lua
    - add data (see code for examples)
    
  3. Log in to WoW and test changes - you should get a Mini Patch prompt
