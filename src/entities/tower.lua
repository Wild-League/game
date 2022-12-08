local Layout = require('./src/helpers/layout')

local Tower = {
	num_towers = 3
}

-- local TowerMetatable = {}

function Tower:draw()
	local down_left = Layout:down_left(20, 20)
	love.graphics.rectangle('fill', down_left.width, down_left.height, 20, 20)
end

-- setmetatable(Tower, TowerMetatable)

return Tower
