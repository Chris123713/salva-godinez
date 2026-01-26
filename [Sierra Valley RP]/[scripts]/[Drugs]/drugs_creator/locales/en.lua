locales['en'] = {
    ['not_enough'] = "You don't have enough ~r~%s",
    ['open_lab'] = "Press ~INPUT_CONTEXT~ to use the lab",
    ['press_to_stop'] = "Press ~INPUT_CONTEXT~ to stop",
    ['stopped'] = "You stopped",
    ['too_far'] = "You left the lab",
    ['lab'] = "Laboratory",
    ['interact'] = "Press ~INPUT_CONTEXT~ to interact",
    ['sold'] = "You sold ~b~x%d~s~ ~y~%s~s~ for ~r~$%s",
    ['height'] = "Current height: %s%dm", -- %s will be the color, don't remove it
    ['nothing_useful'] = "You have nothing useful",
    ['minimum_altitude'] = "You are not above the minimum altitude",
    ['remain_to_sell'] = "Remain above this altitude for ~g~%ds~s~ in order to sell drugs",
    ['timer'] = "Wait ~g~%ds~s~ to sell drugs",
    ['plane_spotted'] = "A suspicious plane has been spotted in the map",
    ['boat_spotted'] = "A suspicious boat has been spotted in the map",
    ['no_space'] = "You have no more space",
    ["it_will_explode"] = "There will be an explosion in few seconds, ~r~RUN~s~",
    ["explosion_in_zone"] = "There was an ~r~explosion~s~",
    ['wrong_items'] = "You used wrong ingredients",
    ['ingredient_taken'] = "You harvested ~b~x%d~s~ ~y~%s~s~",
    ['press_to_sell'] = "Press E to sell drugs",
    ['drug_not_wanted'] = "The guy doesn't want any drug",
    ['sold_for'] = "You sold ~y~x%d %s~s~ for ~g~$%s~s~",
    ['someone_tried_to_sell_drugs'] = "Someone tried to sell ~r~drugs~s~",
    ['not_enough_police'] = "There isn't enough police",
    ['gang_member'] = "Gang member",
    ['this_is_our_zone'] = "This is ~r~our~s~ zone!",
    ['citizen'] = "Citizen",
    ['how_you_dare'] = "How you dare!?",
    ['press_to_retrieve_drugs'] = "Press ~INPUT_CONTEXT~ to get your drugs back",
    ['drug_has_been_stolen'] = "~b~x%d~s~ ~y~%s~s~ ~r~was stolen~s~ from you! Get it back!",
    ['interact_narcos'] = "Press ~INPUT_CONTEXT~ to talk to the narcos",
    ['narcos:drug_request'] = "<span style='color: %s'>x%d %s - $%s</span>",
    ['narcos:this_is_what_i_need'] = "This is what I need",
    ['narcos:sold_drug'] = "You sold ~b~x%d~s~ ~y~%s~s~ for ~r~$%s~s~",
    ['invalid_quantity'] = "Invalid quantity",
    ['confirm'] = "<span style='color: green'>Confirm</span>",
    ['quantity'] = "Quantity",
    ['you_have_to_wait'] = "You have to wait before using it again",
    ['you_cant_sell_anymore'] = "You can't sell anymore",
    ['i_dont_need_anything_for_now'] = "I don't need to buy ~r~anything~s~ for now, come back later",
    ['narcos'] = "Narcos",
    ["no_drugs_to_sell"] = "You don't have any drug to sell",
    ["canceled_sale"] = "Sale ~r~canceled~s~",
    ["you_crafted"] = "You crafted ~b~x%d ~y~%s~s~",
    ["you_are_up_to_high"] = "You are up too high",
    
    -- Pushers
    ["pusher"] = "Pusher",
    ["interact_pusher"] = "Press ~INPUT_CONTEXT~ to talk to the pusher",
    ["pusher:drug_to_sell"] = "<span style='color: %s'>%d/%d - %s</span>",
    ["pusher:sold"] = "You sold ~b~x%d~s~ ~y~%s~s~ for ~r~$%s~s~",

    --[[ Logs ]]
    ['log:generic'] = "Nickname: %s\nIdentifier: %s\n\n%s",

    ['logs:pickedUpItem'] = "Picked up an harvestable item",
    ['logs:pickedUpItem:description'] = "Picked up **x%d** **%s** in harvestable item **%d**",
    ['logs:pickedUpItem:error'] = "Tried to pick up an invalid item",
    ['logs:pickedUpItem:error:description'] = "Tried to pick up **%s**",
    
    ["logs:drugField"] = "Harvested in a drug field",
    ["logs:drugField:description"] = "Harvested **x%d** **%s** in the drug field **%s** (field ID: **%d**)",

    ['logs:craftedRecipe'] = "Crafted recipe in laboratory",
    ['logs:craftedRecipe:description'] = "Crafted recipe **%s** in laboratory **%s** (laboratory ID: **%d**)",

    ['logs:soldOnPlane'] = "Sold drugs on plane",
    ['logs:soldOnPlane:description'] = "Sold **%s** for **$%s**",

    ['logs:soldOnBoat'] = "Sold drugs on boat",
    ['logs:soldOnBoat:description'] = "Sold **%s** for **$%s**",

    ['logs:soldToNarcos'] = "Sold to narcos",
    ['logs:soldToNarcos:description'] = "Sold **x%d** **%s** for **$%s** to narcos",

    ['logs:soldToNPC'] = "Sold to NPC",
    ['logs:soldToNPC:description'] = "Sold **x%d** **%s** for **$%s** to NPC",

    ['logs:soldToPusher'] = "Sold to pusher",
    ['logs:soldToPusher:description'] = "Sold **x%d** **%s** for **$%s** to pusher ID **%d**",

    --[[ Logs finsihed ]]

    ["harvesting"] = "Harvesting %s",
    ["crafting"] = "Crafting",
    ["selling"] = "Selling %s",
    ["you_dont_have_item"] = "You don't have %s",
    ["nobody_close"] = "Nobody close",
    ["ouch"] = "~r~Ouch!~s~",

    ["input_context:letter"] = "E", -- This will replace ~INPUT_CONTEXT~ in the translations, useful for notification that doesn't support it

    ["interact_targeting"] = "Interact",
    ["sell_drugs_targeting"] = "Sell drugs",
    ["harvest_targeting"] = "Harvest",
    ["laboratory_targeting"] = "Laboratory",

    ["you_need_item"] = "You need ~b~x%d~s~ ~y~%s~s~",
    ["you_cant_in_a_vehicle"] = "You can't in a vehicle",

    ["selling_plane"] = "~g~Selling~s~",
    ["go_back_to_zone_or_the_sale_will_be_canceled"] = "Go back to the zone or the sale will be cancelled!",

    ["already_interacting"] = "Already interacting",

    ["an_auction_is_starting_soon"] = "An auction is starting soon",
    ["auction"] = "Auction",
    ["auction_round"] = "Round %d/%d",
    ["auction_item"] = "x%d %s",
    ["auction_time_left"] = "~%s~Time left: %d seconds~s~", -- The first %s will be the color, don't remove it
    ["auction_highest_bid"] = "Highest bid: ~g~$%s~s~",
    ["auction_ended"] = "Auction ended! Thank you for partecipating",
    ["auction_round_finished"] = "Round is finished, next one starting soon!",
    ['auction_new_bid'] = "Somebody placed a new bid of ~g~$%s~s~",
    ['auction_self_place_bid_amount'] = "~y~[E]~s~ bid ~g~$%s~s~",
    ['auction_self_place_bid_amount:info'] = "~y~[←] [→]~s~ change bid value",
    ['auction_no_bids_yet'] = "No bids yet - Starts at ~g~$%s~s~",
    ['auction_round_started'] = "Auction round has started!",

    ["you_received_item"] = "You received ~b~x%d~s~ ~y~%s~s~",
    ["you_received_money"] = "You received ~b~$%s~s~ ~y~%s~s~",
    ["you_received_weapon"] = "You received ~y~%s~s~",

    ["place_entity:cancel"] = "Click ~INPUT_FRONTEND_PAUSE_ALTERNATE~ to ~r~cancel~s~",
    ["place_entity:confirm"] = "Click ~INPUT_ATTACK~ to ~g~confirm~s~",
    ["place_entity:move"] = "Hold ~INPUT_SPRINT~ to ~y~move~s~",
    ["place_entity:heading"] = "Use ~INPUT_CURSOR_SCROLL_UP~ and ~INPUT_CURSOR_SCROLL_DOWN~ to edit ~y~heading~s~",

    ["somebody_reported_weird_auction"] = "Somebody reported a weird auction...",
    ['you_cant_here'] = "You can't here",
    ['you_are_already_the_last_bidder'] = "You are already the last bidder",
    ['auction_starts_in'] = "Auction starts in %d seconds",
    ['npc_selling:nothing_to_sell'] = "You have nothing to sell",
    ['you_already_have_a_customer'] = "You already have a customer",
    ["spawn_npc_selling"] = "A customer is on its way",

    ["press_to_cancel_sell"] = "Press ~INPUT_CONTEXT~ to cancel the sell",
}
