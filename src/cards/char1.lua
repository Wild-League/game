local BaseCard = require('./src/entities/base_card')
local Assets = require('./src/assets')

local anim8 = require('./lib/anim8')

local Char1 = BaseCard.create()

-- override default config
Char1.name = 'char1'
Char1.range = 'melee'
Char1.img = Assets.CHAR1.CARD

Char1.x = 0
Char1.y = 0

Char1.animations = {
	initial = function()
		local walking = Assets.CHAR1.WALKING
		local grid = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())
		return anim8.newAnimation(grid('1-1'), 12)
	end,

	walk = function()
		local walking = Assets.CHAR1.WALKING
		local grid = anim8.newGrid(34, 36, walking:getWidth(), walking:getHeight())
		return anim8.newAnimation(grid('2-3', 1), 12)
	end
}

return Char1
