local BaseCard = require('./src/entities/base_card')
local Assets = require('./src/assets')

local anim8 = require('./lib/anim8')

-- copy of char1 - only for testing
local Char4 = BaseCard.create()

-- override default config
Char4.name = 'char4'
Char4.range = 'melee'
Char4.img = Assets.CHAR1.CARD

Char4.x = 0
Char4.y = 0

Char4.animations = {
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

return Char4
