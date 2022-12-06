local Assets = require('./src/assets')
local anim8 = require('./lib/anim8')

local Range = require('./src/config/range')

local Char3 = {
	name = 'char3',
	card_img = Assets.CHAR1.CARD,
	is_card_loading = false,
	img = Assets.CHAR1.INITIAL,
	speed = 6 / 10,
	cooldown = 10,
	attack_range = Range:getSize('distance', 80),
	attack_speed = 1.2,
	life = 100,
	x = 0,
	y = 0,
	current_action = 'walk',
	animate = {},
	actions = {},
	chars_around = {},
	selected = false,
	preview_card = false
}

-- LOAD
local walking = Assets.CHAR1.WALKING
local grid_walking = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())

local walk_animation = anim8.newAnimation(grid_walking('2-3', 1), 0.2)

local attack = Assets.CHAR1.ATTACK
local grid_attack = anim8.newGrid(36, 36, attack:getWidth(), attack:getHeight())

-- TODO: should split all frame so we can take control of the animation
-- individually, but we can leave like it is by now
local attack_animation = anim8.newAnimation(grid_attack('1-6', 1), 0.5)

function Char3:perception_range()
	return self.attack_range * 2
end

local nearest_enemy = {
	x = 0,
	y = 0
}

local shoot = {
	x = 0,
	y = 0
}

local shoot_animation = Assets.CHAR1.SHOOT
------

Char3.animate.update = function(self,dt)
	return Char3.actions[Char3.current_action].update(dt)
end

Char3.animate.draw = function(self, x, y, ...)
	self.lifebar(x,y)
	self.show_name(x,y)
	return self.actions[self.current_action].draw(x,y)
end

Char3.actions = {
	walk = {
		update = function(dt)
			walk_animation:update(dt)
		end,
		draw = function(x,y)
			x = x - Char3.speed
			-- y = y + Char3.speed

			walk_animation:draw(walking, x, y)

			return x, y
		end
	},
	follow = {
		update = function(dt)
			nearest_enemy = Char3.get_nearest_enemy(Char3.chars_around)

			walk_animation:update(dt)
		end,
		draw = function(x,y)
			if (nearest_enemy.y > y) then
				y = y + Char3.speed
			end
			if (nearest_enemy.y < y) then
				y = y - Char3.speed
			end
			if (nearest_enemy.x > x) then
				x = x + Char3.speed
			end
			if (nearest_enemy.x < x) then
				x = x - Char3.speed
			end

			walk_animation:draw(walking, x, y)
			return x,y
		end
	},
	attack = {
		update = function(dt)
			attack_animation:update(dt)
		end,
		draw = function(x,y)
			if nearest_enemy.width == nil then
				nearest_enemy = Char3.get_nearest_enemy(Char3.chars_around)
			end

			if (nearest_enemy.y > shoot.y) then
				shoot.y = shoot.y + Char3.attack_speed
			end
			if (nearest_enemy.y < shoot.y) then
				shoot.y = shoot.y - Char3.attack_speed
			end
			if (nearest_enemy.x > shoot.x) then
				shoot.x = shoot.x + Char3.attack_speed
			end
			if (nearest_enemy.x < shoot.x) then
				shoot.x = shoot.x - Char3.attack_speed
			end

			love.graphics.draw(shoot_animation, shoot.x, shoot.y)

			if math.ceil(shoot.x) == nearest_enemy.x and math.ceil(shoot.y) == nearest_enemy.y then
        shoot.x = Char3.char_x
        shoot.y = Char3.char_y
    	end

			attack_animation:draw(attack,x,y)
			return x,y
		end
	}
}

function Char3.get_nearest_enemy(around)
	shoot.x = Char3.char_x
	shoot.y = Char3.char_y

	for k,v in pairs(around) do
		local distance_x = v.x - Char3.char_x
		local distance_y = v.y - Char3.char_y

		if (distance_x >= (nearest_enemy.x - Char3.char_x))
			and (distance_y >= (nearest_enemy.y - Char3.char_y)) then
			return v
		end
	end
end

function Char3.lifebar(x, y)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x - 10, y - 10, 50, 5)
	love.graphics.rectangle("fill", x - 10, y - 10, 50, 5)
	love.graphics.setColor(255,255,255)
end

function Char3.show_name(x, y)
	love.graphics.print(Char3.name, x, y)
end

return Char3
