local Layout = require('./src/helpers/layout')
local anim8 = require('./lib/anim8')
local Assets = require('./src/assets')

local center = Layout:Centralize(34, 36) -- sprite size

local initial = 600

local In_Game = {
	__call = function(self)
		self:load()
		self:draw()
	end,
	walk_animation = {}
}

setmetatable(In_Game, In_Game)

function In_Game:load()
	WALKING = Assets.WALKING

	local grid = anim8.newGrid(34, 36, WALKING:getWidth(), WALKING:getHeight())

	-- TODO: need to fix animation sprite, it's kinda weird
	self.walk_animation = anim8.newAnimation(grid('1-3', 1), 12)
end

function In_Game:draw()
	initial = initial - 0.5

	self.walk_animation:update(initial)
	self.walk_animation:draw(WALKING, center.width, initial)
end

return In_Game
