local addonName, addon = ...
local L = addon.L

addon.defaults = {
    char = {
        blacklist = {},
        blizzframes = {
            PlayerFrame = true,
            PetFrame = true,
            TargetFrame = true,
            TargetFrameToT = true,
            FocusFrame = true,
            FocusFrameToT = true,
            arena = true,
            party = true,
            compactraid = true,
            compactparty = true,
            boss = true,
        },
		stopcastingfix = false,
    },
    profile = {
        bindings = {
        },
    },
}
