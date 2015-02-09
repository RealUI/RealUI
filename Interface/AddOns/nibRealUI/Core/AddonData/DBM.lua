local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

nibRealUI["LoadAddOnData_DBM-StatusBarTimers"] = function()
    DBT_AllPersistentOptions = {
        ["Default"] = {
            ["DBM"] = {
                ["HugeTimerY"] = 300,
                ["HugeBarXOffset"] = 0,
                ["Scale"] = 1,
                ["TimerX"] = 400,
                ["TimerPoint"] = "CENTER",
                ["HugeBarYOffset"] = 9,
                ["HugeScale"] = 1,
                ["HugeTimerPoint"] = "CENTER",
                ["BarYOffset"] = 9,
                ["HugeTimerX"] = -400,
                ["TimerY"] = 300,
                ["BarXOffset"] = 0,
            },
        },
    }
end
