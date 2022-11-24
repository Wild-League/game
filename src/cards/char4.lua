local BaseCard = require('./src/entities/base_card')
local Assets = require('./src/assets')

local anim8 = require('./lib/anim8')

-- copy of char1 - only for testing
local Char4 = BaseCard.create()

-- override default config
Char4.name = 'char4'
Char4.range = 'melee'
Char4.card_img = Assets.CHAR1.CARD

Char4.x = 0
Char4.y = 0

local walking = Assets.CHAR1.WALKING
local grid = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())

local walk_animation = anim8.newAnimation(grid('2-3', 1), 0.2)

local initial_animation = anim8.newAnimation(grid('1-1', 1), 0.2)

Char4.animations = {
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

return Char4
