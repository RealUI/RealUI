local _G = _G
-----------------------------------------------------------------------
-- Check if we already exist in the global space
-- If we do - bail out early.
if _G.RealUI_PreLoads then return end
RealUI_PreLoads = true
C_AddOns.LoadAddOn("Blizzard_Deprecated")
print("RealUI_PreLoads loaded")