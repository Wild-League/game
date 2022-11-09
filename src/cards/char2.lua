local BaseCard = require('./src/entities/base_card')
local Assets = require('./src/assets')

local anim8 = require('./lib/anim8')

-- copy of char1 - only for testing
local Char2 = BaseCard.create()

-- override default config
Char2.name = 'char2'
Char2.range = 'melee'
Char2.img = Assets.CHAR1.CARD

Char2.x = 0
Char2.y = 0

local walking = Assets.CHAR1.WALKING
local grid = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())

local walk_animation = anim8.newAnimation(grid('2-3', 1), 0.2)

local initial_animation = anim8.newAnimation(grid('1-1', 1), 0.2)

Char2.animations = {
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
		draw = function(x,y)
			walk_animation:draw(Assets.CHAR1.WALKING, x, y)
		end
	}
}

return Char2
