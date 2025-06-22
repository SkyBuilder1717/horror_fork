local modname = core.get_current_modname()
local worldpath = core.get_worldpath() .. "/"
local filename = "horror_fork.json"

local function read_file(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local txt = f:read("*all")
    f:close()
    return txt
end

local function write_file(path, content)
    local f = io.open(path, "w")
    f:write(content)
    f:close()
end

function horror_fork.save_data()
    local tbl = horror_fork.save
    local content = core.write_json(tbl)
    local path = worldpath .. filename
    write_file(path, content)
end

function horror_fork.load_save()
    local content = read_file(worldpath .. filename)
    if not content then
        return false
    end
    local tbl = core.parse_json(content)
    if not tbl then
        return false
    end
    horror_fork.save = tbl
    return true
end

local spooks = {
    {name = modname .. "_the_entity_attack", pitch = 1.5},
    {name = modname .. "_whistle_1", pitch = 1.5},
    {name = modname .. "_whistle_2", pitch = 0.75},
    {name = modname .. "_laugh", gain = 2},
}

local spook_mobs = {
    modname .. ":the_entity",
    modname .. ":chaser",
    modname .. ":reaper"
}

function horror_fork.generate_pos(ppos, dist)
    local randomx = math.random(-dist, dist)
    local randomz = math.random(-dist, dist)
    local pos = vector.new(randomx + ppos.x, math.random(-math.floor(dist / 8), dist) + ppos.y, randomz + ppos.z)
    local distance_x = math.abs(pos.x - ppos.x)
    local distance_z = math.abs(pos.z - ppos.z)
    if distance_x >= math.round(dist / 4) then
        pos.x = pos.x + math.round(dist / 4)
    end
    if distance_z >= math.round(dist / 4) then
        pos.z = pos.z + math.round(dist / 4)
    end
    return pos
end

local function timer(name)
    local player = core.get_player_by_name(name)
    if not player then return end
    if not core.find_node_near(player:get_pos(), 5, {modname .. ":campfire"}, true) then
        if (horror_fork.save.timers[name] % 2 == 0) then
            core.sound_play({name = modname .. "_tick_1", pitch = 0.75}, {to_player = name}, true)
        else
            core.sound_play({name = modname .. "_tick_2", pitch = 0.75}, {to_player = name}, true)
        end
        horror_fork.save.timers[name] = horror_fork.save.timers[name] - 1
    end
    horror_fork.save_data()
    if horror_fork.save.timers[name] > 0 then
        core.after(1, function()
            timer(name)
        end)
    else
        local mob = math.random(1, #spook_mobs)
        if mob == 2 then
            local player = core.get_player_by_name(name)
            local id = player:hud_add({
                type = "image",
                text = modname .. "_chaser_jumpscare.png",
                position = {x = 0.5, y = 0.5},
                scale = {x = 18, y = 18}
            })
            core.sound_play({name = modname .. "_laugh", gain = 2}, {to_player = name}, true)
            core.after(0.5, function()
                if player:is_valid() then
                    player:hud_remove(id)
                end
            end)
        end

        core.after(10, function()
            local ppos = player:get_pos()
            core.add_entity(horror_fork.generate_pos(ppos, 16), spook_mobs[mob])
            horror_fork.save.timers[name] = nil
            horror_fork.save_data()
        end)
    end
end

local function spook(num)
    for _, player in pairs(core.get_connected_players()) do
        local name = player:get_player_name()
        local ppos = player:get_pos()
        local time = core.get_timeofday()
        local light = core.get_node_light(ppos)
        local pos = horror_fork.generate_pos(ppos, 16)
        local params = {to_player = name, max_hear_distance = 32, pos = pos}
        local safe = core.find_node_near(ppos, 5, {modname .. ":campfire"}, true)
        local biome = core.get_biome_name(core.get_biome_data(ppos).biome)
        if (time <= 0.2 or time >= 0.8) and ((not horror_fork.save.timers[name]) and (not horror_fork.lord_x[name]) and (not horror_fork.shadow[name]) and (not horror_fork.girl[name]))then
            local num = math.random(1, 100)
            if num <= 30 then
                if not safe then
                    if num < 2 then
                        local random = math.random(1, 3)
                        if random == 3 then
                            horror_fork.lord_x[name] = true
                            local id = player:hud_add({
                                type = "image",
                                text = modname .. "_lord_x_1.png",
                                position = {x = 0.5, y = 0.5},
                                scale = {x = 18, y = 18}
                            })
                            core.sound_play({name = modname .. "_lord_x_1", gain = 0.75}, {to_player = name}, true)
                            core.after(4, function()
                                if player:is_valid() then
                                    player:hud_remove(id)
                                end
                                core.after(60, function()
                                    ppos = player:get_pos()
                                    if not core.find_node_near(ppos, 5, {modname .. ":campfire"}, true) then
                                        local id = player:hud_add({
                                            type = "image",
                                            text = modname .. "_lord_x_2.png",
                                            position = {x = 0.5, y = 0.5},
                                            scale = {x = 18, y = 18}
                                        })
                                        core.sound_play({name = modname .. "_lord_x_2", gain = 0.75}, {to_player = name}, true)
                                        core.after(5, function()
                                            if player:is_valid() then
                                                player:hud_remove(id)
                                            end
                                            core.after(60, function()
                                                ppos = player:get_pos()
                                                if not core.find_node_near(ppos, 5, {modname .. ":campfire"}, true) then
                                                    local id = player:hud_add({
                                                        type = "image",
                                                        text = modname .. "_lord_x_3.png",
                                                        position = {x = 0.5, y = 0.5},
                                                        scale = {x = 18, y = 18}
                                                    })
                                                    core.sound_play({name = modname .. "_lord_x_3", gain = 0.75}, {to_player = name}, true)
                                                    core.after(6, function()
                                                        if player:is_valid() then
                                                            player:hud_remove(id)
                                                        end
                                                        horror_fork.lord_x[name] = nil
                                                        core.add_entity(pos, modname .. ":lord_x")
                                                    end)
                                                else
                                                    horror_fork.lord_x[name] = nil
                                                end
                                            end)
                                        end)
                                    else
                                        horror_fork.lord_x[name] = nil
                                    end
                                end)
                            end)
                        elseif random == 2 then
                            local random2 = math.random(1, 3)
                            if random2 == 3 then
                                core.add_entity(pos, modname .. ":girl")
                            elseif random2 == 2 then
                                pos = horror_fork.generate_pos(ppos, 32)
                                core.add_entity(pos, modname .. ":dead_sam")
                            else
                                pos = horror_fork.generate_pos(ppos, 32)
                                core.add_entity(pos, modname .. ":shadow")
                            end
                        else
                            horror_fork.save.timers[name] = 60
                            timer(name)
                        end
                    elseif num <= 5 then
                        params.max_hear_distance = 32
                        core.sound_play({name = modname .. "_the_entity_attack", gain = 1.5}, params, true)
                    elseif num <= 7 then
                        local id = player:hud_add({
                            type = "image",
                            text = modname .. "_chaser_jumpscare.png",
                            position = {x = 0.5, y = 0.5},
                            scale = {x = 18, y = 18}
                        })
                        core.sound_play({name = modname .. "_the_entity_attack", gain = 1.5}, {to_player = name}, true)
                        core.after(0.15, function()
                            if player:is_valid() then
                                player:hud_remove(id)
                            end
                        end)
                    elseif num <= 15 then
                        if (light < 7) or (ppos.y < -30) then
                            core.sound_play({name = modname .. "_cave_sound_" ..  math.random(1, 8), gain = 2.5}, {to_player = name}, true)
                        end
                    elseif num <= 20 and (ppos.y >= 0) then
                        if math.random(1, 2) == 2 then
                            core.sound_play(modname .. "_breath_" ..  math.random(1, 3), params, true)
                        else
                            local spook_selected = spooks[math.random(1, #spooks)]
                            core.sound_play(spook_selected, params, true)
                        end
                    elseif num <= 25 then
                        ppos.y = ppos.y - 1
                        local node = core.get_node(ppos)
                        ppos.y = ppos.y + 1
                        for i = 1, math.random(2, 6) do
                            core.after(i, function()
                                local def = core.registered_nodes[node.name].sounds
                                pos = horror_fork.generate_pos(ppos, 8, false)
                                params.pos = pos
                                if def and def.footstep then
                                    core.sound_play(def.footstep, params, true)
                                end
                            end)
                        end
                    else
                        if (string.find(biome, "beach") or string.find(biome, "dunes")) then
                            core.sound_play({name = modname .. "_beach", gain = 0.5, pitch = 0.75}, {to_player = name}, true)
                        else
                            core.sound_play({name = modname .. "_wind_" ..  math.random(1, 3), gain = 0.5, pitch = 0.75}, {to_player = name}, true)
                        end
                    end
                end
            end
        else
            local num = math.random(1, 90)
            if num <= 30 then
                if num <= 10 then
                    if (light < 7) or (ppos.y < -30) then
                        core.sound_play({name = modname .. "_cave_sound_" ..  math.random(1, 8), gain = 2.5}, {to_player = name}, true)
                    end
                elseif num <= 15 and (ppos.y >= 0) then
                    core.sound_play(modname .. "_breath_" ..  math.random(1, 3), params, true)
                elseif num <= 20 then
                    ppos.y = ppos.y - 1
                    local node = core.get_node(ppos)
                    ppos.y = ppos.y + 1
                    for i = 1, math.random(2, 6) do
                        core.after(i, function()
                            local def = core.registered_nodes[node.name].sounds
                            pos = horror_fork.generate_pos(ppos, 8, false)
                            params.pos = pos
                            if def and def.footstep then
                                core.sound_play(def.footstep, params, true)
                            end
                        end)
                    end
                else
                    if (string.find(biome, "beach") or string.find(biome, "dunes")) then
                        core.sound_play({name = modname .. "_beach", gain = 0.75, pitch = 0.75}, {to_player = name}, true)
                    else
                        core.sound_play({name = modname .. "_wind_" ..  math.random(1, 3), gain = 0.75, pitch = 0.75}, {to_player = name}, true)
                    end
                end
            end
        end
    end
    core.after(5, spook)
end

core.register_on_mods_loaded(function()
    horror_fork.load_save()
    if not horror_fork.save.timers then
        horror_fork.save.timers = {}
    end
    core.after(5, spook)
end)

core.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if horror_fork.save and horror_fork.save.timers and horror_fork.save.timers[name] then
        timer(name)
    end
end)