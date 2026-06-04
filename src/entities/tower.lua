local Assets = require('src.assets')
local Map = require('src.entities.map')

local Tower = {
	enemies_around = {},
	layout_ref_width = 1344,
	layout_ref_height = 768,
	destroy_duration = 1.4,
}

local default_props = {
	type = 'tower',
	life = 100,
	current_life = 100,
	w = Assets.TOWER:getWidth(),
	h = Assets.TOWER:getHeight(),
	img = Assets.TOWER,
	destroying = false,
	destroy_elapsed = 0,
	hidden = false,
}

local function layout_slot(side, position)
	local center_x, center_y = Map:get_play_center()
	local play_w = Map:get_play_width()
	local play_h = Map:get_play_height()
	local scale_x = play_w / Tower.layout_ref_width
	local scale_y = play_h / Tower.layout_ref_height

	local red = { 255 / 255, 0 / 255, 0 / 255 }
	local green = { 0 / 255, 255 / 255, 0 / 255 }

	local positions = {
		left = {
			top = {
				x = center_x - 470 * scale_x,
				y = center_y - 180 * scale_y,
				scale_x = -2,
				color = red
			},
			bottom = {
				x = center_x - 470 * scale_x,
				y = center_y + 200 * scale_y,
				scale_x = -2,
				color = red
			}
		},
		right = {
			top = {
				x = center_x + 470 * scale_x,
				y = center_y - 180 * scale_y,
				scale_x = 2,
				color = green
			},
			bottom = {
				x = center_x + 470 * scale_x,
				y = center_y + 200 * scale_y,
				scale_x = 2,
				color = green
			}
		}
	}

	return positions[side][position]
end

function Tower:reposition(tower)
	if not tower or tower.type ~= 'tower' then return end

	local slot = layout_slot(tower.side, tower.position)
	tower.char_x = slot.x
	tower.char_y = slot.y
	tower.color = slot.color
	tower.scale_x = slot.scale_x
end

function Tower:start_destroy(tower)
	if not tower or tower.destroying or tower.hidden then
		return
	end
	tower.destroying = true
	tower.destroy_elapsed = 0
	tower.destroy_duration = tower.destroy_duration or self.destroy_duration
end

function Tower:load(side, position, tower_id)
	if side ~= 'left' and side ~= 'right' then
		error('Invalid side for Tower')
	end

	if position ~= 'top' and position ~= 'bottom' then
		error('Invalid position for Tower')
	end

	local slot = layout_slot(side, position)

	local tower = {}

	for key, value in pairs(default_props) do
		tower[key] = value
	end

	tower.side = side
	tower.position = position
	tower.tower_id = tower_id
	tower.char_x = slot.x
	tower.char_y = slot.y
	tower.color = slot.color
	tower.scale_x = slot.scale_x
	tower.scale_y = 2
	tower.destroy_duration = self.destroy_duration

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

function Tower:update(dt)
	if not self.destroying then
		return
	end

	self.destroy_elapsed = (self.destroy_elapsed or 0) + dt
	local duration = self.destroy_duration or Tower.destroy_duration
	if self.destroy_elapsed >= duration then
		self.hidden = true
		self.destroying = false
	end
end

function Tower.draw(tower_, current_life)
	if tower_.hidden then
		return
	end

	local alpha = 1
	if tower_.destroying then
		local duration = tower_.destroy_duration or Tower.destroy_duration
		local elapsed = tower_.destroy_elapsed or 0
		alpha = math.max(0, 1 - (elapsed / duration))
	end

	local life = current_life or tower_.current_life or tower_.life or 100
	love.graphics.setColor(1, 1, 1, alpha)
	love.graphics.draw(tower_.img, tower_.char_x, tower_.char_y, 0, tower_.scale_x, tower_.scale_y, tower_.w / 2,
		tower_.h / 2)

	local lifebar_x = tower_.char_x - (100 / 2)
	local lifebar_y = tower_.char_y - tower_.h * tower_.scale_y / 2 - 10

	Tower:lifebar(lifebar_x, lifebar_y, life, tower_.side, tower_.color, alpha)
	love.graphics.setColor(1, 1, 1, 1)
end

function Tower:lifebar(x, y, current_life, side, color, alpha)
	alpha = alpha or 1
	local r, g, b = color[1], color[2], color[3]
	love.graphics.setColor(r, g, b, alpha)

	local max_life = 100

	love.graphics.rectangle("line", x, y, max_life, 5)
	love.graphics.rectangle("fill", x, y, current_life, 5)
	love.graphics.setColor(1, 1, 1, 1)
end

function Tower:get_enemies_in_range(enemies)
	-- for k,v in pairs(enemies) do
	-- 	local has_collision = Utils.circle_rect_collision(
	-- 		self.char_x, self.char_y, self.perception_range/2,
	-- 		v.char_x, v.char_y, v.img_preview:getWidth(), v.img_preview:getHeight()
	-- 	)
	--
	-- 	self.enemies_around[k] = has_collision and v or nil
	-- end
end

return Tower
