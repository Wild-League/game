local Layout = require('src.helpers.layout')
local Assets = require('src.assets')

local Tower = {}

local default_props = {
	type = 'tower',
	life = 100,
	current_life = 100,

	w = Assets.TOWER_LEFT:getWidth(),
	h = Assets.TOWER_LEFT:getHeight()
}

local center = Layout:center(Assets.TOWER_LEFT:getWidth(), Assets.TOWER_LEFT:getHeight())

local positions = {
	left = {
		top = {
			x = center.width - 470,
			y = center.height - 200
		},
		bottom = {
			x = center.width - 470,
			y = center.height + 200
		}
	},
	right = {
		top = {
			x = center.width + 470,
			y = center.height - 200
		},
		bottom = {
			x = center.width + 470,
			y = center.height + 200
		}
	}
}

function Tower:new(side, position)
	if side ~= 'left' and side ~= 'right' then
		error('Invalid side for Tower')
	end

	if position ~= 'top' and position ~= 'bottom' then
		error('Invalid position for Tower')
	end

	local tower = {}

	for key, value in pairs(default_props) do
		tower[key] = value
	end

	tower.char_x = positions[side][position].x
	tower.char_y = positions[side][position].y

	tower.img = side == 'left' and Assets.TOWER_LEFT or Assets.TOWER_RIGHT

	tower.update = function(tower_, dt)
		return Tower.update(tower_, dt)
	end

	tower.draw = function(tower_, current_life)
		return Tower.draw(tower_, current_life)
	end

	setmetatable(tower, self)
	self.__index = self

	return tower
end

function Tower:update(dt) end

function Tower.draw(tower_, current_life)
	love.graphics.draw(tower_.img, tower_.char_x, tower_.char_y)
	Tower:lifebar(tower_.char_x + tower_.w / 4, tower_.char_y + tower_.h / 1.4, current_life)
	return tower_.char_x, tower_.char_y
end

function Tower:lifebar(x,y, current_life)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x, y, 100, 5)
	love.graphics.rectangle("fill", x, y, current_life, 5)
	love.graphics.setColor(255,255,255)
end

return Tower
