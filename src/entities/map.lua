local MatchUi = require('src.config.match_ui')
local sti = require("lib.sti")

local Map = {
	left_side = {
		w = 0,
		h = 0
	},
	right_side = {
		w = 0,
		h = 0
	},

	map = {},
	map_width = 1344,
	map_height = 768,
	scale_x = 1,
	scale_y = 1,
	cached_play_w = 0,
	cached_play_h = 0,
}

local function floor_play_height()
	return math.floor(love.graphics.getHeight() - MatchUi.deck_ui_height)
end

local function floor_play_width()
	return math.floor(love.graphics.getWidth())
end

function Map:load()
	self.map = sti('assets/world.lua')
	-- STI width/height are in tiles; pixel size is tiles * tile size.
	self.map_width = self.map.width * self.map.tilewidth
	self.map_height = self.map.height * self.map.tileheight

	-- STI draws tiles 1:1 onto a map-sized canvas, then scales to the screen.
	self.map:resize(self.map_width, self.map_height)
	if self.map.canvas then
		self.map.canvas:setFilter('nearest', 'nearest')
	end

	self:refresh_bounds(true)
end

function Map:update(dt)
	if self.map.update then
		self.map:update(dt)
	end
	self:refresh_bounds()
end

function Map:get_play_width()
	return self.cached_play_w > 0 and self.cached_play_w or floor_play_width()
end

function Map:get_play_height()
	return self.cached_play_h > 0 and self.cached_play_h or floor_play_height()
end

function Map:get_play_center()
	return self:get_play_width() / 2, self:get_play_height() / 2
end

function Map:refresh_bounds(force)
	local play_w = floor_play_width()
	local play_h = floor_play_height()

	if force or play_w ~= self.cached_play_w or play_h ~= self.cached_play_h then
		self.scale_x = play_w / self.map_width
		self.scale_y = play_h / self.map_height
		self.cached_play_w = play_w
		self.cached_play_h = play_h
	end

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
	-- Do not scissor here: STI renders via an internal canvas and scissor breaks that pass.
	love.graphics.setColor(1, 1, 1, 1)
	self.map:draw(0, 0, self.scale_x, self.scale_y)
end

function Map:sides()
	local play_w = self:get_play_width()
	local play_h = self:get_play_height()

	Map.left_side.w = play_w / 2
	Map.right_side.w = play_w

	Map.left_side.h = play_h
	Map.right_side.h = play_h
end

function Map:block_left_side()
	Map:sides()

	love.graphics.setColor(1, 0, 0, 0.5)
	love.graphics.rectangle('fill', 0, 0, Map.left_side.w, Map.left_side.h)

	love.graphics.setColor(1, 1, 1)
end

return Map
