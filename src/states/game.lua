local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local Utils = require('src.helpers.utils')

local Map = require('src.entities.map')
local Tower = require('src.entities.tower')
local Deck = require('src.entities.deck')
local Timer = require('src.helpers.timer')
local Card = require('src.entities.card')

local Udp = require('src.network.udp')
local Events = require('src.network.events')

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

function Game:load()
	Map:load()
	Game:load_towers()

	Deck:load()
	Game.deck = Deck.deck_selected
end

function Game:update(dt)
	self.t = self.t + dt

	repeat
		local data = self:handle_received_data()
	until not data

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


	for _, obj in pairs(self.all_objects) do
		-- remove from list if off-screen
		-- if (obj.char_x < -50 or obj.char_x > (love.graphics.getWidth() + 50)) then
		-- 	self.all_objects[key] = nil
		-- 	break
		-- end

		obj.update(obj, dt)
	end

	for key, obj in pairs(self.my_objects) do
		if obj.type ~= 'tower' then
			if obj.current_life <= 0 then
				obj.current_action = 'death'

				Udp:send({ event=Events.Object, identifier=key, obj={
					key = key,
					char_x = obj.char_x,
					char_y = obj.char_y,
					current_life = obj.current_life,
					current_action = obj.current_action,
				} })
				break
			end

			for _, enemy in pairs(self.enemy_objects) do
				if Utils.circle_rect_collision(obj.char_x, obj.char_y, obj.attack_range, enemy.char_x, enemy.char_y, enemy.w, enemy.h) then
					obj.current_action = 'attack'

					if self.t > self.update_interval then
						self.last_timestamp = os.time()

						Udp:send({ event=Events.Object, identifier=key, obj={
							key = key,
							char_x = obj.char_x,
							char_y = obj.char_y,
							current_action = obj.current_action,
						} })

						self.t = 0
					end

					break
				end

				if Utils.circle_rect_collision(obj.char_x, obj.char_y, obj.perception_range, enemy.char_x, enemy.char_y, enemy.w, enemy.h) then
					obj.handle_chars_around(obj, enemy)
					obj.current_action = 'follow'

					if self.t > self.update_interval then
						self.last_timestamp = os.time()

						Udp:send({ event=Events.Object, identifier=key, obj={
							key = key,
							char_x = obj.char_x,
							char_y = obj.char_y,
							current_action = obj.current_action,
						} })

						self.t = 0
					end
				end
			end
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

function Game:handle_received_data()
	local data = Udp:receive_data()

	if data then
		if data.timestamp then
			self.ping = os.time() - self.last_timestamp
		end

		if data.event == Events.EnemyObject then
			if self.enemy_objects[data.identifier] then
				if data.obj.current_action == 'dead' then
					self.enemy_objects[data.identifier] = nil
					self.all_objects = Utils.merge_tables(self.my_objects, self.enemy_objects)
					return
				end
				self.enemy_objects[data.identifier].key = data.obj.key
				self.enemy_objects[data.identifier].char_x = data.obj.char_x
				self.enemy_objects[data.identifier].char_y = data.obj.char_y
				self.enemy_objects[data.identifier].current_action = data.obj.current_action
			else
				self.enemy_objects[data.identifier] = Card:new(
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

			self.enemy_objects[data.identifier].key = data.obj.key
			self.enemy_objects[data.identifier].char_x = data.obj.char_x
			self.enemy_objects[data.identifier].char_y = data.obj.char_y
		end

		if data.event == Events.Object and self.my_objects[data.identifier] then
			self.my_objects[data.identifier].key = data.obj.key
			self.my_objects[data.identifier].current_life = data.obj.current_life
		end

		if data.event == Events.Tower then
			self.my_objects[data.identifier].current_life = data.obj.current_life
		end

		if data.event == Events.EnemyTower then
			if not self.enemy_objects[data.identifier] then
				self.enemy_objects[data.identifier] = Tower:new('left', data.obj.position)
				self.enemy_objects[data.identifier].key = data.obj.key
				self.enemy_objects[data.identifier].current_life = data.obj.current_life
			else
				self.enemy_objects[data.identifier].current_life = data.obj.current_life
			end
		end
	end
end

function Game:load_towers()
	local tower3 = Tower:new('right', 'top')
	self.my_objects[tostring(tower3)] = tower3
	self.my_objects[tostring(tower3)].key = tostring(tower3)

	Udp:send({ identifier = tostring(tower3), event = Events.Tower, obj = {
		key = tostring(tower3),
		current_life = tower3.current_life,
		position = 'top'
	} })

	local tower4 = Tower:new('right', 'bottom')
	self.my_objects[tostring(tower4)] = tower4
	self.my_objects[tostring(tower4)].key = tostring(tower4)

	Udp:send({ identifier = tostring(tower4), event = Events.Tower, obj = {
		key = tostring(tower4),
		current_life = tower4.current_life,
		position = 'bottom'
	} })
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
