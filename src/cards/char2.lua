local BaseCard = require('./src/entities/base_card')
local Assets = require('./src/assets')

local anim8 = require('./lib/anim8')

-- copy of char1 - only for testing
local Char2 = BaseCard.create()

-- override default config
Char2.name = 'char2'
Char2.range = 'melee'
Char2.img = Assets.CHAR1.CARD

-- position for card number 2
Char2.x = 220
Char2.y = 620

Char2.initial_position_x = 220
Char2.initial_position_y = 620

Char2.animations = {
	walk_animation = function()
		local walking = Assets.CHAR1.WALKING
		local grid = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())
		return anim8.newAnimation(grid('2-3', 1), 12)
	end
}

return Char2
