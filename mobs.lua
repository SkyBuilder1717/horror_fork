local modname = core.get_current_modname()

local idle = {x = 0, y = 2, name = "idle"}
local scream = {x = 2.25, y = 2.29, name = "scream"}
local punch = {x = 2.5, y = 3.13, name = "punch"}
local walk = {x = 3.17, y = 4.17, name = "walk"}
local eat = {x = 4.33, y = 7.38, name = "eat"}
core.register_entity(modname .. ":dead_sam", {
    initial_properties = {
        visual = "mesh",
        mesh = modname .. "_dead_sam.gltf",
        textures = {modname .. "_dead_sam.png"},
        use_texture_alpha = true,
        physical = true,
        collide_with_objects = true,
        collisionbox = {
            -0.5, 0, -0.5,
            0.5, 4, 0.5
        },
        stepheight = 2,
        is_visible = true,
        makes_footstep_sound = true,
        damage_texture_modifier = "",
        groups = {fleshy = 0}
    },
    on_activate = function(self, staticdata, dtime_s)
        local pos = self.object:get_pos()
        local near_objects = core.get_objects_inside_radius(pos, 64)
        local player = nil
        for _, obj in pairs(near_objects) do
            if obj:is_valid() and obj:is_player() then
                player = obj
                break
            end
        end
        if player == nil then
            self.object:remove()
            return
        end
        self.player = player:get_player_name()
        self.object:set_animation(idle, 1, 0, true)
        core.after(math.random(30, 60), function()
            if self.object:is_valid() then
                self.object:remove()
            end
        end)
    end,
    on_step = function(self, dtime, moveresult)
        local player = core.get_player_by_name(self.player)
        if not player then
            self.object:remove()
            return
        end
        local player_pos = player:get_pos() + player:get_look_dir()
        local pos = self.object:get_pos()
        local vel = player_pos - pos

        local target_pos = player:get_pos()
        local self_pos = self.object:get_pos()
        local dir = {x = target_pos.x - self_pos.x, y = target_pos.y - self_pos.y, z = target_pos.z - self_pos.z}
        local length = math.sqrt(dir.x^2 + dir.y^2 + dir.z^2)
        if length > 0 then
            dir.x = dir.x / length
            dir.y = dir.y / length
            dir.z = dir.z / length
        end
        local yaw = math.atan2(dir.z, dir.x)
        local pitch = math.asin(-dir.y)
        self.object:set_yaw(yaw - 1.575)
        
        local dist = math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z)
        if not (self.animation_name == punch.name) then
            if not self.attacking then
                if dist < 8 then
                    self.attacking = true
                    return
                end
                if dist > 16 then
                    if self.object:is_valid() then
                        if ((not (self.animation_name == walk.name)) or (not self.animation_name)) and (player:is_valid() and (player:get_hp() > 0))then
                            self.object:set_animation(walk, 1, 0, true)
                            self.animation_name = walk.name
                        end
                        self.object:set_velocity(vector.new((vel.x / 4), -9, (vel.z / 4)))
                    end
                else
                    if self.object:is_valid() then
                        if (not (self.animation_name == idle.name)) or (not self.animation_name) then
                            if math.random(1,2) == 2 then
                                self.object:set_animation(idle, 1, 0, true)
                                self.animation_name = idle.name
                            else
                                self.object:set_animation(scream, 1, 0, false)
                                self.animation_name = scream.name
                            end
                        end
                        self.object:set_velocity(vector.new(0, -9, 0))
                    end
                end
            elseif not self.attackedless then
                if not self.attacked then
                    if dist < 2 then
                        self.attacked = true
                        return
                    end
                    if self.object:is_valid() then
                        if ((not (self.animation_name == walk.name)) or (not self.animation_name)) and (player:is_valid() and (player:get_hp() > 0)) then
                            self.object:set_animation(walk, 1, 0, true)
                            self.animation_name = walk.name
                        end
                        self.object:set_velocity(vector.new(vel.x, -9, vel.z))
                    end
                else
                    if self.object:is_valid() and (player:is_valid() and (player:get_hp() > 0)) and (dist < 2) then
                        self.object:set_animation(eat, 1, 0, false)
                        self.object:set_velocity(vector.new(0, -9, 0))
                        player:set_velocity(vector.new(0, 0, 0))
                        self.animation_name = eat.name
                        self.attackedless = true
                        player:set_physics_override({
                            speed = 0,
                            speed_walk = 0,
                            speed_climb = 0,
                            speed_crouch = 0,
                            speed_fast = 0,
                            jump = 0,
                            gravity = 0,
                            liquid_fluidity = 0,
                            liquid_fluidity_smooth = 0,
                            liquid_sink = 0,
                            acceleration_default = 0,
                            acceleration_air = 0,
                            acceleration_fast = 0,
                            sneak = false,
                            sneak_glitch = true,
                            new_move = false,
                        })
                        local ppos = table.copy(pos)
                        ppos.y = ppos.y + 2.5
                        vector.add(ppos, self.object:get_rotation())
                        player:move_to(ppos)
                        core.after(3.05, function()
                            if player:is_valid() then
                                player:set_physics_override({
                                    speed = 1,
                                    speed_walk = 1,
                                    speed_climb = 1,
                                    speed_crouch = 1,
                                    speed_fast = 1,
                                    jump = 1,
                                    gravity = 1,
                                    liquid_fluidity = 1,
                                    liquid_fluidity_smooth = 1,
                                    liquid_sink = 1,
                                    acceleration_default = 1,
                                    acceleration_air = 1,
                                    acceleration_fast = 1,
                                    sneak = true,
                                    sneak_glitch = false,
                                    new_move = true,
                                })
                            end
                            if self.object:is_valid() then
                                if (player:is_valid() and (player:get_hp() > 0)) then
                                    player:move_to(ppos)
                                    player:set_hp(0)
                                end
                                self.attacking = false
                                self.attacked = false
                                self.attackedless = false
                                self.object:set_velocity(vector.new(0, -9, 0))
                                self.object:set_animation(idle, 1, 0, true)
                                self.animation_name = idle.name
                            end
                        end)
                    end
                end
            end
        end
    end,
    on_punch = function(self, player)
        if not self.attacking then
            player:set_hp(0)
            if self.object:is_valid() then
                self.object:set_animation(punch, 1, 0, false)
            end
            core.after(0.42, function()
                if self.object:is_valid() then
                    self.object:set_animation(idle, 1, 0, true)
                end
            end)
        end
        return true
    end,
    on_deactivate = function(self, removal)
        if not removal then
            self.object:remove()
        end
    end,
})

