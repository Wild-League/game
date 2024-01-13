local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')

local Assets = require('src.assets')
local Constants = require('src.constants')

local Utils = require('src.helpers.utils')
local Map = require('src.entities.map')

local Deck = require('src.entities.deck')
local Tower = require('src.entities.tower')
local Card = require('src.entities.card')

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
	Deck:load()
	Game.deck = Deck.deck_selected

	Game.map = sti('assets/world.lua')
end

function Game:handle_received_data()
	local data = Udp:receive_data()
	if data and data.identifier then
		if data.event == Events.Object then
			if self.enemy_objects[data.identifier] then
				self.enemy_objects[data.identifier].char_x = data.obj.x
				self.enemy_objects[data.identifier].char_y = data.obj.y
				self.enemy_objects[data.identifier].current_action = data.obj.current_action
			else

				self.enemy_objects[data.identifier]	= Card:new(
					true,
					data.obj.name,
					data.obj.type,
					data.obj.cooldown,
					data.obj.damage,
					data.obj.life,
					data.obj.speed,
					data.obj.attack_range,
					data.obj.width,
					data.obj.height
				)
			end
		end

		if data.event == Events.EnemyObject then
			if self.my_objects[data.identifier] then
				self.my_objects[data.identifier].current_life = data.obj.current_life
				-- self.my_objects[data.identifier].current_action = data.obj.current_action
			end
		end
	end

	return data
end


function Game:update(dt)
	repeat
		local data = self:handle_received_data()
	until not data

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
			local x, y = love.mouse.getPosition()
			card.char_x = x
			card.char_y = y
		end
	end

	-- TODO: change type `static` to `tower`
	-- since it's a specific part of the game

	-- I think that maybe I can just add all cards played to `my_objects`
	-- and then check the percpetion/attach individually
	-- making possible to each card update the `current_action` itself, instead of here

	-- maybe I could just send all the `my_objects` to the server
	for _,value in pairs(self.my_objects) do
		if value.type ~= 'static' then
			value.animate.update(value, dt)

			Udp:send({ identifier=tostring(value), event=Events.Object, obj={
				x = value.char_x,
				y = value.char_y,
				current_action = value.current_action,
				name = value.name,
				type = value.type,
				cooldown = value.cooldown,
				damage = value.damage,
				life = value.life,
				speed = value.speed,
				attack_range = value.attack_range,
				width = value.img_preview:getWidth() or 60,
				height = value.img_preview:getHeight() or 60
			} })
		end

		for k,enemy in pairs(self.enemy_objects) do
			if value.type ~= 'static' then

				if enemy.type == 'static' then
					if Utils.circle_rect_collision(value.char_x + (value.img_preview:getWidth() / 2), value.char_y + (value.img_preview:getHeight() / 2),
						value.perception_range, enemy.x, enemy.y, enemy.w, enemy.h) then
							value.handle_chars_around(enemy)
							value.current_action = 'follow'
					end

					if Utils.circle_rect_collision(value.char_x + (value.img_preview:getWidth() / 2), value.char_y + (value.img_preview:getHeight() / 2),
						value.attack_range, enemy.x, enemy.y, enemy.w, enemy.h) then
							value.current_action = 'attack'
					end

					Udp:send({ identifier=k, event=Events.EnemyObject, obj={
						current_life = enemy.current_life
					} })
				else
					local enemy_x = enemy.char_x and enemy.char_x or 0
					local enemy_y = enemy.char_y and enemy.char_y or 0
					local enemy_w = enemy.img_preview and enemy.img_preview:getWidth() or 60 -- default size
					local enemy_h = enemy.img_preview and enemy.img_preview:getHeight() or 60

					if Utils.circle_rect_collision(value.char_x + (value.img_preview:getWidth() / 2), value.char_y + (value.img_preview:getHeight() / 2),
						value.perception_range, enemy_x, enemy_y, enemy_w, enemy_h) then
							value.handle_chars_around(enemy)
							value.current_action = 'follow'
					end

					if Utils.circle_rect_collision(value.char_x + (value.img_preview:getWidth() / 2), value.char_y + (value.img_preview:getHeight() / 2), value.attack_range,
						enemy_x, enemy_y, enemy_w, enemy_h) then

							if enemy.current_life == 0 then
								enemy.current_action = 'death'
							end

							value.current_action = 'attack'

							if value.current_life == 0 then
								value.current_action = 'death'
							end
					end

					Udp:send({ identifier=k, event=Events.EnemyObject, obj={
						current_life = enemy.current_life,
						current_action = enemy.current_action
					} })
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

	-- ideally, I would not need to check the card type to draw
	-- the same for lifebar

	-- draw all objects
	for _,card in pairs(self.my_objects) do
		if card.type == 'static' then
			love.graphics.draw(card.img, card.x, card.y)
			Tower:lifebar(card.x + card.w / 4, card.y + card.h / 1.4, card.current_life)
		end

		if card.type ~= 'static' then
			card.char_x, card.char_y = card.animate.draw(card, card.char_x, card.char_y)
			card:lifebar(card.char_x, card.char_y, card.current_life)
		end
	end

	for _,enemy in pairs(self.enemy_objects) do
		if enemy.type == 'static' then
			love.graphics.draw(enemy.img, enemy.x, enemy.y)
			Tower:lifebar(enemy.x + enemy.w / 4, enemy.y + enemy.h / 1.4, enemy.current_life)
		end

		if enemy.type ~= 'static' then
			enemy.char_x, enemy.char_y = enemy.animate.draw(enemy, enemy.char_x, enemy.char_y)
			enemy:lifebar(enemy.char_x, enemy.char_y, enemy.current_life)
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

-- function love.resize(w,h)
-- 	if CONTEXT.current == 'game' then
-- 		Game.map:resize(w, h)
-- 	end
-- end

return Game
