local socket = require('lib.nakama.socket')
local json = require('lib.json')
local MatchEvents = require('src.config.match_events')
local Constants = require('src.constants')
local Utils = require('src.helpers.utils')

local Char = {
	current_action = 'walk',
	current_life = 0,

	scale_x = 1,
	last_x = 0,

	allies_around = {},

	enemies_around = {},
	nearest_enemy = nil,

	animations = {
		walk = {},
		attack = {},
		death = {}
	},

	timeout = 0
}

--[[
	function Char.handle_chars_around(char, enemy)
		char.chars_around[enemy.key] = enemy
		char.chars_around[enemy.key].key = enemy.key
	end

	function Char:load_actions(char)
		char.actions = {
			walk = {
				update = function(dt)
					char.animations['walk']:update(dt)
				end,
				draw = function(x, y, current_life, enemy)
					char:lifebar(x,y, current_life)

					if enemy then
						x = x + char.speed
					else
						x = x - char.speed
					end

					char.animations['walk']:draw(char.img_walk, x, y)
					return x, y
				end
			},
			follow = {
				update = function(dt)
					char.nearest_enemy = char:get_nearest_enemy(char, char.chars_around)

					char.animations['walk']:update(dt)
				end,
				draw = function(x,y, current_life)
					char:lifebar(x,y, current_life)

					local dx = char.nearest_enemy.char_x - x
					local dy = char.nearest_enemy.char_y - y

					local distance = math.sqrt(dx*dx + dy*dy)

					if distance > 1 then
						local angle = math.atan2(dy, dx)
						x = x + char.speed * math.cos(angle)
						y = y + char.speed * math.sin(angle)
					end

					char.animations['walk']:draw(char.img_walk, x, y)
					return x,y
				end
			},
			attack = {
				update = function(dt)
					char.animations['attack']:update(dt)
				end,
				draw = function(x,y, current_life)
					char:lifebar(x,y, current_life)

					char.nearest_enemy = char:get_nearest_enemy(char, char.chars_around)

					char.animations['attack']:draw(char.img_attack,x,y)
					return x,y
				end
			},
			death = {
				update = function(dt)
					char.animations['death']:update(dt)
				end,
				draw = function(x,y, _)
					char.animations['death']:draw(char.img_death,x,y)
					return x,y
				end
			}
		}

		return char
	end

	function Char:get_nearest_enemy(char, around)
		for _,v in pairs(around) do
			local distance_x = v.char_x - char.char_x
			local distance_y = v.char_y - char.char_y

			if (distance_x >= (char.nearest_enemy.char_x - char.char_x))
				and (distance_y >= (char.nearest_enemy.char_y - char.char_y)) then
				return v
			end
		end
	end
]]

function Char:get_enemies_in_range(enemies)
	for k,v in pairs(enemies) do
		local has_collision = Utils.circle_rect_collision(
			self.char_x, self.char_y, self.perception_range/2,
			v.char_x, v.char_y, v.img_preview:getWidth(), v.img_preview:getHeight()
		)

		self.enemies_around[k] = has_collision and v or nil
	end

	self:get_nearest_enemy()

	if self.nearest_enemy then
		self:check_attack_range()
	end
end

function Char:check_attack_range()
	local attack_range_collision = Utils.circle_rect_collision(
		self.char_x, self.char_y, self.attack_range/2,
		self.nearest_enemy.char_x, self.nearest_enemy.char_y,
		self.nearest_enemy.img_preview:getWidth(), self.nearest_enemy.img_preview:getHeight()
	)

	if attack_range_collision then
		if self.current_action ~= 'attack' then
			self.current_action = 'attack'

			coroutine.resume(coroutine.create(function()
				-- maybe I should create a function to send the data so I can add a proper timeout to it?
				socket.match_data_send(
					Constants.SOCKET_CONNECTION,
					Constants.MATCH_ID,
					MatchEvents.card_action,
					json.encode({
						card_id = self.card_id,
						action = self.current_action
					}),
					nil
				)
			end))
		end
	end
end

function Char:get_nearest_enemy()
	local nearest_distance = 0

	for k,v in pairs(self.enemies_around) do
		local distance_x = v.char_x - self.char_x
		local distance_y = v.char_y - self.char_y

		local distance = math.sqrt(distance_x * distance_x + distance_y * distance_y)

		if nearest_distance == 0 or distance < nearest_distance then
			nearest_distance = distance
			v.card_id = k
			self.nearest_enemy = v
		else
			self.nearest_enemy = nil
		end
	end
end

function Char:preview(x, y)
	-- -- attack range
	-- love.graphics.ellipse("line", x, y, card.attack_range, card.attack_range)
	-- -- perception range
	-- love.graphics.ellipse("line", x, y, card.perception_range, card.perception_range)

	local center_x = x - self.img_preview:getWidth() / 2
	local center_y = y - self.img_preview:getHeight() / 2

	love.graphics.setColor(0.2,0.2,0.7,0.5)
	love.graphics.draw(self.img_preview, center_x, center_y)
	love.graphics.setColor(1,1,1)
end

function Char:lifebar(x,y, current_life)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x - 10, y - 10, self.life, 5)
	love.graphics.rectangle("fill", x - 10, y - 10, current_life, 5)
	love.graphics.setColor(255,255,255)
end


function Char:get_action(current_action)
	if current_action == 'walk' then
		local new_position = self.enemy
			and self.char_x + self.speed
			or self.char_x - self.speed

		self.char_x = new_position
		self.scale_x = self.last_x >= self.char_x and 1 or -1
	end
end

function Char:update(dt)
	self.animations[self.current_action]:update(dt)
end

function Char:draw()
	self.last_x = self.char_x

	local x = self.enemy and self.char_x - self.img_preview:getWidth()/2 or self.char_x + self.img_preview:getWidth()/2
	local y = self.char_y + self.img_preview:getHeight()/2

	love.graphics.circle("line", x, y, self.perception_range)
	love.graphics.circle("line", x, y, self.attack_range)

	self.animations[self.current_action]:draw(self['img_'..self.current_action], self.char_x, self.char_y, 0, self.scale_x, 1)

	self:get_action(self.current_action)
end

return Char
