local Layout = require('src.helpers.layout')
local sti = require("lib.sti")

-- 1344 x 768
local Map = {
	-- indicates the max value in x to each side
	left_side = {
		w = 0,
		h = 0
	},
	right_side = {
		w = 0,
		h = 0
	},

	map = {},
	original_width = 1344,
	original_height = 768
}

function Map:load()
	self.map = sti('assets/world.lua')
	self.original_width, self.original_height = love.graphics.getDimensions()
	self:sides()
end

function Map:update(dt)
	self:refresh_bounds()
end

function Map:refresh_bounds()
	self:sides()
end

function Map:clamp_player_x(x)
	self:sides()
	if x <= self.left_side.w then
		return self.left_side.w
	end
	return x
end

function Map:draw()
	-- self.map:draw(nil, nil, scale_x, scale_y - 0.2)
	self.map:draw()
end

function Map:sides()
	local center = Layout:center(2, 2)

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

-- function love.resize(w, h)
-- 	Map.original_width, Map.original_height = w, h
-- end

return Map
