local modname = core.get_current_modname()
local S = core.get_translator(modname)

core.register_node(modname .. ":campfire", {
    description = S("Campfire"),
	tiles = {modname .. "_campfire.png"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 1, wood = 1},
	drawtype = "mesh",
    mesh = modname .. "_campfire.obj",
	paramtype = "light",
    light_source = 9,
    walkable = false,
    damage_per_second = 1
})

core.register_craft({
    output = modname .. ":campfire",
    type = "shaped",
    recipe = {
        {"", "default:coal_lump", ""},
        {"group:tree", "group:tree", "group:tree"}
    }
})

core.register_craft({
    recipe = modname .. ":campfire",
    type = "fuel",
    burntime = 30,
})

core.register_abm({
    nodenames = {modname .. ":campfire"},
    interval = 1,
    chance = 1,
    action = function(pos)
        pos.y = pos.y + 0.15
        if math.random(1, 10) == 1 then
            core.sound_play({name = modname .. "_campfire", pitch = 1.25, gain = 4}, {pos = pos, max_hear_distance = 8}, true)
        end
        core.add_particle({
            pos = pos,
            expirationtime = 1,
            vertical = true,
            size = 8,
            texture = "fire_basic_flame_animated.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 1
            },
            glow = 14,
        })
        core.add_particle({
            pos = pos,
            velocity = {x=0, y=math.random(0.7, 1.15), z=0},
            expirationtime = 15,
            collisiondetection = true,
            size = math.random(5, 7),
            texture = "smoke_puff.png",
        })
    end,
})