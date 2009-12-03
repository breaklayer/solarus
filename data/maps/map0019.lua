----------------------
-- Cake shop script --
----------------------

apples_question_asked = false

function event_hero_on_sensor(sensor_name)

   if not savegame_get_boolean(32) and not apples_question_asked then
      start_message("cake_shop.dont_leave")
      apples_question_asked = true
   end
end

function event_message_sequence_finished(first_message_id, answer)

  if first_message_id == "cake_shop.dont_leave" 
    or first_message_id == "cake_shop.seller.ask_apples_again" then

    savegame_set_boolean(46, true)

    if answer == 0 then
      if inventory_item_get(10) == 1 then
	if inventory_item_get_amount(10) >= 6 then
	  start_message("cake_shop.thank_you")
	  inventory_item_remove_amount(10, 6)
	else
	  start_message("cake_shop.not_enough_apples")
	end
      else
	start_message("cake_shop.no_apples")
      end
    end
  elseif first_message_id == "cake_shop.thank_you" then
    give_treasure(7, 32)
  end
end

function event_npc_dialog(npc)
  if npc == "seller" then
    talk_to_seller()
  end
end

function event_interaction(entity_name)
  if entity_name == "seller_talking_place" then
    talk_to_seller()
  end
end

function talk_to_seller()
  if not savegame_get_boolean(46) or savegame_get_boolean(32) then
    start_message("cake_shop.seller.choose_item")
  else 
    start_message("cake_shop.seller.ask_apples_again")
  end
end
