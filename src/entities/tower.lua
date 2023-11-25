local Layout = require('src.helpers.layout')
local Assets = require('src.assets')

-- TODO: review
local Tower = {
	range = 220,

	life = 2000,
	current_life = 2000,

	shoot = {
		x = 0,
		y = 0
	},

	num_towers = 2
}

function Tower:load()
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

function Tower:update() end

function Tower:draw()
	-- towers from left
	for i = 1, self.num_towers do
		local pos = self.positions_left['tower'..i]
		love.graphics.draw(Assets.TOWER_LEFT, pos.x, pos.y)

		local w = Assets.TOWER_LEFT:getWidth() / 2
		local h = Assets.TOWER_LEFT:getHeight() / 1.4

		local x = pos.x + w / 2
		local y = pos.y + h

		self:lifebar(x, y)
	end

	-- towers from right
	for i = 1, self.num_towers do
		local pos = self.positions_right['tower'..i]
		love.graphics.draw(Assets.TOWER_RIGHT, pos.x, pos.y)

		local w = Assets.TOWER_RIGHT:getWidth() / 2
		local h = Assets.TOWER_RIGHT:getHeight() / 1.4

		local x = pos.x + w / 1.4
		local y = pos.y + h

		self:lifebar(x, y)
	end
end

function Tower:lifebar(x,y)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x, y, 100, 5)
	love.graphics.rectangle("fill", x, y, 100, 5)
	love.graphics.setColor(255,255,255)
end

return Tower
