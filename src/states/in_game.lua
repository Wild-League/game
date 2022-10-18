local Suit = require('./lib/suit') -- called from main
local Layout = require('./src/helpers/layout')
local anim8 = require('./lib/anim8')
local Assets = require('./src/assets')
-- local Constants = require('./src/constants')

local DT = 0

local In_Game = {
	__call = function(self, dt)
		DT = dt
		self.load()
		self.draw()
	end
}

setmetatable(In_Game, In_Game)

function In_Game:load()
	WALKING = Assets.WALKING
end

function In_Game:draw()
	local center = Layout:Centralize(34, 36) -- sprite size

	local grid = anim8.newGrid(34, 36, WALKING:getWidth(), WALKING:getHeight())

	local walk_animation = anim8.newAnimation(grid('1-3', 1), 1)

	-- for i=1,#walk_animation do

		walk_animation:update(DT)
		-- walk_animation:gotoFrame(3)
		walk_animation:draw(WALKING, center.width, center.height)

	-- end
end

return In_Game
