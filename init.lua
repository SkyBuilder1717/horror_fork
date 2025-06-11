horror_fork = {
    save = {
        timers = {}
    },
    lord_x = {},
    girl = {},
    shadow = {}
}

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

dofile(modpath .. "/mobs.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/api.lua")