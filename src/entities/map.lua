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
end

function Map:update(dt) end

function Map:draw()
	local scale_x = love.graphics.getWidth() / self.original_width
	local scale_y = love.graphics.getHeight() / self.original_height

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
