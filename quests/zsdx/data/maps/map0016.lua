-- Smith cave

local sword_price = 75

-- Function called when the player wants to talk to a non-playing character.
function event_npc_interaction(npc_name)

  -- smith dialog
  if not sol.map.get_game():get_boolean(30) then
    -- the player has no sword yet
    sol.map.dialog_start("smith_cave.without_sword")
  else
    -- the player already has the sword
    sol.map.dialog_start("smith_cave.with_sword")
  end
end

-- Function called when the dialog box is being closed.
function event_dialog_finished(dialog_id, answer)

  if dialog_id == "smith_cave.without_sword" then
    -- the dialog was the question to buy the sword

    if answer == 1 then
      -- the player does not want to buy the sword
      sol.map.dialog_start("smith_cave.not_buying")
    else
      -- wants to buy the sword
      if sol.map.get_game():get_money() < sword_price then
        -- not enough money
        sol.audio.play_sound("wrong")
        sol.map.dialog_start("smith_cave.not_enough_money")
      else
        -- enough money: buy the sword
        sol.map.get_game():remove_money(sword_price)
        sol.map.treasure_give("sword", 1, 30)
      end
    end
  end
end

-- Function called when the player is obtaining the sword.
function event_treasure_obtaining(item_name, variant, savegame_variable)

  if item_name == "sword" then
    sol.audio.play_sound("treasure")
  end
end

-- Function called when the player has just obtained the sword.
function event_treasure_obtained(item_name, variant, savegame_variable)
   if (savegame_variable == 30) then
      sol.map.dialog_start("smith_cave.thank_you")
   end
end

