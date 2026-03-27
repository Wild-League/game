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

local function get_walk_preview_quad(char)
	if not char.img_walk then return nil end
	if not char.frame_width or not char.frame_height then return nil end
	if char.img_walk:getWidth() < char.frame_width then return nil end
	if char.img_walk:getHeight() < char.frame_height then return nil end

	if not char.walk_preview_quad then
		char.walk_preview_quad = love.graphics.newQuad(
			0,
			0,
			char.frame_width,
			char.frame_height,
			char.img_walk:getWidth(),
			char.img_walk:getHeight()
		)
	end

	return char.walk_preview_quad
end

function Char:get_enemies_in_range(enemies)
	local enemies_in_range = {}

	for k,v in pairs(enemies) do
		if v.type == 'char' then
			enemies_in_range[k] = v
		end
	end

	for k,v in pairs(enemies_in_range) do
		local has_collision = Utils.circle_rect_collision(
			self.char_x, self.char_y, self.perception_range/2,
			v.char_x, v.char_y, v.frame_width or 60, v.frame_height or 60
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
		self.nearest_enemy.frame_width or 60, self.nearest_enemy.frame_height or 60
	)

	if attack_range_collision then
		if self.current_action ~= 'attack' then
			self.current_action = 'attack'

			coroutine.resume(coroutine.create(function()
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
	local walk_quad = get_walk_preview_quad(self)
	if not walk_quad then return end

	local center_x = x - self.frame_width / 2
	local center_y = y - self.frame_height / 2

	love.graphics.setColor(0.2, 0.2, 0.7, 0.5)
	love.graphics.draw(self.img_walk, walk_quad, center_x, center_y)
	love.graphics.setColor(1, 1, 1, 1)
end

function Char:lifebar(x, y, current_life)
	love.graphics.setColor(1, 29/255, 29/255)
	love.graphics.rectangle("line", x - 10, y - 10, self.life, 5)
	love.graphics.rectangle("fill", x - 10, y - 10, current_life, 5)
	love.graphics.setColor(1, 1, 1, 1)
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
	local anim = self.animations[self.current_action]
	if anim and type(anim.update) == 'function' then
		anim:update(dt)
	end
end

function Char:draw()
	self.last_x = self.char_x
	love.graphics.setColor(1, 1, 1, 1)

	local fw = self.frame_width or 60
	local fh = self.frame_height or 60

	local x = self.enemy and self.char_x - fw/2 or self.char_x + fw/2
	local y = self.char_y + fh/2

	love.graphics.circle("line", x, y, self.perception_range)
	love.graphics.circle("line", x, y, self.attack_range)

	local action = self.current_action
	local current_animation = self.animations[action]
	local current_img = self['img_' .. action]

	local has_valid_anim = current_animation
		and type(current_animation.draw) == 'function'
		and current_img

	if has_valid_anim then
		current_animation:draw(current_img, self.char_x, self.char_y, 0, self.scale_x, 1)
	else
		local walk_quad = get_walk_preview_quad(self)
		if walk_quad then
			love.graphics.draw(self.img_walk, walk_quad, self.char_x, self.char_y, 0, self.scale_x, 1)
		end
	end

	self:get_action(self.current_action)
end

return Char
