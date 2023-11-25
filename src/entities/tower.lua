local Layout = require('src.helpers.layout')
local Assets = require('src.assets')

-- TODO: review
local Tower = {
	range = 220,

	shoot = {
		x = 0,
		y = 0
	},

	num_towers = 2
}

function Tower:update()
	local center = Layout:center(Assets.TOWER_LEFT:getWidth(), Assets.TOWER_LEFT:getHeight())

	self.positions_left = {
		tower1 = {
			x = center.width - 470,
			y = center.height - 250
		},
		tower2 = {
			x = center.width - 470,
			y = center.height + 250
		}
	}

	self.positions_right = {
		tower1 = {
			x = center.width + 470,
			y = center.height - 250
		},
		tower2 = {
			x = center.width + 470,
			y = center.height + 250
		}
	}
end

function Tower:draw()
	-- towers from left
	for i = 1, self.num_towers do
		local pos = self.positions_left['tower'..i]
		love.graphics.draw(Assets.TOWER_LEFT, pos.x, pos.y)
	end

	-- towers from right
	for i = 1, self.num_towers do
		local pos = self.positions_right['tower'..i]
		love.graphics.draw(Assets.TOWER_RIGHT, pos.x, pos.y)
	end
end

return Tower
