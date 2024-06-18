local Suit = require('lib.suit')
local Images = require('src.ui.images')
local Layout = require('src.helpers.layout')

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
	local center_background = Layout:center(100, 100)
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle('fill', center_background.width - 50, 10, 150, 60)
	love.graphics.setColor(1, 1, 1)

	love.graphics.draw(Images.sun, x - 50, y - 30, 0, 0.2, 0.2)
	Suit.Label(self.time_to_show, x, y + 5, w, h)
end

function Timer:reset()
	self.timer = 0
	self.time_to_show = 0
end

return Timer
