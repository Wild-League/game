local Layout = require('./src/helpers/layout')

local tower_size = 50

local down_left = Layout:down_left(tower_size, tower_size)
local up_right = Layout:up_right(tower_size, tower_size)

local Tower = {
	num_towers = 3,
	positions_left = {
		tower1 = {
			x = down_left.width,
			y = down_left.height - 200
		},
		tower2 = {
			x = down_left.width,
			y = down_left.height
		},
		tower3 = {
			x = down_left.width + 200,
			y = down_left.height
		}
	},
	positions_right = {
		tower1 = {
			x = up_right.width - 200,
			y = up_right.height
		},
		tower2 = {
			x = up_right.width,
			y = up_right.height
		},
		tower3 = {
			x = up_right.width,
			y = up_right.height + 200
		}
	}
}

-- local TowerMetatable = {}

function Tower:draw()
	for i = 1, self.num_towers do
		local pos = self.positions_left['tower'..i]
		love.graphics.rectangle('fill', pos.x, pos.y, 50, 50)
		love.graphics.ellipse('line', pos.x + 25, pos.y+ 25, 100, 100)
	end

	for i = 1, self.num_towers do
		local pos = self.positions_right['tower'..i]
		love.graphics.rectangle('fill', pos.x, pos.y, 50, 50)
		love.graphics.ellipse('line', pos.x + 25, pos.y+ 25, 100, 100)
	end
end

-- setmetatable(Tower, TowerMetatable)

return Tower
