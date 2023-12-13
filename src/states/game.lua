local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')

local Assets = require('src.assets')
local Constants = require('src.constants')

local Utils = require('src.helpers.utils')
local Map = require('src.entities.map')

local Deck = require('src.entities.deck')
local Tower = require('src.entities.tower')

local Udp = require('src.network.udp')
local Events = require('src.network.events')

local Timer = require('src.helpers.timer')

local timer = 0
local sti = require("lib.sti")

local Game = {
	user = {},
	deck = {},

	--[[
		TODO: find another way to implement it

		have all the objects in the game
		so we can compare collisions easily
		type = character | building | spells
	]]
	my_objects = {},
	enemy_objects = {},

	card_selected = nil
}

-- used for message_timer
local should_message = false
local message = ''

setmetatable(Game, Game)

function Game:load()
	Tower:load()

	Deck:load()
	Game.deck = Deck.deck_selected

	Game.map = sti('assets/world.lua')

	table.insert(self.my_objects, {
		type = 'static',
		x = Tower.positions_right.tower1.x,
		y = Tower.positions_right.tower1.y,
		w = Assets.TOWER_LEFT:getWidth() / 1.5,
		h = Assets.TOWER_LEFT:getHeight() / 1.5,
		current_life = Tower.current_life
	})

	table.insert(self.my_objects, {
		type = 'static',
		x = Tower.positions_right.tower2.x,
		y = Tower.positions_right.tower2.y,
		w = Assets.TOWER_LEFT:getWidth() / 1.5,
		h = Assets.TOWER_LEFT:getHeight() / 1.5,
		current_life = Tower.current_life
	})

	table.insert(self.enemy_objects, {
		type = 'static',
		x = Tower.positions_left.tower1.x,
		y = Tower.positions_left.tower1.y,
		w = Assets.TOWER_LEFT:getWidth() / 1.5,
		h = Assets.TOWER_LEFT:getHeight() / 1.5,
		current_life = Tower.current_life
	})

	table.insert(self.enemy_objects, {
		type = 'static',
		x = Tower.positions_left.tower2.x,
		y = Tower.positions_left.tower2.y,
		w = Assets.TOWER_LEFT:getWidth() / 1.5,
		h = Assets.TOWER_LEFT:getHeight() / 1.5,
		current_life = Tower.current_life
	})
end

function Game:handle_received_data()
	local data = Udp:receive_data()
	if data then
		if data.event == Events.Object and data.identifier then
			if self.enemy_objects[data.identifier] then
				Deck.enemy_possible_cards[data.identifier].char_x = data.obj.x
				Deck.enemy_possible_cards[data.identifier].char_y = data.obj.y
			end

			self.enemy_objects[data.identifier]	= self.enemy_objects[data.identifier] or Deck.enemy_possible_cards[data.identifier]
		end
	end

	return data
end


function Game:update(dt)
	repeat
		local data = self:handle_received_data()
	until not data

	Tower:update()
	Deck:update(dt)

	-- timer
	local new_center = Layout:center(100, 100)
	love.graphics.setColor(1,1,1)
	Suit.Label(Timer:match(dt), new_center.width, 35, 100, 0)
	love.graphics.setColor(1,1,1)

	Game:message_timer(dt)

	-- TODO: implement function to show player details
	-- nickname, level
	-- Suit.Label(Game.user.nickname, { align='center', font = new_font}, 10, 680, 200, 30)
	-- Suit.Label('lv. '..Game.user.level, { align='center', font = new_font  }, 10, 695, 200, 30)

	for _,card in pairs(self.deck) do
		if card.selected then
			local x,y = love.mouse.getPosition()
			card.char_x = x
			card.char_y = y
		end
	end

	for _,value in pairs(self.my_objects) do
		if value.type ~= 'static' then
			value.animate.update(value, dt)
		end

		Udp:send({ identifier=value.name, event=Events.Object, obj={ x = value.char_x, y = value.char_y } })

		for _,enemy in pairs(self.enemy_objects) do
			if value.type ~= 'static' then
				if Utils.circle_rect_collision(value.char_x + (value.img:getWidth() / 4), value.char_y + (value.img:getHeight() / 4),
					value.perception_range, enemy.x, enemy.y, enemy.w, enemy.h) then
					value.chars_around.key = enemy
					value.current_action = 'follow'
				end

				if Utils.circle_rect_collision(value.char_x + (value.img:getWidth() / 4), value.char_y + (value.img:getHeight() / 4), value.attack_range,
					enemy.x, enemy.y, enemy.w, enemy.h) then
						value.chars_around.key = enemy
						value.current_action = 'attack'
						-- break
				end
			end
		end
	end

	for _, enemy in pairs(self.enemy_objects) do
		if enemy.type ~= 'static' then
			enemy.animate.update(enemy, dt)
		end
	end
end

function Game:draw()
	self.map:draw()

	local new_center = Layout:center(100, 100)
	love.graphics.setColor(0,0,0, 0.8)
	love.graphics.rectangle('fill', new_center.width, 10, 100, 50)
	love.graphics.setColor(1,1,1)

	-- TEST: fake char to be attacked, should remove after tests
	-- love.graphics.rectangle("fill", 100, 100, 20, 20)

	-- # tower
	Tower:draw()

	-- # deck
	Deck:draw()

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

	-- draw all objects
	for _,card in pairs(self.my_objects) do
		if card.type ~= 'static' then
			card.char_x, card.char_y = card.animate.draw(card, card.char_x, card.char_y)
		end
		-- if card.type == 'character' then
		-- 	card.char_x, card.char_y = card.animate.draw(card, card.char_x, card.char_y)
		-- end
	end

	for _,enemy in pairs(self.enemy_objects) do
		if enemy.type ~= 'static' then
			enemy.char_x, enemy.char_y = enemy.animate.draw(enemy, enemy.char_x, enemy.char_y)
		end
	end
end

-- shows the time passed in the game
function Game:timer(dt)
	timer = timer + dt

	local seconds = tostring(math.floor(timer % 60))
	local minutes = tostring(math.floor(timer / 60))

	if tonumber(seconds) <= 9 then
		seconds = '0'..seconds
	end
	if tonumber(minutes) <= 9 then
		minutes = '0'..minutes
	end

	local time = minutes..':'..seconds

	local new_center = Layout:center(100, 200)

	Suit.Label(time, { align='center'}, new_center.width, 10, 100, 200)
end

local countdown_message = 5
-- TODO: create class for messages like this
function Game:message_timer(dt)
	countdown_message = countdown_message - dt

	if should_message then
		Suit.Label(message, {align='center'},100,25,100,200)
		if countdown_message <= 0 then
			countdown_message = countdown_message + 5
			should_message = false
		end
	end
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

function love.resize(w,h)
	if CONTEXT.current == 'game' then
		Game.map:resize(w, h)
	end
end

return Game