core.register_entity(modname .. ":lightning", {
    initial_properties = {
        visual = "upright_sprite",
        textures = {modname .. "_lightning.png", modname .. "_lightning.png"},
        use_texture_alpha = true,
        visual_size = {x = 2, y = 64, z = 2},
        pointable = false,
        physical = false,
        is_visible = true,
        glow = 14,
    },
    on_activate = function(self, staticdata, dtime_s)
        self.object:set_rotation(vector.new(math.random(0, 50) / 100, math.random(0, 314) / 100, 0))
        core.sound_play({name = modname .. "_lightning", gain = 4, pitch = 0.2}, {pos = self.object:get_pos(), max_hear_distance = 64}, true)
        core.after(0.5, function()
            core.sound_play({name = modname .. "_thunder", gain = 4, pitch = 0.5}, {pos = self.object:get_pos(), max_hear_distance = 64}, true)
            if self.object:is_valid() then
                self.object:remove()
            end
        end)
    end,
    on_deactivate = function(self, removal)
        if not removal then
            self.object:remove()
        end
    end,
})

core.register_entity(modname .. ":the_entity", {
    initial_properties = {
        visual = "sprite",
        textures = {modname .. "_the_entity.png"},
        use_texture_alpha = true,
        visual_size = {x = 2, y = 4, z = 2},
        pointable = false,
        physical = true,
        is_visible = false,
        collide_with_objects = false,
        collisionbox = {
            -0.5, -2, -0.5,
            0.5, 2, 0.5
        },
        stepheight = 2,
        glow = 14,
    },
    on_activate = function(self, staticdata, dtime_s)
        local pos = self.object:get_pos()
        local near_objects = core.get_objects_inside_radius(pos, 64)
        local player = nil
        for _, obj in pairs(near_objects) do
            if obj:is_valid() and obj:is_player() then
                player = obj
                break
            end
        end
        if player == nil then
            self.object:remove()
            return
        end
        self.player = player:get_player_name()
        core.sound_play({name = modname .. "_the_entity_spawns", gain = 2}, {to_player = self.player}, true)
        self.sound = core.sound_play({name = modname .. "_breaths_1", gain = 2}, {to_player = self.player}, false)
        core.after(4, function()
            if self.object:is_valid() then
                local prop = self.object:get_properties()
                prop.is_visible = true
                core.after(1, function()
                    if self.object:is_valid() then
                        self.spawned = true
                    end
                end)
                self.object:set_properties(prop)
            end
        end)
    end,
    on_step = function(self, dtime, moveresult)
        if self.spawned then
            local player = core.get_player_by_name(self.player)
            if not player then
                self.object:remove()
                return
            end
            local player_pos = player:get_pos() + player:get_look_dir()
            local pos = self.object:get_pos()
            local vel = player_pos - pos
            local dist = math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z)
            if dist > 1 and not self.attacking then
                self.object:set_velocity(vector.new(vel.x / dist, vel.y / dist, vel.z / dist) * 10)
            else
                self.attacking = true
                local player_lighting = player:get_lighting()
                local exposure = player_lighting.exposure.exposure_correction
                player_lighting.exposure.exposure_correction = -4
                player:set_lighting(player_lighting)
                self.object:set_velocity(vector.new(0, 0, 0))
                core.after(0.5, function()
                    if self.object:is_valid() then
                        if player:is_valid() then
                            if math.random(1, 3) ~= 1 then
                                core.sound_play({name = modname .. "_the_entity_attack", gain = 2, pitch = 1.5}, {to_player = self.player}, true)
                                player:set_hp(0, "slane")
                            else
                                core.sound_play({name = modname .. "_the_entity_scream", gain = 2, pitch = 0.75}, {to_player = self.player}, true)
                            end
                            core.after(0.5, function()
                                if player:is_valid() then
                                    local player_lighting = player:get_lighting()
                                    player_lighting.exposure.exposure_correction = exposure
                                    player:set_lighting(player_lighting)
                                end
                            end)
                        end
                        self.object:remove()
                    end
                end)
            end
        end
    end,
    on_deactivate = function(self, removal)
        if self.sound then
            core.sound_stop(self.sound)
        end
        if not removal then
            self.object:remove()
        end
    end,
})

