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
	frame_height = 0,
	animate = {}
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

	card.animate.update = function(char_, dt)
		return char_.actions[char_.current_action].update(dt)
	end

	card.animate.draw = function(char_, x, y, ...)
		self:lifebar(x,y)

		return char_.actions[char_.current_action].draw(x,y)
	end

	return card
end

-- only showed on preview
function Card:perception_range()
	return self.attack_range * 2
end

function Card:lifebar(x,y)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x - 10, y - 10, 50, 5)
	love.graphics.rectangle("fill", x - 10, y - 10, 50, 5)
	love.graphics.setColor(255,255,255)
end

function Card:show_name(x, y)
	love.graphics.print(self.name, x, y + 30)
end

Card.__index = Card

return Card
