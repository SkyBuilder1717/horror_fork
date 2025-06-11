local modname = core.get_current_modname()

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
                local ratio = math.abs(math.max(vel.x, vel.y, vel.z))
                vel.x = (vel.x / ratio) * 10
                vel.y = (vel.y / ratio) * 10
                vel.z = (vel.z / ratio) * 10
                self.object:set_velocity(vel)
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
                local ratio = math.abs(math.max(vel.x, vel.y, vel.z))
                vel.x = (vel.x / ratio) * 4
                vel.y = -9
                vel.z = (vel.z / ratio) * 4

                self.object:set_velocity(vel)
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
            local ratio = math.abs(math.max(vel.x, vel.y, vel.z))
            vel.x = (vel.x / ratio) * 4
            vel.y = (vel.y / ratio) * 4
            vel.z = (vel.z / ratio) * 4
            self.object:set_velocity(vel)
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
                local ratio = math.abs(math.max(vel.x, vel.y, vel.z))
                vel.x = (vel.x / ratio) * 10
                vel.y = (vel.y / ratio) * 10
                vel.z = (vel.z / ratio) * 10
                self.object:set_velocity(vel)
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
            local ratio = math.abs(math.max(vel.x, vel.y, vel.z))
            vel.x = (vel.x / ratio) * speed
            vel.y = -9
            vel.z = (vel.z / ratio) * speed
            self.object:set_velocity(vel)
        elseif dist < 29 then
            local ratio = math.abs(math.max(vel.x, vel.y, vel.z))
            vel.x = -(vel.x / ratio) * speed
            vel.y = -9
            vel.z = -(vel.z / ratio) * speed
            self.object:set_velocity(vel)
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
                local ratio = math.abs(math.max(vel.x, vel.y, vel.z))
                vel.x = (vel.x / ratio) * 4
                vel.y = -9
                vel.z = (vel.z / ratio) * 4
                self.object:set_velocity(vel)
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