core.register_entity(modname .. ":chaser", {
    initial_properties = {
        visual = "sprite",
        textures = {modname .. "_chaser.png"},
        use_texture_alpha = true,
        visual_size = {x = 2, y = 4, z = 2},
        pointable = false,
        physical = true,
        is_visible = true,
        collide_with_objects = false,
        collisionbox = {
            -0.5, -2, -0.5,
            0.5, 2, 0.5
        },
        stepheight = 2,
        makes_footstep_sound = true,
        glow = 14,
    },
    on_activate = function(self, staticdata, dtime_s)
        local pos = self.object:get_pos()
        local near_objects = core.get_objects_inside_radius(pos, 64)
        local player = nil
        for _, obj in pairs(near_objects) do
            if obj:is_valid() and obj:is_player() then
                player = obj
                break
            end
        end
        if player == nil then
            self.object:remove()
            return
        end
        self.player = player:get_player_name()
        core.after(4 * math.random(1, 4), function()
            if self.object:is_valid() then
                self.attacking = true
                self.object:set_velocity(vector.new(0, 0, 0))

                core.sound_play({name = modname .. "_the_entity_attack", gain = 2, pitch = 0.5}, {to_player = self.player}, true)
                core.after(0.25, function()
                    if self.object:is_valid() then
                        self.object:set_pos(player:get_pos() + player:get_look_dir())
                    end
                end)
                core.after(1, function()
                    if self.object:is_valid() then
                        self.object:remove()
                        if player:is_valid() then
                            player:set_hp(0, "slain")
                        end
                    end
                end)
            end
        end)
    end,
    on_step = function(self, dtime, moveresult)
        if not self.attacking then
            local player = core.get_player_by_name(self.player)
            if not player then
                self.object:remove()
                return
            end
            if not self.whistled and math.random(1, 2) == 1 then
                core.sound_play({name = modname .. "_whistle_1", gain = 2, pitch = 2}, {pos = self.object:get_pos(), max_hear_distance = 64}, true)
                self.whistled = true
            end
            local player_pos = player:get_pos() + player:get_look_dir()
            local pos = self.object:get_pos()
            local vel = player_pos - pos
            local dist = math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z)
            if dist > 10 then
                self.object:set_velocity(vector.new((vel.x / dist) * 4, -9, (vel.z / dist) * 4))
            else
                self.object:set_velocity(vector.new(0, -9, 0))
            end
        end
    end,
    on_deactivate = function(self, removal)
        if not removal then
            self.object:remove()
        end
    end,
})

