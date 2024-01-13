local Char = require('src.entities.cards.char')
local Spell = require('src.entities.cards.spell')

local Card = {}

local default_props = {
	x = 0,
	y = 0,
	char_x = 0,
	char_y = 0,
	current_cooldown = 0,
	selected = false,
	selectable = false,
	preview_card = false,
	is_card_loading = false,
	frame_width = 0,
	frame_height = 0
}

function Card:new(enemy, name, type, cooldown, damage, life, speed, attack_range, width, height)
	local card = {}

	if type == 'spell' then
		card = Spell:new(name, type, cooldown, damage, life, speed, attack_range, width, height)
	end

	if type == 'char' then
		card = Char:new(enemy, name, type, cooldown, damage, life, speed, attack_range, width, height)
	end

	for key, value in pairs(default_props) do
		card[key] = value
	end

	card.update = function(card_, dt)
		return card_.actions[card_.current_action].update(dt)
	end

	card.draw = function(card_, current_life, x, y)
		return card_.actions[card_.current_action].draw(x,y, current_life)
	end

	return card
end

-- only showed on preview
function Card:perception_range()
	return self.attack_range * 2
end

function Card:show_name(x, y)
	love.graphics.print(self.name, x, y + 30)
end

Card.__index = Card

return Card
