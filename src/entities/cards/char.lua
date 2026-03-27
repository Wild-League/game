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

-- anim8 draws with top-left at (char_x, char_y) when scale_x >= 0, and with the
-- right edge at char_x when flipped (scale_x < 0). Match hitboxes, range circles,
-- and lifebar to that footprint.
local function char_frame_size(c)
	local fw = c.frame_width or 60
	local fh = c.frame_height or 60
	return fw, fh
end

local function char_hit_top_left(c)
	local fw, fh = char_frame_size(c)
	if (c.scale_x or 1) < 0 then
		return c.char_x - fw, c.char_y
	end
	return c.char_x, c.char_y
end

local function char_range_center(c)
	local fw, fh = char_frame_size(c)
	if (c.scale_x or 1) < 0 then
		return c.char_x - fw / 2, c.char_y + fh / 2
	end
	return c.char_x + fw / 2, c.char_y + fh / 2
end

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

	for k, v in pairs(enemies) do
		if v.type == 'char' then
			enemies_in_range[k] = v
		end
	end

	for k, v in pairs(enemies_in_range) do
		local scx, scy = char_range_center(self)
		local rx, ry = char_hit_top_left(v)
		local vw, vh = char_frame_size(v)
		local has_collision = Utils.circle_rect_collision(
			scx, scy, self.perception_range / 2,
			rx, ry, vw, vh
		)

		self.enemies_around[k] = has_collision and v or nil
	end

	self:get_nearest_enemy()

	if self.nearest_enemy then
		self:check_attack_range()
	end
end

function Char:check_attack_range()
	local scx, scy = char_range_center(self)
	local rx, ry = char_hit_top_left(self.nearest_enemy)
	local rw, rh = char_frame_size(self.nearest_enemy)
	local attack_range_collision = Utils.circle_rect_collision(
		scx, scy, self.attack_range / 2,
		rx, ry, rw, rh
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
	local best = nil
	local best_d = math.huge

	for k, v in pairs(self.enemies_around) do
		if v then
			local ax, ay = char_range_center(self)
			local bx, by = char_range_center(v)
			local dx, dy = bx - ax, by - ay
			local distance = math.sqrt(dx * dx + dy * dy)

			if distance < best_d then
				best_d = distance
				v.card_id = k
				best = v
			end
		end
	end

	self.nearest_enemy = best
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
	current_life = current_life or self.current_life or self.life or 0
	local max_life = self.life or 1
	local bar_width = 46
	local bar_height = 5
	local fill_ratio = math.max(0, math.min(1, current_life / max_life))
	local fill_width = bar_width * fill_ratio

	love.graphics.setColor(1, 29 / 255, 29 / 255)
	love.graphics.rectangle("line", x, y, bar_width, bar_height)
	love.graphics.rectangle("fill", x, y, fill_width, bar_height)
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

	local rcx, rcy = char_range_center(self)
	love.graphics.circle("line", rcx, rcy, self.perception_range / 2)
	love.graphics.circle("line", rcx, rcy, self.attack_range / 2)

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

	local bar_w = 46
	local lcx, _ = char_range_center(self)
	local lifebar_x = lcx - bar_w / 2
	local lifebar_y = self.char_y + fh + 4
	self:lifebar(lifebar_x, lifebar_y, self.current_life)

	self:get_action(self.current_action)
end

return Char