core.register_entity(modname .. ":reaper", {
    initial_properties = {
        visual = "sprite",
        textures = {modname .. "_reaper.png"},
        use_texture_alpha = true,
        visual_size = {x = 2, y = 4, z = 2},
        pointable = false,
        physical = false,
        is_visible = true,
        collide_with_objects = false,
        collisionbox = {
            -0.5, -2, -0.5,
            0.5, 2, 0.5
        },
        glow = 14,
    },
    on_activate = function(self, staticdata, dtime_s)
        local pos = self.object:get_pos()
        local near_objects = core.get_objects_inside_radius(pos, 64)
        local player = nil
        for _, obj in pairs(near_objects) do
            if obj:is_valid() and obj:is_player() then
                player = obj
                break
            end
        end
        if player == nil then
            self.object:remove()
            return
        end
        self.player = player:get_player_name()
        core.after(16, function()
            if self.object:is_valid() then
                if math.random(1, 5) ~= 1 then
                    self.object:remove()
                else
                    core.sound_play({name = modname .. "_the_entity_attack", gain = 2, pitch = 0.5}, {to_player = self.player}, true)
                    core.after(0.25, function()
                        if self.object:is_valid() then
                            self.object:set_pos(player:get_pos() + player:get_look_dir())
                        end
                    end)
                    core.after(1, function()
                        if self.object:is_valid() then
                            self.object:remove()
                            if player:is_valid() then
                                player:set_hp(0, "reaped")
                            end
                        end
                    end)
                end
            end
        end)
    end,
    on_step = function(self, dtime, moveresult)
        local player = core.get_player_by_name(self.player)
        if not player then
            self.object:remove()
            return
        end
        local player_pos = player:get_pos() + player:get_look_dir()
        local pos = self.object:get_pos()
        local vel = player_pos - pos
        local dist = math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z)
        if dist > 16 then
            self.object:set_velocity(vector.new(vel.x / dist, vel.y / dist, vel.z / dist) * 4)
        else
            self.object:set_velocity(vector.new(0, 0, 0))
        end
    end,
    on_deactivate = function(self, removal)
        local pos = self.object:get_pos()
        core.add_entity(pos, modname .. ":lightning")
        if not removal then
            self.object:remove()
        end
    end,
})

