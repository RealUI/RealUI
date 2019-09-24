cargBags_Nivaya
======

Extended modifications for the RealUI implementation of cargBags_Nivaya


Additional Automatic Loot Filters
-----------------------
Custom bags should be created for each type to automatically sort the 
appropriate items into them using the /cbniv addbag **NAME** command. 
Names are case-sensitive and localized.

  - **Tradeskill: Parts** (various parts used for various profs)
  - **Tradeskill: Jewelcrafting** (Jewelcrafting supplies)
  - **Tradeskill: Cloth** (Tailoring supplies)
  - **Tradeskill: Leatherworking** (Leatherworking supplies)
  - **Tradeskill: Metal & Stone** (Metal/Stone reagents)
  - **Tradeskill: Cooking** (Cooking supplies)
  - **Tradeskill: Herb** (Herbalism reagents)
  - **Tradeskill: Elemental** (Elemental reagents)
  - **Tradeskill: Enchanting** (Enchanting supplies)
  - **Tradeskill: Inscription** (Inscription supplies)
  - **Mechagon Tinkering** (reagents used in tinkering)
  - **Travel & Teleportation** (items used for travel or that teleport the player)
  - **Archaeology** (items used in Archaeology)
  - **Tabards** (tabards)

Additional sortable columns
-----------------------
A third sortable column has been added to reduce the amount of space previously 
taken up by the standard two-column design that ships with RealUI.

Debugging
-----------------------
**/cbniv ? item** can be used to output detailed information about an item in 
your bags (useful for debugging purposes).