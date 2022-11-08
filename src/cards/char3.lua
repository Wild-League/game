local BaseCard = require('./src/entities/base_card')
local Assets = require('./src/assets')

local anim8 = require('./lib/anim8')

-- copy of char1 - only for testing
local Char3 = BaseCard.create()

-- override default config
Char3.name = 'char3'
Char3.range = 'melee'
Char3.img = Assets.CHAR1.CARD

Char3.x = 0
Char3.y = 0

Char3.animations = {
	initial = function()
		local walking = Assets.CHAR1.WALKING
		local grid = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())
		return anim8.newAnimation(grid('1-1', 1), 12)
	end,

	walk = function()
		local walking = Assets.CHAR1.WALKING
		local grid = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())
		return anim8.newAnimation(grid('2-3', 1), 12)
	end
}

return Char3
