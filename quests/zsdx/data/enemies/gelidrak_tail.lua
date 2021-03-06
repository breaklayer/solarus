-- Gelidrak's tail

retracted = false      -- becomes retracted when touched by an arrow
retracted_delay = 3000 -- delay while the tail remains retracted

function event_appear()

  sol.enemy.set_life(1000000)
  sol.enemy.set_damage(12)
  sol.enemy.create_sprite("enemies/gelidrak_tail")
  sol.enemy.set_size(16, 16)
  sol.enemy.set_origin(8, 8)
  sol.enemy.set_hurt_style("boss")
  sol.enemy.set_obstacle_behavior("flying")
  sol.enemy.set_no_treasure()
  sol.enemy.set_layer_independent_collisions(true)
  sol.enemy.set_push_hero_on_sword(true)

  sol.enemy.set_invincible()
  sol.enemy.set_attack_consequence("arrow", 1)
  sol.enemy.set_attack_consequence("sword", "protected")
  sol.enemy.set_attack_consequence("hookshot", "protected")
  sol.enemy.set_attack_consequence("boomerang", "protected")
  sol.enemy.set_pushed_back_when_hurt(false)

  -- go to the high layer
  local x, y = sol.enemy.get_position()
  sol.enemy.set_position(x, y, 2)
end

function event_restart()

  if not retracted then
    local m = sol.movement.create("path")
    m:set_path{0,0,0,0,7,7,3,3,4,4,4,4,4,4,4,4,5,5,1,1,0,0,0,0}
    m:set_speed(64)
    m:set_ignore_obstacles(true)
    m:set_loop(true)
    sol.enemy.start_movement(m)
  else
    sol.enemy.stop_movement()
    sol.main:start_timer(retracted_delay, function()
      local x, y = sol.map.enemy_get_position(sol.enemy.get_father())
      local m = sol.movement.create("target")
      m:set_speed(48)
      m:set_target(x, y - 112)
      sol.enemy.start_movement(m)
      sol.enemy.send_message(sol.enemy.get_father(), "recovering")
    end)
  end
end

function event_movement_finished(m)

  -- the tail was retracted and has just recovered its normal position
  retracted = false
  sol.enemy.set_attack_consequence("arrow", 1)
  sol.enemy.set_can_attack(true)
  event_restart()

  if not sol.map.enemy_is_dead(sol.enemy.get_father()) then
    sol.enemy.send_message(sol.enemy.get_father(), "recovered")
  end
end

function event_hurt(attack, life_lost)

  -- notify the body (so that it stops moving and becomes vulnerable)
  sol.enemy.send_message(sol.enemy.get_father(), "hurt")

  -- retract the tail for a while
  retracted = true
  local x, y = sol.map.enemy_get_position(sol.enemy.get_father())
  sol.enemy.set_position(x, y - 48)
  sol.enemy.set_attack_consequence("arrow", "protected")
  sol.enemy.set_can_attack(false)
  sol.map.arrow_remove()
end

