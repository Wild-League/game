local Utils = require('src.helpers.utils')

local Spell = {
	current_action = 'attack',
	enemies_around = {},
	hit_targets = {},

	animations = {
		attack = {}
	}
}

local RENDER_SCALE = 1.2
local MIN_CAST_DURATION = 0.35

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

local function is_living_char(card)
	return card
			and card.type == 'char'
			and (card.current_life or card.life or 0) > 0
			and card.current_action ~= 'death'
			and not card.pending_removal
end

local function is_active_spell(spell)
	return spell
			and spell.type == 'spell'
			and not spell.pending_removal
end

local function spell_aoe_center(spell)
	return spell.char_x, spell.char_y
end

local function spell_aoe_radius(spell)
	return (spell.attack_range or 100) / 2
end

local function enemy_in_spell_aoe(spell, enemy)
	local cx, cy = spell_aoe_center(spell)
	local radius = spell_aoe_radius(spell)
	local rx, ry = char_hitbox_origin(enemy)
	local rw, rh = char_hitbox_dimensions(enemy)
	return Utils.circle_rect_collision(cx, cy, radius, rx, ry, rw, rh)
end

local function spell_frame_size(s)
	local fw = s.frame_width or 60
	local fh = s.frame_height or 60
	return fw, fh
end

local function spell_draw_origin(spell)
	local fw, fh = spell_frame_size(spell)
	local scaled_w = fw * RENDER_SCALE
	local scaled_h = fh * RENDER_SCALE
	return spell.char_x - scaled_w / 2, spell.char_y - scaled_h / 2
end

function Spell:get_cast_duration()
	if self.cast_duration then
		return math.max(MIN_CAST_DURATION, self.cast_duration)
	end

	local duration = MIN_CAST_DURATION
	local anim = self.animations and self.animations.attack
	if anim and anim.totalDuration and anim.totalDuration > 0 then
		duration = anim.totalDuration
	else
		local aps = tonumber(self.attack_speed)
		if aps and aps > 0 then
			duration = 1 / aps
		end
	end

	self.cast_duration = math.max(MIN_CAST_DURATION, duration)
	return self.cast_duration
end

function Spell:mark_targets_hit()
	if self.targets_hit then
		return
	end

	self.targets_hit = true
	self.hit_targets = {}

	for k, v in pairs(self.enemies_around or {}) do
		if v then
			self.hit_targets[k] = v
		end
	end
end

function Spell:get_enemies_in_range(enemies)
	if not is_active_spell(self) then
		self.enemies_around = {}
		return
	end

	for k, v in pairs(enemies or {}) do
		if is_living_char(v) and enemy_in_spell_aoe(self, v) then
			self.enemies_around[k] = v
		else
			self.enemies_around[k] = nil
		end
	end
end

function Spell:preview(x, y)
	local radius = spell_aoe_radius(self)

	love.graphics.setColor(0.4, 0.5, 1, 0.2)
	love.graphics.circle('fill', x, y, radius)
	love.graphics.setColor(0.4, 0.6, 1, 0.85)
	love.graphics.circle('line', x, y, radius)
	love.graphics.setColor(1, 1, 1, 1)
end

function Spell:update(dt)
	if self.pending_removal then
		return
	end

	local anim = self.animations and self.animations[self.current_action]
	if anim and type(anim.update) == 'function' then
		anim:update(dt)
	end

	if not self.targets_hit then
		self:mark_targets_hit()
	end

	self.cast_elapsed = (self.cast_elapsed or 0) + dt
	if self.cast_elapsed >= self:get_cast_duration() then
		self.pending_removal = true
		self.local_cast = false
		self.predicted = false
	end
end

function Spell:draw()
	love.graphics.setColor(1, 1, 1, 1)

	local action = self.current_action
	local current_animation = self.animations[action]
	local current_img = self['img_' .. action]

	local has_valid_anim = current_animation
			and type(current_animation.draw) == 'function'
			and current_img

	if has_valid_anim then
		local draw_x, draw_y = spell_draw_origin(self)
		current_animation:draw(
			current_img,
			draw_x,
			draw_y,
			0,
			RENDER_SCALE,
			RENDER_SCALE
		)
	end

	if self.hit_flash_until and love.timer.getTime() < self.hit_flash_until then
		local cx, cy = spell_aoe_center(self)
		local radius = spell_aoe_radius(self)
		love.graphics.setColor(1, 0.3, 0.2, 0.35)
		love.graphics.circle('fill', cx, cy, radius)
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function Spell:flash_hit()
	self.hit_flash_until = love.timer.getTime() + 0.15
end

return Spell
