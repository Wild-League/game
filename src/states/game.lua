local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local Utils = require('src.helpers.utils')

local Map = require('src.entities.map')
local Tower = require('src.entities.tower')
local Deck = require('src.entities.deck')
local Timer = require('src.helpers.timer')
local Card = require('src.entities.card')

local Game = {
	timer = Timer:new()
}

-- Game:load_towers()

Map:load()
function Game:load()
	-- Deck:load()
	-- Game.deck = Deck.deck_selected
end

function Game:update(dt)
	Map:update(dt)

	Deck:update(dt)

	self.timer:update(dt)
end

function Game:draw()
	Map:draw()

	Deck:draw()

	self:draw_timer()
end

-- private functions ---------

function Game:load_towers()
	local tower1 = Tower:load('left', 'top')

	local tower2 = Tower:load('left', 'bottom')
end

-- function Game:preview_char(card,x,y)
-- 	-- attack range
-- 	love.graphics.ellipse("line", x, y, card.attack_range, card.attack_range)
-- 	-- perception range
-- 	love.graphics.ellipse("line", x, y, card.perception_range, card.perception_range)

-- 	-- represents the char preview
-- 	love.graphics.setColor(0.2,0.2,0.7,0.5)
-- 	love.graphics.draw(card.img_preview, card.char_x, card.char_y)
-- 	love.graphics.setColor(1,1,1)
-- end

function Game:draw_timer()
	local center_background = Layout:center(100, 100)
	love.graphics.setColor(0,0,0, 0.8)
	love.graphics.rectangle('fill', center_background.width, 10, 100, 50)
	love.graphics.setColor(1,1,1)

	local center_timer = Layout:center(100, 100)

	love.graphics.setColor(1,1,1)
	self.timer:draw(center_timer.width, 35, 100, 0)
	love.graphics.setColor(1,1,1)
end

return Game
