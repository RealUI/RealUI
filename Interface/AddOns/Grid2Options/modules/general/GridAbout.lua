
local L = Grid2Options.L
local options = { d1 = { type = "description", fontSize = "medium", name = L["GRID2_DESC"] } }
Grid2Options:MakeTitleOptions( options, Grid2.versionstring, L["GRID2_WELCOME"], nil, "Interface\\Addons\\Grid2\\media\\icon" )
Grid2Options:AddGeneralOptions( "About", nil, options )

