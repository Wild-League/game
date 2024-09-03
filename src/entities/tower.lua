local Utils = require('src.helpers.utils')
local Assets = require('src.assets')

local Tower = {
	enemies_around = {}
}

local default_props = {
	type = 'tower',
	life = 100,
	current_life = 100,
	w = Assets.TOWER:getWidth(),
	h = Assets.TOWER:getHeight(),
	img = Assets.TOWER
}

function Tower:load(side, position)
	if side ~= 'left' and side ~= 'right' then
		error('Invalid side for Tower')
	end

	if position ~= 'top' and position ~= 'bottom' then
		error('Invalid position for Tower')
	end

	local center = {
		width = love.graphics.getWidth() / 2,
		height = love.graphics.getHeight() / 2
	}

	local red = { 255/255, 0/255, 0/255 }
	local green = { 0/255, 255/255, 0/255 }

	local positions = {
		left = {
			top = {
				x = center.width - 470,
				y = center.height - 180,
				scale_x = -1,
				color = red
			},
			bottom = {
				x = center.width - 470,
				y = center.height + 200,
				scale_x = -1,
				color = red
			}
		},
		right = {
			top = {
				x = center.width + 470,
				y = center.height - 180,
				scale_x = 1 ,
				color = green
			},
			bottom = {
				x = center.width + 470,
				y = center.height + 200,
				scale_x = 1,
				color = green
			}
		}
	}

	local tower = {}

	for key, value in pairs(default_props) do
		tower[key] = value
	end

	tower.side = side
	tower.char_x = positions[side][position].x
	tower.char_y = positions[side][position].y
	tower.color = positions[side][position].color
	tower.scale_x = positions[side][position].scale_x

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
	love.graphics.draw(tower_.img, tower_.char_x, tower_.char_y, 0, tower_.scale_x, tower_.scale_y, tower_.w / 2, tower_.h / 2)

	local lifebar_x = tower_.char_x - (100 / 2)
	local lifebar_y = tower_.char_y - tower_.h * tower_.scale_y / 2 - 10
	Tower:lifebar(lifebar_x, lifebar_y, current_life, tower_.side,tower_.color)
end

function Tower:lifebar(x, y, current_life, side, color)

    love.graphics.setColor(color)

    -- Desenhar a lifebar
    love.graphics.rectangle("line", x, y, 100, 5)
    love.graphics.rectangle("fill", x, y, current_life, 5)
    love.graphics.setColor(255, 255, 255)
end

function Tower:get_enemies_in_range(enemies)
	for k,v in pairs(enemies) do
		local has_collision = Utils.circle_rect_collision(
			self.char_x, self.char_y, self.perception_range/2,
			v.char_x, v.char_y, v.img_preview:getWidth(), v.img_preview:getHeight()
		)

		self.enemies_around[k] = has_collision and v or nil
	end
end

return Tower
