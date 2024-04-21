local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local Utils = require('src.helpers.utils')

local Map = require('src.entities.map')
local Tower = require('src.entities.tower')
local Deck = require('src.entities.deck')
local Timer = require('src.helpers.timer')
local Card = require('src.entities.card')

local Game = {
	all_objects = {},
	my_objects = {},
	enemy_objects = {},
	deck = {},
	t = 0,
	update_interval = 0.1,

	last_timestamp = 0,
	ping = 0
}

-- Game:load_towers()

function Game:load()
	Map:load()
	-- Deck:load()
	-- Game.deck = Deck.deck_selected
end

function Game:update(dt)
	Map:update(dt)
	self.t = self.t + dt

	self.all_objects = Utils.merge_tables(self.my_objects, self.enemy_objects)

	Deck:update(dt)

	Game:timer(dt)

	for _,card in pairs(self.deck) do
		if card.selected then
			local x, y = love.mouse.getPosition()
			card.char_x = x
			card.char_y = y
		end
	end
end

function Game:draw()
	Map:draw()

	Deck:draw()

	Game:timer_background()

	for _, card in pairs(self.deck) do
		if card.selected then
			Map:block_left_side()

			-- because the char is walking from right -> left (by now)
			if card.char_x <= Map.left_side.w then
				card.char_x = Map.left_side.w
			end

			Game:preview_char(card, card.char_x + card.img_preview:getWidth() / 2, card.char_y + card.img_preview:getHeight() / 2)
		end
	end

	for key, obj in pairs(self.all_objects) do
		obj.char_x, obj.char_y = obj.draw(obj, obj.current_life, obj.char_x, obj.char_y, self.enemy_objects[key])
	end

	love.graphics.print(tostring(self.ping), 10, 10, 0, 1, 1, 0, 0, 0, 0)
end

-- private functions ---------

function Game:load_towers()
	local tower1 = Tower:load('left', 'top')

	local tower2 = Tower:load('left', 'bottom')
end

function Game:preview_char(card,x,y)
	-- attack range
	love.graphics.ellipse("line", x, y, card.attack_range, card.attack_range)
	-- perception range
	love.graphics.ellipse("line", x, y, card.perception_range, card.perception_range)

	-- represents the char preview
	love.graphics.setColor(0.2,0.2,0.7,0.5)
	love.graphics.draw(card.img_preview, card.char_x, card.char_y)
	love.graphics.setColor(1,1,1)
end

function Game:timer(dt)
	local new_center = Layout:center(100, 100)
	love.graphics.setColor(1,1,1)
	Suit.Label(Timer:match(dt), new_center.width, 35, 100, 0)
	love.graphics.setColor(1,1,1)
end

function Game:timer_background()
	local new_center = Layout:center(100, 100)
	love.graphics.setColor(0,0,0, 0.8)
	love.graphics.rectangle('fill', new_center.width, 10, 100, 50)
	love.graphics.setColor(1,1,1)
end

return Game