core.register_entity(modname .. ":lord_x", {
    initial_properties = {
        visual = "sprite",
        textures = {modname .. "_lord_x.png"},
        use_texture_alpha = true,
        visual_size = {x = 2, y = 4, z = 2},
        pointable = false,
        physical = true,
        is_visible = true,
        collide_with_objects = false,
        collisionbox = {
            -0.5, -2, -0.5,
            0.5, 2, 0.5
        },
        stepheight = 2,
        makes_footstep_sound = true,
        glow = 14,
    },
    on_activate = function(self, staticdata, dtime_s)
        local pos = self.object:get_pos()
        local near_objects = core.get_objects_inside_radius(pos, 64)
        local player = nil
        for _, obj in pairs(near_objects) do
            if obj:is_valid() and obj:is_player() then
                player = obj
                break
            end
        end
        if player == nil then
            self.object:remove()
            return
        end
        self.player = player:get_player_name()
        core.sound_play({name = modname .. "_laugh", gain = 2}, {to_player = self.player}, true)
        core.after(4 * math.random(1, 4), function()
            if self.object:is_valid() then
                self.attacking = true
                self.object:set_velocity(vector.new(0, 0, 0))
                local id = player:hud_add({
                    type = "image",
                    text = modname .. "_lord_x_jumpscare.png",
                    position = {x = 0.5, y = 0.5},
                    scale = {x = 18, y = 18}
                })
                core.after(0.25, function()
                    if self.object:is_valid() then
                        self.object:set_pos(player:get_pos() + player:get_look_dir())
                    end
                end)
                core.sound_play({name = modname .. "_the_entity_scream", gain = 2, pitch = 0.75}, {to_player = self.player}, true)
                core.after(1, function()
                    if self.object:is_valid() then
                        self.object:remove()
                        if player:is_valid() then
                            player:hud_remove(id)
                            player:set_hp(0, "eaten")
                        end
                    end
                end)
            end
        end)
    end,
    on_step = function(self, dtime, moveresult)
        if not self.attacking then
            local player = core.get_player_by_name(self.player)
            if not player then
                self.object:remove()
                return
            end
            local player_pos = player:get_pos() + player:get_look_dir()
            local pos = self.object:get_pos()
            local vel = player_pos - pos
            local dist = math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z)
            if dist > 1 then
                self.object:set_velocity(vector.new(vel.x / dist, vel.y / dist, vel.z / dist) * 10)
            else
                if self.object:is_valid() then
                    self.attacking = true
                    self.object:set_velocity(vector.new(0, 0, 0))
                    local id = player:hud_add({
                        type = "image",
                        text = modname .. "_lord_x_jumpscare.png",
                        position = {x = 0.5, y = 0.5},
                        scale = {x = 18, y = 18}
                    })
                    core.after(0.25, function()
                        if self.object:is_valid() then
                            self.object:set_pos(player:get_pos() + player:get_look_dir())
                        end
                    end)
                    core.sound_play({name = modname .. "_the_entity_scream", gain = 2, pitch = 0.75}, {to_player = self.player}, true)
                    core.after(1, function()
                        if self.object:is_valid() then
                            self.object:remove()
                            if player:is_valid() then
                                player:hud_remove(id)
                                player:set_hp(0, "eaten")
                            end
                        end
                    end)
                end
            end
        end
    end,
    on_deactivate = function(self, removal)
        if not removal then
            self.object:remove()
        end
    end,
})

core.register_entity(modname .. ":shadow", {
    initial_properties = {
        visual = "sprite",
        textures = {modname .. "_shadow.png"},
        use_texture_alpha = true,
        visual_size = {x = 2, y = 4, z = 2},
        physical = true,
        is_visible = true,
        collide_with_objects = false,
        collisionbox = {
            -0.5, -2, -0.5,
            0.5, 2, 0.5
        },
        stepheight = 2,
        makes_footstep_sound = true,
        glow = 14,
    },
    on_activate = function(self, staticdata, dtime_s)
        local pos = self.object:get_pos()
        local near_objects = core.get_objects_inside_radius(pos, 64)
        local player = nil
        for _, obj in pairs(near_objects) do
            if obj:is_valid() and obj:is_player() then
                player = obj
                break
            end
        end
        if player == nil then
            self.object:remove()
            return
        end
        self.player = player:get_player_name()
        horror_fork.shadow[self.player] = true
        core.after(10 * math.random(2, 6), function()
            if self.object:is_valid() then
                self.object:remove()
                horror_fork.shadow[self.player] = nil
            end
        end)
    end,
    on_step = function(self, dtime, moveresult)
        local player = core.get_player_by_name(self.player)
        if not player then
            self.object:remove()
            return
        end
        local player_pos = player:get_pos() + player:get_look_dir()
        local pos = self.object:get_pos()
        local vel = player_pos - pos
        local dist = math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z)
        local speed = dist / 4
        if dist < 3 and not self.jumpscared then
            if self.object:is_valid() then
                self.jumpscared = true
                self.object:set_velocity(vector.new(0, 0, 0))
                local id
                if player:is_valid() then
                    id = player:hud_add({
                        type = "image",
                        text = modname .. "_shadow_jumpscare.png",
                        position = {x = 0.5, y = 0.5},
                        scale = {x = 18, y = 18}
                    })
                end
                core.sound_play({name = modname .. "_shadow_attack", gain = 4}, {to_player = self.player}, true)
                core.after(0.25, function()
                    if self.object:is_valid() then
                        self.object:set_pos(player:get_pos() + player:get_look_dir())
                    end
                end)
                core.after(1, function()
                    if self.object:is_valid() then
                        self.object:remove()
                        if player:is_valid() then
                            if id then
                                player:hud_remove(id)
                            end
                            player:set_hp(0, "slain")
                            horror_fork.shadow[self.player] = nil
                        end
                    end
                end)
            end
            return
        end
        if dist > 31 then
            self.object:set_velocity(vector.new((vel.x / dist) * speed, -9, (vel.z / dist) * speed))
        elseif dist < 29 then
            self.object:set_velocity(vector.new(-((vel.x / dist) ) * speed), -9, -((vel.z / dist) * speed))
        else
            self.object:set_velocity(vector.new(0, -9, 0))
        end
    end,
    on_deactivate = function(self, removal)
        if not removal then
            self.object:remove()
        end
    end,
})

