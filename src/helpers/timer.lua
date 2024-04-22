local Suit = require('lib.suit')

local Timer = {
	timer = 0,
	time_to_show = 0
}

function Timer:new()
	local timer = {
		timer = 0,
		time_to_show = 0
	}

	setmetatable(timer, self)
	self.__index = self

	return timer
end

function Timer:update(dt)
	self.timer = self.timer + dt

	local seconds = tostring(math.floor(self.timer % 60))
	local minutes = tostring(math.floor(self.timer / 60))

	if tonumber(seconds) <= 9 then
		seconds = '0'..seconds
	end
	if tonumber(minutes) <= 9 then
		minutes = '0'..minutes
	end

	self.time_to_show = minutes..':'..seconds
end

function Timer:draw(x, y, w, h)
	Suit.Label(self.time_to_show, x, y, w, h)
end

return Timer
