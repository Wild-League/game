local Constants = require('./src/constants')
local Layout = require('./src/helpers/layout')

local Map = {
	-- indicates the max value in x to each side
	left_side = {
		w = 0,
		h = 0
	},
	right_side = {
		w = 0,
		h = 0
	}
}

function Map:sides()
	local center = Layout:Center(2, 2)

	Map.left_side.w = center.width
	Map.right_side.w = center.width * 2

	Map.left_side.h = center.height * 2
	Map.right_side.h = center.height * 2
end

function Map:block_left_side()
	Map:sides()

	love.graphics.setColor(1,0,0, 0.5)
	love.graphics.rectangle('fill', 0, 0, Map.left_side.w, Map.left_side.h)

	love.graphics.setColor(1,1,1)
end

return Map
