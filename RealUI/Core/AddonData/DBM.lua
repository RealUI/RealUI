local _, private = ...

private.AddOns["DBM-StatusBarTimers"] = function()
    _G.DBT_AllPersistentOptions = {
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
