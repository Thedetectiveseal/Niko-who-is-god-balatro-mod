function perform_operations(val1, op, val2)
	if type(val2) == "number" then
		if op == "=" then return val2 end
		if op == "+" then return val1 + val2 end
		if op == "-" then return val1 - val2 end
		if op == "*" then return val1 * val2 end
		if op == "/" then return val1 / val2 end
		if op == "%" then return val1 % val2 end
		if op == "^" then return val1 ^ val2 end
	elseif type(val1) == "number" and type(val2) == "table" then
		local final = val1
		for _, v in ipairs(val2) do
			final = perform_operations(final, op, v)
		end
		return final
	end
end

function modify_joker_values(card, modifytbl, exclusions, ignoreimmutable, nodeckeffects)
	if not card or not modifytbl then return nil end
	if card.config.center.immutable and not ignoreimmutable then return nil end
	local cardwasindeck = card.added_to_deck
	if not nodeckeffects and cardwasindeck then card:remove_from_deck(true) end
	exclusions = exclusions or {}
	local ops = { "=", "+", "-", "*", "/", "%", "^" }
	local function modify_value(ref_table, ref_value, isdirectlyinability)
		if type(ref_table[ref_value]) == 'table' and (ignoreimmutable or ref_value ~= "immutable") then
			for k, v in pairs(ref_table[ref_value]) do
				modify_value(ref_table[ref_value], k, false)
			end
		elseif type(ref_table[ref_value]) == 'number' and ((not (exclusions[ref_value] == true or exclusions[ref_value] == ref_table[ref_value])) or not isdirectlyinability) then
			for i, v in ipairs(ops) do
				if modifytbl[v] then
					ref_table[ref_value] = perform_operations(ref_table[ref_value], v, modifytbl[v])
				end
			end
		end
	end
	for k, v in pairs(card.ability) do
		modify_value(card.ability, k, true)
	end
	if not nodeckeffects and cardwasindeck then card:add_to_deck(true) end
end

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
			local other_joker = {}
				for k, v in pairs(G.jokers.cards) do
					if v == card then other_joker = G.jokers.cards[k - 1] end
				end
			return {
				message = 'Upgraded!',
				colour = G.C.RED,
				func = function() modify_joker_values(other_joker, { ['^'] = 5 }) end
			}
		end
		-- Add the mult in main scoring context
		if context.joker_main then
			return {
				hypermult = { card.ability.extra.hypermult, card.ability.extra.hyperside },
				hyperchips = { card.ability.extra.hypermult, card.ability.extra.hyperside },
				level_up_hand = "High Card",
				level_up = true,

			}
		end
		if context.end_of_round and context.main_eval and context.beat_blind then
			local other_joker = {}
			for k, v in pairs(G.jokers.cards) do
				if v == card then other_joker = G.jokers.cards[k - 1] end
			end
			return { func = function() modify_joker_values(other_joker, { ['^'] = 5 }) end }
		end
		in_pool = function(self, args)
			return next(SMODS.find_card("j_modprefix_otherjoker"))
		end
	end,






	SMODS.Atlas {
		key = "nikored",
		path = "red.png",
		px = 71,
		py = 95
	},


	SMODS.Joker {
		key = 'joker3',
		loc_txt = {
			name = 'Niko who spawns a god',
			text = {
				"lets niko who is a god spawn"
			}
		},
		config = { extra = { change = 1 }, extra_value = 1 },
		rarity = 3,
		atlas = 'nikored',
		pos = { x = 0, y = 0 },
		cost = 5,
		calculate = function(self, card, context)
			if context.before and next(context.poker_hands['High Card']) then
				card.ability.extra.change = card.ability.extra.change + 1
				card.ability.extra_value = card.ability.extra_value * card.ability.extra.change
				card:set_cost()
				local other_joker = {}
				for k, v in pairs(G.jokers.cards) do
					if v == card then other_joker = G.jokers.cards[k - 1] end
				end
				return {
					message = 'Upgraded sell value!',
					colour = G.C.YELLOW,
					func = function() modify_joker_values(other_joker, { ['*'] = 2 }) end
				}
			end
			if context.end_of_round and context.main_eval and context.beat_boss then
				return {
					dollars = card.sell_cost / 2
				}
			end
			if context.end_of_round and context.main_eval and context.beat_blind then
				local other_joker = {}
				for k, v in pairs(G.jokers.cards) do
					if v == card then other_joker = G.jokers.cards[k - 1] end
				end
				return { func = function() modify_joker_values(other_joker, { ['*'] = 2 }) end }
			end
		end

	}
}
