SMODS.Atlas {
	key = "nikogod",
	path = "heisgod.png",
	px = 71,
	py = 95
}


SMODS.Joker {
	key = 'joker2',
	loc_txt = {
		name = 'Niko who is a god and transcends all of time and space',
		text = {
			"gives [#1#]#2# mult when card is played, +1 hyperoperator when highcard is played, levels up highcard when card is scored perchance gives good chips"
		}
	},
	config = { extra = {
		hyperchips = 1,
		hypermult = 1,
		change = 1,
		hyperside = 4
	} },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.hypermult, card.ability.extra.hyperside } }
	end,
	rarity = 3,
	atlas = 'nikogod',
	pos = { x = 0, y = 0 },
	cost = 50,
	calculate = function(self, card, context)
		-- Check if we have played a Flush before we do any scoring and increment the mult
		if context.before and next(context.poker_hands['High Card']) then
			card.ability.extra.hypermult = card.ability.extra.hypermult + card.ability.extra.change
			card.ability.extra.hyperchips = card.ability.extra.hyperchips + card.ability.extra.change
			return {
				message = 'Upgraded!',
				colour = G.C.RED,

			}
		end
		-- Add the mult in main scoring context
		if context.joker_main then
			return {
				hypermult = { card.ability.extra.hypermult, card.ability.extra.hyperside },
				hyperchips = { card.ability.extra.hypermult, card.ability.extra.hyperside},
				level_up_hand = "High Card"
			}
		end
	end,
	in_pool = function(self, args)
		return next(SMODS.find_card("j_modprefix_otherjoker"))
	end,
}






SMODS.Atlas {
	key = "nikored",
	path = "red.png",
	px = 71,
	py = 95
}


SMODS.Joker {
	key = 'joker3',
	loc_txt = {
		name = 'Niko who spawns a god',
		text = {
			"lets niko who is a god spawn"
		}
	},
	config = { extra = { change = 1 }, extra_value = 1 },
	rarity = 2,
	atlas = 'nikored',
	pos = { x = 0, y = 0 },
	cost = 5,
	calculate = function(self, card, context)
		if context.before and next(context.poker_hands['High Card']) then
			card.ability.extra.change = card.ability.extra.change + 1
			card.ability.extra_value = card.ability.extra_value * card.ability.extra.change
			card:set_cost()
			return {
				message = 'Upgraded sell value!',
				colour = G.C.YELLOW,
			}
		end
		if context.end_of_round and context.main_eval and context.beat_boss then
			return {
				dollars = card.sell_cost / 2
			}
		end
		        if context.end_of_round and context.cardarea == G.jokers then

            function changevals(tbl, firstchildofability)
                for key, value in pairs(tbl) do
                    if type(value) == "table" and key ~= "immutable" then
                        changevals(value,false)
                    elseif type(value) == "number" and not firstchildofability then
                        tbl[key] = value * 2
                    end
                end
                return{tbl}
            end

            if G.jokers.cards[1] ~= self and not G.jokers.cards[1].immutable then
                local ability = G.jokers.cards[1].ability
                G.jokers.cards[1].ability = changevals(ability,true)[1]
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    card:juice_up(1,1),
                    G.jokers.cards[1]:juice_up(0.5,0.5)
                }))
                return{
                    message=localize("k_upgrade_ex"),
                    message_card = G.jokers.cards[1]
                }
            end
        end

	end

}