core.register_entity(modname .. ":girl", {
    initial_properties = {
        visual = "sprite",
        textures = {modname .. "_girl.png"},
        use_texture_alpha = true,
        damage_texture_modifier = "",
        visual_size = {x = 2, y = 4, z = 2},
        physical = true,
        is_visible = true,
        collide_with_objects = false,
        collisionbox = {
            -0.5, -2, -0.5,
            0.5, 2, 0.5
        },
        stepheight = 2,
        makes_footstep_sound = true,
        glow = 14,
    },
    on_activate = function(self, staticdata, dtime_s)
        core.after(10 * math.random(2, 4), function()
            if self.object:is_valid() then
                self.object:remove()
            end
        end)
    end,
    on_punch = function(self, player)
        self.player = player:get_player_name()
        horror_fork.girl[self.player] = true
        core.sound_play({name = modname .. "_the_entity_attack", gain = 2, pitch = 1.5}, {to_player = self.player}, true)
        core.sound_play({name = modname .. "_girl_ow", gain = 2}, {to_player = self.player}, true)
        self.object:set_properties({textures = {modname .. "_girl_angry.png"}})
        core.after(1, function()
            core.after(15, function()
                local ppos = player:get_pos()
                local girl = core.add_entity(horror_fork.generate_pos(ppos, 16), modname .. ":girl_angry")
                girl:set_properties({player = self.player})
            end)
            if self.object:is_valid() then
                self.object:remove()
            end
        end)
        return true
    end,
    on_step = function(self, dtime, moveresult)
        self.object:set_velocity(vector.new(0, -9, 0))
    end,
    on_deactivate = function(self, removal)
        if not removal then
            self.object:remove()
        end
    end,
})

core.register_entity(modname .. ":girl_angry", {
    initial_properties = {
        visual = "sprite",
        textures = {modname .. "_girl_angry.png"},
        use_texture_alpha = true,
        visual_size = {x = 2, y = 4, z = 2},
        pointable = false,
        physical = true,
        is_visible = true,
        collide_with_objects = false,
        collisionbox = {
            -0.5, -2, -0.5,
            0.5, 2, 0.5
        },
        stepheight = 2,
        makes_footstep_sound = true,
        glow = 14,
    },
    on_activate = function(self)
        local pos = self.object:get_pos()
        local near_objects = core.get_objects_inside_radius(pos, 64)
        local player = nil
        for _, obj in pairs(near_objects) do
            if obj:is_valid() and (obj:is_player() and horror_fork.girl[obj:get_player_name()]) then
                player = obj
                break
            end
        end
        if player == nil then
            self.object:remove()
            return
        end
        self.player = player:get_player_name()
        core.after(5, function()
            core.after(0.25, function()
                if self.object:is_valid() then
                    self.object:set_pos(player:get_pos() + player:get_look_dir())
                end
            end)
            core.sound_play({name = modname .. "_the_entity_scream", gain = 3, pitch = 1.5}, {to_player = self.player}, true)
            core.after(1, function()
                if self.object:is_valid() then
                    self.object:remove()
                    if player:is_valid() then
                        player:set_hp(0, "slane")
                        horror_fork.girl[self.player] = nil
                    end
                end
            end)
        end)
    end,
    on_step = function(self, dtime, moveresult)
        if not self.attacking then
            local player = core.get_player_by_name(self.player)
            if not player then
                self.object:remove()
                return
            end
            local player_pos = player:get_pos() + player:get_look_dir()
            local pos = self.object:get_pos()
            local vel = player_pos - pos
            local dist = math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z)
            if dist > 1 then
                self.object:set_velocity(vector.new((vel.x / dist) * 4, -9, (vel.z / dist) * 4))
            else
                if self.object:is_valid() then
                    self.attacking = true
                    self.object:set_velocity(vector.new(0, -9, 0))
                end
            end
        end
    end,
    on_deactivate = function(self, removal)
        if not removal then
            self.object:remove()
        end
    end,
})