local BaseCard = require('./src/entities/base_card')
local Assets = require('./src/assets')
local Utils = require('./src/helpers/utils')
local anim8 = require('./lib/anim8')

local Range = require('./src/config/range')

local Char1 = BaseCard.create()

-- override default config
Char1.name = 'char1'
Char1.card_img = Assets.CHAR1.CARD

Char1.img = Assets.CHAR1.INITIAL

Char1.speed = 6 / 10

Char1.cooldown = 10

Char1.attack_range = Range:getSize('distance', 80)

Char1.attack_speed = 1.2

Char1.life = 100

Char1.x = 0
Char1.y = 0

Char1.current_action = 'walk'

-- LOAD
local walking = Assets.CHAR1.WALKING
local grid_walking = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())

local walk_animation = anim8.newAnimation(grid_walking('2-3', 1), 0.2)

local attack = Assets.CHAR1.ATTACK
local grid_attack = anim8.newGrid(36, 36, attack:getWidth(), attack:getHeight())

-- TODO: should split all frame so we can take control of the animation
-- individually, but we can leave like it is by now
local attack_animation = anim8.newAnimation(grid_attack('1-6', 1), 0.5)

local nearest_enemy = {
	x = 0,
	y = 0
}

local shoot = {
	x = Char1.char_x,
	y = Char1.char_y
}

local shoot_animation = Assets.CHAR1.SHOOT
------

Char1.animate.update = function(dt)
	return Char1.actions[Char1.current_action].update(dt)
end

Char1.animate.draw = function(x, y, ...)
	Char1.lifebar(x,y)

	love.graphics.setColor(255,255,255)
	-- attack range
	love.graphics.ellipse("line", x + (Char1.img:getWidth() / 4), y + (Char1.img:getHeight() / 4), Char1.attack_range, Char1.attack_range)

	-- perception range
	love.graphics.ellipse("line", x + (Char1.img:getWidth() / 4), y + (Char1.img:getHeight() / 4), Char1:perception_range(), Char1:perception_range())

	return Char1.actions[Char1.current_action].draw(x,y)
end

Char1.actions = {
	walk = {
		update = function(dt)
			walk_animation:update(dt)
		end,
		draw = function(x,y)
			x = x - Char1.speed
			-- y = y + Char1.speed

			walk_animation:draw(walking, x, y)

			return x, y
		end
	},
	follow = {
		update = function(dt)
			nearest_enemy = Char1.get_nearest_enemy(Char1.chars_around)

			walk_animation:update(dt)
		end,
		draw = function(x,y)
			if (nearest_enemy.y > y) then
				y = y + Char1.speed
			end
			if (nearest_enemy.y < y) then
				y = y - Char1.speed
			end
			if (nearest_enemy.x > x) then
				x = x + Char1.speed
			end
			if (nearest_enemy.x < x) then
				x = x - Char1.speed
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
				nearest_enemy = Char1.get_nearest_enemy(Char1.chars_around)
			end

			if (nearest_enemy.y > shoot.y) then
				shoot.y = shoot.y + Char1.attack_speed
			end
			if (nearest_enemy.y < shoot.y) then
				shoot.y = shoot.y - Char1.attack_speed
			end
			if (nearest_enemy.x > shoot.x) then
				shoot.x = shoot.x + Char1.attack_speed
			end
			if (nearest_enemy.x < shoot.x) then
				shoot.x = shoot.x - Char1.attack_speed
			end

			love.graphics.draw(shoot_animation, shoot.x, shoot.y)

			if math.ceil(shoot.x) == nearest_enemy.x and math.ceil(shoot.y) == nearest_enemy.y then
        shoot.x = Char1.char_x
        shoot.y = Char1.char_y
    	end

			attack_animation:draw(attack,x,y)
			return x,y
		end
	}
}

function Char1.get_nearest_enemy(around)
	shoot.x = Char1.char_x
	shoot.y = Char1.char_y

	for k,v in pairs(around) do
		local distance_x = v.x - Char1.char_x
		local distance_y = v.y - Char1.char_y

		if (distance_x >= (nearest_enemy.x - Char1.char_x))
			and (distance_y >= (nearest_enemy.y - Char1.char_y)) then
			return v
		end
	end
end

function Char1.lifebar(x, y)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x - 10, y - 10, 50, 5)
	love.graphics.rectangle("fill", x - 10, y - 10, 25, 5)
end

return Char1
