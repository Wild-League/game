local Constants = require('./src/constants')
local Layout = require('./src/helpers/layout')

local Map = {
	-- indicates the max value in x to each side
	left_side = 0,
	right_side = 0
}

function Map:sides()
	local center = Layout:Center(2, 2)

	Map.left_side = center.width
	Map.right_side = center.width * 2

	-- draw divisor
	-- love.graphics.line(center.width, center.height - 100, center.width, center.height + 100)

	-- left side
	love.graphics.setColor(1,0,0, 0.5)
	love.graphics.rectangle('fill', 0, 0, Map.left_side, center.height * 2)

	love.graphics.setColor(1,1,1)
end

return Map
