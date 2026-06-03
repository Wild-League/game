local Utils = require('src.helpers.utils')

local Char = {
	current_action = 'walk',
	current_life = 0,

	scale_x = 1,

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

local RENDER_SCALE = 1.2

local function char_frame_size(c)
	local fw = c.frame_width or 60
	local fh = c.frame_height or 60
	return fw, fh
end

local function char_hitbox_dimensions(card)
	local fw, fh = char_frame_size(card)
	return fw * RENDER_SCALE, fh * RENDER_SCALE
end

local function char_hitbox_origin(card)
	local sw, _ = char_hitbox_dimensions(card)
	if (card.scale_x or 1) < 0 then
		return card.char_x - sw, card.char_y
	end
	return card.char_x, card.char_y
end

local function char_range_center(c)
	local fw, fh = char_frame_size(c)
	local scaled_w = fw * RENDER_SCALE
	local scaled_h = fh * RENDER_SCALE
	if (c.scale_x or 1) < 0 then
		return c.char_x - scaled_w / 2, c.char_y + scaled_h / 2
	end
	return c.char_x + scaled_w / 2, c.char_y + scaled_h / 2
end

local function is_living_char(card)
	return card
			and card.type == 'char'
		and (card.current_life or card.life or 0) > 0
			and card.current_action ~= 'death'
			and not card.pending_removal
end

local function enemy_in_attack_range(attacker, target)
	local self_cx, self_cy = char_range_center(attacker)
	local rx, ry = char_hitbox_origin(target)
	local rw, rh = char_hitbox_dimensions(target)
	return Utils.circle_rect_collision(
		self_cx, self_cy, attacker.attack_range / 2,
		rx, ry, rw, rh
	)
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

local function get_death_animation_duration(char)
	if char.death_animation_duration then
		return char.death_animation_duration
	end

	local default_duration = 0.35
	if not char.img_death or not char.frame_width then
		char.death_animation_duration = default_duration
		return char.death_animation_duration
	end

	local total_width = char.img_death:getWidth() or 0
	local frame_width = char.frame_width or 0
	local number_frames = math.max(1, math.floor(total_width / frame_width))
	local frame_duration = (char.speed or 1) / 10

	char.death_animation_duration = math.max(default_duration, number_frames * frame_duration)
	return char.death_animation_duration
end

function Char:has_attackable_enemy(enemies)
	for _, enemy in pairs(enemies or {}) do
		if is_living_char(enemy) and enemy_in_attack_range(self, enemy) then
			return true
		end
	end
	return false
end

function Char:get_enemies_in_range(enemies)
	if not is_living_char(self) then
		self.nearest_enemy = nil
		self.enemies_around = {}
		return
	end

	local self_cx, self_cy = char_range_center(self)

	for k, v in pairs(enemies or {}) do
		if is_living_char(v) then
			local rx, ry = char_hitbox_origin(v)
			local rw, rh = char_hitbox_dimensions(v)
			local in_perception = Utils.circle_rect_collision(
				self_cx, self_cy, self.perception_range / 2,
				rx, ry, rw, rh
			)
			self.enemies_around[k] = in_perception and v or nil
		else
			self.enemies_around[k] = nil
		end
	end

	self:get_nearest_enemy()
	self:check_attack_range()
end

function Char:check_attack_range()
	if not is_living_char(self) then
		self.current_action = 'death'
		return
	end

	local target = self.nearest_enemy
	local in_range = target and enemy_in_attack_range(self, target)

	if in_range then
		if self.current_action ~= 'attack' then
			self.current_action = 'attack'
		end
	elseif self.current_action == 'attack' then
		self.current_action = 'walk'
	end
end

function Char:get_nearest_enemy()
	local nearest_distance = math.huge
	local nearest = nil
	local self_cx, self_cy = char_range_center(self)

	for k, v in pairs(self.enemies_around) do
		if v then
			local vx, vy = char_range_center(v)
			local distance_x = vx - self_cx
			local distance_y = vy - self_cy
			local distance = math.sqrt(distance_x * distance_x + distance_y * distance_y)

			if distance < nearest_distance then
				nearest_distance = distance
				v.card_id = k
				nearest = v
			end
		end
	end

	self.nearest_enemy = nearest
end

function Char:preview(x, y)
	local walk_quad = get_walk_preview_quad(self)

	if not walk_quad then return end

	local fw = (self.frame_width or 60) * RENDER_SCALE
	local fh = (self.frame_height or 60) * RENDER_SCALE
	local center_x = x - fw / 2
	local center_y = y - fh / 2

	love.graphics.setColor(0.2, 0.2, 0.7, 0.5)
	love.graphics.draw(self.img_walk, walk_quad, center_x, center_y, 0, RENDER_SCALE, RENDER_SCALE)
	love.graphics.setColor(1, 1, 1, 1)
end

function Char:lifebar(x, y, current_life)
	current_life = current_life or self.current_life or self.life or 0
	local max_life = self.life or 1
	local bar_width = 46
	local bar_height = 5
	local fill_ratio = math.max(0, math.min(1, current_life / max_life))
	local fill_width = bar_width * fill_ratio

	if self.enemy then
		love.graphics.setColor(1, 29 / 255, 29 / 255)
	else
		love.graphics.setColor(0, 200 / 255, 0)
	end
	love.graphics.rectangle("line", x, y, bar_width, bar_height)
	love.graphics.rectangle("fill", x, y, fill_width, bar_height)
	love.graphics.setColor(1, 1, 1, 1)
end

function Char:update(dt)
	local anim = self.animations[self.current_action]
	if anim and type(anim.update) == 'function' then
		anim:update(dt)
	end

	if self.current_action == 'death' then
		self.death_elapsed = (self.death_elapsed or 0) + dt
		self.death_animation_duration = get_death_animation_duration(self)
		return
	end

	local prev_x = self._prev_char_x
	if prev_x == nil then
		prev_x = self.char_x
	end

	if self.predicted and self.current_action == 'walk' then
		local new_position = self.enemy
				and self.char_x + self.speed
				or self.char_x - self.speed
		self.char_x = new_position
	end

	if self.predicted and self.current_action == 'walk' then
		if self.char_x > prev_x then
			self.scale_x = -1
		elseif self.char_x < prev_x then
			self.scale_x = 1
		end
	end

	self._prev_char_x = self.char_x
end

function Char:draw()
	love.graphics.setColor(1, 1, 1, 1)

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
		if self.damage_flash_until and love.timer.getTime() < self.damage_flash_until then
			love.graphics.setColor(1, 0.45, 0.45, 1)
		end
		current_animation:draw(
			current_img,
			self.char_x,
			self.char_y,
			0,
			self.scale_x * RENDER_SCALE,
			RENDER_SCALE
		)
		love.graphics.setColor(1, 1, 1, 1)
	end

	local bar_w = 46
	local lcx, _ = char_range_center(self)
	local lifebar_x = lcx - bar_w / 2
	local lifebar_y = self.char_y + fh * RENDER_SCALE + 4
	self:lifebar(lifebar_x, lifebar_y, self.current_life)
end

return Char
