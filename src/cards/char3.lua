local BaseCard = require('./src/entities/base_card')
local Assets = require('./src/assets')

local anim8 = require('./lib/anim8')

-- copy of char1 - only for testing
local Char3 = BaseCard.create()

-- override default config
Char3.name = 'char3'
Char3.range = 'melee'
Char3.img = Assets.CHAR1.CARD

-- position for card number 3
Char3.x = 320
Char3.y = 620

Char3.initial_position_x = 320
Char3.initial_position_y = 620

Char3.animations = {
	walk_animation = function()
		local walking = Assets.CHAR1.WALKING
		local grid = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())
		return anim8.newAnimation(grid('2-3', 1), 12)
	end
}

return Char3
