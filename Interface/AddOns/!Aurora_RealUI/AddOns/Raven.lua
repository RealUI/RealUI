local _, mods = ...

mods["PLAYER_LOGIN"]["Raven"] = function(self, F, C)
    --print("Raven", F, C)
    Raven.db.global.Defaults.timeFont = RealUI:Font(true)
    Raven.db.global.Defaults.labelFont = RealUI:Font(true)
    Raven.db.global.Defaults.iconFont = RealUI:Font(true)
    Raven:UpdateAllBarGroups()
end
