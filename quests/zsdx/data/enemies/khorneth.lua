-- The boss Khorneth from @PyroNet.
-- Khorneth has two blades that must be destroyed first.

main_sprite = nil
left_blade_sprite = nil
right_blade_sprite = nil

-- State
left_blade_life = 4
right_blade_life = 4
blade_attack = false

function event_appear()

  -- set the properties
  sol.enemy.set_life(5)
  sol.enemy.set_damage(2)
  sol.enemy.set_pushed_back_when_hurt(false)
  main_sprite = sol.enemy.create_sprite("enemies/khorneth")
  left_blade_sprite = sol.enemy.create_sprite("enemies/khorneth_left_blade")
  right_blade_sprite = sol.enemy.create_sprite("enemies/khorneth_right_blade")
  sol.enemy.set_size(40, 48)
  sol.enemy.set_origin(20, 25)
  sol.enemy.set_invincible()
  sol.enemy.set_attack_consequence_sprite(left_blade_sprite, "sword", "custom")
  sol.enemy.set_attack_consequence_sprite(right_blade_sprite, "sword", "custom")

  -- when a blade sprite has the same animation than the main sprite, synchronize their frames
  left_blade_sprite:synchronize(main_sprite)
  right_blade_sprite:synchronize(main_sprite)
end

function event_restart()

  -- set the movement
  local m = sol.movement.create("random_path")
  m:set_speed(48)
  sol.enemy.start_movement(m)

  -- schedule a blade attack
  if has_blade() then
    local delay = 1000 * (1 + math.random(4))
    sol.main:start_timer(delay, start_blade_attack)
    blade_attack = false
  end
end

function has_left_blade()
  return left_blade_life > 0
end

function has_right_blade()
  return right_blade_life > 0
end

function has_blade()
  return has_left_blade() or has_right_blade()
end

-- The enemy receives an attack whose consequence is "custom"
function event_custom_attack_received(attack, sprite)

  if has_left_blade()
    and sprite == left_blade_sprite
    and sprite:get_animation() ~= "stopped" then  

    sprite:set_animation("hurt")
    main_sprite:set_animation("stopped")
    if has_right_blade() then
      right_blade_sprite:set_animation("stopped")
    end
    sol.enemy.stop_movement()
    sol.audio.play_sound("boss_hurt")
    left_blade_life = left_blade_life - 1
    sol.main:start_timer(400, stop_hurting_left_blade)

  elseif has_right_blade()
    and sprite == right_blade_sprite
    and sprite:get_animation() ~= "stopped" then  

    sprite:set_animation("hurt")
    main_sprite:set_animation("stopped")
    if has_left_blade() then
      left_blade_sprite:set_animation("stopped")
    end
    sol.enemy.stop_movement()
    sol.audio.play_sound("boss_hurt")
    right_blade_life = right_blade_life - 1
    sol.main:start_timer(400, stop_hurting_right_blade)
  end
end

function start_blade_attack()

  if has_blade() and not blade_attack then

    blade_attack = true
    local side
    if not has_right_blade() then
      side = 0
    elseif not has_left_blade() then
      side = 1
    else
      side = math.random(2) - 1
    end

    if side == 0 then
      animation = "left_blade_attack"
    else
      animation = "right_blade_attack"
    end

    main_sprite:set_animation(animation)
    if has_left_blade() then
      left_blade_sprite:set_animation(animation)
    end
    if has_right_blade() then
      right_blade_sprite:set_animation(animation)
    end

    sol.enemy.stop_movement()

  end
end

function event_sprite_animation_finished(sprite, animation)

  if blade_attack and sprite == main_sprite then
    blade_attack = false
    sol.enemy.restart()
  end
end

function stop_hurting_left_blade()

  sol.enemy.restart()
  if left_blade_life <= 0 then
    sol.audio.play_sound("stone")
    sol.enemy.remove_sprite(left_blade_sprite)

    if not has_right_blade() then
      start_final_phase()
    end
  end
end

function stop_hurting_right_blade()

  sol.enemy.restart()
  if right_blade_life <= 0 then
    sol.audio.play_sound("stone")
    sol.enemy.remove_sprite(right_blade_sprite)

    if not has_left_blade() then
      start_final_phase()
    end
  end
end

function start_final_phase()

  sol.enemy.set_attack_consequence("sword", 1);
end

