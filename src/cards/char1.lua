local BaseCard = require('./src/entities/base_card')
local Assets = require('./src/assets')

local anim8 = require('./lib/anim8')

local Char1 = BaseCard.create()

-- override default config
Char1.name = 'char1'
Char1.range = 'melee'
Char1.img = Assets.CHAR1.CARD

Char1.speed = 8 / 10

Char1.range = 20

Char1.x = 0
Char1.y = 0

local walking = Assets.CHAR1.WALKING
local grid = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())

local walk_animation = anim8.newAnimation(grid('2-3', 1), 0.2)

local initial_animation = anim8.newAnimation(grid('1-1', 1), 0.2)

Char1.animations = {
	initial = {
		update = function(dt)
			initial_animation:update(dt)
		end,
		draw = function(x,y)
			initial_animation:draw(Assets.CHAR1.WALKING, x, y)
		end
	},

	walk = {
		update = function(dt)
			walk_animation:update(dt)
		end,
		draw = function(x,y, destiny_x, destiny_y)
			-- TODO: need to add 'area_perception' to base_card
			-- that indicates the range where the hero realizes that there is
			-- someone around.
			-- NOTE: this is different from 'range' - this means the area that
			-- the hero can attack

			-- if (x ~= destiny_x and y ~= destiny_y) then
			-- 	local follow_x, follow_y = Char1.animations.follow.draw(x, y, destiny_x, destiny_y)
			-- 	return follow_x, follow_y
			-- end

			x = x - Char1.speed
			-- y = y + Char1.speed

			walk_animation:draw(Assets.CHAR1.WALKING, x, y)

			return x, y
		end
	},
	follow = {
		update = function(dt)
			initial_animation:update(dt)
		end,
		draw = function(x,y, destiny_x, destiny_y)
			local x_distance = destiny_x - x
			local y_distance = destiny_y - y

			x = x + (x_distance * Char1.speed)
			y = y + (y_distance * Char1.speed)

			return x,y
		end
	}
}

return Char1
