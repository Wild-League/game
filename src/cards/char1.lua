local BaseCard = require('./src/entities/base_card')
local Assets = require('./src/assets')

local anim8 = require('./lib/anim8')

local Char1 = BaseCard.create()

-- override default config
Char1.name = 'char1'
Char1.range = 'melee'
Char1.img = Assets.CHAR1.CARD

Char1.animations = {
	walk_animation = function()
		local walking = Assets.CHAR1.WALKING
		local grid = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())
		return anim8.newAnimation(grid('2-3', 1), 12)
	end
}

return Char1
